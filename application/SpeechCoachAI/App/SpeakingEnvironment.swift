import Foundation

/// Release builds cannot enter fixture mode. Debug UI tests use their own UUID-named store.
enum SpeakingEnvironment {
    static var fixtureID: UUID? {
        #if DEBUG
        return ProcessInfo.processInfo.environment["SC_SPEAKING_FIXTURE"].flatMap(UUID.init(uuidString:))
        #else
        return nil
        #endif
    }
    static var provider: any SpeakingProvider {
        #if DEBUG
        if fixtureID != nil { return FixtureSpeakingProvider() }
        #endif
        return SpeakingProviderClient()
    }
    static var fixtureScope: ProviderScope? {
        #if DEBUG
        if fixtureID != nil { return try? ProviderScope(workspace: "synthetic-ui-test") }
        #endif
        return nil
    }
    static func seedIfNeeded(_ repository: LearnerRepository) throws {
        #if DEBUG
        if fixtureID != nil, ProcessInfo.processInfo.environment["SC_REWARD_DARK_FIXTURE"] == "1" {
            var settings = try repository.preferences(); settings.appearance = .dark
            try repository.savePreferences(settings)
        }
        if fixtureID != nil, ProcessInfo.processInfo.environment["SC_USAGE_FIXTURE"] == "1", try repository.usageLog().sessions.isEmpty {
            // Three synthetic days of screen time: today 30 minutes (ending a few minutes ago), yesterday 20, three days ago 45.
            let end = Date.now.addingTimeInterval(-300)
            for (daysAgo, minutes) in [(0, 30), (1, 20), (3, 45)] {
                let finish = end.addingTimeInterval(-Double(daysAgo) * 86_400)
                try repository.recordUsage(start: finish.addingTimeInterval(-Double(minutes) * 60), end: finish)
            }
        }
        if fixtureID != nil, ProcessInfo.processInfo.environment["SC_PRACTICE_FIXTURE"] == "1", try repository.practiceLog().stretches.isEmpty {
            // Synthetic practice today: Lesson 12 min, Lexicon 5 min, Lab 3 min; yesterday Lesson 8 min.
            let start = Calendar.current.startOfDay(for: .now).addingTimeInterval(3_600)
            for (offset, minutes, area) in [(0.0, 12, PracticeArea.lesson), (0.1, 5, .lexicon), (0.2, 3, .lab), (-24.0, 8, .lesson)] {
                try repository.recordPractice(PracticeStretch(start: start.addingTimeInterval(offset * 3_600), seconds: minutes * 60, area: area))
            }
        }
        if fixtureID != nil, ProcessInfo.processInfo.environment["SC_REWARD_FIXTURE"] == "1",
           try repository.allLessonJourneys().isEmpty,
           let lesson = CurriculumCatalogLoader.bundled.lesson(id: "intro-01", version: "4") {
            var session = try LessonSession.begin(lesson: lesson, presenter: "synthetic", now: .now)
            for activity in session.activities {
                try session.record(activityID: activity.id, text: "Synthetic reward fixture practice", assisted: false)
                if session.needsComparison(activity.id) { _ = try session.revealAnswer(activityID: activity.id) }
            }
            try session.finish(now: .now)
            try repository.saveLessonJourney(session.journey)
        }
        if fixtureID != nil, ProcessInfo.processInfo.environment["SC_A1_V2_FIXTURE"] == "1",
           try repository.allLessonJourneys().isEmpty,
           let old = CurriculumCatalogLoader.bundled.lesson(id: "a1-home", version: "2") {
            var session = try LessonSession.begin(lesson: old, presenter: "synthetic", now: .now)
            if let first = session.activities.first {
                try session.saveDraft("Synthetic v2 home draft", for: first.id)
                try repository.saveLessonJourney(session.journey)
            }
        }
        guard fixtureID != nil, try repository.recoverableAttempts().isEmpty,
              try repository.completedPracticeCount() == 0, try repository.history().isEmpty,
              try repository.history(recentlyDeleted: true).isEmpty else { return }
        var wav = Data("RIFF".utf8)
        func word(_ value: UInt16) { var v = value.littleEndian; withUnsafeBytes(of: &v) { wav.append(contentsOf: $0) } }
        func dword(_ value: UInt32) { var v = value.littleEndian; withUnsafeBytes(of: &v) { wav.append(contentsOf: $0) } }
        dword(32_036); wav.append(Data("WAVEfmt ".utf8)); dword(16); word(1); word(1)
        dword(16_000); dword(32_000); word(2); word(16); wav.append(Data("data".utf8)); dword(32_000)
        wav.append(Data(repeating: 0, count: 32_000))
        let attempt = try repository.createAttempt(prompt: RecordingController.prompt)
        let recorded = try repository.finalizeRecording(attemptID: attempt.id, data: wav,
            durationMilliseconds: 1000, sampleRate: 16_000, channels: 1, bitsPerSample: 16, expectedVersion: attempt.version)
        try repository.markInterrupted(recorded.id, expectedVersion: recorded.version)
        #endif
    }
}

#if DEBUG
private final class FixtureSpeakingProvider: SpeakingProvider {
    var verification: ProviderVerification? {
        ProviderVerification(workspace: "synthetic-ui-test", asrModel: "qwen3-asr-flash", coachingModel: "qwen-flash",
            validUntil: .now.addingTimeInterval(3600), directNativePermissionVerified: true, quotaProtectionVerified: true,
            retentionDisclosure: "TEST FIXTURE: no remote processing or charges. All responses are synthetic.", evidenceReference: "isolated-ui-fixture")
    }
    func send(body: Data, scope: ProviderScope, stage: SpeakingRequestStage) async throws -> Data {
        guard scope.workspace == "synthetic-ui-test" else { throw SpeakingProviderError.verificationRequired }
        try Task.checkCancellation()
        let content: String
        let model: String
        if stage == .transcription {
            content = "I lives in Manila. I am a developer."; model = "qwen3-asr-flash"
        } else {
            model = "qwen-flash"
            let object: [String: Any] = ["summary": "Fixture feedback: your introduction shares a location and occupation.",
                "strengths": [], "improvements": [], "limitations": ["Synthetic test result, not actual AI coaching."],
                "speechAssessmentStatus": "not_assessed"]
            content = String(decoding: try JSONSerialization.data(withJSONObject: object), as: UTF8.self)
        }
        return try JSONSerialization.data(withJSONObject: ["model": model,
            "choices": [["index": 0, "finish_reason": "stop", "message": ["role": "assistant", "content": content]]]])
    }
}
#endif
