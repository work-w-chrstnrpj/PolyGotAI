# First-loop stabilization evidence · 2026-10-22

Scope and authority: [stabilization batch](../../../development-plan/stabilization-2026-10-22.md). This record supersedes earlier source descriptions for the changed behavior; historical test runs remain historical.

## Implementation and behavior

- Today proposes the latest compatible unfinished lesson, otherwise Introductions. Learn keeps A1–C2 selection and displays actual lesson-attempt status.
- LessonPlayerView follows teaching → one focused activity → saved first attempt → example/retry → continue. The existing five INTRO-01 grammar gaps use answer choices with example-based feedback. Open responses are self-reviewed; no generic string matcher claims they are incorrect.
- Drafts and position persist locally. Supported responses count toward practice completion without becoming unaided evidence. Typed guided responses remain text; the previous player's misleading labels are repaired on resume. New practice attempts preserve older attempts. The explicit quiet equivalent is not a second compulsory introduction.
- An actual successful recording/self-review initiated from the current lesson hands an in-memory completion back to that exact lesson journey. Presentation is item-bound; the completion is consumed after successful persistence so an earlier recording cannot satisfy a repeated lesson. Optional audio/text retention is unchanged. Lesson participation does not claim speech quality or retain private audio merely to preserve credit.
- Bundled vocabulary includes explanatory glosses based on the existing recall cues; INTRO-01 has explicit phrase meanings. Enrollment keeps a gloss snapshot; legacy lesson cards resolve against the bundle. New word meanings do not collapse solely because their spelling matches. Collection and review enrollment remain distinct. A missing meaning cannot receive a rating, and deleting the last topic preserves a kept meaning.
- The immutable bundled catalog is inspected once per process, rather than hashing all audio on each navigation/state render.
- Capture-route activation runs off the main executor. Cancel/background during activation cancels the pending start; another start cannot race its cleanup.

## UI handoff

- Visual source: Page 1, file B1A9qEN1B7I3NJKISX39Dx, dated local 2026-10-17 screenshots `speechcoach-kit-03.png` and `speechcoach-kit-04.png`, both actually opened. Structural/token/artwork provenance comes from the 2026-10-21 `readiness-2026-10-21` audit, its resolved tokens and existing app asset map. No fresh live Figma inspection or cloud-sync claim.
- Recipes: T01 2:37969 (Today), T03 2:38130 (Learn), T04 2:38212 (teaching), T05 2:38252 and T06 2:38294 (activity/retry), T08 2:38663 (Vocabulary), speaking 2:38407 / 2:38472 (record/review).
- Families: Button 2:40308, Answer option 2:40310, Content row 41:1105, Input 41:1127, Status 41:1155, Coaching card 41:1177. Translation: existing Kit semantic colors, KitCard/AvailabilityCard, KitContentRow and KitPrimaryButtonStyle; native navigation, controls and sheets. Existing TeacherGreeting/coach portraits remain discrete source artwork.
- Sources: Features/Navigation/AppShell.swift, Features/Learn/LessonPlayerView.swift, Features/Vocabulary/CustomTopicViews.swift and VocabularyRecallView.swift, Features/Shared/DesignSystem.swift, Features/Recording/RecordingController.swift and RecordingView.swift.
- Native adaptation: inline navigation titles, native tab navigation restored on return, keyboard-aware pinned lesson action, scrollable constrained content, system fonts, expanding text, native back/contents, no decorative motion. Shared color tokens retain appearance choices.
- Apple guidance rechecked: [layout](https://developer.apple.com/design/human-interface-guidelines/layout), [buttons](https://developer.apple.com/design/human-interface-guidelines/buttons). Missing live variant measurements are not presented as newly inspected values.

## Verification

- Baseline audit run: 68 hosted tests and 8 UI tests passed; recording/background UI failed before reaching capture. `application/.build/verification/run-gRNzmY/tests.xcresult`.
- First repair unit run: 74 tests in 15 suites passed. `application/.build/recovery-2026-10-22/unit.xcresult`. Later speaking-handoff/quiet-equivalent changes require the final regression run below.
- First repair UI run: recording/background passed. Connected lesson reached completion, then exposed a parent accessibility identifier masking completion controls; fixed by identifying only the completion heading. `connected-ui-v1.xcresult`.
- Full phone regression v1: 75 domain tests and 10 of 11 UI journeys passed; the new recording-to-lesson return exposed stale presentation context. Fixed with one item-bound recording presentation and a completion tied to the exact lesson journey, consumed after a successful save.
- iPad regression v1: dark/large-text/navigation/Today contrast passed. The new connected journey reached completion but its generic Back helper tapped the sidebar control; the test now targets the named Today back button.
- Phone/iPad focused v2: connected quiet completion → vocabulary, real recording → lesson return without retention, and the synthetic provider/history/rotation journey passed on both device classes. New accessibility checks exposed a redundant progress indicator as a tiny hit target (now hidden from accessibility because the visible text already speaks the position). On phone the scan included a lesson title fully behind the system floating tab bar; the exported app screenshot confirms the occlusion. The contrast-only filter is limited to static Learn labels wholly behind that bar, excludes the bar's own labels and never excludes partial rows. Visible content and interactive targets remain audited.
- Final v3: phone PASS 78/78 (75 domain + 3 UI); iPad PASS 3/3 matching UI journeys. Machine-readable summaries and screenshots are linked below. Source remained unchanged between the final build, both runs and the recorded source manifest.

## Remaining acceptance

No live calls were sent. The full RF/device route/lock/cap matrix, manual accessibility acceptance of changed layouts, iOS/iPadOS 17 runtime regression, full INTRO-01 content/comprehension coverage, broader A2–C2 walkthroughs, specialist methods, rewards, and observed learning effectiveness are not closed by this repair. The owner waiver of a hired reviewer is recorded separately under SC-T006.

## Final phone result

`phone-final-v3.xcresult`: **PASS — 78/78 tests**, 75 domain/persistence tests plus the three new UI journeys. See [machine-readable summary](phone-final-summary.json). The v2 phone/tablet synthetic speaking/provider/history/rotation journeys also passed; no live HTTP transport was used. Catalog authoring syntax, repair idempotence, all 285 glosses and gap-word counts passed static checks. `verify.sh` passed shell syntax and a mocked failure-path check confirming nonzero status and a retained failure summary; the mock is not an app test.

At the end of simulator verification, the physical iPhone/iPad were disconnected. In the owner-requested installation follow-up on 2026-10-22, the iPhone 15 Plus was connected. A fresh signed Debug build succeeded using the existing development team and `com.personal.SpeechCoachAI` identifier, installed over the existing app, and launched successfully with normal launch settings. No uninstall, data reset, test fixture, or live provider request was used. This confirms installation and launch; manual feature/device acceptance remains open. Ignored evidence: `application/.build/recovery-2026-10-22/phone-install-build.log`, `phone-app-before-install.json`, `phone-install.json`, and `phone-launch.json`. The iPad was not updated in this follow-up.

## Screenshots from actual simulator runs

| Screen | Phone |
| --- | --- |
| Connected Today plan | [Today](screenshots/phone-recovery-today.png) |
| Lesson library | [Learn](screenshots/phone-recovery-learn.png) |
| Focused answer choices | [Activity](screenshots/phone-recovery-activity-choices.png) |
| Example and feedback | [Feedback](screenshots/phone-recovery-activity-feedback.png) |
| Completion and words | [Completion](screenshots/phone-recovery-completion.png) |
| Vocabulary collection | [Vocabulary](screenshots/phone-recovery-vocabulary.png) |
| Recall and rating | [Review](screenshots/phone-recovery-vocabulary-review.png) |
| Actual speaking return | [Speaking return](screenshots/phone-recovery-lesson-speaking-return.png) |

Phone screenshots were visually inspected alongside the dated Page 1 compositions. They are implementation evidence, not replacement artwork. Tablet Learn and focused activity screenshots were also visually inspected; there was no horizontal clipping in the reviewed regular-width views.

## Final tablet result and reproducible commands

`ipad-final-v3.xcresult`: **PASS — 3/3 UI journeys** on iPad (A16), iPadOS 27 simulator. See [machine-readable summary](ipad-final-summary.json), [tablet Learn](screenshots/ipad-recovery-learn.png), [tablet activity](screenshots/ipad-recovery-activity-choices.png), and [tablet recording return](screenshots/ipad-recovery-lesson-speaking-return.png). Final phone target: iPhone 18 Pro, iOS 27 simulator. These are simulator results; physical-device/manual/learning acceptance above remains open.

```sh
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
xcodebuild test -project application/SpeechCoachAI.xcodeproj -scheme SpeechCoachAI \
  -destination 'platform=iOS Simulator,id=7535AD2C-F655-4F05-8C36-FE5E0A614902' \
  -derivedDataPath application/.build/RecoveryDerivedData \
  -resultBundlePath application/.build/recovery-2026-10-22/phone-final-v3.xcresult \
  -only-testing:SpeechCoachAITests \
  -only-testing:SpeechCoachAIUITests/BootstrapLaunchTests/testConnectedLessonDraftResumeQuietCompletionAndVocabularyReview \
  -only-testing:SpeechCoachAIUITests/BootstrapLaunchTests/testFocusedLessonAndLibraryAccessibility \
  -only-testing:SpeechCoachAIUITests/BootstrapLaunchTests/testLessonSpeakingSelfReviewReturnsWithoutTypingOrRetention \
  -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=-
```

The iPad command used test-without-building against that same build, destination `709D6F70-328D-4458-8F8A-B2C47A945A80`, result path `ipad-final-v3.xcresult`, the same three UI selections, and omitted the hosted target selection. Use a fresh result path on rerun; existing xcresult bundles are preserved. The earlier full regression and the v2 synthetic speaking/history/rotation retests are retained under the same ignored evidence root.

[Changed source hashes](source-manifest.json) identify the final source relative to the retained ignored baseline. Native project targets, file-protection schema, signing identity, provider credentials and deployment were not changed by this batch.

## UI review record

| Before | After | Why |
| --- | --- | --- |
| Today offered disconnected entry buttons | A resumable lesson with linked speaking and vocabulary steps | Makes the next action clear |
| Every lesson activity and its controls appeared at once | Teaching, then one activity with a pinned action and contents/back navigation | Keeps the task readable and resumable |
| All grammar work used a generic text field | Existing INTRO-01 gaps use bounded choices and example feedback | Gives controlled practice an appropriate interaction |
| Vocabulary mixed creation forms and unscheduled claims | Searchable collection, explicit review state and topic creation sheet | Separates keeping a word from rating it |

No ticket is closed solely from this batch's implementation or simulator checks. Remaining product/content/device/provider acceptance is retained in the exact tickets.
