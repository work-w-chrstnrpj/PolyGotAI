# Phase 9 verification — 2026-10-26

Implementation is under verification; owner acceptance remains open. All test data is synthetic and uses isolated stores. No live provider call, credential access in fixtures, migration or owner-data reset was performed.

- Hosted tests: **399 tests / 47 suites passed** in the integrated `verification/run-Lp4GN5/tests.xcresult` unit stage (the earlier isolated run passed 398). Includes Phase 8's current tests. A final focused run will verify the last completed-reply generation guard.
- Copy audit: `bash tools/native/copy-audit.sh` passed.
- iPhone UI: all four focused journeys passed across `phase9-ui-2.xcresult` (dark, largest text/rotation, Spelling) and `phase9-ui-voice.xcresult` (all Talk modes, Stop/Clear, voice-rate persistence). Earlier selector and fixed-percentage assumptions failed and were corrected.
- iPad (A16): **4/4 passed** in `application/.build/phase9-ipad.xcresult`, including all three Talk modes with fake replies in dark mode, accessibility audit, largest text and rotation, Spelling and voice persistence.
- Full `bash tools/native/verify.sh 7535AD2C-F655-4F05-8C36-FE5E0A614902`: **FAILED**; 399 hosted tests passed, **42/52 UI tests passed, 10 failed**, no skips. All four Phase 9 UI tests passed in this integrated run. Bundle: `application/.build/verification/run-Lp4GN5/tests.xcresult`; `summary.json` and `test.log` beside it.
- Final focused check: **13/13 Talk unit tests + 1/1 Talk/voice UI journey passed** (`application/.build/phase9-final-focused.xcresult`), including successful-completion and cancellation late events, all three displayed mode labels and rate persistence after relaunch.

Full-sweep failures (other lanes, handed to Claude in LOG-0069):
- `-[SpeechCoachAIUITests.BootstrapLaunchTests testA1PreviewResumesV2AndExplicitlyStartsV3]`
- `-[SpeechCoachAIUITests.BootstrapLaunchTests testLargerTextAndAccessibility]`
- `-[SpeechCoachAIUITests.BootstrapLaunchTests testOfflineRecallDraftRevealAndRatingRecovery]`
- `-[SpeechCoachAIUITests.BootstrapLaunchTests testPersonalVocabularySearchAndUnsavedTopicDetails]`
- `-[SpeechCoachAIUITests.BootstrapLaunchTests testRecallLargerTextThinkMode]`
- `-[SpeechCoachAIUITests.BootstrapLaunchTests testReviewOptionsPersistAndLimitOneSession]`
- `-[SpeechCoachAIUITests.Phase3LexiconTests testAWordAlreadyInTheLexiconIsNotAddedTwice]`
- `-[SpeechCoachAIUITests.Phase3LexiconTests testGroupSwitchesAndLargeText]`
- `-[SpeechCoachAIUITests.Phase3LexiconTests testLargestTextNavigationAndFieldPacks]`
- `-[SpeechCoachAIUITests.Round4AccessibilityTests testDarkModeDestinationsAndSpeechLabAccessibility]`

The Today audit flagged `today.badges.all`; the broad dark audit flagged `lexicon.settings`. Old vocabulary tests look for the removed v1 entry or pre-v3 pack layout. The saved A1 test failed to locate `today.lesson`; its cause remains unconfirmed. These failures were not suppressed or treated as a green phase gate.
- Screenshots reviewed: iPhone Talk and Voice in light/dark; six representative PNGs copied here (including iPad Voice). All captures remain in result bundles.

## Commands

```sh
xcodebuild test -project application/SpeechCoachAI.xcodeproj -scheme SpeechCoachAI \
  -destination 'platform=iOS Simulator,id=7535AD2C-F655-4F05-8C36-FE5E0A614902' \
  -derivedDataPath application/.build/CodexPhase9DerivedData \
  -only-testing:SpeechCoachAITests -parallel-testing-enabled NO \
  CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=-
```

UI runs replace `-only-testing` with `SpeechCoachAIUITests/Phase9LabTests`. DEBUG fixtures require an isolated `SC_SPEAKING_FIXTURE` UUID and `SC_TALK_FIXTURE=1`; no release bypass exists. Screenshots are retained in result-bundle attachments and the UI runner's `Library/Caches/Phase9Evidence` directory.

## Physical checks still required

Real English recognition with installed SpeechAnalyzer assets; permission denial; speaker playback without echo; headset route loss; phone interruption; chosen voice by ear; actual end-of-speech → first text → first audio latency. Simulator fixture timings are not device or provider latency evidence. Talk stays hidden without a saved key and unexpired workspace/model verification.

## Sources used for implementation

[Apple SpeechAnalyzer](https://developer.apple.com/documentation/Speech/SpeechAnalyzer), [Model Studio streaming](https://help.aliyun.com/en/model-studio/stream), [Model Studio error codes](https://help.aliyun.com/en/model-studio/error-code). The new transport uses SSE and maps 403 to quota exhaustion; no live request verified the provider contract.
