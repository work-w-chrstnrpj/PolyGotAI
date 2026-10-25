# SC-D007 native implementation evidence — 2026-10-23

Owner-approved personal-use implementation only. [Implementation scope and remaining acceptance](../../../development-plan/sc-d007-implementation-2026-10-23.md). Qualified review, physical iPhone/iPad acceptance, original expansion/pilot prerequisites and real learner/retention/transfer results remain open. No live provider call, account action, learner-store reset, migration or Git initialization occurred.

## Final scoped results

- iPad (A16), iOS 27.0 simulator: **151 hosted tests passed**. The existing introduction speaking-return UI passed in the same run. The new v2/v3/optional-speaking UI passed on focused retest after correcting its query to select the visible sheet's button.
- iPhone 18 Pro, iOS 27.0 simulator: **37 focused hosted tests and both UI journeys passed** in the final run (39 total, zero failures).
- The new journey relaunches an isolated synthetic v2 home draft, resumes exact v2 tasks, explicitly starts v3, opens a separate day-7 practice with text retention off, records/self-reviews through the exact optional prompt, returns without completing the source course, and reopens the original unchanged v2 draft.
- Domain tests cover exact old tasks/first responses/drafts, real repository close/reopen, current versus historical completion, missing/ambiguous archives, future archived optional practice, all optional route types, no-text privacy, retained first-response/retry distinction and exact recording provenance.
- Ten Python candidate boundary tests and the current-production standalone Swift loader/session harness also passed. All 28 scope-approved candidate artifacts remain unchanged. Exact INTRO v3, A2–C2, twelve original v2 lesson objects, all 57 audio declarations/files and shared sense identities are preserved.

[Machine-readable results and source hashes](verification.json) identify exact artifact names, devices, versions and failures. Parameterized cases can make a device configuration's run count larger than the top-level unique-test count; counts above refer to the tests reported by Swift Testing and the selected UI cases.

## Initial failures and corrections

| Artifact under `application/.build/` | Actual result | Correction / retest |
| --- | --- | --- |
| `sc-d007-first.xcresult`, `.log` | Build database locked; no tests ran | Confirmed no active Xcode process and used isolated `SC-D007DerivedData`; no process/data reset |
| `sc-d007-hosted.xcresult` | 146 passed, 2 failed (148 unique hosted tests) | Small-course tests now resolve their exact approved v2 packs through the archive API; original v2 assertions remain. Removed a duplicate guard that masked the existing objectiveMismatch error |
| `sc-d007-integrated.xcresult` | 149 passed, 2 UI failures (151 total) | Extra version toolbar item hid normal controls in system overflow. Version controls moved into the existing activity list; normal activity navigation restored |
| `sc-d007-tablet.xcresult` | 151 hosted + original speaking UI passed; new UI query failed (152 passed, 1 failed of 153) | iPad accessibility tree retained both source/sheet buttons. New helper selects a visible frontmost match; no product behavior was weakened |
| `sc-d007-phone-final.xcresult` | 39 passed, 0 failed | Final selected hosted classes and both UI journeys |
| `sc-d007-tablet-retest.xcresult` | 1 passed, 0 failed | New full v2/v3/optional-speaking journey on iPad |

The initial results have not been overwritten. Deliberately corrupt-store fixtures log expected CoreData failures during recovery tests; their assertions passed. Existing AVAudioSession activation warnings remain distinct from test failures and from actual device acceptance.

## Commands

All commands were run from the repository root with `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`, ad-hoc simulator signing, the SpeechCoachAI scheme and serial test execution. No simultaneous Xcode runs were started after the initial lock was identified.

```sh
# Full hosted tablet coverage plus scoped UI; contains the retained first UI-query failure.
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild test -project application/SpeechCoachAI.xcodeproj -scheme SpeechCoachAI -destination 'platform=iOS Simulator,id=709D6F70-328D-4458-8F8A-B2C47A945A80' -derivedDataPath application/.build/SC-D007DerivedData -resultBundlePath application/.build/sc-d007-tablet.xcresult -parallel-testing-enabled NO -only-testing:SpeechCoachAITests -only-testing:SpeechCoachAIUITests/BootstrapLaunchTests/testA1PreviewResumesV2AndExplicitlyStartsV3 -only-testing:SpeechCoachAIUITests/BootstrapLaunchTests/testLessonSpeakingSelfReviewReturnsWithoutTypingOrRetention CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=-

# Final phone, all passing.
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild test -project application/SpeechCoachAI.xcodeproj -scheme SpeechCoachAI -destination 'platform=iOS Simulator,id=7535AD2C-F655-4F05-8C36-FE5E0A614902' -derivedDataPath application/.build/SC-D007DerivedData -resultBundlePath application/.build/sc-d007-phone-final.xcresult -parallel-testing-enabled NO -only-testing:SpeechCoachAITests/A1CurriculumDeliveryTests -only-testing:SpeechCoachAITests/CurriculumCatalogTests -only-testing:SpeechCoachAITests/LessonJourneyTests -only-testing:SpeechCoachAITests/SmallA1CourseTests -only-testing:SpeechCoachAIUITests/BootstrapLaunchTests/testA1PreviewResumesV2AndExplicitlyStartsV3 -only-testing:SpeechCoachAIUITests/BootstrapLaunchTests/testLessonSpeakingSelfReviewReturnsWithoutTypingOrRetention CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=-

# Final tablet retest, all passing.
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild test -project application/SpeechCoachAI.xcodeproj -scheme SpeechCoachAI -destination 'platform=iOS Simulator,id=709D6F70-328D-4458-8F8A-B2C47A945A80' -derivedDataPath application/.build/SC-D007DerivedData -resultBundlePath application/.build/sc-d007-tablet-retest.xcresult -parallel-testing-enabled NO -only-testing:SpeechCoachAIUITests/BootstrapLaunchTests/testA1PreviewResumesV2AndExplicitlyStartsV3 CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=-
```

Paths above are the actual retained results; use fresh result paths for future reruns. UI tests require a UUID-named `SC_SPEAKING_FIXTURE` store; the v2 seed additionally requires `SC_A1_V2_FIXTURE=1`, is synthetic, DEBUG-only and cannot reset/reuse learner data. Provider access stays fixture-only.

## Visual evidence and limits

Phone screenshots were inspected for teaching/card wrapping and the optional retention/support controls. These use the retained Page 1 teaching/activity identity and native sheets/activity lists. Simulator screenshots are not physical, full accessibility, dark-mode or complete A1 learning acceptance.

| State | iPhone | iPad |
| --- | --- | --- |
| Exact v2 draft resume | [Screenshot](phone-a1-exact-v2-resume.png) | [Screenshot](tablet-a1-exact-v2-resume.png) |
| v3 teaching / review-pending notice | [Screenshot](phone-a1-v3-personal-preview.png) | [Screenshot](tablet-a1-v3-personal-preview.png) |
| Separate check / text retention off | [Screenshot](phone-a1-separate-optional-check.png) | [Screenshot](tablet-a1-separate-optional-check.png) |
| Optional speaking returns without course completion | [Screenshot](phone-a1-optional-speaking-return.png) | [Screenshot](tablet-a1-optional-speaking-return.png) |

No automatic correctness/CEFR/retention/transfer/pronunciation pass is produced. The mixed foundation items are not five independent items per child objective. Qualified depth, descriptor, rubric/answer/rights review and original INTRO-01 learning obligations remain with their exact tickets. SC-T073–087 are awaiting_testing; SC-T029 remains in_progress and SC-T088 pending.

## Final evidence-label regression

Final source inspection found that an explicitly supported optional response with text retention enabled could enter the unaided-text field when Save my answer passed its default flag. `LessonSession.record` now combines the saved support condition with the action flag, so it retains the first response as assisted. The final focused run passed all 24 tests in A1CurriculumDeliveryTests and LessonJourneyTests, including that dedicated regression; the actual result is recorded in verification.json. This preserves the distinction between first response and unaided response.
