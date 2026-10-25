# SC-T049 saved-word recall evidence — 2026-10-21

## Current implementation — 2026-10-22

Recall now resolves lesson and personal meanings, preserves separate collection/review membership, and refuses missing-meaning ratings. Pinned FSRS-6 scheduling and interrupted revealed-card recovery are implemented. Spoken recall/device acceptance remain separate. See [first-loop stabilization](../first-loop-stabilization/README.md) for current source, UI handoff, results and limits. The ticket remains in_progress.

## Historical checkpoint below — superseded where the current implementation differs

The ticket stays **in_progress**. Saved words can be practiced offline. A recognition rating now sets the next due time. See [SC-T046](../SC-T046/README.md).

## What the code does

- Shows the word first and the meaning only after the learner asks.
- Keeps the first typed meaning if they write one.
- Rates Again as a miss, and Hard, Good, and Easy as successful recall.
- Stores the rating on this device and sets the next recognition due time. A rating is not an English level.
- A failed save does not add a second rating. Reset clears the ratings.
- Today offers the practice when words are saved. Progress counts it separately from speaking completions.

## Check actually executed

`VocabularyRecallTests` and `CustomVocabularyTests` — 3 tests passed on iPhone 18 Pro simulator, iOS 27, in `application/.build/vocabulary-recall-v1.xcresult`.

## Still open

Interrupted review recovery beyond the saved due time. Spoken recall as its own recording. Reviewed lesson vocabulary. Device walkthrough of this screen.
