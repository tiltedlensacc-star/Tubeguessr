import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showWelcomeScreen = true

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()

        // Adjust title position for both normal and selected states
        appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -8)
        appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -8)

        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            GameView(showWelcomeScreen: $showWelcomeScreen)
                .tabItem {
                    Image(systemName: "tram.fill")
                    Text("Game")
                }
                .tag(0)

            StatsView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Stats")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("About")
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