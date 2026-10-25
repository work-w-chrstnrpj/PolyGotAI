# OpenCode proofread — Job 1 — 2026-10-25

**Validator last line:** `OK`

Full validator output (for context):

```text
lexicon words: 120
course lessons: 57, track lessons: 8, typed exercises: 272
OK
```

Read-only job. No product file was edited. Reviewer: Claude.

**Scope (4 files, 224 learner items):** `application/SpeechCoachAI/Resources/Tracks/track-grammarian.json` (8 lessons, 104 activities), `Resources/Lexicon/lexicon-1-everyday.json`, `lexicon-2-work.json`, `lexicon-3-academic.json` (40 words each). Read one file at a time in batches of one to two lessons / 40 words. All 4 files were finished; nothing was skipped.

**Checks run:** typos, grammar, punctuation, American spelling; two-correct-option items; accepted answers that miss a variant; unclear prompts; quotation-mark and apostrophe consistency; Lexicon `wrong` sentences that are really correct English. Answer matching was read in `Domain/Exercise.swift` and `Domain/AnswerChecker.swift` first, so leniency is judged against what the app actually does: case, punctuation and curly quotes are ignored, and contractions are expanded (`don't` = `do not`, `can't` = `cannot`).

**Result:** 24 findings (1 high, 9 medium, 14 low). No structural or validation problem to report. No American-spelling error and no typo in any `meaning`, `example` or `tip`. No `wrong` sentence is broken English; 9 `wrong` sentences are grammatical and use the word correctly, which is the only reason they are listed.

---

## 1. `application/SpeechCoachAI/Resources/Tracks/track-grammarian.json`

| file | id | field | problem | suggested fix |
| --- | --- | --- | --- | --- |
| track-grammarian.json | all 38 `choice` activities | `exercise.options` | **Pattern, affects every lesson.** The correct answer is `options[0]` in 38 of 38 choice items, so a learner can score full marks by always tapping the first option. | Shuffle options at display time, or vary the authored position (roughly a quarter of items per slot). |
| track-grammarian.json | gram-sent-subject-09 (same defect in `gram-sent-object-09`, `gram-sent-command-09`, `gram-be-amisare-11`, `gram-be-have-11`, `gram-be-do-10`, `gram-be-dont-10`) | `prompt` | The sentence to repair is not set off from the instruction: `"Find the mistake, then write the sentence correctly. Play children in the park."` The wrong sentence reads as a second instruction ("Play, children, in the park"), and elsewhere the file quotes target sentences with curly quotes. | `"Find the mistake, then write the sentence correctly: “Play children in the park.”"` — apply the same colon + quotes to all 7 `spotError` prompts. |
| track-grammarian.json | gram-sent-subject-11 | `prompt` + `exercise.options` | **Two defensible answers.** `"Which sentence starts correctly?"` with options `"She sings."`, `"she sings."`, `"She sings"`, `"Sings she."` — `"She sings"` also *starts* correctly; its only fault is the missing final period, which is about ending, not starting. | `"Which sentence has a capital letter and a period?"` (or replace `"She sings"` with `"sings She."`). |
| track-grammarian.json | gram-sent-subject-12 (and `gram-sent-subject` `tip`) | `prompt` / `tip` | `"True or false: A sentence needs a subject and a verb."` → `"True"`, and the tip says `"A sentence needs a subject (who or what) and a verb"`. Lesson 3 then teaches that `"A command starts with the verb: “Open the door.”"`, which has no subject, so the pack contradicts itself. | `"True or false: A statement needs a subject and a verb."` and tip: `"Every statement needs a subject (who or what) and a verb."` |
| track-grammarian.json | gram-sent-join-02 | `exercise.options` | `"You want to show a difference: I am small, ___ my brother is tall."` — `"and"` also makes correct English (`I am small, and my brother is tall.`). Only the instruction word "difference" excludes it, so the item reads as two acceptable options. | Remove `"and"` (`but`, `or`, `so`), or add a contrast that only `but` fits. |
| track-grammarian.json | gram-sent-join-12 | `prompt` | `"Use and, but and or once each."` — ambiguous list (`and but and or`), and it conflicts with the serial comma used in the lesson title `"Join with and, but, or"`. | `"Use “and”, “but”, and “or” once each."` |
| track-grammarian.json | gram-sent-command-08, gram-be-dont-09, gram-be-do-09 (all 8 `match` items) | `answer` | The `answer` string glues pairs with `= …; `, producing broken punctuation: `"Someone is at the door. = Come in, please.; The baby is asleep. = Be quiet, please.; Your friend is lost. = Follow me."` and `"Do you like tea? = Yes, I do.; Does she swim? = No, she doesn't.; Do they know you? = Yes, they do."` | Strip the trailing period before the separator or use an arrow and one pair per line: `"Someone is at the door → Come in, please"`. |
| track-grammarian.json | gram-be-have-10 | `exercise.pairs` | Every right-hand option starts with `has` (`"has two wheels"`, `"has five fingers"`, `"has seven days"`), so the match can be solved by elimination without knowing `have`/`has`. | Use bare noun phrases on the right (`"two wheels"`, `"five fingers"`, `"seven days"`) or mix `have`/`has` targets. |
| track-grammarian.json | gram-be-have | `tip` | `"Use “has” with he, she, it and with one person or thing"` — "one person or thing" is not a category a learner can apply (it is a singular noun). | `"Use “has” with he, she, it and with any singular noun (one person, one thing): “She has a bike.”"` |
| track-grammarian.json | gram-be-dont-08 | `answer` / `exercise.items` | `"I don't watch TV today."` — present simple with "today" is unnatural (a native speaker says "I'm not watching TV today" or "I don't watch TV on Sundays"). | `"I don't watch TV on Sundays."` (same target form, natural). |
| track-grammarian.json | gram-be-do, gram-be-dont | `tip` | Nonstandard term for A1: `"the main verb stays simple: like, not likes"` and `"before the simple verb"`. | `"the main verb stays in the base form: like, not likes"` and `"before the verb in its base form"`. |
| track-grammarian.json | gram-sent-object-06 | `exercise.accepted` | Accepts `"window"` as well as `"the window"` while the prompt asks for the object of `“We open the window.”`; `gram-sent-object-05` accepts only `"water"`, so leniency is inconsistent. | Accept `"the window"` only. |
| track-grammarian.json | whole file (69 straight apostrophes, 46 curly quotes) | `tip`, `prompt`, `options`, `accepted` | Mixed typography: curly double quotes wrap text that contains straight apostrophes — `"use “do not” (don't) or “does not” (doesn't)"`, `"“I don't like rain.”"`, `"Does she likes music?"`. The file contains zero curly apostrophes. | Use `’` inside quoted text (`don’t`, `doesn’t`, `I don’t`) or, if straight is the house style, use straight double quotes too. |

---

## 2. `application/SpeechCoachAI/Resources/Lexicon/lexicon-1-everyday.json` (40 words)

The `wrong` question is `"Which sentence uses “<lemma>” correctly?"`, so a distractor must be wrong in its use of the word. Findings:

| file | id | field | problem | suggested fix |
| --- | --- | --- | --- | --- |
| lexicon-1-everyday.json | answer | `meaning` | The definition and the only example teach different senses: `"To say or write something after a question."` vs `"Please {answer} the phone."` | `"To say or write something after a question, or to pick up the phone when it rings."` |
| lexicon-1-everyday.json | repeat | `wrong[0]` | `"I repeat the word once and only one time."` is correct English — redundant, not wrong. A learner can defend it as the correct-use sentence. | `"I repeat the word for the first time."` |
| lexicon-1-everyday.json | neighbor | `wrong[0]` | `"My neighbor lives in another country, far from my house."` is grammatical and often true of a former neighbour; it only conflicts with the definition. | `"My neighbor lives on the moon and has never been near my house."` |
| lexicon-1-everyday.json | lunch | `wrong[0]` | `"I eat lunch at midnight, before breakfast."` is correct English and factually normal for night-shift workers. | `"I eat lunch while I sleep."` |
| lexicon-1-everyday.json | weather | `meaning` | `"The sun, rain, wind or cold outside."` is a list, not a definition; it reads as a fragment. | `"The conditions outside, such as sun, rain, wind or cold."` |

---

## 3. `application/SpeechCoachAI/Resources/Lexicon/lexicon-2-work.json` (40 words)

| file | id | field | problem | suggested fix |
| --- | --- | --- | --- | --- |
| lexicon-2-work.json | feedback | `wrong[0]` | `"I gave my boss feedback before I did the presentation."` is correct English, plausible, and uses "feedback" correctly (comments on a plan). | `"I gave my boss feedback by saying nothing at all."` |
| lexicon-2-work.json | interview | `wrong[0]` | `"At the interview, I asked the manager all the questions and she said nothing."` is correct English and a normal interview event; "interview" is used correctly. Only the definition's role assignment makes it wrong. | `"The interview asked me twenty questions."` |

---

## 4. `application/SpeechCoachAI/Resources/Lexicon/lexicon-3-academic.json` (40 words)

| file | id | field | problem | suggested fix |
| --- | --- | --- | --- | --- |
| lexicon-3-academic.json | indicate | `wrong[0]` | `"The results indicate that nobody knows anything."` is correct English and a textbook use of "indicate". | `"The results indicate nothing, so we know exactly what happened."` |
| lexicon-3-academic.json | evidence | `wrong[0]` | `"He has no evidence, but he is completely sure it is a fact."` is correct English with "evidence" used correctly; it is a statement, not a misuse. | `"Evidence is a person who tells stories."` |
| lexicon-3-academic.json | respond | `wrong[0]` | `"I responded before I read the email."` is correct English and a real thing people do. | `"I responded the email yesterday."` (shows the missing "to"). |
| lexicon-3-academic.json | source | `wrong[0]` | `"The report has no source and no one wrote it."` is grammatical and uses "source" correctly; only the content is odd. | `"The report's source is a kind of soup."` |

---

## 5. Lower-confidence notes (judgement calls, not counted above)

Same pattern as the rows above: grammatical sentence, word used correctly, wrong only because it contradicts the definition. Flagged for Claude's judgement, not as errors:

- `lexicon-1-everyday.json` / window: `"It is freezing, so please open the window wide."`
- `lexicon-2-work.json` / colleague: `"My colleague lives in another country and I have never met her."` (the definition allows a remote colleague)
- `lexicon-2-work.json` / manager: `"The manager follows all the orders of the new employee."`
- `lexicon-2-work.json` / invoice: `"The invoice shows the date of our next holiday."`
- `lexicon-2-work.json` / supervisor: `"My supervisor is the newest worker and has no team."`
- `lexicon-2-work.json` / agenda: `"We read the agenda after the meeting ended."`
- `lexicon-2-work.json` / submit: `"I submit the form to myself and nobody reads it."`

Design note, not a text error: most `wrong[0]` entries are logical contradictions and most `wrong[1]` entries are grammar errors. That split is consistent across all three groups, which is good, but it means `wrong[0]` is often "correct English with a false statement" — the 9 rows above are the cases where a learner can reasonably argue the sentence is fine.

---

## 6. What is clean

- **Validator:** no structural problem; nothing to list.
- **American spelling:** clean in all 4 files. No `colour`/`organise`/`practise`/`centre`/`travelling` forms; `favorite`, `neighbor`, `analyze`, `toward`, `license` are correct US forms. Zero hits across a 36-word British-spelling list.
- **Typos:** none found in `tip`, `prompt`, `meaning`, `examples`, `options`, `accepted`, `audioText` or `wrong` after reading all 224 items.
- **Missing accepted variants:** none to report. `AnswerChecker` already lowercases, strips punctuation, folds curly quotes and expands contractions, so `Don't`/`Do not`, `doesn't`/`does not`, `can't`/`cannot` and period-free input are all accepted without extra `accepted` entries.
- **Duplicate options:** none. `gram-sent-subject-11` differs only by capital letter, which is intended (choice matching is exact) — the problem there is the prompt, reported above.
- **Formatting:** no double spaces, no leading or trailing spaces, no straight double quotes inside values, no stray markdown in any of the 4 files.
