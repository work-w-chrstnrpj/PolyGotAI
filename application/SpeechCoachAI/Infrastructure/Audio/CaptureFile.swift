import AVFAudio
import Foundation

/// Inspect the file's storage format, not AVAudioFile's floating-point processing format.
struct CaptureFile {
    let data: Data
    let durationMilliseconds: Int
    let sampleRate: Int
    let channels: Int
    let bits: Int

    init(url: URL) throws {
        let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
        guard (44...32 * 1024 * 1024).contains(size) else { throw LearnerStorageError.invalidContent }
        let bytes = try Data(contentsOf: url)
        guard bytes.prefix(4) == Data("RIFF".utf8), bytes.dropFirst(8).prefix(4) == Data("WAVE".utf8) else {
            throw LearnerStorageError.invalidContent
        }
        let file = try AVAudioFile(forReading: url)
        let format = file.fileFormat.streamDescription.pointee
        guard format.mFormatID == kAudioFormatLinearPCM,
              format.mFormatFlags & kAudioFormatFlagIsSignedInteger != 0,
              format.mFormatFlags & kAudioFormatFlagIsFloat == 0,
              format.mChannelsPerFrame == 1, format.mBitsPerChannel == 16,
              format.mSampleRate.isFinite, format.mSampleRate > 0 else {
            throw LearnerStorageError.invalidContent
        }
        let seconds = Double(file.length) / format.mSampleRate
        guard seconds >= 1, seconds <= 120 else { throw LearnerStorageError.invalidContent }
        data = bytes; durationMilliseconds = Int((seconds * 1000).rounded())
        sampleRate = Int(format.mSampleRate.rounded()); channels = Int(format.mChannelsPerFrame)
        bits = Int(format.mBitsPerChannel)
    }
}
