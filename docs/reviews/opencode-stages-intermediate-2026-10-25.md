# Job 10 — Stage proofread: Intermediate wave (all 10 coach packs)

Validator: `lexicon words: 866 / course lessons: 57, track lessons: 176, typed exercises: 3087 / OK`

Snapshot: 2026-10-25 22:38 PST. Read-only report. No product file changed.

The Intermediate wave landed while this audit was running (22:26–22:38, one pack per minute). No log entry names the batch yet — the last entries are LOG-0047/LOG-0048 and neither lists these lessons. This report covers the wave as found at the snapshot; if Claude names sub-batches later, the same findings apply per pack.

## Scope

10 packs × 8 Intermediate lessons = **80 lessons, 1,032 activities**, all with a typed `exercise` block (`choice` 633, `match` 80, `fillBlank` 80, `wordBank` 80, `open` 80, `order` 63, `spotError` 16). Every lesson also has a `tip` (51–78 words) and one `open` production task. The wave also gave `grammarian` and `reading-listening` a new Foundation stage (each now Starter + Foundation + Intermediate = 24 lessons); the other eight packs are Foundation + Intermediate.

## Stage fit: B1–B2, appropriate, but the item design is easier than the level

- Reading passages average **3.6–14.5 words per sentence** and 1–14% long words (`rl-i-infer` is the densest at 14.5/8%; `cp-i-proof` the lightest at 4.9/6% because it is ad copy). That sits inside B1–B2: nothing reads too hard.
- The production tasks (`open`) are genuinely B1+/B2: write a three-sentence scene plus an inference (`rl-i-infer`), two tones about the same park (`rl-i-purpose`), three present-perfect sentences (`gram-i-perfect`).
- The recognition tasks are the weak point: **41% of choice items (255/625) restate the tip almost verbatim** (≥80% content-word overlap). Per pack: business 33/60, storyteller 30/62, grammarian 26/51, reading-listening 26/63, copywriter 25/62, creative-writer 25/64, journalist 24/66, public-speaker 24/64, debater 21/67, negotiator 21/66. Example: the tip says "Use the passive when the action matters more than who did it" and item 3 asks "When do we use the passive?" with that sentence as the answer. This is recall of the tip, not use of the skill.
- The same **13-activity formula** is repeated in all 80 lessons: 2 reading items, ~6 definitional choices, a true/false pair, one match, one fillBlank, one wordBank, one listening item, one order item, one open task. It is consistent but predictable; an Intermediate learner will learn the shape rather than the skill.

## Findings

### 1. Choice answers are given away by length — 290/633 (46%)

290 choice items have the answer as the strictly longest option, and 281 of those keys have four or more words. Another 132 items have the answer *tied* for longest, so **422/633 (67%)** offer a key that is at least as long as every distractor. Worst examples (answer word count in brackets):

| file | lesson id | prompt | answer | distractors |
| --- | --- | --- | --- | --- |
| `track-business.json` | `bz-i-pushback` | Which reply pushes back politely? | `I want the launch to succeed. I can’t finish by Friday, but I can send a first version Tuesday.` (19) | `No way.` · `That is your problem.` · `Maybe, whatever.` (2–3) |
| `track-journalist.json` | `jn-i-lede` | Read this … Which is the strongest news lede? | `A fire damaged the Corner Bakery early Monday, but no one was hurt, the owner said.` (16) | `Early Monday was cold.` · `Sam Cole likes bread.` · `Fires are bad.` (3–4) |
| `track-copywriter.json` | `cp-i-story` | Which is a mini-story? | `Mira worked late and her eyes hurt. She switched lamps. Now she finishes without a headache.` (16) | `The lamp is soft.` · `Buy the lamp.` · `Eyes are important.` (3–4) |
| `track-negotiator.json` | `ng-i-close` | Which summary is clear? | `I will send the file on Friday, and you will pay half on Monday.` (14) | `We will see.` · `Things are fine.` · `It is done.` (3) |
| `track-journalist.json` | `jn-i-verify` | Read this … How should the story describe the oven? | `The cause may be a broken oven, an officer said, but the report is not finished.` (16) | `A broken oven caused the fire.` · `The owner broke the oven.` · `The oven is new.` (4–5) |
| `track-reading-listening.json` | `rl-i-summary` | Read this … Which is the best summary? | `A new train line will be faster, but tickets will cost more and some villages will lose buses.` (18) | `Trains are fun.` · `The company will review prices, and that is all.` · `Critics are always wrong.` (4–9) |
| `track-creative-writer.json` | `cw-i-voice` | Which narrator sounds tired? | `The street went on and on, the way streets do when you have no strength left.` (16) | `What a bright, glorious morning it was!` · `Three quick steps, and I was there.` · `The street was in the city.` (6–8) |
| `track-reading-listening.json` | `rl-i-argument` | What is the mayor’s main reason? | `Residents complain about parking more than anything else.` (9) | `Shop owners like the market.` · `The market is old.` · `Customers walk far.` (4–5) |

Five items have the answer as the **only multi-word option**: `bz-i-call` (`Confirming details`), `cp-i-reader` (`Tired eyes`), `cw-i-conflict` (`A closed bridge`), `ng-i-anchor` (`220 dollars, because the tires are new`), `st-i-voices` (`Breaking the story to comment on your voices`). Two more (`gram-i-pp` `last week`, `rl-i-purpose` `Neutral, giving both sides`) are multi-word where the distractors are single words.

Fix: keep every option within about two words of the key, and make the distractors plausible near-misses instead of obviously wrong ("Fires are bad", "Trains are fun"). The best items already do this: `rl-i-purpose` item 2 (`Neutral, giving both sides` vs `Angry`/`Joking`/`Excited`) still needs shorter options, but its distractors are real tones.

### 2. `spotError` accepts one rewrite although the prompt asks for a free one — grammarian

All 16 `spotError` items have exactly one accepted string. The prompt is "Find the mistake, then write the sentence correctly", and `Exercise.evaluate` compares the typed text with `accepted` (only case, punctuation, contractions and one spelling slip are tolerated). Valid corrections that will be marked wrong:

| file | lesson id | given sentence | only accepted answer | other correct answer marked wrong |
| --- | --- | --- | --- | --- |
| `track-grammarian.json` | `gram-i-relative` | `The book who I read was long.` | `The book that I read was long.` | `The book which I read was long.` |
| `track-grammarian.json` | `gram-i-passive` | `A new school is build in our town.` | `A new school is being built in our town.` | `A new school is built in our town.` |
| `track-grammarian.json` | `gram-i-deduce` | `She can’t knew the answer.` | `She can’t have known the answer.` | `She can’t know the answer.` |
| `track-grammarian.json` | `gram-i-pp` | `Did you ever try sushi?` | `Have you ever tried sushi?` | `Did you ever try sushi?` is idiomatic American English |
| `track-grammarian.json` | `gram-i-link` | `Despite he was tired, he kept running.` | `Despite being tired, he kept running.` | `Despite the fact that he was tired, he kept running.` |

Fix: add the alternatives to `accepted`, or make the prompt narrow ("Change only the verb") so one answer is the only correct response. The other 11 spotError items have a single defensible correction and are fine.

### 3. American spelling — 2 strings

| file | lesson id | text | fix |
| --- | --- | --- | --- |
| `track-copywriter.json` | `cp-i-email` | `The grey jacket in medium is available again.` (`audioText`) | `gray` |
| `track-negotiator.json` | `ng-i-trade` | `The deal is cancelled` | `canceled` |

### 4. Repeated passage inside one lesson — 2 lessons

`rl-i-infer` items 0 and 1 use the same 37-word shop passage; `rl-i-purpose` items 0 and 1 use the same 28-word Brightline ad. Both pairs ask a different question about the same text, which is defensible, but the second pass adds no new reading and the lesson already repeats the whole passage in the prompt. Consider one shared passage with two questions, or a second short text.

### 5. Low-value true/false pairs

Every lesson has a two-item true/false pair. Several are answerable without reading the tip: `rl-i-infer` item 7 `True or false: You can draw any conclusion you like.` → `False`; `rl-i-purpose` item 7 `True or false: Word choice can show the writer’s attitude.` → `True`. Fine as a warm-up, but they should not sit among the eight scored choices.

## Checked and clean

- **No answer key is missing.** All 1,032 activities carry `answer`/`accepted`; no item has an empty key.
- **No duplicate prompts or answers** within any pack (0).
- **No straight apostrophes, double spaces or space-before-punctuation** anywhere in the 80 lessons.
- **Accepted variants are complete for normal typed answers.** The one flag (`gram-i-deduce` `can't`) is a false alarm: `AnswerChecker` normalizes curly quotes and expands `can't`→`cannot`, so the typed form is accepted.
- **Tips are all exercised.** 0 tips fall below 30% vocabulary overlap with their lesson's prompts/answers; every tip's key terms appear in the activities.
- **No factual or grammar errors** found in the sampled lessons (`bz-i-pushback`, `cp-i-objection`, `cw-i-figure`, `db-i-question`, `jn-i-style`, `ng-i-close`, `ps-i-three`, `st-i-voices`, plus full reads of `rl-i-infer`, `rl-i-purpose`, `gram-i-perfect`). The grammar tips are accurate one-liners; conditional, passive, reported-speech and relative-clause explanations are correct.
- **Listening items paraphrase rather than copy** where the task is comprehension (e.g. `rl-i-purpose` item 10: audio `You simply must buy it today` → answer `To persuade`). The 41 items where the answer is ≥80% verbatim are reading "find the line" tasks and are by design.

## Open items for Claude

1. **No log entry names this wave.** 80 Intermediate lessons and 16 new Foundation lessons are on disk unlogged. Please add the batch entry so the next proofread can be scoped.
2. **Advanced is not started** (0 lessons). Intermediate is complete for all 10 packs at this snapshot.
3. **Decide the `spotError` policy** before more grammar packs copy the pattern: accepted variants, or a narrower prompt.
4. **Length-tell clean-up** is the single highest-value edit: 46% of choice items can be answered by picking the longest option. A pass that trims keys to the length of the longest distractor would fix most of it without changing content.
