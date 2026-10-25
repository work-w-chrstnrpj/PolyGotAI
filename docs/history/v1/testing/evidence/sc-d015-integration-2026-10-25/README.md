# SC-D015 review/integration evidence — 2026-10-25

Owner-authorized check/fix of [Grok's partial return](../../../../../development-plan/sc-d015-grok-2026-10-23/README.md). See [confirmed defects, integration and remaining requirements](../../../development-plan/sc-d015-integration-2026-10-25.md). All new tests use synthetic wording/policies, local temporary roots or UUID-isolated UI fixtures. No live provider request, learner-data reset, migration, device install, release or Git initialization.

## Run history

| Run | Actual result | Ignored raw evidence under application/.build/ |
| --- | --- | --- |
| First real-target compile | Failed: actor-isolation errors in Grok's synthetic counter/wire helper and mutating-expression macro errors in new tests; corrected | `sc-d015-review-first.xcresult`, `.log` |
| Focused hosted tests | PASS: 17 tests across original and repair suites | `sc-d015-review-focused.xcresult`, `.log` |
| Phone integration | Full hosted suite PASS: 227 tests; both initial UI journeys passed before later confirmation/policy-copy refinements | `sc-d015-review-phone.xcresult`, `.log` |
| iPad integration | PASS: 228 hosted tests across 26 suites and both UI journeys, including removal confirmations | `sc-d015-review-ipad.xcresult`, `.log` |
| Final iPhone | PASS: 19 focused original/repair hosted tests plus both UI journeys on final source | `sc-d015-review-final-phone.xcresult`, `.log` |

Final source hashes, exact run counts and source boundaries are in [verification.json](verification.json). Initial failures remain recorded; passing parse or macOS harness output is not substituted for target/hosted/native evidence.

## Meaningful coverage

Original delivery tests plus repairs cover missing/unapproved policy and absent transport, malformed/unsupported payloads and hidden answers, source/objective/schedule preservation, full request source/policy/kind pins, cancellation/late/duplicate/unknown outcomes, cache-policy/source/target/type compatibility and lowered bounds, immutable full-content identity, retention decline and non-resurrection, exact report save status, full report version/expiry/export identity, epoch preflight, actual repository reopen, compare-and-replace, failed-write rollback/retry, durable deletion, expiry and delete-all. Recovery does not claim a marker saved until its write succeeds.

Native journey 1 opens Speech Lab → Generated practice with no production policy and verifies request/report controls are disabled. Native journey 2 uses a DEBUG-only synthetic retained variant and local report policy, reveals the answer, saves a report, terminates/reopens to check saved status, removes the report and wording, and reopens without either being recreated. It sends no online request and tests neither educator review nor content quality. Updated irreversible removals use native confirmation alerts; final runs use those controls.

## Reproduce

Project: `application/SpeechCoachAI.xcodeproj`; scheme: `SpeechCoachAI`; ad-hoc simulator signing. Derived data: `application/.build/SC-D017DerivedData` (reused local compilation cache, not SC-D017 acceptance evidence). iPhone 18 Pro `7535AD2C-F655-4F05-8C36-FE5E0A614902`, iPad A16 `709D6F70-328D-4458-8F8A-B2C47A945A80`, iOS/iPadOS simulator 27.0. Runs are serial.

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild test \
  -project application/SpeechCoachAI.xcodeproj -scheme SpeechCoachAI \
  -destination 'platform=iOS Simulator,id=7535AD2C-F655-4F05-8C36-FE5E0A614902' \
  -derivedDataPath application/.build/SC-D017DerivedData \
  -parallel-testing-enabled NO \
  -only-testing:SpeechCoachAITests \
  -only-testing:SpeechCoachAIUITests/BootstrapLaunchTests/testGeneratedPracticeRemainsUnavailableWithoutPolicy \
  -only-testing:SpeechCoachAIUITests/BootstrapLaunchTests/testGeneratedReportAndWordingDeletionSurviveRestart \
  CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=-
```

Use focused suite selectors `SpeechCoachAITests/GeneratedPracticeDeliveryTests` and `SpeechCoachAITests/GeneratedPracticeRepairTests` after bounded repairs. Raw logs retain existing SDK actor/simulator/accessibility-loader warnings; no warning-free build claim. Whole-suite corrupt-store fixtures intentionally exercise CoreData failures; these are separate from test failures.

## Unperformed acceptance and remaining implementation

No adopted production generation policy, real objective/template/model manifest, calibrated semantic/answer/difficulty validation, selected live provider adapter, approved cost/quota/retention record or reviewed fallback is delivered. Actual account billing/transport, physical interruption/network/background/accessibility/large text/themes, qualified content and learner outcomes remain unverified. A snapshot's approval-shaped fields and synthetic numbers are not evidence for those gates. Original prerequisite/parent acceptance remains; SC-D015 and all mapped records stay in_progress.

## Final source and screenshot boundary

Scoped checks passed. The final iPad full hosted run passed 228 tests plus two UI journeys; final iPhone passed 19 focused tests and both UI journeys. Final phone controls include the later missing-policy save/copy refinement; unchanged broad domain behavior uses the prior full hosted evidence. Initial phone integration passed 227 hosted tests and both UI journeys before the additional familiar-type regression and UI confirmations.

The regular-width [recovered report](ipad-generated-report-recovered.png) was visually inspected. Other exercised screenshots: [iPad policy gate](ipad-generated-policy-gate.png), [final phone policy gate](phone-generated-policy-gate.png), [final phone recovered report](phone-generated-report-recovered.png). These are synthetic UI evidence, not full visual/accessibility/device acceptance. Raw reports retain SDK/runtime warnings, including occasional SQLite temporary-store cleanup warnings in new/old isolated fixtures; no warning-free result is claimed.

Project plist, exact queue status/source hashes, grouped membership and local links are checked separately; they do not prove runtime behavior. All five original records remain in_progress, with no done or awaiting_testing promotion.
