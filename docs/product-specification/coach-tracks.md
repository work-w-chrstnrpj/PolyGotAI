# Coach tracks (v2)

> Owner direction 2026-10-25. Replaces the v1 "seven specialized trainers" ([history](../history/v1/product-specification/specialized-trainers.md)).

Each coach is a **track** in Learn: units, then lessons, then exercises. Tracks use the same exercise engine as the CEFR course ([tdd](../tdd/tdd.md#exercise-engine)). The Teacher hosts the CEFR course and is not one of the ten.

## Track structure

- **Stages** (owner approved 2026-10-25): Foundation (≈ A2–B1), Intermediate (≈ B1–B2), Advanced (≈ C1–C2). Grammarian and Reading & Listening add a fourth, **Starter** stage (A1).
- **Unit** = one skill (e.g. "Inverted pyramid"). 4–6 lessons.
- **Lesson** = coach tip → 8–15 auto-checked exercises → one open "Your turn" task → finish.
- **First delivery:** 2 units × 4 lessons per coach, then expand.
- Nothing is locked. Learners can open any unit. The level lock applies to the CEFR course only ([Course rules](product-specification.md#course-cefr-a1c2)); stages are a suggested order, never a gate.

## How coaches are presented (owner approved 2026-10-25)

The same shape as the Course (level → unit → lesson), so one list design serves both.

1. **Lesson tab:** title, one-line tagline, and a segmented switch **Course | Coaches**.
2. **Coaches grid:** one flat grid, no group headings. Each card has the coach artwork, name, a one-line tagline and a thin progress ring. Two columns on iPhone, three or four on iPad, one column at the largest Dynamic Type sizes. A **Continue** card above the grid resumes the last coach lesson.
3. **Only coaches with lessons appear.** No "coming soon" cards. Phase 2 shows the Grammarian alone, and the grid grows as Phase 4 lands each coach. Coaches without final art use an SF Symbol placeholder.
4. **Coach screen:** artwork, name and tagline at the top; stage chips (Starter only for Grammarian and Reading & Listening); below them one card per unit with its lesson count and progress bar.
5. **Unit screen:** a lesson list. Each row shows the title, a state (new, in progress, done) and the accuracy.
6. **Lesson player:** the existing player (coach tip → exercises → "Your turn" → finish), with the coach's character in the tip and the feedback bar.
7. **Elsewhere:** Today's "Up next" card may suggest a coach lesson; Progress shows per-coach progress; Speech Lab has no coach picker.

## Content rules

- All text is **original wording written for this app**. Sources supply structure and ideas only. Each lesson lists its sources in the catalog `sources` field.
- Public-domain texts (Project Gutenberg, LibriVox, US government works such as VOA Learning English and plainlanguage.gov) may be quoted or adapted, with credit.
- Copyrighted books (Cialdini, Fisher & Ury, Toulmin, Minto, AP Stylebook, etc.) are used for **concepts only**: no quotes, no copied examples.
- American English. Examples use diverse names and neutral settings, and make no assumptions about gender or nationality.
- Every exercise has one or more accepted answers and a one-line reason.

## The ten coaches

### 1. Grammarian — *Owl Grammarian* (artwork exists)

- **Focus:** accurate sentences while speaking and writing.
- **Units:** sentence building (subject–verb–object); be/have/do; present simple vs. continuous; past forms; perfect aspect; articles and determiners; countable/uncountable; modals; conditionals; relative clauses; reported speech; common-error clinic.
- **Signature exercises:** find the error, fix it, tap words into order, transform (positive → question → negative).
- **Feedback focus:** names the specific pattern, one rule at a time.
- **Sources:** British Council–EAQUALS Core Inventory (structure); CEFR Companion Volume; Strunk, *The Elements of Style* (1918, public domain).

### 2. Reading & Listening Comprehension — *Bear Librarian* (artwork exists)

- **Focus:** understanding texts and speech, gist and detail.
- **Units:** gist vs. detail; scanning for facts; main idea; inference; vocabulary from context; signal words (however, therefore); fact vs. opinion; note-taking; summarizing.
- **Signature exercises:** short passage or audio, then choice/match questions; "which sentence is the main idea?"; listen and type the key phrase.
- **Sources:** VOA Learning English (US public domain); Project Gutenberg and LibriVox (public domain text and audio); CEFR reading/listening descriptors.

### 3. Debater & Argument — *new character (owner to choose)*

- **Focus:** building and answering arguments clearly and fairly.
- **Units:** claim, reason, evidence; the Toulmin model (claim, grounds, warrant, rebuttal); steelmanning and Rapoport's rules; rebuttal phrases; common fallacies (straw man, ad hominem, false dilemma, slippery slope); weighing and comparing arguments; cross-examination questions.
- **Signature exercises:** put an argument in order; spot the fallacy; choose the strongest evidence; write a one-sentence rebuttal.
- **Sources:** Aristotle, *Rhetoric* (public-domain translations, Project Gutenberg); Toulmin, *The Uses of Argument* (concepts); Rapoport's rules as described by Daniel Dennett (concept).

### 4. Persuasion & Negotiation — *new character (owner to choose)*

- **Focus:** influencing ethically and reaching agreement.
- **Units:** ethos, pathos, logos; interests vs. positions; options and BATNA; making an offer; conditional concessions ("If you…, then I…"); softening and hedging language; saying no politely; Monroe's Motivated Sequence; ethical persuasion vs. manipulation.
- **Signature exercises:** label the appeal; rewrite a demand as an interest; choose the most polite refusal; order a motivated-sequence pitch.
- **Sources:** Aristotle, *Rhetoric*; Fisher, Ury & Patton, *Getting to Yes* (concepts); Cialdini's influence principles (concepts); Alan Monroe's Motivated Sequence (concept).

### 5. Public Speaking & Rhetoric (verbal + nonverbal) — *Parrot Speaker* (artwork exists)

- **Focus:** structure and delivery of talks.
- **Units:** the five canons (invention, arrangement, style, memory, delivery); strong openings and closings; signposting; rhetorical devices (tricolon, anaphora, antithesis, rhetorical question); pausing and emphasis; vocal variety; **nonverbal:** posture, eye contact, gestures, movement, managing nerves.
- **Signature exercises:** identify the device; choose the better opening; mark where to pause; nonverbal "what would you do" scenarios; record a 30-second talk.
- **Nonverbal practice** uses scenarios and self-checklists. Camera-based checks are not in scope now.
- **Sources:** Esenwein & Carnegie, *The Art of Public Speaking* (1915, public domain); Cicero's five canons; Silva Rhetoricae (BYU, free reference); Aristotle, *Rhetoric*.

### 6. Journalist — *Fox Journalist* (artwork exists)

- **Focus:** asking good questions and reporting accurately.
- **Units:** 5 Ws + H; the inverted pyramid; open vs. closed questions; follow-up questions; quoting and attribution; fact vs. opinion vs. uncertainty; headlines and ledes; summarizing a source fairly; ethics (accuracy, fairness).
- **Signature exercises:** order paragraphs into an inverted pyramid; turn a closed question into an open one; pick the accurate summary; write a headline.
- **Sources:** inverted-pyramid and 5W conventions; SPJ Code of Ethics (summarized, not quoted at length).

### 7. Creative Writing (fiction) — *Creative Writer (artwork pending)*

- **Focus:** writing vivid, well-shaped fiction in English.
- **Units:** character; setting; conflict; point of view; show, don't tell; sensory detail; dialogue and its punctuation; plot shape (Freytag's pyramid); beginnings and endings.
- **Signature exercises:** choose the "show" version; fix dialogue punctuation; add a sensory detail; continue a scene.
- **Sources:** Freytag, *Technique of the Drama* (public domain); Aristotle, *Poetics* (public domain); Chekhov's letters on writing (public-domain translations); Gutenberg short stories as models.

### 8. Business & Professional — *Tiger Business Professional* (artwork exists)

- **Focus:** clear workplace communication.
- **Units:** small talk and introductions; meetings (agreeing, disagreeing, interrupting politely); emails; status updates (BLUF); PREP answers; **job interviews (STAR)**, absorbing v1 Interview practice; presentations; plain language; feedback (SBI).
- **Signature exercises:** order a BLUF email; choose the more polite phrasing; match STAR parts; rewrite in plain language.
- **Sources:** Federal Plain Language Guidelines (plainlanguage.gov, public domain); Minto, *The Pyramid Principle* (concepts); STAR, PREP, BLUF and SBI conventions.

### 9. Storytelling — *new character (owner to choose)*

- **Focus:** telling stories out loud that people remember.
- **Units:** the story spine; personal anecdotes; tension and payoff; the hero's journey; the story circle; retelling fables; time words and narrative tenses; oral delivery (pace, pause, voices).
- **Signature exercises:** fill a story spine; order story events; choose the stronger hook; retell a fable aloud.
- **Sources:** Kenn Adams' story spine (credited); Campbell's monomyth (concept); Dan Harmon's story circle (concept); Aesop's fables (public domain).

### 10. Advertising & Copywriting — *new character (owner to choose)*

- **Focus:** short persuasive writing for products and ideas.
- **Units:** features vs. benefits; AIDA; PAS (problem, agitate, solve); headlines; calls to action; tone of voice; taglines and slogans; writing for different channels; truthful claims.
- **Signature exercises:** turn a feature into a benefit; order AIDA parts; pick the clearer CTA; spot a misleading claim.
- **Sources:** E. St. Elmo Lewis (AIDA, concept); Claude Hopkins, *Scientific Advertising* (1923, public domain); FTC truth-in-advertising guidance (US government, public domain).

## Relationship to Speech Lab practice

Speech Lab **keeps** Conversation, Interview and Communication practice (owner decision 2026-10-25). The coaches teach the skills; Speech Lab is where the learner practices them out loud.

| Speech Lab practice | Taught in the Lesson tab by |
| --- | --- |
| Interview | Business & Professional → Job interviews unit |
| Conversation | CEFR course role-play lessons; Business & Professional |
| Communication (PREP/BLUF/STAR/SCQA/SBI) | Business & Professional; Public Speaking & Rhetoric |
| Coach picker | Removed from Speech Lab; the default coach is set in Settings |
| Generated practice | Hidden until online AI is enabled (Phase 6) |

## Online AI coaching (later, Phase 6)

The "Your turn" task in each lesson can be sent, by explicit request with the learner's own key, to an AI coach. The AI reviews it with that coach's feedback focus.
