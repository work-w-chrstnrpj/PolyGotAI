# Codex handoff — Round 3: screens and UI tests

Read first: [AGENTS.md](../../../../AGENTS.md), the [round 3 split](../../progress.md#round-3--who-does-what-2026-10-25) and the last entries of [the shared log](../../../../Claude-Codex-Cursor-conversation.md) (LOG-0033 to LOG-0038). Re-read the last entry number before you append; two agents write there.

**Lane:** you own `application/SpeechCoachAI/Features/` views and `application/SpeechCoachAIUITests/`. Claude owns `tools/curriculum/`, `Resources/`, `Domain/`, `Infrastructure/`, docs and `project.pbxproj` (the project is folder-synchronized, so new files need no registration). `AppShell.swift` is shared: touch only the region you need and say so in the log. If a change needs a `Domain/` or `Resources/` edit, write it as a request in your report instead of making it.

**Simulator:** iPhone 18 Pro `7535AD2C-F655-4F05-8C36-FE5E0A614902` through `bash tools/native/verify.sh 7535AD2C-F655-4F05-8C36-FE5E0A614902`. Never share a simulator or DerivedData with Claude (his are the iPhone 18 Pro Max and `application/.build/ClaudeDerivedData`).

## State you start from (commit `f4b5abc`)

- Lesson tab has Course | Coaches; levels lock in order and any locked level opens by its perfect-score test (A2–C2 content is typed). Lexicon has 23 groups: 18 level groups plus five opt-in "Field packs". Speech Lab home: Dictation, Pronunciation, Speaking, Interview, Conversation, Communication, Record an introduction, Saved practice.
- 390 unit tests pass. Three UI tests in `BootstrapLaunchTests.swift` now `throw XCTSkip`: `testOptionalIntroPracticeResumesAndReturnsToCourseDraft`, `testPersonalCheckKeepsFollowUpHiddenAndReturnsWithoutCourseCompletion`, `testLessonSpeakingSelfReviewReturnsWithoutTypingOrRetention`.

## Build, in this order

**X1. Rewrite the three skipped UI tests for the exercise player.** They drive the v1 lesson player (`lesson.begin`, `lesson.response.read-mina`, `lesson.jump.guided-intro`). Keep what each test proves: (a) optional intro practice resumes and returns to the course draft; (b) the personal check keeps its follow-up hidden and returns without completing the course lesson; (c) lesson speaking self-review returns without typing or retention. Use the current screens (`today.lesson`, `learn.open.<lessonId>`, the exercise views in `Features/Learn/Exercises/`). If a behavior no longer exists in v2, delete that test and say why in the report rather than faking it. Use synthetic data and `SC_SPEAKING_FIXTURE`.

**X2. Coach lesson intro screen.** When a learner opens a coach lesson, show the coach (artwork or its SF Symbol), the lesson title and a "Communication practice" chip that opens the existing communication entry. Teacher stays the host for the CEFR course. One helper line at most; no explanatory "not available" copy. Add a UI test.

**X3. iPad Lexicon navigation label under large Dynamic Type.** On iPad the Lexicon tab's navigation label wraps or clips at accessibility sizes (finding from the Phase 3 run). Reproduce on an iPad simulator at the largest text size, fix in `Features/Vocabulary/` or the shell region, and add a large-text UI test. Also check the new "Field packs" section at that size.

**X4. Saved communication practice for older lesson versions.** The Speech Lab "Practice linked to a lesson" list now shows current lessons only (`CommunicationPracticeLauncher`). A saved practice linked to an archived version (for example `a1-greetings` version 3) must still be reachable. Check "Saved practice" and the Communication entry; if such a practice is not listed, add it to the saved list (read-only title "Lesson name · version N"). Unit-test with a synthetic store.

**X5. Phase 5b Interview screen — only after Claude logs "R3-C3 done".** Hands-free Interview: orb, live caption, Repeat and Skip, summary. Claude is building the turn-taking rules, scripted question bank and session model in `Domain/`; you build the screen on top. Do not start X5 before that log entry.

## Rules

- No "unavailable", "not scored", "coming later" text. Buttons are 1–3 words; at most one helper line under a title. Keep existing accessibility identifiers or update the tests that use them.
- Support iPhone and iPad, Dynamic Type, Dark Mode and VoiceOver. No new colors or button styles beyond `DesignSystem.swift`.
- Offline only. No provider calls. Don't log transcripts, audio or learner text.
- Tests use synthetic data and isolated stores. Never reset the owner's learner data.

## Report back (under one page)

Append a `HANDOFF-REPLY` to the log: files changed, tests run with results (including failures), what you could not verify (microphone, real device, iPad if you could not run it), and doc impacts for Claude to apply.
