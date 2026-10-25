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
| LOG-0012 | Claude → Codex | Phase 2 screens: Course \| Coaches, coach grid, locked level picker, jump-test screen | 2026-10-25 | **Awaiting Claude review (LOG-0017).** Implementation handed back; full verification incomplete; see evidence and LOG-0016 |

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

### LOG-0007 · 2026-10-25 11:22 · Owner (recorded by Claude) · DECISION
**Phase:** — · **Status:** DONE
**Summary:** The owner decided to keep https://github.com/work-w-chrstnrpj/PolyGotAI **public**. No scrubbing of local paths, team ID or device IDs was requested.
**For others:** treat everything committed as public. Do not commit credentials, provider keys, learner data or recordings. Commit and push only when the owner asks.
**Open items:** none.

### LOG-0008 · 2026-10-25 11:39 · Claude · CHANGE
**Phase:** 1 · **Status:** DONE
**Summary:** Fixes after the owner tried the iPad. (1) The owner saw the **old** lesson screens ("Read this…" on one line, "Save my answer", no feedback): those were unfinished version-3 lessons, which reopen as they were. Added a banner "A new version of this lesson is ready → Switch to the new version" to old-version lesson screens. (2) **XP and gold were not awarded for v4 lessons** (they were missing from the rewards catalog's content targets, and typed answers were not marked as reviewed): fixed in `AwardCatalog.json` (+120 `@4` targets) and by revealing on submit; the feedback bar shows "+10 XP · +2 gold". (3) The reading passage now sits in its own card above the question. (4) More question variety: true/false and a listen-and-write per lesson (phone voice reads a short sentence), typed words for single-word recall, and fill-in-the-blank shown as a sentence with a blank and word tiles. A1 v4 now has 168 typed exercises (14 per lesson).
**Files:**
- `application/SpeechCoachAI/Features/Learn/Exercises/ExerciseActivityView.swift` — passage card, cloze view and tiles, reward line slot
- `application/SpeechCoachAI/Features/Learn/LessonPlayerView.swift` — view split into smaller parts, switch-version banner, reveal on submit
- `application/SpeechCoachAI/Features/Rewards/RewardCelebrationView.swift` — `RewardEarnedLine`
- `application/SpeechCoachAI/Resources/Rewards/AwardCatalog.json` — v4 content targets (file was re-serialized, so the diff is large)
- `application/SpeechCoachAI/Resources/Curriculum/CurriculumCatalog.json`, `tools/curriculum/convert_a1_v4.py` — regenerated from the v3 backup (`application/.build/backup/CurriculumCatalog.v3.json`)
- `application/SpeechCoachAITests/CurriculumCatalogTests.swift`, `application/SpeechCoachAIUITests/BootstrapLaunchTests.swift`
**Verification:** 315 unit tests passed; UI tests passed: typed exercises (now true/false, listen-and-write, fill-in-the-blank, tiles), connected lesson flow, launch/all destinations. Checked on the iPad simulator: switch banner, passage card, +XP line. Rebuilt, installed and launched on the owner's iPad.
**Not verified:** on the real iPad (owner play-test); listening-clip wording; dictation; the phone voice reading the listen-and-write sentence on a device.
**For others:** reward credit needs BOTH (a) `lessonID@version` in `AwardCatalog.json` `contentTargetIDs` of AW-P-01 and (b) `answerRevealed` on the response. Any new lesson version must add its targets or it earns nothing. Keep `LessonPlayerView.body` small: the Swift compiler times out on one large view expression.
**Open items:** a matching exercise and spot-the-error have no A1 content yet; A2–C2 lessons still use the old format; per-answer XP wording and amounts are the existing economy (first try that day 10 XP + 2 gold, a repeat half, then none).
**Docs/tracker updated:** `progress.md`, `phases/phase-1/README.md`.

### LOG-0009 · 2026-10-25 11:43 · Claude · CHANGE
**Phase:** 1 · **Status:** DONE
**Summary:** At the owner's request, committed and pushed LOG-0007 and LOG-0008's changes (switch-version banner, v4 rewards fix, reading passage card, true/false, listen-and-write, fill-in-the-blank tiles, A1 content regenerated) to https://github.com/work-w-chrstnrpj/PolyGotAI (`main`).
**Verification:** `git push` succeeded. Tests were run before the commit (315 unit tests and key UI tests passed).
**Not verified:** nothing built from a fresh clone.
**For others:** the repo is public; commit and push only when the owner asks.

### LOG-0010 · 2026-10-25 12:05 · Owner (recorded by Claude) · DECISION
**Phase:** 2 (and 4) · **Status:** DONE (docs only; no code yet)
**Summary:** The owner set a **level lock**: the learner cannot jump from A1 to C2. Levels unlock in order. To skip ahead, the learner takes a test for the next level only (A1 → A2, then A2 → B1, and so on) and needs a **perfect score**. This reverses the v1 rule "any level is freely selectable".
**Files:**
- `docs/product-specification/product-specification.md` — Course rules replaced
- `docs/product-specification/ui-ux-design.md` — v2 override for the level picker
- `docs/development-plan/development-plan.md` — Phase 2 and Phase 4 rows; new open decision 8 (details to confirm)
- `docs/development-plan/progress.md` — tasks 2.4–2.6 and a Phase 4 row for the later jump tests
- `docs/history-version.md` — direction addition
**For others:** Claude builds `LevelGate` and the A1 → A2 test (2.4, 2.5); Codex builds the locked level picker and test screen (2.6) once that API exists. Later tests come with each level's Phase 4 conversion. `ui-screen-state-inventory.md` ON-02 and `english-foundations.md` still say "no placement lock"; they are v1-era and were not edited.
**Open items:** owner to confirm decision 8 (finish-level unlock, retakes, existing opened levels, storage without a migration).
**Docs/tracker updated:** the files above.

### LOG-0011 · 2026-10-25 12:20 · Owner (recorded by Claude) · DECISION
**Phase:** 2 · **Status:** DONE (docs only; no code yet)
**Summary:** The owner approved how coaches are presented in the Lesson tab: a **Course | Coaches** switch; one **flat grid** of coach cards (artwork, name, one-line tagline, progress ring) with a Continue card; only coaches with lessons appear; coach screen with stage chips (Starter only for Grammarian and Reading & Listening) and unit cards; unit lesson list; the existing lesson player. **Coaches and stages are not locked** (the level lock applies to the CEFR course only). Open decision 1 (coach stages) is closed.
**Files:**
- `docs/product-specification/coach-tracks.md` — stages approved, lock note, new "How coaches are presented" section
- `docs/product-specification/ui-ux-design.md` — coaches override points to it
- `docs/development-plan/development-plan.md` — open decision 1 marked decided
- `docs/development-plan/progress.md` — task 2.3 describes the screens
**For others:** Codex builds task 2.3 from the coach-tracks.md section; the Phase 2 handoff file is not written yet.
**Open items:** owner to confirm open decision 8 (level lock details).
**Docs/tracker updated:** the files above.

### LOG-0012 · 2026-10-25 12:40 · Claude · HANDOFF
**Phase:** 2 · **Status:** PLAN written; not started
**Summary:** Wrote the Phase 2 brief and the Codex handoff. The owner confirmed open decision 8 (level lock details) as written. Codex builds the Course | Coaches switch, the flat coach grid with stage and unit screens, the locked level picker and the jump-test screen. Claude builds the API first (track catalog, `LevelGate`, A1 → A2 `JumpTest`) and the Grammarian Units 1–2 content.
**Files:**
- `docs/development-plan/phases/phase-2/README.md` — brief
- `docs/development-plan/phases/phase-2/codex-handoff.md` — handoff (API contract, changes, accessibility ids, UI tests)
- `docs/development-plan/development-plan.md`, `progress.md` — decision 8 confirmed; Phase 2 status
**For others:** Codex must **not start** until Claude appends a `HANDOFF-READY` entry with the final API. Phase 2 also needs the owner's approval to start. Codex currently has no usage; if that is still true, Claude does the screens.
**Open items:** owner approval of the Phase 2 brief.
**Docs/tracker updated:** the files above and the Open handoffs table.

### LOG-0013 · 2026-10-25 17:05 · Owner (recorded by Claude) · DECISION
**Phase:** 2 and 3 · **Status:** DONE
**Summary:** To deliver faster, the owner asked for two phases with separate scopes to run in parallel: **Codex builds the Phase 2 screens; Claude does all of Phase 3 (Lexicon)**, including its screens. This overrides "one phase at a time" for these two phases. Each keeps its own VERIFY and APPROVE.
**Files:** `AGENTS.md` (Don't-run-all-phases rule), `docs/development-plan/development-plan.md` (workflow note, Phase 3 row), `docs/development-plan/progress.md`, new `docs/development-plan/phases/phase-3/README.md`.
**For others:** `AppShell.swift` is split by region: Codex edits only `LearnContent` and `case .learn:`; Claude edits only `case .vocabulary:` and `TodayContent`. Read before every edit; small targeted edits only. Separate DerivedData and simulators per agent.
**Open items:** none.
**Docs/tracker updated:** the files above.

### LOG-0014 · 2026-10-25 17:08 · Claude · HANDOFF-READY
**Phase:** 2 · **Status:** DONE (Claude lane)
**Summary:** Claude's Phase 2 lane is built and tested, so Codex can start the screens in [codex-handoff.md](docs/development-plan/phases/phase-2/codex-handoff.md) (Replies to / unblocks: LOG-0012). Built: `LevelGate`, `JumpTest` (A1 → A2), `TrackCoach` and `TrackCatalog` (`install.tracks`), `LessonProgress`, `storage.levelGate(install:)` and `storage.recordJumpTestPass(level:)`, the Grammarian track (8 lessons, `Resources/Tracks/track-grammarian.json`).
**Files:**
- `Domain/LevelGate.swift`, `Domain/JumpTest.swift`, `Domain/TrackCatalog.swift` — new
- `Infrastructure/Curriculum/CurriculumCatalogLoader.swift` — loads `track-*.json`; `CurriculumInstall.tracks`
- `Infrastructure/Persistence/LearnerRepository.swift` — `passedJumpTests()`, `recordJumpTestPass`; new optional field in the learner document (added to its custom `CodingKeys`, no migration)
- `App/LearnerStorageController.swift` — `levelGate`, `recordJumpTestPass`
- `Resources/Tracks/track-grammarian.json`, `Resources/Rewards/AwardCatalog.json` (XP targets), `tools/curriculum/build_grammarian.py`, `tools/curriculum/validate.py`
- `SpeechCoachAITests/LevelGateTests.swift` — 16 new tests
**Verification:** 331 unit tests passed on the iPhone 18 Pro Max simulator (Claude's lane); `validate.py` clean.
**Not verified:** no screen uses any of this yet; UI tests not run; the A1 → A2 test has not been played on a device.
**For others:** the learner document has hand-written `CodingKeys`; a new stored field must be added to the enum, `init(from:)` and `encode(to:)` or it silently does not persist (caught by a test here). A lesson earns XP only when `lessonID@version` is in `AwardCatalog.json` (handled by `build_grammarian.py` for the Grammarian).
**Open items:** Codex screens (2.3, 2.6); the owner's approval of open decision 8 is recorded in the plan.
**Docs/tracker updated:** `progress.md`, `development-plan.md`, `codex-handoff.md`.

### LOG-0015 · 2026-10-25 16:30 · Codex · CHANGE
**Phase:** 2 · **Status:** PARTIAL (screens built; UI verification running)
**Summary:** Implemented LOG-0014's screen contract: Course | Coaches, gated course picker, coach grid → stage → unit → existing lesson player, Continue card, jump-test question/feedback/result/retry and perfect-pass save. Uses the approved kit and existing exercise views without changing their logic.
**Files:** `Features/Navigation/AppShell.swift` (LearnContent only); new `Features/Learn/CourseCatalogView.swift`, `CoachCatalogView.swift`, `JumpTestView.swift`; new `SpeechCoachAIUITests/Phase2LessonTests.swift` (five isolated-store tests).
**Verification:** iPhone 18 Pro `xcodebuild build-for-testing` passed. Focused Phase2LessonTests now running with Codex DerivedData; full verification and screenshots follow.
**For others:** Claude's Phase 3 regions and files are untouched. Docs remain Claude-owned per handoff; tracker tasks 2.3/2.6 can be marked in progress. Final HANDOFF-REPLY will report verification and doc impacts.

### LOG-0016 · 2026-10-25 16:42 · Codex · QUESTION
**Phase:** 2 · **Status:** OPEN for Claude review
**Summary:** The iPad (A16) large-text/Dark Mode accessibility audit flags the existing custom navigation label **Lexicon**: “Dynamic Type font sizes are partially unsupported” (`Phase2LessonTests.swift`, accessibility audit). The coach lesson/Continue flow passed; rotation check is running. This appears in `AppShell.bottomBar`, outside my assigned `LearnContent` region, so I have not edited it or suppressed the audit.
**Evidence:** `application/.build/phase2-ipad.log` lines 78–81; result bundle `application/.build/phase2-ipad.xcresult` (finishing). The isolated dark test now uses the existing `SC_REWARD_DARK_FIXTURE`; the first run's launch argument did not actually select Dark Mode, caught by screenshot review.
**For Claude:** please review/fix the custom iPad navigation label during integration. My remaining `AppShell.swift` edits stay inside LearnContent. Screenshots and final HANDOFF-REPLY follow.

### LOG-0017 · 2026-10-25 17:11 · Codex · HANDOFF-REPLY
**Phase:** 2 · **Status:** IMPLEMENTED; VERIFY incomplete · **Replies to:** LOG-0012, LOG-0014
**Summary:** Built tasks 2.3 and 2.6 from the approved handoff (plan-first execution): Course | Coaches session choice; gated course levels; ready-coach grid, progress and Continue; stage → unit → existing player; jump-test feedback/result/retry and perfect-pass persistence with save-error recovery. The result route stays registered when unlocking replaces the locked card. No lesson-player or exercise-logic changes.
**Files:** `Features/Navigation/AppShell.swift` (LearnContent only); new `Features/Learn/CourseCatalogView.swift`, `CoachCatalogView.swift`, `JumpTestView.swift`; new `SpeechCoachAIUITests/Phase2LessonTests.swift`; six screenshots and [verification summary](docs/development-plan/phases/phase-2/evidence/verification.md). Claude's Phase 3 regions/files were preserved. No commit or push.
**Verification:** Build-for-testing and diff checks passed. Earlier focused runs passed course gating, the complete failed jump test + Retry/relaunch lock, coach/player/Continue and iPhone/iPad mode/rotation. Latest serial iPhone run passed actual Dark Mode/accessibility and coach/Continue, then hit a five-minute launch timeout before Lesson; two remaining cases did not run. iPad: 2/3 passed; existing Lexicon navigation-label Dynamic Type finding remains (LOG-0016), unsuppressed. Required `verify.sh` ran: **349 unit tests and four existing UI tests passed**, Communication draft recovery failed waiting for `communication.answer`, then Interview stalled; run stopped (143), **not a full pass**. Prior result collection overlapped full-run startup and may have contributed; a later serial retry also stalled. Logs and the idle-main-thread sample are indexed in the evidence summary. Initial identifier/startup defects were fixed and retested.
**For Claude / doc impacts:** review the code, investigate LOG-0016 and runtime/Communication findings, finish clean serial verification, update tracker tasks 2.3/2.6 and navigation/TDD/test docs. Specs/tracker remain Claude-owned per the handoff. Device play-test, VoiceOver walkthrough and perfect-pass/save-failure UI paths are not verified. No phase approval claimed.

### LOG-0016 · 2026-10-25 17:20 · Claude · CHANGE
**Phase:** 3 · **Status:** DONE (waiting for the owner's try-out)
**Summary:** Built the Lexicon phase while Codex builds Phase 2. Lexicon tab (Daily Training, Lexicon in Action, groups, add-word with the duplicate message), the Daily Lexicon card on Today, a 120-word bank (3 groups × 40) and the domain behind them.
**Files:**
- `Domain/Lexicon.swift`, `Domain/LexiconPractice.swift`, `Infrastructure/Lexicon/LexiconBankLoader.swift` — bank, duplicate check, stages, daily word, training plan, Lexicon in Action builder
- `Infrastructure/Persistence/LearnerRepository.swift` — `lexicon` field of the learner document (in `CodingKeys`), `lexiconState`, `startLexiconWords`, `recordLexiconAction`, `lexiconStages`
- `Features/Vocabulary/LexiconHome.swift`, `LexiconTrainingView.swift`, `LexiconActionView.swift`, `LexiconAddWordView.swift`, `DailyLexiconCard.swift` — new
- `Features/Navigation/AppShell.swift` — only `case .vocabulary:` and one line in `TodayContent`
- `Resources/Lexicon/lexicon-*.json`, `tools/curriculum/build_lexicon.py`, `tools/curriculum/validate.py`
- `SpeechCoachAITests/LexiconTests.swift` (18), `SpeechCoachAIUITests/Phase3LexiconTests.swift` (4), `BootstrapLaunchTests.swift` (4 existing tests now open "Saved words and topics" first)
- Docs: `lexicon.md` (as built), `data-model.md`, `phases/phase-3/README.md` (+ evidence), `progress.md`
**Verification:** 349 unit tests passed; `Phase3LexiconTests` 4/4 and `testOfflineRecallDraftRevealAndRatingRecovery` passed on the iPhone 18 Pro Max simulator; walked Today and the Lexicon flow by hand there.
**Not verified:** `testReviewOptionsPersistAndLimitOneSession` (contrast audit on the old Review options screen) and `testConnectedLessonDraftResumeQuietCompletionAndVocabularyReview` (fails at `lesson.next` in the lesson flow) fail; neither was checked against the earlier commit. No real device, no iPad. Wrong-usage sentences need a native-speaker read.
**For others:** `AppShell.swift` changes in my regions are done. Do not put an `accessibilityIdentifier` on a container view: it overrides its children's identifiers (cost me a failing test). A custom `CodingKeys` on the learner document must list every new field.
**Open items:** owner try-out; triage of the two failing UI tests during VERIFY; Phase 2 integration.
**Docs/tracker updated:** `progress.md`, `lexicon.md`, `data-model.md`, `phases/phase-3/README.md`.

### LOG-0018 · 2026-10-25 17:50 · Claude · CORRECTION
**Phase:** 2 and 3 · **Status:** DONE · **Corrects:** numbering of two entries
**Summary:** Two entries were both numbered LOG-0016 (Codex's QUESTION at 16:42 and Claude's Phase 3 CHANGE at 17:20), because both agents appended at once. Rule 4 applies to the later one: the entry called "LOG-0016 · 17:20 · Claude · CHANGE" is **LOG-0016b** from here on. References to "LOG-0016" in Codex's HANDOFF-REPLY (LOG-0017) mean Codex's QUESTION about the Lexicon navigation label.
**For others:** before appending, re-read the last entry number; two agents are now writing to this file.
