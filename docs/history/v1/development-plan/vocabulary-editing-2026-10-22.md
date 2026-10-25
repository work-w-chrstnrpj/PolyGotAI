# Personal vocabulary editing and search · 2026-10-22

Owner authorized continued implementation and concurrent isolated Grok preparation. Mode A: bounded follow-up to SC-T165/SC-T048. Codex owns application source/tests and canonical records. Grok receives [a new content preparation assignment](../../../development-plan/handoffs/grok-intro-content-2026-10-22.md), with new files only under intro-content-preparation/. Reward drafts remain proposals.

## Source-grounded changes

Inspected CustomVocabulary.swift, CustomTopicViews.swift, CustomVocabularyTests.swift, repository custom-topic transactions and existing UI test helpers. Search previously matched collection lemmas and topic titles only, omitting meanings, subtopics and words not enrolled in collection. Refresh after adding/editing a word replaced unsaved topic metadata. Domain rename also changed title before validating subtopic (repository copying prevented a committed partial write, but the domain mutation was not atomic).

Implement local whitespace-separated, case/diacritic-insensitive search across meanings and topic content; show result counts, no-results recovery and clear action. Preserve unsaved topic metadata when word content refreshes; explicit save/discard establishes a new baseline. Validate both rename fields before mutation. Draft preservation is in the mounted editor, not a claim of durable crash recovery. No schema or provider changes.

## UI inputs and verification

Read the UI reference guide and inspected speechcoach-kit-03.png. Retain T08 2:38663, Input 41:1127, Status 41:1155 and existing Kit/native text controls; no redesign. Consulted local Apple searching guidance and its official https://developer.apple.com/design/human-interface-guidelines/searching page (automated response requires JavaScript). No fresh live Figma sync claim.

Run hosted regression plus the new isolated UI journey on phone and tablet simulators. Cover search of unenrolled meanings, accents/multiple terms, invalid rename atomicity and word-save refresh retaining topic edits. Physical acceptance remains separately recorded. Results will be linked from the ticket after execution.

## Completed verification — 2026-10-23

98 hosted tests passed on phone simulator; the focused UI journey passed on both phone/tablet simulators. Initial test compilation and tablet-selector failures were corrected and retained in [evidence](../testing/evidence/vocabulary-editing-2026-10-23/README.md). Both screenshots inspected. SC-T165/048 are awaiting_testing, not done. No physical build installation in this batch. Grok handoff is prepared, not dispatched through a connected service.
