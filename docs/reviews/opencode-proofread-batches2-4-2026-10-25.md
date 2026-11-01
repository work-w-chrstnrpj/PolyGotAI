# OpenCode proofread — coach tracks, batches 2–4 (2026-10-25, read-only)

Validator last line:

```text
OK
```

(`lexicon words: 120` / `course lessons: 57, track lessons: 80, typed exercises: 1276`)

Scope: Job 1, batches 2–4 of `docs/development-plan/opencode-handoff.md` — the nine coach-track packs listed below. Read-only: no product file was edited; this report is the only output.

Method: every learner-facing string was read (lesson `tip`, activity `prompt`, `answer`, `exercise.options`, `accepted`, `pairs`, `items`, `audioText`, `explanation`), then checked mechanically for answer/option mismatches, duplicate options, accepted-answer gaps, British spellings, doubled spaces, and apostrophe/quote styles. Fixes below are suggestions for Claude or Codex; nothing was applied.

## Systemic findings (all nine files, plus `track-grammarian.json`)

| file | id | field | problem | suggested fix |
|---|---|---|---|---|
| all 9 files | all `choice` activities | `exercise.options` | In **every** multiple-choice item the correct answer is `options[0]` — a learner who always taps the first option scores 100%: reading-listening 72/72, journalist 64/64, debater 65/65, negotiator 66/66, public-speaker 71/71, business 68/68, creative-writer 78/78, storyteller 72/72, copywriter 73/73 (grammarian 38/38 already reported). | Rotate the correct option per item at authoring time, or shuffle `options` in the exercise engine at load; do not rely on authored order. |
| all 9 files | all `match` activities | `answer`, `pairs` | Match answers are duplicated as free text in `answer` and structured in `pairs`, and the separator differs from `track-grammarian.json` (`→` + " \| " here, `=` + `;` there). | Pick one separator set for every track pack and generate `answer` from `pairs` so the two can never drift. |
| all 9 files | pack metadata | `editorialApprovalReference` | All nine packs carry the same sentence "Authored 2026-10-25 for the owner's personal use. Qualified editorial review is pending." — correct today, but it must be updated when this review closes. | Update the string to name the review date once Claude signs off. |

Apostrophes and quotation marks are internally consistent in each of the nine files (curly `’ “ ”` only, zero straight quotes). That is the opposite of `track-grammarian.json`, which uses straight quotes throughout. See the punctuation row under journalist.

## `application/SpeechCoachAI/Resources/Tracks/track-reading-listening.json`

111 activities, 8 lessons. Content is clear and at the right level. Findings:

| file | id | field | problem | suggested fix |
|---|---|---|---|---|
| track-reading-listening.json | rl-context-meaning-05 | `prompt` | British spelling in an en-US pack: "It was a gloomy morning. The sky was dark and grey, and everyone felt sad." | "The sky was dark and gray" |
| track-reading-listening.json | rl-scan-facts-08 | `prompt`, `options` | British date order: "Spring Market. Saturday 14 April." and distractor "Saturday 4 April". | "Saturday, April 14" and "Saturday, April 4" |
| track-reading-listening.json | rl-detail-find-08 | `answer`, `options`, `audioText` | British clock forms: answer "Ten past nine", distractor "Ten to nine", audio "at ten past nine". American English says "nine ten". | Answer "Nine ten", distractor "Eight fifty", audio "at nine ten" (also update rl-detail-find-07 if it shares the clip) |
| track-reading-listening.json | rl-signal-words-01 | `options` | "Fill the gap: I was tired, ___ I went to bed early." — "but" is also grammatical ("I was tired, but I went to bed early"); only meaning separates it from the keyed "so". | Add the meaning to the prompt ("…show a result") or swap "but" for a linker that cannot fit |
| track-reading-listening.json | rl-main-idea-02 | `prompt`, `answer` | The answer is literally the passage's first sentence, and the lesson tip tells learners to "look at the first sentence". The item can be answered without reading the passage. | Use a passage whose main idea is not the first sentence, or ask for a paraphrase of the main idea |
| track-reading-listening.json | rl-main-idea-01, rl-main-idea-02 | `prompt`, `answer` | The same passage and the same answer ("Walking is a good way to stay healthy") appear in two consecutive activities. | Change one item (for example give rl-main-idea-02 a different passage or a detail-vs-main-idea task) |
| track-reading-listening.json | rl-gist-read-06 | `options`, `audioText` | The answer is a keyword match on the first four words of the clip ("Welcome to the city museum" → "Information about a museum"), so no listening past the first sentence is needed. | Ask for a detail that needs the whole clip (for example the free-ticket rule) |
| track-reading-listening.json | rl-main-idea-06 | `options`, `audioText` | Same pattern: audio opens "Good sleep is important for students." and the answer is "Good sleep helps students". | Ask for an idea that only the later sentences support |
| track-reading-listening.json | rl-context-meaning-07 | `options` | Option "Was" is capitalized while the source word in "The soup was scorching" is lower-case `was`; the other options are not capitalized the same way. | "was" |
| track-reading-listening.json | rl-gist-read-04 | `answer`, `options` | British usage in an en-US pack: "Ben tells Mia about his holiday" (meaning a trip). In American English a trip is a vacation; "holiday" means a public holiday. | "Ben tells Mia about his vacation" |

Clean in this file: all 8 lessons' tips, all matching pairs, and every reading passage except the two gist items above. No duplicate options, no answer that is missing from its options, no broken `accepted` list.

## `application/SpeechCoachAI/Resources/Tracks/track-journalist.json`

106 activities, 8 lessons. The teaching is accurate; the quotation lesson is the strongest in the batch. Findings:

| file | id | field | problem | suggested fix |
|---|---|---|---|---|
| track-journalist.json | jn-five-ws-05 | `answer`, `options` | The keyed option opens with an unattached pronoun: "They think an electrical problem caused it" — the question is "Why did the fire start, according to officials?" | "Officials think an electrical problem caused it" |
| track-journalist.json | jn-five-ws-01 | `pairs` | The tip teaches six questions (who, what, where, when, why, how) but the match drops What and How entirely. | Add "What → a thing or an event" and "How → the way it happened" |
| track-journalist.json | jn-open-closed-08 | `answer`, `pairs` | "Is the store open? → a short yes or no" is not grammatical as a noun phrase. | "a short yes-or-no answer" |
| track-journalist.json | jn-quote-attribute | `tip` | The quoted fragment "who said them: “said Maria Lopez.”" carries a full stop inside the quotation marks although it is a fragment, and the sentence's own rule one line later is about exact quoting. The file otherwise puts commas and stops inside the quote correctly. | Change to: `Attribution says who said them: “said Maria Lopez”.` or quote only "said Maria Lopez" |
| track-journalist.json | jn-pyramid-06 | `options` | Two answers are defensible for "Which sentence is best for the first line?": the keyed "A school bus caught fire near Pine Park on Tuesday morning." and "All 24 children got off safely." (no injuries is the most newsworthy fact in a fire story). | Replace the safety option with a clearly minor fact, for example "The bus route is number 14." |
| track-journalist.json | jn-headlines-13 | `items` | The required order puts "Write a short headline" before "Write a lede with the key facts"; editors normally draft the lede first and cut the headline from it, and nothing in the lesson fixes the order. | Swap the last two items, or state the order in the prompt |
| track-journalist.json | jn-summarize-03 | `options` | Only one option appears in the passage; the other three ("The meeting began at six.", "The room was warm.", "A man wore a hat.") are invented, so the item can be answered by text-matching rather than by judging what is a key fact. | Use details that are all present in the passage, then ask which one is key |
| track-journalist.json | jn-summarize-04 | `prompt` | Mixed ellipsis style inside one file: "A summary should be..." uses three periods, while the tips in the same file use the single character `…`. | "A summary should be…" |

Clean in this file: the fact/opinion lesson, the follow-up-question lesson, and all 14 quotation activities except the tip row above. `jn-headlines-09` correctly accepts both "lede" and "lead".

## `application/SpeechCoachAI/Resources/Tracks/track-debater.json`

107 activities, 8 lessons. Findings:

| file | id | field | problem | suggested fix |
|---|---|---|---|---|
| track-debater.json | db-phrases-06 | `prompt`, `answer` | The keyed answer produces a redundant sentence: "Fill the gap: ___, I think cities need more parks." → "In my opinion, I think cities need more parks." | Drop "I think" from the prompt: "___, cities need more parks." |
| track-debater.json | db-evidence-06 | `options` | "Which sentence is evidence from a survey?" — the keyed option is the only one containing the word "survey", so no reading is required. | Ask "Which sentence is evidence?" and keep the survey among distractors-free facts |
| track-debater.json | db-evidence-03 | `options` | "Which evidence is vague?" has two unhelpful options: "Many experts say so." (keyed) and "The report was published in 2024.", which states no finding at all and is equally weak. | Replace the date option with a specific finding, for example "The report found 1,200 users in May." |
| track-debater.json | db-fallacy-people-06 | `prompt`, `pairs` | The prompt says "Match each term with its meaning" but includes "Rebuttal", and db-fallacy-logic-06 says "Match each fallacy with its clue" while including "Fair argument" — a non-fallacy in a fallacy set. | Reword both prompts to "Match each item with its clue" |

Clean in this file: the claim-and-reason, structure, rebuttal and weighing lessons; every ordering item is unambiguous; the fallacies are correctly labelled.

## `application/SpeechCoachAI/Resources/Tracks/track-negotiator.json`

107 activities, 8 lessons. Findings:

| file | id | field | problem | suggested fix |
|---|---|---|---|---|
| track-negotiator.json | ng-pitch-13 | `prompt` | Uses "call to action", a term the lesson never teaches; the pitch steps are taught as "Next step" (ng-pitch-05, ng-pitch-06). | "Which sentence is the next step?" |
| track-negotiator.json | ng-offer-10 | `answer`, `accepted` | "___ you consider a smaller order?" keys only "Would", but "Will you consider a smaller order?" is equally grammatical and is marked wrong. | Add "Will" to `accepted`, or put the phrase in the prompt |
| track-negotiator.json | ng-refuse-02 | `options` | All four options carry stray trailing commas ("Unfortunately,", "Obviously,", "Never,", "Stop,"), turning single words into sentence fragments; "Never," and "Stop," are also not softening words. | Use bare words: "Unfortunately", "Obviously", "Never", "Stop" |
| track-negotiator.json | ng-appeals-09 | `prompt`, `answer` | "Logos means facts and ___." keyed to "logic" defines logos with itself ("logos (logic: facts and reasons)" in the tip); the word that actually completes the sentence is the accepted variant "reasons". | Key "reasons", or reword to "Logos uses facts and ___." |

Clean in this file: interests vs positions (ng-interests-12 is the best listening item in the batch), concessions, refusals, and ethics. No duplicate or missing options.

## `application/SpeechCoachAI/Resources/Tracks/track-public-speaker.json`

115 activities, 8 lessons. Findings:

| file | id | field | problem | suggested fix |
|---|---|---|---|---|
| track-public-speaker.json | ps-pause-12 | `accepted` | The stem is "Pause before an ___ word." and the list accepts "key", which yields "Pause before an key word." | Drop "key" from `accepted`, or change the stem to "a ___ word" |
| track-public-speaker.json | ps-pause-02 | `options` | "Which word should you stress in “We need action today, not tomorrow”?" includes the option "the", which does not occur in the quoted line. | Replace "the" with a word from the line, for example "need" |
| track-public-speaker.json | ps-signpost-03 | `options` | Option forms are inconsistent: "To sum up," (keyed) and "First,", "Next," carry commas while "Let me begin." is a full sentence, so punctuation gives the answer away. | Make all four bare phrases without commas |

Clean in this file: the rhythm, contrast, voice and body-language lessons, and every ordering item. ps-rhythm-13 deliberately avoids a tricolon option, which keeps anaphora unambiguous — good authoring.

## `application/SpeechCoachAI/Resources/Tracks/track-business.json`

116 activities, 8 lessons. The clearest file in the batch. Findings:

| file | id | field | problem | suggested fix |
|---|---|---|---|---|
| track-business.json | bz-intro-09 | `answer`, `items` | "I work in the sales team." is not idiomatic; English uses "on the sales team" or "in sales". | "I work on the sales team." |
| track-business.json | bz-sbi-07 | `pairs` | The match tiles carry punctuation from the sentence they were cut from: "In Tuesday’s meeting," / "you interrupted Ana twice," / "and she stopped sharing ideas." As tiles they read as broken sentences. | Drop the trailing commas and the leading "and": "In Tuesday’s meeting", "you interrupted Ana twice", "she stopped sharing ideas" |

Clean in this file: the meeting, email, BLUF, PREP, STAR, plain-language and SBI lessons teach accurate, conventional workplace English. All 15 other choice sets have exactly one defensible answer, and every ordering item has one sensible order.

## `application/SpeechCoachAI/Resources/Tracks/track-creative-writer.json`

117 activities, 8 lessons. **No findings.** The clearest writing in the batch:

- Every reading passage is original and self-contained; no question can be answered from the first sentence alone (cw-character-06/07, cw-setting-06/07, cw-dialogue-07, cw-pov-12/13, cw-plot-13, cw-start-end-12 all turn on a different detail).
- Show-don't-tell, dialogue and point-of-view items each have exactly one keyed answer, with distractors that are genuinely wrong rather than merely weaker.
- Quote and apostrophe style is consistent (curly only) and matches the other eight files.
- The open-ended "Your turn" prompts are answerable in one or two sentences and match their lesson objective.

Optional style note only (not a defect): in cw-dialogue-06 the four options differ only in their final clause, so the word "quickly" carries the whole item. It works, but it is the thinnest discrimination in the file.

## `application/SpeechCoachAI/Resources/Tracks/track-storyteller.json`

112 activities, 8 lessons. Findings:

| file | id | field | problem | suggested fix |
|---|---|---|---|---|
| track-storyteller.json | st-people-11 | `answer`, `items` | The target sentence is broken: "My mother looked at me and said." ends with "said" and nothing is said. It becomes the model answer learners copy. | "My mother looked at me and smiled." or add a quoted line: "My mother looked at me and said, “Be careful.”" |
| track-storyteller.json | st-people-13 | `audioText` | Direct speech is unpunctuated: "My grandfather looked at the sky and said, quietly, rain by noon." The lesson itself teaches quoting with quotation marks (st-people tip: "said, ‘You are late again.’"), so the clip contradicts the rule. | "My grandfather looked at the sky and said quietly, “Rain by noon.”" |
| track-storyteller.json | st-trim-10 | `prompt`, `answer` | "Time your story ___." keyed to "aloud" produces "Time your story aloud", which is not idiomatic — you time *yourself* telling it aloud. | "Tell your story ___ and time it." (answer "aloud"), or "Time yourself telling the story ___." |
| track-storyteller.json | st-detail-04 | `options` | The keyed option justifies itself: "The color of the tablecloth, if it does not matter to the story". The conditional clause gives the answer away before the learner judges anything. | "The color of the tablecloth" (plain), with the reason in the explanation |
| track-storyteller.json | st-moment-13 | `options` | Distractor "A holiday" uses British usage for a trip; the en-US pack should say "vacation". | "A vacation" |

Clean in this file: the arc, detail, hook, voice and listener lessons; every ordering item; and st-voice-12/st-listeners-12, which need the clip or passage to answer.

## `application/SpeechCoachAI/Resources/Tracks/track-copywriter.json`

113 activities, 8 lessons. Findings:

| file | id | field | problem | suggested fix |
|---|---|---|---|---|
| track-copywriter.json | cp-benefit-03 | `options` | British vocabulary in an en-US pack: "The bag has two zips." American English says "zippers". | "The bag has two zippers." |
| track-copywriter.json | cp-headline-04 | `options` | British vocabulary again: "Fix a leaking tap in ten minutes." American English says "faucet". | "Fix a leaking faucet in ten minutes" |
| track-copywriter.json | cp-headline-09 | `prompt` | The true/false stem contradicts itself: "True or false: “Best product ever” is a strong headline with no proof." A learner can answer either way and be right about part of it. | "True or false: “Best product ever” is a strong headline." (answer False) |
| track-copywriter.json | cp-aida-13 | `options` | Two options are defensible for "Which sentence creates desire?": the keyed "Imagine leaving home right on time" and "Never miss a bus again", which is a benefit promise — and the lesson defines Desire as "show the benefit". | Replace "Never miss a bus again" with a plain fact, for example "It shows live bus times" |
| track-copywriter.json | cp-cta-02 | `options` | "Which word makes a strong CTA verb?" offers one verb ("Join") and three adverbs ("Perhaps", "Possibly", "Eventually"), so the grammar gives the answer away. | Use two weak verbs as distractors, for example "Consider", "Think" |

Clean in this file: the feature/benefit lesson, the honest-claims lesson (cp-honest-13 is the strongest item) and the edit lesson; `accepted` lists correctly offer real variants such as "proof \| evidence" and "concrete \| specific".

## Summary

| file | activities | lessons | findings | worst severity |
|---|---|---|---|---|
| track-reading-listening.json | 111 | 8 | 10 | medium (British date/time forms, gist answerable from the first sentence) |
| track-journalist.json | 106 | 8 | 8 | medium (jn-summarize-03 answerable by text-matching) |
| track-debater.json | 107 | 8 | 4 | medium (db-phrases-06 redundant sentence) |
| track-negotiator.json | 107 | 8 | 4 | medium (ng-offer-10 rejects a correct answer) |
| track-public-speaker.json | 115 | 8 | 3 | medium (ps-pause-12 "an key word") |
| track-business.json | 116 | 8 | 2 | low |
| track-creative-writer.json | 117 | 8 | 0 | clean |
| track-storyteller.json | 112 | 8 | 5 | high (st-people-11 model sentence is ungrammatical) |
| track-copywriter.json | 113 | 8 | 5 | medium (cp-headline-09 self-contradicting stem) |

Highest-value fixes, in order:

1. **Shuffle choice options** — the answer is `options[0]` in 629 of 629 choice items across the nine files. Nothing else matters as much, because a learner can finish every lesson without reading.
2. **track-storyteller.json `st-people-11`** — learners copy a model sentence that has no object.
3. **British forms in en-US packs** — `grey`, "14 April", "ten past nine", "holiday", "zips", "tap".
4. **Accepted-answer and stem-grammar breaks** — `ps-pause-12` ("an key"), `ng-offer-10` ("Will"), `ps-pause-02` (option "the" not in the line).
5. **Self-answering stems** — `db-evidence-06` (keyword "survey"), `jn-summarize-03`, `st-detail-04`, `db-evidence-03`.

## Status

All nine files finished — batches 2, 3 and 4 complete, nothing skipped. No product file was edited; this report is the only change. Everything above is a proposal for Claude or Codex to accept, reject or rewrite.

