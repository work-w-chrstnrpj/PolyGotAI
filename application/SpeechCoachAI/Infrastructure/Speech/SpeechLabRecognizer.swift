import AVFoundation
import Speech

/// Recognizes an existing private recording, with no network fallback and no transcript logging.
@MainActor final class SpeechLabRecognizer {
    private var task: SFSpeechRecognitionTask?
    private var pending: CheckedContinuation<SpeechLabTranscript, Error>?
    private var timeout: Task<Void, Never>?
    private var generation = UUID()
    enum Failure: Error, Equatable { case denied, unsupported, noSpeech, cancelled }
    static var fixture: Bool {
        #if DEBUG
        SpeakingEnvironment.fixtureID != nil && ProcessInfo.processInfo.environment["SC_SPEECHLAB_FIXTURE"] == "1"
        #else
        false
        #endif
    }
    static var supported: Bool {
        #if DEBUG
        if SpeakingEnvironment.fixtureID != nil && ProcessInfo.processInfo.environment["SC_SPEECHLAB_NO_RECOGNITION"] == "1" { return false }
        #endif
        return fixture || DictationRecognizer.isSupported
    }

    func recognize(_ url: URL) async throws -> SpeechLabTranscript {
        cancel()
        guard !Task.isCancelled else { throw CancellationError() }
        let allowed = await Self.authorized()
        guard allowed else { throw Failure.denied }
        guard !Task.isCancelled else { throw CancellationError() }
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US")),
              recognizer.supportsOnDeviceRecognition, recognizer.isAvailable else { throw Failure.unsupported }
        let request = SFSpeechURLRecognitionRequest(url: url)
        request.requiresOnDeviceRecognition = true
        request.shouldReportPartialResults = false
        let token = UUID(); generation = token
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                pending = continuation
                task = Self.makeTask(recognizer, request: request) { [weak self] result in
                    Task { @MainActor in
                        guard let self, self.generation == token else { return }
                        self.finish(result)
                    }
                }
                timeout = Task { [weak self] in
                    do { try await Task.sleep(for: .seconds(30)) } catch { return }
                    guard let self, self.generation == token else { return }
                    self.finish(.failure(Failure.noSpeech))
                }
            }
        } onCancel: { Task { @MainActor [weak self] in if self?.generation == token { self?.cancel() } } }
    }
    func cancel() { generation = UUID(); finish(.failure(Failure.cancelled)) }
    private func finish(_ result: Result<SpeechLabTranscript, Error>) {
        let continuation = pending; pending = nil
        timeout?.cancel(); timeout = nil
        task?.cancel(); task = nil
        continuation?.resume(with: result)
    }
    private nonisolated static func authorized() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { continuation.resume(returning: $0 == .authorized) }
        }
    }
    private nonisolated static func makeTask(_ recognizer: SFSpeechRecognizer, request: SFSpeechURLRecognitionRequest,
        result: @escaping @Sendable (Result<SpeechLabTranscript, Error>) -> Void) -> SFSpeechRecognitionTask {
        recognizer.recognitionTask(with: request) { value, error in
            if let value, value.isFinal {
                let transcription = value.bestTranscription
                let words = transcription.segments.map { SpeechLabWordTiming(word: $0.substring, start: $0.timestamp, duration: $0.duration) }
                result(transcription.formattedString.isEmpty ? .failure(Failure.noSpeech) : .success(.init(text: transcription.formattedString, words: words)))
            } else if let error { result(.failure(error)) }
        }
    }
}
