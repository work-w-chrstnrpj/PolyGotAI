import Foundation

// MARK: Stored log

/// One stretch of screen time: the app was open on screen for `seconds` starting at `start`. Only stretches of a minute or more are kept.
struct UsageSession: Codable, Equatable, Identifiable {
    var start: Date
    var seconds: Int
    var id: Date { start }
    var end: Date { start.addingTimeInterval(TimeInterval(seconds)) }
}

/// Screen time on this device. Detailed sessions are kept for `detailDays`; older days keep only their total.
struct UsageLog: Codable, Equatable {
    static let minimumSeconds = 60
    static let detailDays = 120

    var sessions: [UsageSession] = []
    /// "yyyy-MM-dd" (local day when it was folded) → seconds, for days older than the detail window.
    var olderDays: [String: Int] = [:]

    /// Adds a stretch of screen time. Stretches under a minute, backwards stretches and stretches that end in the future are ignored.
    @discardableResult
    mutating func record(start: Date, end: Date, now: Date = .now, calendar: Calendar = .current) -> Bool {
        let length = end.timeIntervalSince(start)
        guard length.isFinite, length >= TimeInterval(Self.minimumSeconds), end <= now.addingTimeInterval(5) else { return false }
        let new = UsageSession(start: start, seconds: Int(length.rounded(.down)))
        if let index = sessions.firstIndex(where: { $0.start <= new.end && new.start <= $0.end }) {
            // Overlapping or touching stretches (for example a repeated save) become one.
            let merged = min(sessions[index].start, new.start)
            let mergedEnd = max(sessions[index].end, new.end)
            sessions[index] = UsageSession(start: merged, seconds: Int(mergedEnd.timeIntervalSince(merged)))
        } else {
            sessions.append(new)
        }
        sessions.sort { $0.start < $1.start }
        compact(now: now, calendar: calendar)
        return true
    }

    /// Folds sessions older than the detail window into per-day totals.
    mutating func compact(now: Date, calendar: Calendar = .current) {
        guard let cutoff = calendar.date(byAdding: .day, value: -Self.detailDays, to: calendar.startOfDay(for: now)) else { return }
        let old = sessions.filter { $0.start < cutoff }
        guard !old.isEmpty else { return }
        for session in old {
            for (day, seconds) in UsageReport.split(session, calendar: calendar) { olderDays[day, default: 0] += seconds }
        }
        sessions.removeAll { $0.start < cutoff }
    }
}

// MARK: Tracking foreground time

/// Turns "became active / went inactive" events into whole stretches of screen time. A quick switch to another app and back
/// (within `mergeGap`) continues the same stretch. Pure: the caller passes the clock.
struct UsageTracker: Equatable {
    static let mergeGap: TimeInterval = 30

    private(set) var start: Date?
    private(set) var lastSeen: Date?
    private(set) var isActive = false

    /// The app came to the foreground. Returns an earlier stretch that is now finished, if any.
    mutating func becameActive(at time: Date) -> (start: Date, end: Date)? {
        var finished: (Date, Date)?
        if let start, let lastSeen {
            if !isActive, time.timeIntervalSince(lastSeen) > Self.mergeGap {
                finished = (start, lastSeen)
                self.start = time
            }
        } else {
            start = time
        }
        lastSeen = time
        isActive = true
        return finished
    }

    /// The app left the foreground (another app, the lock screen, the app switcher).
    mutating func becameInactive(at time: Date) {
        guard isActive else { return }
        lastSeen = max(lastSeen ?? time, time)
        isActive = false
    }

    /// While the app is on screen, call this now and then so a crash or a force-quit loses almost nothing.
    mutating func heartbeat(at time: Date) {
        guard isActive else { return }
        lastSeen = max(lastSeen ?? time, time)
    }

    /// A stretch that ended more than `mergeGap` ago is finished. Returns it and clears the tracker.
    mutating func finishIfIdle(at time: Date) -> (start: Date, end: Date)? {
        guard let start, let lastSeen, !isActive, time.timeIntervalSince(lastSeen) > Self.mergeGap else { return nil }
        self.start = nil; self.lastSeen = nil
        return (start, lastSeen)
    }

    /// Ends the open stretch at once (for example when the app is about to be terminated).
    mutating func finishNow(at time: Date) -> (start: Date, end: Date)? {
        guard let start else { return nil }
        let end = max(lastSeen ?? time, isActive ? time : (lastSeen ?? time))
        self.start = nil; self.lastSeen = nil; isActive = false
        return (start, end)
    }
}

// MARK: Reading the log

enum UsagePeriod: String, CaseIterable, Identifiable {
    case day, week, month, year
    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}

/// A piece of one session that falls on a single day.
struct UsageSegment: Equatable, Identifiable {
    var start: Date
    var end: Date
    var id: Date { start }
    var seconds: Int { Int(end.timeIntervalSince(start)) }
}

struct UsageBucket: Equatable, Identifiable {
    var start: Date
    var seconds: Int
    var id: Date { start }
}

struct UsageReport {
    let calendar: Calendar
    /// Day key → segments of that day, in time order.
    private let segmentsByDay: [String: [UsageSegment]]
    private let olderDays: [String: Int]

    init(log: UsageLog, calendar: Calendar = .current) {
        self.calendar = calendar
        olderDays = log.olderDays
        var grouped: [String: [UsageSegment]] = [:]
        for session in log.sessions {
            var cursor = session.start
            while cursor < session.end {
                let dayStart = calendar.startOfDay(for: cursor)
                guard let next = calendar.date(byAdding: .day, value: 1, to: dayStart) else { break }
                let end = min(session.end, next)
                grouped[Self.key(dayStart, calendar), default: []].append(UsageSegment(start: cursor, end: end))
                cursor = end
            }
        }
        segmentsByDay = grouped.mapValues { $0.sorted { $0.start < $1.start } }
    }

    static func key(_ date: Date, _ calendar: Calendar) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }

    /// The pieces of a session by day, as "yyyy-MM-dd" → seconds (used when old sessions are folded into totals).
    static func split(_ session: UsageSession, calendar: Calendar) -> [String: Int] {
        var out: [String: Int] = [:]
        var cursor = session.start
        while cursor < session.end {
            let dayStart = calendar.startOfDay(for: cursor)
            guard let next = calendar.date(byAdding: .day, value: 1, to: dayStart) else { break }
            let end = min(session.end, next)
            out[key(dayStart, calendar), default: 0] += Int(end.timeIntervalSince(cursor))
            cursor = end
        }
        return out
    }

    /// Screen time in the segments of one day, from detailed sessions or the folded total.
    func seconds(on date: Date) -> Int {
        let key = Self.key(date, calendar)
        if let segments = segmentsByDay[key] { return segments.reduce(0) { $0 + $1.seconds } + (olderDays[key] ?? 0) }
        return olderDays[key] ?? 0
    }

    /// The timeline of one day. Empty for days that were folded into a total.
    func segments(on date: Date) -> [UsageSegment] { segmentsByDay[Self.key(date, calendar)] ?? [] }

    /// The buckets of a period around `date`: 24 hours, 7 days, the days of the month, or 12 months.
    func buckets(_ period: UsagePeriod, containing date: Date) -> [UsageBucket] {
        switch period {
        case .day:
            let dayStart = calendar.startOfDay(for: date)
            let segments = self.segments(on: date)
            return (0..<24).compactMap { hour in
                guard let start = calendar.date(byAdding: .hour, value: hour, to: dayStart),
                      let end = calendar.date(byAdding: .hour, value: 1, to: start) else { return nil }
                let seconds = segments.reduce(0) { total, segment in
                    total + max(0, Int(min(segment.end, end).timeIntervalSince(max(segment.start, start))))
                }
                return UsageBucket(start: start, seconds: seconds)
            }
        case .week:
            guard let interval = calendar.dateInterval(of: .weekOfYear, for: date) else { return [] }
            return days(from: interval.start, count: 7)
        case .month:
            guard let interval = calendar.dateInterval(of: .month, for: date),
                  let count = calendar.range(of: .day, in: .month, for: date)?.count else { return [] }
            return days(from: interval.start, count: count)
        case .year:
            guard let interval = calendar.dateInterval(of: .year, for: date) else { return [] }
            return (0..<12).compactMap { month in
                guard let start = calendar.date(byAdding: .month, value: month, to: interval.start),
                      let monthDays = calendar.range(of: .day, in: .month, for: start)?.count else { return nil }
                return UsageBucket(start: start, seconds: days(from: start, count: monthDays).reduce(0) { $0 + $1.seconds })
            }
        }
    }

    func total(_ period: UsagePeriod, containing date: Date) -> Int {
        period == .day ? seconds(on: date) : buckets(period, containing: date).reduce(0) { $0 + $1.seconds }
    }

    /// Days with any screen time in the period.
    func daysUsed(_ period: UsagePeriod, containing date: Date) -> Int {
        switch period {
        case .day: return seconds(on: date) > 0 ? 1 : 0
        case .week, .month: return buckets(period, containing: date).filter { $0.seconds > 0 }.count
        case .year:
            guard let interval = calendar.dateInterval(of: .year, for: date) else { return 0 }
            return days(from: interval.start, count: calendar.range(of: .day, in: .year, for: date)?.count ?? 365).filter { $0.seconds > 0 }.count
        }
    }

    /// Every day that has screen time, oldest first (for lifetime totals and milestones).
    var allSeconds: Int { segmentsByDay.values.joined().reduce(0) { $0 + $1.seconds } + olderDays.values.reduce(0, +) }
    var allDaysUsed: Int { Set(segmentsByDay.keys).union(olderDays.keys).count }

    private func days(from start: Date, count: Int) -> [UsageBucket] {
        (0..<count).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: start) else { return nil }
            return UsageBucket(start: day, seconds: seconds(on: day))
        }
    }
}

enum UsageFormat {
    /// "1 h 05 min", "42 min", "0 min".
    static func duration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        if minutes >= 60 { return String(format: "%d h %02d min", minutes / 60, minutes % 60) }
        return "\(minutes) min"
    }
}
