# Phase 0 — Declutter

**Goal:** the app reads like a learning app. Disclaimer and explanatory copy is gone, unavailable features are hidden, and Today shows one next step. Build friction is removed for later phases.

**Status:** Claude's lane done (project conversion, iPad navigation). Codex's declutter pass waits for Codex usage and owner approval.

| Lane | Work | Files |
| --- | --- | --- |
| Codex | Copy and hide pass; simplify Today ([handoff](codex-handoff.md)) | `Features/**`, `SpeechCoachAIUITests/**` |
| Claude | 1. Convert app and test groups in `project.pbxproj` to folder-synchronized groups (back up first; build must stay green). 2. Draft the Phase 1 Swift API (`AnswerChecker`, catalog fields, `ExerciseSession`) so Codex can start Phase 1 screens immediately after approval. | `project.pbxproj`, `Domain/`, `Infrastructure/`, `SpeechCoachAITests/`, `docs/` |

**Verify:** Claude reviews Codex's diff, runs both simulators, takes screenshots (Today, Learn, Speech Lab, lesson activity, lesson completion), and checks that existing learner data still opens.

**Done when:** the [phase gates](../../development-plan.md#phase-gates-what-done-means-for-every-phase) pass and the owner approves.
