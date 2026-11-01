# OpenCode proofread — Job 6, the 13 A1 lessons (2026-10-25, read-only)

Validator last line:

```text
lexicon words: 866
course lessons: 57, track lessons: 80, typed exercises: 1848
OK
```

Scope: `application/SpeechCoachAI/Resources/Curriculum/CurriculumCatalog.json`, the 13 lessons with `level` "A1" and `contentVersion` "4" (274 activities, 168 with an `exercise`). Read-only: no product file was edited.

Method: every learner-facing string was read (`tip`, `supplement.teaching`, `supplement.concepts`, `prompt`, `answer`, `explanation`, `exercise.options`, `accepted`, `audioText`, `choiceSet`), then checked mechanically for: straight vs curly quotes, British spellings and clock/date forms, double spaces and stray punctuation, option case and punctuation consistency, wordBank tiles that cannot build an accepted variant, `accepted` answers shorter than the prompt asks for, and dictation text that also appears in the same lesson.

## Systemic findings (across the 13 lessons)

| file | id | field | problem | suggested fix |
|---|---|---|---|---|
| CurriculumCatalog.json | `intro-01` | whole lesson | **This lesson was never converted to content v4.** All 22 activities lack `exercise`; the 6 reading/listening items are therefore unscored (they map to `open`), and the 5 grammar items still use the v3 `choiceSet` field, which the engine only reaches through `ExerciseSpec.legacy(for:)`. The lesson also has no `tip`, no `supplement` and no `trackId`, unlike the other 12. | Convert it like the others: add `exercise` blocks, `tip`, `supplement` and `trackId: "course"`. Until then, exclude it from v4 lesson counts. |
| CurriculumCatalog.json | 11 lessons | `exercise.audioText` | **The dictation answer is already printed in the same lesson.** The `listenType` text is an exact substring of an earlier prompt in 11 of 13 lessons: `a1-greetings-dictation` ← `a1-greetings-read`, `a1-alphabet-dictation` ← `a1-alphabet-read`, `a1-numbers-dictation` ← `a1-numbers-read`, `family-01-dictation` ← `read-family`, `a1-home-dictation` ← `a1-home-read`, `routine-01-dictation` ← `read-routine`, `food-01-dictation` ← `read-food`, `a1-places-dictation` ← `a1-places-read`, `a1-hobbies-dictation` ← `a1-hobbies-read`, `a1-weather-dictation` ← `a1-weather-read`. (`a1-dates-dictation` and `a1-shopping-dictation` are clean.) | Give each dictation a new sentence that is not on screen, or move the dictation before the reading. |
| CurriculumCatalog.json | 40 choice sets | `exercise.options` | **Mixed case inside one option set.** Recall items mix sentence-case and lower-case options, and the `answer` field often disagrees with the option: `family-01` / `recall-mother` has `answer` "My mother …" but options `['my mother', 'my father', 'I have', 'there is']`; same in `routine-01` (`recall-morning` answer "In the morning, I …" vs option `in the morning`), `a1-weather` and `a1-home`. A learner copying the option starts a sentence in lower case. | Make every option that starts a sentence capitalized, and make `answer` match the option letter for letter. |
| CurriculumCatalog.json | 7 strings | `answer`, `prompt` | **Straight apostrophes in an otherwise curly-quote file.** `intro-01` `/activities[3]/answer` "The speaker's name is Alex.", `intro-01` `/activities[4]/prompt` "What is Alex's job?", `a1-dates-read` prompt "Mina's class is on Monday in March.", `family-01` `/activities[0]/answer` "Lina is Mina's sister.", `family-01` `/activities[1]/answer` "Sam is the speaker's brother.", `family-01-production-v3-4` accepted "Lina is Mina's sister.", `a1-home-read` prompt "Mina's bedroom has one window.", `a1-weather-guided` prompt "Say today's weather…". Everything else in the file is curly (`’`). | Use `’` in all seven strings. |

## Per-lesson findings

| file | id | field | problem | suggested fix |
|---|---|---|---|---|
| CurriculumCatalog.json | a1-greetings-read | `prompt` | The stem prints the answer before asking for it: "Mina meets a coworker at night and says, Good evening. How are you? Which greeting does Mina use?" — answer "Good evening." | Ask about the time of day instead: "Mina meets a coworker at night. Which greeting does she use?" |
| CurriculumCatalog.json | a1-greetings-production-v3-4 | `answer` | The model answer offers two alternatives — "I am well, thank you. / I’m fine, thanks." — but `accepted` is only "I am well, thank you.", and the explanation says "Several short polite replies work". A learner who picks another sensible option is marked wrong. | Accept "I’m fine, thanks." as well, or drop the second model answer and the "several replies" sentence. |
| CurriculumCatalog.json | a1-greetings-production-v3-5 | `exercise.options` | The distractor tile `but` builds a grammatical sentence — "I am fine but ready." — that is marked wrong. Same shape in `routine-01-production-v3-5` (`but` → "I study in the morning but cook at night.") and `a1-hobbies-production-v3-5` (`and` → "I like soccer and I do not play it."). | Remove the conjunction tile that produces a second correct sentence, or add the variant to `accepted`. |
| CurriculumCatalog.json | a1-alphabet-production-v3-5 | `answer` | `answer` promises "Could you repeat the letters, please?" but no option says it and `accepted` is only "Please repeat the letters." | Keep one model answer that is also an option. |
| CurriculumCatalog.json | a1-numbers-production-v3-4 | `exercise.options` | `accepted[1]` "How much does one ticket cost?" cannot be built: the tiles are `How / much / is / one / ticket? / many / are` — there is no `does` and no `cost`. | Add `does` and `cost` tiles, or drop the second accepted answer. |
| CurriculumCatalog.json | a1-dates-read | `exercise.options` | "Which month is the class in?" offers only one month: `March.`, `Monday.`, `April.`, `Nine.` The answer can be found by category (only two options are months), and two options are not months at all. | Use four months, e.g. `March.`, `April.`, `May.`, `June.` |
| CurriculumCatalog.json | a1-dates-production-v3-5 | `accepted` | The second accepted answer uses day-month order — "The appointment is at nine in the morning on Monday, 4 May." — in an en-US pack, and it contradicts the prompt's own "Monday / May 4". | Drop the second variant, or keep it as "on Monday, May 4, at nine in the morning". |
| CurriculumCatalog.json | a1-dates-transfer | `prompt` | British clock form: "Give Wednesday at half past five in the evening". American English says "five thirty". | "Wednesday at five thirty in the evening" |
| CurriculumCatalog.json | family-01-production-v3-3 | `answer`, `explanation` | `answer` promises "She is a teacher. / They are a teacher." and the explanation says singular *they* "is also valid when chosen", but `accepted` is only "She is a teacher." and no option offers it. | Either remove "They are a teacher" from `answer`/`explanation`, or add it to the options and `accepted`. |
| CurriculumCatalog.json | routine-01-production-v3-3 | `exercise.options` | "He does not ___ on Sunday. Use work." — the tiles include `works` and `working`, which is fine, but the prompt-embedded "Use work" gives the answer away in a `choice`. | Drop "Use work" from the prompt; the options already carry it. |
| CurriculumCatalog.json | food-01-recall-water | `accepted` | "Write a sentence that asks for water." accepts the bare word `water` before the sentence form. | `accepted: ["Can I have water?", "Could I have water, please?"]` |
| CurriculumCatalog.json | a1-shopping-production-v3-1 | `exercise.options` | `accepted[1]` "How much is the hat?" cannot be built: tiles are `How / much / is / this / hat? / are / these` — no `the`. | Add a `the` tile or drop the second accepted answer. |
| CurriculumCatalog.json | a1-places-production-v3-3 | `exercise.options` | `accepted[1]` "Go straight. Then turn right." needs a `straight.` tile; the tile is `straight,` (the checker normalizes punctuation, so this one does work — recording it only so the next proofreader does not "fix" it). | No change needed. |
| CurriculumCatalog.json | a1-hobbies-production-v3-3 | `prompt` | Stray space before the period: "Complete: She can ___ . Use swim." | "Complete: She can ___. Use swim." |
| CurriculumCatalog.json | a1-greetings-recall-morning | `exercise.options` | Mixed end punctuation in one set: `['Good morning', 'How are you?', 'I am fine', 'Goodbye']`; `a1-greetings-recall-how` repeats it. | Add the missing final stops, or drop all of them consistently. |
| CurriculumCatalog.json | intro-01-grammar-be-is | `prompt` | British noun: "Fill the gap with one word. He ___ in a shop." American English prefers "store". | "He ___ in a store." |
| CurriculumCatalog.json | a1-alphabet | `tip` | The tip teaches "to hear something again say “Please repeat that.”" but no exercise uses that phrase; the only exercise on the point (`a1-alphabet-production-v3-5`) keys "Please repeat the letters." | Add "Please repeat that." as an accepted variant, or teach the phrase the exercise uses. |
| CurriculumCatalog.json | a1-shopping | `tip` | The tip teaches "For more than one thing say “How much are these?”", but no exercise in the lesson uses the plural question (every item is `How much is …`). | Add one item on "How much are these?", or drop the sentence. |
| CurriculumCatalog.json | a1-dates | `tip` | `a1-dates-production-v3-5` asks for a full written date with commas, but the tip only covers `on` / `at` / `in` and says nothing about date order or commas. | Add one sentence: "Write a date in order: Monday, May 4, at nine." |
| CurriculumCatalog.json | a1-greetings | `tip` | The tip says to answer "How are you?" with "I am fine, thank you," but `a1-greetings-production-v3-4` requires "I am well, thank you." and marks a *fine* answer wrong. | Use "fine" in the exercise, or mention "well" in the tip. |

## Clean

- `a1-numbers`, `a1-home`, `a1-weather`, `a1-places`, `a1-hobbies`, `routine-01` and `food-01` tips match their exercises except where listed above.
- All 13 `supplement.teaching` blocks and all 65 `supplement.concepts` questions are accurate and use the same term the exercises use (for example `a1-home-concept-3` "Why use There are with two chairs?" matches `a1-home-production-v3-2`).
- Every `choice` set has one defensible answer; no duplicate options; every `accepted` value is an option (the validator's own checks pass, and I found no case the validator misses).
- No British spelling other than the clock form and "shop" above (`gray`, `color`, `organize`, `favorite` are all American).
- No double spaces, no missing space after a full stop, no stray punctuation besides `a1-hobbies-production-v3-3`.

## Highest-value fixes, in order

1. Convert `intro-01` to v4 — it is the only lesson in the set that still has no auto-checking on its reading and listening items.
2. Give the 11 A1 dictations sentences that are not already printed in the same lesson.
3. `family-01-production-v3-3` and `a1-greetings-production-v3-4`: the model answer promises a variant the checker rejects.
4. The 40 mixed-case recall option sets, and the 7 straight apostrophes.

Nothing above was applied; all of it is a proposal for Claude to accept, reject or rewrite.
