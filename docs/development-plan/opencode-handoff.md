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
