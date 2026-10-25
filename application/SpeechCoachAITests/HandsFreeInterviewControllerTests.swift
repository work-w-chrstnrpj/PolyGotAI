import Foundation
import Testing
@testable import SpeechCoachAI

@MainActor
struct HandsFreeInterviewControllerTests {
    private let now = Date(timeIntervalSince1970: 2_000_000_000)

    @Test func captionsAndSilenceDriveTheScriptToItsSummary() {
        let controller = HandsFreeInterviewController(fixture: true)
        controller.start(set: "general", level: "C2", bank: SpeechLabCatalog.bundled.interview, now: now)
        var sawCaption = false
        for step in 1...400 {
            controller.tick(now: now.addingTimeInterval(Double(step) * 0.25))
            sawCaption = sawCaption || !controller.caption.isEmpty
            if controller.phase == .summary { break }
        }
        #expect(sawCaption)
        #expect(controller.phase == .summary)
        #expect(controller.interview?.summary.answered ?? 0 > 0)
        #expect(controller.interview?.summary.followUps ?? 0 > 0)
        #expect(controller.caption.isEmpty)
    }

    @Test func pausePreventsLateCaptureAndRepeatSkipRemainSeparateFromAnswers() {
        let controller = HandsFreeInterviewController(fixture: true)
        controller.start(set: "general", level: "A1", bank: SpeechLabCatalog.bundled.interview, now: now)
        controller.tick(now: now.addingTimeInterval(0.4))
        controller.tick(now: now.addingTimeInterval(1.5))
        #expect(!controller.caption.isEmpty)
        controller.pause()
        controller.tick(now: now.addingTimeInterval(200))
        #expect(controller.phase == .paused)
        #expect(controller.caption.isEmpty)
        #expect(controller.interview?.turns.isEmpty == true)
        controller.resume(now: now.addingTimeInterval(201))
        controller.repeatQuestion(now: now.addingTimeInterval(202))
        controller.skip(now: now.addingTimeInterval(203))
        #expect(controller.interview?.turns.first?.skipped == true)
        #expect(controller.interview?.turns.first?.repeats == 1)
        controller.finish(now: now.addingTimeInterval(204))
        #expect(controller.phase == .summary)
        #expect(controller.interview?.summary.answered == 0)
        #expect(controller.interview?.summary.skipped == 1)
        controller.reset()
        #expect(controller.phase == .setup && controller.interview == nil)
    }

    @Test func silenceOffersSkipWithoutInventingAnAnswer() {
        let controller = HandsFreeInterviewController(fixture: true, silentFixture: true)
        controller.start(set: "general", level: "A1", bank: SpeechLabCatalog.bundled.interview, now: now)
        for step in 1...120 { controller.tick(now: now.addingTimeInterval(Double(step) * 0.25)) }
        #expect(controller.phase == .waiting)
        #expect(controller.interview?.turns.isEmpty == true)
        #expect(controller.caption.isEmpty)
        controller.finish(now: now.addingTimeInterval(31))
        #expect(controller.interview?.summary.answered == 0)
    }
}
