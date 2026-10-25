# Proofread: A2–C2 course lessons

Read-only proofreading report. No source file was changed. Only this file was written.

**Validator output** (`python3 tools/curriculum/validate.py`, run 2026-10-25):

```text
lexicon words: 866
course lessons: 57, track lessons: 80, typed exercises: 1848
OK
```

The last line is `OK`. The lexicon count now reads **866**, not the 722 recorded in `opencode-proofread-lexicon-2026-10-25.md`: the bank grew from 18 to 23 files (five new `field-*` groups) while this review was running. That affects Job 1 only, not this report — the lesson catalog (`57` course lessons, `1848` typed exercises) is unchanged.

## Scope and method

- File reviewed: `application/SpeechCoachAI/Resources/Curriculum/CurriculumCatalog.json`.
- All 44 non-A1 lessons read in full: **A2 11, B1 10, B2 10, C1 8, C2 5** = 748 activities. (The 13 A1 lessons are outside this job; they are referenced only where a defect is systemic.)
- Every finding below was re-checked against the JSON after reading, so quotes are exact.
- Checked: typos, grammar, punctuation, American spelling, choices with two correct options, wrong answer keys, missing accepted variants, unclear prompts, quote consistency.
- Not checked: audio files themselves (only `audioText`/`answer`), track lessons under `Resources/Tracks/`, A1 content.

## Systemic findings

These are single defects repeated across many activities. They are counted once, not once per activity.

| file | id | field | problem | suggested fix |
| --- | --- | --- | --- | --- |
| `CurriculumCatalog.json` | 54 items, all `kind: recall` (A2 24, B1 20, C1 5, B2 3, C2 2) | `answer` vs `exercise.accepted[0]` | `answer` and `accepted[0]` disagree, e.g. `a2-travel-recall-went` has `answer: "I went to …"` but `accepted: ["I went"]` and option `"I went"`. Two learner-visible effects: (1) the EXAMPLE block prints `answer` (`LessonPlayerView.swift:347–350`) while the tile the learner tapped is the option, so the model answer looks different from the correct answer; (2) `feedbackTitle` compares the tapped text with `answer` (`LessonPlayerView.swift:788–789`), so a **correct** answer still shows “Let’s look at the pattern” instead of “That fits the sentence”. Grading itself is unaffected — choice grading only tests `accepted` (`Exercise.swift:77–78`). | Make `answer` equal `accepted[0]`, i.e. the option text (`"I went"`). Keep the sentential frame in `prompt` or `explanation`, not in `answer`. |
| `CurriculumCatalog.json` | 44 `*-tf` items | `answer` | The True/False key is `False` in **43 of 44** items; the only `True` is `b1-career-tf`. A learner who always taps False scores 98% on this whole item type. | Rebalance to roughly half True. Easiest edit: rewrite ~20 `*-tf` prompts as true statements (e.g. `a2-travel-tf` → “True or false: Mina stayed with her aunt in Chicago.”). |
| `CurriculumCatalog.json` | 20 occurrences in 18 strings across 8 lessons (`a2-transport`, `a2-health`, `a2-invitations`, `b1-relationships`, `b1-culture`, `b2-innovation`, `b2-disagree`, `c2-debate`) | `tip`, `prompt`, `answer`, `accepted`, `options` | Apostrophe style is split by level. Every A2–C2 lesson uses the **straight** apostrophe only: 20 straight, **0 curly**, e.g. “Mina's taxi” (`a2-transport-read`), “Let's meet” (`a2-invitations-recall-lets`), “one other's” (`b1-relationships-g4`), “her colleague's case” (`c2-debate-read`). A1 is the opposite: 45 curly versus 9 straight. Both characters render differently on screen, so “Mina’s” looks unlike “Mina's” from lesson to lesson. The lexicon bank is curly-only, which suggests curly is the house style. | Replace `'` with `’` in those 20 places so the whole course (and the bank) uses one style. Typographic only: `AnswerChecker.words` normalizes quotes, so no answer or grading change. |
| `CurriculumCatalog.json` | 7 items with an untypeable template — `b1-education-recall-because`, `b1-relationships-recall-although`, `b1-culture-recall-usually`, `b1-culture-recall-whereas`, `b1-community-recall-started`, `b2-disagree-recall-although`, `c1-research-recall-although` — plus 5 more that ask for a clause: `b1-entertainment-recall-while`, `b2-social-recall-while`, `c1-problems-recall-unless`, `c1-policy-recall-or`, `c1-debate-recall-whereas` | `prompt` vs `exercise.accepted` | These are typed `fillBlank` items whose prompt asks for a clause (“Write a sentence that gives a reason for a study choice.”, “Write a contrast between two customs.”, “Write the condition the partial fix ignores.”) but whose accepted answers are a bare connector — in the 7 worst cases with a template that can never be typed: `["because", "I study … because …"]`. `AnswerChecker.words` strips `…`, so that value collapses to a fragment (`["i","study","because"]`). A learner who follows the prompt and writes a real sentence is marked wrong; only the connector passes. The 5 without a template have the same problem in milder form (`b1-entertainment-recall-while` accepts only `"while"`). Contrast the correctly built `b1-unexpected-recall-stopped`, which accepts a real sentence (`"The train stopped"`). | Either change the prompt to “Write the word that …” (as the other single-word items do) or accept real variants — always without `…` inside `accepted`. |
| `CurriculumCatalog.json` | `a2-leisure` (11 mentions), `b1-entertainment` (4), `a2-invitations` (2), `a2-past` (2) | `title`, `tip`, `prompt`, `options`, `audioText` | British vocabulary in an American-English course: **19 mentions of `film` across 4 lessons**. `b1-entertainment` is built around it (title “Recommend a show or film”, “rather watch a short series than a film on a weeknight”), and `a2-leisure` teaches “We saw a film.” American English uses “movie”. Low priority — understood everywhere — but the curriculum outline states American usage is the default, and the same lessons use American forms elsewhere. | Use “movie” (or “show”). Keep one deliberate `film` mention only if you want to teach the British variant explicitly. |

## A2 (11 lessons)

| file | id | field | problem | suggested fix |
| --- | --- | --- | --- | --- |
| `CurriculumCatalog.json` | `a2-leisure-read` | `options[3]` | `"The concert was cancelled."` — British spelling. | `"The concert was canceled."` |
| `CurriculumCatalog.json` | `a2-invitations-g1` | `prompt`, `options` | “Fill in the blank: ___ you like to come?” accepts `Would`, but the distractor `Do` also yields grammatical English (“Do you like to come?”). With no context the item has two defensible answers. | Add the context that forces the invitation reading, e.g. “Invite a classmate politely: ___ you like to come?” — or replace `Do` with a clearly wrong form. |
| `CurriculumCatalog.json` | `a2-eating` tip and `a2-eating-recall-bill` | `tip`, `answer`, `options` | Lesson teaches `"ask for “the bill”"` and the recall item's answer is `"the bill"`. In US restaurants this is “the check”. Low priority — “bill” is understood — but this lesson is exactly where the American word should be taught. | Use “the check” (optionally note that British English says “bill”). |
| `CurriculumCatalog.json` | `a2-leisure` tip | `tip` | `"We saw a film."` / `"We walked after the film."` — British. | “We saw a movie.” / “We walked after the movie.” |
| `CurriculumCatalog.json` | `a2-invitations-read` | `options[2]` | `"He is on holiday."` — British; American English says “on vacation”. Low priority, and it is only a distractor here, but it is the same course that teaches American forms. | `"He is on vacation."` |

A2 checked clean apart from the above and the systemic rows: `a2-travel`, `a2-transport` (apart from the straight apostrophe), `a2-appointments`, `a2-health` (apart from apostrophes), `a2-work`, `a2-past` (apart from `film` in `-g4`), `a2-plans`, `a2-problems`. Answer keys, distractors and `accepted` lists in those lessons are correct and unambiguous.

## B1 (10 lessons)

| file | id | field | problem | suggested fix |
| --- | --- | --- | --- | --- |
| `CurriculumCatalog.json` | `b1-technology-read` | `prompt` | “When the app failed, she **had better write** the time down before she forgot it.” `had better` is advice about the future, not a past narrative form — the sentence is ungrammatical and contradicts its own past tense (“before she forgot it”). This is learner-facing reading text. | “When the app failed, she **wrote** the time down before she forgot it.” |
| `CurriculumCatalog.json` | `b1-decisions` (5 mentions: `tip`, `-dictation` `answer`/`audioText`/`accepted[0]`, `-g1` prompt) and `b1-relationships-read` (1) | `tip`, `answer`, `accepted`, `audioText`, `prompt` | `flat` is used where American English says “apartment”, 6 times across two lessons: `"I chose the smaller flat because it was closer."`, the dictation `"I chose the smaller flat because it was closer to work."`, `"Choice: I ___ the smaller flat."`, and `"Mina and her brother argue about money, although they still share a flat."` | “apartment” in all six places. The dictation changes, so update `answer`, `accepted[0]` and `audioText` together. |
| `CurriculumCatalog.json` | `b1-entertainment` | `title`, `prompt` | Title “Recommend a show or **film**”; `-read` “than a **film** on a weeknight”; `-tf` “rather watch a **film** than a short series”. | “movie”. |

B1 checked clean apart from the above and the systemic rows: `b1-education`, `b1-career` (its `-tf` is the catalog's only `True` key — correct as written), `b1-community`, `b1-achievements`, `b1-unexpected`, `b1-culture` (apart from the straight apostrophe). Grammar items `b1-education-g2` (`harder than`), `b1-relationships-g3` (`although`), `b1-culture-g4` (`such as`) are correct with clean distractors.

## B2 (10 lessons)

| file | id | field | problem | suggested fix |
| --- | --- | --- | --- | --- |
| `CurriculumCatalog.json` | `b2-environment-listen` | `prompt` | “Play the recording. **What did more than the poster campaign?**” — the verb is missing, so the question is ungrammatical as written. The expected answer is the gerund `"Cutting the commute by two days a week."` | “**What cut more than the poster campaign?**” (then the gerund answer reads naturally). |
| `CurriculumCatalog.json` | `b2-media-read` | `prompt` | Passage and question contradict each other. Passage: “Mina **treats** a viral clip as if it were the whole event.” Question: “What does she **refuse** to treat as the whole event?” Keyed answer: “A viral clip.” As written, the passage says the opposite of what its own question asks, so the item cannot be answered from the text. | “Mina **refuses to treat** a viral clip as if it were the whole event.” |
| `CurriculumCatalog.json` | `b2-social-listen` | `options[1]` | `"Shop owners."` — in American English generic retail is “store owners” (“shop” is kept for repair/coffee/bike shops). Low priority; it is a distractor, not a key. | `"Store owners."` |

B2 checked clean apart from the above and the systemic rows: `b2-projects`, `b2-leadership`, `b2-social` (apart from `Shop owners`), `b2-innovation` (apart from the straight apostrophe), `b2-ethics`, `b2-present`, `b2-negotiation`, `b2-disagree` (apart from apostrophe + the `…` accepted template). Note `b2-ethics-read` (“owes users a plain reason unless the data is required for the service they asked for”) is convoluted but consistent and intentional — not reported as an error.

## C1 (8 lessons)

| file | id | field | problem | suggested fix |
| --- | --- | --- | --- | --- |
| `CurriculumCatalog.json` | `c1-change-read` | `prompt` | “she gives them a week with **the old and new side by side**” — a noun is missing; “the old and new” has no head. The same lesson's `c1-change-tf` explanation reads “a week with the old and new **tools** side by side”, which confirms the intended wording. | “…with the old and new **tools** side by side.” |
| `CurriculumCatalog.json` | `c1-policy-g2` | `prompt` | Label is `"Result:"` but the keyed answer is `or`: “Result: Write it down, ___ people will invent a path.” `or` is a warning, not a result — and the lesson's own tip calls it a warning. The label teaches the wrong relation. | Label it `"Warning:"` (matching the tip). |
| `CurriculumCatalog.json` | `c1-culture-g1` | `prompt` | Label is `"Contrast:"` but the keyed answer is `and`, which adds rather than contrasts: “Contrast: A direct no can be clarity in one team ___ a closed door in another.” | Label it `"Addition:"`, or change the sentence so the blank is genuinely contrastive (`whereas`). |
| `CurriculumCatalog.json` | `c1-problems-recall-tangled`, `c1-sensitive-recall-uneven` | `answer` vs `options[0]` | `answer` is `"Two causes are tangled."` / `"The load is uneven."` while the option and `accepted[0]` are lower-case and unpunctuated (`"two causes are tangled"`, `"the load is uneven"`). The EXAMPLE block and the tile therefore differ, and the feedback line misfires (see systemic row 1). | Use the same string in both places, capitalised and punctuated in both. |

C1 checked clean apart from the above and the systemic rows: `c1-strategy`, `c1-research`, `c1-debate`, and the remaining `c1-change`/`c1-policy`/`c1-sensitive` items. The `c1-change` vocabulary (`practice` as a verb — correct American spelling, not British `practise`) is right. `queue` in `c1-problems-read` (“make the queue look polite”) is kept: it is standard American English for a queue of messages and requests, not a British-only word.

## C2 (5 lessons)

| file | id | field | problem | suggested fix |
| --- | --- | --- | --- | --- |
| `CurriculumCatalog.json` | `c2-interpret-recall-history` | `options[0]` | The prompt is “Choose what can settle it.”, the `answer` is `"the history between the speakers"`, but the option and `accepted[0]` are truncated to `"the history between"` — which dangles (“between” with nothing after it) and does not match the model answer. | Make the option `"the history between the speakers"`. |
| `CurriculumCatalog.json` | `c2-debate-recall-is-not` | `prompt`, `options[0]` | Prompt says “Choose the best **start** for a sentence that separates facts from what follows.” The option is `"is not"`, which is not a start; the `answer` is the full frame `"Agreement on the facts is not …"`. | Make the option the frame, or change the prompt to “Choose the words that separate the two claims.” |

C2 checked clean apart from the above and the systemic rows: `c2-abstract`, `c2-debate` (apart from the straight apostrophe), `c2-culture`, `c2-multi`. The C2 register and the “less … than …”, “only if”, “worth keeping” items read correctly.

## Answer keys and accepted lists

- Every `choice` item has its keyed answer inside `options`, and no item was found where the key is simply wrong. No item was found with two *correct* options other than `a2-invitations-g1` above.
- `accepted` lists in the typed items are otherwise consistent with their prompts. There are 37 typed `fillBlank` items in A2–C2: 12 are the ones to revisit in the systemic row above, and the other 25 are sound — 23 accept one word behind a “Write the word / verb / past of …” prompt, and 2 correctly accept a whole phrase (`a2-invitations-g4` “Let's / Let us”, `b1-unexpected-recall-stopped` “The train stopped”). Do not widen the 23 single-word items.
- No missing obvious variants were found in `fillBlank`/`listenType` beyond the `…` templates in the systemic row.

## Lessons with no findings beyond the systemic rows

Clean across every checked field, apart from the shared systemic rows above (which are counted there, not here): `a2-travel`, `a2-appointments`, `a2-work`, `a2-plans`, `a2-problems`, `b1-education`, `b1-career`, `b1-community`, `b1-achievements`, `b1-unexpected`, `b2-projects`, `b2-leadership`, `b2-social`, `b2-ethics`, `b2-present`, `b2-negotiation`, `c1-strategy`, `c1-research`, `c1-debate`, `c2-abstract`, `c2-culture`, `c2-multi`.

## Not checked

- The 13 A1 lessons (outside this job), except where they appear in systemic counts.
- The 80 track lessons in `Resources/Tracks/`.
- Audio recordings (only the text fields that describe them).
- Whether the shipped code renders every field as intended — that is the Job 3 / reviewer scope. The two code paths quoted above are cited only to explain the learner-visible effect of the data.
