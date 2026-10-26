import Foundation
import SwiftData

/// Rank (CEFR) tests passed.
extension LearnerRepository {
    func passedJumpTests() throws -> Set<String> { Set(try document().passedJumpTests ?? []) }

    func recordJumpTestPass(level: String) throws {
        let level = level.uppercased()
        guard LevelGate.levels.dropFirst().contains(level) else { throw LearnerStorageError.invalidContent }
        var stored = try document()
        var passed = stored.passedJumpTests ?? []
        if !passed.contains(level) { passed.append(level) }
        stored.passedJumpTests = passed
        try write(stored)
    }
}
