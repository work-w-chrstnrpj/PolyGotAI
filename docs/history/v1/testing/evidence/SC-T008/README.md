# SC-T008 execution evidence — 2026-10-21

Plan-first bootstrap implementation, owner-authorized in the adopted execution sequence. This is a native engineering launch surface, not delivered learning/recording/coaching UI.

## Environment and result

Xcode 27.0, build 27A266a; per-command `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`. No global developer-path or account changes. Swift 6 mode; deployment target 17.0. One universal app, hosted Swift Testing and XCUITest targets, shared SpeechCoachAI scheme. No third-party dependencies or project generator.

| Check | Result | Evidence |
| --- | --- | --- |
| Project/scheme discovery | PASS | `xcodebuild -list -project application/SpeechCoachAI.xcodeproj`; app and both test targets listed |
| iPhone 18 Pro simulator, iOS 27.0/24A434, arm64 | PASS | [Summary](iphone-summary.json): 3 tests, zero failures/skips |
| iPad (A16) simulator, iOS 27.0/24A434, arm64 | PASS | [Summary](ipad-summary.json): 3 tests, zero failures/skips |
| Bootstrap visual inspection, iPhone portrait | PASS for basic launch surface | [Screenshot](iphone-bootstrap.png), title and supporting text visible without clipping; no product fidelity acceptance claimed |
| Xcode project / shell syntax | PASS | `plutil -lint application/SpeechCoachAI.xcodeproj/project.pbxproj`; `bash -n tools/native/verify.sh` |
| External preset structure validation | PASS | 30 checks; independent of app behavior |
| Dispatch status/hash/dependency consistency | PASS | [Derived queue check](dispatch-verification.json), 192 records / 185 unfinished rows |
| Physical iPhone/iPad signing/install/launch | NOT_RUN | Owner reports iPhone 15 Plus on iOS 27; no physical iPhone listed; registered physical iPad (A16) unavailable |
| Minimum iOS/iPadOS 17 runtime | NOT_RUN | No minimum-OS simulator runtime available; metadata test does not prove compatibility |
| VoiceOver, accessibility sizes, device audio/provider/content/learner acceptance | NOT_RUN | Outside bootstrap checks; retained delivery gates |

## Repeatable commands

Run serially from project root:

```sh
bash tools/native/verify.sh 7535AD2C-F655-4F05-8C36-FE5E0A614902
bash tools/native/verify.sh 709D6F70-328D-4458-8F8A-B2C47A945A80
```

Both scripts exited 0. Xcode results: `application/.build/verification/run-L9PXMZ/tests.xcresult` (iPhone) and `application/.build/verification/run-BIDbR2/tests.xcresult` (iPad). Each directory includes `project.txt`, `test.log`, `summary.json`. These paths are local and ignored; sanitized summaries above persist. Tests verify minimum-OS/universal metadata, absence of sensitive bootstrap permission/background/ATS overrides, and foreground launch, expected visible availability text and terminate/relaunch. No placeholder business logic or fixture was counted as a feature.

The first compile failed because main-actor default affected inherited XCTest initializers. UI test target now uses nonisolated default and main-actor test methods; subsequent builds and both full test runs passed. Xcode emitted AppIntents metadata-skip messages for targets with no AppIntents dependency. Simulator logs also emitted a system duplicate accessibility class warning; result summaries report no runtime warnings or failures. No toolchain/system files were altered. A screenshot taken during simulator shutdown was blank; the retained screenshot was recaptured after boot/launch and visually checked.

## Remaining closure conditions

SC-T008 stays in_progress until required physical delivery evidence is obtained. Confirm owner bundle ID, signing team and connected iPhone/iPad access before signed installation. `org.example.SpeechCoachAI` is a simulator placeholder, not approved signing identity. No keys, account operations, entitlements, Git initialization, provider calls, publication or distribution occurred. SC-T009 remains dependent on SC-T008 completion.

Implementation follows the SC-T002 layout with only populated App/test directories; no empty future modules. Product navigation and design-to-source mapping stay in SC-T010. Commands/setup, technical/structure/testing/deployment docs and all relevant status views were updated; historical planning claims are superseded by dated kickoff records.

Official guidance checked for this implementation: [Apple Dynamic Type](https://developer.apple.com/videos/play/wwdc2024/10074/) and [running tests](https://developer.apple.com/documentation/xcode/running-tests-and-interpreting-results). System text styles support scaling; this does not establish a completed accessibility audit.

## Physical connection recheck — 2026-10-21

After owner connected the phone, `devicectl` confirmed a paired wired iPhone 15 Plus running iOS 27.0.1 (24A446). Developer Mode is disabled, which prevents the development launch check. The registered iPad also now appears available/paired; no iPad install was requested in this follow-up. One valid local Apple Development signing identity is available, but app bundle/profile configuration remains pending. No private key material was read, provisioning/account changes made, or app installed. Next action: owner enables Developer Mode on the iPhone, restarts and confirms the prompt; then resume signing/build/install verification.

## Physical launch completion — 2026-10-21

Developer Mode and manual trust were enabled by owner. Signed device build, signature verification, install, launch/relaunch and process inspection PASS on iPhone 15 Plus iOS 27.0.1/24A446. Owner confirmed the app opens. Bundle identifier is now `com.personal.SpeechCoachAI`; existing local signing identity used, automatic provisioning generated a development profile including the phone. Profile expires 2026-10-28; development installation is not a release. No private key material or credentials entered source/evidence. Physical iPad and minimum-OS execution remain NOT_RUN; both simulator device classes passed. SC-T008 is done; prior pending statements above are historical.
