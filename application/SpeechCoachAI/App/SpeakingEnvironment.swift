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
        if ProcessInfo.processInfo.environment["SC_GENERATED_FIXTURE"] == "1" {
            try GeneratedPracticeUIFixture.seed(repository)
        }
        #endif
    }
}

#if DEBUG
/// Synthetic source/policy only for the UUID-isolated UI fixture; never a production grant.
enum GeneratedPracticeUIFixture {
    static var policy: GenerationPolicy {
        GenerationPolicy(schemaVersion: 1, decisionRecord: "synthetic-ui-generation-policy", ownerDecisionAccepted: true,
            permittedObjectiveIDs: ["synthetic-objective"], permittedTemplateIDs: ["synthetic-template"],
            permittedActivityKinds: [.recognitionChoice], contextScalarLimit: 1000, maximumActivitiesPerRequest: 1,
            maximumValidatedCacheEntries: 2, cacheFreshnessSeconds: 3600, maximumResponseBytes: 4096,
            regenerationPermitted: false, costCeilingRecord: "synthetic-no-billing", factualSource: .noFactualClaims,
            reportRetention: ReportRetentionRule(retainForSeconds: 3600, exportPermitted: false, exportEvidenceReference: "", localOnly: true),
            providerAccess: ProviderAccessRule(liveTransportPermitted: true, quotaProtectionVerified: true, evidenceReference: "synthetic-no-network"))
    }

    static func seed(_ repository: LearnerRepository) throws {
        let epoch = try repository.learningDataEpoch()
        let source = PracticeSource(objectiveID: "synthetic-objective", contentVersion: "synthetic-1", level: "A1",
            templateID: "synthetic-template", rubricVersion: "synthetic-rubric", grammarTargetIDs: [], vocabularySenseIDs: [],
            senseID: nil, cardID: nil, variety: "en-US")
        let attempt = CurrentAttempt(id: UUID(), prompt: "Synthetic current practice.", objectiveID: source.objectiveID,
            senseID: nil, cardID: nil, contentVersion: source.contentVersion, rubricVersion: source.rubricVersion,
            schedule: ScheduleIdentity(cardID: nil, dueAt: nil, inReview: false))
        var session = GeneratedPracticeSession(); session.bindEpoch(epoch)
        _ = session.prepare(attempt: attempt, source: source)
        session.familiarity = .fresh; session.requestedKind = .recognitionChoice
        _ = session.beginFresh(policy: policy, connected: true, now: .now)
        let payload: [String: Any] = [
            "schemaVersion": 1, "objectiveID": source.objectiveID, "contentVersion": source.contentVersion,
            "level": source.level, "templateID": source.templateID, "rubricVersion": source.rubricVersion,
            "activityKind": "recognitionChoice", "variety": "en-US", "prompt": "Synthetic generated practice.",
            "explanation": "Synthetic explanation.", "choices": ["Synthetic answer", "Synthetic alternative"],
            "correctChoiceIndex": 0, "recallAnswer": NSNull(), "candidateHeadword": NSNull(), "candidateMeaning": NSNull(),
            "grammarTargetIDs": [String](), "vocabularySenseIDs": [String](), "cardID": NSNull(),
            "editorialLabel": "generated", "factualSourceIDs": [String](), "referenceAudioID": NSNull(), "mediaURL": NSNull()
        ]
        guard let request = session.requestID else { throw LearnerStorageError.invalidState }
        let data = try JSONSerialization.data(withJSONObject: payload)
        guard session.receive(data: data, policy: policy, requestID: request, now: .now) == nil,
              session.applyRetention(.optedIn, policy: policy, now: .now) == nil,
              session.commit(expectedEpoch: epoch, writeSucceeds: true) == nil else { throw LearnerStorageError.invalidState }
        try repository.saveGeneratedPracticeRecord(session.committed, expectedEpoch: epoch, replacing: nil)
    }
}

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
