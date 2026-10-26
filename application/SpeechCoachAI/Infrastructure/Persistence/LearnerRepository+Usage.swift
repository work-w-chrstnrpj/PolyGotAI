import Foundation
import SwiftData

/// Screen time for Progress analytics.
extension LearnerRepository {
    // MARK: Screen time (Progress analytics)

    func usageLog() throws -> UsageLog { try document().usage ?? UsageLog() }

    /// Saves one stretch of screen time. Stretches under a minute are ignored. Returns whether it was saved.
    @discardableResult
    func recordUsage(start: Date, end: Date) throws -> Bool {
        var stored = try document()
        var log = stored.usage ?? UsageLog()
        guard log.record(start: start, end: end, now: try effectiveNow()) else { return false }
        stored.usage = log
        try write(stored)
        return true
    }

    func clearUsage() throws {
        var stored = try document()
        stored.usage = nil
        try write(stored)
    }
}
