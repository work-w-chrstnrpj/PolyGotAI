# SC-D014 review and local integration — 2026-10-24

Owner authorized reviewing, fixing and integrating Grok's returned communication/articulation work. [Grok's original return](../../../development-plan/sc-d014-grok-2026-10-23/README.md), candidate manifest and harness remain historical artifacts. Codex now owns integration of the four returned Swift files and shared application files. No unreviewed candidate was added to app resources, and no online request was enabled.

## Confirmed review fixes

1. A changed task before the first response previously reused a recording slot made for the old task. A task revision with a pending recording now starts a distinct attempt and rejects the old callback. Reopening the same unfinished slot reuses its ID for recovery; completed or different-question slots get new IDs. Routine participation is not copied into another task.
2. Text discard previously retained the learner-entered framework name in both task and draft. It now clears that field alongside purpose, scaffold, source text, responses, feedback and self-review. View drafts are cleared and final archives have an empty draft dictionary. Private recording prompt text is cleared independently when text is declined, including when audio is retained.
3. Retry previously allowed a new response while feedback for the old response was unresolved. It now refuses until that request is explicitly resolved/cancelled. First responses remain intact, retry links remain explicit and an earlier feedback card is cleared when a new response is saved.
4. Unsupported-score checks previously omitted feedback hints and retry prompts. Both now pass the same validation as other feedback prose. This is bounded text-content validation, not a claim of calibrated assessment or a live-provider safety result.
5. Delimiter-joined task fingerprints could collide when purpose/framework text contained the delimiter. Identity now uses length-prefixed fields; source/version archive keys use the same unambiguous construction.
6. Ending a stopped practice previously hid retention controls. Both stopped and ended states now offer independent retention choices. The reference card no longer claims playback is connected when only an identifier exists. Validated feedback hints and retry instructions are now rendered alongside each action.

## Connected behavior

The real project registers `CommunicationPractice.swift`, `CommunicationPracticeView.swift`, `DeliveryFeedbackView.swift` and `CommunicationDeliveryTests.swift`. Speech Lab opens Communication practice, with a standalone task and exact lesson-version links. Learn's Extra practice menu opens the same composition using the displayed lesson version, including archived v2 content. Lessons without the existing extra-practice menu receive a native toolbar entry. Optional communication practice does not finish, score or mutate a course, vocabulary schedule or reward account.

Both entry points use the same exact-source local recovery key, independent of the entry path. A saved first response, retry, credit UUID, draft, task/support and recording slot therefore resume rather than duplicate when reopening that source through the other route. Different lesson versions have different keys. This applies to explicitly retained local work; unsaved in-memory practice does not become a durable progress event. Explicit Start a new practice removes the previous recovery record before resetting that source's session.

The existing native recorder handles capture/replay/re-record/take selection/self-review. Recording completion must match the independent session and one-use response slot. A visible confirmation identifies the attached response. `communicationTurn` is included in independent recorder recovery/return and excluded from one-shot online coaching and course completion. Optional `SpeakingProvenance.communicationSource` freezes exact lesson/content/objective/sense identity. Recorder level metadata uses the exact source level, or Unassessed for standalone work; neither is an assessment. The independent session UUID is not a claimed course journey. The recorder preserves its separate audio-retention choice. A UUID reference is participation/ownership evidence, not permission to upload or proof that audio was retained.

Declining audio uses existing private-file soft-delete/purge APIs for all recordings owned by this independent session, including replaced or abandoned slots and its Recently Deleted recordings. Supplied foreign visible references are rejected before mutation; unrelated sessions are preserved. Declining text clears private recorder prompts independently of audio. Failed removals remain visible and do not report successful final retention.

## Recovery and storage

`CommunicationPractice` is Codable. The existing optional `SpeakingPracticeArchive` gains an optional communication payload; no SwiftData model, schema migration or second learner store is added. The repository validates a matching payload and exact-source key. Missing communication/provenance fields continue to decode for older conversation/interview documents and recordings.

Work starts in memory. Keep draft for 24 hours opts into protected local storage using the existing recovery controls. Explicit save/resume extends expiry; keystrokes/background saves do not extend it. Existing maintenance/read removes expired archives. Saved form fields include unfinished response and self-review drafts. Reopening an unresolved request marks unknown outcome, with no automatic retry or send. Save/removal requires the learner epoch; delete-all invalidates stale screens. Failed writes preserve the previous successful archive and show retry UI. Final retention stores a sanitized snapshot without temporary expiry, with no unsubmitted form-draft dictionary.

This is one latest recovery record per exact lesson source, plus a standalone record. It is not a transcript library. Actual retained audio playback/deletion remains in existing History/Recently Deleted. New source-linked archives do not modify existing v2/v3 course journeys or curriculum resources.

## Remaining original requirements and status

| Ticket | Current result | Remaining work |
| --- | --- | --- |
| SC-T036 | Local composition integrated | All child outcomes, original prerequisites and real acceptance |
| SC-T154 | Concrete eight-item manifest proposal preserved | Owner-selected release subset/volume, framework/editorial/asset/rubric/duration decisions; proposal is not adopted |
| SC-T155 | Organization/listening/interaction candidates and local authoring routes | Qualified reviewed teaching/rubrics/publication and required content depth |
| SC-T156 | Production/expression candidates and local recording/self-review | Reviewed sound targets, reference assets/rights and rubrics |
| SC-T157 | Shared local entry/recovery/recorder integration | Reviewed-reference playback/content integration, configured daily/Home/Activity integration and all original prerequisites/actual acceptance; no reference-audio adapter or global participation/reward integration completion claim |
| SC-T158 | Precise sound requests fail closed; no TTS | Adopted capability/release record and validated reference/assessment support; existing proposal is not approval |
| SC-T159 | Bounded feedback validation and honest local feedback UI | Adopted online text contract/transport and validated audio capability if selected |
| SC-T160 | Fixture verification contributes limited evidence | Original unfamiliar/delayed/qualified/provider/physical/accessibility acceptance |

SC-T036 and SC-T154–159 are in_progress. SC-T160 remains pending. No ticket is moved to awaiting_testing while its original code/content/decision work remains incomplete. Qualified review, actual acceptance and prerequisite closure stay separate from local engineering success.

## UI handoff

Visual input: retained Figma file `B1A9qEN1B7I3NJKISX39Dx`, Page 1 `0:1`, root `41:1074`, 2026-10-17 local snapshot. The page-template screenshot `speechcoach-kit-03.png` was opened. T07 entry `2:38336`, T05 activity `2:38252`, T06 retry `2:38294`, Record `2:38407`, Take review `2:38472` and independent Save `2:38610` guide composition. Content row `41:1105`, Input `41:1127`, Status `41:1155`, Button `2:40308` and Switch `2:40309` map to existing Kit rows/cards/styles and native controls. No Figma write, artwork generation or matched-viewport fidelity claim.

Native scrolling, menus, keyboard editing, independent retention and error/retry states use existing styles and selected background. Both compact/regular behavioral checks and screenshots are recorded in [verification evidence](../testing/evidence/sc-d014-integration-2026-10-24/README.md). Full VoiceOver, all themes/text sizes, physical microphone/routes and learning acceptance remain separate. No sound, confidence, emotion, eye contact, clinical, body-language or CEFR assessment is inferred from a transcript or self-review.

Current official Apple [text-field guidance](https://developer.apple.com/design/human-interface-guidelines/text-fields) and [accessibility guidance](https://developer.apple.com/design/human-interface-guidelines/accessibility) were checked on 2026-10-24 via their Markdown endpoints. Persistent field labels and native editing follow those inputs; this source check does not prove runtime accessibility conformance.
