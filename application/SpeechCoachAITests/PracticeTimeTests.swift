import Foundation
import Testing
@testable import SpeechCoachAI

/// Ticket #5: practice time as data (tracker, report, storage). Synthetic data and isolated stores only.
struct PracticeTimeTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 2
        return calendar
    }
    private func date(_ day: Int, _ hour: Int = 0, _ minute: Int = 0, _ second: Int = 0, month: Int = 10) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: hour, minute: minute, second: second))!
    }
    private func at(_ seconds: Int) -> Date { date(1, 9).addingTimeInterval(TimeInterval(seconds)) }

    /// Runs a screen from 0 s with a touch every 30 s up to `seconds`, then closes it.
    private func stretch(lasting seconds: Int) -> [PracticeStretch] {
        var tracker = PracticeTracker()
        tracker.screenOpened(.lesson, at: at(0))
        var t = 30
        while t < seconds { tracker.touch(at: at(t)); t += 30 }
        return tracker.screenClosed(at: at(seconds))
    }

    // MARK: AC1

    @Test("#5 AC1 a stretch is recorded only once it has lasted one minute")
    func ac1OneMinute() {
        #expect(stretch(lasting: 59).isEmpty)
        let kept = stretch(lasting: 60)
        #expect(kept == [PracticeStretch(start: at(0), seconds: 60, area: .lesson)])
        var log = PracticeLog()
        #expect(log.record(PracticeStretch(start: at(0), seconds: 59, area: .lab), now: at(600)) == false)
        #expect(log.record(kept[0], now: at(600)) && log.stretches.count == 1)
    }

    // MARK: AC2

    @Test("#5 AC2 a stretch pauses after 2 minutes with no touch and idle time is not counted")
    func ac2IdlePause() {
        var tracker = PracticeTracker()
        tracker.screenOpened(.lexicon, at: at(0))
        tracker.touch(at: at(60))                       // active until 60, then idle
        tracker.heartbeat(at: at(120))
        tracker.heartbeat(at: at(400))                  // counted only up to 60 + 120 = 180
        tracker.touch(at: at(1_000))                    // back after a long pause: idle time skipped
        let done = tracker.screenClosed(at: at(1_030))  // 30 more seconds
        #expect(done == [PracticeStretch(start: at(0), seconds: 180 + 30, area: .lexicon)])
    }

    // MARK: AC3

    @Test("#5 AC3 leaving the app for 30 seconds or less continues the stretch; longer ends it")
    func ac3LeavingTheApp() {
        var tracker = PracticeTracker()
        tracker.screenOpened(.lab, at: at(0))
        tracker.touch(at: at(40))
        _ = tracker.becameInactive(at: at(50))
        #expect(tracker.becameActive(at: at(80)).isEmpty, "30 seconds away continues")   // 50 s counted so far
        tracker.touch(at: at(110))
        let continued = tracker.screenClosed(at: at(140))                                  // + 60 s
        #expect(continued == [PracticeStretch(start: at(0), seconds: 110, area: .lab)])

        var longer = PracticeTracker()
        longer.screenOpened(.lab, at: at(0))
        longer.touch(at: at(60))
        _ = longer.becameInactive(at: at(90))
        let ended = longer.becameActive(at: at(121))                                       // 31 s away
        #expect(ended == [PracticeStretch(start: at(0), seconds: 90, area: .lab)])
        // The screen is still open, so a new stretch starts on return.
        longer.touch(at: at(150))
        #expect(longer.screenClosed(at: at(160)).isEmpty, "the new stretch has not lasted a minute")
    }

    @Test("#5 AC3 a stretch left in the background is finished once the gap has passed")
    func ac3FinishWhileAway() {
        var tracker = PracticeTracker()
        tracker.screenOpened(.lesson, at: at(0))
        tracker.touch(at: at(45))
        _ = tracker.becameInactive(at: at(75))
        #expect(tracker.finishIfAway(at: at(100)).isEmpty)
        #expect(tracker.finishIfAway(at: at(106)) == [PracticeStretch(start: at(0), seconds: 75, area: .lesson)])
        #expect(tracker.finishIfAway(at: at(500)).isEmpty)
    }

    // MARK: AC4

    @Test("#5 AC4 after a crash the stretch is closed at its last heartbeat")
    func ac4CrashRecovery() {
        var tracker = PracticeTracker()
        tracker.screenOpened(.lexicon, at: at(0))
        tracker.touch(at: at(60))
        tracker.heartbeat(at: at(100))
        let saved = tracker.openSnapshot                 // what the recorder keeps on disk
        tracker.touch(at: at(130))                       // lost in the crash
        let recovered = PracticeTracker.recover(saved)
        #expect(recovered == PracticeStretch(start: at(0), seconds: 100, area: .lexicon))
        var short = PracticeTracker()
        short.screenOpened(.lab, at: at(0)); short.heartbeat(at: at(20))
        #expect(PracticeTracker.recover(short.openSnapshot) == nil, "under a minute is not kept")
        #expect(PracticeTracker.recover(nil) == nil)
    }

    // MARK: AC5

    @Test("#5 AC5 totals per day, week, month and year, and per area")
    func ac5Totals() {
        var log = PracticeLog()
        let now = date(30, 12, month: 11)
        log.record(PracticeStretch(start: date(5, 9), seconds: 600, area: .lesson), now: now)
        log.record(PracticeStretch(start: date(5, 20), seconds: 300, area: .lab), now: now)
        log.record(PracticeStretch(start: date(7, 9), seconds: 120, area: .lexicon), now: now)   // same week (Mon 5 – Sun 11)
        log.record(PracticeStretch(start: date(20, 9), seconds: 60, area: .lesson), now: now)    // same month
        log.record(PracticeStretch(start: date(3, 9, month: 3), seconds: 900, area: .lexicon), now: now) // same year
        log.record(PracticeStretch(start: date(3, 9, month: 3).addingTimeInterval(-365 * 86_400), seconds: 777, area: .lab), now: now) // 2025
        let report = PracticeReport(log: log, calendar: calendar)
        let day = date(5, 12)
        #expect(report.total(.day, containing: day) == 900)
        #expect(report.total(.week, containing: day) == 1_020)
        #expect(report.total(.month, containing: day) == 1_080)
        #expect(report.total(.year, containing: day) == 1_980)
        #expect(report.total(.day, containing: date(6, 12)) == 0)
        #expect(report.seconds(.lesson, in: .month, containing: day) == 660)
        #expect(report.seconds(.lab, in: .year, containing: day) == 300)
        #expect(report.byArea(.week, containing: day) == [.lesson: 600, .lexicon: 120, .lab: 300])
        #expect(report.byArea(.day, containing: date(6, 12)) == [.lesson: 0, .lexicon: 0, .lab: 0])
        #expect(PracticeArea.allCases == [.lesson, .lexicon, .lab])
    }

    // MARK: AC6

    private func makeRepo() throws -> (LearnerRepository, URL, Date) {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("PT-\(UUID().uuidString)")
        let now = date(20, 12)
        return (try LearnerRepository(root: root, now: { now }, protectedDataAvailable: { true }), root, now)
    }

    @Test("#5 AC6 saved practice stretches load back unchanged; an older document loads with an empty log")
    func ac6Storage() throws {
        let (repo, root, now) = try makeRepo()
        defer { try? FileManager.default.removeItem(at: root) }
        #expect(try repo.practiceLog() == PracticeLog(), "no practice field yet: empty log")
        let one = PracticeStretch(start: now.addingTimeInterval(-900), seconds: 300, area: .lexicon)
        let two = PracticeStretch(start: now.addingTimeInterval(-3_000), seconds: 90, area: .lab)
        #expect(try repo.recordPractice(one) && repo.recordPractice(two))
        #expect(try repo.recordPractice(PracticeStretch(start: now, seconds: 10, area: .lab)) == false)
        #expect(try repo.practiceLog().stretches == [two, one])
        // Reopen the same store: unchanged.
        let again = try LearnerRepository(root: root, now: { now }, protectedDataAvailable: { true })
        #expect(try again.practiceLog().stretches == [two, one])

        // A document saved before this change has no "practice" key.
        var doc = try repo.document()
        doc.practice = nil
        var object = try #require(try JSONSerialization.jsonObject(with: JSONEncoder().encode(doc)) as? [String: Any])
        #expect(object["practice"] == nil)
        object["practice"] = nil
        let old = try JSONDecoder().decode(LearnerRepository.LearnerDocument.self, from: JSONSerialization.data(withJSONObject: object))
        #expect(old.practice == nil)
        try repo.clearPractice()
        #expect(try repo.practiceLog().stretches.isEmpty)
    }

    // MARK: AC7

    @Test("#5 AC7 screen time totals and history are identical with practice time stored")
    func ac7ScreenTimeUnchanged() throws {
        let (repo, root, now) = try makeRepo()
        defer { try? FileManager.default.removeItem(at: root) }
        #expect(try repo.recordUsage(start: now.addingTimeInterval(-3_600), end: now.addingTimeInterval(-3_000)))
        let before = try repo.usageLog()
        let totalBefore = UsageReport(log: before, calendar: calendar).allSeconds
        _ = try repo.recordPractice(PracticeStretch(start: now.addingTimeInterval(-900), seconds: 300, area: .lesson))
        #expect(try repo.usageLog() == before)
        #expect(UsageReport(log: try repo.usageLog(), calendar: calendar).allSeconds == totalBefore && totalBefore == 600)
        try repo.clearPractice()
        #expect(try repo.usageLog() == before, "clearing practice leaves screen time alone")
        try repo.clearUsage()
        _ = try repo.recordPractice(PracticeStretch(start: now.addingTimeInterval(-900), seconds: 300, area: .lab))
        try repo.clearUsage()
        #expect(try repo.practiceLog().stretches.count == 1, "clearing screen time leaves practice alone")
    }
}
