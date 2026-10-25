import AVFAudio
import Foundation
import Testing
@testable import SpeechCoachAI

struct CaptureRecoveryTests {
    private func writePCM(_ url: URL, seconds: Double, floatingPoint: Bool = false) throws {
        let format = try #require(AVAudioFormat(commonFormat: floatingPoint ? .pcmFormatFloat32 : .pcmFormatInt16,
            sampleRate: 44_100, channels: 1, interleaved: true))
        let frames = AVAudioFrameCount(seconds * 44_100)
        let buffer = try #require(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames))
        buffer.frameLength = frames
        if floatingPoint { buffer.floatChannelData?[0].initialize(repeating: 0, count: Int(frames)) }
        else { buffer.int16ChannelData?[0].initialize(repeating: 0, count: Int(frames)) }
        let file = try AVAudioFile(forWriting: url, settings: format.settings,
            commonFormat: floatingPoint ? .pcmFormatFloat32 : .pcmFormatInt16, interleaved: true)
        try file.write(from: buffer)
    }

    @Test func pendingCaptureSurvivesRestartAndFinalizesVerifiedOriginal() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        var repository: LearnerRepository? = try LearnerRepository(root: root, protectedDataAvailable: { true })
        let attempt = try repository!.createAttempt(prompt: RecordingController.prompt)
        let draft = try repository!.prepareCapture(attempt.id, expectedVersion: attempt.version)
        try writePCM(draft, seconds: 1.25)
        repository!.close(); repository = nil
        let reopened = try LearnerRepository(root: root, protectedDataAvailable: { true })
        #expect(FileManager.default.fileExists(atPath: draft.path))
        #expect(try reopened.recoverableAttempts().contains { $0.id == attempt.id })
        let result = try reopened.finalizeCapture(attempt.id)
        let audio = try #require(result.recording)
        #expect(audio.sampleRate == 44_100 && audio.channelCount == 1 && audio.bitsPerSample == 16)
        #expect(audio.durationMilliseconds == 1_250)
        #expect(result.pendingCaptureID == nil)
        #expect(!FileManager.default.fileExists(atPath: draft.path))
        #expect(try reopened.finalizeCapture(attempt.id).recording?.id == audio.id)
        let saved = try reopened.saveSelection(result.id, keepAudio: true, keepText: false, expectedVersion: result.version)
        #expect(saved.audio.state == .saved && saved.text.state == .purged)
        #expect(try Data(contentsOf: reopened.recordingURL(result.id)).count == audio.byteCount)
    }

    @Test func shortDraftIsRejectedRetainedAndExplicitlyDiscardable() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let repository = try LearnerRepository(root: root, protectedDataAvailable: { true })
        let attempt = try repository.createAttempt(prompt: RecordingController.prompt)
        let draft = try repository.prepareCapture(attempt.id, expectedVersion: attempt.version)
        try writePCM(draft, seconds: 0.5)
        #expect(throws: LearnerStorageError.invalidContent) { try repository.finalizeCapture(attempt.id) }
        #expect(FileManager.default.fileExists(atPath: draft.path))
        let pending = try repository.attempt(attempt.id)
        #expect(pending.recording == nil && pending.pendingCaptureID != nil)
        try repository.discardTemporary(pending.id, expectedVersion: pending.version)
        #expect(!FileManager.default.fileExists(atPath: draft.path))
    }

    @Test func draftExpiresWithoutDeletingSavedOriginalAndRetriesHaveNewIdentity() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        var date = Date(timeIntervalSince1970: 1_800_000_000)
        let repository = try LearnerRepository(root: root, now: { date }, uptime: { 0 }, protectedDataAvailable: { true })
        let first = try repository.createAttempt(prompt: RecordingController.prompt)
        let draft = try repository.prepareCapture(first.id, expectedVersion: first.version)
        try writePCM(draft, seconds: 1)
        let complete = try repository.finalizeCapture(first.id)
        _ = try repository.saveSelection(first.id, keepAudio: true, keepText: false, expectedVersion: complete.version)
        let retry = try repository.createAttempt(prompt: RecordingController.prompt, retryOf: first.id)
        #expect(retry.id != first.id && retry.retryOfAttemptID == first.id)
        let retryDraft = try repository.prepareCapture(retry.id, expectedVersion: retry.version)
        try writePCM(retryDraft, seconds: 1)
        date = retry.recoveryDeadline
        try repository.maintain()
        #expect(!FileManager.default.fileExists(atPath: retryDraft.path))
        #expect(try repository.attempt(first.id).audio.state == .saved)
        #expect(try repository.recordingURL(first.id).isFileURL)
    }

    @Test func floatingPointPCMIsNotMislabeledSigned16Bit() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let url = root.appendingPathComponent("fixture.wav")
        try writePCM(url, seconds: 1, floatingPoint: true)
        #expect(throws: LearnerStorageError.invalidContent) { try CaptureFile(url: url) }
    }
    @Test func sessionContextPersistsWithoutChangingDefaultsAndDeclinedContextIsRemoved() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let repository = try LearnerRepository(root: root, protectedDataAvailable: { true })
        let defaults = try repository.preferences()
        var context = PracticeSessionContext(defaults: defaults, sourceLessonID: "synthetic-lesson", objectiveID: "INTRO-01")
        context.coachOverride = .foxJournalist
        let attempt = try repository.createAttempt(prompt: RecordingController.prompt, context: context)
        #expect(attempt.preferences?.coach == .foxJournalist)
        #expect(attempt.practiceSessionID == context.id && attempt.sourceLessonID == "synthetic-lesson")
        #expect(try repository.preferences() == defaults)
        let draft = try repository.prepareCapture(attempt.id, expectedVersion: attempt.version)
        try writePCM(draft, seconds: 1)
        let recorded = try repository.finalizeCapture(attempt.id)
        let finished = try repository.saveSelection(recorded.id, keepAudio: false, keepText: false, expectedVersion: recorded.version)
        #expect(finished.practiceSessionID == nil && finished.sourceLessonID == nil && finished.preferences == nil)
    }

    @Test func specialistSpeakingFreezesTaskAndRecoversWithoutChangingCourse() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        var repository = try LearnerRepository(root: root, protectedDataAvailable: { true })
        let pack = IntroPracticePack.journalist
        let session = try LessonSession.begin(lesson: pack.lesson, presenter: "journalist", now: .now)
        let origin = LessonPracticeOrigin(journeyID: UUID(), lessonID: "intro-01", objectiveID: "INTRO-01", activityID: "guided")
        let step = try #require(pack.steps.first { $0.id.hasSuffix("-question") })
        let context = pack.speakingContext(session: session, step: step, origin: origin,
            defaults: try repository.preferences(), supported: false)
        let prompt = try #require(context.promptOverride)
        let attempt = try repository.createAttempt(prompt: prompt, context: context)
        #expect(attempt.prompt.text == step.prompt)
        #expect(attempt.speakingProvenance?.purpose == "specialistPractice")
        repository.close()
        repository = try LearnerRepository(root: root, protectedDataAvailable: { true })
        let restored = try repository.attempt(attempt.id)
        let recovered = PracticeSessionContext.recovering(restored, defaults: LearnerPreferences())
        #expect(recovered.provenance == context.provenance)
        #expect(recovered.sourceLessonJourneyID == origin.journeyID)
        #expect(recovered.promptOverride == prompt)
        let url = try repository.prepareCapture(attempt.id, expectedVersion: restored.version)
        try writePCM(url, seconds: 1)
        let recorded = try repository.finalizeCapture(attempt.id)
        let finished = try repository.saveSelection(recorded.id, keepAudio: false, keepText: false, expectedVersion: recorded.version)
        #expect(finished.speakingProvenance == nil && finished.sourceLessonJourneyID == nil)
        #expect(try repository.lessonJourneys(lessonID: origin.lessonID).isEmpty)
    }

    @Test func oldSnapshotDecodesAndExpiredCaptureCannotBecomeAnOriginal() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        var now = Date(timeIntervalSince1970: 1_800_000_000)
        let repository = try LearnerRepository(root: root, now: { now }, uptime: { 0 }, protectedDataAvailable: { true })
        let attempt = try repository.createAttempt(prompt: RecordingController.prompt)
        var oldJSON = try #require(JSONSerialization.jsonObject(with: JSONEncoder().encode(attempt)) as? [String: Any])
        for key in ["pendingCaptureID", "practiceSessionID", "sourceLessonID"] { oldJSON.removeValue(forKey: key) }
        let old = try JSONDecoder().decode(AttemptSnapshot.self, from: JSONSerialization.data(withJSONObject: oldJSON))
        #expect(old.id == attempt.id && old.pendingCaptureID == nil && old.practiceSessionID == nil)
        let url = try repository.prepareCapture(attempt.id, expectedVersion: attempt.version)
        try writePCM(url, seconds: 1)
        now = (try repository.attempt(attempt.id)).recoveryDeadline
        let expired = try repository.finalizeCapture(attempt.id)
        #expect(expired.recording == nil && expired.audio.state == .purged)
        #expect(!FileManager.default.fileExists(atPath: url.path))
    }

    @Test func overLimitAndNonWAVContainersAreRejected() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let tooLong = root.appendingPathComponent("long.wav")
        try writePCM(tooLong, seconds: 120.01)
        #expect(throws: LearnerStorageError.invalidContent) { try CaptureFile(url: tooLong) }
        let notWAV = root.appendingPathComponent("wrong.wav")
        try Data(repeating: 0, count: 100).write(to: notWAV)
        #expect(throws: LearnerStorageError.invalidContent) { try CaptureFile(url: notWAV) }
    }

    @Test(arguments: [1.0, 1.25, 120.0])
    func submissionCopyUsesActual16kPCMAndPreservesOriginal(_ seconds: Double) throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let original = root.appendingPathComponent("original.wav")
        try writePCM(original, seconds: seconds)
        let originalBytes = try Data(contentsOf: original)
        let prepared = try ASRPreparation(original: original)
        #expect(try Data(contentsOf: original) == originalBytes)
        #expect(prepared.wav.count <= 4 * 1024 * 1024 && prepared.requestBody.count <= 6 * 1024 * 1024)
        let copy = root.appendingPathComponent("copy.wav")
        try prepared.wav.write(to: copy)
        let inspected = try CaptureFile(url: copy)
        #expect(inspected.sampleRate == 16_000 && inspected.bits == 16 && inspected.channels == 1)
        #expect(abs(Double(inspected.durationMilliseconds) - seconds * 1000) <= 1)
        let json = try #require(JSONSerialization.jsonObject(with: prepared.requestBody) as? [String: Any])
        #expect(json["model"] as? String == "qwen3-asr-flash")
        let messages = try #require(json["messages"] as? [[String: Any]])
        #expect(messages.count == 1 && messages[0]["role"] as? String == "user")
        let content = try #require(messages[0]["content"] as? [[String: Any]])
        let audio = try #require(content.first?["input_audio"] as? [String: String])
        #expect(audio["data"] == "data:audio/wav;base64," + prepared.wav.base64EncodedString())
        #expect(json["Authorization"] == nil)
    }

}
