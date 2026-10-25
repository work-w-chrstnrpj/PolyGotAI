# OpenCode handoff — proofreading (read-only)

OpenCode runs on a free tier, so it gets **small, low-risk, report-only jobs**. It never edits product files.

Read first: [AGENTS.md](../../AGENTS.md). Reviewer: Claude.

## Rules

- **Write only report files** under `docs/reviews/` (create the folder if missing), one file per job, named `opencode-<job>-<YYYY-MM-DD>.md`.
- **Never edit** Swift, JSON, Python, the Xcode project, `AGENTS.md` or any doc outside `docs/reviews/`. Never commit or push. Never run `xcodebuild` or any simulator command.
- Work in small batches: one file at a time, about 40 items per batch. If you run out of budget, stop and say where you stopped.
- Report format: a table with `file | id | field | problem | suggested fix`. Quote the exact text. No rewriting of whole lessons. Don't invent problems; if a file is clean, say so.
- Do not append to `Claude-Codex-Cursor-conversation.md`; Claude logs your reports.

## Job 1 — Proofread lesson and word content

Files: `application/SpeechCoachAI/Resources/Tracks/track-*.json` (coach lessons) and `application/SpeechCoachAI/Resources/Lexicon/lexicon-*.json` (word bank). Claude will tell you which files are new.

Check each learner-facing text (`tip`, `prompt`, `options`, `accepted`, `answer`, `explanation`, `meaning`, `examples`, `wrong`):
1. Typos, grammar, punctuation, and **American** spelling (color, organize).
2. A multiple-choice question where **two options are correct**, or the accepted answer is not right.
3. Accepted answers that miss an obvious correct variant (for example a missing contraction form).
4. Prompts that are unclear or leave out what to do.
5. Inconsistent quotation marks or apostrophes (the content uses curly quotes in tips).
6. In Lexicon `wrong` sentences: a sentence that is actually correct English with that word.

Run `python3 tools/curriculum/validate.py` first to confirm structure; paste its last line at the top of your report. Do not fix validation problems yourself; list them.

## Job 2 — Doc sweep (only when Job 1 is done)

Over `docs/**/*.md` **except** `docs/history/`:
1. Stale names: "Vocabulary tab", "Learn tab" (the tabs are now Lexicon and Lesson), "Word of the Day" (now Daily Lexicon), "seven specialized trainers".
2. Broken relative links (target file does not exist).
3. Statements that say "nothing is locked" about the CEFR course (now levels are locked; coaches are not).

Report each hit with file, line and the suggested wording. Do not edit.

---

## Round 2 (2026-10-25) — three more report-only jobs

Same rules as above (report files only, American spelling, small batches, quote exact text, say where you stopped). Run `python3 tools/curriculum/validate.py` first and paste its last line at the top of each report. Do the jobs in order.

## Job 3 — Proofread the Lexicon 2 word bank

Files: `application/SpeechCoachAI/Resources/Lexicon/lexicon-01-*.json` to `lexicon-18-*.json` (722 words, 18 groups, three per CEFR level). One batch per three files.

Check each word:
1. `meaning`: accurate, plain, at most 140 characters, no circular definition (the word inside its own meaning).
2. `examples`: natural English; the `{marked}` form is the word in a correct form; the sentence suits the group's CEFR level (A1 sentences use simple words).
3. `wrong`: each sentence must actually be wrong or nonsensical *for that word*. Flag any that is correct English. Words new in Lexicon 2 have one wrong sentence; flag the ones that are weak (too obvious, or only wrong by accident of grammar).
4. `cefr` equals the group's level. Flag words that look clearly too easy or too hard for the level.
5. `register` fits the word: everyday, formal, term, jargon, slang, informal, literary. Flag clear mismatches.
6. Typos, British spelling, and words that appear twice with the same meaning.

Output: `docs/reviews/opencode-lexicon2-<date>.md`.

## Job 4 — Proofread the A2–C2 course lessons

Files: `application/SpeechCoachAI/Resources/Curriculum/CurriculumCatalog.json`, lessons with `contentVersion` "3" (levels A2 to C2, 44 lessons). Use the same checks as Job 1 (items 1 to 6) and also:
- Any `choice` item with two defensible answers, or with an answer that can be found by matching one word with no reading.
- Any `fillBlank` or `listenType` item whose accepted list misses a common correct variant (contractions, American spelling).
- A `tip` that teaches something wrong or that the exercises do not use.

Output: `docs/reviews/opencode-course-a2c2-<date>.md`.

## Job 5 — Check the docs against the code

Compare these claims with the source files and list every mismatch with file, line, what the doc says and what the code does (do not guess; open the code):
- `docs/product-specification/lexicon.md` (group count, word count, ids, stages, wait days, daily limits) against `Domain/Lexicon.swift`, `Domain/LexiconPractice.swift`, `Resources/Lexicon/`.
- `docs/product-specification/speech-lab.md` against `Features/SpeechLab/` and `Domain/SpeechLab*.swift` (entries on the Lab home, what is stored).
- `docs/product-specification/product-specification.md` course rules (level lock, tests, question counts) against `Domain/LevelGate.swift` and `Domain/JumpTest.swift`.

Output: `docs/reviews/opencode-doc-code-check-<date>.md`.

---

## Round 3 (2026-10-25) — four more report-only jobs

Same rules as above. Run `python3 tools/curriculum/validate.py` first and paste its last line at the top of each report. Do the jobs in order; stop and say where you stopped if you run out of budget.

## Job 6 — Proofread the 13 A1 lessons

Files: `application/SpeechCoachAI/Resources/Curriculum/CurriculumCatalog.json`, lessons with `level` "A1" and `contentVersion` "4" (`a1-*` and `intro-01`). Same checks as Job 4 (including: two defensible answers, answers findable by matching one word, accepted lists missing common variants, tips that teach something the exercises do not use, American spelling, apostrophe style). Output: `docs/reviews/opencode-course-a1-<date>.md`.

## Job 7 — Proofread the Speech Lab content

Files: `application/SpeechCoachAI/Resources/SpeechLab/speechlab-*.json` (dictation sentences, minimal pairs, tongue twisters, passages, sound chart). Check: typos and American spelling; minimal pairs that are not actually a minimal pair; IPA that does not match the example words; example words that do not contain the sound; tongue twisters with grammar errors; dictation sentences whose numbers, dates or names are ambiguous when spoken aloud; passages whose length does not match the stated level. Output: `docs/reviews/opencode-speechlab-<date>.md`.

## Job 8 — Give-away audit across all lessons

Files: `Resources/Tracks/track-*.json` and the A1–C2 lessons in `CurriculumCatalog.json`. Report counts and the worst offenders (id list) for each pattern: (1) the correct option is the longest of the options; (2) the correct option is the only one that shares a content word with the prompt or audio text; (3) True/False key balance per track and per level; (4) two options that differ only in capitalization or punctuation; (5) `fillBlank` items where `accepted` has exactly one entry and the answer is a function word. This is a data report: do not suggest rewrites except for the ten worst items per pattern. Output: `docs/reviews/opencode-giveaway-audit-<date>.md`.

## Job 9 — Regression check of the earlier findings

Re-read `docs/reviews/opencode-proofread-batches2-4-2026-10-25.md` and, for each row, check the current file text: write FIXED, STILL OPEN or CHANGED (with the current text) per row. Do the same for `opencode-docs-sweep-2026-10-25.md`. Claude applied most of the first and all of the second on 2026-10-25 (LOG-0037). Output: `docs/reviews/opencode-regression-<date>.md`.

---

## Round 4 (2026-10-25) — validation jobs while the close-out runs

Same rules as above (report files only under `docs/reviews/`, American spelling, small batches, exact quotes, say where you stopped). Run `python3 tools/curriculum/validate.py` first and paste its last line.

## Job 10 — Proofread new content as it lands (rolling)

Claude adds `intro-01` (typed), then Intermediate and Advanced stages to the ten `Resources/Tracks/track-*.json` files, two coaches at a time (the log says which). For each batch Claude names, run the Job 1 checks plus: two defensible answers, answers findable by one matching word, `accepted` lists missing obvious variants, tips that teach something the exercises do not use, and stage fit (Intermediate about B1–B2, Advanced about C1–C2: flag lessons that read too easy or too hard). One report per batch: `docs/reviews/opencode-stages-<coaches>-<date>.md`. Also proofread `intro-01` in `CurriculumCatalog.json` once.

## Job 11 — UI copy audit

Read `application/SpeechCoachAI/Features/**/*.swift` (strings only; do not edit). List: any visible text that says something is unavailable, not scored, not assessed, coming later or explains what the app cannot do; button labels longer than three words; more than one helper line under a title; inconsistent names for the same thing (Lesson/Learn, Lexicon/Vocabulary, Speaking/Voice, Pronunciation/Phonetics); error messages longer than one sentence. Output: `docs/reviews/opencode-ui-copy-<date>.md` with file, line, text, suggested fix.

## Job 12 — Check the tracker against the code

Open `docs/development-plan/progress.md` and `development-plan.md`. For each row marked done, find the file or test that proves it and list rows whose claim you cannot confirm, with what is missing. Output: `docs/reviews/opencode-tracker-check-<date>.md`.

## Job 13 — Test-gap list

For each type in `application/SpeechCoachAI/Domain/` list whether a test in `application/SpeechCoachAITests/` exercises it (name the test file), and list public functions with no test. Do not write tests. Output: `docs/reviews/opencode-test-gaps-<date>.md`, sorted by risk (answer checking, level gate, scoring, rewards, persistence first).

## Job 14 — Repeat the give-away audit and doc-code check after wave B

Run Jobs 8 and 5 again on the new content and docs once Claude logs "wave B content done". Outputs: `opencode-giveaway-audit-2-<date>.md`, `opencode-doc-code-check-2-<date>.md`.
