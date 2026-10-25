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
  Resources/        Curriculum/ (catalog JSON + audio), Tracks/ (v2), Rewards/, Assets.xcassets
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
| `tip` | String | Coach tip shown before the exercises (2–4 sentences) |
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
| `accepted` | [String] | Every answer that counts as correct. The first is the model answer shown after answering |
| `pairs` | [[String]] | `match`: left/right pairs |
| `items` | [String] | `order`: items in the correct order (shown shuffled) |
| `audioText` | String | Text spoken by the on-device voice when there is no bundled clip (`listenType`, `speak`) |

A malformed `exercise` closes only its lesson (the loader's `metadataProblem()`), never the catalog.

### Coach tracks

One file per track: `Resources/Tracks/<trackId>.json`:

```json
{ "schemaVersion": 1, "trackId": "grammarian", "coach": "owlGrammarian", "title": "Grammarian",
  "units": [ { "id": "gram-u1", "title": "Build a sentence", "stage": "foundation",
               "lessons": [ { "...same lesson schema, with trackId/unitId..." } ] } ] }
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
- Result: `.correct`, `.almost(hint)` (same word count; one word within edit distance 1, or 2 for words of 8+ letters), or `.incorrect`.
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

**Bank:** `Resources/Lexicon/<groupId>.json`:

```json
{ "schemaVersion": 1, "groupId": "everyday-a1", "title": "Everyday A1", "level": "A1",
  "sources": ["NGSL (word selection only)"],
  "words": [ { "id": "everyday-a1-borrow", "lemma": "borrow", "pos": "verb",
               "meaning": "Take something and give it back later.",
               "examples": ["Can I borrow your pen?"],
               "wrongUsage": ["She borrowed me her pen."],
               "blankSentences": ["Can I ___ your pen?"] } ] }
```

- `LexiconWord.key` = normalized lemma + part of speech (lowercase, accents and extra spaces removed). **Adding a word whose key already exists in the bank or the learner's words is refused** with a pointer to the existing word.
- **Stage** (New, Learning, Review, Easy) is derived from the FSRS card state and last `RecallRating`. A word is **Easy** when its last rating is `.easy`.
- **Lexicon in Action** builds questions with the exercise engine: `fillBlank`/`choice` from `blankSentences`, and `choice` from one `examples` sentence versus `wrongUsage` sentences. A word needs at least one question source to be eligible.
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
- `Infrastructure/Speech/OnDeviceRecognizer.swift`: `SFSpeechRecognizer(locale: en-US)` with `requiresOnDeviceRecognition = true`. If `supportsOnDeviceRecognition` is false, `speak` exercises are skipped (never sent to a server). Returns the transcript plus segment timestamps.
- `Domain/VoiceMetrics.swift`: words per minute, pauses > 1 s (from segment gaps), filler count, loudness samples (from `AVAudioRecorder` metering).
- The Info.plist is generated: add `INFOPLIST_KEY_NSSpeechRecognitionUsageDescription` to the app target's Debug/Release build settings. `INFOPLIST_KEY_NSMicrophoneUsageDescription` already exists; reword it to cover Speech Lab.

## Coaches

`LearnerPreferences.Coach` gains cases for the new characters (`debater`, `negotiator`, `storyteller`, `copywriter`). Adding cases is backward compatible for stored data; never rename or remove a case. A coach without artwork shows an SF Symbol placeholder.

## Online AI (Phase 6)

The existing gated provider clients (`Infrastructure/Providers/`) stay disabled. Phase 6 connects the lesson's "Your turn" task to a per-coach review prompt. Keys stay in Keychain, requests are explicit only, and failures are shown plainly.

## Xcode project

`project.pbxproj` uses explicit file references (objectVersion 56), so every new file must be registered, and two people editing it at once conflict. **Phase 0 (Claude):** convert the app and test groups to folder-synchronized groups so that new files under the source folders are picked up automatically. Until that lands, only one engineer edits `project.pbxproj` at a time.

## Testing

See the [test specification](../testing/test-specification.md). Domain logic (AnswerChecker, catalog validation, metrics) gets Swift Testing unit tests. Each new screen gets one XCUITest happy path. `tools/native/verify.sh <SIMULATOR_UUID>` must pass before a phase is reviewed.
