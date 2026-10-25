import Foundation
import Testing
@testable import SpeechCoachAI

/// Extra acceptance checks for resource link normalization and browser handoff.
struct ResourceLibraryAcceptanceTests {
    @Test(arguments: ["https://music.youtube.com/watch?v=abcdefghijk", "https://www.youtu.be/abcdefghijk"])
    func additionalRecognizedVideoHosts(_ input: String) throws {
        #expect(try ResourceLink(input).canonical == "https://www.youtube.com/watch?v=abcdefghijk")
    }

    @Test(arguments: ["https://music.youtube.com/playlist?list=synthetic", "https://www.youtu.be/short"])
    func unsupportedShapesOnAdditionalHosts(_ input: String) {
        #expect(throws: ResourceLinkError.unsupportedYouTube) { try ResourceLink(input) }
    }

    @Test(arguments: ["token", "apikey", "password", "auth", "authorization", "signature", "AuThOrIzAtIoN", "%61uth"])
    func additionalCredentialNamesAreRejected(_ name: String) {
        #expect(throws: ResourceLinkError.invalidURL) { try ResourceLink("https://example.com/?\(name)=synthetic") }
    }

    @Test(arguments: ["home", "lan", "invalid", "test", "onion"])
    func additionalReservedSuffixesAreRejected(_ suffix: String) {
        #expect(throws: ResourceLinkError.invalidURL) { try ResourceLink("https://example.\(suffix)/") }
    }

    @Test func encodedHostCannotBypassHostValidation() {
        #expect(throws: ResourceLinkError.invalidURL) { try ResourceLink("https://%65xample.com/") }
    }

    @Test func trackingRemovalPreservesRepeatedFieldsFlagsAndOrder() throws {
        let link = try ResourceLink("https://example.com/read?chapter=2&FBCLID=synthetic&chapter=1&gclid=synthetic&flag&empty=&ut%6D_source=synthetic#section")
        #expect(link.canonical == "https://example.com/read?chapter=2&chapter=1&flag&empty=#section")
        #expect(try ResourceLink(link.canonical) == link)
    }

    @Test(arguments: [
        ("https://example.com/search?q=a%2Bb&utm_source=x", "https://example.com/search?q=a%2Bb"),
        ("https://example.com/search?next=%2Fpart%3Fx%3D1&gclid=x#part", "https://example.com/search?next=%2Fpart%3Fx%3D1#part"),
        ("https://example.com/search?q=a+b&literal=%252B&fbclid=x", "https://example.com/search?q=a+b&literal=%252B"),
        ("https://example.com/?value=%26%3D%23&blank=&flag", "https://example.com/?value=%26%3D%23&blank=&flag"),
        ("https://example.com/?", "https://example.com/?")
    ])
    func meaningfulQueryEncodingSurvivesNormalization(_ pair: (String, String)) throws {
        let link = try ResourceLink(pair.0)
        #expect(link.canonical == pair.1)
        #expect(try ResourceLink(link.canonical) == link)
    }

    @Test func encodedQuerySurvivesSaveReopenDuplicateAndOpenValidation() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("SC-D017-acceptance-\(UUID())")
        defer { try? FileManager.default.removeItem(at: root) }
        var repository: LearnerRepository? = try LearnerRepository(root: root, protectedDataAvailable: { true })
        let epoch = try #require(try repository?.learningDataEpoch())
        let destination = "https://example.com/search?q=a%2Bb&next=%2Fpart%3Fx%3D1"
        var draft = ResourceEditorDraft(epoch: epoch)
        draft.title = "Synthetic query resource"
        draft.destination = destination + "&fbclid=synthetic"
        draft.notes = "Synthetic local note"
        let saved = try #require(try repository?.saveLearningResource(draft))
        #expect(saved.destination == destination)
        repository?.close(); repository = nil
        let reopened = try LearnerRepository(root: root, protectedDataAvailable: { true })
        defer { reopened.close() }
        #expect(try reopened.learningResources() == [saved])
        let intent = try ResourceOpenIntent(destination: saved.destination, epoch: epoch, bookmark: saved)
        #expect(try reopened.resourceDestination(intent).absoluteString == destination)
        var duplicate = ResourceEditorDraft(epoch: epoch)
        duplicate.title = "Duplicate synthetic resource"
        duplicate.destination = destination + "&gclid=other&utm_source=synthetic"
        #expect(throws: ResourceLinkError.duplicate) { try reopened.saveLearningResource(duplicate) }
        #expect(try reopened.learningResources() == [saved])
        // A literal plus and an escaped plus must not collapse into one bookmark identity.
        var distinct = ResourceEditorDraft(epoch: epoch)
        distinct.title = "Different query semantics"
        distinct.destination = destination.replacingOccurrences(of: "a%2Bb", with: "a+b")
        let other = try reopened.saveLearningResource(distinct)
        #expect(other.destination != saved.destination)
        #expect(try reopened.learningResources().count == 2)
    }
}
