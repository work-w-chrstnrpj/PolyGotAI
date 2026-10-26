import Foundation
import Testing
@testable import SpeechCoachAI

/// Phase 10: minimal-pair verdicts, YIN pitch on synthetic tones, intonation shape, and the pair content.
struct PronunciationCheckTests {
    private let pair = MinimalPair(id: "pair-sheep-ship", sound: "sound-i", target: "sheep", contrast: "ship", tip: "Make it long.")

    @Test func pairVerdicts() {
        #expect(MinimalPairJudge.judge(pair, heard: "Sheep") == .clear)
        #expect(MinimalPairJudge.judge(pair, heard: "a sheep.") == .clear)
        #expect(MinimalPairJudge.judge(pair, heard: "Ship") == .soundedLike("ship"))
        #expect(MinimalPairJudge.judge(pair, heard: "shipping") == .heard("shipping"))
        #expect(MinimalPairJudge.judge(pair, heard: "  ") == .nothing)
    }

    @Test func twoWordTargetsMatchAsAPhrase() {
        let phrase = MinimalPair(id: "p", sound: "sound-h", target: "hat", contrast: "at", tip: "")
        #expect(MinimalPairJudge.judge(phrase, heard: "hat") == .clear)
        #expect(MinimalPairJudge.judge(phrase, heard: "at") == .soundedLike("at"))
    }

    // MARK: Pitch

    private func tone(_ hertz: (Double) -> Double, seconds: Double = 1.2, rate: Double = 16_000, amplitude: Float = 0.3) -> [Float] {
        var phase = 0.0
        return (0..<Int(seconds * rate)).map { index in
            let time = Double(index) / rate
            phase += 2 * .pi * hertz(time) / rate
            // A few harmonics, like a voice.
            return amplitude * Float(sin(phase) + 0.4 * sin(2 * phase) + 0.2 * sin(3 * phase)) / 1.6
        }
    }

    @Test func yinFindsASteadyPitch() {
        let points = PitchTracker.track(tone { _ in 200 }, sampleRate: 16_000).compactMap(\.hertz)
        #expect(points.count > 40)
        let median = points.sorted()[points.count / 2]
        #expect(abs(median - 200) < 4, "median \(median)")
    }

    @Test func silenceHasNoPitch() {
        let points = PitchTracker.track([Float](repeating: 0, count: 16_000), sampleRate: 16_000)
        #expect(!points.isEmpty && points.allSatisfy { $0.hertz == nil })
    }

    @Test func risingAndFallingLinesAreRecognised() {
        let rising = PitchContour(PitchTracker.track(tone { 150 + 90 * $0 }, sampleRate: 16_000))
        let falling = PitchContour(PitchTracker.track(tone { 240 - 90 * $0 }, sampleRate: 16_000))
        let level = PitchContour(PitchTracker.track(tone { _ in 180 }, sampleRate: 16_000))
        #expect(IntonationJudge.shape(of: rising) == .rising)
        #expect(IntonationJudge.shape(of: falling) == .falling)
        #expect(IntonationJudge.shape(of: level) == .level)
    }

    @Test func contourIsCentredOnTheSpeakersMedianAndNormalised() throws {
        let contour = PitchContour(PitchTracker.track(tone { _ in 220 }, sampleRate: 16_000))
        let values = contour.points.map(\.semitones)
        #expect(values.allSatisfy { abs($0) < 0.5 })
        let last = try #require(contour.normalised.last)
        #expect(abs(last.time - 1) < 0.0001)
    }

    @Test func expectedShapeFollowsTheEndMark() {
        #expect(IntonationJudge.expected(for: "You're ready?") == .rising)
        #expect(IntonationJudge.expected(for: "You're ready.") == .falling)
    }

    // MARK: Content

    @Test func everyPairBelongsToASoundAndDiffersFromItsContrast() {
        let catalog = SpeechLabCatalog.bundled
        #expect(catalog.pairs.count >= 80)
        let sounds = Set(catalog.sounds.map(\.id))
        for pair in catalog.pairs {
            #expect(sounds.contains(pair.sound), "\(pair.id)")
            #expect(AnswerChecker.normalize(pair.target) != AnswerChecker.normalize(pair.contrast), "\(pair.id)")
            #expect(!pair.tip.isEmpty, "\(pair.id)")
        }
        #expect(Set(catalog.pairs.map(\.id)).count == catalog.pairs.count)
    }

    @Test func theCommonConfusionsAreCovered() {
        let targets = Set(SpeechLabCatalog.bundled.pairs.map { "\($0.target)/\($0.contrast)" })
        for expected in ["sheep/ship", "think/sink", "right/light", "very/berry", "she/see", "west/vest"] {
            #expect(targets.contains(expected), "missing \(expected)")
        }
    }
}
