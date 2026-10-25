import Foundation
import Testing
@testable import SpeechCoachAI

@MainActor
struct SavedCommunicationLinksTests {
    @Test func archivedPracticeRemainsReachableWithoutListingUnsavedVersions() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let repository = try LearnerRepository(root: root, protectedDataAvailable: { true })
        defer { repository.close() }
        let install = CurriculumCatalogLoader.bundled
        let lesson = try #require(install.lesson(id: "a1-greetings", version: "3"))
        #expect(try SavedCommunicationLinks.savedLessons(install: install, repository: repository).isEmpty)
        let source = CommunicationSource(lessonID: lesson.id, contentVersion: lesson.contentVersion,
            objectiveID: lesson.objectiveId, senseID: nil)
        let session = CommunicationPractice.blank(entry: .learn, source: source)
        let archive = SpeakingPracticeArchive(kind: session.archiveKind, drafts: ["answer": "Synthetic draft"],
            expiresAt: nil, communication: session, updatedAt: .now)
        try repository.saveSpeakingPractice(archive, expectedEpoch: repository.learningDataEpoch())
        var currentSource = source
        currentSource.contentVersion = "4"
        let current = CommunicationPractice.blank(entry: .learn, source: currentSource)
        try repository.saveSpeakingPractice(SpeakingPracticeArchive(kind: current.archiveKind, drafts: [:],
            expiresAt: nil, communication: current, updatedAt: .now), expectedEpoch: repository.learningDataEpoch())
        let listed = try SavedCommunicationLinks.savedLessons(install: install, repository: repository)
        #expect(listed.count == 1)
        #expect(listed.first?.id == lesson.id && listed.first?.contentVersion == "3")
        #expect(try repository.speakingPractice(session.archiveKind)?.drafts["answer"] == "Synthetic draft")
        #expect(try repository.lessonJourneys(lessonID: lesson.id).isEmpty)
        try repository.removeSpeakingPractice(session.archiveKind, expectedEpoch: repository.learningDataEpoch())
        #expect(try SavedCommunicationLinks.savedLessons(install: install, repository: repository).isEmpty)
    }
}
