# AI structure guidelines

The project uses the Codex/fullstack preset from `ai-project-structure-template` as reusable guidance. Project requirements live in `AGENTS.md` and `docs/`, not in the portable roles and skills.

## Installed assets

- Six roles in `.agents/roles/`: Software Engineer, System Architect, Frontend UI/UX Developer, Backend & Database Engineer, SQA Engineer, Technical Documentation Specialist. Codex adapters are in `.codex/agents/`.
- Mentor and Coach style overlays in `.agents/overlays/`; workflows in `.agents/workflows/`; skills in `.agents/skills/`.
- Edit canonical `.agents/` files, not generated adapters. The generator is external; see [commands](../commands/commands.md#ai-preset-external-generator).

## Team (v2)

- **Claude:** senior engineer and reviewer. Plans phases, owns domain, content, build config and docs, and reviews and verifies all work.
- **Codex:** implementing engineer. Owns SwiftUI screens and UI tests within each phase's handoff.
- The lane split and parallel-work rules are in the [development plan](../development-plan/development-plan.md#who-does-what).

## Working rules

1. Read `AGENTS.md`, the development plan, and the current phase folder.
2. Stay inside your lane's files. Ask for changes to other files.
3. Read exact source before editing. Run `tools/native/verify.sh` before reporting.
4. Report briefly: files changed, test results, screenshots, open questions. State failures plainly.
5. Update the docs that your change makes wrong (Claude owns docs; Codex lists doc impacts in the report).
