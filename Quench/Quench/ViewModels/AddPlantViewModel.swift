import Foundation
import SwiftData
import SwiftUI
import Observation

@Observable
final class AddPlantViewModel {
    var nickname: String = ""
    var selectedSpecies: CareProfile? = nil
    var photoData: Data? = nil
    var wateringInterval: Int = 7
    var searchQuery: String = ""
    var isIdentifying: Bool = false
    var identifyError: String? = nil
    var hasAIResult: Bool = false

    var speciesResults: [CareProfile] {
        SpeciesDatabase.shared.search(query: searchQuery)
    }

    func selectSpecies(_ profile: CareProfile) {
        selectedSpecies = profile
        wateringInterval = profile.wateringFrequencyDays
        if nickname.isEmpty {
            nickname = profile.commonName
        }
    }

    func identifyWithAI() async -> Bool {
        guard let data = photoData else { return false }
        isIdentifying = true
        identifyError = nil
        defer { isIdentifying = false }

        do {
            let result = try await AIService.shared.identifyPlant(imageData: data)
            let profile = CareProfile(
                commonName: result.commonName,
                scientificName: result.species,
                wateringFrequencyDays: result.wateringFrequencyDays,
                lightRequirement: result.lightNeeds,
                humidityPreference: "Average",
                toxicity: "Unknown",
                careTips: result.careTips
            )
            selectedSpecies = profile
            wateringInterval = result.wateringFrequencyDays
            if nickname.isEmpty {
                nickname = result.commonName
            }
            hasAIResult = true
            return true
        } catch {
            identifyError = error.localizedDescription
            return false
        }
    }

    func savePlant(context: ModelContext) -> Plant? {
        let profile = selectedSpecies ?? CareProfile.defaultProfile
        let plant = Plant(
            nickname: nickname.isEmpty ? profile.commonName : nickname,
            species: profile.scientificName,
            commonName: profile.commonName,
            photoData: photoData,
            baseWateringInterval: wateringInterval,
            lightNeeds: profile.lightRequirement,
            humidityNeeds: profile.humidityPreference,
            toxicity: profile.toxicity,
            careTips: profile.careTips
        )
        context.insert(plant)
        try? context.save()
        return plant
    }

    func reset() {
        nickname = ""
        selectedSpecies = nil
        photoData = nil
        wateringInterval = 7
        searchQuery = ""
        identifyError = nil
        hasAIResult = false
    }
}
