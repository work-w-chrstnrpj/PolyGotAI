# Lexicon (v2)

> Owner direction 2026-10-25. The **Vocabulary** tab becomes **Lexicon**. It keeps spaced-repetition training (FSRS-6, already implemented) and adds four modes. Replaces the v1 "Vocabulary" section of the spec.

Tab order: **Today | Lexicon | Lesson | Speech Lab | Progress**.

## The four modes

| # | Mode | Where | What it is | Status |
| --- | --- | --- | --- | --- |
| 1 | **Daily Lexicon** (word of the day) | **Today** tab | One word a day from the Lexicon bank: word, meaning, one example, a speaker button. "Add to training" if it isn't there yet | Phase 3 |
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

## CEFR vocabulary levels and register (owner direction 2026-10-25)

The predefined bank is organized by CEFR level, A1 to C2, with about three groups per level. Each word carries its level and a register tag: everyday, term, jargon, slang or informal. Groups switch on to match the level the learner has unlocked, and the next group is suggested when one is finished. Ready-made field packs (business, tech, health, travel, law) add terms and jargon offline. AI-made collections (mode 4) use the same level and register fields.

## Content sources for the predefined bank

Word lists are chosen from open, well-known lists; **all meanings and examples are original wording**. Candidate sources: New General Service List (NGSL) and New Academic Word List (NAWL) from the NGSL Project (CC BY-SA 4.0: credit, and check the share-alike effect on the word *list* before publishing), Coxhead's Academic Word List, and public-domain word lists. Lists are used only to choose which words to include. Licensing is checked before any list is bundled. Every bank file records its sources.

## Data (summary; full detail in the TDD)

- Bank: bundled `Resources/Lexicon/*.json`, one file per group, validated like lessons.
- Learner data: review cards, enrollments and recalls already exist. v2 adds an optional "Lexicon" section to the learner document: active groups, user-added words, Lexicon in Action history, and the daily-word record.

## As built in Phase 3 (2026-10-25)

- **Bank:** `Resources/Lexicon/lexicon-*.json`, three groups of 40 words: Everyday A1, Work and office, Academic basics. Examples mark the word form with braces (`She felt {happy} today.`), which gives the blank and the typed answer for Lexicon in Action. Each word has one or two wrong-usage sentences. `tools/curriculum/build_lexicon.py` generates the files and `validate.py` checks them. The wrong-usage sentences still need a native-speaker read.
- **Daily Training:** words enroll when a session starts: the next words of the active groups (the first group is active by default, 10 new words a day, adjustable in the stored state). Due words from lessons and "My words" are in the same session. Ratings use the existing FSRS-6 scheduler. A word's stage is New, Learning, Review, or Easy (Easy while its latest rating is Easy).
- **Lexicon in Action:** appears on the Lexicon tab once a word is Easy. Each session has up to 10 questions, cycling between choose-the-missing-word, choose-the-sentence and type-the-word. A right answer (a spelling slip counts) makes the word wait longer: 1, 3, 7, 14, 30, then 60 days. A wrong answer clears the wait and rates the word Hard in Daily Training.
- **Daily Lexicon:** the next unshown bank word that isn't Easy; it stays the same all day and the cycle restarts when every word has been shown.
- **Adding words:** the Add a word screen checks lemma and part of speech (ignoring case, accents and spaces). A match, in the bank, in "My words" or among saved words, shows "Already in your Lexicon". Added words land in a "My words" topic and are scheduled like any other.
- **Stored state:** an optional `lexicon` section of the learner document (active groups, daily word, Lexicon in Action waits). No SwiftData migration.

## Not in scope

Spanish or other languages, shared decks between learners, importing from Anki, handwriting, images on cards.
