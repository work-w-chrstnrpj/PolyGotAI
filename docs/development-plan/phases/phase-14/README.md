# Phase 14 — Lexicon to about 2,400 words

Owner decision (feedback round 2, point 3): about 2,400 built-in words, around 400 per rank, packs of 40–80, written offline in batches, with synonyms. Whole phase: Claude. **Built 2026-10-26; native-speaker proofread and owner play-test open.**

## What changed

| Rank | Before | New packs | After |
| --- | --- | --- | --- |
| A1 | 120 | Body and clothes, Things at home, Everyday actions, Describing words, Time and calendar, Animals and nature, School and fun (7 × 40) | 400 |
| A2 | 120 | Shopping and money, Food and cooking, Weather and nature, People and family, Useful verbs, Sport and free time, Getting around town (7 × 40) | 400 |
| B1 | 157 | Study and learning, Phones media and news, Health and the body, Relationships, Phrasal verbs, Linking and adverbs (6 × 40) | 397 |
| B2 | 215 | Science and the environment, Society and politics, Arts and books, Formal linking words, Character and behavior (5 × 40) | 415 |
| C1 | 155 | Reasoning and argument, Verbs of change, People and personality, Economy and policy, Communication, Formal adverbs (6 × 40) | 395 |
| C2 | 99 | Rare and formal verbs, Rare describing words, Formal nouns, More idioms, Academic precision, More literary language (6 × 45) | 369 |

Totals: 2,376 words (2,232 in 55 rank packs, 144 in the 5 field packs). Every new word has a meaning, one example with the marked form and one wrong-usage sentence; 1,046 of the 1,510 have synonyms. All wording is original.

- **Older words are untouched:** the 23 earlier files are byte-identical apart from their file number, so ids and saved progress carry over. Files are now numbered in rank order by `build_lexicon.py`.
- **Checks:** the build fails on a repeated word (normalized lemma + part of speech), a malformed row, or a level word that would remove a field-pack word. Same-pack near-synonyms list each other, so the synonym question never offers one as a wrong choice for the other.
- **Training settings:** each rank's packs sit in a closed list ("A1 packs · 3 of 10 on"); field packs stay open.

## Files

`tools/curriculum/lexdata/more_{a1,a2,b1,b2,c1,c2}.py` (new), `build_lexicon.py`, `add_synonyms.py`, the Lexicon block of `validate.py`, `Resources/Lexicon/*.json`, `Features/Vocabulary/LexiconSettingsView.swift`, `SpeechCoachAITests/{LexiconTests,LexiconTrainingTests}.swift`, `SpeechCoachAIUITests/Phase3LexiconTests.swift`, `docs/product-specification/lexicon.md`.

## Verification

Run in a clean copy (commit `b3f5f25` + Phase 14 files) because the shared tree did not compile from another lane's in-progress file: `validate.py` OK; 411 unit tests pass; Phase 3 Lexicon UI tests 5/5 pass on iPhone 18 Pro Max (one test's scroll loop was made to wait for the row, not only its header). Screenshots: [A1 packs](evidence/settings-a1-packs-largest-text.png), [field packs](evidence/settings-field-packs-largest-text.png), both at the largest text size. Full `verify.sh`, iPad and Dark Mode were not run.

## Not done

- A native-speaker proofread of the 1,510 new entries (OpenCode Job 10 can take it). Wrong-usage sentences for linking words and adverbs are the weakest part.
- Easier idioms in "More idioms" keep the pack's C2 level; lowering a few (as was done for the first idiom pack) is a later tweak.
- Install on the owner's iPhone and play-test.
