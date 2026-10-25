import Foundation
import Testing
@testable import SpeechCoachAI

@MainActor struct SpeechLabPhoneticsTests {
    @Test func soundChartHasAllGroupsAndUsableCheckedLessons() {
        let catalog = SpeechLabCatalog.bundled
        #expect(catalog.sounds.count >= 40)
        #expect(Set(catalog.sounds.map(\.id)).count == catalog.sounds.count)
        #expect(Set(catalog.sounds.map(\.group)) == ["Vowels", "Diphthongs", "R-colored vowels", "Consonants"])
        for sound in catalog.sounds {
            #expect(sound.examples.count == 3 && !sound.ipa.isEmpty && !sound.tip.isEmpty)
            #expect(sound.activity.resolvedExercise.problem() == nil)
            #expect(sound.activity.resolvedExercise.evaluate(.text(sound.cue)) == .correct)
            #expect(sound.activity.resolvedExercise.evaluate(.text("not an option")) == .incorrect)
        }
        #expect(catalog.sounds.filter { $0.partner != nil }.count == 16)
    }
    @Test func stressAndIntonationHaveCheckedAnswers() {
        let items = SpeechLabCatalog.bundled.prosody
        #expect(items.count >= 6)
        #expect(Set(items.map(\.kind)) == ["stress", "intonation"])
        for item in items { #expect(item.activity.resolvedExercise.evaluate(.text(item.answer)) == .correct) }
    }
    @Test func spokenPracticeDoesNotProduceAnAccuracyScore() {
        let attempt = SpeechLabAttempt(area: .phonetics, itemID: "sound-ih")
        #expect(attempt.accuracy == nil)
        #expect(attempt.summary == "Practice complete")
    }
}
