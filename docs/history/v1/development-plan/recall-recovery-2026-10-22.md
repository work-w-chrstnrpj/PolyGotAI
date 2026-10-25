# Offline recall recovery batch · 2026-10-22

Owner instruction: “Can we now implement more group tickets?” This is the next bounded implementation pass over SC-T048–SC-T050 under SC-T023. The daily suggestion/evidence implementation remains recorded separately. Grouping permits integration work; it does not waive original acceptance or change rewards/provider gates.

## Source-grounded plan

Mode A, existing ticket execution. Inspected: exact SC-T048/049/050 and SC-T055/057 prerequisites, TDD vocabulary/scheduler contracts, UI/UX decisions and QA-04/05/34/36/37; `VocabularyRecall.swift`, `VocabularyRecallView.swift`, `LearnerRepository.swift`, `CustomTopicViews.swift`, existing domain/persistence/UI tests. No Git repository exists; no Git initialization.

Observed gaps: only revealed cards were saved; hidden text vanished at restart. UI rating calls used a fresh UUID by default, weakening repeat-delivery identity. Resuming at an index could skip preceding due cards. Optional spoken practice had no distinct self-report mode.

1. Keep a stable event UUID from hidden draft to committed rating; persist optional UUID/mode on existing open recall. Preserve old document decoding and the existing SwiftData schema.
2. Save unfinished text/mode after a short typing pause and flush on leave/background. Save exposure before revealing; freeze first response and mode at the persistence boundary. Resume the open card first, followed by all remaining due cards.
3. Offer Think / Write / Say. Say is explicitly unrecorded, learner-reported self-check, with no microphone capture, transcript, pronunciation score or speech-completion credit. Rating remains explicit; failed recall is Again, Hard is successful effort.
4. Bind duplicate events to the same sense; commit rating and schedule once. Failed writes retain the previous draft/history. Clearing a draft requires its own event ID.
5. Verify full hosted regression and focused phone/tablet UI recovery, larger-text and collection/enrollment paths. Update evidence, technical/data docs and dispatch/tracker records.

Roles covered serially: software, UI, persistence, QA and documentation. No agent delegation. No live call, credential operation, migration or deployment required. Existing device installation is unchanged by this implementation pass.

## UI handoff

Page 1 `B1A9qEN1B7I3NJKISX39Dx`, snapshot 2026-10-17 `speechcoach-kit-03.png` actually opened. T08 Vocabulary `2:38663`, T05 Activity `2:38252`, T06 retry `2:38294`; existing KitCard, Input `41:1127`, Status `41:1155`, Button `2:40308`. Reuse Kit semantic tokens and system fonts. Native segmented picker for three short choices; native menu at accessibility text sizes. Existing scroll/navigation shell, multiline labeled optional input, keyboard dismissal on reveal/mode change, no new artwork or motion. No fresh live Figma/master measurement or cloud-sync claim. Apple HIG mirror articles on segmented controls and text fields read; current official pages were checked but the web renderer could not read their Markdown content.

Normal/empty/waiting/revealed/saved/error/restart states stay explicit. Unavailable storage produces a recovery message; a failed exposure save keeps the answer hidden. No answer shown before explicit reveal. See [verification evidence](../testing/evidence/recall-recovery-2026-10-22/README.md).

## Remaining original acceptance

SC-T048/049/050 and parent SC-T023 remain in progress/open pending their full acceptance. Provider-gated optional typed sentence coaching, recorded spoken recall if later selected, manual VoiceOver, physical-device walkthrough and broader learning evidence remain separate. No reward defaults or economic choices are invented.

## Executed outcome

Implemented in nine existing Swift files across domain, repository, vocabulary UI and tests. No new module or native project target. Final hosted regression passed 92/92; both review UI journeys passed on phone and tablet simulators, including automated revealed-controls accessibility and larger-text behavior. A final legacy-only identity repair is covered by the full final hosted suite; exact source checkpoints and earlier failures/retests are preserved in evidence. Existing physical builds were not updated. No ticket status is promoted to done without original full acceptance.
