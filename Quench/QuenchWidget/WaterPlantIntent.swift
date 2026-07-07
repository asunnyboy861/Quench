import AppIntents
import Foundation
import WidgetKit

struct WaterPlantIntent: AppIntent {
    static var title: LocalizedStringResource = "Water Plant"
    static var description: IntentDescription? = IntentDescription("Mark a plant as watered without opening the app.")

    @Parameter(title: "Plant ID")
    var plantID: String

    init() {}

    init(plantID: String) {
        self.plantID = plantID
    }

    func perform() async throws -> some IntentResult {
        await markPlantAsWatered()
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }

    @MainActor
    private func markPlantAsWatered() async {
        guard let uuid = UUID(uuidString: plantID) else { return }
        var plants = WidgetSharedStore.loadPlantsNeedingWater()
        plants.removeAll { $0.id == uuid }
        let updated = plants.map { WidgetPlantData(id: $0.id, nickname: $0.nickname, commonName: $0.commonName, daysUntilWater: $0.daysUntilWater, photoData: $0.photoData) }
        WidgetSharedStore.savePlantsForWidget(updated)
    }
}
