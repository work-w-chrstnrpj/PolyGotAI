# Physical iPad automated acceptance · 2026-10-22

Owner requested simulated/automated testing on their iPad after discussing closure of the 20 in-progress tickets. This run executes existing tests on the physical device; outcomes are not simulated. No manual-owner, live-provider or learning-quality pass is inferred.

## Environment and scope

- Physical iPad (A16), iPadOS 27.0.1 (24A446), USB, paired, Developer Mode enabled.
- Existing signed development setup, same `com.personal.SpeechCoachAI` bundle identifier and development team. No signing-account changes, uninstall, reset, Git initialization or publishing.
- Exact pre-build source snapshot retained in ignored `application/.build/ipad-acceptance-2026-10-22/source-snapshot.json`. Full log/result are local under the same run root.
- All selected UI cases use a UUID-named `SC_SPEAKING_FIXTURE` learner store, separate from the normal `Learner` store. Hosted tests use temporary stores and isolated synthetic Keychain service names. No real provider key is read or submitted by these cases.
- Fixture ASR/coaching are synthetic in-process responses. The lesson-speaking return case exercises one short physical microphone capture; it is not exported/uploaded. The fixture history test saves/deletes/restores only synthetic data in its isolated store.

## Current execution state

Owner unlocked the iPad and Xcode resumed automatically. Signed build/install and test launch proceeded. Runtime checks completed on the physical device; the earlier lock wait is retained in the raw log. No unlock/passcode was automated.

## Selected checks

| Check | Scope | Result |
| --- | --- | --- |
| SpeechCoachAITests | Full hosted domain/persistence/Keychain suite on physical iPad | PASS — 95 tests |
| testConnectedLessonDraftResumeQuietCompletionAndVocabularyReview | Lesson draft restart, core quiet completion, enrollment/review | PASS |
| testDailyPrimaryChoiceAndConfidenceRecovery | Today/Progress action, override, confidence save/clear/restart | PASS after keyboard-ready retest; final Progress contrast also PASS |
| testFocusedLessonAndLibraryAccessibility | Lesson/library automated contrast, hit-region and description audits | PASS |
| testIntegratedSpeakingLoopFixtureAndHistory | Synthetic provider path, rotation, save/history/delete/restore | PASS |
| testLessonSpeakingSelfReviewReturnsWithoutTypingOrRetention | Short recording/self-review returns to exact lesson without retaining audio | PASS |
| testOfflineRecallDraftRevealAndRatingRecovery | Hidden draft/reveal restart, explicit ratings, method separation | PASS |
| testRecallLargerTextThinkMode | Review at accessibility text size, Think mode | PASS |

## Separate unexecuted acceptance

This selection does not demonstrate live-provider quality/cost/quota/retention, actual speech intelligibility, call/headphone routing, full 120-second capture behavior, permission denial/revocation, device lock, manual VoiceOver/Reduce Motion, iOS 17 runtime, all missing specialist/foundation content, or delayed learning effectiveness. Existing scoped evidence stays valid where applicable. Ticket closure requires its complete acceptance and prerequisites; this run supplies physical evidence for the cases actually executed.

## First-run result and targeted retest

`device-v1.xcresult`: **101 passed, 1 failed**, 102 logical tests. [Raw summary](device-v1-summary.json). The 95 hosted tests and six UI cases passed. The Today/Progress case stopped at opening its newly created topic; the failure hierarchy still showed the New Topic sheet, `Kitchen` in the focused title field and the Create button. No app save-error message was shown. This does not establish a storage failure or a completed Today/Progress run.

The test helper now commits keyboard entry with Return, waits for Create to be enabled and explicitly waits for the sheet to dismiss. It does not repeat Create taps or change the app’s creation behavior. Only `SpeechCoachAIUITests/BootstrapLaunchTests.swift` changed; the original is retained in the ignored run root. `daily-retest-v2.xcresult` targets only the failed Today/Progress case. Earlier failure remains recorded and is not counted as a pass.

## Final result

- **95 hosted tests and all seven selected UI journeys passed on the physical iPad**, across the first run and targeted retests. This is not a single all-green first run: v1 was 101/102; its one setup failure remains recorded above.
- `daily-retest-v2.xcresult`: PASS 1/1, completes Today/Progress override, confidence save/clear/restart and entry into review. [Summary](daily-retest-v2-summary.json).
- Visual review then exposed low contrast in the blank confidence field’s placeholder on this device’s dark appearance. `Features/Progress/ProgressOverview.swift` now explicitly applies existing `Kit.secondary` to that prompt. No persistence, recommendation or reward rule changed.
- `progress-contrast-v3.xcresult`: PASS 1/1 on the new signed build. Re-executes the full Today/Progress journey, commits keyboard entry, and adds a Progress viewport contrast audit after clearing the note. [Summary](progress-contrast-v3-summary.json). Final [dark Progress screenshot](screenshots/daily-progress-final.png) was visually inspected, along with [Today](screenshots/daily-review-primary-final.png) and [lesson speaking return](screenshots/recovery-lesson-speaking-return.png).
- [Source checkpoints](source-checkpoints.json) identify the two changed files after v1: test-helper/readiness/contrast assertion and the single placeholder-color repair. Other product/domain/persistence sources remain unchanged. [Final signed build metadata](build-metadata-final.json) supplies the exact executable hash; version remains 0.1.0/build 1.
- The latest app was installed in place by Xcode. A final normal launch of `com.personal.SpeechCoachAI` succeeded with no fixture variable or test arguments. No uninstall or learner-data reset occurred. Regular learner storage was not inspected or exported.

## Reproduction

The first run used `xcodebuild test`, project `application/SpeechCoachAI.xcodeproj`, scheme `SpeechCoachAI`, destination `platform=iOS,id=00008120-0014354C112B601E`, derived data `application/.build/IPadAcceptanceDerivedData`, parallel testing off, hosted target plus the seven named UI methods above. Signing overrides reused `CODE_SIGN_STYLE=Automatic DEVELOPMENT_TEAM=LMHJKZ2N43 CODE_SIGN_IDENTITY='Apple Development' CODE_SIGNING_ALLOWED=YES`. Xcode selection was per-command `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`. No provisioning/account update flag was used. Each retest selected only `SpeechCoachAIUITests/BootstrapLaunchTests/testDailyPrimaryChoiceAndConfidenceRecovery` with a fresh result path. Raw logs/bundles remain ignored/local. No retry result erases a prior failure.

These results add physical-device evidence for the executed requirements. Full ticket prerequisites, live-provider proof, missing content and original acceptance remain separately open; no ticket was marked done solely from this run.
