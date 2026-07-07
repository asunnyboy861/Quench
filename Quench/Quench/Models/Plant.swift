import Foundation
import SwiftData

@Model
final class Plant {
    var id: UUID
    var nickname: String
    var species: String
    var commonName: String
    var photoData: Data?
    var baseWateringInterval: Int
    var lastWateredDate: Date?
    var createdAt: Date
    var lightNeeds: String
    var humidityNeeds: String
    var toxicity: String
    var careTips: String
    var room: Room?
    var wateringLogs: [WateringLog] = []
    var photos: [PlantPhoto] = []

    init(
        nickname: String,
        species: String,
        commonName: String,
        photoData: Data? = nil,
        baseWateringInterval: Int,
        lastWateredDate: Date? = nil,
        lightNeeds: String = "Medium",
        humidityNeeds: String = "Average",
        toxicity: String = "Non-toxic",
        careTips: String = ""
    ) {
        self.id = UUID()
        self.nickname = nickname
        self.species = species
        self.commonName = commonName
        self.photoData = photoData
        self.baseWateringInterval = baseWateringInterval
        self.lastWateredDate = lastWateredDate
        self.createdAt = Date()
        self.lightNeeds = lightNeeds
        self.humidityNeeds = humidityNeeds
        self.toxicity = toxicity
        self.careTips = careTips
    }

    var nextWaterDate: Date? {
        guard let last = lastWateredDate else {
            return Calendar.current.date(byAdding: .day, value: baseWateringInterval, to: createdAt)
        }
        return Calendar.current.date(byAdding: .day, value: baseWateringInterval, to: last)
    }

    var needsWaterToday: Bool {
        guard let next = nextWaterDate else { return false }
        return next <= Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
    }

    var daysUntilWater: Int {
        guard let next = nextWaterDate else { return baseWateringInterval }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: next)
        return calendar.dateComponents([.day], from: today, to: target).day ?? 0
    }
}
