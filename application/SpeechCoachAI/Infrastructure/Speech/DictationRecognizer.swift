import AVFoundation
import Observation
import Speech

/// On-device speech-to-text for typing fields. Audio never leaves the device: if the device can't recognize
/// English on-device, `isSupported` is false and the dictation button is hidden.
@MainActor @Observable
final class DictationRecognizer {
    enum State: Equatable { case idle, listening, denied, unavailable }

    private(set) var state: State = .idle
    /// Everything recognized in the current session (replaced as recognition refines).
    private(set) var transcript = ""
    private(set) var wordTimings: [SpeechLabWordTiming] = []

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let engine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var generation = UUID()
    private var finalResult: CheckedContinuation<String, Error>?
    private var finalTimeout: Task<Void, Never>?
    private var tapped = false
    private var completedFinal: String?

    static var isSupported: Bool {
        SFSpeechRecognizer(locale: Locale(identifier: "en-US"))?.supportsOnDeviceRecognition == true
    }

    var isListening: Bool { state == .listening }

    func toggle() async {
        if isListening { stop() } else { await start() }
    }

    func start() async {
        guard !isListening else { return }
        let token = UUID(); generation = token
        let allowed = await Self.authorized()
        guard generation == token, !Task.isCancelled else { return }
        guard allowed else { state = .denied; return }
        guard let recognizer, recognizer.isAvailable, Self.isSupported else { state = .unavailable; return }
        transcript = ""; wordTimings = []; completedFinal = nil
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.requiresOnDeviceRecognition = true
        request.shouldReportPartialResults = true
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: [.duckOthers, .allowBluetoothHFP])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            let input = engine.inputNode
            guard input.outputFormat(forBus: 0).sampleRate > 0 else { throw TalkError.recognition }
            Self.installTap(on: input, format: input.outputFormat(forBus: 0), request: UncheckedRequest(request))
            tapped = true
            engine.prepare()
            try engine.start()
        } catch {
            teardown()
            state = .unavailable
            return
        }
        self.request = request
        task = Self.makeTask(recognizer: recognizer, request: UncheckedRequest(request)) { [weak self] text, finished, final in
            Task { @MainActor in
                guard let self, self.generation == token else { return }
                self.handle(text: text, finished: finished, final: final)
            }
        }
        state = .listening
    }

    func stop() {
        completedFinal = nil
        generation = UUID()
        request?.endAudio()
        teardown()
    }

    /// End capture and await the recognizer's final result; never submit a partial hypothesis online.
    func finishRecognition() async throws -> String {
        if let completedFinal { return completedFinal }
        guard isListening, finalResult == nil else { throw TalkError.recognition }
        let token = generation
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                finalResult = continuation
                engine.stop()
                if tapped { engine.inputNode.removeTap(onBus: 0); tapped = false }
                request?.endAudio()
                finalTimeout = Task { [weak self] in
                    do { try await Task.sleep(for: .seconds(4)) } catch { return }
                    guard let self, self.generation == token else { return }
                    let pending = finalResult; finalResult = nil
                    pending?.resume(throwing: TalkError.recognition); stop()
                }
            }
        } onCancel: { Task { @MainActor [weak self] in if self?.generation == token { self?.stop() } } }
    }

    private func handle(text: SpeechLabTranscript?, finished: Bool, final: Bool) {
        if let text, state == .listening { transcript = text.text; wordTimings = text.words }
        if finished {
            let pending = finalResult; finalResult = nil
            if final { completedFinal = transcript; pending?.resume(returning: transcript) } else { pending?.resume(throwing: TalkError.recognition) }
            teardown()
        }
    }

    private func teardown() {
        if engine.isRunning { engine.stop() }
        if tapped { engine.inputNode.removeTap(onBus: 0); tapped = false }
        finalTimeout?.cancel(); finalTimeout = nil
        let pending = finalResult; finalResult = nil; pending?.resume(throwing: CancellationError())
        task?.cancel()
        task = nil
        request = nil
        if state == .listening { state = .idle }
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    // MARK: Permissions and audio plumbing (nonisolated: these closures run on audio and recognition threads)

    /// The system calls the authorization handler on a background queue, so this must not be main-actor isolated.
    private nonisolated static func authorized() async -> Bool {
        let speech = await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
            SFSpeechRecognizer.requestAuthorization { continuation.resume(returning: $0 == .authorized) }
        }
        guard speech else { return false }
        return await AVAudioApplication.requestRecordPermission()
    }

    private nonisolated struct UncheckedRequest: @unchecked Sendable {
        let value: SFSpeechAudioBufferRecognitionRequest
        init(_ value: SFSpeechAudioBufferRecognitionRequest) { self.value = value }
    }

    private nonisolated static func installTap(on node: AVAudioInputNode, format: AVAudioFormat, request: UncheckedRequest) {
        node.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in request.value.append(buffer) }
    }

    private nonisolated static func makeTask(
        recognizer: SFSpeechRecognizer, request: UncheckedRequest,
        onResult: @escaping @Sendable (SpeechLabTranscript?, Bool, Bool) -> Void
    ) -> SFSpeechRecognitionTask {
        recognizer.recognitionTask(with: request.value) { result, error in
            let recognized = result.map { value in
                SpeechLabTranscript(text: value.bestTranscription.formattedString,
                    words: value.bestTranscription.segments.map { .init(word: $0.substring, start: $0.timestamp, duration: $0.duration) })
            }
            onResult(recognized, result?.isFinal == true || error != nil, result?.isFinal == true)
        }
    }
}
