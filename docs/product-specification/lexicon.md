# Lexicon (v2)

> Owner direction 2026-10-25. The **Vocabulary** tab becomes **Lexicon**. It keeps spaced-repetition training (FSRS-6, already implemented) and adds four modes. Replaces the v1 "Vocabulary" section of the spec.

Tab order: **Today | Lexicon | Lesson | Speech Lab | Progress**.

## The four modes

| # | Mode | Where | What it is | Status |
| --- | --- | --- | --- | --- |
| 1 | **Daily Lexicon** (one word a day) | **Today** tab | One word a day from the Lexicon bank: word, meaning, one example, a speaker button. "Add to training" if it isn't there yet | Phase 3 |
| 2 | **Lexicon Daily Training** | Lexicon tab | Predefined groups of words trained with spaced repetition. Learners can add their own words to the bank | Phase 3 (today's recall screens already work for saved words) |
| 3 | **Lexicon in Action** | Lexicon tab | Words the learner marked **Easy** in Daily Training reappear in context: fill the blank, or choose the sentence that uses the word correctly | Phase 3 |
| 4 | **Specialized Lexicon Training** | Lexicon tab | The learner names a field (for example Software Engineering). AI generates its vocabulary, jargon, slang and terms, which are added to the bank and trained like any other words | Phase 6 (needs the learner's AI key) |

## 1. Daily Lexicon (Today)

- One card on Today, below the continue card: the word, its meaning, one example sentence, a speaker button (on-device voice), and **Add to training**.
- Chosen from the predefined bank, in bank order, skipping words the learner has already rated Easy. The word stays the same all day, and all day it can be revisited.
- Works offline. Opening it counts as an exposure (no scheduling credit; scheduling happens only in Daily Training).

## 2. Lexicon Daily Training

- **The bank:** the app ships predefined **groups** of words (for example "Everyday A1", "Work and office", "Academic basics"). Each word has a lemma, a part of speech, a short learner-friendly meaning, 1–2 example sentences (original wording), and one or two **wrong-usage sentences** for Lexicon in Action.
- **Spaced repetition:** each word is a review card (existing FSRS-6 scheduler). Learners see four ratings: Again, Hard, Good, Easy. The word's **stage** is shown as New, Learning, Review or Easy, taken from its card state and last rating.
- **Daily session:** due words first, then new words from the learner's active groups, up to the daily limit already in Review options.
- **Adding words:** the learner can add words to the bank (lemma, meaning, optional example). **A word that is already in the bank can't be added again.** Duplicates are detected by lemma and part of speech, ignoring case, accents and extra spaces; a close match shows "Already in your Lexicon" with a link to the existing word.
- **Groups:** learners choose which predefined groups are active. Their own words live in a "My words" group.
- Existing v1 data (saved words, custom topics, review cards) carries over as "My words" and keeps its schedule.

## 3. Lexicon in Action

- **Eligibility:** a word whose latest rating in Daily Training is **Easy**. If the learner later rates it Again or Hard, it leaves Lexicon in Action until it is Easy again.
- **Two question types** (they reuse the exercise engine from the lessons):
  - **Fill the blank:** a sentence with the word removed, and the learner types it or picks it (`fillBlank` / `choice`).
  - **Choose the sentence:** three sentences, one uses the word correctly (`choice`).
- **Content:** needs example and wrong-usage sentences. Predefined words ship with them. A learner's own word joins Lexicon in Action once it has an example sentence the learner wrote (fill the blank only) or is covered by AI generation in Phase 6.
- A session is 8–10 questions. Results feed back to the word: a wrong answer sends it back into Daily Training with a Hard rating; correct answers lengthen how long it waits for the next Lexicon in Action.
- Instant right/almost/not-quite feedback, like lessons.

## 4. Specialized Lexicon Training (online, Phase 6)

- The learner types a field ("Software Engineering", "Nursing", "Football", "Gen Z slang"), picks a level, and taps Generate. The app sends one request to the learner's own AI provider (BYOK) and gets back a list of terms, each with meaning, example, part of speech and a register tag (term, jargon, slang, informal).
- The learner reviews the list and keeps the ones they want. Kept words enter the bank in a group named after the field and are trained like any other word (modes 2 and 3).
- Duplicates against the bank are skipped automatically.
- The generation prompt asks for accurate terms and original examples. The learner can flag a wrong term; flagged terms are removed.
- Without a key, this mode shows a single "Add your AI key in Settings" button and nothing else.
- **Core built 2026-10-26 (no screen yet):** `LexiconGenerationRequest` (topic up to 80 characters, level, up to 15 words) and `GeneratedLexicon` (each card checked like a bundled word; broken, above-level, repeated and already-known words are skipped and listed). The learner picks words from the preview; `saveGeneratedLexicon` puts them in a personal topic named "AI: <topic>" and enrolls them for review.

## CEFR vocabulary levels and register (owner direction 2026-10-25)

The predefined bank is organized by CEFR level, A1 to C2, with about three groups per level. Each word carries its level and a register tag: everyday, term, jargon, slang or informal. Groups switch on to match the level the learner has unlocked, and the next group is suggested when one is finished. Ready-made field packs (business, tech, health, travel, law) add terms and jargon offline. AI-made collections (mode 4) use the same level and register fields.

## Content sources for the predefined bank

Word lists are chosen from open, well-known lists; **all meanings and examples are original wording**. Candidate sources: New General Service List (NGSL) and New Academic Word List (NAWL) from the NGSL Project (CC BY-SA 4.0: credit, and check the share-alike effect on the word *list* before publishing), Coxhead's Academic Word List, and public-domain word lists. Lists are used only to choose which words to include. Licensing is checked before any list is bundled. Every bank file records its sources.

## Data (summary; full detail in the TDD)

- Bank: bundled `Resources/Lexicon/*.json`, one file per group, validated like lessons.
- Learner data: review cards, enrollments and recalls already exist. v2 adds an optional "Lexicon" section to the learner document: active groups, user-added words, Lexicon in Action history, and the daily-word record.

## As built in Phase 3 (2026-10-25)

- **Bank (Lexicon 2):** `Resources/Lexicon/lexicon-*.json`, 18 level groups of about 40 words, three per CEFR level A1–C2 (722 words), plus five opt-in field packs (below). Every word has a `cefr` level (never above its group's; easier idioms and literary words sit lower inside the C2 groups) and a per-word `register` (everyday, formal, term, jargon, slang, informal, literary). Words from the first bank keep their ids, so earlier progress still counts. Word choice follows CEFR-style levels; the lists were used only to choose words (see sources) and no list file is bundled. Examples mark the word form with braces (`She felt {happy} today.`), which gives the blank and the typed answer for Lexicon in Action. Each word has one or two wrong-usage sentences (words new in Lexicon 2 have one). `tools/curriculum/build_lexicon.py` generates the files and `validate.py` checks them. The wrong-usage sentences still need a native-speaker read.
- **Daily Training:** words enroll when a session starts: the next words of the active groups (until the learner chooses, the first group of the highest unlocked level is active; 10 new words a day, adjustable in the stored state). Due words from lessons and "My words" are in the same session. Ratings use the existing FSRS-6 scheduler. A word's stage is New, Learning, Review, or Easy (Easy while its latest rating is Easy).
- **Lexicon in Action:** appears on the Lexicon tab once a word is Easy. Each session has up to 10 questions, cycling between choose-the-missing-word, choose-the-sentence and type-the-word. A right answer (a spelling slip counts) makes the word wait longer: 1, 3, 7, 14, 30, then 60 days. A wrong answer clears the wait and rates the word Hard in Daily Training.
- **Field packs (L2.3):** five opt-in groups after the level groups — Business and finance (B2), Technology (B2), Health and medicine (B2), Travel (B1), Law (C1) — about 28 words each (144 in all), mostly terms with some jargon and formal wording, each word with one wrong-usage sentence. They show under "Field packs" on the Lexicon tab with a "Field" tag. A pack is never the default group and never the "Next" suggestion; the daily word comes from a pack only while the learner has switched it on. The bank has 866 words in 23 groups.
- **Level-aware start:** the daily word and new training words never come from a level above the learner's highest unlocked level. When every active group is started, the Lexicon tab marks the next unfinished group at or below that level as "Next".
- **Daily Lexicon:** the next unshown bank word that isn't Easy; it stays the same all day and the cycle restarts when every word has been shown.
- **Adding words:** the Add a word screen checks lemma and part of speech (ignoring case, accents and spaces). A match, in the bank, in "My words" or among saved words, shows "Already in your Lexicon". Added words land in a "My words" topic and are scheduled like any other.
- **Stored state:** an optional `lexicon` section of the learner document (active groups, daily word, Lexicon in Action waits). No SwiftData migration.

## Phase 8 rework (2026-10-26)

- **Lexicon home:** Daily Training card (to review · new, next review time, the ranks in use) with **Start** and **Practice**; Lexicon in Action when words are ready; **Training from** (only the packs in use, with progress) and a **Settings** button; **Your packs** (the learner's own topics, now called packs); **Saved words**.
- **Training settings:** rank switches A1–C2 (all off = every rank; "C2 only" takes new words from every C2 pack unless C2 packs were chosen), new words per day (0–30), a switch per pack (grouped by rank, then field packs), **Hide** by swipe or context menu, a Hidden packs list with **Show**, and Review options. The rank filter ignores the course lock (owner decision 2026-10-26).
- **Practice:** unlimited, unrated rounds of 10: "Choose the word that fits" (sentence with a blank, four words of the same part of speech) and "Which word is closest in meaning to …?" (one synonym, three non-synonyms). Uses words already started, else the packs in training. Never changes the review schedule.
- **Rating buttons** show when the word comes back, Anki-style ("<1m", "10m", "1d", "4d", "2mo"). The scheduler is FSRS-6, the algorithm Anki offers as its modern option.
- **Your packs:** "Train all" adds every word of a pack to Daily Training; **Fill with AI** (only when online feedback is set up) writes words for the pack and saves the ones the learner picks into that pack.
- **Saved words:** only words kept from lessons and the word of the day, searchable, each with its next review or **Add to training**. Lexicon bank words and pack words are no longer mixed in.
- **Synonyms:** 700 of 866 bank words carry `synonyms` (written in `tools/curriculum/lexdata/synonyms.py`, applied by `add_synonyms.py`); words without an honest synonym are asked as sentence questions only.

## Not in scope

Spanish or other languages, shared decks between learners, importing from Anki, handwriting, images on cards.
