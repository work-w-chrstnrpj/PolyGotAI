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
    private(set) var confidenceDraft: ConfidenceNoteDraft?
    /// Shared across Today view lifetimes, including iPad sidebar navigation.
    private(set) var practiceGoalDraft: PracticeGoalDraft?
    private(set) var practiceGoalMessage: String?
    /// Resource edits survive view/sidebar changes while the app is open, until Save or Discard.
    var resourceDraft: ResourceEditorDraft?
    let rewardEngagement = RewardEngagementState()

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

    func loadConfidenceDraft(saved: String?, epoch: UUID) {
        if confidenceDraft?.epoch != epoch || confidenceDraft?.isDirty == false {
            confidenceDraft = ConfidenceNoteDraft(epoch: epoch, text: saved ?? "", savedText: saved)
        }
    }

    func editConfidenceDraft(_ text: String) {
        confidenceDraft?.text = String(text.unicodeScalars.prefix(280))
        confidenceDraft?.hasSaveFailure = false
    }

    func saveConfidenceDraft() {
        guard let draft = confidenceDraft, draft.isDirty else { return }
        do {
            guard let repository else { throw LearnerStorageError.unavailable }
            guard try repository.learningDataEpoch() == draft.epoch else {
                confidenceDraft = nil
                return
            }
            try repository.saveConfidenceNote(draft.text, expectedEpoch: draft.epoch)
            confidenceDraft?.savedText = ConfidenceStatement.normalize(draft.text)
            confidenceDraft?.hasSaveFailure = false
        } catch {
            confidenceDraft?.hasSaveFailure = true
        }
    }

    func loadPracticeGoalDraft() {
        guard let repository else { return }
        do {
            let saved = try repository.practiceGoal()
            let epoch = try repository.learningDataEpoch()
            let changedLearner = practiceGoalDraft?.epoch != epoch
            practiceGoalDraft = practiceGoalDraft?.refreshed(saved: saved, epoch: epoch)
                ?? PracticeGoalDraft(epoch: epoch, selection: saved, saved: saved)
            if changedLearner || practiceGoalDraft?.hasSaveFailure == false { practiceGoalMessage = nil }
        } catch {
            // Retain any unsaved selection; failed reads cannot replace it with a default.
            if practiceGoalMessage == nil {
                practiceGoalMessage = "Your practice preference could not be loaded. Try again after unlocking your device."
            }
        }
    }

    func editPracticeGoalDraft(_ selection: SuggestionAction?) {
        practiceGoalDraft?.selection = selection
    }

    @discardableResult
    func savePracticeGoalDraft() -> Bool {
        guard var draft = practiceGoalDraft else { return false }
        do {
            guard let repository else { throw LearnerStorageError.unavailable }
            try repository.savePracticeGoal(draft.selection, expectedEpoch: draft.epoch)
            draft.recordSaveSuccess()
            practiceGoalDraft = draft
            practiceGoalMessage = nil
            return true
        } catch LearnerStorageError.invalidState {
            practiceGoalDraft = nil
            loadPracticeGoalDraft()
            practiceGoalMessage = "Practice was reset on this device. The unsaved preference was discarded."
        } catch {
            draft.recordSaveFailure()
            practiceGoalDraft = draft
            practiceGoalMessage = "Your preference could not be saved. It is kept here while the app is open. Try again after unlocking your device."
        }
        return false
    }

    func open() {
        do {
            if let repository { try repository.maintain() }
            else {
                let support = try FileManager.default.url(for: .applicationSupportDirectory,
                    in: .userDomainMask, appropriateFor: nil, create: true)
                let folder = SpeakingEnvironment.fixtureID.map { "SpeakingUITest-" + $0.uuidString } ?? "Learner"
                repository = try LearnerRepository(root: support.appendingPathComponent(folder, isDirectory: true))
                if let repository { try SpeakingEnvironment.seedIfNeeded(repository) }
            }
            preferences = try repository?.preferences() ?? LearnerPreferences()
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
