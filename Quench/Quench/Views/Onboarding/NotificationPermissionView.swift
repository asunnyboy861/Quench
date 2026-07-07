import SwiftUI

struct NotificationPermissionView: View {
    var onComplete: () -> Void
    @State private var hasRequested = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "bell.badge.fill")
                .font(.system(size: 70))
                .foregroundStyle(AppTheme.quenchBlue)

            Text("Enable Daily Reminders")
                .font(.title.bold())

            Text("Quench sends one daily digest at 8 AM listing plants that need water. No spam, no per-plant alerts.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 24)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    NotificationService.shared.requestPermission { granted in
                        UserDefaults.standard.set(true, forKey: "notificationPermissionAsked")
                        UserDefaults.standard.set(8, forKey: "preferredNotificationHour")
                        UserDefaults.standard.set(0, forKey: "preferredNotificationMinute")
                        onComplete()
                    }
                } label: {
                    Text("Allow Notifications")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.quenchBlue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Button("Skip for now") {
                    UserDefaults.standard.set(true, forKey: "notificationPermissionAsked")
                    onComplete()
                }
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
    }
}
