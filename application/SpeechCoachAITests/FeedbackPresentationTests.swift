import Foundation
import Testing
@testable import SpeechCoachAI

@MainActor struct FeedbackPresentationTests {
    private let scope = try! ProviderScope(workspace: "synthetic")
    @Test func disabledFeedbackCannotSubmitAndSavedCredentialTestUsesMemoryOnly() throws {
        let provider = Round4FeedbackProvider(enabled: false)
        let controller = AIFeedbackController(service: LabFeedbackService(provider: provider, scope: scope))
        controller.submit(.init(mode: .speaking, transcript: "Yesterday I go", task: nil, level: nil))
        #expect(!controller.isAvailable && provider.requestCount == 0)
        let model = ProviderSettingsModel(credentials: MemoryProviderSettingsCredentials())
        model.testSavedValues()
        #expect(model.message == ProviderSettingsModel.firstSentence(SpeakingProviderError.credentialMissing.message))
        model.workspace = "synthetic"; model.key = "synthetic-key"; model.save()
        #expect(model.key.isEmpty && model.configured == scope)
        model.testSavedValues()
        #expect(model.message == "Saved values found." && provider.requestCount == 0)
        model.remove(); model.testSavedValues()
        #expect(model.configured == nil)
    }
    @Test func duplicateTapsDoNotSendTwiceAndCancellationDropsResults() async {
        let provider = Round4FeedbackProvider(enabled: true)
        let controller = AIFeedbackController(service: LabFeedbackService(provider: provider, scope: scope))
        let request = LabFeedbackRequest(mode: .speaking, transcript: "Yesterday I go to the market.", task: nil, level: nil)
        controller.submit(request); controller.submit(request)
        while provider.requestCount == 0 { await Task.yield() }
        #expect(provider.requestCount == 1 && controller.busy)
        controller.cancel(clear: true)
        for _ in 0..<20 { await Task.yield() }
        #expect(!controller.busy && controller.result == nil && controller.message == nil)
    }
}
