# SC-T165 personal vocabulary topics evidence — 2026-10-21

The ticket stays **in_progress**. A learner can type a topic and its words on the device. Generated topics and daily reviews are not included.

## What the code does

- Saves a topic without putting its words into review.
- Keeps one card when the same wording is saved again, including from another personal topic.
- Edits the wording without creating a new card, and refuses a wording that already belongs to a different meaning.
- Adds a word to later review only from the separate save action. That card has no rating and no due date.
- Removes a topic without removing a word already saved for later review.
- Rejects a blank name and a name longer than 80 characters. A failed save leaves no topic.
- Does not require speaking.

The Vocabulary screen uses the existing cards and text fields for Page 1 template T08 (`2:38663`). Live Figma was not reopened.

## Check actually executed

`CustomVocabularyTests` and `VocabularyLinkTests` — 5 tests passed on iPhone 18 Pro simulator, iOS 27, in `application/.build/custom-vocabulary-v1.xcresult`.

## Still open

Cloud generation, subtopic narrowing, level, word count, and purpose. Rated reviews and a scheduler. Reviewed Introductions vocabulary. Device walkthrough of this screen.
