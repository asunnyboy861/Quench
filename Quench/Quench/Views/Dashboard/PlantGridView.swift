import SwiftUI

struct PlantGridView: View {
    let plants: [Plant]

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("My Plants")
                .font(.headline)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(plants) { plant in
                    NavigationLink {
                        PlantDetailView(plant: plant)
                    } label: {
                        PlantGridCell(plant: plant)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct PlantGridCell: View {
    let plant: Plant

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                if let data = plant.photoData, let img = UIImage(data: data) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppTheme.plantGreen.opacity(0.15))
                        .frame(height: 120)
                        .overlay {
                            Image(systemName: "leaf.fill")
                                .font(.title)
                                .foregroundStyle(AppTheme.plantGreen)
                        }
                }

                StatusBadge(daysUntilWater: plant.daysUntilWater, streak: ScheduleEngine.streak(for: plant))
                    .padding(6)
            }

            Text(plant.nickname)
                .font(.subheadline.weight(.medium))
                .lineLimit(1)

            Text(plant.commonName)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(8)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
