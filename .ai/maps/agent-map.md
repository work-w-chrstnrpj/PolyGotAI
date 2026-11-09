# SpeechCoachAI Agent Map

Project-owned routing for the engr-toolbox roles (the main roles since 2026-11-08).

| Task | Owner |
| --- | --- |
| Design: boundaries, data model, flows, API, ADRs | Architect |
| Implementation across UI, domain, persistence and docs, test-first | Builder |
| Manual, exploratory, acceptance and regression testing; bug reports | QA |
| Automation, test strategy, CI test pipelines, flaky tests | SDET |
| Read-only review of a diff against standards, spec and ADRs | Reviewer |

Use the smallest matching skill from `.agents/skills/`; Mentor/Coach overlays change style only. Work is tracked in `tickets/`. `.claude/` and `.codex/agents/` are generated adapters: edit `.agents/`, then run `node .ai/cli/bin/cli.mjs sync`. Product work begins with AGENTS.md, TDD and the matching ticket or plan item.
