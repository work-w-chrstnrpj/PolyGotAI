# Codex handoff — Phase 0: Declutter

Read first: [development plan](../../development-plan.md) (workflow and parallel-work rules) and [product spec](../../../product-specification/product-specification.md#ui-copy-rules). Reviewer: Claude. Do not start Phase 1 work.

**Lane boundary:** you own `application/SpeechCoachAI/Features/**` and `application/SpeechCoachAIUITests/**`. Claude is converting `project.pbxproj` to folder-synchronized groups at the same time, so **don't touch `project.pbxproj`** and don't add new files in this phase. Don't edit `Domain/`, `Infrastructure/`, `Resources/` or `docs/`.

## Goal

The app should read like a learning app, not a spec. Remove copy that explains what the app does or can't do, hide features that only show "unavailable", and reduce Today to one clear next step. **No new features, no data/schema changes, no content (JSON) changes.**

## Rules for copy

- Delete any UI text that says something is unavailable, not scored, not assessed, optional, separate, local/on-device, or "not an English level". Keep real error messages (save failed, storage locked, permission denied) — shorten them to one sentence.
- At most one short helper line (≤ 12 words) under a screen title. Section headers: 1–3 words.
- A row/button that leads only to an "unavailable" screen is removed from navigation. Leave the destination code in place (don't delete files) so later phases can re-enable it.

## Changes

**Today** — `Features/Navigation/AppShell.swift` (`TodayContent`)
- Keep: date, greeting + artwork, one card with the suggestion title and its primary button, `RewardSummary` (compact: streak + XP only; badges stay in Progress).
- Remove from Today: "YOUR CONNECTED PRACTICE" label, the reason text when it only restates the title, "Choose a difficulty to practise" menu, "Or choose for today" alternatives, the whole practice-preference `goalCard`, the Word of the Day row, the bottom three-link list, the speaking-completions label, the footer sentence.
- Add: a small "Words to review: N" row (only when N > 0) linking to `VocabularyRecallSession`. Use `storage.repository?.reviewQueue().due.count` (`LearnerRepository.swift:149`); don't add a new query.
- Keep `persist`/`persistDifficulty`/goal code compiling; it's fine if it becomes unused (mark with `// Phase 0: hidden`), or move the preference picker into `SettingsView` if trivial.

**Learn** — `LearnContent` in `AppShell.swift`
- Remove the footer sentence. Move "Learning resources" to the bottom of the list. Keep the level picker and lesson rows.

**Speech Lab** — `SpeechLabContent` in `AppShell.swift`
- Remove: "Make this session yours" card (move coach picker + quiet toggle into a toolbar `Menu` with a `slider.horizontal.3` icon), Generated practice row, "Optional online coaching" card, the bottom presenters sentence.
- Shorten each row's detail to ≤ 5 words (e.g. "Talk through a scenario", "Answer interview questions", "Structure what you say").
- Keep "Record an introduction", Conversation, Interview, Communication, and Saved practice (they stay in Speech Lab).

**Lesson player** — `Features/Learn/LessonPlayerView.swift`
- Intro screen: keep title/objective, the three-step row list and "Let's begin". Remove the "Available offline…" label and the practice-conditions footnotes ("Opened from a lesson…", "If off, only participation…").
- Activity: remove the guided-speaking quiet-practice paragraph (keep the "Open speaking practice" button). After an attempt, replace "Compare your response with the example. Different wording can also be valid." with nothing; replace "…Speech has not been assessed." with "Saved." Remove the "First try:" line when it equals the current response.
- Completion: remove the footnote "Completion records practice, not an English level…".
- Leave the hard-coded `grammar-be-am` / `grammar-be-is` explanations alone (those IDs still exist in the catalog; Phase 1 moves them into JSON).

**Everything else** — apply the copy rules to these files (counts are disclaimer strings found by grep): `ConversationPracticeView` (9), `RewardOverview` (7), `IntroPracticeView` (7), `CustomTopicViews` (6), `SettingsView` (5), `VocabularyDiscoveryView` (4), `RecordingView` (4), `PracticeHistoryView` (4), `VocabularyRecallView` (3), `ResourceLibraryView` (3), `ProgressOverview` (2), `CommunicationPracticeView` (2), `DeliveryFeedbackView` (2), `InterviewPracticeView` (1). Skip `GeneratedPractice/*` and `WordOfDayView` (they are now hidden). `ProviderSettingsView` keeps its cost/privacy disclosure — that one is required.

## Out of scope

Exercise checking, new screens, coach tracks, Speech Lab redesign, catalog JSON, repository/domain logic, persistence, rewards rules.

## Acceptance

1. Today on iPhone shows, without scrolling at default text size: date, greeting, one suggestion card with one primary button, rewards summary, and (if due) the review row.
2. No visible string in the app contains "unavailable", "not scored", "not assessed", "coming later", or "on this device" — except real error states and provider settings.
3. No navigation row opens a screen whose main content is an "unavailable" message.
4. Existing accessibility identifiers used by tests still exist, or the tests are updated in the same change.
5. All tests pass: `bash tools/native/verify.sh 7535AD2C-F655-4F05-8C36-FE5E0A614902` (iPhone 18 Pro).

## Report back (keep it short)

- Files changed, one line each.
- Test result summary (pass/fail counts).
- Screenshots (iPhone, light mode): Today, Learn, Speech Lab, one lesson activity after answering, lesson completion — saved to `docs/development-plan/phases/phase-0/evidence/`. Write the report to `docs/development-plan/phases/phase-0/codex-report.md` (one page max).
- Anything you were unsure about, as a list of questions. Don't guess on those.
