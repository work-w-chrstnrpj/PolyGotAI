# SpeechCoachAI — Technical Design (v2)

> Canonical technical intent since 2026-10-25. The source code is the final truth. The v1 TDD and its decision log are in [history/v1](../history/v1/tdd/tdd.md).

## Platform

- Swift + SwiftUI, iOS/iPadOS 17+, universal app (`application/SpeechCoachAI.xcodeproj`, scheme `SpeechCoachAI`).
- Xcode 27 locally. Simulators: iPhone 18 Pro, iPad (A16).
- No backend. Online AI goes directly to the learner's provider with their own key (BYOK).
- No third-party dependencies except the pinned FSRS-6 library in `application/Vendor/swift-fsrs/`.

## Source layout

```text
application/SpeechCoachAI/
  App/              app entry, LearnerStorageController (observable state owner), SpeakingEnvironment
  Domain/           pure Swift models and rules (no SwiftUI, no SwiftData)
  Infrastructure/
    Persistence/    SwiftData schema v1, LearnerRepository, PrivateFileStore (audio)
    Curriculum/     catalog loader and validation
    Credentials/    Keychain provider keys
    Providers/      gated HTTP clients for ASR/coaching (off until enabled)
    Audio/          capture file inspection
    Speech/         (v2) on-device TTS, recognition, voice metrics
  Features/         SwiftUI screens by area (Learn, Vocabulary, Recording, SpeechLab, …)
  Resources/        Curriculum/ (catalog JSON + audio), Tracks/ (v2), Lexicon/ (v2 word bank), SpeechLab/ (v2 drill catalogs), Rewards/, Assets.xcassets
application/SpeechCoachAITests/     Swift Testing, hosted
application/SpeechCoachAIUITests/   XCUITest
tools/curriculum/                   Python authoring and validation scripts
tools/native/verify.sh              build + all tests on a simulator
```

**Layering:** Features → Domain ← Infrastructure. Views read immutable domain snapshots from `LearnerStorageController`/`LearnerRepository`. SwiftData types never leave `Persistence/`.

## Persistence (unchanged in v2)

- SwiftData `LearnerSchemaV1` has three rows: `StateRow` (one learner document as Codable JSON, plus an epoch), `AttemptRow` (recording attempts), `FileIntentRow` (audio file finalize/delete intents).
- The learner document holds preferences, lesson journeys, vocabulary enrollments/exposures/recalls, FSRS review cards, custom topics, rewards ledger, resources and other optional fields.
- **v2 rule:** add new data as optional Codable fields on the learner document (default `nil`). Do not do a SwiftData migration without owner approval.
- Epoch checks and failed-save rollback in `LearnerRepository` stay in place. New write paths use the same pattern.
- Details: [data model](../database/data-model.md).

## Content catalog

### Current (v1)

`Resources/Curriculum/CurriculumCatalog.json` (schema 1) holds `lessons[]` (id, contentVersion, level, title, objectiveId, senses[], activities[]) and `archivedLessons[]` (old versions kept so saved journeys reopen exactly). The loader validates IDs, assets and kinds; an invalid lesson is hidden, not shown broken.

### v2 additions (all optional, backward compatible)

**Lesson**

| Field | Type | Meaning |
| --- | --- | --- |
| `tip` | String | Coach tip shown before the exercises (2–6 sentences) |
| `trackId` | String | `course` or a coach track id (e.g. `grammarian`) |
| `unitId` | String | Unit within the track |
| `sources` | [String] | Credits for ideas and public-domain material |

**Activity** (`CurriculumActivity`) gains one optional field, `exercise`, holding the typed spec. Existing fields (`prompt`, `answer`, `explanation`, `assetId`, …) keep their meaning; `prompt` is the question shown.

```json
{ "id": "a1-greetings-g1", "kind": "grammar", "required": true,
  "prompt": "Complete: I ___ fine.", "explanation": "Use am with I.",
  "exercise": { "type": "choice", "options": ["am", "is", "are"], "accepted": ["am"] } }
```

| `exercise` field | Type | Meaning |
| --- | --- | --- |
| `type` | String | One of `choice`, `wordBank`, `fillBlank`, `match`, `order`, `spotError`, `listenType`, `speak`, `open` |
| `options` | [String] | `choice`: the buttons. `wordBank`: tiles including distractors. `spotError`: the sentence tokens |
| `accepted` | [String] | Every answer that counts as correct. The lesson player shows `answer` as the example after answering; keep `answer` equal to `accepted[0]` for choice items (a test enforces it) |
| `pairs` | [[String]] | `match`: left/right pairs |
| `items` | [String] | `order`: items in the correct order (shown shuffled) |
| `audioText` | String | Text spoken by the on-device voice when there is no bundled clip (`listenType`, `speak`) |

A malformed `exercise` closes only its lesson (the loader's `metadataProblem()`), never the catalog.

### Coach tracks

One file per track: `Resources/Tracks/<trackId>.json`:

```json
{ "schemaVersion": 1, "packId": "speechcoach.track.grammarian", "contentVersion": "1", "locale": "en-US",
  "track": { "id": "grammarian", "coach": "grammarian",
             "stages": [ { "id": "starter", "title": "Starter", "units": [ { "id": "sentences", "title": "Build sentences" } ] } ] },
  "lessons": [ { "...same lesson schema, with trackId and unitId pointing at the unit above..." } ] }
```

Track lessons use the same `LessonJourney` progress store (keyed by lesson id), the same player and the same rewards. Lesson ids must be unique across the course and all tracks; the validator enforces this.

### Validation

`tools/curriculum/validate.py` (v2) checks: unique ids; every `type` has its required fields; `accepted` is non-empty; for `choice`, each accepted answer is in `options`; for `wordBank`, the accepted answer's tokens are in `options`; for `order`, ≥ 3 items; `match` has ≥ 3 pairs; audio exists or `audioText` is set; `sources` is present on track lessons. It runs before every content commit and inside a Swift test.

## Exercise engine

| `type` | Screen | Check |
| --- | --- | --- |
| `choice` | Tap one option (optional audio) | Option ∈ `accepted` |
| `wordBank` | Tap tiles to build a sentence | Normalized join ∈ `accepted` |
| `fillBlank` | Type a word or phrase | Normalized ∈ `accepted`, with "almost" tolerance |
| `match` | Tap left, then right, to pair | All pairs correct; wrong pairs shake and reset |
| `order` | Drag or tap to order | Sequence equals `items` |
| `spotError` | Tap the wrong word, then pick or type the fix | Token and correction ∈ `accepted` |
| `listenType` | Play TTS or clip, type what you hear | Word diff against `accepted[0]` |
| `speak` | Hear the model, say it | On-device transcript vs. `accepted` (word diff), shown as "We heard" |
| `open` | Write or record freely | Self-review; AI review later (Phase 6) |

**Legacy mapping:** an activity with no `type` and a `choiceSet` becomes `choice`; otherwise it becomes `open` (current compare-with-example behavior). Old journeys keep working.

**AnswerChecker** (`Domain/AnswerChecker.swift`, pure and fully unit-tested):

- Normalize: Unicode quotes → ASCII, lowercase, trim, collapse spaces, strip `.,!?;:"`, expand contractions (I'm → I am, don't → do not, can't → cannot, etc.) on both sides.
- Result: `.correct`, `.almost(hint)` (same word count; one word within edit distance 1, or 2 for words of 8+ letters; words under 4 letters must match exactly), or `.incorrect`.
- Word diff (for `listenType`/`speak`): per-word `correct | misspelled | missing | extra`.

**Swift API for screens** (all in `Domain/`, written; screens only call these):

```swift
activity.resolvedExercise            // ExerciseSpec; legacy activities map to .choice or .open
spec.kind                            // ExerciseType?  (.choice, .wordBank, .fillBlank, .match, .order, .spotError, .listenType, .speak, .open)
spec.options / .pairs / .items / .audioText / .modelAnswer
spec.evaluate(.text("am"))           // AnswerResult? — nil for .open
spec.evaluate(.sequence(["I","am","fine."]))   // wordBank tiles, order items
spec.evaluate(.pairs([["hello","greeting"]]))  // match

var session = ExerciseSession(activities: lesson.sessionActivities)
session.current                      // Item (id + spec) or nil when finished
session.submit(response)             // checks the current item once -> AnswerResult? (nil for .open)
session.awaitingContinue             // true after submit, until advance()
session.advance()                    // next item; a wrong first answer returns once at the end
session.progress / .isFinished / .accuracy   // 0...1, Bool, first-try accuracy (correct 1, almost 0.5)
AnswerChecker.diff(response:expected:)       // [WordDiffEntry] for dictation and "We heard"
spec.storedText(response) / spec.result(forStored:)   // one text per answer in the journey; accuracy is recomputed from it
lessonSession.exerciseAccuracy / .missedExercises     // first-try accuracy and the wrongly answered activities
SpeechSynthesizer.shared.speak(text, slow:)  // Infrastructure/Speech, on-device en-US voice
```

**Lesson flow** (`LessonPlayerView` + `Features/Learn/Exercises/ExerciseActivityView`): coach tip → one exercise per screen → Check → feedback bar (correct / almost / not quite + answer + reason) → Continue. A lesson uses this flow when its current activity has a checked `exercise`; other activities (guided speaking, self-review, quiet text, all older lessons) keep the existing screens. The first answer of each exercise is saved as that activity's response (so completion, rewards and resume work as before); the result is recomputed from it. Finish shows first-try accuracy and "try the ones you missed" (`MissedPracticeView`, not saved), plus words to keep.

## Lexicon (Phase 3)

Spec: [lexicon.md](../product-specification/lexicon.md). The Lexicon tab reuses the existing word review (FSRS-6, `ReviewSchedule`, `VocabularyRecall`) and adds a bundled bank plus a learner section.

**Bank:** `Resources/Lexicon/lexicon-NN-<name>.json` (one file per group; field packs carry `"kind": "field"`):

```json
{ "schemaVersion": 2,
  "group": { "id": "everyday-a1", "title": "Everyday A1", "level": "A1", "tagline": "Words for daily life", "sources": ["..."] },
  "words": [ { "lemma": "borrow", "pos": "verb", "cefr": "A1", "register": "everyday",
               "meaning": "To take something and give it back later.",
               "examples": ["Can I {borrow} your pen?"],
               "wrong": ["I borrow my sister a pen."] } ] }
```

- `LexiconWord.key` = normalized lemma + part of speech (lowercase, accents and extra spaces removed). **Adding a word whose key already exists in the bank or the learner's words is refused** with a pointer to the existing word.
- **Stage** (New, Learning, Review, Easy) is derived from the FSRS card state and last `RecallRating`. A word is **Easy** when its last rating is `.easy`.
- **Lexicon in Action** builds questions with the exercise engine: `fillBlank`/`choice` from the braced form in `examples` (the blank), and `choice` from one `examples` sentence versus `wrong` sentences. A word needs at least one question source to be eligible.
- **Daily Lexicon:** the first bank word in an active group, in group order, not yet Easy; the choice is stored for the local day (optional `dailyLexicon` field on the learner document) so it doesn't change.
- **Learner data (all optional fields on the learner document):** `lexiconActiveGroups: [String]`, `lexiconWords: [UserLexiconWord]` (learner-added), `lexiconActionHistory`, `dailyLexicon`. No SwiftData migration.
- **Specialized Lexicon (Phase 6):** one provider request returns a validated list `{ lemma, pos, meaning, example, register }`; invalid entries are dropped; duplicates are skipped; the learner confirms before words are added.

## Dictation input (Phase 1)

- `Infrastructure/Speech/DictationRecognizer.swift`: wraps `SFSpeechRecognizer(locale: en-US)` with `requiresOnDeviceRecognition = true` and `AVAudioEngine` input; publishes partial text; handles permission and interruptions; unavailable when on-device recognition isn't supported.
- `Features/Shared/DictationButton.swift`: a microphone button for any text field. It takes a `Binding<String>` and inserts the spoken text after the existing text, replacing the partial result as recognition updates. The button shows a stop state with a pulsing indicator while listening.
- Permissions: `INFOPLIST_KEY_NSSpeechRecognitionUsageDescription`; the microphone key already exists.
- Used on every typing field, and hidden for listen-and-write exercises.

## Speech services (Phase 5; Phase 1 uses TTS and dictation)

- `Infrastructure/Speech/SpeechSynthesizer.swift`: `AVSpeechSynthesizer` wrapper. en-US voice (enhanced if installed), normal and slow rate, completion callbacks. Respects quiet mode.
- `Infrastructure/Speech/SpeechLabRecognizer.swift`: `SFSpeechRecognizer(locale: en-US)` with `requiresOnDeviceRecognition = true`. If `supportsOnDeviceRecognition` is false, `speak` exercises are skipped (never sent to a server). Returns the transcript plus segment timestamps.
- `Domain/SpeechLab.swift` and `Domain/SpeechLabVoice.swift`: words per minute, pauses > 1 s (from segment gaps), filler count, loudness samples (from `AVAudioRecorder` metering).
- The Info.plist is generated: add `INFOPLIST_KEY_NSSpeechRecognitionUsageDescription` to the app target's Debug/Release build settings. `INFOPLIST_KEY_NSMicrophoneUsageDescription` already exists; reword it to cover Speech Lab.

### Hands-free Interview (Phase 5b)

`Domain/HandsFreeInterview.swift`: `TurnTakingRules` + `TurnDetector` (pure state machine; the caller passes the clock and the live caption's word count), `InterviewFollowUpRule`, `HandsFreeInterview` (plan, prompt, record, skip, repeat, finish, summary; Codable but not persisted). Bank: `Resources/SpeechLab/speechlab-interview.json`, loaded by `SpeechLabCatalog.interview`. Screen: `Features/SpeechLab/HandsFreeInterviewController` (audio lifetime: TTS, one `DictationRecognizer` per turn, pause on background, interruption and route loss) and `HandsFreeInterviewView`. Online follow-ups arrive in Phase 6c.

## Coaches

`LearnerPreferences.Coach` gains cases for the new characters (`debater`, `negotiator`, `storyteller`, `copywriter`). Adding cases is backward compatible for stored data; never rename or remove a case. A coach without artwork shows an SF Symbol placeholder.

## Level and usage analytics (2026-10-26)

- `Domain/XPLevel.swift`: level from XP (`threshold(L) = 50·(L−1)·L`). The ledger keeps a legacy `gold` field on old rows, always 0 on new ones; purchases, quotes, Freeze and Repair buying are removed.
- `Domain/UsageLog.swift`: `UsageSession`, `UsageLog` (learner document field `usage`; visits under 60 seconds are ignored; overlaps merge; visits older than 120 days fold into per-day totals), `UsageTracker` (pure foreground state machine; a gap of up to 30 seconds continues a visit), `UsageReport` (splits visits at midnight; hourly, daily and monthly buckets; totals and days used).
- `App/UsageRecorder.swift`: listens to scene phase, saves finished visits through `LearnerRepository.recordUsage`, keeps an unsaved visit across a locked device or a crash (UserDefaults `usage.open` and `usage.pending`).
- `Domain/Milestones.swift`: milestones are computed from the ledger, level tests, journeys, usage and word stages; nothing extra is stored.
- Screens: `Features/Progress/{LevelAndMilestonesViews,UsageAnalyticsView}.swift` (Swift Charts); `Features/Rewards/RewardOverview.swift` is now "Level and badges".

## Online AI (Phase 6)

The existing gated provider clients (`Infrastructure/Providers/`) stay disabled until the owner installs a verification file (`tools/provider/install_verification.sh`). Keys stay in Keychain, requests are explicit only, and failures are shown plainly. Endpoint, models and limits: [Decision 9 findings](../development-plan/development-plan.md#decision-9-findings--phase-6a-research-2026-10-25).

**Built so far (fake transport only, no live call):**

- `LabFeedbackService` (`LabFeedbackClient.swift`): `transcribe` (`qwen3-asr-flash`), `feedback` (`qwen-flash`, strict reply: summary, strengths, up to three quoted improvements, next step, `speechAssessmentStatus` = `not_assessed`, every quote must appear in the learner's text), `followUp` (6c: one short question that picks up a word from the answer; any failure falls back to the scripted follow-up; 6 second timeout), `generateLexicon` (6d: up to 15 cards, each checked like a bundled word and skipped if broken, above the level, repeated or already in the Lexicon). One request at a time, no retry, only with a `LabFeedbackConsent` made from the current `LabFeedbackDisclosure` line.
- `LabFeedbackRequest` builders per mode (`LabFeedbackRequests.swift`): pronunciation, speaking, interview, conversation, communication and `coachReview` (a coach lesson's "Your turn" answer); each mode has a rubric of topics for comments, never marks.
- Saved results: `StoredLabFeedback` in the learner document (`labFeedback`, capped at 100) with `LabFeedbackHistorySummary` (count, last two weeks, repeated tips; never a score). Generated words are saved by `LearnerRepository.saveGeneratedLexicon` into a personal topic named "AI: <topic>".

## Xcode project

`project.pbxproj` uses explicit file references (objectVersion 56), so every new file must be registered, and two people editing it at once conflict. **Phase 0 (Claude):** convert the app and test groups to folder-synchronized groups so that new files under the source folders are picked up automatically. Until that lands, only one engineer edits `project.pbxproj` at a time.

## Testing

See the [test specification](../testing/test-specification.md). Domain logic (AnswerChecker, catalog validation, metrics) gets Swift Testing unit tests. Each new screen gets one XCUITest happy path. `tools/native/verify.sh <SIMULATOR_UUID>` must pass before a phase is reviewed.
