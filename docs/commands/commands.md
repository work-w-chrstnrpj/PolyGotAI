# Commands

Run from the project root. Xcode is selected per command through `DEVELOPER_DIR`.

## Build and test (main check)

```bash
bash tools/native/verify.sh 7535AD2C-F655-4F05-8C36-FE5E0A614902
```

Builds and runs all unit and UI tests on the iPhone 18 Pro simulator. It exits nonzero on failure; read `application/.build/verification/run-*/test.log`. The iPad (A16) simulator is `709D6F70-328D-4458-8F8A-B2C47A945A80`. Don't run two test commands on the same simulator or DerivedData at once.

List simulators:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl list devices available
```

Build only (no tests), with a separate DerivedData folder (Claude's lane):

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild build -project application/SpeechCoachAI.xcodeproj -scheme SpeechCoachAI -destination 'platform=iOS Simulator,id=29BC0B67-0669-4B64-8691-5C1509075E6E' -derivedDataPath application/.build/ClaudeDerivedData CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=-
```

Ad-hoc simulator signing (`CODE_SIGN_IDENTITY=-`) is needed for Keychain tests.

## Content

```bash
python3 tools/curriculum/validate.py
```

Validates the course catalog and coach track JSON (unique ids, typed exercise fields, track tips and sources). Run it before committing content changes.

## Design helper (Figma plugin, not app code)

```bash
node tools/figma-local-helper/build.mjs
```

```bash
node tools/figma-local-helper/verify.mjs
```

## AI preset (external generator)

```bash
node /Users/chrixcrusher/Documents/Projects/ai-project-structure-template/bin/create-preset.mjs validate --into /Users/chrixcrusher/Documents/Projects/SpeechCoachAI
```

This checks the AI folder structure only, not app behavior. Preview a sync with `sync --target codex --profile fullstack --into <project> --dry-run` before applying it; a sync can overwrite managed `.agents/` files.
