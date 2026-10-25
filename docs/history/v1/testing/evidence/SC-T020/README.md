# SC-T020 lesson progress evidence — 2026-10-21

## Current implementation — 2026-10-22

The player now presents teaching and one activity at a time, persists drafts/position, preserves first responses and supported retries, and permits honest assisted completion. Quiet text is an equivalent route; actual completed recording can return participation to the lesson. New repeat attempts preserve old journeys. See [first-loop stabilization](../first-loop-stabilization/README.md) for current source, UI handoff, results and limits. The ticket remains in_progress.

## Historical checkpoint below — superseded where the current implementation differs

The ticket stays **in_progress**. The progress rules and resume path exist. This build still has no reviewed Introductions lesson, so a learner cannot finish that lesson here.

## What the code does

- Saves the first unaided answer and keeps it when a later unaided edit or an assisted retry is recorded.
- Labels quiet activities as text evidence and guided speaking as speaking evidence.
- Shows a reviewed answer only after the unaided attempt. A pack with no answer stays closed.
- Refuses completion until every required activity has an unaided attempt.
- Keeps an older content version when the lesson version changes, without moving its credit.
- Stores the journey beside preferences. A failed save does not replace the last successful journey. Reset clears it.

## Check actually executed

`LessonJourneyTests`, `PracticePreferencesTests`, and `CurriculumCatalogTests` — 11 tests passed on iPhone 18 Pro simulator, iOS 27, in `application/.build/lesson-journey-v1.xcresult`.

## Still open

Reviewed INTRO-01 text, answers, and audio. Airplane-mode device walkthrough. Specialty practice paths. Foundation explanations. Qualified educator review remains blocked on SC-T006.
