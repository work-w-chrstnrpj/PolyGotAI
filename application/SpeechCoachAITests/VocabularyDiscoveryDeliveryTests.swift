import Foundation
import Testing
@testable import SpeechCoachAI

@Test func localDayUsesThePracticeRecommendationKey() {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    let date = Date(timeIntervalSince1970: 1_761_359_400)
    #expect(LocalDayKey.from(date, calendar: calendar) == PracticeRecommendation.localDay(date, calendar: calendar))
}

@Test func manualTopicsStayUntouchedWhenSuggestionsFail() throws {
    let now = Date(timeIntervalSince1970: 1_700_000_000)
    var library = CustomVocabularyLibrary(topics: [], enrollments: [])
    let topic = try library.createTopic(title: "Weekend meals", subtopic: "Breakfast", now: now)
    let sense = try library.addSense(topicID: topic.id, lemma: "oatmeal", note: "A warm breakfast.", now: now)
    let saved = library
    var session = VocabularyDiscoverySession()
    session.bindEpoch(UUID())
    session.choices = readyChoices(count: "2")
    #expect(session.requestSuggestion(policy: nil, connected: false, now: now) == .generation(.missingPolicy))
    #expect(session.requestSuggestion(policy: proposalPolicy(), connected: true, now: now)?.message.contains("approved generation policy") == true)
    #expect(session.requestSuggestion(policy: fixturePolicy(), connected: false, now: now) == .countNotRepresentedBySchema)
    session.choices.countText = "1"
    #expect(session.requestSuggestion(policy: fixturePolicy(), connected: false, now: now) == .generation(.offline))
    #expect(session.practice.phase != .awaiting)
    #expect(session.practice.envelope == nil)
    #expect(session.requestSuggestion(policy: fixturePolicy(live: true), connected: true, now: now) == nil)
    let malformedToken = try #require(session.practice.requestID)
    #expect(session.receivePreview(data: Data("[]".utf8), policy: fixturePolicy(live: true), source: suggestionSource(), token: malformedToken, now: now) == .generation(.malformed))
    #expect(session.practice.phase == .failed)
    #expect(session.save(into: &library, topicID: topic.id, now: now, addToReview: true) == .generation(.enrollmentBlocked))
    #expect(session.save(into: &library, topicID: topic.id, now: now, addToReview: false) == .generation(.enrollmentBlocked))
    #expect(library == saved)
    #expect(library.topics.first?.senses.first?.id == sense.sense.id)
    #expect(session.manualPracticeRemains)
}

@Test func oneSuggestionCanBePreviewedAndStillDoesNotEnroll() throws {
    let now = Date(timeIntervalSince1970: 1_700_000_000)
    var library = try manualLibrary(now: now)
    let saved = library
    var session = VocabularyDiscoverySession()
    session.bindEpoch(UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"))
    session.choices = readyChoices(count: "1", purpose: "practice-fixture")
    let policy = fixturePolicy(live: true)
    #expect(session.requestSuggestion(policy: policy, connected: true, now: now) == nil)
    #expect(session.practice.phase == .awaiting)
    #expect(session.practice.automaticRetryCount == 0)
    let envelope = try #require(session.practice.envelope)
    let encoded = try JSONEncoder().encode(envelope)
    let json = String(decoding: encoded, as: UTF8.self)
    #expect(envelope.activityKind == .vocabularyCandidate)
    #expect(!json.contains("purpose"))
    #expect(!json.contains("practice-fixture"))
    let token = try #require(session.practice.requestID)
    #expect(session.receivePreview(data: wordPayload(), policy: policy, source: suggestionSource(), token: UUID(), now: now) == .staleCallback)
    #expect(session.receivePreview(data: wordPayload(), policy: policy, source: suggestionSource(), token: token, now: now) == nil)
    #expect(session.practice.phase == .succeeded)
    #expect(session.practice.working.unresolvedRequestID == nil)
    #expect(session.preview?.permitsVocabularyEnrollment == false)
    #expect(session.draftLemma == "synthetic-fixture")
    #expect(session.receivePreview(data: wordPayload(headword: "other-fixture"), policy: policy, source: suggestionSource(), token: token, now: now) == .staleCallback)
    #expect(session.draftLemma == "synthetic-fixture")
    session.edit(lemma: "synthetic-edited", meaning: "A changed fixture meaning.")
    #expect(session.selectedVariantID == nil)
    #expect(session.select(now: now) == nil)
    #expect(session.save(into: &library, topicID: library.topics[0].id, now: now, addToReview: false) == .generation(.enrollmentBlocked))
    #expect(session.save(into: &library, topicID: library.topics[0].id, now: now, addToReview: true) == .generation(.enrollmentBlocked))
    #expect(library == saved)
    #expect(session.cancel() == .generation(.cancelled))
    #expect(session.preview == nil)
    #expect(session.receivePreview(data: wordPayload(), policy: policy, source: suggestionSource(), token: token, now: now) == .staleCallback)
    let restarted = session.restored()
    #expect(restarted.preview == nil)
    #expect(restarted.manualPracticeRemains)
}

@Test func hiddenCardSuggestionsStayHiddenUntilReveal() throws {
    let now = Date(timeIntervalSince1970: 1_700_000_000)
    var library = try manualLibrary(now: now)
    let saved = library
    var session = VocabularyDiscoverySession()
    let source = suggestionSource(cardID: "c1", senseID: "s1", senses: ["s1"])
    // Seed an already-validated card preview to exercise reveal/edit separately from transport.
    let result = GeneratedVariantValidator.validate(data: wordPayload(cardID: "c1", senseID: "s1"), policy: fixturePolicy(), source: source)
    guard case .success(let variant) = result else { Issue.record("Synthetic variant rejected"); return }
    session.preview = variant
    session.presented = GeneratedVariantValidator.present(variant, revealed: false, unavailable: false)
    session.edit(lemma: "premature", meaning: "premature")
    #expect(session.draftLemma.isEmpty)
    #expect(session.draftLemma.isEmpty)
    #expect(session.presented?.revealedAnswer == nil)
    #expect(session.select(now: now) == .revealBeforeSelect)
    #expect(session.reveal() == nil)
    #expect(session.draftLemma == "synthetic-fixture")
    #expect(session.select(now: now) == nil)
    #expect(session.save(into: &library, topicID: nil, now: now, addToReview: true) == .generation(.enrollmentBlocked))
    #expect(library == saved)
}

@Test func subtopicPathAndUnapprovedPolicyDoNotStartARequest() {
    let now = Date(timeIntervalSince1970: 1_700_000_000)
    var session = VocabularyDiscoverySession()
    session.choices = readyChoices(count: "1")
    session.choices.path = .subtopic
    session.choices.subtopic = ""
    #expect(session.requestSuggestion(policy: fixturePolicy(live: true), connected: true, now: now) == .subtopicRequired)
    #expect(session.practice.phase != .awaiting)
    session.choices.subtopic = "Breakfast"
    session.choices.objectiveID = ""
    #expect(session.requestSuggestion(policy: fixturePolicy(live: true), connected: true, now: now) == .objectiveNotChosen)
}

@Test func wordOfDayStaysOnThePinnedSenseAcrossRestartTravelAndClockChanges() throws {
    var utc = Calendar(identifier: .gregorian)
    utc.timeZone = TimeZone(secondsFromGMT: 0)!
    var components = DateComponents()
    components.calendar = utc
    components.timeZone = TimeZone(secondsFromGMT: 0)
    components.year = 2026
    components.month = 10
    components.day = 24
    components.hour = 23
    let evening = try #require(components.date)
    var ahead = Calendar(identifier: .gregorian)
    ahead.timeZone = TimeZone(secondsFromGMT: 14 * 3600)!
    let utcDay = LocalDayKey.from(evening, calendar: utc)
    let aheadDay = LocalDayKey.from(evening, calendar: ahead)
    #expect(utcDay != aheadDay)
    let nextDay = LocalDayKey.from(evening.addingTimeInterval(2 * 3600), calendar: utc)
    #expect(nextDay != utcDay)

    let library = try manualLibrary(now: evening)
    let saved = library
    var session = WordOfDaySession()
    let epoch = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!
    session.bindEpoch(epoch)
    let sense = reviewedSense()
    #expect(session.pin(personalSense(), localDay: utcDay) == .ineligibleSense)
    #expect(session.pin(generatedSense(), localDay: utcDay) == .ineligibleSense)
    #expect(session.pin(emptyExampleSense(), localDay: utcDay) == .ineligibleSense)
    #expect(session.working == nil)
    #expect(session.pin(sense, localDay: utcDay) == nil)
    #expect(session.commit(expectedEpoch: epoch, writeSucceeds: false) == .storageFailure)
    #expect(session.restored().working == nil)
    #expect(session.commit(expectedEpoch: epoch, writeSucceeds: true) == nil)
    let restarted = session.restored()
    let shown = restarted.presentation(localDay: utcDay, catalog: [sense])
    #expect(shown.word?.senseID == sense.senseID)
    #expect(shown.word?.lemma == sense.lemma)
    #expect(shown.word?.meaning == sense.meaning)
    #expect(restarted.creditCount == 0)
    #expect(session.presentation(localDay: aheadDay, catalog: [sense]).reason == .notThisLocalDay)
    #expect(session.presentation(localDay: nextDay, catalog: [sense]).reason == .notThisLocalDay)
    #expect(session.working?.senseID == sense.senseID)
    var changed = sense
    changed.meaning = "A different fixture meaning."
    let changedPresentation = session.presentation(localDay: utcDay, catalog: [changed])
    #expect(changedPresentation.meaningChanged)
    #expect(changedPresentation.word?.meaning == sense.meaning)
    #expect(changedPresentation.word?.senseID == sense.senseID)
    #expect(session.presentation(localDay: utcDay, catalog: []).reason == .contentUnavailable)
    #expect(session.working?.senseID == sense.senseID)
    let before = session.working
    #expect(session.selectAutomatically(from: [sense, reviewedSense(itemID: "item-2", senseID: "sense-2")], localDay: nextDay, policy: WordOfDayPolicy(decisionRecord: WordOfDayPolicy.unapprovedProposalRecord, ownerDecisionAccepted: true, repeatRule: .unresolved)) == .selectionPolicyUnresolved)
    #expect(session.selectAutomatically(from: [sense], localDay: utcDay, policy: WordOfDayPolicy(decisionRecord: "fixture-day-record", ownerDecisionAccepted: true, repeatRule: .unresolved)) == .selectionPolicyUnresolved)
    #expect(session.working == before)
    #expect(session.creditCount == 0)
    #expect(session.saveToCollection() == .enrollmentBlocked)
    #expect(session.addToReview() == .enrollmentBlocked)
    #expect(library == saved)
    let encoded = try JSONEncoder().encode(session.durableRecord().shown)
    let roundTrip = try JSONDecoder().decode(ShownDailyWord.self, from: encoded)
    #expect(roundTrip.senseID == sense.senseID)
    #expect(try decodeDaily(enrolled: true) == nil)
}

@Test func discoveryResetAndRestartDropPrivateChoicesAndLateResponses() throws {
    let now = Date(timeIntervalSince1970: 1_700_000_000)
    var session = VocabularyDiscoverySession()
    let epoch = UUID()
    session.bindEpoch(epoch)
    session.choices = readyChoices(count: "1", purpose: "private purpose")
    #expect(session.requestSuggestion(policy: fixturePolicy(live: true), connected: true, now: now) == nil)
    let token = try #require(session.practice.requestID)
    let restarted = session.restored()
    #expect(restarted.choices == DiscoveryChoices())
    #expect(restarted.practice.epoch == epoch)
    #expect(restarted.practice.envelope == nil)
    #expect(restarted.preview == nil)
    session.bindEpoch(UUID())
    #expect(session.choices == DiscoveryChoices())
    #expect(session.practice.source == nil)
    #expect(session.practice.working.unresolvedRequestID == nil)
    #expect(session.receivePreview(data: wordPayload(), policy: fixturePolicy(live: true), source: suggestionSource(), token: token, now: now) == .staleCallback)
    #expect(session.preview == nil)
}

@Test func discoveryChangedChoicesOrSourceCannotPresentTheOldResponse() throws {
    let now = Date(timeIntervalSince1970: 1_700_000_000)
    for changeChoices in [true, false] {
        var session = VocabularyDiscoverySession()
        session.bindEpoch(UUID())
        session.choices = readyChoices(count: "1")
        #expect(session.requestSuggestion(policy: fixturePolicy(live: true), connected: true, now: now) == nil)
        let token = try #require(session.practice.requestID)
        var source = suggestionSource()
        if changeChoices { session.choices.topicTitle = "A different topic" }
        else { source.level = "B2" }
        #expect(session.receivePreview(data: wordPayload(), policy: fixturePolicy(live: true), source: source, token: token, now: now) == .staleCallback)
        #expect(session.preview == nil)
        #expect(session.practice.phase == .cancelled)
        #expect(session.practice.working.unresolvedRequestID == nil)
    }
}

@Test func discoveryPinsTheEntirePolicyAndCanRequestAgainAfterSuccess() throws {
    let now = Date(timeIntervalSince1970: 1_700_000_000)
    var session = VocabularyDiscoverySession()
    session.bindEpoch(UUID())
    session.choices = readyChoices(count: "1")
    let policy = fixturePolicy(live: true)
    #expect(session.requestSuggestion(policy: policy, connected: true, now: now) == nil)
    let token = try #require(session.practice.requestID)
    var changed = policy
    changed.maximumResponseBytes += 1
    #expect(session.receivePreview(data: wordPayload(), policy: changed, source: suggestionSource(), token: token, now: now) == .generation(.missingPolicy))
    #expect(session.preview == nil)
    #expect(session.practice.phase == .failed)
    #expect(session.requestSuggestion(policy: policy, connected: true, now: now) == nil)
    let nextToken = try #require(session.practice.requestID)
    #expect(session.receivePreview(data: wordPayload(), policy: policy, source: suggestionSource(), token: nextToken, now: now) == nil)
    #expect(session.practice.phase == .succeeded)
    #expect(session.requestSuggestion(policy: policy, connected: true, now: now) == nil)
    #expect(session.preview == nil)
    #expect(session.draftLemma.isEmpty)
    #expect(session.practice.phase == .awaiting)
}

@Test func dailyPinNeedsEpochAndNeverReplacesExistingIdentity() throws {
    var session = WordOfDaySession()
    let day = "2026-10-25"
    #expect(session.pin(reviewedSense(), localDay: day) == .missingEpoch)
    let epoch = UUID()
    session.bindEpoch(epoch)
    #expect(session.pin(reviewedSense(), localDay: day) == nil)
    let first = session.working
    #expect(session.pin(reviewedSense(itemID: "other", senseID: "other"), localDay: day) == .alreadyPinned)
    #expect(session.pin(reviewedSense(), localDay: "2026-10-26") == .alreadyPinned)
    #expect(session.working == first)
    #expect(session.commit(expectedEpoch: epoch, writeSucceeds: true) == nil)
    #expect(session.restored().working == first)
    var changedReview = reviewedSense()
    changedReview.qualifiedRecord = "another-review"
    #expect(session.presentation(localDay: day, catalog: [changedReview]).word == nil)
    session.bindEpoch(UUID())
    #expect(session.working == nil)
    #expect(session.committed == nil)
    #expect(session.creditCount == 0)
}

@Test func dailyWordUsesProtectedStorageAcrossReopenFailureAndReset() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("SC-D016-\(UUID())")
    defer { try? FileManager.default.removeItem(at: root) }
    let now = Date(timeIntervalSince1970: 1_700_000_000)
    var repository: LearnerRepository? = try LearnerRepository(root: root, now: { now }, protectedDataAvailable: { true })
    let epoch = try #require(try repository?.learningDataEpoch())
    #expect(try repository?.wordOfDayRecord() == nil)
    var session = WordOfDaySession()
    session.bindEpoch(epoch)
    #expect(session.pin(reviewedSense(), localDay: "2026-10-25") == nil)
    var offered: WordOfDayRecord?
    #expect(session.persist(expectedEpoch: epoch, using: { record in offered = record; return false }) == .storageFailure)
    #expect(session.committed == nil)
    #expect(offered?.learnerEpoch == epoch)
    let candidate = try #require(offered)
    repository?.beforeCommit = { throw LearnerStorageError.storageFailure }
    #expect(throws: LearnerStorageError.storageFailure) { try repository?.saveWordOfDayRecord(candidate, expectedEpoch: epoch, replacing: nil) }
    repository?.beforeCommit = nil
    #expect(try repository?.wordOfDayRecord() == nil)
    var writeFailure: Error?
    let failure = session.persist(expectedEpoch: epoch, using: { record in
        do { try repository?.saveWordOfDayRecord(record, expectedEpoch: epoch, replacing: nil); return true }
        catch { writeFailure = error; return false }
    })
    #expect(failure == nil)
    #expect(writeFailure == nil)
    repository?.close(); repository = nil
    let reopened = try LearnerRepository(root: root, now: { now }, protectedDataAvailable: { true })
    defer { reopened.close() }
    let saved = try #require(try reopened.wordOfDayRecord())
    #expect(saved == session.durableRecord())
    let recovered = WordOfDaySession.recover(saved, epoch: epoch)
    #expect(recovered.working == session.working)
    #expect(recovered.creditCount == 0)
    #expect(recovered.presentation(localDay: "2026-10-26", catalog: [reviewedSense()]).word == nil)
    #expect(WordOfDaySession.recover(saved, epoch: UUID()).working == nil)
    #expect(throws: LearnerStorageError.staleVersion) { try reopened.saveWordOfDayRecord(saved, expectedEpoch: epoch, replacing: nil) }
    var replacement = saved
    replacement.shown?.senseID = "different"
    #expect(throws: LearnerStorageError.invalidContent) { try reopened.saveWordOfDayRecord(replacement, expectedEpoch: epoch, replacing: saved) }
    try reopened.deleteAllLearningData()
    #expect(try reopened.wordOfDayRecord() == nil)
    #expect(throws: LearnerStorageError.staleVersion) { try reopened.saveWordOfDayRecord(saved, expectedEpoch: epoch, replacing: nil) }
}

private func readyChoices(count: String, purpose: String = "Examples") -> DiscoveryChoices {
    var choices = DiscoveryChoices()
    choices.path = .direct
    choices.topicTitle = "Weekend meals"
    choices.level = "A1"
    choices.countText = count
    choices.purpose = purpose
    choices.objectiveID = "OBJ-FIXTURE-1"
    choices.templateID = "situation-sentence"
    choices.contentVersion = "v1"
    choices.rubricVersion = "rubric-1"
    return choices
}

private func fixturePolicy(live: Bool = false) -> GenerationPolicy {
    GenerationPolicy(
        schemaVersion: GeneratedPracticeSchema.version, decisionRecord: "fixture-decision", ownerDecisionAccepted: true,
        permittedObjectiveIDs: ["OBJ-FIXTURE-1"], permittedTemplateIDs: ["situation-sentence"],
        permittedActivityKinds: [.vocabularyCandidate], contextScalarLimit: 500, maximumActivitiesPerRequest: 1,
        maximumValidatedCacheEntries: 2, cacheFreshnessSeconds: 120, maximumResponseBytes: 6000,
        regenerationPermitted: false, costCeilingRecord: "fixture-cost-record", factualSource: .noFactualClaims,
        reportRetention: ReportRetentionRule(retainForSeconds: 90, exportPermitted: false, exportEvidenceReference: "", localOnly: true),
        providerAccess: ProviderAccessRule(liveTransportPermitted: live, quotaProtectionVerified: live, evidenceReference: live ? "fixture-provider-record" : ""))
}

private func proposalPolicy() -> GenerationPolicy {
    var policy = fixturePolicy(live: true)
    policy.decisionRecord = GenerationPolicy.unapprovedProposalRecord
    return policy
}

private func suggestionSource(cardID: String? = nil, senseID: String? = nil, senses: [String] = []) -> PracticeSource {
    PracticeSource(
        objectiveID: "OBJ-FIXTURE-1", contentVersion: "v1", level: "A1", templateID: "situation-sentence",
        rubricVersion: "rubric-1", grammarTargetIDs: [], vocabularySenseIDs: senses, senseID: senseID, cardID: cardID,
        variety: "en-US")
}

private func wordPayload(headword: String = "synthetic-fixture", cardID: String? = nil, senseID: String? = nil) -> Data {
    let card: Any = cardID ?? NSNull()
    let senses = senseID.map { [$0] } ?? []
    let object: [String: Any] = [
        "schemaVersion": 1, "objectiveID": "OBJ-FIXTURE-1", "contentVersion": "v1", "level": "A1",
        "templateID": "situation-sentence", "rubricVersion": "rubric-1", "activityKind": "vocabularyCandidate",
        "variety": "en-US", "prompt": "A fixture situation for this objective.",
        "explanation": "The objective stays the same.", "choices": NSNull(), "correctChoiceIndex": NSNull(),
        "recallAnswer": NSNull(), "candidateHeadword": headword, "candidateMeaning": "A fixture meaning.",
        "grammarTargetIDs": [String](), "vocabularySenseIDs": senses, "cardID": card, "editorialLabel": "generated",
        "factualSourceIDs": [String](), "referenceAudioID": NSNull(), "mediaURL": NSNull()
    ]
    return try! JSONSerialization.data(withJSONObject: object)
}

private func manualLibrary(now: Date) throws -> CustomVocabularyLibrary {
    var library = CustomVocabularyLibrary(topics: [], enrollments: [])
    let topic = try library.createTopic(title: "Weekend meals", subtopic: "Breakfast", now: now)
    _ = try library.addSense(topicID: topic.id, lemma: "oatmeal", note: "A warm breakfast.", now: now)
    return library
}

private func reviewedSense(itemID: String = "item-1", senseID: String = "sense-1") -> DailySense {
    DailySense(itemID: itemID, senseID: senseID, lemma: "synthetic-fixture", example: "A synthetic example stays on this sense.", meaning: "A fixture meaning.", qualifiedRecord: "fixture-review-record", personalUsePreview: false, generatedUnreviewed: false)
}

private func personalSense() -> DailySense {
    var sense = reviewedSense()
    sense.personalUsePreview = true
    return sense
}

private func generatedSense() -> DailySense {
    var sense = reviewedSense()
    sense.generatedUnreviewed = true
    return sense
}

private func emptyExampleSense() -> DailySense {
    var sense = reviewedSense()
    sense.example = " "
    return sense
}

private func decodeDaily(enrolled: Bool) throws -> ShownDailyWord? {
    let object: [String: Any] = [
        "localDay": "2026-10-24", "itemID": "item-1", "senseID": "sense-1", "lemma": "synthetic-fixture",
        "example": "A synthetic example stays on this sense.", "meaning": "A fixture meaning.",
        "qualifiedRecord": "fixture-review-record", "enrolled": enrolled, "creditGranted": false
    ]
    let data = try JSONSerialization.data(withJSONObject: object)
    return try? JSONDecoder().decode(ShownDailyWord.self, from: data)
}
