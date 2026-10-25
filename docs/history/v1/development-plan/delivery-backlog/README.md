# Feature-sized delivery backlog

Updated 2026-10-23 at the owner’s request. **20 delivery tickets plus one completed foundation record replace child-by-child assignment.** The original 192 SC-T records remain the requirement and evidence checklist; none was deleted, renumbered, or marked complete by this regrouping.

Use this page to choose a coherent feature assignment. Use the [workflow](../ticket-workflow.md), exact SC-T files and [dependency queue](../execution-sequence.json) for current gates. The [machine-readable grouping](delivery-tickets.json) maps every original ticket exactly once, records source hashes and preserves prerequisite edges as a snapshot. It does not start automation or assign an agent.

## How to execute a delivery ticket

1. Read the mapped requirements and existing implementation. Confirm current ownership and the eligible scope using exact prerequisite/decision records. Reuse completed work.
2. Assign the feature outcome across its necessary UI, domain, persistence, content and checks. Work in reviewable changes without returning for a new assignment after each narrow checklist item.
3. For simultaneous Codex/Grok work, agree disjoint exact files before starting; one owner integrates shared runtime, project registration, builds and canonical status updates. Existing handoffs stay authoritative until explicitly replaced. This regrouping does not dispatch either agent.
4. Run relevant checks for changed behavior and one appropriate integrated verification pass. Reuse valid evidence for unchanged behavior; keep physical, provider and longitudinal learning acceptance explicit.
5. Update the underlying SC-T records with actual evidence. Implementation complete with only testing remaining becomes `awaiting_testing`. Missing code, content or decisions stays unfinished. Refresh this summary when those records change.
6. Close a delivery ticket only after every mapped requirement and its original parent acceptance is satisfied. Cross-group prerequisite edges apply to the affected requirement, not every task in the other delivery ticket. Continue eligible work while unrelated acceptance waits.

No new blanket dependency barriers, product decisions, release permission or agent assignments are introduced. The delivery IDs are scheduling identifiers, not a second set of independently editable evidence/status records.

## Current snapshot

SC-D002 personal-use authoring/runtime now awaits testing; SC-T043 remains pending actual acceptance. [Current delivery/coverage](../sc-d002-2026-10-25/README.md). Preserve independent SC-D004 work and original gates.

[Current grouped report](../grouped-ticket-report-2026-10-25.md) records SC-D017’s repaired query behavior and missing Grok return. SC-D018 is deferred per owner correction; it has not been started.

Refreshed 2026-10-25 from exact ticket records after Codex’s SC-D017 acceptance follow-up and repair.

Original ticket statuses: **11 done**, **37 awaiting_testing**, **19 in_progress**, **125 pending**, **0 blocked**. Counts measure records, not product completeness.

`Partially implemented` describes existing work, not an active agent assignment. `Awaiting testing` excludes missing implementation/content/decision work but retains all acceptance and prerequisite gates. Pending acceptance-only rows and parent closure rows are not counted as missing code when deriving a delivery summary.

| Delivery ticket | Feature outcome | Summary | Original records |
| --- | --- | --- | ---: |
| [SC-D000](#sc-d000) | Completed foundation | done | 11 |
| [SC-D001](#sc-d001) | Record, coach and revisit speaking | awaiting testing | 7 |
| [SC-D002](#sc-d002) | Complete first introduction course | awaiting testing | 5 |
| [SC-D003](#sc-d003) | Vocabulary collection and scheduled recall | awaiting testing | 7 |
| [SC-D004](#sc-d004) | Today and trustworthy progress | awaiting testing | 4 |
| [SC-D005](#sc-d005) | Rewards, achievements and motivation | in_progress | 10 |
| [SC-D006](#sc-d006) | Small A1 course pilot and stabilization | pending | 13 |
| [SC-D007](#sc-d007) | Complete A1 curriculum | in progress | 17 |
| [SC-D008](#sc-d008) | Complete A2 curriculum | pending | 15 |
| [SC-D009](#sc-d009) | Complete B1 curriculum | pending | 14 |
| [SC-D010](#sc-d010) | Complete B2 curriculum | pending | 14 |
| [SC-D011](#sc-d011) | Complete C1 curriculum | pending | 12 |
| [SC-D012](#sc-d012) | Complete C2 curriculum | pending | 9 |
| [SC-D013](#sc-d013) | Conversation, interviews and workplace practice | partially_implemented | 7 |
| [SC-D014](#sc-d014) | Communication and articulation practice | partially_implemented | 8 |
| [SC-D015](#sc-d015) | Generated practice and reporting | partially implemented | 5 |
| [SC-D016](#sc-d016) | Personal vocabulary and word discovery | partially implemented | 4 |
| [SC-D017](#sc-d017) | Learning resource library | awaiting testing | 3 |
| [SC-D018](#sc-d018) | Seven specialized trainers | pending | 12 |
| [SC-D019](#sc-d019) | Whole-app coverage and reliability | pending | 9 |
| [SC-D020](#sc-d020) | Export and installable release | pending | 6 |

## Scope and acceptance checklists

The level packs stay separate because each has its own reviewed manifest, integration gate and acceptance. Trainer packs share one delivery ticket because they share a runtime and a method matrix. Small reviewable commits and internal milestones are still appropriate; they do not require returning to narrow ticket dispatch.

<a id="sc-d000"></a>
### SC-D000 — Completed foundation

Approved foundation, native bootstrap, recovery and navigation baseline, plus award source artwork.

Archived baseline. Regressions belong to the feature that changes it.

| Requirement | Type | Status snapshot |
| --- | --- | --- |
| [SC-T001 — Define first-proof scope and completion rules](../tickets/SC-T001.md) | decision | done |
| [SC-T002 — Select native architecture and repeatable tooling](../tickets/SC-T002.md) | decision | done |
| [SC-T003 — Investigate provider and credential transport feasibility](../tickets/SC-T003.md) | investigation | done |
| [SC-T004 — Reconcile retention deletion and recovery contracts](../tickets/SC-T004.md) | decision | done |
| [SC-T005 — Specify offline curriculum delivery and versioning](../tickets/SC-T005.md) | decision | done |
| [SC-T006 — Define curriculum publication and level-completeness gates](../tickets/SC-T006.md) | decision | done |
| [SC-T007 — Review first-flow UI and native adaptation readiness](../tickets/SC-T007.md) | design | done |
| [SC-T008 — Create runnable native project and verification commands](../tickets/SC-T008.md) | implementation | done |
| [SC-T009 — Implement local state and recovery foundation](../tickets/SC-T009.md) | implementation | done |
| [SC-T010 — Implement adaptive navigation and local preferences](../tickets/SC-T010.md) | implementation | done |
| [SC-T045 — Produce the 68 adopted award-family raster masters](../tickets/SC-T045.md) | asset production | done |

<a id="sc-d001"></a>
### SC-D001 — Record, coach and revisit speaking

Record and replay speech, configure BYOK, request transcription/coaching, and revisit retained history.

Finish outstanding acceptance against the actual implementation. Fixture evidence does not prove live provider access.

| Requirement | Type | Status snapshot |
| --- | --- | --- |
| [SC-T011 — Record replay and retry an introduction offline](../tickets/SC-T011.md) | implementation | awaiting_testing |
| [SC-T012 — Implement BYOK setup and authorized requests](../tickets/SC-T012.md) | implementation | awaiting_testing |
| [SC-T013 — Transcribe and confirm a recorded attempt](../tickets/SC-T013.md) | implementation | awaiting_testing |
| [SC-T014 — Validate and present text coaching with retry](../tickets/SC-T014.md) | implementation | awaiting_testing |
| [SC-T015 — Save speech history and recover deleted records](../tickets/SC-T015.md) | implementation | awaiting_testing |
| [SC-T016 — Integrate first speaking session and truthful progress](../tickets/SC-T016.md) | implementation | awaiting_testing |
| [SC-T017 — Verify device provider and learner proof gates](../tickets/SC-T017.md) | acceptance | awaiting_testing |

External prerequisite references: [SC-D000](#sc-d000). These are references only, not whole-group blockers. Exact affected requirement edges are retained in the JSON; re-read current ticket dependencies before execution.

<a id="sc-d002"></a>
### SC-D002 — Complete first introduction course

Complete INTRO-01 from foundation lessons through connected speaking and follow-up learning checks.

[Personal-use INTRO-01 v4 content/integration](../sc-d002-2026-10-25/README.md) is delivered: post-reveal alternatives/rubric/specialist review, exact v3/v2 recovery and free comparison before completion. SC-T043 actual learner evidence remains separate; qualified review and original acceptance are still open.

| Requirement | Type | Status snapshot |
| --- | --- | --- |
| [SC-T018 — Author and review A1 Introductions topic](../tickets/SC-T018.md) | content | awaiting_testing |
| [SC-T019 — Load versioned lessons and required offline assets](../tickets/SC-T019.md) | implementation | awaiting_testing |
| [SC-T020 — Complete and resume the first lesson offline](../tickets/SC-T020.md) | implementation | awaiting_testing |
| [SC-T021 — Connect lesson vocabulary speaking and shared progress](../tickets/SC-T021.md) | implementation | awaiting_testing |
| [SC-T043 — Validate the Introductions learning loop before expansion](../tickets/SC-T043.md) | acceptance | pending |

External prerequisite references: [SC-D000](#sc-d000), [SC-D001](#sc-d001). These are references only, not whole-group blockers. Exact affected requirement edges are retained in the JSON; re-read current ticket dependencies before execution.

<a id="sc-d003"></a>
### SC-D003 — Vocabulary collection and scheduled recall

Save vocabulary by sense, enroll it in review, recover interrupted recall, and receive a reliable due queue.

Eligible implementation is complete with [SC-D003 simulator evidence](../../testing/evidence/sc-d003-2026-10-23/README.md): retention/session controls, prospective version policy and collection-to-recall behavior preserve identity/recovery/history. Original owner/device and prerequisite acceptance remain open.

| Requirement | Type | Status snapshot |
| --- | --- | --- |
| [SC-T022 — Decide scheduler and review-credit policy](../tickets/SC-T022.md) | delivery group | pending |
| [SC-T023 — Deliver vocabulary enrollment and daily reviews](../tickets/SC-T023.md) | delivery group | pending |
| [SC-T046 — Select scheduler library and versioned parameters](../tickets/SC-T046.md) | decision | awaiting_testing |
| [SC-T047 — Define review eligibility and shared sense identity](../tickets/SC-T047.md) | decision | awaiting_testing |
| [SC-T048 — Enroll shared vocabulary senses without duplicate cards](../tickets/SC-T048.md) | implementation | awaiting_testing |
| [SC-T049 — Complete an offline recall and rated review](../tickets/SC-T049.md) | implementation | awaiting_testing |
| [SC-T050 — Persist due queues and recover interrupted reviews](../tickets/SC-T050.md) | implementation | awaiting_testing |

External prerequisite references: [SC-D002](#sc-d002). These are references only, not whole-group blockers. Exact affected requirement edges are retained in the JSON; re-read current ticket dependencies before execution.

<a id="sc-d004"></a>
### SC-D004 — Today and trustworthy progress

Choose a grounded next practice and inspect daily/weekly learning evidence and confidence.

Complete recommendation and progress behavior together. Original SC-T024 closure also requires SC-T053 in the reward delivery ticket.

| Requirement | Type | Status snapshot |
| --- | --- | --- |
| [SC-T024 — Implement daily recommendations and progress evidence](../tickets/SC-T024.md) | delivery group | pending |
| [SC-T051 — Suggest next practice with an explanation and override](../tickets/SC-T051.md) | implementation | awaiting_testing |
| [SC-T052 — Display separate learning evidence and comparison history](../tickets/SC-T052.md) | implementation | awaiting_testing |
| [SC-T054 — Show weekly summaries and connected daily focus](../tickets/SC-T054.md) | implementation | awaiting_testing |

External prerequisite references: [SC-D003](#sc-d003), [SC-D005](#sc-d005). These are references only, not whole-group blockers. Exact affected requirement edges are retained in the JSON; re-read current ticket dependencies before execution.

<a id="sc-d005"></a>
### SC-D005 — Rewards, achievements and motivation

Earn and inspect rewards, use hints, manage streak repair and goals, and see appropriate celebrations.

Owner-adopted policy and personal-use runtime: [SC-D005](../sc-d005-2026-10-25/README.md), status in_progress. All 68 families retain versioned criteria/availability; future/learning/CEFR claims stay unavailable. Original acceptance/requires_done gates remain; historical Grok drafts stay unchanged.

| Requirement | Type | Status snapshot |
| --- | --- | --- |
| [SC-T025 — Implement approved rewards and goal lifecycle](../tickets/SC-T025.md) | delivery group | in_progress |
| [SC-T053 — Show achievement criteria and evidence availability](../tickets/SC-T053.md) | implementation | in_progress |
| [SC-T055 — Settle reward event and local-day policies](../tickets/SC-T055.md) | decision | in_progress |
| [SC-T056 — Define finite AW instances and reviewed earning rules](../tickets/SC-T056.md) | decision | in_progress |
| [SC-T057 — Commit participation credits and gold spending once](../tickets/SC-T057.md) | implementation | in_progress |
| [SC-T058 — Deliver free hints and explicit optional assistance purchases](../tickets/SC-T058.md) | implementation | in_progress |
| [SC-T059 — Deliver Freeze inventory and Repair continuity](../tickets/SC-T059.md) | implementation | in_progress |
| [SC-T060 — Track daily goals break timer and private reminders](../tickets/SC-T060.md) | implementation | in_progress |
| [SC-T061 — Prepare adopted native award artwork and state overlays](../tickets/SC-T061.md) | asset production | in_progress |
| [SC-T062 — Present committed results and skippable celebrations](../tickets/SC-T062.md) | implementation | in_progress |

External prerequisite references: [SC-D000](#sc-d000), [SC-D003](#sc-d003), [SC-D004](#sc-d004). These are references only, not whole-group blockers. Exact affected requirement edges are retained in the JSON; re-read current ticket dependencies before execution.

<a id="sc-d006"></a>
### SC-D006 — Small A1 course pilot and stabilization

Deliver the bounded A1 course, evaluate its learning journey, and fix observed pilot defects.

Preserve expansion approval and prospective evaluation gates. Reuse actual defect evidence; do not invent issues to close repair scope.

| Requirement | Type | Status snapshot |
| --- | --- | --- |
| [SC-T026 — Expand proven patterns into a bounded A1 course](../tickets/SC-T026.md) | delivery group | pending |
| [SC-T027 — Validate teaching usefulness and native usability](../tickets/SC-T027.md) | delivery group | pending |
| [SC-T028 — Generalize demonstrated patterns and resolve pilot defects](../tickets/SC-T028.md) | delivery group | pending |
| [SC-T063 — Freeze the small A1 course topic and objective manifest](../tickets/SC-T063.md) | decision | pending |
| [SC-T064 — Author the small-course personal and routine topic batch](../tickets/SC-T064.md) | content | pending |
| [SC-T065 — Author the small-course everyday needs topic batch](../tickets/SC-T065.md) | content | pending |
| [SC-T066 — Run the bounded small A1 course using proven activities](../tickets/SC-T066.md) | implementation | pending |
| [SC-T067 — Freeze small-course learning and owner evaluation protocol](../tickets/SC-T067.md) | decision | pending |
| [SC-T068 — Execute small-course learning and usefulness evaluation](../tickets/SC-T068.md) | acceptance | pending |
| [SC-T069 — Validate small-course native daily journeys](../tickets/SC-T069.md) | acceptance | pending |
| [SC-T070 — Freeze blocking pilot defects and reuse opportunities](../tickets/SC-T070.md) | decision | pending |
| [SC-T071 — Extract only demonstrated reusable activity behavior](../tickets/SC-T071.md) | refactor | pending |
| [SC-T072 — Close and retest the frozen blocking pilot defect batch](../tickets/SC-T072.md) | implementation | pending |

External prerequisite references: [SC-D000](#sc-d000), [SC-D002](#sc-d002), [SC-D004](#sc-d004), [SC-D005](#sc-d005). These are references only, not whole-group blockers. Exact affected requirement edges are retained in the JSON; re-read current ticket dependencies before execution.

<a id="sc-d007"></a>
### SC-D007 — Complete A1 curriculum

Provide the complete approved A1 topic pack through the shared course runtime.

2026-10-23: Codex authored an [unpublished thirteen-topic candidate](../sc-d007-codex-2026-10-23/README.md); ten boundary tests and thirteen synthetic production-code sessions pass. Owner approved the thirteen-topic scope ([decision](../sc-d007-codex-2026-10-23/scope-approval.json)); qualified review/full manifest acceptance, historical-version access, live integration and full native/learner acceptance remain open. Grok handoff is queued, not active. Subsequent owner-authorized [runtime implementation](../sc-d007-implementation-2026-10-23.md) is complete for the finite personal-use scope: SC-T073–087 await testing/review, exact v2 versions remain resumable, and SC-T029/088 retain full original closure/acceptance gates.

Freeze the manifest, author/review its topics, integrate the pack and demonstrate level acceptance. Topic rows are a checklist, not separate routine assignments.

| Requirement | Type | Status snapshot |
| --- | --- | --- |
| [SC-T029 — Complete reviewed A1 five-skill curriculum](../tickets/SC-T029.md) | delivery group | in_progress |
| [SC-T073 — Freeze A1 unit objective and publication manifest](../tickets/SC-T073.md) | decision | awaiting_testing |
| [SC-T074 — Author and review A1 topic: Greetings](../tickets/SC-T074.md) | content | awaiting_testing |
| [SC-T075 — Reconcile A1 introductions coverage with the reviewed INTRO-01 pack](../tickets/SC-T075.md) | content | awaiting_testing |
| [SC-T076 — Author and review A1 topic: alphabet and spelling](../tickets/SC-T076.md) | content | awaiting_testing |
| [SC-T077 — Author and review A1 topic: numbers](../tickets/SC-T077.md) | content | awaiting_testing |
| [SC-T078 — Author and review A1 topic: dates and time](../tickets/SC-T078.md) | content | awaiting_testing |
| [SC-T079 — Author and review A1 topic: family](../tickets/SC-T079.md) | content | awaiting_testing |
| [SC-T080 — Author and review A1 topic: home](../tickets/SC-T080.md) | content | awaiting_testing |
| [SC-T081 — Author and review A1 topic: daily routines](../tickets/SC-T081.md) | content | awaiting_testing |
| [SC-T082 — Author and review A1 topic: food](../tickets/SC-T082.md) | content | awaiting_testing |
| [SC-T083 — Author and review A1 topic: shopping](../tickets/SC-T083.md) | content | awaiting_testing |
| [SC-T084 — Author and review A1 topic: places and directions](../tickets/SC-T084.md) | content | awaiting_testing |
| [SC-T085 — Author and review A1 topic: hobbies](../tickets/SC-T085.md) | content | awaiting_testing |
| [SC-T086 — Author and review A1 topic: weather](../tickets/SC-T086.md) | content | awaiting_testing |
| [SC-T087 — Integrate reviewed A1 packs without changing learner history](../tickets/SC-T087.md) | implementation | awaiting_testing |
| [SC-T088 — Accept A1 five-skill completeness and learning evidence](../tickets/SC-T088.md) | acceptance | pending |

External prerequisite references: [SC-D000](#sc-d000), [SC-D002](#sc-d002), [SC-D006](#sc-d006). These are references only, not whole-group blockers. Exact affected requirement edges are retained in the JSON; re-read current ticket dependencies before execution.

<a id="sc-d008"></a>
### SC-D008 — Complete A2 curriculum

Provide the complete approved A2 topic pack through the shared course runtime.

Batch manifest, topic content, integration and acceptance. Retain the original upstream integration gate.

| Requirement | Type | Status snapshot |
| --- | --- | --- |
| [SC-T030 — Complete reviewed A2 five-skill curriculum](../tickets/SC-T030.md) | delivery group | pending |
| [SC-T089 — Freeze A2 unit objective and publication manifest](../tickets/SC-T089.md) | decision | pending |
| [SC-T090 — Author and review A2 topic: Travel](../tickets/SC-T090.md) | content | pending |
| [SC-T091 — Author and review A2 topic: transportation](../tickets/SC-T091.md) | content | pending |
| [SC-T092 — Author and review A2 topic: appointments](../tickets/SC-T092.md) | content | pending |
| [SC-T093 — Author and review A2 topic: health](../tickets/SC-T093.md) | content | pending |
| [SC-T094 — Author and review A2 topic: eating out](../tickets/SC-T094.md) | content | pending |
| [SC-T095 — Author and review A2 topic: invitations](../tickets/SC-T095.md) | content | pending |
| [SC-T096 — Author and review A2 topic: leisure](../tickets/SC-T096.md) | content | pending |
| [SC-T097 — Author and review A2 topic: work routines](../tickets/SC-T097.md) | content | pending |
| [SC-T098 — Author and review A2 topic: past experiences](../tickets/SC-T098.md) | content | pending |
| [SC-T099 — Author and review A2 topic: future plans](../tickets/SC-T099.md) | content | pending |
| [SC-T100 — Author and review A2 topic: everyday problems](../tickets/SC-T100.md) | content | pending |
| [SC-T101 — Integrate reviewed A2 packs without changing learner history](../tickets/SC-T101.md) | implementation | pending |
| [SC-T102 — Accept A2 five-skill completeness and learning evidence](../tickets/SC-T102.md) | acceptance | pending |

External prerequisite references: [SC-D000](#sc-d000), [SC-D002](#sc-d002), [SC-D007](#sc-d007). These are references only, not whole-group blockers. Exact affected requirement edges are retained in the JSON; re-read current ticket dependencies before execution.

<a id="sc-d009"></a>
### SC-D009 — Complete B1 curriculum

Provide the complete approved B1 topic pack through the shared course runtime.

Batch manifest, topic content, integration and acceptance. Retain the original upstream integration gate.

| Requirement | Type | Status snapshot |
| --- | --- | --- |
| [SC-T031 — Complete reviewed B1 five-skill curriculum](../tickets/SC-T031.md) | delivery group | pending |
| [SC-T103 — Freeze B1 unit objective and publication manifest](../tickets/SC-T103.md) | decision | pending |
| [SC-T104 — Author and review B1 topic: Education](../tickets/SC-T104.md) | content | pending |
| [SC-T105 — Author and review B1 topic: career goals](../tickets/SC-T105.md) | content | pending |
| [SC-T106 — Author and review B1 topic: relationships](../tickets/SC-T106.md) | content | pending |
| [SC-T107 — Author and review B1 topic: technology](../tickets/SC-T107.md) | content | pending |
| [SC-T108 — Author and review B1 topic: entertainment](../tickets/SC-T108.md) | content | pending |
| [SC-T109 — Author and review B1 topic: culture](../tickets/SC-T109.md) | content | pending |
| [SC-T110 — Author and review B1 topic: community](../tickets/SC-T110.md) | content | pending |
| [SC-T111 — Author and review B1 topic: personal achievements](../tickets/SC-T111.md) | content | pending |
| [SC-T112 — Author and review B1 topic: decisions](../tickets/SC-T112.md) | content | pending |
| [SC-T113 — Author and review B1 topic: unexpected situations](../tickets/SC-T113.md) | content | pending |
| [SC-T114 — Integrate reviewed B1 packs without changing learner history](../tickets/SC-T114.md) | implementation | pending |
| [SC-T115 — Accept B1 five-skill completeness and learning evidence](../tickets/SC-T115.md) | acceptance | pending |

External prerequisite references: [SC-D000](#sc-d000), [SC-D002](#sc-d002), [SC-D008](#sc-d008). These are references only, not whole-group blockers. Exact affected requirement edges are retained in the JSON; re-read current ticket dependencies before execution.

<a id="sc-d010"></a>
### SC-D010 — Complete B2 curriculum

Provide the complete approved B2 topic pack through the shared course runtime.

Batch manifest, topic content, integration and acceptance. Retain the original upstream integration gate.

| Requirement | Type | Status snapshot |
| --- | --- | --- |
| [SC-T032 — Complete reviewed B2 five-skill curriculum](../tickets/SC-T032.md) | delivery group | pending |
| [SC-T116 — Freeze B2 unit objective and publication manifest](../tickets/SC-T116.md) | decision | pending |
| [SC-T117 — Author and review B2 topic: Professional projects](../tickets/SC-T117.md) | content | pending |
| [SC-T118 — Author and review B2 topic: leadership](../tickets/SC-T118.md) | content | pending |
| [SC-T119 — Author and review B2 topic: media](../tickets/SC-T119.md) | content | pending |
| [SC-T120 — Author and review B2 topic: social issues](../tickets/SC-T120.md) | content | pending |
| [SC-T121 — Author and review B2 topic: innovation](../tickets/SC-T121.md) | content | pending |
| [SC-T122 — Author and review B2 topic: ethics](../tickets/SC-T122.md) | content | pending |
| [SC-T123 — Author and review B2 topic: environment](../tickets/SC-T123.md) | content | pending |
| [SC-T124 — Author and review B2 topic: presentations](../tickets/SC-T124.md) | content | pending |
| [SC-T125 — Author and review B2 topic: negotiation](../tickets/SC-T125.md) | content | pending |
| [SC-T126 — Author and review B2 topic: disagreements](../tickets/SC-T126.md) | content | pending |
| [SC-T127 — Integrate reviewed B2 packs without changing learner history](../tickets/SC-T127.md) | implementation | pending |
| [SC-T128 — Accept B2 five-skill completeness and learning evidence](../tickets/SC-T128.md) | acceptance | pending |

External prerequisite references: [SC-D000](#sc-d000), [SC-D002](#sc-d002), [SC-D009](#sc-d009). These are references only, not whole-group blockers. Exact affected requirement edges are retained in the JSON; re-read current ticket dependencies before execution.

<a id="sc-d011"></a>
### SC-D011 — Complete C1 curriculum

Provide the complete approved C1 topic pack through the shared course runtime.

Batch manifest, topic content, integration and acceptance. Retain the original upstream integration gate.

| Requirement | Type | Status snapshot |
| --- | --- | --- |
| [SC-T033 — Complete reviewed C1 five-skill curriculum](../tickets/SC-T033.md) | delivery group | pending |
| [SC-T129 — Freeze C1 unit objective and publication manifest](../tickets/SC-T129.md) | decision | pending |
| [SC-T130 — Author and review C1 topic: Strategy](../tickets/SC-T130.md) | content | pending |
| [SC-T131 — Author and review C1 topic: research](../tickets/SC-T131.md) | content | pending |
| [SC-T132 — Author and review C1 topic: organizational change](../tickets/SC-T132.md) | content | pending |
| [SC-T133 — Author and review C1 topic: complex problems](../tickets/SC-T133.md) | content | pending |
| [SC-T134 — Author and review C1 topic: policy](../tickets/SC-T134.md) | content | pending |
| [SC-T135 — Author and review C1 topic: sensitive workplace discussions](../tickets/SC-T135.md) | content | pending |
| [SC-T136 — Author and review C1 topic: specialist debates](../tickets/SC-T136.md) | content | pending |
| [SC-T137 — Author and review C1 topic: cross-cultural communication](../tickets/SC-T137.md) | content | pending |
| [SC-T138 — Integrate reviewed C1 packs without changing learner history](../tickets/SC-T138.md) | implementation | pending |
| [SC-T139 — Accept C1 five-skill completeness and learning evidence](../tickets/SC-T139.md) | acceptance | pending |

External prerequisite references: [SC-D000](#sc-d000), [SC-D002](#sc-d002), [SC-D010](#sc-d010). These are references only, not whole-group blockers. Exact affected requirement edges are retained in the JSON; re-read current ticket dependencies before execution.

<a id="sc-d012"></a>
### SC-D012 — Complete C2 curriculum

Provide the complete approved C2 topic pack through the shared course runtime.

Batch manifest, topic content, integration and acceptance. Retain the original upstream integration gate.

| Requirement | Type | Status snapshot |
| --- | --- | --- |
| [SC-T034 — Complete reviewed C2 five-skill curriculum](../tickets/SC-T034.md) | delivery group | pending |
| [SC-T140 — Freeze C2 unit objective and publication manifest](../tickets/SC-T140.md) | decision | pending |
| [SC-T141 — Author and review C2 topic: Abstract ideas](../tickets/SC-T141.md) | content | pending |
| [SC-T142 — Author and review C2 topic: competing interpretations](../tickets/SC-T142.md) | content | pending |
| [SC-T143 — Author and review C2 topic: sophisticated debate](../tickets/SC-T143.md) | content | pending |
| [SC-T144 — Author and review C2 topic: cultural references](../tickets/SC-T144.md) | content | pending |
| [SC-T145 — Author and review C2 topic: complex multidisciplinary problems](../tickets/SC-T145.md) | content | pending |
| [SC-T146 — Integrate reviewed C2 packs without changing learner history](../tickets/SC-T146.md) | implementation | pending |
| [SC-T147 — Accept C2 five-skill completeness and learning evidence](../tickets/SC-T147.md) | acceptance | pending |

External prerequisite references: [SC-D000](#sc-d000), [SC-D002](#sc-d002), [SC-D011](#sc-d011). These are references only, not whole-group blockers. Exact affected requirement edges are retained in the JSON; re-read current ticket dependencies before execution.

<a id="sc-d013"></a>
### SC-D013 — Conversation, interviews and workplace practice

Practice turn-based conversation and interview/workplace follow-ups with appropriate retained context.

Deliver content and supported conversation behavior together. Realtime feasibility remains research and does not silently authorize a realtime product.

| Requirement | Type | Status snapshot |
| --- | --- | --- |
| [SC-T035 — Deliver interview business and expanded speaking coverage](../tickets/SC-T035.md) | delivery group | in_progress |
| [SC-T148 — Define conversation interview turn and workplace contracts](../tickets/SC-T148.md) | decision | pending |
| [SC-T149 — Author reviewed workplace communication and interview scenarios](../tickets/SC-T149.md) | content | pending |
| [SC-T150 — Deliver explicit text or recorded-turn conversation](../tickets/SC-T150.md) | implementation | in_progress |
| [SC-T151 — Deliver response-dependent interview follow-ups and retry](../tickets/SC-T151.md) | implementation | in_progress |
| [SC-T152 — Validate workplace and conversational practice boundaries](../tickets/SC-T152.md) | acceptance | pending |
| [SC-T153 — Record later realtime feasibility and release decision](../tickets/SC-T153.md) | investigation | pending |

External prerequisite references: [SC-D000](#sc-d000), [SC-D001](#sc-d001), [SC-D006](#sc-d006). These are references only, not whole-group blockers. Exact affected requirement edges are retained in the JSON; re-read current ticket dependencies before execution.

<a id="sc-d014"></a>
### SC-D014 — Communication and articulation practice

Practice organization and articulation offline, with supported audio assessment and focused feedback.

Connect approved content, practice, assessment boundaries and feedback; distinguish self-review from measured speech claims.

| Requirement | Type | Status snapshot |
| --- | --- | --- |
| [SC-T036 — Deliver communication and articulation practice](../tickets/SC-T036.md) | delivery group | in_progress |
| [SC-T154 — Freeze communication and articulation teaching subsets](../tickets/SC-T154.md) | decision | in_progress |
| [SC-T155 — Author reviewed organization listening and interaction drills](../tickets/SC-T155.md) | content | in_progress |
| [SC-T156 — Author reviewed articulation and delivery reference drills](../tickets/SC-T156.md) | content | in_progress |
| [SC-T157 — Deliver shared offline communication and articulation practice](../tickets/SC-T157.md) | implementation | in_progress |
| [SC-T158 — Validate the audio assessment boundary before sound feedback](../tickets/SC-T158.md) | investigation | in_progress |
| [SC-T159 — Deliver supported focused communication feedback](../tickets/SC-T159.md) | implementation | in_progress |
| [SC-T160 — Validate communication articulation and fresh-task evidence](../tickets/SC-T160.md) | acceptance | pending |

External prerequisite references: [SC-D000](#sc-d000), [SC-D001](#sc-d001), [SC-D002](#sc-d002), [SC-D006](#sc-d006). These are references only, not whole-group blockers. Exact affected requirement edges are retained in the JSON; re-read current ticket dependencies before execution.

<a id="sc-d015"></a>
### SC-D015 — Generated practice and reporting

Request policy-constrained practice variants and inspect the resulting practice reports.

[Reviewed local integration](../sc-d015-integration-2026-10-25.md) connects repaired request/cache/report machinery and protected storage. Production policy, model/adapter, content/semantic validation and original acceptance remain incomplete; generation is disabled.

| Requirement | Type | Status snapshot |
| --- | --- | --- |
| [SC-T037 — Generate validated practice with offline fallbacks](../tickets/SC-T037.md) | delivery group | in_progress |
| [SC-T161 — Define bounded generation validation and reporting policy](../tickets/SC-T161.md) | decision | in_progress |
| [SC-T162 — Generate and validate one explicit practice request safely](../tickets/SC-T162.md) | implementation | in_progress |
| [SC-T163 — Reuse compatible variants without resetting learning identities](../tickets/SC-T163.md) | implementation | in_progress |
| [SC-T164 — Record and resolve incorrect-activity reports locally](../tickets/SC-T164.md) | implementation | in_progress |

External prerequisite references: [SC-D000](#sc-d000), [SC-D001](#sc-d001), [SC-D006](#sc-d006). These are references only, not whole-group blockers. Exact affected requirement edges are retained in the JSON; re-read current ticket dependencies before execution.

<a id="sc-d016"></a>
### SC-D016 — Personal vocabulary and word discovery

Create personal vocabulary topics and discover generated vocabulary and a word of the day.

[Reviewed local integration](../sc-d016-integration-2026-10-25.md) repairs discovery/request/privacy and daily pin stability. Topic-aware generation/enrollment, approved daily policy/pool and optional enrollment remain incomplete. Manual topics remain awaiting_testing.

| Requirement | Type | Status snapshot |
| --- | --- | --- |
| [SC-T038 — Deliver Word of Day and custom vocabulary topics](../tickets/SC-T038.md) | delivery group | in_progress |
| [SC-T165 — Create and edit custom vocabulary topics offline](../tickets/SC-T165.md) | implementation | awaiting_testing |
| [SC-T166 — Preview select and enroll generated topic vocabulary](../tickets/SC-T166.md) | implementation | in_progress |
| [SC-T167 — Deliver a stable Word of the Day with offline fallback](../tickets/SC-T167.md) | implementation | in_progress |

External prerequisite references: [SC-D003](#sc-d003), [SC-D005](#sc-d005), [SC-D015](#sc-d015). These are references only, not whole-group blockers. Exact affected requirement edges are retained in the JSON; re-read current ticket dependencies before execution.

<a id="sc-d017"></a>
### SC-D017 — Learning resource library

Find and use curated learning resources with clear source and availability information.

[Owner-selected HTTPS policy and registered resource library](../sc-d017-implementation-2026-10-24.md) are implemented. Original QA-11 physical/accessibility/external-site acceptance and SC-T028/parent closure remain open; group is awaiting testing.

| Requirement | Type | Status snapshot |
| --- | --- | --- |
| [SC-T039 — Deliver supporting resource bookmarks](../tickets/SC-T039.md) | delivery group | pending |
| [SC-T168 — Decide resource destinations metadata and thumbnail rights](../tickets/SC-T168.md) | decision | awaiting_testing |
| [SC-T169 — Save curated and personal resource cards safely](../tickets/SC-T169.md) | implementation | awaiting_testing |

External prerequisite references: [SC-D006](#sc-d006). These are references only, not whole-group blockers. Exact affected requirement edges are retained in the JSON; re-read current ticket dependencies before execution.

<a id="sc-d018"></a>
### SC-D018 — Seven specialized trainers

Use all seven adopted trainer methods through a shared runtime with method-specific content and behavior.

Implement the shared trainer contract/runtime once, then complete every method pack and its acceptance checklist. Internal milestones may divide work without creating new routine child tickets.

| Requirement | Type | Status snapshot |
| --- | --- | --- |
| [SC-T044 — Deliver and validate seven specialized trainer packs](../tickets/SC-T044.md) | delivery group | pending |
| [SC-T182 — Freeze all-seven role objective and level coverage matrix](../tickets/SC-T182.md) | decision | pending |
| [SC-T183 — Resolve Creative Writer character and optional voice design](../tickets/SC-T183.md) | decision | pending |
| [SC-T184 — Run explicit specialist packs with safe switch and course return](../tickets/SC-T184.md) | implementation | pending |
| [SC-T185 — Author and review Teacher specialist pack coverage](../tickets/SC-T185.md) | content | pending |
| [SC-T186 — Author and review Grammarian specialist pack coverage](../tickets/SC-T186.md) | content | pending |
| [SC-T187 — Author and review Librarian specialist pack coverage](../tickets/SC-T187.md) | content | pending |
| [SC-T188 — Author and review Journalist specialist pack coverage](../tickets/SC-T188.md) | content | pending |
| [SC-T189 — Author and review Business Professional specialist pack coverage](../tickets/SC-T189.md) | content | pending |
| [SC-T190 — Author and review Speaker specialist pack coverage](../tickets/SC-T190.md) | content | pending |
| [SC-T191 — Author and review Creative Writer specialist pack coverage](../tickets/SC-T191.md) | content | pending |
| [SC-T192 — Validate all-seven specialist methods and retained learning](../tickets/SC-T192.md) | acceptance | pending |

External prerequisite references: [SC-D000](#sc-d000), [SC-D002](#sc-d002), [SC-D006](#sc-d006), [SC-D013](#sc-d013), [SC-D014](#sc-d014). These are references only, not whole-group blockers. Exact affected requirement edges are retained in the JSON; re-read current ticket dependencies before execution.

<a id="sc-d019"></a>
### SC-D019 — Whole-app coverage and reliability

Demonstrate curriculum/capability/award coverage and reliable persistence, accessibility and network/privacy behavior.

Consolidate audits and regression evidence. Fix observed defects in their owning feature; do not mislabel verification-only work as missing feature implementation.

| Requirement | Type | Status snapshot |
| --- | --- | --- |
| [SC-T040 — Audit full release curriculum and capability coverage](../tickets/SC-T040.md) | delivery group | pending |
| [SC-T041 — Verify release reliability privacy and accessibility](../tickets/SC-T041.md) | delivery group | pending |
| [SC-T170 — Audit complete level and foundation publication coverage](../tickets/SC-T170.md) | acceptance | pending |
| [SC-T171 — Audit all-seven trainer workplace and practice capability claims](../tickets/SC-T171.md) | acceptance | pending |
| [SC-T172 — Audit all award families evidence states and unchanged economics](../tickets/SC-T172.md) | acceptance | pending |
| [SC-T173 — Freeze release regression matrix and measurable budgets](../tickets/SC-T173.md) | decision | pending |
| [SC-T174 — Verify persistence upgrades retention export and reset recovery](../tickets/SC-T174.md) | acceptance | pending |
| [SC-T175 — Verify all supported native appearance and accessibility journeys](../tickets/SC-T175.md) | acceptance | pending |
| [SC-T176 — Verify credential cost and network failure containment](../tickets/SC-T176.md) | acceptance | pending |

External prerequisite references: [SC-D000](#sc-d000), [SC-D004](#sc-d004), [SC-D005](#sc-d005), [SC-D012](#sc-d012), [SC-D013](#sc-d013), [SC-D014](#sc-d014), [SC-D015](#sc-d015), [SC-D016](#sc-d016), [SC-D017](#sc-d017), [SC-D018](#sc-d018), [SC-D020](#sc-d020). These are references only, not whole-group blockers. Exact affected requirement edges are retained in the JSON; re-read current ticket dependencies before execution.

<a id="sc-d020"></a>
### SC-D020 — Export and installable release

Export supported learner data and deliver the selected signed distribution with a usable handoff.

Implement approved export, establish distribution, and verify the signed handoff. Publication and sensitive external actions retain their existing authorization requirements.

| Requirement | Type | Status snapshot |
| --- | --- | --- |
| [SC-T042 — Prepare distribution recovery and release handoff](../tickets/SC-T042.md) | delivery group | pending |
| [SC-T177 — Define selected export and any explicit restore boundary](../tickets/SC-T177.md) | decision | pending |
| [SC-T178 — Export only explicitly selected retained learner data](../tickets/SC-T178.md) | implementation | pending |
| [SC-T179 — Select distribution signing identity and release recovery procedure](../tickets/SC-T179.md) | decision | pending |
| [SC-T180 — Prepare a repeatable signed release candidate](../tickets/SC-T180.md) | implementation | pending |
| [SC-T181 — Write verified release and recovery handoff](../tickets/SC-T181.md) | documentation | pending |

External prerequisite references: [SC-D000](#sc-d000), [SC-D001](#sc-d001), [SC-D006](#sc-d006), [SC-D019](#sc-d019). These are references only, not whole-group blockers. Exact affected requirement edges are retained in the JSON; re-read current ticket dependencies before execution.

## Validation and maintenance

The initial grouping was checked for all 192 original IDs appearing exactly once, all 22 original parent closure records being retained, valid prerequisite references, preserved queue prerequisite arrays, and unchanged source ticket status/hash during generation. No application build is required for this planning change.

Ticket files remain the live status authority. This snapshot is dated, not a live dashboard. When refreshing, read each ticket’s current status/type/source hash and the current queue prerequisites; recompute summaries using the JSON status policy. Never infer that a pending record is unimplemented without checking its source and evidence.

SC-D013 local preview is connected under owner authorization; see [integration and remaining gates](../sc-d013-integration-2026-10-24.md). Its original online, content and acceptance work remains incomplete. SC-D014 was dispatched to Grok; a dispatch is not completion evidence.

SC-D014 returned code was reviewed, repaired and connected under owner authorization. See [local integration and original gaps](../sc-d014-integration-2026-10-24.md); missing code/content/decisions prevent awaiting_testing or closure.

SC-D004 refresh, 2026-10-25: [Connected focus/evidence](../sc-d004-2026-10-25.md) is awaiting_testing. Original SC-T024 reward/prerequisite closure and qualified content/device/manual/learning acceptance remain open.
