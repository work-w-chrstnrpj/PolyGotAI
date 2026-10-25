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
