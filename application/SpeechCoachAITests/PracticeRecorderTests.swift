import Foundation
import SwiftUI
import Testing
@testable import SpeechCoachAI

/// Ticket #6: the app-layer practice recorder with a fake clock. Real elapsed time on a device (AC1, AC5) is covered by
/// these tests plus QA ticket #9. Synthetic data, isolated defaults suite, never the owner's data.
@MainActor
struct PracticeRecorderTests {
    final class Clock { var now = Date(timeIntervalSince1970: 1_800_000_000); func advance(_ s: Double) { now += s } }
    final class Sink { var saved: [PracticeStretch] = []; var failing = false }

    private func make(suite: String = UUID().uuidString, clock: Clock, sink: Sink) -> PracticeRecorder {
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return PracticeRecorder(defaults: defaults, clock: { clock.now }) { s in
            if sink.failing { throw LearnerStorageError.unavailable }
            sink.saved.append(s)
        }
    }

    /// Advances in 30 s steps with a touch and a heartbeat each.
    private func use(_ r: PracticeRecorder, _ c: Clock, seconds: Int) {
        for _ in 0..<(seconds / 30) { c.advance(30); r.touched(); r.tick() }
    }

    @Test("#6 AC1 one minute in a practice screen saves one minute under its area")
    func ac1() {
        for area in PracticeArea.allCases {
            let c = Clock(), s = Sink(); let r = make(clock: c, sink: s)
            r.areaChanged(area); use(r, c, seconds: 60); r.areaChanged(nil)
            #expect(s.saved.map(\.area) == [area] && s.saved.first?.seconds == 60)
        }
        let c = Clock(), s = Sink(); let r = make(clock: c, sink: s)
        r.areaChanged(.lesson); use(r, c, seconds: 30); r.areaChanged(nil)
        #expect(s.saved.isEmpty, "under a minute is not kept")
    }

    @Test("#6 AC2 with no practice screen open nothing is recorded")
    func ac2() {
        let c = Clock(), s = Sink(); let r = make(clock: c, sink: s)
        use(r, c, seconds: 600); r.areaChanged(nil)
        #expect(s.saved.isEmpty && r.openArea == nil)
    }

    @Test("#6 AC3 an untouched practice screen stops counting after 2 minutes")
    func ac3() {
        let c = Clock(), s = Sink(); let r = make(clock: c, sink: s)
        r.areaChanged(.lesson)
        for _ in 0..<40 { c.advance(15); r.tick() }   // 10 min, no touch
        r.areaChanged(nil)
        #expect(s.saved.first?.seconds == 120)
    }

    @Test("#6 AC4 away 30 s or less keeps one stretch; longer ends it and starts a new one")
    func ac4() {
        let c = Clock(), s = Sink(); let r = make(clock: c, sink: s)
        r.areaChanged(.lexicon); use(r, c, seconds: 60)
        r.scenePhaseChanged(.background); c.advance(30); r.scenePhaseChanged(.active)
        use(r, c, seconds: 60); r.areaChanged(nil)
        #expect(s.saved.count == 1 && s.saved[0].seconds == 120)

        let c2 = Clock(), s2 = Sink(); let r2 = make(clock: c2, sink: s2)
        r2.areaChanged(.lab); use(r2, c2, seconds: 60)
        r2.scenePhaseChanged(.background); c2.advance(31); r2.scenePhaseChanged(.active)
        #expect(s2.saved.count == 1 && s2.saved[0].seconds == 60)
        use(r2, c2, seconds: 60); r2.areaChanged(nil)
        #expect(s2.saved.count == 2)
    }

    @Test("#6 AC5 a crash keeps the time up to the last heartbeat; a failed save is kept and retried")
    func ac5() {
        let suite = UUID().uuidString
        let c = Clock(), s = Sink(); let r = make(suite: suite, clock: c, sink: s)
        r.areaChanged(.lab); use(r, c, seconds: 90)
        // force-quit: a new recorder over the same defaults
        let defaults = UserDefaults(suiteName: suite)!
        let s2 = Sink()
        let reborn = PracticeRecorder(defaults: defaults, clock: { c.now }) { s2.saved.append($0) }
        reborn.recoverLeftover()
        #expect(s2.saved == [PracticeStretch(start: s2.saved.first?.start ?? c.now, seconds: 90, area: .lab)])

        let c3 = Clock(), s3 = Sink(); let r3 = make(clock: c3, sink: s3)
        s3.failing = true
        r3.areaChanged(.lesson); use(r3, c3, seconds: 60); r3.areaChanged(nil)
        #expect(s3.saved.isEmpty)
        s3.failing = false; r3.tick()
        #expect(s3.saved.count == 1)
    }

    @Test("#6 AC6 storage keeps only times and areas, on the device")
    func ac6() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("PR-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let repo = try LearnerRepository(root: root, now: { now.addingTimeInterval(7200) }, protectedDataAvailable: { true })
        let stretch = PracticeStretch(start: now, seconds: 60, area: .lesson)
        try repo.recordPractice(stretch)
        #expect(try repo.practiceLog().stretches == [stretch])
        #expect(Set(Mirror(reflecting: stretch).children.compactMap(\.label)) == ["start", "seconds", "area"])
    }
}
