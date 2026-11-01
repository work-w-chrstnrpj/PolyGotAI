# Job 14b — docs against code, repeat (post-wave-B snapshot)

Read-only. No doc or source file was changed. This report is the only file this lane wrote.

**Validator at write time** (`python3 tools/curriculum/validate.py`, 2026-10-25 23:18):

```text
lexicon words: 866
course lessons: 57, track lessons: 256, typed exercises: 4074
OK
```

Last line: `OK`. This is the **post-wave-B** tree: LOG-0052 (Advanced for all ten coaches, 256 lessons) and LOG-0053 (6b–6d cores, 448 tests) are logged, and the specs were last edited at 23:06. No mid-write movement this time.

## Method

Re-ran the Job 5 checklist (`opencode-docs-vs-code-2026-10-25.md`) against the current tree: counts, tab/screen names, TDD structure and rules, lexicon file shape, Speech Lab claims. Code and JSON are truth. No `xcodebuild` or simulator command was run.

## Fixed since Job 5

| Job 5 finding | Now |
| --- | --- |
| `lexicon.md:64` contradicted `:67` (722 vs 866) | `:65` says 18 level groups (722) “plus five opt-in field packs (below)”; `:68` owns 23 groups / 866. Data: 722 + 144 = 866. Consistent. |
| `lexicon.md` “one wrong-usage sentence” vs “one or two” | One rule now: one or two, field packs exactly one. Data confirms 0 field words with ≠1 `wrong`. |
| `product-specification.md:29` and `tdd.md:55` said tips are 2–4 sentences | Both now say 2–6. Longest tip is 5 (`c1-strategy`); `intro-01` now has a tip. |
| `tdd.md:26` Resources layout missed Lexicon/ and SpeechLab/ | Both listed. |
| `tdd.md:174` pointed at a nonexistent `OnDeviceRecognizer.swift` | Now `SpeechLabRecognizer.swift`, which exists. |
| `tdd.md:175` pointed at a nonexistent `Domain/VoiceMetrics.swift` | Now `Domain/SpeechLab.swift` + `Domain/SpeechLabVoice.swift`; `wordsPerMinute`/`fillerCount` live there. |
| `tdd.md:84–87` track JSON shape was wrong | Now `track.stages[].units[]` + separate `lessons[]`, matching the packs. |
| `tdd.md:114` `.almost` omitted the under-4-letter floor | Floor now stated; code matches. |
| `tdd.md:72` said `accepted[0]` is shown as the example | Now says the player shows `answer` and asks for `answer == accepted[0]` (the enforcement claim is still false — below). |
| `tdd.md:147–156` lexicon example had wrong file shape and keys | Now `group{}` + top-level `words[]` with `wrong`, matching the files. |
| `ui-ux-design.md:7/28/34` old Speech Lab mode names; “Take the C1 test” on every level | Fixed; wording matches the shipped hub and `"Take the \(level) test"`. |
| `ui-screen-state-inventory.md:3/105` said conversation/interview/communication moved to Coaches | Fixed; SP-01 now lists the shipped eight entries. |
| `english-curriculum.md:11` “unreleased content is marked Coming later” | Fixed: “Only unlocked levels are open; later levels show their level test. Unfinished content is hidden.” |
| `coach-tracks.md:12` “176 coach lessons” | Fixed: the line records 176 as the Intermediate checkpoint and ends with “the packs hold 256 coach lessons”, matching the validator. |

## Still open

| file | location | claim as written | code reality | suggested fix |
| --- | --- | --- | --- | --- |
| `product-specification/product-specification.md` | line 18 | Speech Lab = “Introduction recording, Conversation, Interview, Communication practice, plus Phonetics, Articulation, Dictation, Voice” | The hub labels are Dictation, Pronunciation (grouping Phonetics + Articulation) and Speaking; Phonetics and Articulation are second-level, not peers of Dictation. | Use the hub labels, as `ui-ux-design.md:7` does. |
| `product-specification/product-specification.md` | line 60 | “adds four sound-and-voice modes (Phonetics, Articulation, Dictation, Voice)” | Same: three hub entries, two of them renamed. | “adds Dictation, Pronunciation (Phonetics and Articulation) and Speaking”. |
| `product-specification/speech-lab.md` | line 15 | Home table lists “Phonetics · Articulation · Dictation · Voice” | Line 63 of the same file gives the correct hub: “Dictation · Pronunciation (Phonetics and Articulation together) · Speaking (the former Voice) · …”. The file contradicts itself and the app. | Replace the table cell with the line-63 labels. |
| `product-specification/product-specification.md` | line 30 | “**Exercises (8–15).**” | Taught coach lessons now hold 12–16 exercises; `rl-scan-facts` (Starter) has 16. `intro-01` has 22 activities and 0 typed exercises (the guided exception). | Widen to “12–16 (the guided introduction excepted)” or trim `rl-scan-facts` by one. |
| `tdd/tdd.md` | line 72 | “…keep `answer` equal to `accepted[0]` for choice items (a test enforces it)” | No test reads content JSON. 35 choice items break equality — e.g. `a1-greetings-production-v3-4` (“I am well, thank you. / I’m fine, thanks.” vs “I am well, thank you.”), `a1-greetings-recall-morning` (“Good morning.” vs “Good morning”), `read-family` (straight vs curly apostrophe). | Add the equality check to `validate.py` (it already has give-away checks) and fix the 35 items, or delete “(a test enforces it)”. |
| `tdd/tdd.md` | line 94 | “It runs before every content commit and inside a Swift test.” | No Swift test invokes `validate.py` or a Swift port; the only validator run is the manual script. | Add a hosted test that runs the checks, or drop “and inside a Swift test”. |
| `tdd/tdd.md` | line 169 | “Used on every typing field, and hidden for listen-and-write exercises.” | `ExerciseActivityView.typedBody` always applies `.dictation($typed)` (`:283`), and `listenType` falls into `typedBody` (`:166`), so the mic button shows under “Type what you hear”. | Hide the button for `listenType` (and then the sentence is true), or correct the doc. |
| `tdd/tdd.md` | line 94 | The validator check list | The list stops at `sources`; `validate.py` now also rejects a printed answer, case/punctuation twins and repeated dictation. | Add the three give-away checks to the list. |

## Claims re-checked and correct

- Tab names and order (`AppDestination` = Today · Lexicon · Lesson · Speech Lab · Progress) match `product-specification.md:21`, `ui-ux-design.md:7` and `ui-screen-state-inventory.md`.
- Level rules (`product-specification.md:48–50`): lock per level, test for any locked level including C2 from A1, pass opens that level and every level below, lessons inside a level open in any order — matches `LevelGate` and `JumpTest`.
- `"Take the A2 test"`-style action: `CourseCatalogView.swift:38` renders `"Take the \(level) test"`.
- `ExerciseType` list in `tdd.md:70` matches the 9 enum cases, including `open`.
- The validator rules in `tdd.md:93` that are listed match `validate.py` (unique ids, required fields, accepted non-empty, accepted in options, wordBank tokens, order ≥3, match ≥3, audio or `audioText`, `sources`).
- Lexicon numbers: 866 words, 23 files, 18 level groups × 40 (722), 5 field packs (144), one `wrong` per field word, `newPerDay` default 10, `sessionSize` 10.
- Hands-free claims (`speech-lab.md:53`): silence 2.0 s, max turn 90 s, two “Take your time” prompts, 39 questions in `speechlab-interview.json`, orb/“We heard”/Repeat/Skip/Done, summary never scores — all match `TurnTakingRules`, `HandsFreeInterviewController` and the view.
- `speech-lab.md:55–57` now labels the AI follow-up as “Phase 6c core”, matching `LabAIExtras.followUp` and its tests (screen still pending, as stated).
- Paths `Infrastructure/Speech/DictationRecognizer.swift` and `Features/Shared/DictationButton.swift` exist; the hub order matches `AppShell.SpeechLabContent`.

## Where this stopped

The Job 5 checklist is closed out item by item and re-read against the settled 256-lesson tree. The two largest leftovers are naming drift in three Speech Lab doc lines and the TDD's three “enforced/hidden” claims that nothing enforces. Lesson and test counts in the specs are now correct (256 lessons; 866 words), but the “8–15 exercises” line and the TDD validator list still describe the older content. No further count is expected to move until the owner approves the phase.
