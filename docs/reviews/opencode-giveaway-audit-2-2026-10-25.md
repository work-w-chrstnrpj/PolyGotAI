# Job 14a — give-away audit, repeat (post-wave-B snapshot)

Read-only. No content was changed. This report is the only file this lane wrote.

**Validator at write time** (`python3 tools/curriculum/validate.py`, 2026-10-25 23:18):

```text
lexicon words: 866
course lessons: 57, track lessons: 256, typed exercises: 4074
OK
```

Last line: `OK`. This run is **after** LOG-0052 (Advanced, 256 coach lessons) and LOG-0053 (6b–6d cores), so it replaces the pre-wave-B snapshot. 2,603 choice items were measured across 57 course lessons and 256 coach lessons.

## What changed since Job 8

| Job 8 pattern | Job 8 | Wave A (22:52) | Now (23:18) | Verdict |
| --- | --- | --- | --- | --- |
| Answer is `options[0]` in the data | 1235/1265 | 2453/2483 (98.8%) | 2573/2603 (98.8%) | **Open in the data, not on screen**: `ExerciseActivityView.swift:38–45` shuffles with a seed of `activity.id + salt`. The 30 exceptions are all course True/False items whose `False` sits at index 1 (e.g. `a1-greetings-tf`); the shuffle hides that too. |
| Correct option strictly longest | 580/1265 (46%) | 1534/2483 (62%) | 1499/2603 (57.6%) | **Still open, and much worse inside the coaches**: Advanced 450/585 (77%), Intermediate 413/633 (65%), Foundation 403/677 (60%), course 193/598 (32%). |
| Answer printed verbatim in the prompt | 46 (41 exploitable) | 0 exploitable | **0 exploitable** | **Fixed.** The 5 remaining broad matches are `recall` ids (exempt by design). Enforced by `giveaway_problems` in `validate.py`. |
| Options that differ only by case/punctuation | 5 items | 0 | 0 | **Fixed and enforced.** |
| Dictation repeats an earlier printed sentence | 13 | 0 | 0 | **Fixed and enforced.** |
| True/False key balance | worst 9:6 | worst stage 1:8 (Journalist Advanced) | worst stage 0:8 (Storyteller Advanced) | **Worse in Advanced**: 27 True / 64 False across the stage. |
| `fillBlank` with one accepted word | 16 | 38 function words | 264/315 accept exactly one answer; 39 are function words | **Grew** with the new stages; partly by design (Grammarian). |

## Pattern 1 — the correct option is the longest (the main open flaw)

2,603 choice items: strict-longest 1,499 (57.6%), shortest 354 (13.6%), answer ≥ 1.5× the longest distractor 706 (27.1%). Per pack, the strict share is highest in the new coach content:

| pack | strict-longest / choice | share |
| --- | --- | --- |
| storyteller | 143/191 | 75% |
| negotiator | 144/194 | 74% |
| copywriter | 139/191 | 73% |
| journalist | 136/187 | 73% |
| creative-writer | 142/198 | 72% |
| business | 127/184 | 69% |
| public-speaker | 129/194 | 66% |
| debater | 127/196 | 65% |
| reading-listening | 153/259 | 59% |
| grammarian | 66/211 | 31% |
| course | 193/598 | 32% |

| file | id | field | problem | suggested fix |
| --- | --- | --- | --- | --- |
| `track-reading-listening.json` | `rl-a-synth-01` | `options` | Answer 113 chars, longest distractor 26: `"The effect may depend on the work: a manager survey suggests gains, while a small call-center trial finds none."` | Cut the answer to the claim, or give each distractor a matching clause. |
| `track-business.json` | `bz-i-pushback-01` | `options` | Answer 95 chars, next 21: `"I want the launch to succeed. I can’t finish by Friday, but I can send a first version Tuesday."` | Give the three distractors one clause each, or cut the answer to a single request. |
| `track-copywriter.json` | `cp-i-story-02` | `options` | Answer 92 chars, next 19: `"Mira worked late and her eyes hurt. She switched lamps. Now she finishes without a headache."` | Same: make all four a two-clause story beat. |
| `track-public-speaker.json` | `ps-a-hostile-01` | `options` | Answer 88 chars, next 24: `"I hear that frustration. Let me tell you how this plan came from residents’ suggestions."` | Shorten the answer or lengthen distractors. |
| `track-journalist.json` | `jn-i-lede-04` | `options` | Answer 83 chars, next 22: `"A fire damaged the Corner Bakery early Monday, but no one was hurt, the owner said."` | Keep all four as one-line ledes. |
| `track-debater.json` | `db-a-close-02` | `options` | Answer 78 chars, next 20: `"Even if they win the cost point, our point concerns lives, which matters more."` | Same. |
| `track-business.json` | `bz-a-crisis-02` | `options` | Answer 74 chars, next 15: `"What happened, what you know, what you do not know, and what you are doing"` | Distractors are 2–3 words; give each the same four-part shape. |
| `track-negotiator.json` | `ng-a-pressure-04` | `options` | Answer 73 chars, next 15: `"I notice the deadline is very tight. What happens if we need another day?"` | Same. |

The cause is unchanged from Job 8: the prompt is often a passage and the answer is a near-verbatim line from it, so the answer inherits the passage's length while distractors are short authored lines. A length-ratio check in `validate.py` (same style as the give-away checks) would stop the next batch. `rl-a-synth-01` is the clearest new case.

## Pattern 2 — the answer is printed in the prompt

Sharp measure (answer ≥ 2 words, printed in the prompt, no distractor printed): **0 exploitable items**. The five broad matches are `recall-morning`, `recall-night`, `b1-relationships-recall-known`, `b1-achievements-recall-proud`, `c1-strategy-recall-who`; all are `recall` by design and exempt. The check is enforced by `validate.py`.

## Pattern 3 — True/False key balance

Overall 197 True / 228 False. Per stage:

| Stage | True | False |
| --- | --- | --- |
| Advanced | 27 | 64 |
| Intermediate | 59 | 64 |
| Foundation | 78 | 61 |
| Starter | 7 | 9 |
| A1 | 3 | 9 |
| A2 | 6 | 5 |
| B1 | 6 | 4 |
| B2 | 5 | 5 |
| C1 | 4 | 4 |
| C2 | 2 | 3 |

Worst packs: Storyteller Advanced 0/8, Journalist Advanced 1/8, Course A1 3/9, Reading & Listening Advanced 1/7, Business Advanced 2/6, Copywriter Advanced 2/6, Creative Writing Advanced 2/6, Reading & Listening Intermediate 8/4. A learner who always answers False gets 64/91 (70%) in Advanced and 8/8 in Storyteller Advanced. This is the largest exploitable pattern after the length bias; the new Advanced items were written mostly with False keys.

## Pattern 4 — options that differ only by case or punctuation

None. The five items Job 8 listed are clean, and the validator now rejects new ones.

## Pattern 5 — `fillBlank` with one accepted answer

315 `fillBlank` items; 264 accept exactly one answer (84%), 39 of those are function words (Grammarian 17, course 8, Negotiator 4, Business 2, Creative Writing 2, Debater 2, one each in Journalist, Public Speaking, Reading & Listening, Storytelling). The Grammarian 17 are the lesson's point (`gram-be-amisare-07/08`, `gram-be-have-07/08`, `gram-be-do-07`, `gram-f-present-10`, `gram-f-future-10`, `gram-f-modal-10`, `gram-f-prep-10`, `gram-i-cond-10`, `gram-i-passive-10`, `gram-i-relative-10`, `gram-i-reported-10`, `gram-sent-join-06`). Outside Grammarian:

| file | id | accepted | prompt |
| --- | --- | --- | --- |
| `track-business.json` | `bz-i-call-09` | `when` | “Type the missing word: Spell the name ___ you need to.” |
| `track-business.json` | `bz-a-clause-09` | `when` | “Type the missing word: Specify who does what and by ___.” |
| `track-creative-writer.json` | `cw-setting-11` | `when` | “Type the missing word: Setting means where and ___ a scene happens.” |
| `track-creative-writer.json` | `cw-pov-10` | `they` | “Type the missing word: In third person, the narrator uses “he,” “she” or ___.” |
| `track-debater.json` | `db-structure-10` | `For` | “Type the missing word: ___ example, many cities have done this.” |
| `track-debater.json` | `db-i-cause-10` | `before` | “Type the missing word: The effect cannot come ___ the cause.” |
| `track-journalist.json` | `jn-i-record-09` | `before` | “Type the missing word: Agree the rule ___ the person speaks.” |
| `track-negotiator.json` | `ng-concede-08` | `will` | “Type the missing word: If you agree, I ___ start tomorrow.” |
| `track-negotiator.json` | `ng-i-trade-09` | `then` | “Type the missing word: If you pay today, ___ I can lower the price.” |
| `track-negotiator.json` | `ng-i-ask-09` | `no` | “Type the missing word: An open question cannot be answered with yes or ___.” |
| `track-negotiator.json` | `ng-i-close-09` | `on` | “Type the missing word: So I will send the file ___ Friday.” |
| `track-public-speaker.json` | `ps-signpost-10` | `To` | “Type the missing word: ___ sum up, the plan is simple.” |
| `track-reading-listening.json` | `rl-f-notes-09` | `the` | “Type the missing word: Leave out small words like a and ___.” |
| `track-storyteller.json` | `st-i-abt-10` | `but` | “Type the missing word: Rita lost the watch, ___ no one had seen it.” |
| `CurriculumCatalog.json` | `a2-work-recall-while` | `while` | “Write the word that links two things happening together.” |
| `CurriculumCatalog.json` | `a2-problems-recall-so` | `so` | “Write the word that introduces a result.” |
| `CurriculumCatalog.json` | `b1-education-recall-because` | `because` | “Write the word that gives a reason.” |
| `CurriculumCatalog.json` | `b1-entertainment-recall-while` | `while` | “Write the word that links two things true at the same time.” |
| `CurriculumCatalog.json` | `b1-decisions-recall-because` | `because` | “Write the reason after the choice.” |
| `CurriculumCatalog.json` | `b2-social-recall-while` | `while` | “Write the word that links two effects that happen together.” |
| `CurriculumCatalog.json` | `b2-present-recall-then` | `then` | “Write the word that orders the next move.” |
| `CurriculumCatalog.json` | `c1-policy-recall-or` | `or` | “Write the word that warns of the consequence.” |

The bigger risk is the 264/315 single-accepted figure: a legitimate variant outside `accepted` still fails a correct learner. That is unchanged from Job 8 and is not addressed by any validator check. `AnswerChecker` accepts contractions, case and punctuation, so only real word-choice variants are at risk.

## New finding — dictation button on listen-and-write exercises

`ExerciseActivityView.typedBody` always applies `.dictation($typed)` (`:283`), and `listenType` falls into `typedBody` (`:166`). The mic button therefore appears under “Type what you hear”, so a learner can repeat the clip into the mic instead of listening and typing. The TDD still says the button is “hidden for listen-and-write exercises” (`docs/tdd/tdd.md:169`). Either hide it for `listenType` (product) or correct the TDD (doc); this report only records the mismatch.

## Where this stopped

All five requested patterns were measured across the full 2,603-item set on the settled 256-lesson tree. The verbatim/twin/dictation checks are enforced by `validate.py`; the longest-option, True/False and single-accepted-answer patterns are not. The two changes worth acting on before the next content batch are the Advanced True/False skew (27/64) and the length ratio in the coach packs (65–77% strict). The audit did not re-read every option for meaning or correctness — only the five patterns above.
