import Foundation

/// Response-dependent interview practice. Follow-ups quote the learner's answer and do not add employment facts.
struct InterviewSession: Codable, Equatable, Identifiable {
    let id: UUID
    var draftSupport: InterviewSupport
    var draftPreparation: InterviewPreparation
    private(set) var attempts: [InterviewAttempt]
    private(set) var activeAttemptID: UUID?
    private(set) var phase: ConversationPhase
    var onlinePolicy: OnlineTurnPolicy
    private(set) var retention: RetentionSelection
    var startedAt: Date
    private(set) var endedAt: Date?
    var affectsCourseProgress: Bool { false }
    var trainerReference: String { "TR-BIZ" }

    init(id: UUID = UUID(), presenterID: String, now: Date = .now) {
        self.id = id
        draftSupport = InterviewSupport(
            roleTitle: "", interviewType: .introduction, technicalCoaching: false,
            presenterID: presenterID, scenarioID: nil, scenarioVersion: nil, fictionalPersona: false)
        draftPreparation = InterviewPreparation(note: "", suppliedFacts: [], quietPractice: false)
        attempts = []
        phase = .preparing
        onlinePolicy = .disabledUntilContract
        retention = RetentionSelection()
        startedAt = now
    }

    var activeAttempt: InterviewAttempt? { attempts.first { $0.id == activeAttemptID && $0.supersededAt == nil } }

    var qualifiesAsInteractiveInterview: Bool { activeAttempt?.qualifiesAsInteractiveInterview == true }

    mutating func begin(publishedScenarios: [WorkplaceScenarioReference], now: Date) -> ConversationAction {
        guard phase == .preparing else { return .refuse(.sessionClosed) }
        guard !draftSupport.roleTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return .refuse(.invalidSetup) }
        if let scenarioID = draftSupport.scenarioID {
            guard let match = ScenarioAvailability.published(publishedScenarios).first(where: { $0.id == scenarioID }) else {
                return .refuse(.invalidSetup)
            }
            draftSupport.scenarioVersion = match.version
        }
        let attempt = InterviewAttempt(support: draftSupport, preparation: draftPreparation, startedAt: now)
        attempts = [attempt]
        activeAttemptID = attempt.id
        phase = .practicing
        startedAt = now
        return .accept()
    }

    /// A changed role, type, presenter, scenario, coaching choice, or fiction flag starts a distinct attempt.
    mutating func reviseSupport(_ support: InterviewSupport, publishedScenarios: [WorkplaceScenarioReference], now: Date) -> ConversationAction {
        guard phase == .practicing, let index = activeIndex else { return .refuse(.sessionClosed) }
        var support = support
        if let scenarioID = support.scenarioID {
            guard let match = ScenarioAvailability.published(publishedScenarios).first(where: { $0.id == scenarioID }) else {
                return .refuse(.invalidSetup)
            }
            support.scenarioVersion = match.version
        } else {
            support.scenarioVersion = nil
        }
        guard !support.roleTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return .refuse(.invalidSetup) }
        guard support.fingerprint != attempts[index].support.fingerprint else { return .accept() }
        cancelInFlight(now: now)
        attempts[index].supersededAt = now
        var next = InterviewAttempt(support: support, preparation: attempts[index].preparation, startedAt: now)
        next.preparation.note = attempts[index].preparation.note
        next.preparation.suppliedFacts = attempts[index].preparation.suppliedFacts
        attempts.append(next)
        activeAttemptID = next.id
        draftSupport = support
        return .accept()
    }

    mutating func updatePreparation(note: String) -> ConversationAction {
        guard !retention.applied else { return .refuse(.sessionClosed) }
        let note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        if phase == .preparing {
            draftPreparation.note = note
            return .accept()
        }
        guard let index = activeIndex else { return .refuse(.sessionClosed) }
        attempts[index].preparation.note = note
        return .accept()
    }

    mutating func setQuietPractice(_ quiet: Bool) -> ConversationAction {
        guard !retention.applied else { return .refuse(.sessionClosed) }
        if phase == .preparing {
            draftPreparation.quietPractice = quiet
            return .accept()
        }
        guard let index = activeIndex else { return .refuse(.sessionClosed) }
        attempts[index].preparation.quietPractice = quiet
        return .accept()
    }

    mutating func addSuppliedFact(_ text: String) -> ConversationAction {
        guard !retention.applied else { return .refuse(.sessionClosed) }
        let fact = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !fact.isEmpty else { return .refuse(.emptyTurn) }
        guard let index = activeIndex else { return .refuse(.sessionClosed) }
        if attempts[index].onlineNotes.contains(where: { $0.text == fact }) { return .refuse(.invalidReply) }
        attempts[index].preparation.suppliedFacts.append(fact)
        return .accept()
    }

    mutating func submitOpening(text: String, recordingReference: String?, now: Date) -> ConversationAction {
        guard let index = activeIndex, phase == .practicing else { return .refuse(.sessionClosed) }
        let promptID = attempts[index].support.interviewType.promptID
        return submit(index: index, promptID: promptID, retryOf: nil, text: text, recordingReference: recordingReference, now: now)
    }

    mutating func retryOpening(previousID: UUID, text: String, recordingReference: String?, now: Date) -> ConversationAction {
        guard let index = activeIndex, phase == .practicing else { return .refuse(.sessionClosed) }
        guard attempts[index].answers.contains(where: { $0.id == previousID && $0.promptID == attempts[index].support.interviewType.promptID }) else {
            return .refuse(.unknownTurn)
        }
        return submit(
            index: index, promptID: attempts[index].support.interviewType.promptID, retryOf: previousID,
            text: text, recordingReference: recordingReference, now: now)
    }

    mutating func submitFollowUp(text: String, recordingReference: String?, now: Date) -> ConversationAction {
        guard let index = activeIndex, phase == .practicing else { return .refuse(.sessionClosed) }
        guard let followUp = attempts[index].activeFollowUp else { return .refuse(.invalidSetup) }
        return submit(index: index, promptID: followUp.id.uuidString, retryOf: nil, text: text, recordingReference: recordingReference, now: now)
    }

    mutating func retryFollowUp(previousID: UUID, text: String, recordingReference: String?, now: Date) -> ConversationAction {
        guard let index = activeIndex, phase == .practicing, let followUp = attempts[index].activeFollowUp else {
            return .refuse(.sessionClosed)
        }
        guard attempts[index].answers.contains(where: { $0.id == previousID && $0.promptID == followUp.id.uuidString }) else {
            return .refuse(.unknownTurn)
        }
        return submit(index: index, promptID: followUp.id.uuidString, retryOf: previousID, text: text, recordingReference: recordingReference, now: now)
    }

    mutating func saveTechnicalNote(_ note: String) -> ConversationAction {
        guard !retention.applied else { return .refuse(.sessionClosed) }
        guard let index = activeIndex else { return .refuse(.sessionClosed) }
        guard attempts[index].support.technicalCoaching else { return .refuse(.invalidSetup) }
        attempts[index].technicalNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        return .accept()
    }

    mutating func saveSelfReview(purposeClear: Bool, factsNamed: String, nextStep: String, now: Date) -> ConversationAction {
        guard !retention.applied else { return .refuse(.sessionClosed) }
        guard let index = activeIndex else { return .refuse(.sessionClosed) }
        let facts = factsNamed.trimmingCharacters(in: .whitespacesAndNewlines)
        let step = nextStep.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !facts.isEmpty, !step.isEmpty else { return .refuse(.emptyTurn) }
        attempts[index].review = PracticeSelfReview(purposeClear: purposeClear, factsNamed: facts, nextStep: step, completedAt: now)
        return .accept()
    }

    mutating func requestOnlineNote(answerID: UUID, authorization: TurnRequestAuthorization, now: Date) -> ConversationAction {
        guard let index = activeIndex, phase == .practicing else { return .refuse(.sessionClosed) }
        guard let answer = attempts[index].answers.last(where: { $0.id == answerID }), let text = answer.text, !text.isEmpty else {
            return .refuse(.emptyTurn)
        }
        if let refusal = TurnRequestGate.refusal(
            policy: onlinePolicy, quietPractice: attempts[index].preparation.quietPractice, authorization: authorization,
            submitted: true, current: answerID == attempts[index].answers.last?.id,
            inFlightRequestID: attempts[index].inFlightRequestID,
            closedRequestIDs: Set(attempts[index].closedRequests.map(\.requestID))) {
            return .refuse(refusal)
        }
        attempts[index].inFlightRequestID = authorization.requestID
        attempts[index].inFlightAnswerID = answerID
        return .accept(PartnerRequestDescriptor(
            requestID: authorization.requestID, learnerTurnID: answerID, modality: answer.modality,
            currentTurnText: text, priorTurnIDs: [], priorTurnText: [:], createdAt: now))
    }

    mutating func receiveOnlineNote(_ reply: PartnerReply, now: Date) -> ConversationAction {
        guard let index = activeIndex, phase == .practicing else { return .refuse(.sessionClosed) }
        let text = reply.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            if reply.requestID == attempts[index].inFlightRequestID, let answerID = attempts[index].inFlightAnswerID {
                attempts[index].closedRequests.append(ClosedPartnerRequest(requestID: reply.requestID, learnerTurnID: answerID, reason: .failed, closedAt: now))
                attempts[index].inFlightRequestID = nil
                attempts[index].inFlightAnswerID = nil
            }
            return .refuse(.invalidReply)
        }
        guard reply.requestID == attempts[index].inFlightRequestID, reply.learnerTurnID == attempts[index].inFlightAnswerID else {
            attempts[index].ignoredLateRequestIDs.append(reply.requestID)
            return .refuse(.lateResult)
        }
        attempts[index].onlineNotes.append(OnlineInterviewNote(requestID: reply.requestID, sourceAnswerID: reply.learnerTurnID, text: text, receivedAt: now))
        attempts[index].closedRequests.append(ClosedPartnerRequest(requestID: reply.requestID, learnerTurnID: reply.learnerTurnID, reason: .delivered, closedAt: now))
        attempts[index].inFlightRequestID = nil
        attempts[index].inFlightAnswerID = nil
        return .accept()
    }

    mutating func markUnknownOutcome(now: Date) -> ConversationAction {
        guard let index = activeIndex, let requestID = attempts[index].inFlightRequestID, let answerID = attempts[index].inFlightAnswerID else {
            return .refuse(.unknownTurn)
        }
        attempts[index].closedRequests.append(ClosedPartnerRequest(requestID: requestID, learnerTurnID: answerID, reason: .unknownOutcome, closedAt: now))
        attempts[index].inFlightRequestID = nil
        attempts[index].inFlightAnswerID = nil
        return .accept()
    }

    mutating func stop(now: Date) -> ConversationAction {
        guard phase == .practicing || phase == .stopped else { return .refuse(.sessionClosed) }
        cancelInFlight(now: now)
        phase = .stopped
        return .accept()
    }

    mutating func end(now: Date) -> ConversationAction {
        guard phase == .practicing || phase == .stopped else { return .refuse(.sessionClosed) }
        cancelInFlight(now: now)
        phase = .ended
        endedAt = now
        return .accept()
    }

    mutating func restart() -> ConversationAction {
        guard phase == .stopped, retention.applied == false else { return .refuse(.sessionClosed) }
        phase = .practicing
        return .accept()
    }

    mutating func applyRetention(keepAudio: Bool, keepText: Bool) -> ConversationAction {
        guard phase == .stopped || phase == .ended else { return .refuse(.retentionIncomplete) }
        if !keepText {
            draftPreparation = InterviewPreparation(note: "", suppliedFacts: [], quietPractice: draftPreparation.quietPractice)
            draftSupport.roleTitle = ""
        }
        if !keepText || !keepAudio {
            for index in attempts.indices {
                if !keepText {
                    for answer in attempts[index].answers.indices { attempts[index].answers[answer].text = nil }
                    for followUp in attempts[index].followUps.indices { attempts[index].followUps[followUp].quotedAnswer = "" }
                    attempts[index].support.roleTitle = ""
                    attempts[index].preparation.note = ""
                    attempts[index].preparation.suppliedFacts = []
                    attempts[index].technicalNote = ""
                    attempts[index].review.factsNamed = ""
                    attempts[index].review.nextStep = ""
                    attempts[index].onlineNotes = []
                }
                if !keepAudio {
                    for answer in attempts[index].answers.indices { attempts[index].answers[answer].recordingReference = nil }
                }
            }
        }
        retention = RetentionSelection(keepAudio: keepAudio, keepText: keepText, applied: true)
        return .accept()
    }

    private var activeIndex: Int? {
        attempts.firstIndex { $0.id == activeAttemptID && $0.supersededAt == nil }
    }

    private mutating func submit(
        index: Int, promptID: String, retryOf: UUID?, text: String, recordingReference: String?, now: Date
    ) -> ConversationAction {
        if attempts[index].inFlightRequestID != nil { return .refuse(.requestInFlight) }
        if retryOf == nil, attempts[index].answers.contains(where: { $0.promptID == promptID }) {
            return .refuse(.duplicateRequest)
        }
        let note = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let reference = recordingReference?.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasRecording = !(reference ?? "").isEmpty
        guard !note.isEmpty || hasRecording else { return .refuse(.emptyTurn) }
        let answer = InterviewAnswer(
            id: UUID(), promptID: promptID, text: note.isEmpty ? nil : note, recordingReference: hasRecording ? reference : nil,
            modality: hasRecording ? .recordedTurn : .text, retryOf: retryOf, createdAt: now)
        attempts[index].answers.append(answer)
        if attempts[index].creditID == nil {
            attempts[index].creditID = UUID()
        }
        if promptID == attempts[index].support.interviewType.promptID, let quote = answer.text {
            let followUp = GroundedFollowUp(sourceAnswerID: answer.id, quotedAnswer: quote)
            attempts[index].followUps.append(followUp)
            attempts[index].activeFollowUpID = followUp.id
        }
        return .accept()
    }

    private mutating func cancelInFlight(now: Date) {
        guard let index = activeIndex, let requestID = attempts[index].inFlightRequestID, let answerID = attempts[index].inFlightAnswerID else { return }
        attempts[index].closedRequests.append(ClosedPartnerRequest(requestID: requestID, learnerTurnID: answerID, reason: .cancelled, closedAt: now))
        attempts[index].inFlightRequestID = nil
        attempts[index].inFlightAnswerID = nil
    }
}

enum InterviewType: String, Codable, CaseIterable, Identifiable {
    case introduction, behavioral, roleSpecific
    var id: String { rawValue }
    var title: String {
        switch self {
        case .introduction: "Introduction"
        case .behavioral: "Behavioral"
        case .roleSpecific: "Role-specific"
        }
    }
    var promptID: String { "offline-practice-\(rawValue)" }
    static let promptVersion = "unreviewed-offline-1"
    var offlinePrompt: String {
        switch self {
        case .introduction:
            "Introduce the role you named and one kind of work you want to talk about. Use only details you supply."
        case .behavioral:
            "Describe one situation you choose to share. Say what you did and what you would do next."
        case .roleSpecific:
            "Explain one task from the role you named, using only details you supply."
        }
    }
}

struct InterviewSupport: Equatable, Codable {
    var roleTitle: String
    var interviewType: InterviewType
    var technicalCoaching: Bool
    var presenterID: String
    var scenarioID: String?
    var scenarioVersion: String?
    var fictionalPersona: Bool

    var fingerprint: String {
        [roleTitle, interviewType.rawValue, technicalCoaching ? "technical" : "english-only",
         presenterID, scenarioID ?? "none", scenarioVersion ?? "none", fictionalPersona ? "fiction" : "personal"]
            .joined(separator: "|")
    }
}

struct InterviewPreparation: Equatable, Codable {
    var note: String
    var suppliedFacts: [String]
    var quietPractice: Bool
}

struct InterviewAnswer: Equatable, Codable, Identifiable {
    let id: UUID
    let promptID: String
    var text: String?
    var recordingReference: String?
    var modality: TurnModality
    var retryOf: UUID?
    var createdAt: Date
}

enum InterviewFollowUpWording {
    static let instruction = "Add one detail that you choose to share. This follow-up uses only the answer you just submitted. It does not add a job, a result, or a number."
}

struct GroundedFollowUp: Equatable, Codable, Identifiable {
    let id: UUID
    let sourceAnswerID: UUID
    var quotedAnswer: String
    let instruction: String

    init(id: UUID = UUID(), sourceAnswerID: UUID, quotedAnswer: String) {
        self.id = id
        self.sourceAnswerID = sourceAnswerID
        self.quotedAnswer = quotedAnswer
        instruction = InterviewFollowUpWording.instruction
    }

    var composed: String { "You said: \(quotedAnswer)\n\(instruction)" }

    var preservesSuppliedFacts: Bool {
        instruction == InterviewFollowUpWording.instruction && composed == "You said: \(quotedAnswer)\n\(instruction)"
    }
}

struct OnlineInterviewNote: Equatable, Codable {
    var requestID: UUID
    var sourceAnswerID: UUID
    var text: String
    var receivedAt: Date
}

struct InterviewAttempt: Equatable, Codable, Identifiable {
    let id: UUID
    var support: InterviewSupport
    var preparation: InterviewPreparation
    var answers: [InterviewAnswer]
    var followUps: [GroundedFollowUp]
    var activeFollowUpID: UUID?
    var review: PracticeSelfReview
    var technicalNote: String
    var onlineNotes: [OnlineInterviewNote]
    var closedRequests: [ClosedPartnerRequest]
    var ignoredLateRequestIDs: [UUID]
    var inFlightRequestID: UUID?
    var inFlightAnswerID: UUID?
    var creditID: UUID?
    var supersededAt: Date?
    var startedAt: Date

    init(support: InterviewSupport, preparation: InterviewPreparation, startedAt: Date) {
        id = UUID()
        self.support = support
        self.preparation = preparation
        answers = []
        followUps = []
        review = PracticeSelfReview()
        technicalNote = ""
        onlineNotes = []
        closedRequests = []
        ignoredLateRequestIDs = []
        self.startedAt = startedAt
    }

    var activeFollowUp: GroundedFollowUp? { followUps.first { $0.id == activeFollowUpID } }

    var qualifiesAsInteractiveInterview: Bool {
        guard let followUp = activeFollowUp, followUp.preservesSuppliedFacts else { return false }
        let openingID = support.interviewType.promptID
        guard let source = answers.first(where: { $0.id == followUp.sourceAnswerID }), source.promptID == openingID, source.text == followUp.quotedAnswer else {
            return false
        }
        let answeredFollowUp = answers.contains { $0.promptID == followUp.id.uuidString && !($0.text ?? "").isEmpty }
        return answeredFollowUp && review.isComplete && review.speechAssessed == false
    }
}


/// One recorder launch owns one submission slot. Results are consumed once and never reused across tasks.
struct InterviewRecordingSlot: Codable, Equatable {
    let id: UUID
    let attemptID: UUID
    let promptID: String
    private(set) var reference: String?

    init(attemptID: UUID, promptID: String) {
        id = UUID(); self.attemptID = attemptID; self.promptID = promptID
    }

    mutating func receive(_ attachment: PracticeRecordingAttachment, activeAttemptID: UUID?) -> Bool {
        guard reference == nil, attachment.turnID == id, activeAttemptID == attemptID,
              !attachment.reference.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        reference = attachment.reference
        return true
    }

    func reference(attemptID: UUID?, promptID: String) -> String? {
        guard attemptID == self.attemptID, promptID == self.promptID else { return nil }
        return reference
    }
}
