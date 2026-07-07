import Foundation

struct ScheduleResult {
    let effectiveInterval: Int
    let nextWaterDate: Date?
    let explanation: String
    let factors: [String]
}

struct WeatherData {
    let isHotSpell: Bool
    let isColdSpell: Bool
    let isRainy: Bool
    let description: String
}

enum ScheduleEngine {
    static func effectiveInterval(for plant: Plant, weather: WeatherData? = nil) -> ScheduleResult {
        var interval = plant.baseWateringInterval
        var factors: [String] = []
        factors.append("Base interval: \(plant.baseWateringInterval) days")

        let seasonal = seasonalAdjustment(for: Calendar.currentSeason)
        interval += seasonal.adjustment
        if seasonal.adjustment != 0 {
            factors.append("\(seasonal.season.rawValue): \(seasonal.adjustment > 0 ? "+" : "")\(seasonal.adjustment) days")
        }

        if let weather = weather {
            let weatherAdj = weatherAdjustment(for: weather)
            interval += weatherAdj
            if weatherAdj != 0 {
                factors.append("Weather: \(weatherAdj > 0 ? "+" : "")\(weatherAdj) days (\(weather.description))")
            }
        }

        if let room = plant.room {
            let roomAdj = roomAdjustment(for: room)
            interval += roomAdj
            if roomAdj != 0 {
                factors.append("Room \(room.name): \(roomAdj > 0 ? "+" : "")\(roomAdj) days")
            }
        }

        if let lastLog = plant.wateringLogs.sorted(by: { $0.date > $1.date }).first,
           let soil = lastLog.soilCheckIn {
            let soilAdj = soilAdjustment(for: soil)
            interval += soilAdj
            if soilAdj != 0 {
                factors.append("Soil \(soil.rawValue): \(soilAdj > 0 ? "+" : "")\(soilAdj) days")
            }
        }

        let clamped = max(1, min(interval, 30))
        let nextDate: Date? = {
            guard let last = plant.lastWateredDate else {
                return Calendar.current.date(byAdding: .day, value: clamped, to: plant.createdAt)
            }
            return Calendar.current.date(byAdding: .day, value: clamped, to: last)
        }()

        let explanation = factors.joined(separator: "\n")
        return ScheduleResult(effectiveInterval: clamped, nextWaterDate: nextDate, explanation: explanation, factors: factors)
    }

    struct SeasonalAdjustment {
        let season: Season
        let adjustment: Int
    }

    static func seasonalAdjustment(for season: Season) -> SeasonalAdjustment {
        switch season {
        case .spring: return SeasonalAdjustment(season: season, adjustment: 0)
        case .summer: return SeasonalAdjustment(season: season, adjustment: -2)
        case .fall: return SeasonalAdjustment(season: season, adjustment: 0)
        case .winter: return SeasonalAdjustment(season: season, adjustment: 3)
        }
    }

    static func weatherAdjustment(for weather: WeatherData) -> Int {
        var adj = 0
        if weather.isHotSpell { adj -= 1 }
        if weather.isColdSpell { adj += 2 }
        if weather.isRainy { adj += 1 }
        return adj
    }

    static func roomAdjustment(for room: Room) -> Int {
        var adj = 0
        switch room.lightLevel {
        case .direct: adj -= 1
        case .bright: adj -= 1
        case .low: adj += 1
        case .medium: break
        }
        switch room.humidityLevel {
        case .low: adj -= 1
        case .high: adj += 1
        case .average: break
        }
        return adj
    }

    static func soilAdjustment(for soil: SoilMoisture) -> Int {
        switch soil {
        case .dry: return -1
        case .moist: return 0
        case .wet: return 2
        }
    }

    static func streak(for plant: Plant) -> Int {
        let calendar = Calendar.current
        let logs = plant.wateringLogs.sorted(by: { $0.date > $1.date })
        guard !logs.isEmpty else { return 0 }

        var streak = 0
        var expectedDay = calendar.startOfDay(for: Date())

        for log in logs {
            let logDay = calendar.startOfDay(for: log.date)
            let dayDiff = calendar.dateComponents([.day], from: logDay, to: expectedDay).day ?? 0

            if dayDiff == 0 {
                streak += 1
                expectedDay = calendar.date(byAdding: .day, value: -1, to: expectedDay)!
            } else if dayDiff == 1 {
                streak += 1
                expectedDay = calendar.date(byAdding: .day, value: -2, to: expectedDay)!
            } else if dayDiff > 1 {
                break
            }
        }
        return streak
    }
}
