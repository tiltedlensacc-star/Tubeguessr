import SwiftUI
import StoreKit

struct StatsView: View {
    @ObservedObject private var persistenceManager = PersistenceManager.shared
    @State private var showHowToPlay = false
    @State private var showSeasonTicketUpgrade = false
    // Real StoreKit subscription manager
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
                            }
                        }
                        .foregroundColor(Color(hex: "#2E7DF6"))
                    } else {
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
                    }

                    Spacer()

                    Text("TubeGuessr")
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
                    } else {
                        Button(action: {
                            showHowToPlay = true
                        }) {
                            Image(systemName: "info.circle")
                                .foregroundColor(Color(hex: "#2E7DF6"))
                                .font(.title2)
                        }
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
                VStack(spacing: 15) {
                    statsOverview

                    recentGamesSection

                    Spacer(minLength: 50)
                }
                .padding()
            }
        }
        .sheet(isPresented: $showHowToPlay) {
            InfoView()
        }
        .sheet(isPresented: $showSeasonTicketUpgrade) {
            SeasonTicketUpgradeView()
        }
        .onAppear {
            Task {
                await subscriptionManager.loadSubscriptions()
                await subscriptionManager.updateCustomerProductStatus()
            }
        }
    }

    private var statsOverview: some View {
        VStack(spacing: 15) {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 15),
                GridItem(.flexible(), spacing: 15)
            ], spacing: 15) {
                StatCard(
                    title: "Games Played",
                    value: "\(persistenceManager.stats.totalGames)",
                    color: Color(hex: "#2E7DF6")
                )

                StatCard(
                    title: "Games Won",
                    value: "\(persistenceManager.stats.totalWins)",
                    color: Color(hex: "#007D32")
                )

                StatCard(
                    title: "Win Rate",
                    value: String(format: "%.1f%%", persistenceManager.stats.winRate * 100),
                    color: Color(hex: "#4A5158")
                )

                StatCard(
                    title: "Hints used",
                    value: "\(persistenceManager.stats.totalHintsUsed)",
                    color: Color(hex: "#4A5158")
                )

                StatCard(
                    title: "Current Streak",
                    value: subscriptionManager.hasActiveSubscription ? "\(persistenceManager.stats.currentStreak)" : "",
                    color: Color(hex: "#4A5158"),
                    isLocked: !subscriptionManager.hasActiveSubscription,
                    onTap: !subscriptionManager.hasActiveSubscription ? { showSeasonTicketUpgrade = true } : nil
                )

                StatCard(
                    title: "Max Streak",
                    value: subscriptionManager.hasActiveSubscription ? "\(persistenceManager.stats.maxStreak)" : "",
                    color: Color(hex: "#4A5158"),
                    isLocked: !subscriptionManager.hasActiveSubscription,
                    onTap: !subscriptionManager.hasActiveSubscription ? { showSeasonTicketUpgrade = true } : nil
                )

                StatCard(
                    title: "Avg. Time",
                    value: subscriptionManager.hasActiveSubscription ? (persistenceManager.stats.averageCompletionTime > 0 ? formatTime(persistenceManager.stats.averageCompletionTime) : "N/A") : "",
                    color: Color(hex: "#4A5158"),
                    isLocked: !subscriptionManager.hasActiveSubscription,
                    onTap: !subscriptionManager.hasActiveSubscription ? { showSeasonTicketUpgrade = true } : nil
                )

                StatCard(
                    title: "Avg. Guesses",
                    value: subscriptionManager.hasActiveSubscription ? (persistenceManager.stats.averageGuesses > 0 ? String(format: "%.1f", persistenceManager.stats.averageGuesses) : "N/A") : "",
                    color: Color(hex: "#4A5158"),
                    isLocked: !subscriptionManager.hasActiveSubscription,
                    onTap: !subscriptionManager.hasActiveSubscription ? { showSeasonTicketUpgrade = true } : nil
                )
            }
        }
    }

    private var recentGamesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Your Recent Games")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)

            if persistenceManager.stats.history.isEmpty {
                Text("No games to show yet!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(persistenceManager.stats.history.suffix(10).reversed(), id: \.id) { game in
                    GameHistoryRow(game: game)
                }
            }
        }
    }

    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let isLocked: Bool
    let onTap: (() -> Void)?

    init(title: String, value: String, color: Color, isLocked: Bool = false, onTap: (() -> Void)? = nil) {
        self.title = title
        self.value = value
        self.color = color
        self.isLocked = isLocked
        self.onTap = onTap
    }

    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                } else {
                    Text(value)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                }

                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isLocked ? Color.gray.opacity(0.05) : Color.gray.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isLocked ? Color.gray.opacity(0.2) : Color.clear, lineWidth: 1)
            )

            if isLocked {
                VStack {
                    HStack {
                        Image(systemName: "ticket.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                            .frame(width: 24, height: 24)
                            .onTapGesture {
                                onTap?()
                            }
                            .background(Color.clear)
                        Spacer()
                    }
                    Spacer()
                }
                .padding(8)
            }
        }
        .onTapGesture {
            if isLocked {
                onTap?()
            }
        }
    }
}

struct GameHistoryRow: View {
    let game: GameRound

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    private func formatTryText(guessCount: Int) -> String {
        let actualCount = guessCount
        switch actualCount {
        case 1:
            return "1st Try!"
        case 2:
            return "2nd Try!"
        case 3:
            return "3rd Try!"
        case 4:
            return "4th Try!"
        case 5:
            return "5th Try!"
        default:
            return "\(actualCount)th Try!"
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .center, spacing: 4) {
                if game.isWin {
                    Image(systemName: "checkmark")
                        .foregroundColor(Color.green.opacity(0.8))
                        .font(.body)
                } else {
                    Image(systemName: "xmark")
                        .foregroundColor(Color.red.opacity(0.8))
                        .font(.body)
                }
            }
            .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(game.station.name)
                    .font(.headline)
                    .foregroundColor(Color(hex: "#2E7DF6"))

                Text(dateFormatter.string(from: game.date))
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 4) {
                    ForEach(game.station.lines) { line in
                        if line.name == "National Rail" {
                            Image(systemName: "train.side.front.car")
                                .foregroundColor(Color(hex: line.colorCode))
                                .font(.system(size: 6, weight: .semibold))
                                .frame(width: 8, height: 8)
                        } else {
                            Circle()
                                .fill(Color(hex: line.colorCode))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
            }

            Spacer()

            HStack(spacing: 8) {
                if game.hintsUsed {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.orange)
                        .font(.body)
                }

                if game.locationHintUsed {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.orange)
                        .font(.body)
                }

                if game.isWin {
                    Text(formatTryText(guessCount: game.guesses.count))
                        .font(.body)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(game.isWin ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
        .cornerRadius(10)
    }
}

struct SeasonTicketUpgradeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isPulsing = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()

                // Premium Icon
                ZStack {
                    // Pulsing background circle
                    Circle()
                        .fill(Color.yellow.opacity(0.3))
                        .frame(width: 100, height: 100)
                        .scaleEffect(isPulsing ? 1.4 : 1.0)
                        .opacity(isPulsing ? 0.1 : 0.3)
                        .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isPulsing)

                    // Static background circle
                    Circle()
                        .fill(Color.yellow.opacity(0.2))
                        .frame(width: 100, height: 100)

                    Image(systemName: "ticket.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.yellow)
                }
                .onAppear {
                    isPulsing = true
                }

                // Title and Description
                VStack(spacing: 24) {
                    Text("Unlimited Stations.\nTry free for 7 days.")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Unlimited daily rounds - play as much as you want")
                            .font(.body)
                            .foregroundColor(.primary)

                        Text("• Advanced statistics including streaks and averages")
                            .font(.body)
                            .foregroundColor(.primary)

                        Text("• Full access to all new features")
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal)

                    Text("Season Tickets start at £0.99/month with a 7-day free trial. Cancel anytime.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }


                Spacer()

                // CTA Button
                Button(action: {
                    Task {
                        // First ensure subscriptions are loaded
                        await SubscriptionManager.shared.loadSubscriptions()

                        // Purchase the monthly subscription
                        if let monthlyProduct = SubscriptionManager.shared.subscriptions.first(where: { $0.id == "com.tubeguessr.premium.monthly" }) {
                            do {
                                _ = try await SubscriptionManager.shared.purchase(monthlyProduct)

                                // Update GameManager premium status
                                GameManager.shared.syncPremiumStatusFromSubscriptionManager()
                                // Also update directly as a backup
                                GameManager.shared.updatePremiumStatus(true)
                                dismiss()
                            } catch {
                                // Handle error silently
                            }
                        }
                    }
                }) {
                    Text("Get a Season Ticket")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(hex: "#2E7DF6"))
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                Button(action: {
                    dismiss()
                }) {
                    Text("Maybe Later")
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                Button(action: {
                    Task {
                        await SubscriptionManager.shared.restorePurchases()
                        if SubscriptionManager.shared.hasActiveSubscription {
                            dismiss()
                        }
                    }
                }) {
                    Text("Restore Purchases")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom)
            }
            .navigationTitle("Season Ticket")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SeasonTicketFeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color(hex: "#2E7DF6"))
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}