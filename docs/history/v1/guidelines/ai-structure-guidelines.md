# SpeechCoachAI AI Structure Guidelines

The project adopts the Codex/fullstack preset as reusable contributor guidance. SpeechCoachAI product requirements live in AGENTS.md and docs, rather than portable template roles/skills.

## Installed assets

Six role owners: Software Engineer, System Architect, Frontend UI/UX Developer, Backend & Database Engineer, SQA Engineer, Technical Documentation Specialist. Canonical prompts are under `.agents/roles/`; generated Codex adapters under `.codex/agents/`. Mentor and Coach are style overlays. Reusable skills and workflows under `.agents/` provide planning, execution, review, testing and documentation procedures.

Read exact installed guidance before invoking it. Do not claim Product Manager, Security Engineer or DevOps roles are installed; coordinate those responsibilities with the available owners or explicitly adopt another profile later.

## Project maintenance

1. Read project intent and the relevant plan item.
2. Select the smallest owning role and skill.
3. Use maps for discovery and exact files for truth.
4. Keep edits within scope, preserve others' changes, and run available verification.
5. Update affected project docs and report unresolved choices honestly.

Canonical reusable assets are edited before generated adapters. The generator is in the external template repository; this project has no local sync scripts. Use the [commands](../commands/commands.md) preview and validation instructions. Review template changes and retain project-owned docs/maps; do not copy SpeechCoach-specific requirements into reusable role/skill sources.

## Evidence and status

Design drafts are not implemented contracts. Do not invent build/test/deploy commands, mark milestones complete without evidence, or use preset validation as app acceptance. See the testing specification for planned functional checks.
