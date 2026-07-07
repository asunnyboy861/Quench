import Foundation

enum AIError: LocalizedError {
    case apiKeyNotConfigured
    case invalidResponse
    case networkError(Error)
    case parseError

    var errorDescription: String? {
        switch self {
        case .apiKeyNotConfigured: return "OpenAI API key not configured. Add your key in Settings."
        case .invalidResponse: return "Invalid response from OpenAI."
        case .networkError(let err): return "Network error: \(err.localizedDescription)"
        case .parseError: return "Failed to parse AI response."
        }
    }
}

struct PlantIdentification: Codable {
    let species: String
    let commonName: String
    let confidence: Double
    let wateringFrequencyDays: Int
    let lightNeeds: String
    let careTips: String
}

struct HealthDiagnosis: Codable {
    let diagnosis: String
    let severity: String
    let urgency: String
    let treatmentSteps: [String]
}

struct ChatMessage: Codable {
    let role: String
    let content: String
}

final class AIService {
    static let shared = AIService()
    private let keychainAccount = "openai_api_key"
    private let baseURL = URL(string: "https://api.openai.com/v1")!

    private init() {}

    var isConfigured: Bool {
        guard let key = KeychainHelper.readString(account: keychainAccount) else { return false }
        return key.hasPrefix("sk-")
    }

    func saveAPIKey(_ key: String) {
        KeychainHelper.saveString(key, account: keychainAccount)
    }

    func getAPIKey() -> String? {
        KeychainHelper.readString(account: keychainAccount)
    }

    func removeAPIKey() {
        KeychainHelper.delete(account: keychainAccount)
    }

    func validateKey() async -> Bool {
        guard let key = getAPIKey() else { return false }
        var request = URLRequest(url: baseURL.appendingPathComponent("models"))
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse {
                return http.statusCode == 200
            }
            return false
        } catch {
            return false
        }
    }

    func identifyPlant(imageData: Data) async throws -> PlantIdentification {
        guard let key = getAPIKey() else { throw AIError.apiKeyNotConfigured }
        let base64 = imageData.base64EncodedString()
        let prompt = """
        Identify this plant. Respond ONLY with valid JSON matching this schema:
        {"species":"scientific name","commonName":"common name","confidence":0.0-1.0,"wateringFrequencyDays":1-30,"lightNeeds":"Low/Medium/Bright/Direct","careTips":"brief tip"}
        """
        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": prompt],
                        ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64)"]]
                    ]
                ]
            ],
            "max_tokens": 500
        ]
        let response: [String: Any] = try await sendChatRequest(body: body, key: key)
        guard let choices = response["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIError.invalidResponse
        }
        guard let data = extractJSON(from: content).data(using: .utf8) else {
            throw AIError.parseError
        }
        do {
            return try JSONDecoder().decode(PlantIdentification.self, from: data)
        } catch {
            throw AIError.parseError
        }
    }

    func diagnoseHealth(imageData: Data, plantContext: String) async throws -> HealthDiagnosis {
        guard let key = getAPIKey() else { throw AIError.apiKeyNotConfigured }
        let base64 = imageData.base64EncodedString()
        let prompt = """
        Diagnose this plant's health issue. Plant context: \(plantContext). Respond ONLY with valid JSON:
        {"diagnosis":"issue name","severity":"Low/Medium/High","urgency":"None/Soon/Immediate","treatmentSteps":["step 1","step 2"]}
        """
        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": prompt],
                        ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64)"]]
                    ]
                ]
            ],
            "max_tokens": 600
        ]
        let response: [String: Any] = try await sendChatRequest(body: body, key: key)
        guard let choices = response["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIError.invalidResponse
        }
        guard let data = extractJSON(from: content).data(using: .utf8) else {
            throw AIError.parseError
        }
        do {
            return try JSONDecoder().decode(HealthDiagnosis.self, from: data)
        } catch {
            throw AIError.parseError
        }
    }

    func coachChat(messages: [ChatMessage], plantContext: String) async throws -> String {
        guard let key = getAPIKey() else { throw AIError.apiKeyNotConfigured }
        var allMessages = messages.map { msg -> [String: String] in
            ["role": msg.role, "content": msg.content]
        }
        let systemMsg = ["role": "system", "content": "You are Quench, a friendly plant care coach. Plant context: \(plantContext). Keep answers concise and practical."]
        allMessages.insert(systemMsg, at: 0)

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": allMessages,
            "max_tokens": 500
        ]
        let response: [String: Any] = try await sendChatRequest(body: body, key: key)
        guard let choices = response["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIError.invalidResponse
        }
        return content
    }

    private func sendChatRequest(body: [String: Any], key: String) async throws -> [String: Any] {
        var request = URLRequest(url: baseURL.appendingPathComponent("chat/completions"))
        request.httpMethod = "POST"
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                throw AIError.invalidResponse
            }
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw AIError.parseError
            }
            return json
        } catch let err as AIError {
            throw err
        } catch {
            throw AIError.networkError(error)
        }
    }

    private func extractJSON(from text: String) -> String {
        if let start = text.firstIndex(of: "{"), let end = text.lastIndex(of: "}") {
            return String(text[start...end])
        }
        return text
    }
}
