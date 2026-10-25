# Job 10 — Proofread `intro-01` (first batch)

Validator (refresh 22:54, content still landing): `lexicon words: 866 / course lessons: 57, track lessons: 248, typed exercises: 3975 / OK`

Date: 2026-10-25 · Read-only report. No product file changed.

## What changed since Job 6

LOG-0047 keeps `intro-01` as a guided-production lesson (no typed `exercise` blocks) and adds a coach tip. Current state: `contentVersion: "4"`, 22 activities, 0 typed exercises, `tip` present, `supplement` and `trackId` still absent. The 12 other A1 lessons still have `supplement` and `trackId: "course"`.

Stage fit: A1 is correct. The lesson uses present simple `be`/`do`, a three-fact frame and invented details; nothing reads too easy or too hard for A1.

## Findings

| file | id | field | text | suggested fix |
| --- | --- | --- | --- | --- |
| `CurriculumCatalog.json` | `intro-01` | `/activities[3]/answer` | `The speaker's name is Alex.` | `The speaker’s name is Alex.` (straight apostrophe; the file is otherwise curly) |
| `CurriculumCatalog.json` | `intro-01` | `/activities[4]/prompt` | `What is Alex's job?` | `What is Alex’s job?` |
| `CurriculumCatalog.json` | `intro-01` | `/activities[9]/prompt` | `Fill the gap with one word. He ___ in a shop.` | `He ___ in a store.` — Job 6 row still open; project copy uses American English (`store` and `apartment` already appear in this catalog). |
| `CurriculumCatalog.json` | `intro-01` | `tip` | `An introduction has three facts: your name, your work or study, and one thing you like.` | Add the origin fact the lesson itself teaches: activity 12 recalls `I am from …`, sense `intro-origin` exists, and activity 21 asks `Where are you from?`. Say “name, work or study, where you are from, and one interest” or name origin as the follow-up. |
| `CurriculumCatalog.json` | `intro-01` | `tip` vs activities 16–21 | Tip says `one thing you like`; the prompts say `one interest` and `something you enjoy`. | Use one phrase across the lesson, e.g. `one interest (something you enjoy)`. |
| `CurriculumCatalog.json` | `intro-01` | `/activities[16]/answer` | `My name is ___. I study / I work ___. I like ___. A simple follow-up is: What do you like?` | The model names the follow-up but never answers it, while the prompt asks the learner to answer one question. Add the answer, e.g. `In my free time, I like ___.` |
| `CurriculumCatalog.json` | `intro-01` | `/activities[19]/prompt` | `Before any model, write an introduction with three facts and answer one follow-up. This check stays out of ordinary practice.` | `Write this before you look at any example.` — “stays out of ordinary practice” is app-internal wording an A1 learner cannot act on. |
| `CurriculumCatalog.json` | `intro-01` | `/activities[11]/prompt` | `Write one sentence that tells someone what you are called.` | `Write one sentence that gives your name.` — “what you are called” is harder than the target language. |
| `CurriculumCatalog.json` | `intro-01` | lesson metadata | `trackId` missing | `"trackId": "course"` to match the other 12 A1 lessons. No visible effect today (`LessonPlayerView` only resolves coach tracks), but it keeps the pack consistent. `supplement` is **not** needed: the new `tip` replaces the “Make the pattern useful” block for an introduction lesson (`LessonPlayerView:266`). |

## Checked and clean

- **Tip teaches something the exercises use.** The three-fact frame, `Hello`, `My name is …`, `I study …` / `I work …`, `I like …` and `Nice to meet you` all appear in senses, recall items 11–15, or guided items 16–21.
- **Two defensible answers / one-word give-away.** This lesson has no typed exercises, so there is no single keyed answer to game. The reading and listening answers are full sentences and are not printed verbatim in the prompts.
- **Grammar explanations.** `am` with I, `is` with he/she, `study` vs `studies`, `works` with he, `Do` with you — all correct and one line each.
- **Reading / listening split.** Three reading items use Mina; three listening items use a different speaker, Alex, and the prompts say so. No accidental answer leakage between the two.
- **Self-review and quiet-text items** describe observable behaviour (name, role, interest, one follow-up) rather than a score. Good fit with the guided-production design.

## Cross-reference — Job 6 rows still open outside `intro-01`

The other five straight-apostrophe strings from Job 6 are unchanged: `a1-dates` `Mina's`, `family-01` `Mina's` and `speaker's`, `a1-home` `Mina's`, `a1-weather` `today's`. Not part of this batch; listed here so the Job 6 item is not lost.

## Stage batches

Intermediate/Advanced stage content is landing. At the 22:54 snapshot the packs hold 248 lessons: all 10 coaches have Foundation + Intermediate, and 8 also have Advanced; Grammarian and Reading & Listening still carry Starter instead of Advanced. Stages are the lesson `level` field (`Starter`/`Foundation`/`Intermediate`/`Advanced`), not a `stage` key. The Intermediate wave is proofread in [opencode-stages-intermediate-2026-10-25.md](opencode-stages-intermediate-2026-10-25.md). The next stage report will be named `opencode-stages-<coaches>-<date>.md` when Claude names the batch; the Job 14 audit on this tree is the pre-log snapshot, since no "wave B content done" entry exists yet.
