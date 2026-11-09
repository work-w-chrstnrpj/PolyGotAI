# ADR-0008: engr-toolbox is the main workflow, roles and skills

**Status:** accepted
**Date:** 2026-11-08
**Ticket:** owner decision in chat (no ticket)
**Input:** none
**Supersedes:** none

## Context

Until now work ran as numbered phases in `docs/development-plan/` with an agent log, and AI roles and skills came from an external preset generator. The engr-toolbox was installed on 2026-11-08 and adopted through ticket #2, which left two overlapping systems with conflicting rules (for example "no new ticket IDs").

## Decision

The engr-toolbox is the single source for workflow, roles and skills. Work is tracked as tickets (GitHub Issues, per `docs/agents/issue-tracker.md`), ends with evidence and `/update-docs`, and uses the toolbox's five roles. The six roles and three workflows from the old preset were retired (backups in `application/.build/backup/`). The development plan stays as the phase roadmap and the shared log as the agent handoff record.

## Alternatives

- Keep both systems: two trackers and two role sets would drift apart.
- Re-ticket all past phase work: no value; past phases stay as history.

## Consequences

Edit `.agents/` then run `node .ai/cli/bin/cli.mjs sync` and `validate`; `.claude/` and `.codex/agents/` are generated. New work needs a ticket and its ID in commits. `AGENTS.md` carries the rule. Agents and docs that name the old roles must be updated when found.
