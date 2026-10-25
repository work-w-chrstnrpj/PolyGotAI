# SC-T019 lesson catalog evidence — 2026-10-21

## Current implementation — 2026-10-22

The bundle-first loader validates all 57 lesson records and hashes required audio. Immutable content is now cached once per process. This is structural availability; full content and device acceptance remain separate. See [first-loop stabilization](../first-loop-stabilization/README.md) for current source, UI handoff, results and limits. The ticket remains in_progress.

## Historical checkpoint below — superseded where the current implementation differs

The ticket stays **in_progress**. The loader can validate a bundled catalog. The build now includes ready lesson `intro-01`. A2–C2 stay empty.

## What the code does

- Reads `CurriculumCatalog.json` from the app bundle or a test directory. It does not download or copy curriculum into learner storage.
- A lesson is ready only when the pack schema is supported, both review and rights references are non-empty, and every required activity has its text or a matching audio file.
- An empty review reference keeps the whole pack unavailable. A bad listening file blocks that lesson only.
- Reserved prompts are omitted from the practice list. Missing listening audio is not treated as reading.

## Check actually executed

`SpeechCoachAITests/CurriculumCatalogTests` — 5 tests passed on iPhone 18 Pro simulator, iOS 27, in `application/.build/curriculum-catalog-v1.xcresult`.

## Still open

Reviewed INTRO-01 text, answers, reference audio, and rights. Lesson play, resume, and completion (SC-T020). Physical device and airplane-mode walkthrough. Qualified educator review remains blocked on SC-T006.
