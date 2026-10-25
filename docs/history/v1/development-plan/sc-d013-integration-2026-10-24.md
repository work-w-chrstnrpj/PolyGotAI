# SC-D013 local integration — 2026-10-24

Owner requested connecting the repaired Grok delivery and confirmed SC-D014 was sent to Grok. Codex owns the SC-D013 integration; Grok's four named Communication source/test files and report folder are left untouched. This implements local solo practice only. The open SC-T148 online contract, reviewed workplace publication and actual interactive/qualified/physical/learning acceptance remain separate.

## Connected behavior

Speech Lab now links to Conversation practice and Interview practice, using the existing selected presenter without changing learner defaults. The registered domain/views/tests compile in the real application target. Learners can prepare, submit local text turns, stop/end, retry, self-review, choose independent text/audio retention and start a new practice. Interview follow-ups quote the submitted answer and preserve the fictional/personal choice. Online partner/follow-up buttons remain explicitly disabled; no online or realtime feature is claimed.

Recorded turns open the existing native recording/replay/take-selection/self-review flow. Each launch carries an exact private prompt, session ID and turn/question slot ID. Returned completion must match both session and slot; interview results are consumed once and cannot move to another answer. These recordings carry `conversationTurn` or `interviewTurn` provenance and no source-course completion. Independent-turn screens hide one-shot online coaching; the conversation contract cannot be bypassed through the recorder. Recovery inside an independent recorder is restricted to the same slot. Saved interview recorder slots survive an opted-in draft and are reused only for the same unfinished attempt/question.

Keep recording in the recorder decides whether an actual audio file survives; the independent practice's later decline removes its own saved audio through existing soft-delete/purge APIs. A reference alone does not restore audio that was declined in the recorder. Existing History/Recently Deleted continues to own retained audio playback/deletion. Actual microphone/route/retention acceptance remains distinct from synthetic simulator checks.

## Explicit recovery and privacy

A practice starts in memory. Keep draft for 24 hours explicitly stores the current session and form draft in the existing protected preferences document. The deadline is extended only by an explicit keep/resume interaction, not each keystroke or background save. Subsequent opted-in changes and background/leave saves preserve the same expiry. On reopening, saved session state, task IDs, conditions and drafts are restored; any unresolved request becomes unknown outcome and is never resent. Expired archives are removed by repository maintenance/read. No automatic cloud operation occurs.

Final retention writes the sanitized session and an empty draft dictionary. Declining text clears setup/preparation/role, answer/follow-up/technical/self-review text and local fields; post-retention edits are disabled/refused. Audio remains independent. Failed writes surface a retry message and preserve the last successful repository record; no success is shown for a failed save. An archive write/removal requires the learner epoch; stale views cannot repopulate deleted learning data. A new practice starts only after removing the previous archive successfully.

This is a latest-session recovery slot per mode, not a new multi-session transcript library. Prior durable audio remains in the existing History until explicitly deleted. No SwiftData model/schema change, external service, dependency or Git repository was introduced. Optional `speakingPracticeArchives` decodes absent on old preference documents.

## Source changes

- Real Xcode registration of Grok's five source/test files.
- Conversation/InterviewSession Codable snapshots, `SpeakingPracticeArchive`, one-use interview recording slots and interrupted-request resolution.
- Existing LearnerRepository archive read/write/removal/expiry and epoch checks; own-session audio cleanup through existing APIs.
- Existing LearnerStorageController ephemeral recorder return; RecordingView exact completion dispatch and no online one-shot entry for independent turns; RecordingController restricts independent recovery to its slot.
- Conversation/Interview views connect local recorder sheets, explicit draft/recovery and final retention; shared persistence controls reuse Kit/native components.
- SpeechLabContent links and integrated hosted/UI tests in existing files.

The [earlier repair report](sc-d013-fixes-2026-10-24.md) and original Grok return remain unchanged historical evidence. [Current verification](../testing/evidence/sc-d013-integration-2026-10-24/README.md) owns actual build/test results, failures/retests and limits.

## Remaining original ticket work

SC-T150/151 local code is connected, but their complete original scope still requires adopted SC-T148 choices and the relevant online reply/feedback behavior, actual acceptance and prerequisite closure. They remain in_progress, not awaiting_testing. SC-T148 contract choices, SC-T149 qualified scenarios/rubrics, SC-T152 acceptance and SC-T153 realtime decision are not closed by this integration. No fabricated review signature, validated pronunciation, complete AI conversation or learner result is claimed. SC-D014 is concurrently dispatched to Grok; this integration does not authorize edits in that lane.

## UI input and native handoff

- Scope: SC-T150/151 local preview, following their original retention/modality boundaries; no online or published scenario activation.
- Visual input: retained file `B1A9qEN1B7I3NJKISX39Dx`, Page 1 `0:1`, root `41:1074`, dated local 2026-10-17 snapshot. The page-template screenshot `speechcoach-kit-03.png` was opened; this is not a new live Figma/cloud inspection.
- Closest recipes: T07 mode entry `2:38336`, T05 prompt/activity `2:38252`; reuse existing Record `2:38407`, Take review `2:38472` and independent Save `2:38610` through the current recorder. Content row `41:1105`, Input `41:1127`, Status `41:1155`, Button `2:40308` and Switch `2:40309` map to existing KitContentRow, native editing, AvailabilityCard, Kit button styles and native toggles. Existing Kit colors/type/spacing and native navigation remain the implementation inputs; no new artwork is needed.
- Actual source: SpeechLabContent links, ConversationPracticeView/InterviewPracticeView, shared SpeakingPracticePersistence/PracticeRetentionForm and existing RecordingView. Normal/empty/offline/closed states, explicit recovery/error messaging, retry and interrupted-request handling are represented; no simulated online success state appears in the product UI.
- Compact iPhone and regular iPad behavioral runs cover keyboard entry, scrolling, relaunch and recording sheets. Rendered screenshots were inspected separately from the retained design reference. New controls use native labels and existing styles; full matched-viewport fidelity, larger text, all appearances/backgrounds, VoiceOver, contrast and Reduce Motion acceptance remain unperformed for these screens. Simulator navigation/recording evidence does not close those gates.
