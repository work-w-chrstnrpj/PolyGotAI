# Job 9 — Regression check of earlier findings

Validator: `lexicon words: 866 / course lessons: 57, track lessons: 80, typed exercises: 1848 / OK`

Date: 2026-10-25 · Read-only report. No product file changed.

## Method

Re-read `opencode-proofread-batches2-4-2026-10-25.md` (44 rows) and `opencode-docs-sweep-2026-10-25.md` (23 unique rows), then opened every named item in the current JSON/Markdown and compared the reported field against its text today. Verdicts:

- **FIXED** — the reported problem is gone; the suggested wording (or an equivalent) is in place.
- **CHANGED** — the row was acted on but the current text is not what the report proposed, or the fix left a new problem.
- **STILL OPEN** — the text is unchanged.

## Coach tracks, batches 2–4 — 38 FIXED, 3 CHANGED, 3 STILL OPEN

### Still open

| file | id | field | verdict | current text |
| --- | --- | --- | --- | --- |
| all 10 track packs | all 667 `choice` activities | `exercise.options` | **STILL OPEN** | The answer is still `options[0]` in 667/667 track items (and 1235/1265 including the course). Nothing was reordered. |
| all 10 track packs | pack metadata | `editorialApprovalReference` | **STILL OPEN** | `"Authored 2026-10-25 for the owner’s personal use. Qualified editorial review is pending. Completion records practice, not an English level."` — identical in all ten. |
| `track-journalist.json` | `jn-headlines-13` | `items` | **STILL OPEN** | `"Find the main news \| Write a lede with the key facts \| Write a short headline"` — headline still comes before lede. |

### Changed

| file | id | field | verdict | current text |
| --- | --- | --- | --- | --- |
| `track-reading-listening.json` | `rl-main-idea-02` | `prompt`, `answer` | **CHANGED** | The lesson was re-authored around a new passage: “Maria brings her camera to the market every Saturday… Photography is her favorite hobby.” The answer is now the **last** sentence, not the first, and the tip now says “look at the first sentence, the last sentence, and the idea that most sentences are about.” The specific give-away is gone, but the “answer is printed verbatim in the prompt” pattern remains (see Job 8, pattern 2). |
| `track-reading-listening.json` | `rl-context-meaning-07` | `options` | **CHANGED** | Options are now `['I burned my tongue', 'The soup', 'My', 'was']` and the answer is `"I burned my tongue"`. The capitalised “Was” is gone, but the answer is now the only multi-word option and the only one that states the clue — the item is easier than before. |
| `track-debater.json` | `db-evidence-06` | `prompt`, `options` | **CHANGED** | Prompt is now `"Which sentence is evidence?"` (the word “survey” was removed from the prompt), but three of the four options are now evidence statements: `"The old library has only 200 seats."`, `"1,500 people visit each week."` and the keyed survey line. The keyword tell is gone; the discrimination is now between “evidence” and “evidence about the same claim”, which the lesson does not teach. |

### Fixed — coach tracks

| file | id | field | verdict | current text |
| --- | --- | --- | --- | --- |
| all 10 packs | all 80 `match` activities | `answer`, `pairs` | **FIXED** | Every pack now uses `→` and `" \| "` — e.g. `"Who → a person or group \| What → a thing or an event \| …"`. `track-grammarian.json` was converted too. |
| `track-reading-listening.json` | `rl-context-meaning-05` | `prompt` | **FIXED** | “The sky was dark and **gray**” |
| `track-reading-listening.json` | `rl-scan-facts-08` | `prompt`, `options` | **FIXED** | “Spring Market. **Saturday, April 14.**”; distractor “Saturday, April 4” |
| `track-reading-listening.json` | `rl-detail-find-08` | `answer`, `options`, `audioText` | **FIXED** | Answer `"Nine ten"`, distractor `"Eight fifty"`, audio “at **nine ten**” |
| `track-reading-listening.json` | `rl-signal-words-01` | `prompt` | **FIXED** | “Fill the gap **to show a result**: I was tired, ___ I went to bed early.” |
| `track-reading-listening.json` | `rl-main-idea-01` / `rl-main-idea-02` | `prompt`, `answer` | **FIXED** (duplicate) | The two items now use different passages (walking / Maria’s photography), so the duplicate passage-and-answer pair is gone. |
| `track-reading-listening.json` | `rl-gist-read-06` | `options`, `audioText` | **FIXED** | Answer is now `"Opening times and tickets for visitors"`; the clip’s first sentence (“Welcome to the city museum.”) no longer contains it. |
| `track-reading-listening.json` | `rl-main-idea-06` | `options`, `audioText` | **FIXED** | Clip now opens “Many students stay up late.”; answer `"Good sleep helps students"` needs the later sentences. |
| `track-reading-listening.json` | `rl-gist-read-04` | `answer`, `options` | **FIXED** | `"Ben tells Mia about his **vacation**"` |
| `track-journalist.json` | `jn-five-ws-05` | `answer`, `options` | **FIXED** | `"Officials think an electrical problem caused it"` |
| `track-journalist.json` | `jn-five-ws-01` | `pairs` | **FIXED** | Pairs now include `['What', 'a thing or an event']` and `['How', 'the way it happened']` — all six question words. |
| `track-journalist.json` | `jn-open-closed-08` | `answer`, `pairs` | **FIXED** | `['Is the store open?', 'a short yes-or-no answer']` |
| `track-journalist.json` | `jn-quote-attribute` | `tip` | **FIXED** | “Attribution says who said them: **“said Maria Lopez”.**” — the full stop now sits outside the fragment. |
| `track-journalist.json` | `jn-pyramid-06` | `options` | **FIXED** | Fourth option replaced with `"The bus route is number 14."` |
| `track-journalist.json` | `jn-summarize-03` | `options` | **FIXED** | All four options now appear in the passage: the vote, the Monday date, Pine Street, and the parking worry. |
| `track-journalist.json` | `jn-summarize-04` | `prompt` | **FIXED** | `"A summary should be…"` (single ellipsis character) |
| `track-debater.json` | `db-phrases-06` | `prompt`, `answer` | **FIXED** | `"Fill the gap: ___, cities need more parks."` — no longer produces “In my opinion, I think…” |
| `track-debater.json` | `db-evidence-03` | `options` | **FIXED** | Distractors are now all specific findings: “The city counted 1,200 users in May.”, “A survey of 300 students found 70 percent agree.”, “The report found 640 visitors in June.” |
| `track-debater.json` | `db-fallacy-people-06` / `db-fallacy-logic-06` | `prompt` | **FIXED** | Both now read `"Match each item with its clue."` |
| `track-negotiator.json` | `ng-pitch-13` | `prompt` | **FIXED** | `"…Which sentence is the next step?"` |
| `track-negotiator.json` | `ng-offer-10` | `answer`, `accepted` | **FIXED** | `accepted: ["Would", "Will"]` |
| `track-negotiator.json` | `ng-refuse-02` | `options` | **FIXED** | `['Unfortunately', 'Obviously', 'Never', 'Stop']` — trailing commas removed. |
| `track-negotiator.json` | `ng-appeals-09` | `prompt`, `answer` | **FIXED** | `"Type the missing word: Logos uses facts and ___."` with `accepted: ["reasons", "reason", "logic"]` — no longer defines logos with itself. (“logic” is still accepted, which is correct English here.) |
| `track-public-speaker.json` | `ps-pause-12` | `accepted` | **FIXED** | `"Pause before an ___ word."` now accepts only `["important"]`. |
| `track-public-speaker.json` | `ps-pause-02` | `options` | **FIXED** | `['today', 'need', 'We', 'not']` — “the” removed; every option now occurs in the quoted line. |
| `track-public-speaker.json` | `ps-signpost-03` | `options` | **FIXED** | `['To sum up', 'First', 'Next', 'Let me begin']` — punctuation no longer marks the answer. |
| `track-business.json` | `bz-intro-09` | `answer`, `items` | **FIXED** | `"I work on the sales team."` |
| `track-business.json` | `bz-sbi-07` | `pairs` | **FIXED** | `['Situation', 'In Tuesday’s meeting'], ['Behavior', 'you interrupted Ana twice'], ['Impact', 'she stopped sharing ideas']` — commas and “and” removed. |
| `track-storyteller.json` | `st-people-11` | `answer`, `items` | **FIXED** | `"My mother looked at me and smiled."` |
| `track-storyteller.json` | `st-people-13` | `audioText` | **FIXED** | “…and said quietly, “Rain by noon.” He was never wrong.” |
| `track-storyteller.json` | `st-trim-10` | `prompt`, `answer` | **FIXED** | `"Type the missing word: Tell your story ___ and time it."` (`aloud`) |
| `track-storyteller.json` | `st-detail-04` | `options` | **FIXED** | Keyed option is now plain `"The color of the tablecloth"`; the “if it does not matter” clause was removed. |
| `track-storyteller.json` | `st-moment-13` | `options` | **FIXED** | Distractor is now `"A vacation"`. |
| `track-copywriter.json` | `cp-benefit-03` | `options` | **FIXED** | Distractor is now `"The bag has two zippers."` |
| `track-copywriter.json` | `cp-headline-04` | `options` | **FIXED** | `"Fix a leaking faucet in ten minutes"` |
| `track-copywriter.json` | `cp-headline-09` | `prompt` | **FIXED** | `"True or false: “Best product ever” is a strong headline."` — the self-contradicting “with no proof” tail is gone. |
| `track-copywriter.json` | `cp-aida-13` | `options` | **FIXED** | Distractors are now `"Download it free today"`, `"The app is free"`, `"It tells you when the bus arrives"` — “Never miss a bus again” is no longer an option. |
| `track-copywriter.json` | `cp-cta-02` | `options` | **FIXED** | `['Join', 'Consider', 'Think', 'Perhaps']` — three verbs plus one adverb; the grammatical tell is gone. |

`track-creative-writer.json` had no rows. Its one optional note (`cw-dialogue-06`, options differing only in the final clause) still stands as written and was deliberately not changed: `['“I’m fine,” she said, and quickly closed the door.', '…and smiled at the camera.', '…and sat down.', '…and made tea.']`.

## Docs sweep — 21 FIXED, 2 CHANGED

### Changed

| file | line | verdict | current text |
| --- | --- | --- | --- |
| `docs/product-specification/english-foundations.md` | 9 | **CHANGED** | The lock wording was replaced, but the replacement sentence is incomplete: “…levels unlock in order (see the course rules in the product specification), and **inside an unlocked level learners remain free.**” — “remain free” has no complement (“free to do what?”). Suggested: “…inside an unlocked level learners remain free to skip familiar explanations and revisit foundations.” (the first clause of the same sentence already says this, so the trailing clause can simply be deleted). |
| `docs/product-specification/ui-screen-state-inventory.md` | 62 | **CHANGED** | The row body is fixed — `**LR-01 · Level, units and lessons** \| Lesson → unlocked levels and level tests → illustrated unit header → structured lesson list.` — but the evidence column still reads `SEEN: **Learn** · Open levels`, keeping the retired tab name the row was supposed to remove. Suggested: `SEEN: Lesson · Open levels`. |

### Fixed — docs

| file | line | verdict | current text |
| --- | --- | --- | --- |
| `docs/development-plan/development-plan.md` | 47 | **FIXED** | Link now points at `[phase 1](phases/phase-1/README.md)`, which exists. |
| `docs/product-specification/ui-screen-state-inventory.md` | 91 | **FIXED** | `**VO-01 · Lexicon home and search** \| Lexicon tab → due reviews/collection/word/topic.` and evidence `SEEN: Lexicon · Your words`. |
| `docs/product-specification/ui-screen-state-inventory.md` | 3 | **FIXED** | The “belong to Learn → Coaches” clause is gone from the v2 note. |
| `docs/product-specification/ui-screen-state-inventory.md` | 109 | **FIXED** | `Lesson or Speech Lab → technique/example → scaffold/no framework → solo practice.` |
| `docs/product-specification/ui-screen-state-inventory.md` | 163 | **FIXED** | `Lesson supporting resources → curated/personal YouTube card → external destination.` |
| `docs/product-specification/coach-tracks.md` | 5 | **FIXED** | `Each coach is a **track** in the Lesson tab: units, then lessons, then exercises.` |
| `docs/product-specification/english-curriculum.md` | 3 | **FIXED** | `…the topic outline for the **CEFR course** in the Lesson tab.` |
| `docs/product-specification/figma-design-review.md` | 101 | **FIXED** | `- Lesson: Open levels.` |
| `docs/contracts/resource-library-v1.md` | 3, 31 | **FIXED** | `The resource library stays in the Lesson tab (bottom of the course list).` / `The Lesson tab opens the library without leaving or completing a lesson.` |
| `docs/testing/test-specification.md` | 35 | **FIXED** | `…no "unavailable/not scored/coming later" strings on Today, the Lesson tab or Speech Lab` |
| `docs/product-specification/ui-ux-design.md` | 28 | **FIXED** | `Main navigation: Today, Lexicon, Lesson, Speech Lab, Progress; Profile opens Settings.` |
| `docs/product-specification/ui-ux-design.md` | 30 | **FIXED** | `…due reviews, Daily Lexicon and achievements.` |
| `docs/diagrams/user-flow.md` | 8 | **FIXED** | `T -->\|Daily Lexicon\| DL[Daily Lexicon]` |
| `docs/product-specification/lexicon.md` | 11 | **FIXED** | `**Daily Lexicon** (one word a day)` |
| `docs/product-specification/product-specification.md` | 15 | **FIXED** | `…the Daily Lexicon (one word a day)…` |
| `docs/product-specification/ui-screen-state-inventory.md` | 40 | **FIXED** | `Welcome → unlocked level and time/activity targets → Today.` / `A1 unlocked; locked levels show a lock and a level-test button; edit later.` |
| `docs/product-specification/ui-screen-state-inventory.md` | 262 | **FIXED** | `New learner skips optional setup, previews intro and lands on A1; locked levels show the level test; no key needed` |
| `docs/product-specification/achievement-catalog.md` | 29 | **FIXED** | `\| All coach tracks (ten) \| 14 \|` |
| `docs/product-specification/achievement-catalog.md` | 39 | **FIXED** | `All ten coaches preserve the fixed CEFR course.` |
| `docs/product-specification/achievement-catalog.md` | 146 | **FIXED** | Heading is now `## All coach tracks`. |
| `docs/product-specification/ui-screen-state-inventory.md` | 41 | **FIXED** | `All ten coach roles unlocked; selected/unselected; published versus planned packs; …` |

The eight “hits that need no change” still hold: `coach-tracks.md:13` (“Nothing is locked. Learners can open any unit. The level lock applies to the CEFR course only”), `ui-ux-design.md:11` (“Coaches are not locked”), `ui-ux-design.md:40` (v1 text under a v2 banner), `figma-design-review.md:13` (“all seven section exports” = Figma sections), `ui-screen-state-inventory.md:292` (“all coaches/backgrounds remain unlocked”), and the `docs/history/` and phase-log references.

## Still needing an owner/Claude decision (not regressions)

- `achievement-visual-design.md:51` still has the heading `## Seven trainer signatures`, and the body (`:182`, `:194`) still says seven trainer completion/skill pairs — correct for adopted artwork, incomplete for ten tracks. `achievement-catalog.md:228` still lists `seven trainer signatures` in the adopted visual-system paragraph. This was flagged as “needs a decision, not a rename” and no decision has been recorded yet.
- `docs/reviews/` now holds ten reports (including this one). `docs/README.md` does not mention the folder; Claude may want to add one line so the reports are discoverable.

## Where this stopped

All 44 coach-track rows and all 23 unique docs rows were re-checked against current text. Nothing was skipped. No product file was edited; this report is the only change.
