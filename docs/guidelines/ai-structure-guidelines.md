# AI structure guidelines

The project uses the engr-toolbox (v3.4.0) as its main workflow, roles and skills (owner decision 2026-11-08). Project requirements live in `AGENTS.md` and `docs/`, not in the portable roles and skills.

## Installed assets

- Five roles in `.agents/roles/`: Architect, Builder, QA, SDET, Reviewer. Generated adapters are in `.claude/agents/` and `.codex/agents/`. The six roles from the earlier external preset were retired (backup: `application/.build/backup/old-roles/`).
- Mentor and Coach style overlays in `.agents/overlays/`; workflows in `.agents/workflows/`; skills in `.agents/skills/`.
- Edit canonical `.agents/` files, not generated adapters; then run `node .ai/cli/bin/cli.mjs sync` and `validate`. Tickets live in `tickets/`.

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
