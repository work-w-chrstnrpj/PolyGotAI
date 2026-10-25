# SC-T021 vocabulary link evidence — 2026-10-21

## Current implementation — 2026-10-22

Lesson words now carry meanings into the collection/review path. Saving and adding to review are separate. Lesson speaking opens the existing recording loop and its successful self-review returns to the current lesson without forcing retained audio or typed work. See [first-loop stabilization](../first-loop-stabilization/README.md) for current source, UI handoff, results and limits. The ticket remains in_progress.

## Historical checkpoint below — superseded where the current implementation differs

The ticket stays **in_progress**. A lesson can point at shared word meanings, and the learner can save one card per meaning. This build still has no reviewed Introductions vocabulary, and no review schedule.

## What the code does

- Keeps one collection card for each item and sense. Saving it again, even from another lesson, does not add a second card or replace the first wording.
- Records that the learner saw the word in the lesson. That record is recognition only. It has no rating and no due date.
- Opens speaking with the lesson's objective and source lesson, and leaves the lesson unfinished.
- Refuses to open the introduction recorder for a different objective.
- A blank vocabulary identity keeps that lesson unavailable. A sibling lesson can still open.
- Reset clears the collection. A failed save does not add the new card.

## Check actually executed

`VocabularyLinkTests`, `LessonJourneyTests`, `CurriculumCatalogTests`, and `PracticePreferencesTests` — 14 tests passed on iPhone 18 Pro simulator, iOS 27, in `application/.build/vocabulary-link-v1.xcresult`. The three vocabulary tests were run again in `application/.build/vocabulary-link-v2.xcresult` and passed.

## Still open

Reviewed INTRO-01 senses. Scheduler selection and rated reviews. Specialist practice paths. Device proof for the speaking loop. Qualified educator review remains blocked on SC-T006.
