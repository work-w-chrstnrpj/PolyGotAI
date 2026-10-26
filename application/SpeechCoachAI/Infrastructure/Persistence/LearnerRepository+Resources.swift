import Foundation
import SwiftData

/// Learning resources, confidence note and attempt comparison formats.
extension LearnerRepository {
    func learningResources() throws -> [LearningResource] { try document().learningResources ?? [] }

    @discardableResult
    func saveLearningResource(_ draft: ResourceEditorDraft) throws -> LearningResource {
        guard try learningDataEpoch() == draft.epoch else { throw LearnerStorageError.staleVersion }
        let link = try ResourceLink(draft.destination)
        let title = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { throw ResourceLinkError.titleRequired }
        var stored = try document()
        var resources = stored.learningResources ?? []
        let index = resources.firstIndex { $0.id == draft.id }
        if let original = draft.original {
            guard let index else { throw ResourceLinkError.missing }
            guard resources[index] == original else { throw ResourceLinkError.changed }
        } else if index != nil { throw ResourceLinkError.changed }
        guard !resources.contains(where: { $0.id != draft.id && $0.destination == link.canonical }) else {
            throw ResourceLinkError.duplicate
        }
        let curated = CuratedLearningResource.catalog.first {
            $0.id == draft.curatedID && (try? ResourceLink($0.destination)) == link
        }
        let value = LearningResource(id: draft.id, revision: (draft.original?.revision ?? 0) + 1,
            title: title, destination: link.canonical,
            topic: draft.topic.trimmingCharacters(in: .whitespacesAndNewlines), notes: draft.notes,
            curatedID: curated?.id, curatedVersion: curated?.version, updatedAt: now())
        if let index { resources[index] = value } else { resources.append(value) }
        stored.learningResources = resources
        try write(stored)
        return value
    }

    func deleteLearningResource(_ resource: LearningResource, expectedEpoch: UUID) throws {
        guard try learningDataEpoch() == expectedEpoch else { throw LearnerStorageError.staleVersion }
        var stored = try document()
        guard let index = stored.learningResources?.firstIndex(where: { $0.id == resource.id }) else {
            throw ResourceLinkError.missing
        }
        guard stored.learningResources?[index] == resource else { throw ResourceLinkError.changed }
        stored.learningResources?.remove(at: index)
        try write(stored)
    }

    /// Revalidate the exact displayed destination immediately before handing it to the system.
    func resourceDestination(_ intent: ResourceOpenIntent) throws -> URL {
        guard try learningDataEpoch() == intent.epoch else { throw LearnerStorageError.staleVersion }
        if let bookmark = intent.bookmark {
            guard try learningResources().contains(bookmark), bookmark.destination == intent.link.canonical else {
                throw ResourceLinkError.changed
            }
        }
        return try ResourceLink(intent.link.canonical).url
    }
}
