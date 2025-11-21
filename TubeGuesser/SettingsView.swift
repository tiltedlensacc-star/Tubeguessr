import SwiftUI

struct SettingsView: View {
    private let baseURL = "https://tiltedlensacc-star.github.io/Tubeguessr"
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showResetAlert = false

    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack(alignment: .center, spacing: 10) {
                        Image(systemName: "tram.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "#2E7DF6"))

                        Text("Tubeguessr")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Version 1.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                    .padding(.bottom, 5)
                }
                .listRowBackground(Color.clear)

                Section {
                    Text("A daily guessing game where you identify London Underground stations based on the lines they serve.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Section("Legal") {
                    Link(destination: URL(string: "\(baseURL)/privacy-policy.html")!) {
                        HStack {
                            Label("Privacy Policy", systemImage: "hand.raised.fill")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Link(destination: URL(string: "\(baseURL)/terms.html")!) {
                        HStack {
                            Label("Terms of Service", systemImage: "doc.text.fill")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section("Support") {
                    Link(destination: URL(string: "\(baseURL)/support.html")!) {
                        HStack {
                            Label("Help & Support", systemImage: "questionmark.circle.fill")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Link(destination: URL(string: "mailto:tubeguessr@gmail.com")!) {
                        HStack {
                            Label("Contact Us", systemImage: "envelope.fill")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section {
                    Text("TubeGuesser is not affiliated with, endorsed by, or connected to Transport for London (TfL).")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .listRowBackground(Color.clear)

                #if DEBUG
                Section("Debug Options") {
                    Button(action: {
                        showResetAlert = true
                    }) {
                        HStack {
                            Label("Reset Subscription Status", systemImage: "arrow.clockwise")
                                .foregroundColor(.orange)
                            Spacer()
                        }
                    }

                    if subscriptionManager.hasActiveSubscription {
                        Text("Current Status: Active Subscription")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Text("Current Status: No Subscription")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                #endif
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Reset Subscription Status", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    Task {
                        // Force refresh subscription status
                        await subscriptionManager.updateCustomerProductStatus()
                        // Update game manager
                        GameManager.shared.syncPremiumStatusFromSubscriptionManager()
                    }
                }
            } message: {
                Text("This will refresh your subscription status from the App Store. Use this to test the subscription flow.")
            }
        }
    }
}

#Preview {
    SettingsView()
}
