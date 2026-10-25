import Foundation
import Testing
@testable import SpeechCoachAI

@MainActor struct SpeechLabPersistenceTests {
    private func wav() -> Data {
        var data = Data("RIFF".utf8)
        func word(_ input: UInt16) { var value = input.littleEndian; withUnsafeBytes(of: &value) { data.append(contentsOf: $0) } }
        func dword(_ input: UInt32) { var value = input.littleEndian; withUnsafeBytes(of: &value) { data.append(contentsOf: $0) } }
        dword(32036); data.append(Data("WAVEfmt ".utf8)); dword(16); word(1); word(1); dword(16000); dword(32000)
        word(2); word(16); data.append(Data("data".utf8)); dword(32000); data.append(Data(repeating: 0, count: 32000))
        return data
    }
    @Test func optionalAudioReopensAndUsesExistingRecentlyDeletedRules() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("SpeechLab-audio-\(UUID())")
        defer { try? FileManager.default.removeItem(at: root) }
        var repo = try LearnerRepository(root: root, protectedDataAvailable: { true })
        let prompt = PromptSnapshot(id: "speechlab-test", version: "1", objectiveID: "SPEECHLAB", text: "Synthetic sample", isPrivate: false, selectedLevel: "A1")
        let draft = try repo.createAttempt(prompt: prompt)
        let take = try repo.finalizeRecording(attemptID: draft.id, data: wav(), durationMilliseconds: 1000,
            sampleRate: 16000, channels: 1, bitsPerSample: 16, expectedVersion: draft.version)
        #expect(throws: LearnerStorageError.invalidState) {
            try repo.recordSpeechLabAttempt(.init(area: .articulation, itemID: "test", recordingID: take.id))
        }
        _ = try repo.saveSelection(take.id, keepAudio: true, keepText: false, expectedVersion: take.version)
        let result = SpeechLabAttempt(area: .articulation, itemID: "test", recordingID: take.id)
        try repo.recordSpeechLabAttempt(result)
        repo.close(); repo = try LearnerRepository(root: root, protectedDataAvailable: { true })
        #expect(try repo.speechLabState().attempts.first?.recordingID == take.id)
        #expect(FileManager.default.fileExists(atPath: try repo.recordingURL(take.id).path))
        let store = SpeechLabStore(repo); store.remove(result)
        #expect(store.state.attempts.isEmpty)
        #expect(try repo.attempt(take.id).audio.state == .recentlyDeleted)
        #expect(try repo.attempt(take.id).text.state != .saved)
        repo.close()
    }
    @Test func deletedHistoryRecomputesMissedStateAndExtrasStillNeedReview() {
        var state = SpeechLabState()
        let wrong = SpeechLabAttempt(area: .dictation, itemID: "x", correct: 3, total: 3, errors: 1)
        state.record(wrong)
        #expect(state.missedDictation == ["x"])
        let right = SpeechLabAttempt(area: .dictation, itemID: "x", correct: 3, total: 3)
        state.record(right); #expect(state.missedDictation.isEmpty)
        state.remove(right.id); #expect(state.missedDictation == ["x"])
        state.remove(wrong.id); #expect(state.missedDictation.isEmpty)
    }
    @Test func resetRejectsAnOldScreenSave() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("SpeechLab-epoch-\(UUID())")
        defer { try? FileManager.default.removeItem(at: root) }
        let repo = try LearnerRepository(root: root, protectedDataAvailable: { true })
        let store = SpeechLabStore(repo)
        try repo.deleteAllLearningData() // synthetic isolated store only
        #expect(!store.save(.init(area: .voice, itemID: "old", wordsPerMinute: 130)))
        #expect(try repo.speechLabState().attempts.isEmpty)
        repo.close()
    }
}
