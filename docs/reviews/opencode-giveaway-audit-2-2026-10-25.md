# Job 14a — give-away audit, repeat (snapshot before the wave-B log entry)

Read-only. No content was changed. This report is the only file written.

**Validator at write time** (`python3 tools/curriculum/validate.py`, 2026-10-25 22:52):

```text
lexicon words: 866
course lessons: 57, track lessons: 240, typed exercises: 3871
OK
```

Last line: `OK`. This is a **snapshot before Claude logs "wave B content done"**: while the audit ran, track lessons went 176 → 240 and typed exercises 3087 → 3871 (Advanced now present for 8 coaches; Grammarian and Reading & Listening still hold Starter instead). It read 248 lessons / 3975 exercises at 22:54; the counts below are pinned to the 22:52 tree and should be re-read after the log entry.

## What changed since Job 8

| Job 8 pattern | Job 8 | Now (22:52) | Verdict |
| --- | --- | --- | --- |
| Answer is `options[0]` in the data | 1235/1265 | 2453/2483 (98.8%) | **Open in the data, not on screen**: `ExerciseActivityView.swift:38–45` shuffles with a seed of `activity.id + salt`, so each item has its own order. `validate.py` documents the convention. Not a learner-visible tell. |
| Correct option strictly longest | 580/1265 (46%) | 1534/2483 (62%) | **Worse.** Still open; not checked by the validator. |
| Answer printed verbatim in the prompt | 46 (41 exploitable) | 61 broad, **0 exploitable** | **Fixed** by the new `giveaway_problems` check in `validate.py`; the 5 that remain are `recall` ids (exempt by design). |
| Options that differ only by case/punctuation | 5 items | 0 | **Fixed.** |
| Dictation repeats an earlier printed sentence | 13 | 0 | **Fixed.** |
| True/False key balance | worst 9:6 | worst stage 1:8 (Journalist Advanced) | Small-sample skew in the new stages; see below. |
| `fillBlank` single accepted function word | 16 | 38 | **Grew** with Intermediate/Advanced content; partly by design (Grammarian). |

## Pattern 1 — the correct option is the longest (still the main open flaw)

2483 choice items: strict-longest 1534 (62%), shortest 481 (19%), answer ≥1.5× the longest distractor 687 (28%). Per pack, the strict share is highest in the writer/coach packs: storyteller 145/190, negotiator 146/194, creative-writer 145/198, copywriter 142/190, journalist 138/186, business 132/184, public-speaker 135/193, debater 134/195, reading-listening 115/200, grammarian 64/146, course 238/590.

| file | id | field | problem | suggested fix |
| --- | --- | --- | --- | --- |
| `track-business.json` | `bz-i-pushback-01` | `options` | Answer 95 chars, longest distractor 21: `"I want the launch to succeed. I can’t finish by Friday, but I can send a first version Tuesday."` | Give the three distractors one clause each, or cut the answer to a single request. |
| `track-copywriter.json` | `cp-i-story-02` | `options` | Answer 92 chars, next 19: `"Mira worked late and her eyes hurt. She switched lamps. Now she finishes without a headache."` | Same: make all four a two-clause story beat. |
| `track-public-speaker.json` | `ps-a-hostile-01` | `options` | Answer 88 chars, next 24: `"I hear that frustration. Let me tell you how this plan came from residents’ suggestions."` | Shorten the answer or lengthen distractors. |
| `track-journalist.json` | `jn-i-lede-04` | `options` | Answer 83 chars, next 22: `"A fire damaged the Corner Bakery early Monday, but no one was hurt, the owner said."` | Keep all four as one-line ledes. |
| `track-business.json` | `bz-a-crisis-02` | `options` | Answer 74 chars, next 15: `"What happened, what you know, what you do not know, and what you are doing"` | Distractors are 2–3 words; give each the same four-part shape. |
| `track-debater.json` | `db-a-close-02` | `options` | Answer 78 chars, next 20: `"Even if they win the cost point, our point concerns lives, which matters more."` | Same. |
| `track-negotiator.json` | `ng-a-pressure-04` | `options` | Answer 73 chars, next 15: `"I notice the deadline is very tight. What happens if we need another day?"` | Same. |
| `track-debater.json` | `db-a-charity-01` | `options` | Answer 90 chars, next 33: `"Sports build teamwork, and a smaller sports budget could weaken a rare chance to learn it."` | Same. |

The cause is unchanged from Job 8: the prompt is often a passage and the answer is a near-verbatim line from it, so the answer inherits the passage's length while distractors are short authored lines. A length-ratio check in `validate.py` (same style as the new give-away checks) would stop the next batch.

## Pattern 2 — the answer is printed in the prompt

Sharp measure (answer ≥2 words, printed in the prompt, no distractor printed): **5 items, all `recall` by design** — `recall-morning`, `recall-night`, `b1-relationships-recall-known`, `b1-achievements-recall-proud`, `c1-strategy-recall-who`. Everything else is now enforced by `validate.py`. The broad measure (answer printed and at least one distractor also printed) is 61 items; those still require reading to discriminate and are not a give-away.

## Pattern 3 — True/False key balance

Per track (True / False): storyteller 15/23, copywriter 15/22, journalist 17/22, business 13/20, public-speaker 17/19, debater 18/19, creative-writer 19/20, negotiator 21/18, grammarian 11/12, reading-listening 19/13, course A1–C2 26/30.

Per stage, the new stages carry the skew:

| Stage | True | False |
| --- | --- | --- |
| Journalist Advanced | 1 | 8 |
| Business Advanced | 2 | 6 |
| Debater Advanced | 5 | 8 |
| Journalist Intermediate | 8 | 8 |
| Business Intermediate | 3 | 6 |
| Copywriter Intermediate | 5 | 8 |
| Grammarian Intermediate | 3 | 5 |
| Reading & Listening Intermediate | 8 | 4 |
| Course A1 | 3 | 9 |

A learner who always answers False gets 8/9 on Journalist Advanced and 6/8 on Business Advanced. Worth balancing before the wave closes; the course A1 3/9 item is unchanged from Job 8.

## Pattern 4 — options that differ only by case or punctuation

None. The five items Job 8 listed (`gram-sent-subject-11`, `jn-quote-attribute-01/03`, `a1-alphabet-production-v3-1`, `a1-places-production-v3-5`) are clean now, and the validator check prevents new ones.

## Pattern 5 — `fillBlank` with one accepted function word

275 `fillBlank` items; 231 accept exactly one answer (84%), 38 of those are function words. Grammarian accounts for 15 and they are the lesson's point (`gram-be-amisare-07/08`, `gram-be-have-07/08`, `gram-be-do-07`, `gram-f-present-10`, `gram-f-future-10`, `gram-f-modal-10`, `gram-f-prep-10`, `gram-i-cond-10`, `gram-i-passive-10`, `gram-i-relative-10`, `gram-i-reported-10`, `gram-sent-join-06`). Outside Grammarian:

| file | id | accepted | prompt |
| --- | --- | --- | --- |
| `track-business.json` | `bz-i-call-09` | `when` | “Spell the name ___ you need to.” |
| `track-business.json` | `bz-a-clause-09` | `when` | “Specify who does what and by ___.” |
| `track-creative-writer.json` | `cw-setting-11` | `when` | “Setting means where and ___ a scene happens.” |
| `track-creative-writer.json` | `cw-pov-10` | `they` | “In third person, the narrator uses “he,” “she” or ___” |
| `track-debater.json` | `db-structure-10` | `For` | “___ example, many cities have done this.” |
| `track-debater.json` | `db-i-cause-10` | `before` | “The effect cannot come ___ the cause.” |
| `track-journalist.json` | `jn-five-ws-11` | `Who` | “___ asks for a person.” |
| `track-journalist.json` | `jn-i-record-09` | `before` | “Agree the rule ___ the person speaks.” |
| `track-negotiator.json` | `ng-concede-08` | `will` | “If you agree, I ___ start tomorrow.” |
| `track-negotiator.json` | `ng-i-trade-09` | `then` | “If you pay today, ___ I can lower the price.” |
| `track-negotiator.json` | `ng-i-close-09` | `on` | “So I will send the file ___ Friday.” |
| `track-public-speaker.json` | `ps-signpost-10` | `To` | “___ sum up, the plan is simple.” |
| `track-reading-listening.json` | `rl-detail-find-10` | `Where` | “___ do students meet? At the front gate.” |
| `track-reading-listening.json` | `rl-f-notes-09` | `the` | “Leave out small words like a and ___.” |
| `track-storyteller.json` | `st-i-abt-10` | `but` | “Rita lost the watch, ___ no one had seen it.” |
| `CurriculumCatalog.json` | `a2-work-recall-while` | `while` | “Write the word that links two things happening together.” |
| `CurriculumCatalog.json` | `a2-problems-recall-so` | `so` | “Write the word that introduces a result.” |
| `CurriculumCatalog.json` | `b1-education-recall-because` | `because` | “Write the word that gives a reason.” |
| `CurriculumCatalog.json` | `b1-entertainment-recall-while` | `while` | “Write the word that links two things true at the same time.” |
| `CurriculumCatalog.json` | `b1-decisions-recall-because` | `because` | “Write the reason after the choice.” |
| `CurriculumCatalog.json` | `b2-social-recall-while` | `while` | “Write the word that links two effects that happen together.” |
| `CurriculumCatalog.json` | `b2-present-recall-then` | `then` | “Write the word that orders the next move.” |
| `CurriculumCatalog.json` | `c1-policy-recall-or` | `or` | “Write the word that warns of the consequence.” |

The bigger risk is the 231/275 single-accepted figure: a legitimate variant outside `accepted` still fails a correct learner. That is unchanged from Job 8 and is not addressed by any validator check.

## New finding — dictation button on listen-and-write exercises

`ExerciseActivityView.typedBody` always applies `.dictation($typed)` (`:283`), and `listenType` falls into `typedBody` (`:166`). The mic button therefore appears under “Type what you hear”, so a learner can repeat the clip into the mic instead of listening and typing. The TDD says the button is “hidden for listen-and-write exercises” — it is not. Either hide it for `listenType` (product) or correct the TDD (doc); this report only records the mismatch.

## Where this stopped

All five requested patterns were measured across the full 2483-item set. The snapshot moved twice during the run (232 → 240 track lessons), so the counts are dated. The verbatim/dictation/twin checks are now enforced by `validate.py`; the longest-option and single-accepted-answer patterns are not, and both got larger with the new stages.
