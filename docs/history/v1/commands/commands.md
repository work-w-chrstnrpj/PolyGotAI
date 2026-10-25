# SpeechCoachAI Command Reference

## Available preset checks

The CLI resides in the external template repository, not this project. Node.js 18+ is required. These commands do not build or test SpeechCoachAI.

```sh
node /Users/chrixcrusher/Documents/Projects/ai-project-structure-template/bin/create-preset.mjs --help
node /Users/chrixcrusher/Documents/Projects/ai-project-structure-template/bin/create-preset.mjs validate --into /Users/chrixcrusher/Documents/Projects/SpeechCoachAI
```

Task checks can use `--task api`, `--task database`, `--task testing`, or `--task deployment`. IN_PROGRESS design docs can remain insufficient for implementation-ready task validation; do not falsely mark them COMPLETE to suppress a warning.

## Preview template synchronization

```sh
node /Users/chrixcrusher/Documents/Projects/ai-project-structure-template/bin/create-preset.mjs sync --target codex --profile fullstack --into /Users/chrixcrusher/Documents/Projects/SpeechCoachAI --dry-run
```

Preview only. Review proposed changes before applying synchronization; it refreshes generator-managed canonical assets and adapters. Conflicting user-owned files are normally preserved as `skipped_user_file`. `--force` intentionally replaces conflicts; `--clean` can remove stale skills. Neither is routine documentation maintenance. No sync was required to adopt project docs.

## Local Figma tooling checks

```sh
node tools/figma-local-helper/build.mjs
node tools/figma-local-helper/verify.mjs
```

The build bundles the project-local plugin without dependencies. Verification checks route integrity, independent retention choices, disclosure separation, wrong-file rejection and distributable syntax. Import/run it using the [helper instructions](../../../../tools/figma-local-helper/README.md). Passing these checks does not prove runtime execution inside Figma or visual/device acceptance.

## Native simulator verification — SC-T008

From the project root, list destinations and run the shared SpeechCoachAI scheme:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -list -project application/SpeechCoachAI.xcodeproj
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl list devices available
bash tools/native/verify.sh 7535AD2C-F655-4F05-8C36-FE5E0A614902
bash tools/native/verify.sh 709D6F70-328D-4458-8F8A-B2C47A945A80
```

These UUIDs identify this machine's iPhone 18 Pro and iPad (A16), iOS 27.0 simulators. Substitute current available UUIDs elsewhere. Run serially because both commands share DerivedData. The script uses per-command Xcode selection, performs `xcodebuild test` (which builds the app and both test targets), disables simulator signing and test parallelization, and writes a unique `.build/verification/run-*/` containing log, xcresult and extracted summary. It exits nonzero on failure; inspect `test.log`. No test retries are automatic. Raw xcresults remain local/ignored; sanitized summaries are under [SC-T008 evidence](../testing/evidence/SC-T008/README.md).

Equivalent explicit build (no tests):

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild build -project application/SpeechCoachAI.xcodeproj -scheme SpeechCoachAI -destination 'platform=iOS Simulator,id=7535AD2C-F655-4F05-8C36-FE5E0A614902' -derivedDataPath application/.build/DerivedData CODE_SIGNING_ALLOWED=NO
```

Open `application/SpeechCoachAI.xcodeproj`, choose SpeechCoachAI and an available simulator, and Run for interactive inspection. Product UI is not implemented. Bundle ID `org.example.SpeechCoachAI` is a simulator placeholder. Signed build/archive/install requires owner-confirmed team/bundle identity and connected device; no signing credentials are embedded. No backend, migration or deployment commands exist. iOS/iPadOS 17 is the configured minimum, but minimum-OS runtime testing is unavailable locally. See the ticket for actual execution results.

## SC-T002 tooling inspection — 2026-10-21

Read-only commands succeeded with a per-command developer path (the global setting was not changed):

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -version
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl list devices available
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun devicectl list devices
```

Observed Xcode 27.0/27A266a and iOS 27 simulators; registered iPad unavailable. Without DEVELOPER_DIR, the active CommandLineTools setting could not locate full-Xcode tools. These checks do not compile, launch or install an app. Selected future scheme is SpeechCoachAI; SC-T008 must create and verify actual build/test commands and device destinations after owner development authorization. No current app command is runnable.

## Focused recording verification — SC-T011

From the repository root, the final simulator command used the existing Xcode installation and iPhone 18 Pro destination:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild test -project application/SpeechCoachAI.xcodeproj -scheme SpeechCoachAI -destination 'platform=iOS Simulator,id=7535AD2C-F655-4F05-8C36-FE5E0A614902' -derivedDataPath application/.build/DerivedData -resultBundlePath application/.build/capture-domain-v2.xcresult -parallel-testing-enabled NO -only-testing:SpeechCoachAITests -only-testing:SpeechCoachAIUITests/BootstrapLaunchTests/testOfflineRecordingEntryRequiresDeliberateStart CODE_SIGNING_ALLOWED=NO
```

PASS, 28 reported cases. Choose a new result bundle path for another execution; Xcode does not overwrite existing bundles. This deliberately does not capture actual microphone audio. Broader iPad accessibility tests currently have an unresolved failure: see ticket evidence rather than assuming the generic verification script must pass. Signed device build/install used the previously authorized existing development team; no signing identity or key export.

## Keychain simulator verification correction — 2026-10-21

Keychain tests require a signed host even on simulator. Use `CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=-` for ad-hoc simulator signing; `tools/native/verify.sh` now does this. The focused `-only-testing:SpeechCoachAITests/ProviderCredentialTests` rerun passed on iPhone simulator; physical hosted suite and masked-settings UI also passed. Initial unsigned Keychain failure is retained in SC-T012 evidence. This does not require a real provider key or provider request.

## Stabilization verification — 2026-10-22

`bash tools/native/verify.sh SIMULATOR_UUID` runs the full simulator suite and now preserves summary.json after a failing test as well as after success. A nonzero test exit remains a failure. Focused native commands and actual result bundles for the current first-loop repair are in `docs/testing/evidence/first-loop-stabilization/README.md`; their scope does not replace physical-device or live-provider acceptance.

## Offline recall recovery checks — 2026-10-22

[SC-T048–SC-T050 evidence and reproducible command](../testing/evidence/recall-recovery-2026-10-22/README.md) record 92 final hosted tests and two review journeys on each iPhone/iPad simulator. Use the named recall UI selections and a fresh result path. No physical install or provider request was made by this batch.

## Today and Progress reliability checks — 2026-10-22

[SC-T051/052/054 evidence and command](../testing/evidence/daily-flow-2026-10-22/README.md): 95 hosted tests, new override/note recovery, Today contrast and larger-text/accessibility passed on iPhone/iPad simulators. Same product across all UI runs; no device install or provider call. Grok reward preparation remains isolated and noncanonical.

## Physical iPad acceptance — 2026-10-22

[Exact run and retests](../testing/evidence/ipad-acceptance-2026-10-22/README.md): 95 hosted tests plus seven selected UI journeys passed on wired iPad A16/iPadOS 27.0.1, with the initial setup failure retained. Existing development signing was reused. Current app installed and launched normally; tests used isolated stores and synthetic provider responses. Live-provider and remaining original acceptance gates stay open.

## SC-D007 bounded native verification — 2026-10-23

[SC-D007 evidence](../testing/evidence/sc-d007-2026-10-23/README.md) records exact selected commands, initial failures and final phone/tablet checks. Use isolated `application/.build/SC-D007DerivedData`, fresh result paths and serial Xcode runs. The DEBUG-only `SC_A1_V2_FIXTURE=1` additionally requires a UUID `SC_SPEAKING_FIXTURE` store and seeds synthetic old-version content only; it never selects the learner store.
