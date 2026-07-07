import Foundation
import SwiftData
import SwiftUI
import WidgetKit
import Observation

@Observable
final class PlantDetailViewModel {
    var showSoilCheckIn: Bool = false
    var showWateredAnimation: Bool = false
    var pendingSoilLog: WateringLog? = nil

    func quickWater(plant: Plant, context: ModelContext) {
        let log = WateringLog(date: Date())
        log.plant = plant
        plant.lastWateredDate = Date()
        context.insert(log)
        try? context.save()

        pendingSoilLog = log
        showWateredAnimation = true
        showSoilCheckIn = true

        WidgetCenter.shared.reloadAllTimelines()
    }

    func setSoilCheckIn(_ soil: SoilMoisture?, leaf: LeafStatus?, context: ModelContext) {
        pendingSoilLog?.soilCheckIn = soil
        pendingSoilLog?.leafCheckIn = leaf
        try? context.save()
        showSoilCheckIn = false
    }

    func updateNickname(_ name: String, for plant: Plant, context: ModelContext) {
        plant.nickname = name
        try? context.save()
    }

    func deletePlant(_ plant: Plant, context: ModelContext) {
        context.delete(plant)
        try? context.save()
    }

    func addPhoto(_ data: Data, note: String, to plant: Plant, context: ModelContext) {
        let photo = PlantPhoto(imageData: data, note: note)
        photo.plant = plant
        context.insert(photo)
        try? context.save()
    }

    func streak(for plant: Plant) -> Int {
        ScheduleEngine.streak(for: plant)
    }

    func scheduleExplanation(for plant: Plant) -> ScheduleResult {
        let weather = WeatherService.shared.currentWeather()
        return ScheduleEngine.effectiveInterval(for: plant, weather: weather)
    }
}
