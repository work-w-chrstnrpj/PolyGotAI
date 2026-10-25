# Today and Progress reliability batch · 2026-10-22

Owner instruction: finish Codex’s implementation part while Grok continues reward preparation. Existing SC-T051, SC-T052 and SC-T054 govern behavior. This pass does not close SC-T024 or activate rewards.

## Ownership and inspected inputs

Codex owns application source, tests, implementation evidence and canonical status/technical records. Grok owns new files only under `docs/development-plan/reward-preparation/`; Codex does not edit those drafts or incorporate proposed reward rules. No agent delegation and no Git initialization.

Mode A: execute the agreed plan. Exact source inspected: `Features/Navigation/AppShell.swift`, `Features/Progress/ProgressOverview.swift`, `App/LearnerStorageController.swift`, `Domain/PracticeRecommendation.swift`, `Domain/LearningEvidence.swift`, `Infrastructure/Persistence/LearnerRepository.swift` and their hosted/UI tests. Exact intent: SC-T051/052/054, UI reference guide, daily-evidence record, TDD, existing native HIG buttons/text-input guidance.

## Changes

1. Today’s primary action follows its resolved lesson/review/Speech Lab suggestion. Explicit alternatives select today’s choice without requiring entry into the destination. Opening a destination does not silently clear an override. Choosing the grounded suggestion clears it explicitly. Failed choice saves show an error and preserve the prior selection.
2. Confidence editing is limited to 280 Unicode scalars, autosaved after 400 ms and flushed on submit/leave/background. Unsaved text and save failure remain in controller memory through navigation/lock, with a visible retry. Clearing a saved note remains clear on reload. A store epoch prevents a pending pre-reset draft from recreating deleted data; this adds no persistent field or native migration.
3. Today and Progress reload on foreground, significant time and timezone changes. Recommendation day and calendar week are recomputed. Week intervals are half-open so an event exactly at next week’s boundary is counted once.
4. Verification: full hosted suite, injected save failures and reset, midnight/timezone and week-boundary fixtures, Today contrast and new phone/tablet UI override/note recovery journeys. Original physical/manual/provider/learning acceptance remains separate.

## UI handoff

Retain Page 1 file `B1A9qEN1B7I3NJKISX39Dx`, dated 2026-10-17 `speechcoach-kit-03.png` previously inspected in this chat. Recipes T01 Today `2:37969`, T09 Progress `2:38732`; Button `2:40308`, Input `41:1127`, Status `41:1155`. Existing KitCard, KitPrimaryButtonStyle, semantic colors and system controls. Today now emphasizes the actual next action, with secondary native choice buttons; no new artwork or motion. Confidence has a labeled field, saved/error status and retry. Existing compact tabs/regular sidebar and scrolling remain. No fresh live Figma/measurement/cloud-sync claim.

## Evidence and remaining gates

[Execution evidence](../testing/evidence/daily-flow-2026-10-22/README.md). Owner/device accessibility and real learning acceptance are not inferred from simulator checks. No live provider request, reward implementation, schema migration or physical installation is part of this pass.

## Executed outcome

Seven existing Swift files changed. Full hosted regression passed 95/95. The new UI recovery journey, Today contrast and larger-text/accessibility checks passed on both phone and tablet simulators. Screenshots were actually reviewed. No reward drafts, reward policy sections or assets were edited by Codex. No physical installation or ticket closure is inferred; original owner/device/manual/provider/learning acceptance remains open.
