import Foundation
import Testing
@testable import SpeechCoachAI

@MainActor struct SpeechLabArticulationTests {
    @Test func bankCoversPairsEndingsLinkingAndGradedTwisters() {
        let items = SpeechLabCatalog.bundled.articulation
        #expect(items.filter { $0.category == "Minimal pairs" }.count >= 20)
        #expect(items.filter { $0.category == "Word endings" }.count >= 6)
        #expect(items.filter { $0.category == "Clusters & linking" }.count >= 4)
        #expect(items.filter { $0.category == "Tongue twisters" }.count >= 12)
        #expect(Set(items.filter { $0.category == "Tongue twisters" }.map(\.grade)) == ["Short", "Medium", "Long"])
        for item in items {
            #expect(item.activity.resolvedExercise.problem() == nil)
            #expect(item.activity.resolvedExercise.evaluate(.text(item.answer)) == .correct)
        }
    }
    @Test func recognitionDiffIsTextComparisonOnly() {
        let diff = AnswerChecker.diff(response: "sheep", expected: "ship")
        #expect(diff.contains { $0.mark != .correct })
        let attempt = SpeechLabAttempt(area: .articulation, itemID: "art-pair-1")
        #expect(attempt.accuracy == nil)
    }
    @Test func fixtureCaptureRetainsThroughNativeLifecycleAndRetries() throws {
        // The fixture is exercised through UI; pure recording reference persistence is checked here.
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("SpeechLab-art-\(UUID())")
        defer { try? FileManager.default.removeItem(at: root) }
        let repo = try LearnerRepository(root: root, protectedDataAvailable: { true })
        let first = SpeechLabAttempt(area: .articulation, itemID: "art-pair-1", correct: 1, total: 1)
        try repo.recordSpeechLabAttempt(first)
        try repo.recordSpeechLabAttempt(.init(area: .articulation, itemID: "art-pair-1"))
        #expect(try repo.speechLabState().results(for: .articulation).count == 2)
        repo.close()
    }
}
