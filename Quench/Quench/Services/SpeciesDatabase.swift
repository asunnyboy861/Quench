import Foundation

final class SpeciesDatabase {
    static let shared = SpeciesDatabase()

    private(set) var species: [CareProfile] = []

    private init() {
        loadSpecies()
    }

    private func loadSpecies() {
        guard let url = Bundle.main.url(forResource: "SpeciesDatabase", withExtension: "json") else {
            species = [CareProfile.defaultProfile]
            return
        }

        do {
            let data = try Data(contentsOf: url)
            species = try JSONDecoder().decode([CareProfile].self, from: data)
            if species.isEmpty {
                species = [CareProfile.defaultProfile]
            }
        } catch {
            species = [CareProfile.defaultProfile]
        }
    }

    func search(query: String) -> [CareProfile] {
        guard !query.isEmpty else { return species }
        let lowercased = query.lowercased()
        return species.filter {
            $0.commonName.lowercased().contains(lowercased) ||
            $0.scientificName.lowercased().contains(lowercased)
        }
    }

    func find(species name: String) -> CareProfile? {
        species.first { $0.commonName == name || $0.scientificName == name }
    }
}
