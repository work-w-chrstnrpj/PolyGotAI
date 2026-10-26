# Phase 7 — Look and clean-up

**Status:** APPROVED by the owner 2026-10-26 after a play-test on the iPhone; commit `d41aa00`. C8 coach art follows when the images arrive.

## Goal
1. The app looks like one designed product and follows Apple's guidelines.
2. Each theme changes the whole look, not only the background.
3. Today shows where you are.
4. Progress can be read at a glance.
5. No v1 leftovers remain.
6. Erase all data works behind Face ID or Touch ID.

## Claude lane (core, assets, project file, docs). Do C1 first, because Codex builds on it.
- **C1 Theme tokens.**
  - Add `Features/Shared/Theme.swift`: a `KitTheme` value per background, with accent, on-accent, soft tint and chart colours, each with a dark variant.
  - Add new colorsets: Academy stays green; Atlas and Studio get their own accent.
  - Inject the theme through the SwiftUI environment from `AppShell`; `Kit.accent` reads it.
  - Set `.tint` per theme so switches, links and progress bars follow it.
  - Add a type scale and spacing constants.
- **C2 Rank copy.** CEFR A1–C2 is called "Rank" in every screen string (Rank A1, rank test, locked rank). "Level" means only the XP level. Code names stay.
- **C3 Delete v1.**
  - Remove: `Features/Communication`, `Features/GeneratedPractice`, Record an introduction (the `RecordingView` entry from the Lab), the lesson player's "Communication practice", the v1 evidence cards in Progress ("This week" prose, "What the record can show"), and the `CoachArtwork` "Artwork coming later" text.
  - Then delete their now-unused domain code, tests and stored fields. The owner allows dropping old data, so bump the schema only if it is truly needed; a clean store via Erase is fine.
- **C4 Today "current lessons".** Add `CurrentLessons`, which returns:
  - the next course lesson at your highest open rank, resuming any unfinished one;
  - up to two coach lessons in progress, or the next one in the last-used coach;
  - words due as a separate count.

  It replaces `PracticeRecommendation` for Today.
- **C5 Erase all data core.**
  - Add `LearnerReset`: gate it with `LAContext.evaluatePolicy(.deviceOwnerAuthentication)`, so it uses Face ID or Touch ID with passcode fallback.
  - On success it closes storage, deletes the SwiftData store, private files and audio, the Keychain provider key, `UserDefaults` and scene storage, then reopens fresh at first launch.
  - Add `NSFaceIDUsageDescription` in the project file.
  - Unit tests run against an isolated store and a fake authenticator. Never run them against the owner's data.
- **C6 Copy audit.** `tools/native/copy-audit.sh` fails on banned screen phrases ("unavailable", "not scored", "not a level", "coming later", "not assessed", "placement") in Swift string literals. Add it to `verify.sh`.
- **C7 Split `LearnerRepository`** into extensions by area, with no behavior change. Do this last.
- **C3b (after X2 and X3).** Delete `PracticeRecommendation`, `LearningEvidence`, `LearnerRepository+Today.swift`, the introduction lesson's extra practice and checks (`IntroPracticeView`, `IntroductionReviewView`, `IntroCheck*`), and `ProgressOverview`'s evidence card if Codex has not; the copy audit passes after this.
- **C8 Coach art.** When the owner's images arrive, add them to the asset catalog and map them in `TrackCatalog.artwork`.

## Codex lane (screens, UI tests)
- **X1 Design system v3** in `DesignSystem.swift`: `HeroCard`, `StatTile`, `ProgressRing`, `BadgeTile`, `SectionHeader`, and primary and secondary button styles. Everything reads the theme; no fixed colours.
- **X2 Today**:
  - XP ring with "Level N" and a streak tile;
  - "Continue" cards for the course lesson and coach lessons, from `CurrentLessons`;
  - the Daily Lexicon card;
  - a strip of the last 3 earned badges that opens Badges.
- **X3 Progress**:
  - top row of 3 stats: Level, streak, minutes this week;
  - a week bar chart with Swift Charts, with Day, Week, Month and Year kept;
  - a grid of earned badges with artwork, and "See all";
  - the next 3 milestones with progress bars, and "Show all".

  At most one helper line on the screen. Practice history moves behind a link.
- **X4 Settings** › "Erase all data": a destructive row, a confirm alert, then the biometric prompt, with a single error line on failure.
- **X5 HIG pass on Today, Lesson, Progress and Settings**:
  - large titles on root tabs;
  - `List` with inset-grouped style for navigation lists;
  - one prominent button per screen;
  - consistent symbol weights.

  Lexicon and the Lab are redone in Phases 8 and 9; give them only theme fixes.

## Gate
- `verify.sh` passes, including the copy audit.
- Screenshots on iPhone and iPad: 3 themes × light and dark, for Today, Progress, a lesson and Settings.
- Erase was tested on the simulator, including a cancelled authentication.
- **The owner plays the build on the iPhone and approves it.**
