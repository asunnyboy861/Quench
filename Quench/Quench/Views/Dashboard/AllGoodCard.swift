import SwiftUI

struct AllGoodCard: View {
    let nextPlant: Plant?

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 40))
                .foregroundStyle(AppTheme.plantGreen)

            Text("All quenched")
                .font(.headline)

            if let plant = nextPlant {
                Text("Next: **\(plant.nickname)** in \(plant.daysUntilWater) day\(plant.daysUntilWater > 1 ? "s" : "")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("No plants need water today")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(AppTheme.plantGreen.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
