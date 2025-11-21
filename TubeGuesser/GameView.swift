import SwiftUI
import StoreKit


struct GameView: View {
    @ObservedObject private var gameManager = GameManager.shared
    @State private var currentGuess = ""
    @State private var showHint = false
    @State private var feedback = ""
    @State private var showFeedback = false
    @Binding var showWelcomeScreen: Bool
    @State private var hintRevealed = false
    @State private var locationHintRevealed = false
    @State private var showInfo = false
    @State private var showStats = false
    @State private var showHowToPlay = false
    @State private var showSubscription = false
    @State private var showSeasonTicketUpgrade = false
    // Real StoreKit subscription manager
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    @State private var magnifyingGlassOffset = CGSize.zero
    @State private var magnifyingGlassRotation: Double = 0
    @State private var congratsScale: CGFloat = 0
    @State private var congratsShakeOffset: CGFloat = 0
    @State private var seasonTicketButtonScale: CGFloat = 1.0
    @State private var displayTime: TimeInterval = 0

    init(showWelcomeScreen: Binding<Bool> = .constant(false)) {
        self._showWelcomeScreen = showWelcomeScreen
    }


    private func updateDisplayTime() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.updateDisplayTime()
            }
            return
        }

        displayTime = gameManager.getCurrentElapsedTime()
    }

    @State private var showHintUsedPopup = false
    @State private var hasUsedTriviaHint = false
    @State private var hasUsedLocationHint = false
    @State private var hintPopupMessage = "First hint used!"
    @State private var showIncorrectPopup = false

    var body: some View {
        Group {
            if showWelcomeScreen {
                welcomeScreenView
                    .toolbar(.hidden, for: .tabBar)
            } else {
            VStack(spacing: 0) {
                // Sticky title
                VStack(spacing: 0) {
                    HStack {
                        // Premium button (if not subscribed)
                        if !subscriptionManager.hasActiveSubscription {
                            Button(action: {
                                showSeasonTicketUpgrade = true
                            }) {
                                Image(systemName: "ticket.fill")
                                    .foregroundColor(.yellow)
                                    .font(.title2)
                            }
                        } else {
                            // Invisible spacer for premium users
                            Button(action: {}) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(Color.clear)
                                    .font(.title2)
                            }
                            .disabled(true)
                        }

                        Spacer()

                        Text("TubeGuessr")
                            .font(.system(size: 20, weight: .bold, design: .serif))
                            .foregroundColor(Color(hex: "#2E7DF6"))

                        Spacer()

                        Button(action: {
                            showInfo = true
                        }) {
                            Image(systemName: "info.circle")
                                .foregroundColor(Color(hex: "#2E7DF6"))
                                .font(.title2)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    .padding(.bottom, 12)
                    .background(Color(UIColor.systemBackground))

                    Divider()
                        .padding(.vertical, 8)
                }

                ScrollView {
                    VStack(spacing: 20) {
                        headerViewWithoutTitle

                        switch gameManager.gameState {
                        case .waiting:
                            startGameView
                        case .playing:
                            playingGameView
                        case .completed, .alreadyPlayed:
                            completedGameView
                        }
                    }

                    Spacer(minLength: 50)
                }
                .padding()
            }
            .onAppear {
                // Always check game state, but it should respect existing completed/alreadyPlayed states
                gameManager.checkGameState()
                updateDisplayTime()

                // Initialize subscription manager
                Task {
                    await subscriptionManager.loadSubscriptions()
                    await subscriptionManager.updateCustomerProductStatus()
                }
            }
            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                guard gameManager.gameState == .playing else { return }
                updateDisplayTime()
            }
            .onChange(of: gameManager.gameState) { _, newState in
                // Reset hints when game state changes
                if newState == .playing {
                    hintRevealed = false
                    locationHintRevealed = false
                }
            }
            .overlay(
                hintUsedPopup
            )
            .overlay(
                incorrectPopup
            )
            }
        }
        .sheet(isPresented: $showInfo) {
            InfoView()
        }
        .sheet(isPresented: $showSeasonTicketUpgrade) {
            SeasonTicketUpgradeView()
        }
        .fullScreenCover(isPresented: $showStats) {
            StatsView(showBackButton: true, onDismiss: {
                showStats = false
            })
        }
        .fullScreenCover(isPresented: $showHowToPlay) {
            InfoView(showBackButton: true, onDismiss: {
                showHowToPlay = false
            })
        }
        .fullScreenCover(isPresented: $showSubscription) {
            SubscriptionView()
        }
    }

    private var hintUsedPopup: some View {
        Group {
            if showHintUsedPopup {
                VStack(spacing: 0) {
                    Spacer()
                    HStack(spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.white)
                            .font(.headline)
                        Text(hintPopupMessage)
                    }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "#2E7DF6").opacity(0.8))
                        .cornerRadius(8)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 30)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .background(Color.clear)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: showHintUsedPopup)
            }
        }
    }

    private var incorrectPopup: some View {
        Group {
            if showIncorrectPopup {
                VStack(spacing: 0) {
                    Spacer()
                    HStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.headline)
                        Text("Incorrect! Try again.")
                    }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 30)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .background(Color.clear)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: showIncorrectPopup)
            }
        }
    }

    private var welcomeScreenView: some View {
        ZStack {
            Color(hex: "#2E7DF6")
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()
                Spacer()
                Spacer()

                VStack(spacing: 20) {
                    ZStack {
                        TubeMapGraphic()
                            .frame(width: 320, height: 220)

                        // Magnifying glass icon overlaid on the map
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 80))
                            .foregroundColor(.black)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 2)
                            .offset(magnifyingGlassOffset)
                            .rotationEffect(.degrees(magnifyingGlassRotation))
                            .onAppear {
                                withAnimation(
                                    Animation.easeInOut(duration: 3.0)
                                        .repeatForever(autoreverses: true)
                                ) {
                                    magnifyingGlassOffset = CGSize(width: 30, height: 20)
                                }

                                withAnimation(
                                    Animation.easeInOut(duration: 4.0)
                                        .repeatForever(autoreverses: true)
                                ) {
                                    magnifyingGlassRotation = 10
                                }
                            }
                    }
                    .padding(.bottom, 10)

                    Text("TubeGuessr")
                        .font(.system(size: 48, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("Can you guess the tube station\nfrom its lines?")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 10)
                }

                Spacer()

                VStack(spacing: 20) {
                    Text(dayString)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.bottom, 10)

                    Button(action: {
                        showWelcomeScreen = false
                        gameManager.startNewGame()
                    }) {
                        Text("Play")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                            .frame(width: 280, height: 50)
                            .background(Color.white)
                            .cornerRadius(25)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: {
                        showStats = true
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color(hex: "#2E7DF6"))
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 280, height: 50)

                            Text("Your Stats")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 280, height: 50)
                    .buttonStyle(PlainButtonStyle())

                    Button("How to Play?") {
                        showHowToPlay = true
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                    .underline()
                    .padding(.top, 8)
                }
                .padding(.bottom, 100)
            }
        }
    }

    private var welcomeScreenViewWithoutTitle: some View {
        VStack(spacing: 30) {
            Text(dayString)
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.top, 20)

            Button("Play") {
                showWelcomeScreen = false
                if gameManager.gameState == .waiting {
                    gameManager.startNewGame()
                }
            }
            .buttonStyle(TubeButtonStyle())
        }
    }

    private var headerView: some View {
        VStack {
            Text("TubeGuessr")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#2E7DF6"))
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)

            Text(dayString)
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)

            Text(timeString)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(gameManager.gameState == .completed && gameManager.currentGame?.isWin == true ? Color.green : Color.red)
                .cornerRadius(8)
                .padding(.top, 8)
        }
    }

    private var headerViewWithoutTitle: some View {
        VStack {
            Text(timeString)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(gameManager.gameState == .completed && gameManager.currentGame?.isWin == true ? Color.green : Color.red)
                .cornerRadius(8)
                .padding(.top, 12)
        }
    }

    private var startGameView: some View {
        VStack(spacing: 20) {
            Text("Ready for today's challenge?")
                .font(.title2)
                .multilineTextAlignment(.center)

            Button("Start Game") {
                gameManager.startNewGame()
            }
            .buttonStyle(TubeButtonStyle())
        }
    }

    private var playingGameView: some View {
        VStack(spacing: 30) {
            if let game = gameManager.currentGame {
                linesDisplayView(for: game.station)

                VStack(spacing: 20) {
                    Text("What station are you at?")
                        .font(.headline)

                    HStack(spacing: 8) {
                        TextField("Enter station name", text: $currentGuess)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.gray.opacity(0.15))
                                    .contentShape(Rectangle())
                            )
                            .contentShape(Rectangle())
                            .onSubmit {
                                makeGuess()
                            }

                        Button(action: {
                            makeGuess()
                        }) {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .frame(width: 44, height: 44)
                        .background(Color(hex: "#2E7DF6"))
                        .cornerRadius(22)
                        .disabled(currentGuess.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }

                    if let game = gameManager.currentGame {
                        VStack(spacing: 15) {
                            HStack(spacing: 8) {
                                Button(action: {
                                    gameManager.useLocationHint()
                                    locationHintRevealed = true
                                    hintRevealed = false

                                    if !hasUsedLocationHint {
                                        hasUsedLocationHint = true
                                        if hasUsedTriviaHint {
                                            hintPopupMessage = "Both hints used!"
                                        } else {
                                            hintPopupMessage = "First hint used!"
                                        }
                                        showHintUsedPopup = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            withAnimation(.easeOut(duration: 0.5)) {
                                                showHintUsedPopup = false
                                            }
                                        }
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        if game.guesses.isEmpty {
                                            Image(systemName: "lock.fill")
                                                .foregroundColor(.gray)
                                                .font(.caption)
                                        }
                                        Text("Location")
                                            .foregroundColor(game.guesses.isEmpty ? .gray : .black)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .frame(maxWidth: .infinity)
                                .buttonStyle(TubeButtonStyle(backgroundColor: locationHintRevealed ? Color.red.opacity(0.3) : Color.white))
                                .disabled(game.guesses.isEmpty)

                                Button(action: {
                                    gameManager.useHint()
                                    hintRevealed = true
                                    locationHintRevealed = false

                                    if !hasUsedTriviaHint {
                                        hasUsedTriviaHint = true
                                        if hasUsedLocationHint {
                                            hintPopupMessage = "Both hints used!"
                                        } else {
                                            hintPopupMessage = "First hint used!"
                                        }
                                        showHintUsedPopup = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            withAnimation(.easeOut(duration: 0.5)) {
                                                showHintUsedPopup = false
                                            }
                                        }
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        if game.guesses.count < 3 {
                                            Image(systemName: "lock.fill")
                                                .foregroundColor(.gray)
                                                .font(.caption)
                                        }
                                        Text("Trivia hint")
                                            .foregroundColor(game.guesses.count < 3 ? .gray : .black)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .frame(maxWidth: .infinity)
                                .buttonStyle(TubeButtonStyle(backgroundColor: hintRevealed ? Color.red.opacity(0.3) : Color.white))
                                .disabled(game.guesses.count < 3)
                            }
                            .frame(maxWidth: .infinity)

                            if hintRevealed {
                                Text("\(game.station.trivia.prefix(1).uppercased() + game.station.trivia.dropFirst())")
                                    .frame(maxWidth: .infinity)
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                            } else if locationHintRevealed {
                                Text("Located in \(game.station.location)")
                                    .frame(maxWidth: .infinity)
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 24)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)


                guessesView(for: game)
            }
        }
    }

    private var completedGameView: some View {
        VStack(spacing: 20) {
            if let game = gameManager.currentGame ?? PersistenceManager.shared.stats.history.last {
                linesDisplayView(for: game.station)

                VStack(spacing: 0) {
                    if game.isWin {
                        // Green top half
                        VStack(spacing: 5) {
                            Text("Congratulations!")
                                .font(.system(size: 24, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                                .padding(.bottom, 5)

                            Image(systemName: "tram.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                                .padding(.vertical, 5)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .padding(.horizontal, 30)
                        .background(Color.green)

                        // White bottom half
                        VStack(spacing: 10) {
                            Text("\(game.station.name)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)

                            Text("You got it in \(game.guesses.count) \(game.guesses.count == 1 ? "guess" : "guesses")!")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .padding(.horizontal, 30)
                        .background(Color.white)
                    } else {
                        // Red top half
                        VStack(spacing: 5) {
                            Text("Better luck tomorrow!")
                                .font(.system(size: 20, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                                .padding(.bottom, 5)

                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                                .padding(.vertical, 5)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .padding(.horizontal, 30)
                        .background(Color.red)

                        // White bottom half
                        VStack(spacing: 10) {
                            Text("The station was:")
                                .font(.headline)
                                .foregroundColor(.gray)

                            Text("\(game.station.name)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .padding(.horizontal, 30)
                        .background(Color.white)
                    }
                }
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 30)
                .scaleEffect(congratsScale)
                .onAppear {
                    congratsScale = 0

                    withAnimation(
                        Animation.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0)
                    ) {
                        congratsScale = 1
                    }
                }

            }

            if !SubscriptionManager.shared.hasActiveSubscription {
                premiumPrompt
            } else {
                // Premium user - show "Next Mystery Station" button
                Button(action: {
                    gameManager.startNewGame()
                }) {
                    HStack {
                        Text("Next Mystery Station")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(hex: "#2E7DF6"))
                    .foregroundColor(.white)
                    .cornerRadius(25)
                }
                .padding(.horizontal)
            }
        }
    }

    private var premiumPrompt: some View {
        VStack(spacing: 15) {
            VStack(spacing: 15) {
                Text("Want to play more?")
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("Get a Season Ticket for unlimited daily games plus access to advanced stats!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Text("Starting at £0.99/month with a 7-day free trial")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Button(action: {
                    // Button press animation
                    withAnimation(.easeInOut(duration: 0.1)) {
                        seasonTicketButtonScale = 0.95
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            seasonTicketButtonScale = 1.0
                        }
                        // Show subscription view
                        showSubscription = true
                    }
                }) {
                    HStack {
                        Image(systemName: "ticket.fill")
                            .foregroundColor(.black)
                        Text("Get a Season Ticket")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(22)
                    .scaleEffect(seasonTicketButtonScale)
                    .shadow(color: .yellow.opacity(0.4), radius: seasonTicketButtonScale == 0.95 ? 2 : 4, x: 0, y: 2)
                }
            }
            .padding()
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
            )

            Text("Otherwise, come back tomorrow for a new station!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var alreadyPlayedView: some View {
        VStack(spacing: 20) {
            Text("🕐 You've already played today!")
                .font(.title)
                .fontWeight(.bold)

            Text("Come back tomorrow for a new challenge!")
                .font(.headline)
                .foregroundColor(.secondary)

            Button("🔄 Reset for Testing") {
                gameManager.resetForTesting()
            }
            .buttonStyle(TubeButtonStyle(backgroundColor: Color.gray))
        }
    }

    private func linesDisplayView(for station: Station) -> some View {
        VStack(spacing: 10) {
            Text("Served by these lines:")
                .font(.headline)
                .padding(.top, 12)
                .padding(.bottom, 8)

            VStack(spacing: 8) {
                ForEach(station.lines) { line in
                    HStack {
                        ZStack {
                            if line.name == "National Rail" {
                                Image(systemName: "train.side.front.car")
                                    .foregroundColor(Color(hex: line.colorCode))
                                    .font(.system(size: 14, weight: .semibold))
                                    .frame(width: 18, height: 18)
                            } else {
                                Circle()
                                    .fill(Color(hex: line.colorCode))
                                    .frame(width: 18, height: 18)

                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 8, height: 8)
                            }
                        }

                        Text(line.name)
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func guessesView(for game: GameRound) -> some View {
        VStack(alignment: .center, spacing: 5) {
            Text("Guesses (\(game.guesses.count)/5)")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)

            ForEach(Array(game.guesses.enumerated()), id: \.offset) { index, guess in
                HStack {
                    Text("\(index + 1).")
                        .fontWeight(.medium)
                    Text(guess)
                    Spacer()
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
                .padding(.vertical, 2)
            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func hintSection(for game: GameRound) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 15) {
                if !hintRevealed {
                    Button("💡 Use Hint") {
                        gameManager.useHint()
                        hintRevealed = true
                    }
                    .buttonStyle(TubeButtonStyle(backgroundColor: Color(hex: "#DC241F")))
                }

                Button("💡 Use Hint 2") {
                    gameManager.useHint()
                    hintRevealed = true
                }
                .buttonStyle(TubeButtonStyle(backgroundColor: Color(hex: "#007D32")))
            }

            if hintRevealed {
                triviaView(for: game.station)
            }

            if locationHintRevealed {
                locationView(for: game.station)
            }
        }
    }

    private func triviaView(for station: Station) -> some View {
        VStack(alignment: .center, spacing: 5) {
            Text("💡 Hint")
                .font(.headline)
                .foregroundColor(Color(hex: "#DC241F"))

            Text(station.trivia)
                .font(.body)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
                .background(Color(hex: "#DC241F").opacity(0.1))
                .cornerRadius(10)
        }
    }

    private func locationView(for station: Station) -> some View {
        VStack(alignment: .center, spacing: 5) {
            Text("📍 Location")
                .font(.headline)
                .foregroundColor(Color(hex: "#007D32"))

            Text(station.location)
                .font(.body)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
                .background(Color(hex: "#007D32").opacity(0.1))
                .cornerRadius(10)
        }
    }

    private var dayString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: Date())
    }

    private func makeGuess() {
        let guess = currentGuess.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !guess.isEmpty else { return }

        let isCorrect = gameManager.makeGuess(guess, completionTime: gameManager.getCurrentElapsedTime())

        if isCorrect {
            feedback = "🎉 Correct! Well done!"
            showFeedback = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showFeedback = false
            }
        } else {
            if let game = gameManager.currentGame, game.remainingGuesses == 0 {
                feedback = "😔 Out of guesses! The answer was \(game.station.name)"
                showFeedback = true
            } else {
                showIncorrectPopup = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showIncorrectPopup = false
                    }
                }
            }
        }

        currentGuess = ""
    }

    private var timeString: String {
        let timeToShow: TimeInterval

        // If we're showing completed results and have today's completed game, show its completion time
        if gameManager.gameState == .completed || gameManager.gameState == .alreadyPlayed {
            if let completedGame = gameManager.currentGame ?? PersistenceManager.shared.stats.history.last {
                timeToShow = completedGame.completionTime ?? displayTime
            } else {
                timeToShow = displayTime
            }
        } else {
            timeToShow = displayTime
        }

        let minutes = Int(timeToShow) / 60
        let seconds = Int(timeToShow) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // Helper functions for congratulations decorative elements
    private func starShape() -> some Shape {
        StarShape()
    }

    private func decorativeStarburst() -> some View {
        ZStack {
            ForEach(0..<8) { i in
                Rectangle()
                    .fill(Color.yellow)
                    .frame(width: 3, height: 15)
                    .rotationEffect(.degrees(Double(i) * 45))
            }
        }
        .frame(width: 30, height: 30)
    }

    private func decorativeCircle(filled: Bool = true) -> some View {
        Circle()
            .fill(filled ? Color.orange : Color.clear)
            .stroke(Color.white, lineWidth: filled ? 0 : 3)
            .frame(width: 12, height: 12)
    }

    private func decorativeTriangle(color: Color) -> some View {
        Path { path in
            path.move(to: CGPoint(x: 8, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 14))
            path.addLine(to: CGPoint(x: 16, y: 14))
            path.closeSubpath()
        }
        .fill(color)
        .frame(width: 16, height: 14)
    }

    private func decorativeSquare(color: Color) -> some View {
        Rectangle()
            .fill(color)
            .frame(width: 12, height: 12)
    }

    private func ribbonTail() -> some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 25, y: 0))
            path.addLine(to: CGPoint(x: 20, y: 40))
            path.addLine(to: CGPoint(x: 5, y: 40))
            path.closeSubpath()
        }
        .fill(Color.blue)
    }
}

struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.6
        let numberOfPoints = 8

        for i in 0..<numberOfPoints {
            let angle = (Double(i) * 2 * .pi) / Double(numberOfPoints) - .pi / 2
            let x = center.x + cos(angle) * outerRadius
            let y = center.y + sin(angle) * outerRadius

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }

            // Add inner point
            let innerAngle = angle + (.pi / Double(numberOfPoints))
            let innerX = center.x + cos(innerAngle) * innerRadius
            let innerY = center.y + sin(innerAngle) * innerRadius
            path.addLine(to: CGPoint(x: innerX, y: innerY))
        }

        path.closeSubpath()
        return path
    }
}

struct InfoView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared

    var showBackButton: Bool = false
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Sticky title
            VStack(spacing: 0) {
                HStack {
                    if showBackButton {
                        Button("← Home") {
                            if let onDismiss = onDismiss {
                                onDismiss()
                            } else {
                                dismiss()
                            }
                        }
                        .foregroundColor(Color(hex: "#2E7DF6"))
                    }

                    Spacer()

                    Text("How to Play")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundColor(Color(hex: "#2E7DF6"))

                    Spacer()

                    if showBackButton {
                        // Invisible placeholder for centering
                        Button("← Home") {
                            // Placeholder
                        }
                        .foregroundColor(Color.clear)
                        .disabled(true)
                    }
                }
                .padding(.horizontal)
                .padding(.top, showBackButton ? 12 : 20)
                .padding(.bottom, 12)
                .background(Color(UIColor.systemBackground))

                Divider()
                    .padding(.vertical, 8)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 35) {
                    VStack(alignment: .leading, spacing: 25) {
                        HStack {
                            Image(systemName: "target")
                                .foregroundColor(Color(hex: "#2E7DF6"))
                            Text("Objective")
                        }
                        .font(.headline)
                        .fontWeight(.bold)

                        Text("Everyday, we challenge you to guess the mystery London Underground station we've picked.")
                            .font(.body)

                        Text("But the only hint we give you are the tube lines that serve it.")
                            .font(.body)

                        HStack {
                            Image(systemName: "gamecontroller")
                                .foregroundColor(Color(hex: "#2E7DF6"))
                            Text("How to Play")
                        }
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.top, 10)

                        Text("• You'll be shown a number of tube lines, these lines represent the lines that the station uses.")
                            .font(.body)

                        Text("• Guess the station by typing it in the text field.")
                            .font(.body)

                        Text("• You have 5 attempts to guess correctly.")
                            .font(.body)

                        HStack {
                            Image(systemName: "lightbulb")
                                .foregroundColor(Color(hex: "#2E7DF6"))
                            Text("Hints")
                        }
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.top, 10)

                        Text("• **Location hint**: Available after 1 guess, shows the general area of London.")
                            .font(.body)

                        Text("• **Trivia hint**: Available after 3 guesses, shows a fun fact about the station.")
                            .font(.body)

                        // Season Ticket section - show benefits for premium users, purchase option for non-premium
                        HStack {
                            Image(systemName: "ticket.fill")
                                .foregroundColor(.yellow)
                            Text(subscriptionManager.hasActiveSubscription ? "Your Season Ticket Benefits" : "Season Ticket Features")
                        }
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.top, 10)

                        if subscriptionManager.hasActiveSubscription {
                            // Show benefits for premium users
                            Text("• **Unlimited Games**: Enjoy unlimited rounds every day - play as much as you want!")
                                .font(.body)

                            Text("• **Advanced Statistics**: Access your streak tracking, average guesses, and completion times.")
                                .font(.body)

                            Text("• **Priority Access**: Get early access to new features and stations as they're released.")
                                .font(.body)

                            Text("Thank you for supporting TubeGuessr! Your Season Ticket gives you the full experience.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                        } else {
                            // Show purchase option for non-premium users
                            Text("• **Unlimited Games**: Play as many rounds as you want every day.")
                                .font(.body)

                            Text("• **Advanced Statistics**: Unlock streak tracking, average guesses, and completion time.")
                                .font(.body)

                            Text("• **Priority Access**: Be first to try new features and stations.")
                                .font(.body)

                            Text("Season Tickets start at £0.99/month with a 7-day free trial.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)

                            Button(action: {
                                Task {
                                    // Ensure subscriptions are loaded
                                    await SubscriptionManager.shared.loadSubscriptions()

                                    if let monthlyProduct = SubscriptionManager.shared.subscriptions.first(where: { $0.id == "com.tubeguessr.seasonticket.monthly" }) {
                                        do {
                                            _ = try await SubscriptionManager.shared.purchase(monthlyProduct)

                                            // Update GameManager premium status
                                            GameManager.shared.syncPremiumStatusFromSubscriptionManager()
                                            // Also update directly as a backup
                                            GameManager.shared.updatePremiumStatus(true)
                                        } catch {
                                            // Handle error silently
                                        }
                                    }
                                }
                            }) {
                                HStack {
                                    Image(systemName: "ticket.fill")
                                        .foregroundColor(.black)
                                    Text("Get a Season Ticket")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.yellow)
                                .foregroundColor(.black)
                                .cornerRadius(22)
                                .shadow(color: .yellow.opacity(0.4), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(SeasonTicketButtonStyle())
                            .padding(.top, 15)
                        }
                    }

                    Spacer(minLength: 20)
                }
                .padding()
            }
        }
    }
}

struct TubeButtonStyle: ButtonStyle {
    var backgroundColor: Color = Color(hex: "#2E7DF6")
    var isCompact: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.horizontal, isCompact ? 20 : 30)
            .padding(.vertical, isCompact ? 8 : 12)
            .background(backgroundColor.opacity(configuration.isPressed ? 0.7 : 1.0))
            .cornerRadius(25)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct TubeMapGraphic: View {
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height

                // Horizontal line
                Path { path in
                    path.move(to: CGPoint(x: 0, y: height * 0.6))
                    path.addLine(to: CGPoint(x: width, y: height * 0.6))
                }
                .stroke(Color.white, lineWidth: 6)

                // Vertical line
                Path { path in
                    path.move(to: CGPoint(x: width * 0.3, y: 0))
                    path.addLine(to: CGPoint(x: width * 0.3, y: height))
                }
                .stroke(Color.white, lineWidth: 6)

                // Horizontal line 2
                Path { path in
                    path.move(to: CGPoint(x: 0, y: height * 0.3))
                    path.addLine(to: CGPoint(x: width, y: height * 0.3))
                }
                .stroke(Color.white, lineWidth: 6)

                // L-shaped line
                Path { path in
                    path.move(to: CGPoint(x: width * 0.5, y: 0))
                    path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.5))
                    path.addLine(to: CGPoint(x: width, y: height * 0.5))
                }
                .stroke(Color.white, lineWidth: 6)


                // L-shaped line 2
                Path { path in
                    path.move(to: CGPoint(x: width * 0.7, y: 0))
                    path.addLine(to: CGPoint(x: width * 0.7, y: height * 0.7))
                    path.addLine(to: CGPoint(x: 0, y: height * 0.7))
                }
                .stroke(Color.white, lineWidth: 6)

                // Junction circles (stations)
                Circle()
                    .fill(Color(hex: "#2E7DF6"))
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 12, height: 12)
                    .position(x: width * 0.3, y: height * 0.3)

                Circle()
                    .fill(Color(hex: "#2E7DF6"))
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 12, height: 12)
                    .position(x: width * 0.3, y: height * 0.6)

                Image(systemName: "plus")
                    .font(.system(size: 27, weight: .bold))
                    .foregroundColor(.red)
                    .rotationEffect(.degrees(45))
                    .position(x: width * 0.5, y: height * 0.5)

                Circle()
                    .fill(Color(hex: "#2E7DF6"))
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 12, height: 12)
                    .position(x: width * 0.7, y: height * 0.6)

                Circle()
                    .fill(Color(hex: "#2E7DF6"))
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 12, height: 12)
                    .position(x: width * 0.5, y: height * 0.3)

                Circle()
                    .fill(Color(hex: "#2E7DF6"))
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 12, height: 12)
                    .position(x: width * 0.7, y: height * 0.5)

                Circle()
                    .fill(Color(hex: "#2E7DF6"))
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 12, height: 12)
                    .position(x: width * 0.4, y: height * 0.7)

                // Additional junction circles
                Circle()
                    .fill(Color(hex: "#2E7DF6"))
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 12, height: 12)
                    .position(x: width * 0.1, y: height * 0.3)

                Circle()
                    .fill(Color(hex: "#2E7DF6"))
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 12, height: 12)
                    .position(x: width * 0.9, y: height * 0.3)

                Circle()
                    .fill(Color(hex: "#2E7DF6"))
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 12, height: 12)
                    .position(x: width * 0.7, y: height * 0.2)



                Circle()
                    .fill(Color(hex: "#2E7DF6"))
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 12, height: 12)
                    .position(x: width * 0.9, y: height * 0.5)
            }

        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.1))
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 46, 125, 246) // Default to the new blue color #2E7DF6
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct SeasonTicketButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

