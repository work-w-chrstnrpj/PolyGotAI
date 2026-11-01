# Round 4 verification evidence

Implementation uses the Round 4 handoff (plan-first execution). X1–X3 are implemented. X4 is in progress; X5 follows the completed verification run and LOG-0053 APIs.

- `r4-dictation.xcresult`: remaining-field microphone test passed (resource title/topic/notes; URL excluded; synthetic insertion).
- `r4-screens.xcresult` and `r4-screens-retry.xcresult`: three presentation/controller tests and five distinct screen tests passed across runs. Two initial accessibility queries failed because a container identifier shadowed its children; the correction passed both retries.
- `r4-ipad-screens.xcresult`: fake feedback/disclosure and synthetic three-stage largest-text Dark Mode checks passed.
- `r4-ipad-final-walkthrough.xcresult`: all five tabs, Course/Coaches, seven Speech Lab entries, and all five tabs in landscape passed label/hit-region audits in Dark Mode. Screenshots copied to `phase-0/1/2/3/5/5b/evidence/round-4/` and here. An earlier successful run hung while finalizing its bundle; rerun saved successfully.
- `r4-four-stages.xcresult`, `r4-polish-recheck.xcresult`: real Grammarian with Starter/Foundation/Intermediate/Advanced and 32 lessons passed on iPad at the largest text size in Dark Mode. Screenshot review caught oversized decorative unit icons; capped their scaling and verified the corrected screenshot.
- `r4-unit-recheck.xcresult`: 436 hosted tests passed against completed Advanced content. The first full-run snapshot had a stale stage/count expectation during Claude's rollout (6 assertions in one test).
- `r4-intro-repair.xcresult`: Introduction draft/resume/completion/vocabulary flow passed after making save/continue actions reachable with the keyboard open. Its original direct taps failed in the full run.
- `verification/run-9LGKFq`: full `bash tools/native/verify.sh 7535AD2C-F655-4F05-8C36-FE5E0A614902` still running; final result to be recorded.

Local artifacts above are under `application/.build/`. iPhone 18 Pro uses `DerivedData`; iPad `2A6AD8BF-57CE-4C58-AF2D-E8D28FF4B856` uses `CodexIPadDerivedData`.

Actual VoiceOver gesture/announcement testing is blocked: computer-use cannot bind Simulator by display name, app path, or bundle identifier. Automated accessibility audits are separate evidence and do not establish VoiceOver acceptance. Real microphone and provider behavior are unverified; all request/credential tests use isolated synthetic fixtures, no live network or owner Keychain values. Nothing committed or pushed.
