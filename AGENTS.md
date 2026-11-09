# Project Agent Rules

Source of intent: `docs/` (start with `docs/development-plan/development-plan.md`). Source files remain the final implementation truth.

Agents working in this repository must keep implementation and documentation changes aligned with the project goal:

```text
Help learners improve English grammar, vocabulary, reading, listening, pronunciation and speaking through short auto-checked lessons — a CEFR A1–C2 course plus ten specialist coach tracks — and a practical Speech Lab, on iPhone and iPad, offline first, with optional online AI coaching using the learner's own key.
```

## Project Overview

PolyGotAI (previously SpeechCoachAI) is a native iPhone/iPad English learning app, built first for the owner and possibly shared later. The repository folder, Xcode target and bundle identifier retain their existing names for compatibility. **Current direction: v2 (since 2026-10-25).** Read [docs/history-version.md](docs/history-version.md) to see why v2 replaced v1.

- **Tabs, in order:** Today | Lexicon | Lesson | Speech Lab | Progress.
- **Lesson:** CEFR course A1–C2 (hosted by the Teacher) plus 10 coach tracks: Grammarian; Reading & Listening Comprehension; Debater & Argument; Persuasion & Negotiation; Public Speaking & Rhetoric; Journalist; Creative Writing; Business & Professional; Storytelling; Advertising & Copywriting. See [coach tracks](docs/product-specification/coach-tracks.md).
- **Lexicon:** spaced-repetition word training (Daily Lexicon on Today, Daily Training, Lexicon in Action, Specialized Lexicon via AI). See [Lexicon](docs/product-specification/lexicon.md).
- **Speech Lab:** keeps Introduction, Conversation, Interview and Communication practice; adds Phonetics, Articulation, Dictation, Voice. See [Speech Lab](docs/product-specification/speech-lab.md).
- **Today and Progress** are kept from v1. Rewards (XP, gold, badges, streak) are kept.
- Every typing field has a speech-to-text (dictation) button. Taglines fit on one line.
- Lessons use auto-checked exercises with instant feedback. Content is original wording derived from open and well-known sources, with credits.
- Offline first. Online AI uses the learner's own provider key (BYOK) in Keychain, and comes in Phase 6.

**Shared log (all agents):** [Claude-Codex-Cursor-conversation.md](Claude-Codex-Cursor-conversation.md) is where every coding agent appends what it changed and where handoffs between agents are written. Read its open handoffs and last entries before you start, and append one entry after every change set (format and rules are at the top of that file).

**Team and workflow:** Claude is senior engineer and reviewer; Codex is the implementing engineer; OpenCode (free tier) does read-only proofreading and writes reports under `docs/reviews/` only. Work runs one phase at a time: PLAN → EXECUTE → VERIFY → REVISE (if needed) → VERIFY → APPROVE. Lanes, the parallel-work rules and current status are in the [development plan](docs/development-plan/development-plan.md). The current phase's files are in `docs/development-plan/phases/phase-N/`.

## Detected Tech Stack

- Application: Swift, SwiftUI, AVFAudio; iOS/iPadOS 17+; universal app in `application/SpeechCoachAI.xcodeproj` (scheme `SpeechCoachAI`), Xcode 27.
- Speech (v2): on-device `AVSpeechSynthesizer`, and `SFSpeechRecognizer` for dictation and Speech Lab (on-device only).
- Data: local SwiftData (`LearnerSchemaV1`, one learner document plus attempt and file-intent rows), private audio files, Keychain for provider keys. No migration without owner approval.
- Content: bundled JSON in `Resources/Curriculum/` (course), `Resources/Tracks/` (coach tracks, v2) and `Resources/Lexicon/` (word bank, v2) plus audio.
- Testing: Swift Testing (hosted unit tests) and XCUITest.
- Service/API: no backend. BYOK provider clients exist and stay disabled until Phase 6.
- Deployment: local Xcode builds to the simulator and the owner's devices. No TestFlight or App Store yet.

## Repository Map

Update this map whenever the project structure changes.

- `application/SpeechCoachAI/App/`: app entry and `LearnerStorageController`.
- `application/SpeechCoachAI/Domain/`: pure Swift models and rules (catalog, journeys, vocabulary, FSRS scheduling, rewards, recommendations; v2: answer checking, exercise sessions, voice metrics).
- `application/SpeechCoachAI/Infrastructure/`: Persistence (SwiftData, `LearnerRepository` split into `+Area` extension files, private files), Curriculum loader, Credentials (Keychain), Providers (gated online clients), Audio; v2: Speech.
- `application/SpeechCoachAI/Features/`: SwiftUI screens by area (Navigation/AppShell, Learn (shared topic-reading player and `LessonReadingPage`), Vocabulary, Recording, Progress, Rewards, Settings, Resources, SpeechLab (Lab: Talk, Speaking, Spelling, Timed tests, Videos, Voice; Pronunciation is a Lesson coach since Phase 12, with the say-it `SpeakAnswerView` in Learn/Exercises), Talk (AI conversation), Today, Feedback, Shared: `Theme.swift` tokens and `DesignSystem.swift` components).
- `application/SpeechCoachAI/Resources/`: curriculum JSON and audio, rewards catalog, asset catalog, and the layered `PolyGotAI.icon` Icon Composer document (source vectors and branding notes: `assets/branding/polygotai/`).
- `application/SpeechCoachAITests/`, `application/SpeechCoachAIUITests/`: tests. `application/Vendor/swift-fsrs/`: pinned FSRS-6. `application/.build/`: ignored build output and backups.
- `.github/workflows/release.yml`, `.github/scripts/`: release on merge of `development` into `main` (version and grouped notes).
- `tools/native/verify.sh`: build and run all tests. `tools/curriculum/`: content authoring and validation scripts. `tools/figma-local-helper/`: Figma plugin for the design kit (not app code).
- `assets/awards/v1/`: adopted award artwork.
- `docs/`: current docs (index: `docs/README.md`); `docs/history/v1/` holds archived v1 tickets, milestones, evidence and old specs (reference only).
- `.agents/`, `.ai/`, `.claude/`, `.codex/`, `tickets/`: engr-toolbox roles, skills, maps, ticket board and generated adapters.

## Core Operating Rules

- Prefer project docs as the source of product intent.
- Prefer exact source files as the source of implementation truth.
- Use maps, indexes, graphs, and summaries only for discovery.
- Read exact files before changing them.
- Make small, reviewable edits that follow the project structure.
- Run relevant verification before claiming success.
- Ask for approval before destructive, high-risk, production, secret, or migration operations.
- **Stay in your lane.** Edit only the files your phase handoff assigns to you. Don't touch `project.pbxproj` unless you are Claude.
- **Don't run all phases at once.** Do only the phases the owner has assigned to you. From 2026-10-25 phases with separate file scopes may run in parallel (now: Phase 5 Speech Lab by Codex and Phase 4 coach content by Claude). Each agent stays inside its phase's files; `AppShell.swift` is shared by region (see the Phase 2 and Phase 3 briefs).

## UI Rules

- Keep the approved visual design: Page 1 kit, `Features/Shared/DesignSystem.swift` components, coach artwork, three backgrounds. See the [UI reference guide](docs/product-specification/ui-reference-guide.md) and the [v2 overrides](docs/product-specification/ui-ux-design.md#v2-overrides--2026-10-25).
- **A screen never explains what the app can't do.** No "unavailable", "not scored", "not assessed" or "coming later" copy. Hide unfinished features instead.
- At most one short helper line under a screen title. Button labels are 1–3 words. Teaching text belongs in coach tips and feedback lines.
- Keep real error messages to one plain sentence.
- Support iPhone and iPad, Dynamic Type, Dark Mode and VoiceOver. Keep existing accessibility identifiers, or update the tests that use them.

## Documentation Rules

- **Append a log entry** to `Claude-Codex-Cursor-conversation.md` after every change set; never edit old entries.
- **Workflow (owner decision 2026-11-08): the engr-toolbox is the main workflow.** Work is tracked as tickets in `tickets/` (see `tickets/README.md`; skills `/to-tickets`, `/implement`, `/triage`, `/diagnosing-bugs`, `/update-docs`), and every ticket ends with evidence and a docs update (`/update-docs`; check with `node .ai/cli/bin/cli.mjs validate`). Reference the ticket ID in commits. `docs/development-plan/development-plan.md` stays the phase roadmap, and the shared log stays the agent handoff record; keep their status tables current. Existing phase work is not re-ticketed.
- Update the product spec, coach-tracks, Speech Lab, TDD, data-model and test docs when behavior or architecture changes. Claude owns docs; Codex lists doc impacts in its report.
- Handoffs and reports stay under one page. Evidence = test summary + a few screenshots in the phase folder.
- Record each future change of direction in `docs/history-version.md`.
- Don't add project-specific requirements to reusable template files under `.agents/`.

## Security Rules

- Do not commit secrets, tokens, private keys, credentials, or production configuration.
- Do not log sensitive input, provider responses, credentials, or private user data.
- Validate input at trust boundaries.
- Prefer least privilege for accounts, tokens, services, and automation.
- Tests use synthetic data and isolated stores. Never reset the owner's learner data. Never make live provider calls without owner approval.

## Git And PR Rules

- The project is a Git repository: `https://github.com/work-w-chrstnrpj/PolyGotAI` (branches `development` for work and `main` for releases, **public**; merging `development` into `main` publishes a release, see `docs/commands/commands.md`). Commit only when the owner asks. Never commit secrets, keys, learner data, `application/.build/` or signing files. Push only when the owner asks; don't force-push or rewrite history.
- Back up a file before a risky rewrite (copy it to `application/.build/backup/`).
- Do not revert other people's changes unless explicitly asked.
- Avoid destructive operations without explicit approval.

## Canonical AI Structure

The engr-toolbox is the canonical source (owner decision 2026-11-08). Edit `.agents/` first, then run `node .ai/cli/bin/cli.mjs sync` and `node .ai/cli/bin/cli.mjs validate`:

- `.agents/roles/`: 5 roles (Architect, Builder, QA, SDET, Reviewer).
- `.agents/skills/`: workflow skills (`/to-tickets`, `/implement`, `/diagnosing-bugs`, `/update-docs`, `/code-review` and more). List them with `node .ai/cli/bin/cli.mjs`.
- `.agents/workflows/`, `.agents/overlays/`: multi-role workflows and Mentor/Coach style.
- `.ai/`: maps and the toolbox CLI. `tickets/`: the board.

`.claude/` and `.codex/agents/` are generated adapters, not the source. The old external preset generator is no longer used.

## Overlay Usage

Use overlays to change response style without changing work ownership.

Examples:

- `Mentor ELI12: Explain this architecture.`
- `Coach: Critique this plan.`
- `Software Engineer + Mentor: Explain this feature design.`
- `Backend & Database Engineer + Mentor: Explain this API design.`
- `System Architect + Coach: Challenge this architecture proposal.`

## AI Role Usage Guide

Roles live in `.agents/roles/` (routing table: `.ai/maps/agent-map.md`).

- Architect: design tickets, boundaries, data model, ADRs.
- Builder: implements tickets test-first across UI, domain, persistence and docs.
- QA: manual, acceptance and regression testing; bug reports.
- SDET: test automation, strategy, flaky tests, CI test stages.
- Reviewer: read-only review of a diff.

## Skill Usage Guide

Skills live in `.agents/skills/`, one reusable workflow each. Choose the smallest skill that matches the task, then read exact source files before editing. Claude, Cursor, Copilot, OpenCode and Windsurf use generated copies; Codex uses `.agents/skills/` directly.

## Verification Commands

Main check (builds the app and runs all unit and UI tests; see `docs/commands/commands.md`):

```sh
bash tools/native/verify.sh 7535AD2C-F655-4F05-8C36-FE5E0A614902
```

Claude's parallel lane uses the iPhone 18 Pro Max simulator and `application/.build/ClaudeDerivedData`, so the two lanes never share a simulator or DerivedData. Toolbox validation checks only the AI folder structure, maps and tickets:

```sh
node .ai/cli/bin/cli.mjs validate
```

Design helper checks (not app behavior):

```sh
node tools/figma-local-helper/build.mjs
node tools/figma-local-helper/verify.mjs
```

## Current status — 2026-10-25

The detailed task list and status is [docs/development-plan/progress.md](docs/development-plan/progress.md). Update it at the end of each working session; progress reports to the owner are based on it.


- v1 code is in place and working: course catalog (57 lessons), lesson player, recording, vocabulary and FSRS review, Today, Progress, rewards, resources. v1 history: [docs/history-version.md](docs/history-version.md), with full records in `docs/history/v1/`.
- **Phase 0 (Declutter and setup)** is done, awaiting owner approval: [phase folder](docs/development-plan/phases/phase-0/). Phase 1 (exercise engine, A1 typed exercises, dictation button) is built and verified; waiting for owner play-test.
- Open owner decisions: [development plan → Open decisions](docs/development-plan/development-plan.md#open-decisions).
