import Foundation
import SwiftData
import UIKit

/// Main-actor ownership serializes all mutation. No model/context escapes this boundary.
final class LearnerRepository {
    typealias StateRow = LearnerSchemaV1.StateRow
    typealias AttemptRow = LearnerSchemaV1.AttemptRow
    typealias IntentRow = LearnerSchemaV1.FileIntentRow
    private var container: ModelContainer?
    private var context: ModelContext?
    let files: PrivateFileStore
    let now: () -> Date
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

    func visibleSnapshot(_ stored: AttemptSnapshot) throws -> AttemptSnapshot {
        var result = stored
        if !result.audio.isVisible { result.recording = nil }
        if !result.text.isVisible { result.transcripts = []; result.feedback = []; result.requests = [] }
        if !result.audio.isVisible && !result.text.isVisible { minimize(&result) }
        return result
    }

    func checked(_ id: UUID, _ version: Int) throws -> AttemptSnapshot {
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

    func read(_ id: UUID) throws -> AttemptSnapshot { try decode(AttemptSnapshot.self, from: attemptRow(id).snapshot) }
    func put(_ value: AttemptSnapshot) throws { try attemptRow(value.id).snapshot = encode(value) }
    func attemptRow(_ id: UUID) throws -> AttemptRow {
        let row = try db().fetch(FetchDescriptor<AttemptRow>(predicate: #Predicate { $0.id == id })).first
        guard let row else { throw LearnerStorageError.invalidReference }; return row
    }
    func state() throws -> StateRow {
        guard let value = try db().fetch(FetchDescriptor<StateRow>()).first else { throw LearnerStorageError.invalidState }
        return value
    }
    func db() throws -> ModelContext {
        guard available(), let context else { throw LearnerStorageError.unavailable }; return context
    }
    func effectiveNow() throws -> Date {
        let row = try state()
        let date = max(now(), row.lastObservedUTC, anchorDate.addingTimeInterval(max(0, uptime() - anchorUptime)))
        row.lastObservedUTC = date; return date
    }
    private func insertIntent(_ value: FileIntent) throws { try db().insert(IntentRow(id: value.id, value: encode(value))) }
    func commit() throws {
        let db = try db()
        do { try beforeCommit?(); try db.save(); try files.protectTree() }
        catch { db.rollback(); throw LearnerStorageError.storageFailure }
    }
    func encode<T: Encodable>(_ value: T) throws -> Data { try JSONEncoder().encode(value) }
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T { try JSONDecoder().decode(type, from: data) }

    func learningDataEpoch() throws -> UUID { try state().epoch }

    func storedAttempts() throws -> [AttemptSnapshot] {
        try db().fetch(FetchDescriptor<AttemptRow>()).map { try decode(AttemptSnapshot.self, from: $0.snapshot) }
    }

/// Repository-internal: members below are shared by the LearnerRepository extension files only.
    func document() throws -> LearnerDocument {
        let data = try state().preferences
        let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        if object?["preferences"] != nil { return try decode(LearnerDocument.self, from: data) }
        return LearnerDocument(preferences: try decode(LearnerPreferences.self, from: data))
    }

    func write(_ document: LearnerDocument) throws {
        var candidate = document
        try reconcileRewards(previous: self.document(), next: &candidate)
        try state().preferences = encode(candidate); try commit()
        if let ledger = candidate.rewards {
            RewardReminderScheduler.cancelIfGoalMet(ledger: ledger)
            NotificationCenter.default.post(name: .rewardLedgerChanged, object: nil)
        }
    }
}
