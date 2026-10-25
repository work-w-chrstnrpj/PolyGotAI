# Phase 3 — Lexicon

**Goal:** the Lexicon tab trains words with spaced repetition from predefined groups, tests easy words in context (Lexicon in Action), and Today shows a Daily Lexicon word. Spec: [lexicon.md](../../../product-specification/lexicon.md).

**Status:** built and tested (349 unit tests, 4 new UI tests); waiting for the owner to try it. Ran **in parallel with Phase 2** (owner decision 2026-10-25): Claude did all of Phase 3 (domain, content and screens) while Codex built the Phase 2 screens. Mode 4 (Specialized Lexicon via AI) stays in Phase 6. As built: [lexicon.md](../../../product-specification/lexicon.md#as-built-in-phase-3-2026-10-25).

## Scope (all Claude)

| # | Task |
| --- | --- |
| 3.1 | Lexicon bank: `Resources/Lexicon/lexicon-*.json` (groups of words), model, loader, validator |
| 3.2 | Duplicate check (lemma + part of speech, normalized) for added words |
| 3.3 | Word stages (New, Learning, Review, Easy) from FSRS state and last rating; Easy list |
| 3.4 | Lexicon in Action question builder (fill the blank, choose the sentence) built on `ExerciseSpec`; results feed back to the card |
| 3.5 | Daily Lexicon pick (stable all day, skips Easy words); exposure only |
| 3.6 | First predefined groups: 3 groups × 40 words, original meanings and examples |
| 3.7 | Lexicon tab screens: groups, Daily Training, Lexicon in Action, add-word with the duplicate message |
| 3.8 | Daily Lexicon card on Today |

## Files this phase touches (so the two phases never collide)

- Claude: `Domain/Lexicon*.swift`, `Infrastructure/Lexicon/`, `Resources/Lexicon/`, `Features/Vocabulary/**` (new Lexicon files), `tools/curriculum/`, tests `Lexicon*Tests.swift`.
- `AppShell.swift` is shared with Phase 2 (Codex). Claude edits **only** the `case .vocabulary:` line and `TodayContent`; Codex edits only `LearnContent` and the `case .learn:` line. Read the file immediately before every edit and use small targeted edits, never a whole-file rewrite.
- Learner data: new fields go in the optional section of the learner document, and its custom `CodingKeys` must list them. No SwiftData migration.

## Done when

- Fresh install: Lexicon shows the groups; a word can be trained with all four ratings and its stage changes.
- Adding a duplicate word shows "Already in your Lexicon".
- A word rated Easy appears in Lexicon in Action; a wrong answer sends it back to training.
- Today shows one Daily Lexicon word that stays the same all day.
- Existing saved words and custom topics keep their schedule (shown as "My words").
- `verify.sh` passes; the owner has tried it.

## Result

- Evidence: [evidence/](evidence/) (Today's word of the day, Lexicon home). Unit tests: 349 pass. UI tests: `Phase3LexiconTests` (4) pass.
- Existing recall UI tests now go through "Saved words and topics" (`openSavedWords`); `testOfflineRecallDraftRevealAndRatingRecovery` passes there.

## Not verified or known issues

- UI triage (2026-10-25, run on the commit before Phase 2 and on the current code): `testReviewOptionsPersistAndLimitOneSession` (contrast audit on the old Review options screen) and `testCommunicationDraftSharesExactSourceAcrossLearnAndSpeechLab` **already failed before Phases 2 and 3**. `testConnectedLessonDraftResumeQuietCompletionAndVocabularyReview` passes on the current code; its earlier failure came from two test runs sharing one simulator. These two older failures still need a fix or removal.
- Wrong-usage sentences in the bank need a native-speaker read. Daily Training lists words alphabetically (the existing queue order), not in bank order.
- Not run on a real device. iPad layout not checked.
