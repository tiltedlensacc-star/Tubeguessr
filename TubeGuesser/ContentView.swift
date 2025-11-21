import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showWelcomeScreen = true

    var body: some View {
        ZStack(alignment: .bottom) {
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
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 15)
            }
        }
    }
}

#Preview {
    ContentView()
}