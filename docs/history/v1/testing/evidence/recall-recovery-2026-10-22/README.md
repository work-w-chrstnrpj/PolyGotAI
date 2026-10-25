# Offline recall recovery evidence · 2026-10-22

Scope: [SC-T048–SC-T050 batch](../../../development-plan/recall-recovery-2026-10-22.md). Implementation is in `Domain/VocabularyRecall.swift`, `Infrastructure/Persistence/LearnerRepository.swift`, `Features/Vocabulary/VocabularyRecallView.swift` and `CustomTopicViews.swift`.

Hidden answers and mode persist without a rating. A stable recall event survives reveal/restart/failure; duplicate delivery returns the same committed result and cannot apply another schedule. A duplicate UUID for a different sense is refused. Persisted revealed response/mode win over later edits. The open card resumes before other due cards. Think, Write, and Say remain separate; Say is unrecorded learner-reported self-check (`spokenSelfCheck`), with no speech-quality or speech-completion claim. Hard is successful effort and Again is a miss. New optional mode/event fields preserve old documents; no SwiftData migration.

## Verification

- Final hosted regression: **PASS 92/92**, 17 suites, iPhone 18 Pro / iOS 27 simulator. Includes the legacy revealed-draft identity/skip regression, real repository reopen, synthetic pre-new-field payload, injected identity-save failure/retry, and unchanged rating/schedule assertions. `application/.build/recall-recovery-2026-10-22/legacy-final.xcresult`; [summary](hosted-summary.json).
- Phone v3: **PASS 2/2 UI journeys**, iPhone 18 Pro / iOS 27 simulator; [summary](phone-ui-summary.json).
- iPad v3: **PASS 2/2 UI journeys**, iPad (A16) / iPadOS 27 simulator; [summary](ipad-ui-summary.json).
- The UI journeys passed typed hidden-draft/restart, reveal/restart, first-response display, full two-card progression, successful Hard, unrecorded Say/Again, and accessibility-size Think with the native menu. They used collection-only Save and Add to review separately. The revealed-answer screen passed automated contrast, hit-region and sufficient-description audits on both device classes.
- Phone v2 also passed all then-current 91 hosted tests + 2 UI tests. v3 UI used the [UI source snapshot](ui-v3-source-manifest.json). The only subsequent product-source change assigns an event UUID to a legacy open recall on first read; the final full hosted regression above covers its persistence, failure and skip path. Modern-draft UI paths were unchanged. [Final source snapshot](source-manifest.json).
- New/updated local doc links and source hashes checked: PASS. No project structure or native schema changed. The ignored run root retains logs, result bundles and baseline copies.

Remaining gates: physical iPhone/iPad walkthrough, manual VoiceOver/Reduce Motion acceptance, iOS 17 runtime, optional provider sentence feedback and learning acceptance. No live provider call. No new physical installation in this batch. Ticket and parent closure are not inferred from implementation.

## Regression history and boundaries

- v1: 89/91 hosted tests passed. Two older fault-injection tests reused an already committed draft to represent a new review; they now explicitly use a new event ID. New recovery/mode/legacy checks passed in v1. The phone UI setup exposed the topic editor retaining its keyboard after Save word; focus now dismisses on save and scrolling can dismiss it. The accessibility-size picker received a stable identifier.
- Phone v2: 91/91 hosted + 2/2 UI passed. Two-card collection/enrollment, typed hidden draft/restart, reveal/restart, Hard, unrecorded Say/Again and accessibility-size Think all completed.
- Tablet v2: both UI tests stopped in setup because the generic first navigation-bar button selected the sidebar. v3 targets the named Vocabulary back button. This was a test navigation failure, not an executed review acceptance pass.
- New source uses the same private-store schema and FSRS version. Existing UI-test interruption-monitor actor warnings remain outside this change. No live provider request or microphone capture occurs in these review journeys; fixture-mode app storage is isolated from normal learner data.

## Reproduce

```sh
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
xcodebuild test -project application/SpeechCoachAI.xcodeproj -scheme SpeechCoachAI \
  -destination 'platform=iOS Simulator,id=7535AD2C-F655-4F05-8C36-FE5E0A614902' \
  -derivedDataPath application/.build/RecallRecoveryDerivedData \
  -resultBundlePath application/.build/recall-recovery-2026-10-22/phone-new.xcresult \
  -only-testing:SpeechCoachAITests \
  -only-testing:SpeechCoachAIUITests/BootstrapLaunchTests/testOfflineRecallDraftRevealAndRatingRecovery \
  -only-testing:SpeechCoachAIUITests/BootstrapLaunchTests/testRecallLargerTextThinkMode \
  -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=-
```

Tablet v3 uses test-without-building against the same product, iPad (A16) destination `709D6F70-328D-4458-8F8A-B2C47A945A80`, both UI selections and no hosted selection. Use a fresh result path. The [source manifest](source-manifest.json) records changed files against the retained baseline. Native design handoff is in the linked batch plan; no fresh live Figma claim.

## Visual review

Actually opened: [phone hidden response](screenshots/phone-recall-hidden.png), [phone spoken self-check](screenshots/phone-recall-spoken-self-check.png), [phone accessibility size](screenshots/phone-recall-larger-text.png), [tablet revealed response](screenshots/ipad-recall-written-reveal.png), and [tablet accessibility size](screenshots/ipad-recall-larger-text.png). Cream/teal identity and shared cards are retained against the dated Page 1 reference. Larger text uses scrolling and the method menu; at the maximum accessibility size, the existing tablet sidebar labels wrap. This is not a manual VoiceOver or complete app accessibility acceptance claim.

## Subsequent physical iPad run

[Physical iPad acceptance](../ipad-acceptance-2026-10-22/README.md) passed the hidden-draft/reveal recovery and accessibility-size Think journeys on actual hardware. The shared test-topic helper received explicit keyboard readiness after a separate daily-flow setup miss. Original full ticket/provider/manual/learning acceptance remains separate.
