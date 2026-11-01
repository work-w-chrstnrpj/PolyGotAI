import Foundation
import Testing
@testable import SpeechCoachAI

@MainActor struct SpeechLabVoiceTests {
    @Test func metricsUseTimedWordsAndStrictlyLongerThanOneSecondPauses() throws {
        let words: [SpeechLabWordTiming] = [
            .init(word: "Um", start: 0, duration: 0.5), .init(word: "I", start: 1.5, duration: 0.2),
            .init(word: "like", start: 3, duration: 0.5), .init(word: "tea", start: 3.5, duration: 0.5),
            .init(word: "uh", start: 6, duration: 0.5)]
        let result = try #require(SpeechLabVoiceMetrics.measure(words, duration: 30))
        #expect(result.wordCount == 5 && result.wordsPerMinute == 10)
        #expect(result.pauses == 2 && result.fillers == 3)
    }
    @Test func invalidEmptyAndUnorderedSegmentsDoNotCreateMisleadingMetrics() {
        #expect(SpeechLabVoiceMetrics.measure([], duration: 30) == nil)
        #expect(SpeechLabVoiceMetrics.measure([], duration: .nan) == nil)
        let words: [SpeechLabWordTiming] = [.init(word: "later", start: 5, duration: 0.5), .init(word: "first", start: 0, duration: 0.5),
            .init(word: "", start: 1, duration: 1), .init(word: "no", start: -.infinity, duration: 1), .init(word: "beyond", start: 40, duration: 1)]
        let result = SpeechLabVoiceMetrics.measure(words, duration: 30)
        #expect(result?.wordCount == 2 && result?.pauses == 1)
    }
    @Test func loudnessAndPaceBoundaries() {
        #expect(SpeechLabVoiceMetrics.loudness(.nan) == .quiet)
        #expect(SpeechLabVoiceMetrics.loudness(0.1) == .quiet)
        #expect(SpeechLabVoiceMetrics.loudness(0.5) == .steady)
        #expect(SpeechLabVoiceMetrics.loudness(0.95) == .loud)
        #expect(SpeechLabVoiceMetrics(wordCount: 60, wordsPerMinute: 120, pauses: 0, fillers: 0).pace == "Comfortable pace")
        #expect(SpeechLabVoiceMetrics(wordCount: 80, wordsPerMinute: 160, pauses: 0, fillers: 0).pace == "Comfortable pace")
    }
    @Test func passagesAndWarmupsMeetTheContentContract() {
        let catalog = SpeechLabCatalog.bundled
        #expect(catalog.passages.count >= 8)
        #expect(Set(catalog.passages.map(\.level)) == Set(LevelGate.levels))
        #expect(catalog.warmups.count >= 3)
        #expect(catalog.warmups.allSatisfy { (5...60).contains($0.seconds) })
    }
    @Test func paceTrendSkipsWarmupsAndRejectsNonfiniteNumbers() {
        var state = SpeechLabState()
        state.record(.init(area: .voice, itemID: "first", wordsPerMinute: 130, pauses: 3, fillers: 2))
        state.record(.init(area: .voice, itemID: "warmup"))
        state.record(.init(area: .voice, itemID: "second", wordsPerMinute: 140, pauses: 2, fillers: 1))
        #expect(state.trend(for: .voice) == "Pace: +10 wpm from last time")
        #expect(!SpeechLabAttempt(area: .voice, itemID: "x", wordsPerMinute: .infinity).isValid)
    }
}
