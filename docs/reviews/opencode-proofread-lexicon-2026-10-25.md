# OpenCode proofread — Lexicon bank (2026-10-25, read-only)

> **Scope note, added after the pass:** the main sections below cover the **18 files / 722 words** that existed when this review ran. While it was running, another agent added five specialist groups, so the bank is now **23 files / 866 words**. The five new files (144 words) are covered in the [addendum](#addendum--five-new-field-groups-144-words) at the end. Both are dated 2026-10-25.

Validator last line:

```text
OK
```

Full validator output tail **at the time of the main pass**:

```text
lexicon words: 722
course lessons: 57, track lessons: 80, typed exercises: 1848
OK
```

Current output after the addendum (`python3 tools/curriculum/validate.py`):

```text
lexicon words: 866
course lessons: 57, track lessons: 80, typed exercises: 1848
OK
```

(The earlier report in this folder recorded `lexicon words: 120`; the bank then grew to 18 groups / 722 words, and now to 23 groups / 866 words.)

Scope: Job 1 of `docs/development-plan/opencode-handoff.md`, Lexicon half — all 18 files in `application/SpeechCoachAI/Resources/Lexicon/`. Every learner-facing string was read: `lemma`, `pos`, `cefr`, `register`, `meaning`, every `examples` sentence and every `wrong` sentence. Read-only: no product file was edited; this report is the only output.

Method: all 722 words were read in 18 file batches, then checked mechanically for American-vs-British spelling, `cefr` vs group level, `register` values, duplicate lemmas, `{marked}` form in examples, meaning length/period style, doubled spaces, and quote style. `wrong` sentences were judged by one test: **would this sentence still be a correct use of the word?** Because `LexiconActionBuilder.chooseSentence` asks "Which sentence uses “word” correctly?", a logically absurd but grammatical sentence is a valid wrong option; only a sentence that is a *correct* use of the word would break the question. `docs/` and `application/SpeechCoachAI/Domain/Lexicon.swift`, `Domain/LexiconPractice.swift` and `Infrastructure/Lexicon/LexiconBankLoader.swift` were read to confirm how the fields are used.

## Summary

| file | words | findings | verdict |
|---|---|---|---|
| lexicon-01-a1-everyday.json | 40 | 1 minor (salt) | clean otherwise |
| lexicon-02-a1-people-places.json | 40 | 0 | clean |
| lexicon-03-a1-food-time.json | 40 | 0 | clean |
| lexicon-04-a2-travel-health.json | 40 | 2 (`travelling`, `cinema`) | see table |
| lexicon-05-a2-home-town.json | 40 | 1 (`flat`) | see table |
| lexicon-06-a2-work-basics.json | 40 | 2 (`colour`, `online` POS) | see table |
| lexicon-07-b1-work.json | 40 | 2 (`the a job`, `holidays`) | see table |
| lexicon-08-b1-society.json | 40 | 0 | clean |
| lexicon-09-b1-feelings.json | 41 | 0 | clean |
| lexicon-10-b2-work-terms.json | 40 | 0 | clean |
| lexicon-11-b2-academic.json | 40 | 0 | clean |
| lexicon-12-b2-opinion.json | 40 | 1 (`flat`) | see table |
| lexicon-13-c1-nuance.json | 40 | 1 (`redundant`) | see table |
| lexicon-14-c1-professional.json | 40 | 0 | clean |
| lexicon-15-c1-abstract.json | 41 | 0 | clean |
| lexicon-16-c2-precision.json | 40 | 0 | clean |
| lexicon-17-c2-idioms.json | 40 | 4 (`cancelled` ×2, `holiday plans`, `vibe`) | see table |
| lexicon-18-c2-literary.json | 40 | 0 | clean |
| **total** | **722** | **15 rows** | |

Every finding is a suggested edit for Claude or Codex. Nothing was applied.

## American English (the app is en-US; other checked text uses `theater`, `neighbor`, `color`, `analyze`, `license`)

| file | id | field | problem | suggested fix |
|---|---|---|---|---|
| lexicon-04-a2-travel-health.json | `journey` | `meaning` | British spelling: "The act of **travelling** from one place to another." | "The act of **traveling** from one place to another." |
| lexicon-05-a2-home-town.json | `rent` | `examples[0]` | British noun: "The {rent} for this **flat** is $800 a month." The same file teaches `apartment` as the A2 word. | "The {rent} for this **apartment** is $800 a month." |
| lexicon-12-b2-opinion.json | `disadvantage` | `examples[0]` | British noun: "The main {disadvantage} of the **flat** is the noise." | "The main {disadvantage} of the **apartment** is the noise." |
| lexicon-06-a2-work-basics.json | `document` | `wrong[0]` | British spelling: "A document is a machine that prints in **colour**." | "…prints in **color**." |
| lexicon-13-c1-nuance.json | `redundant` | `examples[0]` | British HR usage: "Many workers were made **redundant** when the factory closed." In American English people are *laid off*. | "Many workers were **laid off** when the factory closed." (or keep `redundant` in the example as a word, but then it must be taught as British) |
| lexicon-17-c2-idioms.json | `bummer` | `examples[0]` | British spelling: "It’s a {bummer} that the concert is **cancelled**." | "…is **canceled**." |
| lexicon-17-c2-idioms.json | `stoked` | `wrong[0]` | British spelling: "I am stoked about the **cancelled** trip and feel miserable." | "I am stoked about the **canceled** trip and feel miserable." |
| lexicon-17-c2-idioms.json | `up in the air` | `examples[0]` | British vocabulary: "Our **holiday** plans are still {up in the air}." In American English this is a vacation. | "Our **vacation** plans are still {up in the air}." |

Lower priority, same class, all inside `wrong` sentences (read but never the keyed answer):

| file | id | field | problem | suggested fix |
|---|---|---|---|---|
| lexicon-04-a2-travel-health.json | `medicine` | `wrong[0]` | British noun: "Medicine is a kind of cold drink you buy at a **cinema**." | "…you buy at a **movie theater**." |
| lexicon-06-a2-work-basics.json, lexicon-07-b1-work.json | `lesson`, `shift`, `qualification` | `wrong[0]` | British sense of *holiday* = time off school/work: "A lesson is a long **holiday** from school.", "My shift is a week of **holidays**.", "A qualification is a kind of **holiday** from work." | Use *vacation* in these three sentences. (`lexicon-08` "An election is a holiday when no one votes" is fine: a public holiday is also American usage.) |

## Wording, typo and word-class rows

| file | id | field | problem | suggested fix |
|---|---|---|---|---|
| lexicon-07-b1-work.json | `apply` | `wrong[1]` | Doubled article, which looks like an editing slip rather than the intended error: "He applied **to the a** job." | "He applied **to a** job." (the target error is *apply to* instead of *apply for*) |
| lexicon-06-a2-work-basics.json | `online` | `pos` | Labelled `adjective`, but the only example is adverbial: "I like to shop {online}." | Either set `pos` to `adverb`, or change the example to an adjectival use: "The {online} shop delivers quickly." |
| lexicon-17-c2-idioms.json | `vibe` | `wrong[0]` | Self-contradictory in a way that is hard to parse: "The vibe in the crowded, noisy room was silent and completely dead, so it felt busy." | "The vibe in the silent, empty room was busy and lively, so everyone felt excited." |
| lexicon-17-c2-idioms.json | `cringe` | `wrong[0]` | "because I think they are **perfect and proud**" — *proud* does not describe photographs, so the contrast is unclear. | "I cringe at my old photos because I think they are wonderful and I feel proud of myself." |
| lexicon-01-a1-everyday.json | `salt` | `meaning` | Mildly circular for an A1 definition: "A white substance that makes food taste **salty**." | "A white powder used to give food flavor." (minor; the current line is understandable) |

## Structural findings (no per-row fix without a content pass)

1. **`register` is set per group, not per word.** Files 01–09 are 100% `everyday`, 11 is 100% `term`, 12/13/14/16 are 100% `formal`, 18 is 100% `literary`. Many words in the formal/term groups are neutral, everyday words. Clearest examples:
   - `lexicon-12-b2-opinion.json` marked `formal`: `disagree`, `support`, `suggest`, `advantage`, `disadvantage`, `attitude`, `debate`.
   - `lexicon-13-c1-nuance.json` marked `formal`: `vague`, `thorough`, `trivial`, `deliberate`, `notorious`, `obsolete`, `mundane`, `versatile`.
   - `lexicon-11-b2-academic.json` marked `term`: `role`, `issue`, `individual`, `respond`, `occur`, `require`, `focus`, `involve`.
   - `lexicon-10-b2-work-terms.json` marked `term`: `challenge`, `priority`, `resource`, `approve`, `propose`, `objective`, `efficient`.
   Suggested fix: a per-word register pass in these four files; `lexicon-14-c1-professional.json` and `lexicon-16-c2-precision.json` are the only all-`formal` files where `formal` is accurate throughout.

2. **Word `cefr` must equal the group level** (`tools/curriculum/validate.py` errors otherwise), so the two groups defined by *register* rather than difficulty force C2 onto easier words. This is functional, not cosmetic: `DailyLexicon.pick(maxLevel:)` and `LexiconState.activeGroups(startLevel:)` hide words above the learner's level, so an A2/B1 learner never meets the easier idioms. Clearest cases:
   - `lexicon-17-c2-idioms.json` (C2): `broke`, `hang out`, `figure out`, `mess up`, `chill out`, `break the ice`, `under the weather`, `hit the sack`, `spill the beans`, `once in a blue moon`, `the last straw` read as B1–B2.
   - `lexicon-18-c2-literary.json` (C2): `wander`, `drift`, `fade`, `dusk`, `hush`, `stillness`, `veil`, `murmur`, `glimmer`, `ember` read as B1–C1.
   Suggested fix: split each of those two groups by difficulty (for example `idioms-b1`, `idioms-c2`, `literary-b2`, `literary-c2`), or relax the validator so `cefr` may sit below the group level. Both are product decisions, not edits I can make.

3. **Not a defect — checked and cleared:** the odd `id` namespaces (`work-office.schedule` inside the A2 file, `academic-basics.argue` inside the B1 society file) are intentional. `LexiconBankLoader` fills a missing `id` with `<group.id>.<slug>` and keeps an explicit id "a word kept when it moved between groups". All 722 words therefore get a unique `itemId`, including the two `patient` entries (A2 noun, B1 adjective), which are distinct because they sit in different groups.

4. **Not a defect — checked and cleared:** the number of `wrong` sentences per word varies (one in files 02–05, 09, 12–16; two in 01, 06–08, 10, 11, 17). The loader only needs a non-empty list, and `chooseSentence` takes up to two, so both shapes work.

## Clean files

`lexicon-02`, `lexicon-03`, `lexicon-08`, `lexicon-09`, `lexicon-10`, `lexicon-11`, `lexicon-14`, `lexicon-15`, `lexicon-16`, `lexicon-18` — no row. Meanings are accurate, examples use the marked form naturally, every `wrong` sentence is a genuinely incorrect use of its word, and the only items I would touch are the shared register/CEFR notes above.

Across all 722 words of the 18 files that existed at this pass: no duplicate lemma+part-of-speech pair, no `cefr`/group mismatch, no unknown `register` or `pos`, no example without exactly one `{marked}` form, no meaning over 110 characters, no doubled spaces, no stray punctuation spacing. Quotes are curly-only in all 18 files (47 apostrophes, zero straight quotes), which is consistent. The five files added later continue this (17 more curly apostrophes, still zero straight — 64 in the bank today); see the addendum.

## Not checked

- I did not verify the CEFR placement of every word against an external word list (licence notes in the files say the authors used general knowledge, not a copied list). Levels look plausible on inspection; the only level problem I can defend is the group-level one above.
- I did not re-read the 80 coach-track lessons or the 57 course lessons in this report; the tracks are covered in `opencode-proofread-batches2-4-2026-10-25.md` and the course lessons get their own report.
- I did not run the app, so I have not seen the `chooseSentence` and cloze options as rendered; my checks are on the JSON and the builder code.

---

# Addendum — five new field groups (144 words)

Added after the main pass, when the bank grew from 18 to 23 files. Same method and same one test for `wrong` sentences: **would this sentence still be a correct use of the word?**

Validator at this second pass: `lexicon words: 866` / `course lessons: 57, track lessons: 80, typed exercises: 1848` / `OK`.

## Scope check (all verified in the loader, not assumed)

| check | result |
|---|---|
| Raw words in JSON vs words loaded | 866 raw = 866 loaded. **Zero** words dropped by the `lemma\|pos` de-duplication in `LexiconBankLoader.swift:43`. |
| Generated ids | All 144 new words omit `id`, so the loader fills `<group.id>.<slug>`. Computed every id across all 23 files: **no collisions**, so nothing is silently overwritten. |
| Per-word `cefr` | Every new word takes the group level (`field-business` B2, `field-tech` B2, `field-health` B2, `field-travel` B1, `field-law` C1). This is **not** a defect: field groups are exempt from the level ceiling (`LexiconPractice.swift:85`, `group.isField \|\| … cefr <= ceiling`), the Lexicon home labels them "Field" rather than a level (`LexiconHome.swift:74`), and they enter the Daily pool only after the learner activates them. So the group level does not lock anyone out. |
| `kind` | All five carry `"kind": "field"`, which is what sets `isField`. Correct. |

## Findings

| file | id | field | problem | suggested fix |
| --- | --- | --- | --- | --- |
| `lexicon-20-field-tech.json` | `server` | `wrong[0]` | “A server is a **person who brings food in a restaurant**, not a computer.” This *is* a correct use of “server” — it is the standard American word for a waiter. The question is “Which sentence uses “server” correctly?”, so this option is defensible as correct, and the learner is marked wrong for choosing a true statement. This is the one `wrong` sentence in the new files that fails the test. | Replace with something that is wrong in both senses, e.g. “A server is the cable that connects a monitor to a computer.” |
| `lexicon-22-field-travel.json` | `round trip` | `examples[0]` | “A {round trip} ticket is cheaper than **two single tickets**.” “Single ticket” is British; American English says “one-way ticket” — and the file defines `one-way` two entries later, so the file contradicts itself. | “…cheaper than two one-way tickets.” |
| `lexicon-22-field-travel.json` | `cruise` | `meaning` | “A **holiday** on a large ship that visits several places.” | “A **vacation** on a large ship…” |
| `lexicon-22-field-travel.json` | `resort` | `meaning` | “A place where people go for a **holiday**, with hotels and activities.” | “…for a **vacation**…” |
| `lexicon-21-field-health.json` | `therapy` | `examples[0]` | “She goes to {therapy} to **help her stress**.” Not idiomatic: you help *with* a problem or *manage* it; “help her stress” reads as helping the stress itself. | “She goes to {therapy} to **help with her stress**.” |
| `lexicon-19-field-business.json` | `startup` | `examples[0]` (on `pivot`) | The lemma is `startup` (one word) but the `pivot` example spells it “The **start-up** had to {pivot}…”. Same file, same company type, two spellings. | Use `startup` in the `pivot` example. |
| `lexicon-19-field-business.json` | `franchise` | `meaning` | “A business that sells the right to use its name and methods.” That describes the **franchisor**; a franchise is the right itself, or the business run under it. The same file's example (“She bought a {franchise} of a famous burger chain”) uses the correct sense, so the meaning and example disagree. | “The right to run a business using another company’s name and methods, or the business run that way.” |
| `lexicon-22-field-travel.json` | `layover`, `jet lag` | `register` | Both are marked `informal`, but both are neutral standard travel vocabulary (unlike, say, “a shuteye flight”). The same file marks the equally everyday `boarding pass`, `check-in` and `carry-on` as `term`. | `term` or `everyday` for both. |
| `lexicon-22-field-travel.json` | `check-in` vs `checkout` | `lemma` | Parallel nouns treated inconsistently: `check-in` hyphenated, `checkout` not. American style hyphenates both nouns (`check-in`, `check-out`) or neither; the pair also sits in the same file where `carry-on` and `one-way` are hyphenated. | Make it `check-in` / `check-out`, or `checkin` / `checkout`; pick one pattern. |

## Checked and clean in the new files

- **Every other `wrong` sentence** in the five files is genuinely an incorrect use of its word. Most are deliberately absurd definitions (“A benchmark is a bench in front of the office.”, “A lawsuit is a suit that a lawyer wears in court.”, “Phishing is a sport in which people catch fish with a net.”). Per the test above, that is valid: they are wrong uses, not correct ones. `vaccine` (“causes a disease on purpose”) is medically false and therefore correctly the wrong option.
- **All 144 `meaning` fields** other than `franchise` are accurate and short, use one full stop, and avoid British forms.
- **All 144 `examples`** other than the four above use the `{marked}` form exactly once and read naturally (`high overhead` as a mass noun, `The local {currency} is the euro`, `no {vacancy} on Friday`).
- **`pos`, `register`, `cefr`** are present on every word; register values are all in the allowed set; no duplicates with the existing 722 words.
- Curly quotes throughout the new files — no straight apostrophes.

## Still open

The register/CEFR group-level note in the main sections above was written for the 18 level groups and still stands for them. It does **not** extend to the field groups, because field groups are exempt from gating.

