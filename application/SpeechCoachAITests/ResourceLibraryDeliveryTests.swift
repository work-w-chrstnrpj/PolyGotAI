import Foundation
import SwiftData
import Testing
@testable import SpeechCoachAI

struct ResourceLibraryDeliveryTests {
    @Test(arguments: [
        "http://example.com", "file:///private/a", "javascript:alert(1)", "data:text/plain,hello",
        "https://user:secret@example.com/a", "https://example.com@evil.com/", "https://example.com:8443/",
        "https://localhost/a", "https://127.0.0.1/", "https://[::1]/", "https://2130706433/",
        "https://0x7f000001/", "https://10.1.2.3/", "https://office.local/", "https://private.internal/",
        "https://example.com\\@evil.com/", "https://example.com/\nsecret", "https://-bad.com/",
        "https://example.com/?access_token=synthetic", "https://example.com/?api_key=synthetic"
    ])
    func rejectsUntrustedDestinations(_ input: String) {
        #expect(throws: (any Error).self) { try ResourceLink(input) }
    }

    @Test(arguments: [
        "https://youtu.be/abcdefghijk?si=tracking", "https://m.youtube.com/watch?v=abcdefghijk&t=30",
        "https://www.youtube.com/shorts/abcdefghijk", "https://youtube.com/live/abcdefghijk",
        "https://youtube.com/embed/abcdefghijk", "https://www.youtube.com/watch?v=abcdefghijk#t=1"
    ])
    func youtubeVideoFormsShareOneDestination(_ input: String) throws {
        #expect(try ResourceLink(input).canonical == "https://www.youtube.com/watch?v=abcdefghijk")
    }

    @Test(arguments: ["https://youtu.be/short", "https://youtube.com/watch?v=abcdefghijk&v=lmnopqrstuv",
                      "https://youtube.com/redirect?q=https://example.com", "https://youtube.com/playlist?list=synthetic"])
    func rejectsUnsupportedYoutubeShapes(_ input: String) {
        #expect(throws: ResourceLinkError.unsupportedYouTube) { try ResourceLink(input) }
    }

    @Test func normalizationPreservesMeaningAndExactHost() throws {
        #expect(try ResourceLink(" HTTPS://EXAMPLE.COM:443 ").canonical == "https://example.com/")
        #expect(try ResourceLink("https://example.com/read?chapter=2&utm_source=test#part").canonical == "https://example.com/read?chapter=2#part")
        #expect(try ResourceLink("https://youtube.com.evil.com/watch?v=abcdefghijk").isYouTube == false)
        #expect(try ResourceLink("https://m.youtube.com/@VOALearningEnglish?si=test").canonical == "https://www.youtube.com/@voalearningenglish")
        #expect(try ResourceLink("https://youtube.com/channel/UCabcdefghijk").canonical == "https://www.youtube.com/channel/UCabcdefghijk")
    }

    @Test func explicitSaveReopenEditAndDeletion() throws {
        let root = root(); defer { try? FileManager.default.removeItem(at: root) }
        var repo: LearnerRepository? = try store(root)
        let epoch = try #require(try repo?.learningDataEpoch())
        var draft = ResourceEditorDraft(epoch: epoch)
        draft.title = "  Synthetic resource  "; draft.destination = "https://youtu.be/abcdefghijk"
        draft.notes = "Synthetic personal notes"; draft.topic = " Speaking "
        #expect(try repo?.learningResources().isEmpty == true) // opening/editing is not a save
        let saved = try #require(try repo?.saveLearningResource(draft))
        #expect(saved.title == "Synthetic resource"); #expect(saved.topic == "Speaking")
        repo?.close(); repo = nil
        let reopened = try store(root); defer { reopened.close() }
        #expect(try reopened.learningResources() == [saved])
        var edit = ResourceEditorDraft(epoch: epoch, resource: saved)
        edit.notes = "Synthetic edited notes"
        let edited = try reopened.saveLearningResource(edit)
        #expect(edited.id == saved.id); #expect(edited.revision == saved.revision + 1)
        #expect(throws: ResourceLinkError.changed) { try reopened.saveLearningResource(edit) }
        #expect(throws: ResourceLinkError.changed) { try reopened.deleteLearningResource(saved, expectedEpoch: epoch) }
        try reopened.deleteLearningResource(edited, expectedEpoch: epoch)
        #expect(try reopened.learningResources().isEmpty)
        #expect(try reopened.allLessonJourneys().isEmpty)
        #expect(try reopened.vocabularyEnrollments().isEmpty)
    }

    @Test func duplicateFormsAndInvalidSavePreservePriorNotes() throws {
        let root = root(); defer { try? FileManager.default.removeItem(at: root) }
        let repo = try store(root); defer { repo.close() }
        let epoch = try repo.learningDataEpoch()
        var first = ResourceEditorDraft(epoch: epoch)
        first.title = "Synthetic"; first.destination = "https://youtu.be/abcdefghijk"; first.notes = "Keep this"
        let saved = try repo.saveLearningResource(first)
        var duplicate = ResourceEditorDraft(epoch: epoch)
        duplicate.title = "Other"; duplicate.destination = "https://youtube.com/shorts/abcdefghijk"
        #expect(throws: ResourceLinkError.duplicate) { try repo.saveLearningResource(duplicate) }
        var edit = ResourceEditorDraft(epoch: epoch, resource: saved); edit.destination = "http://example.com"
        #expect(throws: ResourceLinkError.invalidURL) { try repo.saveLearningResource(edit) }
        edit.destination = saved.destination; edit.title = " \n "
        #expect(throws: ResourceLinkError.titleRequired) { try repo.saveLearningResource(edit) }
        #expect(try repo.learningResources() == [saved])
    }

    @Test func failedWritesPreserveDraftAndSavedValueForRetry() throws {
        let root = root(); defer { try? FileManager.default.removeItem(at: root) }
        let repo = try store(root); defer { repo.close() }
        let storage = LearnerStorageController(repository: repo)
        try storage.beginResourceDraft()
        storage.resourceDraft?.title = "Synthetic"; storage.resourceDraft?.destination = "https://example.com"
        storage.resourceDraft?.notes = "Unsaved synthetic note"
        repo.beforeCommit = { throw LearnerStorageError.storageFailure }
        #expect(storage.saveResourceDraft() == false)
        #expect(storage.resourceDraft?.notes == "Unsaved synthetic note")
        #expect(storage.resourceDraft?.message != nil)
        #expect(try repo.learningResources().isEmpty)
        repo.beforeCommit = nil
        #expect(storage.saveResourceDraft())
        #expect(storage.resourceDraft == nil)
        let saved = try #require(try repo.learningResources().first)
        repo.beforeCommit = { throw LearnerStorageError.storageFailure }
        #expect(throws: LearnerStorageError.storageFailure) {
            try repo.deleteLearningResource(saved, expectedEpoch: repo.learningDataEpoch())
        }
        repo.beforeCommit = nil
        #expect(try repo.learningResources() == [saved])
    }

    @Test func resetRejectsStaleDraftDeleteAndExternalOpen() throws {
        let root = root(); defer { try? FileManager.default.removeItem(at: root) }
        let repo = try store(root); defer { repo.close() }
        let storage = LearnerStorageController(repository: repo)
        try storage.beginResourceDraft()
        storage.resourceDraft?.title = "Synthetic"; storage.resourceDraft?.destination = "https://example.com/"
        let draft = try #require(storage.resourceDraft)
        let saved = try repo.saveLearningResource(draft)
        let intent = try ResourceOpenIntent(destination: saved.destination, epoch: draft.epoch, bookmark: saved)
        #expect(try repo.resourceDestination(intent).absoluteString == saved.destination)
        try repo.deleteAllLearningData()
        #expect(throws: LearnerStorageError.staleVersion) { try repo.saveLearningResource(draft) }
        #expect(throws: LearnerStorageError.staleVersion) { try repo.deleteLearningResource(saved, expectedEpoch: draft.epoch) }
        #expect(throws: LearnerStorageError.staleVersion) { try repo.resourceDestination(intent) }
        #expect(storage.saveResourceDraft() == false); #expect(storage.resourceDraft == nil)
        #expect(try repo.learningResources().isEmpty)
    }

    @Test func openRejectsEditedRemovedOrSubstitutedBookmark() throws {
        let root = root(); defer { try? FileManager.default.removeItem(at: root) }
        let repo = try store(root); defer { repo.close() }
        let epoch = try repo.learningDataEpoch()
        var draft = ResourceEditorDraft(epoch: epoch)
        draft.title = "Synthetic"; draft.destination = "https://example.com/"
        let saved = try repo.saveLearningResource(draft)
        let substituted = try ResourceOpenIntent(destination: "https://example.org/", epoch: epoch, bookmark: saved)
        #expect(throws: ResourceLinkError.changed) { try repo.resourceDestination(substituted) }
        let intent = try ResourceOpenIntent(destination: saved.destination, epoch: epoch, bookmark: saved)
        var edit = ResourceEditorDraft(epoch: epoch, resource: saved); edit.notes = "Changed"
        let updated = try repo.saveLearningResource(edit)
        #expect(throws: ResourceLinkError.changed) { try repo.resourceDestination(intent) }
        let newIntent = try ResourceOpenIntent(destination: updated.destination, epoch: epoch, bookmark: updated)
        try repo.deleteLearningResource(updated, expectedEpoch: epoch)
        #expect(throws: ResourceLinkError.changed) { try repo.resourceDestination(newIntent) }
        #expect(throws: ResourceLinkError.missing) { try repo.saveLearningResource(edit) }
    }

    @Test func curatedLinksHaveExplicitProvenanceWithoutRemoteMedia() throws {
        let root = root(); defer { try? FileManager.default.removeItem(at: root) }
        let repo = try store(root); defer { repo.close() }
        let epoch = try repo.learningDataEpoch()
        for source in CuratedLearningResource.catalog {
            _ = try ResourceLink(source.destination)
            #expect(!source.source.isEmpty); #expect(!source.version.isEmpty)
        }
        let source = try #require(CuratedLearningResource.catalog.first)
        var draft = ResourceEditorDraft(epoch: epoch, curated: source)
        let saved = try repo.saveLearningResource(draft)
        #expect(saved.curatedID == source.id)
        draft = ResourceEditorDraft(epoch: epoch, resource: saved); draft.destination = "https://example.com/"
        let changed = try repo.saveLearningResource(draft)
        #expect(changed.curatedID == nil); #expect(changed.curatedVersion == nil)
        let object = try #require(try JSONSerialization.jsonObject(with: JSONEncoder().encode(changed)) as? [String: Any])
        #expect(object["thumbnail"] == nil); #expect(object["transcript"] == nil)
    }

    @Test func existingLegacyPreferencesDecodeAndSettingsDoNotOverwriteResources() throws {
        let root = root(); defer { try? FileManager.default.removeItem(at: root) }
        let repo = try store(root); defer { repo.close() }
        #expect(try repo.learningResources().isEmpty)
        let epoch = try repo.learningDataEpoch()
        var draft = ResourceEditorDraft(epoch: epoch)
        draft.title = "Synthetic"; draft.destination = "https://example.com/"
        let saved = try repo.saveLearningResource(draft)
        var preferences = try repo.preferences(); preferences.appearance = .dark
        try repo.savePreferences(preferences)
        #expect(try repo.learningResources() == [saved])
        #expect(try repo.preferences().appearance == .dark)
    }

    @Test func navigatingToAnotherEditorDoesNotOverwriteUnsavedWork() throws {
        let root = root(); defer { try? FileManager.default.removeItem(at: root) }
        let repo = try store(root); defer { repo.close() }
        let storage = LearnerStorageController(repository: repo)
        try storage.beginResourceDraft(); storage.resourceDraft?.notes = "Synthetic unsaved note"
        let first = storage.resourceDraft
        try storage.beginResourceDraft(curated: CuratedLearningResource.catalog.first)
        #expect(storage.resourceDraft == first)
        #expect(try repo.learningResources().isEmpty)
        storage.resourceDraft = nil
        try storage.beginResourceDraft(curated: CuratedLearningResource.catalog.first)
        #expect(storage.resourceDraft?.curatedID != nil)
    }

    private func root() -> URL { FileManager.default.temporaryDirectory.appendingPathComponent("SC-D017-\(UUID().uuidString)") }
    private func store(_ root: URL) throws -> LearnerRepository {
        try LearnerRepository(root: root, protectedDataAvailable: { true }, storeName: root.lastPathComponent)
    }
}
