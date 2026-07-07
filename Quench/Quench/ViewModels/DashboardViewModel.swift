import Foundation
import SwiftData
import SwiftUI
import WidgetKit
import Observation

@Observable
final class DashboardViewModel {
    var showWateredAnimation: Bool = false
    var lastWateredPlant: Plant? = nil
    var plantsNeedingWater: [Plant] = []
    var upcomingPlant: Plant? = nil

    func update(plants: [Plant]) {
        plantsNeedingWater = plants.filter { $0.needsWaterToday }
            .sorted { ($0.daysUntilWater) < ($1.daysUntilWater) }

        upcomingPlant = plants
            .filter { !$0.needsWaterToday }
            .sorted { ($0.daysUntilWater) < ($1.daysUntilWater) }
            .first

        NotificationService.shared.rescheduleDailyDigest(plants: plants)
        sharePlantsForWidget(plants: plants)
    }

    private func sharePlantsForWidget(plants: [Plant]) {
        let widgetPlants = plants.filter { $0.needsWaterToday }.map { p in
            WidgetPlantData(
                id: p.id,
                nickname: p.nickname,
                commonName: p.commonName,
                daysUntilWater: p.daysUntilWater,
                photoData: p.photoData
            )
        }
        WidgetSharedStore.savePlantsForWidget(widgetPlants)
    }

    func quickWater(plant: Plant, context: ModelContext) {
        let log = WateringLog(date: Date())
        log.plant = plant
        plant.lastWateredDate = Date()
        context.insert(log)
        try? context.save()

        lastWateredPlant = plant
        showWateredAnimation = true

        WidgetCenter.shared.reloadAllTimelines()
    }

    func undoWater(context: ModelContext) {
        guard let plant = lastWateredPlant,
              let lastLog = plant.wateringLogs.sorted(by: { $0.date > $1.date }).first else { return }

        let previousDate = plant.wateringLogs
            .sorted(by: { $0.date > $1.date })
            .dropFirst()
            .first?.date

        plant.lastWateredDate = previousDate
        context.delete(lastLog)
        try? context.save()
        showWateredAnimation = false

        WidgetCenter.shared.reloadAllTimelines()
    }
}
