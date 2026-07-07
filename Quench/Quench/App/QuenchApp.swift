import SwiftUI
import SwiftData

@main
struct QuenchApp: App {
    @State private var purchaseService = PurchaseService.shared
    @AppStorage("themePreference") private var themePreference: String = ThemeMode.system.rawValue

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(purchaseService)
                .preferredColorScheme(ThemeMode(rawValue: themePreference)?.colorScheme)
                .modelContainer(for: [Plant.self, WateringLog.self, Room.self, PlantPhoto.self])
        }
    }
}

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @Query private var plants: [Plant]

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                WelcomeView()
            }
        }
        .onAppear {
            if hasCompletedOnboarding {
                NotificationService.shared.rescheduleDailyDigest(plants: plants)
            }
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    @Environment(PurchaseService.self) private var purchaseService

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            PlantsListView()
                .tabItem {
                    Label("Plants", systemImage: "leaf.fill")
                }
                .tag(1)

            AIHubView()
                .tabItem {
                    Label("AI Hub", systemImage: "stethoscope")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tint(AppTheme.quenchBlue)
    }
}
