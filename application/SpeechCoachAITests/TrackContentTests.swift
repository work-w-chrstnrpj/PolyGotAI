import Foundation
import Testing
@testable import SpeechCoachAI

/// Every bundled coach track must load, run, and accept its own model answers.
struct TrackContentTests {
    private let install = CurriculumCatalogLoader.bundled

    private func modelResponse(_ spec: ExerciseSpec) -> ExerciseResponse? {
        switch spec.kind {
        case .wordBank: .sequence((spec.accepted?.first ?? "").split(separator: " ").map(String.init))
        case .order: .sequence(spec.items ?? [])
        case .match: .pairs(spec.pairs ?? [])
        case .choice, .fillBlank, .spotError, .listenType, .speak: .text(spec.accepted?.first ?? "")
        case .open, .none: nil
        }
    }

    @Test func authoredCoachesLoadInOrder() {
        #expect(install.tracks.tracks.map(\.coach) == TrackCoach.allCases)
        for track in install.tracks.tracks {
            // Grammarian and Reading & Listening start at A1 (Starter); every coach then has Foundation, Intermediate and Advanced.
            let starts = [TrackCoach.grammarian, .readingListening].contains(track.coach)
            let expected = starts ? ["starter", "foundation", "intermediate", "advanced"] : ["foundation", "intermediate", "advanced"]
            #expect(track.stages.map(\.id) == expected, "\(track.id) stages")
            if track.coach == .grammarian {
                // Phase 11: the Grammarian's full syllabus adds 40 lessons in 7 more units (72 in all).
                #expect(track.stages.map(\.units.count) == [3, 4, 4, 4], "grammarian units per stage")
                #expect(track.lessons.count == 72, "grammarian lesson count")
            } else {
                #expect(track.stages.allSatisfy { $0.units.count == 2 }, "\(track.id) has 2 units per stage")
                #expect(track.lessons.count == expected.count * 8, "\(track.id) has 8 lessons per stage")
            }
        }
    }

    @Test func everyTrackLessonIsReadyAndComplete() {
        for lesson in install.tracks.lessons {
            #expect(lesson.isReady, "\(lesson.id) is ready")
            #expect(!(lesson.tip ?? "").isEmpty, "\(lesson.id) has a tip")
            #expect(!(lesson.sources ?? []).isEmpty, "\(lesson.id) names its sources")
            #expect(lesson.practiceActivities.count >= 12, "\(lesson.id) has enough activities")
            #expect(lesson.practiceActivities.last?.resolvedExercise.type == "open", "\(lesson.id) ends with Your turn")
        }
    }

    @Test func everyCheckedExerciseAcceptsItsModelAnswer() {
        var checked = 0
        for lesson in install.tracks.lessons {
            for activity in lesson.practiceActivities {
                let spec = activity.resolvedExercise
                #expect(spec.problem(hasClip: activity.assetId != nil) == nil, "\(activity.id) is well formed")
                guard spec.isChecked, let response = modelResponse(spec) else { continue }
                checked += 1
                #expect(spec.evaluate(response) == .correct, "\(activity.id) accepts its model answer")
            }
        }
        #expect(checked > 400)
    }

    @Test func choiceQuestionsHaveOneCorrectOptionAndNoDuplicates() {
        for lesson in install.tracks.lessons {
            for activity in lesson.practiceActivities {
                let spec = activity.resolvedExercise
                guard spec.kind == .choice, let options = spec.options else { continue }
                #expect((spec.accepted ?? []).count == 1, "\(activity.id) has one correct option")
                #expect(Set(options).count == options.count, "\(activity.id) has distinct options")
            }
        }
    }

    @Test func trackLessonIdsAreUniqueAcrossTracks() {
        let ids = install.tracks.lessons.map(\.id)
        #expect(Set(ids).count == ids.count)
        #expect(Set(ids).isDisjoint(with: Set(install.lessons.map(\.id))))
    }
}

/// Phase 11: the Grammarian covers the core grammar syllabus.
struct GrammarianSyllabusTests {
    private let install = CurriculumCatalogLoader.bundled

    @Test func theSyllabusTopicsArePresent() throws {
        let track = try #require(install.tracks.track(id: "grammarian"))
        let titles = Set(track.lessons.map(\.title))
        for topic in ["Nouns: common and proper", "Personal pronouns", "Articles: a, an, the", "Adjectives", "Adverbs",
                      "Conjunctions and interjections", "Kinds of verbs", "Four sentence structures", "Subject–verb agreement",
                      "The tense map", "Commas", "Apostrophes", "Indicative, imperative, subjunctive", "Parallel structure"] {
            #expect(titles.contains(topic), "missing \(topic)")
        }
    }

    /// A wrong option the answer checker reads the same as the right one would be marked correct.
    @Test func noChoiceHasTwoOptionsTheCheckerCannotTellApart() {
        for lesson in install.tracks.lessons + install.lessons {
            for activity in lesson.practiceActivities {
                guard let options = activity.exercise?.options, activity.exercise?.type == "choice" else { continue }
                let normalized = options.map(AnswerChecker.normalize)
                #expect(Set(normalized).count == normalized.count, "\(activity.id): \(options)")
            }
        }
    }
}
