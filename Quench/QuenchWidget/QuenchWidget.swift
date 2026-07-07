import WidgetKit
import SwiftUI

@main
struct QuenchWidget: Widget {
    let kind: String = "QuenchWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetTimelineProvider()) { entry in
            QuenchWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Quench")
        .description("Tap to water your plants without opening the app.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct QuenchWidgetView: View {
    let entry: WidgetEntry

    var body: some View {
        if entry.allQuenched {
            AllQuenchedView()
        } else if entry.plantsNeedingWater.count == 1 {
            SinglePlantView(plant: entry.plantsNeedingWater[0])
        } else {
            MultiPlantView(plants: entry.plantsNeedingWater)
        }
    }
}

struct AllQuenchedView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .font(.title)
                .foregroundStyle(.green)
            Text("All quenched")
                .font(.headline)
            Text("No plants need water today")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SinglePlantView: View {
    let plant: WidgetPlant

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "drop.fill")
                    .foregroundStyle(.blue)
                Text(plant.nickname)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
            }

            Text("Needs water today")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Button(intent: WaterPlantIntent(plantID: plant.id.uuidString)) {
                Label("Water", systemImage: "drop.fill")
                    .font(.caption.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
        .padding(8)
    }
}

struct MultiPlantView: View {
    let plants: [WidgetPlant]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("💧 \(plants.count) need water")
                    .font(.caption.bold())
                Spacer()
            }

            ForEach(plants.prefix(3)) { plant in
                HStack {
                    Image(systemName: "leaf.fill")
                        .font(.caption2)
                        .foregroundStyle(.green)
                    Text(plant.nickname)
                        .font(.caption)
                        .lineLimit(1)
                    Spacer()
                    Button(intent: WaterPlantIntent(plantID: plant.id.uuidString)) {
                        Image(systemName: "drop.fill")
                            .font(.caption2)
                            .foregroundStyle(.white)
                            .padding(6)
                            .background(.blue)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }

                if plant.id != plants.prefix(3).last?.id {
                    Divider()
                }
            }

            if plants.count > 3 {
                Text("+ \(plants.count - 3) more")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(8)
    }
}

#Preview(as: .systemSmall) {
    QuenchWidget()
} timeline: {
    WidgetEntry(date: Date(), plantsNeedingWater: [], allQuenched: true)
    WidgetEntry(date: Date(), plantsNeedingWater: [
        WidgetPlant(from: WidgetPlantData(id: UUID(), nickname: "Monstera", commonName: "Monstera deliciosa", daysUntilWater: 0, photoData: nil))
    ], allQuenched: false)
}
