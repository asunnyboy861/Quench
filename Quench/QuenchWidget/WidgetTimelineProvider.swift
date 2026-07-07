import WidgetKit
import SwiftUI

struct WidgetEntry: TimelineEntry {
    let date: Date
    let plantsNeedingWater: [WidgetPlant]
    let allQuenched: Bool
}

struct WidgetTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(date: Date(), plantsNeedingWater: [], allQuenched: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> Void) {
        let entry = currentEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> Void) {
        let entry = currentEntry()
        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        completion(timeline)
    }

    private func currentEntry() -> WidgetEntry {
        let plants = WidgetSharedStore.loadPlantsNeedingWater()
        return WidgetEntry(
            date: Date(),
            plantsNeedingWater: plants,
            allQuenched: plants.isEmpty
        )
    }
}
