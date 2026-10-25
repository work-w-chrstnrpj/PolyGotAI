# Personal vocabulary editing and search verification · 2026-10-23

Bounded SC-T165/048 follow-up; [plan](../../../development-plan/vocabulary-editing-2026-10-22.md). Test inputs are synthetic in UUID-scoped fixture stores. No real provider request, physical install, credentials, migration, learner reset or reward activation.

## Changes and result

Search now covers collection word/meaning and topic title/subtopic/word/meaning, including words not enrolled. Whitespace-separated terms ignore case/diacritics. Results offer a clear action and empty-state recovery. Word-list refresh retains unsaved topic metadata; explicit save/discard resets the draft baseline. Both rename fields validate before mutation. This does not add durable unsaved-draft recovery across termination.

- Initial `phone.xcresult`: BUILD FAILED because the new test insertion displaced the helper's MainActor annotation. Corrected before executing the final runs. Failed attempt retained locally.
- `phone-v2.xcresult`: PASS, 98 hosted Swift Testing tests in 17 suites plus one XCUITest journey. Raw xcresult counts parameterized invocations separately (118 passed entries, zero failures). [Summary](phone-summary.json).
- `tablet.xcresult`: FAIL in the UI test navigation selector after saving the preserved topic draft. Index-zero navigation button was “Hide Sidebar” on iPad, so search was correctly absent while still in the editor. Changed the test to the named Vocabulary back button. [First-run summary](tablet-first-summary.json). Application source did not change.
- `tablet-v2.xcresult`: PASS 1/1 with the named back selector. [Summary](tablet-summary.json), [tablet screenshot](tablet.png) visually inspected. No app-source change between phone PASS and tablet PASS; only the test navigation selector changed.
- Hosted regressions cover accent/meaning/subtopic/multi-term search, unscheduled-word discovery, invalid rename preserving both fields/time, and save/discard draft baselines after refreshing words.
- UI journey creates/rates no real data, edits a topic name, adds a word before saving the rename, checks the title survived, searches an unenrolled meaning, checks no-results and clears the search. [Phone screenshot](phone.png) visually inspected. The saved topic title is visible and the search/collection layout retains T08 identity.

## Reproduction and limits

Xcode selection: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`. Scheme SpeechCoachAI, project application/SpeechCoachAI.xcodeproj, DerivedData application/.build/DerivedData, simulator signing `CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=-`, parallel testing NO. Phone iPhone 18 Pro simulator UUID 7535AD2C-F655-4F05-8C36-FE5E0A614902, iOS 27.0. Tablet iPad A16 simulator UUID 709D6F70-328D-4458-8F8A-B2C47A945A80. Phone `xcodebuild test` selects SpeechCoachAITests and SpeechCoachAIUITests/BootstrapLaunchTests/testPersonalVocabularySearchAndUnsavedTopicDetails; tablet `test-without-building` selects the same UI method. Exact logs/bundles/attachments retained under ignored application/.build/vocabulary-editing-2026-10-22/ (run started October 22, completed October 23 in Asia/Manila).

[Source hashes](source-checkpoints.json) identify the four files. No complete manual accessibility, minimum-OS, physical-device or full-ticket acceptance is inferred. Prior physical iPad evidence covers the prior build only. Awaiting-testing status means implementation is available, not accepted done. Grok's content and reward drafts were not integrated.
