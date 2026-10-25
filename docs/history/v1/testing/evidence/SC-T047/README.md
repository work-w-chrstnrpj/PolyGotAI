# SC-T047 review eligibility evidence — 2026-10-21

Recognition schedules only after the learner reveals the answer and chooses Again, Hard, Good, or Easy. A hint is stored on that rating and is not unaided recall. Lesson exposure, a grammar correction, and productive use do not move the recognition due time. The same source-event id does not schedule a second time. Editing the wording keeps the item and sense, so the card stays. A newly added sense does not inherit that due time. A card with no enrollment is not offered.

The rules live in `application/SpeechCoachAI/Domain/ReviewCredit.swift`. Non-rating events are an optional `senseCredits` array on the existing learner document. Older documents still open. No SwiftData migration.

## Checks

Simulator command: `xcodebuild test` for `SpeechCoachAITests/ReviewCreditTests`, `VocabularyRecallTests`, `CustomVocabularyTests`, `ReviewScheduleTests`, and `VocabularyLinkTests` on iPhone 18 Pro, iOS 27. The first run failed one queue assertion because the clock had moved past the due time. `application/.build/review-credit-v2.xcresult` then passed `ReviewCreditTests`. The other four suites passed in `application/.build/review-credit-v1.xcresult`. Device walkthrough remains NOT_RUN. This does not close SC-T046 or the SC-T022 parent. Rewards are not implemented, so a repeated event cannot pay twice because it does not create a second review.

## Limits

No new screen. Productive use is stored and is not an FSRS card. A device pass of the recall screen is still open.
