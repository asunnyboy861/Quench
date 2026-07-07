import Foundation
import SwiftData

enum LightLevel: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case bright = "Bright"
    case direct = "Direct"
}

enum HumidityLevel: String, Codable, CaseIterable {
    case low = "Low"
    case average = "Average"
    case high = "High"
}

@Model
final class Room {
    var id: UUID
    var name: String
    var lightLevel: LightLevel
    var humidityLevel: HumidityLevel
    var averageTemp: Double?
    var createdAt: Date
    var plants: [Plant] = []

    init(name: String, lightLevel: LightLevel = .medium, humidityLevel: HumidityLevel = .average, averageTemp: Double? = nil) {
        self.id = UUID()
        self.name = name
        self.lightLevel = lightLevel
        self.humidityLevel = humidityLevel
        self.averageTemp = averageTemp
        self.createdAt = Date()
    }
}
