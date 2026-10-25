# SC-D006 personal-use integration — 2026-10-23

**Initial version-2 checkpoint: PASS, 26 hosted tests on each simulator**, zero failures/skips, including all four SmallA1CourseTests. **Subsequent workspace recheck: FAIL, 24 passed and 2 failed per simulator** after concurrent curriculum/runtime edits. Both failures were subsequently resolved: [26 selected tests now pass per simulator](../sc-d006-test-fixes-2026-10-23/README.md). Earlier checkpoints below remain historical evidence. [Exact summary](summary.json), [tested source/project hashes](source-hashes.json), [current handoff](../../../../../development-plan/sc-d006-grok-2026-10-23/README.md).

Devices: iPhone 18 Pro and iPad A16, iOS/iPadOS Simulator 27.0, build 24A434. Xcode compiled the app and registered test target with ad-hoc simulator signing. Selected suites: SmallA1CourseTests, CurriculumCatalogTests and LessonJourneyTests. Four new checks cover the exact approved subset/exclusions and available assets; resume identity and cross-lesson completion isolation; separate INTRO personal-check completion; and missing-listening unavailability. Adjacent catalog/journey suites passed in the same run.

Codex registered SmallA1CourseTests.swift in the existing hosted target and corrected stale README/implementation-delta descriptions. No production Swift, curriculum, audio, provider, signing configuration or schema was changed by this integration. The application behavior under test is Grok's previously delivered metadata and objective-identity guard. Synthetic tests do not prove an actual learner can complete the entire course on a device.

Raw evidence: `application/.build/sc-d006-integration-2026-10-23/tests.xcresult` and `tests.log`; pre-registration project snapshot in `project.before.pbxproj`. The exact invocation was:

```sh
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
xcodebuild test -project application/SpeechCoachAI.xcodeproj -scheme SpeechCoachAI \
  -destination 'platform=iOS Simulator,id=7535AD2C-F655-4F05-8C36-FE5E0A614902' \
  -destination 'platform=iOS Simulator,id=709D6F70-328D-4458-8F8A-B2C47A945A80' \
  -derivedDataPath application/.build/DerivedData \
  -resultBundlePath application/.build/sc-d006-integration-2026-10-23/tests.xcresult \
  -parallel-testing-enabled NO -test-timeouts-enabled YES \
  -maximum-test-execution-time-allowance 180 \
  -only-testing:SpeechCoachAITests/SmallA1CourseTests \
  -only-testing:SpeechCoachAITests/CurriculumCatalogTests \
  -only-testing:SpeechCoachAITests/LessonJourneyTests \
  CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=-
```

Personal-use version `personal-use-a1-3-2026-10-23` reuses family-01/routine-01/food-01 version 2. It is separate from introduction version 3, educator review, IL-01–IL-10 and the SC-T043 expansion decision. Full SC-D006 remains open; no ticket was closed by registration or these tests. UI walkthroughs, physical devices, new baseline/assessment/rubric content, learner consent, qualified review, longitudinal learning and public release remain unexecuted/unaccepted here. No live request or learner-data reset.


## Subsequent workspace recheck — historical failure

Other work changed course/catalog/runtime files during documentation validation. Codex preserved those edits. The first recheck, `current-source.xcresult` / `current-source.log`, did not execute tests because a concurrently changed LessonPlayerView callback expected two arguments while AppShell callers still supplied one. The callers were subsequently updated by the other lane; Codex did not edit production Swift.

The next run, `current-v2.xcresult`, compiled and executed **26 tests on each simulator: 24 PASS, 2 FAIL**. [Exact summary](current-v2-summary.json), [source hashes captured at run start](current-v2-input-hashes.json). CurriculumCatalogTests.swift also changed during that run, so this is a named checkpoint of active work, not a final frozen source baseline.

Failures in SmallA1CourseTests:

1. `approvedPersonalUseLessonsStayReadyAndSeparate`: the live family/routine/food packs now load as version 3 rather than the test's version 2 expectation. They now have explanations/foundation content that the same old test explicitly expected to be absent.
2. `oneLessonCannotResumeOrCompleteAnother`: rejecting a mismatched objective now throws unknownActivity while the test expects objectiveMismatch. The mismatch is still rejected; the expected error contract differs.

The new tests are registered successfully. The later [repair checkpoint](../sc-d006-test-fixes-2026-10-23/README.md) resolves both failures using exact archived-version lookup and specific resume guards. Codex did not weaken or silently update assertions against the original approved version-2 handoff, revert concurrent edits or mark SC-D006 complete. The original handoff descriptions above are the initial personal-use delivery checkpoint; later source revisions are separate. The initial and failed recheck bundles are retained intact.
