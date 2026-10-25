# Today and Progress reliability evidence · 2026-10-22

Scope: [Codex-owned SC-T051/052/054 follow-up](../../../development-plan/daily-flow-2026-10-22.md), independent of Grok reward-preparation drafts.

Implementation: `Features/Navigation/AppShell.swift`, `Features/Progress/ProgressOverview.swift`, `App/LearnerStorageController.swift`, `Domain/LearningEvidence.swift`, `Infrastructure/Persistence/LearnerRepository.swift`; tests in `PracticeRecommendationTests.swift` and `BootstrapLaunchTests.swift`.

The primary action now matches the recommendation. An explicit alternative preserves the grounded reason and updates Progress. Navigation itself does not rewrite the choice. Failed writes leave the prior choice/note intact and confidence has a visible retry. Pending confidence text stays in memory through navigation/lock and is protected by the learner-store epoch. An old draft cannot recreate text after delete-all. Clear remains clear. No persistent schema change. Foreground/significant-time/timezone events refresh the day/week, and weekly intervals exclude the next week’s starting instant.

## Verification

- Phone main run: **PASS 97/97** — 95 hosted tests in 17 suites, the new Today/Progress recovery journey and Today contrast. iPhone 18 Pro, iOS 27 simulator, `phone-v1.xcresult`; [summary](phone-summary.json).
- Phone larger-text/accessibility: **PASS 1/1**, same simulator/build, `phone-accessibility.xcresult`; [summary](phone-accessibility-summary.json).
- Tablet: **PASS 3/3 UI checks** — the new recovery journey, Today contrast and larger-text/accessibility. iPad (A16), iPadOS 27 simulator, `ipad-v1.xcresult`; [summary](ipad-summary.json).
- Hosted fixtures cover failed override/save/clear commits, confidence error retention/retry and clear, reset-epoch rejection, local midnight/timezone recomputation and the exact week-end boundary. Corrupt-store diagnostics in the raw log belong to the existing intentional corruption test, which passed.
- The UI journey creates two collection words and enrolls them, sees Start review as the prominent action, chooses Speech Lab for today, verifies matching Progress, saves/restarts/clears/restarts confidence, restores the grounded review suggestion and enters the hidden recall. It does not send a live request or capture speech.
- Existing larger-text/accessibility checks exercise a stable Today viewport, automated dynamic-type/hit-region/sufficient-description checks, maximum accessibility text, reachable Speech Lab action and Settings. Today contrast passes separately on both device classes. These checks are not manual VoiceOver acceptance.
- Source did not change between these runs. [Changed source hashes](source-manifest.json) identify the final seven Swift files against the ignored baseline. Ignored artifacts and baseline: `application/.build/daily-flow-2026-10-22/`.

No live provider request or physical install. Manual VoiceOver/Reduce Motion, changed-layout physical checks, iOS 17 runtime and learning acceptance remain open. SC-T024/053 and rewards are not delivered by this work. Grok’s proposal files remain outside Codex edit ownership.

## Visual review

Opened actual [phone Today](screenshots/phone-daily-review-primary.png), [phone Progress](screenshots/phone-daily-progress.png), [tablet Today](screenshots/ipad-daily-review-primary.png), and [tablet Progress](screenshots/ipad-daily-progress.png). The prominent action matches the review reason; the secondary choices remain visibly subordinate. Kit cream/teal colors, original coach art, shared cards and native navigation remain. Scrolling reveals lower content beneath the system tab bar. No fresh Figma/cloud/measurement claim; the dated Page 1 handoff is in the plan.

## Reproduce

```sh
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
xcodebuild test -project application/SpeechCoachAI.xcodeproj -scheme SpeechCoachAI \
  -destination 'platform=iOS Simulator,id=7535AD2C-F655-4F05-8C36-FE5E0A614902' \
  -derivedDataPath application/.build/DailyFlowDerivedData \
  -resultBundlePath application/.build/daily-flow-2026-10-22/phone-new.xcresult \
  -only-testing:SpeechCoachAITests \
  -only-testing:SpeechCoachAIUITests/BootstrapLaunchTests/testDailyPrimaryChoiceAndConfidenceRecovery \
  -only-testing:SpeechCoachAIUITests/BootstrapLaunchTests/testTodayContrast \
  -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=-
```

The separate phone accessibility run selects `testLargerTextAndAccessibility` using test-without-building. Tablet uses test-without-building against the same product, destination `709D6F70-328D-4458-8F8A-B2C47A945A80`, the three UI selections and no hosted selection. Use fresh result paths. Significant-time/timezone notification wiring is implemented; deterministic calendar fixtures are not a manual device-clock-change run.

## Subsequent physical iPad run

[Physical iPad acceptance](../ipad-acceptance-2026-10-22/README.md) now records actual hardware execution and installation. The initial setup miss, corrected keyboard-ready helper, dark confidence-placeholder repair and successful final Progress contrast are preserved there. Its two source changes supersede this earlier simulator-only source checkpoint where applicable.
