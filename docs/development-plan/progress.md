# Progress tracker

> The basis for every progress report. Updated by Claude at the end of each working session. Status values: ✅ done · 🔄 in progress · ⏳ planned · ⏸ blocked · ❌ dropped. Last updated: 2026-11-01 (coach exam badge follow-up).

## Overall

| Phase | Goal | Status | Approved by owner |
| --- | --- | --- | --- |
| 0 | Declutter + setup | ✅ done: Today, Learn, Speech Lab and lesson screens decluttered; iPad navigation; tab order; one-line taglines | Not yet |
| 1 | Exercise engine + dictation button | ✅ done on iPad simulator; owner to play an A1 lesson and test dictation on a device | Not yet |
| 2 | Lesson restructure (Course + 10 coaches, level lock) | ✅ built and verified: Course | Coaches tabs, any-level lock with perfect-score tests for A2–C2 (390 unit tests; Phase 2 UI tests pass); owner to play-test ([phase 2](phases/phase-2/README.md)) | Not yet |
| 3 | Lexicon (Daily Lexicon, Daily Training, Lexicon in Action) | ✅ built and tested ([phase 3](phases/phase-3/README.md)); try it on your device | Not yet |
| 4 | Coach content (10 tracks) + A2–C2 conversion | ✅ all 10 coaches (80 lessons) and all 44 A2–C2 lessons written and proofread once by OpenCode; round-2 fixes to the A2–C2 lessons and True/False balance are next (see Round 3) | — |
| 5 | Lab on-device base: Dictation, Pronunciation (Phonetics + Articulation), Speaking (was Voice) | ✅ built by Codex, finished and merged by Claude after Codex's usage limit; 377 unit tests and 8 Speech Lab UI tests pass on iPhone 18 Pro Max; real-device audio and recognition not yet tried ([brief](phases/phase-5/README.md)) | Not yet |
| 5b | Interview v2 (offline hands-free voice) | 🔄 core done 2026-10-25 (turn-taking rules, 39-question bank in three sets, follow-up rule, session and summary; 14 unit tests); Interview screen is Codex's X5 | — |
| 6a–6d | Online AI with Alibaba/Qwen: foundation, AI evaluation across the Lab, voice Interview, coach review and Specialized Lexicon | 🔄 cores built and tested with a fake transport (2026-10-26): 6a transcription, feedback, stored results, owner-local switch-on; 6b per-mode requests, rubrics, history; 6c AI follow-ups for the Interview; 6d coach review and generated vocabulary with saving. Screens are Codex's X3 and X5. Stays off until the owner installs the verification file and runs the live check. Decision 9 still awaits the owner | — |
| 7 | Look and clean-up (rework) | ✅ done 2026-10-26, commit `d41aa00`: new Today and Progress, theme per background, "Rank", Erase all data (Face ID), v1 removed, copy audit, repository split. All eleven coaches now have portraits (six added 2026-11-01; owner visual review open) | ✅ 2026-10-26 |
| 8 | Lexicon v3 (Claude) | 🔄 built 2026-10-26: new Lexicon home, Training settings (ranks, packs, hide), Practice (word-in-sentence and synonyms), Anki-style review times, own packs with Train all and Fill with AI, Saved words list, synonyms for 700 words. 391 unit tests pass. Waiting: install on iPhone and owner play-test | Not yet |
| 9 | Lab v3: Talk and voice (Codex) | 🔄 implemented; 399 hosted tests pass, Phase 9 iPhone 4/4 and iPad 4/4 pass; full UI 42/52 pass, 10 Today/Lexicon/audit failures; review/device acceptance open ([evidence](phases/phase-9/evidence/README.md)) | Not yet |
| 11 | Lessons depth (Claude) | 🔄 built 2026-10-26: Grammarian 32 → 72 lessons (parts of speech, sentence structure, 12 tenses, punctuation, mood, common errors); other coaches audited, owner to choose additions; six missing portraits added 2026-11-01; owner visual review open | Not yet |
| 14 | Lexicon to about 2,400 words (Claude) | 🔄 built 2026-10-26: 1,510 new words in 37 new packs (A1 +280, A2 +280, B1 +240, B2 +200, C1 +240, C2 +270; 2,376 words in 55 rank packs and 5 field packs), each with meaning, example and a wrong-usage sentence; synonyms on 1,046 of the new words (1,746 in all). Older words and ids unchanged. Training settings show each rank's packs as a closed list. 411 unit tests and 5 Lexicon UI tests pass in a clean copy ([phase 14](phases/phase-14/README.md)). Waiting: native-speaker proofread, iPhone install, owner play-test | Not yet |
| 15 | Lab Videos and Timed tests (Claude) | 🔄 built 2026-10-26: Videos (26 checked links, Watched list) and Timed tests (impromptu writing with auto-send and AI feedback, timed reading, analogies; AI-written, no repeats, one retry). 17 unit and 4 UI tests pass. Waiting: owner play-test with a real key | Not yet |
| 16 | Play-test fixes 2026-10-30 (Claude) | 🔄 built: Lab = Talk, Timed tests, Videos, Voice as Kit cards (Speaking and Spelling removed); Videos 26 → 131 checked links from 45 channels in 14 topics, favorite channels sort first, a tap opens YouTube and counts as watched on return; one look across screens (Kit text fields, Kit buttons instead of system bordered ones, card-coloured list rows, shared chip style). 497 unit tests pass. Grammarian 25 → 46 lessons: 21 newly written topics (2 reading pages + 16 checked exercises each; tenses one by one, verb patterns, phrasal verbs, quantities, indirect and noun clauses, passive in every tense, clefts, ellipsis); the 25 existing lessons are unchanged. Round 2: Videos topic dropdown; Time in the app day view (hourly chart, longest visit, first opened, 7-day average, visits) and a date/range picker; badges v2 (83 families: 43 hidden, 4 legacy, P-05 renamed, Talk and course badges rewired, 15 new for coaches, Lexicon, videos and timed tests; worked out from stored data, never taken back). 439 unit tests pass. Round 3: date picker without a range; "Lesson" button re-opens the reading mid-exercise and "Back to exercise" returns; word of the day C1/C2 only; IPA on all 2,376 Lexicon words (+725 with antonyms); Daily Training repeats a word rated Again in the same sitting (Anki learn-ahead 20 min); Vocabulary Enricher (meaning → word, synonym, antonym, sentence; any pack word); badge/milestone celebration overlay with confetti; original background music, sound effects and haptics (Settings → Sound and haptics; music pauses while the app speaks, listens or records). 443 unit tests pass. Waiting: native-speaker proofread, owner play-test | Not yet |
| 17 | Premium UI polish (Claude, owner request 2026-11-01) | 🔄 built: card depth and press motion across the Kit, icon badges, gradient progress bars, Success/Warning/Streak colours, Today greeting + level medal + hero art, numbered lesson path with rank summary, gradient coach tiles, tab bar hidden in lessons, sliding feedback panel, accuracy ring, canvas launch screen. [Review](../reviews/claude-ui-premium-review-2026-11-01.md). Waiting: owner play-test, iPad check | Not yet |

## Artwork follow-up — 2026-11-01

Owner requested matching artwork for every missing badge and animal coach. Built and focused-verified: **17 badge PNGs** replace all remaining symbol-only collectible badges, and **six portraits** complete the eleven-coach grid (wolf, penguin, cat, hedgehog, magpie and robin). [Delivery, prompts and gallery](../../assets/artwork-v2-2026-11-01/README.md); [verification](../../assets/artwork-v2-2026-11-01/verification.json). All 86 award file/hash mappings pass; the generator is idempotent and preserves rules/tiers. iPhone 18 Pro simulator: **19 unit + 3 UI tests passed**, including dark/large-text screens. [Screenshots](phases/phase-7/evidence/artwork-2026-11-01/). Installed and launched on the owner’s iPhone 15 Plus on 2026-11-01; the existing learner store and older app files remain present. Owner visual review and iPad check remain open; nothing committed or pushed.

## PolyGotAI branding follow-up — 2026-11-01

Owner selected a cream speech bubble with six centered waveform bars (last gold) on teal. Native Icon Composer document and default/dark/tinted appearances are built, connected as the primary icon in Debug/Release, and the user-visible name is **PolyGotAI**. Simulator and signed-device builds pass; installed and launched on the owner's iPhone 15 Plus, with the existing app identity retained. [Source and verification](../../assets/branding/polygotai/README.md). Default/dark/tinted previews inspected; six bars have a common center line, and native 1024 px variants/icon stacks are present in the device build. Launch/relaunch/all-tabs smoke test passes with an isolated store (the initial shared-store run failed). Owner Home Screen visual acceptance remains open; no commit/push.

## Coach exam badge follow-up — 2026-11-01

Owner requested a face badge for completing each coach with at least 80% on all exams. Built **11 new badges**, including Pronunciation, matching the existing teal/cream shields and each coach's animal portrait. Every current lesson must have a completed attempt with at least 80% weighted first-try accuracy; best completed retakes count, and required open work must be finished. Earlier qualifying work is reconciled automatically. The 86 older catalog rows are preserved exactly; the catalog now has 97 families. [Artwork, exact prompts, rules and gallery](../../assets/coach-exam-badges-2026-11-01/README.md); [verification](../../assets/coach-exam-badges-2026-11-01/verification.json).

**32 unit + 2 UI tests passed**, including threshold/retake/version checks, all eleven mappings, badge details and dark/large-text rewards. Signed build passed and was installed in place and launched on the owner's iPhone 15 Plus; no schema change, reset or uninstall. [Screenshots](phases/phase-7/evidence/coach-exam-badges-2026-11-01/). Full suite, iPad UI and owner visual acceptance remain open. Doc impacts for Claude: reward/badge specification and coach completion rules. No commit/push.

## Commit follow-up — 2026-11-01

Owner requested committing all pending changes. Implementation is committed locally as `da35178` (premium UI polish and PolyGotAI branding) and `08e35ba` (coach portraits, badge artwork and coach exam badges). Shared progress/log/plan records accompany a documentation commit. Pre-commit checks passed: clean diff whitespace, 97 artwork hashes, valid JSON, catalog byte-idempotence and no detected credential/signing/store/build files. Prior focused tests and device installation evidence remain applicable; no app source changed during commit preparation. Not pushed. Owner visual acceptance, full-suite and iPad checks remain open.

## Owner review and rework plan (2026-10-26)

The owner reviewed the app and is not satisfied; Claude agrees. All work so far is committed (`f73fa0f`, not pushed). Claude's critical review and the proposed rework (Phases 7–11: look and clean-up, Lexicon v3, Lab Talk + voice, speak-first pronunciation, lessons depth) are in [review-and-rework-plan-2026-10-26.md](review-and-rework-plan-2026-10-26.md). Owner answered all 7 decisions on 2026-10-26 (section 5) and added Erase all data with Face ID / Touch ID. [Phase 7 brief](phases/phase-7/README.md) is ready; **waiting for the owner's go**. Owner is generating the 5 missing coach images from [coach-art-prompts.md](phases/phase-7/coach-art-prompts.md). New gate for every phase: owner play-test on the phone.

## Round 3 — who does what (2026-10-25)

State: commit `f4b5abc`. 390 unit tests pass. The last full UI run had 6 failures of 48; since then 3 were repaired and 3 old v1 lesson-player tests skip (so a clean full run is expected but not yet confirmed). OpenCode has filed six reports in `docs/reviews/`. Codex is back. Nothing is pushed.

| Lane | Jobs, in order |
| --- | --- |
| **Claude** (core, content, docs) | R3-C1 ✅ apply the A2–C2 lesson proofread: rebalance True/False (43 of 44 keys are False), American words (film, flat, holiday, bill), apostrophes, untypeable "…" templates, `b1-technology-read`, truncated options. R3-C2 ✅ apply the Lexicon proofread (American English, field-pack items, register of layover/jet lag, `franchise`, `server`) and the docs-versus-code mismatches. R3-C3 ✅ Phase 5b core: turn-taking rules, question bank, session model, tests (no screens). R3-C4 ✅ Phase 6a core with a fake transport (built on the user's go-ahead; nothing is enabled). R3-C5 review Codex's work and keep this tracker current |
| **Codex** (screens, UI tests) | See [Codex handoff, round 3](phases/round-3/codex-handoff.md): X1 rewrite the three skipped UI tests for the exercise player; X2 coach lesson intro screen (Teacher plus "Communication practice" chip) and polish; X3 iPad Lexicon navigation label under large Dynamic Type; X4 saved communication practice linked to archived lesson versions stays reachable; X5 Phase 5b Interview screen after Claude's R3-C3 lands |
| **OpenCode** (read-only reports) | Round 3 in [opencode-handoff.md](opencode-handoff.md): Job 6 proofread the 13 A1 lessons; Job 7 proofread the Speech Lab content (`Resources/SpeechLab`); Job 8 give-away audit across tracks and course (longest-option bias, prompt-word matches, True/False balance); Job 9 re-check that the earlier findings are fixed |

Rules for this round: Claude owns `tools/curriculum/`, `Resources/`, `Domain/`, `Infrastructure/`, docs and the Xcode project; Codex owns `Features/` views and `SpeechCoachAIUITests/`; `AppShell.swift` only by region and only with a note in the log. One `xcodebuild` per simulator at a time. Each agent logs every change set.

## Completion audit — are all planned phases done? (2026-10-25)

Checked against the plan, the code and the tests. "Built" means it exists and its tests pass; a phase is only **complete** when its open items are closed and the owner has approved it ([phase gates](development-plan.md#phase-gates-what-done-means-for-every-phase)).

| Phase | Built | Open items before it counts as complete |
| --- | --- | --- |
| 0 Declutter | ✅ | Owner approval; device check of the iPad layout |
| 1 Exercise engine, dictation | ✅ built (mic buttons added, Codex LOG-0048) | (a) `intro-01` "Introduce yourself" stays a guided-production lesson on purpose (its own checks, baseline and self-review); it now has a coach tip. The 12 topic lessons are the typed A1 set. (b) The microphone button is missing on about eight free-text fields: Progress note, online review text, resource notes and title, vocabulary discovery fields, custom topic name, subtopic, word and meaning. (c) Dictation on the owner's device (in test now) |
| 2 Lessons and level lock | ✅ | Owner approval. Level tests exist for A2–C2; the first full pass of all five tests on a device is untried |
| 3 Lexicon, modes 1–3 | ✅ | Owner approval. Mode 4 (Specialized Lexicon) belongs to 6d |
| 4 Coach content | ✅ written (needs OpenCode proofread and owner approval) | (a) Every coach now has Foundation and Intermediate (2 units × 4 lessons each); Grammarian and Reading & Listening also have Starter and a new Foundation, so the packs hold 176 lessons in all; the **Advanced stage (C1–C2) is now written for every coach** (256 coach lessons in all). (b) Placeholder art for the new coaches and per-track progress (Codex lane). (c) OpenCode's give-away audit findings are not yet acted on. (d) No phase brief exists for Phase 4 |
| 5 Lab base | ✅ | Evidence folder empty; recognition on a device (owner testing); iPad check |
| 5b Interview v2 | 🔄 core and screen built (Codex LOG-0045) | Claude's review of the screen, then device test. Hands-free sessions are not stored (summary is shown, nothing saved) |
| 6a AI foundation | 🔄 partial | Built: client with fake transport, consent line, strict reply checks. Missing: Settings key and workspace test flow wired to it, cost-and-privacy sheet, "AI feedback" button and result card, the recording → transcript step, the bundled verification file that switches it on, one approved live check |
| 6b AI across the Lab | ⏳ not started | Per-mode prompts and rubrics, result cards, history |
| 6c Voice Interview online | ⏳ not started | Qwen speech loop, AI follow-ups, screen |
| 6d Other online AI | ⏳ not started | Coach "Your turn" review, Specialized Lexicon generation |

Gates still open for every phase: a clean full `verify.sh` run on the current tree (last full UI run was before Round 3), the iPad pass, and owner approval. No phase has been formally approved yet.

## Round 4 — close-out (2026-10-25)

Plan: [phases/round-4/README.md](phases/round-4/README.md). Codex handoff: [codex-handoff.md](phases/round-4/codex-handoff.md). OpenCode jobs 10–14: [opencode-handoff.md](opencode-handoff.md). Round 3 is implemented (LOG-0045).

| Lane | Wave A (now) | Wave B |
| --- | --- | --- |
| **Claude** | R4-C1 ✅ `intro-01` tip (stays guided); R4-C2 ✅ Intermediate stage for 10 coaches (and Foundation for Grammarian and Reading & Listening); R4-C3 ✅ review Round 3 and update specs; R4-C4 ✅ 6a core (recording → transcript → feedback, stored results, owner-local switch-on) | R4-C2 ✅ Advanced stage (80 lessons); R4-C5 ✅ cores for 6b prompts, rubrics and history, 6c AI follow-ups, 6d coach review and Specialized Lexicon (screens are R4-X5) |
| **Codex** | R4-X1 ✅ mic buttons on remaining fields (LOG-0048); R4-X2 coach placeholders, per-track progress, three-stage coach screen; R4-X3 online feedback screens (hidden until enabled) | R4-X4 full verify, iPad, Dark Mode, VoiceOver, evidence (⏳ iPad/Dark/VoiceOver for new screens); R4-X5 ✅ 6b–6d screens, built by Claude 2026-10-26 (LOG-0055) |
| **OpenCode** | Job 10 proofread new content as it lands; Job 11 UI copy audit | Job 12 tracker check; Job 13 test gaps; Job 14 repeat audits |

## Rewards and usage analytics (owner request 2026-10-26)

| # | Task | Lane | Status |
| --- | --- | --- | --- |
| U1 | Remove gold (earning, wallet, Freeze/Repair purchases); hints and examples free; XP-only labels | Claude (Codex out of usage) | ✅ 2026-10-26 |
| U2 | XP level (`XPLevel`), level card on Progress and in the badges screen | Claude | ✅ |
| U3 | Screen-time tracking: visits of 60 seconds or more, merged across quick app switches, kept across a locked device or crash | Claude | ✅ |
| U4 | Progress: time in the app, Day timeline and Week/Month/Year totals | Claude | ✅ |
| U5 | Milestones (levels, level tests, coach stages, practice time and days, Easy words) | Claude | ✅ |
| U6 | New badge artwork for v2 milestones | Claude + owner | ⏳ not started; milestones are shown without badge art |

## Blockers and decisions

| Item | Status |
| --- | --- |
| Codex is available again (2026-10-25) | Round 3 split below; Codex works on the iPhone 18 Pro simulator, Claude on the 18 Pro Max |
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
| 2.7 | **Level-lock change (owner, 2026-10-25):** any locked level can be unlocked by its test, even C2 from A1. `LevelGate.canTakeJumpTest(to:)` true for every locked level that has a test; `JumpTest` draws from the target level and the levels below; a pass opens that level and all below; tests per level; unit tests | Claude | ✅ 377 unit tests (20 level-gate tests on synthetic content) |
| 2.8 | Locked level picker shows "Take the X test" on every locked level; UI test: C2 reachable by test from a fresh learner | Codex | ✅ already generic: the picker shows the test button for any locked level that has a test; the UI test for C2 from A1 follows the A2–C2 conversion |
| 2.9 | Test content: each level's test becomes available when its typed exercises exist (A1 now; A2–C2 with the Phase 4 conversion) | Claude | ✅ 2026-10-25 (every locked level has a test) |

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

## Lexicon 2 — CEFR vocabulary and AI collections

| # | Task | Lane | Status |
| --- | --- | --- | --- |
| L2.1 | **Vocabulary by CEFR level (owner, 2026-10-25):** bank grouped A1–C2 (about 3 groups per level, 700–1,000 words), each word tagged with its CEFR level and a register (everyday, term, jargon, slang, informal). Word choice follows CEFR vocabulary levels; check the licence of any list (Cambridge English Vocabulary Profile, Oxford 3000/5000) before use, choose words only and write all meanings and examples ourselves | Claude | ✅ 2026-10-25: 18 groups, 722 words, registers tagged; no list file bundled (licences unconfirmed); wrong sentences need a native read |
| L2.2 | Level-aware start: active groups follow the learner's unlocked level; the next group is suggested when one is finished | Claude (rules) + Claude (screen) | ✅ 2026-10-25 (level capsule and "Next" tag on the Lexicon tab) |
| L2.3 | Ready-made field packs (business, tech, health, travel, law) with terms and jargon, offline | Claude | ✅ 2026-10-25: 5 packs, 144 words; wrong sentences need a native read |
| L2.4 | AI collections from a topic with suggested topic chips (Phase 6d, after the AI foundation 6a); results marked AI-generated and reviewed before saving | Claude + Codex | ⏳ Phase 6d |

## Phase 4 — Coach content

| Coach | Units authored | Status |
| --- | --- | --- |
| Grammarian | 2 / 2 | ✅ (Phase 2) |
| Reading & Listening | 2 / 2 | ✅ Starter stage: 8 lessons, 111 activities (`build_reading_listening.py`); OpenCode proofread fixes applied 2026-10-25 |
| Debater & Argument | 2 / 2 | ✅ Foundation stage: 8 lessons, 107 activities (`build_debater.py`); OpenCode proofread fixes applied 2026-10-25 |
| Persuasion & Negotiation | 2 / 2 | ✅ Foundation stage: 8 lessons, 107 activities (`build_negotiator.py`); OpenCode proofread fixes applied 2026-10-25 |
| Public Speaking & Rhetoric | 2 / 2 | ✅ Foundation stage: 8 lessons, 115 activities (`build_public_speaker.py`); OpenCode proofread fixes applied 2026-10-25 |
| Journalist | 2 / 2 | ✅ Foundation stage: 8 lessons, 106 activities (`build_journalist.py`); OpenCode proofread fixes applied 2026-10-25 |
| Creative Writing | 2 / 2 | ✅ Foundation stage: 8 lessons, 117 activities (`build_creative_writer.py`); OpenCode proofread fixes applied 2026-10-25 |
| Business & Professional | 2 / 2 | ✅ Foundation stage: 8 lessons, 116 activities (`build_business.py`); OpenCode proofread fixes applied 2026-10-25 |
| Storytelling | 2 / 2 | ✅ Foundation stage: 8 lessons, 112 activities (`build_storyteller.py`); OpenCode proofread fixes applied 2026-10-25 |
| Advertising & Copywriting | 2 / 2 | ✅ Foundation stage: 8 lessons, 113 activities (`build_copywriter.py`); OpenCode proofread fixes applied 2026-10-25 |
| CEFR course A2–C2 fixes and typed exercises | 44 / 44 lessons (content v3) | ✅ |
| Level tests for A2, B1, B2, C1, C2 (any locked level, perfect score) | 5 / 5 | ✅ |

## Phase 5 — Speech Lab additions

| # | Task | Lane | Status |
| --- | --- | --- | --- |
| 5.1 | On-device recognizer, `VoiceMetrics`, word diff | Codex | ✅ |
| 5.2 | Content data: sounds, minimal pairs, dictation sentences, passages, twisters (`Resources/SpeechLab`, `validate_speechlab.py`) | Codex | ✅ |
| 5.3 | Dictation, Pronunciation (hub for Sounds and Clear speech), Speaking screens; Lab home order Dictation, Pronunciation, Speaking, Interview, Conversation, Communication, then Record an introduction and Saved practice | Codex, merge and rename by Claude | ✅ |

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

## Phase 9 — Lab v3 (2026-10-26)

Owner confirmed Codex's Phase 9 assignment. P9-1 Voice, P9-2 Spelling, P9-3 streamed Talk engine, P9-4 Talk screen and P9-5 Lab shell are implemented and **under verification**, not approved. The optional voice preference field was authorized explicitly by the owner. Hosted tests: 399 passed. Phase 9 iPhone 4/4 and iPad 4/4 passed. Full verification failed: 42/52 UI pass, 10 Today/Lexicon/audit failures handed to Claude (LOG-0069). [Evidence](phases/phase-9/evidence/README.md). Physical audio/recognition, live-provider verification and owner play-test remain open. No commit or push.

## First release — 2026-11-01

Branches are now `development` (work) and `main` (releases). Merging a `development` → `main` pull request publishes a GitHub release with grouped notes ([commands](../commands/commands.md#branches-and-releases)). **v0.1.0** was published from [PR #1](https://github.com/work-w-chrstnrpj/PolyGotAI/pull/1): [release page](https://github.com/work-w-chrstnrpj/PolyGotAI/releases/tag/v0.1.0). Owner visual acceptance, full-suite and iPad checks listed above remain open.
