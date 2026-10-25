import Foundation

struct SpeechLabVoiceMetrics: Equatable {
    var wordCount: Int
    var wordsPerMinute: Double
    var pauses: Int
    var fillers: Int
    var pace: String { wordsPerMinute < 120 ? "Take a steady pace" : wordsPerMinute > 160 ? "Leave room to pause" : "Comfortable pace" }

    /// Count only timed, nonempty words inside the recording. Include the full recording duration
    /// in pace, so a long pause does not misleadingly raise words per minute.
    static func measure(_ words: [SpeechLabWordTiming], duration: Double) -> SpeechLabVoiceMetrics? {
        guard duration.isFinite, duration > 0 else { return nil }
        let valid = words.filter { $0.start.isFinite && $0.duration.isFinite && $0.start >= 0 && $0.duration > 0 && $0.start < duration && !SpeechLabDictationChecker.tokens($0.word, strict: false).isEmpty }
            .sorted { $0.start < $1.start }
        guard !valid.isEmpty else { return nil }
        let tokens = valid.flatMap { SpeechLabDictationChecker.tokens($0.word, strict: false) }
        var pauses = 0
        var lastEnd: Double?
        for word in valid {
            if let lastEnd, word.start - lastEnd > 1 { pauses += 1 }
            lastEnd = max(lastEnd ?? 0, min(duration, word.start + word.duration))
        }
        return .init(wordCount: tokens.count, wordsPerMinute: Double(tokens.count) * 60 / duration,
            pauses: pauses, fillers: tokens.filter { ["um", "uh", "like"].contains($0) }.count)
    }
    enum Loudness: String { case quiet = "Too quiet", steady = "Steady", loud = "Too loud" }
    /// RecordingController normalizes average dBFS from -60...0. These are practice hints,
    /// not calibrated sound pressure measurements.
    static func loudness(_ level: Float) -> Loudness {
        guard level.isFinite else { return .quiet }
        return level < 0.25 ? .quiet : level > 0.9 ? .loud : .steady
    }
}

struct SpeechLabPassage: Codable, Equatable, Identifiable {
    var id: String
    var title: String
    var level: String
    var text: String
}
struct SpeechLabWarmup: Codable, Equatable, Identifiable {
    var id: String
    var title: String
    var text: String
    var seconds: Int
}
