import Foundation
import SwiftData

enum SoilMoisture: String, Codable, CaseIterable {
    case dry = "Dry"
    case moist = "Moist"
    case wet = "Wet"
}

enum LeafStatus: String, Codable, CaseIterable {
    case healthy = "Healthy"
    case drooping = "Drooping"
    case yellowing = "Yellowing"
}

@Model
final class WateringLog {
    var id: UUID
    var date: Date
    var soilCheckIn: SoilMoisture?
    var leafCheckIn: LeafStatus?
    var note: String
    var plant: Plant?

    init(date: Date = Date(), soilCheckIn: SoilMoisture? = nil, leafCheckIn: LeafStatus? = nil, note: String = "") {
        self.id = UUID()
        self.date = date
        self.soilCheckIn = soilCheckIn
        self.leafCheckIn = leafCheckIn
        self.note = note
    }
}
