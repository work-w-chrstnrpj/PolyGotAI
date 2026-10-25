# Phase 2 — Lesson restructure

**Goal:** the Lesson tab becomes **Course | Coaches**. The Course gets an ordered level lock with one-level jump tests. Coaches get a flat grid, with the Grammarian as the first track.

**Status:** PLAN written. Waiting for the owner to approve before work starts.

Specs: [Course rules](../../../product-specification/product-specification.md#course-cefr-a1c2) · [coach presentation](../../../product-specification/coach-tracks.md#how-coaches-are-presented-owner-approved-2026-10-25) · [development plan](../../development-plan.md).

## Scope

| # | Task | Lane |
| --- | --- | --- |
| 2.1 | Track catalog: `Resources/Tracks/*.json`, model, loader, validator; new coach cases (placeholders for the four new characters) | Claude |
| 2.2 | Grammarian Units 1–2 (2 units × 4 lessons, Starter stage, original wording, sources credited) | Claude |
| 2.4 | `LevelGate`: unlocked levels, finish-level unlock, jump-test pass rule, storage without a migration; unit tests | Claude |
| 2.5 | A1 → A2 jump test: 20-item builder from A1 typed exercises, perfect-score rule; unit tests | Claude |
| 2.3 | Course \| Coaches switch; coach grid and Continue card; coach screen (stage chips, unit cards); unit lesson list | Codex |
| 2.6 | Locked level picker and jump-test screen; UI tests | Codex |

Out of scope: tests for A2 and higher (Phase 4), other nine coaches' content (Phase 4), Lexicon (Phase 3), any change to the lesson player's exercise flow.

## Decisions this phase follows

- **Level lock** (decision 8, confirmed by the owner 2026-10-25): finishing a level's lessons also unlocks the next one; unlimited retakes with new question order; levels already opened in v1 stay unlocked; no SwiftData migration (derive from completed lessons plus a passed-test record; ask the owner before any schema change); until a level's test exists, only finishing the previous level unlocks it.
- **Coaches are not locked.** Stages are a suggested order.
- **Jump test rules:** 20 items, every A1 topic at least once, drawn from the typed exercises; no re-queue of wrong items; instant right / not-quite feedback as in lessons; "almost" counts as not correct; pass = 20 of 20. Result screen: one line, "Perfect. A2 is open." or "18 of 20. Try again."
- **Copy:** no explanation text. A locked level shows a lock and one action, "Take the A2 test".

## Order of work

1. Claude builds 2.1, 2.4, 2.5 (and 2.2 content in parallel). Claude then appends a `HANDOFF-READY` note to the log with the final API.
2. Codex starts 2.3 and 2.6 only after that note ([handoff](codex-handoff.md)).
3. VERIFY: Claude reviews, integrates, runs `tools/native/verify.sh`, checks iPhone and iPad (portrait and landscape) with screenshots in `evidence/`.

## Done when

- From a fresh A1 learner, C2 cannot be opened; A2 opens only after a perfect jump test or finishing A1.
- A failed test unlocks nothing and can be retaken.
- Coaches tab shows the Grammarian with Starter stage, 2 units, 8 lessons; its lessons play in the existing player with checked exercises.
- Existing learner data launches unchanged; the owner's v1-opened levels stay unlocked.
- `verify.sh` passes; the owner has tried it and approved.
