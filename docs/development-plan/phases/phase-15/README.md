# Phase 15 — Lab Videos and Timed tests

**Status:** built 2026-10-26 by Claude (owner: "Implement phase 15"; the whole phase, not split with Codex). Waiting for the owner's play-test with a real key. Not committed.
**Plan:** [owner feedback round 2, points 6 and 7](../../owner-feedback-plan-2026-10-26b.md). **Spec:** [speech-lab.md → Videos and Timed tests](../../../product-specification/speech-lab.md#videos-and-timed-tests-phase-15-2026-10-26).

## What was built

| Part | Files |
| --- | --- |
| Video list (26 links checked with oEmbed), watched state, test fingerprints and themes | `Domain/LabVideos.swift` |
| Test kinds, themes, clock, answers, fingerprints | `Domain/LabTimedTest.swift` |
| Prompts, strict reply checks, option shuffle, one retry | `Infrastructure/Providers/LabTimedTests.swift` |
| `writing` feedback mode and `timedWriting` request | `LabFeedbackClient.swift`, `LabFeedbackRequests.swift`, `AIFeedbackSection.swift` (history title) |
| Storage: optional `SpeechLabState.extras` | `Domain/SpeechLab.swift`, `LearnerRepository+Lab.swift` |
| Screens | `Features/SpeechLab/{LabVideosView,LabTimedTestsView}.swift`; two links in the Lab region of `AppShell.swift` |
| Link check | `tools/curriculum/check_lab_videos.py` |
| Tests | `SpeechCoachAITests/LabTimedTestsTests.swift` (17), `SpeechCoachAIUITests/Phase15LabTests.swift` (4) |

`LabFeedbackService.send(_:stage:timeout:)` in `LabAIExtras.swift` changed from `private` to internal so the timed tests share the timeout logic. Without a key, Start uses the Phase 12 `aiSetupSheet`, and the service is rebuilt when the sheet closes.

## Verification (iPhone 17 simulator, `application/.build/Phase15DerivedData`)

- All 17 new unit tests pass, and so do the existing Lab feedback, AI extras and persistence suites.
- All 4 Phase 15 UI tests pass with synthetic replies (`SC_TIMED_FIXTURE=1`): marking a video Watched survives leaving the screen; Start without a key opens setup; writing is sent automatically when a 12-second clock ends and feedback appears; reading and analogies are scored.
- Full hosted suite and Speech Lab UI tests: 442 passed, 2 failed. Both failures are `LexiconTests` expectations that the in-progress Phase 14 word bank changes (55 groups); they are not in this lane.
- `check_lab_videos.py`: 26 of 26 videos match their title and channel.

## Not verified

- Real Qwen replies: whether `qwen-flash` keeps to the formats, and how often the one retry is needed. No live call was made.
- Opening the YouTube app on a device, iPad layout, VoiceOver traversal, and a full `verify.sh` run.
