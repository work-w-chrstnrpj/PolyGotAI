# SC-D006 failed-test repair — 2026-10-23

**PASS: 26 hosted tests per simulator, zero failures or skips (52 executions).** All four SmallA1CourseTests pass on iPhone 18 Pro and iPad A16, Simulator 27.0/build 24A434. Selected suites: SmallA1CourseTests, CurriculumCatalogTests and LessonJourneyTests. [Exact results](summary.json), [input hashes](input-hashes.json), [source stability](source-stability.json).

The two failures in the [previous checkpoint](../sc-d006-integration-2026-10-23/README.md) are resolved:

- Approved personal-use packs resolve by exact lesson ID and version, including archived version-2 packs. New live version-3 packs do not inherit the original approval. The regression also rejects a different revision and verifies archive resolution when a newer live pack exists.
- Resume checks reject mismatched lesson, objective and version with their specific errors. The regression verifies saved work stays unchanged after rejection and completion remains isolated between lessons.

Exact-version lookup and the specific resume guards were already present from concurrent curriculum integration when this repair was made. This repair preserved them and strengthened SmallA1CourseTests; no production Swift was changed in this repair. Test registration remains in the hosted Xcode target. Swift syntax parsing also passed.

The domain, catalog, test and project inputs stayed unchanged during execution. The concurrently owned Features/Learn/LessonPlayerView.swift changed during the run; its starting hash is retained. These hosted tests establish the domain/catalog checkpoint, not final UI acceptance of that changing file. Earlier failed bundles are preserved. Full SC-D006, educator review, IL-01–IL-10 and SC-T043 expansion acceptance remain open. No live provider request, learner-data reset or status promotion.

Raw bundle/log: `application/.build/sc-d006-test-fixes-2026-10-23/tests.xcresult` and `tests.log`.

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild test \
  -project application/SpeechCoachAI.xcodeproj -scheme SpeechCoachAI \
  -destination 'platform=iOS Simulator,id=7535AD2C-F655-4F05-8C36-FE5E0A614902' \
  -destination 'platform=iOS Simulator,id=709D6F70-328D-4458-8F8A-B2C47A945A80' \
  -derivedDataPath application/.build/DerivedData \
  -resultBundlePath application/.build/sc-d006-test-fixes-2026-10-23/tests.xcresult \
  -parallel-testing-enabled NO -test-timeouts-enabled YES \
  -maximum-test-execution-time-allowance 180 \
  -only-testing:SpeechCoachAITests/SmallA1CourseTests \
  -only-testing:SpeechCoachAITests/CurriculumCatalogTests \
  -only-testing:SpeechCoachAITests/LessonJourneyTests \
  CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=-
```
