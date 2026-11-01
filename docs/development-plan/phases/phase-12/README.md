# Phase 12 — Lab refocus, Pronunciation coach, Today header, AI buttons (Claude)

**Status:** BUILT (Claude, 2026-10-26); owner play-test open · plan: [owner feedback round 2](../../owner-feedback-plan-2026-10-26b.md)

## Scope
1. **Today header:** one full-width card (Level, XP bar, streak, today's minutes) instead of the split ring and streak.
2. **AI buttons always show.** Without a provider key, tapping Talk, Fill with AI or Get feedback opens the key setup in a sheet; on close the app checks again. Shared piece: `Features/Feedback/AISetupGate.swift`.
3. **Lab refocus:** Pronunciation leaves the Lab list; pitch graph and intonation judging are removed. The Lab becomes Talk, Speaking, Spelling (+ Videos and Timed tests from Phase 15), Voice, Feedback history.
4. **Pronunciation coach** (Lesson tab): vowels, diphthongs, consonant pairs, word stress, intonation, in the Phase 13 read → examples → exercises format, keeping the say-it check. **Waits for Codex's Phase 13 lesson format to land** (`LessonReading`, `TrackCatalog`, the Tracks JSON belong to Phase 13).

## Lanes
- Claude edits: `TodayView.swift`, `AppShell.swift` (Lab list region only), `AIFeedbackSection.swift` (unavailable branch only), `CustomTopicViews.swift`, the new `AISetupGate.swift`, the Phase 10 Lab files.
- Not touched: Phase 13 files (Codex), Phase 14 lexdata, Phase 15 Lab Videos / Timed tests.

## Done when
Unit tests pass, the affected UI tests are updated, it is installed on the iPhone and the owner has play-tested it.

## Result (2026-10-26)
All four parts are built. The Pronunciation coach is the 11th coach (second in the list): 12 lessons in three stages, 204 checked items (about 80 Say it, 80 Listen, the rest sound questions), written reading pages. A new `speak` answer screen (`Features/Learn/Exercises/SpeakAnswerView.swift`) answers by voice only; `ExerciseSpec.evaluate` accepts a speak answer when the heard words contain the target. The unreachable Phase 10 Lab screens (`SpeechLabPronunciationView`, `SpeechLabPhoneticsView`, `SpeechLabArticulationView`, `SpeakCheckView`) were removed (copies in `application/.build/backup/phase12/`), with their three skipped UI tests; `Phase12PronunciationTests` replaces them.
