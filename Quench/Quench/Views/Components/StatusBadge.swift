import SwiftUI

struct StatusBadge: View {
    let daysUntilWater: Int
    var streak: Int = 0

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(label)
                .font(.caption.monospacedDigit())
                .foregroundStyle(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }

    private var color: Color {
        AppTheme.statusColor(daysUntilWater: daysUntilWater)
    }

    private var label: String {
        if streak > 0 {
            return "🔥 \(streak)"
        }
        if daysUntilWater < 0 {
            return "Overdue \(abs(daysUntilWater))d"
        }
        if daysUntilWater == 0 {
            return "Today"
        }
        return "\(daysUntilWater)d"
    }
}

#Preview {
    VStack {
        StatusBadge(daysUntilWater: 0, streak: 3)
        StatusBadge(daysUntilWater: -2)
        StatusBadge(daysUntilWater: 5)
    }
}
