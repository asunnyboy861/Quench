import Foundation
import SwiftData

@Model
final class PlantPhoto {
    var id: UUID
    var imageData: Data
    var note: String
    var date: Date
    var plant: Plant?

    init(imageData: Data, note: String = "", date: Date = Date()) {
        self.id = UUID()
        self.imageData = imageData
        self.note = note
        self.date = date
    }
}
