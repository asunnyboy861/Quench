import Foundation

extension Date {
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: self)
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Hello"
        }
    }

    func formatted(dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .none) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.string(from: self)
    }

    func relativeDescription() -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: self)
        let dayDiff = calendar.dateComponents([.day], from: today, to: target).day ?? 0

        switch dayDiff {
        case -1: return "Yesterday"
        case 0: return "Today"
        case 1: return "Tomorrow"
        case 2...7: return "In \(dayDiff) days"
        case let n where n < -1: return "\(abs(n)) days ago"
        default: return self.formatted()
        }
    }
}

extension Calendar {
    static var currentSeason: Season {
        let month = Calendar.current.component(.month, from: Date())
        switch month {
        case 3, 4, 5: return .spring
        case 6, 7, 8: return .summer
        case 9, 10, 11: return .fall
        default: return .winter
        }
    }
}

enum Season: String, CaseIterable {
    case spring = "Spring"
    case summer = "Summer"
    case fall = "Fall"
    case winter = "Winter"
}
