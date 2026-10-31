import Foundation
import Testing
@testable import SpeechCoachAI

/// Phase 10: minimal-pair verdicts and the pair content (pitch judging removed in Phase 12).
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
