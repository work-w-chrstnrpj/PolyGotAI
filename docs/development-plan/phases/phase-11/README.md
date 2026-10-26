# Phase 11 — Lessons depth (Claude)

**Status:** EXECUTE (owner: "continue Phase 11 first", 2026-10-26). **Why:** the owner found the coaches shallow. The Grammarian taught sentence patterns but no parts of speech ([rework plan](../../review-and-rework-plan-2026-10-26.md) §2 Lesson).

## Grammarian: full syllabus
The existing 32 lessons stay unchanged, so saved progress is kept. Seven new units (40 lessons, 12 auto-checked activities each) fill the gaps. They are added inside the existing stages with `track_lib.add_units`.

| Stage | New unit (placed) | Lessons |
|---|---|---|
| Starter (A1) | **Parts of speech** (first) | Nouns: common and proper · Singular and plural · Personal pronouns · Possessives · Articles: a, an, the · Adjectives · Adverbs · Conjunctions and interjections |
| Foundation (A2–B1) | **More about words** | Kinds of nouns · More pronouns · Determiners and quantifiers · Adjective order, -ed and -ing · Kinds of adverbs and where they go · Kinds of verbs · Regular and irregular verbs · Phrasal verbs and objects |
| Foundation (A2–B1) | **Sentence building blocks** | Phrases and clauses · Main and dependent clauses · Four sentence structures · Four sentence purposes · Subject–verb agreement · Fragments and run-ons |
| Intermediate (B1–B2) | **The twelve tenses** | Past continuous · Present perfect continuous · Past perfect simple and continuous · Future continuous and future perfect · The tense map · Gerund or infinitive |
| Intermediate (B1–B2) | **Punctuation** | Capitals and end marks · Commas · Apostrophes · Colons, semicolons and dashes · Quotation marks and direct speech |
| Advanced (C1–C2) | **Voice and mood** | Have something done · Indicative, imperative, subjunctive · Mixed conditionals |
| Advanced (C1–C2) | **Common errors** | Its, your, their and friends · Affect, fewer, whom · Dangling modifiers · Parallel structure |

That makes the Grammarian 72 lessons. Content is original wording. Topic order follows the British Council–EAQUALS Core Inventory and the CEFR Companion Volume.

## Other coaches
An audit of syllabus gaps for the other nine coaches is in [coach-syllabus-audit.md](coach-syllabus-audit.md). Filling those gaps waits for the owner to choose which coaches matter most.

## Still waiting
- Art for the five new coaches. The owner generates it from [coach-art-prompts.md](../phase-7/coach-art-prompts.md).
- The "Talk about it" button on lessons. It needs Phase 9's Talk engine.

## Gate
`validate.py` passes, unit tests pass, the Grammarian screen in the simulator shows the new units, and the owner play-tests on the iPhone.
