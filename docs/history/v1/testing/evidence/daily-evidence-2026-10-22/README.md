# Daily suggestion and progress evidence · 2026-10-22

Scope: SC-T051, SC-T052, and SC-T054. Parent SC-T024 stays open. SC-T053 and the reward tickets are not in this batch. SC-T023 stays open for device acceptance of review.

## Implementation and behavior

- Today shows one reason. A saved choice for the local calendar day wins when that destination is still available, and the grounded reason stays visible. Otherwise the newest supported difficulty wins. At the same time, grammar outranks retrieval, then follow-up, then clarity. An undated observation loses to a dated one. With no difficulty, due reviews come first, then a ready or unfinished lesson, then Speech Lab.
- Retrieval comes from a revealed Again rating or vocabulary feedback. Grammar comes from an assisted or revealed grammar response or grammar feedback. Follow-up and clarity are reported observations. Organization feedback is not a follow-up. Duration and completion do not invent those difficulties.
- Copy does not name Librarian, Grammarian, Journalist, Speaker, Business Professional, Writer, or Teacher as a session. It does not claim a CEFR or English-level placement.
- Progress keeps recognition, recall, productive use, retention, and transfer on separate rows. A recall today is not retention. Confidence is an optional note of at most 280 scalars. There is no XP.
- A saved take is paired only after the learner labels it on the practice detail. The four labels are baseline, related practice, same prompt again, and unfamiliar transfer. App-created attempts are self-review support. A pair is comparable only when the rubric matches, both supports are independent, both are speaking, and both voices can be replayed. Every link says no proficiency change is shown. Missing or deleted voice turns replay off. Text is not speech.
- The week counts speaking self-reviews, saved speaking time only while the voice remains saved, text answers on completed lesson journeys, and recall ratings inside the calendar week. An empty week is a quiet week, not a change in English level. The narrative does not say the learner improved. Deletion recomputes from the records that remain.
- Optional `dailyChoice`, `confidenceNote`, and `attemptFormats` live on the existing preferences document. Older documents still open. There is no SwiftData migration. Delete-all clears the choice, the note, and the labels.

## UI handoff

- Visual source: Page 1, file B1A9qEN1B7I3NJKISX39Dx, dated local 2026-10-17 screenshots. No fresh live Figma inspection or cloud-sync claim.
- Recipes: T01 2:37969 (Today) and T09 2:38732 (Progress).
- Translation: existing Kit card, content row, primary button, and availability card. The comparison label is a native menu. The confidence note is a labeled text field. No new color tokens and no custom motion.
- Sources: `Features/Navigation/AppShell.swift`, `Features/Progress/ProgressOverview.swift`, `Features/History/PracticeHistoryView.swift`, `Domain/PracticeRecommendation.swift`, `Domain/LearningEvidence.swift`.
- The repaired Today lesson button, `today.lesson`, stays. The reason is `today.suggestion`. Returning to the grounded suggestion clears the day's choice. Progress history, including `progress.completions`, stays below the new overview.

## Verification

- PracticeRecommendationTests, 7 passed, and LearningEvidenceTests, 5 passed. iPhone 18 Pro simulator `7535AD2C-F655-4F05-8C36-FE5E0A614902`. `application/.build/daily-evidence-2026-10-22/recommendation-v3.xcresult`.
- LessonJourneyTests, 7 passed, in the preceding `recommendation-v2.xcresult`, after the preferences document gained the optional fields.
- The first test compile failed because Swift Testing treated `allSatisfy` with a key path as throwing. The assertions now use ordinary Booleans. One recognition sentence was also corrected so it says "not a level".
- Today contrast and the existing progress/history speaking-loop journey: 2 passed, 0 failed, same simulator, after the final Today source. `application/.build/daily-evidence-2026-10-22/today-progress-ui-v2.xcresult`. `today.lesson` and `progress.completions` still resolve, and the history replay, delete, and restore path completed. This is a simulator result. Physical-device, manual accessibility, owner walkthrough, and learning acceptance remain open.

## Remaining acceptance

No live calls were sent. Follow-up and clarity are not inferred. Specialist packs are not offered. Unlabeled takes are not paired. SC-T023, SC-T024, and SC-T053 stay open. Rewards, four-week learning, and curriculum expansion are outside this batch.

```sh
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
xcodebuild test -project application/SpeechCoachAI.xcodeproj -scheme SpeechCoachAI \
  -destination 'platform=iOS Simulator,id=7535AD2C-F655-4F05-8C36-FE5E0A614902' \
  -derivedDataPath application/.build/DailyEvidenceDerivedData \
  -resultBundlePath application/.build/daily-evidence-2026-10-22/recommendation-v3.xcresult \
  -only-testing:SpeechCoachAITests/PracticeRecommendationTests \
  -only-testing:SpeechCoachAITests/LearningEvidenceTests \
  -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=-
```

Use a fresh result path on rerun. Existing xcresult bundles are preserved.
