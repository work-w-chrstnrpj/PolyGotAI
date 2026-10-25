# SC-D017 learning resource library — 2026-10-24

Owner assigned SC-D017 to Codex, then explicitly requested implementation and selected public HTTPS destinations including normalized YouTube links. This supersedes earlier no-implementation wording for this bounded feature; SC-T028 pilot closure and original actual acceptance are not waived. Grok retains the disjoint SC-D015 lane. No Grok source/report was edited.

Execution used the existing allocation plan (execute-code-change Mode A), with native Swift/design and documentation guidance. The owner settled the one material link-policy choice during implementation. Verification drove repairs to card accessibility/action sizing, discard confirmation, search-keyboard dismissal and native alert test selectors; those deviations are retained in evidence. Final source review covered the resource domain/views, shared controller/repository/document coding and target registration.

## Delivered behavior

Learn opens Learning resources. A learner can add/edit a title, HTTPS URL, optional topic and personal notes, save a source card, search saved metadata, remove a bookmark with confirmation, and deliberately open the displayed destination externally. Two versioned VOA source links retain publisher provenance without copied media/teaching material. Personal content is clearly distinguished from reviewed curriculum. URL validation/canonicalization refuses unsafe schemes, embedded credentials, local/IP hosts and ambiguous/unsupported YouTube forms; recognized video forms share a canonical identity and duplicates cannot overwrite notes.

Existing LearnerRepository persists explicit Save operations through optional Codable document fields, with rollback and current learner epoch/exact-record guards. No SwiftData migration or second store. Unsaved controller drafts survive view/sidebar lifetimes while the process stays alive; no durable unsaved-draft promise. Failed saves keep prior durable state and draft for retry. Delete-all invalidates draft/save/remove/open operations; deleted/changed bookmarks cannot be opened through a stale confirmation. Preference writes preserve the library. No resource action mutates course progress, vocabulary schedules or rewards.

Native network path observation fetches no content. Offline metadata/editing remains usable; external opening is disabled while no path is available. A satisfied path does not prove destination availability. Each open uses a destination disclosure followed by revalidation and system URL handoff. Cancel invokes no URL handler. System refusal shows a recoverable error; accepted handoff cannot prove site loading. Notes never accompany the request. No thumbnail, page, video or transcript fetch, background crawler, embedding, provider request, metadata service or external messaging.

Full policy, source provenance and privacy/deletion/export behavior: [resource-library-v1](../../../contracts/resource-library-v1.md). No export/restore feature is introduced; SC-D020 retains selected-export obligations.

## Sources and integration

- `Domain/LearningResource.swift`: link policy, curated metadata, saved snapshot, editor draft and external-open intent.
- `Features/Resources/ResourceLibraryView.swift` / `ResourceEditorView.swift`: native library, connectivity observation and explicit editing/open/discard flows.
- Existing LearnerRepository/LearnerStorageController: optional document storage, epoch/revision validation and in-memory draft ownership.
- Existing AppShell: Learn navigation entry. Real project registers all three source files and `ResourceLibraryDeliveryTests.swift`.
- Two BootstrapLaunchTests journeys use UUID-isolated fixture stores and synthetic notes, with DEBUG-only no-external-open failure/offline overrides. These overrides require fixture identity and cannot activate in release builds.

Page 1 `speechcoach-kit-03.png` was inspected; T03 `2:38130`, T08 `2:38663`, Content row `41:1105`, Input `41:1127`, Status `41:1155` and Button `2:40308` map to existing Kit/native patterns. RS-01/02 are retained behavioral gaps extended by native UI; no claim of a dedicated Figma resource screen or matched-viewport fidelity. No Figma writes. Relevant native HIG and current Apple API documentation were read as recorded in the contract.

## Original requirement coverage

| Requirement | Implementation | Remaining acceptance |
| --- | --- | --- |
| SC-T039 | Source/personal cards, validated external destinations, notes, offline/errors and return to Learn | QA-11 owner/device checks and original prerequisite closure |
| SC-T168 | Owner-selected host policy recorded; YouTube normalization, metadata provenance, placeholder/no-media rights boundary, privacy/removal/export scope defined | Owner/device review of actual behavior; SC-T028 original closure |
| SC-T169 | Registered native library/editor and protected storage; duplicate, failure, stale edit/reset/deletion/open handling | Physical external navigation, full accessibility/themes/backgrounds and owner acceptance |

The original SC-T028 dependency remains pending; independent bookmark work introduces no generalized lesson runtime or claim of pilot remediation. Authorization permits this bounded implementation, not prerequisite completion or public release. Qualified curriculum review is not fabricated for external source links.

## Verification and acceptance

Executed runs, failures/repairs, source boundaries and sanitized results are maintained in [SC-D017 evidence](../testing/evidence/sc-d017-2026-10-24/README.md). Full external website handoff/loading, actual connectivity transitions, all appearances/backgrounds, largest text/VoiceOver and physical owner use remain separate checks. Existing recording/provider/curriculum behavior is covered by the hosted regression suite, not reassessed as actual learner results. No live provider call, learner reset, device install, release or Git initialization.

Final scoped verification: 209 hosted tests passed per phone/tablet integration run; final focused iPad run passed 12 hosted tests plus offline/discard/accessibility journey, and final phone confirmation journey passed. Exact failures, retests and source boundaries remain in evidence. SC-D017 and SC-T168/169 are awaiting_testing; no done promotion.
