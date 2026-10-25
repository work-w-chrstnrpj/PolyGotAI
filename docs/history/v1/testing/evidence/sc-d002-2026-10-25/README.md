# SC-D002 implementation verification — 2026-10-25

[Delivery, versions, coverage and remaining actual acceptance](../../../development-plan/sc-d002-2026-10-25/README.md). All executed tests use synthetic/isolated learner stores; no live provider call, physical install, owner-data reset, Git initialization or SwiftData migration.

## Run history and scope

Exact raw results and source hashes are in verification.json. Raw logs/xcresults remain under application/.build/. Earlier valid INTRO/course/recording evidence is reused at its original scope; this pass does not rerun longitudinal or physical acceptance.

- `sc-d002-first`: initial full hosted run exposed a stale SmallA1CourseTests expectation for INTRO version 3; changed to 4 while preserving its separate approved v2 pilot-pack assertions.
- `sc-d002-phone`: interrupted after an archive-aware recommendation assertion needed the actual archive argument, while another SC-D004 batch was executing simulator checks. The test caller was adapted; shared recommendation implementation was preserved.
- `sc-d002-phone-retest`: runtime bootstrap failed with signal kill before test connection while simulator work overlapped. This is not counted as a passing run or a product assertion failure.
- `sc-d002-ipad-hosted`: all 262 hosted tests passed, including the new eight-test IntroductionDeliveryTests suite. Test totals include concurrently added SC-D004 tests in the shared workspace.

New regressions check exact v4 core counts/quiet outcome, all guide-item bindings, no reserved/unrevealed/wrong-version answers, actual hashed guide/audio asset, exact v3 saved-journey reopen and incompatible-version rejection, identical core across seven presenters, exact specialist pack binding, source/teaching-exposure snapshots with legacy decoding, unscored review-before-completion and preservation of old completion behavior, plus malformed/approval-shaped guide rejection.

UI tests follow Learn → the exact intro-01 lesson instead of relying on Today’s currently ranked lesson. One verifies post-reveal guidance/rubric and refusal to complete skipped core; the existing full course/restart/quiet/vocabulary journey now performs required comparison. Results are recorded only after execution.

## Limits

Qualified educator/descriptor/rubric/comparability review, actual prospective consent/conditions, day-7/day-28 and blinded human feedback/learning outcomes, original provider/device gates, physical/VoiceOver/largest text/all appearances/owner acceptance remain open. The personal-use guide is draft advisory material. Completion is participation, not mastery. The SC-T043 protocol is prepared, not an executed pilot or expansion decision. Do not label failed/interrupted infrastructure runs passed.

## UI correction history

The first dedicated phone UI run passed the new post-reveal guidance/rubric/skipped-core test and all eight IntroductionDeliveryTests. The full walkthrough completed all core activities and enrolled vocabulary, then failed at its old back-button selector: the test now enters from Learn, so the expected back title is Learn, not Today. The selector was corrected. No production course change was needed for that failure. The rubric test also scrolls to the audio-boundary heading for compact layouts; unexecuted source is never counted as a pass.

## Inspected visuals and asset checks

Opened [post-reveal phone review](phone-intro-v4-revealed-review.png) and [expanded self-review guide](phone-intro-v4-rubric.png), captured from the passing new UI test. The shared pinned action bar remains available while long advisory content scrolls. The screenshot records only its viewport; it is not a full Dynamic Type/VoiceOver/appearance or physical-device pass. Current Apple DisclosureGroup API documentation was checked through its official documentation JSON; local HIG and Page 1 composition are the design inputs. No Figma writes.

Authoring checks confirm only quiet-intro, listen-alex-name and listen-alex-like changed within the v4 lesson; activity IDs/counts/senses remain exact, v3 is archived, and both authoring helpers preserve v4. Python AST, JSON decoding and pbxproj syntax passed. Guide and original audio checksum checks passed in native tests.

## Final result

PASS: all 262 hosted tests on iPad A16 simulator; all eight new IntroductionDeliveryTests also passed in the focused phone run. Final iPhone 18 Pro Max/iOS 27.0 run passed both new review/rubric/skipped-core and full restart/quiet-course/vocabulary-enrollment/recall UI journeys. The original iPhone destination had bootstrap signal-kill failures; the final separate destination with explicit Xcode tool path completed. Earlier assertion/infrastructure failures remain in verification.json, not overwritten.

The final UI build includes the named v4 catalog and authored guide. Full qualified review, actual pilot/learning, provider/prerequisite and physical/accessibility acceptance remain open at awaiting_testing. No acceptance gate is declared passed from this label.

Final inspected captures: [revealed review](final-phone-intro-v4-revealed-review.png), [rubric and audio boundary](final-phone-intro-v4-rubric.png), [course completion](final-phone-recovery-completion.png). Long text scrolls above the pinned controls; these images prove only the captured simulator viewports.
