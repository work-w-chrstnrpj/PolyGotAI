import Foundation

extension CurrentLessons {
    /// Today's lessons from the learner's saved journeys. Empty when storage is closed.
    init(storage: LearnerStorageController, install: CurriculumInstall) {
        guard let repository = storage.repository else {
            self.init(course: nil, coaches: [], dueWords: 0)
            return
        }
        let journeys = (try? repository.allLessonJourneys()) ?? []
        let due = (try? repository.reviewQueue().due.count) ?? 0
        self = CurrentLessons.make(install: install, journeys: journeys, gate: storage.levelGate(install: install), dueWords: due)
    }
}
