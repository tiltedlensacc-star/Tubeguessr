import Foundation

class PersistenceManager: ObservableObject {
    static let shared = PersistenceManager()

    private static let sharedEncoder = JSONEncoder()
    private static let sharedDecoder = JSONDecoder()

    private let userDefaults = UserDefaults.standard
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()

    private let currentGameKey = "currentGame"
    private let statsKey = "gameStats"
    private let lastPlayedDateKey = "lastPlayedDate"

    @Published var currentGame: GameRound?
    @Published var stats: GameStats

    private init() {
        self.stats = PersistenceManager.loadStats()
        self.currentGame = PersistenceManager.loadCurrentGame()
    }

    func saveCurrentGame(_ game: GameRound) {
        currentGame = game
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            if let encoded = try? self.jsonEncoder.encode(game) {
                DispatchQueue.main.async {
                    self.userDefaults.set(encoded, forKey: self.currentGameKey)
                }
            }
        }
    }

    func saveStats(_ newStats: GameStats) {
        stats = newStats
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            if let encoded = try? self.jsonEncoder.encode(newStats) {
                DispatchQueue.main.async {
                    self.userDefaults.set(encoded, forKey: self.statsKey)
                }
            }
        }
    }

    func saveLastPlayedDate(_ date: Date) {
        userDefaults.set(date, forKey: lastPlayedDateKey)
    }

    func getLastPlayedDate() -> Date? {
        return userDefaults.object(forKey: lastPlayedDateKey) as? Date
    }

    func canPlayToday(isPremium: Bool = false) -> Bool {
        if isPremium {
            return true // Premium users can always play
        }
        guard let lastPlayed = getLastPlayedDate() else { return true }
        return !Calendar.current.isDate(lastPlayed, inSameDayAs: Date())
    }

    func clearCurrentGame() {
        currentGame = nil
        userDefaults.removeObject(forKey: currentGameKey)
    }

    func completeGame(_ game: GameRound, won: Bool) {
        var gameToSave = game

        gameToSave.isCompleted = true
        gameToSave.isWin = won

        var newStats = stats
        newStats.totalGames += 1

        if won {
            newStats.totalWins += 1
            newStats.currentStreak += 1
            newStats.maxStreak = max(newStats.maxStreak, newStats.currentStreak)
        } else {
            newStats.currentStreak = 0
        }

        var hintsUsedCount = 0
        if gameToSave.hintsUsed {
            hintsUsedCount += 1
        }
        if gameToSave.locationHintUsed {
            hintsUsedCount += 1
        }
        newStats.totalHintsUsed += hintsUsedCount

        newStats.history.append(gameToSave)

        // Track recent station IDs for uniqueness
        newStats.recentStationIds.append(gameToSave.station.id)
        if newStats.recentStationIds.count > 15 {
            newStats.recentStationIds.removeFirst()
        }

        // Invalidate cached calculations since history changed
        newStats.invalidateCache()

        saveStats(newStats)
        saveLastPlayedDate(Date())
        // Clear the current game since it's now saved in history
        clearCurrentGame()
    }

    func resetForTesting() {
        userDefaults.removeObject(forKey: lastPlayedDateKey)
        userDefaults.removeObject(forKey: "gameStats")
        clearCurrentGame()
    }

    private static func loadCurrentGame() -> GameRound? {
        guard let data = UserDefaults.standard.data(forKey: "currentGame"),
              let game = try? sharedDecoder.decode(GameRound.self, from: data) else {
            return nil
        }
        return game
    }

    private static func loadStats() -> GameStats {
        guard let data = UserDefaults.standard.data(forKey: "gameStats"),
              let stats = try? sharedDecoder.decode(GameStats.self, from: data) else {
            return GameStats()
        }
        return stats
    }
}