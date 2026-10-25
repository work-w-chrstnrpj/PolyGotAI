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
            #expect(track.stages.flatMap(\.units).count == 2, "\(track.id) has 2 units")
            #expect(track.lessons.count == 8, "\(track.id) has 8 lessons")
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
