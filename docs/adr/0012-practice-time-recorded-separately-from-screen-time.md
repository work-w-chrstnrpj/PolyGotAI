# ADR-0012: Practice time is recorded separately from screen time

**Status:** accepted
**Date:** 2026-11-09
**Ticket:** #7 (spec #3, https://github.com/work-w-chrstnrpj/PolyGotAI/issues/3)
**Input:** none
**Supersedes:** none

## Context

The app measured only screen time: how long it was open. A learner could not see how long they really practised, and leaving a lesson open for an hour looked like an hour of study. Screen time history must stay as it is.

## Decision

Record **practice time** in a new practice log beside the usage log, in the same learner document (ADR-0002). A practice screen reports its practice area (Lesson, Lexicon or Lab) to a recorder, which stores stretches of start, seconds and area, never content. Rules: a stretch counts once it reaches one minute; it pauses after 2 minutes without a touch and the idle time is not counted; it ends when the screen closes, or when the app leaves the foreground for more than 30 seconds (the same merge gap as screen time). The learner document gets one optional field read with `decodeIfPresent`, so older documents load unchanged and no migration runs. The owner approved this schema change on 2026-11-09.

## Alternatives

- Derive practice time from screen time: cannot tell a lesson from a list, and cannot drop idle time.
- Count every second a screen is open: an unattended phone would inflate it.
- A migration with backfill: past practice cannot be known; old days simply have none.

## Consequences

Progress shows Screen time and Practice time side by side, with a Lesson, Lexicon and Lab breakdown, and Today shows practice time. Screen time code and data are untouched. The recorder keeps the open stretch on the device and recovers it after a crash. New practice screens must carry the `.practiceScreen(area:)` marker or they are not counted and keep the tab bar. Idle thresholds are constants in `PracticeTracker`; changing them needs a new ADR.
