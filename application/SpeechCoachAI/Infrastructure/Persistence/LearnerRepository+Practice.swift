import Foundation

/// Practice time (Lesson, Lexicon, Lab) in the learner document, next to screen time.
extension LearnerRepository {
    func practiceLog() throws -> PracticeLog { try document().practice ?? PracticeLog() }

    /// Saves one practice stretch. Stretches under a minute and repeats are ignored. Returns whether it was saved.
    @discardableResult
    func recordPractice(_ stretch: PracticeStretch) throws -> Bool {
        var stored = try document()
        var log = stored.practice ?? PracticeLog()
        guard log.record(stretch, now: try effectiveNow()) else { return false }
        stored.practice = log
        try write(stored)
        return true
    }

    func clearPractice() throws {
        var stored = try document()
        stored.practice = nil
        try write(stored)
    }
}
