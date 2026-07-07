import Foundation
import CoreLocation

final class WeatherService: NSObject {
    static let shared = WeatherService()
    private let locationManager = CLLocationManager()
    private var lastFetchDate: Date?
    private var cachedWeather: WeatherData?

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    var hasLocationPermission: Bool {
        locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways
    }

    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    func currentWeather() -> WeatherData? {
        guard WeatherService.weatherKitEnabled else { return nil }
        return cachedWeather
    }

    static var weatherKitEnabled: Bool {
        Bundle.main.object(forInfoDictionaryKey: "com.apple.developer.weatherkit") != nil
    }

    func updateWeather(completion: @escaping (WeatherData?) -> Void) {
        guard WeatherService.weatherKitEnabled else {
            completion(nil)
            return
        }

        if let cached = cachedWeather, let lastFetch = lastFetchDate, Date().timeIntervalSince(lastFetch) < 3600 {
            completion(cached)
            return
        }

        if !hasLocationPermission {
            requestLocation()
            completion(nil)
            return
        }

        locationManager.requestLocation()
        completion(cachedWeather)
    }
}

extension WeatherService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard locations.last != nil else { return }
        cachedWeather = WeatherData(isHotSpell: false, isColdSpell: false, isRainy: false, description: "Normal")
        lastFetchDate = Date()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        cachedWeather = nil
    }
}
