import Foundation

struct WidgetPlant: Codable, Identifiable {
    let id: UUID
    let nickname: String
    let commonName: String
    let daysUntilWater: Int
    let photoData: Data?

    init(from plant: WidgetPlantData) {
        self.id = plant.id
        self.nickname = plant.nickname
        self.commonName = plant.commonName
        self.daysUntilWater = plant.daysUntilWater
        self.photoData = plant.photoData
    }
}

struct WidgetPlantData: Codable {
    let id: UUID
    let nickname: String
    let commonName: String
    let daysUntilWater: Int
    let photoData: Data?
}

struct WidgetSharedStore {
    static let appGroupIdentifier = "group.com.zzoutuo.Quench"

    static func loadPlantsNeedingWater() -> [WidgetPlant] {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            return []
        }
        let fileURL = containerURL.appendingPathComponent("widget_plants.json")

        guard let data = try? Data(contentsOf: fileURL),
              let plants = try? JSONDecoder().decode([WidgetPlantData].self, from: data) else {
            return []
        }
        return plants.map { WidgetPlant(from: $0) }
    }

    static func savePlantsForWidget(_ plants: [WidgetPlantData]) {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            return
        }
        let fileURL = containerURL.appendingPathComponent("widget_plants.json")

        if let data = try? JSONEncoder().encode(plants) {
            try? data.write(to: fileURL)
        }
    }
}
