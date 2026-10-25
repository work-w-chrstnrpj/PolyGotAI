# Job 8 — Give-away audit across all lessons

Validator: `lexicon words: 866 / course lessons: 57, track lessons: 80, typed exercises: 1848 / OK`

Date: 2026-10-25 · Read-only report. No product files changed.

## Scope and method

- Lesson files: `Resources/Tracks/track-*.json` (10 packs, 80 lessons) and the A1–C2 lessons in `Resources/Curriculum/CurriculumCatalog.json` (57 lessons).
- Choice items audited: **1265** (`accepted[0]` is the answer in every one).
- One structural finding sits behind all of the numbers below: **the answer is `options[0]` in 1235 of 1265 items** (667/667 track, 568/598 course). Any learner who always taps the first option scores ~98%. This was already reported in `opencode-proofread-batches2-4-2026-10-25.md` and is still open; it is listed here only because it dominates every other give-away pattern.
- Text comparisons are done on normalized tokens (case, curly quotes and punctuation folded). Listening `audioText` is **not** treated as a printed prompt, because a listening answer legitimately quotes the clip. Prompts beginning `Read this.` are treated as printed text.
- Length tests use character count of the raw option string.

## Pattern 1 — the correct option is the longest

| Measure | Count | Share of 1265 |
| --- | --- | --- |
| Correct option strictly longest | 580 | 46% |
| Correct option tied longest | 75 | 6% |
| Correct option equal-or-longest (total) | 655 | 52% |
| Correct option ≥ 1.5× the longest distractor | 208 | 16% |
| Correct option strictly **shortest** (opposite flaw) | 205 | 16% |

The 580 breaks down by source as: creative-writer 54, storyteller 52, copywriter 48, public-speaker 44, journalist 40, negotiator 40, business 39, debater 39, reading-listening 32, grammarian 9, course 183. The flaw is much stronger in the writer/coach packs (54 of 78 creative-writer items, 52 of 72 storyteller) than in Grammarian (9 of 38), which is the pack where option length carries the least signal. The 205 shortest-correct items are spread across every pack and are concentrated in the course (99 of 598).

### Ten worst: largest gap between answer and the next-longest option

| file | id | field | problem | suggested fix |
| --- | --- | --- | --- | --- |
| `track-public-speaker.json` | `ps-open-close-03` | `options` | Answer is 88 chars, distractors 24/15/13: `"Last winter, my bus broke down in the snow, and a stranger changed my mind about people."` | Shorten the answer or lengthen the distractors to the same shape (e.g. all four as one-line openings). |
| `track-business.json` | `bz-sbi-05` | `options` | Answer 80 chars, distractors 13/21/25: `"In today’s meeting, you spoke over Ana twice, and she stopped sharing her ideas."` | Give the distractors the same sentence form and length. |
| `track-storyteller.json` | `st-trim-05` | `options` | Answer 80 chars, distractors 29/10/16: `"A long explanation of how your uncle met his wife, in a story about a lost phone"` | Pad distractors to a clause each, or cut the answer to a phrase. |
| `track-storyteller.json` | `st-arc-05` | `options` | Answer 77 chars, distractors 28/17/28: `"Because the bridge was closed, he took the long road and met his old teacher."` | Same fix: make all four a single short sentence. |
| `track-journalist.json` | `jn-summarize-01` | `options` | Answer 109 chars, distractors 47/60/52: `"The council voted to build a bike lane; supporters say it is safer, and some shop owners worry about parking."` | Trim the answer to one clause; keep the three wrong summaries at similar length. |
| `track-creative-writer.json` | `cw-character-05` | `options` | Answer 69 chars, distractors 18/20/17: `"Ravi wants to join the band but is afraid to play in front of people."` | Lengthen distractors, or reduce the answer to “Ravi’s want and fear”. |
| `track-journalist.json` | `jn-headlines-04` | `options` | Answer 72 chars, distractors 22/24/18: `"A water pipe broke on Main Street on Monday, closing the road for a day."` | Keep all four as one-line headlines. |
| `track-creative-writer.json` | `cw-show-tell-04` | `options` | Answer 61 chars, distractors 14/13/13: `"She laughed, grabbed her friend’s hands and spun in a circle."` | The three distractors are all “she was happy” variants — vary their wording and length. |
| `track-creative-writer.json` | `cw-start-end-03` | `options` | Answer 62 chars, distractors 10/13/18: `"On the morning my brother disappeared, his bed was still warm."` | Add a clause to each distractor. |
| `track-public-speaker.json` | `ps-open-close-04` | `options` | Answer 67 chars, distractors 21/25/22: `"So the next time you feel tired, protect your sleep. Start tonight."` | Same fix. |

Note the shared cause: in these packs the prompt is a passage and the answer is often a verbatim or near-verbatim line from it, so the answer inherits the passage's length while the distractors are short authored lines. Fixing pattern 2 also shrinks pattern 1.

## Pattern 2 — the answer is the only option connected to the prompt

Two measurements, because the loose one is too common to be a finding:

| Measure | Count | Read |
| --- | --- | --- |
| Only the correct option shares a content word with the prompt | 748 / 1265 | Over-broad: most items naturally echo one prompt noun. Not a headline. |
| Answer phrase is printed **verbatim** in the prompt and no distractor is (yes/no and single-word answers excluded) | **46 / 1265** | The sharp subset. A learner can copy-matches without reading. |

Of the 46, **41 are exploitable** and **5 are recall by design** (`routine-01` ×2, `b1-relationships-recall-known`, `b1-achievements-recall-proud`, `c1-strategy-recall-who` — the intended task is to recall the phrase from the lesson).

Distribution of the 46: course 30 (25 `*-read` comprehension items plus the 5 recall items), reading-listening 9, journalist 3, storyteller 2, copywriter 1, creative-writer 1. The course `*-read` family is the largest single group — every level from A1 to C2 has at least one item whose answer is a phrase lifted from its own two-to-four-sentence passage — and `track-reading-listening.json` `rl-detail-find`/`rl-scan-facts` are the worst track family: the prompt is the passage and the question asks for a phrase the passage already prints. (A further 30 items print the answer *and* a distractor, mostly `jn-fact-opinion` and `jn-pyramid` where the options are sentences from the passage; those are discriminating but still reward matching over reading.)

### Ten worst: verbatim answer, no distractor printed

| file | id | field | problem | suggested fix |
| --- | --- | --- | --- | --- |
| `track-reading-listening.json` | `rl-detail-find-04` | `options` | Prompt ends “Last week a rabbit ate her lettuce, so now she has a fence.”; answer `"A rabbit ate her lettuce"` is the first clause. | Paraphrase the answer (`"To stop animals eating her crops"`) or ask a why-question that needs inference. |
| `track-journalist.json` | `jn-five-ws-03` | `options` | Prompt opens “A fire broke out … on Monday night.”; answer `"Monday night"`. | Ask a question whose answer is not one of the four Ws already stated. |
| `track-reading-listening.json` | `rl-scan-facts-04` | `options` | Prompt prints “Address: 12 Oak Road.”; answer `"Oak Road"`. | Have learners derive the road from an address that is not labelled, or use a map-style prompt. |
| `course` `a1-weather` | `a1-weather-read` | `options` | Prompt: “It is hot and sunny.”; answer `"Hot and sunny."` — identical to the printed sentence. | Ask about Mina (`"What does Mina want?"`) so the copied phrase is not the answer. |
| `course` `a1-places` | `a1-places-read` | `options` | Prompt: “The library is on the right.”; answer `"On the right."`. | Change the prompt direction wording so the answer must be worked out. |
| `track-storyteller.json` | `st-arc-12` | `options` | Prompt: “his oven broke”; answer `"His oven broke"`. | Ask “What kind of obstacle is it?” so the option is a category, not a quote. |
| `track-storyteller.json` | `st-moment-12` | `options` | Prompt: “Dana missed the last train home”; answer is the same clause. | Ask which moment *started* the chain, with options that describe consequences. |
| `track-reading-listening.json` | `rl-main-idea-01` | `options` | Prompt's first sentence “Walking is a good way to stay healthy” is also the main-idea answer. | Main-idea items should paraphrase the thesis, not reuse the topic sentence. |
| `track-reading-listening.json` | `rl-detail-find-05` | `options` | Prompt: “Every evening she waters the plants.”; answer `"Every evening"`. | Ask about a detail that requires joining two sentences. |
| `track-reading-listening.json` | `rl-scan-facts-08` | `options` | Prompt: “Saturday, April 14.”; answer `"Saturday, April 14"`. | The other three options differ by one digit, so the item is a look-up, not a scan — ask for a derived fact instead. |

Cheap systemic fix for this family: for any `*-read`, `rl-*`, `jn-*` item, reject the build if `normalize(answer) in normalize(prompt)` unless the item is tagged recall.

## Pattern 3 — True/False key balance

Per track (answer counts):

| Track | True | False | Total |
| --- | --- | --- | --- |
| business | 8 | 8 | 16 |
| copywriter | 8 | 8 | 16 |
| creative-writer | 9 | 7 | 16 |
| debater | 7 | 5 | 12 |
| grammarian | 3 | 4 | 7 |
| journalist | 8 | 6 | 14 |
| negotiator | 9 | 6 | 15 |
| public-speaker | 8 | 7 | 15 |
| reading-listening | 4 | 5 | 9 |
| storyteller | 9 | 7 | 16 |
| course (all levels) | 26 | 30 | 56 |

Per bank and level:

| Group | True | False |
| --- | --- | --- |
| Foundation (8 packs) | 66 | 54 |
| Starter (grammarian, reading-listening) | 7 | 9 |
| A1 | 3 | 9 |
| A2 | 6 | 5 |
| B1 | 6 | 4 |
| B2 | 5 | 5 |
| C1 | 4 | 4 |
| C2 | 2 | 3 |

No track is worse than 9:6, so the keys are usable. Two things are worth noting rather than fixing: A1 is the only level skewed to False (3 True / 9 False — a learner who always answers False gets 75% at A1), and the packs have very different T/F volume (business, copywriter, creative-writer and storyteller 16 each; negotiator and public-speaker 15; journalist 14; debater 12; reading-listening 9; grammarian 7). Both are small-sample effects of content volume, not a flaw in the items.

## Pattern 4 — options that differ only by capitalization or punctuation

Five items have two or more options that collapse to the same string once case and punctuation are folded:

| file | id | field | problem | suggested fix |
| --- | --- | --- | --- | --- |
| `track-grammarian.json` | `gram-sent-subject-11` | `options` | `"She sings."` vs `"she sings."` vs `"She sings"` — three of four options are the same sentence. | Keep one punctuated option and replace the other two with genuinely different sentences. |
| `track-journalist.json` | `jn-quote-attribute-01` | `options` | `"“I love this town,” said Mia."` vs `"“I love this town”, said Mia."` — differ only in comma placement inside the quote. | Differentiate on the *attribution* rule, not on a comma. |
| `track-journalist.json` | `jn-quote-attribute-03` | `options` | `"The mayor said the road will close on Monday."` vs `"The mayor said, “The road will close on Monday.”"` — same content, punctuation only. | Use one indirect and one direct quote with different words. |
| `course` `a1-alphabet` | `a1-alphabet-production-v3-1` | `options` | `"My name is Ben."` vs `"my name is ben."` vs `"My name is ben."` — capitalization-only variants. | Replace the two lowercase variants with different content (e.g. `"My name Ben is."`, `"Name my is Ben."`). |
| `course` `a1-places` | `a1-places-production-v3-5` | `options` | `"Go straight. Turn left. The library is on the right."` vs the same string with one missing full stop. | Differentiate on word order, not on a missing period. |

The `a1-alphabet` and `a1-places` cases are the worst because the task is “which sentence is correct?” and the near-duplicates make the answer guessable by elimination.

## Pattern 5 — `fillBlank` with a single accepted entry that is a function word

**112 of 139 `fillBlank` items have exactly one accepted answer** (80%). Of those, **16 accept only a function word** (article, preposition, conjunction, auxiliary, pronoun, wh-word), so the missing slot can be filled from grammar alone with no vocabulary recall:

| file | id | accepted | prompt (excerpt) |
| --- | --- | --- | --- |
| `track-creative-writer.json` | `cw-setting-11` | `when` | “Setting means where and ___ a scene happens.” |
| `track-creative-writer.json` | `cw-pov-10` | `they` | “…the narrator uses “he,” “she” or ___” |
| `track-debater.json` | `db-structure-10` | `For` | “___ example, many cities have done this.” |
| `track-grammarian.json` | `gram-sent-join-06` | `or` | “Do you want rice ___ noodles?” |
| `track-grammarian.json` | `gram-be-amisare-07` | `are` | “You ___ my friend.” |
| `track-grammarian.json` | `gram-be-amisare-08` | `is` | “My name ___ Ana.” |
| `track-grammarian.json` | `gram-be-have-07` | `has` | “Tom ___ a bike.” |
| `track-grammarian.json` | `gram-be-have-08` | `have` | “You ___ my book.” |
| `track-grammarian.json` | `gram-be-do-07` | `Does` | “___ your brother play football?” |
| `track-journalist.json` | `jn-five-ws-11` | `Who` | “___ asks for a person.” |
| `track-negotiator.json` | `ng-concede-08` | `will` | “If you agree, I ___ start tomorrow.” |
| `track-public-speaker.json` | `ps-signpost-10` | `To` | “___ sum up, the plan is simple.” |
| `track-reading-listening.json` | `rl-detail-find-10` | `Where` | “___ do students meet? At the front gate.” |
| `course` `a2-problems` | `a2-problems-recall-so` | `so` | “Write the word that introduces a result.” |
| `course` `b2-present` | `b2-present-recall-then` | `then` | “Write the word that orders the next move.” |
| `course` `c1-policy` | `c1-policy-recall-or` | `or` | “Write the word that warns of the consequence.” |

For Grammarian the function-word blanks are the point of the lesson, so they are not defects. Elsewhere, for example `cw-setting-11`, `jn-five-ws-11`, `ps-signpost-10`, `rl-detail-find-10`, `a2-problems-recall-so`, `b2-present-recall-then` and `c1-policy-recall-or`, the blank tests punctuation-level grammar rather than the lesson's skill. The broader 112/139 single-accepted figure is the bigger risk: any legitimate variant not in the list is marked wrong, so items where two forms are both correct will fail a learner who is right.

## Related finding — dictation repeats a printed sentence

13 of 56 `listenType` items play a sentence that the same lesson already prints in an earlier prompt, so the learner can copy it instead of listening:

| file | id | text |
| --- | --- | --- |
| `CurriculumCatalog.json` | `a1-greetings-dictation` | “Good evening. How are you?” |
| `CurriculumCatalog.json` | `a1-alphabet-dictation` | “Ben spells his name.” |
| `CurriculumCatalog.json` | `a1-numbers-dictation` | “Mina buys fifteen apples.” |
| `CurriculumCatalog.json` | `family-01-dictation` | “Mina has a sister.” |
| `CurriculumCatalog.json` | `a1-home-dictation` | “The bathroom is upstairs.” |
| `CurriculumCatalog.json` | `routine-01-dictation` | “Mina gets up at six.” |
| `CurriculumCatalog.json` | `food-01-dictation` | “I would like tea and a sandwich.” |
| `CurriculumCatalog.json` | `a1-places-dictation` | “The library is on the right.” |
| `CurriculumCatalog.json` | `a1-hobbies-dictation` | “Mina plays the piano on Sunday.” |
| `CurriculumCatalog.json` | `a1-weather-dictation` | “It is hot and sunny.” |
| `CurriculumCatalog.json` | `a2-travel-dictation` | “Mina took the train to Chicago in June.” |
| `CurriculumCatalog.json` | `c1-debate-dictation` | “One group trusts the survey, whereas the other trusts the incident log.” |
| `CurriculumCatalog.json` | `c2-abstract-dictation` | “Privacy is a claim about who decides the boundary.” |

All 13 are in A1 except `a2-travel`, `c1-debate` and `c2-abstract`. A one-line sentence from the reading is a reasonable A1 dictation, but from A2 up it should be a new sentence that reuses the lesson's vocabulary.

## Where this stopped

All five requested patterns were measured across the full 1265-item set and both lesson banks. No exceptions were skipped. The report is counts plus the ten worst items per pattern, as the handoff asks; it does not propose rewrites of individual lessons beyond those rows.

Left for Claude to decide: whether the 1235/1265 `options[0]` answer position stays open (it is the single largest give-away), and whether a build-time check for “answer printed verbatim in prompt” should be added to `tools/curriculum/validate.py` — the 46-item list above is the exact set that check would flag today.
