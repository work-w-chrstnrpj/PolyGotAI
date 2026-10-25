# SC-T048 collection and review evidence — 2026-10-22

A lesson or personal topic can save a word to the collection without putting it in the due queue. Add to review uses that same item and sense. Repeating either action does not create a second card. An older enrollment with no `inReview` field still opens as in review. No SwiftData migration.

The buttons are on the existing lesson player and topic card. They reuse the current card layout and stay at least 44 points tall.

## Checks

Simulator command: `xcodebuild test` for `ReviewCreditTests`, `VocabularyLinkTests`, `VocabularyRecallTests`, and `CustomVocabularyTests` on iPhone 18 Pro `7535AD2C-F655-4F05-8C36-FE5E0A614902`, iOS 27. `application/.build/lesson-review-loop-v2.xcresult` passed 9 tests on 2026-10-22, including `aCollectionSaveIsNotDueAndAnInterruptedRevealIsNotRated`.

## Limits

Physical iPad walkthrough of Save to collection and Add to review is NOT_RUN. This does not close SC-T022 or SC-T023. Spoken recall on the practice screen is still not recorded. No live provider request was sent.
