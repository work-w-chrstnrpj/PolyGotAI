import AVFAudio
import Foundation
import Observation

@Observable
final class RecordingController {
    enum Phase { case ready, requestingPermission, countdown, preparing, recording, paused, review, finished }
    private(set) var phase: Phase = .ready
    private(set) var candidate: AttemptSnapshot?
    private(set) var accepted: AttemptSnapshot?
    private(set) var recoverable: [AttemptSnapshot] = []
    private(set) var elapsed: TimeInterval = 0
    private(set) var level: Float = 0
    private(set) var countdown = 0
    private(set) var message: String?
    private(set) var permissionDenied = false
    private(set) var isPlaying = false
    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?
    private var countdownTask: Task<Void, Never>?
    private var repository: LearnerRepository?
    private var sessionContext: PracticeSessionContext?
    private var ownsAudioSession = false
    private var sessionAttemptIDs: Set<UUID> = []

    static let prompt = PromptSnapshot(id: "INTRO-01-internal-recording", version: "1", objectiveID: "INTRO-01",
        text: "Introduce yourself to someone new. Share a chosen name, your work, study or daily role, and an interest. Fictional details are welcome.",
        isPrivate: false, selectedLevel: "A1")

    func load(_ repository: LearnerRepository?, context: PracticeSessionContext? = nil) {
        self.repository = repository
        if candidate == nil && accepted == nil { sessionContext = context }
        refreshRecovery()
    }

    var activeProvenance: SpeakingProvenance? { candidate?.speakingProvenance ?? accepted?.speakingProvenance ?? sessionContext?.provenance }

    var activePrompt: PromptSnapshot { candidate?.prompt ?? accepted?.prompt ?? sessionContext?.promptOverride ?? Self.prompt }

    private func refreshRecovery() {
        let all = (try? repository?.recoverableAttempts()) ?? []
        if let context = sessionContext, ["conversationTurn", "interviewTurn", "communicationTurn"].contains(context.provenance?.purpose ?? "") {
            recoverable = all.filter { $0.practiceSessionID == context.id }.sorted { $0.createdAt > $1.createdAt }
        } else { recoverable = all.sorted { $0.createdAt > $1.createdAt } }
    }

    func start(countdownEnabled: Bool) {
        guard phase == .ready || phase == .review else { return }
        stopPlayback(); message = nil; permissionDenied = false
        guard repository != nil else { message = "Local storage is unavailable. Unlock your device and try again."; return }
        phase = .requestingPermission
        countdownTask = Task { [weak self] in
            let allowed = await AVAudioApplication.requestRecordPermission()
            guard let self, !Task.isCancelled, self.phase == .requestingPermission else { return }
            guard allowed else {
                self.permissionDenied = true; self.phase = self.candidate == nil ? .ready : .review
                self.message = "Microphone access is off. Enable it in Settings to record. Your existing takes are kept."
                return
            }
            if countdownEnabled {
                self.phase = .countdown
                for value in (1...3).reversed() {
                    self.countdown = value
                    do { try await Task.sleep(for: .seconds(1)) } catch { return }
                }
            }
            guard !Task.isCancelled else { return }
            await self.beginCapture()
        }
    }

    /// Audio-route activation can block. Keep it off the UI executor and recheck cancellation afterward.
    @concurrent private static func activateCaptureSession() async throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try session.setPreferredSampleRate(44_100)
        try session.setActive(true)
    }

    private func beginCapture() async {
        do {
            guard let repository else { throw LearnerStorageError.unavailable }
            phase = .preparing
            try await Self.activateCaptureSession()
            ownsAudioSession = true
            try Task.checkCancellation()
            guard phase == .preparing else { deactivate(); return }
            let previous = candidate?.id ?? accepted?.id
            let attempt = try repository.createAttempt(prompt: activePrompt, retryOf: previous, context: sessionContext)
            candidate = attempt; sessionAttemptIDs.insert(attempt.id)
            let url = try repository.prepareCapture(attempt.id, expectedVersion: attempt.version)
            candidate = try repository.attempt(attempt.id)
            let recorder = try AVAudioRecorder(url: url, settings: [
                AVFormatIDKey: kAudioFormatLinearPCM, AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 1, AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsFloatKey: false, AVLinearPCMIsBigEndianKey: false
            ])
            recorder.isMeteringEnabled = true
            guard recorder.prepareToRecord() else { throw LearnerStorageError.storageFailure }
            try repository.protectCapture()
            self.recorder = recorder; elapsed = 0; level = 0
            guard recorder.record(forDuration: 120) else { throw LearnerStorageError.storageFailure }
            phase = .recording
        } catch is CancellationError {
            deactivate(); phase = candidate == nil ? .ready : .review
        } catch {
            recorder?.stop(); recorder = nil; deactivate()
            phase = candidate == nil ? .ready : .review
            message = "Recording could not start. Check microphone access, the audio route and free device storage. Existing takes are kept."
        }
    }

    func tick() {
        if phase == .recording, let recorder {
            if !recorder.isRecording { stop(interrupted: false); return }
            elapsed = recorder.currentTime
            recorder.updateMeters(); level = max(0, min(1, (recorder.averagePower(forChannel: 0) + 60) / 60))
        }
        if isPlaying, player?.isPlaying != true { stopPlayback() }
    }

    func pauseOrResume() {
        guard let recorder else { return }
        if phase == .recording {
            elapsed = recorder.currentTime; recorder.pause(); phase = .paused
        } else if phase == .paused {
            guard recorder.record(forDuration: max(0.01, 120 - elapsed)) else { stop(interrupted: true); return }
            phase = .recording
        }
    }

    /// System events always stop. Only an explicit learner action may start another take.
    func stop(interrupted: Bool) {
        if phase == .preparing {
            // Do not allow a second setup to race the first one's eventual cancellation/deactivation.
            countdownTask?.cancel()
            return
        }
        if phase == .requestingPermission || phase == .countdown {
            countdownTask?.cancel(); countdownTask = nil
            phase = candidate == nil ? .ready : .review
        }
        guard phase == .recording || phase == .paused, let id = candidate?.id else { stopPlayback(); return }
        recorder?.stop(); recorder = nil; level = 0; deactivate(); phase = .review
        do {
            guard let repository else { throw LearnerStorageError.unavailable }
            candidate = try repository.finalizeCapture(id)
            if interrupted, let value = candidate {
                try repository.markInterrupted(id, expectedVersion: value.version)
                candidate = try repository.attempt(id)
            }
            message = interrupted ? "Recording stopped. Review this partial take or start a fresh one. It will not resume automatically." : nil
        } catch {
            message = "This take could not be finalized. Takes must contain 1–120 seconds of valid audio. Any draft remains recoverable until you discard it or its 24-hour deadline."
        }
    }

    func recover(_ value: AttemptSnapshot) {
        guard phase == .ready || phase == .review else { return }
        stopPlayback(); sessionAttemptIDs.insert(value.id)
        sessionContext = PracticeSessionContext.recovering(value, defaults: sessionContext?.baseline ?? LearnerPreferences())

        do {
            guard let repository else { throw LearnerStorageError.unavailable }
            if value.pendingCaptureID != nil { candidate = try repository.finalizeCapture(value.id) }
            else { candidate = try repository.attempt(value.id) }
            guard let current = candidate else { throw LearnerStorageError.unavailable }
            try repository.recordRecoveryInteraction(current.id, expectedVersion: current.version)
            candidate = try repository.attempt(current.id); phase = .review
            message = "Recovered take. Recording has not resumed."
        } catch {
            candidate = value; phase = .review
            message = "The recovered draft is unavailable for replay. You can keep another accepted take, start a fresh take, or discard this draft."
        }
    }

    func accept() { guard candidate?.recording != nil else { return }; accepted = candidate; message = "This take is selected for self-review." }

    func replayAcceptedOrCandidate() {
        if isPlaying { stopPlayback(); return }
        guard let id = candidate?.recording != nil ? candidate?.id : accepted?.id else { return }
        do {
            guard let repository else { throw LearnerStorageError.unavailable }
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true); ownsAudioSession = true
            let player = try AVAudioPlayer(contentsOf: repository.recordingURL(id))
            guard player.play() else { throw LearnerStorageError.unavailable }
            self.player = player; isPlaying = true
        } catch { message = "Replay is unavailable. Your take has not been replaced."; deactivate() }
    }

    func finish(keepAudio: Bool, keepText: Bool = false) {
        guard let accepted, let repository, phase == .review else { return }
        stopPlayback()
        do {
            let current = try repository.attempt(accepted.id)
            for id in sessionAttemptIDs where id != current.id {
                let value = try repository.attempt(id)
                if value.finishedAt == nil { try repository.discardTemporary(id, expectedVersion: value.version) }
            }
            _ = try repository.saveSelection(current.id, keepAudio: keepAudio, keepText: keepText, expectedVersion: current.version)
            phase = .finished; candidate = nil; self.accepted = nil
            message = "Self-review finished. Voice \(keepAudio ? "saved" : "not saved"); transcript and feedback \(keepText ? "saved" : "not saved")."

        } catch { message = "Your save choice could not be completed. Your take is still available; try again." }
    }

    func discardCandidate() {
        guard let candidate, let repository else { return }
        stop(interrupted: true); stopPlayback()
        do {
            let value = try repository.attempt(candidate.id)
            try repository.discardTemporary(value.id, expectedVersion: value.version)
            if accepted?.id == value.id { accepted = nil }
            self.candidate = accepted; phase = accepted == nil ? .ready : .review
            message = "Draft discarded."; refreshRecovery()
        } catch { message = "The draft could not be discarded. Try again after unlocking your device." }
    }

    func keepForLater() -> Bool {
        stop(interrupted: true)
        guard let repository else { return false }
        do {
            for id in sessionAttemptIDs {
                let value = try repository.attempt(id)
                if value.finishedAt == nil {
                    try repository.recordRecoveryInteraction(id, expectedVersion: value.version)
                    let updated = try repository.attempt(id)
                    try repository.markInterrupted(id, expectedVersion: updated.version)
                }
            }
            return true
        } catch { message = "Some drafts could not be updated. Existing recovery deadlines still apply."; return false }
    }

    func discardSession() -> Bool {
        stop(interrupted: true)
        guard let repository else { return false }
        do {
            for id in sessionAttemptIDs {
                let value = try repository.attempt(id)
                if value.finishedAt == nil { try repository.discardTemporary(id, expectedVersion: value.version) }
            }
            candidate = nil; accepted = nil; return true
        } catch { message = "Draft cleanup could not finish. Please try again after unlocking."; return false }
    }

    func stopPlayback() { player?.stop(); player = nil; isPlaying = false; deactivate() }
    private func deactivate() {
        guard ownsAudioSession else { return }
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        ownsAudioSession = false
    }
}
