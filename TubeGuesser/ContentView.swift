import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showWelcomeScreen = true

    var body: some View {
        TabView(selection: $selectedTab) {
            GameView(showWelcomeScreen: $showWelcomeScreen)
                .tabItem {
                    VStack(spacing: 4) {
                        Image(systemName: "tram.fill")
                        Text("Game")
                    }
                    .padding(.vertical, 8)
                }
                .tag(0)

            StatsView()
                .tabItem {
                    VStack(spacing: 4) {
                        Image(systemName: "chart.bar")
                        Text("Stats")
                    }
                    .padding(.vertical, 8)
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    VStack(spacing: 4) {
                        Image(systemName: "gearshape.fill")
                        Text("About")
                    }
                    .padding(.vertical, 8)
                }
                .tag(2)
        }
        .accentColor(Color(hex: "#2E7DF6"))
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}