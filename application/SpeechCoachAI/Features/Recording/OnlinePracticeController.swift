import Foundation
import Observation

@Observable
final class OnlinePracticeController {
    private(set) var attempt: AttemptSnapshot?
    private(set) var isBusy = false
    private(set) var message: String?
    var editedText = ""
    var hintsOnly = false
    var expanded = false
    private let provider: any SpeakingProvider
    private let scopeOverride: ProviderScope?
    private var repository: LearnerRepository?
    private var task: Task<Void, Never>?
    private var generation = UUID()
    private var activeRequest: (UUID, CallbackToken)?

    init(provider: any SpeakingProvider = SpeakingEnvironment.provider, scope: ProviderScope? = SpeakingEnvironment.fixtureScope) {
        self.provider = provider; scopeOverride = scope
    }
    var scope: ProviderScope? { scopeOverride ?? (try? ProviderCredentialStore().configuredScope()) }
    var canSubmit: Bool {
        guard let scope else { return false }
        return provider.verification?.permits(scope) == true
    }
    var currentConfirmed: TranscriptSnapshot? { attempt?.transcripts.last(where: { $0.kind == .learnerConfirmed }) }
    var currentFeedback: FeedbackSnapshot? {
        guard let confirmed = currentConfirmed else { return nil }
        return attempt?.feedback.last(where: { $0.transcriptID == confirmed.id && $0.transcriptRevision == confirmed.revision })
    }
    var original: TranscriptSnapshot? { attempt?.transcripts.last(where: { $0.kind == .asrOriginal }) }
    var disclosure: String {
        "Alibaba Cloud Model Studio · Singapore. " + (provider.verification?.retentionDisclosure ?? "Processing and retention terms have not been verified for this account.")
    }
    func load(_ repository: LearnerRepository?, attemptID: UUID) {
        if attempt?.id != attemptID { cancel(); attempt = nil; editedText = "" }
        self.repository = repository
        do {
            guard let repository else { throw LearnerStorageError.unavailable }
            attempt = try repository.attempt(attemptID)
            if !isBusy { editedText = currentConfirmed?.text ?? original?.text ?? "" }
        } catch { message = "Local practice is unavailable. Unlock your device and try again." }
    }
    func confirm() {
        guard !isBusy, let repository, let attempt, let source = currentConfirmed ?? original else { return }
        do {
            self.attempt = try repository.confirmTranscript(attempt.id, sourceID: source.id,
                text: editedText, expectedVersion: attempt.version)
            message = "Text confirmed on this device. No coaching request was sent."
        } catch { message = "Text could not be confirmed. Keep 1–12,000 characters and try again; your original is kept." }
    }
    /// Invoked only by the explicit disclosure confirmation button for the chosen stage.
    func submit(_ stage: SpeakingRequestStage) {
        guard !isBusy, let repository, let attempt, let scope else {
            message = SpeakingProviderError.credentialMissing.message; return
        }
        guard provider.verification?.permits(scope) == true else { message = SpeakingProviderError.verificationRequired.message; return }
        if stage == .coaching, currentConfirmed?.text != editedText {
            message = "Confirm your current edits before requesting coaching."; return
        }
        isBusy = true; message = nil
        let requestedHints = hintsOnly; let requestedExpanded = expanded
        let run = UUID(); generation = run
        task = Task { [weak self] in
            guard let self else { return }
            do {
                let fresh = try repository.attempt(attempt.id)
                let body: Data
                let prepared: CallbackToken
                if stage == .transcription {
                    body = try ASRPreparation(original: repository.recordingURL(fresh.id)).requestBody
                    prepared = try repository.prepareTranscription(fresh.id, expectedVersion: fresh.version,
                        model: "qwen3-asr-flash", region: "Singapore")
                } else {
                    guard let confirmed = fresh.transcripts.last(where: { $0.kind == .learnerConfirmed }) else {
                        throw LearnerStorageError.invalidReference
                    }
                    body = try CoachingPreparation(attempt: fresh, confirmed: confirmed, hintsOnly: requestedHints, expanded: requestedExpanded).body
                    prepared = try repository.prepareCoaching(fresh.id, transcriptID: confirmed.id,
                        expectedVersion: fresh.version, model: "qwen-flash", region: "Singapore")
                }
                let pending = try repository.attempt(fresh.id)
                guard let request = pending.requests.last else { throw LearnerStorageError.invalidState }
                activeRequest = (request.id, prepared)
                try Task.checkCancellation()
                let sent = try repository.transitionRequest(request.id, status: .sent, token: prepared)
                activeRequest = (request.id, sent)
                let response = try await provider.send(body: body, scope: scope, stage: stage)
                try Task.checkCancellation()
                guard generation == run else { return }
                if stage == .transcription {
                    let result = try ASRRecognition(response: response, expectedModel: "qwen3-asr-flash")
                    self.attempt = try repository.completeTranscription(result, requestID: request.id, token: sent)
                    editedText = original?.text ?? ""
                    message = "Recognition can miss words. Review and confirm the text before coaching."
                } else {
                    guard let transcript = pending.transcripts.last(where: { $0.kind == .learnerConfirmed }) else {
                        throw LearnerStorageError.invalidReference
                    }
                    let result = try ProviderCompletionContent(response: response, expectedModel: "qwen-flash", maximumScalars: 60_000)
                    let validated = try ValidatedCoachingContent(response: Data(result.text.utf8), confirmed: transcript,
                        expanded: requestedExpanded, hintsOnly: requestedHints)
                    self.attempt = try repository.completeCoaching(validated, requestID: request.id,
                        rubricVersion: "recorded-feedback-v1", token: sent)
                    message = "Text coaching is ready. Pronunciation and acoustic fluency were not assessed."
                }
                activeRequest = nil; isBusy = false; task = nil
            } catch {
                guard generation == run else { return }
                let sanitized: SpeakingProviderError
                if error is CancellationError { sanitized = .cancelled }
                else if let providerError = error as? SpeakingProviderError { sanitized = providerError }
                else if error is ASRResponseError || error is CoachingValidationError { sanitized = .invalidResponse }
                else { sanitized = .unavailable }
                if let (id, token) = activeRequest {
                    let status: RequestSnapshot.Status = sanitized == .unknownOutcome ? .unknownOutcome : sanitized == .cancelled ? .cancelled : .failed
                    _ = try? repository.transitionRequest(id, status: status, token: token)
                }
                self.attempt = try? repository.attempt(attempt.id)
                message = sanitized.message; activeRequest = nil; isBusy = false; task = nil
            }
        }
    }
    func cancel() {
        guard isBusy else { return }
        generation = UUID(); task?.cancel(); task = nil
        if let repository, let attempt, let (id, token) = activeRequest {
            _ = try? repository.transitionRequest(id, status: .cancelled, token: token)
            self.attempt = try? repository.attempt(attempt.id)
        }
        activeRequest = nil; isBusy = false; message = SpeakingProviderError.cancelled.message
    }
}
