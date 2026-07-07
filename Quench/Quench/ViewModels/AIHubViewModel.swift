import Foundation
import SwiftUI
import Observation

@Observable
final class AIHubViewModel {
    var isProcessing: Bool = false
    var errorMessage: String? = nil
    var identification: PlantIdentification? = nil
    var diagnosis: HealthDiagnosis? = nil
    var chatMessages: [ChatMessage] = []
    var chatInput: String = ""
    var isStreaming: Bool = false

    var canUseAI: Bool {
        AIService.shared.isConfigured
    }

    func identify(imageData: Data) async {
        isProcessing = true
        errorMessage = nil
        identification = nil
        defer { isProcessing = false }

        do {
            identification = try await AIService.shared.identifyPlant(imageData: imageData)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func diagnose(imageData: Data, plantContext: String) async {
        isProcessing = true
        errorMessage = nil
        diagnosis = nil
        defer { isProcessing = false }

        do {
            diagnosis = try await AIService.shared.diagnoseHealth(imageData: imageData, plantContext: plantContext)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func sendChat(plantContext: String) async {
        guard !chatInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let userMsg = ChatMessage(role: "user", content: chatInput)
        chatMessages.append(userMsg)
        chatInput = ""

        isStreaming = true
        errorMessage = nil
        defer { isStreaming = false }

        do {
            let response = try await AIService.shared.coachChat(messages: chatMessages, plantContext: plantContext)
            chatMessages.append(ChatMessage(role: "assistant", content: response))
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
