import Foundation
import Testing
@testable import SpeechCoachAI

@Suite(.serialized)
struct LearnerRepositoryTests {
    private func root() -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("SC-T009-\(UUID().uuidString)")
    }
    private func prompt() -> PromptSnapshot {
        PromptSnapshot(id: "intro", version: "1", objectiveID: "INTRO-01", text: "Synthetic private prompt",
                       isPrivate: true, selectedLevel: "A1")
    }
    private func store(_ url: URL) throws -> LearnerRepository {
        try LearnerRepository(root: url, protectedDataAvailable: { true })
    }
    private func withAudio(_ repo: LearnerRepository) throws -> AttemptSnapshot {
        let a = try repo.createAttempt(prompt: prompt())
        return try repo.finalizeRecording(attemptID: a.id, data: Data([1, 2, 3, 4]),
            durationMilliseconds: 1000, sampleRate: 44_100, channels: 1, bitsPerSample: 16, expectedVersion: a.version)
    }
    private func withText(_ repo: LearnerRepository, _ attempt: AttemptSnapshot) throws -> AttemptSnapshot {
        let t = TranscriptSnapshot(id: UUID(), revision: 1, kind: .asrOriginal, text: "Synthetic introduction.",
                                   createdAt: Date(), provider: "fixture", model: "fixture", region: "fixture")
        try repo.appendTranscript(t, token: repo.token(for: attempt.id))
        return try repo.attempt(attempt.id)
    }

    @Test func settingsAndSavedStateSurviveReopen() throws {
        let url = root(); defer { try? FileManager.default.removeItem(at: url) }
        var repo: LearnerRepository? = try store(url)
        var preferences = LearnerPreferences(); preferences.background = .adventureAtlas; preferences.appearance = .dark
        try repo!.savePreferences(preferences)
        let a = try withAudio(repo!)
        let saved = try repo!.saveSelection(a.id, keepAudio: true, keepText: false, expectedVersion: a.version)
        repo!.close(); repo = nil
        let reopened = try store(url)
        #expect(try reopened.preferences() == preferences)
        let value = try reopened.attempt(saved.id)
        #expect(value.recording == saved.recording)
        #expect(value.audio.state == .saved)
        #expect(value.text.state == .purged)
    }

    @Test(arguments: [(false, false), (true, false), (false, true), (true, true)])
    func independentRetention(choices: (Bool, Bool)) throws {
        let url = root(); defer { try? FileManager.default.removeItem(at: url) }
        let repo = try store(url)
        let a = try withText(repo, withAudio(repo))
        let value = try repo.saveSelection(a.id, keepAudio: choices.0, keepText: choices.1, expectedVersion: a.version)
        #expect((value.recording != nil) == choices.0)
        #expect(!value.transcripts.isEmpty == choices.1)
        #expect(value.audio.state == (choices.0 ? .saved : .purged))
        #expect(value.text.state == (choices.1 ? .saved : .purged))
        if !choices.0 && !choices.1 { #expect(value.prompt.text == nil); #expect(value.preferences == nil) }
        let disk = try FileManager.default.contentsOfDirectory(atPath: url.appendingPathComponent("audio").path)
        #expect(disk.count == (choices.0 ? 1 : 0))
    }

    @Test func failedMetadataCommitDoesNotReportSaveAndDraftSurvives() throws {
        let url = root(); defer { try? FileManager.default.removeItem(at: url) }
        let repo = try store(url); let a = try withAudio(repo)
        repo.beforeCommit = { throw LearnerStorageError.storageFailure }
        #expect(throws: LearnerStorageError.storageFailure) {
            try repo.saveSelection(a.id, keepAudio: true, keepText: false, expectedVersion: a.version)
        }
        repo.beforeCommit = nil
        let value = try repo.attempt(a.id)
        #expect(value.finishedAt == nil)
        #expect(value.audio.state == .temporary)
        #expect(value.recording != nil)
    }

    @Test func interruptedRenameRecoversDurableJournalAfterReopen() throws {
        let url = root(); defer { try? FileManager.default.removeItem(at: url) }
        let files = try PrivateFileStore(root: url)
        var repo: LearnerRepository? = try LearnerRepository(root: url, protectedDataAvailable: { true }, fileStore: files)
        let a = try repo!.createAttempt(prompt: prompt())
        files.beforeOperation = { if $0 == .rename { throw LearnerStorageError.storageFailure } }
        #expect(throws: LearnerStorageError.storageFailure) {
            try repo!.finalizeRecording(attemptID: a.id, data: Data([1, 2]), durationMilliseconds: 1000,
                sampleRate: 44_100, channels: 1, bitsPerSample: 16, expectedVersion: a.version)
        }
        #expect(try repo!.pendingFileWorkCount() == 1)
        repo!.close(); repo = nil; files.beforeOperation = nil
        let reopened = try store(url)
        let recovered = try reopened.recoverableAttempts()
        #expect(recovered.count == 1)
        #expect(recovered.first?.recording != nil)
        #expect(try reopened.pendingFileWorkCount() == 0)
    }

    @Test func failedFileWriteLeavesNoSuccessfulRecording() throws {
        let url = root(); defer { try? FileManager.default.removeItem(at: url) }
        let files = try PrivateFileStore(root: url)
        let repo = try LearnerRepository(root: url, protectedDataAvailable: { true }, fileStore: files)
        let a = try repo.createAttempt(prompt: prompt())
        files.beforeOperation = { if $0 == .write { throw LearnerStorageError.storageFailure } }
        #expect(throws: LearnerStorageError.storageFailure) {
            try repo.finalizeRecording(attemptID: a.id, data: Data([1]), durationMilliseconds: 1000,
                sampleRate: 44_100, channels: 1, bitsPerSample: 16, expectedVersion: a.version)
        }
        #expect(try repo.attempt(a.id).recording == nil)
    }

    @Test func componentDeleteRestoreAndLateCallback() throws {
        let url = root(); defer { try? FileManager.default.removeItem(at: url) }
        let repo = try store(url)
        let a = try withText(repo, withAudio(repo))
        let saved = try repo.saveSelection(a.id, keepAudio: true, keepText: true, expectedVersion: a.version)
        let token = try repo.token(for: a.id)
        let deletions = try repo.softDelete(a.id, scope: .text, expectedVersion: saved.version)
        let deleted = try repo.attempt(a.id)
        #expect(deleted.recording != nil)
        #expect(deleted.transcripts.isEmpty)
        let stale = TranscriptSnapshot(id: UUID(), revision: 2, kind: .asrOriginal, text: "Late result", createdAt: Date())
        #expect(throws: LearnerStorageError.staleVersion) { try repo.appendTranscript(stale, token: token) }
        try repo.restore(try #require(deletions.first), expectedVersion: deleted.version)
        let restored = try repo.attempt(a.id)
        #expect(restored.transcripts.count == 1)
        #expect(restored.recording != nil)
        #expect(throws: LearnerStorageError.staleVersion) { try repo.appendTranscript(stale, token: token) }
    }

    @Test func failedPhysicalDeletionRemainsJournaledAndInvisibleAcrossRestart() throws {
        let url = root(); defer { try? FileManager.default.removeItem(at: url) }
        let files = try PrivateFileStore(root: url)
        var repo: LearnerRepository? = try LearnerRepository(root: url, protectedDataAvailable: { true }, fileStore: files)
        let a = try withAudio(repo!)
        files.beforeOperation = { if $0 == .remove { throw LearnerStorageError.storageFailure } }
        #expect(throws: LearnerStorageError.storageFailure) {
            try repo!.saveSelection(a.id, keepAudio: false, keepText: false, expectedVersion: a.version)
        }
        #expect(try repo!.pendingFileWorkCount() == 1)
        repo!.close(); repo = nil; files.beforeOperation = nil
        let reopened = try store(url)
        #expect(try reopened.attempt(a.id).recording == nil)
        #expect(try reopened.pendingFileWorkCount() == 0)
        #expect(try FileManager.default.contentsOfDirectory(atPath: url.appendingPathComponent("audio").path).isEmpty)
    }

    @Test func exactExpiryAndClockRollbackDoNotExtendTrash() throws {
        let url = root(); defer { try? FileManager.default.removeItem(at: url) }
        var date = Date(timeIntervalSince1970: 1_800_000_000)
        let repo = try LearnerRepository(root: url, now: { date }, uptime: { 0 }, protectedDataAvailable: { true })
        let a = try withAudio(repo)
        let saved = try repo.saveSelection(a.id, keepAudio: true, keepText: false, expectedVersion: a.version)
        let deletion = try #require(repo.softDelete(a.id, scope: .audio, expectedVersion: saved.version).first)
        let deadline = try #require(repo.attempt(a.id).audio.expiresAt)
        date = deadline
        try repo.maintain()
        date = deadline.addingTimeInterval(-86400)
        #expect(try repo.attempt(a.id).audio.state == .purged)
        #expect(throws: LearnerStorageError.invalidReference) { try repo.restore(deletion, expectedVersion: saved.version + 1) }
    }

    @Test func interruptedDraftExpiresAtTwentyFourHours() throws {
        let url = root(); defer { try? FileManager.default.removeItem(at: url) }
        var date = Date(timeIntervalSince1970: 1_800_000_000)
        let repo = try LearnerRepository(root: url, now: { date }, uptime: { 0 }, protectedDataAvailable: { true })
        let a = try withAudio(repo)
        try repo.markInterrupted(a.id, expectedVersion: a.version)
        #expect(try repo.recoverableAttempts().count == 1)
        date = a.recoveryDeadline
        #expect(try repo.recoverableAttempts().isEmpty)
        let expired = try repo.attempt(a.id)
        #expect(expired.recording == nil)
        #expect(expired.prompt.text == nil)
    }

    @Test func resetRejectsOldEpochAndDoesNotResurrectPrivateText() throws {
        let url = root(); defer { try? FileManager.default.removeItem(at: url) }
        let repo = try store(url); let a = try withAudio(repo); let token = try repo.token(for: a.id)
        try repo.deleteAllLearningData()
        let text = TranscriptSnapshot(id: UUID(), revision: 1, kind: .asrOriginal, text: "Late callback", createdAt: Date())
        #expect(throws: LearnerStorageError.invalidReference) { try repo.appendTranscript(text, token: token) }
        #expect(try repo.recoverableAttempts().isEmpty)
    }

    @Test func invalidPathsOrphanTranscriptsAndUnavailableStorageAreRejected() throws {
        let url = root(); defer { try? FileManager.default.removeItem(at: url) }
        let files = try PrivateFileStore(root: url)
        #expect(throws: LearnerStorageError.invalidReference) { try files.url(for: "../outside.wav") }
        #expect(throws: LearnerStorageError.invalidReference) { try files.url(for: "audio/not-a-uuid.wav") }
        let repo = try store(url); let a = try withAudio(repo)
        let text = TranscriptSnapshot(id: UUID(), revision: 1, kind: .learnerConfirmed,
            sourceTranscriptID: UUID(), text: "Orphan confirmation", createdAt: Date())
        #expect(throws: LearnerStorageError.invalidReference) { try repo.appendTranscript(text, token: repo.token(for: a.id)) }
        repo.close()
        #expect(throws: LearnerStorageError.unavailable) { try repo.preferences() }
        #expect(throws: LearnerStorageError.unavailable) {
            try LearnerRepository(root: url, protectedDataAvailable: { false })
        }
    }

    @Test func corruptStoreIsNotErased() throws {
        let url = root(); defer { try? FileManager.default.removeItem(at: url) }
        _ = try PrivateFileStore(root: url)
        let file = url.appendingPathComponent("learner.store")
        let bytes = Data("Synthetic invalid store".utf8); try bytes.write(to: file)
        #expect(throws: (any Error).self) { try store(url) }
        #expect(try Data(contentsOf: file) == bytes)
    }

    @Test func filesRequestCompleteProtectionAndBackupExclusion() throws {
        let url = root(); defer { try? FileManager.default.removeItem(at: url) }
        let repo = try store(url); let a = try withAudio(repo)
        let recording = try #require(a.recording)
        let file = url.appendingPathComponent(recording.relativePath)
        let values = try file.resourceValues(forKeys: [.isExcludedFromBackupKey])
        #expect(values.isExcludedFromBackup == true)
        #if !targetEnvironment(simulator)
        let attrs = try FileManager.default.attributesOfItem(atPath: file.path)
        #expect(attrs[.protectionKey] as? String == FileProtectionType.complete.rawValue)
        #endif // Simulator does not establish device Data Protection behavior.
    }
    @Test func finalizationMetadataFailureRecoversWithoutLosingTheTake() throws {
        let url = root(); defer { try? FileManager.default.removeItem(at: url) }
        var repo: LearnerRepository? = try store(url)
        let a = try repo!.createAttempt(prompt: prompt()); var commits = 0
        repo!.beforeCommit = { commits += 1; if commits == 2 { throw LearnerStorageError.storageFailure } }
        #expect(throws: LearnerStorageError.storageFailure) {
            try repo!.finalizeRecording(attemptID: a.id, data: Data([1, 2]), durationMilliseconds: 1000,
                sampleRate: 44_100, channels: 1, bitsPerSample: 16, expectedVersion: a.version)
        }
        repo!.beforeCommit = nil; repo!.close(); repo = nil
        let reopened = try store(url)
        #expect(try reopened.recoverableAttempts().first?.recording != nil)
        #expect(try reopened.pendingFileWorkCount() == 0)
    }

    @Test func sentRequestsBecomeUnknownAndMissingAudioBecomesUnavailable() throws {
        let url = root(); defer { try? FileManager.default.removeItem(at: url) }
        var repo: LearnerRepository? = try store(url)
        let a = try withAudio(repo!); let recording = try #require(a.recording)
        let request = RequestSnapshot(id: UUID(), stage: .transcription, model: "fixture", region: "fixture",
                                      status: .sent, createdAt: Date())
        _ = try repo!.registerRequest(request, token: repo!.token(for: a.id))
        repo!.close(); repo = nil
        try FileManager.default.removeItem(at: url.appendingPathComponent(recording.relativePath))
        let reopened = try store(url); let value = try reopened.attempt(a.id)
        #expect(value.requests.first?.status == .unknownOutcome)
        #expect(value.audio.state == .unavailable)
        #expect(value.recording == nil)
    }

    @Test func managedSymlinkIsRejectedWithoutTouchingItsTarget() throws {
        let url = root(); defer { try? FileManager.default.removeItem(at: url) }
        let files = try PrivateFileStore(root: url)
        let target = url.appendingPathComponent("synthetic-target")
        let bytes = Data([1, 2]); try bytes.write(to: target)
        let relative = "audio/\(UUID().uuidString).wav"
        try FileManager.default.createSymbolicLink(at: url.appendingPathComponent(relative), withDestinationURL: target)
        #expect(throws: LearnerStorageError.invalidReference) { try files.url(for: relative) }
        #expect(try Data(contentsOf: target) == bytes)
    }

}
