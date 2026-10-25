# Next grouped allocation — 2026-10-24

Owner requested a new Grok group and a separate Codex group after checking SC-D014. This allocation changes work ownership, not acceptance or product policy.

## Checked previous return

The pasted SC-D014 text is its dispatch prompt. Grok's actual return is `sc-d014-grok-2026-10-23/README.md`; Codex's later [review/fixes/integration](sc-d014-integration-2026-10-24.md) supersedes that return's missing shared-integration list for the recorded local scope. All 14 final-source SHA-256 values in [verification.json](../testing/evidence/sc-d014-integration-2026-10-24/verification.json) matched current files on this check; all four recorded xcresult bundles exist. No unchanged application tests were rerun. Recorded final hosted iPhone checks passed 197 tests; phone/tablet UI evidence and its exact source boundaries remain in the evidence README. Missing reference playback/content, online/capability decisions and actual acceptance remain open. SC-D014 stays partially implemented.

## Ownership

| Owner | Group | Assignment state | Boundary |
| --- | --- | --- | --- |
| Grok | SC-D015 Generated practice and reporting | New prompt prepared for owner delivery; start unconfirmed | Six exact proposed source/test files and one report folder in [dispatch supplement](../../../development-plan/handoffs/grok-sc-d015-dispatch-2026-10-24.md) |
| Codex | SC-D017 Learning resource library | Selected; source-grounded planning begun, implementation not yet delivered | Resource domain/views/tests, existing shared storage/navigation/project integration, canonical docs and serial builds |

Codex reserves `application/SpeechCoachAI/Domain/LearningResource.swift`, `application/SpeechCoachAI/Features/Resources/ResourceLibraryView.swift`, `application/SpeechCoachAI/Features/Resources/ResourceEditorView.swift` and `application/SpeechCoachAITests/ResourceLibraryDeliveryTests.swift`. These files were absent at allocation. The queued Grok SC-D017 handoff is inactive while Codex owns this group. Grok's SC-D015 whitelist is disjoint; shared-file proposals return to Codex. Neither lane may overwrite the other or run overlapping builds.

## Codex SC-D017 plan and gates

Read SC-T039/168/169, SC-T028, technical intent, QA-11, UI guide and current ownership before selecting this group. Current source has no resource-library implementation; existing `LearnerRepository` owns durable learner storage. SC-T028 is pending and SC-T168 has unresolved destination/metadata/rights policy. Selecting this group does not close those prerequisites or approve a host list.

1. Reconcile exact prerequisite restrictions and produce a reviewable SC-T168 policy covering curated/personal sources, allowed URL forms/hosts, YouTube canonicalization, credential/scheme rejection, metadata/notes, external opening, thumbnails/rights and deletion/export. Use adopted constraints; keep genuine owner decisions explicit. No guessed curated destinations or automatic thumbnail fetching.
2. After the affected policy is settled, implement validated resource identity, normalized duplicate handling, local notes and accessible library/editor behavior using shared storage. Preserve failed saves/unsaved edits and learner epoch boundaries. No independent database, scraping, embedded video or inferred video contents.
3. Integrate deliberate external opening and invalid/unavailable/offline states without blocking core lessons. Inspect relevant Page 1 visuals and native HIG before UI implementation; retain exact references in the eventual implementation record.
4. Verify URL trust boundaries, duplicate normalization, missing thumbnails, cancellation/open behavior, failed writes, delete-all/epoch and persistence reopen with synthetic tests; run bounded integrated phone/tablet checks serially when changed code is ready.
5. Update canonical technical/data/testing/tracker records with delivered behavior and evidence. Keep physical/accessibility/content acceptance distinct. Only promote implementation-complete requirements to awaiting_testing.

No resource policy or application implementation was delivered by this allocation. Exact original ticket statuses remain unchanged; no live provider call, migration, release, learner reset or Git initialization is authorized by this document.

## Later SC-D017 activation

Owner explicitly requested implementation and selected public HTTPS links, including normalized YouTube destinations. [Implementation and evidence](sc-d017-implementation-2026-10-24.md) supersede the allocation-only state above. SC-T168/169 are awaiting_testing; parent/prerequisite/actual acceptance remains open. Grok SC-D015 dispatch confirmation is still not established by this Codex work.
