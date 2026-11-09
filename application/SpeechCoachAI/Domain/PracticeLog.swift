import Foundation

// MARK: Stored log

/// The three places where the learner practises. Shared with the tab bar marker (ticket #4).
enum PracticeArea: String, Codable, CaseIterable, Identifiable {
    case lesson, lexicon, lab
    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}

/// One stretch of practice: `seconds` of active time in one area, starting at `start`. Idle time and time away are not counted,
/// so `seconds` can be shorter than the wall-clock span. Only stretches of a minute or more are kept.
struct PracticeStretch: Codable, Equatable, Identifiable {
    var start: Date
    var seconds: Int
    var area: PracticeArea
    var id: String { "\(area.rawValue)-\(start.timeIntervalSince1970)" }
}

/// Practice time on this device, kept apart from screen time (`UsageLog`).
struct PracticeLog: Codable, Equatable {
    static let minimumSeconds = 60

    var stretches: [PracticeStretch] = []

    /// Adds a stretch. Stretches under a minute, stretches that start in the future and exact repeats (a repeated save) are ignored.
    @discardableResult
    mutating func record(_ stretch: PracticeStretch, now: Date = .now) -> Bool {
        guard stretch.seconds >= Self.minimumSeconds, stretch.start <= now.addingTimeInterval(5),
              !stretches.contains(stretch) else { return false }
        stretches.append(stretch)
        stretches.sort { $0.start < $1.start }
        return true
    }

    /// A copy that also counts the stretch still open, so a screen shows it before it is saved.
    func including(_ open: PracticeStretch?, now: Date = .now) -> PracticeLog {
        var copy = self
        if let open { copy.record(open, now: now) }
        return copy
    }
}

// MARK: Tracking

/// What a crash leaves behind: the open stretch as of its last heartbeat. Keep it on disk and pass it to `PracticeTracker.recover`.
struct PracticeOpenSnapshot: Codable, Equatable {
    var area: PracticeArea
    var start: Date
    var seconds: Int
}

/// Turns practice events into stretches. A stretch counts only while a practice screen is open, the app is in front and
/// the learner touched the screen in the last `idleLimit` seconds. Pure: every event carries its time.
struct PracticeTracker: Equatable {
    static let idleLimit: TimeInterval = 120
    static let mergeGap: TimeInterval = 30

    private(set) var area: PracticeArea?
    private var start = Date.distantPast
    private var counted: TimeInterval = 0
    private var mark = Date.distantPast         // time up to which `counted` is brought up to date
    private var lastTouch = Date.distantPast
    private(set) var isActive = true
    private var awaySince: Date?

    var isOpen: Bool { area != nil }

    /// A practice screen opened. A stretch already open in another area is finished and returned.
    @discardableResult
    mutating func screenOpened(_ area: PracticeArea, at time: Date) -> [PracticeStretch] {
        var out: [PracticeStretch] = []
        if let finished = finish(at: time) { out.append(finished) }
        begin(area, at: time)
        return out
    }

    /// The practice screen closed.
    mutating func screenClosed(at time: Date) -> [PracticeStretch] {
        finish(at: time).map { [$0] } ?? []
    }

    mutating func touch(at time: Date) {
        guard isOpen, isActive else { return }
        advance(to: time)
        lastTouch = max(lastTouch, time)
    }

    /// Call every few seconds while the screen is open.
    mutating func heartbeat(at time: Date) {
        guard isOpen, isActive else { return }
        advance(to: time)
    }

    /// The app left the foreground.
    @discardableResult
    mutating func becameInactive(at time: Date) -> [PracticeStretch] {
        guard isOpen, isActive else { return [] }
        advance(to: time)
        isActive = false
        awaySince = time
        return []
    }

    /// The app came back. Away for `mergeGap` seconds or less continues the stretch; longer finishes it and, because the
    /// screen is still open, starts a new one.
    mutating func becameActive(at time: Date) -> [PracticeStretch] {
        guard let area, !isActive, let away = awaySince else { return [] }
        if time.timeIntervalSince(away) <= Self.mergeGap {
            isActive = true; awaySince = nil
            mark = time; lastTouch = time
            return []
        }
        let finished = finishAway()
        begin(area, at: time)
        return finished.map { [$0] } ?? []
    }

    /// A stretch whose app has been away for more than `mergeGap` seconds is finished (screen closed in the background).
    mutating func finishIfAway(at time: Date) -> [PracticeStretch] {
        guard isOpen, !isActive, let away = awaySince, time.timeIntervalSince(away) > Self.mergeGap else { return [] }
        let finished = finishAway()
        area = nil
        return finished.map { [$0] } ?? []
    }

    /// The stretch in progress as it stands at `time`, once it has passed a minute (for Progress and Today before it is saved).
    /// Reads only; the tracker is not changed. Nil while the app is away or the stretch is still under a minute.
    func openStretch(at time: Date) -> PracticeStretch? {
        guard let area, isActive else { return nil }
        var copy = self
        copy.advance(to: time)
        let seconds = Int(copy.counted)
        return seconds >= PracticeLog.minimumSeconds ? PracticeStretch(start: start, seconds: seconds, area: area) : nil
    }

    /// The open stretch as of now, for the recorder to keep on disk after each heartbeat.
    var openSnapshot: PracticeOpenSnapshot? {
        guard let area else { return nil }
        return PracticeOpenSnapshot(area: area, start: start, seconds: Int(counted))
    }

    /// Closes a stretch left open by a crash at its last heartbeat. Nil when there is none or it was under a minute.
    static func recover(_ snapshot: PracticeOpenSnapshot?) -> PracticeStretch? {
        guard let snapshot, snapshot.seconds >= PracticeLog.minimumSeconds else { return nil }
        return PracticeStretch(start: snapshot.start, seconds: snapshot.seconds, area: snapshot.area)
    }

    // MARK: Private

    private mutating func begin(_ area: PracticeArea, at time: Date) {
        self.area = area
        start = time; mark = time; lastTouch = time
        counted = 0; isActive = true; awaySince = nil
    }

    /// Counts the active time between the last event and `time`, never past the idle limit.
    private mutating func advance(to time: Date) {
        guard time > mark else { return }
        let upto = min(time, lastTouch.addingTimeInterval(Self.idleLimit))
        if upto > mark { counted += upto.timeIntervalSince(mark) }
        mark = time
    }

    /// Ends the open stretch and clears the tracker.
    private mutating func finish(at time: Date) -> PracticeStretch? {
        guard let area else { return nil }
        if isActive { advance(to: time) }
        return close(area)
    }

    /// Ends a stretch whose app left earlier: the time away is not counted.
    private mutating func finishAway() -> PracticeStretch? {
        guard let area else { return nil }
        return close(area)
    }

    private mutating func close(_ area: PracticeArea) -> PracticeStretch? {
        let stretch = PracticeStretch(start: start, seconds: Int(counted), area: area)
        self.area = nil; counted = 0; isActive = true; awaySince = nil
        return stretch.seconds >= PracticeLog.minimumSeconds ? stretch : nil
    }
}

// MARK: Reading the log

/// One area's slice of a period.
struct PracticeShare: Equatable, Identifiable {
    var area: PracticeArea
    var seconds: Int
    var fraction: Double
    var id: PracticeArea { area }
}

/// Practice totals per day, week, month and year, overall and per area. A stretch belongs to the day it started on.
struct PracticeReport {
    let calendar: Calendar
    private let stretches: [PracticeStretch]

    init(log: PracticeLog, calendar: Calendar = .current) {
        self.calendar = calendar
        stretches = log.stretches
    }

    /// Practice seconds in the period around `date`, for one area or (nil) all areas.
    func seconds(_ area: PracticeArea? = nil, in period: UsagePeriod, containing date: Date) -> Int {
        guard let interval = interval(period, containing: date) else { return 0 }
        return stretches.reduce(0) { total, stretch in
            interval.contains(stretch.start) && (area == nil || stretch.area == area) ? total + stretch.seconds : total
        }
    }

    func total(_ period: UsagePeriod, containing date: Date) -> Int { seconds(nil, in: period, containing: date) }

    /// Every area has an entry, zero when unused.
    func byArea(_ period: UsagePeriod, containing date: Date) -> [PracticeArea: Int] {
        Dictionary(uniqueKeysWithValues: PracticeArea.allCases.map { ($0, seconds($0, in: period, containing: date)) })
    }

    /// The buckets of a period around `date`: 24 hours, 7 days, the days of the month, or 12 months. Same shape as screen time.
    func buckets(_ period: UsagePeriod, containing date: Date) -> [UsageBucket] {
        let starts: [Date]
        let component: Calendar.Component
        switch period {
        case .day:
            let dayStart = calendar.startOfDay(for: date)
            starts = (0..<24).compactMap { calendar.date(byAdding: .hour, value: $0, to: dayStart) }; component = .hour
        case .week:
            guard let interval = calendar.dateInterval(of: .weekOfYear, for: date) else { return [] }
            starts = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: interval.start) }; component = .day
        case .month:
            guard let interval = calendar.dateInterval(of: .month, for: date),
                  let count = calendar.range(of: .day, in: .month, for: date)?.count else { return [] }
            starts = (0..<count).compactMap { calendar.date(byAdding: .day, value: $0, to: interval.start) }; component = .day
        case .year:
            guard let interval = calendar.dateInterval(of: .year, for: date) else { return [] }
            starts = (0..<12).compactMap { calendar.date(byAdding: .month, value: $0, to: interval.start) }; component = .month
        }
        return starts.map { start in
            let end = calendar.date(byAdding: component, value: 1, to: start) ?? start
            let seconds = stretches.reduce(0) { $1.start >= start && $1.start < end ? $0 + $1.seconds : $0 }
            return UsageBucket(start: start, seconds: seconds)
        }
    }

    /// Lesson, Lexicon and Lab for the period, each with its share of the total (all zero when there is no practice).
    func shares(_ period: UsagePeriod, containing date: Date) -> [PracticeShare] {
        let totals = byArea(period, containing: date)
        let all = totals.values.reduce(0, +)
        return PracticeArea.allCases.map { area in
            let seconds = totals[area] ?? 0
            return PracticeShare(area: area, seconds: seconds, fraction: all == 0 ? 0 : Double(seconds) / Double(all))
        }
    }

    private func interval(_ period: UsagePeriod, containing date: Date) -> DateInterval? {
        switch period {
        case .day: return calendar.dateInterval(of: .day, for: date)
        case .week: return calendar.dateInterval(of: .weekOfYear, for: date)
        case .month: return calendar.dateInterval(of: .month, for: date)
        case .year: return calendar.dateInterval(of: .year, for: date)
        }
    }
}
