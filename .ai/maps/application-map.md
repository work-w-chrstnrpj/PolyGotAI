# SpeechCoachAI Application Map

Project-owned discovery map (v2, refreshed 2026-11-08). Navigation only; read the exact source before editing. Paths are under `application/SpeechCoachAI/`.

Read first: `docs/development-plan/development-plan.md` (phase and lanes), `docs/product-specification/product-specification.md`, `docs/tdd/tdd.md`. For UI work, read `docs/product-specification/ui-reference-guide.md`.

| Area | Entry points |
| --- | --- |
| App and state | `App/SpeechCoachAIApp.swift`, `App/LearnerStorageController.swift`, `App/SpeakingEnvironment.swift` |
| Navigation, Today, Learn and Speech Lab shells | `Features/Navigation/AppShell.swift` |
| Lesson player | `Features/Learn/LessonPlayerView.swift`; INTRO-01 extras in `IntroPracticeView.swift`, `IntroductionReviewView.swift` |
| Course catalog | `Domain/CurriculumCatalog.swift`, `Infrastructure/Curriculum/CurriculumCatalogLoader.swift`, `Resources/Curriculum/CurriculumCatalog.json` |
| Lesson progress | `Domain/LessonJourney.swift` |
| Lexicon, vocabulary and review | `Features/Vocabulary/*`, `Domain/Lexicon.swift`, `LexiconTraining.swift`, `Infrastructure/Lexicon/LexiconBankLoader.swift`, `Domain/VocabularyLink.swift`, `VocabularyRecall.swift`, `ReviewSchedule.swift` (FSRS-6), `CustomVocabulary.swift` |
| Recording | `Features/Recording/RecordingView.swift`, `RecordingController.swift`, `Infrastructure/Audio/CaptureFile.swift` |
| Today and Progress | `Features/Today/TodayView.swift`, `Features/Progress/ProgressOverview.swift`, `LevelAndMilestonesViews.swift`, `UsageAnalyticsView.swift`, `Domain/XPLevel.swift`, `Domain/Milestones.swift`, `Domain/UsageLog.swift` |
| Rewards | `Domain/RewardPolicy.swift`, `RewardLedger.swift`, `AwardCatalog.swift`, `Features/Rewards/*` |
| Persistence | `Infrastructure/Persistence/LearnerRepository.swift`, `LearnerSchema.swift`, `PrivateFileStore.swift` |
| Provider (BYOK) | see `service-map.md` |
| Talk | `Features/Talk/TalkView.swift`, `TalkSession.swift`, `Domain/TalkModels.swift`, `Infrastructure/Speech/TalkSpeaker.swift` |
| Design system | `Features/Shared/DesignSystem.swift`, `Resources/Assets.xcassets` |
| Exercises, tracks, Lab | `Domain/AnswerChecker.swift`, `Domain/Exercise.swift`, `Domain/TrackCatalog.swift`, `Domain/LevelGate.swift`, `Features/Learn/Exercises/*`, `Features/Learn/CoachCatalogView.swift`, `Features/SpeechLab/*`, `Infrastructure/Speech/*`, `Resources/Tracks/*.json` |

Tests: `application/SpeechCoachAITests/` (Swift Testing), `application/SpeechCoachAIUITests/` (XCUITest). Main check: `tools/native/verify.sh`.
