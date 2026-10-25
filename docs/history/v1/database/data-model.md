# Data Model

## SC-D017 resource bookmarks — 2026-10-24

Optional `LearnerDocument.learningResources` stores explicit saved bookmarks in the existing protected, backup-excluded document: UUID/revision, title, canonical destination, topic, notes, optional curated ID/version and update time. Missing fields decode as an empty library; no SwiftData migration. Notes are learner-entered text, never evidence of website contents or learning assessment. Edit/delete require exact record and learner epoch; save failures roll back, while drafts remain in the controller's memory for retry. Explicit Remove deletes the bookmark and its notes; delete-all invalidates stale drafts/open callbacks. No automatic export/upload, metadata/thumbnail download or separate database. See [resource contract](../../../contracts/resource-library-v1.md).

> Status: IN_PROGRESS
> SC-T009 implements the first-slice local-only SwiftData repository and private-file boundary; later curriculum/vocabulary/reward models remain design intent.

## Separation and candidate records

Separate versioned curriculum from learner-generated progress. Stable curriculum IDs and generated attempt IDs are proposed; field names and types await schema design.

| Record | Proposed information and purpose |
| --- | --- |
| Curriculum | Language, CEFR level, version, units/topics, objectives, lessons and exercises; available versus planned content |
| LearnerSettings | Learning preferences, feedback style/timing, coach personality, workload and speaking choice; session overrides remain scoped |
| VocabularyItem | Word/phrase, meaning, examples, language, topic, source and personal edits |
| VocabularyCard | Item link and recognition or production task; scheduler state/version |
| ReviewAttempt | Card, timestamp, attempted answer, self-rating and optional AI feedback; append history |
| SpeechAttempt | Mode, prompt/objective, start/end, optional recording reference, comparison relationship and session settings |
| Feedback | Attempt link, transcript uncertainty, grammar/vocabulary observations, capability, provider/version and evidence |
| LessonAttempt | Content version, objective, answers and outcome |
| ResourceBookmark | Curated/personal source, YouTube link, thumbnail reference, title, tags and learner notes |
| AchievementEvidence | Rule/version, eligible attempts, completion or improvement category, awarded event |
| ActivitySummary | Recomputable summaries of attempts, recall and participation |

## Relationships and invariants

A vocabulary item may have separate recognition/use cards and many review attempts. A speech attempt may have multiple feedback records/retries and no retained audio. Comparisons reference identifiable prompts and attempts; deleting a recording must not leave a playable dangling reference. Grammar mistakes do not imply vocabulary retrieval failed. Rewards reference eligible events to prevent duplicate awards on request retry.

Content updates must preserve objective identity or provide explicit mappings. Aggregates must not replace evidence. A topic set may group vocabulary without duplicating independent learner history; exact deduplication rules remain open.

## Sensitive data, deletion and recovery

Recordings, transcripts, custom topics and interview responses can contain personal data. Apply the selected SC-T002 file-protection/backup policy and SC-T004 retention/deletion contract. SC-T177 settles the selected export format and any restore scope; verify provider retention before live calls. Device loss/uninstall can lose local data. Optional baseline saving does not authorize blanket audio retention or synchronization. No production backup procedure or migration command exists.

## Open schema work

IDs/types, indexes, timestamps/time-zone policy, schema versions, file integrity, atomic recording persistence, crash recovery, reward ledgers and storage limits require engineering design. SwiftData is selected for the first slice by SC-T002 below. Recognition review state is an optional `reviewCards` field in the learner document, so older documents still open and no SwiftData migration is added. An enrollment may set `inReview` to false for a collection-only save; a missing value stays in review. An optional `openRecall` remembers a revealed card that has not been rated. An unknown scheduler version is not rewritten. Productive use is a separate `senseCredits` event and does not create a scheduled card. A repeated source event does not schedule twice.

## Generated activity records and attempt identity

Proposed ActivityVariant record: stable variant ID, approved objective/template and versions, type, language variety, target/difficulty constraints, exact displayed prompt, answer rules/rubric and explanation, origin, generation provenance, validation state/version and optional editorial review state. Record creation/cache times and source/rights provenance where relevant. Fields and storage remain design candidates.

Attempts reference an immutable snapshot/version of the presented variant and grading criteria. Preserve historical interpretation when content or providers change. Assessment eligibility and task comparability must be explicit; validation alone does not prove calibration. Cached variants must remain compatible with current content and include sufficient answer data for supported offline exercises. Set cache limits, expiration and invalidation during engineering design.

Vocabulary variants link to existing cards and senses without replacing review history. Do not duplicate XP or scheduled recall events because a prompt was regenerated. Generated private topics/examples require the same retention/deletion protections as other learner data.

## Lesson activities and shared vocabulary

Proposed lesson structure includes versioned teaching segments and objective-linked activities with stable IDs, targets, answer rules and appropriate optional speaking/feedback links. Attempts preserve exact activity/version, assistance and evidence; completion and later improvement remain separate concepts.

Represent lesson-to-vocabulary references independently of learner enrollment in review. One item/sense may occur in several lessons and personal/topic collections; recognition and productive-use cards stay distinct. Learning evidence identifies its lesson/activity source, context, hint/answer exposure and attempted retrieval, without implying automatic scheduler credit. Exact identity matching for personal entries, senses/variants and edits remains open. A single source attempt must not create duplicate review events or rewards across entry points.

## BYOK storage separation

Learner settings may reference provider identity/model and a nonsecret credential reference/status. Raw keys must not be fields in settings, SwiftData, curriculum, attempt records, activity snapshots, logs or export payloads. Apple Keychain owns the secret; deletion/rotation is independent of learner progress. Key synchronization and migration are not approved. Optional usage metadata must distinguish measured provider usage from estimates; it is not an authoritative account balance.

## Approved evidence/retention defaults

Store original recognition and learner-edited transcript as distinct versioned evidence with edit provenance; edited text is not acoustic assessment evidence. Save recordings only on learner choice and specify temporary-file cleanup/storage limits before implementation. Lesson attempts retain learning evidence; only explicit rated reviews advance scheduler state initially. Incorrect-activity reports should reference variant/version and minimal context; exact storage/export/report handling remains to be designed.

## First-proof persistence baseline

[Recorded-feedback v1](../../../contracts/recorded-feedback-v1.md#local-persistence-contracts) specifies concrete record keys/links, immutable transcript revisions, validated feedback identity, local file finalization, deletion and crash reconciliation. These are store-independent design contracts, not migrations or implemented tables. SC-T004 below settles cleanup/retention defaults; later vocabulary/reward schemas remain separately scoped.

## UI/UX-derived persistence requirements

Follow [UI/UX decisions](../../../product-specification/ui-ux-design.md): persist background style separately from Light/Dark/System and coach choice; all seven trainer roles and three styles are unlocked. Audio saving and transcript/feedback saving are independent. Saved-record soft deletion supports 30-day restoration and explicit permanent purge; declined temporary audio bypasses recovery. Define deletion effects on aggregates, evidence and rewards before implementation. XP progression, gold credits/debits, free-hint usage, Freeze inventory/consumption and Repair purchases require distinct versioned event identities and idempotent local transactions. Device timezone governs day boundaries; travel/clock-change rules remain open. This adds requirements, not tables or migrations.

## Introductions assessment evidence requirements

The [adopted first-topic criteria](../product-specification/introductions-learning-loop.md) require assessment purpose, objective/content/task/rubric/protocol version, actual elapsed delay and practice exposure, preparation/support/accommodations, hints/answer exposure, modality, first response versus retry, and recognition/recall/use/retention/transfer evidence distinctions. Record per-dimension rating or not-assessed state with assessor/source provenance; confidence remains self-reported. Model precise fields in the architecture/schema tickets, not as assumed implemented tables.

Preserve links between baseline, repeated baseline and reserved unfamiliar tasks without equating them. Missing/declined/deleted evidence must be representable independently of failure. Separate participation and assessment eligibility; no lesson/pilot event silently advances a vocabulary schedule. Consent and retention rules apply to supporting private payloads and evidence availability; deletion invalidates unsupported derived claims without resurrecting audio/transcripts.

## Shared grammar objective evidence

The [English Foundations contract](../../../product-specification/english-foundations.md) requires stable versioned child grammar objectives under EF strands, links to CEFR lesson/objective IDs and reviewed descriptor references. Keep concept-identification results, controlled production and communicative target use distinct, with target opportunity counts, support/answer exposure, modality and delayed/transfer context. Shared source-attempt identity prevents duplicate progress/rewards across focused and contextual entry points. Preserve not-assessed/missing evidence and existing consent/deletion rules; no vocabulary scheduler credit from grammar work alone. Exact fields/store contracts remain architecture work, not implemented schema.

## Trainer method and specialty evidence

The [seven-trainer contract](../product-specification/specialized-trainers.md) requires role/method/pack version, linked primary and specialty objective, exact activity/task/rubric, modality/support and assessment purpose alongside source-attempt identity. Keep fiction versus factual mode explicit without copying invented stories into personal history. Switching preserves shared evidence/reward identity; a changed assessment context becomes a separate attempt. Source-based listening, text comprehension, written composition, rehearsed speech and independent delivery have distinct evidence availability. Detailed fields and interfaces remain design work; no new schema, seven-agent infrastructure or separate provider per trainer is adopted.

## Learning context and reward delivery separation

[Course/practice requirements](../product-specification/learning-path-and-practice.md) need course/specialist/conversation/interview context and source-lesson return identity. Coach presentation is independent from substantive method/task/support/rubric. Future interactive modes need turn/request/answer/follow-up links and explicit session/retention policy before storing dialogue; keys stay in Keychain and private context stays out of logs.

The [reward proposal](../../../product-specification/celebrations-badges-and-rewards.md) separates rule/event/award identity, eligible source events, itemized XP/gold and badge criteria/evidence from queued presentation/acknowledgement. A display animation is never an earning transaction. Idempotent local commits/reconciliation and deletion/reversal/current-evidence behavior remain schema/retention design work; no automatic gold debt or data resurrection is approved. The catalog and visual/motion targets are adopted; unresolved activation rules and exact delivery fields remain scoped work, with no implemented tables.

## SC-T002/SC-T004 decision update — 2026-10-21

SwiftData is selected for first-slice local-only learner metadata, with audio files outside the store, explicit saves, serialized mutation, versioned migrations and no CloudKit. See the canonical architecture decision and [reconciled retention contract](../../../contracts/recorded-feedback-v1.md#reconciled-retention-contract--sc-t004-2026-10-21), which supersede earlier candidate/provisional statements.

Separate processing stage from payload/component lifecycle. Add component-scoped deletion identities, deletedAt/expiresAt, temporary recovery deadline, record version/learner epoch, payload-retention choices and durable cleanup intents. Default summaries never keep declined private text. Scope purge cascades to selected payload; retained participation credits use minimal non-content event identity while unsupported skill evidence becomes unavailable. Delete-all clears the learner ledger too; no callback from its old epoch may commit. All learner stores/sidecars/files, trash and journals request backup exclusion. These are required schema invariants, not implemented models/migrations.

## Bundled curriculum/version contract — 2026-10-21

SC-T005 selects bundled versioned JSON/required assets for first-topic offline delivery with app-update content releases. Keep read-only content catalog separate from excluded learner-data store; stable lesson/activity/sense/objective IDs plus immutable content/rubric versions preserve attempt interpretation. Retained public definitions/minimal permitted snapshots may explain old attempts; private generated text remains governed by opt-in/purge. No automatic scheduling/reward/proficiency migration from an updated pack. See technical intent and the publication readiness record; no schema or app bundle exists.

## Local persistence implementation — SC-T009, 2026-10-21

Implementation now lives under `application/SpeechCoachAI/Domain/LearnerState.swift` and `Infrastructure/Persistence/`. `LearnerSchemaV1` (1.0.0) has three local-only SwiftData models: singleton StateRow (epoch, typed preference encoding, nondecreasing observed UTC), AttemptRow (UUID and typed versioned domain snapshot), and FileIntentRow (durable finalization/deletion journal). Typed snapshots contain prompt identity, creation/completion/recovery dates, processing stage, independent audio/text lifecycle/deletion IDs/deadlines, recording integrity metadata, immutable transcript revisions, validated-feedback links and nonsecret request metadata. JSON encoding is inside SwiftData rows, not a standalone learner-data JSON store. No raw provider body or credential field exists. Full provider schema validation stays SC-T014; stored feedback link consistency is checked locally.

`LearnerRepository` serializes synchronous mutations on the main actor, disables autosave and CloudKit, uses explicit save/rollback, and returns value snapshots rather than SDK models. A failed open/migration propagates; there is no erase/recreate fallback. Schema v1 creates an initial store; no existing learner-data migration has run. Future schema changes must add a migration stage and retained old-schema fixtures before delivery.

Private files live under app-private Application Support/Learner/{audio,staging}; metadata store/sidecars and journal share the protected Learner subtree. The file boundary permits UUID-named WAV paths only, rejects root/managed descendant symlinks, preserves OS-managed container aliases, verifies byte count/SHA-256, writes protected staging files, syncs and renames before metadata attachment. Capture/container-format verification belongs to SC-T011; synthetic persistence bytes are not claimed as valid captured WAV. Metadata finalization failures leave a recoverable journal; reset/stale journal entries cannot attach to a later epoch. Unreferenced namespace files are reconciled. Complete file protection and best-effort backup exclusion are reapplied to the subtree/files; simulator execution cannot establish device Data Protection.

Finish records independent explicit audio/text selections. Declining both removes private prompt/preference snapshots and payloads, retaining only minimal identity/status. Audio-only selection retains necessary prompt/playback context. Scoped 30-day trash has separate component deletion IDs and UTC deadlines. Restore requires unexpired, available evidence and invalidates old callbacks; it never resumes a request. Purge/temporary discard revoke access before physical deletion, with failed cleanup journaled. Interrupted drafts recover for 24 hours after explicit interaction; no passive callback extends the deadline. Maintenance uses persisted nondecreasing UTC plus elapsed uptime within a run. Missing files become unavailable; expired data is hidden before cleanup. Sent requests become unknown-outcome on reopen, never automatically resent. Epoch reset removes attempts/private files and resets local preferences; keys remain a separate future boundary, and reward-ledger clearing must be extended when that ledger exists.

`LearnerStorageController` opens at app/foreground/unlock, closes the repository before protected data becomes unavailable, and exposes a generic retry state without SDK errors/private paths. Protection-lock/device interruption, actual recording, owner history UI, physical iPad/minimum-OS and broader RF acceptance remain separate; unit fault injection does not prove those journeys. See SC-T009 for actual verification status.

## In-progress capture references — SC-T011, 2026-10-21

AttemptSnapshot now has optional pendingCaptureID in its existing Codable payload. Absent fields decode as nil; SwiftData schema remains 1.0.0. The repository commits the reference before recording bytes, excludes referenced staging UUID files from orphan removal, validates closed audio before the existing journaled finalization path, then clears/removes the draft idempotently. Deletion/expiry/reset journal draft cleanup as well as finalized original cleanup. No old-schema migration or production data reset occurred. Synthetic restart and exact-deadline tests pass; actual microphone/lock/device acceptance remains open.

## Session snapshots and credentials — 2026-10-21

Attempts optionally encode practiceSessionID/sourceLessonID and freeze effective session preferences (including coach override) without mutating defaults. Absent optional fields decode from old snapshots; schema remains v1. Declining both payloads clears private source/session/preference context. Tests cover old-snapshot decode and preservation/removal semantics on phone/simulator. Provider credentials live only in Keychain, not these Codable payloads/SwiftData or submission-preparation objects.

## Request transition and revision operations — 2026-10-21

Existing v1 request/snapshot models now have explicit operations; no schema migration. Prepared/sent duplication per stage is rejected. Only legal pending-to-terminal transitions occur. On reopen unsent prepared requests become cancelled; sent requests become unknownOutcome. Recognition plus request success commit together; confirmation allocates a fresh immutable revision, including unchanged text. Coaching preparation selects latest confirmed text and completion accepts only validated content bound to its UUID/revision/checksum and sent request. Feedback plus request success commit together. Local edits preserve historical associations and trigger no provider work. Raw responses/keys remain outside persistence.

## Completion-only group integration — 2026-10-21

Existing AttemptSnapshot JSON now optionally stores completionID and didCompleteSelfReview. Explicit successful finish sets completionID to the frozen session UUID (or attempt UUID for legacy context); retries in the same session count once. Fresh practice sessions reset context identity; recovery reconstructs the stored identity/preferences/source. Neither draft discard nor old records silently become completed/credited. All fields remain in schema-v1 Codable payloads; absent optional fields decode unchanged, with no migration.

Repository history queries expose only available saved components or redacted trash metadata, after maintenance/expiry. Recently Deleted hides its payload until restoration. completedPracticeCount uses distinct minimal completion IDs even if the learner saves neither component or later purges saved payloads. Delete-all removes attempts/completions; it does not remove provider Keychain entries. No source private text or provider body is added to completion metadata.

## Lesson progress and vocabulary collection — SC-T020 and SC-T021, 2026-10-21

StateRow.preferences now stores a document when lesson or vocabulary data is written: preferences, lesson journeys, vocabulary enrollments, recognition exposures, and personal topics. Older rows that store LearnerPreferences directly still open, and missing document fields decode as empty. There is no SwiftData schema change. An enrollment is one card per item and sense. An exposure records recognition only and has no rating or due date. A personal topic is learner-written and is not a reviewed lesson. A recall attempt stores the rating, whether the meaning was revealed, and the first typed response. It has no due date. Delete-all writes a fresh preferences value, which clears journeys, enrollments, exposures, personal topics, and recall attempts.

## First-loop repair compatibility — 2026-10-22

No SwiftData schema or migration is changed. Existing Codable payloads gain optional LessonJourney.drafts, LessonResponse.recordedPracticeID, and sense/enrollment meaning fields; absent fields remain nil. Multiple lesson journey UUIDs may belong to the same lesson/content version so repetition preserves earlier work. Latest compatible journeys drive resume, while old versions remain distinct. Drafts and navigation do not create completion or review credit.

The recording-to-lesson event is in memory and only follows a successful explicit self-review finish for the active lesson/session/journey. Its presentation context and event include the exact journey UUID in memory; consuming it after a successful lesson save prevents crediting a later repeat. A lesson can store the minimal recording attempt reference as participation without forcing audio/text retention; it does not preserve a private payload or create acoustic assessment. The existing recording minimization/deletion policy remains intact. New meaning snapshots keep a collection card usable after topic deletion; legacy personal notes are snapshotted before their topic is removed. Same spelling with distinct notes creates distinct senses. Reset still clears the entire learner document.

## Daily choice, confidence, and comparison labels — 2026-10-22

No SwiftData schema or migration is changed. The preferences document gains optional `dailyChoice`, `confidenceNote`, and `attemptFormats`. Absent fields stay nil, so an older document still opens. `dailyChoice` stores one action and the local `yyyy-MM-dd` day. It is ignored when the day does not match or the action is no longer available. `confidenceNote` is the learner's own text, at most 280 scalars, and is omitted when empty. `attemptFormats` labels an existing attempt as baseline, practice, repeated baseline, or reserved transfer. The label does not copy audio or text into the document. Delete-all writes a fresh preferences value, which clears the choice, the note, and the labels.

## Recall draft/event identity — 2026-10-22

The existing optional `openRecall` payload now also accepts optional `mode` (`think`, `write`, `say`) and `sourceEventID`. Hidden text persists as an unfinished draft, not a review event. Reveal freezes first response/mode; rating atomically appends one `VocabularyRecallAttempt` and updates its recognition schedule, then clears the matching open recall. Retry uses the same source UUID, bound to the same item/sense. Later deliberate reviews use new UUIDs. Old payloads without these fields decode as optional writing; reading an old open recall durably assigns its missing event ID once before resume/skip. Failure to save that identity returns an error and leaves the old payload intact. `spokenSelfCheck` is learner-reported, unrecorded recall modality; it introduces no audio file or speech score. Delete-all still clears the document and these private fields. No StateRow/SwiftData version or migration change. See [batch](../development-plan/recall-recovery-2026-10-22.md).

## Confidence draft failure/reset boundary — 2026-10-22

Confidence remains the same optional normalized note in the existing preferences payload. A controller-only `ConfidenceNoteDraft` holds text, previously saved text, save-error state and the existing StateRow epoch. It adds no persistent table/field. Debounced and leave/background saves use the epoch guard; delete-all invalidates pre-reset pending edits. Write failure keeps the earlier persisted note and the in-memory edit for explicit retry. A cleared note stays nil on reload. [Daily-flow batch](../development-plan/daily-flow-2026-10-22.md).

## Optional INTRO-01 practice state — 2026-10-23

`LessonJourney.practiceOrigin` is an optional Codable value containing the source course journey UUID, lesson ID, objective ID and activity ID. Foundation and specialist packs use separate lesson IDs, versioned practice definitions and journey UUIDs in the existing local document. Completing a pack does not write the course journey. `LessonResponse.firstResponseText` optionally freezes the first response even when supported; `assistedText` may change on retries and `unaidedText` remains absent for supported first attempts. Missing fields decode as nil; no SwiftData migration. Delete-all removes optional practice with the other journeys. These responses are text, not acoustic or independent-assessment evidence. See [implementation](../development-plan/intro-runtime-2026-10-23.md).

## Connected personal-check state — 2026-10-23

AttemptSnapshot optionally stores sourceLessonJourneyID and SpeakingProvenance (role/method/pack/activity/source objective and support). Recording recovery freezes the original prompt/context. Existing minimize removes both optional fields alongside sourceLessonID/preferences when retained payloads are declined/purged. LessonJourney optionally stores teachingBeganAt and an IntroCheckSnapshot: frozen prompts/purpose/conditions, exposure/timing, explicit text retention, participation indices/modalities and self-review. No answer keys or automatic scores. Retained written drafts/responses use the existing journal; no-retention attempts persist participation only. Delete-all clears journals. No SwiftData schema change or migration.


## SC-D003 review settings and parameter provenance — 2026-10-23

The existing LearnerDocument JSON gains optional `reviewSettings` (desiredRetention, optional positive sessionLimit) and `practiceGoal` (existing SuggestionAction raw value). Missing settings preserve 0.90 and all due words; missing goal means no preference. saveReviewSettings/savePracticeGoal atomically update only their document fields and optionally validate the learner epoch. Delete-all restores absent/default state. No SwiftData model or migration changes.

ReviewCardState and VocabularyRecallAttempt gain optional desiredRetention; new scheduled recall attempts also retain optional schedulerVersion. New ratings freeze the parameters actually used; earlier absent provenance is not backfilled. Settings changes never rewrite stored cards, attempts or open drafts. Session limits slice an ordered presentation after prioritizing an eligible open recall; they do not remove enrollments, alter the due queue or change due instants. Duplicate histories/enrollments and unsupported stored cards cannot be bypassed by a direct rating call. Existing event deduplication and atomic failure behavior remain in force.

## SC-D007 optional practice and content archives — 2026-10-23

No SwiftData migration or new learner store. `LessonJourney.practiceConditions` is an optional Codable value with purpose, source content version, actual start/teaching dates, support, text retention, possible prior teaching exposure and draft rubric reference; existing `practiceOrigin` links the source course. Optional `LessonResponse.participatedWithoutText` and `attemptWasSupported` record an explicit text participation event without its response/draft when retention is declined. Retained first-response/retry behavior is unchanged. Typed participation is not speech/accuracy evidence. Bundled `CurriculumManifest.archivedLessons` and lesson `supplement` are content resources, not copies in learner storage. Exact id/version selection never reassigns old attempts; current-version practice creates a new UUID. See [implementation and limits](../development-plan/sc-d007-implementation-2026-10-23.md).

## SC-D013 optional local practice archives — 2026-10-24

`LearnerDocument.speakingPracticeArchives` optionally holds one latest `SpeakingPracticeArchive` per conversation/interview mode. It stores a Codable session, explicit draft dictionary, optional one-use interview recording slot, updated date and optional expiry. Missing fields decode on older documents; no SwiftData migration. Draft saves are explicitly opted in for 24 hours; reopening explicitly extends that window. Maintenance/read removes expired archives. Final retention stores sanitized sessions with empty drafts and no expiry. Failed writes roll back; archive save/removal validates the delete-all epoch. Saved audio remains under existing Attempt/private-file ownership and is referenced by UUID; a reference cannot resurrect declined audio. Reopening an interrupted online-request fixture records unknown outcome rather than resending. See [implementation and limits](../development-plan/sc-d013-integration-2026-10-24.md).

## SC-D014 communication snapshot and provenance — 2026-10-24

`SpeakingPracticeArchive.communication` optionally stores a Codable CommunicationPractice. Its archive kind is length-prefixed exact lesson/content/objective/sense identity, or a standalone key; it does not include entry path. One explicitly retained latest session per source preserves first response/retry/support/credit/slot/drafts across Learn and Speech Lab, with different versions separate. Existing 24-hour expiry, maintenance, epoch validation, write rollback and final sanitization apply. Optional `SpeakingProvenance.communicationSource` freezes the source of independent recordings; sourceLessonID/sourceLessonJourneyID remain unset, excluding course completion. Old absent fields decode nil. No SwiftData migration. Independent audio decline purges all same-session slots through existing file intents, including abandoned/Recently Deleted takes. Private prompt text can be removed independently of audio. See [implementation and limits](../development-plan/sc-d014-integration-2026-10-24.md).

## SC-D015 optional generation journal — 2026-10-25

`LearnerDocument.generatedPractice` optionally stores `GeneratedPracticeRecord`: learner epoch/schema, cache entries and deletion identities, retained frozen attempts, minimal local reports and an unresolved request UUID. Old missing fields decode nil. New cache entries include exact source and accepted supplied-policy snapshots; frozen attempts retain source/schedule identity. Source and policy snapshots are not a verified grant, model manifest or semantic assessment. Only explicit retention can store generated wording; reports exclude learner responses and have exact version/expiry identity. Removed/expired reports are excluded from export helpers; no new transfer UI. Cache/report expiry is applied on read/maintenance, while explicitly retained frozen history remains independent.

Saves require the current epoch and exact prior journal, reject restored text for deleted identities and use existing protected writes/rollback. UI persistence prepares the exact committed report statuses before calling the repository. Unknown-outcome recovery changes the working journal, then saves; it never silently retries a request or claims an unwritten marker persisted. Delete-all removes the optional journal and clears stale screen context. No second learner store or SwiftData migration. [Review and actual verification](../development-plan/sc-d015-integration-2026-10-25.md).

## SC-D016 optional daily pin — 2026-10-25

`LearnerDocument.wordOfDay` optionally stores `WordOfDayRecord.shown` and `learnerEpoch`. The shown snapshot freezes local-day string, item/sense identity, lemma/example/optional meaning and qualified-record reference. Serialization rejects enrollment/credit flags; this record does not schedule or award anything. Legacy documents decode the absent field as nil. Writes require the current epoch and exact prior record and cannot replace an existing pin under unresolved selection rules. Existing protected writes/rollback and Delete all apply; no new store or SwiftData migration. The host reads the record but supplies an empty reviewed pool and no production selection action. See [review/evidence and missing scope](../development-plan/sc-d016-integration-2026-10-25.md).


## Daily difficulty focus — 2026-10-25

The existing DailyPracticeChoice accepts optional Codable `difficulty` (retrieval, grammar, followUp, clarity), only with openLesson. Old values without it decode unchanged. The local-day choice stores no response text, audio, score or provider result. It is ignored with an explanation when its source content cannot open. Save/clear accept the displayed expected learner epoch and reject stale post-delete-all writes. Separate focus journals reuse existing LessonJourney practiceOrigin and practiceConditions, exact source version, and explicit optional written retention (off by default). Course answers/completion remain independent. No SwiftData schema change or migration. See [SC-D004](../development-plan/sc-d004-2026-10-25.md).

## SC-D002 first-introduction delivery — 2026-10-25

IntroCheckSnapshot gains optional sourceContentVersion and teachingMayHaveBeenSeen, frozen from the actual source course when the check begins. Existing optional personalCheck Codable storage decodes absent values as nil. Prompt priorExposure remains separate from teaching exposure. Earlier records are never inferred/relabelled using the latest course state. No SwiftData migration or learner-store reset. Guide content and versioned lesson archives remain app resources, not learner responses. [SC-D002 source/verification](../development-plan/sc-d002-2026-10-25/README.md).

## Optional local reward ledger — SC-D005, 2026-10-25

The existing `LearnerDocument` adds optional `rewards: RewardLedger?` in `StateRow.preferences`. Missing data means no prior reward grant; legacy plain preferences and earlier lesson/review documents still decode. `RewardLedger` stores learner epoch/revision, versioned source/activity/date transactions, award receipts/acknowledgments, finite lesson plans/checkpoints, owned Freeze inventory/protected dates/cooldown, settings and distinct active-time sample UUIDs/totals. No new SwiftData model or migration. IDs/reasons contain no transcript/provider/credential payload.

Source progress and reward reconciliation share the existing ModelContext save. Actual completed recording+self-review also writes the same optional document in that transaction. Purchases quote epoch/revision/date/cost/protected-day set, revalidate before debit and deduplicate by purchase UUID; no negative balance or implicit retry spend. Delete-all clears the document and changes epoch, rejecting old purchases/time/notification callbacks. Ordinary retained participation receipts are independent of optional audio/text retention. Learning awards remain unavailable without qualified evidence; the presentation supports a visibly unavailable supporting-evidence state. [Policy and exact bindings](../development-plan/sc-d005-2026-10-25/owner-decisions.md).
