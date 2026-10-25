import Foundation

enum CommunicationAction: Equatable {
    case accepted(notice: String? = nil)
    case refused(CommunicationRefusal)

    var accepted: Bool { if case .accepted = self { return true }; return false }

    static func accept(_ notice: String? = nil) -> CommunicationAction { .accepted(notice: notice) }
    static func refuse(_ reason: CommunicationRefusal) -> CommunicationAction { .refused(reason) }
}

enum CommunicationRefusal: Equatable, Error {
    case invalidSetup, unavailableItem, sessionClosed, emptyResponse, duplicateResponse
    case unsupportedSound, missingSource, ungroundedEvidence, invalidFeedback
    case onlineDisabled, capabilityUnavailable, quietPractice, requestInFlight
    case lateResult, unknownOutcome, retentionIncomplete
}

enum CommunicationPhase: String, Codable { case preparing, practicing, stopped, ended }
enum CommunicationEntry: String, Codable, CaseIterable { case learn, speechLab }
enum CommunicationModality: String, Codable { case text, recorded }
enum CommunicationRequestClose: String, Codable { case cancelled, failed, unknownOutcome, lateResult }

/// Practice families already named in the communication contract. None is a required lesson count.
enum CommunicationFocus: String, Codable, CaseIterable, Identifiable {
    case explainClearly, speakConcisely, listenAndRespond, presentAndPersuade
    case difficultConversation, deliveryPractice, speechProduction, expression

    var id: String { rawValue }

    var title: String {
        switch self {
        case .explainClearly: "Explain clearly"
        case .speakConcisely: "Speak concisely"
        case .listenAndRespond: "Listen and respond"
        case .presentAndPersuade: "Present and persuade"
        case .difficultConversation: "Difficult conversation"
        case .deliveryPractice: "Delivery practice"
        case .speechProduction: "Speech production"
        case .expression: "Expression"
        }
    }

    /// Local instruction only. This is not a published lesson or a reviewed rubric.
    var offlinePrompt: String {
        switch self {
        case .explainClearly: "Say the point first, then two details, in your own words."
        case .speakConcisely: "Keep one idea and remove anything the listener does not need."
        case .listenAndRespond: "Restate the source in your own words and mark anything you did not hear."
        case .presentAndPersuade: "Name the audience, the request, and one reason. A framework name is optional."
        case .difficultConversation: "Describe the issue, its effect, and one respectful next step."
        case .deliveryPractice: "Record or replay if you want, then note what you noticed. Sound is not scored."
        case .speechProduction: "Use the reference when one is available, then try the target in a new sentence."
        case .expression: "Keep your meaning and add one concrete detail."
        }
    }

    var trainerReference: String {
        switch self {
        case .explainClearly, .speakConcisely, .presentAndPersuade, .difficultConversation: "TR-BIZ"
        case .listenAndRespond: "TR-JOUR"
        case .deliveryPractice, .speechProduction: "TR-SPEAK"
        case .expression: "TR-WRITE"
        }
    }

    static let offlinePromptVersion = "unreviewed-offline-1"
}

enum RoutineItem: String, Codable, CaseIterable, Identifiable {
    case organizedAnswer, simpleExplanation, conciseSummary, paraphrase, pausePractice, constructiveDisagreement
    var id: String { rawValue }
}

struct CommunicationSource: Equatable, Codable {
    var lessonID: String
    var contentVersion: String
    var objectiveID: String
    var senseID: String?

    var isComplete: Bool {
        !lessonID.isEmpty && !contentVersion.isEmpty && !objectiveID.isEmpty
    }
}

struct CommunicationTask: Equatable, Codable {
    var itemID: String?
    var itemVersion: String?
    var source: CommunicationSource?
    var purpose: String
    var focus: CommunicationFocus
    var frameworkID: String?
    var scaffold: String?
    var fictional: Bool
    var sourceExchange: String?
    var referenceAudioID: String?

    var trainerReference: String { focus.trainerReference }

    /// Entry path is intentionally absent so Learn and Speech Lab share one identity.
    var fingerprint: String {
        [
            source?.lessonID ?? "", source?.contentVersion ?? "", source?.objectiveID ?? "", source?.senseID ?? "",
            itemID ?? "", itemVersion ?? "", focus.rawValue, purpose, frameworkID ?? "", scaffold ?? "",
            fictional ? "fiction" : "task", sourceExchange ?? "", referenceAudioID ?? ""
        ].map { "\($0.utf8.count):\($0)" }.joined()
    }

    func normalized() -> CommunicationTask {
        var copy = self
        copy.purpose = purpose.trimmingCharacters(in: .whitespacesAndNewlines)
        copy.frameworkID = frameworkID?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty
        copy.scaffold = scaffold?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty
        copy.sourceExchange = sourceExchange?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty
        copy.referenceAudioID = referenceAudioID?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty
        copy.itemID = itemID?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty
        copy.itemVersion = itemVersion?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty
        return copy
    }

    var isValid: Bool {
        let task = normalized()
        guard !task.purpose.isEmpty, source?.isComplete != false else { return false }
        if task.itemID != nil { return task.itemVersion != nil }
        return true
    }
}

struct CommunicationItem: Codable, Equatable, Identifiable {
    var id: String
    var version: String
    var focus: CommunicationFocus
    var lessonID: String?
    var contentVersion: String?
    var objectiveID: String?
    var senseID: String?
    var audience: String
    var purpose: String
    var sourceExchange: String?
    var referenceAudioID: String?
    var prompt: String
    var fictionalExample: String
    var reviewStatus: String
    var rubricStatus: String
    var representsLearnerAccomplishment: Bool
    var frameworkRequired: Bool

    static func published(_ items: [CommunicationItem]) -> [CommunicationItem] {
        items.filter {
            $0.reviewStatus == "reviewed" && $0.rubricStatus == "reviewed"
                && !$0.representsLearnerAccomplishment && !$0.frameworkRequired
                && !$0.purpose.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
}

enum SoundAssessment: Equatable {
    case notAssessed(reason: String)

    static let transcriptReason = "A transcript cannot establish sound, intelligibility, confidence, emotion, or body language."

    static func fromTranscript(_ transcript: String) -> SoundAssessment {
        _ = transcript
        return .notAssessed(reason: transcriptReason)
    }
}

enum CommunicationFeedbackPolicy: Equatable, Codable {
    case disabledUntilCapability
    case textOnlyEnabled(contractVersion: String)
}

struct CommunicationImprovement: Equatable, Codable {
    enum Category: String, Codable { case grammar, vocabulary, organization }
    var category: Category
    var evidenceQuote: String
    var explanation: String
    var suggestedRevision: String?
    var hint: String?
    var retryPrompt: String
}

struct CommunicationTextFeedback: Equatable, Codable {
    var requestID: UUID
    var responseID: UUID
    var summary: String
    var strengths: [String]
    var improvements: [CommunicationImprovement]
    var limitations: [String]
    var speechAssessmentStatus: String

    var soundAssessed: Bool { false }
}

struct CommunicationFeedbackRequest: Equatable {
    var requestID: UUID
    var responseID: UUID
    var attemptID: UUID
    var text: String
    var sourceFingerprint: String
    var contractVersion: String

    /// A stored recording reference is not permission to upload audio.
    var sendsAudio: Bool { false }
}

struct ClosedCommunicationRequest: Equatable, Codable {
    var requestID: UUID
    var responseID: UUID
    var reason: CommunicationRequestClose
    var closedAt: Date
}

struct CommunicationResponse: Equatable, Codable, Identifiable {
    let id: UUID
    var questionID: String
    var text: String?
    var recordingReference: String?
    var modality: CommunicationModality
    var retryOf: UUID?
    var assisted: Bool
    var createdAt: Date
}

struct CommunicationSelfReview: Equatable, Codable {
    var purposeClear: Bool? = nil
    var organizationNote: String = ""
    var wordUseNote: String = ""
    var deliveryNote: String = ""
    var eyeContactNote: String = ""
    var completedAt: Date? = nil

    var isComplete: Bool {
        purposeClear != nil && !organizationNote.isEmpty && !wordUseNote.isEmpty && completedAt != nil
    }

    var soundAssessed: Bool { false }
}

struct CommunicationRetention: Equatable, Codable {
    var keepAudio: Bool? = nil
    var keepText: Bool? = nil
    var applied = false

    var isExplicit: Bool { applied && keepAudio != nil && keepText != nil }
}

struct CommunicationRecordingSlot: Equatable, Codable {
    let id: UUID
    let attemptID: UUID
    let questionID: String
    private(set) var reference: String?
    private(set) var consumed = false

    init(attemptID: UUID, questionID: String) {
        id = UUID(); self.attemptID = attemptID; self.questionID = questionID
    }

    mutating func receive(turnID: UUID, reference: String, activeAttemptID: UUID?) -> Bool {
        let value = reference.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !consumed, self.reference == nil, turnID == id, activeAttemptID == attemptID, !value.isEmpty else { return false }
        self.reference = value
        return true
    }

    mutating func consume(attemptID: UUID, questionID: String) -> String? {
        guard !consumed, self.attemptID == attemptID, self.questionID == questionID else { return nil }
        consumed = true
        let value = reference
        reference = nil
        return value
    }
}

struct CommunicationAttempt: Equatable, Codable, Identifiable {
    let id: UUID
    var task: CommunicationTask
    var responses: [CommunicationResponse]
    var review: CommunicationSelfReview
    var feedback: CommunicationTextFeedback?
    var recordingSlot: CommunicationRecordingSlot?
    var creditID: UUID?
    var routineItems: [RoutineItem]
    var routineParticipationID: UUID?
    var inFlightRequestID: UUID?
    var inFlightResponseID: UUID?
    var closedRequests: [ClosedCommunicationRequest]
    var supersededAt: Date?
    let startedAt: Date

    var courseCompletionID: UUID? { nil }
    var masteryAwarded: Bool { false }

    var currentResponse: CommunicationResponse? { responses.last }

    /// A completed self-review is local participation. A framework name is never required, and sound is never scored.
    func qualifies() -> Bool {
        guard let response = responses.first(where: { $0.retryOf == nil }) ?? responses.first,
              !(response.text ?? "").isEmpty, response.assisted == false,
              review.isComplete, review.soundAssessed == false else { return false }
        if task.focus == .listenAndRespond { return task.sourceExchange?.isEmpty == false }
        return true
    }
}

struct CommunicationPractice: Codable, Equatable, Identifiable {
    let id: UUID
    var entry: CommunicationEntry
    var draftTask: CommunicationTask
    var feedbackPolicy: CommunicationFeedbackPolicy
    var quietPractice: Bool
    private(set) var phase: CommunicationPhase
    private(set) var attempts: [CommunicationAttempt]
    private(set) var retention = CommunicationRetention()
    private(set) var activeAttemptID: UUID?

    static let soundCapabilityVersion: String? = nil

    static func preciseSoundFeedbackAvailable() -> Bool { soundCapabilityVersion != nil }

    func requestSoundFeedback() -> Result<CommunicationFeedbackRequest, CommunicationRefusal> {
        .failure(.capabilityUnavailable)
    }

    init(entry: CommunicationEntry, task: CommunicationTask, quietPractice: Bool = false) {
        id = UUID()
        self.entry = entry
        draftTask = task.normalized()
        feedbackPolicy = .disabledUntilCapability
        self.quietPractice = quietPractice
        phase = .preparing
        attempts = []
    }

    var activeAttempt: CommunicationAttempt? {
        guard let activeAttemptID else { return nil }
        return attempts.first { $0.id == activeAttemptID && $0.supersededAt == nil }
    }

    var activeRecordingSlot: CommunicationRecordingSlot? { activeAttempt?.recordingSlot }

    var affectsCourseProgress: Bool { false }

    var participationKey: String? { activeAttempt?.task.fingerprint }

    mutating func setEntry(_ entry: CommunicationEntry) -> CommunicationAction {
        guard !retention.applied else { return .refuse(.sessionClosed) }
        self.entry = entry
        return .accept()
    }

    mutating func begin(published items: [CommunicationItem], now: Date) -> CommunicationAction {
        guard phase == .preparing, attempts.isEmpty else { return .refuse(.sessionClosed) }
        let task = tryApply(draftTask, published: items)
        guard let task else { return .refuse(draftTask.itemID == nil ? .invalidSetup : .unavailableItem) }
        guard task.isValid else { return .refuse(.invalidSetup) }
        draftTask = task
        let attempt = CommunicationAttempt(
            id: UUID(), task: task, responses: [], review: CommunicationSelfReview(), feedback: nil,
            recordingSlot: nil, creditID: nil, routineItems: [], routineParticipationID: nil,
            inFlightRequestID: nil, inFlightResponseID: nil, closedRequests: [], supersededAt: nil, startedAt: now)
        attempts = [attempt]
        activeAttemptID = attempt.id
        phase = .practicing
        return .accept()
    }

    @discardableResult
    mutating func reviseTask(_ task: CommunicationTask, published items: [CommunicationItem], now: Date) -> CommunicationAction {
        guard !retention.applied, let index = activeIndex, phase == .practicing || phase == .stopped else {
            return .refuse(.sessionClosed)
        }
        guard let proposed = tryApply(task, published: items), proposed.isValid else {
            return .refuse(task.itemID?.isEmpty == false ? .unavailableItem : .invalidSetup)
        }
        if proposed.fingerprint == attempts[index].task.fingerprint { return .accept() }
        if attempts[index].responses.isEmpty, attempts[index].inFlightRequestID == nil, attempts[index].recordingSlot == nil {
            attempts[index].task = proposed
            draftTask = proposed
            return .accept()
        }
        closeRequest(.cancelled, now: now)
        attempts[index].recordingSlot = nil
        attempts[index].supersededAt = now
        let next = CommunicationAttempt(
            id: UUID(), task: proposed, responses: [], review: CommunicationSelfReview(), feedback: nil,
            recordingSlot: nil, creditID: nil, routineItems: [],
            routineParticipationID: nil,
            inFlightRequestID: nil, inFlightResponseID: nil, closedRequests: [], supersededAt: nil, startedAt: now)
        attempts.append(next)
        activeAttemptID = next.id
        draftTask = proposed
        phase = .practicing
        return .accept("Started a separate attempt.")
    }

    mutating func openRecordingSlot(questionID: String) -> CommunicationAction {
        guard !retention.applied, let index = activeIndex, phase == .practicing else { return .refuse(.sessionClosed) }
        guard !questionID.isEmpty else { return .refuse(.invalidSetup) }
        if let slot = attempts[index].recordingSlot, slot.questionID == questionID, !slot.consumed, slot.reference == nil { return .accept() }
        attempts[index].recordingSlot = CommunicationRecordingSlot(attemptID: attempts[index].id, questionID: questionID)
        return .accept()
    }

    mutating func receiveRecording(turnID: UUID, reference: String) -> CommunicationAction {
        guard !retention.applied, let index = activeIndex, phase == .practicing, attempts[index].recordingSlot != nil else {
            return .refuse(.lateResult)
        }
        guard attempts[index].recordingSlot?.receive(
            turnID: turnID, reference: reference, activeAttemptID: activeAttemptID) == true else {
            return .refuse(.lateResult)
        }
        return .accept()
    }

    mutating func submit(questionID: String, text: String, now: Date) -> CommunicationAction {
        guard let index = activeIndex, phase == .practicing, !retention.applied else { return .refuse(.sessionClosed) }
        if attempts[index].inFlightRequestID != nil { return .refuse(.requestInFlight) }
        if attempts[index].responses.contains(where: { $0.questionID == questionID && $0.retryOf == nil }) {
            return .refuse(.duplicateResponse)
        }
        return store(index: index, questionID: questionID, retryOf: nil, text: text, now: now)
    }

    mutating func retry(previousID: UUID, questionID: String, text: String, now: Date) -> CommunicationAction {
        guard let index = activeIndex, phase == .practicing, !retention.applied else { return .refuse(.sessionClosed) }
        guard attempts[index].inFlightRequestID == nil else { return .refuse(.requestInFlight) }
        guard attempts[index].responses.contains(where: { $0.id == previousID && $0.questionID == questionID }) else {
            return .refuse(.invalidSetup)
        }
        if attempts[index].responses.contains(where: { $0.retryOf == previousID }) { return .refuse(.duplicateResponse) }
        return store(index: index, questionID: questionID, retryOf: previousID, text: text, now: now)
    }

    mutating func requestTextFeedback(now: Date) -> Result<CommunicationFeedbackRequest, CommunicationRefusal> {
        guard !retention.applied, let index = activeIndex, phase == .practicing else { return .failure(.sessionClosed) }
        if quietPractice { return .failure(.quietPractice) }
        guard case .textOnlyEnabled(let version) = feedbackPolicy else { return .failure(.onlineDisabled) }
        if attempts[index].inFlightRequestID != nil { return .failure(.requestInFlight) }
        guard let response = attempts[index].currentResponse, let text = response.text, !text.isEmpty else {
            return .failure(.emptyResponse)
        }
        if attempts[index].task.focus == .listenAndRespond, attempts[index].task.sourceExchange == nil {
            return .failure(.missingSource)
        }
        let requestID = UUID()
        attempts[index].inFlightRequestID = requestID
        attempts[index].inFlightResponseID = response.id
        return .success(CommunicationFeedbackRequest(
            requestID: requestID, responseID: response.id, attemptID: attempts[index].id, text: text,
            sourceFingerprint: attempts[index].task.fingerprint, contractVersion: version))
    }

    mutating func receiveTextFeedback(_ feedback: CommunicationTextFeedback, now: Date) -> CommunicationAction {
        guard let index = activeIndex else { return .refuse(.lateResult) }
        guard feedback.requestID == attempts[index].inFlightRequestID,
              feedback.responseID == attempts[index].inFlightResponseID else {
            return .refuse(.lateResult)
        }
        guard let response = attempts[index].responses.first(where: { $0.id == feedback.responseID }),
              let text = response.text else {
            closeRequest(.failed, now: now)
            return .refuse(.invalidFeedback)
        }
        guard let accepted = CommunicationPractice.validate(feedback, learnerText: text, source: attempts[index].task.sourceExchange) else {
            closeRequest(.failed, now: now)
            return .refuse(.invalidFeedback)
        }
        attempts[index].feedback = accepted
        attempts[index].inFlightRequestID = nil
        attempts[index].inFlightResponseID = nil
        return .accept()
    }

    mutating func cancelFeedback(now: Date) -> CommunicationAction {
        guard activeAttempt?.inFlightRequestID != nil else { return .refuse(.sessionClosed) }
        closeRequest(.cancelled, now: now)
        return .accept()
    }

    mutating func markUnknownOutcome(now: Date) -> CommunicationAction {
        guard activeAttempt?.inFlightRequestID != nil else { return .refuse(.sessionClosed) }
        closeRequest(.unknownOutcome, now: now)
        return .accept("Check the provider before trying again.")
    }

    mutating func saveSelfReview(
        purposeClear: Bool, organization: String, wordUse: String, delivery: String, eyeContact: String, now: Date
    ) -> CommunicationAction {
        guard !retention.applied, let index = activeIndex, phase != .preparing else { return .refuse(.sessionClosed) }
        let organizationNote = organization.trimmingCharacters(in: .whitespacesAndNewlines)
        let wordUseNote = wordUse.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !organizationNote.isEmpty, !wordUseNote.isEmpty else { return .refuse(.emptyResponse) }
        attempts[index].review = CommunicationSelfReview(
            purposeClear: purposeClear, organizationNote: organizationNote, wordUseNote: wordUseNote,
            deliveryNote: delivery.trimmingCharacters(in: .whitespacesAndNewlines),
            eyeContactNote: eyeContact.trimmingCharacters(in: .whitespacesAndNewlines), completedAt: now)
        return .accept()
    }

    mutating func completeRoutine(_ items: Set<RoutineItem>, now: Date) -> CommunicationAction {
        guard !retention.applied, let index = activeIndex, phase != .preparing else { return .refuse(.sessionClosed) }
        guard !items.isEmpty else { return .refuse(.invalidSetup) }
        _ = now
        attempts[index].routineItems = RoutineItem.allCases.filter { items.contains($0) }
        if attempts[index].routineParticipationID == nil { attempts[index].routineParticipationID = UUID() }
        return .accept()
    }

    mutating func stop(now: Date) -> CommunicationAction {
        guard phase == .practicing else { return .refuse(.sessionClosed) }
        closeRequest(.cancelled, now: now)
        phase = .stopped
        return .accept()
    }

    mutating func restart() -> CommunicationAction {
        guard phase == .stopped, !retention.applied, activeAttempt?.inFlightRequestID == nil else {
            return .refuse(.sessionClosed)
        }
        phase = .practicing
        return .accept()
    }

    mutating func end() -> CommunicationAction {
        guard phase == .stopped || phase == .practicing else { return .refuse(.sessionClosed) }
        if phase == .practicing { _ = stop(now: Date()) }
        phase = .ended
        return .accept()
    }

    mutating func applyRetention(keepAudio: Bool, keepText: Bool) -> CommunicationAction {
        guard phase == .stopped || phase == .ended else { return .refuse(.retentionIncomplete) }
        if !keepText {
            for index in attempts.indices {
                attempts[index].task.purpose = ""
                attempts[index].task.frameworkID = nil
                attempts[index].task.scaffold = nil
                attempts[index].task.sourceExchange = nil
                for response in attempts[index].responses.indices { attempts[index].responses[response].text = nil }
                attempts[index].review = CommunicationSelfReview()
                attempts[index].feedback = nil
            }
            draftTask.purpose = ""
            draftTask.frameworkID = nil
            draftTask.scaffold = nil
            draftTask.sourceExchange = nil
        }
        if !keepAudio {
            for index in attempts.indices {
                for response in attempts[index].responses.indices {
                    attempts[index].responses[response].recordingReference = nil
                }
                attempts[index].recordingSlot = nil
            }
        }
        retention = CommunicationRetention(keepAudio: keepAudio, keepText: keepText, applied: true)
        return .accept()
    }

    static func validate(
        _ feedback: CommunicationTextFeedback, learnerText: String, source: String?
    ) -> CommunicationTextFeedback? {
        guard feedback.speechAssessmentStatus == "not_assessed", feedback.soundAssessed == false else { return nil }
        guard feedback.strengths.count <= 2, feedback.improvements.count <= 2, feedback.limitations.count <= 5 else { return nil }
        guard bounded(feedback.summary, maximum: 600),
              feedback.strengths.allSatisfy({ bounded($0, maximum: 300) }),
              feedback.limitations.allSatisfy({ bounded($0, maximum: 300) }) else { return nil }
        let prose = ([feedback.summary] + feedback.strengths + feedback.limitations).joined(separator: "\n")
        guard !containsUnsupportedClaim(prose) else { return nil }
        for item in feedback.improvements {
            guard bounded(item.evidenceQuote, maximum: 500), bounded(item.explanation, maximum: 600),
                  bounded(item.retryPrompt, maximum: 400),
                  item.suggestedRevision.map({ bounded($0, maximum: 600) }) ?? true,
                  item.hint.map({ bounded($0, maximum: 600) }) ?? true else { return nil }
            let cited = learnerText.contains(item.evidenceQuote) || (source?.contains(item.evidenceQuote) == true)
            guard cited, !containsUnsupportedClaim(item.explanation),
                  !containsUnsupportedClaim(item.retryPrompt),
                  !(item.hint.map(containsUnsupportedClaim) ?? false) else { return nil }
            if let revision = item.suggestedRevision, containsUnsupportedClaim(revision) { return nil }
        }
        if feedback.improvements.isEmpty && feedback.strengths.isEmpty && feedback.summary.isEmpty { return nil }
        return feedback
    }

    private static func bounded(_ text: String, maximum: Int) -> Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && text.unicodeScalars.count <= maximum
    }

    private static func containsUnsupportedClaim(_ text: String) -> Bool {
        let value = text.lowercased()
        let banned = [
            "confidence score", "cefr", "clinical", "body language", "emotion score",
            "intelligibility score", "acoustic score", "pronunciation score"
        ]
        return banned.contains { value.contains($0) }
    }

    private func tryApply(_ task: CommunicationTask, published items: [CommunicationItem]) -> CommunicationTask? {
        var proposed = task.normalized()
        if let itemID = proposed.itemID {
            guard let item = CommunicationItem.published(items).first(where: { $0.id == itemID && $0.version == proposed.itemVersion }) else {
                return nil
            }
            proposed.focus = item.focus
            proposed.purpose = item.purpose
            proposed.sourceExchange = item.sourceExchange
            proposed.referenceAudioID = item.referenceAudioID
            proposed.fictional = true
            if let lessonID = item.lessonID, let version = item.contentVersion, let objective = item.objectiveID {
                proposed.source = CommunicationSource(
                    lessonID: lessonID, contentVersion: version, objectiveID: objective, senseID: item.senseID)
            }
        }
        return proposed.isValid ? proposed : nil
    }

    private var activeIndex: Int? {
        guard let activeAttemptID else { return nil }
        return attempts.firstIndex { $0.id == activeAttemptID && $0.supersededAt == nil }
    }

    private mutating func store(
        index: Int, questionID: String, retryOf: UUID?, text: String, now: Date
    ) -> CommunicationAction {
        let note = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let slot = attempts[index].recordingSlot
        let recordingReady = slot?.consumed == false && slot?.attemptID == attempts[index].id
            && slot?.questionID == questionID && slot?.reference?.isEmpty == false
        guard !note.isEmpty || recordingReady else { return .refuse(.emptyResponse) }
        if attempts[index].task.focus == .listenAndRespond, attempts[index].task.sourceExchange == nil {
            return .refuse(.missingSource)
        }
        let attemptID = attempts[index].id
        let recording = attempts[index].recordingSlot?.consume(attemptID: attemptID, questionID: questionID)
        if attempts[index].creditID == nil { attempts[index].creditID = UUID() }
        attempts[index].feedback = nil
        attempts[index].responses.append(CommunicationResponse(
            id: UUID(), questionID: questionID, text: note.isEmpty ? nil : note, recordingReference: recording,
            modality: recording == nil ? .text : .recorded, retryOf: retryOf,
            assisted: attempts[index].task.scaffold != nil || attempts[index].task.frameworkID != nil,
            createdAt: now))
        return .accept()
    }

    private mutating func closeRequest(_ reason: CommunicationRequestClose, now: Date) {
        guard let index = activeIndex, let requestID = attempts[index].inFlightRequestID,
              let responseID = attempts[index].inFlightResponseID else { return }
        attempts[index].closedRequests.append(ClosedCommunicationRequest(
            requestID: requestID, responseID: responseID, reason: reason, closedAt: now))
        attempts[index].inFlightRequestID = nil
        attempts[index].inFlightResponseID = nil
    }
}

private extension String {
    var nonEmpty: String? { isEmpty ? nil : self }
}


extension CommunicationPractice {
    var archiveKind: String { Self.archiveKind(source: draftTask.source) }
    static func archiveKind(source: CommunicationSource?) -> String {
        guard let source else { return "communication:standalone" }
        let fields = [source.lessonID, source.contentVersion, source.objectiveID, source.senseID ?? ""]
        return "communication:" + fields.map { "\($0.utf8.count):\($0)" }.joined()
    }
    var audioReferences: [UUID] {
        attempts.flatMap { attempt in
            (attempt.responses.compactMap(\.recordingReference) + [attempt.recordingSlot?.reference].compactMap { $0 })
                .compactMap(UUID.init(uuidString:))
        }
    }
    static func blank(entry: CommunicationEntry, source: CommunicationSource? = nil) -> CommunicationPractice {
        CommunicationPractice(entry: entry, task: CommunicationTask(itemID: nil, itemVersion: nil, source: source,
            purpose: "", focus: .explainClearly, frameworkID: nil, scaffold: nil, fictional: false,
            sourceExchange: nil, referenceAudioID: nil))
    }
}
