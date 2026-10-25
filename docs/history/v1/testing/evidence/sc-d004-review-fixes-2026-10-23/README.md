# SC-D004 review fixes — 2026-10-23

**PASS:** 29 selected test functions on each simulator (28 hosted + one UI; 30 executions per device because the reset test has two cases), zero failures/skips. iPhone 18 Pro and iPad A16, Simulator 27.0 build 24A434. [Exact summary](summary.json), [tested source hashes](source-hashes.json), [scope/ownership](../../../development-plan/sc-d004-review-fixes-2026-10-23.md).

The run selected DailyProgressDeliveryTests, PracticeRecommendationTests, PracticePreferencesTests and BootstrapLaunchTests/testPracticePreferencePersistsAndConnectsToday. New controller fixtures inject failed save and failed clear, reload the shared draft, retry successfully, and reset the learner before either reload or a stale save. The UI journey selects Speech Lab, navigates Progress → Today before saving, confirms the unsaved selection, saves, restarts, clears and verifies an unavailable review preference. It now queries today.goal.picker/status/save/clear directly, confirming removal of the parent identifier collision. No synthetic failure was injected in the UI journey; fault recovery is hosted integration coverage combined with the actual unsaved-navigation UI check.

Raw log and result bundle: `application/.build/sc-d004-review-fixes-2026-10-23/tests.log` and `tests.xcresult`. Swift syntax parsing also exited 0 before Xcode compiled the selected targets.

```sh
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
xcodebuild test -project application/SpeechCoachAI.xcodeproj -scheme SpeechCoachAI \
  -destination 'platform=iOS Simulator,id=7535AD2C-F655-4F05-8C36-FE5E0A614902' \
  -destination 'platform=iOS Simulator,id=709D6F70-328D-4458-8F8A-B2C47A945A80' \
  -derivedDataPath application/.build/DerivedData \
  -resultBundlePath application/.build/sc-d004-review-fixes-2026-10-23/tests.xcresult \
  -parallel-testing-enabled NO -test-timeouts-enabled YES \
  -maximum-test-execution-time-allowance 180 \
  -only-testing:SpeechCoachAITests/DailyProgressDeliveryTests \
  -only-testing:SpeechCoachAITests/PracticeRecommendationTests \
  -only-testing:SpeechCoachAITests/PracticePreferencesTests \
  -only-testing:SpeechCoachAIUITests/BootstrapLaunchTests/testPracticePreferencePersistsAndConnectsToday \
  CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=-
```

No ranking/persistent-schema/provider changes, data reset, physical installation or live request. Test stores are isolated synthetic stores. Existing wider verified behavior was not rerun. Physical VoiceOver, appearance/size matrix, learner/content acceptance and reviewed specialist mappings remain separate. SC-D004 stays partially implemented; SC-T051 stays in_progress.
