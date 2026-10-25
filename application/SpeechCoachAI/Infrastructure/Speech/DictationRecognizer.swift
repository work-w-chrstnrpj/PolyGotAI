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

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let engine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    static var isSupported: Bool {
        SFSpeechRecognizer(locale: Locale(identifier: "en-US"))?.supportsOnDeviceRecognition == true
    }

    var isListening: Bool { state == .listening }

    func toggle() async {
        if isListening { stop() } else { await start() }
    }

    func start() async {
        guard !isListening else { return }
        guard await Self.authorized() else { state = .denied; return }
        guard let recognizer, recognizer.isAvailable, Self.isSupported else { state = .unavailable; return }
        transcript = ""
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.requiresOnDeviceRecognition = true
        request.shouldReportPartialResults = true
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: [.duckOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            let input = engine.inputNode
            Self.installTap(on: input, format: input.outputFormat(forBus: 0), request: UncheckedRequest(request))
            engine.prepare()
            try engine.start()
        } catch {
            teardown()
            state = .unavailable
            return
        }
        self.request = request
        task = Self.makeTask(recognizer: recognizer, request: UncheckedRequest(request)) { [weak self] text, finished in
            Task { @MainActor in self?.handle(text: text, finished: finished) }
        }
        state = .listening
    }

    func stop() {
        request?.endAudio()
        teardown()
    }

    private func handle(text: String?, finished: Bool) {
        if let text, state == .listening { transcript = text }
        if finished { teardown() }
    }

    private func teardown() {
        if engine.isRunning { engine.stop() }
        engine.inputNode.removeTap(onBus: 0)
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
        onResult: @escaping @Sendable (String?, Bool) -> Void
    ) -> SFSpeechRecognitionTask {
        recognizer.recognitionTask(with: request.value) { result, error in
            onResult(result?.bestTranscription.formattedString, result?.isFinal == true || error != nil)
        }
    }
}
