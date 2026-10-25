# SC-D004 — review fixes, 2026-10-23

Owner explicitly requested both findings from the read-only review be fixed. This follow-up transfers the bounded AppShell.swift and DailyProgressDeliveryTests.swift edits to Codex after Grok's delivery. Codex also owns LearnerStorageController.swift and BootstrapLaunchTests.swift. Grok's report/domain source and other reserved files are unchanged; the original handoff describes the earlier concurrent lane.

## Changes

The shared LearnerStorageController now owns practiceGoalDraft and its save-error message. Today reads/edits/saves through that controller. Dirty/failed choices survive Today view destruction during regular-width sidebar navigation, including an attempted clear that could not be saved. Successful retry updates the persisted preference and clears the error. Reload/reset uses the learner epoch to discard earlier drafts; a stale save is rejected before writing.

Remove the parent today.goal identifier, which propagated to child controls. The picker, status, save, clear and error keep their individual today.goal.* identifiers. The preference UI test now queries those identifiers directly and switches Progress → Today before saving an unsaved selection. The native menu choice still excludes the separate Speech Lab navigation button.

No recommendation ranking, learner document field, SwiftData schema, provider behavior or visual layout changes. Existing Page 1 T01/T02 and shared native control patterns remain the reference. This follows the already inspected UI reference; no new assets or live Figma inspection.

## Verification and status

[Exact evidence](../testing/evidence/sc-d004-review-fixes-2026-10-23/README.md) records actual runs. Hosted controller fixtures inject failed saves/clears, repeated reloads, successful retry and reset-before-reload versus reset-before-save. UI verifies an unsaved selection survives actual destination changes and all named controls can be reached by identifier. Failed-save fault injection is hosted coverage; the UI journey does not inject a storage failure.

SC-T051 stays in_progress for its separate reviewed specialist/difficulty mapping gap. SC-D004 remains partially implemented; this repair does not close original physical/learning/content/parent acceptance.
