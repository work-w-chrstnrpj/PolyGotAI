# OpenCode proofread — Job 7, the Speech Lab content (2026-10-25, read-only)

Validator last line:

```text
lexicon words: 866
course lessons: 57, track lessons: 80, typed exercises: 1848
OK
```

Scope: every `application/SpeechCoachAI/Resources/SpeechLab/speechlab-*.json` file — 7 files, 189 items:

| file | version | items | what it holds |
|---|---|---|---|
| `speechlab-dictation.json` | 1 | 44 | 36 sentences (A1–C2, six each) + 8 Numbers/Dates/Names/Spelling items |
| `speechlab-articulation.json` | 1 | 46 | 22 minimal pairs, 6 word endings, 6 clusters, 12 tongue twisters |
| `speechlab-phonetics.json` | 1 | 43 | 10 vowels, 5 diphthongs, 4 r-colored vowels, 24 consonants |
| `speechlab-prosody.json` | 1 | 6 | 4 stress items, 2 intonation items |
| `speechlab-voice.json` | 1 | 8 | read-aloud passages, one per CEFR level (A1 and A2 have two) |
| `speechlab-interview.json` | 1 | 39 | 3 interview sets (general 13, job 14, study 12) |
| `speechlab-warmups.json` | 1 | 3 | breathing, humming, lip trills |

Read-only: no product file was edited. Method: every learner-facing string was read, then checked mechanically for IPA/example mismatches, false minimal pairs, option and answer placement, straight vs curly apostrophes, British spellings and clock/date forms, double spaces, items whose two options are homophones, and items whose spoken text differs from the text the checker compares against.

## Systemic findings

| file | id | field | problem | suggested fix |
|---|---|---|---|---|
| `speechlab-phonetics.json` | all 43 sounds | `choices` | **The correct word is always `choices[0]`, and every item's last option is the literal word `boat`** (35 items have three options, the 8 items without a `partner` have two). `SpeechLabSound.activity` keys `accepted: [cue]`, so a learner who always taps the first tile scores 43/43, and "boat" is never the target of any contrast. | Rotate the cue through the three positions, and give each item three words that all belong to the contrast set instead of a fixed filler. |
| `speechlab-articulation.json` | all 22 minimal pairs | `title`, `answer` | **The pair title gives the answer away.** Every title lists the keyed word first: `"ship / sheep"` → answer `ship`, `"live / leave"` → `live`, … `"luck / lock"` → `luck` (22 of 22). The same order is then used in `options`, so the answer is also `options[0]` in 42 of 46 items. | List the pair in the opposite order from the option list, or title the item by the contrast ("Short i / long i") rather than by the two words. |
| `speechlab-dictation.json` | `dict-spell`, `dict-spell-place` | `text` vs `spoken` | **The app plays a sentence but grades only the letters.** `SpeechLabModelAudio(text: item.spoken)` speaks "The name is Mina. M. I. N. A.", while `SpeechLabDictationChecker` compares against `text` "M I N A". A learner who follows "Listen and write." and writes the sentence gets 4 correct words out of 8. Same in `dict-spell-place`: spoken "The street is Elm. E. L. M." vs `text` "E L M". | Set `spoken` to "M. I. N. A." (and "E. L. M."), or add the lead-in sentence to `text`. |
| `speechlab-dictation.json` | `dict-numbers`, `dict-date`, `dict-time` | `text` | **Hyphenated forms fail in strict mode.** `SpeechLabDictationChecker.tokens(strict: true)` splits on whitespace only, so a learner who writes the standard "Forty-two" or "October twenty-fifth" is scored against two tokens and loses a word. The model text itself omits the hyphens: "Forty two", "October twenty fifth". | "Forty-two", "October twenty-fifth". (Non-strict mode already treats both forms the same.) |
| `speechlab-dictation.json` | 3 items | `text` | **Homophones that no ear can separate.** `dict-a1-5` "Please put the cup here." (here/hear), `dict-b1-2` "…take the bus than drive downtown." (than/then), `dict-c1-1` "…while defending its decision…" (its/it's). These test spelling knowledge, not listening, and a learner who hears correctly is still marked wrong. | Keep them only if the point is grammar; otherwise swap the word (for example "Put the cup on the table."). |
| `speechlab-voice.json` | all 8 passages | `text` | **Passage length does not track the stated level.** Word counts: A1 68 and 66, A2 71 and 66, B1 70, B2 71, C1 75, C2 79 — a 16% spread across six levels, and the A1 passages are longer than the B1 one. A C2 read-aloud of 79 words is short. | Scale by level (for example A1 45–55, A2 70, B1 90, B2 110, C1 130, C2 150 words), or relabel the set as "short passages" and drop the level tags. |

## Per-item findings

| file | id | field | problem | suggested fix |
|---|---|---|---|---|
| `speechlab-articulation.json` | art-pair-2 | `tip` | "Relax the first vowel and lengthen the second." There is only one vowel in *live / leave*; the tip names a second one. All 21 other pair tips describe one contrast correctly (art-pair-1: "Keep the short vowel relaxed; hold the long one."). | "Relax the vowel in live and lengthen it in leave." |
| `speechlab-articulation.json` | art-pair-2 | `text`, `options` | `live` as a lone word is a homograph: a device voice may read the adjective /laɪv/ ("live music") instead of the verb /lɪv/ the item teaches, which turns the contrast into nonsense. | Use a word with no second reading ("sit / seat" is already art-pair-10), or speak it with an IPA hint the way prosody does. |
| `speechlab-articulation.json` | art-link-3 | `options` | "an apple" vs "a nap" are homophones when linked — that is the point of the pair — but the task is a two-option listening choice, so both answers are defensible from the audio. A learner who hears correctly can still lose. | Keep the pair as a speaking drill, or replace the distractor with one that differs in sound ("a pear"). |
| `speechlab-phonetics.json` | sound-schwa | `choices` | `['about', 'above', 'boat']` — the distractor "above" also begins with a schwa, so the item does not test /ə/; it tests the second syllable. | `['about', 'under', 'boat']` or another word without /ə/. |
| `speechlab-phonetics.json` | sound-er-weak | `choices` | `['teacher', 'later', 'boat']` — "later" ends in the same /ɚ/ as "teacher" (`/ˈleɪtɚ/`), so the target vowel is in both options. | Use a distractor without /ɚ/, for example `['teacher', 'today', 'boat']`. |
| `speechlab-dictation.json` | dict-name, dict-place | `text` | A proper name cannot be recovered from sound: "Mina" can be heard as *Meena*, "Cedar Lane" as *Cedar Lain*. The checker accepts only one spelling. | Accept the common spellings in the comparison, or show the name and test only its capitalization. |
| `speechlab-dictation.json` | dict-numbers, dict-price, dict-date, dict-time, dict-name, dict-place, dict-spell, dict-spell-place | `text`, `spoken` | The eight special items carry no final stop while the 36 sentences do. In strict mode ("Check capitals and punctuation") a learner who punctuates the item as a sentence loses a word for the extra period. | Add the stop to the six that are sentences ("Mina Carter.", "Cedar Lane.") and decide one rule for the two spelled items. |
| `speechlab-dictation.json` | dict-time | `text` | "Quarter past seven" is British clock usage ("quarter past" is rare in American English) in a pack whose other items are American ("downtown", "vacation"-style vocabulary). It also sits under `category` "Dates". | "Quarter after seven", or "Seven fifteen". |
| `speechlab-prosody.json` | intonation-question, intonation-statement | `text` | "You're ready?" and "You're ready." use straight apostrophes — the only two straight apostrophes in all seven files, and the rest of the app (course tips, track tips) uses `’`. `AnswerChecker` normalizes both, so this is style only. | `You’re`. |
| `speechlab-voice.json` | voice-passage-8 | `text` | The C2 passage is 79 words — shorter than voice-passage-1 at A1 (68 words is close) and barely longer than the B2 passage. Level labelling is not supported by the text. | Lengthen the C1/C2 passages, or retag them. |
| `speechlab-interview.json` | whole file | `level` | Level coverage is uneven: A1 1 item, A2 10, B1 17, B2 8, C1 3, **C2 0**. `HandsFreeInterview.plan(set:level:bank:)` keeps only items at or below the learner's level, so at A1 the "general" set yields one question (the opening; no core, no closing) and the "job" and "study" sets yield an empty session. At C2 no question above C1 is ever asked. | Add A1 openings/core/closings and at least one C2 core question per set, or make `plan` fall back to the easiest available items instead of returning an empty list. |
| `speechlab-interview.json` | interview-general-close-1, interview-job-close-1/2, interview-study-close-1/2 | `followUpLong` | The "long answer" follow-up is a closing compliment ("Thank you. That was clear and well organized.", "Thank you for your time today."), so a learner who speaks at length is not asked anything in return. Defensible at a close, but it is the only place where the follow-up does not follow up. | Replace with a last question, or name the field `closingRemark` so the intent is visible. |

## Clean

- **IPA and example words: no errors found.** All 43 `ipa`, `cueIPA` and example sets in `speechlab-phonetics.json` match General American usage (`/ʃip/`, `/bɛd/`, `/kɑm/`, `/ˈtitʃɚ/`, `/ˈmɛʒɚ/`, `tʃ`/`dʒ` pairs, `θ`/`ð`, `ɹ`), and every example word contains its sound. `speechlab-prosody.json` is accurate too (`ˈfoʊtəɡræf`, `fəˈtɑɡrəfi`, `bəˈnænə`; the stress marks match the keyed syllable in all four stress items).
- All 22 minimal pairs are true minimal pairs (one phoneme), and all 12 word-ending items key the correct allomorph (`cats` /s/, `dogs` /z/, `buses` /ɪz/, `walked` /t/, `played` /d/, `wanted` /ɪd/).
- All 12 tongue twisters are grammatical, contain the sound they advertise (b/br, f, r, t, s, θ, kw, n, g/gr, st), and their two options differ by exactly one word.
- American spelling throughout: no `colour`, `favourite`, `organise`, `centre`, `grey`, `practise`, `whilst`, `learnt`. (`gray` appears in the twisters and is correct for en-US.)
- No double spaces, no space before punctuation, no missing space after a full stop in any of the seven files.
- `speechlab-warmups.json` is clean: accurate, safe instructions with sensible timings.
- The 36 graded dictation sentences are unambiguous when spoken, and their length scales sensibly by level (A1 5–6 words, A2 7–9, B1 9, B2 9–12, C1 11–13, C2 11–14).
- The interview questions and follow-ups are idiomatic and free of typos; every `followUpShort` is answerable from the question it follows (except the closing compliments noted above).

## Highest-value fixes, in order

1. **Phonetics and articulation give-aways.** The cue is `choices[0]` in all 43 sounds, and the pair title names the answer first in all 22 minimal pairs. A learner can finish both areas without listening.
2. **`dict-spell` / `dict-spell-place`.** The recorded text and the graded text are different sentences.
3. **Interview level coverage.** At A1 the flow can produce a one-question session or none.
4. **`art-pair-2`** (wrong tip, homograph audio) and **`art-link-3`** (two homophone options).
5. **Voice passage lengths** and the two missing hyphens in the dictation number/date.

Nothing above was applied; all of it is a proposal for Claude to accept, reject or rewrite.
