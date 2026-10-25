# Data model (v2)

> Source of truth: `Infrastructure/Persistence/LearnerSchema.swift` and `LearnerRepository.swift`. Detailed v1 field history: [history/v1/database](../history/v1/database/data-model.md).

## Storage

| Store | What | Where |
| --- | --- | --- |
| SwiftData `LearnerSchemaV1` | `StateRow` (one learner document as JSON + epoch), `AttemptRow` (recording attempt snapshots), `FileIntentRow` (pending audio finalize/delete) | App container, excluded from device backup |
| Private files | Recorded audio | `PrivateFileStore`, protected app directory |
| Keychain | Learner's AI provider keys | `ProviderCredentialStore` |
| App bundle (read-only) | Course catalog, coach tracks (v2), audio, award catalog | `Resources/` |

## Learner document (in `StateRow`)

`preferences` (coach, background, appearance, countdown, …) · `lessonJourneys` (per lesson and version: current activity, responses, drafts, completion) · `vocabularyEnrollments` · `vocabularyExposures` · `vocabularyRecalls` · `reviewCards` (FSRS-6) · `senseCredits` · `customTopics` · `openRecall` · `dailyChoice` · `confidenceNote` · `attemptFormats` · `reviewSettings` · `practiceGoal` · `speakingPracticeArchives` · `learningResources` · `generatedPractice` · `wordOfDay` · `rewards` (ledger) · **v2:** `passedJumpTests` (levels opened by a perfect jump test) · `lexicon` (active groups, daily word, Lexicon in Action waits). The document has hand-written `CodingKeys`: a new field must be added to the enum, `init(from:)` and `encode(to:)`, or it silently does not persist.

## Rules

- **No SwiftData migration** without owner approval. New data goes in as **optional** Codable fields on the learner document (default `nil`), so older documents still decode.
- Never rename or remove a stored enum case (e.g. `LearnerPreferences.Coach`). Only add.
- Every write checks the learner-data epoch and rolls back on failure. "Delete all learning data" replaces the epoch and clears files.
- Content is versioned separately from learner data. A journey records the lesson `contentVersion` it started with; old versions stay in `archivedLessons` so saved work reopens exactly.

## v2 additions (planned)

| Phase | Addition | Shape |
| --- | --- | --- |
| 1 ✅ | First answer per exercise | The existing `firstResponseText` on the journey response holds it (tiles joined by spaces, order items and match pairs joined by " \| "). No new field |
| 1 ✅ | Result and lesson accuracy | Recomputed from the stored first answer with `ExerciseSpec.result(forStored:)`; not stored |
| 2 | Track lessons | Same `lessonJourneys`, keyed by unique lesson id |
| 4 | Speech Lab attempts | Optional `speechLabAttempts: [SpeechLabAttempt]` (area, item id, date, accuracy/wpm/pauses, optional recording id) |
