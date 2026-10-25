# SC-D017 acceptance follow-up evidence — 2026-10-25

[Review, exact defect and repair](../../../development-plan/sc-d017-acceptance-2026-10-25.md). This is Codex work: no Grok completion artifacts were found. All tests use synthetic notes and UUID-isolated learner stores. No owner learner-data reset, physical installation, Git initialization or provider call.

## Runs

Exact test counts, failures and result paths are in [verification.json](verification.json). Raw logs/xcresults are retained under `application/.build/`.

- `sc-d017-acceptance-before-fix`: eight new test definitions, six passed and two failed; six issues expose changed query encoding, wrong saved/opened destination and false duplicate identity. This intentionally failing regression run is preserved.
- `sc-d017-acceptance-phone`: all 247 hosted tests plus two existing resource UI journeys passed. Those journeys exercise save/reopen/edit/search/confirmation/cancel/synthetic refusal/remove/reopen and synthetic-offline save/discard plus a limited viewport accessibility audit.
- `sc-d017-acceptance-ipad`: PASS: 20 focused resource tests and the newly added actual system-handoff/return UI journey. Safari reached the foreground after explicit confirmation; returning preserved the resource library and synthetic notes. This confirms browser foreground/return, not page loading or redirects.

Existing diagnostics include intentional corrupted-store failures, isolated temporary-store cleanup, simulator framework duplication and debugger messages. The before-fix run also emitted an Xcode helper simctl-path diagnostic after reporting the actual test failures. No warning-free claim.

## QA-11 matrix

| Check | Result / evidence |
| --- | --- |
| Destination validation, canonical identity and encoded query meaning through save/reopen/open | PASS — hosted phone suite including eight new test definitions |
| Local titles/notes, search/edit/remove/reopen | PASS — phone simulator UI journey |
| Confirmation Cancel and refused system open | PASS — simulator DEBUG refusal fixture; not a live unavailable-site test |
| Offline save/discard and disabled Open | PASS — simulator DEBUG offline fixture; not an actual path transition |
| Actual system browser handoff and return | PASS — iPad simulator system URL handler foregrounded Safari and returned with notes intact; page loading is not asserted |
| Redirect chain, valid-but-unavailable site and content availability | NOT_RUN — no redirect/content verification claimed |
| Actual offline/online transition | NOT_RUN — no host/device connectivity disruption |
| Complete VoiceOver/largest text/all themes/backgrounds | NOT_RUN — existing limited viewport audit is not full coverage |
| Physical owner use / isolated device deletion | NOT_RUN — phone requires passcode; physical iPad unavailable |
| Original SC-T028 pilot closure | BLOCKED by pending prerequisite; this does not make the implementation ticket globally blocked |

Remaining physical steps: Learn → Learning resources; test a source link and personal bookmark, confirm the canonical destination, cancel then explicitly hand off and return to the library; check a valid-but-unavailable site and redirects; change real connectivity; exercise Light/Dark/System, all backgrounds, largest text, VoiceOver and keyboard; verify saved/restart/failed-protected-data retry/deletion and an isolated approved Delete all. Notes must stay local and intact after failures. Physical/site/owner results require actual execution, not elapsed time or test source inspection.

[Final iPad handoff-return capture](ipad-real-handoff-return.png) was inspected. Its scope is the returned library viewport; full theme/VoiceOver/physical acceptance remains open.
