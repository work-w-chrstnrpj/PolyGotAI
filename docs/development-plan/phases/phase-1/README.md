# Phase 1 — Exercise engine

**Goal:** lessons give instant right / almost / not-quite feedback, like Duolingo, instead of "type, save, compare". Proven on the A1 lessons.

**Status:** done and verified on the simulators; waiting for the owner to play an A1 lesson and to test dictation on a real device. Codex had no usage, so Claude built the screens too.

## What shipped

- **Engine** (`Domain/`): `AnswerChecker` (case, punctuation, contractions, spelling slips), `ExerciseSpec` and `ExerciseSession`, stored-text form so accuracy survives a restart.
- **Content:** the 12 A1 topic lessons are now **version 4**: a coach tip, and 14 typed exercises each: a reading question, a listening question, a true/false, a listen-and-write, five grammar exercises (sentence building and fill-in-the-blank) and five word-recall questions (type the word, or choose a phrase). The exact version 3 is archived, so unfinished v3 lessons keep opening as they were. INTRO-01 is unchanged.
- **Screens** (`Features/Learn/Exercises/`): multiple choice, true/false, tap-to-build sentence, fill-in-the-blank (the sentence shows the blank and the chosen word drops in), typed words, matching, ordering, listen-and-write. Green/red answer highlighting, XP and gold in the feedback bar, a banner that switches an old saved lesson to the new version, a feedback bar with the right answer and a one-line reason, accuracy on the finish screen, and a "try the ones you missed" practice.
- **Dictation:** a microphone button beside every typing field ([speech-lab.md](../../../product-specification/speech-lab.md#speech-to-text-on-every-typing-field)).
- **Tools:** `tools/curriculum/validate.py` and `convert_a1_v4.py`.

## Evidence

[evidence/](evidence/): coach tip, choice, wrong answer restored after an app restart, word bank. Tests: 315 unit tests pass, plus UI tests for the typed flow, lesson resume, launch and accessibility.

## Not covered yet

- Spot-the-error and speak exercises have no dedicated screen (they fall back to a typed answer). No A1 content uses them yet.
- Match, ordering and listen-and-type have no A1 content yet; they are covered by unit tests only.
- Dictation recognition was not testable on the simulator.
- A2–C2 lessons keep the old type-and-compare format until Phase 4.
