import SwiftUI

struct SettingsView: View {
    private let baseURL = "https://tiltedlensacc-star.github.io/Tubeguessr"

    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack(alignment: .center, spacing: 10) {
                        Image(systemName: "tram.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "#2E7DF6"))

                        Text("TubeGuesser")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Version 1.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
                .listRowBackground(Color.clear)

                Section("About") {
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

                    Link(destination: URL(string: "mailto:milesbennett90@yahoo.co.uk")!) {
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
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    SettingsView()
}
