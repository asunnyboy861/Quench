import SwiftUI

struct WateringHistorySection: View {
    let plant: Plant

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Watering History")
                .font(.headline)

            if plant.wateringLogs.isEmpty {
                HStack {
                    Image(systemName: "drop")
                        .foregroundStyle(.secondary)
                    Text("Tap 💧 to start tracking")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                ForEach(plant.wateringLogs.sorted(by: { $0.date > $1.date })) { log in
                    Divider()
                    HStack(spacing: 12) {
                        Image(systemName: "drop.fill")
                            .foregroundStyle(AppTheme.quenchBlue)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(log.date.formatted())
                                .font(.subheadline)
                            if let soil = log.soilCheckIn {
                                Text("Soil: \(soil.rawValue)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            if let leaf = log.leafCheckIn {
                                Text("Leaves: \(leaf.rawValue)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            if !log.note.isEmpty {
                                Text(log.note)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}
