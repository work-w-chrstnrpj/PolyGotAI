import AVFoundation
import os

/// Pitch lines for the Pronunciation check (Phase 10): the learner's recording and the model voice, on the device.
nonisolated enum PitchAnalysis {
    static let sampleRate = 16_000.0

    /// The learner's private recording as a pitch line. Runs off the main actor; nothing leaves the phone.
    nonisolated static func contour(of url: URL) async -> PitchContour? {
        await Task.detached(priority: .userInitiated) {
            guard let samples = try? loadSamples(url) else { return nil }
            return PitchContour(PitchTracker.track(samples, sampleRate: sampleRate))
        }.value
    }

    /// The model voice's pitch line for `text`, rendered silently with the chosen system voice.
    @MainActor static func modelContour(_ text: String, settings: VoiceSettings) async -> PitchContour? {
        guard let samples = await ModelVoiceRenderer().render(text, settings: settings) else { return nil }
        return await Task.detached(priority: .userInitiated) {
            PitchContour(PitchTracker.track(samples, sampleRate: sampleRate))
        }.value
    }

    /// Mono Float samples at 16 kHz from any file AVAudioFile can read.
    nonisolated static func loadSamples(_ url: URL) throws -> [Float] {
        let file = try AVAudioFile(forReading: url)
        guard file.length > 0, file.length < Int64(file.processingFormat.sampleRate * 120),
              let input = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length)) else { return [] }
        try file.read(into: input)
        return convert(input) ?? []
    }

    /// Converts any PCM buffer to mono Float at 16 kHz.
    nonisolated static func convert(_ input: AVAudioPCMBuffer) -> [Float]? {
        guard let target = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: sampleRate, channels: 1, interleaved: false),
              let converter = AVAudioConverter(from: input.format, to: target) else { return nil }
        let ratio = sampleRate / input.format.sampleRate
        let capacity = AVAudioFrameCount(Double(input.frameLength) * ratio) + 1024
        guard let output = AVAudioPCMBuffer(pcmFormat: target, frameCapacity: capacity) else { return nil }
        var supplied = false
        var failure: NSError?
        let status = converter.convert(to: output, error: &failure) { _, outStatus in
            if supplied { outStatus.pointee = .endOfStream; return nil }
            supplied = true; outStatus.pointee = .haveData; return input
        }
        guard status != .error, let channel = output.floatChannelData?[0] else { return nil }
        return Array(UnsafeBufferPointer(start: channel, count: Int(output.frameLength)))
    }
}

/// Renders an utterance to memory with `AVSpeechSynthesizer.write`, so the model's pitch can be measured.
@MainActor final class ModelVoiceRenderer {
    private let synthesizer = AVSpeechSynthesizer()

    func render(_ text: String, settings: VoiceSettings) async -> [Float]? {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = settings.voice
        utterance.rate = settings.speechRate
        let collected = OSAllocatedUnfairLock(initialState: [Float]())
        let finished = OSAllocatedUnfairLock(initialState: false)
        return await withCheckedContinuation { (continuation: CheckedContinuation<[Float]?, Never>) in
            let timeout = Task { @MainActor in
                try? await Task.sleep(for: .seconds(10))
                if finished.withLock({ let was = $0; $0 = true; return !was }) { continuation.resume(returning: nil) }
            }
            // Called on a synthesizer queue, never the main actor.
            synthesizer.write(utterance) { @Sendable buffer in
                guard let pcm = buffer as? AVAudioPCMBuffer else { return }
                if pcm.frameLength == 0 {
                    guard finished.withLock({ let was = $0; $0 = true; return !was }) else { return }
                    timeout.cancel()
                    let samples = collected.withLock { $0 }
                    continuation.resume(returning: samples.isEmpty ? nil : samples)
                    return
                }
                if let chunk = PitchAnalysis.convert(pcm) { collected.withLock { $0.append(contentsOf: chunk) } }
            }
        }
    }
}
