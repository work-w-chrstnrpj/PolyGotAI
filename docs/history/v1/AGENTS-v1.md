# Project Agent Rules

Source of intent: `docs/tdd/tdd.md`. Source files remain the final implementation truth.

Agents working in this repository must keep implementation and documentation changes aligned with the project goal:

```text
Help learners improve English grammar, vocabulary, pronunciation and speaking fluency through connected offline learning and online AI coaching on iPhone and iPad. Speaking practice leads the first usable delivery.
```

## Project Overview

SpeechCoachAI initially serves the owner and may later be shared. Grammar, vocabulary and speaking have equal product importance. First speaking session: record a short introduction, replay/re-record, then request feedback afterward online. Basic lessons, vocabulary and self-review work offline. Online AI uses learner-supplied provider keys (BYOK), stored in Apple Keychain; learner provider accounts bear usage charges. Anki-style vocabulary practice, configurable coaching, evidence-based progress and game-like rewards support the learning loop. Read the product specification for confirmed scope versus proposals. SC-T008 bootstrap and SC-T009 local state/recovery are complete. SC-T010 has historical owner/device acceptance; changed layouts require their own regression evidence. The first-loop repair remains recorded in docs/development-plan/stabilization-2026-10-22.md. Current Codex focus is owner-authorized SC-D002 first-introduction completion. SC-D017 review/repair is recorded and SC-D018 remains deferred. A separate active SC-D004 Today/Progress pass retains its files and status/evidence; preserve concurrent edits and serialize Xcode/device execution. Earlier Today/Progress, recall and reward-preparation allocations remain historical checkpoints. SC-T011 recording is implemented and installed for owner/device checks; provider/learning features remain pending.

## Direction change — 2026-10-25 (read first)

The owner changed product direction. [docs/development-plan/direction-2026-10-25/README.md](docs/development-plan/direction-2026-10-25/README.md) is the active plan and supersedes older Speech Lab, specialist-trainer and UI-copy guidance below where they conflict. Learn = CEFR course + 10 coach tracks; Speech Lab = Articulation, Dictation, Voice, Phonetics. Work proceeds one phase at a time (PLAN → EXECUTE → VERIFY → REVISE → VERIFY → APPROVE); Claude reviews, Codex implements. UI rule: screens never explain what the app can't do; hide unfinished features. Keep handoffs and reports short. Older checkpoint sections below are history.

## Detected Tech Stack

First-slice architecture is selected in docs/tdd/tdd.md (SC-T002); SC-T008 creates the native bootstrap. Native iPhone/iPad, iOS/iPadOS 17+ and English-first are confirmed.

- Application/runtime: Swift/SwiftUI and AVFAudio selected for the first slice; app target exists under application/SpeechCoachAI.xcodeproj.
- Service/API: BYOK provider adapters; direct provider access preferred where supported/permitted; backend only if required by chosen capability.
- Data store: local-only SwiftData selected with private audio files; learner-data device backups excluded.
- Testing: Swift Testing for domain/repository checks and XCTest/XCUITest for platform/UI selected; bootstrap configuration and launch tests exist under application/.
- Deployment: iPhone/iPad, minimum OS 17+; signing/bundle identity and distribution remain unverified.

## Repository Map

Update this map whenever the project structure changes.

- `application/`: native Xcode project, App composition, Domain snapshots, Infrastructure/Persistence and Curriculum catalog loading, hosted Swift Testing and XCUITest targets; `Vendor/swift-fsrs/` is the pinned FSRS-6 library; `.build/` holds ignored local evidence.
- `application/SpeechCoachAI/Features/Learn/`: shared course/optional practice/check runtime and post-reveal introduction review. `Domain/IntroductionReviewGuide.swift` consumes the hashed draft guide; `tools/curriculum/complete_intro.py` preserves exact historical INTRO revisions.
- `application/SpeechCoachAI/Features/Vocabulary/`: manual topics/recall plus registered discovery and Word-of-Day launchers; `Domain/VocabularyDiscovery.swift` owns memory-only suggestions and protected daily-pin snapshots. Production generation and daily selection remain unavailable.
- `application/SpeechCoachAI/Features/Resources/`: native resource library/editor; `Domain/LearningResource.swift` validates bookmark URLs and existing learner storage persists explicitly saved notes. No embedded media or automatic metadata fetching.
- `application/SpeechCoachAI/Features/GeneratedPractice/`: registered generation/report host and local report sheet; production policy/transport remain unavailable. Domain and existing protected repository own journal/validation/recovery.
- `service/`: proposed future online integration; directory does not yet exist.
- `shared/`: possible future contracts; directory does not yet exist.
- `tests/`: future cross-cutting tests; directory does not yet exist.
- `assets/awards/v1/`: adopted award-family raster artwork, generation prompts/provenance, manifest and static review gallery; not application implementation.
- `docs/`: project intent, contracts, architecture, operations, and quality documentation.
- `docs/development-plan/`: feature tracker, milestone/ticket index, ticket workflow, `decomposition.md` parent/child coverage, `progress.md` monitoring tables and `execution-sequence.md`/`.json` automation run order; `tickets/` contains detailed specifications and 22 delivery groups with bounded children.
- `tools/curriculum/`: authoring script for the bundled A1–C2 lesson catalog; the app reads the generated JSON and audio, not the script.
- `tools/figma-local-helper/`: project-local Figma development plugin, build script and design-tool verification; not application implementation.
- `tools/figma-local-helper/consolidation/`: fixed-purpose Page 1 UI-kit helper and reviewed exports; `read-only-audit/` captures components/tokens/image references without design writes; `review/readiness-2026-10-21/` holds SC-T007 live inspection/source-art evidence. Consolidation/Page 2 removal verified locally; cloud sync remains unverified.
- `.agents/`: canonical reusable AI roles, skills, overlays, workflows, and tool policies.
- `.ai/`: context routing, maps, prompt recipes, and generated-index guidance.
- Tool adapter: `.codex/agents/` exposes installed roles; other provider folders are not currently installed.

## Core Operating Rules

- Prefer project docs as the source of product intent.
- Prefer exact source files as the source of implementation truth.
- Use maps, indexes, graphs, and summaries only for discovery.
- Read exact files before changing them.
- Make small, reviewable edits that follow the project structure.
- Run relevant verification before claiming success.
- Ask for approval before destructive, high-risk, production, secret, or migration operations.

## UI Design Inputs for Future Implementation

Before planning, building or reviewing any app UI, read [the UI reference guide](docs/product-specification/ui-reference-guide.md). Follow its read order, exact Page 1 template/component IDs, screenshot map, desktop/local-backup fallback, asset rules and per-ticket handoff record. Product contracts govern behavior; retain the approved visual identity and reuse shared patterns. Record unavailable inputs and conflicts explicitly. The removed Page 2 is historical. This documentation does not authorize application implementation or close design/device acceptance.

## Documentation Rules

- Keep `docs/tdd/tdd.md` canonical for technical intent.
- Update API, data, diagram, testing, deployment, and project-structure docs when behavior or architecture changes.
- If work is tracked in `docs/development-plan/development-plan.md`, update the matching status.
- Do not add project-specific requirements to reusable template files unless the project has adopted them.

## Security Rules

- Do not commit secrets, tokens, private keys, credentials, or production configuration.
- Do not log sensitive input, provider responses, credentials, or private user data.
- Validate input at trust boundaries.
- Prefer least privilege for accounts, tokens, services, and automation.

## Git And PR Rules

- Check `git status` before major edits.
- Do not revert user changes unless explicitly asked.
- Keep commits scoped and explain verification in PR notes.
- Avoid force push, reset, clean, or destructive history operations without explicit approval.

## Canonical AI Structure

Canonical reusable AI assets live in `.agents/`:

- `.agents/roles/`: 6 role owners selected by the fullstack profile.
- `.agents/skills/`: reusable workflow skills only.
- `.agents/overlays/`: Mentor and Coach overlays.
- `.agents/workflows/`: multi-role workflows.
- `.agents/tools/`: context, verification, adapter, and tool policies.

Tool-specific folders are generated adapters, not source of truth. Update canonical files first. The preset generator is maintained in `/Users/chrixcrusher/Documents/Projects/ai-project-structure-template`; its CLI is not installed in this project. Review template updates before synchronizing, because synchronization can refresh managed canonical assets. See `README.md` for the external generator commands.

## Overlay Usage

Use overlays to change response style without changing work ownership.

Examples:

- `Mentor ELI12: Explain this architecture.`
- `Coach: Critique this plan.`
- `Software Engineer + Mentor: Explain this feature design.`
- `Backend & Database Engineer + Mentor: Explain this API design.`
- `System Architect + Coach: Challenge this architecture proposal.`

## AI Role Usage Guide

Six installed role prompts live in `.agents/roles/`; current generated adapters live under `.codex/agents/`. Planning, deployment and security responsibilities require coordination with available owners; additional specialist roles are not installed.

- Software Engineer: general coding, fullstack implementation, end-to-end features, refactoring, and integration.
- System Architect: architecture, module boundaries, dataflow, and technical risk.
- Frontend UI/UX Developer: UI, routing, state, accessibility, client behavior, and frontend tests.
- Backend & Database Engineer: APIs, services, validation, auth, persistence, integrations, jobs, queues, and data ingestion.
- SQA Engineer: test plans, manual cases, automated tests, regressions, acceptance verification, and bug reports.
- Technical Documentation Specialist: README, API docs, setup, onboarding, operations, workflow, integration, and changelog docs.

## Skill Usage Guide

Create or keep a standalone skill only when it defines a reusable workflow with clear inputs, steps, boundaries, and outputs.

Do not create standalone skills for every role capability. Put domain-specific capability guidance inside the owning role file under `Embedded Capability Playbooks` or reference playbooks.

Reusable skills live in `.agents/skills/`. Tool-specific skill copies are generated for Claude, Cursor, GitHub Copilot, OpenCode, and Windsurf; Codex and Antigravity use `.agents/skills/` directly. Choose the smallest skill that matches the task, then read exact source files before editing.

## Verification Commands

Native simulator checks: `bash tools/native/verify.sh SIMULATOR_UUID` (see docs/commands/commands.md). External preset validation is also available:

```sh
node /Users/chrixcrusher/Documents/Projects/ai-project-structure-template/bin/create-preset.mjs validate --into /Users/chrixcrusher/Documents/Projects/SpeechCoachAI
```

The native verification script builds and runs hosted configuration/UI launch tests. Product acceptance remains pending. Do not claim preset validation proves app behavior. There is currently no Git repository; do not initialize it unless separately requested. Product docs describe intended behavior, not shipped features.

The local design helper has separate tooling checks:

```sh
node tools/figma-local-helper/build.mjs
node tools/figma-local-helper/verify.mjs
```

These checks do not prove Figma runtime execution, visual quality or product behavior.

## Current implementation status — 2026-10-21

Owner authorized development in the adopted execution sequence. Owner authorized continuous serial execution, asking only for required personal intervention/decisions. Default to one active bounded batch; the 2026-10-22 first-loop stabilization batch supersedes serial dispatch for its existing ticket coverage. Exact ticket status and evidence remain authoritative. `tools/native/verify.sh` owns repeatable unsigned simulator checks. Physical iPhone bootstrap delivery passed; later device acceptance remains separately scoped. Do not bypass ticket prerequisites or initialize Git.


## Recording engineering checkpoint — 2026-10-21

`application/SpeechCoachAI/Features/Recording/` owns native capture/replay/self-review UI and lifecycle controller. `Infrastructure/Audio/CaptureFile.swift` inspects actual PCM originals. Repository pending capture references retain crash drafts under the existing private staging namespace; optional JSON field, no SwiftData migration. `SpeechCoachAITests/CaptureRecoveryTests.swift` uses synthetic WAV files only. The speaking-loop practice sheet stays on a stable root, and the save/finish bar is pinned to the review scroll. Simulator fixture journey, rotation, and background-stop checks passed. On 2026-10-21 the same navigation, contrast, larger-text, background-stop, and fixture history checks passed on a physical iPad (A16), iPadOS 27.0.1. On 2026-10-22 the owner reported the requested speaking close-out is working. SC-T010 is done. SC-T011–SC-T017 remain in_progress. Live provider access and the remaining 120-second cap and call or headphones route stay open. See the evidence folders for exact results.

## Provider preparation checkpoint — 2026-10-21

`Infrastructure/Credentials/` and `Features/Settings/ProviderSettingsView.swift` implement local Keychain/masked settings; `Infrastructure/Providers/ASRPreparation.swift` prepares a separate in-memory candidate submission copy. The gated HTTP transport now exists in Infrastructure/Providers/SpeakingProviderClient.swift. Live access remains disabled without the reviewed account record. Synthetic credential tests pass on signed phone/simulator. `tools/native/verify.sh` uses ad-hoc simulator signing for Keychain access. Source preparation does not close SC-T010/011/012/013 acceptance.

## Request/feedback checkpoint — 2026-10-21

`Infrastructure/Providers/ASRRecognition.swift` and `ValidatedCoachingContent.swift` implement bounded response/content decoding; LearnerRepository owns request transitions and atomic typed result/revision commits. `TranscriptionLifecycleTests.swift` and `CoachingValidationTests.swift` use synthetic fixtures. Simulator and focused physical iPhone tests pass. Fixture transcript and feedback UI is delivered and stays fail-closed until a reviewed Singapore account record exists. No live transport has been sent. A later physical iPad run passed the fixture speaking loop; that does not open live provider access. Exact tickets/evidence remain authoritative; ten tickets are done.

## Lesson catalog and progress checkpoint — 2026-10-21

`Domain/CurriculumCatalog.swift` and `Infrastructure/Curriculum/CurriculumCatalogLoader.swift` load a bundle-first catalog. The shipped `CurriculumCatalog.json` includes a lesson for every outline topic from A1 through C2 (57 lessons). They follow the public CEFR global scale. The owner waived a hired reviewer on 2026-10-21; the pack records that source honestly and is not a CEFR certificate. `LessonPlayerView` plays the bundled listening clip. `Domain/LessonJourney.swift` stores unaided attempts beside preferences with no SwiftData migration. `Domain/VocabularyLink.swift` keeps one collection card per sense and records recognition without a due date. `Domain/CustomVocabulary.swift` stores learner-written topics in the same preferences document. `Domain/VocabularyRecall.swift` lets a saved word be revealed and rated. `Domain/ReviewSchedule.swift` then sets the next recognition due time with pinned FSRS-6. `Domain/ReviewCredit.swift` schedules only an explicit revealed recognition rating. Lesson exposure, grammar correction, productive use, and a repeated event leave that due time alone. A collection save sets `inReview` false and stays out of the due queue. Add to review keeps that same card. `OpenRecall` stores a revealed card that has not been rated and the practice screen resumes it. SC-T018, SC-T019, SC-T020, SC-T021, SC-T046, SC-T047, SC-T048, SC-T049, SC-T050, and SC-T165 stay in_progress. A2–C2 lesson walkthroughs, spoken recall, and generated topics remain open. SC-T006 is owner-approved without a qualified educator review.

## First-loop stabilization — 2026-10-22

Owner authorized implementation after the audit and paused the other implementation process. See `docs/development-plan/stabilization-2026-10-22.md` and its evidence record. Today/Learn, the focused lesson player, honest text/recording participation, vocabulary meanings and sense identity are implemented as one stabilization batch; its final simulator evidence is recorded in the linked recovery record. Optional Codable drafts/meaning/completion references retain schema-v1 compatibility; no SwiftData migration. Do not treat structural catalog availability or this repair as full content, provider, device, or learning acceptance.

## Daily suggestion and progress evidence — 2026-10-22

`Domain/PracticeRecommendation.swift` suggests one next action. A saved choice for the local day wins and keeps the grounded reason. Otherwise the newest supported difficulty wins, with grammar ahead of retrieval, then follow-up, then clarity. Due reviews, then a ready lesson, then Speech Lab cover missing evidence. Follow-up and clarity are not inferred from audio. Specialist packs are not offered. `Domain/LearningEvidence.swift` keeps recognition, recall, productive use, retention, and transfer separate. Four comparison labels pair takes without a proficiency claim. The week counts real speaking, text, and recall, and a quiet week is not a level change. Optional `dailyChoice`, `confidenceNote`, and `attemptFormats` stay on the existing preferences document. SC-T051, SC-T052, and SC-T054 are in progress. SC-T023, SC-T024, and SC-T053 stay open. No live call and no schema migration.

## Offline recall recovery — 2026-10-22

The owner authorized another grouped implementation pass. SC-T048–SC-T050 now save hidden drafts as well as reveal, with optional mode/event UUID in the existing preferences document. Think/Write/Say are distinct; Say is an unrecorded learner-reported self-check and supplies no speech assessment or speaking-completion credit. First revealed response/mode are frozen at the repository. The same event cannot schedule twice or identify a different sense. Exposure is committed before reveal; failed writes preserve the prior draft/history. No SwiftData migration or live call. See docs/development-plan/recall-recovery-2026-10-22.md and its evidence. Exact tickets remain in_progress pending full original acceptance.

## Parallel work ownership and daily-flow checkpoint — 2026-10-22

Owner assigned Codex application implementation/testing/integration and Grok new files only under docs/development-plan/reward-preparation/. Do not edit Grok’s drafts or treat their proposals as adopted reward rules. Codex’s daily-flow batch connects the primary action to the recommendation, makes overrides explicit and failed saves visible, retains unsaved confidence in memory for retry and guards it with the learner epoch. Refresh day/week on foreground and significant-time/timezone changes; weeks are start-inclusive/end-exclusive. No reward implementation or persistent schema change. See docs/development-plan/daily-flow-2026-10-22.md and its evidence; original ticket acceptance stays separately scoped.

## Physical iPad current-build checkpoint — 2026-10-22

Owner authorized automated checks on the connected physical iPad A16/iPadOS 27.0.1. 95 hosted tests and seven selected UI journeys passed across initial run/retests. The initial New Topic test-setup miss is preserved; helper commits keyboard entry and waits for sheet dismissal. Progress confidence placeholder now uses Kit.secondary and final Progress contrast passed. Current signed build installed in place and normal launch passed. Tests used isolated stores/synthetic provider; no live call or learner-data reset. See docs/testing/evidence/ipad-acceptance-2026-10-22/README.md. Exact remaining acceptance/prerequisites still govern closure.

## Status and concurrent ownership — 2026-10-23

Owner requested `awaiting_testing` for implementation-complete tickets with only testing/acceptance remaining. Keep incomplete code/content/decisions `in_progress`; `done` still requires full evidence and prerequisites. See docs/development-plan/status-review-2026-10-22.md. Codex owns application/tests/canonical integration. Grok's next handoff authorizes only new files under docs/development-plan/intro-content-preparation/ for missing INTRO-01 foundation and optional specialist content; no app/build/status/reward edits. The handoff is prepared for the owner to deliver. Current Codex batch is personal vocabulary search/editor reliability under SC-T165/048. No Git initialization or live provider requests.

## Expedited parallel implementation — 2026-10-23

Owner explicitly prioritizes substantial grouped implementation and parallel Codex/Grok work until implementation is complete/awaiting_testing; avoid repeatedly assigning documentation-only work or retesting unchanged verified code. This preference is saved at the owner's explicit request. Current group SC-T018–SC-T021: Grok owns exact catalog model/loader/resource/tests/authoring files in docs/development-plan/handoffs/grok-catalog-implementation-2026-10-23.md; Codex owns IntroPracticeView, LessonJourney, LessonPlayerView, journey/UI tests, project registration and canonical integration. Do not cross file ownership or overlap Xcode runs. New optional practice uses separate local journeys with source-course references. It does not close reviewed-content, specialist-speaking or actual learner-assessment gates. Current status/evidence remains authoritative.

## INTRO parallel delivery — 2026-10-23

SC-T019/020 are awaiting_testing after catalog metadata integration and four durable optional offline routes. Foundation version 2 requires five concepts, five production attempts, linked application, example review and self-review without an accuracy gate. Combined phone/tablet and final focused phone verification are scoped in docs/testing/evidence/intro-practice-2026-10-23/README.md. SC-T018/021 retain unfinished content/speaking/assessment scope. Grok finished catalog work; its next handoff is docs/development-plan/handoffs/grok-review-safety-2026-10-23.md, limited to ReviewSchedule.swift, ReviewScheduleTests.swift and a new report. Codex owns runtime integration, repository, builds and canonical status. Handoff preparation is not proof of dispatch.

## Connected speaking/checks checkpoint — 2026-10-23

SC-T021 is awaiting_testing. Specialist recording keeps exact task/provenance through recovery; personal baseline/repeated baseline/transfer/day-7/day-28 checks have separate journals, frozen conditions, staged follow-ups, explicit text retention and no automatic scores. Course completion requires matching course-purpose/journey/activity; checks and specialist practice cannot complete it. Source/evidence: docs/development-plan/connected-practice-2026-10-23.md. Grok scheduler fixes are integrated; next coding handoff is grok-goal-recommendations-2026-10-23.md, prepared for owner dispatch. No physical acceptance, live provider proof or qualified learning result is implied.

Final connected runtime verification: 114 tablet tests (112 hosted + two UI), two final phone UI journeys, and one full 18-activity version 3 phone course/review journey passed. Initial wrong-specialist-prompt failure is retained in evidence and passed after item-driven recording presentation. Grok six-question comprehension content is integrated; old version 2 journeys remain separate.

## SC-D007 runtime checkpoint — 2026-10-23

The owner approved the thirteen-topic A1 scope and authorized remaining code with v2 journey preservation. Twelve A1 v3 topics are integrated as explicit personal-use previews; INTRO-01 v3, A2–C2, audio and shared senses are preserved. The live catalog retains thirteen historical versions; exact old journeys/drafts/first responses resume through version-aware lookup. Optional topic practice uses the shared player/recorder and separate source-linked journals, with explicit text-retention choice. No SwiftData migration or live provider call. SC-T073–087 are awaiting_testing, SC-T029 in_progress and SC-T088 pending. See docs/development-plan/sc-d007-implementation-2026-10-23.md and docs/testing/evidence/sc-d007-2026-10-23/README.md. Qualified review, original prerequisites and actual physical/learning acceptance remain separate.

## Local conversation/interview integration — 2026-10-24

Owner authorized connecting SC-D013. Speech Lab now opens local Conversation/Interview views registered in the real Xcode project, with exact session/question recorder return and optional explicitly saved 24-hour archives in the existing learner document. Online/realtime actions remain disabled; original content/contracts/actual acceptance stay open. SC-T035/150/151 remain in_progress because their full implementation scope is incomplete. See docs/development-plan/sc-d013-integration-2026-10-24.md and its linked evidence. Owner separately dispatched SC-D014 to Grok; preserve its four Communication files and report folder until integration handoff. No Git initialization, live calls or SwiftData migration.

## SC-D014 local communication integration — 2026-10-24

Owner authorized reviewing/fixing/integrating Grok's returned SC-D014 files, superseding the earlier until-handoff ownership hold for this pass. Real-target communication views now connect Learn/Speech Lab, independent native recording and explicit source/version recovery through optional fields on existing storage. No curriculum candidate publication, live provider, TTS or sound assessment is enabled. SC-T036/154–159 are in_progress; SC-T160 remains pending because original code/content/decisions/acceptance are incomplete. See docs/development-plan/sc-d014-integration-2026-10-24.md and its evidence. Existing v2/v3 journeys remain separate; no Git initialization, learner reset or SwiftData migration.

## SC-D017 learning resource library — 2026-10-24

Owner authorized SC-D017 implementation and selected public HTTPS links including normalized YouTube destinations, with local notes, no metadata/thumbnail fetching and explicit external-open confirmation. Learn now opens the registered native resource library/editor. Optional Codable bookmarks use existing protected learner storage; exact epoch/revision checks, failed-save rollback, in-memory unsaved drafts and delete-all invalidation apply. No provider request, migration, embedded media, resource export or curriculum/reward completion. SC-T168/169 are awaiting_testing; SC-T039 parent and SC-T028 prerequisite/actual acceptance remain open. See docs/development-plan/sc-d017-implementation-2026-10-24.md and linked evidence. Grok's next SC-D015 prompt remains prepared for owner delivery; receipt/start must not be inferred.

## SC-D015 reviewed integration — 2026-10-25

Owner confirmed Grok's SC-D015 assignment and authorized Codex review/fixes. Repaired validation/request/cache/report/retention boundaries and real-target storage/navigation are integrated; production still supplies no generation policy or transport. Optional Codable journal has epoch/exact-record guards and rollback, with durable deletion and unknown-outcome recovery. No new provider request, migration, learner reset, automatic retry/enrollment, qualified content or assessment/reward outcome. SC-T037/161–164 remain in_progress for missing original policy/adapter/model/content/semantic-validation and actual acceptance scope. See docs/development-plan/sc-d015-integration-2026-10-25.md and linked evidence. Grok's SC-D016 recommendation is not verified dispatch; preserve that lane.

## SC-D016 reviewed integration — 2026-10-25

Owner authorized reviewing/fixing Grok’s actual SC-D016 return. Repaired discovery consumes the SC-D015 pinned request state machine and clears private drafts on epoch replacement/restart; daily pins require an epoch and cannot be replaced. Registered native launchers connect Vocabulary/Today with current background/day lifecycle. Production policy/transport/reviewed pool are absent; generation/enrollment/automatic selection remain incomplete; optional protected daily snapshot persistence/recovery is integrated. SC-T038/166/167 are in_progress; SC-T165 stays awaiting_testing. No migration/live call/physical acceptance. Codex owns shared integration/builds; SC-D017 acceptance-review handoff is prepared for owner delivery, not dispatched.

## SC-D017 acceptance follow-up — 2026-10-25

No expected Grok completion report/new test file was present. Owner redirected Codex to SC-D017 instead of SC-D018. Codex repaired retained query encoding/identity and registered ResourceLibraryAcceptanceTests; added a real system-browser handoff/return UI check with synthetic notes. Source policy/no-fetch/local storage remains unchanged, with no migration or live provider call. SC-T168/169 remain awaiting_testing; SC-T039/028 and physical/accessibility/site acceptance remain open. See docs/development-plan/sc-d017-acceptance-2026-10-25.md and grouped-ticket-report-2026-10-25.md. The new tests are Codex-authored; SC-D018 has no implementation or status changes.

## SC-D002 INTRO-01 v4 — 2026-10-25

Owner requested completion at least to awaiting_testing. Personal-use v4 keeps minimum core counts/IDs/senses/audio, archives exact v3 beside v2, corrects quiet follow-up equivalence and gender assumptions in listening keys, and adds draft advisory alternatives/explanations/rubric anchors/specialist review. V4 requires comparing sixteen unscored core examples after an attempt, with no accuracy gate; old completion remains unchanged. Optional check source/exposure metadata is frozen and legacy nil stays unknown. SC-T018/019/020/021 await testing; SC-T043 stays pending actual prospective review/consent/longitudinal acceptance, not missing runtime code. Qualified review, actual device/provider gates, learning outcomes and public publication are not fabricated. See docs/development-plan/sc-d002-2026-10-25/README.md and linked evidence. No migration/live request/learner reset. Preserve the independent SC-D004 source/status work and serialize native tests.

## SC-D005 reward implementation checkpoint — 2026-10-25

Owner adopted the named economy and personal-use achievement bindings in `docs/development-plan/sc-d005-2026-10-25/owner-decisions.md`. `Domain/RewardPolicy.swift`, `RewardLedger.swift`, `AwardCatalog.swift`, `Features/Rewards/` and bundled `Resources/Rewards/AwardCatalog.json` now implement the local wallet, all-68 criteria/availability, optional helps, continuity, goals/reminders/timer and committed safe-boundary presentation. Repository source events and credits share the existing preferences-document transaction; no SwiftData migration. Preserve qualified-learning/CEFR/unsupported-family unavailability and original source masters. No live call, owner-data reset or Git initialization. See the delivery/evidence records for status and exact remaining acceptance.
