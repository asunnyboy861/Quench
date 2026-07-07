import SwiftUI

struct TodayTasksCard: View {
    let plants: [Plant]
    var onWater: (Plant) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Tasks")
                    .font(.headline)
                Spacer()
                Text("\(plants.count) need\(plants.count > 1 ? "" : "s") water")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(plants) { plant in
                Divider()
                HStack(spacing: 12) {
                    if let data = plant.photoData, let img = UIImage(data: data) {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 44, height: 44)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(AppTheme.plantGreen.opacity(0.2))
                            .frame(width: 44, height: 44)
                            .overlay {
                                Image(systemName: "leaf.fill")
                                    .foregroundStyle(AppTheme.plantGreen)
                            }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(plant.nickname)
                            .font(.subheadline.weight(.medium))
                        Text(plant.daysUntilWater < 0 ? "Overdue by \(abs(plant.daysUntilWater)) day\(abs(plant.daysUntilWater) > 1 ? "s" : "")" : "Water today")
                            .font(.caption)
                            .foregroundStyle(AppTheme.urgentRed)
                    }

                    Spacer()

                    Button {
                        onWater(plant)
                    } label: {
                        Image(systemName: "drop.fill")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(AppTheme.quenchBlue)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 4)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
