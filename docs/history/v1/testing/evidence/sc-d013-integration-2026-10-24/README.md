# SC-D013 local integration evidence — 2026-10-24

Scope: owner-authorized real-target integration of repaired Conversation/Interview sources. See the [implementation record](../../../development-plan/sc-d013-integration-2026-10-24.md). All new UI journeys use a UUID-isolated `SC_SPEAKING_FIXTURE` store and synthetic text/audio; no live request or learner-data reset occurred. Original qualified, provider, physical, learner and release acceptance remains open.

## Executed runs

| Run | Result | Evidence |
| --- | --- | --- |
| Initial real-target build + hosted repair suite | PASS: 16 tests | `application/.build/sc-d013-connect-first.xcresult` |
| Intermediate integrated compilation | FAIL: missing MainActor annotations on two new UI tests, then missing nested try in a test assertion | `sc-d013-connect-integrated.xcresult`, `sc-d013-connect-phone.xcresult`; corrected test source |
| iPhone integrated v2 | 20 hosted tests and conversation recovery/discard PASS; interview UI FAIL before role entry | `sc-d013-connect-phone-v2.xcresult` |
| iPhone v3 diagnostic | 22 hosted tests PASS; interview navigation still FAIL | `sc-d013-connect-phone-v3.xcresult` |
| iPhone v4 | Interview recording/return/follow-up/discard PASS | `sc-d013-connect-phone-v4.xcresult` |
| iPad integrated | PASS: 174 hosted tests across 22 suites plus both new UI journeys | `sc-d013-connect-ipad.xcresult` |

The interview setup failure was a test tap hitting the floating iPhone tab bar over the offscreen link. The reachability helper now requires the control's full frame above that bar before tapping. No unsuccessful run was discarded. Later source polish adds exact-answer recording confirmation, retry-opening after a protected-data/load failure, and explicit audio availability wording. The final iPhone run below verifies those changes and an additional own-session audio purge regression.

## Final iPhone result

PASS: **175 hosted tests in 22 suites and both connected UI journeys** (177 reported tests, zero failures), real project, `sc-d013-connect-final-phone.xcresult`. This run includes final draft-load retry, retention wording, exact opening-answer attachment confirmation and own-session synthetic audio purge. Source hashes matched the final compiled source at evidence collection. The AVAudioSession main-thread responsiveness warning remains recorded in verification.json; test success does not establish physical audio acceptance.

## Journeys and assertions

- Conversation: Speech Lab navigation, local setup, explicit 24-hour draft save, termination/relaunch with exact draft restoration, submit, disabled online action, end/discard, relaunch with no discarded sentinel.
- Interview: Speech Lab navigation, role setup, exact independent recorder prompt, synthetic take/replay selection/self-review completion, return to the opening answer with explicit attachment confirmation, submitted-answer-dependent local follow-up, disabled online action and discard.
- Hosted additions: Codable/repository reopen, expiry removal, stale delete-all epoch refusal, unresolved request → unknown outcome without resend, exact private recorder provenance without course link, failed-write rollback and sanitized final archive. Final run adds actual synthetic audio purge with rejection of another session's reference.
- Existing hosted regression suite includes exact-version A1/v2 journey and repository behavior. No catalog/version resource was changed in this integration.

Simulator identifiers: iPhone `7535AD2C-F655-4F05-8C36-FE5E0A614902`; iPad A16 `709D6F70-328D-4458-8F8A-B2C47A945A80`; both iOS/iPadOS 27.0 simulator. Real project/scheme: `application/SpeechCoachAI.xcodeproj`, `SpeechCoachAI`. Derived data: `application/.build/SC-D013IntegratedDerivedData`. Ad-hoc simulator signing uses `CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=-`.

Repeat the final focused integration with:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild test \
  -project application/SpeechCoachAI.xcodeproj -scheme SpeechCoachAI \
  -destination 'platform=iOS Simulator,id=7535AD2C-F655-4F05-8C36-FE5E0A614902' \
  -derivedDataPath application/.build/SC-D013IntegratedDerivedData \
  -parallel-testing-enabled NO \
  -only-testing:SpeechCoachAITests \
  -only-testing:SpeechCoachAIUITests/BootstrapLaunchTests/testConnectedConversationDraftRecoveryAndDiscard \
  -only-testing:SpeechCoachAIUITests/BootstrapLaunchTests/testConnectedInterviewRecordsAndReturnsToExactAnswer \
  CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=-
```

## Limits

Saved audio playback/deletion remains in existing History. Simulator capture/fixtures do not prove physical microphone/route quality, accessibility, learner effectiveness or online provider access. The restored latest-session slot is not a multi-session transcript library. Original SC-T148/149/150/151/152/153 criteria and prerequisite closure remain authoritative; local-preview success does not make the full AI conversation implementation complete. SC-T035/150/151 remain in_progress. Grok's dispatched SC-D014 is separate.

Raw logs/xcresults remain ignored under `application/.build/`. Sanitized screenshots alongside this file show the executed iPad setup/discard screens; iPad screenshots precede the final retention-copy/retry polish. Final source hashes and run results are in `verification.json`.
