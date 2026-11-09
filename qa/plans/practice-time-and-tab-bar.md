# Test Plan: Practice time and a tab bar that gets out of the way

**Spec:** [issue #3](https://github.com/work-w-chrstnrpj/PolyGotAI/issues/3)
**Owner:** SDET (automation), QA (manual device pass)
**Status:** approved (owner said "approved" together with the ticket breakdown, 2026-11-09)

`qa/strategy.md` is not filled in yet (status NOT_STARTED), so the defaults below use the project's own check: `bash tools/native/verify.sh <simulator-udid>` (build, unit and UI tests).

## Risks

| Risk | Likelihood (1-3) | Impact (1-3) | Score | How we test it |
|---|---|---|---|---|
| Practice time counts when it should not (phone left open on a lesson, idle, app in background) | 3 | 3 | 9 | Unit tests on the practice tracker with an injected clock: idle pause after 2 minutes, background gap over 30 seconds ends a stretch; manual stopwatch check on device |
| Practice time is lost (crash, lock screen, save fails) | 2 | 3 | 6 | Unit test of recovery from the last heartbeat; repository round trip; manual kill-and-relaunch |
| Older learner data fails to load after the schema change | 1 | 3 | 3 | Persistence test: a document written before the change decodes with an empty practice log |
| Tab bar stays visible on a practice screen and blocks buttons (the reported bug) | 3 | 2 | 6 | iPad UI test on every practice screen; manual check on both devices |
| Tab bar hides on a screen that is not a practice screen, or stays hidden after leaving | 2 | 2 | 4 | UI test: bar visible on the five tab roots and on list screens; bar returns after Back |
| Rotation or sheet presentation breaks the hide rule or loses state | 2 | 2 | 4 | UI test rotates once while in a lesson; manual rotation pass |
| Screen time history changes by accident | 1 | 3 | 3 | Existing `UsageLog`/`UsageReport` tests must stay green |
| Totals by area or period are wrong (week/month boundaries, time zones) | 2 | 2 | 4 | Unit tests on the practice report with fixed dates and calendars |

## Scope by level

| Behaviour / criterion | Unit | Integration | API | UI | Manual | Notes |
|---|---|---|---|---|---|---|
| Practice stretch counts only after one minute | x | | | | | Practice tracker (seam 1) |
| Pauses after 2 minutes without touch; idle time not counted | x | | | | x | Tracker; stopwatch check on device |
| Background or lock over 30 seconds ends the stretch; under 30 seconds continues it | x | | | | x | Tracker |
| Crash recovery keeps time up to the last heartbeat | x | | | | x | Tracker plus recorder |
| Totals by day, week, month, year and by area | x | | | | | Practice report (seam 2) |
| Practice log saved and loaded; old documents still decode | | x | | | | Learner repository (seam 3) |
| Practice screens report their area (Lesson, Lexicon, Lab) | | | | x | x | Smoke through the app shell |
| Tab bar hidden on every practice screen, iPhone and iPad | | | | x | x | App shell (seam 4) |
| Tab bar returns after leaving a practice screen | | | | x | x | App shell |
| Progress switch Screen time / Practice time and area breakdown | | | | x | x | Dev ticket 4 adds a UI test |
| Today shows practice time | | | | x | x | |
| Browsing, Settings and Progress do not add practice time | x | | | | x | Tracker fed no practice events |

## Out of scope

- Backfilled history, sync or export, goals or rewards from practice time, XP changes.
- The Round4 Progress "Hit area is too small" failure (tracked separately in LOG-0105).

## Test data and environments

- Synthetic learner data and isolated stores only; never the owner's data (AGENTS.md).
- Simulators: iPad (A16) and iPhone 18 Pro Max (the verify script takes the UDID).
- A physical iPad and iPhone for the manual pass; a stopwatch.
- Anything only a human can do: holding a lesson open untouched for over 2 minutes and killing the app on a real device.

## Entry criteria

- Dev tickets 1 to 4 in `in-review`, `bash tools/native/verify.sh` green for unit tests, build installed on the iPad and iPhone.

## Exit criteria

- `verify.sh` passes (unit and UI tests), the new UI test covers every practice screen on iPad, the manual pass has no open S1 or S2 bug, practice time is within about 5 seconds per minute of the stopwatch in the manual pass.

## Tickets

| Ticket | Type | Blocked by | Covers |
|---|---|---|---|
| Automate: tab bar hides on every practice screen and returns (iPad and iPhone) | automation | dev 1 | tab bar stories 1 to 3 |
| QA: device pass on iPad and iPhone for the tab bar and practice time accuracy | qa | dev 3, dev 4 | stories 1 to 13 by hand |
