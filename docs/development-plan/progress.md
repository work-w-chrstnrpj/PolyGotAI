# Progress tracker

> The basis for every progress report. Updated by Claude at the end of each working session. Status values: ✅ done · 🔄 in progress · ⏳ planned · ⏸ blocked · ❌ dropped. Last updated: 2026-10-25.

## Overall

| Phase | Goal | Status | Approved by owner |
| --- | --- | --- | --- |
| 0 | Declutter + setup | ✅ done: Today, Learn, Speech Lab and lesson screens decluttered; iPad navigation; tab order; one-line taglines | Not yet |
| 1 | Exercise engine + dictation button | ✅ done on iPad simulator; owner to play an A1 lesson and test dictation on a device | Not yet |
| 2 | Lesson restructure (Course + 10 coaches, level lock) | 🔄 built by Claude (API, content) and Codex (screens); Claude verifying ([phase 2](phases/phase-2/README.md)) | Not yet |
| 3 | Lexicon (Daily Lexicon, Daily Training, Lexicon in Action) | ✅ built and tested ([phase 3](phases/phase-3/README.md)); try it on your device | Not yet |
| 4 | Coach content (10 tracks) + A2–C2 fixes | ⏳ planned | — |
| 5 | Speech Lab additions (Phonetics, Articulation, Dictation, Voice) | ⏳ planned | — |
| 6 | Online AI (coach review, Specialized Lexicon) | ⏳ later | — |

## Blockers and decisions

| Item | Status |
| --- | --- |
| Codex has no usage right now | ⏸ Claude has done the Codex-lane work for Phases 0 and 1. Phases 2–5 screens will wait for Codex or be done by Claude |
| Dictation can't be checked on the simulator | The permission prompt and recognition don't show there. Please try the mic button on your iPhone or iPad and tell me what happens |
| One UI test fails on the iPhone 18 Pro Max simulator | `testA1PreviewResumesV2AndExplicitlyStartsV3`: the recording stop button never appears, so it looks like a microphone/simulator issue. Not yet confirmed on iPhone 18 Pro, where these tests passed before |
| Open decisions (coach levels, on-device speech, new characters, rewards on Today) | Recommendations in the [development plan](development-plan.md#open-decisions); owner has not yet answered |

## Phase 0 — Declutter + build setup

| # | Task | Lane | Status | Notes |
| --- | --- | --- | --- | --- |
| 0.1 | Archive v1 docs, remove Grok files, rewrite docs for v2 | Claude | ✅ | `docs/history/v1/`; Grok files in Trash |
| 0.2 | Write `history-version.md` | Claude | ✅ | |
| 0.3 | Lane split and parallel-work rules | Claude | ✅ | In the development plan |
| 0.4 | Convert Xcode project to folder-synchronized groups | Claude | ✅ | Builds; bundle has all 57 audio clips, 3 JSON files, asset catalog, award masters; 283/283 unit tests pass. New files under the source folders no longer need registering. Backup: `application/.build/backup/` |
| 0.5 | Remove disclaimer and "unavailable" copy; hide unfinished features | Claude (Codex has no usage) | ✅ | ~27 disclaimer lines deleted; Word of the Day, Generated practice and topic suggestions removed from navigation (code kept). Verified: 312/312 unit tests; 6 targeted UI tests pass on iPhone 18 Pro Max |
| 0.6 | Simplify Today to one continue card | Claude | ✅ screenshot-verified | Date, one-line tagline, one "Up next" card, review row when words are due, rewards summary |
| 0.7 | **iPad navigation:** bottom tab bar in portrait, sidebar in landscape | Claude | ✅ simulator-verified; owner to check on the real iPad | iPad (A16) simulator: portrait bottom bar, landscape sidebar, lesson stays open through two rotations; iPhone unchanged |
| 0.8 | Tab order Today \| Lexicon \| Lesson \| Speech Lab \| Progress; rename Vocabulary → Lexicon and Learn → Lesson | Claude | ✅ built; UI tests updated | |
| 0.9 | Taglines on one line | Claude | ✅ | Today, Speech Lab, lesson, resources, Lexicon headers |
| 0.10 | Speech Lab keeps Introduction, Conversation, Interview, Communication | Claude | ✅ | Already the case on screen; new modes arrive in Phase 5 |

**0.7 — iPad navigation.** `AppShell.swift` picks the sidebar whenever the horizontal size class is regular, which includes iPad portrait. Required: iPad **portrait** uses the same bottom tab bar as iPhone (Today, Learn, Vocabulary, Speech Lab, Progress); iPad **landscape** uses the sidebar. Use the view's width versus height (for example `GeometryReader` or `horizontalSizeClass` plus window size), not the size class alone. Keep the current tab selection and navigation state when the iPad rotates. Existing sheets (recording, settings) are anchored on a stable root so rotation doesn't dismiss them; keep that. Acceptance: rotate an iPad (A16) simulator with each tab selected and with a lesson open; no tab change, no dismissed sheet, tab bar in portrait, sidebar in landscape. Accessibility identifiers `navigation.*` stay for the sidebar; the tab bar keeps its labels.

## Phase 1 — Exercise engine

| # | Task | Lane | Status |
| --- | --- | --- | --- |
| 1.1 | `AnswerChecker` (normalize, contractions, almost, word diff) + tests | Claude | ✅ |
| 1.2 | Catalog fields (`exercise` object on activities; `tip`, `trackId`, `unitId`, `sources` on lessons) + loader checks | Claude | ✅ |
| 1.3 | `ExerciseSpec` + `ExerciseSession` (queue, re-queue wrong items, accuracy) + tests | Claude | ✅ 312/312 unit tests pass (29 new) |
| 1.4 | `SpeechSynthesizer` wrapper (TTS) | Claude | ✅ builds; no screen uses it yet, so not yet tested by ear |
| 1.5 | `tools/curriculum/validate.py` | Claude | ✅ runs clean on the current catalog |
| 1.6 | Convert the 12 A1 topic lessons to typed exercises (content v4; v3 archived so saved work reopens) | Claude | ✅ 168 typed exercises (14 per lesson: multiple choice, true/false, listen-and-write, sentence building, fill-in-the-blank with word tiles, typed words), a coach tip per lesson, `tools/curriculum/convert_a1_v4.py`, `validate.py` clean. INTRO-01 left as is |
| 1.7 | Exercise views: choice, word bank, fill blank, match, order, listen & type | Claude (Codex has no usage) | ✅ `Features/Learn/Exercises/`; spot error and speak use the typed-answer field for now |
| 1.8 | Feedback bar, coach tip screen, accuracy on the finish screen, "try the ones you missed"; integrated into `LessonPlayerView` | Claude | ✅ |
| 1.9 | UI test for typed exercises (tip, right, wrong, tiles) | Claude | ✅ `testTypedExercisesGiveInstantFeedbackAndAccuracy`; match, order and listen-and-type have unit tests only |
| 1.10 | `DictationRecognizer` (on-device speech-to-text) and `DictationButton` component | Claude | ✅ built; fixed a crash found on the simulator; **real dictation not yet verified, needs a device** |
| 1.12 | XP and gold for typed lessons (reward targets for v4, answer counts as reviewed, "+10 XP · +2 gold" in the feedback bar) | Claude | ✅ fixed a gap: v4 lessons earned nothing at first |
| 1.13 | Banner to switch from an old saved lesson version; reading passage shown apart from its question; fill-in-the-blank shows the sentence with a blank | Claude | ✅ |
| 1.11 | Add the microphone button to every typing field | Claude (existing fields) / Codex (new exercise fields) | ✅ existing fields done: lesson answers, intro practice, recall, Conversation, Interview, Communication, self-review, Lexicon word and meaning. ⏳ new exercise fields (Codex) |

## Phase 2 — Lesson restructure

| # | Task | Lane | Status |
| --- | --- | --- | --- |
| 2.1 | Track catalog model and loader (`TrackCoach`, `TrackCatalog`, `install.tracks`) | Claude | ✅ 331/331 unit tests |
| 2.2 | Grammarian Units 1–2 content (Starter stage: 8 lessons, 104 activities, XP targets registered; `build_grammarian.py`) | Claude | ✅ validate.py clean |
| 2.3 | Lesson tab = Course \| Coaches; flat coach grid (only coaches with lessons) + Continue card; coach screen with stage chips and unit cards; unit lesson list. Design: [coach-tracks.md](../product-specification/coach-tracks.md#how-coaches-are-presented-owner-approved-2026-10-25) | Codex | ✅ built; 4 of 5 UI tests pass on iPhone (re-verifying) |
| 2.4 | **Level lock (owner rule, 2026-10-25):** `LevelGate` (unlocked levels, finish-level unlock, jump test needs a perfect score) + tests | Claude | ✅ |
| 2.5 | A1 → A2 jump test: question builder from A1 typed exercises, perfect-score check (later levels' tests come with Phase 4) | Claude | ✅ |
| 2.6 | Locked level picker (lock icon, "Take the A2 test") and jump-test screen; UI test that C2 cannot be opened from A1 | Codex | ✅ built; failed test + retry + relaunch lock verified; perfect-pass path unit-tested only |

## Phase 3 — Lexicon

| # | Task | Lane | Status |
| --- | --- | --- | --- |
| 3.1 | Lexicon bank model, loader, validator (`Resources/Lexicon/lexicon-*.json`, `LexiconBankLoader`, `validate.py`) | Claude | ✅ |
| 3.2 | Duplicate check (lemma + part of speech, normalized) | Claude | ✅ |
| 3.3 | Word stages from FSRS state and last rating; Easy list | Claude | ✅ |
| 3.4 | Lexicon in Action question builder (fill the blank, choose the sentence) + tests | Claude | ✅ |
| 3.5 | Daily Lexicon pick (word of the day) | Claude | ✅ |
| 3.6 | First predefined groups: 3 groups × 40 words (Everyday A1, Work and office, Academic basics), original meanings, examples and wrong-usage sentences; `build_lexicon.py` | Claude | ✅ wrong-usage sentences need an editorial read |
| 3.7 | Lexicon tab screens: groups, Daily Training, Lexicon in Action; add-word with duplicate message | Claude (Codex is on Phase 2) | ✅ Lexicon home, Daily Training, Lexicon in Action, add-word with duplicate message; simulator-checked |
| 3.8 | Daily Lexicon card on Today | Claude | ✅ simulator-checked |
| 3.9 | Specialized Lexicon Training (AI field generation) | Claude + Codex | ⏳ Phase 6 |

## Phase 4 — Coach content

| Coach | Units authored | Status |
| --- | --- | --- |
| Grammarian | 0 / 2 | ⏳ (Phase 2) |
| Reading & Listening | 0 / 2 | ⏳ |
| Debater & Argument | 0 / 2 | ⏳ |
| Persuasion & Negotiation | 0 / 2 | ⏳ |
| Public Speaking & Rhetoric | 0 / 2 | ⏳ |
| Journalist | 0 / 2 | ⏳ |
| Creative Writing | 0 / 2 | ⏳ |
| Business & Professional | 0 / 2 | ⏳ |
| Storytelling | 0 / 2 | ⏳ |
| Advertising & Copywriting | 0 / 2 | ⏳ |
| CEFR course A2–C2 fixes and typed exercises | 0 / 43 lessons | ⏳ |
| Jump tests A2 → B1, B1 → B2, B2 → C1, C1 → C2 (one per converted level) | 0 / 4 | ⏳ |

## Phase 5 — Speech Lab additions

| # | Task | Lane | Status |
| --- | --- | --- | --- |
| 5.1 | On-device recognizer, `VoiceMetrics`, word diff | Claude | ⏳ |
| 5.2 | Content data: sounds, minimal pairs, dictation sentences, passages, twisters | Claude | ⏳ |
| 5.3 | Phonetics, Articulation, Dictation, Voice screens (Conversation, Interview, Communication stay) | Codex | ⏳ |

## Phase 6 — Online AI

| # | Task | Lane | Status |
| --- | --- | --- | --- |
| 6.1 | Per-coach review of "Your turn" tasks | Claude + Codex | ⏳ later |
| 6.2 | Specialized Lexicon Training: generate field vocabulary | Claude + Codex | ⏳ later |

## Session log

| Date | What happened |
| --- | --- |
| 2026-10-25 (iPad install) | Shared agent log `Claude-Codex-Cursor-conversation.md` created (rules, templates, open handoffs); current build installed and launched on the owner's physical iPad for play-testing |
| 2026-10-25 (Phase 1 built) | A1 lessons converted to content v4 (12 lessons, 144 typed exercises, coach tips; v3 archived); exercise screens built by Claude (Codex has no usage); dictation button on all typing fields; 315 unit tests and 5 UI tests pass |
| 2026-10-25 (Phase 0 finished) | Declutter done by Claude (Codex out of usage): Today = one card; Learn, Speech Lab, lesson player and ~27 disclaimers cleaned; Word of the Day, Generated practice, topic suggestions hidden; 6 obsolete UI tests removed; targeted UI tests pass. Owner added the Lexicon direction, tab order, one-line taglines and dictation button: docs updated, tab order and taglines done |
| 2026-10-25 (later) | Project converted to folder-synchronized groups (283 tests pass); Phase 1 domain layer written and tested (312 tests pass); validate.py added; iPad bottom bar (portrait) and sidebar (landscape) built and checked on the iPad simulator; Phase 1 Codex handoff written |
| 2026-10-25 | Audit of v1; v2 direction set; docs rewritten and v1 archived; Grok files removed; plan and tracker created; project file converted to folder-synchronized groups (build check in progress) |
