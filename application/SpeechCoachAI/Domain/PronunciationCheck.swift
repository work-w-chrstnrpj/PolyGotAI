import Accelerate
import Foundation

// MARK: Minimal pairs (Phase 10)

/// Two words that differ by one sound. The learner says `target`; hearing `contrast` means the sound slipped.
struct MinimalPair: Codable, Equatable, Identifiable {
    var id: String
    /// The `SpeechLabSound` this pair practises.
    var sound: String
    var target: String
    var contrast: String
    /// How to fix it when the contrast was heard.
    var tip: String
}

enum PairVerdict: Equatable {
    /// The recogniser heard the target word.
    case clear
    /// It heard the other word of the pair.
    case soundedLike(String)
    /// It heard something else.
    case heard(String)
    /// Nothing was recognised.
    case nothing
}

enum MinimalPairJudge {
    /// Judges the best transcription. Only whole words count, so "ship" never matches "shipping".
    static func judge(_ pair: MinimalPair, heard: String) -> PairVerdict {
        let words = AnswerChecker.words(in: heard)
        guard !words.isEmpty else { return .nothing }
        let target = AnswerChecker.words(in: pair.target), contrast = AnswerChecker.words(in: pair.contrast)
        if contains(words, target) { return .clear }
        if contains(words, contrast) { return .soundedLike(pair.contrast) }
        return .heard(heard.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private static func contains(_ words: [String], _ phrase: [String]) -> Bool {
        guard !phrase.isEmpty, words.count >= phrase.count else { return false }
        return (0...(words.count - phrase.count)).contains { Array(words[$0..<($0 + phrase.count)]) == phrase }
    }
}

// MARK: Pitch (YIN)

nonisolated struct PitchPoint: Equatable, Sendable {
    var time: Double
    /// Fundamental frequency in hertz; nil where the frame is silent or unvoiced.
    var hertz: Double?
}

/// YIN fundamental-frequency estimate (de Cheveigné and Kawahara, 2002), for speech between 70 and 450 Hz.
nonisolated enum PitchTracker {
    static let minimumHertz = 70.0
    static let maximumHertz = 450.0

    static func track(_ samples: [Float], sampleRate: Double, frame: Int = 1024, hop: Int = 256,
                      threshold: Float = 0.15, silence: Float = 0.01) -> [PitchPoint] {
        guard sampleRate > 0, samples.count >= frame else { return [] }
        let minLag = max(2, Int(sampleRate / maximumHertz)), maxLag = min(frame / 2, Int(sampleRate / minimumHertz))
        guard maxLag > minLag else { return [] }
        var points: [PitchPoint] = []
        var difference = [Float](repeating: 0, count: maxLag + 1)
        var scratch = [Float](repeating: 0, count: frame)
        samples.withUnsafeBufferPointer { x in
            var start = 0
            while start + frame <= x.count {
                let time = Double(start + frame / 2) / sampleRate
                var energy: Float = 0
                vDSP_svesq(x.baseAddress! + start, 1, &energy, vDSP_Length(frame))
                let rms = (energy / Float(frame)).squareRoot()
                guard rms >= silence else { points.append(PitchPoint(time: time, hertz: nil)); start += hop; continue }
                let window = frame - maxLag
                scratch.withUnsafeMutableBufferPointer { delta in
                    for lag in 1...maxLag {
                        // delta = x[start + lag ..] - x[start ..], then the sum of squares (vectorised).
                        vDSP_vsub(x.baseAddress! + start, 1, x.baseAddress! + start + lag, 1, delta.baseAddress!, 1, vDSP_Length(window))
                        var sum: Float = 0
                        vDSP_svesq(delta.baseAddress!, 1, &sum, vDSP_Length(window))
                        difference[lag] = sum
                    }
                }
                // Cumulative mean normalised difference.
                var running: Float = 0
                var normalised = [Float](repeating: 1, count: maxLag + 1)
                for lag in 1...maxLag {
                    running += difference[lag]
                    normalised[lag] = running > 0 ? difference[lag] * Float(lag) / running : 1
                }
                var chosen: Int?
                var lag = minLag
                while lag <= maxLag {
                    if normalised[lag] < threshold {
                        while lag + 1 <= maxLag, normalised[lag + 1] < normalised[lag] { lag += 1 }
                        chosen = lag; break
                    }
                    lag += 1
                }
                if let tau = chosen {
                    // Parabolic interpolation around the minimum.
                    var refined = Double(tau)
                    if tau > 1, tau < maxLag {
                        let a = normalised[tau - 1], b = normalised[tau], c = normalised[tau + 1]
                        let denominator = a - 2 * b + c
                        if denominator != 0 { refined += Double((a - c) / (2 * denominator)) }
                    }
                    let hertz = sampleRate / refined
                    points.append(PitchPoint(time: time, hertz: (minimumHertz...maximumHertz).contains(hertz) ? hertz : nil))
                } else {
                    points.append(PitchPoint(time: time, hertz: nil))
                }
                start += hop
            }
        }
        return points
    }
}

/// A pitch line in semitones around the speaker's own median, smoothed, ready to draw and compare.
nonisolated struct PitchContour: Equatable, Sendable {
    struct Point: Equatable, Sendable { var time: Double; var semitones: Double }
    var points: [Point]
    var duration: Double

    init(points: [Point], duration: Double) { self.points = points; self.duration = duration }

    init(_ track: [PitchPoint]) {
        let voiced = track.compactMap { point in point.hertz.map { (point.time, $0) } }
        guard !voiced.isEmpty else { self.init(points: [], duration: track.last?.time ?? 0); return }
        let sorted = voiced.map(\.1).sorted()
        let median = sorted[sorted.count / 2]
        let raw = voiced.map { Point(time: $0.0, semitones: 12 * log2($0.1 / median)) }
        // Five-point median filter removes octave jumps and single bad frames.
        let smoothed = raw.indices.map { index -> Point in
            let window = raw[max(0, index - 2)...min(raw.count - 1, index + 2)].map(\.semitones).sorted()
            return Point(time: raw[index].time, semitones: window[window.count / 2])
        }
        let start = smoothed.first?.time ?? 0
        self.init(points: smoothed.map { Point(time: $0.time - start, semitones: $0.semitones) },
                  duration: (smoothed.last?.time ?? 0) - start)
    }

    /// Points stretched to 0…1 in time, so a learner's line and the model's line can share one chart.
    var normalised: [Point] {
        guard duration > 0 else { return points }
        return points.map { Point(time: $0.time / duration, semitones: $0.semitones) }
    }
}

enum IntonationShape: String, Equatable { case rising, falling, level }

enum IntonationJudge {
    static let threshold = 1.5

    /// Compares the last fifth of the voiced line with its middle. Needs at least eight voiced frames.
    static func shape(of contour: PitchContour) -> IntonationShape? {
        let points = contour.points
        guard points.count >= 8 else { return nil }
        let count = points.count
        let middle = points[(count * 3 / 10)..<max(count * 3 / 10 + 1, count * 7 / 10)].map(\.semitones)
        let end = points[(count * 4 / 5)..<count].map(\.semitones)
        let difference = end.reduce(0, +) / Double(end.count) - middle.reduce(0, +) / Double(middle.count)
        if difference >= threshold { return .rising }
        if difference <= -threshold { return .falling }
        return .level
    }

    /// The shape an intonation item asks for: a yes/no question rises, a statement falls.
    static func expected(for text: String) -> IntonationShape {
        text.trimmingCharacters(in: .whitespacesAndNewlines).hasSuffix("?") ? .rising : .falling
    }
}
