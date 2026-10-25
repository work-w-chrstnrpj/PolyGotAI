import Foundation
import CryptoKit

/// Structural contract for one generated practice variation.
/// Numeric budgets, provider approval and editorial approval are caller-supplied.
/// This file does not bundle an approved policy or a default budget.
enum GeneratedPracticeSchema {
    static let version = 1
    static let variety = "en-US"
    static let generatedLabel = "generated"
    static let payloadKeys: Set<String> = [
        "schemaVersion", "objectiveID", "contentVersion", "level", "templateID", "rubricVersion",
        "activityKind", "variety", "prompt", "explanation", "choices", "correctChoiceIndex",
        "recallAnswer", "candidateHeadword", "candidateMeaning", "grammarTargetIDs",
        "vocabularySenseIDs", "cardID", "editorialLabel", "factualSourceIDs", "referenceAudioID", "mediaURL"
    ]
}

enum GeneratedActivityKind: String, Codable, CaseIterable, Identifiable, Sendable {
    case recognitionChoice
    case recallCloze
    case guidedProduction
    case situationExample
    /// Shared shape for a later vocabulary preview. Acceptance never enrolls a card.
    case vocabularyCandidate

    var id: String { rawValue }

    var title: String {
        switch self {
        case .recognitionChoice: "Choose a sentence"
        case .recallCloze: "Recall"
        case .guidedProduction: "Say it yourself"
        case .situationExample: "New situation"
        case .vocabularyCandidate: "Word suggestion"
        }
    }
}

enum FamiliarityChoice: String, Codable, Sendable {
    case fresh
    case familiar
}

enum PrivateRetentionChoice: String, Codable, Sendable {
    case notChosen
    case declined
    case optedIn
}

enum EditorialStatus: Equatable, Codable, Sendable {
    case qualifiedEducatorReviewed(record: String)
    case personalUsePreview(record: String)
    case generatedUnreviewed
}

enum FactualSourceRule: Equatable, Codable, Sendable {
    case noFactualClaims
    case reviewedMaterial(ids: [String])
    case learnerNoteIDs(ids: [String])
}

struct ReportRetentionRule: Equatable, Codable, Sendable {
    var retainForSeconds: Int
    var exportPermitted: Bool
    var exportEvidenceReference: String
    var localOnly: Bool

    func refusal() -> GenerationPolicyRefusal? {
        if retainForSeconds < 1 { return .reportRetentionMissing }
        if !localOnly { return .remoteReportRejected }
        if exportPermitted {
            let evidence = exportEvidenceReference.trimmingCharacters(in: .whitespacesAndNewlines)
            if evidence.isEmpty || evidence == GenerationPolicy.unapprovedProposalRecord { return .exportEvidenceMissing }
        }
        return nil
    }
}

struct ProviderAccessRule: Equatable, Codable, Sendable {
    var liveTransportPermitted: Bool
    var quotaProtectionVerified: Bool
    var evidenceReference: String

    var permitsLiveTransport: Bool {
        let evidence = evidenceReference.trimmingCharacters(in: .whitespacesAndNewlines)
        return liveTransportPermitted && quotaProtectionVerified && !evidence.isEmpty
            && evidence != GenerationPolicy.unapprovedProposalRecord
    }
}

/// Every bound is an explicit input. Missing or unapproved input fails closed.
struct GenerationPolicy: Equatable, Codable, Sendable {
    static let unapprovedProposalRecord = "sc-d015-policy-proposal-2026-10-24"

    var schemaVersion: Int
    var decisionRecord: String
    var ownerDecisionAccepted: Bool
    var permittedObjectiveIDs: [String]
    var permittedTemplateIDs: [String]
    var permittedActivityKinds: [GeneratedActivityKind]
    var contextScalarLimit: Int
    var maximumActivitiesPerRequest: Int
    var maximumValidatedCacheEntries: Int
    var cacheFreshnessSeconds: Int
    var maximumResponseBytes: Int
    var regenerationPermitted: Bool
    var costCeilingRecord: String
    var factualSource: FactualSourceRule
    var reportRetention: ReportRetentionRule
    var providerAccess: ProviderAccessRule

    func refusal() -> GenerationPolicyRefusal? {
        let decision = decisionRecord.trimmingCharacters(in: .whitespacesAndNewlines)
        let cost = costCeilingRecord.trimmingCharacters(in: .whitespacesAndNewlines)
        if !ownerDecisionAccepted { return .ownerDecisionMissing }
        if decision.isEmpty { return .decisionRecordMissing }
        if decision == Self.unapprovedProposalRecord { return .proposalIsNotApproval }
        if schemaVersion != GeneratedPracticeSchema.version { return .schemaMismatch }
        if permittedObjectiveIDs.isEmpty || permittedObjectiveIDs.contains(where: \.isEmpty) { return .objectivesMissing }
        if permittedTemplateIDs.isEmpty || permittedTemplateIDs.contains(where: \.isEmpty) { return .templatesMissing }
        if permittedActivityKinds.isEmpty { return .activityKindsMissing }
        if contextScalarLimit < 1 { return .contextBoundMissing }
        if maximumActivitiesPerRequest < 1 { return .countBoundMissing }
        if maximumValidatedCacheEntries < 1 { return .cacheBoundMissing }
        if cacheFreshnessSeconds < 1 { return .freshnessMissing }
        if maximumResponseBytes < 1 { return .responseBoundMissing }
        if cost.isEmpty || cost == Self.unapprovedProposalRecord { return .costCeilingMissing }
        if let retention = reportRetention.refusal() { return retention }
        if providerAccess.liveTransportPermitted && !providerAccess.permitsLiveTransport { return .providerEvidenceMissing }
        return nil
    }

    var accepted: Bool { refusal() == nil }
}

enum GenerationPolicyRefusal: String, Equatable, Sendable {
    case ownerDecisionMissing, decisionRecordMissing, proposalIsNotApproval, schemaMismatch
    case objectivesMissing, templatesMissing, activityKindsMissing
    case contextBoundMissing, countBoundMissing, cacheBoundMissing, freshnessMissing, responseBoundMissing
    case costCeilingMissing, reportRetentionMissing, remoteReportRejected, exportEvidenceMissing, providerEvidenceMissing
}

enum GenerationRefusal: Equatable, Error, Sendable {
    case missingPolicy
    case policyRejected(GenerationPolicyRefusal)
    case providerAccessNotGranted
    case malformed
    case unsupportedObjective
    case unsupportedVariety
    case unsupportedActivity
    case incompatibleVersion
    case invalidAnswer
    case ambiguous
    case answerLeakedBeforeRecall
    case mislabeledReview
    case pronunciationAssessmentUnavailable
    case videoSourceUnavailable
    case factualSourceRejected
    case contextBoundExceeded
    case responseBoundExceeded
    case regenerationNotPermitted
    case familiarityNotChosen
    case activityKindNotChosen
    case retentionNotChosen
    case requestInFlight
    case cancelled
    case lateResult
    case duplicateResult
    case unknownOutcome
    case offline
    case storageFailure
    case missingEpoch
    case staleEpoch
    case cacheBoundReached
    case cacheIncompatible
    case personalUsePreviewIsNotQualifiedReview
    case qualifiedFallbackUnavailable
    case automaticRetryBlocked
    case liveCallBlocked
    case enrollmentBlocked

    var message: String {
        switch self {
        case .missingPolicy, .policyRejected:
            "Generated practice needs an approved generation policy. Nothing was requested."
        case .providerAccessNotGranted, .liveCallBlocked:
            "Online generation is not approved. Nothing was sent, and nothing will be retried automatically."
        case .malformed, .invalidAnswer, .ambiguous, .contextBoundExceeded, .responseBoundExceeded:
            "That result could not be used. Your current practice is unchanged."
        case .unsupportedObjective, .unsupportedActivity, .unsupportedVariety, .incompatibleVersion, .cacheIncompatible:
            "That result does not match this objective. Your current practice is unchanged."
        case .answerLeakedBeforeRecall:
            "The result showed the answer too early. Your current practice is unchanged."
        case .mislabeledReview, .personalUsePreviewIsNotQualifiedReview:
            "Generated or personal-use material is not educator-reviewed practice."
        case .pronunciationAssessmentUnavailable:
            "Pronunciation scoring is not available. A generated sentence was not used."
        case .videoSourceUnavailable:
            "A link is not practice content. Nothing was presented."
        case .factualSourceRejected:
            "The result named a source this policy does not allow. Nothing was presented."
        case .regenerationNotPermitted:
            "A familiar saved variation is available. A new online variation was not requested."
        case .familiarityNotChosen:
            "Choose fresh or familiar practice before requesting a variation."
        case .activityKindNotChosen:
            "Choose an activity type before requesting a variation."
        case .retentionNotChosen:
            "Choose whether to keep this wording on the device before saving it."
        case .requestInFlight:
            "A request is already waiting. Nothing new was sent."
        case .cancelled:
            "Stopped waiting. Nothing will be retried automatically. Your current practice is unchanged."
        case .lateResult, .duplicateResult:
            "A late or repeated result was ignored. Your current practice is unchanged."
        case .unknownOutcome:
            "The request ended without a confirmed result. Nothing will be retried automatically."
        case .offline:
            "A connection is unavailable. Your current practice is unchanged. Nothing will be retried automatically."
        case .storageFailure:
            "The last save failed. The last saved copy is unchanged."
        case .missingEpoch, .staleEpoch:
            "This learner record cannot accept that save. Nothing from an older record was written."
        case .cacheBoundReached:
            "The saved-variation limit from the approved policy was reached. Older protected practice was kept."
        case .qualifiedFallbackUnavailable:
            "No educator-reviewed fallback is available. Your current practice is unchanged."
        case .automaticRetryBlocked:
            "Nothing was retried automatically."
        case .enrollmentBlocked:
            "A suggestion is not added to your words."
        }
    }
}

struct LearningIdentity: Equatable, Codable, Sendable {
    var objectiveID: String
    var senseID: String?
    var cardID: String?
}

struct ScheduleIdentity: Equatable, Codable, Sendable {
    var cardID: String?
    var dueAt: Date?
    var inReview: Bool
}

struct PracticeSource: Equatable, Codable, Sendable {
    var objectiveID: String
    var contentVersion: String
    var level: String
    var templateID: String
    var rubricVersion: String
    var grammarTargetIDs: [String]
    var vocabularySenseIDs: [String]
    var senseID: String?
    var cardID: String?
    var variety: String

    var learning: LearningIdentity {
        LearningIdentity(objectiveID: objectiveID, senseID: senseID, cardID: cardID)
    }

    func refusal() -> GenerationRefusal? {
        let fields = [objectiveID, contentVersion, level, templateID, rubricVersion]
        if fields.contains(where: { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) { return .malformed }
        if variety != GeneratedPracticeSchema.variety { return .unsupportedVariety }
        if grammarTargetIDs.contains(where: \.isEmpty) || vocabularySenseIDs.contains(where: \.isEmpty) { return .malformed }
        if let senseID {
            if senseID.isEmpty || !vocabularySenseIDs.contains(senseID) { return .malformed }
        }
        return nil
    }
}

struct CurrentAttempt: Equatable, Codable, Sendable {
    var id: UUID
    var prompt: String
    var objectiveID: String
    var senseID: String?
    var cardID: String?
    var contentVersion: String
    var rubricVersion: String
    var schedule: ScheduleIdentity
}

struct ReviewedFallback: Equatable, Codable, Sendable {
    var activityID: String
    var objectiveID: String
    var contentVersion: String
    var level: String
    var rubricVersion: String
    var prompt: String
    var status: EditorialStatus

    var qualifiedRecord: String? {
        if case .qualifiedEducatorReviewed(let record) = status {
            let trimmed = record.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty && trimmed != GenerationPolicy.unapprovedProposalRecord { return trimmed }
        }
        return nil
    }

    var isPersonalUsePreview: Bool {
        if case .personalUsePreview = status { return true }
        return false
    }
}

struct StoredVariantText: Equatable, Codable, Sendable {
    var prompt: String
    var explanation: String
    var choices: [String]?
    var recallAnswer: String?
    var candidateHeadword: String?
    var candidateMeaning: String?
}

struct ValidatedVariant: Equatable, Sendable {
    var id: String
    var source: PracticeSource
    var kind: GeneratedActivityKind
    var text: StoredVariantText
    var correctChoiceIndex: Int?
    var editorialLabel: String
    var answerDigest: String
    var permittedFactualSourceIDs: [String]

    var permitsVocabularyEnrollment: Bool { false }
    var countsAsComparableAssessment: Bool { false }
    var qualifiedEducatorReviewed: Bool { false }
    var soundAssessed: Bool { false }
}

struct PresentedActivity: Equatable, Sendable {
    var variantID: String
    var kind: GeneratedActivityKind
    var prompt: String?
    var explanation: String?
    var choices: [String]?
    var answerRevealed: Bool
    var revealedAnswer: String?
    var editorialLabel: String
    var qualifiedEducatorReviewed: Bool
    var countsAsComparableAssessment: Bool
    var soundAssessed: Bool
    var textUnavailableAfterDeletion: Bool
    var learning: LearningIdentity
    var rubricVersion: String
    var contentVersion: String
    var schemaVersion: Int
}

struct FrozenPracticeAttempt: Equatable, Codable, Sendable {
    var id: UUID
    var variantID: String
    var learning: LearningIdentity
    var templateID: String
    var schemaVersion: Int
    var contentVersion: String
    var level: String
    var rubricVersion: String
    var kind: GeneratedActivityKind
    var correctChoiceIndex: Int?
    var text: StoredVariantText?
    var retention: PrivateRetentionChoice
    var schedule: ScheduleIdentity
    var countsAsComparableAssessment: Bool
    var qualifiedEducatorReviewed: Bool
    var answerDigest: String
    var frozenAt: Date
    var sourceSnapshot: PracticeSource? = nil
}

struct CachedVariant: Equatable, Codable, Sendable {
    var id: String
    var learning: LearningIdentity
    var templateID: String
    var schemaVersion: Int
    var contentVersion: String
    var level: String
    var rubricVersion: String
    var kind: GeneratedActivityKind
    var correctChoiceIndex: Int?
    var text: StoredVariantText?
    var editorialLabel: String
    var validatedAt: Date
    var expiresAt: Date
    var privatePayloadDeleted: Bool
    var retention: PrivateRetentionChoice
    var answerDigest: String
    var sourceSnapshot: PracticeSource? = nil
    var acceptedPolicy: GenerationPolicy? = nil
}

struct VariantCache: Equatable, Codable, Sendable {
    var entries: [CachedVariant] = []
    var deletedVariantIDs: [String] = []

    func presentable(source: PracticeSource, policy: GenerationPolicy, now: Date) -> [CachedVariant] {
        guard source.refusal() == nil, policy.accepted,
              policy.permittedObjectiveIDs.contains(source.objectiveID),
              policy.permittedTemplateIDs.contains(source.templateID) else { return [] }
        return entries.filter { entry in
            entry.sourceSnapshot == source && entry.acceptedPolicy == policy
                && entry.schemaVersion == policy.schemaVersion
                && entry.learning.objectiveID == source.objectiveID
                && entry.learning.cardID == source.cardID
                && entry.learning.senseID == source.senseID
                && entry.contentVersion == source.contentVersion
                && entry.level == source.level
                && entry.templateID == source.templateID
                && entry.rubricVersion == source.rubricVersion
                && policy.permittedActivityKinds.contains(entry.kind)
                && entry.editorialLabel == GeneratedPracticeSchema.generatedLabel
                && now < entry.expiresAt
                && !entry.privatePayloadDeleted
                && entry.text != nil
        }
    }

    mutating func admit(
        _ variant: ValidatedVariant,
        policy: GenerationPolicy,
        retention: PrivateRetentionChoice,
        protectedVariantIDs: Set<String>,
        now: Date
    ) -> Result<CachedVariant, GenerationRefusal> {
        if let refusal = policy.refusal() { return .failure(.policyRejected(refusal)) }
        guard retention != .notChosen else { return .failure(.retentionNotChosen) }
        let deleted = deletedVariantIDs.contains(variant.id)
        let storedText = retention == .optedIn && !deleted ? variant.text : nil
        let entry = CachedVariant(
            id: variant.id, learning: variant.source.learning, templateID: variant.source.templateID,
            schemaVersion: policy.schemaVersion, contentVersion: variant.source.contentVersion,
            level: variant.source.level, rubricVersion: variant.source.rubricVersion, kind: variant.kind,
            correctChoiceIndex: variant.correctChoiceIndex, text: storedText, editorialLabel: GeneratedPracticeSchema.generatedLabel, validatedAt: now,
            expiresAt: now.addingTimeInterval(TimeInterval(policy.cacheFreshnessSeconds)),
            privatePayloadDeleted: deleted, retention: deleted ? .declined : retention,
            answerDigest: variant.answerDigest, sourceSnapshot: variant.source, acceptedPolicy: policy)
        if let index = entries.firstIndex(where: { $0.id == variant.id }) {
            if entries[index].answerDigest != variant.answerDigest { return .failure(.incompatibleVersion) }
            if entries[index].privatePayloadDeleted {
                var kept = entries[index]
                kept.validatedAt = now
                kept.expiresAt = entry.expiresAt
                kept.text = nil
                entries[index] = kept
                return .success(kept)
            }
            entries[index] = entry
            return .success(entry)
        }
        var next = entries
        while next.count >= policy.maximumValidatedCacheEntries {
            let victims = next.enumerated().filter { !protectedVariantIDs.contains($0.element.id) }.sorted { $0.element.validatedAt < $1.element.validatedAt }
            guard let victim = victims.first else { return .failure(.cacheBoundReached) }
            next.remove(at: victim.offset)
        }
        next.append(entry)
        entries = next
        return .success(entry)
    }

    mutating func deletePrivatePayload(variantID: String) {
        if !deletedVariantIDs.contains(variantID) { deletedVariantIDs.append(variantID) }
        guard let index = entries.firstIndex(where: { $0.id == variantID }) else { return }
        entries[index].text = nil
        entries[index].correctChoiceIndex = nil
        entries[index].privatePayloadDeleted = true
        entries[index].retention = .declined
    }
}

struct GeneratedPracticeRecord: Equatable, Codable, Sendable {
    var schemaVersion: Int = GeneratedPracticeSchema.version
    var cache: VariantCache = VariantCache()
    var reports: [IncorrectActivityReport] = []
    var frozenAttempts: [FrozenPracticeAttempt] = []
    var unresolvedRequestID: UUID?
    var learnerEpoch: UUID? = nil

    static let empty = GeneratedPracticeRecord()
}

struct GenerationRequestEnvelope: Equatable, Codable, Sendable {
    var schemaVersion: Int
    var requestID: UUID
    var objectiveID: String
    var contentVersion: String
    var level: String
    var templateID: String
    var rubricVersion: String
    var activityKind: GeneratedActivityKind
    var variety: String
    var familiarity: FamiliarityChoice
    var grammarTargetIDs: [String]
    var vocabularySenseIDs: [String]
    var cardID: String?
    var factualSourceIDs: [String]
    var costCeilingRecord: String
    var contextScalarLimit: Int
}

enum RequestDisposition: String, Codable, Sendable {
    case awaiting, succeeded, failed, cancelled, unknownOutcome
}

enum StableIdentity {
    static func digest(_ parts: [String]) -> String {
        var bytes = Data()
        for part in parts {
            var length = UInt64(part.utf8.count).bigEndian
            withUnsafeBytes(of: &length) { bytes.append(contentsOf: $0) }
            bytes.append(contentsOf: part.utf8)
        }
        return SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
    }

    static func variantID(source: PracticeSource, kind: GeneratedActivityKind, prompt: String) -> String {
        digest([source.objectiveID, source.cardID ?? "", source.senseID ?? "", source.templateID,
                String(GeneratedPracticeSchema.version), source.contentVersion, kind.rawValue, prompt])
    }
}

enum GeneratedVariantValidator {
    static func validate(data: Data, policy: GenerationPolicy?, source: PracticeSource) -> Result<ValidatedVariant, GenerationRefusal> {
        guard let policy else { return .failure(.missingPolicy) }
        if let refusal = policy.refusal() { return .failure(.policyRejected(refusal)) }
        if let refusal = source.refusal() { return .failure(refusal) }
        guard policy.permittedObjectiveIDs.contains(source.objectiveID) else { return .failure(.unsupportedObjective) }
        guard policy.permittedTemplateIDs.contains(source.templateID) else { return .failure(.unsupportedActivity) }
        if data.count > policy.maximumResponseBytes { return .failure(.responseBoundExceeded) }
        let object: [String: Any]
        do {
            guard let parsed = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { return .failure(.malformed) }
            object = parsed
        } catch { return .failure(.malformed) }
        guard Set(object.keys) == GeneratedPracticeSchema.payloadKeys else { return .failure(.malformed) }
        guard let schema = jsonInt(object["schemaVersion"]) else { return .failure(.malformed) }
        guard schema == GeneratedPracticeSchema.version else { return .failure(.incompatibleVersion) }
        let payload: Payload
        do { payload = try JSONDecoder().decode(Payload.self, from: data) }
        catch { return .failure(.malformed) }
        if let blocked = blockedKind(payload.activityKind) { return .failure(blocked) }
        guard let kind = GeneratedActivityKind(rawValue: payload.activityKind), policy.permittedActivityKinds.contains(kind) else {
            return .failure(.unsupportedActivity)
        }
        guard payload.objectiveID == source.objectiveID else { return .failure(.unsupportedObjective) }
        guard payload.contentVersion == source.contentVersion, payload.rubricVersion == source.rubricVersion else {
            return .failure(.incompatibleVersion)
        }
        guard payload.level == source.level else { return .failure(.unsupportedObjective) }
        guard payload.templateID == source.templateID else { return .failure(.unsupportedActivity) }
        guard payload.variety == GeneratedPracticeSchema.variety else { return .failure(.unsupportedVariety) }
        guard payload.editorialLabel == GeneratedPracticeSchema.generatedLabel else { return .failure(.mislabeledReview) }
        guard payload.cardID == source.cardID else { return .failure(.unsupportedObjective) }
        guard Set(payload.grammarTargetIDs) == Set(source.grammarTargetIDs),
              Set(payload.vocabularySenseIDs) == Set(source.vocabularySenseIDs) else { return .failure(.unsupportedObjective) }
        if let media = payload.mediaURL?.trimmingCharacters(in: .whitespacesAndNewlines), !media.isEmpty {
            return .failure(.videoSourceUnavailable)
        }
        if payload.referenceAudioID?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            return .failure(.pronunciationAssessmentUnavailable)
        }
        if let factual = factualRefusal(payload.factualSourceIDs, rule: policy.factualSource) { return .failure(factual) }
        let prompt = payload.prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        let explanation = payload.explanation.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else { return .failure(.malformed) }
        let text: StoredVariantText
        let digest: String
        switch kind {
        case .recognitionChoice:
            guard let choices = payload.choices, payload.correctChoiceIndex != nil, payload.recallAnswer == nil,
                  payload.candidateHeadword == nil, payload.candidateMeaning == nil else { return .failure(.malformed) }
            let trimmed = choices.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            guard trimmed.count >= 2, trimmed.allSatisfy({ !$0.isEmpty }), Set(trimmed).count == trimmed.count,
                  let index = payload.correctChoiceIndex, trimmed.indices.contains(index) else { return .failure(.invalidAnswer) }
            guard !explanation.isEmpty else { return .failure(.ambiguous) }
            if leaks(trimmed[index], in: [prompt, explanation]) { return .failure(.answerLeakedBeforeRecall) }
            text = StoredVariantText(prompt: prompt, explanation: explanation, choices: trimmed, recallAnswer: nil, candidateHeadword: nil, candidateMeaning: nil)
            digest = StableIdentity.digest([String(index), trimmed[index]])
        case .recallCloze:
            guard payload.choices == nil, payload.correctChoiceIndex == nil, payload.candidateHeadword == nil,
                  payload.candidateMeaning == nil, let answer = payload.recallAnswer?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !answer.isEmpty else { return .failure(.invalidAnswer) }
            guard !explanation.isEmpty else { return .failure(.ambiguous) }
            if leaks(answer, in: [prompt, explanation]) { return .failure(.answerLeakedBeforeRecall) }
            text = StoredVariantText(prompt: prompt, explanation: explanation, choices: nil, recallAnswer: answer, candidateHeadword: nil, candidateMeaning: nil)
            digest = StableIdentity.digest([answer])
        case .guidedProduction, .situationExample:
            guard payload.choices == nil, payload.correctChoiceIndex == nil, payload.recallAnswer == nil,
                  payload.candidateHeadword == nil, payload.candidateMeaning == nil else { return .failure(.malformed) }
            text = StoredVariantText(prompt: prompt, explanation: explanation, choices: nil, recallAnswer: nil, candidateHeadword: nil, candidateMeaning: nil)
            digest = StableIdentity.digest([kind.rawValue])
        case .vocabularyCandidate:
            guard payload.choices == nil, payload.correctChoiceIndex == nil, payload.recallAnswer == nil,
                  let headword = payload.candidateHeadword?.trimmingCharacters(in: .whitespacesAndNewlines), !headword.isEmpty,
                  let meaning = payload.candidateMeaning?.trimmingCharacters(in: .whitespacesAndNewlines), !meaning.isEmpty else {
                return .failure(.invalidAnswer)
            }
            if source.cardID != nil && leaks(headword, in: [prompt, explanation]) { return .failure(.answerLeakedBeforeRecall) }
            text = StoredVariantText(prompt: prompt, explanation: explanation, choices: nil, recallAnswer: nil, candidateHeadword: headword, candidateMeaning: meaning)
            digest = StableIdentity.digest([headword, meaning])
        }
        let scalars = [text.prompt, text.explanation, text.choices?.joined() ?? "", text.recallAnswer ?? "", text.candidateHeadword ?? "", text.candidateMeaning ?? ""]
            .reduce(0) { $0 + $1.unicodeScalars.count }
        if scalars > policy.contextScalarLimit { return .failure(.contextBoundExceeded) }
        let id = StableIdentity.digest([
            StableIdentity.variantID(source: source, kind: kind, prompt: text.prompt),
            source.level, source.rubricVersion,
            StableIdentity.digest(source.grammarTargetIDs), StableIdentity.digest(source.vocabularySenseIDs),
            text.explanation, StableIdentity.digest(text.choices ?? []), text.recallAnswer ?? "",
            text.candidateHeadword ?? "", text.candidateMeaning ?? "", digest
        ])
        let choiceIndex = kind == .recognitionChoice ? payload.correctChoiceIndex : nil
        return .success(ValidatedVariant(
            id: id, source: source, kind: kind, text: text, correctChoiceIndex: choiceIndex,
            editorialLabel: payload.editorialLabel, answerDigest: digest, permittedFactualSourceIDs: payload.factualSourceIDs))
    }

    static func present(_ variant: ValidatedVariant, revealed: Bool, unavailable: Bool) -> PresentedActivity {
        let hideSupport = !revealed && (variant.kind == .recognitionChoice || variant.kind == .recallCloze
            || (variant.kind == .vocabularyCandidate && variant.source.cardID != nil))
        return PresentedActivity(
            variantID: variant.id, kind: variant.kind,
            prompt: unavailable ? nil : variant.text.prompt,
            explanation: hideSupport || unavailable ? nil : variant.text.explanation,
            choices: unavailable ? nil : (variant.kind == .recognitionChoice ? variant.text.choices : nil),
            answerRevealed: revealed, revealedAnswer: unavailable || !revealed ? nil : revealedAnswer(variant),
            editorialLabel: GeneratedPracticeSchema.generatedLabel, qualifiedEducatorReviewed: false,
            countsAsComparableAssessment: false, soundAssessed: false, textUnavailableAfterDeletion: unavailable,
            learning: variant.source.learning, rubricVersion: variant.source.rubricVersion,
            contentVersion: variant.source.contentVersion, schemaVersion: GeneratedPracticeSchema.version)
    }

    static func revealedAnswer(_ variant: ValidatedVariant) -> String? {
        switch variant.kind {
        case .recognitionChoice:
            guard let index = variant.correctChoiceIndex, let choices = variant.text.choices, choices.indices.contains(index) else { return nil }
            return choices[index]
        case .recallCloze: return variant.text.recallAnswer
        case .vocabularyCandidate: return variant.text.candidateHeadword
        case .guidedProduction, .situationExample: return nil
        }
    }

    private static func blockedKind(_ raw: String) -> GenerationRefusal? {
        switch raw {
        case "pronunciation", "pronunciationScoring": return .pronunciationAssessmentUnavailable
        case "video", "videoActivity": return .videoSourceUnavailable
        default: return nil
        }
    }

    private static func factualRefusal(_ ids: [String], rule: FactualSourceRule) -> GenerationRefusal? {
        let trimmed = ids.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        if trimmed.contains(where: \.isEmpty) { return .factualSourceRejected }
        switch rule {
        case .noFactualClaims:
            return trimmed.isEmpty ? nil : .factualSourceRejected
        case .reviewedMaterial(let allowed), .learnerNoteIDs(let allowed):
            return trimmed.allSatisfy(allowed.contains) ? nil : .factualSourceRejected
        }
    }

    private static func leaks(_ secret: String, in fields: [String]) -> Bool {
        let needle = secret.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !needle.isEmpty else { return false }
        return fields.contains { $0.range(of: needle, options: [.caseInsensitive, .diacriticInsensitive]) != nil }
    }

    private static func jsonInt(_ value: Any?) -> Int? {
        guard let number = value as? NSNumber else { return nil }
        if CFGetTypeID(number) == CFBooleanGetTypeID() { return nil }
        let decimal = number.decimalValue
        var input = decimal
        var rounded = Decimal()
        NSDecimalRound(&rounded, &input, 0, .plain)
        if rounded != decimal { return nil }
        return number.intValue
    }

    private struct Payload: Decodable {
        var schemaVersion: Int
        var objectiveID: String
        var contentVersion: String
        var level: String
        var templateID: String
        var rubricVersion: String
        var activityKind: String
        var variety: String
        var prompt: String
        var explanation: String
        var choices: [String]?
        var correctChoiceIndex: Int?
        var recallAnswer: String?
        var candidateHeadword: String?
        var candidateMeaning: String?
        var grammarTargetIDs: [String]
        var vocabularySenseIDs: [String]
        var cardID: String?
        var editorialLabel: String
        var factualSourceIDs: [String]
        var referenceAudioID: String?
        var mediaURL: String?
    }
}

struct GeneratedPracticeSession: Equatable, Sendable {
    var epoch: UUID? = nil
    var phase: RequestDisposition? = nil
    var source: PracticeSource? = nil
    var protectedAttempt: CurrentAttempt? = nil
    var schedule: ScheduleIdentity? = nil
    var familiarity: FamiliarityChoice? = nil
    var requestedKind: GeneratedActivityKind? = nil
    var retention: PrivateRetentionChoice = .notChosen
    var presented: PresentedActivity? = nil
    var qualifiedFallback: ReviewedFallback? = nil
    var personalPreviewBlocked = false
    var frozenVariant: FrozenPracticeAttempt? = nil
    var working: GeneratedPracticeRecord = .empty
    var committed: GeneratedPracticeRecord = .empty
    var requestID: UUID? = nil
    var requestEpoch: UUID? = nil
    var decisionRecord: String? = nil
    var envelope: GenerationRequestEnvelope? = nil
    var requests: [UUID: RequestDisposition] = [:]
    var consumedRequestID: UUID? = nil
    var lastRefusal: GenerationRefusal? = nil
    var commitFailed = false
    var automaticRetryCount = 0
    private(set) var validated: ValidatedVariant? = nil
    private var fallbackStore: ReviewedFallback? = nil
    private var requestSource: PracticeSource? = nil
    private var requestPolicy: GenerationPolicy? = nil

    static let unavailable = GeneratedPracticeSession()

    var hasUnsavedChanges: Bool { working != committed }

    mutating func bindEpoch(_ newEpoch: UUID?) {
        guard epoch != newEpoch else { return }
        let replacing = epoch != nil
        if replacing { self = Self() }
        epoch = newEpoch
        if replacing { lastRefusal = .staleEpoch }
    }

    mutating func prepare(attempt: CurrentAttempt, source: PracticeSource) -> GenerationRefusal? {
        if phase == .awaiting { return refuse(.requestInFlight) }
        guard attempt.objectiveID == source.objectiveID, attempt.cardID == source.cardID, attempt.senseID == source.senseID,
              attempt.contentVersion == source.contentVersion, attempt.rubricVersion == source.rubricVersion,
              attempt.schedule.cardID == source.cardID else { return refuse(.unsupportedObjective) }
        if let refusal = source.refusal() { return refuse(refusal) }
        if protectedAttempt?.id != attempt.id || self.source != source {
            presented = nil; validated = nil; frozenVariant = nil
            qualifiedFallback = nil; fallbackStore = nil; phase = nil
        }
        protectedAttempt = attempt
        schedule = attempt.schedule
        self.source = source
        lastRefusal = nil
        return nil
    }

    mutating func beginFresh(policy: GenerationPolicy?, connected: Bool, now: Date) -> GenerationRefusal? {
        let anchor = protectedAttempt
        let preservedSchedule = schedule
        defer { protectedAttempt = anchor; schedule = preservedSchedule }
        if phase == .awaiting { return refuse(.requestInFlight) }
        guard epoch != nil else { return refuse(.missingEpoch) }
        guard let familiarity else { return refuse(.familiarityNotChosen) }
        guard familiarity == .fresh else { return presentFamiliar(policy: policy, now: now) }
        guard let requestedKind else { return refuse(.activityKindNotChosen) }
        guard let policy else { return refuse(.missingPolicy) }
        if let refusal = policy.refusal() { return refuse(.policyRejected(refusal)) }
        guard let source else { return refuse(.malformed) }
        if let refusal = source.refusal() { return refuse(refusal) }
        guard policy.permittedObjectiveIDs.contains(source.objectiveID) else { return refuse(.unsupportedObjective) }
        guard policy.permittedTemplateIDs.contains(source.templateID), policy.permittedActivityKinds.contains(requestedKind) else {
            return refuse(.unsupportedActivity)
        }
        guard connected else { return failClosed(.offline, policy: policy, now: now) }
        guard policy.providerAccess.permitsLiveTransport else { return failClosed(.providerAccessNotGranted, policy: policy, now: now) }
        if !policy.regenerationPermitted && working.cache.presentable(source: source, policy: policy, now: now).contains(where: { $0.kind == requestedKind }) {
            return failClosed(.regenerationNotPermitted, policy: policy, now: now)
        }
        let id = UUID()
        requestID = id
        requestEpoch = epoch
        requestSource = source
        requestPolicy = policy
        decisionRecord = policy.decisionRecord
        phase = .awaiting
        requests[id] = .awaiting
        consumedRequestID = nil
        working.unresolvedRequestID = id
        envelope = GenerationRequestEnvelope(
            schemaVersion: policy.schemaVersion, requestID: id, objectiveID: source.objectiveID,
            contentVersion: source.contentVersion, level: source.level, templateID: source.templateID,
            rubricVersion: source.rubricVersion, activityKind: requestedKind, variety: source.variety,
            familiarity: .fresh, grammarTargetIDs: source.grammarTargetIDs, vocabularySenseIDs: source.vocabularySenseIDs,
            cardID: source.cardID, factualSourceIDs: factualIDs(policy), costCeilingRecord: policy.costCeilingRecord,
            contextScalarLimit: policy.contextScalarLimit)
        lastRefusal = nil
        return nil
    }

    mutating func presentFamiliar(policy: GenerationPolicy?, now: Date) -> GenerationRefusal? {
        if phase == .awaiting { return refuse(.requestInFlight) }
        let anchor = protectedAttempt
        let preservedSchedule = schedule
        defer { protectedAttempt = anchor; schedule = preservedSchedule }
        guard let policy else { return failClosed(.missingPolicy, policy: nil, now: now) }
        if let refusal = policy.refusal() { return failClosed(.policyRejected(refusal), policy: policy, now: now) }
        guard let source else { return failClosed(.malformed, policy: policy, now: now) }
        guard let requestedKind else { return refuse(.activityKindNotChosen) }
        if let match = working.cache.presentable(source: source, policy: policy, now: now).last(where: { $0.kind == requestedKind }),
           let text = match.text, !match.privatePayloadDeleted {
            let variant = ValidatedVariant(
                id: match.id, source: source, kind: match.kind, text: text, correctChoiceIndex: match.correctChoiceIndex,
                editorialLabel: match.editorialLabel, answerDigest: match.answerDigest, permittedFactualSourceIDs: [])
            validated = variant
            presented = GeneratedVariantValidator.present(variant, revealed: false, unavailable: false)
            if let existing = working.frozenAttempts.last(where: { $0.variantID == variant.id }) {
                frozenVariant = existing
            } else {
                let frozen = freeze(variant, policy: policy, now: now)
                working.frozenAttempts.append(frozen)
                frozenVariant = frozen
            }
            qualifiedFallback = nil
            personalPreviewBlocked = false
            phase = .succeeded
            lastRefusal = nil
            return nil
        }
        return failClosed(.cacheIncompatible, policy: policy, now: now)
    }

    mutating func cancelRequest() -> GenerationRefusal {
        guard let requestID, requests[requestID] == .awaiting else { return refuse(.lateResult) }
        requests[requestID] = .cancelled
        phase = .cancelled
        working.unresolvedRequestID = nil
        consumedRequestID = requestID
        lastRefusal = .cancelled
        return .cancelled
    }

    mutating func noteRestart() -> GenerationRefusal? {
        guard let id = committed.unresolvedRequestID ?? working.unresolvedRequestID else { return nil }
        requests[id] = .unknownOutcome
        phase = .unknownOutcome
        working.unresolvedRequestID = nil
        requestID = id
        consumedRequestID = id
        lastRefusal = .unknownOutcome
        return .unknownOutcome
    }

    mutating func receive(data: Data, policy: GenerationPolicy?, requestID incoming: UUID, now: Date) -> GenerationRefusal? {
        let anchor = protectedAttempt
        let preservedSchedule = schedule
        let preservedFrozen = working.frozenAttempts
        let preservedCache = working.cache
        defer { protectedAttempt = anchor; schedule = preservedSchedule }
        switch requests[incoming] {
        case .awaiting: break
        case .succeeded, .failed: return refuse(.duplicateResult)
        case .cancelled, .unknownOutcome, nil: return refuse(.lateResult)
        }
        guard incoming == requestID, phase == .awaiting else { return refuse(.lateResult) }
        guard let requestEpoch, requestEpoch == epoch else { return settle(.staleEpoch, data: data, policy: policy, now: now, cache: preservedCache, frozen: preservedFrozen) }
        guard let policy, policy == requestPolicy else {
            return settle(.missingPolicy, data: data, policy: policy, now: now, cache: preservedCache, frozen: preservedFrozen)
        }
        guard let source, source == requestSource else { return settle(.incompatibleVersion, data: data, policy: policy, now: now, cache: preservedCache, frozen: preservedFrozen) }
        switch GeneratedVariantValidator.validate(data: data, policy: policy, source: source) {
        case .failure(let refusal):
            return settle(refusal, data: data, policy: policy, now: now, cache: preservedCache, frozen: preservedFrozen)
        case .success(let variant):
            guard variant.kind == envelope?.activityKind else {
                return settle(.unsupportedActivity, data: data, policy: policy, now: now, cache: preservedCache, frozen: preservedFrozen)
            }
            if working.cache.deletedVariantIDs.contains(variant.id) {
                validated = nil
                presented = GeneratedVariantValidator.present(variant, revealed: false, unavailable: true)
                working.cache = preservedCache
                working.frozenAttempts = preservedFrozen
                frozenVariant = preservedFrozen.last
                requests[incoming] = .failed
                phase = .failed
                working.unresolvedRequestID = nil
                lastRefusal = nil
                return nil
            }
            validated = variant
            presented = GeneratedVariantValidator.present(variant, revealed: false, unavailable: false)
            let frozen = freeze(variant, policy: policy, now: now)
            frozenVariant = frozen
            if let previous = working.frozenAttempts.last, previous.variantID != frozen.variantID {
                // Previous frozen wording stays in history and is not rewritten.
            }
            if !working.frozenAttempts.contains(where: { $0.id == frozen.id }) {
                working.frozenAttempts.append(frozen)
            }
            qualifiedFallback = nil
            personalPreviewBlocked = false
            requests[incoming] = .succeeded
            phase = .succeeded
            working.unresolvedRequestID = nil
            lastRefusal = nil
            return nil
        }
    }

    mutating func reveal() -> GenerationRefusal? {
        guard var shown = presented, let validated else { return refuse(.malformed) }
        guard !shown.textUnavailableAfterDeletion else { return refuse(.lateResult) }
        shown.answerRevealed = true
        shown.explanation = validated.text.explanation
        shown.revealedAnswer = GeneratedVariantValidator.revealedAnswer(validated)
        presented = shown
        return nil
    }

    mutating func applyRetention(_ choice: PrivateRetentionChoice, policy: GenerationPolicy?, now: Date) -> GenerationRefusal? {
        retention = choice
        guard choice != .notChosen else { return refuse(.retentionNotChosen) }
        guard let policy, let validated else { return refuse(.retentionNotChosen) }
        if let refusal = policy.refusal() { return refuse(.policyRejected(refusal)) }
        if choice == .declined {
            deletePrivateVariant(variantID: validated.id)
            lastRefusal = nil
            return nil
        }
        switch working.cache.admit(validated, policy: policy, retention: choice, protectedVariantIDs: protectedIDs, now: now) {
        case .failure(let refusal): return refuse(refusal)
        case .success: break
        }
        frozenVariant = freeze(validated, policy: policy, now: now)
        if let frozenVariant {
            if let index = working.frozenAttempts.firstIndex(where: { $0.variantID == frozenVariant.variantID }) {
                let existingID = working.frozenAttempts[index].id
                var replaced = frozenVariant
                replaced.id = existingID
                replaced.frozenAt = working.frozenAttempts[index].frozenAt
                working.frozenAttempts[index] = replaced
                self.frozenVariant = replaced
            }
        }
        lastRefusal = nil
        return nil
    }

    mutating func deletePrivateVariant(variantID: String) {
        working.cache.deletePrivatePayload(variantID: variantID)
        for index in working.frozenAttempts.indices where working.frozenAttempts[index].variantID == variantID {
            working.frozenAttempts[index].text = nil
            working.frozenAttempts[index].correctChoiceIndex = nil
            working.frozenAttempts[index].retention = .declined
        }
        if frozenVariant?.variantID == variantID {
            frozenVariant?.text = nil
            frozenVariant?.correctChoiceIndex = nil
            frozenVariant?.retention = .declined
        }
        if presented?.variantID == variantID {
            presented?.prompt = nil
            presented?.explanation = nil
            presented?.choices = nil
            presented?.revealedAnswer = nil
            presented?.textUnavailableAfterDeletion = true
        }
        validated = nil
    }

    mutating func stageReport(issue: ActivityReportIssue, policy: GenerationPolicy?, now: Date) -> Result<IncorrectActivityReport, GenerationRefusal> {
        guard let policy else { return .failure(refuse(.missingPolicy)) }
        if let refusal = policy.refusal() { return .failure(refuse(.policyRejected(refusal))) }
        guard let subject = reportSubject else { return .failure(refuse(.malformed)) }
        switch IncorrectActivityReports.stage(issue: issue, subject: subject, existing: working.reports, policy: policy, now: now) {
        case .failure(let refusal): return .failure(refuse(refusal))
        case .success(let report):
            if !working.reports.contains(where: { $0.id == report.id }) { working.reports.append(report) }
            lastRefusal = nil
            return .success(report)
        }
    }

    mutating func deleteReport(id: UUID) -> GenerationRefusal? {
        guard let index = working.reports.firstIndex(where: { $0.id == id }) else { return refuse(.malformed) }
        working.reports[index].status = .deleted
        return nil
    }

    mutating func expire(now: Date) {
        working.cache.entries.removeAll { now >= $0.expiresAt }
        working.reports = IncorrectActivityReports.expire(working.reports, now: now)
    }

    mutating func noteSupersedingVariant(_ variantID: String, reportID: UUID) -> GenerationRefusal? {
        let frozenBefore = working.frozenAttempts
        guard let updated = IncorrectActivityReports.supersede(working.reports, reportID: reportID, variantID: variantID) else {
            return refuse(.malformed)
        }
        working.reports = updated
        working.frozenAttempts = frozenBefore
        return nil
    }

    @discardableResult
    mutating func commit(expectedEpoch: UUID?, writeSucceeds: Bool) -> GenerationRefusal? {
        guard let epoch else { commitFailed = true; return refuse(.missingEpoch) }
        guard expectedEpoch == epoch else { commitFailed = true; return refuse(.staleEpoch) }
        guard writeSucceeds else { commitFailed = true; return refuse(.storageFailure) }
        for index in working.reports.indices where working.reports[index].status == .pendingSave {
            working.reports[index].status = .recordedLocally
        }
        working.reports.removeAll { $0.status == .deleted || $0.status == .retentionExpired }
        working.learnerEpoch = epoch
        committed = working
        commitFailed = false
        lastRefusal = nil
        return nil
    }

    /// Validate and prepare the exact committed value before invoking the storage boundary.
    @discardableResult
    mutating func persistChanges(expectedEpoch: UUID?, using write: ((GeneratedPracticeRecord) -> Bool)?) -> Bool {
        var candidate = self
        if let refusal = candidate.commit(expectedEpoch: expectedEpoch, writeSucceeds: true) {
            commitFailed = true; lastRefusal = refusal; return false
        }
        guard let write, write(candidate.committed) else {
            commitFailed = true; lastRefusal = .storageFailure; return false
        }
        self = candidate
        return true
    }

    func enrollVocabulary() -> GenerationRefusal { .enrollmentBlocked }

    mutating func rejectAutomaticRetry() -> GenerationRefusal {
        automaticRetryCount = 0
        return refuse(.automaticRetryBlocked)
    }

    func restored() -> GeneratedPracticeSession {
        var session = GeneratedPracticeSession()
        session.epoch = epoch
        session.committed = committed
        session.working = committed
        session.protectedAttempt = protectedAttempt
        session.schedule = protectedAttempt?.schedule
        session.source = source
        if committed.unresolvedRequestID != nil { _ = session.noteRestart() }
        session.frozenVariant = session.working.frozenAttempts.last
        if let frozen = session.frozenVariant, let text = frozen.text, let source = frozen.sourceSnapshot,
           frozen.learning == source.learning, frozen.templateID == source.templateID,
           frozen.contentVersion == source.contentVersion, frozen.rubricVersion == source.rubricVersion,
           frozen.schemaVersion == GeneratedPracticeSchema.version {
            session.source = source
            session.schedule = frozen.schedule
            let variant = ValidatedVariant(
                id: frozen.variantID, source: source, kind: frozen.kind, text: text, correctChoiceIndex: frozen.correctChoiceIndex,
                editorialLabel: GeneratedPracticeSchema.generatedLabel, answerDigest: frozen.answerDigest, permittedFactualSourceIDs: [])
            session.validated = variant
            session.presented = GeneratedVariantValidator.present(variant, revealed: false, unavailable: frozen.text == nil)
        } else if session.frozenVariant?.text == nil, session.frozenVariant != nil {
            session.presented = nil
        }
        return session
    }

    static func recover(_ record: GeneratedPracticeRecord, epoch: UUID) -> GeneratedPracticeSession {
        guard record.schemaVersion == GeneratedPracticeSchema.version, record.learnerEpoch == epoch else {
            var refused = Self(); refused.bindEpoch(epoch); refused.lastRefusal = .staleEpoch; return refused
        }
        var saved = Self()
        saved.epoch = epoch; saved.working = record; saved.committed = record
        return saved.restored()
    }

    func transportAllowed(for incoming: UUID) -> Bool {
        phase == .awaiting && requestID == incoming && consumedRequestID != incoming && requests[incoming] == .awaiting
    }

    mutating func consumeTransportAttempt(_ incoming: UUID) -> Bool {
        guard transportAllowed(for: incoming) else { return false }
        consumedRequestID = incoming
        return true
    }

    func durableRecord() -> GeneratedPracticeRecord {
        var record = working
        record.learnerEpoch = epoch
        return record
    }

    var reportSubject: ActivityReportSubject? {
        if let presented {
            return ActivityReportSubject(variantID: presented.variantID, schemaVersion: presented.schemaVersion,
                                          contentVersion: presented.contentVersion, objectiveID: presented.learning.objectiveID,
                                          templateID: source?.templateID ?? "", rubricVersion: presented.rubricVersion)
        }
        if let qualifiedFallback, qualifiedFallback.qualifiedRecord != nil {
            return ActivityReportSubject(variantID: qualifiedFallback.activityID, schemaVersion: GeneratedPracticeSchema.version,
                                          contentVersion: qualifiedFallback.contentVersion, objectiveID: qualifiedFallback.objectiveID,
                                          templateID: source?.templateID ?? "", rubricVersion: qualifiedFallback.rubricVersion)
        }
        if let protectedAttempt, let source {
            return ActivityReportSubject(variantID: protectedAttempt.id.uuidString, schemaVersion: GeneratedPracticeSchema.version,
                                          contentVersion: protectedAttempt.contentVersion, objectiveID: protectedAttempt.objectiveID,
                                          templateID: source.templateID, rubricVersion: protectedAttempt.rubricVersion)
        }
        return nil
    }

    private var protectedIDs: Set<String> { Set(working.frozenAttempts.map(\.variantID)) }

    private mutating func failClosed(_ refusal: GenerationRefusal, policy: GenerationPolicy?, now: Date) -> GenerationRefusal {
        _ = (policy, now)
        qualifiedFallback = nil
        personalPreviewBlocked = false
        if fallbackStore?.isPersonalUsePreview == true && fallbackStore?.qualifiedRecord == nil {
            personalPreviewBlocked = true
            phase = .failed
            lastRefusal = .personalUsePreviewIsNotQualifiedReview
            return .personalUsePreviewIsNotQualifiedReview
        }
        if let fallback = fallbackStore, fallback.qualifiedRecord != nil,
           fallback.objectiveID == source?.objectiveID, fallback.contentVersion == source?.contentVersion,
           fallback.rubricVersion == source?.rubricVersion, fallback.level == source?.level {
            qualifiedFallback = fallback
        }
        phase = .failed
        lastRefusal = refusal
        return refusal
    }

    mutating func offer(fallback: ReviewedFallback?) {
        fallbackStore = fallback
    }

    private mutating func settle(_ refusal: GenerationRefusal, data: Data, policy: GenerationPolicy?, now: Date, cache: VariantCache, frozen: [FrozenPracticeAttempt]) -> GenerationRefusal {
        _ = data
        working.cache = cache
        working.frozenAttempts = frozen
        frozenVariant = frozen.last
        if let requestID { requests[requestID] = .failed }
        working.unresolvedRequestID = nil
        return failClosed(refusal, policy: policy, now: now)
    }

    private func freeze(_ variant: ValidatedVariant, policy: GenerationPolicy, now: Date) -> FrozenPracticeAttempt {
        let keep = retention == .optedIn && !working.cache.deletedVariantIDs.contains(variant.id)
        return FrozenPracticeAttempt(
            id: UUID(), variantID: variant.id, learning: variant.source.learning, templateID: variant.source.templateID,
            schemaVersion: policy.schemaVersion, contentVersion: variant.source.contentVersion, level: variant.source.level,
            rubricVersion: variant.source.rubricVersion, kind: variant.kind, correctChoiceIndex: variant.correctChoiceIndex,
            text: keep ? variant.text : nil,
            retention: keep ? .optedIn : retention, schedule: schedule ?? ScheduleIdentity(cardID: variant.source.cardID, dueAt: nil, inReview: false),
            countsAsComparableAssessment: false, qualifiedEducatorReviewed: false, answerDigest: variant.answerDigest, frozenAt: now,
            sourceSnapshot: variant.source)
    }

    private func factualIDs(_ policy: GenerationPolicy) -> [String] {
        switch policy.factualSource {
        case .noFactualClaims: []
        case .reviewedMaterial(let ids), .learnerNoteIDs(let ids): ids
        }
    }

    @discardableResult
    private mutating func refuse(_ refusal: GenerationRefusal) -> GenerationRefusal {
        lastRefusal = refusal
        return refusal
    }
}
