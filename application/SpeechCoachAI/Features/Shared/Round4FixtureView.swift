#if DEBUG
import SwiftUI
import Observation

@MainActor @Observable final class Round4FeedbackProvider: SpeakingProvider {
    var verification: ProviderVerification?
    private(set) var requestCount = 0
    var failure = false
    init(enabled: Bool) {
        if enabled {
            verification = ProviderVerification(workspace: "synthetic", asrModel: "qwen3-asr-flash", coachingModel: "qwen-flash",
                validUntil: .distantFuture, directNativePermissionVerified: true, quotaProtectionVerified: true,
                retentionDisclosure: "Synthetic test disclosure.", evidenceReference: "isolated-ui-test")
        }
    }
    func send(body: Data, scope: ProviderScope, stage: SpeakingRequestStage) async throws -> Data {
        requestCount += 1
        try await Task.sleep(for: .milliseconds(500))
        if failure { throw SpeakingProviderError.quotaExhausted }
        if String(decoding: body, as: UTF8.self).contains("vocabulary cards") { return try Self.lexiconReply() }
        let content: [String: Any] = ["summary": "Your meaning is clear.", "strengths": ["You named a time."],
            "improvements": [["quote": "Yesterday I go", "tip": "Use the past tense.", "retry": "Yesterday I went to the market."]],
            "nextStep": "Say it again with went.", "speechAssessmentStatus": "not_assessed"]
        let json = String(decoding: try JSONSerialization.data(withJSONObject: content), as: UTF8.self)
        return try JSONSerialization.data(withJSONObject: ["model": "qwen-flash", "choices": [
            ["index": 0, "finish_reason": "stop", "message": ["role": "assistant", "content": json]]]])
    }

    private static func lexiconReply() throws -> Data {
        let words: [[String: String]] = [
            ["lemma": "gavel", "pos": "noun", "meaning": "A small hammer a judge uses to call for order.", "example": "The judge struck the {gavel} twice.",
             "wrong": "She cooked soup with a gavel.", "cefr": "A1", "register": "term"],
            ["lemma": "verdict", "pos": "noun", "meaning": "The decision a jury reaches at the end of a trial.", "example": "The jury announced its {verdict} today.",
             "wrong": "He ate a verdict for lunch.", "cefr": "A2", "register": "term"]]
        let json = String(decoding: try JSONSerialization.data(withJSONObject: ["words": words]), as: UTF8.self)
        return try JSONSerialization.data(withJSONObject: ["model": "qwen-flash", "choices": [
            ["index": 0, "finish_reason": "stop", "message": ["role": "assistant", "content": json]]]])
    }
}

struct Round4FixtureView: View {
    var storage: LearnerStorageController
    @State private var provider: Round4FeedbackProvider
    private let service: LabFeedbackService
    init(storage: LearnerStorageController) {
        self.storage = storage
        let provider = Round4FeedbackProvider(enabled: ProcessInfo.processInfo.environment["SC_LAB_FEEDBACK_ENABLED"] == "1")
        provider.failure = ProcessInfo.processInfo.environment["SC_LAB_FEEDBACK_FAILURE"] == "1"
        _provider = State(initialValue: provider)
        service = LabFeedbackService(provider: provider, scope: try! ProviderScope(workspace: "synthetic"))
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Requests: \(provider.requestCount)").accessibilityIdentifier("fixture.requests")
                AIFeedbackSection(request: LabFeedbackRequest(mode: .speaking, transcript: "Yesterday I go to the market.", task: "Tell me about yesterday.", level: "A2"),
                                  title: "Free talk", storage: storage, service: service)
                NavigationLink("Specialized words") { SpecializedLexiconView(storage: storage, service: service) }
                    .accessibilityIdentifier("fixture.specialized")
                NavigationLink("Feedback history") { LabFeedbackHistoryView(storage: storage) }.accessibilityIdentifier("fixture.history")
                NavigationLink("Three stages") {
                    CoachTrackView(storage: storage, install: CurriculumInstall(lessons: [], problem: nil),
                        track: Self.track, onSpeak: { _, _ in })
                }.accessibilityIdentifier("fixture.track")
            }.padding(20)
        }.navigationTitle("UI fixture")
    }
    static var track: Track {
        let stages = ["foundation", "intermediate", "advanced"].map { id in
            let lesson = ResolvedLesson(id: "synthetic-\(id)", level: "A2", title: "Synthetic lesson", objectiveId: id,
                contentVersion: "1", availability: .ready, practiceActivities: [])
            return TrackStage(id: id, title: id.capitalized, units: [TrackUnit(id: id, title: "\(id.capitalized) unit", lessons: [lesson])])
        }
        return Track(id: "synthetic", coach: .debater, stages: stages)
    }
}
#endif
