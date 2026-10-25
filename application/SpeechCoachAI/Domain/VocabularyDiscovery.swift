import Foundation

/// Personal-topic discovery and a stable Word of the Day.
/// Generation uses the provisional SC-D015 schema and validator. This file does not define another payload.
/// Enrollment stays behind `GeneratedPracticeSession.enrollVocabulary()` and `ValidatedVariant.permitsVocabularyEnrollment`.
/// Word-of-day rotation, repeat, and daily reset stay unresolved. See `WordOfDayPolicy`.
enum LocalDayKey {
    /// Same year-month-day key as `PracticeRecommendation.localDay`. Callers pass the active calendar.
    static func from(_ date: Date, calendar: Calendar) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }
}

enum DiscoveryPath: String, CaseIterable, Identifiable, Equatable {
    case direct
    case subtopic

    var id: String { rawValue }

    var title: String {
        switch self {
        case .direct: "Direct topic"
        case .subtopic: "Narrow by subtopic"
        }
    }
}

struct DiscoveryChoices: Equatable {
    var path: DiscoveryPath?
    var topicTitle = ""
    var subtopic = ""
    var level = ""
    var countText = ""
    var purpose = ""
    var objectiveID = ""
    var templateID = ""
    var contentVersion = ""
    var rubricVersion = ""

    var count: Int? {
        let text = countText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let value = Int(text), text == String(value), value >= 1 else { return nil }
        return value
    }

    var isReady: Bool {
        guard path != nil, count != nil else { return false }
        let required = [topicTitle, level, purpose, objectiveID, templateID, contentVersion, rubricVersion]
        if required.contains(where: { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) { return false }
        if path == .subtopic && subtopic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return false }
        return true
    }
}

enum DiscoveryRefusal: Equatable, Error {
    case choicesIncomplete
    case subtopicRequired
    case topicRejected(CustomVocabularyError)
    case objectiveNotChosen
    case countNotRepresentedBySchema
    case generation(GenerationRefusal)
    case staleCallback
    case notSelected
    case revealBeforeSelect
    case existingTopicRequired
    case manualPracticeRemains

    var message: String {
        switch self {
        case .choicesIncomplete:
            "Choose a path, topic, level, count, purpose, and the approved activity. Nothing was requested."
        case .subtopicRequired:
            "Enter a subtopic, or switch to a direct topic. Nothing was requested."
        case .topicRejected:
            "That topic or word does not fit the existing topic limits. Your saved topics are unchanged."
        case .objectiveNotChosen:
            "Choose an approved objective. A topic name is not published as a new objective."
        case .countNotRepresentedBySchema:
            "The current suggestion schema can check one result. A larger count was not requested, and nothing was sent."
        case .generation(let refusal):
            refusal.message
        case .staleCallback:
            "A late or repeated suggestion was ignored. Your topics are unchanged."
        case .notSelected:
            "Select the suggestion you want before saving. Nothing was added."
        case .revealBeforeSelect:
            "Reveal the suggestion before selecting it. Nothing was added."
        case .existingTopicRequired:
            "Choose one of your existing topics. A suggestion does not create a topic by itself."
        case .manualPracticeRemains:
            "You can still write your own practice. Nothing was added."
        }
    }
}

struct VocabularyDiscoverySession: Equatable {
    var practice = GeneratedPracticeSession()
    var choices = DiscoveryChoices()
    var anchorID = UUID()
    var preview: ValidatedVariant?
    var presented: PresentedActivity?
    var draftLemma = ""
    var draftMeaning = ""
    var selectedVariantID: String?
    var consumedPreviewToken: UUID?
    private var requestedChoices: DiscoveryChoices?
    var manualPracticeRemains = true
    var lastRefusal: DiscoveryRefusal?

    var hidesCandidateUntilReveal: Bool { preview?.source.cardID != nil && presented?.answerRevealed != true }

    mutating func bindEpoch(_ newEpoch: UUID?) {
        guard practice.epoch != newEpoch else { return }
        let replacing = practice.epoch != nil
        self = Self()
        practice.bindEpoch(newEpoch)
        if replacing { lastRefusal = .generation(.staleEpoch) }
    }

    mutating func requestSuggestion(policy: GenerationPolicy?, connected: Bool, now: Date) -> DiscoveryRefusal? {
        manualPracticeRemains = true
        guard practice.phase != .awaiting else { return refuse(.generation(.requestInFlight)) }
        if let refusal = preparedRequest(policy: policy, now: now) { return refuse(refusal) }
        guard let count = choices.count, let policy else { return refuse(.choicesIncomplete) }
        if count != 1 || count > policy.maximumActivitiesPerRequest {
            return refuse(.countNotRepresentedBySchema)
        }
        practice.familiarity = .fresh
        practice.requestedKind = .vocabularyCandidate
        if let refusal = practice.beginFresh(policy: policy, connected: connected, now: now) {
            return refuse(.generation(refusal))
        }
        clearPreview()
        requestedChoices = choices
        consumedPreviewToken = nil
        lastRefusal = nil
        return nil
    }

    /// Only the request state machine may accept external bytes. Rendering never validates a second payload.
    private mutating func showPreview(_ variant: ValidatedVariant) {
        preview = variant
        presented = GeneratedVariantValidator.present(variant, revealed: false, unavailable: false)
        selectedVariantID = nil
        draftLemma = variant.source.cardID == nil ? variant.text.candidateHeadword ?? "" : ""
        draftMeaning = variant.source.cardID == nil ? variant.text.candidateMeaning ?? "" : ""
    }

    mutating func receivePreview(data: Data, policy: GenerationPolicy?, source: PracticeSource, token: UUID, now: Date) -> DiscoveryRefusal? {
        guard practice.phase == .awaiting, token == practice.requestID, consumedPreviewToken != token else {
            return refuse(.staleCallback)
        }
        guard requestedChoices == choices, source == practice.source else {
            _ = cancel()
            return refuse(.staleCallback)
        }
        consumedPreviewToken = token
        if let refusal = practice.receive(data: data, policy: policy, requestID: token, now: now) {
            clearPreview()
            return refuse(.generation(refusal))
        }
        guard practice.phase == .succeeded, let variant = practice.validated, variant.kind == .vocabularyCandidate else {
            clearPreview()
            return refuse(.generation(.unsupportedActivity))
        }
        showPreview(variant)
        lastRefusal = nil
        return nil
    }

    mutating func reveal() -> DiscoveryRefusal? {
        guard let preview else { return refuse(.notSelected) }
        presented = GeneratedVariantValidator.present(preview, revealed: true, unavailable: false)
        if draftLemma.isEmpty { draftLemma = preview.text.candidateHeadword ?? "" }
        if draftMeaning.isEmpty { draftMeaning = preview.text.candidateMeaning ?? "" }
        lastRefusal = nil
        return nil
    }

    mutating func edit(lemma: String, meaning: String) {
        guard preview != nil, !hidesCandidateUntilReveal else { return }
        draftLemma = lemma
        draftMeaning = meaning
        selectedVariantID = nil
    }

    mutating func select(now: Date) -> DiscoveryRefusal? {
        guard preview != nil else { return refuse(.notSelected) }
        if hidesCandidateUntilReveal { return refuse(.revealBeforeSelect) }
        if let problem = draftFits(now: now) { return refuse(.topicRejected(problem)) }
        selectedVariantID = preview?.id
        lastRefusal = nil
        return nil
    }

    mutating func cancel() -> DiscoveryRefusal {
        _ = practice.cancelRequest()
        requestedChoices = nil
        clearPreview()
        manualPracticeRemains = true
        return refuse(.generation(.cancelled))
    }

    /// Provisional SC-D015 gates. `enrollVocabulary()` currently always refuses, and a true enrollment flag still does not write.
    func blocksEnrollment() -> DiscoveryRefusal? {
        let refusal = practice.enrollVocabulary()
        if preview?.permitsVocabularyEnrollment == true && refusal != .enrollmentBlocked {
            return .generation(.enrollmentBlocked)
        }
        return .generation(refusal)
    }

    /// Does not call `addSense` or `enroll`. Collection and review writes stay on the existing manual topic APIs.
    mutating func save(into library: inout CustomVocabularyLibrary, topicID: UUID?, now: Date, addToReview: Bool) -> DiscoveryRefusal? {
        let unchanged = library
        _ = (topicID, now, addToReview)
        library = unchanged
        if let refusal = blocksEnrollment() { return refuse(refusal) }
        return refuse(.generation(.enrollmentBlocked))
    }

    func restored() -> VocabularyDiscoverySession {
        var copy = VocabularyDiscoverySession()
        copy.practice.bindEpoch(practice.epoch)
        copy.manualPracticeRemains = true
        return copy
    }

    private mutating func preparedRequest(policy: GenerationPolicy?, now: Date) -> DiscoveryRefusal? {
        guard choices.isReady else {
            if choices.path == .subtopic && choices.subtopic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !trimmed(choices.topicTitle).isEmpty {
                return .subtopicRequired
            }
            if trimmed(choices.objectiveID).isEmpty && choices.path != nil && choices.count != nil
                && !trimmed(choices.topicTitle).isEmpty && !trimmed(choices.level).isEmpty && !trimmed(choices.purpose).isEmpty
                && !trimmed(choices.templateID).isEmpty && !trimmed(choices.contentVersion).isEmpty && !trimmed(choices.rubricVersion).isEmpty
                && (choices.path != .subtopic || !trimmed(choices.subtopic).isEmpty) {
                return .objectiveNotChosen
            }
            return .choicesIncomplete
        }
        let title = choices.topicTitle
        let subtopic = choices.subtopic
        if case .failure(let error) = validatedTopic(title: title, subtopic: subtopic, now: now) {
            return .topicRejected(error)
        }
        if trimmed(choices.purpose).count > CustomVocabularyLibrary.noteLimit {
            return .topicRejected(.tooLong)
        }
        let objective = choices.objectiveID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !objective.isEmpty else { return .objectiveNotChosen }
        guard let policy else { return .generation(.missingPolicy) }
        if let refusal = policy.refusal() { return .generation(.policyRejected(refusal)) }
        let source = PracticeSource(
            objectiveID: objective, contentVersion: trimmed(choices.contentVersion), level: trimmed(choices.level),
            templateID: trimmed(choices.templateID), rubricVersion: trimmed(choices.rubricVersion),
            grammarTargetIDs: [], vocabularySenseIDs: [], senseID: nil, cardID: nil,
            variety: GeneratedPracticeSchema.variety)
        let attempt = CurrentAttempt(
            id: anchorID, prompt: "Vocabulary suggestion", objectiveID: source.objectiveID, senseID: nil, cardID: nil,
            contentVersion: source.contentVersion, rubricVersion: source.rubricVersion,
            schedule: ScheduleIdentity(cardID: nil, dueAt: nil, inReview: false))
        if let refusal = practice.prepare(attempt: attempt, source: source) { return .generation(refusal) }
        return nil
    }

    private func draftFits(now: Date) -> CustomVocabularyError? {
        var library = CustomVocabularyLibrary(topics: [], enrollments: [])
        guard let topic = try? library.createTopic(title: "Length check", subtopic: "", now: now) else { return .tooLong }
        do {
            _ = try library.addSense(topicID: topic.id, lemma: draftLemma, note: draftMeaning, now: now)
            return nil
        } catch let error as CustomVocabularyError {
            return error
        } catch {
            return .tooLong
        }
    }

    private func validatedTopic(title: String, subtopic: String, now: Date) -> Result<CustomVocabularyTopic, CustomVocabularyError> {
        var library = CustomVocabularyLibrary(topics: [], enrollments: [])
        do { return .success(try library.createTopic(title: title, subtopic: subtopic, now: now)) }
        catch let error as CustomVocabularyError { return .failure(error) }
        catch { return .failure(.tooLong) }
    }

    private func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private mutating func clearPreview() {
        preview = nil
        presented = nil
        draftLemma = ""
        draftMeaning = ""
        selectedVariantID = nil
    }

    @discardableResult
    private mutating func refuse(_ refusal: DiscoveryRefusal) -> DiscoveryRefusal {
        lastRefusal = refusal
        return refusal
    }
}

enum WordOfDayRepeat: Equatable {
    /// No adopted rotation, repeat interval, or daily reset exists.
    case unresolved
}

struct WordOfDayPolicy: Equatable {
    static let unapprovedProposalRecord = "sc-d016-word-of-day-proposal-2026-10-24"

    var decisionRecord: String
    var ownerDecisionAccepted: Bool
    var repeatRule: WordOfDayRepeat

    /// Every supplied record stays unresolved until an owner adopts the repeat rule.
    func refusal() -> WordOfDayRefusal {
        _ = decisionRecord
        _ = ownerDecisionAccepted
        _ = repeatRule
        return .selectionPolicyUnresolved
    }
}

enum WordOfDayRefusal: Equatable, Error {
    case selectionPolicyUnresolved
    case ineligibleSense
    case localDayMissing
    case nothingChosen
    case notThisLocalDay
    case contentUnavailable
    case enrollmentBlocked
    case missingEpoch
    case staleEpoch
    case storageFailure
    case alreadyPinned

    var message: String {
        switch self {
        case .selectionPolicyUnresolved:
            "Automatic selection, repeat, and a daily reset are not approved. Nothing was chosen, added, or credited."
        case .ineligibleSense:
            "This sense needs a reviewed record and a meaningful example. Nothing was substituted."
        case .localDayMissing:
            "Today's local day is unavailable. Nothing was chosen."
        case .nothingChosen:
            "No word is chosen for this local day."
        case .notThisLocalDay:
            "The saved word belongs to another local day. It was not replaced."
        case .contentUnavailable:
            "The saved word is not in the available reviewed set. Nothing was substituted."
        case .enrollmentBlocked:
            "A suggestion is not added to your words."
        case .missingEpoch, .staleEpoch:
            "This learner record cannot accept that save. Nothing from an older record was written."
        case .alreadyPinned:
            "The pinned word is unchanged. Daily selection rules are not available."
        case .storageFailure:
            "The last save failed. The last saved copy is unchanged."
        }
    }
}

struct DailySense: Equatable, Codable, Sendable {
    var itemID: String
    var senseID: String
    var lemma: String
    var example: String
    var meaning: String?
    var qualifiedRecord: String
    var personalUsePreview: Bool
    var generatedUnreviewed: Bool
}

enum DailySenseEligibility {
    static func allows(_ sense: DailySense) -> Bool {
        let example = sense.example.trimmingCharacters(in: .whitespacesAndNewlines)
        let lemma = sense.lemma.trimmingCharacters(in: .whitespacesAndNewlines)
        let record = sense.qualifiedRecord.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sense.itemID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !sense.senseID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !lemma.isEmpty, !example.isEmpty else { return false }
        guard !sense.personalUsePreview, !sense.generatedUnreviewed else { return false }
        guard !record.isEmpty,
              record != WordOfDayPolicy.unapprovedProposalRecord,
              record != GenerationPolicy.unapprovedProposalRecord else { return false }
        return true
    }
}

struct ShownDailyWord: Equatable, Sendable {
    var localDay: String
    var itemID: String
    var senseID: String
    var lemma: String
    var example: String
    var meaning: String?
    var qualifiedRecord: String
}

extension ShownDailyWord: Codable {
    private enum CodingKeys: String, CodingKey {
        case localDay, itemID, senseID, lemma, example, meaning, qualifiedRecord, enrolled, creditGranted
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        localDay = try container.decode(String.self, forKey: .localDay)
        itemID = try container.decode(String.self, forKey: .itemID)
        senseID = try container.decode(String.self, forKey: .senseID)
        lemma = try container.decode(String.self, forKey: .lemma)
        example = try container.decode(String.self, forKey: .example)
        meaning = try container.decodeIfPresent(String.self, forKey: .meaning)
        qualifiedRecord = try container.decode(String.self, forKey: .qualifiedRecord)
        if try container.decodeIfPresent(Bool.self, forKey: .enrolled) == true {
            throw DecodingError.dataCorruptedError(forKey: .enrolled, in: container, debugDescription: "A daily word cannot enroll itself.")
        }
        if try container.decodeIfPresent(Bool.self, forKey: .creditGranted) == true {
            throw DecodingError.dataCorruptedError(forKey: .creditGranted, in: container, debugDescription: "A daily word cannot grant credit.")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(localDay, forKey: .localDay)
        try container.encode(itemID, forKey: .itemID)
        try container.encode(senseID, forKey: .senseID)
        try container.encode(lemma, forKey: .lemma)
        try container.encode(example, forKey: .example)
        try container.encodeIfPresent(meaning, forKey: .meaning)
        try container.encode(qualifiedRecord, forKey: .qualifiedRecord)
        try container.encode(false, forKey: .enrolled)
        try container.encode(false, forKey: .creditGranted)
    }
}

struct WordOfDayPresentation: Equatable {
    var localDay: String
    var word: ShownDailyWord?
    var reason: WordOfDayRefusal?
    var meaningChanged: Bool
}

struct WordOfDayRecord: Codable, Equatable, Sendable {
    var shown: ShownDailyWord?
    var learnerEpoch: UUID? = nil
}

struct WordOfDaySession: Equatable {
    var epoch: UUID?
    var working: ShownDailyWord?
    var committed: ShownDailyWord?
    var creditCount = 0
    var lastRefusal: WordOfDayRefusal?

    mutating func bindEpoch(_ newEpoch: UUID?) {
        let replacing = epoch != nil && epoch != newEpoch
        epoch = newEpoch
        guard replacing else { return }
        working = nil
        committed = nil
        creditCount = 0
        lastRefusal = .staleEpoch
    }

    mutating func pin(_ sense: DailySense, localDay: String) -> WordOfDayRefusal? {
        guard epoch != nil else { return refuse(.missingEpoch) }
        guard !localDay.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return refuse(.localDayMissing) }
        guard DailySenseEligibility.allows(sense) else { return refuse(.ineligibleSense) }
        guard working == nil else { return refuse(.alreadyPinned) }
        working = ShownDailyWord(
            localDay: localDay, itemID: sense.itemID, senseID: sense.senseID, lemma: sense.lemma,
            example: sense.example, meaning: sense.meaning, qualifiedRecord: sense.qualifiedRecord)
        creditCount = 0
        lastRefusal = nil
        return nil
    }

    func presentation(localDay: String, catalog: [DailySense]) -> WordOfDayPresentation {
        guard let working else {
            return WordOfDayPresentation(localDay: localDay, word: nil, reason: .nothingChosen, meaningChanged: false)
        }
        guard working.localDay == localDay else {
            return WordOfDayPresentation(localDay: localDay, word: nil, reason: .notThisLocalDay, meaningChanged: false)
        }
        guard let match = catalog.first(where: { $0.itemID == working.itemID && $0.senseID == working.senseID }) else {
            return WordOfDayPresentation(localDay: localDay, word: nil, reason: .contentUnavailable, meaningChanged: false)
        }
        guard DailySenseEligibility.allows(match), match.qualifiedRecord == working.qualifiedRecord else {
            return WordOfDayPresentation(localDay: localDay, word: nil, reason: .ineligibleSense, meaningChanged: false)
        }
        let changed = match.lemma != working.lemma || match.example != working.example || match.meaning != working.meaning
        return WordOfDayPresentation(localDay: localDay, word: working, reason: nil, meaningChanged: changed)
    }

    mutating func selectAutomatically(from catalog: [DailySense], localDay: String, policy: WordOfDayPolicy?) -> WordOfDayRefusal {
        _ = catalog
        _ = localDay
        _ = policy?.refusal()
        creditCount = 0
        return refuse(.selectionPolicyUnresolved)
    }

    func saveToCollection() -> WordOfDayRefusal { .enrollmentBlocked }

    func addToReview() -> WordOfDayRefusal { .enrollmentBlocked }

    @discardableResult
    mutating func commit(expectedEpoch: UUID?, writeSucceeds: Bool) -> WordOfDayRefusal? {
        guard let epoch else { return refuse(.missingEpoch) }
        guard expectedEpoch == epoch else { return refuse(.staleEpoch) }
        guard writeSucceeds else { return refuse(.storageFailure) }
        committed = working
        creditCount = 0
        lastRefusal = nil
        return nil
    }

    func restored() -> WordOfDaySession {
        var copy = WordOfDaySession()
        copy.epoch = epoch
        copy.committed = committed
        copy.working = committed
        copy.creditCount = 0
        return copy
    }

    /// Prepare the exact durable value before asking storage to write. Failed writes keep the committed copy.
    mutating func persist(expectedEpoch: UUID?, using write: (WordOfDayRecord) -> Bool) -> WordOfDayRefusal? {
        guard let epoch else { return refuse(.missingEpoch) }
        guard expectedEpoch == epoch else { return refuse(.staleEpoch) }
        let candidate = WordOfDayRecord(shown: working, learnerEpoch: epoch)
        guard write(candidate) else { return refuse(.storageFailure) }
        committed = working
        lastRefusal = nil
        return nil
    }

    static func recover(_ record: WordOfDayRecord, epoch: UUID) -> WordOfDaySession {
        var session = Self()
        session.bindEpoch(epoch)
        guard record.learnerEpoch == epoch else { session.lastRefusal = .staleEpoch; return session }
        session.working = record.shown
        session.committed = record.shown
        return session
    }

    func durableRecord() -> WordOfDayRecord { WordOfDayRecord(shown: committed, learnerEpoch: epoch) }

    @discardableResult
    private mutating func refuse(_ refusal: WordOfDayRefusal) -> WordOfDayRefusal {
        lastRefusal = refusal
        return refusal
    }
}
