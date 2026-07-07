import SwiftUI

struct WelcomeView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showNotificationPermission = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 24) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(AppTheme.quenchBlue)
                        .symbolEffect(.pulse)

                    Text("Quench")
                        .font(.largeTitle.bold())

                    Text("Never kill another plant.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(icon: "bell.badge.fill", title: "Daily reminders", subtitle: "One calm digest — never spam")
                    FeatureRow(icon: "drop.degreesign.fill", title: "One-tap watering", subtitle: "Water plants in 2 seconds")
                    FeatureRow(icon: "leaf.fill", title: "Unlimited plants", subtitle: "Free forever, no caps")
                    FeatureRow(icon: "rectangle.grid.1x2", title: "Home screen widget", subtitle: "Water without opening the app")
                }
                .padding(.horizontal, 8)

                Spacer()

                Button {
                    showNotificationPermission = true
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.quenchBlue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 32)
            .navigationDestination(isPresented: $showNotificationPermission) {
                NotificationPermissionView {
                    hasCompletedOnboarding = true
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(AppTheme.quenchBlue)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}

#Preview {
    WelcomeView()
}
