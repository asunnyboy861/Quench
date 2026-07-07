import Foundation

struct CareProfile: Codable, Identifiable, Hashable {
    var id: String { commonName }
    let commonName: String
    let scientificName: String
    let wateringFrequencyDays: Int
    let lightRequirement: String
    let humidityPreference: String
    let toxicity: String
    let careTips: String

    static let defaultProfile = CareProfile(
        commonName: "Houseplant",
        scientificName: "Unknown",
        wateringFrequencyDays: 7,
        lightRequirement: "Medium",
        humidityPreference: "Average",
        toxicity: "Non-toxic",
        careTips: "Water when top inch of soil feels dry."
    )
}
