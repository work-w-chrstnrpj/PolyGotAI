# SC-T050 interrupted review evidence — 2026-10-22

Showing a meaning stores an optional `openRecall` on the learner document and does not rate the card. Opening the repository again restores that revealed card. A failed save leaves the open recall and does not add a rating. One successful rating clears it and writes one recall. The same source event still cannot schedule twice.

## Checks

The same simulator result as SC-T048, `application/.build/lesson-review-loop-v2.xcresult`, passed on iPhone 18 Pro, iOS 27, on 2026-10-22. The interrupted-reveal assertions are in `ReviewCreditTests`.

## Limits

Physical iPad walkthrough is NOT_RUN. This does not close SC-T023. Speaking during recall is still not recorded. No live provider request was sent.
