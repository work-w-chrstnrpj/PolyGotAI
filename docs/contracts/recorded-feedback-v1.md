# Recorded Introduction Contracts — v1

> **v2 note (2026-10-25):** kept for online AI coaching, which is now Phase 6 in the [development plan](../development-plan/development-plan.md). Sections that mention v1 tickets, Speech Lab trainers or delivery groups are history; see [history-version.md](../history-version.md).

> Status: IN_PROGRESS
> Concrete design baseline for review, not implemented storage/API or a provider schema. Implementation tickets are now recorded in the [milestone roadmap](../history/v1/development-plan/milestones.md); the SC-T004 section below reconciles retention; implementation and runtime checks remain pending.

## First-proof boundary and provisional limits

Recording, replay, ASR, learner-confirmed transcript, text feedback and optional local history are covered. No realtime conversation, synthesis, clinical assessment, automatic CEFR placement or precise pronunciation scoring. Owner-approved internal proof range (2026-10-21), subject to feasibility: 1–120 seconds per introduction; proposed engineering format: mono 16 kHz signed 16-bit PCM WAV (at most 3,840,044 bytes before encoding); encoded JSON request body capped at 6 MiB. Verify the exact selected model accepts this format/size before locking transport. Format conversion must preserve the local original until the learner discards it. The duration range is approved for the internal proof only; format and payload limits remain proposals, not claimed provider maxima.

## Identifiers and values

App-generated UUIDs identify attempts, recordings, transcripts, requests and feedback; opaque provider IDs remain provenance. UTC RFC3339 timestamps; durations in integer milliseconds; `schemaVersion: 1`. Text is valid Unicode, with prose fields capped at 12,000 Unicode scalar values unless specified below. Limits reject oversize inputs visibly; never silently truncate learner text. Empty/whitespace-only transcript cannot be submitted for coaching.

An attempt captures a frozen prompt ID/version/text, objective ID, selected learning level (user selection, not assessment), `language: en`, `variety: en-US` and relevant preference snapshot. Credentials never appear in contracts, persisted records or diagnostic outputs.

## Domain operations (not server endpoints)

| Operation | Input | Result |
| --- | --- | --- |
| finalizeRecording | Valid local file plus duration/format | Durable attempt and recording metadata or local failure |
| transcribe | attemptId, recordingId, requestId, configured capability reference | ASR transcript revision with provider provenance or typed error |
| confirmTranscript | attemptId, source transcriptId, expected revision, chosen text | New immutable learner-confirmed revision |
| requestFeedback | attemptId, confirmed transcriptId/revision, requestId, prompt/objective/preferences | Validated feedback for that revision or typed error |
| saveRecording | attemptId, recordingId | Retained file flag committed or disk failure |
| discardRecording | recordingId | File unavailable immediately; cleanup transaction queued/completed |
| deleteAttempt | attemptId | Recoverable scoped soft deletion; permanent cleanup uses purge |

Request identity is local; no provider idempotency support is assumed. One in-flight request per attempt/stage. New request IDs identify explicit retries; their local completion cannot duplicate attempt/reward events. Network timeout after send has unknown provider billing outcome. Do not automatically retry ASR/coaching or malformed output in v1; offer an explicit retry with possible-charge explanation. Cancellation stops local consumption, not guaranteed remote work or billing.

## Transcript contract

| Field | Type / rule |
| --- | --- |
| id, attemptId | UUID; existing attempt link |
| revision | Positive integer, monotonically allocated per attempt |
| kind | `asr_original` or `learner_confirmed` |
| sourceTranscriptId | null for ASR; required prior transcript ID for confirmation |
| text | String, max 12,000 scalars; confirmation copies original when no edits |
| createdAt | UTC timestamp |
| provenance | ASR: provider/model/region, nullable providerRequestId; learner: local user action |
| confidence | null unless adapter supplies documented confidence semantics; no invented score |

Original ASR is immutable. Every confirmation creates a new revision, including unchanged text. Feedback requires a confirmed revision; transcript editing is local and triggers no automatic cloud call. Editing after feedback creates a new revision; older feedback remains associated with its old text and is not displayed as current. Responses arriving for stale revisions are retained as historical only if the attempt still exists; deleted attempts discard late payloads. Edits never become acoustic evidence.

## Coaching request and response

Send only confirmed text, frozen objective/prompt context and selected preferences to the text model. Original audio is not required for v1 coaching and must not be represented as assessed by it. Treat learner text as quoted data, not instructions able to alter rubric or credential behavior. Provider DTOs are internal to the adapter.

The adapter attaches trusted local `id`, `attemptId`, `transcriptId`, `transcriptRevision`, `requestId`, `schemaVersion`, `createdAt`, `rubricVersion` and provider/model/region/request provenance after validating model content. Never let a model choose links to another learner attempt.

Model content fields:

| Field | Type / validation |
| --- | --- |
| summary | String, 1–600 scalars, no proficiency/certification claim |
| strengths | Array of 0–2 strings, each 1–300 scalars |
| improvements | Array of 0–2 items by default; explicit expanded detail permits 0–5; no forced mistakes |
| item.category | `grammar`, `vocabulary` or `organization` |
| item.evidenceQuote | Exact nonempty substring of confirmed transcript, max 500 scalars |
| item.explanation | String, 1–600 scalars; tentative where recognition ambiguity persists |
| item.suggestedRevision | null or string, 1–600 scalars; hints-only requests require null |
| item.hint | null or string, 1–600 scalars; hints-only requests require a hint |
| item.retryPrompt | String, 1–400 scalars linked to current objective |
| limitations | Array of 0–5 strings, each 1–300 scalars |
| speechAssessmentStatus | Fixed `not_assessed` in this text-only proof |

Reject missing/extra fields, wrong types/enums, invalid lengths, mismatched IDs/revisions or evidence not present in text. Do not strip Markdown fences and silently accept arbitrary prose. The future adapter can request JSON/schema mode where supported, but local semantic validation remains mandatory. Grammar/content truth, preservation of meaning, valid alternatives and helpfulness require reviewed evaluation; schema compliance is not sufficient. A valid empty improvements list is allowed. Do not display incomplete streaming JSON as final feedback.

Example model content (fictional learner text: “I lives in Manila. I am a developer.”):

```json
{
  "summary": "Your introduction clearly states where you live and what you do.",
  "strengths": ["You included a location and an occupation."],
  "improvements": [{
    "category": "grammar",
    "evidenceQuote": "I lives in Manila.",
    "explanation": "With I, use the base form live in the present simple.",
    "suggestedRevision": "I live in Manila.",
    "hint": "Check the verb form after I.",
    "retryPrompt": "Introduce yourself again using I live."
  }],
  "limitations": ["Pronunciation was not assessed from this transcript."],
  "speechAssessmentStatus": "not_assessed"
}
```

## Errors and state transitions

Typed errors: `permission_denied`, `invalid_audio`, `empty_transcript`, `credential_missing`, `unauthorized`, `unsupported_capability`, `rate_limited`, `quota_exhausted`, `offline`, `timeout_unknown_outcome`, `provider_unavailable`, `invalid_response`, `cancelled`, `storage_failure`, `stale_revision`. Error metadata: local requestId, stage, retry eligibility, optional documented provider retry-after; no raw payloads/keys. Quota/auth/cancel errors do not auto-retry. Preserve attempt and valid transcript on feedback failure.

States: recording → recorded → transcribing → transcript_review → feedback_pending → feedback_ready. Failed/cancelled requests return to recorded or transcript_review as appropriate with a typed error; self-review can finish independently. Rerecording creates a new attempt linked by retryOfAttemptId, never overwrites the baseline. Transcript edits are revisions of the same attempt. App restart marks unresolved sent requests unknown-outcome and never silently resubmits. Finishing local practice is separate from stage state and optional history retention; reward eligibility is not finalized here.

## UI/UX retention update

The [owner UI/UX record](../product-specification/ui-ux-design.md) supersedes immediate removal for saved-record deletion below: saved records enter Recently Deleted for 30 days, with restore and immediate permanent deletion. Declined temporary recordings bypass recovery. Audio retention and transcript/feedback retention are independent explicit choices. The deleteAttempt cascade below describes permanent purge, not entry into Recently Deleted. The reconciled SC-T004 section below defines recoverable deletion/restore operations, expiration and evidence/reward handling; late callbacks cannot resurrect either deleted state. The introduction proof range above was approved on 2026-10-21 subject to feasibility; the general recording maximum is unresolved.

## Local persistence contracts

SwiftData selected by SC-T002; these store-independent constraints still apply. No store exists.

| Record | Required persisted fields and constraints |
| --- | --- |
| SpeechAttempt | UUID primary key; optional retryOfAttemptId; frozen prompt/objective/preferences; createdAt; stage; finishedAt nullable; revision counter; recordingId nullable; deletion state |
| RecordingAsset | UUID; attemptId; app-private relative file reference; format/duration/byteCount; integrity checksum; retention `temporary`/`saved`; availability; createdAt |
| TranscriptRevision | UUID; unique (attemptId, revision); kind/source/text/provenance/confidence; immutable |
| FeedbackRecord | UUID; requestId unique per validated result; attempt/transcript FK and revision; rubric/schema/provenance; validated content; historical/current derived from confirmed revision |
| ProviderRequest | UUID; attemptId; stage; transcriptId nullable; model/region; status; timestamps; nullable provider ID; typed error; documented usage/unit nullable; no secrets or raw bodies |
| RewardEvent | Future: unique eligible event/rule-version pair; do not infer reward policy from provider success |

Foreign keys or equivalent app invariants reject orphan evidence; feedback revision must match its transcript. File finalization: write temporary file → verify readability/checksum → atomic rename → metadata transaction; reconcile orphan files if transaction fails. UI cannot report save success before file and metadata are durable. Disk failure must preserve any recoverable file and provide retry without overwriting another attempt.

Historical proposed cleanup (superseded by SC-T004 below): on explicit discard or finishing/leaving the attempt, delete unsaved audio once in-flight requests are cancelled/settled; clean inactive temporary files older than 24 hours on next launch. Explain crash-recovery retention; retain transcript/history only if the learner chose to save the session. This is a provisional privacy default subject to UI/UX review, not silent permanent retention. Saved recordings remain until explicit deletion; configure storage limits later and never evict saved recordings without consent. After audio deletion, text history can remain if saved but replay is unavailable.

Permanent purge only (soft deletion does not run this cascade): mark logically deleted first → cancel requests → hide history → transactionally remove transcript/feedback/request-linked personal evidence → remove files and reconcile failures on next launch. Minimal pending cleanup IDs are allowed; no cloud sync tombstone design implied. Late callbacks cannot resurrect deletion. Removing a Keychain key does not delete attempts. Local file deletion does not promise deletion from the provider: retention terms need review/disclosure before proof calls.

## Consistency and readiness

Initially, only explicit rated vocabulary reviews advance scheduler state; lesson and speaking attempts supply separate evidence. Introductions is the approved first A1 topic. App-controlled retries prevent duplicate local events, not guaranteed duplicate provider charges. SC-T002 selects local-only SwiftData, minimum OS 17+ and Keychain WhenUnlockedThisDeviceOnly; SC-T003 selects the provisional ASR/text candidate. Provider wire implementation and actual account/device acceptance remain outstanding. Reference [acceptance](../testing/recorded-feedback-acceptance.md) for provisional targets and proof evidence. Implementation and acceptance are tracked in SC-T008–SC-T017; this document does not authorize execution.

## Reconciled retention contract — SC-T004, 2026-10-21

This section supersedes earlier provisional cleanup/deletion wording. Owner approved independent opt-in audio/text saving, 30-day Recently Deleted, 24-hour interrupted recovery, exclusion of all learner data from device backups and preservation of already-earned participation credits on individual purge. No implementation or physical erasure is claimed.

| Audio saved | Text/feedback saved | Retained private payload after finish |
| --- | --- | --- |
| No | No | None; only minimal non-content completion/participation/deduplication metadata |
| Yes | No | Accepted audio and necessary playback/prompt identity; no transcript/feedback text |
| No | Yes | Original/confirmed transcript revisions and validated feedback with provenance; audio unavailable |
| Yes | Yes | Both, linked to the same stable attempt |

Draft/audio/text used to finish the current practice remain temporary until selected. Neither control is preselected by inference from the other. Saving additional takes requires explicit choice. Keep metadata minimal: IDs, public curriculum references, timestamps, modality/support and eligible completion event; remove private/freeform prompt/preferences snapshots when private payload retention is declined. Private payload must not be copied into summaries, logs, request bodies on disk, assessment anchors or ledgers. Completion is not inferred speech success. Saving success requires durable selected files and metadata; failure retains recoverable draft and shows retry, never falsely reports success.

Lifecycle: active temporary → saved active or explicit discard; interrupted temporary → recoverable until recovery deadline → discard; saved active → recently_deleted → restore or permanent purge. These are independent from ASR/coaching stage and audio/text availability. Audio-only deletion affects only selected audio; text-only deletion affects text and derived content; deleteAttempt applies to all saved parts. Component trash records retain their own deletion ID, selected scope, deletedAt and expiresAt; normal display excludes only the deleted components. Temporary discard bypasses trash.

Operations: saveSelection(attemptId, keepAudio, keepText, expectedVersion); softDelete(attemptId, scope, expectedVersion); restore(deletionId, expectedVersion); purge(deletionId, expectedVersion); discardTemporary(attemptId); reconcileCleanup(now); deleteAllLearningData. Durable intent and version/epoch checks precede asynchronous work. In-flight callbacks check attempt epoch and selected component scope; cancelled/old/recently-deleted/purged or text-retention-declined responses cannot persist or reappear. Restore never resumes requests or accepts a pre-delete response; a new explicit request is needed. Restoring selected components preserves IDs/history and pays no reward.

30-day deadline = deletedAt UTC + 30 × 24 hours, independent of calendar/timezone/DST; restore is allowed only before expiry and successful availability checks. Expired content becomes inaccessible on access/launch/foreground before cleanup. Purge runs on next available protected-data maintenance opportunity; no guaranteed background deletion at the deadline. Offline wall-clock rollback cannot be made tamper-proof: use monotonic elapsed time within a run and persist a nondecreasing last-observed UTC for maintenance; timezone changes do not alter deadlines, forward clock jumps can expire data, and incorrect clocks across a powered-off device remain a limitation. Never extend a trash deadline merely on restart.

Interrupted temporary deadline = last explicit learner recovery/capture interaction UTC + 24 hours. No passive network/background event renews it. Before deadline, show recoverable take and offer replay/save/discard; never auto-resume capture/submission. Explicit discard or finish/leave without saving revokes visibility immediately, cancels requests and queues immediate cleanup; do not wait indefinitely for a server response. Invalid/unreadable interrupted audio is labeled unavailable, never a successful saved take. Transient in-memory raw response data is released; crash recovery never silently retains declined text.

Soft deletion hides selected payload and makes related skill claims evidence unavailable; retained unrelated evidence can still support a claim. Trash is not assessment input or exportable by default. Restore recomputes claims only from restored valid evidence. Permanent purge removes selected private data, linked request payload/provenance that is no longer needed, derived private quotes and files; mark file cleanup pending until successful. No orphan transcript/feedback survives full attempt purge. Minimal opaque deletion/cleanup identities prevent resurrection and duplicate credits without retaining quotes/audio/text. Do not promise secure overwriting of flash storage.

Earned participation XP/gold stays on individual deletion/purge under owner approval. Keep a minimal non-content event/rule/deduplication identity and credit history; no new credit for restore/replay/delete/recreate of the same event. Evidence-based award claims lose evidence availability when their only supporting payload is removed; preserved participation is not preserved proof of mastery. Future SC-T024/SC-T025 must implement this distinction, not invent reversals or new economy values.

Delete all learning data is a separately confirmed permanent reset, bypassing trash: invalidate the learner-data epoch, cancel requests, remove learner attempts/vocabulary/custom content/progress/reward ledger and all private files including trash/temp/export staging; reconcile failed deletions before claiming physical cleanup. Preserve shipped curriculum/assets. Key removal is an independent explicit control; do not claim reset revoked provider credentials/account access. Reset exports no recovery copy and creates no app-managed backup. After reset old callbacks fail the epoch check.

All learner store/sidecars/audio/trash/journals are excluded from device backup on a best-effort platform basis. Do not promise Apple never restored an old copy. Do not import old exports/backups automatically. Explicit selected export omits keys, temp/trash and deleted components; manually exported copies are outside app deletion. First proof supplies no broad export/import UI; before later delivery SC-T004 requirements must be carried into a bounded child of SC-T042. No silent restore/sync or local backup containing deleted private data.

Design walkthrough (2026-10-21, specified outcomes reviewed; not executed software tests): all four save combinations above; crash before commit yields recoverable draft/orphan reconciliation; disk-full cannot report saved; delete during request invalidates late response; restore before expiry restores selected components without credits; at exact expiry restore is rejected and cleanup queued; failed file deletion remains inaccessible and pending after restart; clock rollback cannot extend recorded maintenance time; individual purge preserves participation but removes unsupported evidence; reset invalidates all old callbacks and clears credits. Runtime fixtures/device checks remain RF-08/10/11/12 plus SC-T009/SC-T015/SC-T017.
