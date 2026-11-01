import Foundation
import Testing
import UIKit
@testable import SpeechCoachAI

@MainActor struct CoachTrackPresentationTests {
    @Test func everyCoachHasItsOwnBundledPortrait() throws {
        let names = try TrackCoach.allCases.map { coach in
            let name = try #require(coach.artwork, "\(coach.title) needs a portrait")
            #expect(UIImage(named: name) != nil, "Missing bundled portrait: \(name)")
            return name
        }
        #expect(Set(names).count == TrackCoach.allCases.count)
    }

    @Test func threeStagesSelectTheirOwnUnitsAndCountOnlyExactVersionCompletions() {
        let stages = ["foundation", "intermediate", "advanced"].map { id in
            let lesson = ResolvedLesson(id: id, level: "A2", title: id, objectiveId: id,
                contentVersion: "2", availability: .ready, practiceActivities: [])
            return TrackStage(id: id, title: id.capitalized, units: [TrackUnit(id: id, title: id, lessons: [lesson])])
        }
        let track = Track(id: "synthetic", coach: .debater, stages: stages)
        let done = LessonJourney(id: UUID(), lessonID: "intermediate", objectiveID: "intermediate", contentVersion: "2",
            presenter: "synthetic", currentActivityID: nil, responses: [], completedAt: .now)
        var archived = done; archived.lessonID = "advanced"; archived.contentVersion = "1"
        #expect(CoachTrackPresentation.progress(track.lessons, journeys: [done, archived, done]) == "1 of 3 lessons done")
        for stage in stages {
            #expect(CoachTrackPresentation.stage(in: track, selected: stage.id)?.units.first?.id == stage.id)
        }
        #expect(CoachTrackPresentation.stage(in: track, selected: "removed")?.id == "foundation")
        for count in 1...3 {
            var partial = track; partial.stages = Array(stages.prefix(count))
            #expect(CoachTrackPresentation.stage(in: partial, selected: nil)?.id == "foundation")
        }
    }
}
