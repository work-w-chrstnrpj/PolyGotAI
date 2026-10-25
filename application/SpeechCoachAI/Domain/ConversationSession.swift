import Foundation

/// Local text or recorded-turn conversation. This value is not a learner store, a provider client, or a realtime session.
struct ConversationSession: Codable, Equatable, Identifiable {
    let id: UUID
    var setup: ConversationSetup
    var phase: ConversationPhase
    var turns: [ConversationTurn]
    var currentLearnerTurnID: UUID?
    private var inFlightRequestID: UUID?
    private var inFlightTurnID: UUID?
    private(set) var credits: [LocalParticipationCredit]
    var onlinePolicy: OnlineTurnPolicy
    private(set) var selfReview: PracticeSelfReview
    private(set) var retention: RetentionSelection
    private(set) var closedRequests: [ClosedPartnerRequest]
    private(set) var ignoredLateRequestIDs: [UUID]
    var startedAt: Date
    private(set) var endedAt: Date?
    var affectsCourseProgress: Bool { false }

    init(id: UUID = UUID(), presenterID: String, now: Date = .now) {
        self.id = id
        setup = ConversationSetup(
            kind: .freeDiscussion, situation: "", scenarioID: nil, scenarioVersion: nil,
            supportNote: "", feedbackFocus: "", modality: .text, presenterID: presenterID, quietPractice: false)
        phase = .preparing
        turns = []
        credits = []
        onlinePolicy = .disabledUntilContract
        selfReview = PracticeSelfReview()
        retention = RetentionSelection()
        closedRequests = []
        ignoredLateRequestIDs = []
        startedAt = now
    }

    var sendsAudio: Bool { false }

    /// Two learner turns with a partner reply bound to each turn. A self-review alone is not a conversation.
    var backAndForthCount: Int {
        turns.filter { turn in
            turn.speaker == .learner && turn.disposition == .submitted
                && turns.contains { $0.speaker == .partner && $0.respondsTo == turn.id }
        }.count
    }
    var qualifiesAsConversation: Bool { backAndForthCount >= 2 }

    static func selectRealtime() -> ConversationRefusal { .realtimeUnavailable }

    mutating func begin(publishedScenarios: [WorkplaceScenarioReference], now: Date) -> ConversationAction {
        guard phase == .preparing else { return .refuse(.sessionClosed) }
        switch setup.kind {
        case .freeDiscussion:
            guard !setup.situation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return .refuse(.invalidSetup) }
            setup.scenarioID = nil
            setup.scenarioVersion = nil
        case .everydayScenario:
            let published = ScenarioAvailability.published(publishedScenarios)
            guard let scenarioID = setup.scenarioID, let match = published.first(where: { $0.id == scenarioID }) else {
                return .refuse(.invalidSetup)
            }
            setup.scenarioVersion = match.version
        }
        phase = .practicing
        startedAt = now
        return .accept()
    }

    @discardableResult
    mutating func openLearnerTurn(now: Date) -> ConversationAction {
        guard phase == .practicing else { return .refuse(.sessionClosed) }
        guard inFlightRequestID == nil else { return .refuse(.requestInFlight) }
        if let currentLearnerTurnID, let current = turns.first(where: { $0.id == currentLearnerTurnID }), current.disposition == .drafting {
            return .accept()
        }
        let turn = ConversationTurn(
            id: UUID(), exchangeID: UUID(), speaker: .learner, modality: setup.modality,
            text: nil, recordingReference: nil, respondsTo: nil, retryOf: nil, disposition: .drafting, createdAt: now)
        turns.append(turn)
        currentLearnerTurnID = turn.id
        return .accept()
    }

    mutating func attachRecording(turnID: UUID, reference: String) -> ConversationAction {
        guard phase == .practicing, !retention.applied, turnID == currentLearnerTurnID, let index = draftingIndex(turnID) else { return .refuse(.unknownTurn) }
        let reference = reference.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !reference.isEmpty else { return .refuse(.emptyTurn) }
        turns[index].recordingReference = reference
        turns[index].modality = .recordedTurn
        return .accept()
    }

    mutating func submitLearnerTurn(id: UUID, text: String, now: Date) -> ConversationAction {
        guard phase == .practicing else { return .refuse(.sessionClosed) }
        guard id == currentLearnerTurnID, let index = draftingIndex(id) else { return .refuse(.notCurrentTurn) }
        let note = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let reference = turns[index].recordingReference?.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasRecording = !(reference ?? "").isEmpty
        guard !note.isEmpty || hasRecording else { return .refuse(.emptyTurn) }
        turns[index].text = note.isEmpty ? nil : note
        turns[index].modality = hasRecording ? .recordedTurn : .text
        turns[index].disposition = .submitted
        turns[index].createdAt = now
        if !credits.contains(where: { $0.exchangeID == turns[index].exchangeID }) {
            credits.append(LocalParticipationCredit(id: UUID(), exchangeID: turns[index].exchangeID, firstLearnerTurnID: id))
        }
        return .accept()
    }

    mutating func retryLearnerTurn(previousID: UUID, now: Date) -> ConversationAction {
        guard phase == .practicing else { return .refuse(.sessionClosed) }
        guard inFlightRequestID == nil else { return .refuse(.requestInFlight) }
        if let currentLearnerTurnID, turns.first(where: { $0.id == currentLearnerTurnID })?.disposition == .drafting {
            return .refuse(.notCurrentTurn)
        }
        guard let previous = turns.first(where: { $0.id == previousID }), previous.speaker == .learner, previous.disposition == .submitted else {
            return .refuse(.unknownTurn)
        }
        let turn = ConversationTurn(
            id: UUID(), exchangeID: previous.exchangeID, speaker: .learner, modality: setup.modality,
            text: nil, recordingReference: nil, respondsTo: nil, retryOf: previous.id, disposition: .drafting, createdAt: now)
        turns.append(turn)
        currentLearnerTurnID = turn.id
        return .accept()
    }

    mutating func requestPartner(turnID: UUID, authorization: TurnRequestAuthorization, now: Date) -> ConversationAction {
        guard phase == .practicing else { return .refuse(.sessionClosed) }
        guard let turn = turns.first(where: { $0.id == turnID }) else { return .refuse(.unknownTurn) }
        let currentText = turn.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let currentText, !currentText.isEmpty else { return .refuse(.emptyTurn) }
        if let refusal = TurnRequestGate.refusal(
            policy: onlinePolicy, quietPractice: setup.quietPractice, authorization: authorization,
            submitted: turn.disposition == .submitted, current: turnID == currentLearnerTurnID && turn.speaker == .learner,
            inFlightRequestID: inFlightRequestID, closedRequestIDs: Set(closedRequests.map(\.requestID))) {
            return .refuse(refusal)
        }
        let priorIDs = authorization.includePriorTurnText
            ? authorization.priorTurnIDs.filter { id in id != turnID && turns.contains { $0.id == id } }
            : []
        var priorText: [UUID: String] = [:]
        if authorization.includePriorTurnText {
            for id in priorIDs {
                if let text = turns.first(where: { $0.id == id })?.text, !text.isEmpty { priorText[id] = text }
            }
        }
        let descriptor = PartnerRequestDescriptor(
            requestID: authorization.requestID, learnerTurnID: turnID, modality: turn.modality,
            currentTurnText: currentText, priorTurnIDs: priorIDs, priorTurnText: priorText, createdAt: now)
        inFlightRequestID = authorization.requestID
        inFlightTurnID = turnID
        return .accept(descriptor)
    }

    mutating func cancelPartnerRequest(now: Date) -> ConversationAction {
        guard phase == .practicing || phase == .stopped else { return .refuse(.sessionClosed) }
        closeInFlight(.cancelled, now: now)
        return .accept()
    }

    mutating func receivePartner(_ reply: PartnerReply, now: Date) -> ConversationAction {
        guard phase == .practicing else { return .refuse(.sessionClosed) }
        let text = reply.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            closeInFlight(.failed, now: now, matching: reply.requestID)
            return .refuse(.invalidReply)
        }
        guard reply.requestID == inFlightRequestID, reply.learnerTurnID == inFlightTurnID else {
            if !ignoredLateRequestIDs.contains(reply.requestID) { ignoredLateRequestIDs.append(reply.requestID) }
            return .refuse(.lateResult)
        }
        turns.append(ConversationTurn(
            id: UUID(), exchangeID: turns.first { $0.id == reply.learnerTurnID }?.exchangeID ?? UUID(),
            speaker: .partner, modality: .text, text: text, recordingReference: nil,
            respondsTo: reply.learnerTurnID, retryOf: nil, disposition: .submitted, createdAt: now))
        closeInFlight(.delivered, now: now)
        return .accept()
    }

    mutating func failPartnerRequest(requestID: UUID, now: Date) -> ConversationAction {
        guard requestID == inFlightRequestID else { return .refuse(.lateResult) }
        closeInFlight(.failed, now: now)
        return .accept()
    }

    /// Restart leaves the unresolved request unknown and does not send it again.
    mutating func markUnknownOutcome(now: Date) -> ConversationAction {
        guard inFlightRequestID != nil else { return .refuse(.unknownTurn) }
        closeInFlight(.unknownOutcome, now: now)
        return .accept()
    }

    mutating func stop(now: Date) -> ConversationAction {
        guard phase == .practicing || phase == .stopped else { return .refuse(.sessionClosed) }
        closeInFlight(.cancelled, now: now)
        phase = .stopped
        return .accept()
    }

    mutating func end(now: Date) -> ConversationAction {
        guard phase == .practicing || phase == .stopped else { return .refuse(.sessionClosed) }
        closeInFlight(.cancelled, now: now)
        phase = .ended
        endedAt = now
        return .accept()
    }

    mutating func restart() -> ConversationAction {
        guard phase == .stopped, retention.applied == false, inFlightRequestID == nil else { return .refuse(.sessionClosed) }
        phase = .practicing
        return .accept()
    }

    mutating func saveSelfReview(purposeClear: Bool, factsNamed: String, nextStep: String, now: Date) -> ConversationAction {
        guard phase != .preparing, !retention.applied else { return .refuse(.sessionClosed) }
        let facts = factsNamed.trimmingCharacters(in: .whitespacesAndNewlines)
        let step = nextStep.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !facts.isEmpty, !step.isEmpty else { return .refuse(.emptyTurn) }
        selfReview = PracticeSelfReview(purposeClear: purposeClear, factsNamed: facts, nextStep: step, completedAt: now)
        return .accept()
    }

    mutating func applyRetention(keepAudio: Bool, keepText: Bool) -> ConversationAction {
        guard phase == .stopped || phase == .ended else { return .refuse(.retentionIncomplete) }
        if !keepText {
            for index in turns.indices { turns[index].text = nil }
            setup.situation = ""; setup.supportNote = ""; setup.feedbackFocus = ""
            selfReview = PracticeSelfReview()
        }
        if !keepAudio { for index in turns.indices { turns[index].recordingReference = nil } }
        retention = RetentionSelection(keepAudio: keepAudio, keepText: keepText, applied: true)
        return .accept()
    }

    private func draftingIndex(_ id: UUID) -> Int? {
        turns.firstIndex { $0.id == id && $0.speaker == .learner && $0.disposition == .drafting }
    }

    private mutating func closeInFlight(_ reason: PartnerRequestClose, now: Date, matching expected: UUID? = nil) {
        guard let requestID = inFlightRequestID, let turnID = inFlightTurnID else { return }
        if let expected, expected != requestID { return }
        closedRequests.append(ClosedPartnerRequest(requestID: requestID, learnerTurnID: turnID, reason: reason, closedAt: now))
        inFlightRequestID = nil
        inFlightTurnID = nil
    }
}

struct ConversationSetup: Equatable, Codable {
    var kind: ConversationKind
    var situation: String
    var scenarioID: String?
    var scenarioVersion: String?
    var supportNote: String
    var feedbackFocus: String
    var modality: TurnModality
    var presenterID: String
    var quietPractice: Bool
}

enum ConversationKind: String, Codable, CaseIterable, Identifiable {
    case freeDiscussion, everydayScenario
    var id: String { rawValue }
    var title: String {
        switch self {
        case .freeDiscussion: "Free discussion"
        case .everydayScenario: "Everyday scenario"
        }
    }
}

enum TurnModality: String, Codable, CaseIterable, Identifiable {
    case text, recordedTurn
    var id: String { rawValue }
    var title: String {
        switch self {
        case .text: "Text turn"
        case .recordedTurn: "Recorded turn"
        }
    }
    static let realtimeTitle = "Live voice"
    static let realtimeDetail = "Live voice is not available. Streaming, interruption and turn-taking stay a separate investigation."
}

enum ConversationPhase: String, Codable { case preparing, practicing, stopped, ended }

enum Speaker: String, Codable { case learner, partner }

enum TurnDisposition: String, Codable { case drafting, submitted }

struct ConversationTurn: Equatable, Codable, Identifiable {
    let id: UUID
    let exchangeID: UUID
    let speaker: Speaker
    var modality: TurnModality
    var text: String?
    var recordingReference: String?
    var respondsTo: UUID?
    var retryOf: UUID?
    var disposition: TurnDisposition
    var createdAt: Date
}

struct LocalParticipationCredit: Equatable, Codable, Identifiable {
    let id: UUID
    let exchangeID: UUID
    let firstLearnerTurnID: UUID
}

enum OnlineTurnPolicy: Equatable, Codable {
    case disabledUntilContract
    case explicitlyEnabled(contractVersion: String)
}

struct TurnRequestAuthorization: Equatable {
    var requestID: UUID
    var consentReference: String
    var contractVersion: String
    var includePriorTurnText: Bool = false
    var priorTurnIDs: [UUID] = []
}

struct PartnerRequestDescriptor: Equatable, Codable {
    var requestID: UUID
    var learnerTurnID: UUID
    var modality: TurnModality
    var currentTurnText: String
    var priorTurnIDs: [UUID]
    var priorTurnText: [UUID: String]
    var createdAt: Date
    var sendsAudio: Bool { false }
}

struct PartnerReply: Equatable {
    var requestID: UUID
    var learnerTurnID: UUID
    var text: String
}

enum PartnerRequestClose: String, Codable { case delivered, cancelled, failed, unknownOutcome }

struct ClosedPartnerRequest: Equatable, Codable {
    var requestID: UUID
    var learnerTurnID: UUID
    var reason: PartnerRequestClose
    var closedAt: Date
}

enum ConversationRefusal: Equatable, Codable {
    case invalidSetup, emptyTurn, unknownTurn, notCurrentTurn, turnNotSubmitted
    case requestInFlight, onlineDisabled, quietPractice, missingConsent, contractMismatch
    case duplicateRequest, lateResult, invalidReply, sessionClosed, realtimeUnavailable, retentionIncomplete
}

struct ConversationAction: Equatable {
    var refusal: ConversationRefusal?
    var descriptor: PartnerRequestDescriptor?
    var accepted: Bool { refusal == nil }
    static func accept(_ descriptor: PartnerRequestDescriptor? = nil) -> ConversationAction {
        ConversationAction(refusal: nil, descriptor: descriptor)
    }
    static func refuse(_ refusal: ConversationRefusal) -> ConversationAction {
        ConversationAction(refusal: refusal, descriptor: nil)
    }
}

enum TurnRequestGate {
    static func refusal(
        policy: OnlineTurnPolicy, quietPractice: Bool, authorization: TurnRequestAuthorization,
        submitted: Bool, current: Bool, inFlightRequestID: UUID?, closedRequestIDs: Set<UUID>
    ) -> ConversationRefusal? {
        if quietPractice { return .quietPractice }
        switch policy {
        case .disabledUntilContract:
            return .onlineDisabled
        case .explicitlyEnabled(let version):
            if version.isEmpty || authorization.contractVersion != version { return .contractMismatch }
        }
        if authorization.consentReference.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return .missingConsent }
        if !current { return .notCurrentTurn }
        if !submitted { return .turnNotSubmitted }
        if inFlightRequestID != nil { return .requestInFlight }
        if closedRequestIDs.contains(authorization.requestID) { return .duplicateRequest }
        return nil
    }
}

struct PracticeSelfReview: Equatable, Codable {
    var purposeClear: Bool? = nil
    var factsNamed: String = ""
    var nextStep: String = ""
    var completedAt: Date? = nil
    var speechAssessed: Bool { false }
    var isComplete: Bool {
        purposeClear != nil && !factsNamed.isEmpty && !nextStep.isEmpty && completedAt != nil
    }
}

struct RetentionSelection: Equatable, Codable {
    var keepAudio: Bool?
    var keepText: Bool?
    var applied = false
    var isExplicit: Bool { keepAudio != nil && keepText != nil }
}

struct WorkplaceScenarioReference: Equatable, Codable, Identifiable {
    var id: String
    var version: String
    var kind: String
    var levelLessonID: String?
    var levelContentVersion: String?
    var objectiveID: String?
    var trainerReference: String
    var audience: String
    var purpose: String
    var nextStep: String
    var fictionalExample: String
    var reviewStatus: String
    var rubricStatus: String
    var representsLearnerAccomplishment: Bool
}

enum ScenarioAvailability {
    static func published(_ scenarios: [WorkplaceScenarioReference]) -> [WorkplaceScenarioReference] {
        scenarios.filter {
            $0.reviewStatus == "reviewed" && $0.rubricStatus == "reviewed" && !$0.representsLearnerAccomplishment
        }
    }
}

struct PracticeRecordingAttachment: Equatable {
    var turnID: UUID
    var reference: String
}

/// Explicit local recovery, on the existing preferences document. No automatic online resubmission.
struct SpeakingPracticeArchive: Codable, Equatable, Identifiable {
    var id: String { kind }
    var kind: String
    var conversation: ConversationSession?
    var interview: InterviewSession?
    var drafts: [String: String]
    var expiresAt: Date?
    var recordingSlot: InterviewRecordingSlot? = nil
    var communication: CommunicationPractice? = nil
    var updatedAt: Date

    var audioReferences: [UUID] {
        let values = (conversation?.turns.compactMap(\.recordingReference) ?? [])
            + (interview?.attempts.flatMap { $0.answers.compactMap(\.recordingReference) } ?? [])
        return (values + [recordingSlot?.reference].compactMap { $0 }).compactMap(UUID.init(uuidString:)) + (communication?.audioReferences ?? [])
    }

    mutating func resolveInterruptedRequest(now: Date) {
        if conversation != nil { _ = conversation?.markUnknownOutcome(now: now) }
        if interview != nil { _ = interview?.markUnknownOutcome(now: now) }
        if communication != nil { _ = communication?.markUnknownOutcome(now: now) }
    }
}
