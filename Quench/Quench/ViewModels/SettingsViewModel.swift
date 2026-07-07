import Foundation
import SwiftUI
import SwiftData
import Observation

@Observable
final class SettingsViewModel {
    var apiKeyInput: String = ""
    var apiKeyMasked: String = ""
    var isValidating: Bool = false
    var validationMessage: String? = nil
    var feedbackName: String = ""
    var feedbackEmail: String = ""
    var feedbackMessage: String = ""
    var feedbackStatus: String? = nil

    func loadAPIKey() {
        let key = AIService.shared.getAPIKey()
        apiKeyMasked = KeychainHelper.mask(key: key)
    }

    func saveAPIKey() {
        let trimmed = apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("sk-") else {
            validationMessage = "Key must start with 'sk-'"
            return
        }
        AIService.shared.saveAPIKey(trimmed)
        apiKeyInput = ""
        loadAPIKey()
        validationMessage = "Saved"
    }

    func validateKey() async {
        isValidating = true
        validationMessage = nil
        defer { isValidating = false }

        let valid = await AIService.shared.validateKey()
        validationMessage = valid ? "Key is valid" : "Key is invalid or unreachable"
    }

    func removeAPIKey() {
        AIService.shared.removeAPIKey()
        apiKeyMasked = ""
        validationMessage = "Key removed"
    }

    func sendFeedback() {
        guard !feedbackName.isEmpty, !feedbackEmail.isEmpty, !feedbackMessage.isEmpty else {
            feedbackStatus = "Please fill in all fields"
            return
        }

        FeedbackService.shared.sendFeedback(name: feedbackName, email: feedbackEmail, message: feedbackMessage) { success in
            self.feedbackStatus = success ? "Feedback sent. Thank you!" : "Failed to send. Please try again later."
            if success {
                self.feedbackName = ""
                self.feedbackEmail = ""
                self.feedbackMessage = ""
            }
        }
    }

    func exportData(plants: [Plant], rooms: [Room]) -> URL? {
        struct ExportPlant: Codable {
            let nickname: String
            let species: String
            let commonName: String
            let baseWateringInterval: Int
            let lastWateredDate: Date?
            let createdAt: Date
            let lightNeeds: String
            let humidityNeeds: String
            let toxicity: String
            let careTips: String
            let wateringLogs: [ExportLog]
        }
        struct ExportLog: Codable {
            let date: Date
            let soilCheckIn: String?
            let leafCheckIn: String?
            let note: String
        }
        struct ExportRoom: Codable {
            let name: String
            let lightLevel: String
            let humidityLevel: String
            let averageTemp: Double?
        }
        struct ExportData: Codable {
            let plants: [ExportPlant]
            let rooms: [ExportRoom]
            let exportedAt: Date
        }

        let exportPlants = plants.map { p in
            ExportPlant(
                nickname: p.nickname,
                species: p.species,
                commonName: p.commonName,
                baseWateringInterval: p.baseWateringInterval,
                lastWateredDate: p.lastWateredDate,
                createdAt: p.createdAt,
                lightNeeds: p.lightNeeds,
                humidityNeeds: p.humidityNeeds,
                toxicity: p.toxicity,
                careTips: p.careTips,
                wateringLogs: p.wateringLogs.map { log in
                    ExportLog(date: log.date, soilCheckIn: log.soilCheckIn?.rawValue, leafCheckIn: log.leafCheckIn?.rawValue, note: log.note)
                }
            )
        }
        let exportRooms = rooms.map { r in
            ExportRoom(name: r.name, lightLevel: r.lightLevel.rawValue, humidityLevel: r.humidityLevel.rawValue, averageTemp: r.averageTemp)
        }

        let data = ExportData(plants: exportPlants, rooms: exportRooms, exportedAt: Date())
        guard let encoded = try? JSONEncoder().encode(data) else { return nil }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("QuenchExport-\(Int(Date().timeIntervalSince1970)).json")
        do {
            try encoded.write(to: url)
            return url
        } catch {
            return nil
        }
    }
}
