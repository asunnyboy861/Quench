import Foundation
import UIKit

struct FeedbackPayload: Codable {
    let name: String
    let email: String
    let message: String
    let appVersion: String
    let deviceInfo: String
}

final class FeedbackService {
    static let shared = FeedbackService()

    private var backendURL: URL? {
        let raw = Bundle.main.object(forInfoDictionaryKey: "FEEDBACK_BACKEND_URL") as? String
            ?? ProcessInfo.processInfo.environment["FEEDBACK_BACKEND_URL"]
            ?? ""
        return URL(string: raw)
    }

    func sendFeedback(name: String, email: String, message: String, completion: @escaping (Bool) -> Void) {
        guard let url = backendURL else {
            completion(false)
            return
        }

        let appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0"
        let deviceInfo = "\(UIDevice.current.model) - iOS \(UIDevice.current.systemVersion)"
        let payload = FeedbackPayload(name: name, email: email, message: message, appVersion: appVersion, deviceInfo: deviceInfo)

        guard let body = try? JSONEncoder().encode(payload) else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { _, response, _ in
            if let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) {
                DispatchQueue.main.async { completion(true) }
            } else {
                DispatchQueue.main.async { completion(false) }
            }
        }.resume()
    }
}
