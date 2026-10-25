# SC-D003 verification — 2026-10-23

Scope: [implementation and ownership](../../../development-plan/sc-d003-2026-10-23.md). Synthetic, isolated simulator stores; no learner reset, physical install, live provider call or schema migration.

## Executed checkpoints

- Initial hosted pass: **118 test functions passed** (137 parameterized executions) on iPhone 18 Pro / iOS Simulator 27.0, build 24A434. `application/.build/sc-d003-2026-10-23/hosted.xcresult`; [summary](hosted-summary.json). Six new delivery tests passed at this checkpoint.
- Existing hidden-draft/reveal/rating recovery journey: **PASS on phone and tablet** in `ui.xcresult`. It covers restart with typed hidden draft, restart with frozen reveal, Hard/Again ratings and unrecorded Say self-check. New options journey initially **FAIL on both** at its accessibility audit: system gray section headers nearly met contrast. The app's existing secondary text color replaced those headers; Form uses the Vocabulary background. [Initial UI summary](ui-summary.json).
- Final application source (including per-rating scheduling provenance and old-field decoding): **119 hosted test functions PASS on both** iPhone 18 Pro and iPad A16 simulators, iOS/iPadOS Simulator 27.0 / 24A434. New options journey **PASS on tablet**: invalid zero limit rejected, 95%/one-word settings saved and restored after restart, contrast/description audit, limited-session completion and next session's remaining word. `application/.build/sc-d003-2026-10-23/final.xcresult`; [combined summary](final-summary.json). Seven new ReviewDeliveryTests are included.
- The same final phone UI checkpoint **FAIL** at contrast: the history paragraph was partially behind the system floating tab bar. Attachment inspection identifies the occluded paragraph; no change to domain/persistence resulted. The test now scrolls that paragraph fully into view before applying the same accessibility audit, with no exclusion added. Phone retest result is recorded below when complete.

Initial and final result bundles remain intact; no failed attempt is overwritten. `ui-activities.json` / `final-activities.json` and exported attachment folders under the ignored evidence directory identify the exact failed elements. Xcode emitted a keyboard/layout `Invalid frame dimension` runtime warning and could not collect additional simulator diagnostics through its subprocess's xcrun path; these do not replace the actual result summaries. No source in this batch computes a negative/nonfinite view frame. Full OS-warning root-cause investigation and physical acceptance are not claimed.

## Commands

Use `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer` with the following project command. Results/logs are under `application/.build/sc-d003-2026-10-23/`.

```sh
xcodebuild test -project application/SpeechCoachAI.xcodeproj -scheme SpeechCoachAI \
  -destination 'platform=iOS Simulator,id=7535AD2C-F655-4F05-8C36-FE5E0A614902' \
  -destination 'platform=iOS Simulator,id=709D6F70-328D-4458-8F8A-B2C47A945A80' \
  -derivedDataPath application/.build/DerivedData \
  -resultBundlePath application/.build/sc-d003-2026-10-23/final.xcresult \
  -parallel-testing-enabled NO -only-testing:SpeechCoachAITests \
  -only-testing:SpeechCoachAIUITests/BootstrapLaunchTests/testReviewOptionsPersistAndLimitOneSession \
  CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=-
```

Initial UI selection also included `testOfflineRecallDraftRevealAndRatingRecovery`. Phone retest selects only `testReviewOptionsPersistAndLimitOneSession` and writes `phone-options-retest.xcresult`. SC-D003 vocabulary/scheduler source stayed fixed after final.xcresult; the shared SC-D004 recommendation connection was added for the subsequent integrated-v2 build. Swift syntax parsing passed before the first build; Xcode subsequently compiled final source/tests. The test-only scroll correction does not change product behavior.

## Targeted coverage

ReviewDeliveryTests cover valid/default/rejected controls; retention's effect on future schedules; interrupted-card priority before limits; unchanged full backlog; collection enrollment deduplication; prospective persistence/default restoration; failed-save rollback; stale epoch rejection; reset clearing; shared goal-storage independence/restart/failure; legacy optional-field decoding without invented provenance; and direct-rating refusal of conflicting histories without losing an open draft. Existing scheduler/credit/identity suites cover deterministic ratings, overdue/clock cases, reveal/event deduplication and distinct productive use.

## Remaining acceptance

NOT_RUN in this batch: physical-device options walkthrough, VoiceOver, full appearance/Dynamic Type matrix, minimum OS 17, explicit timezone-travel/device clock changes and owner policy acceptance. Existing valid prior evidence remains scoped to its original source/checkpoint. Actual learner effectiveness, qualified content review, provider-gated sentence coaching and original parent prerequisites retain their separate records. Simulator fixtures do not waive them.

Owner follow-up: open Vocabulary → Review options; choose/save a retention/session size, interrupt a hidden and a revealed recall, reopen, rate once, confirm remaining words in another session and check older due dates after restoring defaults. Verify on the actual phone/tablet, with VoiceOver/larger text and selected appearances. SC-T022/023 cannot close merely because all code is implemented.

## Grok boundary

[Full SC-D004 handoff](../../../../../development-plan/handoffs/grok-sc-d004-2026-10-23.md) is prepared for owner dispatch. Codex changed none of its reserved source/test files. Shared practiceGoal storage is implemented and tested; recommendation fact wiring waits for Grok's defaulted goal input. This is not evidence of Grok execution or SC-D004 completion.


## SC-D003 final result and Grok integration

**SC-D003 PASS:** in `integrated-v2.xcresult`, the review-options journey passes on **both** phone/tablet with the history paragraph fully visible during the unchanged contrast/description audit. It rejects invalid limits, saves/restores 95% and a one-word session after restart, completes that session and offers the remaining due word in the next. Earlier draft/reveal/rating recovery passes remain applicable. [Phone options](screenshots/phone-review-options-saved.png), [tablet options](screenshots/tablet-review-options-saved.png), [phone limited session](screenshots/phone-review-limited-session.png), [tablet limited session](screenshots/tablet-review-limited-session.png).

The first phone-only retest stalled on event synthesis in test setup, before review options, and failed with a tap timeout; [summary](phone-options-retest-summary.json). Restarting only the phone simulator (without erasing data) recovered execution. Subsequent runs have explicit 180-second test timeouts. The earlier `integrated.xcresult` attempt did not run tests because the added Codex UI test used a nonexistent XCTest `lastMatch`; it was corrected to a query plus XCTUnwrap. Both attempts are preserved under the ignored artifact directory.

**Shared integration:** Grok delivered its reserved files and report. Codex supplied the single `goal: stored.practiceGoal` repository argument and registered its new test file. **134 hosted test functions PASS on each simulator**, including all 15 new Grok recommendation/draft/persistence/board tests. [Integrated summary](integrated-v2-summary.json), [exact ownership and build-source hashes](integrated-source-hashes-and-ownership.json). The combined result bundle is marked Failed because the newly added Today UI journey queried child identifiers that the parent today.goal identifier masks at runtime. The accessibility hierarchy exposes the picker and actions with their visible labels, all bearing the parent identifier. Review-options and all hosted results within the same bundle passed. A second query by any element type confirmed the child identifier is masked. The next focused preference-only retest queries the actual visible labels; its result is recorded below. No Grok-owned source/report was modified by Codex.

SC-T046 is now awaiting_testing alongside SC-T047–050. SC-D003 is awaiting testing; original owner/device/prerequisite closure remains. SC-D004 stays partially implemented and SC-T051 in_progress for missing reviewed specialist mappings; goal-domain/UI integration does not close that requirement or SC-T024's reward dependency.


## Final Today preference retest — PASS

`preference-v4.xcresult` passes the focused Today journey on **both simulators**: select Speech Lab through the native menu, explicitly save, see the connected action/reason, restart with the preference retained, clear to the default lesson, then select Review due words and see an unavailable-preference explanation when nothing is due. [Result summary](preference-v4-summary.json). The earlier v3 selector accidentally selected the identically labeled navigation destination; v4 explicitly excludes navigation identifiers when selecting the native menu option. No app source changed to repair these test selectors. Earlier failed attempts remain preserved.

Final successful coverage across the named bundles is **134 hosted test functions on each simulator**, review options and preference UI on both, and the earlier interrupted-recall UI on both. This does not mean the whole initial combined bundle passed; its selector failures and all other limits are retained above.

Inspected final [phone options](screenshots/phone-review-options-saved.png) and [tablet limited-session](screenshots/tablet-review-limited-session.png) screenshots for hierarchy, readable text and complete history/session copy. Final preference screenshots: [phone](screenshots/phone-today-preference-applied.png), [tablet](screenshots/tablet-today-preference-applied.png); unavailable preference [phone](screenshots/phone-today-preference-unavailable.png), [tablet](screenshots/tablet-today-preference-unavailable.png). These are scoped visual inputs, not full appearance/VoiceOver/device acceptance.

[Final source hashes and disjoint ownership](current-source-hashes-and-ownership.json) include the tested selector corrections. All seven Grok-reserved source/test files have unchanged hashes through Codex integration. Codex's shared repository/project edits are separately listed, and Grok's report remains untouched. Canonical ticket/backlog/queue counts and updated ticket hashes were checked: 192 tickets, 11 done, 18 awaiting_testing, 2 in_progress and 161 pending.
