import Foundation
import UserNotifications
import UIKit

final class NotificationService {
    static let shared = NotificationService()
    private let center = UNUserNotificationCenter.current()
    private let digestIdentifier = "daily-watering-digest"

    private init() {}

    func requestPermission(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    func rescheduleDailyDigest(plants: [Plant]) {
        center.removePendingNotificationRequests(withIdentifiers: [digestIdentifier])

        let calendar = Calendar.current
        let now = Date()
        let preferredHour = UserDefaults.standard.object(forKey: "preferredNotificationHour") as? Int ?? 8
        let preferredMinute = UserDefaults.standard.object(forKey: "preferredNotificationMinute") as? Int ?? 0

        var components = DateComponents()
        components.hour = preferredHour
        components.minute = preferredMinute

        var nextTriggerDate = calendar.nextDate(after: now, matching: components, matchingPolicy: .nextTime) ?? now
        if nextTriggerDate <= now {
            nextTriggerDate = calendar.date(byAdding: .day, value: 1, to: nextTriggerDate) ?? nextTriggerDate
        }

        let plantsNeedingWater = plants.filter { $0.needsWaterToday }
        guard !plantsNeedingWater.isEmpty else { return }

        let title = "💧 \(plantsNeedingWater.count) plant\(plantsNeedingWater.count > 1 ? "s" : "") need water today"
        let names = plantsNeedingWater.prefix(3).map { $0.nickname }
        var body = names.joined(separator: ", ")
        if plantsNeedingWater.count > 3 {
            body += " and \(plantsNeedingWater.count - 3) more"
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.badge = NSNumber(value: plantsNeedingWater.count)
        content.sound = .default

        let triggerComponents = calendar.dateComponents([.hour, .minute], from: nextTriggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)
        let request = UNNotificationRequest(identifier: digestIdentifier, content: content, trigger: trigger)
        center.add(request)
    }

    func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "💧 Quench Test"
        content.body = "Daily digest notifications are working!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "test-\(UUID().uuidString)", content: content, trigger: trigger)
        center.add(request)
    }

    func clearBadge() {
        center.removeAllDeliveredNotifications()
        center.setBadgeCount(0)
    }
}
