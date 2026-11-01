# UI review: making SpeechCoachAI feel premium — 2026-11-01

Reviewer: Claude (owner asked for a free UI/UX evaluation and fixes that keep every working feature).
Checked on the iPhone 18 Pro Max simulator (light and dark) with a synthetic fixture store.

## What was already good

- A calm, consistent palette per background, real coach artwork, Dynamic Type and VoiceOver work throughout.
- Clear information order on Today (level → lesson → word → badges) and instant answer feedback in lessons.

## What held it back (before)

| # | Area | Problem | Weight |
| --- | --- | --- | --- |
| 1 | Everywhere | Flat white cards on cream with no depth or edge; looks like a form, not a product. | High |
| 2 | Lessons | The tab bar stayed on screen during exercises (`.visible` on the tab root overrode the lesson's `.hidden`), so a lesson never owned the screen and the feedback bar sat under the tabs. | High |
| 3 | Lesson list | Every row had the same book icon and "New"; no sense of a path, position or rank. | High |
| 4 | Feedback | Right/almost colours were fixed RGB values, too dark in Dark Mode; the feedback strip was a flat tinted band that just appeared. | High |
| 5 | Today hero | A 4-pt left stripe made the main card read like a quote block; no coach, no progress. | Medium |
| 6 | Coach grid | Coaches without a portrait showed a big outline symbol on grey, looking like placeholders next to the illustrated ones. | Medium |
| 7 | Rows | Bare 30-pt glyphs with no container; rows looked like a system list. | Medium |
| 8 | Motion | Presses only dimmed; nothing sprang, filled or bounced. | Medium |
| 9 | Progress/level | Thin system progress views; level shown as plain text. | Medium |
| 10 | Launch | White launch screen before the cream app appeared. | Low |
| 11 | Course rank picker | Emoji padlocks in the segmented control. | Low (kept: UI tests rely on the segmented control) |

## What changed (no feature or flow removed)

- **Design system** (`DesignSystem.swift`, `Theme.swift`): `kitSurface()` card look (continuous corners, soft shadow in light, hairline edge in dark) used by every Kit card, tile and dropdown; `kitPressEffect` spring press on all Kit buttons and tappable cards (`.buttonStyle(.kitCard)`); gradient primary button with a soft glow; `IconBadge` (symbol on a tinted rounded square) in every `KitContentRow` and `StatTile`; `KitProgressBar` (gradient, springs to its value); `KitEyebrow` chip; new asset colours `Success`, `Warning`, `Streak` with dark variants; `Kit.Motion` springs; `Kit.Radius.hero`.
- **HeroCard:** eyebrow chip, larger title, optional coach artwork and progress bar, soft accent glow instead of the stripe.
- **Today:** time-of-day greeting with the date (one line), level medal + gradient XP bar, orange streak flame, Teacher artwork and rank progress on the lesson card, play/arrow buttons on coach rows, refined word-of-the-day card.
- **Lesson tab:** rank summary card (A1 · Beginner, N of M done); lessons as numbered nodes (number → play ring → green check); locked rank card with lock badge and gradient bar. Coach units number their lessons too.
- **Coaches:** symbol coaches get a gradient tile in the theme colour; portraits sit on a soft tile; the progress ring turns green with a check at 100%.
- **Lesson player:** tab bar hidden while a lesson is open (iPhone); thicker gradient progress bar; choices spring when picked and the right one is tinted; focused text fields get an accent outline; the feedback panel slides up as a rounded sheet with a bouncing check/cross badge; completion screen shows an animated accuracy ring and one short praise line.
- **Progress:** level medal, larger bar, tinted stat tiles.
- **Launch screen:** uses the Canvas colour (light/dark), so there is no white flash.
- **Dark Mode:** primary buttons drop the glow and sheen (a light halo on a dark canvas failed the contrast audit); cards use a hairline edge instead of a shadow.

## Verification

- 446 unit tests pass. Targeted UI suites (Bootstrap, Phase 2, 3, 9, 12, 13, 15, 16, Round 4 screens and accessibility, Progress usage): 53 passed, 2 failed; after the Dark Mode button fix `testDarkAppearance` passes.
- `Phase12PronunciationTests.testPronunciationReadingAtLargestTextInDarkMode` ("Cannot reach track.unit.stress-rhythm") also fails on the last commit (`1197d04`), so it predates this work.
- Test trap found: after hours of test runs the simulator's default store reached the "5 hours of practice time" milestone; the celebration overlay then kept the app from going idle and Bootstrap tests hung at launch. Dismiss it (or reset the simulator store) before a long UI run.
- Not checked: iPad, the full UI suite in one run, the owner's device.

All accessibility identifiers and the visible strings UI tests look for ("Correct!", "Not quite", "Level N", "% right on the first try") are unchanged. Decorative nodes, rings and medals are hidden from VoiceOver; the text beside them is spoken.

## Recommended next (not done)

1. Badge artwork for the 14 symbol-only badges; unearned badges as greyed silhouettes with a lock.
2. A short first-launch welcome (pick background, goal, rank) — today the app opens straight onto Today.
3. Animate the lesson progress bar between exercises (the exercise view is rebuilt per item, so the bar jumps).
4. Replace the emoji padlocks in the rank picker with a custom control, updating `Phase2LessonTests`.
5. App icon and a widget for the word of the day and streak.
6. iPad pass on the new cards at regular width (not checked in this round).
