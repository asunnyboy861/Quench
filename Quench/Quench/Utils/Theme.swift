import SwiftUI

enum ThemeMode: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

enum AppTheme {
    static let quenchBlue = Color(red: 0x21/255, green: 0x96/255, blue: 0xF3/255)
    static let plantGreen = Color(red: 0x4C/255, green: 0xAF/255, blue: 0x50/255)
    static let urgentRed = Color(red: 0xF4/255, green: 0x43/255, blue: 0x36/255)
    static let soonOrange = Color(red: 0xFF/255, green: 0x98/255, blue: 0x00/255)

    static func statusColor(daysUntilWater: Int) -> Color {
        if daysUntilWater < 0 { return urgentRed }
        if daysUntilWater <= 1 { return soonOrange }
        return plantGreen
    }

    static func gradient(for daysUntilWater: Int) -> LinearGradient {
        LinearGradient(
            colors: [statusColor(daysUntilWater: daysUntilWater).opacity(0.8), statusColor(daysUntilWater: daysUntilWater)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
