import SwiftUI
import SwiftData

struct NotificationTimeView: View {
    @AppStorage("preferredNotificationHour") private var hour: Int = 8
    @AppStorage("preferredNotificationMinute") private var minute: Int = 0
    @State private var showSaved = false
    @Query private var plants: [Plant]

    var body: some View {
        Form {
            Section("Daily Digest Time") {
                DatePicker("Time", selection: Binding(
                    get: {
                        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
                    },
                    set: { newDate in
                        let comps = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                        hour = comps.hour ?? 8
                        minute = comps.minute ?? 0
                    }
                ), displayedComponents: .hourAndMinute)

                Button {
                    NotificationService.shared.rescheduleDailyDigest(plants: plants)
                    showSaved = true
                } label: {
                    Label("Save & Reschedule", systemImage: "bell.badge")
                }
            }

            Section {
                Button {
                    NotificationService.shared.scheduleTestNotification()
                } label: {
                    Label("Send Test Notification", systemImage: "bell")
                }
            }

            if showSaved {
                Section {
                    Text("Daily digest rescheduled for \(hour):\(String(format: "%02d", minute))")
                        .foregroundStyle(AppTheme.plantGreen)
                }
            }
        }
        .navigationTitle("Notification Time")
    }
}
