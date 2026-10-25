# Job 14b — docs against code, repeat (snapshot before the wave-B log entry)

Read-only. No doc or source file was changed. This report is the only file written.

**Validator at write time** (`python3 tools/curriculum/validate.py`, 2026-10-25 22:52):

```text
lexicon words: 866
course lessons: 57, track lessons: 240, typed exercises: 3871
OK
```

Last line: `OK`. The 240 includes the Advanced stage for 8 coaches; Grammarian and Reading & Listening still carry Starter instead. This is a **snapshot before Claude logs "wave B content done"**, and the tree moved during the check (232 → 240 lessons, 248 by 22:54).

## Method

Re-ran the Job 5 checklist (`opencode-docs-vs-code-2026-10-25.md`) against the current tree: counts, tab/screen names, TDD structure and rules, lexicon file shape, Speech Lab claims. Code and JSON are truth. No `xcodebuild` or simulator command was run.

## Fixed since Job 5

| Job 5 finding | Now |
| --- | --- |
| `lexicon.md:64` contradicted `:67` (722 vs 866) | `:64` says 18 level groups (722) “plus five opt-in field packs (below)”; `:67` owns 23 groups / 866. Data: 722 + 144 = 866. Consistent. |
| `lexicon.md` “one wrong-usage sentence” vs “one or two” | One rule now: one or two, field packs exactly one. Data confirms 0 field words with ≠1 `wrong`. |
| `product-specification.md:29` and `tdd.md:55` said tips are 2–4 sentences | Both now say 2–6. Longest tip is 5 (`c1-strategy`); `intro-01` now has a tip. |
| `tdd.md:26` Resources layout missed Lexicon/ and SpeechLab/ | Both listed. |
| `tdd.md:174` pointed at a nonexistent `OnDeviceRecognizer.swift` | Now `SpeechLabRecognizer.swift`, which exists. |
| `tdd.md:175` pointed at a nonexistent `Domain/VoiceMetrics.swift` | Now `Domain/SpeechLab.swift` + `Domain/SpeechLabVoice.swift`; `wordsPerMinute`/`fillerCount` live there. |
| `tdd.md:84–87` track JSON shape was wrong | Now `track.stages[].units[]` + separate `lessons[]`, matching the packs. |
| `tdd.md:114` `.almost` omitted the under-4-letter floor | Floor now stated; code matches. |
| `tdd.md:72` said `accepted[0]` is shown as the example | Now says the player shows `answer` and asks for `answer == accepted[0]`. |
| `tdd.md:147–156` lexicon example had wrong file shape and keys | Now `group{}` + top-level `words[]` with `wrong`, matching the files. |
| `ui-ux-design.md:7/28/34` old Speech Lab mode names; “Take the C1 test” on every level | Fixed; wording matches the shipped hub and `"Take the \(level) test"`. |
| `ui-screen-state-inventory.md:3/105` said conversation/interview/communication moved to Coaches | Fixed; SP-01 now lists the shipped eight entries. |
| `english-curriculum.md:11` “unreleased content is marked Coming later” | Fixed: “Only unlocked levels are open; later levels show their level test. Unfinished content is hidden.” |

## Still open

| file | location | claim as written | code reality | suggested fix |
| --- | --- | --- | --- | --- |
| `product-specification/product-specification.md` | line 18 | Speech Lab = “Introduction recording, Conversation, Interview, Communication practice, plus Phonetics, Articulation, Dictation, Voice” | The hub labels are Dictation, Pronunciation (grouping Phonetics + Articulation) and Speaking; Phonetics and Articulation are second-level, not peers of Dictation. | Use the hub labels, as `ui-ux-design.md:7` now does. |
| `product-specification/product-specification.md` | line 60 | “adds four sound-and-voice modes (Phonetics, Articulation, Dictation, Voice)” | Same as above: three hub entries, two of them renamed. | “adds Dictation, Pronunciation (Phonetics and Articulation) and Speaking”. |
| `product-specification/speech-lab.md` | line 15 | Home table lists “Phonetics · Articulation · Dictation · Voice” | Line 59 of the same file gives the correct hub: “Dictation · Pronunciation (Phonetics and Articulation together) · Speaking (the former Voice) · …”. The file contradicts itself and the app. | Replace the table cell with the line-59 labels. |
| `product-specification/product-specification.md` | line 30 | “**Exercises (8–15).**” | Every taught lesson is 12–14 except `rl-scan-facts` (Starter, 16) and `intro-01` (0, the guided introduction). | Either trim `rl-scan-facts` by one exercise or widen to “8–16”, keeping the `intro-01` exception. |
| `tdd/tdd.md` | line 72 | “…keep `answer` equal to `accepted[0]` for choice items (a test enforces it)” | No test reads `accepted`; 35 choice items break equality (e.g. `a1-greetings-recall-morning`: `answer` “Good morning.” vs `accepted[0]` “Good morning”; `a1-alphabet-recall-how-spell`: “How do you spell …?” vs “How do you spell”). Most are punctuation/ellipsis variants in recall items. | Add the equality check to `validate.py` (it already has give-away checks) and fix the 35 items, or delete “(a test enforces it)”. |
| `tdd/tdd.md` | Validation paragraph | “It runs before every content commit and inside a Swift test.” | No Swift test invokes `validate.py` or a Swift port; the only validator run is the manual script. | Add a hosted test that runs the checks, or drop “and inside a Swift test”. |
| `tdd/tdd.md` | Dictation section | “Used on every typing field, and hidden for listen-and-write exercises.” | `ExerciseActivityView.typedBody` always applies `.dictation($typed)` (`:283`), and `listenType` falls into `typedBody` (`:166`), so the mic button shows under “Type what you hear”. | Hide the button for `listenType` (and then the sentence is true), or correct the doc. |
| `product-specification/coach-tracks.md` | line 12 | “176 coach lessons” | 240 at this snapshot (10 tracks; 8 with Foundation/Intermediate/Advanced, 2 with Starter/Foundation/Intermediate). Advanced content is landing now. | Re-count after the wave-B log entry; the number is already behind. |
| `tdd/tdd.md` | line 55 vs data | `tip` 2–6 sentences | Correct now; no action. Listed here only because `c1-strategy` is the single tip at 5 and will fall outside if the range is narrowed again. | None. |

## Claims re-checked and correct

- Tab names and order (`AppDestination` = Today · Lexicon · Lesson · Speech Lab · Progress) match `product-specification.md:21`, `ui-ux-design.md:7` and `ui-screen-state-inventory.md`.
- Level rules (`product-specification.md:48–50`): lock per level, test for any locked level including C2 from A1, pass opens that level and every level below, lessons inside a level open in any order — matches `LevelGate` and `JumpTest`.
- `"Take the A2 test"`-style action: `CourseCatalogView.swift:38` renders `"Take the \(level) test"`.
- `ExerciseType` list in `tdd.md:70` matches the 9 enum cases, including `open`.
- The validator list in `tdd.md:93` matches `validate.py` (unique ids, required fields, accepted non-empty, accepted in options, wordBank tokens, order ≥3, match ≥3, audio or `audioText`, `sources`) and is now stricter — it also rejects printed answers, case/punctuation twins and repeated dictation.
- Lexicon numbers: 866 words, 23 files, 18 level groups × 40 (722), 5 field packs (144), one `wrong` per field word, `newPerDay` default 10, `sessionSize` 10.
- Hands-free claims (`speech-lab.md:52`): silence 2.0 s, max turn 90 s, two “Take your time” prompts, 39 questions in `speechlab-interview.json`, orb/“We heard”/Repeat/Skip/Done, summary never scores — all match `TurnTakingRules`, `HandsFreeInterviewController` and the view.
- Paths `Infrastructure/Speech/DictationRecognizer.swift` and `Features/Shared/DictationButton.swift` exist; the hub order matches `AppShell.SpeechLabContent`.

## Where this stopped

The Job 5 checklist is closed out item by item, plus the data checks the new content made worth repeating (`answer == accepted[0]`, exercise counts, track lesson counts). The two largest leftovers are naming drift in three Speech Lab doc lines and the TDD's two “enforced” claims that nothing enforces. A final pass after the wave-B log entry will be needed for every count in this report.
