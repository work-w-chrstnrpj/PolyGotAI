import Foundation
import SwiftData

/// Speech Lab attempts, online feedback results and saved speaking practice.
extension LearnerRepository {
    // MARK: Speech Lab (v2) — optional JSON field, unchanged SwiftData schema

    func speechLabState() throws -> SpeechLabState { try document().speechLab ?? SpeechLabState() }

    func setSpeechLabStrictDictation(_ strict: Bool) throws {
        var stored = try document()
        var state = stored.speechLab ?? SpeechLabState()
        state.strictDictation = strict; stored.speechLab = state
        try write(stored)
    }

    func recordSpeechLabAttempt(_ attempt: SpeechLabAttempt) throws {
        guard attempt.isValid else { throw LearnerStorageError.invalidContent }
        if let recordingID = attempt.recordingID {
            guard try self.attempt(recordingID).audio.state == .saved else { throw LearnerStorageError.invalidState }
        }
        var stored = try document()
        var state = stored.speechLab ?? SpeechLabState()
        state.record(attempt); stored.speechLab = state
        try write(stored)
    }

    func removeSpeechLabAttempt(_ id: UUID) throws {
        var stored = try document()
        var state = stored.speechLab ?? SpeechLabState()
        state.remove(id)
        stored.speechLab = state
        try write(stored)
    }

    // MARK: Lab videos and timed tests (Phase 15) — inside the Speech Lab JSON field

    func labExtras() throws -> LabExtrasState { try speechLabState().extras ?? LabExtrasState() }

    func setLabVideoWatched(_ id: String, _ watched: Bool) throws {
        guard LabVideoCatalog.isValidID(id) else { throw LearnerStorageError.invalidContent }
        try updateLabExtras { $0.setWatched(id, watched, now: try effectiveNow()) }
    }

    func setLabVideoChannelFavorite(_ channel: String, _ favorite: Bool) throws {
        guard LabVideoCatalog.channels.contains(channel) else { throw LearnerStorageError.invalidContent }
        try updateLabExtras { $0.setFavorite(channel, favorite) }
    }

    /// Keeps the fingerprints of a test the learner started, so the same items are not shown again.
    func rememberTimedTest(_ test: TimedTest) throws {
        try updateLabExtras { $0.remember(test) }
    }

    /// Logs a finished Talk conversation or timed test (for badges). `id` makes a repeated call harmless.
    func recordLabActivity(_ kind: String, id: UUID) throws {
        guard LabActivity.kinds.contains(kind) else { throw LearnerStorageError.invalidContent }
        let date = try effectiveNow()
        try updateLabExtras { $0.log(LabActivity(id: id, kind: kind, date: date)) }
    }

    private func updateLabExtras(_ change: (inout LabExtrasState) throws -> Void) throws {
        var stored = try document()
        var state = stored.speechLab ?? SpeechLabState()
        var extras = state.extras ?? LabExtrasState()
        try change(&extras)
        state.extras = extras; stored.speechLab = state
        try write(stored)
    }

    // MARK: Online feedback results (Phase 6a)

    func labFeedbackHistory(mode: LabFeedbackMode? = nil) throws -> [StoredLabFeedback] {
        let all = try document().labFeedback ?? []
        return mode.map { wanted in all.filter { $0.mode == wanted } } ?? all
    }

    func saveLabFeedback(_ record: StoredLabFeedback) throws {
        guard record.isValid else { throw LearnerStorageError.invalidContent }
        var stored = try document()
        var list = stored.labFeedback ?? []
        guard !list.contains(where: { $0.id == record.id }) else { return }
        list.append(record)
        if list.count > StoredLabFeedback.maximumCount { list.removeFirst(list.count - StoredLabFeedback.maximumCount) }
        stored.labFeedback = list
        try write(stored)
    }

    func removeLabFeedback(_ id: UUID) throws {
        var stored = try document()
        stored.labFeedback = (stored.labFeedback ?? []).filter { $0.id != id }
        try write(stored)
    }

    func clearLabFeedback() throws {
        var stored = try document()
        stored.labFeedback = nil
        try write(stored)
    }

    // MARK: Saved speaking practice (Conversation, Interview)

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
        case "conversation": valid = archive.conversation != nil && archive.interview == nil
        case "interview": valid = archive.interview != nil && archive.conversation == nil
        default: valid = false
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
}
