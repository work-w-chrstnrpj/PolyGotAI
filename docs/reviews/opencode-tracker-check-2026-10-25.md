# Job 12 — tracker check against the code

Read-only. No product file, tracker row or doc was changed. This report is the only file written.

**Validator at write time** (`python3 tools/curriculum/validate.py`, 2026-10-25 22:47):

```text
lexicon words: 866
course lessons: 57, track lessons: 200, typed exercises: 3390
OK
```

Last line: `OK`. Content was landing throughout this check: track lessons read 176 → 184 → 200 while this report was written, and 248 at 22:54, so every **count** row in the tracker is a moving target. Count rows are judged against the snapshot above only.

## Method

For every ✅ row in `progress.md` and the status table in `development-plan.md`, the claim was matched to a file, symbol, JSON count or test name. Runtime claims ("tests pass", "simulator-checked", "verified") cannot be checked without `xcodebuild`, which this lane is forbidden to run; those rows are listed as unverifiable rather than wrong. Static test counts come from declarations only.

## Rows confirmed

| doc | row | claim (short) | proving file / symbol |
| --- | --- | --- | --- |
| progress.md | 0.4 | folder-synchronized groups | `project.pbxproj`: 3 × `PBXFileSystemSynchronizedRootGroup`; 57 `.wav` in `Resources/Curriculum/` |
| progress.md | 0.6 | Today = one card + review row | `AppShell.TodayContent`, `dueCount` row at `:229–231` |
| progress.md | 0.8 / 0.9 | tab names and one-line taglines | `AppDestination` = Today · Lexicon · Lesson · Speech Lab · Progress; `lineLimit(1)` at `AppShell.swift:263, 290, 357` |
| progress.md | 1.1 | `AnswerChecker` + tests | `Domain/AnswerChecker.swift`, `AnswerCheckerTests.swift` |
| progress.md | 1.2 | catalog fields + loader checks | `exercise`, `tip`, `trackId`, `unitId`, `sources` present in `CurriculumCatalog.json` + loader |
| progress.md | 1.3 | `ExerciseSpec` / `ExerciseSession` + tests | `Domain/Exercise.swift`, `ExerciseSession.swift`, `ExerciseTests.swift` |
| progress.md | 1.5 | `validate.py` clean | ran OK (above) |
| progress.md | 1.6 | 12 A1 lessons, 168 typed | `CurriculumCatalog.json`: 13 A1 lessons; 12 topic lessons hold 168 typed exercises, `intro-01` holds 0 |
| progress.md | 1.7 / 1.9 | exercise views; UI test | `Features/Learn/Exercises/`; `BootstrapLaunchTests.swift:83 testTypedExercisesGiveInstantFeedbackAndAccuracy` |
| progress.md | 1.10 | `DictationRecognizer` + `DictationButton` | `Infrastructure/Speech/DictationRecognizer.swift`, `Features/Shared/DictationButton.swift` |
| progress.md | 1.11 | mic on existing fields | `.dictation(` in 13 feature files (see stale rows below for the "new fields" half) |
| progress.md | 2.1 | `TrackCatalog` + tests | `Domain/TrackCatalog.swift`, `CoachTrackPresentationTests.swift`, `TrackContentTests.swift` |
| progress.md | 2.2 | Grammarian Starter 8 lessons / 104 activities | `track-grammarian.json`: Starter 8 / 104 |
| progress.md | 2.4 / 2.7 | `LevelGate`, any-level jump test | `LevelGateTests.swift` = 20 `@Test`; `LevelGate.canTakeJumpTest(to:)` |
| progress.md | 2.9 | every locked level has a test | `JumpTest.isAvailable` needs 3 topics / 10 own items / pool ≥ 20–30; typed per level A2 143, B1 130, B2 130, C1 104, C2 65 |
| progress.md | 3.1, 3.3, 3.6, 3.8 | lexicon loader/validator, stages, first 3×40 groups, Today card | `LexiconBankLoader`, `LexiconSuggestion`; 18 level groups × 40 = 722 words, 5 field packs = 144; `AppShell` `DailyLexiconCard` |
| progress.md | L2.2 | level capsule + "Next" tag | `LexiconHome.swift:100` ("Next"), `:124` `LexiconSuggestion.nextGroup` |
| progress.md | Phase 4 rows | per-pack Foundation/Starter counts | all match: 104, 111, 107, 107, 115, 106, 117, 116, 112, 113 |
| progress.md | 5.1 / 5.2 / 5.3 | recognizer + metrics + diff; content; Lab order | `SpeechLabRecognizer.swift`, `Domain/SpeechLab.swift`, `SpeechLabVoice.swift`; `validate_speechlab.py` → `Speech Lab content valid`; `AppShell.SpeechLabContent` order = Dictation, Pronunciation, Speaking, Interview, Conversation, Communication, Record an introduction, Saved practice |
| progress.md | 5b | 39-question bank | `Resources/SpeechLab/speechlab-interview.json` → 39 `items` |

## Rows that cannot be confirmed by reading code

| file | id | field | problem | suggested fix |
| --- | --- | --- | --- | --- |
| `docs/development-plan/progress.md` | line 11, line 14, line 20 | test counts | "390 unit tests" and "377 unit tests" are both below the current static count (436 `@Test` declarations, 59 UI `func test…`). The counts are stale even before a run, and "pass" cannot be checked here. | After the next `verify.sh`, replace all three with one current figure (or drop exact numbers from the tracker and keep them in the session log). |
| `progress.md` | line 15 | unit-test count | "14 unit tests" for the interview core; the tree has `HandsFreeInterviewTests` 16 + `HandsFreeInterviewControllerTests` 3 = 19. | 19 (or the run's reported figure). |
| `progress.md` | line 16 | unit-test count | "10 unit tests" for `LabFeedbackClient`; `LabFeedbackTests.swift` has 18. | 18. |
| `progress.md` | line 20 | reports count | "OpenCode has filed six reports"; `docs/reviews/` holds 13 now (this one is 14). | 13 before this report. |
| `progress.md` | line 56 | 6a "switch-on" | "R4-C4 ✅ 6a core (recording → transcript → feedback, stored results, owner-local switch-on)": the client, `transcribe`, `StoredLabFeedback` and tests exist, but no learner-facing switch exists — `LabFeedbackClient` is gated by a bundled `ProviderVerification` (`:132`), which line 16 correctly says is not bundled. | Say "pipeline + fake transport ✅; switch-on blocked on the provider verification file", or drop "switch-on". |
| `progress.md` | line 41 | Phase 5 gate | "Evidence folder empty" is no longer true: `docs/development-plan/phases/phase-5/evidence/` holds 4 screenshots (18:47). | Remove that item; keep "recognition on a device" and "iPad check". |
| `progress.md` | line 43 | 6a missing list | "…the 'AI feedback' button and result card, the recording → transcript step" — `AIFeedbackSection.swift` and `LabFeedbackClient.transcribe` now exist, but the section is only shown from the DEBUG fixture (`Round4FixtureView.swift:44`), not a learner screen. | Narrow to "AI feedback is not wired into a learner screen" (the transcript step is built). |
| `progress.md` | line 11, 14, 77, 79, 84, 110, 113, 128, 129 | runtime/simulator claims | "Phase 2 UI tests pass", "pass on iPhone 18 Pro Max", "6 targeted UI tests pass", "simulator-verified", "4 of 5 UI tests pass", "failed test + retry + relaunch lock verified", "simulator-checked". | Leave to Claude's VERIFY run; this lane cannot run `xcodebuild` or a simulator. |
| `progress.md` | line 37 | device item | "(c) Dictation on the owner's device (in test now)" and line 10 "owner to play an A1 lesson" are owner/device actions, not code facts. | No change; listed so the row is not read as code-verified. |

## Stale or contradictory rows

| file | id | field | problem | suggested fix |
| --- | --- | --- | --- | --- |
| `progress.md` | line 13 | Phase 4 status | "✅ all 10 coaches (80 lessons) and all 44 A2–C2 lessons written and proofread once by OpenCode" while line 40 of the same file says 🔄 and "the **Advanced stage is not written**", and the packs now hold 200 lessons (snapshot). The ✅ row was the Foundation-only state and now overstates. | Mark row 4 🔄 like line 40, or scope it: "Foundation stage (80 lessons) done; Intermediate/Advanced tracked in the completion audit". |
| `progress.md` | line 37 | open item (b) | "The microphone button is missing on about eight free-text fields: Progress note, online review text, resource notes and title, vocabulary discovery fields, custom topic name, subtopic, word and meaning." Every one of those now has `.dictation(`: `ProgressOverview.swift:77`, `OnlineReviewSection.swift`, `ResourceEditorView.swift:28,78`, `CustomTopicViews.swift:89,90,166,168`, `VocabularyDiscoveryView.swift:90`. The same row's Built column already says "mic buttons added, Codex LOG-0048". | Delete item (b); keep (a) and (c). |
| `progress.md` | line 102 | row 1.11 status | Still "⏳ new exercise fields (Codex)", but `ExerciseActivityView.swift:283` has `field.dictation($typed)` and LOG-0048 reports the work done. | Mark 1.11 ✅ (both halves). |
| `progress.md` | line 40; `development-plan.md` | line 50 | lesson count | "176 lessons in all" / "176 coach lessons" — the validator read 176, then 184, then 200 during this session. Not wrong at the time of writing; now behind the files. | Re-read at the end of wave B and update both rows once. |
| `progress.md` | line 37 | `intro-01` note | "(a) `intro-01` 'Introduce yourself' … it now has a coach tip." Confirmed: `tip` present, 0 typed exercises. | None. |
| `progress.md` | line 129 | 3.8 | "Daily Lexicon card on Today ✅ simulator-checked": the card exists (`DailyLexiconCard`), but the visual claim is a simulator result. | None on the code side; keep the simulator claim with the run that proved it. |

## Where this stopped

All ✅ rows in `progress.md` and `development-plan.md` were checked against the tree once. Confirmed rows have a named file, symbol or counted JSON. The remaining open risk is not code but the tracker itself: two test-count figures (390/377) and two lesson counts (176/80) describe older trees, and two completion-audit items (mic buttons, evidence folder) are already closed in the files. Runtime pass claims were not run, by rule.
