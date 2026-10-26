import AVFoundation
import Speech

@MainActor protocol TalkRecognizing: AnyObject {
    var transcript: String { get }
    var speechEndedAt: Date? { get }
    func start() async throws
    func finish() async throws -> String
    func cancel()
}

extension TalkRecognizing {
    var speechEndedAt: Date? { nil }
}

/// Owns one turn. iOS 26 uses SpeechAnalyzer with installed assets only; older systems use on-device SFSpeechRecognizer.
@MainActor final class TalkRecognition: TalkRecognizing {
    private var legacy: DictationRecognizer?
    private var legacyStartedAt: Date?
    private var modern: AnyObject?
    var transcript: String {
        if #available(iOS 26, *), let modern = modern as? AnalyzerTurn { return modern.transcript }
        return legacy?.transcript ?? ""
    }
    var speechEndedAt: Date? {
        if #available(iOS 26, *), let modern = modern as? AnalyzerTurn { return modern.speechEndedAt }
        guard let legacyStartedAt, let end = legacy?.wordTimings.map({ $0.start + $0.duration }).max(), end.isFinite else { return nil }
        return legacyStartedAt.addingTimeInterval(end)
    }
    func start() async throws {
        cancel()
        if #available(iOS 26, *) {
            let turn = AnalyzerTurn(); modern = turn
            try await turn.start()
        } else {
            let turn = DictationRecognizer(); legacy = turn
            await turn.start()
            try Task.checkCancellation()
            guard turn.isListening else { throw TalkError.recognition }
            legacyStartedAt = .now
        }
    }
    func finish() async throws -> String {
        if #available(iOS 26, *), let modern = modern as? AnalyzerTurn { return try await modern.finish() }
        guard let legacy else { throw TalkError.recognition }
        return try await legacy.finishRecognition()
    }
    func cancel() {
        legacy?.stop(); legacy = nil
        if #available(iOS 26, *), let modern = modern as? AnalyzerTurn { modern.cancel() }
        modern = nil
    }
}

@available(iOS 26, *)
@MainActor private final class AnalyzerTurn {
    private(set) var transcript = ""
    private var finalized = ""
    private var captureStartedAt: Date?
    private(set) var speechEndedAt: Date?
    private let engine = AVAudioEngine()
    private var analyzer: SpeechAnalyzer?
    private var input: AsyncStream<AnalyzerInput>.Continuation?
    private var results: Task<Void, Error>?
    private var generation = UUID()
    private var tapped = false

    func start() async throws {
        let token = generation
        guard await Self.authorized() else { throw TalkError.recognition }
        try Task.checkCancellation()
        guard token == generation, SpeechTranscriber.isAvailable,
              await SpeechTranscriber.installedLocales.contains(where: { $0.identifier.replacingOccurrences(of: "_", with: "-") == "en-US" }) else { throw TalkError.recognition }
        let transcriber = SpeechTranscriber(locale: Locale(identifier: "en-US"), preset: .progressiveTranscription)
        guard let format = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [transcriber]) else { throw TalkError.recognition }
        try Task.checkCancellation()
        guard token == generation else { throw CancellationError() }
        let analyzer = SpeechAnalyzer(modules: [transcriber]); self.analyzer = analyzer
        let audio = AVAudioSession.sharedInstance()
        try audio.setCategory(.record, mode: .measurement, options: [.duckOthers, .allowBluetoothHFP])
        try audio.setActive(true)
        let pair = AsyncStream<AnalyzerInput>.makeStream(bufferingPolicy: .bufferingOldest(64))
        input = pair.continuation
        let node = engine.inputNode
        let hardware = node.outputFormat(forBus: 0)
        guard hardware.sampleRate > 0, hardware.channelCount > 0,
              let converter = AVAudioConverter(from: hardware, to: format) else { throw TalkError.recognition }
        Self.tap(node, hardware: hardware, target: format, converter: converter, input: pair.continuation)
        tapped = true
        results = Task { [weak self] in
            for try await result in transcriber.results {
                guard let self, self.generation == token, !Task.isCancelled else { return }
                let text = String(result.text.characters)
                let seconds = CMTimeGetSeconds(CMTimeRangeGetEnd(result.range))
                if let captureStartedAt, seconds.isFinite { speechEndedAt = captureStartedAt.addingTimeInterval(seconds) }
                if result.isFinal { finalized += text; transcript = finalized }
                else { transcript = finalized + text }
            }
        }
        do {
            try await analyzer.start(inputSequence: pair.stream)
            try Task.checkCancellation()
            guard token == generation else { throw CancellationError() }
            engine.prepare(); try engine.start(); captureStartedAt = .now
        } catch { cancel(); throw error }
    }
    func finish() async throws -> String {
        stopInput()
        guard let analyzer else { throw TalkError.recognition }
        try await analyzer.finalizeAndFinishThroughEndOfInput()
        try await results?.value
        try Task.checkCancellation()
        self.analyzer = nil; results = nil
        return transcript.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    func cancel() {
        generation = UUID(); stopInput(); results?.cancel(); results = nil
        if let analyzer { Task { await analyzer.cancelAndFinishNow() } }
        analyzer = nil
    }
    private func stopInput() {
        engine.stop()
        if tapped { engine.inputNode.removeTap(onBus: 0); tapped = false }
        input?.finish(); input = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    private nonisolated static func authorized() async -> Bool {
        let speech = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { continuation.resume(returning: $0 == .authorized) }
        }
        return speech ? await AVAudioApplication.requestRecordPermission() : false
    }
    /// The converter and buffers are owned exclusively by the serial audio tap callback.
    private nonisolated static func tap(_ node: AVAudioInputNode, hardware: AVAudioFormat, target: AVAudioFormat,
                                        converter: AVAudioConverter, input: AsyncStream<AnalyzerInput>.Continuation) {
        node.installTap(onBus: 0, bufferSize: 2048, format: hardware) { buffer, _ in
            let capacity = AVAudioFrameCount(Double(buffer.frameLength) * target.sampleRate / hardware.sampleRate) + 32
            guard let output = AVAudioPCMBuffer(pcmFormat: target, frameCapacity: capacity) else { return }
            var supplied = false
            var error: NSError?
            converter.convert(to: output, error: &error) { _, status in
                if supplied { status.pointee = .noDataNow; return nil }
                supplied = true; status.pointee = .haveData; return buffer
            }
            if error == nil, output.frameLength > 0 { input.yield(AnalyzerInput(buffer: output)) }
        }
    }
}
