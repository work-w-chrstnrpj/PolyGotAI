import Foundation
import SwiftData

// SDK objects stay inside persistence; views consume immutable domain snapshots.
nonisolated enum LearnerSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { .init(1, 0, 0) }
    static var models: [any PersistentModel.Type] { [StateRow.self, AttemptRow.self, FileIntentRow.self] }

    @Model final class StateRow {
        @Attribute(.unique) var key: String
        var epoch: UUID
        var preferences: Data
        var lastObservedUTC: Date
        init(epoch: UUID, preferences: Data, now: Date) {
            key = "learner"; self.epoch = epoch; self.preferences = preferences; lastObservedUTC = now
        }
    }

    @Model final class AttemptRow {
        @Attribute(.unique) var id: UUID
        var snapshot: Data
        init(id: UUID, snapshot: Data) { self.id = id; self.snapshot = snapshot }
    }

    @Model final class FileIntentRow {
        @Attribute(.unique) var id: UUID
        var value: Data
        init(id: UUID, value: Data) { self.id = id; self.value = value }
    }
}

nonisolated enum LearnerMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [LearnerSchemaV1.self] }
    static var stages: [MigrationStage] { [] }
}

struct FileIntent: Codable {
    enum Action: String, Codable { case finalize, delete }
    var id = UUID()
    var action: Action
    var attemptID: UUID
    var epoch: UUID
    var expectedVersion: Int
    var recording: RecordingSnapshot
}
