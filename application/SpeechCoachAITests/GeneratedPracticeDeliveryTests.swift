import Foundation
import Testing
@testable import SpeechCoachAI

/// Fixture inputs below are not an approved generation policy.
struct GeneratedPracticeDeliveryTests {
    private let now = Date(timeIntervalSince1970: 1_700_000_000)
    private let epoch = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!

    @Test func missingPolicyAndUnapprovedProposalFailClosed() {
        #expect(GenerationPolicy.unapprovedProposalRecord == "sc-d015-policy-proposal-2026-10-24")
        #expect(makePolicy(record: GenerationPolicy.unapprovedProposalRecord).refusal() == .proposalIsNotApproval)
        #expect(makePolicy(accepted: false).refusal() == .ownerDecisionMissing)
        #expect(makePolicy(localOnly: false).refusal() == .remoteReportRejected)
        var session = prepared(epoch)
        #expect(session.beginFresh(policy: nil, connected: true, now: now) == .missingPolicy)
        #expect(session.protectedAttempt == attempt())
        #expect(GeneratedVariantValidator.validate(data: wire(), policy: nil, source: source()).refusal == .missingPolicy)
    }

    @Test func personalPreviewIsNotQualifiedFallbackAndReviewedFallbackStaysSeparate() {
        var preview = prepared(epoch, fallback: ReviewedFallback(
            activityID: "preview-1", objectiveID: "OBJ-FIXTURE-1", contentVersion: "v1", level: "A1",
            rubricVersion: "rubric-1", prompt: "Personal preview prompt.", status: .personalUsePreview(record: "owner-preview")))
        #expect(preview.beginFresh(policy: makePolicy(), connected: false, now: now) == .personalUsePreviewIsNotQualifiedReview)
        #expect(preview.qualifiedFallback == nil)
        #expect(preview.personalPreviewBlocked)
        #expect(preview.protectedAttempt == attempt())

        var reviewed = prepared(epoch, fallback: ReviewedFallback(
            activityID: "reviewed-1", objectiveID: "OBJ-FIXTURE-1", contentVersion: "v1", level: "A1",
            rubricVersion: "rubric-1", prompt: "Reviewed fixture prompt.", status: .qualifiedEducatorReviewed(record: "educator-record-fixture")))
        #expect(reviewed.beginFresh(policy: makePolicy(), connected: false, now: now) == .offline)
        #expect(reviewed.qualifiedFallback?.activityID == "reviewed-1")
        #expect(reviewed.presented == nil)
        #expect(reviewed.protectedAttempt == attempt())
    }

    @Test func malformedUntrustedAndUnsupportedResultsAreRejected() async {
        let approved = makePolicy(live: true, regenerate: true)
        let cases: [(Data, GenerationRefusal)] = [
            (Data("{".utf8), .malformed),
            (wire(["score": "9"]), .malformed),
            (wire(["objectiveID": "OBJ-OTHER"]), .unsupportedObjective),
            (wire(["schemaVersion": 2]), .incompatibleVersion),
            (wire(["contentVersion": "v9"]), .incompatibleVersion),
            (wire(["correctChoiceIndex": 9]), .invalidAnswer),
            (wire(["explanation": " "]), .ambiguous),
            (wire(["editorialLabel": "educator-reviewed"]), .mislabeledReview),
            (wire(["activityKind": "pronunciation"]), .pronunciationAssessmentUnavailable),
            (wire(["referenceAudioID": "audio-1"]), .pronunciationAssessmentUnavailable),
            (wire(["mediaURL": "https://example.invalid/watch"]), .videoSourceUnavailable),
            (wire(["factualSourceIDs": ["web"]]), .factualSourceRejected),
            (wire(["activityKind": "recallCloze", "choices": NSNull(), "correctChoiceIndex": NSNull(), "recallAnswer": "synthetic-target", "prompt": "Use synthetic-target here."]), .answerLeakedBeforeRecall)
        ]
        for item in cases {
            let result = await send(prepared(epoch), policy: approved, now: now, body: item.0)
            #expect(result.lastRefusal == item.1)
            #expect(result.protectedAttempt == attempt())
            #expect(result.presented == nil)
        }
        let bounded = await send(prepared(epoch), policy: makePolicy(live: true, regenerate: true, context: 40), now: now, body: wire(["prompt": String(repeating: "word ", count: 80)]))
        #expect(bounded.lastRefusal == .contextBoundExceeded)
        let oversized = await send(prepared(epoch), policy: makePolicy(live: true, regenerate: true, bytes: 32), now: now, body: wire())
        #expect(oversized.lastRefusal == .responseBoundExceeded)
    }

    @Test func validResultFreezesRubricHidesAnswerAndDoesNotRetry() async throws {
        let counter = Counter()
        let approved = makePolicy(live: true, regenerate: true)
        let accepted = await GeneratedPracticeClient().submit(prepared(epoch), policy: approved, connected: true, now: now, beforeSend: { _ in true }, send: { data in
            counter.add(data)
            return wire()
        })
        #expect(counter.count == 1)
        let body = try #require(counter.last)
        let object = try #require(try JSONSerialization.jsonObject(with: body) as? [String: Any])
        #expect(Set(object.keys).isDisjoint(with: GeneratedPracticeClient.forbiddenEnvelopeKeys))
        #expect(accepted.presented?.prompt == "Pick the sentence that stays on the objective.")
        #expect(accepted.presented?.revealedAnswer == nil)
        #expect(accepted.presented?.explanation == nil)
        #expect(accepted.presented?.qualifiedEducatorReviewed == false)
        #expect(accepted.presented?.countsAsComparableAssessment == false)
        #expect(accepted.presented?.soundAssessed == false)
        #expect(accepted.protectedAttempt == attempt())
        #expect(accepted.schedule == attempt().schedule)
        #expect(accepted.frozenVariant?.rubricVersion == "rubric-1")
        #expect(accepted.frozenVariant?.text == nil)
        #expect(accepted.enrollVocabulary() == .enrollmentBlocked)
        var revealed = accepted
        #expect(revealed.reveal() == nil)
        #expect(revealed.presented?.revealedAnswer == "synthetic alpha")
        #expect(revealed.receive(data: wire(), policy: approved, requestID: try #require(revealed.requestID), now: now) == .duplicateResult)
        #expect(revealed.working.frozenAttempts.count == 1)

        var recallSession = prepared(epoch)
        recallSession.requestedKind = .recallCloze
        let recall = await send(recallSession, policy: approved, now: now, body: wire([
            "activityKind": "recallCloze", "choices": NSNull(), "correctChoiceIndex": NSNull(),
            "recallAnswer": "synthetic-target", "prompt": "Complete the fixture sentence."
        ]))
        #expect(recall.presented?.revealedAnswer == nil)
        #expect(recall.presented?.prompt?.contains("synthetic-target") == false)
        #expect(recall.presented?.learning.cardID == "c1")
        #expect(recall.schedule == attempt().schedule)
        #expect(recall.presented?.variantID != accepted.presented?.variantID)
    }

    @Test func cancellationLateDuplicateAndRestartDoNotResend() async {
        let approved = makePolicy(live: true, regenerate: true)
        var cancelled = prepared(epoch)
        #expect(cancelled.beginFresh(policy: approved, connected: true, now: now) == nil)
        let request = cancelled.requestID
        #expect(cancelled.cancelRequest() == .cancelled)
        #expect(cancelled.receive(data: wire(), policy: approved, requestID: request!, now: now) == .lateResult)
        #expect(cancelled.presented == nil)
        #expect(cancelled.protectedAttempt == attempt())
        #expect(cancelled.rejectAutomaticRetry() == .automaticRetryBlocked)
        #expect(cancelled.automaticRetryCount == 0)

        let failedSend = Counter()
        let failed = await GeneratedPracticeClient().submit(prepared(epoch), policy: approved, connected: true, now: now, beforeSend: { _ in true }, send: { _ in
            failedSend.add(Data())
            throw GeneratedPracticeTransportError.failed
        })
        #expect(failedSend.count == 1)
        #expect(failed.protectedAttempt == attempt())

        let offlineSend = Counter()
        _ = await GeneratedPracticeClient().submit(prepared(epoch), policy: approved, connected: false, now: now, beforeSend: { _ in true }, send: { data in
            offlineSend.add(data)
            return data
        })
        #expect(offlineSend.count == 0)
        let unstored = Counter()
        let notSaved = await GeneratedPracticeClient().submit(prepared(epoch), policy: approved, connected: true, now: now, beforeSend: nil, send: { data in
            unstored.add(data)
            return data
        })
        #expect(unstored.count == 0)
        #expect(notSaved.lastRefusal == .storageFailure)

        var unknown = await GeneratedPracticeClient().submit(prepared(epoch), policy: approved, connected: true, now: now, beforeSend: { _ in true }, send: { _ in
            throw GeneratedPracticeTransportError.unknownOutcome
        })
        #expect(unknown.lastRefusal == .unknownOutcome)
        #expect(unknown.receive(data: wire(), policy: approved, requestID: unknown.requestID!, now: now) == .lateResult)

        var restarted = prepared(epoch)
        #expect(restarted.beginFresh(policy: approved, connected: true, now: now) == nil)
        #expect(restarted.commit(expectedEpoch: epoch, writeSucceeds: true) == nil)
        var restored = restarted.restored()
        #expect(restored.phase == .unknownOutcome)
        #expect(restored.receive(data: wire(), policy: approved, requestID: restarted.requestID!, now: now) == .lateResult)
    }

    @Test func cacheCompatibilityDeletionAndEpochStayInsideTheSuppliedPolicy() async {
        let narrow = makePolicy(live: true, regenerate: true, cacheEntries: 1)
        var session = prepared(epoch)
        session.retention = .optedIn
        var kept = await send(session, policy: narrow, now: now, body: wire())
        #expect(kept.applyRetention(.optedIn, policy: narrow, now: now) == nil)
        let savedPrompt = kept.working.frozenAttempts.last?.text?.prompt
        #expect(kept.commit(expectedEpoch: epoch, writeSucceeds: true) == nil)
        kept.source?.contentVersion = "v2"
        #expect(kept.presentFamiliar(policy: narrow, now: now) == .cacheIncompatible)
        #expect(kept.working.frozenAttempts.last?.text?.prompt == savedPrompt)
        #expect(kept.protectedAttempt == attempt())
        kept.source?.contentVersion = "v1"
        #expect(kept.presentFamiliar(policy: makePolicy(live: true, regenerate: true, cacheEntries: 1, freshness: 120), now: now.addingTimeInterval(120)) == .cacheIncompatible)
        #expect(kept.working.frozenAttempts.last?.text?.prompt == savedPrompt)

        var second = kept
        second.retention = .optedIn
        #expect(second.beginFresh(policy: narrow, connected: true, now: now) == nil)
        #expect(second.receive(data: wire(["prompt": "Pick another fixture sentence."]), policy: narrow, requestID: second.requestID!, now: now) == nil)
        #expect(second.applyRetention(.optedIn, policy: narrow, now: now) == .cacheBoundReached)
        #expect(second.working.frozenAttempts.count == 2)
        #expect(second.schedule == attempt().schedule)

        var deleted = kept
        let variantID = deleted.presented?.variantID ?? ""
        deleted.deletePrivateVariant(variantID: variantID)
        #expect(deleted.presented?.prompt == nil)
        #expect(deleted.commit(expectedEpoch: UUID(), writeSucceeds: true) == .staleEpoch)
        #expect(deleted.commit(expectedEpoch: epoch, writeSucceeds: false) == .storageFailure)
        #expect(deleted.restored().working.cache.entries.first?.text?.prompt == savedPrompt)
        #expect(deleted.commit(expectedEpoch: epoch, writeSucceeds: true) == nil)
        #expect(deleted.restored().working.cache.entries.first?.text == nil)
        deleted.phase = nil
        #expect(deleted.beginFresh(policy: makePolicy(live: true, regenerate: true), connected: true, now: now) == nil)
        #expect(deleted.receive(data: wire(), policy: makePolicy(live: true, regenerate: true), requestID: deleted.requestID!, now: now) == nil)
        #expect(deleted.presented?.prompt == nil)
        #expect(deleted.working.cache.deletedVariantIDs.contains(variantID))
    }

    @Test func reportsStayLocalAndDoNotChangeTheAttempt() async throws {
        let reported = await send(prepared(epoch), policy: makePolicy(live: true, regenerate: true), now: now, body: wire())
        var reporting = reported
        let staged = try #require(reporting.stageReport(issue: .invalidAnswer, policy: makePolicy(), now: now).value)
        #expect(!staged.learnerResponseIncluded && !staged.remoteSubmission && !staged.correctionPublished && !staged.transmitsOffDevice)
        let encoded = String(decoding: try JSONEncoder().encode(staged), as: UTF8.self)
        #expect(!encoded.contains(attempt().prompt))
        #expect(!encoded.contains("synthetic alpha"))
        #expect(reporting.stageReport(issue: .invalidAnswer, policy: makePolicy(), now: now).value?.id == staged.id)
        let frozen = reporting.working.frozenAttempts
        #expect(reporting.noteSupersedingVariant("variant-next", reportID: staged.id) == nil)
        #expect(reporting.working.reports.first?.variantID == staged.variantID)
        #expect(reporting.working.reports.first?.correctionPublished == false)
        #expect(reporting.working.frozenAttempts == frozen)
        #expect(reporting.protectedAttempt == attempt())
        #expect(IncorrectActivityReports.exportData(reporting.working.reports, policy: makePolicy()) == nil)
        #expect(reporting.deleteReport(id: staged.id) == nil)
        #expect(reporting.working.reports.first?.status == .deleted)
        #expect(reporting.protectedAttempt == attempt())

        var durable = reported
        _ = durable.stageReport(issue: .ambiguousPrompt, policy: makePolicy(), now: now)
        #expect(durable.commit(expectedEpoch: epoch, writeSucceeds: true) == nil)
        #expect(durable.committed.reports.first?.status == .recordedLocally)
        durable.expire(now: now.addingTimeInterval(90))
        #expect(durable.commit(expectedEpoch: epoch, writeSucceeds: false) == .storageFailure)
        #expect(durable.restored().working.reports.first?.status == .recordedLocally)
        let export = try #require(IncorrectActivityReports.exportData(durable.committed.reports, policy: makePolicy(export: true), now: now))
        let exportText = String(decoding: export, as: UTF8.self)
        #expect(!exportText.contains(attempt().prompt))
        let tampered = Data("{\"id\":\"AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE\",\"variantID\":\"v\",\"schemaVersion\":1,\"contentVersion\":\"v1\",\"objectiveID\":\"OBJ-FIXTURE-1\",\"templateID\":\"situation-sentence\",\"rubricVersion\":\"rubric-1\",\"issue\":\"other\",\"status\":\"recordedLocally\",\"recordedAt\":0,\"expiresAt\":1,\"learnerResponseIncluded\":true,\"remoteSubmission\":false,\"correctionPublished\":false,\"transmitsOffDevice\":false}".utf8)
        #expect(throws: DecodingError.self) { try JSONDecoder().decode(IncorrectActivityReport.self, from: tampered) }

        var variety = GeneratedPracticeSession()
        variety.bindEpoch(epoch)
        var foreign = source()
        foreign.variety = "en-GB"
        #expect(variety.prepare(attempt: attempt(), source: foreign) == .unsupportedVariety)
        var moved = reported
        moved.bindEpoch(UUID())
        #expect(moved.working.reports.isEmpty)
        #expect(moved.protectedAttempt == nil)
        #expect(moved.commit(expectedEpoch: epoch, writeSucceeds: true) == .staleEpoch)
    }
}

struct GeneratedPracticeRepairTests {
    private let date = Date(timeIntervalSince1970: 1_700_000_000)
    private let epoch = UUID()

    @Test func changingEpochClearsAllPrivateAndTaskContext() async {
        var session = await send(prepared(epoch), policy: makePolicy(live: true, regenerate: true), now: date, body: wire())
        session.offer(fallback: ReviewedFallback(activityID: "private", objectiveID: "OBJ-FIXTURE-1", contentVersion: "v1",
            level: "A1", rubricVersion: "rubric-1", prompt: "Synthetic old private wording", status: .qualifiedEducatorReviewed(record: "fixture")))
        session.bindEpoch(UUID())
        #expect(session.protectedAttempt == nil && session.source == nil && session.schedule == nil)
        #expect(session.presented == nil && session.frozenVariant == nil && session.envelope == nil)
        #expect(session.working == .empty && session.committed == .empty)
        #expect(session.reportSubject == nil)
        #expect(session.beginFresh(policy: makePolicy(), connected: false, now: date) == .familiarityNotChosen)
        #expect(session.qualifiedFallback == nil)
    }

    @Test func invalidPreparePreservesCurrentContextAndValidChangeClearsPresentation() async {
        var session = await send(prepared(epoch), policy: makePolicy(live: true, regenerate: true), now: date, body: wire())
        let before = session
        var wrong = source(); wrong.objectiveID = "wrong"
        #expect(session.prepare(attempt: attempt(), source: wrong) == .unsupportedObjective)
        #expect(session.source == before.source && session.presented == before.presented)
        var other = attempt(); other.id = UUID()
        #expect(session.prepare(attempt: other, source: source()) == nil)
        #expect(session.presented == nil && session.frozenVariant == nil)
    }

    @Test func requestPinsActivitySourceAndEntirePolicy() throws {
        let policy = makePolicy(live: true, regenerate: true)
        var wrongKind = prepared(epoch)
        #expect(wrongKind.beginFresh(policy: policy, connected: true, now: date) == nil)
        let data = wire(["activityKind": "situationExample", "choices": NSNull(), "correctChoiceIndex": NSNull()])
        #expect(wrongKind.receive(data: data, policy: policy, requestID: try #require(wrongKind.requestID), now: date) == .unsupportedActivity)
        var changedPolicy = prepared(epoch); _ = changedPolicy.beginFresh(policy: policy, connected: true, now: date)
        var changed = policy; changed.maximumResponseBytes += 1
        #expect(changedPolicy.receive(data: wire(), policy: changed, requestID: try #require(changedPolicy.requestID), now: date) == .missingPolicy)
        var changedSource = prepared(epoch); _ = changedSource.beginFresh(policy: policy, connected: true, now: date)
        changedSource.source?.grammarTargetIDs = ["other"]
        #expect(changedSource.receive(data: wire(["grammarTargetIDs": ["other"]]), policy: policy, requestID: try #require(changedSource.requestID), now: date) == .incompatibleVersion)
        var missingEpoch = GeneratedPracticeSession(); missingEpoch.familiarity = .fresh
        missingEpoch.requestedKind = .recognitionChoice; _ = missingEpoch.prepare(attempt: attempt(), source: source())
        #expect(missingEpoch.beginFresh(policy: policy, connected: true, now: date) == .missingEpoch)
    }

    @Test func cacheRejectsChangedPolicyAndTargetsAndContentIdentityIncludesChoices() throws {
        let policy = makePolicy(live: true, regenerate: true)
        let first = try #require(GeneratedVariantValidator.validate(data: wire(), policy: policy, source: source()).value)
        let alternate = try #require(GeneratedVariantValidator.validate(data: wire(["choices": ["synthetic alpha", "different distractor"]]), policy: policy, source: source()).value)
        #expect(first.id != alternate.id)
        var cache = VariantCache()
        _ = cache.admit(first, policy: policy, retention: .optedIn, protectedVariantIDs: [], now: date)
        #expect(cache.presentable(source: source(), policy: policy, now: date).count == 1)
        var changed = policy; changed.permittedObjectiveIDs = ["other"]
        #expect(cache.presentable(source: source(), policy: changed, now: date).isEmpty)
        changed = policy; changed.permittedTemplateIDs = ["other"]
        #expect(cache.presentable(source: source(), policy: changed, now: date).isEmpty)
        var changedSource = source(); changedSource.grammarTargetIDs = ["other"]
        #expect(cache.presentable(source: changedSource, policy: policy, now: date).isEmpty)
        #expect(StableIdentity.digest(["a", "b"]) != StableIdentity.digest(["a\u{ff}b"]))
    }

    @Test func loweredCacheLimitIsEnforcedWithoutMutatingProtectedHistory() throws {
        var cache = VariantCache()
        let broad = makePolicy(cacheEntries: 3)
        for index in 0..<3 {
            let variant = try #require(GeneratedVariantValidator.validate(data: wire(["prompt": "Synthetic prompt \(index)"]), policy: broad, source: source()).value)
            _ = cache.admit(variant, policy: broad, retention: .optedIn, protectedVariantIDs: [], now: date.addingTimeInterval(Double(index)))
        }
        let narrow = makePolicy(cacheEntries: 1)
        let next = try #require(GeneratedVariantValidator.validate(data: wire(["prompt": "Synthetic final"]), policy: narrow, source: source()).value)
        #expect(cache.admit(next, policy: narrow, retention: .optedIn, protectedVariantIDs: [], now: date).value != nil)
        #expect(cache.entries.count == 1)
    }

    @Test func familiarSelectionNeverSubstitutesAnotherRequestedActivity() async {
        let policy = makePolicy(live: true, regenerate: true)
        var session = await send(prepared(epoch), policy: policy, now: date, body: wire())
        _ = session.applyRetention(.optedIn, policy: policy, now: date)
        session.requestedKind = .recallCloze
        #expect(session.presentFamiliar(policy: policy, now: date) == .cacheIncompatible)
        session.requestedKind = nil
        #expect(session.presentFamiliar(policy: policy, now: date) == .activityKindNotChosen)
    }

    @Test func persistencePreflightsEpochAndWritesExactRecordedReport() async throws {
        var session = await send(prepared(epoch), policy: makePolicy(live: true, regenerate: true), now: date, body: wire())
        _ = session.stageReport(issue: .invalidAnswer, policy: makePolicy(), now: date)
        var written: GeneratedPracticeRecord?
        let staleSave = session.persistChanges(expectedEpoch: UUID(), using: { written = $0; return true })
        #expect(staleSave == false)
        #expect(written == nil)
        let failedSave = session.persistChanges(expectedEpoch: epoch, using: { _ in false })
        #expect(failedSave == false)
        #expect(session.committed.reports.isEmpty)
        let reportSave = session.persistChanges(expectedEpoch: epoch, using: { written = $0; return true })
        #expect(reportSave)
        #expect(written == session.committed)
        #expect(written?.reports.first?.status == .recordedLocally)
        let id = try #require(written?.reports.first?.id)
        _ = session.deleteReport(id: id)
        let removalSave = session.persistChanges(expectedEpoch: epoch, using: { written = $0; return true })
        #expect(removalSave)
        #expect(written?.reports.isEmpty == true)
    }

    @Test func declineClearsAllCopiesAndCannotRestoreThroughFamiliarCache() async throws {
        let policy = makePolicy(live: true, regenerate: true)
        var session = await send(prepared(epoch), policy: policy, now: date, body: wire())
        _ = session.applyRetention(.optedIn, policy: policy, now: date)
        let first = try #require(session.working.frozenAttempts.first)
        var duplicate = first; duplicate.id = UUID(); session.working.frozenAttempts.append(duplicate)
        #expect(session.applyRetention(.declined, policy: policy, now: date) == nil)
        #expect(session.working.frozenAttempts.allSatisfy { $0.text == nil })
        #expect(session.working.cache.entries.allSatisfy { $0.text == nil })
        #expect(session.presentFamiliar(policy: policy, now: date) == .cacheIncompatible)
    }

    @Test func localReportDedupAndExportRespectFullVersionExpiryAndRemoval() throws {
        let policy = makePolicy(export: true)
        let subject = ActivityReportSubject(variantID: "synthetic", schemaVersion: 1, contentVersion: "v1", objectiveID: "OBJ-FIXTURE-1", templateID: "situation-sentence", rubricVersion: "rubric-1")
        var first = try #require(IncorrectActivityReports.stage(issue: .other, subject: subject, existing: [], policy: policy, now: date).value)
        var next = subject; next.contentVersion = "v2"
        #expect(IncorrectActivityReports.stage(issue: .other, subject: next, existing: [first], policy: policy, now: date).value?.id != first.id)
        #expect(IncorrectActivityReports.stage(issue: .other, subject: subject, existing: [first], policy: policy, now: first.expiresAt).value?.id != first.id)
        first.status = .deleted
        let data = try #require(IncorrectActivityReports.exportData([first], policy: policy, now: date))
        #expect(try (JSONSerialization.jsonObject(with: data) as? [Any])?.isEmpty == true)
    }

    @Test func repositoryReopenRollbackRemovalAndResetDoNotResurrectPrivateWording() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("SC-D015-\(UUID())")
        defer { try? FileManager.default.removeItem(at: root) }
        var repository: LearnerRepository? = try LearnerRepository(root: root, now: { date }, protectedDataAvailable: { true })
        let epoch = try #require(try repository?.learningDataEpoch())
        let policy = makePolicy(live: true, regenerate: true)
        var session = await send(prepared(epoch), policy: policy, now: date, body: wire())
        _ = session.applyRetention(.optedIn, policy: policy, now: date)
        _ = session.stageReport(issue: .other, policy: policy, now: date)
        _ = session.commit(expectedEpoch: epoch, writeSucceeds: true)
        let saved = session.committed
        try repository?.saveGeneratedPracticeRecord(saved, expectedEpoch: epoch, replacing: nil)
        repository?.close(); repository = nil
        let reopened = try LearnerRepository(root: root, now: { date }, protectedDataAvailable: { true })
        defer { reopened.close() }
        #expect(try reopened.generatedPracticeRecord() == saved)
        var restored = GeneratedPracticeSession.recover(saved, epoch: epoch)
        #expect(restored.presented?.prompt != nil)
        restored.deletePrivateVariant(variantID: try #require(restored.presented?.variantID))
        _ = restored.commit(expectedEpoch: epoch, writeSucceeds: true)
        reopened.beforeCommit = { throw LearnerStorageError.storageFailure }
        #expect(throws: LearnerStorageError.storageFailure) { try reopened.saveGeneratedPracticeRecord(restored.committed, expectedEpoch: epoch, replacing: saved) }
        reopened.beforeCommit = nil
        #expect(try reopened.generatedPracticeRecord() == saved)
        try reopened.saveGeneratedPracticeRecord(restored.committed, expectedEpoch: epoch, replacing: saved)
        #expect(try reopened.generatedPracticeRecord()?.frozenAttempts.allSatisfy { $0.text == nil } == true)
        #expect(throws: LearnerStorageError.staleVersion) { try reopened.saveGeneratedPracticeRecord(saved, expectedEpoch: epoch, replacing: saved) }
        #expect(throws: LearnerStorageError.invalidContent) { try reopened.saveGeneratedPracticeRecord(saved, expectedEpoch: epoch, replacing: restored.committed) }
        try reopened.deleteAllLearningData()
        #expect(throws: LearnerStorageError.staleVersion) { try reopened.saveGeneratedPracticeRecord(saved, expectedEpoch: epoch, replacing: nil) }
        #expect(try reopened.generatedPracticeRecord() == nil)
    }

    @Test func unknownOutcomeRecoveryDoesNotPretendToHaveSaved() throws {
        var pending = prepared(epoch)
        _ = pending.beginFresh(policy: makePolicy(live: true, regenerate: true), connected: true, now: date)
        _ = pending.commit(expectedEpoch: epoch, writeSucceeds: true)
        let record = pending.committed
        let recovered = GeneratedPracticeSession.recover(record, epoch: epoch)
        #expect(recovered.phase == .unknownOutcome)
        #expect(recovered.committed.unresolvedRequestID != nil)
        #expect(recovered.working.unresolvedRequestID == nil)
        #expect(recovered.hasUnsavedChanges)
    }

    @Test func repositoryExpiresCacheAndReportsButPreservesFrozenRetainedAttempt() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("SC-D015-expiry-\(UUID())")
        defer { try? FileManager.default.removeItem(at: root) }
        var clock = date
        let repository = try LearnerRepository(root: root, now: { clock }, protectedDataAvailable: { true })
        defer { repository.close() }
        let epoch = try repository.learningDataEpoch()
        let policy = makePolicy(live: true, regenerate: true)
        var session = await send(prepared(epoch), policy: policy, now: date, body: wire())
        _ = session.applyRetention(.optedIn, policy: policy, now: date)
        _ = session.stageReport(issue: .other, policy: policy, now: date)
        _ = session.commit(expectedEpoch: epoch, writeSucceeds: true)
        try repository.saveGeneratedPracticeRecord(session.committed, expectedEpoch: epoch, replacing: nil)
        clock = date.addingTimeInterval(121)
        try repository.maintain()
        let expired = try #require(try repository.generatedPracticeRecord())
        #expect(expired.cache.entries.isEmpty && expired.reports.isEmpty)
        #expect(expired.frozenAttempts == session.committed.frozenAttempts)
    }
}

nonisolated private final class Counter: @unchecked Sendable {
    private let lock = NSLock()
    private var value = 0
    private var body: Data?
    func add(_ data: Data) { lock.lock(); value += 1; body = data; lock.unlock() }
    var count: Int { lock.lock(); defer { lock.unlock() }; return value }
    var last: Data? { lock.lock(); defer { lock.unlock() }; return body }
}

private extension Result where Failure == GenerationRefusal {
    var refusal: Failure? { if case .failure(let error) = self { return error }; return nil }
    var value: Success? { if case .success(let value) = self { return value }; return nil }
}

private func send(_ session: GeneratedPracticeSession, policy: GenerationPolicy, now: Date, body: Data) async -> GeneratedPracticeSession {
    await GeneratedPracticeClient().submit(session, policy: policy, connected: true, now: now, beforeSend: { _ in true }, send: { _ in body })
}

private func source() -> PracticeSource {
    PracticeSource(objectiveID: "OBJ-FIXTURE-1", contentVersion: "v1", level: "A1", templateID: "situation-sentence", rubricVersion: "rubric-1", grammarTargetIDs: ["g1"], vocabularySenseIDs: ["s1"], senseID: "s1", cardID: "c1", variety: "en-US")
}

private func attempt() -> CurrentAttempt {
    CurrentAttempt(id: UUID(uuidString: "BBBBBBBB-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!, prompt: "Current fixture prompt.", objectiveID: "OBJ-FIXTURE-1", senseID: "s1", cardID: "c1", contentVersion: "v1", rubricVersion: "rubric-1", schedule: ScheduleIdentity(cardID: "c1", dueAt: Date(timeIntervalSince1970: 1_700_000_100), inReview: true))
}

private func prepared(_ epoch: UUID, fallback: ReviewedFallback? = nil) -> GeneratedPracticeSession {
    var session = GeneratedPracticeSession()
    session.bindEpoch(epoch)
    session.familiarity = .fresh
    session.requestedKind = .recognitionChoice
    _ = session.prepare(attempt: attempt(), source: source())
    session.offer(fallback: fallback)
    return session
}

private func makePolicy(record: String = "fixture-decision", accepted: Bool = true, live: Bool = false, regenerate: Bool = false, cacheEntries: Int = 2, context: Int = 500, bytes: Int = 6000, freshness: Int = 120, retain: Int = 90, export: Bool = false, localOnly: Bool = true) -> GenerationPolicy {
    GenerationPolicy(schemaVersion: GeneratedPracticeSchema.version, decisionRecord: record, ownerDecisionAccepted: accepted, permittedObjectiveIDs: ["OBJ-FIXTURE-1"], permittedTemplateIDs: ["situation-sentence"], permittedActivityKinds: GeneratedActivityKind.allCases, contextScalarLimit: context, maximumActivitiesPerRequest: 1, maximumValidatedCacheEntries: cacheEntries, cacheFreshnessSeconds: freshness, maximumResponseBytes: bytes, regenerationPermitted: regenerate, costCeilingRecord: "fixture-cost-record", factualSource: .noFactualClaims, reportRetention: ReportRetentionRule(retainForSeconds: retain, exportPermitted: export, exportEvidenceReference: export ? "fixture-export-record" : "", localOnly: localOnly), providerAccess: ProviderAccessRule(liveTransportPermitted: live, quotaProtectionVerified: live, evidenceReference: live ? "fixture-provider-record" : ""))
}

nonisolated private func wire(_ changes: [String: Any] = [:]) -> Data {
    var object: [String: Any] = [
        "schemaVersion": 1, "objectiveID": "OBJ-FIXTURE-1", "contentVersion": "v1", "level": "A1",
        "templateID": "situation-sentence", "rubricVersion": "rubric-1", "activityKind": "recognitionChoice",
        "variety": "en-US", "prompt": "Pick the sentence that stays on the objective.",
        "explanation": "The objective stays the same.", "choices": ["synthetic alpha", "synthetic beta"],
        "correctChoiceIndex": 0, "recallAnswer": NSNull(), "candidateHeadword": NSNull(), "candidateMeaning": NSNull(),
        "grammarTargetIDs": ["g1"], "vocabularySenseIDs": ["s1"], "cardID": "c1", "editorialLabel": "generated",
        "factualSourceIDs": [String](), "referenceAudioID": NSNull(), "mediaURL": NSNull()
    ]
    for (key, value) in changes { object[key] = value }
    return try! JSONSerialization.data(withJSONObject: object)
}
