import Foundation

@main
struct A1CandidateRuntimeChecks {
    static func check(_ value: Bool, _ message: String) throws {
        if !value { throw NSError(domain: "SC-D007", code: 1, userInfo: [NSLocalizedDescriptionKey: message]) }
    }

    static func main() throws {
        let source = URL(fileURLWithPath: CommandLine.arguments[1])
        let live = URL(fileURLWithPath: CommandLine.arguments[2])
        let loader = CurriculumCatalogLoader()
        let unopened = loader.load(directory: source)
        try check(unopened.problem == nil && unopened.lessons.count == 13, "Decode the candidate using the production loader")
        try check(unopened.lessons.allSatisfy { $0.availability == .unavailable(.missingReview) }, "Unapproved candidate must stay unavailable")
        let liveInstall = loader.load(directory: live)
        let temporary = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.copyItem(at: source, to: temporary)
        defer { try? FileManager.default.removeItem(at: temporary) }
        let file = temporary.appendingPathComponent("CurriculumCatalog.json")
        var manifest = try JSONDecoder().decode(CurriculumManifest.self, from: Data(contentsOf: file))
        // Local synthetic transport fixture only. This value is never written into the candidate or live pack.
        manifest.editorialApprovalReference = "synthetic-runtime-test-only; no editorial approval"
        try JSONEncoder().encode(manifest).write(to: file)
        let ready = loader.load(directory: temporary)
        try check(ready.lessons.count == 13 && ready.lessons.allSatisfy(\.isReady), "All candidate activity shapes/assets must resolve")
        var journeys = 0
        for lesson in ready.lessons {
            try check(lesson.practiceActivities.allSatisfy { $0.withheldFromPractice != true }, "Reserved tasks must remain hidden")
            let guided = try unwrap(lesson.practiceActivities.first { $0.kind == "guidedSpeaking" })
            let quiet = try unwrap(lesson.practiceActivities.first { $0.kind == "quietText" })
            try check(quiet.alternativeToActivityID == guided.id, "Quiet text must replace its exact speaking task")
            try check(!lesson.sessionActivities.contains { $0.id == quiet.id }, "Normal session must not require both modes")
            var session = try LessonSession.begin(lesson: lesson, presenter: "synthetic", now: Date())
            let first = try unwrap(session.activities.first)
            try session.saveDraft("synthetic unfinished answer", for: first.id)
            let persisted = try JSONEncoder().encode(session.journey)
            let restored = try JSONDecoder().decode(LessonJourney.self, from: persisted)
            let resumed = try LessonSession.begin(lesson: lesson, presenter: "synthetic", now: Date(), existing: restored)
            try check(resumed.journey.drafts?[first.id] == "synthetic unfinished answer", "Draft must survive Codable/resume")
            // Intentionally wrong text is participation. No answer correctness gate is allowed.
            for activity in session.activities where activity.required {
                try session.record(activityID: activity.id, text: "synthetic wrong response", assisted: false)
                if activity.kind == "grammar" { _ = try session.revealAnswer(activityID: activity.id) }
            }
            try session.finish(now: Date())
            try check(session.journey.completedAt != nil, "Participation completion must not grade correctness")
            try check(session.journey.responses.filter { $0.kind == "guidedSpeaking" }.allSatisfy { $0.modality == "text" }, "Typed speaking prompt remains text evidence")
            if lesson.id != "intro-01" {
                let old = try unwrap(liveInstall.lesson(id: lesson.id, version: "2"))
                let oldJourney = try LessonSession.begin(lesson: old, presenter: "synthetic", now: Date()).journey
                do {
                    _ = try LessonSession.begin(lesson: lesson, presenter: "synthetic", now: Date(), existing: oldJourney)
                    try check(false, "Old version must never silently resume against changed tasks")
                } catch LessonProgressError.versionMismatch { }
                let stillOld = try LessonSession.begin(lesson: old, presenter: "synthetic", now: Date(), existing: oldJourney)
                try check(stillOld.journey.contentVersion == "2", "Original old-version session remains valid")
            }
            journeys += 1
        }
        // Real loader rejects missing/corrupt bundled files, while unrelated lessons stay usable.
        let damaged = manifest.assets[0]
        let affectedIDs = Set(manifest.lessons.filter { lesson in
            lesson.activities.contains { $0.required && $0.assetId == damaged.id }
        }.map(\.id))
        try Data("corrupt synthetic audio".utf8).write(to: temporary.appendingPathComponent(damaged.relativePath))
        let corrupt = loader.load(directory: temporary)
        try check(corrupt.lessons.filter { affectedIDs.contains($0.id) }.allSatisfy { !$0.isReady }, "Corrupt audio must close affected lessons")
        try check(corrupt.lessons.filter { !affectedIDs.contains($0.id) }.allSatisfy(\.isReady), "Corruption must not close other lessons")
        try FileManager.default.removeItem(at: temporary.appendingPathComponent(damaged.relativePath))
        let missing = loader.load(directory: temporary)
        try check(missing.lessons.filter { affectedIDs.contains($0.id) }.allSatisfy { !$0.isReady }, "Missing audio must close affected lessons")
        print("PASS: production decoder/loader; unapproved pack closed; 13 synthetic offline sessions; reserved-task hiding; quiet substitution; draft round-trip/resume; participation without grading; text modality; 12 old/new version refusals and old-version resumes; corrupt/missing audio isolation.")
        print("Sessions checked: \(journeys). No simulator/device, learner, qualified-review or effectiveness acceptance is implied.")
    }

    static func unwrap<T>(_ value: T?) throws -> T {
        guard let value else { throw NSError(domain: "SC-D007", code: 2) }
        return value
    }
}
