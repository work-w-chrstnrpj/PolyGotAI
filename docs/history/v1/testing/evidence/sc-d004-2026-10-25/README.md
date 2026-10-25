# SC-D004 regression evidence — 2026-10-25

Scope: [connected focus and evidence repair](../../../development-plan/sc-d004-2026-10-25.md). Native iPhone 18 Pro and iPad A16 simulators, iOS 27.0 build 24A434, Xcode project SpeechCoachAI, ad-hoc simulator signing. Tests use isolated synthetic learner stores and no live provider.

## Initial outcomes retained

- `application/.build/sc-d004-2026-10-25/tablet.xcresult`: PASS, 39 hosted test functions plus two UI functions (42 executions including the parameterized reset). New grammar focus and existing preference restart/error/navigation flows.
- `application/.build/sc-d004-2026-10-25/final.xcresult`: FAIL, 62 selected functions across two devices; 126 executions. The expanded all-four-focus phone UI passed. One stale fallback copy assertion failed on both devices, phone preference test runner was killed, and tablet all-four-focus failed to find the menu after a later fixture launch. Other hosted tests passed. The corrected assertion expects the accurate unavailable-saved-content explanation. Preserve raw bundle, summary, focus activities and exported media under the same ignored raw folder.
- `application/.build/sc-d004-2026-10-25/phone-retest.xcresult`: infrastructure FAIL before either test target connected (signal kill/term). The original phone simulator was observed shut down while another SC-D002 job was active on the phone lane. No assertion ran; do not count this as product evidence.

## Final outcome — PASS across regression and targeted retests

- `tablet-retest.xcresult`: PASS, 18 functions (17 DailyProgressDeliveryTests plus the full four-route UI journey), zero failures/skips. All four focus destinations, restart/Today/Progress and default-off retention passed on iPad A16.
- `phone-isolated.xcresult`: PASS, 18 functions (17 corrected DailyProgressDeliveryTests plus existing preference save/navigation/restart/clear/unavailable fallback journey), zero failures/skips. A dedicated temporary iPhone 18 Pro simulator named SC-D004-Verification (50D36A98-6E31-4374-BB2C-4352E1F8012C), iOS 27.0 build 24A434, avoided the other phone lane. Initial boot was allowed to finish; no existing learner device/store was reset.
- The expanded final.xcresult already passed the other 43 hosted functions and the all-four-focus phone journey. The tablet preference journey passed there too. Together with the corrected suite and targeted UI retests, all 62 selected functions have passing evidence on phone/tablet configurations. This is aggregate evidence across recorded runs, not a claim that the initial failed bundle became green. Parameterized reset adds one execution per device.
- [Raw initial expanded summary](final-summary.json), [tablet retest](tablet-retest-summary.json), [isolated phone retest](phone-isolated-summary.json), [interrupted phone attempt](phone-retest-summary.json), [initial tablet](tablet-summary.json), and [source hashes](source-hashes.json). Raw logs, bundles, exported phone screenshots and failure activities remain under application/.build/sc-d004-2026-10-25/.

SC-D004 is awaiting_testing; SC-T051/052/054 are awaiting_testing. Parent SC-T024 remains pending for SC-T053 and original roll-up prerequisites/acceptance.

## Selected checks

PracticeRecommendationTests, LearningEvidenceTests, PracticePreferencesTests, DailyProgressDeliveryTests, LessonJourneyTests, IntroductionDeliveryTests; BootstrapLaunchTests/testTodayDifficultyFocusPersistsAndOpensPractice and testPracticePreferencePersistsAndConnectsToday. The new UI function iterates grammar/followUp/retrieval/clarity with a fresh fixture each, verifies persisted daily focus after restart, matching Progress focus, exact practice destination, and written retention off for recall/listening. Hosted coverage includes failed commit/epoch rejection, local-day expiry, legacy decode, unavailable/completed/historical courses, reason provenance, comparison identity and weekly attribution.

## Remaining acceptance

Physical VoiceOver/Dynamic Type, owner walkthrough/weekly review, qualified content review, actual learning outcomes and prerequisite closure are NOT_RUN in this batch. Unavailable trainers are not claimed implemented, no content publication or speech score. Parent SC-T024 still depends on SC-T053 rewards and original prerequisites. No migration, live request, learner reset, Git initialization or physical installation.

## Reproduction

Run xcodebuild test with project application/SpeechCoachAI.xcodeproj, scheme SpeechCoachAI, derivedDataPath application/.build/DerivedData, jobs 4, parallel-testing-enabled NO, CODE_SIGNING_ALLOWED=YES and CODE_SIGN_IDENTITY=-. The expanded run selects the six hosted suites and two UI functions listed above on both original simulator UUIDs. Tablet retest selects DailyProgressDeliveryTests plus testTodayDifficultyFocusPersistsAndOpensPractice; dedicated phone retest selects DailyProgressDeliveryTests plus testPracticePreferencePersistsAndConnectsToday. Each run has its unique resultBundlePath/log under the raw folder. The exact invocation is retained at the beginning of each raw log. Swift syntax parse passed before the compiled checks.

Visual review: local Page 1 speechcoach-kit-03.png and exported phone clarity/retention screen inspected; no live Figma or full appearance/accessibility matrix claimed. Documentation local-link, JSON consistency and source-hash checks passed after reconciliation.

The dedicated temporary SC-D004 phone simulator was shut down and removed after the passing run. Existing user/other-task simulators and learner data were preserved.
