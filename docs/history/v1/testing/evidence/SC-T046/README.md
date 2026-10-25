# SC-T046 scheduler selection evidence — 2026-10-21

The ticket stays **in_progress**. Recognition reviews now get a next due time. The parent scheduler policy is not closed.

## Decision

FSRS-6.0, MIT license, swift-fsrs commit `d09cfc96c8f4c135ffc1905ac5627672906bf421`, vendored at `application/Vendor/swift-fsrs`. Desired retention 0.90. Maximum interval 36,500 days. Fuzz off. Learning steps are 1 minute and 10 minutes, so a new card's Hard step is 6 minutes.

Not selected: a fixed day ladder, SM-2, and swift-fsrs v5.0.0. That release is FSRS-5 only, and there is no newer tag. The owner has not picked a different retention.

## What the code does

- A saved word is ready for a first rating. Saving it, or meeting it in a lesson, does not set a due time.
- Again, Hard, Good, and Easy on a revealed meaning write one recognition card.
- A new Again comes back in 1 minute, Hard in 6 minutes, Good in 10 minutes, and Easy in 8 days.
- Practice shows words that are due and waits on the others. Today says when words are ready.
- A clock time before the card's last review is refused. An unknown scheduler version is left unchanged.
- A failed save does not add a second rating or move the due time. Reset clears the card.

## Check actually executed

`ReviewScheduleTests`, `VocabularyRecallTests`, `VocabularyLinkTests`, and `CustomVocabularyTests` — 11 tests passed on iPhone 18 Pro simulator, iOS 27, in `application/.build/review-schedule-v1.xcresult`.

The Practice screen reuses the existing recall layout. Live Figma was not inspected again for this change.

## Still open

Productive-use cards. Fitting parameters to this learner. SC-T047 rules for edited senses and duplicate events. A device walkthrough. SC-T022 is not closed.
