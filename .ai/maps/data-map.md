# PolyGotAI Data Map

Learner data is one JSON document in SwiftData (ADR-0002). Paths are repo-relative.

- Schema (`StateRow`, `AttemptRow`, `FileIntentRow`) → `application/SpeechCoachAI/Infrastructure/Persistence/LearnerSchema.swift`
- Learner document and `CodingKeys` → `application/SpeechCoachAI/Infrastructure/Persistence/LearnerDocument.swift`, `application/SpeechCoachAI/Domain/LearnerState.swift`
- Repository by area → `application/SpeechCoachAI/Infrastructure/Persistence/LearnerRepository.swift`, `LearnerRepository+Lab.swift`, and the other `LearnerRepository+*.swift` files
- Private audio files → `application/SpeechCoachAI/Infrastructure/Persistence/PrivateFileStore.swift`
- Observable state owner → `application/SpeechCoachAI/App/LearnerStorageController.swift`
- Erase all data (Face ID gate) → `application/SpeechCoachAI/App/LearnerReset.swift`
- Lesson progress → `application/SpeechCoachAI/Domain/LessonJourney.swift`
- Review cards (FSRS-6) → `application/SpeechCoachAI/Domain/ReviewSchedule.swift`, `application/Vendor/swift-fsrs/`
- Rewards ledger → `application/SpeechCoachAI/Domain/RewardLedger.swift`
- Bundled content (read-only) → `application/SpeechCoachAI/Resources/Curriculum/`, `application/SpeechCoachAI/Resources/Tracks/`, `application/SpeechCoachAI/Resources/Lexicon/`, `application/SpeechCoachAI/Resources/SpeechLab/`, `application/SpeechCoachAI/Resources/Rewards/`
- Docs → `docs/database/data-model.md`
