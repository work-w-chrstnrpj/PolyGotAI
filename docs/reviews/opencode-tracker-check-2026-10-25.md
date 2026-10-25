# Job 12 — tracker check against the code

Read-only. No product file, tracker row or doc was changed. This report is the only file this lane wrote.

**Validator at write time** (`python3 tools/curriculum/validate.py`, 2026-10-25 23:18):

```text
lexicon words: 866
course lessons: 57, track lessons: 256, typed exercises: 4074
OK
```

Last line: `OK`. This run is **after** the wave-B log entries (LOG-0052 Advanced, LOG-0053 6b/6c/6d cores), so the 256/4074 figures are the settled wave-B tree, not a mid-write snapshot. Static test count: 448 `@Test` in 44 files (61 UI `func test…`), against the tracker's 390/377.

## Method

For every ✅ row in `progress.md` and the status table in `development-plan.md`, the claim was matched to a file, symbol, JSON count or test name. Runtime claims ("tests pass", "simulator-checked", "verified") cannot be checked without `xcodebuild`, which this lane is forbidden to run; those rows are listed as unverifiable rather than wrong. Static test counts come from declarations only.

## Rows confirmed

| doc | row | claim (short) | proving file / symbol |
| --- | --- | --- | --- |
| progress.md | 0.4 | folder-synchronized groups | `project.pbxproj`: 3 × `PBXFileSystemSynchronizedRootGroup`; 57 `.wav` in `Resources/Curriculum/` |
| progress.md | 0.6 | Today = one card + review row | `AppShell.TodayContent`, `dueCount` row at `:229–231` |
| progress.md | 0.8 / 0.9 | tab names and one-line taglines | `AppDestination` = Today · Lexicon · Lesson · Speech Lab · Progress; `lineLimit(1)` at `AppShell.swift:263, 290, 357` |
| progress.md | 1.1 | `AnswerChecker` + tests | `Domain/AnswerChecker.swift`, `AnswerCheckerTests.swift` (12) |
| progress.md | 1.2 | catalog fields + loader checks | `exercise`, `tip`, `trackId`, `unitId`, `sources` present in `CurriculumCatalog.json` + loader |
| progress.md | 1.3 | `ExerciseSpec` / `ExerciseSession` + tests | `Domain/Exercise.swift`, `ExerciseSession.swift`, `ExerciseTests.swift` (18) |
| progress.md | 1.5 | `validate.py` clean | ran OK (above) |
| progress.md | 1.6 | 12 A1 lessons, 168 typed | `CurriculumCatalog.json`: 13 A1 lessons; 12 topic lessons hold 168 typed exercises, `intro-01` holds 0 (22 activities, guided) |
| progress.md | 1.7 / 1.9 | exercise views; UI test | `Features/Learn/Exercises/`; `BootstrapLaunchTests.swift:83 testTypedExercisesGiveInstantFeedbackAndAccuracy` |
| progress.md | 1.10 | `DictationRecognizer` + `DictationButton` | `Infrastructure/Speech/DictationRecognizer.swift`, `Features/Shared/DictationButton.swift` |
| progress.md | 1.11 | mic on existing fields | `.dictation(` in 14 feature files; every field named in the old gap has it (see stale rows) |
| progress.md | 2.1 | `TrackCatalog` + tests | `Domain/TrackCatalog.swift`, `CoachTrackPresentationTests.swift`, `TrackContentTests.swift` (5) |
| progress.md | 2.2 | Grammarian Starter 8 lessons / 104 activities | `track-grammarian.json`: Starter 8 lessons / 104 activities |
| progress.md | 2.4 / 2.7 | `LevelGate`, any-level jump test | `LevelGateTests.swift` = 20 `@Test`; `LevelGate.canTakeJumpTest(to:)` |
| progress.md | 2.9 | every locked level has a test | `JumpTest.isAvailable` needs 3 topics / 10 own items / pool ≥ 20–30; typed per level A2 143, B1 130, B2 130, C1 104, C2 65 |
| progress.md | 3.1, 3.3, 3.6, 3.8 | lexicon loader/validator, stages, first 3×40 groups, Today card | `LexiconBankLoader`, `LexiconSuggestion`; 18 level groups × 40 = 722 words, 5 field packs = 144; `AppShell` `DailyLexiconCard` |
| progress.md | L2.2 | level capsule + "Next" tag | `LexiconHome.swift:100` ("Next"), `:124` `LexiconSuggestion.nextGroup` |
| progress.md | Phase 4 (a) | every coach has Foundation + Intermediate, two also Starter | 10 packs: 8 lessons per stage; grammarian and reading-listening 8 Starter + 8 Foundation + 8 Intermediate + 8 Advanced; the other 8 packs 8 + 8 + 8 |
| progress.md | line 56, wave B | Advanced stage: 80 new lessons, 256 total | 256 − 176 = 80; each pack now has 8 Advanced lessons (`validate.py` 256) |
| progress.md | line 56, wave B | 6b/6c/6d cores | `LabFeedbackRequests.swift` (`LabFeedbackHistorySummary`, per-mode rubric request, coach "Your turn" review), `LabAIExtras.swift` (`InterviewFollowUpRequest`/`AIFollowUp`, `LexiconGenerationRequest`/`GeneratedLexicon`, `followUp`, `generateLexicon`, `saveGeneratedLexicon`), `StoredLabFeedback.swift`; tests `LabAIExtrasTests` (12), `LabFeedbackTests` (18) |
| progress.md | 6a | client, consent, stored results, Settings key | `SpeakingProviderClient.swift`, `LabFeedbackClient.transcribe`, `ProviderSettingsView.swift`, `AIFeedbackPrivacyView`, `AIFeedbackSection.swift`; key tests in `ProviderCredentialTests.swift` (3) |
| progress.md | 5.1 / 5.2 / 5.3 | recognizer + metrics + diff; content; Lab order | `SpeechLabRecognizer.swift`, `Domain/SpeechLab.swift`, `SpeechLabVoice.swift`; `validate_speechlab.py` → `Speech Lab content valid`; `AppShell.SpeechLabContent` order = Dictation, Pronunciation, Speaking, Interview, Conversation, Communication, Record an introduction, Saved practice |
| progress.md | 5b | 39-question bank | `Resources/SpeechLab/speechlab-interview.json` → 39 `items` |

## Rows that cannot be confirmed by reading code

| file | id | field | problem | suggested fix |
| --- | --- | --- | --- | --- |
| `docs/development-plan/progress.md` | line 11, 14, 20, 114 | test counts | "390 unit tests" (lines 11, 20) and "377 unit tests" (lines 14, 114) are below the static count (448 `@Test` in 44 files). "…tests pass" cannot be checked here. | After the next `verify.sh`, replace all four with one current figure, or drop exact numbers and keep them in the session log. |
| `progress.md` | line 15 | unit-test count | "14 unit tests" for the interview core; the tree has `HandsFreeInterviewTests` 16 + `HandsFreeInterviewControllerTests` 3 = 19. | 19 (or the run's reported figure). |
| `progress.md` | line 16 | unit-test count | "10 unit tests" for `LabFeedbackClient`; `LabFeedbackTests.swift` has 18 (plus 12 in `LabAIExtrasTests` for the 6b–6d core). | 18 (or 30 including extras). |
| `progress.md` | line 20 | reports count | "OpenCode has filed six reports"; `docs/reviews/` holds 17 now (this one included). | 17. |
| `progress.md` | line 56 | 6a "switch-on" | "R4-C4 ✅ 6a core (… owner-local switch-on)": the client, `transcribe`, `StoredLabFeedback` and Settings key exist, but `AIFeedbackSection` is only shown from the DEBUG fixture (`Round4FixtureView.swift:44`) and `ProviderVerification.bundled` returns `nil` because no `ProviderVerification.json` is in `Resources/`. There is no learner-facing switch. | Say "pipeline + fake transport ✅; learner screen, verification file and live check open". |
| `progress.md` | line 11, 14, 20, 77, 79, 110, 113, 128, 129 | runtime/simulator claims | "Phase 2 UI tests pass", "pass on iPhone 18 Pro Max", "6 targeted UI tests pass", "simulator-verified", "4 of 5 UI tests pass", "failed test + retry + relaunch lock verified", "simulator-checked". | Leave to Claude's VERIFY run; this lane cannot run `xcodebuild` or a simulator. |
| `progress.md` | line 37 | device item | "(c) Dictation on the owner's device (in test now)" and line 10 "owner to play an A1 lesson" are owner/device actions, not code facts. | No change; listed so the row is not read as code-verified. |

## Stale or contradictory rows

| file | id | field | problem | suggested fix |
| --- | --- | --- | --- | --- |
| `progress.md` | line 13 | Phase 4 status | "✅ all 10 coaches (80 lessons) and all 44 A2–C2 lessons written…" while line 40 and `coach-tracks.md:12` now say 256 coach lessons. 80 was the Foundation-only count. | "all 10 coaches (256 lessons across four stages)…" or point at the completion audit. |
| `progress.md` | line 40, item (a) | lesson count | One sentence says both "the packs hold 176 lessons in all" and "(256 coach lessons in all)". 176 was the Intermediate checkpoint. | Delete the 176 clause; keep 256 as the count. |
| `progress.md` | line 41 | Phase 5 gate | "Evidence folder empty" is false: `phases/phase-5/evidence/` holds 7 screenshots (4 base + 3 under `round-4/`). | Remove that item; keep "recognition on a device" and "iPad check". |
| `progress.md` | line 42 | Phase 5b audit row | "core and screen built (Codex LOG-0045)" but the overall row (line 15) still says "Interview screen is Codex's X5". One of the two is out of date. | Confirm the screen exists and mark both rows the same way. |
| `progress.md` | line 43 | 6a missing list | Lists as missing what is built: Settings key + workspace test (`ProviderSettingsView`), cost/privacy sheet (`AIFeedbackPrivacyView`), transcript step (`LabFeedbackClient.transcribe`), result card (`AIFeedbackSection`). The section is only reachable from the DEBUG fixture, and the verification file is not bundled. | Narrow to: "wire `AIFeedbackSection` into a learner screen; bundle the verification file; run one approved live check." |
| `progress.md` | line 44–45 | 6b / 6c audit rows | "⏳ not started" for 6b and 6c, but line 56 and the log say the cores are ✅ (`LabFeedbackRequests`, `LabAIExtras.followUp`, 12 + 18 tests). | "🔄 core done; result cards/history UI and voice loop open." |
| `progress.md` | line 46 | 6d audit row | "⏳ not started", but 6d coach review and Specialized Lexicon generation exist in `LabFeedbackClient`/`LabAIExtras` with saving and tests. | "🔄 core done; review and generation screens open (R4-X5)." |
| `docs/development-plan/development-plan.md` | lines 53–56 | status table | 6a–6d still say "⏳ later" while `progress.md:56` marks the 6a–6d cores ✅ (LOG-0052/0053). | Update the four status cells to "🔄 core built (fake transport); screens pending". |
| `progress.md` | line 37, item (b) | open item | "The microphone button is missing on about eight free-text fields: Progress note, online review text, resource notes and title, vocabulary discovery fields, custom topic name, subtopic, word and meaning." All now have `.dictation(`: `ProgressOverview.swift:77`, `ResourceEditorView.swift:28,78`, `CustomTopicViews.swift:89,90,166,168,187,192,356,357`; the Built column already says "mic buttons added, Codex LOG-0048". | Delete item (b); keep (a) and (c). |
| `progress.md` | line 102 | row 1.11 status | Still "⏳ new exercise fields (Codex)", but `ExerciseActivityView.swift:283` applies `field.dictation($typed)` to the typed exercises and LOG-0048 reports the work done. | Mark 1.11 ✅ (both halves). |
| `progress.md` | line 40, item (c) | give-away findings | "OpenCode's give-away audit findings are not yet acted on": `validate.py` now enforces the printed-answer, case/punctuation-twin and repeated-dictation checks (0 left in the data). The longest-option and single-answer findings are still open. | "Validator enforces the verbatim/twin/dictation give-aways; longest-option bias and one-answer fillBlanks still open." |
| `progress.md` | line 40, item (d) | phase brief | "No phase brief exists for Phase 4" while `docs/development-plan/phases/round-4/README.md` and `codex-handoff.md` cover the round. | Point at the round-4 brief, or keep if a Phase 4 brief is still wanted. |

## Where this stopped

All ✅ rows in `progress.md` and `development-plan.md` were checked against the 256-lesson tree once. Confirmed rows have a named file, symbol or counted JSON. The remaining risk is not code but the tracker: four test-count figures (390/377), two lesson counts (80/176) and one evidence claim are older trees, two completion-audit rows (6b/6c/6d) contradict the round-4 table, and three open items (mic buttons, exercise-field mic, evidence folder) are already closed in the files. Wave-B rows are now confirmed by LOG-0052/0053 and by the files above. Runtime pass claims were not run, by rule.
