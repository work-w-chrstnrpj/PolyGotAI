# Project structure (v2)

```text
SpeechCoachAI/
  AGENTS.md                 rules for AI engineers (Claude, Codex)
  README.md                 overview
  application/              Xcode project, app source, tests, vendored FSRS (see tdd.md for folder roles)
    .build/                 ignored local build output, verification runs, backups
  assets/awards/v1/         adopted award artwork, prompts, manifest
  docs/
    history-version.md      direction changes v0 → v1 → v2
    product-specification/  product spec, coach tracks, Speech Lab, curriculum outline, UI design and rewards
    tdd/                    technical design
    development-plan/       development-plan.md (the tracker) + phases/phase-N/ (brief, Codex handoff, report, evidence)
    database/ api/ contracts/ testing/ deployment/ diagrams/ commands/ guidelines/
    history/v1/             archived v1 tickets, milestones, evidence, old spec/TDD (reference only)
  tools/
    native/verify.sh        build + test on a simulator
    curriculum/             Python authoring and validation for catalog/track JSON
    figma-local-helper/     Figma plugin used for the design kit (not app code)
  .agents/ .ai/ .codex/     reusable AI roles, skills, maps and Codex adapters (from the external preset)
```

Not present and not planned now: `service/` (no backend), `shared/`, top-level `tests/`.

App source folders are described in the [technical design](../tdd/tdd.md#source-layout).
