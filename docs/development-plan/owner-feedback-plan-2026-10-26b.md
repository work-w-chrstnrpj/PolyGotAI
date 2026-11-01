# Owner feedback round 2 — plan (2026-10-26, Claude)

**Status:** PROPOSED. The owner answered four decisions (below). Phases 8–11 are built and on the iPhone but **not committed yet**. Three UI test fixes from the last verify run are written and not yet re-run.

## Owner's points → what we build

| # | Owner said | Plan |
|---|---|---|
| 1 | Stop trying to make the Lab feel like ELSA | Remove the pitch graphs and the intonation judging from the screens. Keep only the simple "say it" check (sheep vs ship), and move it into the new Pronunciation coach (point 5). |
| 2 | Today's top row is poor: the level ring on one half, the streak split on the other | Replace the split with one full-width header card: Level, an XP bar, the streak and today's minutes in a single row. Done in Phase 12; the wider UI work comes later (point 8). |
| 3 | Lexicon packs stop at 40 words; there is no AI fill for your own packs | **Decision: about 2,400 built-in words** (around 400 per rank, packs of 40–80), written offline in batches. **Decision: AI buttons always show**: "Fill with AI" on every pack, and tapping it without a key opens the key setup. |
| 4 | Coach lessons should be real lessons: read the lesson → examples → exercises, grouped by topic (one Nouns lesson covers all kinds of nouns) | A new lesson format with reading sections (a heading, an explanation and marked examples per section), shown as pages before the exercises. **Decision: all 10 coaches are rewritten together** into topic lessons, with 15–20 exercises each. The current 296 lessons become fewer, fuller lessons. |
| 5 | The Lab's phonetics teacher should be a coach | **New Pronunciation coach** under Lesson: vowels, diphthongs, consonant pairs, word stress and sentence intonation. Each lesson follows read → examples → exercises (listen, choose, and **say it**: decision, keep the say-it check). Pronunciation leaves the Lab. Its coach art goes on your image list. |
| 6 | Lab: recommend videos by Vinh Giang, Alexander Lyon and Charisma on Command, and remember what was watched | A **Videos** section: a curated list grouped by skill (speaking, voice, conversation, confidence). Each video opens in YouTube, and you mark it **Watched**, saved on the phone. Every link is checked as real before it goes in; nothing is invented. Links only, no copying. |
| 7 | Lab: timed, AI-made tests: impromptu writing (AI-graded, sent automatically when time runs out), timed reading with multiple choice, and analogies | A **Timed tests** section with three tests. The AI writes each item, and the app keeps a short fingerprint of every past item so none repeats. Impromptu writing gives a random topic and a timer, sends automatically at zero, and returns AI feedback (no score, per the app rules). Reading: a passage, 5 multiple-choice questions, and a timer. Analogies: 10 timed items. These need the key; without one, the buttons open setup (decision 3). |
| 8 | UI/UX later | A separate phase after these. |

After the move, the Lab is **Talk, Speaking, Spelling, Videos, Timed tests**, plus Voice and Feedback history.

## Phases (each ends with an iPhone play-test before commit)

| Phase | Scope | Who (proposal) |
|---|---|---|
| **12** | Lab refocus: remove the pitch UI and move Pronunciation out. Pronunciation coach with the new lesson format. Today header. AI buttons that lead to setup. | Claude (core, content), Codex (Lab list and Today header) |
| **13** | Lesson format for all coaches. Rewrite all 10 coaches into topic lessons (reading → examples → exercises), with Grammarian topics such as Nouns, Pronouns, Verbs, Tenses and Punctuation. | Claude (format, player, all content) |
| **14** | Lexicon to about 2,400 words in batches by rank, plus synonyms for the new words. | Claude (content) |
| **15** | Lab Videos (verified links, Watched list) and Timed tests (AI generation with no repeats, timers, auto-send, AI feedback). | Codex (screens, client), Claude (prompts, validation, review) |
| **16** | UI/UX pass across the app. | Later |

Phase 15 can run beside Phases 13 and 14 because they touch different files. Content (13, 14) is the longest part.

## Risks I want you to know
- **Rewriting all 10 coaches at once** is the largest content job so far: roughly 300 lessons turn into about 150 fuller ones. Your saved coach progress belongs to the old lesson IDs, so it starts fresh. You said data isn't important during development.
- **AI-made tests** depend on Qwen following a strict format. Items that come back in the wrong format are rejected and requested again, once only, so you are never charged twice for nothing.
- **Video links** must be checked online when they're added. If a creator removes a video, its card still opens YouTube, where the video will be missing.
