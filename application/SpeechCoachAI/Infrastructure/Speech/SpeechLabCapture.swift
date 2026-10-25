import AVFAudio
import Foundation
import Observation

/// Wraps the existing private-file/retention controller. A new take is always explicit.
@MainActor @Observable final class SpeechLabCapture {
    private(set) var recorder = RecordingController()
    private let recognizer = SpeechLabRecognizer()
    private let repository: LearnerRepository?
    private let context: PracticeSessionContext
    private var work: Task<Void, Never>?
    private var generation = UUID()
    private var fixtureID: UUID?
    private var savedPlayer: AVAudioPlayer?
    private(set) var transcript: SpeechLabTranscript?
    private(set) var recognizing = false
    private(set) var message: String?
    private(set) var fixtureRecording = false
    private(set) var fixtureElapsed: Double = 0
    private var finished = false
    private(set) var retainedID: UUID?
    var isRecording: Bool { fixtureRecording || recorder.phase == .recording }
    var elapsed: Double { SpeechLabRecognizer.fixture ? fixtureElapsed : recorder.elapsed }
    var level: Float { SpeechLabRecognizer.fixture && fixtureRecording ? 0.55 : recorder.level }
    var ready: Bool { transcript != nil && !recognizing && !isRecording }
    var busy: Bool { recognizing || fixtureRecording || [.requestingPermission, .countdown, .preparing, .recording, .paused].contains(recorder.phase) }

    init(repository: LearnerRepository?, preferences: LearnerPreferences, itemID: String, text: String) {
        self.repository = repository
        var context = PracticeSessionContext(defaults: preferences)
        context.promptOverride = PromptSnapshot(id: "speechlab-" + itemID, version: "1", objectiveID: "SPEECHLAB",
            text: text, isPrivate: false, selectedLevel: "A1")
        self.context = context
        recorder.load(repository, context: context)
    }
    func start() {
        guard !busy else { return }
        cancelRecognition(); SpeechSynthesizer.shared.stop(); recorder.stopPlayback()
        transcript = nil; message = nil; retainedID = nil; finished = false
        if recorder.phase == .finished {
            recorder = RecordingController(); recorder.load(repository, context: context)
        }
        if SpeechLabRecognizer.fixture { fixtureRecording = true; fixtureElapsed = 35; return }
        recorder.start(countdownEnabled: false)
    }
    func tick(maximum: Double) {
        if SpeechLabRecognizer.fixture { return }
        recorder.tick()
        if recorder.elapsed >= maximum, isRecording { stop() }
        if recorder.message != nil, recorder.phase != .finished, transcript == nil, !recognizing, !isRecording { message = recorder.permissionDenied ? "Allow microphone access in Settings." : "Couldn’t finish this recording." }
    }
    func stop() {
        guard isRecording else { return }
        if SpeechLabRecognizer.fixture {
            fixtureRecording = false
            do {
                guard let repository else { throw LearnerStorageError.unavailable }
                if let fixtureID {
                    let old = try repository.attempt(fixtureID)
                    if old.finishedAt == nil { try repository.discardTemporary(fixtureID, expectedVersion: old.version) }
                }
                let attempt = try repository.createAttempt(prompt: context.promptOverride!, context: context)
                let finalized = try repository.finalizeRecording(attemptID: attempt.id, data: Self.silence(seconds: 35),
                    durationMilliseconds: 35_000, sampleRate: 16_000, channels: 1, bitsPerSample: 16, expectedVersion: attempt.version)
                fixtureID = finalized.id
                // Explicit debug-only isolated fixture, never presented as live recognition evidence.
                let text = context.promptOverride?.text ?? ""
                let words = AnswerChecker.words(in: text)
                transcript = .init(text: text, words: words.enumerated().map { .init(word: $0.element, start: Double($0.offset) * 0.5, duration: 0.3) })
            } catch { message = "Couldn’t finish this recording." }
            return
        }
        recorder.stop(interrupted: false)
        guard let id = recorder.candidate?.id, recorder.candidate?.recording != nil, let repository else {
            message = "Couldn’t finish this recording."; return
        }
        recognizing = true
        let token = UUID(); generation = token
        work = Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await recognizer.recognize(repository.recordingURL(id))
                guard generation == token, !Task.isCancelled else { return }
                transcript = result; recognizing = false
            } catch {
                guard generation == token, !Task.isCancelled else { return }
                recognizing = false
                message = (error as? SpeechLabRecognizer.Failure) == .denied ? "Allow speech recognition in Settings." : "Couldn’t hear the words; try again."
            }
        }
    }
    func replay() {
        SpeechSynthesizer.shared.stop()
        if let retainedID, let repository {
            do {
                savedPlayer?.stop()
                try AVAudioSession.sharedInstance().setCategory(.playback)
                try AVAudioSession.sharedInstance().setActive(true)
                savedPlayer = try AVAudioPlayer(contentsOf: repository.recordingURL(retainedID))
                guard savedPlayer?.play() == true else { throw LearnerStorageError.invalidState }
            } catch { message = "Couldn’t play this recording." }
            return
        }
        if let fixtureID, let repository {
            // Use the normal playback controller for fixture audio too.
            if let value = try? repository.attempt(fixtureID) { recorder.recover(value) }
        }
        recorder.replayAcceptedOrCandidate()
    }
    /// Completes the native save/discard choice before returning its optional audio reference.
    func finish(keepAudio: Bool) throws -> UUID? {
        guard ready, let repository else { throw LearnerStorageError.invalidState }
        if finished { return retainedID }
        if let fixtureID {
            let current = try repository.attempt(fixtureID)
            _ = try repository.saveSelection(fixtureID, keepAudio: keepAudio, keepText: false, expectedVersion: current.version)
            if keepAudio { retainedID = fixtureID }
            self.fixtureID = nil; finished = true
            return retainedID
        }
        let id = recorder.candidate?.id
        recorder.accept(); recorder.finish(keepAudio: keepAudio, keepText: false)
        guard recorder.phase == .finished else { throw LearnerStorageError.storageFailure }
        if keepAudio { retainedID = id }
        finished = true
        return retainedID
    }
    func leave() {
        fixtureRecording = false; cancelRecognition(); SpeechSynthesizer.shared.stop()
        if savedPlayer != nil {
            savedPlayer?.stop(); savedPlayer = nil
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
        recorder.stop(interrupted: true); recorder.stopPlayback()
        // Temporary files retain the existing expiry/recovery rules if cleanup fails.
        _ = recorder.discardSession()
        if let fixtureID, let repository, let value = try? repository.attempt(fixtureID), value.finishedAt == nil {
            try? repository.discardTemporary(fixtureID, expectedVersion: value.version)
        }
        fixtureID = nil
        if !finished { transcript = nil }
    }
    private func cancelRecognition() { generation = UUID(); work?.cancel(); work = nil; recognizer.cancel(); recognizing = false }
    private static func silence(seconds: Int) -> Data {
        let bytes = seconds * 16000 * 2
        var data = Data("RIFF".utf8)
        func word(_ v: UInt16) { var value = v.littleEndian; withUnsafeBytes(of: &value) { data.append(contentsOf: $0) } }
        func dword(_ v: UInt32) { var value = v.littleEndian; withUnsafeBytes(of: &value) { data.append(contentsOf: $0) } }
        dword(UInt32(bytes + 36)); data.append(Data("WAVEfmt ".utf8)); dword(16); word(1); word(1)
        dword(16000); dword(32000); word(2); word(16); data.append(Data("data".utf8)); dword(UInt32(bytes))
        data.append(Data(repeating: 0, count: bytes)); return data
    }
}
