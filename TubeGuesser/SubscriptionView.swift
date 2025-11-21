import SwiftUI
import StoreKit

struct SeasonTicketView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false
    @State private var selectedProduct: Product?
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    headerSection

                    if subscriptionManager.subscriptions.isEmpty {
                        loadingView
                    } else {
                        subscriptionOptions
                    }

                    featuresSection

                    if !subscriptionManager.subscriptions.isEmpty {
                        subscribeButton
                    }

                    legalSection
                }
                .padding()
            }
            .navigationTitle("Season Ticket")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#2E7DF6"))
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Restore") {
                        Task {
                            await subscriptionManager.restorePurchases()
                        }
                    }
                    .foregroundColor(Color(hex: "#2E7DF6"))
                }
            }
        }
        .task {
            await subscriptionManager.loadSubscriptions()
            selectedProduct = subscriptionManager.subscriptions.first
        }
        .alert("Purchase Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 15) {
            Image(systemName: "ticket.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)

            Text("Get Your Season Ticket")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundColor(Color(hex: "#2E7DF6"))

            Text("Play unlimited games every day!")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading subscription options...")
                .foregroundColor(.secondary)

            Text("If this persists, subscriptions may not be configured in App Store Connect yet.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(minHeight: 150)
    }

    private var subscriptionOptions: some View {
        VStack(spacing: 15) {
            ForEach(subscriptionManager.subscriptions, id: \.id) { product in
                SubscriptionOptionView(
                    product: product,
                    isSelected: selectedProduct?.id == product.id
                ) {
                    selectedProduct = product
                }
            }
        }
    }

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Season Ticket Features")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#2E7DF6"))

            VStack(alignment: .leading, spacing: 15) {
                FeatureRow(
                    icon: "infinity",
                    title: "Unlimited Daily Games",
                    description: "Play as many rounds as you want, every day"
                )

                FeatureRow(
                    icon: "chart.bar.fill",
                    title: "Advanced Statistics",
                    description: "Unlock streak tracking, average guesses, and completion time metrics"
                )

                FeatureRow(
                    icon: "star.fill",
                    title: "Priority Access",
                    description: "Be first to try new features and stations"
                )

                FeatureRow(
                    icon: "sparkles",
                    title: "Exclusive Content",
                    description: "Access exclusive station collections"
                )

                FeatureRow(
                    icon: "xmark.circle.fill",
                    title: "No Daily Limits",
                    description: "Never wait until tomorrow to play again"
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    private var subscribeButton: some View {
        VStack(spacing: 15) {
            if let product = selectedProduct {
                Button(action: {
                    Task {
                        await purchaseSubscription(product)
                    }
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text("Start Playing Unlimited")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(hex: "#2E7DF6"))
                    .foregroundColor(.white)
                    .cornerRadius(25)
                }
                .disabled(isLoading)

                Text("7-day free trial, then \(product.localizedPrice)/\(product.subscriptionPeriod)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var legalSection: some View {
        VStack(spacing: 10) {
            Text("Terms and Conditions apply. Subscription automatically renews unless canceled at least 24 hours before the end of the current period.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 20) {
                Link("Privacy Policy", destination: URL(string: "https://tiltedlensacc-star.github.io/Tubeguessr/privacy-policy.html")!)
                    .foregroundColor(Color(hex: "#2E7DF6"))

                Link("Terms of Service", destination: URL(string: "https://tiltedlensacc-star.github.io/Tubeguessr/terms.html")!)
                    .foregroundColor(Color(hex: "#2E7DF6"))
            }
            .font(.caption)
        }
    }

    private func purchaseSubscription(_ product: Product) async {
        isLoading = true

        do {
            let transaction = try await subscriptionManager.purchase(product)
            if transaction != nil {
                // Successfully purchased, update game manager and dismiss
                await GameManager.shared.syncPremiumStatusFromSubscriptionManager()
                dismiss()
            } else {
                // User cancelled or purchase pending
                errorMessage = "Purchase was cancelled or is pending. Please try again."
                showError = true
            }
        } catch {
            // Handle purchase errors with user feedback
            errorMessage = "Unable to complete purchase: \(error.localizedDescription)"
            showError = true
            print("Purchase error: \(error)")
        }

        isLoading = false
    }
}

struct SubscriptionOptionView: View {
    let product: Product
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(product.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text(product.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text(product.localizedPrice)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#2E7DF6"))

                    Text("per \(product.subscriptionPeriod)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(hex: "#2E7DF6").opacity(0.1) : Color.gray.opacity(0.05))
                    .stroke(
                        isSelected ? Color(hex: "#2E7DF6") : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color(hex: "#2E7DF6"))
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

#Preview {
    SeasonTicketView()
}