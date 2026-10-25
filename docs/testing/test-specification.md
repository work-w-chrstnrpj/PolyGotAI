# Test specification (v2)

> v1 test plan and evidence: [history/v1/testing](../history/v1/testing/).

## How to run

```bash
bash tools/native/verify.sh 7535AD2C-F655-4F05-8C36-FE5E0A614902
```

This builds the app and runs all hosted unit tests and UI tests on the iPhone 18 Pro simulator. Results go to `application/.build/verification/run-*/` (`test.log`, `summary.json`). Use the iPad (A16) simulator (`709D6F70-328D-4458-8F8A-B2C47A945A80`) at the end of each phase. Claude's parallel runs use iPhone 18 Pro Max with a separate DerivedData folder ([development plan](../development-plan/development-plan.md#rules-for-working-in-parallel)).

## Test layers

| Layer | Framework | Location | Owner | What it covers |
| --- | --- | --- | --- | --- |
| Domain unit | Swift Testing | `application/SpeechCoachAITests/` | Claude | Answer checking, exercise sessions, scheduling, rewards, catalog/track loading, voice metrics |
| Repository | Swift Testing (isolated in-memory store) | same | Claude | Saving and recovery, epoch checks, backward-compatible decoding of old learner documents |
| Content | Swift Testing + `tools/curriculum/validate.py` | same / `tools/` | Claude | Every bundled lesson and track validates: ids, accepted answers, required fields, audio |
| UI | XCUITest | `application/SpeechCoachAIUITests/` | Codex | One happy path per screen; key accessibility identifiers |
| Manual | Simulator / device | `phases/phase-N/evidence/` | Claude, then owner | Walkthrough screenshots, iPad layout, larger text, dark mode |

## Rules

- Tests use synthetic data and isolated stores. Never touch the owner's real learner data. Never make live provider calls.
- Every new domain type gets unit tests in the same phase.
- A UI change that renames or removes an accessibility identifier updates the UI tests in the same change.
- **Compatibility test (every phase):** a learner document saved by the previous build must still decode and open.
- A failing test is reported as failing, with output. Don't skip or delete it to get green; ask first.

## v2 test targets by phase

| Phase | Must-have tests |
| --- | --- |
| 0 | Existing suite green; no "unavailable/not scored/coming later" strings on Today, Learn or Speech Lab (UI test reads static texts) |
| 1 | `AnswerChecker` (normalization, contractions, almost-matches, alternatives); each exercise type's check; `ExerciseSession` re-queue and accuracy; legacy activity mapping; A1 content validation; UI: complete one A1 lesson with mixed types |
| 2 | Track loading and validation; unique lesson ids across course and tracks; new coach cases decode; UI: open a coach and start a lesson |
| 3 | All track files validate; source credits present |
| 4 | Word diff; WPM/pause/filler metrics from fixture timestamps; recognizer unavailable means speak exercises are skipped; UI: dictation check flow |

## Existing suites (v1, kept)

`BootstrapConfiguration`, `CaptureRecovery`, `CoachingValidation`, `CommunicationDelivery`, `ConversationDelivery`, `CurriculumCatalog`, `CustomVocabulary`, `DailyProgressDelivery`, `GeneratedPracticeDelivery`, `IntroductionDelivery`, `LearnerRepository`, `LessonJourney`, `PracticePreferences`, `PracticeRecommendation`, `ProviderCredential`, `ResourceLibraryAcceptance`, `ResourceLibraryDelivery`, `ReviewCredit`, `ReviewSchedule`, `RewardDelivery`, `SmallA1Course`, `SpeakingLoopIntegration`, `TranscriptionLifecycle`, `VocabularyDiscoveryDelivery`, `VocabularyLink`, `VocabularyRecall`; UI: `BootstrapLaunchTests`. When a v2 change makes a test's expectation obsolete (e.g. a removed screen), update or remove the test in the same change and say so in the report.
