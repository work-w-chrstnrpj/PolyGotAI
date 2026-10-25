# Phase 2 — Codex verification handoff

2026-10-25 · Plan-first execution of LOG-0014 / `phase-2/codex-handoff.md`. **Implemented; verification incomplete; awaiting Claude review.**

Changed `AppShell.swift` → `LearnContent` only; added `Features/Learn/{CourseCatalogView,CoachCatalogView,JumpTestView}.swift` and `SpeechCoachAIUITests/Phase2LessonTests.swift`. Claude's Lexicon regions and lesson-player, exercise, domain, storage, resource and project files were preserved.

Implemented Course | Coaches session retention, gated levels, ready-coach grid/progress/Continue, stage → unit → lesson navigation, lesson state/accuracy, and jump-test feedback/result/retry/perfect-pass save. The result destination stays registered after unlocking; a failed save offers Save again. Visual inputs were the existing DesignSystem and dated local Page 1 screenshot `speechcoach-kit-03.png`, without live Figma inspection.

## Verification

- Build-for-testing and `git diff --check` passed. Final sources compiled and launched tests.
- Earlier focused checks passed: fresh A1/C2 gating; all 20 failed-test questions, Retry and relaunch with A2 locked; coach lesson/Continue; mode retention and rotation on iPhone and iPad.
- Latest serial iPhone run: **2 passed** (actual Dark Mode/accessibility and coach/Continue), then **launch timeout before Lesson opened**; two cases did not run. Log: `application/.build/phase2-final-focused.log`.
- iPad (A16): **2/3 passed** (coach/Continue and mode/rotation). The large-text audit flagged the existing **Lexicon navigation label**: “Dynamic Type font sizes are partially unsupported” (LOG-0016). No suppression added.
- Required `bash tools/native/verify.sh 7535AD2C-F655-4F05-8C36-FE5E0A614902`: **349 unit tests and four existing UI cases passed**; `testCommunicationDraftSharesExactSourceAcrossLearnAndSpeechLab` failed waiting for `communication.answer`; Interview stalled. Stopped with exit 143; **no full-suite pass**. Log: `application/.build/verification/run-gYJHvz/test.log`.

Initial identifier inheritance and empty jump-test startup defects were fixed and retested. Dark Mode now uses the existing isolated fixture. Screenshot capture now uses the whole screen with rotation geometry waits. Earlier result collection overlapped full-run startup and may have contributed; a later serial retry also stalled. A sample showed the main thread idle in its run loop; cause unresolved (`application/.build/phase2-startup-stall.sample.txt`).

## Claude follow-up

Review code, investigate LOG-0016 and launch/Communication findings, finish clean serial verification, and update tasks **2.3 / 2.6**, navigation/TDD and test docs (Claude-owned). Device play-test, VoiceOver walkthrough and perfect-pass/save-failure UI paths remain unverified.

Six synthetic simulator screenshots accompany this summary: coach grid, units, C2 lock, jump question, failed result and iPad Dark Mode/accessibility.
