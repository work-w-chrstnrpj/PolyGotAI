# SpeechCoachAI Application Map

Project-owned discovery map (v2, 2026-10-25). Navigation only; read the exact source before editing. Paths are under `application/SpeechCoachAI/`.

Read first: `docs/development-plan/development-plan.md` (phase and lanes), `docs/product-specification/product-specification.md`, `docs/tdd/tdd.md`. For UI work, read `docs/product-specification/ui-reference-guide.md`.

| Area | Entry points |
| --- | --- |
| App and state | `App/SpeechCoachAIApp.swift`, `App/LearnerStorageController.swift`, `App/SpeakingEnvironment.swift` |
| Navigation, Today, Learn and Speech Lab shells | `Features/Navigation/AppShell.swift` |
| Lesson player | `Features/Learn/LessonPlayerView.swift`; INTRO-01 extras in `IntroPracticeView.swift`, `IntroductionReviewView.swift` |
| Course catalog | `Domain/CurriculumCatalog.swift`, `Infrastructure/Curriculum/CurriculumCatalogLoader.swift`, `Resources/Curriculum/CurriculumCatalog.json` |
| Lesson progress | `Domain/LessonJourney.swift` |
| Vocabulary and review | `Features/Vocabulary/*`, `Domain/VocabularyLink.swift`, `VocabularyRecall.swift`, `ReviewSchedule.swift` (FSRS-6), `CustomVocabulary.swift` |
| Recording | `Features/Recording/RecordingView.swift`, `RecordingController.swift`, `Infrastructure/Audio/CaptureFile.swift` |
| Today suggestion and progress evidence | `Domain/PracticeRecommendation.swift`, `Domain/LearningEvidence.swift`, `Features/Progress/ProgressOverview.swift` |
| Rewards | `Domain/RewardPolicy.swift`, `RewardLedger.swift`, `AwardCatalog.swift`, `Features/Rewards/*` |
| Persistence | `Infrastructure/Persistence/LearnerRepository.swift`, `LearnerSchema.swift`, `PrivateFileStore.swift` |
| Provider (off until Phase 6) | `Infrastructure/Credentials/*`, `Infrastructure/Providers/*`, `Features/Settings/ProviderSettingsView.swift`, `Features/Recording/Online*` |
| v1 Speech Lab features being moved or hidden | `Features/Conversation/*`, `Features/Communication/*`, `Features/GeneratedPractice/*`, `Features/Vocabulary/WordOfDayView.swift`, `VocabularyDiscoveryView.swift` |
| Design system | `Features/Shared/DesignSystem.swift`, `Resources/Assets.xcassets` |
| v2 (planned) | `Domain/AnswerChecker.swift`, `Domain/ExerciseSession.swift`, `Domain/TrackCatalog.swift`, `Domain/VoiceMetrics.swift`, `Infrastructure/Speech/*`, `Features/Learn/Exercises/*`, `Features/SpeechLab/*`, `Resources/Tracks/*.json` |

Tests: `application/SpeechCoachAITests/` (Swift Testing), `application/SpeechCoachAIUITests/` (XCUITest). Main check: `tools/native/verify.sh`.
