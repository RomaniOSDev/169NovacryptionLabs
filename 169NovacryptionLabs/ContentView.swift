import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppDataStore.shared

    init() {
        AppAppearance.configure()
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            Group {
                if store.hasSeenOnboarding {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
            .background(Color.clear)
        }
        .environmentObject(store)
        .preferredColorScheme(.dark)
        .onAppear {
            AppAppearance.applyWindowBackground()
        }
    }
}

#Preview {
    ContentView()
}
