import Foundation
import Testing
@testable import SpeechCoachAI

/// Level from XP, screen-time sessions of a minute or more, the foreground tracker, and the day/week/month/year report.
struct XPLevelAndUsageTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 2      // weeks start on Monday
        return calendar
    }
    private func date(_ day: Int, _ hour: Int = 0, _ minute: Int = 0, month: Int = 10) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: hour, minute: minute))!
    }
    /// "Now" for the tests: 30 November 2026, so October sessions are still inside the 120-day detail window.
    private var later: Date { date(30, 12, month: 11) }

    // MARK: Level

    @Test func levelsGrowFromXP() {
        #expect(XPLevel(xp: 0).level == 1 && XPLevel(xp: 99).level == 1)
        #expect(XPLevel(xp: 100).level == 2 && XPLevel(xp: 299).level == 2 && XPLevel(xp: 300).level == 3)
        #expect(XPLevel.threshold(for: 5) == 1_000 && XPLevel(xp: 1_000).level == 5)
        let level = XPLevel(xp: 150)
        #expect(level.level == 2 && level.xpIntoLevel == 50 && level.xpForLevel == 200 && level.xpToNext == 150 && level.fraction == 0.25)
        #expect(XPLevel(xp: -5).level == 1)
        // A full set of 14 typed exercises (140 XP) already reaches Level 2.
        #expect(XPLevel(xp: 140).level == 2)
    }

    // MARK: Log

    @Test func onlyStretchesOfAMinuteAreKept() {
        var log = UsageLog()
        let r1 = log.record(start: date(1, 9), end: date(1, 9).addingTimeInterval(59), now: later, calendar: calendar)
        #expect(!r1)
        let r2 = log.record(start: date(1, 9), end: date(1, 9).addingTimeInterval(60), now: later, calendar: calendar)
        #expect(r2)
        #expect(log.sessions == [UsageSession(start: date(1, 9), seconds: 60)])
        let r3 = log.record(start: date(1, 12), end: date(1, 11), now: later, calendar: calendar)
        #expect(!r3, "backwards")
        let r4 = log.record(start: .now, end: .now.addingTimeInterval(3_600), now: .now, calendar: calendar)
        #expect(!r4, "ends in the future")
    }

    @Test func overlappingStretchesBecomeOne() {
        var log = UsageLog()
        log.record(start: date(1, 9), end: date(1, 9, 30), now: later, calendar: calendar)
        log.record(start: date(1, 9, 20), end: date(1, 10), now: later, calendar: calendar)
        log.record(start: date(1, 9, 20), end: date(1, 10), now: later, calendar: calendar)   // a repeated save
        log.record(start: date(1, 14), end: date(1, 14, 5), now: later, calendar: calendar)
        #expect(log.sessions.map(\.seconds) == [3_600, 300])
    }

    @Test func oldSessionsFoldIntoDailyTotals() {
        var log = UsageLog()
        let now = date(1, 12, month: 12)
        log.record(start: date(1, 9, month: 6), end: date(1, 9, 30, month: 6), now: now, calendar: calendar)   // 1 June: older than 120 days
        log.record(start: date(30, 9, month: 11), end: date(30, 10, month: 11), now: now, calendar: calendar)
        #expect(log.sessions.count == 1 && log.olderDays["2026-06-01"] == 1_800)
        let report = UsageReport(log: log, calendar: calendar)
        #expect(report.seconds(on: date(1, 20, month: 6)) == 1_800 && report.segments(on: date(1, 20, month: 6)).isEmpty, "folded days keep a total only")
        #expect(report.allSeconds == 1_800 + 3_600)
    }

    // MARK: Tracker

    @Test func aQuickSwitchAwayAndBackIsOneStretch() {
        var tracker = UsageTracker()
        let r5 = tracker.becameActive(at: date(1, 9))
        #expect(r5 == nil)
        tracker.becameInactive(at: date(1, 9, 5))
        let r6 = tracker.becameActive(at: date(1, 9, 5).addingTimeInterval(20))
        #expect(r6 == nil, "back within 30 seconds")
        tracker.heartbeat(at: date(1, 9, 10))
        tracker.becameInactive(at: date(1, 9, 12))
        let r7 = tracker.finishIfIdle(at: date(1, 9, 12).addingTimeInterval(10))
        #expect(r7 == nil, "not idle long enough yet")
        let finished = tracker.finishIfIdle(at: date(1, 9, 14))
        #expect(finished?.start == date(1, 9) && finished?.end == date(1, 9, 12))
        #expect(tracker.start == nil)
    }

    @Test func aLongAbsenceStartsANewStretch() throws {
        var tracker = UsageTracker()
        _ = tracker.becameActive(at: date(1, 9))
        tracker.becameInactive(at: date(1, 9, 3))
        let maybe = tracker.becameActive(at: date(1, 11))
        let finished = try #require(maybe)
        #expect(finished.start == date(1, 9) && finished.end == date(1, 9, 3))
        #expect(tracker.start == date(1, 11) && tracker.isActive)
    }

    @Test func heartbeatsOnlyCountWhileOnScreen() {
        var tracker = UsageTracker()
        _ = tracker.becameActive(at: date(1, 9))
        tracker.becameInactive(at: date(1, 9, 1))
        tracker.heartbeat(at: date(1, 9, 50))
        #expect(tracker.lastSeen == date(1, 9, 1))
        let ended = tracker.finishNow(at: date(1, 9, 55))
        #expect(ended?.end == date(1, 9, 1) && tracker.start == nil)
    }

    // MARK: Recorder

    @MainActor
    @Test func theRecorderSavesOnlyLongStretchesAndKeepsWhatCannotBeSavedYet() {
        let defaults = UserDefaults(suiteName: "usage-test-\(UUID().uuidString)")!
        var now = date(1, 9)
        var saved: [(Date, Date)] = []
        var failing = true
        let recorder = UsageRecorder(defaults: defaults, clock: { now }) { start, end in
            if failing { throw LearnerStorageError.unavailable }
            saved.append((start, end))
        }
        recorder.scenePhaseChanged(.active)
        now = date(1, 9, 0).addingTimeInterval(30); recorder.tick()
        recorder.scenePhaseChanged(.background)
        now = date(1, 9, 5); recorder.tick()        // idle long enough: a 30-second stretch is dropped
        #expect(saved.isEmpty)
        now = date(1, 10); recorder.scenePhaseChanged(.active)
        now = date(1, 10, 5); recorder.tick(); recorder.scenePhaseChanged(.background)
        now = date(1, 10, 9); recorder.tick()       // finished (5 minutes) but the store is locked
        #expect(saved.isEmpty)
        failing = false
        now = date(1, 10, 10); recorder.tick()
        #expect(saved.count == 1 && saved[0].0 == date(1, 10) && saved[0].1 == date(1, 10, 5))
    }

    @MainActor
    @Test func aStretchLeftOpenByACrashIsSavedAtItsLastHeartbeat() {
        let defaults = UserDefaults(suiteName: "usage-test-\(UUID().uuidString)")!
        defaults.set([date(1, 9).timeIntervalSince1970, date(1, 9, 20).timeIntervalSince1970], forKey: "usage.open")
        var saved: [(Date, Date)] = []
        let recorder = UsageRecorder(defaults: defaults, clock: { date(2, 8) }) { saved.append(($0, $1)) }
        recorder.recoverLeftover()
        #expect(saved.count == 1 && saved[0].1 == date(1, 9, 20))
        recorder.recoverLeftover()
        #expect(saved.count == 1, "recovered once")
    }

    // MARK: Report

    private func report() -> UsageReport {
        var log = UsageLog()
        log.record(start: date(5, 8), end: date(5, 8, 30), now: later, calendar: calendar)             // Monday 5 Oct, 30 min
        log.record(start: date(5, 22), end: date(6, 1), now: later, calendar: calendar)                 // crosses midnight: 2 h on Mon, 1 h on Tue
        log.record(start: date(7, 12), end: date(7, 12, 10), now: later, calendar: calendar)            // Wednesday, 10 min
        log.record(start: date(20, 9), end: date(20, 9, 45), now: later, calendar: calendar)            // a later week
        log.record(start: date(3, 9, month: 11), end: date(3, 9, 15, month: 11), now: later, calendar: calendar)
        return UsageReport(log: log, calendar: calendar)
    }

    @Test func aSessionAcrossMidnightIsSplitByDay() {
        let report = report()
        #expect(report.seconds(on: date(5, 12)) == 1_800 + 7_200)
        #expect(report.seconds(on: date(6, 12)) == 3_600)
        #expect(report.segments(on: date(6, 12)).map(\.seconds) == [3_600])
        #expect(report.seconds(on: date(9, 12)) == 0)
    }

    @Test func theDayHas24HourlyBuckets() {
        let buckets = report().buckets(.day, containing: date(5, 12))
        #expect(buckets.count == 24 && buckets[8].seconds == 1_800 && buckets[22].seconds == 3_600 && buckets[23].seconds == 3_600)
        #expect(buckets.reduce(0) { $0 + $1.seconds } == 9_000)
    }

    @Test func weekMonthAndYearAddUpTheirDays() {
        let report = report()
        let week = report.buckets(.week, containing: date(7, 12))
        #expect(week.count == 7 && week[0].start == date(5) && week.map(\.seconds) == [9_000, 3_600, 600, 0, 0, 0, 0])
        #expect(report.total(.week, containing: date(7, 12)) == 13_200)
        #expect(report.total(.month, containing: date(7, 12)) == 13_200 + 2_700 && report.buckets(.month, containing: date(7)).count == 31)
        let year = report.buckets(.year, containing: date(7))
        #expect(year.count == 12 && year[9].seconds == 15_900 && year[10].seconds == 900 && year[0].seconds == 0)
        #expect(report.total(.year, containing: date(7)) == 16_800)
        #expect(report.total(.day, containing: date(20)) == 2_700)
    }

    @Test func daysUsedAndLifetimeTotals() {
        let report = report()
        #expect(report.daysUsed(.week, containing: date(7)) == 3)
        #expect(report.daysUsed(.month, containing: date(7)) == 4)
        #expect(report.daysUsed(.year, containing: date(7)) == 5)
        #expect(report.allDaysUsed == 5 && report.allSeconds == 16_800)
        #expect(UsageFormat.duration(0) == "0 min" && UsageFormat.duration(2_520) == "42 min" && UsageFormat.duration(3_900) == "1 h 05 min")
    }

    // MARK: Storage

    @Test func theRepositoryKeepsTheLogAndOldDocumentsStillOpen() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("UL-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let now = Date()
        let repo = try LearnerRepository(root: root, now: { now }, protectedDataAvailable: { true })
        #expect(try repo.usageLog() == UsageLog(), "a document without a usage log opens empty")
        #expect(try repo.recordUsage(start: now.addingTimeInterval(-600), end: now.addingTimeInterval(-300)))
        #expect(try repo.recordUsage(start: now.addingTimeInterval(-30), end: now) == false)
        #expect(try repo.usageLog().sessions.count == 1)
        try repo.clearUsage()
        #expect(try repo.usageLog().sessions.isEmpty)
    }
}
