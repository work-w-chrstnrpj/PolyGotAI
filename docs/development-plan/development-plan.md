# Development plan (v2)

> The single plan for v2. Old tickets, milestones and progress tables are history ([history/v1](../history/v1/development-plan/)). Why the plan changed: [history-version.md](../history-version.md).

## Workflow

Every phase runs **PLAN → EXECUTE → VERIFY → REVISE (if needed) → VERIFY → APPROVE**.

1. **PLAN.** Claude writes the phase brief and the Codex handoff in `phases/phase-N/`. The owner approves before work starts.
2. **EXECUTE.** Claude and Codex work in parallel on **separate files** (split below).
3. **VERIFY.** Claude reviews Codex's code, integrates both lanes, runs `tools/native/verify.sh`, and walks through the app on the simulator with screenshots.
4. **REVISE.** Claude fixes small issues directly and sends larger ones back to Codex as a short list.
5. **APPROVE.** The owner tries the build and approves, or asks for changes. Then the next phase starts.

Normally one phase is active at a time. **Owner exception, 2026-10-25:** to deliver faster, phases with separate file scopes run in parallel. Done: Phase 2 screens (Codex) with Phase 3 (Claude). Now: Phase 5 (Codex) with Phase 4 content (Claude). Each phase keeps its own VERIFY and APPROVE. Rules: each phase brief lists the files it owns; shared files are split by region; builds use separate DerivedData folders and simulators.

**Agent log and handoffs:** [Claude-Codex-Cursor-conversation.md](../../Claude-Codex-Cursor-conversation.md). Every agent appends an entry after each change set; handoffs between agents are written there (the owner pastes them into a tool that can't read the file). Short phase handoff notes may still live in `phases/phase-N/`, but the log entry is the record.

**Status tracker:** [progress.md](progress.md) lists every task, lane and status. It is the basis for progress reports.

## Who does what

**OpenCode (free tier) is a third helper with report-only jobs:** it proofreads lesson and word content and sweeps docs for stale names, writing only under `docs/reviews/`. It edits no product files and commits nothing ([handoff](opencode-handoff.md)).

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
- Git: the repo is `https://github.com/work-w-chrstnrpj/PolyGotAI` (public, branch `main`). Commit and push only when the owner asks. Back up a file before a risky rewrite (copy it to `application/.build/backup/`).
- Handoffs stay under one page. Reports stay under one page. Evidence is the test summary plus 3–6 screenshots in `phases/phase-N/evidence/`.
- No new ticket IDs. This file's status table is the tracker.

## Phases

| # | Phase | Claude lane | Codex lane | Status |
| --- | --- | --- | --- | --- |
| 0 | **Declutter and setup** | Folder-synchronized project; iPad bottom bar and sidebar; declutter pass (Codex had no usage); tab order and Lexicon/Lesson names; one-line taglines | Not needed | ✅ built, awaiting owner approval |
| 1 | **Exercise engine and dictation** | `AnswerChecker`, `ExerciseSpec`/`ExerciseSession`, catalog fields, TTS wrapper, `validate.py` (done); on-device `DictationRecognizer` + `DictationButton` and wiring into existing text fields; convert and fix the 13 A1 lessons as content v4 | Exercise views, tip / feedback / finish screens, player integration, UI test ([phase 1](phases/phase-1/README.md)) | ✅ done: exercise engine, 8 exercise types (6 with dedicated screens), dictation button, 12 A1 lessons converted |
| 2 | **Lesson restructure** (Lesson tab = Course + Coaches, ordered levels) | Track catalog model and loader, new coach cases, Grammarian Units 1–2 content, track validator; **level gate rules (`LevelGate`: unlocked levels, finish-level unlock, jump-test pass/fail) and the A1 → A2 jump test built from A1 exercises**; tests | Course \| Coaches switch, coach grid, track → unit → lesson screens; **locked level picker and jump-test screen**; UI tests ([brief](phases/phase-2/README.md), [handoff](phases/phase-2/codex-handoff.md)) | ✅ built and verified; awaiting owner approval |
| 3 | **Lexicon** (modes 1–3) | Lexicon bank model, loader and validator; duplicate check; stages from FSRS state; Lexicon in Action question builder; Daily Lexicon pick; first predefined groups (content) | Lexicon tab screens (groups, Daily Training, Lexicon in Action), Daily Lexicon card on Today; UI tests | ✅ built (Claude), modes 1–3; awaiting owner approval ([brief](phases/phase-3/README.md)) |
| 4 | **Coach content** | **Claude writes all of it** (owner decision 2026-10-25): 2 units × 4 lessons for the 9 remaining coaches, two coaches per batch; convert and fix A2–C2 course lessons, each level with its jump test (A2 → B1, B1 → B2, B2 → C1, C1 → C2) | Placeholder art for new coaches, per-track progress, iPad polish, fixes from review (after Phase 5 screens) | ✅ all stages written (256 coach lessons, A2–C2 typed); awaiting proofread and owner approval |
| 5 | **Lab: on-device base** (Dictation, Phonetics, Articulation, Voice built; to be shown as Dictation, Pronunciation, Speaking) | Review and revise after Codex finishes (VERIFY) | Recognizer, `VoiceMetrics`, content data, four modes, tests (done, verifying); then merge Phonetics + Articulation into one **Pronunciation** entry and rename Voice to **Speaking** ([brief](phases/phase-5/README.md)) | ✅ built and merged; awaiting device test and owner approval |
| 5b | **Interview v2** (offline voice conversation) | Turn-taking rules (silence ends a turn), scripted question bank and fixed follow-ups, session model; tests | Hands-free Interview screen: orb, live caption, Repeat and Skip, summary | 🔄 core done (Claude); screen is Codex X5 |
| 6a | **AI foundation** (BYOK, Alibaba/Qwen) | Research gate (free-tier models, limits, audio input); provider adapter for speech and text models; one "Get AI feedback" pipeline: send task + audio/transcript, get structured feedback JSON, validate it; quota and error handling; cost and privacy sheet | AI key setup and test in Settings; cost and privacy sheet; "AI feedback" button and result card | ⏳ later |
| 6b | **AI evaluation across the Lab** | Per-mode prompts and rubrics: Pronunciation, Speaking, Interview, Conversation, Communication (Dictation is auto-checked, no AI) | Result cards, history and trends | ⏳ later |
| 6c | **Voice Interview online** | Qwen TTS and STT streaming loop, AI follow-ups | Voice conversation screen | ⏳ later |
| 6d | **Other online AI** | Per-coach review of "Your turn" tasks; Specialized Lexicon generation (mode 4) | Review and generation screens | ⏳ later |
| 7 | **Look and clean-up** ([brief](phases/phase-7/README.md), [rework plan](review-and-rework-plan-2026-10-26.md)) | Theme tokens, "Rank" copy, delete v1, `CurrentLessons`, Erase all data core, copy audit, repository split, coach art | Design system v3, Today, Progress, Erase UI, HIG pass | ✅ approved by owner 2026-10-26 (play-tested on iPhone; commit `d41aa00`); coach art still to come |
| 8 | **Lexicon v3** (whole phase: Claude) | Synonyms content, rank filter, Practice mode, interval preview, topics as packs, and the screens | — | 🔄 executing (Claude) |
| 9 | **Lab v3: Talk and voice** (whole phase: Codex, [brief](phases/phase-9/README.md)) | `TalkSession`, streaming client, sentence buffer, `SpeechAnalyzer`, voice picker logic, Spelling content | Lab (4 entries), Talk, voice settings, Spelling | 🔄 built / focused-verified; full verifier has 10 other-lane UI failures; Claude review / owner device check open |
| 10 | **Lab v3: speak-first pronunciation** | Pitch line, confidence and timing measures, feedback rules | Hear → Say → Feedback screens | ⏳ planned |
| 11 | **Lessons depth** ([brief](phases/phase-11/README.md)) | Grammarian full syllabus (done), coach audit, coach art | — | 🔄 built, awaiting play-test |
| 12 | **Lab refocus + Pronunciation coach** ([plan](owner-feedback-plan-2026-10-26b.md)) | Pronunciation coach, lesson format start, AI buttons lead to setup | Lab list, Today header | ⏳ planned |
| 13 | **Real lessons for all 10 coaches** | Reading pages, topic lessons, all content | — | ⏳ planned |
| 14 | **Lexicon to about 2,400 words** | Content and synonyms | — | ⏳ planned |
| 15 | **Lab Videos and Timed tests** | Prompts, validation, review | Screens, AI client, watched list | ⏳ planned |
| 16 | **UI/UX pass** | — | — | ⏳ later |

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
| 1 | Coach track levels | ✅ Decided 2026-10-25: 3 stages (Foundation ≈ A2–B1, Intermediate ≈ B1–B2, Advanced ≈ C1–C2); Grammarian and Reading & Listening add a Starter (A1) stage. Coaches and stages are not locked; flat coach grid ([presentation](../product-specification/coach-tracks.md#how-coaches-are-presented-owner-approved-2026-10-25)) | Phase 2 |
| 2 | On-device TTS and speech recognition (including the dictation button) | Allow both. Show "We heard", never a score | Phase 1 (TTS, dictation), Phase 5 (Speech Lab recognition) |
| 3 | New characters (Debater, Negotiator, Storyteller, Copywriter; Creative Writer art) | Owner picks animals and names; SF Symbol placeholders until art exists | Phase 4 |
| 4 | Rewards on Today | Streak + XP only; badges in Progress | Phase 0 (done) |
| 5 | Lexicon word lists | Use NGSL/NAWL-style lists only to choose words; write all meanings and examples ourselves; check licenses before bundling ([lexicon.md](../product-specification/lexicon.md#content-sources-for-the-predefined-bank)) | Phase 3 |
| 6 | Tab name "Lesson" (you wrote "Lesson"; the earlier name was "Learn") | Use "Lesson" as written | Phase 0 (done) |
| 8 | Level lock details (**revised 2026-10-25:** any locked level, even C2 from A1, can be unlocked by passing its test; a pass opens that level and all below; perfect score unless the owner changes it) | ✅ Confirmed as written by the owner, 2026-10-25. (a) Finishing a level's lessons also unlocks the next one. (b) Unlimited retakes, new question order each time. (c) [revised] Tests draw from typed exercises of the target level and the levels below it (longer for higher levels, to be decided: recommend 20 items for A2 and 30 for B1 and above), so A2+ tests arrive with Phase 4; until a level's test exists, only finishing the previous level unlocks it. (d) Store unlocked levels without a SwiftData migration (derive from completed lessons plus a passed-test record); if that needs a schema change, ask the owner first. (e) Learners who already opened higher levels in v1: keep what they have opened unlocked | Phase 2 |
| 9 | Alibaba/Qwen for all online speech and AI evaluation (owner direction 2026-10-25: free-tier models through the learner's API key; every Lab speaking activity except Dictation gets AI feedback) | Research gate before 6a. Confirm: which Qwen service and region (Alibaba Cloud Model Studio or another host), the exact speech endpoints and models, streaming versus file upload, per-minute pricing, which model writes the follow-ups (Qwen text model or another), and whether audio is retained by the provider. Provider adapter goes behind the existing disabled BYOK clients; on-device speech remains the offline fallback; audio is sent only after an explicit start, with the cost and privacy line shown first **Research done 2026-10-25 (docs only, no live call): see [Decision 9 findings](#decision-9-findings--phase-6a-research-2026-10-25).** Owner still to confirm the choices in that section. | Before Phase 6 |
| 7 | Per-answer XP | Keep the existing reward policy in Phase 1 (lesson-level); revisit after use | Phase 1 |

### Decision 9 findings — Phase 6a research (2026-10-25)

Sources: Alibaba Cloud Model Studio documentation read on 2026-10-25 (pricing, speech-to-text models, rate limits, OpenAI compatibility, Qwen-Omni). Model names and prices change often; **re-check the console before building**. No API call was made.

| Question | Finding |
| --- | --- |
| Service and region | Alibaba Cloud Model Studio. **Free quota exists only in the Singapore (international) region**, valid 90 days from activation; Beijing and other regions have none. An API key is bound to the region where it was created (a key from another region gets HTTP 401), so the app's key field must say "Singapore". |
| Text endpoint | OpenAI-compatible Chat Completions: `https://{WorkspaceId}.ap-southeast-1.maas.aliyuncs.com/compatible-mode/v1/chat/completions`, header `Authorization: Bearer <key>`. The older shared host `dashscope-intl.aliyuncs.com` is documented as legacy; the learner needs their workspace id as well as the key. |
| Text model for follow-ups | `qwen-flash` (US$0.05 in / $0.40 out per million tokens, up to 256K input) or `qwen-plus` ($0.40 / $1.20; thinking output $4). Free quota is about 1 million tokens per model for text models. Limits (Singapore): qwen-flash 600 requests and 5M tokens per minute; qwen-plus 600 and 1M. Limits are per Alibaba account, not per key. When a free-only quota runs out the call returns 403, not 429. |
| Speech to text (files) | `qwen3-asr-flash` (English supported; base64 or URL; up to 10 MB and 5 minutes per request): $0.000035 per second (about $0.13 per hour), free quota 36,000 seconds (10 hours). Fun-ASR (`fun-asr`, `fun-asr-flash`) has the same price and quota. 100 requests per minute for `qwen3-asr-flash`. Paraformer is Beijing only, so skip it. |
| Speech to text (streaming) | `qwen3-asr-flash-realtime` and `fun-asr-realtime` over WebSocket, $0.00009 per second ($0.32 per hour), same 10-hour free quota. Mono audio, 16 kHz. Not needed for short Lab clips; file upload is simpler and cheaper. |
| Audio understanding | `qwen3.8-omni-flash` (text-only output; audio passed as `input_audio` base64 under 10 MB, up to 3 hours by URL; 113 languages) and `qwen3.5-omni-flash` ($3 per million audio input tokens, $0.40 text input, $2.20 text output). Omni models are limited to 60 requests per minute in Singapore. The documentation does **not** describe pronunciation scoring: any "pronunciation feedback" would be the model's opinion from the audio, not a measured score. |
| Speech out (optional) | `qwen3-tts-flash` $0.10 per 10,000 characters, free 110,000 characters. On-device `AVSpeechSynthesizer` stays the default. |
| Rough cost per Lab clip | A 30-second answer: transcript about $0.001 (30 s × $0.000035); follow-up feedback from `qwen-flash` about $0.0005. About $0.002 per clip once the free quota is used, nothing during it (10 hours of audio ≈ 1,200 clips of 30 s). |
| Not confirmed | Whether the provider keeps audio or uses it for training (read the Model Studio data terms before 6a ships and show the result on the consent line); exact free-quota amount for `qwen3.8-omni-flash`; behaviour when the 90 days end (the free quota stops; paid use needs a payment method on the learner's account). |

**Recommendation for the 6a adapter (owner to confirm):** (1) learner supplies key, workspace id and region fixed to Singapore; (2) record a short clip on device, send it as base64 to `qwen3-asr-flash` for the transcript, then send the transcript plus the exercise to `qwen-flash` for the feedback lines (two cheap calls, English-only prompts we control, JSON reply); (3) use an Omni model only if the owner wants comments on delivery (pace, intonation) and accepts that it is not a score; (4) one request at a time with a visible cost and privacy line before the first send; (5) keep on-device recognition as the offline path, and treat 403 (free quota used) and 401 (wrong region) as plain one-line errors.

