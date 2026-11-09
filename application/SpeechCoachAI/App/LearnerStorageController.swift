import Foundation
import Observation

struct LessonSpeechCompletion: Equatable {
    var lessonID: String
    var journeyID: UUID
    var attemptID: UUID
    var activityID: String? = nil
}

struct IndependentPracticeRecording: Equatable {
    var sessionID: UUID
    var slotID: UUID
    var attemptID: UUID
}

@Observable
final class LearnerStorageController {
    private(set) var repository: LearnerRepository?
    private(set) var hasStorageFailure = false
    private(set) var preferences = LearnerPreferences()
    private(set) var hasPreferenceSaveFailure = false
    /// Ephemeral handoff only; recording retention remains independent of lesson completion.
    var latestLessonSpeech: LessonSpeechCompletion?
    var latestCheckSpeech: LessonSpeechCompletion?
    var latestPracticeRecording: IndependentPracticeRecording?
    /// Resource edits survive view/sidebar changes while the app is open, until Save or Discard.
    var resourceDraft: ResourceEditorDraft?
    let rewardEngagement = RewardEngagementState()
    /// Saves each stretch of screen time of a minute or more (Progress analytics).
    @ObservationIgnored lazy var usage = UsageRecorder { [weak self] start, end in
        guard let repository = self?.repository else { throw LearnerStorageError.unavailable }
        try repository.recordUsage(start: start, end: end)
    }

    /// Saves each stretch of practice time of a minute or more (lesson, Lexicon, Lab).
    @ObservationIgnored lazy var practice = PracticeRecorder { [weak self] stretch in
        guard let repository = self?.repository else { throw LearnerStorageError.unavailable }
        try repository.recordPractice(stretch)
    }

    /// Folder for the store and private files. Nil means Application Support (the app's own data).
    @ObservationIgnored private var customRoot: URL? = nil

    init() {}
    /// Tests use an isolated folder.
    init(root: URL) { customRoot = root }

    /// The folder that holds every saved learner file: the SwiftData store, recordings and other private files.
    func storeRoot() throws -> URL {
        if let customRoot { return customRoot }
        let support = try FileManager.default.url(for: .applicationSupportDirectory,
            in: .userDomainMask, appropriateFor: nil, create: true)
        let folder = SpeakingEnvironment.fixtureID.map { "SpeakingUITest-" + $0.uuidString } ?? "Learner"
        return support.appendingPathComponent(folder, isDirectory: true)
    }

    /// Erases every saved learner file and starts again as a first launch. Call through `LearnerReset.erase`,
    /// which asks the device owner first. Throws when the folder could not be removed; storage is reopened either way.
    func eraseAllLearnerFiles() throws {
        let root = try storeRoot()
        close()
        latestLessonSpeech = nil; latestCheckSpeech = nil; latestPracticeRecording = nil
        resourceDraft = nil
        defer { open() }
        if FileManager.default.fileExists(atPath: root.path) { try FileManager.default.removeItem(at: root) }
    }

    func beginResourceDraft(resource: LearningResource? = nil, curated: CuratedLearningResource? = nil) throws {
        guard let repository else { throw LearnerStorageError.unavailable }
        let epoch = try repository.learningDataEpoch()
        if resourceDraft?.epoch == epoch { return }
        resourceDraft = ResourceEditorDraft(epoch: epoch, resource: resource, curated: curated)
    }

    func validateResourceDraftEpoch() throws {
        guard let repository else { throw LearnerStorageError.unavailable }
        if let draft = resourceDraft, try repository.learningDataEpoch() != draft.epoch {
            resourceDraft = nil
            throw LearnerStorageError.staleVersion
        }
    }

    @discardableResult
    func saveResourceDraft() -> Bool {
        do {
            try validateResourceDraftEpoch()
            guard let repository, let draft = resourceDraft else { throw LearnerStorageError.unavailable }
            _ = try repository.saveLearningResource(draft)
            resourceDraft = nil
            return true
        } catch LearnerStorageError.staleVersion {
            resourceDraft = nil
        } catch let error as ResourceLinkError {
            resourceDraft?.message = error.message
        } catch {
            resourceDraft?.message = "Your bookmark could not be saved. Your edits are kept here while the app is open. Try again after unlocking your device."
        }
        return false
    }

    init(repository: LearnerRepository? = nil) { self.repository = repository }

    /// Bumped when a jump test is passed, so views reading `levelGate(install:)` refresh.
    private(set) var jumpTestRevision = 0

    /// Which CEFR levels are open now. With no readable storage only A1 is open.
    func levelGate(install: CurriculumInstall) -> LevelGate {
        _ = jumpTestRevision
        let journeys = (try? repository?.allLessonJourneys()) ?? []
        let passed = (try? repository?.passedJumpTests()) ?? []
        return LevelGate(install: install, journeys: journeys, passedTests: passed)
    }

    /// Saves a perfect jump test. Returns false when it could not be saved.
    @discardableResult
    func recordJumpTestPass(level: String) -> Bool {
        guard let repository else { return false }
        do { try repository.recordJumpTestPass(level: level) } catch { return false }
        jumpTestRevision += 1
        return true
    }

    func open() {
        do {
            if let repository { try repository.maintain() }
            else {
                repository = try LearnerRepository(root: try storeRoot())
                if let repository { try SpeakingEnvironment.seedIfNeeded(repository) }
            }
            preferences = try repository?.preferences() ?? LearnerPreferences()
            KitTheme.current = KitTheme(preferences.background)
            SpeechSynthesizer.shared.settings = preferences.voiceSettings ?? VoiceSettings()
            hasStorageFailure = false
        } catch {
            close()
            // Do not display/log an SDK error that might contain private paths or payloads.
            hasStorageFailure = true
        }
    }

    func savePreferences(_ value: LearnerPreferences) {
        do {
            guard let repository else { throw LearnerStorageError.unavailable }
            try repository.savePreferences(value)
            KitTheme.current = KitTheme(value.background)
            SpeechSynthesizer.shared.settings = value.voiceSettings ?? VoiceSettings()
            preferences = value
            hasPreferenceSaveFailure = false
        } catch {
            hasPreferenceSaveFailure = true
        }
    }

    func close() {
        repository?.close(); repository = nil
    }
}
