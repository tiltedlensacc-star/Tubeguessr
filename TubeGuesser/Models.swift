import Foundation
import StoreKit

struct TubeLine: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let colorCode: String

    init(name: String, colorCode: String) {
        self.id = UUID()
        self.name = name
        self.colorCode = colorCode
    }
}

struct Station: Identifiable, Codable {
    let id: String // Changed from UUID to String for deterministic IDs
    let name: String
    let lines: [TubeLine]
    let trivia: String
    let location: String
    private let _normalizedName: String

    init(name: String, lines: [TubeLine], trivia: String, location: String) {
        // Use normalized name as deterministic ID
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

        self._normalizedName = normalized
        self.id = self._normalizedName // Deterministic ID based on station name
        self.name = name
        self.lines = lines
        self.trivia = trivia
        self.location = location
    }

    var normalizedName: String {
        _normalizedName
    }
}

struct GameRound: Identifiable, Codable {
    let id: UUID
    let station: Station
    let date: Date
    var hintsUsed: Bool = false
    var locationHintUsed: Bool = false
    var guesses: [String] = []
    var isCompleted: Bool = false
    var isWin: Bool = false
    var completionTime: TimeInterval?
    var accumulatedElapsedTime: TimeInterval = 0 // Time accumulated while app was active

    init(station: Station, date: Date) {
        self.id = UUID()
        self.station = station
        self.date = date
    }

    var remainingGuesses: Int {
        max(0, 5 - guesses.count)
    }
}

struct GameStats: Codable {
    var totalGames: Int = 0
    var totalWins: Int = 0
    var currentStreak: Int = 0
    var maxStreak: Int = 0
    var totalHintsUsed: Int = 0
    var history: [GameRound] = []
    var recentStationIds: [String] = []

    // Cached computed values
    private var _averageGuesses: Double?
    private var _averageCompletionTime: Double?
    private var _lastHistoryCount: Int = 0

    var winRate: Double {
        guard totalGames > 0 else { return 0.0 }
        return Double(totalWins) / Double(totalGames)
    }

    mutating func getAverageGuesses() -> Double {
        if let cached = _averageGuesses, _lastHistoryCount == history.count {
            return cached
        }
        let calculated = calculateAverageGuesses()
        _averageGuesses = calculated
        _lastHistoryCount = history.count
        return calculated
    }

    mutating func getAverageCompletionTime() -> Double {
        if let cached = _averageCompletionTime, _lastHistoryCount == history.count {
            return cached
        }
        let calculated = calculateAverageCompletionTime()
        _averageCompletionTime = calculated
        _lastHistoryCount = history.count
        return calculated
    }

    // Non-mutating computed properties for simple reading (without caching)
    var averageGuesses: Double {
        calculateAverageGuesses()
    }

    var averageCompletionTime: Double {
        calculateAverageCompletionTime()
    }

    private func calculateAverageGuesses() -> Double {
        let winningGames = history.filter { $0.isWin }
        guard !winningGames.isEmpty else { return 0.0 }
        let totalGuesses = winningGames.reduce(0) { $0 + $1.guesses.count }
        return Double(totalGuesses) / Double(winningGames.count)
    }

    private func calculateAverageCompletionTime() -> Double {
        let winningGames = history.filter { $0.isWin && $0.completionTime != nil }
        guard !winningGames.isEmpty else { return 0.0 }
        let totalTime = winningGames.compactMap { $0.completionTime }.reduce(0, +)
        return totalTime / Double(winningGames.count)
    }

    mutating func invalidateCache() {
        _averageGuesses = nil
        _averageCompletionTime = nil
        _lastHistoryCount = 0
    }
}

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    @Published var subscriptions: [Product] = []
    @Published var purchasedSubscriptions: [Product] = []
    @Published var subscriptionGroupStatus: Product.SubscriptionInfo.Status?

    private let productIds: Set<String> = [
        "com.tubeguessr.seasonticket.monthly"
    ]

    private var updates: Task<Void, Never>? = nil

    init() {
        updates = observeTransactionUpdates()
    }

    deinit {
        updates?.cancel()
    }

    // MARK: - StoreKit 2 Transaction Updates
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await _ in StoreKit.Transaction.updates {
                await self.updateCustomerProductStatus()
            }
        }
    }

    // MARK: - Product Loading
    func loadSubscriptions() async {
        do {
            print("Loading subscription products with IDs: \(productIds)")
            subscriptions = try await Product.products(for: productIds)
                .sorted(by: { $0.price < $1.price })
            print("Successfully loaded \(subscriptions.count) subscription products")
            if subscriptions.isEmpty {
                print("WARNING: No subscription products were returned. Check App Store Connect configuration.")
            }
        } catch {
            print("Failed to load products: \(error.localizedDescription)")
            print("Error details: \(error)")
        }
    }

    // MARK: - Purchase Handling
    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        print("Attempting to purchase product: \(product.id)")

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            print("Purchase successful, verifying transaction...")
            let transaction = try checkVerified(verification)
            print("Transaction verified successfully")
            await updateCustomerProductStatus()
            await transaction.finish()
            print("Transaction finished and status updated")
            return transaction

        case .userCancelled:
            print("User cancelled the purchase")
            return nil

        case .pending:
            print("Purchase is pending")
            return nil

        @unknown default:
            print("Unknown purchase result")
            return nil
        }
    }

    // MARK: - Subscription Status
    func updateCustomerProductStatus() async {
        // Clear existing purchased subscriptions to avoid duplicates
        purchasedSubscriptions.removeAll()

        for await result in StoreKit.Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                switch transaction.productType {
                case .autoRenewable:
                    if let subscription = subscriptions.first(where: { $0.id == transaction.productID }) {
                        purchasedSubscriptions.append(subscription)
                    }
                default:
                    break
                }
            } catch {
                print("Failed to verify transaction: \(error)")
            }
        }

        // Update subscription group status
        await updateSubscriptionGroupStatus()
    }

    private func updateSubscriptionGroupStatus() async {
        do {
            guard let subscription = subscriptions.first else { return }

            let statuses = try await subscription.subscription?.status ?? []

            for status in statuses {
                switch status.state {
                case .subscribed, .inGracePeriod, .inBillingRetryPeriod:
                    subscriptionGroupStatus = status
                case .expired, .revoked:
                    subscriptionGroupStatus = nil
                default:
                    break
                }
            }
        } catch {
            print("Failed to update subscription group status: \(error)")
        }
    }

    // MARK: - Verification
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Restore Purchases
    func restorePurchases() async {
        try? await AppStore.sync()
        await updateCustomerProductStatus()
    }

    // MARK: - Subscription Helpers
    var isPremiumSubscriber: Bool {
        !purchasedSubscriptions.isEmpty
    }

    var hasActiveSubscription: Bool {
        guard let status = subscriptionGroupStatus else {
            return false
        }

        switch status.state {
        case .subscribed, .inGracePeriod, .inBillingRetryPeriod:
            return true
        default:
            return false
        }
    }

    var subscriptionStatusDescription: String {
        guard let status = subscriptionGroupStatus else {
            return "No active subscription"
        }

        // Get the product ID from the verified transaction
        do {
            let transaction = try checkVerified(status.transaction)
            let productID = transaction.productID

            switch productID {
            case "com.tubeguessr.seasonticket.monthly":
                return "Season Ticket"
            default:
                return "Unknown subscription"
            }
        } catch {
            return "Unknown subscription"
        }
    }
}

// MARK: - Store Errors
public enum StoreError: Error {
    case failedVerification
}

// MARK: - Product Extensions
extension Product {
    var localizedPrice: String {
        return displayPrice
    }

    var subscriptionPeriod: String {
        guard let subscription = self.subscription else { return "" }

        let unit = subscription.subscriptionPeriod.unit
        let value = subscription.subscriptionPeriod.value

        switch unit {
        case .day:
            return value == 1 ? "day" : "\(value) days"
        case .week:
            return value == 1 ? "week" : "\(value) weeks"
        case .month:
            return value == 1 ? "month" : "\(value) months"
        case .year:
            return value == 1 ? "year" : "\(value) years"
        @unknown default:
            return ""
        }
    }
}