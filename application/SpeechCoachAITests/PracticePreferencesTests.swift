import Foundation
import Testing
@testable import SpeechCoachAI

struct PracticePreferencesTests {
    @Test func sessionOverridesPreserveDefaultsAndSourceIdentity() {
        var defaults = LearnerPreferences(); defaults.coach = .elephantTeacher; defaults.background = .adventureAtlas
        var session = PracticeSessionContext(defaults: defaults, sourceLessonID: "synthetic-lesson", objectiveID: "INTRO-01")
        let identity = session.id
        session.coachOverride = .owlGrammarian; session.quietPractice = true
        #expect(session.effectiveCoach == .owlGrammarian)
        #expect(defaults.coach == .elephantTeacher)
        #expect(defaults.background == .adventureAtlas)
        #expect(session.sourceLessonID == "synthetic-lesson")
        #expect(session.objectiveID == "INTRO-01")
        #expect(session.id == identity)
        defaults.coach = .creativeWriter
        session.coachOverride = nil
        #expect(session.effectiveCoach == .elephantTeacher, "A running session freezes its baseline.")
    }

    @Test func allSevenCoachChoicesPersistIndependently() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("SC-T010-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        var repo: LearnerRepository? = try LearnerRepository(root: root, protectedDataAvailable: { true })
        var preferences = LearnerPreferences(); preferences.background = .mixedMediaStudio; preferences.appearance = .dark
        for coach in LearnerPreferences.Coach.allCases {
            preferences.coach = coach; try repo!.savePreferences(preferences)
            #expect(try repo!.preferences() == preferences)
        }
        repo!.close(); repo = nil
        let reopened = try LearnerRepository(root: root, protectedDataAvailable: { true })
        #expect(try reopened.preferences() == preferences)
        #expect(LearnerPreferences.Coach.allCases.count == 7)
    }
}
