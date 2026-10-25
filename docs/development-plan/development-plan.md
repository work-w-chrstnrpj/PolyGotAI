# Development plan (v2)

> The single plan for v2. Old tickets, milestones and progress tables are history ([history/v1](../history/v1/development-plan/)). Why the plan changed: [history-version.md](../history-version.md).

## Workflow

Every phase runs **PLAN → EXECUTE → VERIFY → REVISE (if needed) → VERIFY → APPROVE**.

1. **PLAN.** Claude writes the phase brief and the Codex handoff in `phases/phase-N/`. The owner approves before work starts.
2. **EXECUTE.** Claude and Codex work in parallel on **separate files** (split below).
3. **VERIFY.** Claude reviews Codex's code, integrates both lanes, runs `tools/native/verify.sh`, and walks through the app on the simulator with screenshots.
4. **REVISE.** Claude fixes small issues directly and sends larger ones back to Codex as a short list.
5. **APPROVE.** The owner tries the build and approves, or asks for changes. Then the next phase starts.

Only one phase is active at a time.

**Agent log and handoffs:** [Claude-Codex-Cursor-conversation.md](../../Claude-Codex-Cursor-conversation.md). Every agent appends an entry after each change set; handoffs between agents are written there (the owner pastes them into a tool that can't read the file). Short phase handoff notes may still live in `phases/phase-N/`, but the log entry is the record.

**Status tracker:** [progress.md](progress.md) lists every task, lane and status. It is the basis for progress reports.

## Who does what

| | Claude (senior engineer / reviewer) | Codex (implementing engineer) |
| --- | --- | --- |
| Owns | Domain logic, data models and loaders, answer checking, speech services, content (lesson JSON), validators, project/build config, docs, reviews | SwiftUI screens and components, navigation wiring, copy/layout passes, accessibility, UI tests |
| Writes | `Domain/`, `Infrastructure/`, `Resources/` content, `tools/`, `docs/`, unit tests, `project.pbxproj` | `Features/` views, `SpeechCoachAIUITests/`, view-level test updates |
| Hands over | A stable Swift API (types and functions) **before** Codex starts on screens that use it | A short report: files changed, test result, screenshots, questions |

**Shared files:** `AppShell.swift` and `LessonPlayerView.swift` belong to Codex. Claude changes them only during VERIFY/REVISE, after Codex's lane is done.

### Rules for working in parallel

- No two people edit the same file in the same phase. If a change is needed in the other lane's file, ask for it in the report or handoff.
- `project.pbxproj`: Claude only, until the project uses folder-synchronized groups (Phase 0). After that, new files need no registration.
- Builds don't share state. Codex uses `bash tools/native/verify.sh 7535AD2C-F655-4F05-8C36-FE5E0A614902` (iPhone 18 Pro, `application/.build/DerivedData`). Claude uses the iPhone 18 Pro Max simulator (`29BC0B67-0669-4B64-8691-5C1509075E6E`) with `-derivedDataPath application/.build/ClaudeDerivedData`.
- No Git repository exists. Don't initialize one unless the owner asks. Back up a file before a risky rewrite (copy it to `application/.build/backup/`).
- Handoffs stay under one page. Reports stay under one page. Evidence is the test summary plus 3–6 screenshots in `phases/phase-N/evidence/`.
- No new ticket IDs. This file's status table is the tracker.

## Phases

| # | Phase | Claude lane | Codex lane | Status |
| --- | --- | --- | --- | --- |
| 0 | **Declutter and setup** | Folder-synchronized project; iPad bottom bar and sidebar; declutter pass (Codex had no usage); tab order and Lexicon/Lesson names; one-line taglines | Not needed | ✅ done, awaiting owner approval |
| 1 | **Exercise engine and dictation** | `AnswerChecker`, `ExerciseSpec`/`ExerciseSession`, catalog fields, TTS wrapper, `validate.py` (done); on-device `DictationRecognizer` + `DictationButton` and wiring into existing text fields; convert and fix the 13 A1 lessons as content v4 | Exercise views, tip / feedback / finish screens, player integration, UI test ([handoff](phases/phase-1/codex-handoff.md)) | ✅ done: exercise engine, 8 exercise types (6 with dedicated screens), dictation button, 12 A1 lessons converted |
| 2 | **Lesson restructure** (Lesson tab = Course + Coaches) | Track catalog model and loader, new coach cases, Grammarian Units 1–2 content, track validator; tests | Course \| Coaches switch, coach grid, track → unit → lesson screens; UI tests | ⏳ |
| 3 | **Lexicon** (modes 1–3) | Lexicon bank model, loader and validator; duplicate check; stages from FSRS state; Lexicon in Action question builder; Daily Lexicon pick; first predefined groups (content) | Lexicon tab screens (groups, Daily Training, Lexicon in Action), Daily Lexicon card on Today; UI tests | ⏳ |
| 4 | **Coach content** | Write 2 units × 4 lessons for all 10 coaches, two coaches per batch; convert and fix A2–C2 course lessons | Placeholder art for new coaches, per-track progress, iPad polish, fixes from review | ⏳ |
| 5 | **Speech Lab additions** (Conversation, Interview, Communication stay) | Recognizer, `VoiceMetrics`, word diff; content data (sounds, minimal pairs, dictation sentences, passages, twisters); tests | Phonetics, Articulation, Dictation, Voice screens; sound chart; record/compare; loudness meter; UI tests | ⏳ |
| 6 | **Online AI** (BYOK) | Per-coach review prompts; Specialized Lexicon generation (mode 4); provider adapter on the existing plumbing | Review request/result UI; Specialized Lexicon screen | ⏳ later |

Feature specs: [product](../product-specification/product-specification.md) · [Lexicon](../product-specification/lexicon.md) · [coach tracks](../product-specification/coach-tracks.md) · [Speech Lab](../product-specification/speech-lab.md) · [technical design](../tdd/tdd.md).

## Phase gates (what "done" means for every phase)

- `tools/native/verify.sh` passes on iPhone. iPad is checked at the end of each phase.
- The app launches with existing learner data (no reset, no migration).
- No visible "unavailable / not scored / coming later" text.
- Claude's review notes are resolved or explicitly deferred by the owner.
- The owner has tried it and approved.

## Open decisions

| # | Decision | Recommendation | Needed by |
| --- | --- | --- | --- |
| 1 | Coach track levels | 3 stages (Foundation ≈ A2–B1, Intermediate ≈ B1–B2, Advanced ≈ C1–C2); Grammarian and Reading & Listening also start at A1 | Phase 2 |
| 2 | On-device TTS and speech recognition (including the dictation button) | Allow both. Show "We heard", never a score | Phase 1 (TTS, dictation), Phase 5 (Speech Lab recognition) |
| 3 | New characters (Debater, Negotiator, Storyteller, Copywriter; Creative Writer art) | Owner picks animals and names; SF Symbol placeholders until art exists | Phase 4 |
| 4 | Rewards on Today | Streak + XP only; badges in Progress | Phase 0 (done) |
| 5 | Lexicon word lists | Use NGSL/NAWL-style lists only to choose words; write all meanings and examples ourselves; check licenses before bundling ([lexicon.md](../product-specification/lexicon.md#content-sources-for-the-predefined-bank)) | Phase 3 |
| 6 | Tab name "Lesson" (you wrote "Lesson"; the earlier name was "Learn") | Use "Lesson" as written | Phase 0 (done) |
| 7 | Per-answer XP | Keep the existing reward policy in Phase 1 (lesson-level); revisit after use | Phase 1 |
