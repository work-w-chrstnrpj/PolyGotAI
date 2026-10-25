import CryptoKit
import Foundation
import Testing
@testable import SpeechCoachAI

struct CurriculumCatalogTests {
    @Test func bundledIntroductionsLessonIsReady() throws {
        let install = CurriculumCatalogLoader().loadBundled()
        let lesson = try #require(install.lessons(at: "A1").first { $0.id == "intro-01" })
        #expect(lesson.isReady)
        #expect(lesson.objectiveId == "INTRO-01")
        #expect(lesson.senses.count == 5)
        #expect(lesson.practiceActivities.map(\.id).contains("listen-alex"))
        #expect(lesson.practiceActivities.first { $0.id == "listen-alex" }?.playbackPath == "intro-01-alex.wav")
        #expect(lesson.practiceActivities.contains { $0.id == "transfer-neighbor" } == false)
        #expect(lesson.practiceActivities.contains { $0.id == "baseline-intro" } == false)
        #expect(install.lessons(at: "A1").filter(\.isReady).count == 13)
        #expect(install.lessons(at: "A2").filter(\.isReady).count == 11)
        #expect(install.lessons(at: "B1").filter(\.isReady).count == 10)
        #expect(install.lessons(at: "B2").filter(\.isReady).count == 10)
        #expect(install.lessons(at: "C1").filter(\.isReady).count == 8)
        #expect(install.lessons(at: "C2").filter(\.isReady).count == 5)
        #expect(install.lessons.filter { $0.isReady }.count == 57)
        #expect(install.lessons.filter { $0.senses.count == 5 }.count == 57)
        let introGrammar = lesson.practiceActivities.filter { $0.id.hasPrefix("grammar-") }
        #expect(introGrammar.map(\.id) == ["grammar-be-am", "grammar-be-is", "grammar-study", "grammar-works", "grammar-do"])
        #expect(introGrammar.map(\.answer) == ["am", "is", "study", "works", "Do"])
        #expect(introGrammar.allSatisfy { $0.required })
        #expect(introGrammar.map { $0.choiceSet ?? [] } == [
            ["am", "is", "are"], ["am", "is", "are"], ["study", "studies", "studying"], ["work", "works", "working"], ["Do", "Does", "Is"]
        ])
        #expect(introGrammar.map(\.explanation) == [
            "With I, use am: I am a student.",
            "With she or he, use is.",
            "With I, use study. Studies is the he/she form.",
            "With he, use works.",
            "With you, start the question with Do. Does is the he/she auxiliary."
        ])
        #expect(introGrammar.map { $0.childObjectiveIds ?? [] } == [
            ["EF-03-BE-01"], ["EF-03-BE-01"], ["EF-03-PRES-01"], ["EF-03-PRES-01"], ["EF-03-PRES-01"]
        ])
        #expect(lesson.contentVersion == "4")
        #expect(lesson.practiceActivities.filter { $0.choiceSet != nil }.count == 5)
        let places = try #require(install.lessons(at: "A1").first { $0.id == "a1-places" })
        #expect(places.practiceActivities.contains { $0.kind == "listening" })
        #expect(places.practiceActivities.contains { $0.id == "a1-places-transfer" } == false)
        let debate = try #require(install.lessons(at: "C2").first { $0.id == "c2-debate" })
        #expect(debate.practiceActivities.first { $0.kind == "listening" }?.playbackPath == "c2-debate.wav")
    }

    @Test func introCoreHasSixQuestionsAndLeavesTheRestOfThePackAlone() throws {
        let url = try #require(Bundle.main.url(forResource: "CurriculumCatalog", withExtension: "json"))
        let manifest = try JSONDecoder().decode(CurriculumManifest.self, from: Data(contentsOf: url))
        let intro = try #require(manifest.lessons.first { $0.id == "intro-01" })
        let install = CurriculumCatalogLoader().loadBundled()
        let ready = try #require(install.lessons.first { $0.id == "intro-01" })
        #expect(intro.contentVersion == "4")
        #expect(manifest.lessons.filter { $0.level != "A1" }.allSatisfy { $0.contentVersion == "2" })
        #expect(manifest.contentVersion == "3")
        let asset = try #require(manifest.assets.first { $0.id == "intro-01-listen-alex" })
        #expect(asset.relativePath == "intro-01-alex.wav")
        #expect(asset.byteCount == 200826)
        #expect(asset.sha256 == "e059e4a8a078787000fdc9e2cf050f51cd1e8e92aad940a0894566d16f8ea894")

        let reading = intro.activities.filter { $0.kind == "reading" }
        let listening = intro.activities.filter { $0.kind == "listening" }
        #expect(reading.map(\.id) == ["read-mina", "read-mina-name", "read-mina-like"])
        #expect(listening.map(\.id) == ["listen-alex-name", "listen-alex", "listen-alex-like"])
        #expect(reading.map(\.answer) == ["Mina studies English.", "Her name is Mina.", "She likes cooking."])
        #expect(listening.map(\.answer) == ["The speaker's name is Alex.", "Alex is a cook.", "Alex likes music."])
        #expect(reading.allSatisfy { $0.required && $0.withheldFromPractice != true && $0.assetId == nil })
        #expect(listening.allSatisfy { $0.required && $0.assetId == "intro-01-listen-alex" && $0.withheldFromPractice != true })
        #expect(reading.allSatisfy { ($0.prompt ?? "").contains("Hello. My name is Mina. I study English. I like cooking.") })
        #expect(listening.allSatisfy { ($0.prompt ?? "").contains("different person from the reading") })
        #expect(reading.allSatisfy { !($0.prompt ?? "").contains("music") && !($0.answer ?? "").contains("cook.") })
        #expect(listening.allSatisfy { !($0.prompt ?? "").contains("Mina") && !($0.prompt ?? "").contains("English") })

        #expect(intro.activities.filter { $0.id.hasPrefix("grammar-") }.map(\.id) == [
            "grammar-be-am", "grammar-be-is", "grammar-study", "grammar-works", "grammar-do"
        ])
        #expect(intro.activities.filter { $0.kind == "recall" }.map(\.id) == [
            "recall-name", "recall-from", "recall-study", "recall-like", "recall-meet"
        ])
        #expect(intro.senses.map(\.itemId) == ["intro-name", "intro-origin", "intro-study", "intro-like", "intro-meet"])
        #expect(intro.senses.map(\.senseId) == ["called", "place", "study", "enjoy", "greeting"])
        let guided = try #require(intro.activities.first { $0.id == "guided-intro" })
        let quiet = try #require(intro.activities.first { $0.id == "quiet-intro" })
        let review = try #require(intro.activities.first { $0.id == "self-review" })
        #expect(guided.kind == "guidedSpeaking" && guided.required && guided.withheldFromPractice != true)
        #expect(quiet.kind == "quietText" && quiet.required && quiet.alternativeToActivityID == "guided-intro")
        #expect(review.kind == "selfReview" && review.required)
        let reserved = intro.activities.filter { $0.withheldFromPractice == true }
        #expect(reserved.map(\.id) == ["baseline-intro", "transfer-neighbor", "transfer-class"])
        #expect(reserved.allSatisfy { $0.required == false })

        #expect(ready.practiceActivities.map(\.id) == [
            "read-mina", "read-mina-name", "read-mina-like",
            "listen-alex-name", "listen-alex", "listen-alex-like",
            "grammar-be-am", "grammar-be-is", "grammar-study", "grammar-works", "grammar-do",
            "recall-name", "recall-from", "recall-study", "recall-like", "recall-meet",
            "guided-intro", "self-review", "quiet-intro",
        ])
        #expect(ready.sessionActivities.map(\.id).contains("quiet-intro") == false)
        #expect(ready.sessionActivities.map(\.id).contains("guided-intro"))
        #expect(ready.practiceActivities.contains { $0.id == "baseline-intro" || $0.id == "transfer-neighbor" || $0.id == "transfer-class" } == false)
        #expect(ready.practiceActivities.filter { $0.kind == "listening" }.allSatisfy { $0.playbackPath == "intro-01-alex.wav" })
        let places = try #require(manifest.lessons.first { $0.id == "a1-places" })
        #expect(places.contentVersion == "4")
        #expect(places.objectiveId == "PLACE-01")
        #expect(places.activities.contains { $0.id == "a1-places-transfer" && $0.withheldFromPractice == true })
        #expect(manifest.lessons.count == 57)
        #expect(install.lessons.filter(\.isReady).count == 57)
    }

    @Test func validPackOpensOnlyTheReviewedLessonAndHidesReservedPrompts() throws {
        let audio = Data("synthetic-audio".utf8)
        let wrongHash = String(repeating: "ab", count: 32)
        let install = try load(manifest: pack(listeningHash: wrongHash, listeningBytes: audio.count), files: ["model.wav": audio])
        let ready = try #require(install.lessons(at: "A1").first { $0.isReady })
        #expect(ready.practiceActivities.map(\.id) == ["read-1", "quiet-1"])
        #expect(ready.practiceActivities.contains { $0.id == "transfer-1" } == false)
        let blocked = try #require(install.lessons.first { $0.id == "listen-broken" })
        #expect(blocked.isReady == false)
        if case .unavailable(.corruptAsset(_)) = blocked.availability {} else {
            Issue.record("A mismatched audio file must not make listening ready")
        }
    }

    @Test func missingReviewKeepsACompletePackUnavailable() throws {
        var manifest = pack(listeningHash: hash(Data("synthetic-audio".utf8)), listeningBytes: Data("synthetic-audio".utf8).count)
        manifest.editorialApprovalReference = ""
        let install = try load(manifest: manifest, files: ["model.wav": Data("synthetic-audio".utf8)])
        #expect(install.hasReadyLesson == false)
        #expect(install.lessons.allSatisfy {
            if case .unavailable(.missingReview) = $0.availability { return true }
            return false
        })
    }

    @Test func missingAudioDoesNotBecomeReading() throws {
        let install = try load(manifest: pack(listeningHash: hash(Data("synthetic-audio".utf8)), listeningBytes: 15), files: [:])
        let listening = try #require(install.lessons.first { $0.id == "listen-broken" })
        #expect(listening.isReady == false)
        if case .unavailable(.missingAsset(_)) = listening.availability {} else {
            Issue.record("Missing listening audio must stay unavailable")
        }
        #expect(install.lessons.first { $0.id == "intro-ready" }?.isReady == true)
    }

    @Test func unreadableCatalogMarksNothingReady() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("SC-T019-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        try Data("not-json".utf8).write(to: root.appendingPathComponent("CurriculumCatalog.json"))
        let install = CurriculumCatalogLoader().load(directory: root)
        #expect(install.hasReadyLesson == false)
        #expect(install.problem != nil)
    }

    @Test func legacyActivityDecodesWithoutOptionalMetadata() throws {
        let manifest = try decode(legacyCatalog(activity: #"{"id":"read-1","kind":"reading","required":true,"prompt":"Read this.","choiceSet":null,"explanation":null}"#))
        let activity = try #require(manifest.lessons.first?.activities.first)
        #expect(activity.choiceSet == nil)
        #expect(activity.explanation == nil)
        #expect(activity.childObjectiveIds == nil)
        let resolved = CurriculumAvailability.resolve(manifest: manifest, inspected: [:])
        #expect(resolved.first?.isReady == true)
        #expect(resolved.first?.practiceActivities.map(\.id) == ["read-1"])
    }

    @Test func grammarMetadataRoundTripsWithoutChangingCompletion() throws {
        let activity = CurriculumActivity(
            id: "grammar-be-am", kind: "grammar", required: true,
            prompt: "Fill the gap with one word. I ___ a student.", answer: "am",
            choiceSet: ["am", "is", "are"], explanation: "With I, use am: I am a student.",
            childObjectiveIds: ["EF-03-BE-01"])
        let decoded = try JSONDecoder().decode(CurriculumActivity.self, from: JSONEncoder().encode(activity))
        #expect(decoded == activity)
        let plain = CurriculumActivity(id: "grammar-be-am", kind: "grammar", required: true,
                                       prompt: "Fill the gap with one word. I ___ a student.", answer: "am")
        let withMetadata = manifest(activities: [activity])
        let withoutMetadata = manifest(activities: [plain])
        let readyMeta = try #require(CurriculumAvailability.resolve(manifest: withMetadata, inspected: [:]).first)
        let readyPlain = try #require(CurriculumAvailability.resolve(manifest: withoutMetadata, inspected: [:]).first)
        #expect(readyMeta.isReady && readyPlain.isReady)
        #expect(readyMeta.practiceActivities.map(\.id) == readyPlain.practiceActivities.map(\.id))
        #expect(readyMeta.practiceActivities.map(\.required) == readyPlain.practiceActivities.map(\.required))
    }

    @Test func malformedChoiceMetadataClosesOnlyThatLesson() throws {
        let sibling = #"{"id":"keep-open","contentVersion":"fixture-1","level":"A1","title":"Open","objectiveId":"INTRO-01","activities":[{"id":"read-ok","kind":"reading","required":true,"prompt":"Read this."}]}"#
        let cases = [
            #"{"id":"bad-empty","contentVersion":"fixture-1","level":"A1","title":"Empty","objectiveId":"INTRO-01","activities":[{"id":"gap","kind":"grammar","required":true,"prompt":"I ___ here.","answer":"am","choiceSet":[]}]}"#,
            #"{"id":"bad-blank","contentVersion":"fixture-1","level":"A1","title":"Blank","objectiveId":"INTRO-01","activities":[{"id":"gap","kind":"grammar","required":true,"prompt":"I ___ here.","answer":"am","choiceSet":["am"," "]}]}"#,
            #"{"id":"bad-duplicate","contentVersion":"fixture-1","level":"A1","title":"Duplicate","objectiveId":"INTRO-01","activities":[{"id":"gap","kind":"grammar","required":true,"prompt":"I ___ here.","answer":"am","choiceSet":["am","AM"]}]}"#,
            #"{"id":"bad-answer","contentVersion":"fixture-1","level":"A1","title":"Answer","objectiveId":"INTRO-01","activities":[{"id":"gap","kind":"grammar","required":true,"prompt":"I ___ here.","answer":"am","choiceSet":["is","are"]}]}"#,
            #"{"id":"bad-type","contentVersion":"fixture-1","level":"A1","title":"Type","objectiveId":"INTRO-01","activities":[{"id":"gap","kind":"grammar","required":true,"prompt":"I ___ here.","answer":"am","choiceSet":"am"}]}"#,
            #"{"id":"bad-objective","contentVersion":"fixture-1","level":"A1","title":"Objective","objectiveId":"INTRO-01","activities":[{"id":"gap","kind":"grammar","required":true,"prompt":"I ___ here.","answer":"am","childObjectiveIds":[""]}]}"#,
        ]
        for bad in cases {
            let manifest = try decode(catalogEnvelope(lessons: "\(sibling),\(bad)"))
            let resolved = CurriculumAvailability.resolve(manifest: manifest, inspected: [:])
            #expect(resolved.first { $0.id == "keep-open" }?.isReady == true)
            let closed = try #require(resolved.first { $0.id != "keep-open" })
            #expect(closed.isReady == false)
            if case .unavailable(.malformedMetadata("gap")) = closed.availability {} else {
                Issue.record("Malformed optional metadata must close only the affected lesson")
            }
        }
    }

    @Test func duplicateLessonActivityAndAssetIDsCloseOnlyTheAffectedLesson() throws {
        let open = #"{"id":"keep-open","contentVersion":"fixture-1","level":"A1","title":"Open","objectiveId":"INTRO-01","activities":[{"id":"read-ok","kind":"reading","required":true,"prompt":"Read this."}]}"#
        let duplicatedLesson = #"{"id":"same-lesson","contentVersion":"fixture-1","level":"A1","title":"One","objectiveId":"INTRO-01","activities":[{"id":"read-a","kind":"reading","required":true,"prompt":"Read this."}]},{"id":"same-lesson","contentVersion":"fixture-1","level":"A1","title":"Two","objectiveId":"INTRO-01","activities":[{"id":"read-b","kind":"reading","required":true,"prompt":"Read this too."}]}"#
        let lessonIDs = CurriculumAvailability.resolve(manifest: try decode(catalogEnvelope(lessons: "\(open),\(duplicatedLesson)")), inspected: [:])
        #expect(lessonIDs.first { $0.id == "keep-open" }?.isReady == true)
        #expect(lessonIDs.filter { $0.id == "same-lesson" }.count == 2)
        #expect(lessonIDs.filter { $0.id == "same-lesson" }.allSatisfy { lesson in
            if case .unavailable(.duplicateIdentity("same-lesson")) = lesson.availability { return !lesson.isReady }
            return false
        })

        let duplicatedActivity = #"{"id":"repeat-activity","contentVersion":"fixture-1","level":"A1","title":"Repeat","objectiveId":"INTRO-01","activities":[{"id":"read-1","kind":"reading","required":true,"prompt":"Read this."},{"id":"read-1","kind":"reading","required":true,"prompt":"Read this again."}]}"#
        let activityIDs = CurriculumAvailability.resolve(manifest: try decode(catalogEnvelope(lessons: "\(open),\(duplicatedActivity)")), inspected: [:])
        #expect(activityIDs.first { $0.id == "keep-open" }?.isReady == true)
        let repeated = try #require(activityIDs.first { $0.id == "repeat-activity" })
        if case .unavailable(.duplicateIdentity("read-1")) = repeated.availability {} else {
            Issue.record("A repeated activity id must close that lesson")
        }

        let audio = Data("synthetic-audio".utf8)
        var assets = pack(listeningHash: hash(audio), listeningBytes: audio.count)
        assets.assets.append(assets.assets[0])
        let install = try load(manifest: assets, files: ["model.wav": audio])
        #expect(install.lessons.first { $0.id == "intro-ready" }?.isReady == true)
        let listening = try #require(install.lessons.first { $0.id == "listen-broken" })
        if case .unavailable(.duplicateIdentity("audio-1")) = listening.availability {} else {
            Issue.record("A repeated asset id must not trap or close an unrelated lesson")
        }
    }

    private func pack(listeningHash: String, listeningBytes: Int) -> CurriculumManifest {
        CurriculumManifest(
            schemaVersion: 1,
            packId: "fixture.catalog",
            contentVersion: "fixture-1",
            locale: "en-US",
            minimumSchemaVersion: 1,
            editorialApprovalReference: "fixture-review-not-publication",
            rightsReference: "fixture-rights",
            assets: [CurriculumAsset(id: "audio-1", relativePath: "model.wav", byteCount: listeningBytes, sha256: listeningHash, mediaType: "audio/wav")],
            lessons: [
                CurriculumLesson(id: "intro-ready", contentVersion: "fixture-1", level: "A1", title: "Fixture reading", objectiveId: "INTRO-01", activities: [
                    CurriculumActivity(id: "read-1", kind: "reading", required: true, prompt: "Read this fixture sentence."),
                    CurriculumActivity(id: "quiet-1", kind: "quietText", required: true, prompt: "Write three facts. This is text evidence."),
                    CurriculumActivity(id: "transfer-1", kind: "recall", required: false, prompt: "Reserved fixture prompt.", withheldFromPractice: true)
                ]),
                CurriculumLesson(id: "listen-broken", contentVersion: "fixture-1", level: "A1", title: "Fixture listening", objectiveId: "INTRO-01", activities: [
                    CurriculumActivity(id: "listen-1", kind: "listening", required: true, prompt: nil, assetId: "audio-1")
                ])
            ]
        )
    }

    private func load(manifest: CurriculumManifest, files: [String: Data]) throws -> CurriculumInstall {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("SC-T019-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let encoded = try JSONEncoder().encode(manifest)
        try encoded.write(to: root.appendingPathComponent("CurriculumCatalog.json"))
        for (name, data) in files {
            try data.write(to: root.appendingPathComponent(name))
        }
        defer { try? FileManager.default.removeItem(at: root) }
        return CurriculumCatalogLoader().load(directory: root)
    }

    private func hash(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    private func manifest(activities: [CurriculumActivity]) -> CurriculumManifest {
        CurriculumManifest(
            schemaVersion: 1, packId: "fixture.catalog", contentVersion: "fixture-1", locale: "en-US",
            minimumSchemaVersion: 1, editorialApprovalReference: "fixture-review-not-publication", rightsReference: "fixture-rights",
            assets: [], lessons: [
                CurriculumLesson(id: "intro-ready", contentVersion: "fixture-1", level: "A1", title: "Fixture", objectiveId: "INTRO-01", activities: activities)
            ])
    }

    private func catalogEnvelope(lessons: String) -> String {
        """
        {"schemaVersion":1,"packId":"fixture.catalog","contentVersion":"fixture-1","locale":"en-US","minimumSchemaVersion":1,"editorialApprovalReference":"fixture-review-not-publication","rightsReference":"fixture-rights","assets":[],"lessons":[\(lessons)]}
        """
    }

    private func legacyCatalog(activity: String) -> String {
        catalogEnvelope(lessons: #"{"id":"intro-ready","contentVersion":"fixture-1","level":"A1","title":"Fixture","objectiveId":"INTRO-01","activities":[\#(activity)]}"#)
    }

    private func decode(_ json: String) throws -> CurriculumManifest {
        try JSONDecoder().decode(CurriculumManifest.self, from: Data(json.utf8))
    }
}


struct A1CurriculumDeliveryTests {
    private func install() -> CurriculumInstall { CurriculumCatalogLoader().loadBundled() }

    @Test func previewsKeepAllLevelsAndExactOldVersionsAvailable() throws {
        let catalog = install()
        #expect(catalog.lessons.count == 57)
        #expect(catalog.archivedLessons.count == 26)
        for current in catalog.lessons(at: "A1") where current.id != "intro-01" {
            #expect(current.contentVersion == "4")
            let v3 = try #require(catalog.lesson(id: current.id, version: "3"))
            #expect(v3.isReady && v3.tip == nil && v3.practiceActivities.allSatisfy { $0.exercise == nil })
            #expect(v3.senses == current.senses)
            let old = try #require(catalog.lesson(id: current.id, version: "2"))
            #expect(old.isReady && old.supplement == nil)
            #expect(current.senses == old.senses)
            #expect(current.supplement?.concepts.count == 5)
            #expect(current.supplement?.reviewNotice.contains("pending") == true)
            #expect(current.reservedActivities.count == 4)
            #expect(current.sessionActivities.allSatisfy { $0.withheldFromPractice != true })
        }
        #expect(catalog.lesson(id: "intro-01", version: "2")?.sessionActivities.count == 14)
        #expect(catalog.lesson(id: "intro-01", version: "3")?.sessionActivities.count == 18)
        #expect(catalog.lesson(id: "a1-home", version: "unknown") == nil)
    }

    @Test func a1Version4TypedExercisesAreCompleteAndSelfConsistent() throws {
        let catalog = install()
        for lesson in catalog.lessons(at: "A1") where lesson.id != "intro-01" {
            #expect(lesson.hasCheckedExercises && lesson.tip?.isEmpty == false)
            let typed = lesson.practiceActivities.filter { $0.exercise != nil }
            #expect(typed.count == 12, "\(lesson.id) typed activities")
            #expect(typed.map(\.kind).filter { $0 == "recall" }.count == 5)
            for activity in typed {
                let spec = activity.resolvedExercise
                #expect(spec.problem(hasClip: activity.assetId != nil) == nil, "\(activity.id)")
                // The first accepted answer must be buildable and must check as correct.
                let answer = try #require(spec.modelAnswer)
                switch spec.kind {
                case .choice, .fillBlank: #expect(spec.evaluate(.text(answer)) == .correct, "\(activity.id)")
                case .wordBank: #expect(spec.evaluate(.sequence(answer.split(separator: " ").map(String.init))) == .correct, "\(activity.id)")
                default: Issue.record("unexpected type in \(activity.id)")
                }
                // Something else must be wrong, so the question is not trivially satisfied.
                if spec.kind == .choice { #expect((spec.options ?? []).count >= 3, "\(activity.id)") }
            }
            // The stored form re-checks to the same result: this is how accuracy survives a restart.
            let first = try #require(typed.first)
            #expect(first.resolvedExercise.result(forStored: first.resolvedExercise.modelAnswer ?? "") == .correct)
        }
    }

    @Test func accuracyIsRecomputedFromSavedFirstAnswers() throws {
        let catalog = install()
        let lesson = try #require(catalog.lessons.first { $0.id == "a1-weather" })
        var session = try LessonSession.begin(lesson: lesson, presenter: "synthetic", now: .now)
        let read = try #require(lesson.practiceActivities.first { $0.kind == "reading" })
        let listen = try #require(lesson.practiceActivities.first { $0.kind == "listening" })
        try session.record(activityID: read.id, text: read.resolvedExercise.modelAnswer ?? "", assisted: false)
        try session.record(activityID: listen.id, text: "Not the answer", assisted: false)
        #expect(session.exerciseAccuracy == 0.5)
        #expect(session.missedExercises.map(\.id) == [listen.id])
        // A second, better answer does not change the first-try record.
        try session.record(activityID: listen.id, text: listen.resolvedExercise.modelAnswer ?? "", assisted: false)
        #expect(session.exerciseAccuracy == 0.5)
    }

    @Test func oldDraftAndFirstResponseResumeAgainstExactTasks() throws {
        let catalog = install()
        let old = try #require(catalog.lesson(id: "a1-home", version: "2"))
        let current = try #require(catalog.lessons.first { $0.id == old.id })
        var previous = try LessonSession.begin(lesson: old, presenter: "synthetic", now: .now)
        let task = try #require(previous.activities.first)
        try previous.record(activityID: task.id, text: "synthetic first answer", assisted: false)
        try previous.saveDraft("synthetic unfinished revision", for: task.id)
        let restored = try JSONDecoder().decode(LessonJourney.self, from: JSONEncoder().encode(previous.journey))
        let chosen = try catalog.opening(current, saved: [restored])
        let resumed = try LessonSession.begin(lesson: chosen.lesson, presenter: "synthetic", now: .now, existing: chosen.journey)
        #expect(resumed.journey.id == previous.journey.id)
        #expect(resumed.journey.contentVersion == "2")
        #expect(resumed.response(for: task.id)?.unaidedText == "synthetic first answer")
        #expect(resumed.journey.drafts?[task.id] == "synthetic unfinished revision")
        #expect(resumed.activities == old.sessionActivities)
        #expect(resumed.activities != current.sessionActivities)
    }

    @Test func completedOldWorkDoesNotCompleteOrRegradeCurrentVersion() throws {
        let catalog = install()
        let old = try #require(catalog.lesson(id: "family-01", version: "2"))
        let current = try #require(catalog.lessons.first { $0.id == old.id })
        var session = try LessonSession.begin(lesson: old, presenter: "synthetic", now: .now)
        for activity in session.activities where activity.required { try session.record(activityID: activity.id, text: "synthetic attempt", assisted: false) }
        try session.finish(now: .now)
        let opening = try catalog.opening(current, saved: [session.journey])
        #expect(opening.journey == nil)
        #expect(opening.lesson.contentVersion == "4")
        #expect(session.journey.contentVersion == "2" && session.journey.completedAt != nil)
    }

    @Test func missingArchivePreservesOldWorkWithoutFallingForward() throws {
        var catalog = install()
        let old = try #require(catalog.lesson(id: "a1-home", version: "2"))
        let current = try #require(catalog.lessons.first { $0.id == old.id })
        let started = try LessonSession.begin(lesson: old, presenter: "synthetic", now: .now).journey
        catalog.archivedLessons = []
        #expect(throws: LessonProgressError.versionMismatch) { try catalog.opening(current, saved: [started]) }
        #expect(started.responses.isEmpty && started.completedAt == nil)
    }

    @Test func ambiguousArchiveIsNotChosen() throws {
        var catalog = install()
        let old = try #require(catalog.lesson(id: "a1-home", version: "2"))
        let current = try #require(catalog.lessons.first { $0.id == old.id })
        catalog.archivedLessons.append(old)
        #expect(catalog.lesson(id: old.id, version: "2") == nil)
        let saved = try LessonSession.begin(lesson: old, presenter: "synthetic", now: .now).journey
        #expect(throws: LessonProgressError.versionMismatch) { try catalog.opening(current, saved: [saved]) }
    }

    @Test func optionalRoutesStaySeparateAndFreezeActualConditions() throws {
        let source = try #require(install().lessons.first { $0.id == "a1-weather" })
        for kind in CurriculumPracticeKind.allCases {
            let optional = try #require(kind.lesson(from: source))
            #expect(optional.id != source.id && optional.objectiveId != source.objectiveId)
            #expect(optional.senses == source.senses)
            #expect(optional.supplement == nil)
            #expect(optional.contentVersion == source.contentVersion)
        }
        let baseline = try #require(CurriculumPracticeKind.baseline.lesson(from: source))
        let delayed = try #require(CurriculumPracticeKind.day7.lesson(from: source))
        #expect(baseline.practiceActivities.first?.prompt != delayed.practiceActivities.first?.prompt)
    }

    @Test func decliningTextRetentionStoresOnlyParticipationAndConditions() throws {
        let source = try #require(install().lessons.first { $0.id == "a1-weather" })
        let optional = try #require(CurriculumPracticeKind.day7.lesson(from: source))
        var session = try LessonSession.begin(lesson: optional, presenter: "synthetic", now: .now)
        session.journey.practiceConditions = CurriculumPracticeConditions(purpose: "day7", sourceContentVersion: "3",
            startedAt: .now, teachingBeganAt: nil, supported: true, retainedText: false)
        for task in session.activities {
            try session.saveDraft("synthetic-private-sentinel", for: task.id)
            try session.record(activityID: task.id, text: "synthetic-private-sentinel", assisted: false)
            #expect(session.hasAttempt(for: task.id))
            #expect(session.response(for: task.id)?.attemptWasSupported == true)
            _ = try session.revealAnswer(activityID: task.id)
        }
        try session.finish(now: .now)
        let encoded = try JSONEncoder().encode(session.journey)
        #expect(String(decoding: encoded, as: UTF8.self).contains("synthetic-private-sentinel") == false)
        #expect(session.journey.responses.allSatisfy { $0.modality == "text" && $0.unaidedText == nil && $0.recordedPracticeID == nil })
        #expect(session.journey.completedAt != nil)
        #expect(session.journey.practiceConditions?.timingDescription.contains("unavailable") == true)
    }

    @Test func explicitTextRetentionKeepsFirstResponseAndRetryDistinct() throws {
        let source = try #require(install().lessons.first { $0.id == "a1-weather" })
        let optional = try #require(CurriculumPracticeKind.concepts.lesson(from: source))
        var session = try LessonSession.begin(lesson: optional, presenter: "synthetic", now: .now)
        session.journey.practiceConditions = CurriculumPracticeConditions(purpose: "concepts", sourceContentVersion: "3",
            startedAt: .now, teachingBeganAt: .now, supported: false, retainedText: true)
        let task = try #require(session.activities.first)
        try session.record(activityID: task.id, text: "first", assisted: false)
        _ = try session.revealAnswer(activityID: task.id)
        try session.record(activityID: task.id, text: "retry", assisted: true)
        #expect(session.response(for: task.id)?.unaidedText == "first")
        #expect(session.response(for: task.id)?.assistedText == "retry")
    }

    @Test func optionalPracticeResumesItsArchivedSourceAfterAnotherUpdate() throws {
        var catalog = install()
        let source = try #require(catalog.lessons.first { $0.id == "a1-home" })
        let oldPractice = try #require(CurriculumPracticeKind.day7.lesson(from: source))
        let saved = try LessonSession.begin(lesson: oldPractice, presenter: "synthetic", now: .now).journey
        catalog.archivedLessons.append(source)
        let index = try #require(catalog.lessons.firstIndex { $0.id == source.id })
        catalog.lessons[index].contentVersion = "5"
        let nextPractice = try #require(CurriculumPracticeKind.day7.lesson(from: catalog.lessons[index]))
        let chosen = try catalog.opening(nextPractice, saved: [saved])
        #expect(chosen.lesson.contentVersion == "4")
        #expect(chosen.journey?.id == saved.id)
    }

    @Test func v2JourneySurvivesRepositoryCloseAndReopen() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("A1-version-test-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let catalog = install()
        let old = try #require(catalog.lesson(id: "a1-home", version: "2"))
        let current = try #require(catalog.lessons.first { $0.id == old.id })
        var session = try LessonSession.begin(lesson: old, presenter: "synthetic", now: .now)
        let task = try #require(session.activities.first)
        try session.saveDraft("synthetic old-version draft", for: task.id)
        var repository = try LearnerRepository(root: root, protectedDataAvailable: { true })
        try repository.saveLessonJourney(session.journey)
        repository.close()
        repository = try LearnerRepository(root: root, protectedDataAvailable: { true })
        let saved = try repository.lessonJourneys(lessonID: old.id)
        let chosen = try catalog.opening(current, saved: saved)
        #expect(chosen.journey?.drafts?[task.id] == "synthetic old-version draft")
        #expect(chosen.lesson.contentVersion == "2")
        #expect(PracticeRecommendation.selectLesson(journeys: saved, lessons: catalog.lessons, archivedLessons: catalog.archivedLessons).resuming)
        repository.close()
    }

    @Test func speakingFreezesExactTopicPromptAndOptionalOrigin() throws {
        let source = try #require(install().lessons.first { $0.id == "a1-weather" })
        let course = try LessonSession.begin(lesson: source, presenter: "synthetic", now: .now).journey
        let practice = try #require(CurriculumPracticeKind.day7.lesson(from: source))
        var session = try LessonSession.begin(lesson: practice, presenter: "synthetic", now: .now)
        session.journey.practiceOrigin = LessonPracticeOrigin(journeyID: course.id, lessonID: source.id, objectiveID: source.objectiveId)
        let context = try LessonSpeakingLink.context(lesson: practice, journey: session.journey, defaults: LearnerPreferences())
        #expect(context.promptOverride?.text == practice.practiceActivities.first?.prompt)
        #expect(context.provenance?.sourceCourseJourneyID == course.id)
        #expect(context.provenance?.purpose == "topicPractice")
        #expect(context.provenance?.primaryObjectiveID == source.objectiveId)
        #expect(context.provenance?.packVersion == source.contentVersion)
        #expect(context.sourceLessonJourneyID == session.journey.id)
    }

    @Test func declaredSupportCannotBecomeAnUnaidedRetainedResponse() throws {
        let source = try #require(install().lessons.first { $0.id == "a1-weather" })
        let practice = try #require(CurriculumPracticeKind.concepts.lesson(from: source))
        var session = try LessonSession.begin(lesson: practice, presenter: "synthetic", now: .now)
        session.journey.practiceConditions = CurriculumPracticeConditions(purpose: "concepts", sourceContentVersion: "3",
            startedAt: .now, teachingBeganAt: nil, supported: true, retainedText: true)
        let task = try #require(session.activities.first)
        try session.record(activityID: task.id, text: "synthetic supported response", assisted: false)
        #expect(session.response(for: task.id)?.unaidedText == nil)
        #expect(session.response(for: task.id)?.assistedText == "synthetic supported response")
        #expect(session.response(for: task.id)?.firstResponseText == "synthetic supported response")
    }
}
