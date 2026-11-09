import Foundation
import Testing
@testable import SpeechCoachAI

/// Ticket #7: practice time in Progress and Today (the numbers behind the screens). Synthetic data only.
/// The UI itself is covered by ProgressPracticeUITests.
struct PracticeTimeScreensTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 2
        return calendar
    }
    private func date(_ day: Int, _ hour: Int = 9, month: Int = 10) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: hour))!
    }
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    private func sampleLog() -> PracticeLog {
        var log = PracticeLog()
        let all = date(31, 23)
        log.record(PracticeStretch(start: date(14, 9), seconds: 600, area: .lesson), now: all)   // Wed
        log.record(PracticeStretch(start: date(14, 15), seconds: 300, area: .lexicon), now: all)
        log.record(PracticeStretch(start: date(15, 9), seconds: 120, area: .lab), now: all)      // Thu, same week
        log.record(PracticeStretch(start: date(2, 9), seconds: 900, area: .lesson), now: all)    // earlier in the month
        log.record(PracticeStretch(start: date(5, 9, month: 3), seconds: 1800, area: .lab), now: all) // other month
        return log
    }

    @Test("#7 AC1 practice time has its own totals for day, week, month and year")
    func ac1Totals() {
        let report = PracticeReport(log: sampleLog(), calendar: calendar)
        let day = date(14)
        #expect(report.total(.day, containing: day) == 900)
        #expect(report.total(.week, containing: day) == 1020)
        #expect(report.total(.month, containing: day) == 1920)
        #expect(report.total(.year, containing: day) == 3720)
        for period in UsagePeriod.allCases {
            let buckets = report.buckets(period, containing: day)
            #expect(buckets.map(\.seconds).reduce(0, +) == report.total(period, containing: day), "\(period)")
        }
        #expect(report.buckets(.day, containing: day).count == 24)
        #expect(report.buckets(.week, containing: day).count == 7)
        #expect(report.buckets(.month, containing: day).count == 31)
        #expect(report.buckets(.year, containing: day).count == 12)
        #expect(report.buckets(.day, containing: day)[9].seconds == 600)
        #expect(report.buckets(.year, containing: day)[2].seconds == 1800)
    }

    @Test("#7 AC1 the stretch still open counts before it is saved")
    func ac1OpenStretch() {
        let open = PracticeStretch(start: date(14, 20), seconds: 240, area: .lexicon)
        let log = sampleLog().including(open, now: date(14, 21))
        #expect(PracticeReport(log: log, calendar: calendar).total(.day, containing: date(14)) == 1140)
        #expect(sampleLog().including(nil) == sampleLog())
    }

    @Test("#7 AC1 a tracker with a stretch past one minute reports it while it is open, and changes nothing")
    func ac1TrackerOpenStretch() {
        var tracker = PracticeTracker()
        let t0 = date(14, 9)
        tracker.screenOpened(.lab, at: t0)
        #expect(tracker.openStretch(at: t0.addingTimeInterval(59)) == nil)
        tracker.touch(at: t0.addingTimeInterval(60))
        let open = tracker.openStretch(at: t0.addingTimeInterval(90))
        #expect(open == PracticeStretch(start: t0, seconds: 90, area: .lab))
        #expect(tracker.screenClosed(at: t0.addingTimeInterval(90)).first?.seconds == 90)
        #expect(tracker.openStretch(at: t0.addingTimeInterval(200)) == nil, "closed")
    }

    @Test("#7 AC2 the breakdown lists Lesson, Lexicon and Lab for the chosen period")
    func ac2Breakdown() {
        let report = PracticeReport(log: sampleLog(), calendar: calendar)
        let day = report.shares(.day, containing: date(14))
        #expect(day.map(\.area) == [.lesson, .lexicon, .lab])
        #expect(day.map(\.seconds) == [600, 300, 0])
        #expect(abs(day[0].fraction - 2.0 / 3.0) < 0.001)
        let month = report.shares(.month, containing: date(14))
        #expect(month.map(\.seconds) == [1500, 300, 120])
        #expect(abs(month.map(\.fraction).reduce(0, +) - 1) < 0.001)
        #expect(report.shares(.year, containing: date(14)).map(\.seconds) == [1500, 300, 1920])
    }

    @Test("#7 AC3 Today shows today's practice time, not screen time")
    func ac3Today() throws {
        var usage = UsageLog()
        _ = usage.record(start: date(14, 8), end: date(14, 12), now: date(31, 23), calendar: calendar)   // four hours of screen time
        let practice = PracticeReport(log: sampleLog(), calendar: calendar)
        let minutes = practice.total(.day, containing: date(14)) / 60
        #expect(minutes == 15)
        #expect(UsageFormat.duration(minutes * 60) == "15 min")
        #expect(UsageReport(log: usage, calendar: calendar).seconds(on: date(14)) == 4 * 3600)
        #expect(practice.total(.day, containing: date(16)) == 0, "a day without practice")
    }

    @Test("#7 AC4 with no practice yet every number is zero and nothing fails")
    func ac4Empty() {
        let report = PracticeReport(log: PracticeLog(), calendar: calendar)
        for period in UsagePeriod.allCases {
            #expect(report.total(period, containing: now) == 0)
            #expect(report.buckets(period, containing: now).allSatisfy { $0.seconds == 0 })
            let shares = report.shares(period, containing: now)
            #expect(shares.count == 3 && shares.allSatisfy { $0.seconds == 0 && $0.fraction == 0 })
        }
        #expect(UsageFormat.duration(0) == "0 min")
        #expect(PracticeLog().including(nil).stretches.isEmpty)
    }
}
