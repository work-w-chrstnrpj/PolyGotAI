# Proofread: docs against the code (counts, tab names, screen names)

Read-only report. No source file, doc or project setting was changed. Only this file was written.

**Validator output** (`python3 tools/curriculum/validate.py`, run 2026-10-25):

```text
lexicon words: 866
course lessons: 57, track lessons: 80, typed exercises: 1848
OK
```

The last line is `OK`. Note the lexicon bank grew from 18 files / 722 words to **23 files / 866 words** while this review was running. `lexicon.md` already documents the new figure in its line 67, but its line 64 still quotes the old one (row 1).

## Method

Compared the claims in `docs/product-specification/*.md` and `docs/tdd/tdd.md` with the shipped code and bundled content. Code and JSON are treated as truth. Table columns are `file | location | claim as written | code reality | suggested fix`; this is the Job 3 variant of the shared table format, because the "id" of a doc claim is its line.

Not a repeat of `opencode-docs-sweep-2026-10-25.md`: this pass only checks the three requested things (counts, tab names, screen names) plus the structural claims that carry them.

## 1. Counts

| file | location | claim as written | code reality | suggested fix |
| --- | --- | --- | --- | --- |
| `product-specification/lexicon.md` | line 64 vs line 67 | Line 64: “18 groups of about 40 words, **three per CEFR level A1–C2** (722 words)”. Line 67: “five opt-in groups … about 28 words each (144 in all) … **The bank has 866 words in 23 groups.**” | The file contradicts itself. Line 67 is correct and matches the code and `validate.py` (`lexicon words: 866`, 23 files, 144 field words = 27+30+28+29+30). Line 64 is the un-updated original bullet. I checked every claim in line 67 against the code and all of them hold: five packs at B2/B2/B2/B1/C1, “Field” tag (`LexiconHome.swift:74`), never the default group (`LexiconPractice.swift:30`), never the “Next” suggestion (`:62` `!group.isField`), daily word only while switched on (`:83–85`). | Rewrite line 64 to the 18 **level** groups and drop the bank total from it, since line 67 now owns the 23/866 figure: “18 level groups of about 40 words, three per CEFR level A1–C2 (722 words), plus five opt-in field packs (line below).” |
| `product-specification/lexicon.md` | line 64 | Two rules in one bullet: “Words new in Lexicon 2 have **one** wrong-usage sentence.” … “Each word has **one or two** wrong-usage sentences.” | The schema field is `wrong` (a list) and the bank uses 1–2 per word; the validator only requires it to be non-empty. The two sentences in the same bullet disagree. | Keep “one or two” and delete the “one” sentence, or state which groups carry two. |
| `product-specification/product-specification.md` | line 29 | “**Coach tip.** 2–4 sentences that teach one idea, with an example.” | 15 of 57 tips are longer: 11 have 5 sentences, 4 have 6 (`a1-numbers`, `a1-weather`, `a2-appointments`, `c2-culture`). `intro-01` has no `tip` at all. The shortest is 2. | Either trim those 15 tips or relax the doc to “3–6 sentences”; also decide whether `intro-01` is exempt (it is the v1 introduction lesson). |
| `tdd/tdd.md` | line 55 | `tip` = “Coach tip shown before the exercises (2–4 sentences)” | Same as above: 15 tips exceed 4. | Same fix as the product spec — change both places together so they cannot drift apart. |

### Counts that are correct

- **Coach tracks: 10.** `Resources/Tracks/` holds exactly 10 files, and `TrackCoach` has exactly 10 cases (grammarian, reading-listening, debater, negotiator, public-speaker, journalist, creative-writer, business, storyteller, copywriter). `product-specification.md:17,54` and `ui-ux-design.md:11` all say 10.
- **Track lessons: 80.** 10 tracks × 8 lessons, each track with 1 stage and 2 units — matches `coach-tracks.md:10–12` (“4–6 lessons” per unit; “2 units × 4 lessons per coach”). `validate.py` agrees (`track lessons: 80`).
- **Lessons per lesson count: 13–14 auto-checked exercises.** `product-specification.md:30` claims “Exercises (8–15)”; every real lesson is 13 or 14, so the range holds. Only `intro-01` (0) is outside it, and it is the legacy introduction lesson.
- **Course lessons: 57** (13 A1 + 44 A2–C2). No product spec states a lesson count, so nothing is stale; the figure is recorded here because reviewers ask for it.

## 2. Tab names — verified, no drift

`application/SpeechCoachAI/Features/Navigation/AppShell.swift` (`AppDestination.title`) ships exactly:

```text
Today · Lexicon · Lesson · Speech Lab · Progress
```

This matches `product-specification.md:21` (“Tab order: **Today | Lexicon | Lesson | Speech Lab | Progress**”) and `ui-ux-design.md:7` (“Today | Lexicon | Lesson | Speech Lab | Progress”) and `:28` (“Today, Lexicon, Lesson, Speech Lab, Progress”), word for word in the names, including the space in “Speech Lab” and the singular “Lesson”. The raw case name is `.vocabulary` while the title is “Lexicon” — internal only, no doc impact. Profile is a toolbar button that opens Settings, as `ui-ux-design.md:7,28` documents.

## 3. Screen names and Speech Lab navigation

The shipped Speech Lab hub (`AppShell.swift:296–345`) has these entries:

```text
Dictation · Pronunciation → (Sounds, Clear speech) · Speaking · Interview · Conversation · Communication · Record an introduction
```

`Pronunciation` is `SpeechLabPronunciationView`, and it is the only way into Phonetics (“Sounds”) and Articulation (“Clear speech”). `Speaking` is `SpeechLabVoiceView` (the former “Voice”). `speech-lab.md:55` states this correctly. Two other docs do not.

| file | location | claim as written | code reality | suggested fix |
| --- | --- | --- | --- | --- |
| `product-specification/ui-ux-design.md` | line 28 | “**(v2: Speech Lab = Phonetics, Articulation, Dictation, Voice; interview and business practice moved to Lesson → Coaches.)**” | Wrong twice. Interview, Conversation, Communication and Record an introduction are still Speech Lab hub entries (`speech.interview`, `speech.conversation`, `speech.communication`, `speech.record`), and Phonetics/Articulation are second-level under Pronunciation, not top-level modes. This line also contradicts line 7 of the same file. | Replace with `speech-lab.md:55`'s wording: “Speech Lab = Dictation · Pronunciation (Phonetics and Articulation together) · Speaking · Interview · Conversation · Communication.” |
| `product-specification/ui-screen-state-inventory.md` | line 3 | “Speech Lab families for conversation, interview and communication now belong to **Lesson → Coaches**” | Same contradiction: those three are shipped Speech Lab entries, not coach-track screens. | “Speech Lab keeps conversation, interview and communication; the new sound-and-voice screens are Dictation, Pronunciation (Phonetics, Articulation) and Speaking.” |
| `product-specification/ui-ux-design.md` | line 7 | “Speech Lab keeps Conversation, Interview and Communication and **adds Phonetics, Articulation, Dictation and Voice**” | The kept modes are right. The four “added” names are not the hub labels: the hub shows `Pronunciation` (grouping Phonetics + Articulation), `Speaking` (not “Voice”) and `Dictation`. | “…adds Dictation, Pronunciation (Phonetics and Articulation) and Speaking.” |
| `product-specification/ui-screen-state-inventory.md` | line 105 (SP-01) | Entry lists “AI conversation (free/scenario), interview, everyday/pronunciation/business/spontaneous/communication/articulation setup” | That v1 mode set no longer exists. The hub has the six entries listed above plus Record an introduction. | Restate SP-01 against the shipped six, or mark the row superseded by `speech-lab.md`. |
| `product-specification/ui-ux-design.md` | line 34 | “with a **"Take the C1 test"** action on **every** locked level” | The button is `"Take the \(level) test"` (`CourseCatalogView.swift:38`), so each locked level shows its own level name. Only C1 shows “Take the C1 test”. `product-specification.md:50` words this correctly with A2. | “with a “Take the A2 test”-style action on every locked level (the level's own name)”. |

`product-specification.md:18` (“Introduction recording, Conversation, Interview, Communication practice, plus Phonetics, Articulation, Dictation, Voice”) lists modes rather than hub labels and is close enough to the shipped screen to leave alone; the same applies to `speech-lab.md`, which is accurate throughout.

## 4. TDD structure, file paths and rules

| file | location | claim as written | code reality | suggested fix |
| --- | --- | --- | --- | --- |
| `tdd/tdd.md` | line 26 | `Resources/` contains “`Curriculum/` (catalog JSON + audio), `Tracks/` (v2), `Rewards/`, `Assets.xcassets`” | `Resources/` also contains `Lexicon/` and `SpeechLab/`. The TDD documents `Resources/Lexicon/` itself at line 145, so the layout block contradicts the body. | Add `Lexicon/ (v2 word bank)` and `SpeechLab/ (v2 drill catalogs)`. |
| `tdd/tdd.md` | line 174 | “`Infrastructure/Speech/OnDeviceRecognizer.swift`: `SFSpeechRecognizer(locale: en-US)` …” | No such file. `Infrastructure/Speech/` holds `DictationRecognizer.swift`, `SpeechLabCapture.swift`, `SpeechLabCatalog.swift`, `SpeechLabRecognizer.swift`, `SpeechSynthesizer.swift`. The class described is `SpeechLabRecognizer`. | Rename the path to `SpeechLabRecognizer.swift`. |
| `tdd/tdd.md` | line 175 | “`Domain/VoiceMetrics.swift`: words per minute, pauses > 1 s, filler count, loudness samples” | No such file. The metrics live in `Domain/SpeechLab.swift` and `Domain/SpeechLabVoice.swift` (searched for `wordsPerMinute`/`fillerCount`). | Point at the real files, or state that metrics are split across them. |
| `tdd/tdd.md` | lines 84–87 | Coach-track example: top-level `trackId`, `coach`, `title`, and `units[].lessons[]` nesting | Real shape (`Domain/TrackCatalog.swift:73–79`, `Resources/Tracks/*.json`): a pack object with `packId`, `track: { id, coach, stages: [{ id, title, units: [{ id, title }] }] }` **and lessons in a separate top-level `lessons[]`**, joined to units by `trackId`/`unitId` (line 143). `title` is derived from the coach, and `coach` values are camelCase ids (`creativeWriter`, `publicSpeaker`, `readingListening`), not `owlGrammarian`. | Replace the example with the real skeleton, and say lessons are flat and joined by `trackId`/`unitId`. As written, an engineer following the TDD would build a file the loader cannot resolve. |
| `tdd/tdd.md` | line 114 | “`.almost(hint)` (same word count; one word within edit distance 1, or 2 for words of 8+ letters)” | `AnswerChecker.swift:96` adds a floor the TDD omits: `guard expected.count >= 4 else { return false }` — words shorter than 4 letters must match exactly, so “cat” vs “cut” is not “almost”. | Add “words under 4 letters must match exactly”. |
| `tdd/tdd.md` | line 72 | `accepted`: “The first is the model answer shown after answering” | The lesson player shows `activity.answer` as the EXAMPLE block (`LessonPlayerView.swift:347–350`); `accepted.first` reaches the screen only as a fallback inside `ExerciseActivityView.swift:409`. This mismatch is exactly what the lesson report flags in 54 recall activities. | Either fix the data (`answer == accepted[0]`) and keep the sentence, or state that the example comes from `answer`. |
| `tdd/tdd.md` | lines 147–156 | Bank file “`Resources/Lexicon/<groupId>.json`” with a flat `{ "groupId": …, "title": …, "level": …, "sources": […], "words": […] }`, and word keys `wrongUsage` / `blankSentences` | Four differences from the shipped files. (1) The file name is not the group id: the file is `lexicon-01-a1-everyday.json` while `groupId` is `everyday-a1`. (2) There is no flat `groupId`/`title`/`level`/`sources` — they are nested under `"group"`, which also carries `tagline` and an optional `kind` (`LexiconBankLoader.GroupFile.Header`). (3) The word key is `wrong`, not `wrongUsage` (`Lexicon.swift:40`). (4) `blankSentences` does not exist: the blank is derived from the `{…}` marker inside `examples` (`Lexicon.swift:56–67`), so examples are stored as “Can I {borrow} your pen?”. The prose under the example (“`fillBlank`/`choice` from `blankSentences` … versus `wrongUsage`”) repeats the wrong names. | Replace the example with the real shape (`group: {id, title, level, tagline, sources, kind?}`, word keys `lemma, pos, meaning, examples, wrong, cefr, register, id?`) and say blanks come from the braced form. `lexicon.md:64` already describes this correctly. |

## 5. Behavioral claims that contradict each other or the code

| file | location | claim as written | code reality | suggested fix |
| --- | --- | --- | --- | --- |
| `product-specification/english-curriculum.md` | line 11 | “Learners choose any available level freely; unreleased content is marked **Coming later**.” | Two stale claims in one sentence. Levels are gated: `CourseCatalogView` locks a level behind `LevelGate`/jump test, per `product-specification.md:48–50`. And unfinished content is **hidden**, not labelled “Coming later” — `ui-ux-design.md:34` (“Unreleased content is hidden, not labeled”) and `product-specification.md:73` (“Unfinished features are hidden”). | “Only unlocked levels are shown as open; later levels show their test action. Unfinished content is hidden.” |

## Claims checked and found correct

- Tab names and order (section 2).
- `product-specification.md` level-gating rules (`48–50`) match `LevelGate` + `CourseCatalogView`: lock per level, test for any locked level including C2 from A1, pass opens that level and every level below, lessons inside an unlocked level open in any order.
- `speech-lab.md` (Home, modes, honesty rule, dictation-on-every-field) matches the shipped hub and `DictationButton`.
- Exercise `type` list in `tdd.md:70` matches `ExerciseType` exactly (9 cases, same names, including `open`).
- `tdd.md:93` validation list matches `tools/curriculum/validate.py`, including “accepted answer is in `options`” for `choice`.
- `tdd.md:37` persistence (three rows: `StateRow`, `AttemptRow`, `FileIntentRow`) matches the shipped schema description in `AGENTS.md` and `Persistence/`.
- `tdd.md:166–167` `DictationRecognizer.swift` / `Features/Shared/DictationButton.swift` paths exist.

## Not checked

- `docs/history/**` (v1 archive, reference only) and `docs/development-plan/**` (owned by Claude in the current phase).
- The 70-family Figma design tables in `ui-screen-state-inventory.md` beyond the Speech Lab rows: they describe design coverage, not shipped screens, and the doc itself says it is `IN_PROGRESS`.
- Anything requiring a build or a simulator run. No `xcodebuild` or simulator command was executed; all code claims above come from reading source.
