# Claude · Codex · Cursor — shared log

The single place where every coding agent records what it changed and talks to the others. It is both the **history** (what was done, when, by whom) and the **inbox** (handoffs between agents). The owner reads it too.

- Project rules: [AGENTS.md](AGENTS.md) · Plan and lanes: [development-plan](docs/development-plan/development-plan.md) · Tracker: [progress.md](docs/development-plan/progress.md)
- This file is append-only. Newest entries are at the **bottom**.

---

## Rules

1. **Start of a session:** read [AGENTS.md](AGENTS.md), the *Open handoffs* table below, and the last 5–10 entries.
2. **End of every change set** (and before you stop): append **one entry** at the bottom. A change set is one finished piece of work, not every file save.
3. **Never edit or delete an old entry.** To fix a mistake, append a `CORRECTION` entry with `Corrects: LOG-NNNN`. The only text you may edit in place is the *Open handoffs* table.
4. **Numbering:** the next number is the last number + 1, four digits (`LOG-0007`). If two agents append at the same moment, the later one renumbers its entry and says so.
5. **Time:** `YYYY-MM-DD HH:MM`, Asia/Manila. Get it with `TZ=Asia/Manila date '+%Y-%m-%d %H:%M'`.
6. **Who:** `Claude`, `Codex`, `Cursor` (add the model in brackets if you know it, e.g. `Cursor [Sonnet]`), or `Owner`.
7. **Keep it short and checkable.** Link to files and docs instead of pasting code. List the files you changed. Report test results as they were, including failures. Say what you did **not** verify. Never write secrets, keys or personal learner data.
8. **Stay in your lane.** Lanes and file ownership come from the development plan and the handoff. If you need a change in a file you don't own, write a `HANDOFF` or `QUESTION` instead of editing it.
9. **Update the tracker.** If your work changes a task's status, update [progress.md](docs/development-plan/progress.md) and say so in the entry.

### Entry types

| Type | Use it for |
| --- | --- |
| `CHANGE` | Code, content, config or doc changes you made |
| `HANDOFF` | Asking another agent to do something (see the template) |
| `HANDOFF-REPLY` | Your answer to a handoff, referencing its ID |
| `REVIEW` | You reviewed another agent's work: findings and verdict |
| `DECISION` | A decision (usually the owner's) that others must follow |
| `QUESTION` | You are blocked or unsure; name who should answer |
| `NOTE` | Context others should know that is not a change |
| `CORRECTION` | Fixes a wrong earlier entry |

### Handoffs

1. Add a `HANDOFF` entry and a row in **Open handoffs**.
2. The receiving agent starts by reading the entry, then does the work and appends a `HANDOFF-REPLY` that says `Replies to: LOG-NNNN`.
3. The sender (or reviewer) verifies, appends a `REVIEW` with `Closes: LOG-NNNN` if accepted, and moves the row from *Open* to *Closed* below. If it is not accepted, the handoff stays open with a new `HANDOFF` or `REVIEW` listing what is missing.
4. The owner pastes a handoff into the receiving agent's tool when that tool cannot read this file by itself.

---

## Entry template

Copy this, fill it in, and append it at the bottom. Delete lines that don't apply.

```markdown
### LOG-0000 · YYYY-MM-DD HH:MM · Agent · CHANGE
**Phase:** N · **Status:** DONE | PARTIAL | BLOCKED
**Summary:** One to three lines: what changed and why.
**Files:** 
- `path/to/file` — what changed
**Verification:** command and result (for example "315 unit tests passed; 1 UI test failed: name"), or "not run".
**Not verified:** what you did not or could not check.
**For others:** decisions, gotchas, interfaces other agents should know.
**Open items:** what remains.
**Docs/tracker updated:** files, or "none".
```

## Handoff template

```markdown
### LOG-0000 · YYYY-MM-DD HH:MM · From → To · HANDOFF
**Status:** OPEN
**Goal:** One sentence.
**Plan link:** phase and task numbers in progress.md.
**You own (may edit):** files or folders.
**Do not touch:** files or folders.
**Use these interfaces:** types and functions already written, with file paths.
**Acceptance:**
1. Checkable condition
2. Checkable condition
**Verify:** exact command, for example `bash tools/native/verify.sh 7535AD2C-F655-4F05-8C36-FE5E0A614902`.
**Reply with:** a `HANDOFF-REPLY` entry (`Replies to: LOG-0000`): files changed, test result, screenshots in `docs/development-plan/phases/phase-N/evidence/`, and any questions.
```

---

## Open handoffs

| ID | From → To | Goal | Opened | Next step |
| --- | --- | --- | --- | --- |
| — | — | none open | — | — |

## Closed handoffs

| ID | From → To | Goal | Closed by |
| --- | --- | --- | --- |
| — | — | none yet | — |

---

## Log

### LOG-0001 · 2026-10-25 · Claude · NOTE
**Phase:** — · **Status:** DONE
**Summary:** Direction reset to **v2** after the owner's review and Claude's audit. Learn becomes the CEFR course plus 10 coach tracks, Speech Lab gets sound-and-voice modes, the UI stops explaining the app, lessons get auto-checked exercises. Grok is no longer on the project (subscription ended). v1 tickets, evidence and specs moved to `docs/history/v1/`. Grok handoffs and drafts were moved to the macOS Trash.
**Files:** `docs/history-version.md` (new), `docs/development-plan/development-plan.md`, `docs/development-plan/progress.md`, `docs/product-specification/*` (rewritten or noted), `docs/tdd/tdd.md`, `AGENTS.md`, `README.md`.
**Verification:** documentation only; all relative links in current docs checked.
**For others:** Read [history-version.md](docs/history-version.md) first. Ticket IDs (SC-Txxx, SC-Dxxx) are history; the tracker is `progress.md` with task numbers like `1.7`. Claude is senior engineer and reviewer; Codex implements; Cursor is available as an additional implementer if the owner assigns it.
**Open items:** none.
**Docs/tracker updated:** the files above.

### LOG-0002 · 2026-10-25 · Claude · CHANGE
**Phase:** 0 · **Status:** DONE
**Summary:** Phase 0 (declutter and setup), done by Claude because Codex had no usage. Xcode project converted to folder-synchronized groups (new files under the source folders need no registration). Today is one "Up next" card. Learn, Speech Lab and lesson screens lost their disclaimer text; Word of the Day, Generated practice and topic suggestions are hidden from navigation (code kept). iPad uses a bottom tab bar in portrait and a sidebar in landscape. Tab order is Today | Lexicon | Lesson | Speech Lab | Progress. Taglines are one line.
**Files:**
- `application/SpeechCoachAI.xcodeproj/project.pbxproj` — folder-synchronized groups (backup in `application/.build/backup/`)
- `application/SpeechCoachAI/Features/Navigation/AppShell.swift` — Today, Lesson list, Speech Lab, iPad navigation, tab order and names
- `application/SpeechCoachAI/Features/Learn/LessonPlayerView.swift` and ~12 other `Features/**` files — disclaimer copy removed
- `application/SpeechCoachAIUITests/BootstrapLaunchTests.swift` — 6 obsolete tests removed; tab names updated
**Verification:** 313 unit tests passed; UI tests passed: launch/all destinations, larger text, contrast, dark appearance, recording entry, connected lesson flow, personal vocabulary.
**Not verified:** one older UI test (`testA1PreviewResumesV2AndExplicitlyStartsV3`) failed on the iPhone 18 Pro Max simulator at the microphone step before this work; not rerun.
**For others:** UI rule: a screen never explains what the app can't do; taglines on one line; one short helper line at most. Accessibility identifiers `navigation.*` and `today.lesson` still exist.
**Open items:** owner approval of Phase 0 was given.
**Docs/tracker updated:** `progress.md`, `development-plan.md`, `phases/phase-0/`.

### LOG-0003 · 2026-10-25 · Claude · DECISION
**Phase:** 1–6 · **Status:** DONE
**Summary:** Owner direction recorded: Vocabulary tab becomes **Lexicon** with four modes (Daily Lexicon on Today, Daily Training with spaced repetition and no duplicate words, Lexicon in Action for words rated Easy, Specialized Lexicon via AI). Speech Lab **keeps** Conversation, Interview and Communication and adds Phonetics, Articulation, Dictation, Voice. Every typing field gets an on-device dictation button. Phases renumbered: Lexicon is Phase 3, Coach content 4, Speech Lab additions 5, Online AI 6.
**Files:** `docs/product-specification/lexicon.md` (new), `speech-lab.md`, `coach-tracks.md`, `product-specification.md`, `docs/tdd/tdd.md`, `docs/development-plan/*`.
**Verification:** documentation only.
**For others:** Lexicon bank format and rules are in `docs/tdd/tdd.md` under "Lexicon (Phase 3)". Dictation component API is in the TDD "Dictation input" section.
**Open items:** word-list licences must be checked before any list is bundled.
**Docs/tracker updated:** yes.

### LOG-0004 · 2026-10-25 · Claude · CHANGE
**Phase:** 1 · **Status:** DONE
**Summary:** Exercise engine and A1 conversion. `AnswerChecker`, `ExerciseSpec`, `ExerciseSession`, stored-text form so accuracy survives restarts. The 12 A1 topic lessons are content **v4** with a coach tip and 144 typed exercises; exact v3 archived. New exercise screens (choice, word bank, fill blank, match, order, listen-and-type), feedback bar, accuracy and "try the ones you missed". `DictationRecognizer` and `DictationButton` on all existing typing fields. Fixed a crash in the dictation permission callback found on the iPad simulator.
**Files:**
- `application/SpeechCoachAI/Domain/AnswerChecker.swift`, `Exercise.swift`, `CurriculumCatalog.swift` — engine and catalog fields (`exercise`, `tip`, `trackId`, `unitId`, `sources`)
- `application/SpeechCoachAI/Features/Learn/Exercises/*` — exercise views, flow layout, missed practice
- `application/SpeechCoachAI/Features/Learn/LessonPlayerView.swift` — runs the exercise flow when the current activity has a checked exercise
- `application/SpeechCoachAI/Infrastructure/Speech/DictationRecognizer.swift`, `SpeechSynthesizer.swift`; `Features/Shared/DictationButton.swift`
- `application/SpeechCoachAI/Resources/Curriculum/CurriculumCatalog.json` — A1 lessons to v4, v3 archived (backup `application/.build/backup/CurriculumCatalog.v3.json`)
- `tools/curriculum/validate.py`, `convert_a1_v4.py`
- `application/SpeechCoachAITests/*` — `AnswerCheckerTests`, `ExerciseTests`, catalog tests updated for v4; Info.plist test updated for the speech permission
**Verification:** 315 unit tests passed; UI tests passed: typed exercises (new), connected lesson flow, launch/all destinations, focused lesson accessibility. `python3 tools/curriculum/validate.py` passes.
**Not verified:** real dictation (the simulator never shows the permission prompt); the A1 lessons on a real device; listening-clip answers were written from the lesson text and not by ear.
**For others:** Choice answers match exactly (case and punctuation count). Typed answers ignore case, punctuation and contractions and allow small spelling slips ("almost"). Do not rename existing stored enum cases. New content must pass `validate.py` and ship as a new content version with the old one archived.
**Open items:** spot-the-error and speak exercises use a typed field; A2–C2 lessons are still the old type-and-compare format.
**Docs/tracker updated:** `progress.md`, `phases/phase-1/README.md`, `tdd.md`, `data-model.md`.

### LOG-0005 · 2026-10-25 11:16 · Claude · CHANGE
**Phase:** 1 · **Status:** DONE
**Summary:** Created this shared log (`Claude-Codex-Cursor-conversation.md`) with rules, entry and handoff templates, and an open-handoffs table; linked it from `AGENTS.md`, `docs/README.md` and the development plan. Built the current app with the owner's existing Apple Development signing and **installed and launched it on the owner's physical iPad ("iPad ni Paj", iPad (A16))** for play-testing. The install replaces the app in place, so existing learner data stays.
**Files:**
- `Claude-Codex-Cursor-conversation.md` — new
- `AGENTS.md`, `docs/README.md`, `docs/development-plan/development-plan.md` — link to the log and the append rule
**Verification:** device build succeeded (`xcodebuild build`, destination `platform=iOS,id=00008120-0014354C112B601E`, derived data `application/.build/DeviceDerivedData2`, `CODE_SIGN_STYLE=Automatic DEVELOPMENT_TEAM=LMHJKZ2N43 CODE_SIGN_IDENTITY='Apple Development'`); `xcrun devicectl device install app` and `process launch` both reported success.
**Not verified:** what the app does on the iPad (nobody has used it there yet): A1 typed lessons, dictation permission and recognition, iPad portrait/landscape navigation.
**For others:** to reinstall: build with the command above, then `xcrun devicectl device install app --device 00008120-0014354C112B601E <path>/SpeechCoachAI.app` and `xcrun devicectl device process launch --device 00008120-0014354C112B601E com.personal.SpeechCoachAI`. Keep the iPad unlocked. The development profile expires 2026-10-28 (per the v1 deployment notes). Never delete the app or reset learner data to "fix" something.
**Open items:** owner play-test of Phase 1 on the iPad; owner approval of Phase 1.
**Docs/tracker updated:** `progress.md` session log.

### LOG-0006 · 2026-10-25 11:21 · Claude · CHANGE
**Phase:** — · **Status:** DONE
**Summary:** At the owner's request, created the Git repository and pushed the project to **https://github.com/work-w-chrstnrpj/PolyGotAI** (branch `main`). The repo was empty and is **public**. Initial commit `a13b284` has 1,375 files (about 189 MB). Excluded via `.gitignore`: `application/.build/` (7.6 GB), the root `.build/`, the stray empty `Untitled/` folder (it contained its own `.git`), `.DS_Store`, Xcode user data.
**Files:** `.gitignore` (added `/.build/`, `Untitled/`); `AGENTS.md` and `docs/development-plan/development-plan.md` (Git rules replaced: repo exists, commit/push only when the owner asks).
**Verification:** checked before pushing: no files over 20 MB, no private keys, provisioning files, `.env` files or key-like strings; no real email addresses in files. `gh repo view` confirms `main` and the push time.
**Not verified:** nothing built from a fresh clone.
**For others:** files in the public repo contain the owner's Mac username in local paths (`/Users/chrixcrusher/...`, in docs and a few config files), the Apple team ID `LMHJKZ2N43`, and device and simulator UDIDs in docs and evidence. Treat the repo as public: never commit credentials, learner data, recordings or provider keys. Do not commit or push unless the owner asks. The vendored FSRS library (`application/Vendor/swift-fsrs`) is MIT-licensed, and the third-party skills under `.agents/skills/` keep their upstream licence files.
**Open items:** owner may want to make the repo private, or scrub local paths and UDIDs.
**Docs/tracker updated:** `AGENTS.md`, `development-plan.md`.
