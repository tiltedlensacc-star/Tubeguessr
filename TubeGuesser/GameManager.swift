import Foundation
import UIKit

@MainActor
class GameManager: ObservableObject {
    static let shared = GameManager()

    @Published var currentGame: GameRound?
    @Published var gameState: GameState = .waiting

    private let persistenceManager = PersistenceManager.shared
    private let stationsData = StationsData.shared
    private var testingDayOffset: Int = 0

    // Track subscription status
    private var isPremiumUser: Bool = false

    // Track when the app was last resumed (for pause/resume timer)
    private var sessionStartTime: Date?

    enum GameState {
        case waiting
        case playing
        case completed
        case alreadyPlayed
    }

    private init() {
        syncPremiumStatus()
        checkGameState()
        setupAppLifecycleObservers()
    }

    private func setupAppLifecycleObservers() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.appWillResignActive()
            }
        }

        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.appDidBecomeActive()
            }
        }
    }

    private func appWillResignActive() {
        // Save the current elapsed time when app goes to background
        guard var game = currentGame, !game.isCompleted, gameState == .playing else { return }

        if let sessionStart = sessionStartTime {
            let currentSessionTime = Date().timeIntervalSince(sessionStart)
            game.accumulatedElapsedTime += currentSessionTime
            currentGame = game
            persistenceManager.saveCurrentGame(game)
        }
        sessionStartTime = nil
    }

    private func appDidBecomeActive() {
        // Resume the timer when app comes back to foreground
        guard let game = currentGame, !game.isCompleted, gameState == .playing else { return }

        sessionStartTime = Date()
    }

    func checkGameState() {
        // First check if there's a current game
        if let existingGame = persistenceManager.currentGame {
            // If the current game is from a previous day, clear it
            if !Calendar.current.isDate(existingGame.date, inSameDayAs: Date()) {
                persistenceManager.clearCurrentGame()
            } else {
                if existingGame.isCompleted {
                    currentGame = existingGame
                    gameState = .completed
                    return
                } else {
                    currentGame = existingGame
                    gameState = .playing
                    // Start a new session when resuming a game in progress
                    if sessionStartTime == nil {
                        sessionStartTime = Date()
                    }
                    return
                }
            }
        }

        // Check if there's a completed game from today in history
        if let lastCompletedGame = persistenceManager.stats.history.last,
           Calendar.current.isDate(lastCompletedGame.date, inSameDayAs: Date()) {
            currentGame = lastCompletedGame
            gameState = .completed
            return
        }

        // If no current game and haven't played today, check if we can play
        if !persistenceManager.canPlayToday(isPremium: isPremiumUser) {
            gameState = .alreadyPlayed
            return
        }

        gameState = .waiting
    }

    func startNewGame() {
        // Sync premium status from SubscriptionManager before starting new game
        isPremiumUser = SubscriptionManager.shared.hasActiveSubscription

        // If current game is completed and user is premium, clear it to allow new round
        if let existingGame = currentGame, existingGame.isCompleted, isPremiumUser {
            persistenceManager.clearCurrentGame()
            currentGame = nil
        }

        guard persistenceManager.canPlayToday(isPremium: isPremiumUser) else {
            gameState = .alreadyPlayed
            return
        }

        // Clear notification badge when user starts playing
        NotificationManager.shared.clearBadge()

        // Create the game with a consistent start time
        let gameStartTime = Date()
        let station = selectDailyStation()
        let newGame = GameRound(station: station, date: gameStartTime)

        currentGame = newGame
        persistenceManager.saveCurrentGame(newGame)
        gameState = .playing

        // Start a new timer session
        sessionStartTime = Date()
    }

    func makeGuess(_ guess: String, completionTime: TimeInterval? = nil) -> Bool {
        guard var game = currentGame,
              !game.isCompleted,
              game.remainingGuesses > 0 else {
            return false
        }

        game.guesses.append(guess)

        let isCorrect = isGuessCorrect(guess, for: game.station)

        currentGame = game

        if isCorrect {
            game.isCompleted = true
            game.isWin = true
            game.completionTime = completionTime
            currentGame = game
            persistenceManager.completeGame(game, won: true)
            gameState = .completed
        } else if game.remainingGuesses == 0 {
            game.isCompleted = true
            game.isWin = false
            game.completionTime = completionTime
            currentGame = game
            persistenceManager.completeGame(game, won: false)
            gameState = .completed
        } else {
            persistenceManager.saveCurrentGame(game)
        }
        return isCorrect
    }

    func useHint() {
        guard var game = currentGame, !game.hintsUsed else { return }

        game.hintsUsed = true
        currentGame = game
        persistenceManager.saveCurrentGame(game)
    }

    func useLocationHint() {
        guard var game = currentGame, !game.locationHintUsed else { return }

        game.locationHintUsed = true
        currentGame = game
        persistenceManager.saveCurrentGame(game)
    }

    func resetForTesting() {
        persistenceManager.resetForTesting()
        testingDayOffset += 1
        currentGame = nil
        gameState = .waiting
    }

    func getCurrentElapsedTime() -> TimeInterval {
        guard let game = currentGame else { return 0 }

        // If game is completed, return the completion time
        if game.isCompleted, let completionTime = game.completionTime {
            return completionTime
        }

        // Calculate current elapsed time: accumulated time + current session time
        let currentSessionTime: TimeInterval
        if let sessionStart = sessionStartTime {
            currentSessionTime = Date().timeIntervalSince(sessionStart)
        } else {
            currentSessionTime = 0
        }

        let totalElapsedTime = game.accumulatedElapsedTime + currentSessionTime
        return max(0, totalElapsedTime) // Ensure non-negative time
    }

    private func selectDailyStation() -> Station {
        let multiLineStations = stationsData.multiLineStations
        let recentStationIds = Set(persistenceManager.stats.recentStationIds)

        let calendar = Calendar.current
        let today = Date()
        let baseDayOfYear = calendar.ordinality(of: .day, in: .year, for: today) ?? 1
        let effectiveDayOfYear = baseDayOfYear + testingDayOffset

        // Filter out recently used stations (last 15 games)
        let availableStations = multiLineStations.filter { station in
            !recentStationIds.contains(station.id)
        }

        // Choose from available stations, or all stations if we've exhausted the available ones
        // This ensures we always have stations to choose from even with limited total multiline stations
        let stationsToChooseFrom = availableStations.isEmpty ? multiLineStations : availableStations

        // Use day-based seeding for consistent daily station
        var randomGenerator = SeededRandomGenerator(seed: UInt64(effectiveDayOfYear * 1000))
        let randomIndex = Int(randomGenerator.next()) % stationsToChooseFrom.count

        let selectedStation = stationsToChooseFrom[randomIndex]

        return selectedStation
    }

    private func isGuessCorrect(_ guess: String, for station: Station) -> Bool {
        let normalizedGuess = normalizeStationName(guess)

        // Exact match
        if normalizedGuess == station.normalizedName {
            return true
        }

        // Check for 1-character difference (fuzzy matching)
        return isOneCharacterDifferent(normalizedGuess, station.normalizedName)
    }

    private func normalizeStationName(_ name: String) -> String {
        var normalized = name.lowercased()

        // Remove all types of apostrophes and quotes
        let apostrophes = ["'", "\u{2018}", "\u{2019}"] // straight, left single, right single
        for apostrophe in apostrophes {
            normalized = normalized.replacingOccurrences(of: apostrophe, with: "")
        }

        let quotes = ["\"", "\u{201C}", "\u{201D}"] // straight, left double, right double
        for quote in quotes {
            normalized = normalized.replacingOccurrences(of: quote, with: "")
        }

        // Remove other punctuation and spaces
        normalized = normalized
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: "&", with: "and")

        return normalized
    }

    private func isOneCharacterDifferent(_ guess: String, _ correct: String) -> Bool {
        let guessArray = Array(guess)
        let correctArray = Array(correct)

        // If length difference is more than 1, not a single character error
        if abs(guessArray.count - correctArray.count) > 1 {
            return false
        }

        // Same length: check for substitution
        if guessArray.count == correctArray.count {
            var differences = 0
            for i in 0..<guessArray.count {
                if guessArray[i] != correctArray[i] {
                    differences += 1
                    if differences > 1 {
                        return false
                    }
                }
            }
            return differences == 1
        }

        // Different length by 1: check for insertion or deletion
        let (shorter, longer) = guessArray.count < correctArray.count ? (guessArray, correctArray) : (correctArray, guessArray)

        var shorterIndex = 0
        var longerIndex = 0
        var foundDifference = false

        while shorterIndex < shorter.count && longerIndex < longer.count {
            if shorter[shorterIndex] != longer[longerIndex] {
                if foundDifference {
                    return false // More than one difference
                }
                foundDifference = true
                longerIndex += 1 // Skip the extra character in longer string
            } else {
                shorterIndex += 1
                longerIndex += 1
            }
        }

        return true
    }

    func updatePremiumStatus(_ isPremium: Bool) {
        isPremiumUser = isPremium
        // Re-check game state when premium status changes
        checkGameState()
    }

    func syncPremiumStatusFromSubscriptionManager() {
        let hasActiveSubscription = SubscriptionManager.shared.hasActiveSubscription
        isPremiumUser = hasActiveSubscription
        checkGameState()
    }

    private func syncPremiumStatus() {
        let hasActiveSubscription = SubscriptionManager.shared.hasActiveSubscription
        isPremiumUser = hasActiveSubscription
    }

    func resetAppData() {
        persistenceManager.resetForTesting()
        currentGame = nil
        gameState = .waiting
        // Increment day offset to get a new station each reset
        testingDayOffset += 1
    }
}

struct SeededRandomGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 1103515245 &+ 12345
        return state
    }
}