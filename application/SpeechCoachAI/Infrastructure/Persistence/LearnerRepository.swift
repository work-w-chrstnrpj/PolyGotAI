import Foundation
import SwiftData
import UIKit

/// Main-actor ownership serializes all mutation. No model/context escapes this boundary.
final class LearnerRepository {
    private typealias StateRow = LearnerSchemaV1.StateRow
    private typealias AttemptRow = LearnerSchemaV1.AttemptRow
    private typealias IntentRow = LearnerSchemaV1.FileIntentRow
    private var container: ModelContainer?
    private var context: ModelContext?
    private let files: PrivateFileStore
    private let now: () -> Date
    private let uptime: () -> TimeInterval
    private let available: () -> Bool
    private let anchorDate: Date
    private let anchorUptime: TimeInterval
    var beforeCommit: (() throws -> Void)?

    init(root: URL, now: @escaping () -> Date = Date.init,
         uptime: @escaping () -> TimeInterval = { ProcessInfo.processInfo.systemUptime },
         protectedDataAvailable: @escaping () -> Bool = { UIApplication.shared.isProtectedDataAvailable },
         fileStore: PrivateFileStore? = nil, storeName: String = "Learner") throws {
        self.now = now; self.uptime = uptime; available = protectedDataAvailable
        anchorDate = now(); anchorUptime = uptime()
        guard protectedDataAvailable() else { throw LearnerStorageError.unavailable }
        files = try fileStore ?? PrivateFileStore(root: root)
        let schema = Schema(versionedSchema: LearnerSchemaV1.self)
        let configuration = ModelConfiguration(storeName, schema: schema,
            url: root.appendingPathComponent("learner.store"), allowsSave: true, cloudKitDatabase: .none)
        // Failure propagates. Never delete/recreate an incompatible or corrupt store.
        let container = try ModelContainer(for: schema, migrationPlan: LearnerMigrationPlan.self,
                                           configurations: [configuration])
        self.container = container
        let context = ModelContext(container); context.autosaveEnabled = false; self.context = context
        if try context.fetch(FetchDescriptor<StateRow>()).isEmpty {
            context.insert(StateRow(epoch: UUID(), preferences: try encode(LearnerPreferences()), now: now()))
            try commit()
        }
        try files.protectTree()
        try recover()
    }

    func close() { context = nil; container = nil }

    func preferences() throws -> LearnerPreferences { try document().preferences }

    func savePreferences(_ value: LearnerPreferences) throws {
        var stored = try document(); stored.preferences = value
        try write(stored)
    }

    func lessonJourneys(lessonID: String) throws -> [LessonJourney] {
        try document().lessonJourneys.filter { $0.lessonID == lessonID }
    }

    func allLessonJourneys() throws -> [LessonJourney] { try document().lessonJourneys }

    func saveLessonJourney(_ journey: LessonJourney) throws {
        var stored = try document()
        if let index = stored.lessonJourneys.firstIndex(where: { $0.id == journey.id }) {
            stored.lessonJourneys[index] = journey
        } else {
            stored.lessonJourneys.append(journey)
        }
        try write(stored)
    }

    func vocabularyEnrollments() throws -> [VocabularyEnrollment] { try document().vocabularyEnrollments }

    func vocabularyExposures() throws -> [VocabularyExposure] { try document().vocabularyExposures }

    @discardableResult
    func enrollVocabulary(_ sense: CurriculumSense, lesson: ResolvedLesson, inReview: Bool = true) throws -> VocabularyEnrollment {
        var stored = try document()
        var collection = VocabularyCollection(enrollments: stored.vocabularyEnrollments, exposures: stored.vocabularyExposures)
        let enrollment = try collection.enroll(sense, lesson: lesson, now: try effectiveNow(), inReview: inReview)
        if stored.vocabularyEnrollments == collection.enrollments { return enrollment }
        stored.vocabularyEnrollments = collection.enrollments
        try write(stored)
        return enrollment
    }

    @discardableResult
    func saveVocabularyToCollection(_ sense: CurriculumSense, lesson: ResolvedLesson) throws -> VocabularyEnrollment {
        try enrollVocabulary(sense, lesson: lesson, inReview: false)
    }

    func addCollectedVocabularyToReview(_ card: VocabularyEnrollment) throws {
        var stored = try document()
        let indices = stored.vocabularyEnrollments.indices.filter { stored.vocabularyEnrollments[$0].id == card.id }
        guard indices.count == 1, let index = indices.first else { throw VocabularyRecallError.unknownCard }
        guard !stored.vocabularyEnrollments[index].inReview else { return }
        stored.vocabularyEnrollments[index].inReview = true
        try write(stored)
    }

    func customTopics() throws -> [CustomVocabularyTopic] { try document().customTopics }

    func vocabularyRecalls() throws -> [VocabularyRecallAttempt] { try document().vocabularyRecalls }

    func senseCredits() throws -> [SenseCreditEvent] { try document().senseCredits }

    /// Assign identity once to a legacy draft before returning it for resume or skip.
    func openRecall() throws -> OpenRecall? {
        var stored = try document()
        guard var open = stored.openRecall else { return nil }
        guard open.sourceEventID == nil else { return open }
        open.sourceEventID = UUID()
        stored.openRecall = open
        try write(stored)
        return open
    }

    /// Saves a hidden draft or reveal without rating. Revealed first responses cannot be replaced.
    func stageOpenRecall(card: VocabularyEnrollment, draft: RecallDraft, expectedEpoch: UUID? = nil) throws {
        if let expectedEpoch, expectedEpoch != (try state().epoch) { throw LearnerStorageError.invalidState }
        var stored = try document()
        guard stored.vocabularyEnrollments.contains(where: { $0.itemId == card.itemId && $0.senseId == card.senseId && $0.inReview }) else {
            throw VocabularyRecallError.unknownCard
        }
        guard !stored.vocabularyRecalls.contains(where: { $0.sourceEventID == draft.sourceEventID }) else {
            throw VocabularyRecallError.staleEvent
        }
        if let open = stored.openRecall, open.itemId == card.itemId, open.senseId == card.senseId {
            if let event = open.sourceEventID, event != draft.sourceEventID { throw VocabularyRecallError.staleEvent }
            if open.revealed { return }
        }
        let staged = OpenRecall(
            itemId: card.itemId, senseId: card.senseId, typed: draft.typed, revealed: draft.revealed,
            firstResponse: draft.firstResponse, hinted: draft.hinted, mode: draft.mode, sourceEventID: draft.sourceEventID)
        guard stored.openRecall != staged else { return }
        stored.openRecall = staged
        try write(stored)
    }

    func clearOpenRecall(sourceEventID: UUID, expectedEpoch: UUID? = nil) throws {
        if let expectedEpoch, expectedEpoch != (try state().epoch) { throw LearnerStorageError.invalidState }
        var stored = try document()
        guard stored.openRecall?.sourceEventID == sourceEventID else { return }
        stored.openRecall = nil
        try write(stored)
    }

    func recognitionSchedule(itemId: String, senseId: String) throws -> ReviewCardState? {
        try document().reviewCards.first { $0.itemId == itemId && $0.senseId == senseId && $0.kind == ReviewSchedule.kind }
    }

    func reviewQueue() throws -> ReviewQueuePlan {
        let stored = try document()
        return ReviewQueue.plan(enrollments: stored.vocabularyEnrollments, cards: stored.reviewCards, now: try effectiveNow())
    }

    func reviewSettings() throws -> ReviewSettings {
        let settings = try document().reviewSettings ?? ReviewSettings()
        try settings.validate()
        return settings
    }

    func saveReviewSettings(_ settings: ReviewSettings, expectedEpoch: UUID? = nil) throws {
        if let expectedEpoch, expectedEpoch != (try state().epoch) { throw LearnerStorageError.invalidState }
        try settings.validate()
        var stored = try document()
        guard stored.reviewSettings != settings else { return }
        stored.reviewSettings = settings
        try write(stored)
    }

    // Practice-goal preference used by the Today suggestion.
    func practiceGoal() throws -> SuggestionAction? { try document().practiceGoal }

    func savePracticeGoal(_ goal: SuggestionAction?, expectedEpoch: UUID? = nil) throws {
        if let expectedEpoch, expectedEpoch != (try state().epoch) { throw LearnerStorageError.invalidState }
        var stored = try document()
        guard stored.practiceGoal != goal else { return }
        stored.practiceGoal = goal
        try write(stored)
    }

    func meaningNote(itemId: String, senseId: String) throws -> String? {
        let stored = try document()
        let note = stored.customTopics.lazy.flatMap(\.senses).first { $0.itemId == itemId && $0.senseId == senseId }?.note
            ?? stored.vocabularyEnrollments.first { $0.itemId == itemId && $0.senseId == senseId }?.meaning
            ?? CurriculumCatalogLoader.bundled.lessons.lazy.filter(\.isReady).flatMap(\.senses)
                .first { $0.itemId == itemId && $0.senseId == senseId }?.meaning
        let trimmed = note?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }

    @discardableResult
    func recordVocabularyRecall(card: VocabularyEnrollment, rating: RecallRating, draft: RecallDraft, sourceEventID: UUID? = nil, expectedEpoch: UUID? = nil) throws -> VocabularyRecallAttempt {
        if let expectedEpoch, expectedEpoch != (try state().epoch) { throw LearnerStorageError.invalidState }
        var stored = try document()
        let sourceEventID = sourceEventID ?? draft.sourceEventID
        let enrolled = stored.vocabularyEnrollments.contains { $0.itemId == card.itemId && $0.senseId == card.senseId && $0.inReview }
        let recorded = Set(stored.vocabularyRecalls.compactMap(\.sourceEventID))
        let decision = ReviewCreditPolicy.decide(
            task: .explicitRating, revealed: draft.revealed, kind: .recognition,
            sourceEventID: sourceEventID, alreadyRecorded: recorded, enrolled: enrolled)
        if case .unchanged(.duplicateEvent) = decision {
            guard let existing = stored.vocabularyRecalls.first(where: { $0.sourceEventID == sourceEventID }),
                  existing.itemId == card.itemId, existing.senseId == card.senseId else {
                throw VocabularyRecallError.staleEvent
            }
            return existing
        }
        var acceptedDraft = draft
        if let open = stored.openRecall, open.itemId == card.itemId, open.senseId == card.senseId {
            if let event = open.sourceEventID, event != sourceEventID { throw VocabularyRecallError.staleEvent }
            acceptedDraft = RecallDraft(open)
        }
        guard enrolled else { throw VocabularyRecallError.unknownCard }
        guard acceptedDraft.revealed else { throw VocabularyRecallError.stillHidden }
        guard try meaningNote(itemId: card.itemId, senseId: card.senseId) != nil else { throw VocabularyRecallError.missingMeaning }
        let now = try effectiveNow()
        var log = VocabularyRecallLog(attempts: stored.vocabularyRecalls)
        var attempt = try log.record(card: card, rating: rating, draft: acceptedDraft, now: now, sourceEventID: sourceEventID)
        // Do not bypass queue integrity through a stale screen or a direct repository call.
        guard stored.vocabularyEnrollments.filter({ $0.id == card.id && $0.inReview }).count == 1 else {
            throw ReviewScheduleError.schedulingFailed
        }
        let histories = stored.reviewCards.filter { $0.itemId == card.itemId && $0.senseId == card.senseId }
        guard histories.count <= 1 else { throw ReviewScheduleError.schedulingFailed }
        let existing = histories.first
        let scheduled = try ReviewSchedule.schedule(existing: existing, rating: rating, now: now, itemId: card.itemId, senseId: card.senseId, settings: stored.reviewSettings ?? ReviewSettings())
        attempt.schedulerVersion = scheduled.schedulerVersion
        attempt.desiredRetention = scheduled.desiredRetention
        log.attempts[log.attempts.count - 1] = attempt
        stored.vocabularyRecalls = log.attempts
        if stored.openRecall?.itemId == card.itemId && stored.openRecall?.senseId == card.senseId {
            stored.openRecall = nil
        }
        if let index = stored.reviewCards.firstIndex(where: { $0.id == scheduled.id }) {
            stored.reviewCards[index] = scheduled
        } else {
            stored.reviewCards.append(scheduled)
        }
        try write(stored)
        return attempt
    }

    /// A grammar correction is not a recall rating and does not move the recognition card.
    func noteGrammarCorrection(itemId: String, senseId: String, sourceEventID: UUID) throws {
        try noteUnscheduled(itemId: itemId, senseId: senseId, task: .grammarCorrection, rating: nil, sourceEventID: sourceEventID)
    }

    /// Productive use is kept beside recognition. It does not schedule the meaning card.
    func recordProductiveUse(card: VocabularyEnrollment, rating: RecallRating, sourceEventID: UUID) throws {
        try noteUnscheduled(itemId: card.itemId, senseId: card.senseId, task: .productiveUse, rating: rating.rawValue, sourceEventID: sourceEventID)
    }

    private func noteUnscheduled(itemId: String, senseId: String, task: ReviewTask, rating: String?, sourceEventID: UUID) throws {
        var stored = try document()
        let enrolled = stored.vocabularyEnrollments.contains { $0.itemId == itemId && $0.senseId == senseId }
        let recorded = Set(stored.senseCredits.map(\.id))
        let decision = ReviewCreditPolicy.decide(
            task: task, revealed: false, kind: task == .productiveUse ? .productiveUse : .recognition,
            sourceEventID: sourceEventID, alreadyRecorded: recorded, enrolled: enrolled)
        switch decision {
        case .unchanged(.duplicateEvent), .unchanged(.grammarCorrection), .unchanged(.productiveUseKeptSeparate):
            if case .unchanged(.duplicateEvent) = decision { return }
        default:
            throw VocabularyRecallError.unknownCard
        }
        guard enrolled else { throw VocabularyRecallError.unknownCard }
        let dueBefore = stored.reviewCards
        stored.senseCredits.append(SenseCreditEvent(
            id: sourceEventID, itemId: itemId, senseId: senseId, task: task.rawValue,
            cardKind: task == .productiveUse ? ReviewCardKind.productiveUse.rawValue : ReviewCardKind.recognition.rawValue,
            rating: rating, createdAt: try effectiveNow()))
        stored.reviewCards = dueBefore
        try write(stored)
    }

    @discardableResult
    func createCustomTopic(title: String, subtopic: String) throws -> CustomVocabularyTopic {
        var stored = try document()
        var library = stored.customLibrary()
        let topic = try library.createTopic(title: title, subtopic: subtopic, now: try effectiveNow())
        stored.customTopics = library.topics
        try write(stored)
        return topic
    }

    @discardableResult
    func renameCustomTopic(id: UUID, title: String, subtopic: String) throws -> CustomVocabularyTopic {
        var stored = try document()
        var library = stored.customLibrary()
        let topic = try library.renameTopic(id: id, title: title, subtopic: subtopic, now: try effectiveNow())
        stored.customTopics = library.topics
        try write(stored)
        return topic
    }

    @discardableResult
    func addCustomSense(topicID: UUID, lemma: String, note: String) throws -> CustomSenseChange {
        var stored = try document()
        var library = stored.customLibrary()
        let change = try library.addSense(topicID: topicID, lemma: lemma, note: note, now: try effectiveNow())
        guard stored.customTopics != library.topics else { return change }
        stored.customTopics = library.topics
        try write(stored)
        return change
    }

    @discardableResult
    func editCustomSense(topicID: UUID, senseID: UUID, lemma: String, note: String) throws -> CustomVocabularySense {
        var stored = try document()
        var library = stored.customLibrary()
        let sense = try library.editSense(topicID: topicID, senseID: senseID, lemma: lemma, note: note, now: try effectiveNow())
        stored.customTopics = library.topics
        stored.vocabularyEnrollments = library.enrollments
        try write(stored)
        return sense
    }

    @discardableResult
    func enrollCustomSense(topicID: UUID, senseID: UUID, inReview: Bool = true) throws -> VocabularyEnrollment {
        var stored = try document()
        var library = stored.customLibrary()
        let enrollment = try library.enroll(topicID: topicID, senseID: senseID, now: try effectiveNow(), inReview: inReview)
        if stored.vocabularyEnrollments == library.enrollments { return enrollment }
        stored.vocabularyEnrollments = library.enrollments
        try write(stored)
        return enrollment
    }

    @discardableResult
    func saveCustomSenseToCollection(topicID: UUID, senseID: UUID) throws -> VocabularyEnrollment {
        try enrollCustomSense(topicID: topicID, senseID: senseID, inReview: false)
    }

    func deleteCustomTopic(id: UUID) throws {
        var stored = try document()
        var library = stored.customLibrary()
        let before = stored.vocabularyEnrollments
        try library.deleteTopic(id: id)
        stored.customTopics = library.topics
        stored.vocabularyEnrollments = library.enrollments
        guard stored.vocabularyEnrollments.map(\.id) == before.map(\.id) else { throw LearnerStorageError.invalidState }
        try write(stored)
    }

    func recordVocabularyExposure(_ sense: CurriculumSense, lesson: ResolvedLesson) throws {
        var stored = try document()
        var collection = VocabularyCollection(enrollments: stored.vocabularyEnrollments, exposures: stored.vocabularyExposures)
        let before = collection.exposures.count
        try collection.expose(sense, lesson: lesson, now: try effectiveNow())
        guard collection.exposures.count != before else { return }
        stored.vocabularyExposures = collection.exposures
        try write(stored)
    }

    func createAttempt(prompt: PromptSnapshot, retryOf: UUID? = nil, context: PracticeSessionContext? = nil) throws -> AttemptSnapshot {
        guard !prompt.id.isEmpty, !prompt.version.isEmpty, !prompt.objectiveID.isEmpty,
              (prompt.text?.unicodeScalars.count ?? 0) <= 12_000 else { throw LearnerStorageError.invalidContent }
        if let objective = context?.objectiveID, objective != prompt.objectiveID { throw LearnerStorageError.invalidReference }
        if let retryOf { _ = try attemptRow(retryOf) }
        let date = try effectiveNow()
        var value = AttemptSnapshot(id: UUID(), epoch: try state().epoch, retryOfAttemptID: retryOf,
            prompt: prompt, preferences: try context?.effectivePreferences ?? preferences(), createdAt: date,
            recoveryDeadline: date.addingTimeInterval(24 * 3600))
        value.practiceSessionID = context?.id; value.sourceLessonID = context?.sourceLessonID
        value.sourceLessonJourneyID = context?.sourceLessonJourneyID
        value.speakingProvenance = context?.provenance
        try db().insert(AttemptRow(id: value.id, snapshot: try encode(value)))
        try commit(); return value
    }

    func attempt(_ id: UUID) throws -> AttemptSnapshot {
        try maintain()
        return try visibleSnapshot(read(id))
    }

    func recoverableAttempts() throws -> [AttemptSnapshot] {
        try maintain()
        return try db().fetch(FetchDescriptor<AttemptRow>()).map { try decode(AttemptSnapshot.self, from: $0.snapshot) }
            .filter { $0.interrupted && $0.finishedAt == nil && ($0.audio.isVisible || $0.text.isVisible) }
            .map { try visibleSnapshot($0) }
    }

    func history(recentlyDeleted: Bool = false) throws -> [AttemptSnapshot] {
        try maintain()
        return try db().fetch(FetchDescriptor<AttemptRow>())
            .map { try decode(AttemptSnapshot.self, from: $0.snapshot) }
            .filter { value in
                if recentlyDeleted { return value.audio.state == .recentlyDeleted || value.text.state == .recentlyDeleted }
                return value.finishedAt != nil && (value.audio.state == .saved || value.text.state == .saved || value.audio.state == .unavailable)
            }
            .sorted { $0.createdAt > $1.createdAt }
            .map { try visibleSnapshot($0) }
    }

    func completedPracticeCount() throws -> Int {
        try maintain()
        let values = try db().fetch(FetchDescriptor<AttemptRow>()).map { try decode(AttemptSnapshot.self, from: $0.snapshot) }
        return Set(values.filter { $0.didCompleteSelfReview == true }.map { $0.completionID ?? $0.id }).count
    }

    func token(for id: UUID) throws -> CallbackToken {
        let value = try attempt(id)
        return CallbackToken(attemptID: id, epoch: value.epoch, version: value.version)
    }

    /// Capture format verification is supplied by SC-T011; storage verifies byte integrity here.
    func finalizeRecording(attemptID: UUID, data: Data, durationMilliseconds: Int,
                           sampleRate: Int, channels: Int, bitsPerSample: Int,
                           expectedVersion: Int) throws -> AttemptSnapshot {
        let value = try checked(attemptID, expectedVersion)
        guard value.audio.state == .temporary, value.recording == nil,
              !data.isEmpty, data.count <= 32 * 1024 * 1024,
              durationMilliseconds > 0, sampleRate > 0, channels > 0, bitsPerSample > 0 else {
            throw LearnerStorageError.invalidContent
        }
        let id = UUID()
        let recording = RecordingSnapshot(id: id, relativePath: "audio/\(id.uuidString).wav", byteCount: data.count,
            sha256: PrivateFileStore.checksum(data), durationMilliseconds: durationMilliseconds,
            sampleRate: sampleRate, channelCount: channels, bitsPerSample: bitsPerSample)
        let intent = FileIntent(action: .finalize, attemptID: value.id, epoch: value.epoch,
                                expectedVersion: value.version, recording: recording)
        try insertIntent(intent); try commit() // durable intent before touching the file
        try files.writeAndFinalize(data, recording: recording)
        return try completeFinalization(intent)
    }

    /// Commit the private capture reference before AVAudioRecorder can create any bytes.
    func prepareCapture(_ id: UUID, expectedVersion: Int) throws -> URL {
        var value = try checked(id, expectedVersion)
        guard value.finishedAt == nil, value.recording == nil, value.pendingCaptureID == nil else {
            throw LearnerStorageError.invalidState
        }
        let capacity = try files.root.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
            .volumeAvailableCapacityForImportantUsage ?? 0
        guard capacity >= 32 * 1024 * 1024 else { throw LearnerStorageError.storageFailure }
        let capture = UUID(); value.pendingCaptureID = capture
        value.recoveryDeadline = try effectiveNow().addingTimeInterval(24 * 3600)
        value.version += 1; try put(value); try commit()
        return try files.url(for: "staging/\(capture.uuidString).wav")
    }

    func protectCapture() throws { try files.protectTree() }

    func finalizeCapture(_ id: UUID) throws -> AttemptSnapshot {
        try maintain()
        var value = try read(id)
        guard let capture = value.pendingCaptureID else { return try attempt(id) }
        let path = "staging/\(capture.uuidString).wav"
        if value.recording == nil {
            let inspected = try CaptureFile(url: files.url(for: path))
            value = try finalizeRecording(attemptID: id, data: inspected.data,
                durationMilliseconds: inspected.durationMilliseconds, sampleRate: inspected.sampleRate,
                channels: inspected.channels, bitsPerSample: inspected.bits, expectedVersion: value.version)
        }
        // A crash here retains the draft reference, so reopening can finish this idempotently.
        try files.remove(path)
        value.pendingCaptureID = nil; value.version += 1; try put(value); try commit()
        return value
    }

    func recordingURL(_ id: UUID) throws -> URL {
        guard let recording = try attempt(id).recording, try files.isAvailable(recording) else {
            throw LearnerStorageError.unavailable
        }
        return try files.url(for: recording.relativePath)
    }

    func markInterrupted(_ id: UUID, expectedVersion: Int) throws {
        var value = try checked(id, expectedVersion)
        value.interrupted = true
        // Passive interruption does not extend the last explicit interaction's deadline.
        value.version += 1; try put(value); try commit()
    }

    func recordRecoveryInteraction(_ id: UUID, expectedVersion: Int) throws {
        try maintain()
        var value = try checked(id, expectedVersion)
        guard value.finishedAt == nil, value.audio.isVisible || value.text.isVisible else {
            throw LearnerStorageError.invalidState
        }
        value.recoveryDeadline = try effectiveNow().addingTimeInterval(24 * 3600)
        value.version += 1; try put(value); try commit()
    }

    func appendTranscript(_ transcript: TranscriptSnapshot, token: CallbackToken) throws {
        try maintain()
        var value = try checked(token.attemptID, token.version)
        guard token.epoch == value.epoch, value.text.isVisible,
              transcript.revision == (value.transcripts.map(\.revision).max() ?? 0) + 1,
              !value.transcripts.contains(where: { $0.id == transcript.id }),
              !transcript.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              transcript.text.unicodeScalars.count <= 12_000 else { throw LearnerStorageError.invalidContent }
        if transcript.kind == .learnerConfirmed {
            guard value.transcripts.contains(where: { $0.id == transcript.sourceTranscriptID }) else {
                throw LearnerStorageError.invalidReference
            }
        } else if transcript.sourceTranscriptID != nil { throw LearnerStorageError.invalidReference }
        value.transcripts.append(transcript); value.stage = .transcriptReview
        value.version += 1; try put(value); try commit()
    }

    func registerRequest(_ request: RequestSnapshot, token: CallbackToken) throws -> CallbackToken {
        try maintain()
        var value = try checked(token.attemptID, token.version)
        guard value.epoch == token.epoch, value.text.isVisible,
              !value.requests.contains(where: { $0.id == request.id }),
              !value.requests.contains(where: { $0.stage == request.stage && ($0.status == .prepared || $0.status == .sent) }),
              request.status == .prepared || request.status == .sent,
              !request.model.isEmpty, !request.region.isEmpty else { throw LearnerStorageError.invalidState }
        if request.stage == .coaching {
            guard value.transcripts.contains(where: { $0.id == request.transcriptID && $0.kind == .learnerConfirmed }) else {
                throw LearnerStorageError.invalidReference
            }
        }
        value.requests.append(request); value.version += 1; try put(value); try commit()
        return CallbackToken(attemptID: value.id, epoch: value.epoch, version: value.version)
    }

    /// Durable preparation is not permission to send. The caller must separately obtain consent.
    func prepareTranscription(_ id: UUID, expectedVersion: Int, model: String, region: String) throws -> CallbackToken {
        let value = try attempt(id)
        guard value.version == expectedVersion else { throw LearnerStorageError.staleVersion }
        guard value.finishedAt == nil, value.audio.isVisible, value.recording != nil else {
            throw LearnerStorageError.invalidState
        }
        let request = RequestSnapshot(id: UUID(), stage: .transcription, model: model, region: region,
            status: .prepared, createdAt: try effectiveNow())
        return try registerRequest(request, token: token(for: id))
    }

    func transitionRequest(_ requestID: UUID, status: RequestSnapshot.Status, token: CallbackToken) throws -> CallbackToken {
        try maintain()
        var value = try checked(token.attemptID, token.version)
        guard value.epoch == token.epoch, value.text.isVisible, value.finishedAt == nil,
              let index = value.requests.firstIndex(where: { $0.id == requestID }) else {
            throw LearnerStorageError.invalidState
        }
        let prior = value.requests[index].status
        let allowed: Bool
        switch (prior, status) {
        case (.prepared, .sent), (.prepared, .cancelled), (.prepared, .failed),
             (.sent, .failed), (.sent, .cancelled), (.sent, .unknownOutcome): allowed = true
        default: allowed = false
        }
        guard allowed else { throw LearnerStorageError.invalidState }
        value.requests[index].status = status
        if status == .sent { value.stage = value.requests[index].stage == .transcription ? .transcribing : .feedbackPending }
        else { value.stage = value.transcripts.isEmpty ? .recorded : .transcriptReview }
        value.version += 1; try put(value); try commit()
        return CallbackToken(attemptID: value.id, epoch: value.epoch, version: value.version)
    }

    /// Complete request + immutable original in one store commit. No partial successful state.
    func completeTranscription(_ result: ASRRecognition, requestID: UUID, token: CallbackToken) throws -> AttemptSnapshot {
        try maintain()
        var value = try checked(token.attemptID, token.version)
        guard value.epoch == token.epoch, value.text.isVisible, value.finishedAt == nil,
              let index = value.requests.firstIndex(where: { $0.id == requestID }),
              value.requests[index].stage == .transcription, value.requests[index].status == .sent,
              value.requests[index].model == result.model,
              !result.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              result.text.unicodeScalars.count <= 12_000 else { throw LearnerStorageError.invalidContent }
        let transcript = TranscriptSnapshot(id: UUID(), revision: (value.transcripts.map(\.revision).max() ?? 0) + 1,
            kind: .asrOriginal, text: result.text, createdAt: try effectiveNow(),
            provider: "Alibaba Cloud Model Studio", model: result.model, region: value.requests[index].region)
        value.transcripts.append(transcript); value.requests[index].status = .succeeded
        value.stage = .transcriptReview; value.version += 1; try put(value); try commit()
        return value
    }

    /// Local edits never enqueue coaching or change any original recognition revision.
    func confirmTranscript(_ id: UUID, sourceID: UUID, text: String, expectedVersion: Int) throws -> AttemptSnapshot {
        let value = try attempt(id)
        guard value.version == expectedVersion else { throw LearnerStorageError.staleVersion }
        guard value.finishedAt == nil, value.transcripts.contains(where: { $0.id == sourceID }) else {
            throw LearnerStorageError.invalidReference
        }
        let confirmation = TranscriptSnapshot(id: UUID(), revision: (value.transcripts.map(\.revision).max() ?? 0) + 1,
            kind: .learnerConfirmed, sourceTranscriptID: sourceID, text: text, createdAt: try effectiveNow())
        try appendTranscript(confirmation, token: token(for: id))
        return try attempt(id)
    }

    func prepareCoaching(_ id: UUID, transcriptID: UUID, expectedVersion: Int, model: String, region: String) throws -> CallbackToken {
        let value = try attempt(id)
        guard value.version == expectedVersion else { throw LearnerStorageError.staleVersion }
        guard value.finishedAt == nil,
              value.transcripts.last(where: { $0.kind == .learnerConfirmed })?.id == transcriptID else {
            throw LearnerStorageError.invalidReference
        }
        let request = RequestSnapshot(id: UUID(), stage: .coaching, transcriptID: transcriptID,
            model: model, region: region, status: .prepared, createdAt: try effectiveNow())
        return try registerRequest(request, token: token(for: id))
    }

    /// No raw content or unvalidated FeedbackSnapshot can enter this commit boundary.
    func completeCoaching(_ content: ValidatedCoachingContent, requestID: UUID,
                          rubricVersion: String, token: CallbackToken) throws -> AttemptSnapshot {
        try maintain()
        var value = try checked(token.attemptID, token.version)
        guard value.epoch == token.epoch, value.text.isVisible, value.finishedAt == nil,
              !rubricVersion.isEmpty,
              let index = value.requests.firstIndex(where: { $0.id == requestID }),
              value.requests[index].stage == .coaching, value.requests[index].status == .sent,
              value.requests[index].transcriptID == content.transcriptID,
              let transcript = value.transcripts.first(where: {
                  $0.id == content.transcriptID && $0.revision == content.transcriptRevision && $0.kind == .learnerConfirmed
              }), PrivateFileStore.checksum(Data(transcript.text.utf8)) == content.transcriptChecksum,
              !value.feedback.contains(where: { $0.requestID == requestID }) else {
            throw LearnerStorageError.invalidReference
        }
        let feedback = FeedbackSnapshot(id: UUID(), requestID: requestID,
            transcriptID: transcript.id, transcriptRevision: transcript.revision, schemaVersion: 1,
            rubricVersion: rubricVersion, provider: "Alibaba Cloud Model Studio", model: value.requests[index].model,
            region: value.requests[index].region, createdAt: try effectiveNow(), summary: content.summary,
            strengths: content.strengths, improvements: content.improvements, limitations: content.limitations)
        value.feedback.append(feedback); value.requests[index].status = .succeeded
        value.stage = .feedbackReady; value.version += 1; try put(value); try commit()
        return value
    }

    func saveSelection(_ id: UUID, keepAudio: Bool, keepText: Bool, expectedVersion: Int) throws -> AttemptSnapshot {
        try maintain()
        var value = try checked(id, expectedVersion)
        let rewardProvenance = value.speakingProvenance
        let hadRecording = value.recording != nil
        let boundRecording = rewardProvenance.map { provenance in
            !["coursePractice", "topicPractice", "specialistPractice"].contains(provenance.purpose) ||
                AwardFamily.supports(lessonID: provenance.packID, version: provenance.packVersion)
        } ?? true
        if value.finishedAt != nil {
            guard value.didCompleteSelfReview == true else { throw LearnerStorageError.invalidState }
            return try visibleSnapshot(value) // A repeated finish cannot issue another completion.
        }
        guard !keepText || (value.text.isVisible && !value.transcripts.isEmpty) else { throw LearnerStorageError.invalidState }
        if keepAudio {
            guard value.audio.isVisible, let recording = value.recording, try files.isAvailable(recording) else {
                throw LearnerStorageError.integrityFailure
            }
            value.audio.state = .saved
        } else { try stripAudio(&value) }
        if keepText { value.text.state = .saved }
        else { stripText(&value) }
        value.finishedAt = try effectiveNow(); value.interrupted = false
        value.completionID = value.practiceSessionID ?? value.id; value.didCompleteSelfReview = true
        if !keepAudio && !keepText { minimize(&value) }
        var stored = try document()
        var ledger = try stored.rewards ?? RewardLedger(epoch: value.epoch, startedAt: effectiveNow())
        let source: String
        let activity: String
        if let provenance = rewardProvenance {
            source = "lesson/\(provenance.journeyID)/\(provenance.activityID)"
            activity = "\(provenance.packID)/\(provenance.packVersion)/\(provenance.activityID)"
        } else {
            source = "speaking/\(value.completionID ?? value.id)"
            activity = "speaking/\(value.prompt.id)/\(value.prompt.version)"
        }
        do {
            if hadRecording && boundRecording { try ledger.credit(source: source, activity: activity, kind: "speaking", day: RewardPolicy.day(try effectiveNow()), now: try effectiveNow()) }
            ledger.revision += 1; stored.rewards = ledger
        } catch RewardError.clockChanged { }
        value.version += 1; try put(value)
        try state().preferences = encode(stored); try commit()
        NotificationCenter.default.post(name: .rewardLedgerChanged, object: nil)
        RewardReminderScheduler.cancelIfGoalMet(ledger: ledger)
        // Logical durable retention is committed. Cleanup failures remain journaled; no physical purge claim.
        try drainDeletes()
        return try visibleSnapshot(value)
    }

    func softDelete(_ id: UUID, scope: PayloadScope, expectedVersion: Int) throws -> [UUID] {
        try maintain()
        var value = try checked(id, expectedVersion)
        let date = try effectiveNow(); var ids: [UUID] = []
        func deleted(_ component: ComponentLifecycle) -> ComponentLifecycle {
            guard component.state == .saved else { return component }
            let id = UUID(); ids.append(id)
            return ComponentLifecycle(state: .recentlyDeleted, deletionID: id, deletedAt: date,
                                      expiresAt: date.addingTimeInterval(30 * 24 * 3600))
        }
        if scope != .text { value.audio = deleted(value.audio) }
        if scope != .audio { value.text = deleted(value.text) }
        guard !ids.isEmpty else { throw LearnerStorageError.invalidState }
        value.version += 1; try put(value); try commit(); return ids
    }

    func restore(_ deletionID: UUID, expectedVersion: Int) throws {
        try maintain()
        var value = try findDeletion(deletionID)
        guard value.version == expectedVersion else { throw LearnerStorageError.staleVersion }
        if value.audio.deletionID == deletionID {
            guard let asset = value.recording, try files.isAvailable(asset) else {
                throw LearnerStorageError.integrityFailure
            }
            value.audio = ComponentLifecycle(state: .saved)
        } else { value.text = ComponentLifecycle(state: .saved) }
        // Increment invalidates pre-delete callbacks. Restoring never resumes a request.
        value.version += 1; try put(value); try commit()
    }

    func purge(_ deletionID: UUID, expectedVersion: Int) throws {
        var value = try findDeletion(deletionID)
        guard value.version == expectedVersion else { throw LearnerStorageError.staleVersion }
        if value.audio.deletionID == deletionID { try stripAudio(&value) }
        else { stripText(&value) }
        if value.audio.state == .purged && value.text.state == .purged { minimize(&value) }
        value.version += 1; try put(value); try commit(); try drainDeletes()
    }

    func discardTemporary(_ id: UUID, expectedVersion: Int) throws {
        var value = try checked(id, expectedVersion)
        guard value.finishedAt == nil else { throw LearnerStorageError.invalidState }
        try stripAudio(&value); stripText(&value); minimize(&value)
        value.finishedAt = try effectiveNow(); value.interrupted = false; value.version += 1
        try put(value); try commit(); try drainDeletes()
    }

    /// Invoked only after the separately confirmed reset control is adopted by feature UI.
    func deleteAllLearningData() throws {
        let db = try db(); let state = try state()
        for row in try db.fetch(FetchDescriptor<AttemptRow>()) {
            var value = try decode(AttemptSnapshot.self, from: row.snapshot)
            try stripAudio(&value); db.delete(row)
        }
        // Old finalize journals must never attach after reset. Their files become deletion intents.
        for row in try db.fetch(FetchDescriptor<IntentRow>()) {
            var intent = try decode(FileIntent.self, from: row.value)
            intent.action = .delete; row.value = try encode(intent)
        }
        let removedEpoch = state.epoch
        state.epoch = UUID(); state.preferences = try encode(LearnerPreferences())
        try commit(); RewardReminderScheduler.cancel(epoch: removedEpoch); try drainDeletes()
    }

    func pendingFileWorkCount() throws -> Int { try db().fetchCount(FetchDescriptor<IntentRow>()) }

    func maintain() throws {
        let date = try effectiveNow()
        var learning = try document()
        let previousCount = learning.speakingPracticeArchives?.count ?? 0
        learning.speakingPracticeArchives?.removeAll { $0.expiresAt.map { date >= $0 } == true }
        if (learning.speakingPracticeArchives?.count ?? 0) != previousCount { try write(learning) }
        _ = try generatedPracticeRecord()
        let rows = try db().fetch(FetchDescriptor<AttemptRow>())
        for row in rows {
            var value = try decode(AttemptSnapshot.self, from: row.snapshot); var changed = false
            if value.finishedAt == nil && date >= value.recoveryDeadline {
                try stripAudio(&value); stripText(&value); minimize(&value)
                value.finishedAt = date; value.interrupted = false; changed = true
            } else {
                if value.audio.state == .recentlyDeleted, let expiry = value.audio.expiresAt, date >= expiry {
                    try stripAudio(&value); changed = true
                }
                if value.text.state == .recentlyDeleted, let expiry = value.text.expiresAt, date >= expiry {
                    stripText(&value); changed = true
                }
            }
            if let asset = value.recording, value.audio.isVisible, !(try files.isAvailable(asset)) {
                value.audio.state = .unavailable; changed = true
            }
            if changed {
                if value.audio.state == .purged && value.text.state == .purged { minimize(&value) }
                value.version += 1; row.snapshot = try encode(value)
            }
        }
        try commit()
        // An inaccessible file remains invisible/pending, even when physical cleanup fails.
        try drainDeletes()
    }

    private func recover() throws {
        let date = try effectiveNow()
        for row in try db().fetch(FetchDescriptor<AttemptRow>()) {
            var value = try decode(AttemptSnapshot.self, from: row.snapshot)
            if value.finishedAt == nil { value.interrupted = true }
            for index in value.requests.indices {
                if value.requests[index].status == .sent { value.requests[index].status = .unknownOutcome }
                else if value.requests[index].status == .prepared { value.requests[index].status = .cancelled }
            }
            if value.stage == .transcribing || value.stage == .feedbackPending {
                value.stage = value.transcripts.isEmpty ? .recorded : .transcriptReview
            }
            row.snapshot = try encode(value)
        }
        try commit()
        for row in try db().fetch(FetchDescriptor<IntentRow>()) {
            let intent = try decode(FileIntent.self, from: row.value)
            guard intent.action == .finalize else { continue }
            if let value = try? read(intent.attemptID), value.epoch == intent.epoch,
               value.version == intent.expectedVersion, value.finishedAt == nil,
               date < value.recoveryDeadline, value.recording == nil {
                do {
                    if try files.recoverFinalization(intent.recording) { _ = try completeFinalization(intent) }
                    else {
                        var unavailable = value; unavailable.audio.state = .unavailable; unavailable.version += 1
                        try put(unavailable); try queueDeleteInstead(row, intent)
                    }
                } catch LearnerStorageError.integrityFailure {
                    var unavailable = value; unavailable.audio.state = .unavailable; unavailable.version += 1
                    try put(unavailable); try queueDeleteInstead(row, intent)
                }
            } else { try queueDeleteInstead(row, intent) }
        }
        try reconcileOrphans(); try maintain()
    }

    private func completeFinalization(_ intent: FileIntent) throws -> AttemptSnapshot {
        var value = try checked(intent.attemptID, intent.expectedVersion)
        guard value.epoch == intent.epoch, value.audio.state == .temporary, value.recording == nil,
              try files.isAvailable(intent.recording) else { throw LearnerStorageError.invalidState }
        value.recording = intent.recording; value.version += 1; try put(value)
        for row in try db().fetch(FetchDescriptor<IntentRow>()) where row.id == intent.id { try db().delete(row) }
        try commit(); return value
    }

    private func queueDeleteInstead(_ row: IntentRow, _ original: FileIntent) throws {
        var intent = original; intent.action = .delete; row.value = try encode(intent); try commit()
    }

    private func reconcileOrphans() throws {
        let attempts = try db().fetch(FetchDescriptor<AttemptRow>()).map { try decode(AttemptSnapshot.self, from: $0.snapshot) }
        let intents = try db().fetch(FetchDescriptor<IntentRow>()).map { try decode(FileIntent.self, from: $0.value) }
        let referenced = Set(attempts.compactMap { $0.recording?.relativePath } + attempts.compactMap {
            $0.pendingCaptureID.map { "staging/\($0.uuidString).wav" }
        } + intents.flatMap {
            [$0.recording.relativePath, "staging/\($0.recording.id.uuidString).wav"]
        })
        for path in try files.allAudioPaths() where !referenced.contains(path) {
            // Only our validated UUID file namespace may be removed. Unexpected names stop mutation.
            _ = try files.url(for: path)
            try files.remove(path)
        }
    }

    private func stripAudio(_ value: inout AttemptSnapshot) throws {
        if let capture = value.pendingCaptureID {
            let draft = RecordingSnapshot(id: capture, relativePath: "staging/\(capture.uuidString).wav",
                byteCount: 0, sha256: "", durationMilliseconds: 0, sampleRate: 0, channelCount: 0, bitsPerSample: 0)
            try insertIntent(FileIntent(action: .delete, attemptID: value.id, epoch: value.epoch,
                expectedVersion: value.version, recording: draft))
            value.pendingCaptureID = nil
        }
        if let recording = value.recording {
            try insertIntent(FileIntent(action: .delete, attemptID: value.id, epoch: value.epoch,
                                        expectedVersion: value.version, recording: recording))
        }
        value.recording = nil; value.audio = ComponentLifecycle(state: .purged)
    }

    private func stripText(_ value: inout AttemptSnapshot) {
        value.transcripts = []; value.feedback = []; value.requests = []
        value.text = ComponentLifecycle(state: .purged)
    }

    private func minimize(_ value: inout AttemptSnapshot) {
        if value.prompt.isPrivate { value.prompt.text = nil }
        value.preferences = nil
        value.practiceSessionID = nil; value.sourceLessonID = nil
        value.sourceLessonJourneyID = nil; value.speakingProvenance = nil
    }

    private func drainDeletes() throws {
        for row in try db().fetch(FetchDescriptor<IntentRow>()) {
            let intent = try decode(FileIntent.self, from: row.value)
            guard intent.action == .delete else { continue }
            try files.remove(intent.recording.relativePath)
            try files.remove("staging/\(intent.recording.id.uuidString).wav")
            try db().delete(row); try commit()
        }
    }

    private func visibleSnapshot(_ stored: AttemptSnapshot) throws -> AttemptSnapshot {
        var result = stored
        if !result.audio.isVisible { result.recording = nil }
        if !result.text.isVisible { result.transcripts = []; result.feedback = []; result.requests = [] }
        if !result.audio.isVisible && !result.text.isVisible { minimize(&result) }
        return result
    }

    private func checked(_ id: UUID, _ version: Int) throws -> AttemptSnapshot {
        let value = try read(id)
        guard value.epoch == (try state().epoch), value.version == version else { throw LearnerStorageError.staleVersion }
        return value
    }

    private func findDeletion(_ id: UUID) throws -> AttemptSnapshot {
        for row in try db().fetch(FetchDescriptor<AttemptRow>()) {
            let value = try decode(AttemptSnapshot.self, from: row.snapshot)
            if value.audio.deletionID == id || value.text.deletionID == id { return value }
        }
        throw LearnerStorageError.invalidReference
    }

    private func read(_ id: UUID) throws -> AttemptSnapshot { try decode(AttemptSnapshot.self, from: attemptRow(id).snapshot) }
    private func put(_ value: AttemptSnapshot) throws { try attemptRow(value.id).snapshot = encode(value) }
    private func attemptRow(_ id: UUID) throws -> AttemptRow {
        let row = try db().fetch(FetchDescriptor<AttemptRow>(predicate: #Predicate { $0.id == id })).first
        guard let row else { throw LearnerStorageError.invalidReference }; return row
    }
    private func state() throws -> StateRow {
        guard let value = try db().fetch(FetchDescriptor<StateRow>()).first else { throw LearnerStorageError.invalidState }
        return value
    }
    private func db() throws -> ModelContext {
        guard available(), let context else { throw LearnerStorageError.unavailable }; return context
    }
    private func effectiveNow() throws -> Date {
        let row = try state()
        let date = max(now(), row.lastObservedUTC, anchorDate.addingTimeInterval(max(0, uptime() - anchorUptime)))
        row.lastObservedUTC = date; return date
    }
    private func insertIntent(_ value: FileIntent) throws { try db().insert(IntentRow(id: value.id, value: encode(value))) }
    private func commit() throws {
        let db = try db()
        do { try beforeCommit?(); try db.save(); try files.protectTree() }
        catch { db.rollback(); throw LearnerStorageError.storageFailure }
    }
    private func encode<T: Encodable>(_ value: T) throws -> Data { try JSONEncoder().encode(value) }
    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T { try JSONDecoder().decode(type, from: data) }

    func practiceSuggestion(install: CurriculumInstall, calendar: Calendar = .current) throws -> PracticeSuggestion {
        try learningBoard(install: install, calendar: calendar).suggestion
    }

    func learningBoard(install: CurriculumInstall, calendar: Calendar = .current) throws -> LearningBoard {
        let stored = try document()
        let now = try effectiveNow()
        let attempts = try storedAttempts()
        let focus = PracticeRecommendation.selectLesson(journeys: stored.lessonJourneys, lessons: install.lessons, archivedLessons: install.archivedLessons)
        let grammar = PracticeRecommendation.grammarSignals(stored.lessonJourneys)
        let feedback = PracticeRecommendation.feedbackDates(attempts)
        let facts = PracticeFacts(
            now: now, dueReviewCount: try reviewQueue().due.count, lesson: focus.lesson, resuming: focus.resuming,
            recallMissedAt: PracticeRecommendation.latestMiss(stored.vocabularyRecalls),
            vocabularyFeedbackAt: feedback.vocabulary, assistedGrammarAt: grammar.dated,
            hasUndatedAssistedGrammar: grammar.undated, grammarFeedbackAt: feedback.grammar, savedChoice: stored.dailyChoice, goal: stored.practiceGoal,
            focusLesson: PracticeRecommendation.focusLesson(journeys: stored.lessonJourneys, install: install))
        let marks = stored.attemptFormats ?? []
        let candidates = LearningEvidence.candidates(attempts: attempts, marks: marks)
        let interval = calendar.dateInterval(of: .weekOfYear, for: now) ?? DateInterval(start: calendar.startOfDay(for: now), duration: 86_400)
        return LearningBoard(
            suggestion: PracticeRecommendation.suggest(facts, calendar: calendar),
            evidence: LearningEvidence.rows(
                recalls: stored.vocabularyRecalls, credits: stored.senseCredits,
                transferCount: candidates.filter { !$0.excluded && $0.format == .reservedTransfer }.count,
                checks: stored.lessonJourneys.compactMap(\.personalCheck)),
            confidence: ConfidenceStatement(note: stored.confidenceNote),
            links: LearningEvidence.links(candidates),
            week: LearningEvidence.week(LearningEvidence.activities(attempts: attempts, journeys: stored.lessonJourneys, recalls: stored.vocabularyRecalls), interval: interval))
    }

    func saveDailyChoice(_ action: SuggestionAction, difficulty: ObservedDifficulty? = nil, expectedEpoch: UUID? = nil) throws {
        if let expectedEpoch, expectedEpoch != (try state().epoch) { throw LearnerStorageError.invalidState }
        guard difficulty == nil || action == .openLesson else { throw LearnerStorageError.invalidState }
        var stored = try document()
        let choice = DailyPracticeChoice(day: PracticeRecommendation.localDay(try effectiveNow()), action: action, difficulty: difficulty)
        guard stored.dailyChoice != choice else { return }
        stored.dailyChoice = choice
        try write(stored)
    }

    func clearDailyChoice(expectedEpoch: UUID? = nil) throws {
        if let expectedEpoch, expectedEpoch != (try state().epoch) { throw LearnerStorageError.invalidState }
        var stored = try document()
        guard stored.dailyChoice != nil else { return }
        stored.dailyChoice = nil
        try write(stored)
    }

    func learningDataEpoch() throws -> UUID { try state().epoch }

    func rewardLedger() throws -> RewardLedger {
        let stored = try document()
        if let ledger = stored.rewards { return ledger }
        return RewardLedger(epoch: try learningDataEpoch(), startedAt: try effectiveNow())
    }

    func saveRewardSettings(_ settings: RewardSettings, expectedEpoch: UUID, expectedRevision: Int) throws {
        try settings.validate()
        try mutateRewards(epoch: expectedEpoch, revision: expectedRevision) { $0.settings = settings }
    }

    func purchaseReward(_ quote: RewardPurchase) throws {
        guard try learningDataEpoch() == quote.epoch else { throw LearnerStorageError.staleVersion }
        if quote.kind == .hint || quote.kind == .example {
            let parts = quote.context?.split(separator: "/").map(String.init) ?? []
            guard parts.count == 3, parts[0] == "intro-01", parts[1] == "4",
                  RewardAssistanceContent.forActivity(parts[2]) != nil else { throw RewardError.invalidRequest }
        }
        let stored = try rewardLedger()
        if stored.transactions.contains(where: { $0.id == quote.id.uuidString }) { return }
        let date = try effectiveNow()
        try mutateRewards(epoch: quote.epoch, revision: quote.revision) { try $0.purchase(quote, day: RewardPolicy.day(date), now: date) }
    }

    func acknowledgeRewards(_ ids: [String], epoch: UUID, revision: Int) throws {
        try mutateRewards(epoch: epoch, revision: revision) { ledger in
            let valid = Set(ledger.awards.map(\.id))
            ledger.acknowledged = Array(Set(ledger.acknowledged).union(ids.filter { valid.contains($0) })).sorted()
        }
    }

    func startRewardPlan(lessonID: String, contentVersion: String, epoch: UUID, revision: Int) throws {
        guard let lesson = CurriculumCatalogLoader.bundled.lesson(id: lessonID, version: contentVersion), lesson.isReady,
              AwardFamily.supports(lessonID: lessonID, version: contentVersion) else { throw RewardError.invalidRequest }
        let date = try effectiveNow()
        try mutateRewards(epoch: epoch, revision: revision) { try $0.startPlan(lesson: lesson, day: RewardPolicy.day(date), now: date) }
    }

    func addRewardActiveTime(seconds: Double, day: String, epoch: UUID, sampleID: UUID = UUID()) throws {
        guard seconds.isFinite, seconds > 0, seconds <= RewardPolicy.inactivitySeconds,
              RewardPolicy.ordinal(day) != nil, day <= RewardPolicy.day(try effectiveNow()) else { throw RewardError.invalidRequest }
        let ledger = try rewardLedger()
        try mutateRewards(epoch: epoch, revision: ledger.revision) { value in
            guard !value.timeSampleIDs.contains(sampleID) else { return }
            value.timeSampleIDs.append(sampleID)
            value.activeSeconds[day, default: 0] += seconds
        }
    }

    func refreshRewardContinuity(epoch: UUID, revision: Int) throws {
        let date = try effectiveNow()
        try mutateRewards(epoch: epoch, revision: revision) { value in
            let day = RewardPolicy.day(date)
            try value.acceptDay(day)
            if value.settings.autoFreeze { value.protectMissedDays(endingAt: day, now: date) }
        }
    }

    private func mutateRewards(epoch: UUID, revision: Int, _ change: (inout RewardLedger) throws -> Void) throws {
        guard try learningDataEpoch() == epoch else { throw LearnerStorageError.staleVersion }
        var stored = try document()
        var ledger = try stored.rewards ?? RewardLedger(epoch: epoch, startedAt: effectiveNow())
        guard ledger.epoch == epoch, ledger.revision == revision else { throw RewardError.stale }
        let original = ledger
        try change(&ledger)
        guard ledger != original else { return }
        ledger.revision += 1
        stored.rewards = ledger
        try write(stored)
    }

    private func reconcileRewards(previous: LearnerDocument, next: inout LearnerDocument) throws {
        let epoch = try learningDataEpoch(), date = try effectiveNow(), day = RewardPolicy.day(date)
        var ledger = next.rewards ?? RewardLedger(epoch: epoch, startedAt: date)
        guard ledger.epoch == epoch else { throw LearnerStorageError.staleVersion }
        let initial = ledger
        for journey in next.lessonJourneys where journey.personalCheck == nil {
            guard let lesson = CurriculumCatalogLoader.bundled.lesson(id: journey.lessonID, version: journey.contentVersion)
                ?? IntroPracticePack.allCases.first(where: { $0.id == journey.lessonID && $0.lesson.contentVersion == journey.contentVersion })?.lesson,
                  lesson.isReady, lesson.objectiveId == journey.objectiveID,
                  AwardFamily.supports(lessonID: lesson.id, version: lesson.contentVersion) else { continue }
            let prior = previous.lessonJourneys.first { $0.id == journey.id }
            for response in journey.responses {
                guard let task = lesson.sessionActivities.first(where: { $0.id == response.activityID && $0.kind == response.kind }), task.kind != "selfReview",
                      response.firstResponseText != nil || response.participatedWithoutText == true || response.recordedPracticeID != nil else { continue }
                let old = prior?.responses.first { $0.activityID == response.activityID }
                let reviewed = response.answerRevealed || (task.kind == "guidedSpeaking" && journey.completedAt != nil)
                let wasReviewed = old?.answerRevealed == true || (task.kind == "guidedSpeaking" && prior?.completedAt != nil)
                guard reviewed && !wasReviewed else { continue }
                let source = "lesson/\(journey.id)/\(task.id)"
                let activity = "\(lesson.id)/\(lesson.contentVersion)/\(task.id)"
                do { try ledger.credit(source: source, activity: activity, kind: "exercise", day: day, now: date) }
                catch RewardError.clockChanged { continue } // Clock anomalies never block learning persistence.
            }
            if journey.completedAt != nil, prior?.completedAt == nil, journey.practiceOrigin != nil {
                let family = ["intro-01-pack-teacher": "AW-TR-01C", "intro-01-pack-grammarian": "AW-TR-02C", "intro-01-pack-journalist": "AW-TR-04C"][journey.lessonID]
                if let family {
                    var verified = try LessonSession.begin(lesson: lesson, presenter: journey.presenter, now: date, existing: journey)
                    verified.journey.completedAt = nil
                    if (try? verified.finish(now: date)) != nil { ledger.award(family, now: date, evidence: [journey.id.uuidString]) }
                }
            }
            if journey.completedAt != nil, prior?.completedAt == nil, journey.practiceOrigin == nil {
                var verified = try LessonSession.begin(lesson: lesson, presenter: journey.presenter, now: date, existing: journey)
                verified.journey.completedAt = nil
                if (try? verified.finish(now: date)) != nil {
                    for task in lesson.sessionActivities where task.kind == "selfReview" {
                        let source = "lesson/\(journey.id)/\(task.id)"
                        if !ledger.transactions.contains(where: { $0.source == source }) {
                            ledger.transactions.append(RewardTransaction(id: "completion/" + source, source: source,
                                activity: "\(lesson.id)/\(lesson.contentVersion)/\(task.id)", day: day, createdAt: date,
                                xp: 0, gold: 0, reason: "Required final self-review completed · included, no extra payout", kind: "completion", multiplier: 0))
                        }
                    }
                    ledger.completePlans(now: date)
                    if journey.objectiveID == "INTRO-01" { ledger.award("AW-P-02", now: date, evidence: [journey.id.uuidString]) }
                    ledger.award("AW-P-03", now: date, evidence: [journey.id.uuidString])
                    let checkpoint = RewardCheckpoint(lessonID: lesson.id, version: lesson.contentVersion, journeyID: journey.id, completedAt: date)
                    if !ledger.checkpoints.contains(where: { $0.lessonID == lesson.id && $0.version == lesson.contentVersion }) { ledger.checkpoints.append(checkpoint) }
                }
            }
        }
        // Explicit rated reviews use the schedule's fresh due opportunity, never a reveal alone.
        let priorIDs = Set(previous.vocabularyRecalls.map(\.id))
        for attempt in next.vocabularyRecalls where !priorIDs.contains(attempt.id) {
            let activity = "sense/\(attempt.itemId)/\(attempt.senseId)"
            let oldCard = previous.reviewCards.first { $0.itemId == attempt.itemId && $0.senseId == attempt.senseId }
            let fresh = oldCard.map { $0.due <= date } ?? true
            do { try ledger.credit(source: "review/\(attempt.sourceEventID ?? attempt.id)", activity: activity, kind: "review", day: day, now: date, freshReview: fresh) }
            catch RewardError.clockChanged { continue }
        }
        if ledger != initial { ledger.revision += 1; next.rewards = ledger }
    }

    /// Levels the learner opened by passing the jump test. Kept in the learner document; no schema migration.
    func passedJumpTests() throws -> Set<String> { Set(try document().passedJumpTests ?? []) }

    func recordJumpTestPass(level: String) throws {
        let level = level.uppercased()
        guard LevelGate.levels.dropFirst().contains(level) else { throw LearnerStorageError.invalidContent }
        var stored = try document()
        var passed = stored.passedJumpTests ?? []
        if !passed.contains(level) { passed.append(level) }
        stored.passedJumpTests = passed
        try write(stored)
    }

    // MARK: Lexicon (v2)

    func lexiconState() throws -> LexiconState { try document().lexicon ?? LexiconState() }

    func saveLexiconState(_ state: LexiconState) throws {
        var stored = try document()
        guard stored.lexicon != state else { return }
        stored.lexicon = state
        try write(stored)
    }

    /// Stage of every bank word from its card and latest rating.
    func lexiconStages(bank: LexiconBank) throws -> [String: LexiconStage] {
        let stored = try document()
        return LexiconLedger.stages(bank: bank, cards: stored.reviewCards, recalls: stored.vocabularyRecalls)
    }

    /// Enrolls today's new words for Daily Training. Words already enrolled are left alone.
    @discardableResult
    func startLexiconWords(_ words: [LexiconWord], bankVersion: String) throws -> [VocabularyEnrollment] {
        guard !words.isEmpty else { return [] }
        var stored = try document()
        let now = try effectiveNow()
        var started: [VocabularyEnrollment] = []
        for word in words where !stored.vocabularyEnrollments.contains(where: { $0.itemId == word.itemId && $0.senseId == LexiconWord.senseId }) {
            let enrollment = LexiconTrainingPlan.enrollment(for: word, bankVersion: bankVersion, now: now)
            stored.vocabularyEnrollments.append(enrollment)
            started.append(enrollment)
        }
        if !started.isEmpty { try write(stored) }
        return started
    }

    /// Saves one Lexicon in Action answer. A miss sends the word back to Daily Training with a Hard rating.
    func recordLexiconAction(word: LexiconWord, correct: Bool) throws {
        let now = try effectiveNow()
        if !correct, let card = try document().vocabularyEnrollments.first(where: { $0.itemId == word.itemId && $0.senseId == LexiconWord.senseId }) {
            _ = try recordVocabularyRecall(card: card, rating: .hard, draft: RecallDraft(revealed: true))
        }
        try saveLexiconState(LexiconActionBuilder.updated(try lexiconState(), wordID: word.id, correct: correct, now: now))
    }

    func wordOfDayRecord() throws -> WordOfDayRecord? { try document().wordOfDay }

    /// Storage only; this does not select a sense or adopt a repeat/day rule.
    func saveWordOfDayRecord(_ record: WordOfDayRecord, expectedEpoch: UUID,
                             replacing expected: WordOfDayRecord?) throws {
        guard try learningDataEpoch() == expectedEpoch else { throw LearnerStorageError.staleVersion }
        var stored = try document()
        guard stored.wordOfDay == expected else { throw LearnerStorageError.staleVersion }
        guard record.learnerEpoch == expectedEpoch else { throw LearnerStorageError.invalidContent }
        if let shown = record.shown {
            let sense = DailySense(itemID: shown.itemID, senseID: shown.senseID, lemma: shown.lemma,
                example: shown.example, meaning: shown.meaning, qualifiedRecord: shown.qualifiedRecord,
                personalUsePreview: false, generatedUnreviewed: false)
            guard DailySenseEligibility.allows(sense), !shown.localDay.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw LearnerStorageError.invalidContent
            }
        }
        // An existing pin cannot be rewritten or rotated through a storage bypass.
        if let previous = stored.wordOfDay?.shown, record.shown != previous {
            throw LearnerStorageError.invalidContent
        }
        stored.wordOfDay = record
        try write(stored)
    }

    func generatedPracticeRecord() throws -> GeneratedPracticeRecord? {
        var stored = try document()
        guard var record = stored.generatedPractice else { return nil }
        let before = record
        let date = try effectiveNow()
        record.cache.entries.removeAll { date >= $0.expiresAt }
        record.reports.removeAll { date >= $0.expiresAt || $0.status == .deleted || $0.status == .retentionExpired }
        if record != before { stored.generatedPractice = record; try write(stored) }
        return record
    }

    func saveGeneratedPracticeRecord(_ record: GeneratedPracticeRecord, expectedEpoch: UUID,
                                     replacing expected: GeneratedPracticeRecord?) throws {
        guard try learningDataEpoch() == expectedEpoch else { throw LearnerStorageError.staleVersion }
        var stored = try document()
        guard stored.generatedPractice == expected else { throw LearnerStorageError.staleVersion }
        guard record.schemaVersion == GeneratedPracticeSchema.version, record.learnerEpoch == expectedEpoch,
              Set(record.cache.entries.map(\.id)).count == record.cache.entries.count,
              Set(record.frozenAttempts.map(\.id)).count == record.frozenAttempts.count,
              Set(record.reports.map(\.id)).count == record.reports.count,
              record.reports.allSatisfy({
                  !$0.learnerResponseIncluded && !$0.remoteSubmission && !$0.correctionPublished && !$0.transmitsOffDevice
                      && $0.status == .recordedLocally && $0.schemaVersion == GeneratedPracticeSchema.version
              }),
              record.cache.entries.allSatisfy({ $0.text == nil || ($0.retention == .optedIn && !$0.privatePayloadDeleted) }),
              record.frozenAttempts.allSatisfy({
                  !$0.countsAsComparableAssessment && !$0.qualifiedEducatorReviewed
                      && ($0.text == nil || $0.retention == .optedIn)
              }) else { throw LearnerStorageError.invalidContent }
        let previousRemoved = Set(stored.generatedPractice?.cache.deletedVariantIDs ?? [])
        let removed = Set(record.cache.deletedVariantIDs)
        guard previousRemoved.isSubset(of: removed),
              record.cache.entries.allSatisfy({ !removed.contains($0.id) || $0.text == nil }),
              record.frozenAttempts.allSatisfy({ !removed.contains($0.variantID) || $0.text == nil }) else {
            throw LearnerStorageError.invalidContent
        }
        stored.generatedPractice = record
        try write(stored)
    }

    func learningResources() throws -> [LearningResource] { try document().learningResources ?? [] }

    @discardableResult
    func saveLearningResource(_ draft: ResourceEditorDraft) throws -> LearningResource {
        guard try learningDataEpoch() == draft.epoch else { throw LearnerStorageError.staleVersion }
        let link = try ResourceLink(draft.destination)
        let title = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { throw ResourceLinkError.titleRequired }
        var stored = try document()
        var resources = stored.learningResources ?? []
        let index = resources.firstIndex { $0.id == draft.id }
        if let original = draft.original {
            guard let index else { throw ResourceLinkError.missing }
            guard resources[index] == original else { throw ResourceLinkError.changed }
        } else if index != nil { throw ResourceLinkError.changed }
        guard !resources.contains(where: { $0.id != draft.id && $0.destination == link.canonical }) else {
            throw ResourceLinkError.duplicate
        }
        let curated = CuratedLearningResource.catalog.first {
            $0.id == draft.curatedID && (try? ResourceLink($0.destination)) == link
        }
        let value = LearningResource(id: draft.id, revision: (draft.original?.revision ?? 0) + 1,
            title: title, destination: link.canonical,
            topic: draft.topic.trimmingCharacters(in: .whitespacesAndNewlines), notes: draft.notes,
            curatedID: curated?.id, curatedVersion: curated?.version, updatedAt: now())
        if let index { resources[index] = value } else { resources.append(value) }
        stored.learningResources = resources
        try write(stored)
        return value
    }

    func deleteLearningResource(_ resource: LearningResource, expectedEpoch: UUID) throws {
        guard try learningDataEpoch() == expectedEpoch else { throw LearnerStorageError.staleVersion }
        var stored = try document()
        guard let index = stored.learningResources?.firstIndex(where: { $0.id == resource.id }) else {
            throw ResourceLinkError.missing
        }
        guard stored.learningResources?[index] == resource else { throw ResourceLinkError.changed }
        stored.learningResources?.remove(at: index)
        try write(stored)
    }

    /// Revalidate the exact displayed destination immediately before handing it to the system.
    func resourceDestination(_ intent: ResourceOpenIntent) throws -> URL {
        guard try learningDataEpoch() == intent.epoch else { throw LearnerStorageError.staleVersion }
        if let bookmark = intent.bookmark {
            guard try learningResources().contains(bookmark), bookmark.destination == intent.link.canonical else {
                throw ResourceLinkError.changed
            }
        }
        return try ResourceLink(intent.link.canonical).url
    }

    func saveConfidenceNote(_ raw: String?, expectedEpoch: UUID? = nil) throws {
        if let expectedEpoch, expectedEpoch != (try state().epoch) { throw LearnerStorageError.invalidState }
        var stored = try document()
        let note = ConfidenceStatement.normalize(raw)
        guard stored.confidenceNote != note else { return }
        stored.confidenceNote = note
        try write(stored)
    }

    func attemptFormat(_ id: UUID) throws -> ComparisonFormat? {
        try document().attemptFormats?.first { $0.attemptID == id }?.format
    }

    func setAttemptFormat(_ id: UUID, _ format: ComparisonFormat?) throws {
        _ = try read(id)
        var stored = try document()
        var marks = stored.attemptFormats ?? []
        marks.removeAll { $0.attemptID == id }
        if let format { marks.append(AttemptFormatMark(attemptID: id, format: format)) }
        stored.attemptFormats = marks.isEmpty ? nil : marks
        try write(stored)
    }

    func speakingPractice(_ kind: String) throws -> SpeakingPracticeArchive? {
        let date = try effectiveNow()
        var stored = try document()
        guard let saved = stored.speakingPracticeArchives?.first(where: { $0.kind == kind }) else { return nil }
        if let expiry = saved.expiresAt, date >= expiry {
            stored.speakingPracticeArchives?.removeAll { $0.kind == kind }
            try write(stored)
            return nil
        }
        var recovered = saved
        recovered.resolveInterruptedRequest(now: date)
        return recovered
    }

    func saveSpeakingPractice(_ archive: SpeakingPracticeArchive, expectedEpoch: UUID) throws {
        guard try learningDataEpoch() == expectedEpoch else { throw LearnerStorageError.staleVersion }
        let valid: Bool
        switch archive.kind {
        case "conversation": valid = archive.conversation != nil && archive.interview == nil && archive.communication == nil
        case "interview": valid = archive.interview != nil && archive.conversation == nil && archive.communication == nil
        default:
            valid = archive.communication.map { $0.archiveKind == archive.kind } == true
                && archive.conversation == nil && archive.interview == nil
        }
        guard valid else { throw LearnerStorageError.invalidContent }
        var stored = try document()
        var values = stored.speakingPracticeArchives ?? []
        values.removeAll { $0.kind == archive.kind }
        values.append(archive); stored.speakingPracticeArchives = values
        try write(stored)
    }

    func removeSpeakingPractice(_ kind: String, expectedEpoch: UUID) throws {
        guard try learningDataEpoch() == expectedEpoch else { throw LearnerStorageError.staleVersion }
        var stored = try document()
        stored.speakingPracticeArchives?.removeAll { $0.kind == kind }
        try write(stored)
    }

    /// Acts only on recordings attributed to this independent practice session.
    func discardSpeakingPracticeAudio(_ references: [UUID], sessionID: UUID, expectedEpoch: UUID) throws {
        guard try learningDataEpoch() == expectedEpoch else { throw LearnerStorageError.staleVersion }
        // Validate all supplied references before changing any recording.
        for id in Set(references) {
            let value = try attempt(id)
            guard !value.audio.isVisible || (value.speakingProvenance?.journeyID == sessionID &&
                ["conversationTurn", "interviewTurn", "communicationTurn"].contains(value.speakingProvenance?.purpose ?? "")) else {
                throw LearnerStorageError.invalidReference
            }
        }
        // Include replaced/abandoned slots as well as the currently attached take.
        let owned = try storedAttempts().filter {
            $0.speakingProvenance?.journeyID == sessionID &&
            ["conversationTurn", "interviewTurn", "communicationTurn"].contains($0.speakingProvenance?.purpose ?? "")
        }
        for value in owned {
            if value.audio.state == .saved {
                let deletions = try softDelete(value.id, scope: .audio, expectedVersion: value.version)
                for deletion in deletions { let latest = try attempt(value.id); try purge(deletion, expectedVersion: latest.version) }
            } else if value.audio.state == .temporary {
                try discardTemporary(value.id, expectedVersion: value.version)
            } else if value.audio.state == .recentlyDeleted, let deletion = value.audio.deletionID {
                try purge(deletion, expectedVersion: value.version)
            }
        }
    }

    func clearSpeakingPracticePrivatePrompts(sessionID: UUID, expectedEpoch: UUID) throws {
        guard try learningDataEpoch() == expectedEpoch else { throw LearnerStorageError.staleVersion }
        for var value in try storedAttempts() where value.speakingProvenance?.journeyID == sessionID &&
            ["conversationTurn", "interviewTurn", "communicationTurn"].contains(value.speakingProvenance?.purpose ?? "") {
            guard value.prompt.isPrivate, value.prompt.text != nil else { continue }
            value.prompt.text = nil; value.version += 1
            try put(value)
        }
        try commit()
    }

    private func storedAttempts() throws -> [AttemptSnapshot] {
        try db().fetch(FetchDescriptor<AttemptRow>()).map { try decode(AttemptSnapshot.self, from: $0.snapshot) }
    }

    /// Older installs stored LearnerPreferences directly in this column. New writes use the document
    /// so lesson progress can resume without a SwiftData migration.
    private struct LearnerDocument: Codable, Equatable {
        var preferences: LearnerPreferences
        var lessonJourneys: [LessonJourney]
        var vocabularyEnrollments: [VocabularyEnrollment]
        var vocabularyExposures: [VocabularyExposure]
        var customTopics: [CustomVocabularyTopic]
        var vocabularyRecalls: [VocabularyRecallAttempt]
        var reviewCards: [ReviewCardState]
        var senseCredits: [SenseCreditEvent]
        var openRecall: OpenRecall?
        var dailyChoice: DailyPracticeChoice?
        var confidenceNote: String?
        var attemptFormats: [AttemptFormatMark]?
        var reviewSettings: ReviewSettings?
        var practiceGoal: SuggestionAction?
        var speakingPracticeArchives: [SpeakingPracticeArchive]? = nil
        var learningResources: [LearningResource]? = nil
        var generatedPractice: GeneratedPracticeRecord? = nil
        var wordOfDay: WordOfDayRecord? = nil
        var rewards: RewardLedger? = nil
        /// v2: levels opened by a perfect jump test, for example ["A2"].
        var passedJumpTests: [String]? = nil
        /// v2: Lexicon groups, daily word and Lexicon in Action progress.
        var lexicon: LexiconState? = nil

        init(preferences: LearnerPreferences, lessonJourneys: [LessonJourney] = [],
             vocabularyEnrollments: [VocabularyEnrollment] = [], vocabularyExposures: [VocabularyExposure] = [],
             customTopics: [CustomVocabularyTopic] = [], vocabularyRecalls: [VocabularyRecallAttempt] = [],
             reviewCards: [ReviewCardState] = [], senseCredits: [SenseCreditEvent] = [], openRecall: OpenRecall? = nil,
             dailyChoice: DailyPracticeChoice? = nil, confidenceNote: String? = nil, attemptFormats: [AttemptFormatMark]? = nil, reviewSettings: ReviewSettings? = nil, practiceGoal: SuggestionAction? = nil) {
            self.preferences = preferences
            self.lessonJourneys = lessonJourneys
            self.vocabularyEnrollments = vocabularyEnrollments
            self.vocabularyExposures = vocabularyExposures
            self.customTopics = customTopics
            self.vocabularyRecalls = vocabularyRecalls
            self.reviewCards = reviewCards
            self.senseCredits = senseCredits
            self.openRecall = openRecall
            self.dailyChoice = dailyChoice
            self.confidenceNote = confidenceNote
            self.attemptFormats = attemptFormats
            self.reviewSettings = reviewSettings
            self.practiceGoal = practiceGoal
        }

        private enum CodingKeys: String, CodingKey {
            case preferences, lessonJourneys, vocabularyEnrollments, vocabularyExposures, customTopics, vocabularyRecalls, reviewCards, senseCredits, openRecall, dailyChoice, confidenceNote, attemptFormats, reviewSettings, practiceGoal, speakingPracticeArchives, learningResources, generatedPractice, wordOfDay, rewards, passedJumpTests, lexicon
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            preferences = try container.decode(LearnerPreferences.self, forKey: .preferences)
            lessonJourneys = try container.decodeIfPresent([LessonJourney].self, forKey: .lessonJourneys) ?? []
            vocabularyEnrollments = try container.decodeIfPresent([VocabularyEnrollment].self, forKey: .vocabularyEnrollments) ?? []
            vocabularyExposures = try container.decodeIfPresent([VocabularyExposure].self, forKey: .vocabularyExposures) ?? []
            customTopics = try container.decodeIfPresent([CustomVocabularyTopic].self, forKey: .customTopics) ?? []
            vocabularyRecalls = try container.decodeIfPresent([VocabularyRecallAttempt].self, forKey: .vocabularyRecalls) ?? []
            reviewCards = try container.decodeIfPresent([ReviewCardState].self, forKey: .reviewCards) ?? []
            senseCredits = try container.decodeIfPresent([SenseCreditEvent].self, forKey: .senseCredits) ?? []
            openRecall = try container.decodeIfPresent(OpenRecall.self, forKey: .openRecall)
            dailyChoice = try container.decodeIfPresent(DailyPracticeChoice.self, forKey: .dailyChoice)
            confidenceNote = try container.decodeIfPresent(String.self, forKey: .confidenceNote)
            attemptFormats = try container.decodeIfPresent([AttemptFormatMark].self, forKey: .attemptFormats)
            reviewSettings = try container.decodeIfPresent(ReviewSettings.self, forKey: .reviewSettings)
            practiceGoal = try container.decodeIfPresent(SuggestionAction.self, forKey: .practiceGoal)
            speakingPracticeArchives = try container.decodeIfPresent([SpeakingPracticeArchive].self, forKey: .speakingPracticeArchives)
            learningResources = try container.decodeIfPresent([LearningResource].self, forKey: .learningResources)
            generatedPractice = try container.decodeIfPresent(GeneratedPracticeRecord.self, forKey: .generatedPractice)
            wordOfDay = try container.decodeIfPresent(WordOfDayRecord.self, forKey: .wordOfDay)
            rewards = try container.decodeIfPresent(RewardLedger.self, forKey: .rewards)
            passedJumpTests = try container.decodeIfPresent([String].self, forKey: .passedJumpTests)
            lexicon = try container.decodeIfPresent(LexiconState.self, forKey: .lexicon)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(preferences, forKey: .preferences)
            try container.encode(lessonJourneys, forKey: .lessonJourneys)
            try container.encode(vocabularyEnrollments, forKey: .vocabularyEnrollments)
            try container.encode(vocabularyExposures, forKey: .vocabularyExposures)
            try container.encode(customTopics, forKey: .customTopics)
            try container.encode(vocabularyRecalls, forKey: .vocabularyRecalls)
            try container.encode(reviewCards, forKey: .reviewCards)
            try container.encode(senseCredits, forKey: .senseCredits)
            try container.encodeIfPresent(openRecall, forKey: .openRecall)
            try container.encodeIfPresent(dailyChoice, forKey: .dailyChoice)
            try container.encodeIfPresent(confidenceNote, forKey: .confidenceNote)
            try container.encodeIfPresent(attemptFormats, forKey: .attemptFormats)
            try container.encodeIfPresent(reviewSettings, forKey: .reviewSettings)
            try container.encodeIfPresent(practiceGoal, forKey: .practiceGoal)
            try container.encodeIfPresent(speakingPracticeArchives, forKey: .speakingPracticeArchives)
            try container.encodeIfPresent(learningResources, forKey: .learningResources)
            try container.encodeIfPresent(generatedPractice, forKey: .generatedPractice)
            try container.encodeIfPresent(wordOfDay, forKey: .wordOfDay)
            try container.encodeIfPresent(rewards, forKey: .rewards)
            try container.encodeIfPresent(passedJumpTests, forKey: .passedJumpTests)
            try container.encodeIfPresent(lexicon, forKey: .lexicon)
        }

        func customLibrary() -> CustomVocabularyLibrary {
            CustomVocabularyLibrary(topics: customTopics, enrollments: vocabularyEnrollments)
        }
    }

    private func document() throws -> LearnerDocument {
        let data = try state().preferences
        let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        if object?["preferences"] != nil { return try decode(LearnerDocument.self, from: data) }
        return LearnerDocument(preferences: try decode(LearnerPreferences.self, from: data))
    }

    private func write(_ document: LearnerDocument) throws {
        var candidate = document
        try reconcileRewards(previous: self.document(), next: &candidate)
        try state().preferences = encode(candidate); try commit()
        if let ledger = candidate.rewards {
            RewardReminderScheduler.cancelIfGoalMet(ledger: ledger)
            NotificationCenter.default.post(name: .rewardLedgerChanged, object: nil)
        }
    }
}
