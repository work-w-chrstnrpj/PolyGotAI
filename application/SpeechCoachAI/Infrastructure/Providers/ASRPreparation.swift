import AVFAudio
import Foundation

/// Pure local preparation: no credential access, transport, cache or persisted submission copy.
struct ASRPreparation {
    let wav: Data
    let requestBody: Data

    init(original: URL) throws {
        _ = try CaptureFile(url: original) // Enforce verified local contract before conversion.
        let file = try AVAudioFile(forReading: original)
        guard file.length > 0, file.length <= 16 * 1024 * 1024,
              let input = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length)),
              let target = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 16_000, channels: 1, interleaved: true),
              let converter = AVAudioConverter(from: file.processingFormat, to: target),
              let output = AVAudioPCMBuffer(pcmFormat: target, frameCapacity: 4096) else {
            throw LearnerStorageError.invalidContent
        }
        try file.read(into: input)
        guard input.frameLength == file.length else { throw LearnerStorageError.integrityFailure }
        var supplied = false
        var pcm = Data()
        var ended = false
        // The converter owns resampling; bounded loop rejects non-progress rather than hanging.
        for _ in 0..<512 {
            var error: NSError?
            let result = converter.convert(to: output, error: &error) { _, status in
                if supplied { status.pointee = .endOfStream; return nil }
                supplied = true; status.pointee = .haveData; return input
            }
            guard error == nil, result != .error else { throw LearnerStorageError.invalidContent }
            if output.frameLength > 0 {
                guard let samples = output.int16ChannelData?[0] else { throw LearnerStorageError.invalidContent }
                // Apple platforms are little endian; serialize explicitly for the WAV contract.
                for index in 0..<Int(output.frameLength) {
                    var sample = samples[index].littleEndian
                    withUnsafeBytes(of: &sample) { pcm.append(contentsOf: $0) }
                }
            }
            guard pcm.count <= 120 * 16_000 * 2 else { throw LearnerStorageError.invalidContent }
            if result == .endOfStream { ended = true; break }
            guard output.frameLength > 0 else { throw LearnerStorageError.invalidContent }
        }
        guard ended, pcm.count >= 16_000 * 2 else { throw LearnerStorageError.invalidContent }
        var wav = Data("RIFF".utf8)
        func append16(_ value: UInt16) { var little = value.littleEndian; withUnsafeBytes(of: &little) { wav.append(contentsOf: $0) } }
        func append32(_ value: UInt32) { var little = value.littleEndian; withUnsafeBytes(of: &little) { wav.append(contentsOf: $0) } }
        append32(UInt32(pcm.count + 36)); wav.append(Data("WAVEfmt ".utf8))
        append32(16); append16(1); append16(1); append32(16_000); append32(32_000)
        append16(2); append16(16); wav.append(Data("data".utf8)); append32(UInt32(pcm.count)); wav.append(pcm)
        guard wav.count <= 4 * 1024 * 1024 else { throw LearnerStorageError.invalidContent }
        let body: [String: Any] = [
            "model": "qwen3-asr-flash", "stream": false,
            "messages": [["role": "user", "content": [["type": "input_audio", "input_audio": ["data": "data:audio/wav;base64," + wav.base64EncodedString()]]]]],
            "asr_options": ["language": "en", "enable_itn": false]
        ]
        let encoded = try JSONSerialization.data(withJSONObject: body)
        guard encoded.count <= 6 * 1024 * 1024 else { throw LearnerStorageError.invalidContent }
        self.wav = wav; requestBody = encoded
    }
}
