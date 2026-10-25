# Codex handoff — Phase 2: Course | Coaches and the level lock

Read first: [AGENTS.md](../../../../AGENTS.md), the [development plan](../../development-plan.md) (workflow and parallel-work rules), the [Phase 2 brief](README.md), and the [coach presentation](../../../product-specification/coach-tracks.md#how-coaches-are-presented-owner-approved-2026-10-25). Reviewer: Claude. Do not start Phase 3 work.

**Do not start until** Claude has appended a `HANDOFF-READY` entry to [the log](../../../../Claude-Codex-Cursor-conversation.md) with the final API. The types below are the contract; if Claude's final names differ, the log entry wins.

**Lane boundary:** you own `application/SpeechCoachAI/Features/**` and `application/SpeechCoachAIUITests/**`. Don't edit `Domain/`, `Infrastructure/`, `Resources/`, `docs/` or `project.pbxproj` (new files under the source folders need no registration). If you need an API change, append a `QUESTION` to the log.

**Claude is working in parallel on Phase 3 (Lexicon)** in the same working tree. To avoid collisions:
- In `AppShell.swift`, edit **only** `LearnContent` and the `case .learn:` line. Claude edits only `case .vocabulary:` and `TodayContent`. Read the file right before each edit and make small targeted edits, never a whole-file rewrite. Put new views in new files under `Features/Learn/`.
- Don't touch `Features/Vocabulary/**`, `Domain/Lexicon*`, `Infrastructure/Lexicon/` or `Resources/Lexicon/`.
- The project is folder-synchronized, so new files appear in the build on their own. If the build breaks in a file you don't own, wait a few minutes and rebuild; it is probably Claude mid-edit. Use your own DerivedData (`application/.build/DerivedData`) and the iPhone 18 Pro simulator, as the verify script does.
- Run only your own tests while you work (`-only-testing`); run the full `verify.sh` once at the end.

## Goal

The Lesson tab shows **Course | Coaches**. The Course level picker obeys the level lock. Coaches appear as a flat grid, then stage → unit → lesson. No explanation text anywhere: at most one helper line under a title.

## API you can rely on (built by Claude)

All of this is built, compiled and unit-tested (`Domain/LevelGate.swift`, `JumpTest.swift`, `TrackCatalog.swift`; tests in `LevelGateTests.swift`). Read those files for exact signatures.

- **Level gate:** `storage.levelGate(install:) -> LevelGate` (re-evaluates after `recordJumpTestPass`; read it inside the view body so it refreshes). `LevelGate.levels` (A1…C2), `isUnlocked(_:)`, `unlockedLevels`, `nextLockedLevel`, `canTakeJumpTest(to:)` (true only for the first locked level, and only when its test exists; today only "A2").
- **Jump test:** `JumpTest.make(target: "A2", install:) -> JumpTest?` (fresh order each call; nil if no test). A `@State var test: JumpTest`. Use `test.current` (`JumpTest.Item` with `.activity: CurriculumActivity` for the exercise views, `.spec`), `test.submit(_ ExerciseResponse) -> AnswerResult?`, `test.advance()`, `test.position`/`total`/`progress`, `isFinished`, `isPerfect`, `correctCount`, `resultLine`. Wrong items are not re-asked and "almost" is not correct, but show the normal feedback. When `isPerfect`, call `storage.recordJumpTestPass(level: test.target)` once (returns false if it could not be saved: then show the same one-sentence error as elsewhere).
- **Course lessons:** unchanged: `install.lessons(at:)`. Check `gate.isUnlocked(level)` before showing a level's lessons.
- **Coach tracks:** `install.tracks` (a `TrackCatalog`): `tracks: [Track]` (only coaches that have ready lessons, in `TrackCoach` order), `Track { id, coach: TrackCoach, title, tagline, stages: [TrackStage], lessons }`, `TrackStage { id, title, units: [TrackUnit], lessons }`, `TrackUnit { id, title, lessons: [ResolvedLesson] }`. `Track.completedFraction(journeys:)` feeds the progress ring; `install.tracks.continueLesson(journeys:)` feeds the Continue card; `LessonProgress.of(lesson, journeys:)` gives `.state` (new, inProgress, done) and `.accuracy` for rows (works for Course lessons too). Journeys: `try storage.repository?.allLessonJourneys()`.
- **Coaches (not `LearnerPreferences.Coach`):** `TrackCoach` (10 cases) has `title`, `tagline` (one line), `artwork` (asset name, or nil) and `symbol` (SF Symbol placeholder when `artwork` is nil). Don't add cases to `LearnerPreferences.Coach`.
- **Playing a track lesson:** `LessonPlayerView(storage:lesson:install:onSpeak:)` with `install: CurriculumCatalogLoader.bundled` works for track lessons as for course lessons (`install.lesson(id:version:)` resolves them).
- **Content now in the app:** the Grammarian track (Starter stage; units "sentences" and "be-have-do"; 4 lessons each; 13 activities each, the last an open "Your turn").

## Changes

**Lesson tab** — `LearnContent` in `Features/Navigation/AppShell.swift` (move the new views into `Features/Learn/` files)
- Header: title, one-line tagline, segmented switch **Course | Coaches** (`learn.mode`). Remember the last choice for the session.
- **Course:** keep the lesson rows and ids (`learn.open.<id>`, `learn.availability`, `learn.resources`). The level picker (`learn.level`) shows a lock on locked levels; selecting one does nothing except show a single button **Take the A2 test** (`level.test.<level>`) for the next level only. Higher locked levels show only the lock.
- **Coaches:** flat grid of cards (`coach.card.<trackId>`): artwork or placeholder, name, one-line tagline, thin progress ring. Two columns on iPhone, three or four on iPad, one column at accessibility Dynamic Type sizes. A **Continue** card (`coach.continue`) above the grid when a coach lesson is in progress. Show only tracks in `TrackCatalog.tracks`; no placeholder or "coming soon" cards.
- **Coach screen:** artwork, name, tagline; stage chips (`track.stage.<stageId>`); one card per unit (`track.unit.<unitId>`) with lesson count and progress bar.
- **Unit screen:** lesson rows with title, state (new, in progress, done) and accuracy; open in the existing `LessonPlayerView`.
- **Jump test screen:** reuse the exercise views in `Features/Learn/Exercises/`; header "A2 test" and a count (3 of 20); feedback bar as in lessons but no re-queue; result screen with one line ("Perfect. A2 is open." or "18 of 20. Try again.") and one button (**Done** or **Retry**). Identifiers `jumptest.*`.
- Keep Dynamic Type, Dark Mode and VoiceOver working; locked levels read as "A2, locked".

**UI tests** — `SpeechCoachAIUITests/`
- A fresh learner sees A1 open and C2 locked, and cannot open C2 lessons.
- Tapping **Take the A2 test** opens the first question; a wrong answer ends in "Try again" with A2 still locked.
- Coaches tab shows the Grammarian card; open it, choose a stage, open a unit and a lesson.
- Course | Coaches switch keeps the selected tab and works in iPad portrait and landscape.
- Use the existing launch-argument pattern for isolated stores; ask Claude for a hook if you need a pre-passed test.

## Rules

- No copy that explains the lock or what's unavailable. Button labels 1–3 words.
- Keep `LessonPlayerView` behavior unchanged; do not touch exercise logic.
- Do not read or write learner storage directly; use `LevelGate`, `JumpTest` and the existing storage controller.

## Report back (under one page)

Append a `HANDOFF-REPLY` to the log: files changed, test results (including failures), 3–6 screenshots in `phases/phase-2/evidence/`, doc impacts, questions. Run `bash tools/native/verify.sh 7535AD2C-F655-4F05-8C36-FE5E0A614902`.
