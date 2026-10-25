# SC-D004 — Codex integration of Grok delivery

The owner requested a full SC-D004 handoff with disjoint ownership. [Grok's report](../../../development-plan/sc-d004-grok-2026-10-23/README.md) subsequently arrived in its reserved folder with domain/Today changes and a new test file. Codex integrated only the shared files it owns: pass `goal: stored.practiceGoal` into learningBoard's PracticeFacts and register DailyProgressDeliveryTests.swift in the hosted test target. No Grok-owned source or report was edited.

The durable optional practice destination uses the already supplied repository API/JSON field. Available same-day choice and supported difficulty remain ahead of due reviews; due reviews remain ahead of preference fallback. No preference preserves original ranking. Unsupported destinations are explained. Clear and delete-all remove the preference; epoch protection and failure drafts remain explicit. Progress receives the same suggestion through its existing board.

Codex added the focused preference/restart/clear/unavailable-destination UI journey in its exclusive BootstrapLaunchTests.swift. [Combined verification](../testing/evidence/sc-d003-2026-10-23/README.md) records the actual result and checkpoints. This is integration evidence, not qualified content, learner effectiveness or physical acceptance.

SC-T051 remains in_progress because reviewed specialist/difficulty task mappings are still missing; available generic destinations do not establish specialist training. SC-T052/054 stay awaiting_testing, and SC-T024's SC-T053/reward dependency remains open. SC-D004 remains partially implemented. The handoff is now delivered, not merely prepared; the earlier handoff text describes its dispatch checkpoint.


## Runtime selector finding

On both simulators, the parent `today.goal` accessibility identifier propagates to the card's children, masking the source-level `today.goal.picker/save/clear/status` identifiers. All controls remain exposed with their visible labels. Codex's UI test uses those labels and records this discrepancy rather than modifying Grok's AppShell.swift. Grok should remove the parent identifier or explicitly contain the parent in a later owned edit if stable child identifiers are required. This finding is about automation identity, not proof that VoiceOver or the full accessibility matrix passed.


Final verification: all 134 combined hosted test functions pass on each simulator, and the preference save/restart/clear/unavailable-fallback UI journey passes on both in preference-v4.xcresult. Menu selection is constrained to exclude the identically labeled navigation button. Codex preserved all prior failures and changed only its own UI test selectors; see the linked evidence. SC-D004 remains partially implemented for the reviewed specialist/difficulty-mapping scope, with original physical/manual/content/parent gates intact.


## Owner-requested review fixes

The owner subsequently authorized Codex to fix draft loss on iPad navigation and the identifier propagation finding. [Exact changes and evidence](sc-d004-review-fixes-2026-10-23.md) supersede the earlier identifier workaround and source-ownership checkpoint only for this bounded follow-up. The shared controller now retains the draft/error; the parent identifier is removed and tests use individual control identifiers. Grok's original report is preserved as a historical delivery record.
