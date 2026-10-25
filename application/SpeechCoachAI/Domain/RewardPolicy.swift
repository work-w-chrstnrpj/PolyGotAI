import Foundation

/// Owner adopted the named recommendations on 2026-10-25. Amounts remain the original prototype economy.
enum RewardPolicy {
    static let version = "rewards-personal-1"
    static let approval = "SC-D005-owner-2026-10-25"
    static let inactivitySeconds: TimeInterval = 60
    static func day(_ date: Date, calendar: Calendar = .current) -> String {
        PracticeRecommendation.localDay(date, calendar: calendar)
    }
    static func ordinal(_ day: String) -> Int? {
        let components = day.split(separator: "-").compactMap { Int($0) }
        guard components.count == 3 else { return nil }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        guard let date = calendar.date(from: DateComponents(year: components[0], month: components[1], day: components[2])),
              self.day(date, calendar: calendar) == day else { return nil }
        return Int(date.timeIntervalSince1970 / 86_400)
    }
}

enum RewardError: Error, Equatable {
    case insufficientGold, invalidRequest, stale, clockChanged, repairUnavailable
    var message: String {
        switch self {
        case .insufficientGold: "Not enough gold. Explanations, correction, replay and retries are still free."
        case .invalidRequest: "This reward action is unavailable. Nothing was spent."
        case .stale: "The reward record changed. Reload before trying again."
        case .clockChanged: "The local date moved backward. Practice still works; reward actions wait until the recorded date is reached."
        case .repairUnavailable: "Repair requires one to seven missed days, enough gold, and a practice date after the previous repair."
        }
    }
}

struct RewardSettings: Codable, Equatable {
    enum Celebration: String, Codable, CaseIterable { case full, subtle, off }
    var celebration: Celebration = .full
    var quiet = false
    var music = false
    var effects = false
    var haptics = false
    var autoFreeze = false
    var activeMinutesGoal: Int? = nil
    var activityGoal: Int? = nil
    var reminderEnabled = false
    var reminderWeekdays: [Int] = []
    var reminderHour = 18
    var reminderMinute = 0
    var breakMinutes: Int? = nil
    func validate() throws {
        guard activeMinutesGoal.map({ $0 > 0 && $0 <= Int.max / 60 }) ?? true,
              activityGoal.map({ $0 > 0 }) ?? true,
              breakMinutes.map({ $0 > 0 && $0 <= Int.max / 60 }) ?? true,
              (0...23).contains(reminderHour), (0...59).contains(reminderMinute),
              Set(reminderWeekdays).count == reminderWeekdays.count,
              reminderWeekdays.allSatisfy({ (1...7).contains($0) }),
              !reminderEnabled || (!reminderWeekdays.isEmpty && (activeMinutesGoal != nil || activityGoal != nil)) else { throw RewardError.invalidRequest }
    }
}

struct RewardPurchase: Codable, Equatable, Identifiable {
    enum Kind: String, Codable { case hint, example, freeze, repair }
    var id: UUID
    var epoch: UUID
    var revision: Int
    var day: String
    var kind: Kind
    var cost: Int
    var missedDays: [String]
    var context: String?
}

extension Notification.Name { static let rewardLedgerChanged = Notification.Name("SpeechCoachAI.rewardLedgerChanged") }
