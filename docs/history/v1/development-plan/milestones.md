# Milestones and ticket index

> Created 2026-10-17 at owner request. Proposed milestone organization is now recorded as a planning baseline; implementation, provider proof and milestone acceptance remain pending. No dates or delivery estimates are committed.

## Delivery rules

Speaking leads the first usable increment. M0–M3 retain their detailed tickets; all 22 later outlines now have bounded children in the [decomposition register](decomposition.md). Parent delivery groups retain their full acceptance; decomposition does not mark them delivered. Read the [ticket workflow](ticket-workflow.md) and [existing feature tracker](development-plan.md). M4 has completed independently authorized base raster artwork preparation; other milestones remain pending and no daily-loop runtime gate is closed. Existing SC-003 design work remains in_progress independently.

Milestone numbers describe outcome gates, not a rigid waterfall. Authoring/review may overlap engineering. M12 work can proceed after its own prerequisites and level-appropriate interview/business material belongs throughout the curriculum. M6–M11 do not forbid freely selecting any available level; authoring order is distinct from learner access. Realtime conversation, accounts, sync, other languages and embedded video remain deferred backlog, without release commitment.

Offline core learning applies to every published level with locally available required reviewed assets. SC-T005 selects bundle-first versioned reviewed content and required reference assets, delivered via app updates with offline first-launch behavior. Fresh cloud generation and personalized feedback require connectivity and configured capability. Public release requires all six levels; internal proofs cannot replace that requirement.

Monitor current ticket status, readiness, next actions and evidence in the [progress tracker](progress.md), starting with [M0](progress.md#m0).

## Summary

| Milestone | Outcome | Status | Parent work |
| --- | --- | --- | --- |
| [M0](#m0) | Implementation decisions | blocked | SC-001, SC-002, SC-003, SC-014, SC-015 |
| [M1](#m1) | Runnable app foundation | in_progress | SC-003, SC-005 |
| [M2](#m2) | First speaking loop | in_progress | SC-004, SC-006, SC-009, SC-015 |
| [M3](#m3) | One complete A1 topic | pending | SC-006, SC-007, SC-008, SC-011, SC-014 |
| [M4](#m4) | Connected daily practice | in_progress | SC-007, SC-009 |
| [M5](#m5) | Small A1 course and owner validation | pending | SC-003, SC-005, SC-008, SC-011, SC-014 |
| [M6](#m6) | Complete A1 | pending | SC-008, SC-014 |
| [M7](#m7) | Complete A2 | pending | SC-008, SC-014 |
| [M8](#m8) | Complete B1 | pending | SC-008, SC-014 |
| [M9](#m9) | Complete B2 | pending | SC-008, SC-014 |
| [M10](#m10) | Complete C1 | pending | SC-008, SC-014 |
| [M11](#m11) | Complete C2 | pending | SC-008, SC-014 |
| [M12](#m12) | Expanded coaching and practice | pending | SC-003, SC-007, SC-008, SC-010, SC-012, SC-013, SC-014, SC-016 |
| [M13](#m13) | Public-release readiness | pending | SC-011, SC-014 |

<a id="m0"></a>
## M0 · Implementation decisions

- Status: done
- Dependencies: None; individual ticket prerequisites still apply.
- Exit criteria: Relevant decisions have settled first-slice scope, architecture, provider candidate, retention, offline delivery, shared publication rules/INTRO-01 mappings and first-flow design inputs. Later curriculum detail and native runtime acceptance remain with their scoped delivery gates. Decisions requiring owner agreement carry actual evidence. Partial readiness follows individual ticket prerequisites; closing M0 does not authorize development.

| Ticket | Type | Status | Dependencies |
| --- | --- | --- | --- |
| [SC-T001 · Define first-proof scope and completion rules](tickets/SC-T001.md) | decision | done | None |
| [SC-T002 · Select native architecture and repeatable tooling](tickets/SC-T002.md) | decision | done | [SC-T001](tickets/SC-T001.md) |
| [SC-T003 · Investigate provider and credential transport feasibility](tickets/SC-T003.md) | investigation | done | [SC-T001](tickets/SC-T001.md) |
| [SC-T004 · Reconcile retention deletion and recovery contracts](tickets/SC-T004.md) | decision | done | [SC-T001](tickets/SC-T001.md) |
| [SC-T005 · Specify offline curriculum delivery and versioning](tickets/SC-T005.md) | decision | done | [SC-T001](tickets/SC-T001.md) |
| [SC-T006 · Define curriculum publication and level-completeness gates](tickets/SC-T006.md) | decision | done | [SC-T001](tickets/SC-T001.md) |
| [SC-T007 · Review first-flow UI and native adaptation readiness](tickets/SC-T007.md) | design | done | [SC-T001](tickets/SC-T001.md) |

<a id="m1"></a>
## M1 · Runnable app foundation

- Status: in_progress
- Dependencies: Relevant M0 decisions, especially SC-T002/SC-T004/SC-T007.
- Exit criteria: Repeatable build and launch on iPhone/iPad; durable local settings/state; accessible native navigation and no-key/offline entry. Simulator and physical evidence remain distinct.

| Ticket | Type | Status | Dependencies |
| --- | --- | --- | --- |
| [SC-T008 · Create runnable native project and verification commands](tickets/SC-T008.md) | implementation | done | [SC-T002](tickets/SC-T002.md) |
| [SC-T009 · Implement local state and recovery foundation](tickets/SC-T009.md) | implementation | done | [SC-T008](tickets/SC-T008.md), [SC-T004](tickets/SC-T004.md) |
| [SC-T010 · Implement adaptive navigation and local preferences](tickets/SC-T010.md) | implementation | done | [SC-T008](tickets/SC-T008.md), [SC-T009](tickets/SC-T009.md), [SC-T007](tickets/SC-T007.md) |

<a id="m2"></a>
## M2 · First speaking loop

- Status: in_progress
- Dependencies: M1 plus SC-T003/SC-T004.
- Exit criteria: Recorded introduction → replay → explicit transcription/confirmation/coaching → retry and independent retention works; offline self-review and recovery work; RF device/provider/owner gates have evidence.

| Ticket | Type | Status | Dependencies |
| --- | --- | --- | --- |
| [SC-T011 · Record replay and retry an introduction offline](tickets/SC-T011.md) | implementation | awaiting_testing | [SC-T009](tickets/SC-T009.md), [SC-T010](tickets/SC-T010.md) |
| [SC-T012 · Implement BYOK setup and authorized requests](tickets/SC-T012.md) | implementation | awaiting_testing | [SC-T003](tickets/SC-T003.md), [SC-T008](tickets/SC-T008.md), [SC-T010](tickets/SC-T010.md) |
| [SC-T013 · Transcribe and confirm a recorded attempt](tickets/SC-T013.md) | implementation | awaiting_testing | [SC-T011](tickets/SC-T011.md), [SC-T012](tickets/SC-T012.md) |
| [SC-T014 · Validate and present text coaching with retry](tickets/SC-T014.md) | implementation | awaiting_testing | [SC-T013](tickets/SC-T013.md) |
| [SC-T015 · Save speech history and recover deleted records](tickets/SC-T015.md) | implementation | awaiting_testing | [SC-T011](tickets/SC-T011.md), [SC-T009](tickets/SC-T009.md), [SC-T004](tickets/SC-T004.md) |
| [SC-T016 · Integrate first speaking session and truthful progress](tickets/SC-T016.md) | implementation | awaiting_testing | [SC-T014](tickets/SC-T014.md), [SC-T015](tickets/SC-T015.md) |
| [SC-T017 · Verify device provider and learner proof gates](tickets/SC-T017.md) | acceptance | awaiting_testing | [SC-T016](tickets/SC-T016.md) |

<a id="m3"></a>
## M3 · One complete A1 topic

- Status: in_progress
- Dependencies: M2 for integrated speaking; content preparation can start after its own M0 prerequisites.
- Exit criteria: Reviewed INTRO-01 minimum pack/rubric integrates teaching, grammar, vocabulary, speaking or quiet completion and local resume; both-device airplane-mode journey succeeds. SC-T043 records the four-week delayed recall/transfer pilot, qualified review and explicit expansion/rework decision under IL-01–IL-10; functional completion alone does not establish learning efficacy.

| Ticket | Type | Status | Dependencies |
| --- | --- | --- | --- |
| [SC-T018 · Author and review A1 Introductions topic](tickets/SC-T018.md) | content | in_progress | [SC-T001](tickets/SC-T001.md), [SC-T006](tickets/SC-T006.md), [SC-T005](tickets/SC-T005.md) |
| [SC-T019 · Load versioned lessons and required offline assets](tickets/SC-T019.md) | implementation | awaiting_testing | [SC-T005](tickets/SC-T005.md), [SC-T009](tickets/SC-T009.md), [SC-T018](tickets/SC-T018.md) |
| [SC-T020 · Complete and resume the first lesson offline](tickets/SC-T020.md) | implementation | awaiting_testing | [SC-T019](tickets/SC-T019.md), [SC-T010](tickets/SC-T010.md), [SC-T001](tickets/SC-T001.md) |
| [SC-T021 · Connect lesson vocabulary speaking and shared progress](tickets/SC-T021.md) | implementation | awaiting_testing | [SC-T020](tickets/SC-T020.md), [SC-T017](tickets/SC-T017.md) |
| [SC-T043 · Validate the Introductions learning loop before expansion](tickets/SC-T043.md) | acceptance | pending | [SC-T018](tickets/SC-T018.md), [SC-T021](tickets/SC-T021.md) |

<a id="m4"></a>
## M4 · Connected daily practice

- Status: in_progress
- Dependencies: M3 for runtime daily-loop delivery; independently authorized SC-T045 artwork preparation can proceed from adopted catalog/visuals. Individual review/progress/reward dependencies apply.
- Exit criteria: Rated vocabulary reviews, recommendations, supported comparison evidence and approved rewards provide a durable daily loop without duplicate credit.

| Ticket | Type | Status | Dependencies |
| --- | --- | --- | --- |
| [SC-T022 · Decide scheduler and review-credit policy](tickets/SC-T022.md) | delivery group | pending | [SC-T021](tickets/SC-T021.md) |
| [SC-T023 · Deliver vocabulary enrollment and daily reviews](tickets/SC-T023.md) | delivery group | pending | [SC-T022](tickets/SC-T022.md) |
| [SC-T024 · Implement daily recommendations and progress evidence](tickets/SC-T024.md) | delivery group | pending | [SC-T023](tickets/SC-T023.md) |
| [SC-T025 · Implement approved rewards and goal lifecycle](tickets/SC-T025.md) | delivery group | pending | [SC-T023](tickets/SC-T023.md) |
| [SC-T045 · Produce the 68 adopted award-family raster masters](tickets/SC-T045.md) | asset production | done | None; owner-authorized scoped work |
| [SC-T046 · Select scheduler library and versioned parameters](tickets/SC-T046.md) | decision | in_progress | [SC-T021](tickets/SC-T021.md) |
| [SC-T047 · Define review eligibility and shared sense identity](tickets/SC-T047.md) | decision | awaiting_testing | [SC-T046](tickets/SC-T046.md) |
| [SC-T048 · Enroll shared vocabulary senses without duplicate cards](tickets/SC-T048.md) | implementation | awaiting_testing | [SC-T022](tickets/SC-T022.md) |
| [SC-T049 · Complete an offline recall and rated review](tickets/SC-T049.md) | implementation | awaiting_testing | [SC-T048](tickets/SC-T048.md) |
| [SC-T050 · Persist due queues and recover interrupted reviews](tickets/SC-T050.md) | implementation | awaiting_testing | [SC-T049](tickets/SC-T049.md) |
| [SC-T051 · Suggest next practice with an explanation and override](tickets/SC-T051.md) | implementation | awaiting_testing | [SC-T023](tickets/SC-T023.md) |
| [SC-T052 · Display separate learning evidence and comparison history](tickets/SC-T052.md) | implementation | awaiting_testing | [SC-T023](tickets/SC-T023.md) |
| [SC-T053 · Show achievement criteria and evidence availability](tickets/SC-T053.md) | implementation | pending | [SC-T052](tickets/SC-T052.md), [SC-T056](tickets/SC-T056.md), [SC-T057](tickets/SC-T057.md), [SC-T061](tickets/SC-T061.md) |
| [SC-T054 · Show weekly summaries and connected daily focus](tickets/SC-T054.md) | implementation | awaiting_testing | [SC-T051](tickets/SC-T051.md), [SC-T052](tickets/SC-T052.md) |
| [SC-T055 · Settle reward event and local-day policies](tickets/SC-T055.md) | decision | pending | [SC-T023](tickets/SC-T023.md) |
| [SC-T056 · Define finite AW instances and reviewed earning rules](tickets/SC-T056.md) | decision | pending | [SC-T055](tickets/SC-T055.md), [SC-T006](tickets/SC-T006.md) |
| [SC-T057 · Commit participation credits and gold spending once](tickets/SC-T057.md) | implementation | pending | [SC-T055](tickets/SC-T055.md) |
| [SC-T058 · Deliver free hints and explicit optional assistance purchases](tickets/SC-T058.md) | implementation | pending | [SC-T057](tickets/SC-T057.md) |
| [SC-T059 · Deliver Freeze inventory and Repair continuity](tickets/SC-T059.md) | implementation | pending | [SC-T057](tickets/SC-T057.md) |
| [SC-T060 · Track daily goals break timer and private reminders](tickets/SC-T060.md) | implementation | pending | [SC-T057](tickets/SC-T057.md) |
| [SC-T061 · Prepare adopted native award artwork and state overlays](tickets/SC-T061.md) | asset production | pending | [SC-T056](tickets/SC-T056.md), [SC-T045](tickets/SC-T045.md) |
| [SC-T062 · Present committed results and skippable celebrations](tickets/SC-T062.md) | implementation | pending | [SC-T057](tickets/SC-T057.md), [SC-T056](tickets/SC-T056.md), [SC-T061](tickets/SC-T061.md) |

<a id="m5"></a>
M4 follow-up, 2026-10-22: [Today/Progress reliability](daily-flow-2026-10-22.md) implements SC-T051/052/054 fixes. [Evidence](../testing/evidence/daily-flow-2026-10-22/README.md): 95 hosted tests and three UI checks on each phone/tablet simulator passed. M4 reward/original parent acceptance remains open; Grok reward drafts have not been integrated.

## M5 · Small A1 course and owner validation

- Status: pending
- Dependencies: M3 including SC-T043 recorded expansion decision before course expansion; M4 before complete daily-loop acceptance.
- Exit criteria: Bounded reviewed course demonstrates reusable patterns and reading/listening coverage; owner/device/learning checks run; blocking pilot defects resolved. This is not complete A1.

| Ticket | Type | Status | Dependencies |
| --- | --- | --- | --- |
| [SC-T026 · Expand proven patterns into a bounded A1 course](tickets/SC-T026.md) | delivery group | pending | [SC-T043](tickets/SC-T043.md) |
| [SC-T027 · Validate teaching usefulness and native usability](tickets/SC-T027.md) | delivery group | pending | [SC-T026](tickets/SC-T026.md), [SC-T024](tickets/SC-T024.md), [SC-T025](tickets/SC-T025.md) |
| [SC-T028 · Generalize demonstrated patterns and resolve pilot defects](tickets/SC-T028.md) | delivery group | pending | [SC-T027](tickets/SC-T027.md) |
| [SC-T063 · Freeze the small A1 course topic and objective manifest](tickets/SC-T063.md) | decision | pending | [SC-T043](tickets/SC-T043.md), [SC-T006](tickets/SC-T006.md) |
| [SC-T064 · Author the small-course personal and routine topic batch](tickets/SC-T064.md) | content | pending | [SC-T063](tickets/SC-T063.md) |
| [SC-T065 · Author the small-course everyday needs topic batch](tickets/SC-T065.md) | content | pending | [SC-T063](tickets/SC-T063.md) |
| [SC-T066 · Run the bounded small A1 course using proven activities](tickets/SC-T066.md) | implementation | pending | [SC-T064](tickets/SC-T064.md), [SC-T065](tickets/SC-T065.md), [SC-T021](tickets/SC-T021.md) |
| [SC-T067 · Freeze small-course learning and owner evaluation protocol](tickets/SC-T067.md) | decision | pending | [SC-T026](tickets/SC-T026.md), [SC-T024](tickets/SC-T024.md), [SC-T025](tickets/SC-T025.md) |
| [SC-T068 · Execute small-course learning and usefulness evaluation](tickets/SC-T068.md) | acceptance | pending | [SC-T067](tickets/SC-T067.md) |
| [SC-T069 · Validate small-course native daily journeys](tickets/SC-T069.md) | acceptance | pending | [SC-T067](tickets/SC-T067.md) |
| [SC-T070 · Freeze blocking pilot defects and reuse opportunities](tickets/SC-T070.md) | decision | pending | [SC-T027](tickets/SC-T027.md) |
| [SC-T071 · Extract only demonstrated reusable activity behavior](tickets/SC-T071.md) | refactor | pending | [SC-T070](tickets/SC-T070.md) |
| [SC-T072 · Close and retest the frozen blocking pilot defect batch](tickets/SC-T072.md) | implementation | pending | [SC-T070](tickets/SC-T070.md), [SC-T071](tickets/SC-T071.md) |

<a id="m6"></a>
## M6 · Complete A1

- Status: pending
- Dependencies: M5 completion gate; independent content preparation may overlap.
- Exit criteria: A1 satisfies M0 five-skill volume/coverage and editorial/rights/assessment checklist; required installed lessons/assets work offline; available-level bypass and history preserved; learner/device evidence recorded.

| Ticket | Type | Status | Dependencies |
| --- | --- | --- | --- |
| [SC-T029 · Complete reviewed A1 five-skill curriculum](tickets/SC-T029.md) | delivery group | pending | [SC-T028](tickets/SC-T028.md), [SC-T006](tickets/SC-T006.md) |
| [SC-T073 · Freeze A1 unit objective and publication manifest](tickets/SC-T073.md) | decision | pending | [SC-T006](tickets/SC-T006.md) |
| [SC-T074 · Author and review A1 topic: Greetings](tickets/SC-T074.md) | content | pending | [SC-T073](tickets/SC-T073.md) |
| [SC-T075 · Reconcile A1 introductions coverage with the reviewed INTRO-01 pack](tickets/SC-T075.md) | content | pending | [SC-T073](tickets/SC-T073.md) |
| [SC-T076 · Author and review A1 topic: alphabet and spelling](tickets/SC-T076.md) | content | pending | [SC-T073](tickets/SC-T073.md) |
| [SC-T077 · Author and review A1 topic: numbers](tickets/SC-T077.md) | content | pending | [SC-T073](tickets/SC-T073.md) |
| [SC-T078 · Author and review A1 topic: dates and time](tickets/SC-T078.md) | content | pending | [SC-T073](tickets/SC-T073.md) |
| [SC-T079 · Author and review A1 topic: family](tickets/SC-T079.md) | content | pending | [SC-T073](tickets/SC-T073.md) |
| [SC-T080 · Author and review A1 topic: home](tickets/SC-T080.md) | content | pending | [SC-T073](tickets/SC-T073.md) |
| [SC-T081 · Author and review A1 topic: daily routines](tickets/SC-T081.md) | content | pending | [SC-T073](tickets/SC-T073.md) |
| [SC-T082 · Author and review A1 topic: food](tickets/SC-T082.md) | content | pending | [SC-T073](tickets/SC-T073.md) |
| [SC-T083 · Author and review A1 topic: shopping](tickets/SC-T083.md) | content | pending | [SC-T073](tickets/SC-T073.md) |
| [SC-T084 · Author and review A1 topic: places and directions](tickets/SC-T084.md) | content | pending | [SC-T073](tickets/SC-T073.md) |
| [SC-T085 · Author and review A1 topic: hobbies](tickets/SC-T085.md) | content | pending | [SC-T073](tickets/SC-T073.md) |
| [SC-T086 · Author and review A1 topic: weather](tickets/SC-T086.md) | content | pending | [SC-T073](tickets/SC-T073.md) |
| [SC-T087 · Integrate reviewed A1 packs without changing learner history](tickets/SC-T087.md) | implementation | pending | [SC-T074](tickets/SC-T074.md), [SC-T075](tickets/SC-T075.md), [SC-T076](tickets/SC-T076.md), [SC-T077](tickets/SC-T077.md), [SC-T078](tickets/SC-T078.md), [SC-T079](tickets/SC-T079.md), [SC-T080](tickets/SC-T080.md), [SC-T081](tickets/SC-T081.md), [SC-T082](tickets/SC-T082.md), [SC-T083](tickets/SC-T083.md), [SC-T084](tickets/SC-T084.md), [SC-T085](tickets/SC-T085.md), [SC-T086](tickets/SC-T086.md), [SC-T019](tickets/SC-T019.md), [SC-T020](tickets/SC-T020.md), [SC-T028](tickets/SC-T028.md) |
| [SC-T088 · Accept A1 five-skill completeness and learning evidence](tickets/SC-T088.md) | acceptance | pending | [SC-T087](tickets/SC-T087.md) |

<a id="m7"></a>
## M7 · Complete A2

- Status: pending
- Dependencies: M6 completion gate; independent content preparation may overlap.
- Exit criteria: A2 satisfies M0 five-skill volume/coverage and editorial/rights/assessment checklist; required installed lessons/assets work offline; available-level bypass and history preserved; learner/device evidence recorded.

| Ticket | Type | Status | Dependencies |
| --- | --- | --- | --- |
| [SC-T030 · Complete reviewed A2 five-skill curriculum](tickets/SC-T030.md) | delivery group | pending | [SC-T029](tickets/SC-T029.md), [SC-T006](tickets/SC-T006.md) |
| [SC-T089 · Freeze A2 unit objective and publication manifest](tickets/SC-T089.md) | decision | pending | [SC-T006](tickets/SC-T006.md) |
| [SC-T090 · Author and review A2 topic: Travel](tickets/SC-T090.md) | content | pending | [SC-T089](tickets/SC-T089.md) |
| [SC-T091 · Author and review A2 topic: transportation](tickets/SC-T091.md) | content | pending | [SC-T089](tickets/SC-T089.md) |
| [SC-T092 · Author and review A2 topic: appointments](tickets/SC-T092.md) | content | pending | [SC-T089](tickets/SC-T089.md) |
| [SC-T093 · Author and review A2 topic: health](tickets/SC-T093.md) | content | pending | [SC-T089](tickets/SC-T089.md) |
| [SC-T094 · Author and review A2 topic: eating out](tickets/SC-T094.md) | content | pending | [SC-T089](tickets/SC-T089.md) |
| [SC-T095 · Author and review A2 topic: invitations](tickets/SC-T095.md) | content | pending | [SC-T089](tickets/SC-T089.md) |
| [SC-T096 · Author and review A2 topic: leisure](tickets/SC-T096.md) | content | pending | [SC-T089](tickets/SC-T089.md) |
| [SC-T097 · Author and review A2 topic: work routines](tickets/SC-T097.md) | content | pending | [SC-T089](tickets/SC-T089.md) |
| [SC-T098 · Author and review A2 topic: past experiences](tickets/SC-T098.md) | content | pending | [SC-T089](tickets/SC-T089.md) |
| [SC-T099 · Author and review A2 topic: future plans](tickets/SC-T099.md) | content | pending | [SC-T089](tickets/SC-T089.md) |
| [SC-T100 · Author and review A2 topic: everyday problems](tickets/SC-T100.md) | content | pending | [SC-T089](tickets/SC-T089.md) |
| [SC-T101 · Integrate reviewed A2 packs without changing learner history](tickets/SC-T101.md) | implementation | pending | [SC-T090](tickets/SC-T090.md), [SC-T091](tickets/SC-T091.md), [SC-T092](tickets/SC-T092.md), [SC-T093](tickets/SC-T093.md), [SC-T094](tickets/SC-T094.md), [SC-T095](tickets/SC-T095.md), [SC-T096](tickets/SC-T096.md), [SC-T097](tickets/SC-T097.md), [SC-T098](tickets/SC-T098.md), [SC-T099](tickets/SC-T099.md), [SC-T100](tickets/SC-T100.md), [SC-T019](tickets/SC-T019.md), [SC-T020](tickets/SC-T020.md), [SC-T029](tickets/SC-T029.md) |
| [SC-T102 · Accept A2 five-skill completeness and learning evidence](tickets/SC-T102.md) | acceptance | pending | [SC-T101](tickets/SC-T101.md) |

<a id="m8"></a>
## M8 · Complete B1

- Status: pending
- Dependencies: M7 completion gate; independent content preparation may overlap.
- Exit criteria: B1 satisfies M0 five-skill volume/coverage and editorial/rights/assessment checklist; required installed lessons/assets work offline; available-level bypass and history preserved; learner/device evidence recorded.

| Ticket | Type | Status | Dependencies |
| --- | --- | --- | --- |
| [SC-T031 · Complete reviewed B1 five-skill curriculum](tickets/SC-T031.md) | delivery group | pending | [SC-T030](tickets/SC-T030.md), [SC-T006](tickets/SC-T006.md) |
| [SC-T103 · Freeze B1 unit objective and publication manifest](tickets/SC-T103.md) | decision | pending | [SC-T006](tickets/SC-T006.md) |
| [SC-T104 · Author and review B1 topic: Education](tickets/SC-T104.md) | content | pending | [SC-T103](tickets/SC-T103.md) |
| [SC-T105 · Author and review B1 topic: career goals](tickets/SC-T105.md) | content | pending | [SC-T103](tickets/SC-T103.md) |
| [SC-T106 · Author and review B1 topic: relationships](tickets/SC-T106.md) | content | pending | [SC-T103](tickets/SC-T103.md) |
| [SC-T107 · Author and review B1 topic: technology](tickets/SC-T107.md) | content | pending | [SC-T103](tickets/SC-T103.md) |
| [SC-T108 · Author and review B1 topic: entertainment](tickets/SC-T108.md) | content | pending | [SC-T103](tickets/SC-T103.md) |
| [SC-T109 · Author and review B1 topic: culture](tickets/SC-T109.md) | content | pending | [SC-T103](tickets/SC-T103.md) |
| [SC-T110 · Author and review B1 topic: community](tickets/SC-T110.md) | content | pending | [SC-T103](tickets/SC-T103.md) |
| [SC-T111 · Author and review B1 topic: personal achievements](tickets/SC-T111.md) | content | pending | [SC-T103](tickets/SC-T103.md) |
| [SC-T112 · Author and review B1 topic: decisions](tickets/SC-T112.md) | content | pending | [SC-T103](tickets/SC-T103.md) |
| [SC-T113 · Author and review B1 topic: unexpected situations](tickets/SC-T113.md) | content | pending | [SC-T103](tickets/SC-T103.md) |
| [SC-T114 · Integrate reviewed B1 packs without changing learner history](tickets/SC-T114.md) | implementation | pending | [SC-T104](tickets/SC-T104.md), [SC-T105](tickets/SC-T105.md), [SC-T106](tickets/SC-T106.md), [SC-T107](tickets/SC-T107.md), [SC-T108](tickets/SC-T108.md), [SC-T109](tickets/SC-T109.md), [SC-T110](tickets/SC-T110.md), [SC-T111](tickets/SC-T111.md), [SC-T112](tickets/SC-T112.md), [SC-T113](tickets/SC-T113.md), [SC-T019](tickets/SC-T019.md), [SC-T020](tickets/SC-T020.md), [SC-T030](tickets/SC-T030.md) |
| [SC-T115 · Accept B1 five-skill completeness and learning evidence](tickets/SC-T115.md) | acceptance | pending | [SC-T114](tickets/SC-T114.md) |

<a id="m9"></a>
## M9 · Complete B2

- Status: pending
- Dependencies: M8 completion gate; independent content preparation may overlap.
- Exit criteria: B2 satisfies M0 five-skill volume/coverage and editorial/rights/assessment checklist; required installed lessons/assets work offline; available-level bypass and history preserved; learner/device evidence recorded.

| Ticket | Type | Status | Dependencies |
| --- | --- | --- | --- |
| [SC-T032 · Complete reviewed B2 five-skill curriculum](tickets/SC-T032.md) | delivery group | pending | [SC-T031](tickets/SC-T031.md), [SC-T006](tickets/SC-T006.md) |
| [SC-T116 · Freeze B2 unit objective and publication manifest](tickets/SC-T116.md) | decision | pending | [SC-T006](tickets/SC-T006.md) |
| [SC-T117 · Author and review B2 topic: Professional projects](tickets/SC-T117.md) | content | pending | [SC-T116](tickets/SC-T116.md) |
| [SC-T118 · Author and review B2 topic: leadership](tickets/SC-T118.md) | content | pending | [SC-T116](tickets/SC-T116.md) |
| [SC-T119 · Author and review B2 topic: media](tickets/SC-T119.md) | content | pending | [SC-T116](tickets/SC-T116.md) |
| [SC-T120 · Author and review B2 topic: social issues](tickets/SC-T120.md) | content | pending | [SC-T116](tickets/SC-T116.md) |
| [SC-T121 · Author and review B2 topic: innovation](tickets/SC-T121.md) | content | pending | [SC-T116](tickets/SC-T116.md) |
| [SC-T122 · Author and review B2 topic: ethics](tickets/SC-T122.md) | content | pending | [SC-T116](tickets/SC-T116.md) |
| [SC-T123 · Author and review B2 topic: environment](tickets/SC-T123.md) | content | pending | [SC-T116](tickets/SC-T116.md) |
| [SC-T124 · Author and review B2 topic: presentations](tickets/SC-T124.md) | content | pending | [SC-T116](tickets/SC-T116.md) |
| [SC-T125 · Author and review B2 topic: negotiation](tickets/SC-T125.md) | content | pending | [SC-T116](tickets/SC-T116.md) |
| [SC-T126 · Author and review B2 topic: disagreements](tickets/SC-T126.md) | content | pending | [SC-T116](tickets/SC-T116.md) |
| [SC-T127 · Integrate reviewed B2 packs without changing learner history](tickets/SC-T127.md) | implementation | pending | [SC-T117](tickets/SC-T117.md), [SC-T118](tickets/SC-T118.md), [SC-T119](tickets/SC-T119.md), [SC-T120](tickets/SC-T120.md), [SC-T121](tickets/SC-T121.md), [SC-T122](tickets/SC-T122.md), [SC-T123](tickets/SC-T123.md), [SC-T124](tickets/SC-T124.md), [SC-T125](tickets/SC-T125.md), [SC-T126](tickets/SC-T126.md), [SC-T019](tickets/SC-T019.md), [SC-T020](tickets/SC-T020.md), [SC-T031](tickets/SC-T031.md) |
| [SC-T128 · Accept B2 five-skill completeness and learning evidence](tickets/SC-T128.md) | acceptance | pending | [SC-T127](tickets/SC-T127.md) |

<a id="m10"></a>
## M10 · Complete C1

- Status: pending
- Dependencies: M9 completion gate; independent content preparation may overlap.
- Exit criteria: C1 satisfies M0 five-skill volume/coverage and editorial/rights/assessment checklist; required installed lessons/assets work offline; available-level bypass and history preserved; learner/device evidence recorded.

| Ticket | Type | Status | Dependencies |
| --- | --- | --- | --- |
| [SC-T033 · Complete reviewed C1 five-skill curriculum](tickets/SC-T033.md) | delivery group | pending | [SC-T032](tickets/SC-T032.md), [SC-T006](tickets/SC-T006.md) |
| [SC-T129 · Freeze C1 unit objective and publication manifest](tickets/SC-T129.md) | decision | pending | [SC-T006](tickets/SC-T006.md) |
| [SC-T130 · Author and review C1 topic: Strategy](tickets/SC-T130.md) | content | pending | [SC-T129](tickets/SC-T129.md) |
| [SC-T131 · Author and review C1 topic: research](tickets/SC-T131.md) | content | pending | [SC-T129](tickets/SC-T129.md) |
| [SC-T132 · Author and review C1 topic: organizational change](tickets/SC-T132.md) | content | pending | [SC-T129](tickets/SC-T129.md) |
| [SC-T133 · Author and review C1 topic: complex problems](tickets/SC-T133.md) | content | pending | [SC-T129](tickets/SC-T129.md) |
| [SC-T134 · Author and review C1 topic: policy](tickets/SC-T134.md) | content | pending | [SC-T129](tickets/SC-T129.md) |
| [SC-T135 · Author and review C1 topic: sensitive workplace discussions](tickets/SC-T135.md) | content | pending | [SC-T129](tickets/SC-T129.md) |
| [SC-T136 · Author and review C1 topic: specialist debates](tickets/SC-T136.md) | content | pending | [SC-T129](tickets/SC-T129.md) |
| [SC-T137 · Author and review C1 topic: cross-cultural communication](tickets/SC-T137.md) | content | pending | [SC-T129](tickets/SC-T129.md) |
| [SC-T138 · Integrate reviewed C1 packs without changing learner history](tickets/SC-T138.md) | implementation | pending | [SC-T130](tickets/SC-T130.md), [SC-T131](tickets/SC-T131.md), [SC-T132](tickets/SC-T132.md), [SC-T133](tickets/SC-T133.md), [SC-T134](tickets/SC-T134.md), [SC-T135](tickets/SC-T135.md), [SC-T136](tickets/SC-T136.md), [SC-T137](tickets/SC-T137.md), [SC-T019](tickets/SC-T019.md), [SC-T020](tickets/SC-T020.md), [SC-T032](tickets/SC-T032.md) |
| [SC-T139 · Accept C1 five-skill completeness and learning evidence](tickets/SC-T139.md) | acceptance | pending | [SC-T138](tickets/SC-T138.md) |

<a id="m11"></a>
## M11 · Complete C2

- Status: pending
- Dependencies: M10 completion gate; independent content preparation may overlap.
- Exit criteria: C2 satisfies M0 five-skill volume/coverage and editorial/rights/assessment checklist; required installed lessons/assets work offline; available-level bypass and history preserved; learner/device evidence recorded.

| Ticket | Type | Status | Dependencies |
| --- | --- | --- | --- |
| [SC-T034 · Complete reviewed C2 five-skill curriculum](tickets/SC-T034.md) | delivery group | pending | [SC-T033](tickets/SC-T033.md), [SC-T006](tickets/SC-T006.md) |
| [SC-T140 · Freeze C2 unit objective and publication manifest](tickets/SC-T140.md) | decision | pending | [SC-T006](tickets/SC-T006.md) |
| [SC-T141 · Author and review C2 topic: Abstract ideas](tickets/SC-T141.md) | content | pending | [SC-T140](tickets/SC-T140.md) |
| [SC-T142 · Author and review C2 topic: competing interpretations](tickets/SC-T142.md) | content | pending | [SC-T140](tickets/SC-T140.md) |
| [SC-T143 · Author and review C2 topic: sophisticated debate](tickets/SC-T143.md) | content | pending | [SC-T140](tickets/SC-T140.md) |
| [SC-T144 · Author and review C2 topic: cultural references](tickets/SC-T144.md) | content | pending | [SC-T140](tickets/SC-T140.md) |
| [SC-T145 · Author and review C2 topic: complex multidisciplinary problems](tickets/SC-T145.md) | content | pending | [SC-T140](tickets/SC-T140.md) |
| [SC-T146 · Integrate reviewed C2 packs without changing learner history](tickets/SC-T146.md) | implementation | pending | [SC-T141](tickets/SC-T141.md), [SC-T142](tickets/SC-T142.md), [SC-T143](tickets/SC-T143.md), [SC-T144](tickets/SC-T144.md), [SC-T145](tickets/SC-T145.md), [SC-T019](tickets/SC-T019.md), [SC-T020](tickets/SC-T020.md), [SC-T033](tickets/SC-T033.md) |
| [SC-T147 · Accept C2 five-skill completeness and learning evidence](tickets/SC-T147.md) | acceptance | pending | [SC-T146](tickets/SC-T146.md) |

<a id="m12"></a>
## M12 · Expanded coaching and practice

- Status: in_progress
- Dependencies: M5 proven patterns and each ticket dependency; can overlap M6–M11.
- Exit criteria: Required interview/business coverage and all seven specialized trainer methods/packs (SC-T044, TR criteria) are closed; release-included generation, vocabulary, communication/articulation and resource capabilities pass their scoped gates. No optional deferral is inferred; owner release-scope decision is required for exclusions.

| Ticket | Type | Status | Dependencies |
| --- | --- | --- | --- |
| [SC-T035 · Deliver interview business and expanded speaking coverage](tickets/SC-T035.md) | delivery group | pending | [SC-T028](tickets/SC-T028.md), [SC-T006](tickets/SC-T006.md) |
| [SC-T036 · Deliver communication and articulation practice](tickets/SC-T036.md) | delivery group | pending | [SC-T028](tickets/SC-T028.md) |
| [SC-T037 · Generate validated practice with offline fallbacks](tickets/SC-T037.md) | delivery group | pending | [SC-T028](tickets/SC-T028.md), [SC-T003](tickets/SC-T003.md) |
| [SC-T038 · Deliver Word of Day and custom vocabulary topics](tickets/SC-T038.md) | delivery group | pending | [SC-T023](tickets/SC-T023.md), [SC-T037](tickets/SC-T037.md) |
| [SC-T039 · Deliver supporting resource bookmarks](tickets/SC-T039.md) | delivery group | pending | [SC-T028](tickets/SC-T028.md) |
| [SC-T044 · Deliver and validate seven specialized trainer packs](tickets/SC-T044.md) | delivery group | pending | [SC-T028](tickets/SC-T028.md), [SC-T006](tickets/SC-T006.md) |
| [SC-T148 · Define conversation interview turn and workplace contracts](tickets/SC-T148.md) | decision | pending | [SC-T028](tickets/SC-T028.md), [SC-T006](tickets/SC-T006.md) |
| [SC-T149 · Author reviewed workplace communication and interview scenarios](tickets/SC-T149.md) | content | pending | [SC-T148](tickets/SC-T148.md) |
| [SC-T150 · Deliver explicit text or recorded-turn conversation](tickets/SC-T150.md) | implementation | pending | [SC-T148](tickets/SC-T148.md), [SC-T149](tickets/SC-T149.md), [SC-T017](tickets/SC-T017.md) |
| [SC-T151 · Deliver response-dependent interview follow-ups and retry](tickets/SC-T151.md) | implementation | pending | [SC-T150](tickets/SC-T150.md) |
| [SC-T152 · Validate workplace and conversational practice boundaries](tickets/SC-T152.md) | acceptance | pending | [SC-T151](tickets/SC-T151.md) |
| [SC-T153 · Record later realtime feasibility and release decision](tickets/SC-T153.md) | investigation | pending | [SC-T017](tickets/SC-T017.md) |
| [SC-T154 · Freeze communication and articulation teaching subsets](tickets/SC-T154.md) | decision | pending | [SC-T028](tickets/SC-T028.md) |
| [SC-T155 · Author reviewed organization listening and interaction drills](tickets/SC-T155.md) | content | pending | [SC-T154](tickets/SC-T154.md), [SC-T006](tickets/SC-T006.md) |
| [SC-T156 · Author reviewed articulation and delivery reference drills](tickets/SC-T156.md) | content | pending | [SC-T154](tickets/SC-T154.md), [SC-T006](tickets/SC-T006.md) |
| [SC-T157 · Deliver shared offline communication and articulation practice](tickets/SC-T157.md) | implementation | pending | [SC-T155](tickets/SC-T155.md), [SC-T156](tickets/SC-T156.md), [SC-T021](tickets/SC-T021.md) |
| [SC-T158 · Validate the audio assessment boundary before sound feedback](tickets/SC-T158.md) | investigation | pending | [SC-T156](tickets/SC-T156.md), [SC-T003](tickets/SC-T003.md) |
| [SC-T159 · Deliver supported focused communication feedback](tickets/SC-T159.md) | implementation | pending | [SC-T157](tickets/SC-T157.md), [SC-T158](tickets/SC-T158.md), [SC-T014](tickets/SC-T014.md), [SC-T012](tickets/SC-T012.md) |
| [SC-T160 · Validate communication articulation and fresh-task evidence](tickets/SC-T160.md) | acceptance | pending | [SC-T159](tickets/SC-T159.md) |
| [SC-T161 · Define bounded generation validation and reporting policy](tickets/SC-T161.md) | decision | pending | [SC-T028](tickets/SC-T028.md), [SC-T003](tickets/SC-T003.md) |
| [SC-T162 · Generate and validate one explicit practice request safely](tickets/SC-T162.md) | implementation | pending | [SC-T161](tickets/SC-T161.md), [SC-T014](tickets/SC-T014.md) |
| [SC-T163 · Reuse compatible variants without resetting learning identities](tickets/SC-T163.md) | implementation | pending | [SC-T162](tickets/SC-T162.md) |
| [SC-T164 · Record and resolve incorrect-activity reports locally](tickets/SC-T164.md) | implementation | pending | [SC-T163](tickets/SC-T163.md) |
| [SC-T165 · Create and edit custom vocabulary topics offline](tickets/SC-T165.md) | implementation | awaiting_testing | [SC-T023](tickets/SC-T023.md) |
| [SC-T166 · Preview select and enroll generated topic vocabulary](tickets/SC-T166.md) | implementation | pending | [SC-T165](tickets/SC-T165.md), [SC-T037](tickets/SC-T037.md) |
| [SC-T167 · Deliver a stable Word of the Day with offline fallback](tickets/SC-T167.md) | implementation | pending | [SC-T166](tickets/SC-T166.md), [SC-T055](tickets/SC-T055.md) |
| [SC-T168 · Decide resource destinations metadata and thumbnail rights](tickets/SC-T168.md) | decision | pending | [SC-T028](tickets/SC-T028.md) |
| [SC-T169 · Save curated and personal resource cards safely](tickets/SC-T169.md) | implementation | pending | [SC-T168](tickets/SC-T168.md) |
| [SC-T182 · Freeze all-seven role objective and level coverage matrix](tickets/SC-T182.md) | decision | pending | [SC-T028](tickets/SC-T028.md), [SC-T006](tickets/SC-T006.md) |
| [SC-T183 · Resolve Creative Writer character and optional voice design](tickets/SC-T183.md) | decision | pending | [SC-T182](tickets/SC-T182.md), [SC-T007](tickets/SC-T007.md), [SC-T158](tickets/SC-T158.md) |
| [SC-T184 · Run explicit specialist packs with safe switch and course return](tickets/SC-T184.md) | implementation | pending | [SC-T182](tickets/SC-T182.md), [SC-T021](tickets/SC-T021.md) |
| [SC-T185 · Author and review Teacher specialist pack coverage](tickets/SC-T185.md) | content | pending | [SC-T182](tickets/SC-T182.md) |
| [SC-T186 · Author and review Grammarian specialist pack coverage](tickets/SC-T186.md) | content | pending | [SC-T182](tickets/SC-T182.md) |
| [SC-T187 · Author and review Librarian specialist pack coverage](tickets/SC-T187.md) | content | pending | [SC-T182](tickets/SC-T182.md) |
| [SC-T188 · Author and review Journalist specialist pack coverage](tickets/SC-T188.md) | content | pending | [SC-T182](tickets/SC-T182.md), [SC-T155](tickets/SC-T155.md) |
| [SC-T189 · Author and review Business Professional specialist pack coverage](tickets/SC-T189.md) | content | pending | [SC-T182](tickets/SC-T182.md), [SC-T149](tickets/SC-T149.md) |
| [SC-T190 · Author and review Speaker specialist pack coverage](tickets/SC-T190.md) | content | pending | [SC-T182](tickets/SC-T182.md), [SC-T156](tickets/SC-T156.md), [SC-T158](tickets/SC-T158.md) |
| [SC-T191 · Author and review Creative Writer specialist pack coverage](tickets/SC-T191.md) | content | pending | [SC-T182](tickets/SC-T182.md), [SC-T183](tickets/SC-T183.md), [SC-T155](tickets/SC-T155.md) |
| [SC-T192 · Validate all-seven specialist methods and retained learning](tickets/SC-T192.md) | acceptance | pending | [SC-T184](tickets/SC-T184.md), [SC-T185](tickets/SC-T185.md), [SC-T186](tickets/SC-T186.md), [SC-T187](tickets/SC-T187.md), [SC-T188](tickets/SC-T188.md), [SC-T189](tickets/SC-T189.md), [SC-T190](tickets/SC-T190.md), [SC-T191](tickets/SC-T191.md) |

<a id="m13"></a>
## M13 · Public-release readiness

- Status: pending
- Dependencies: M6–M11 plus M12 release-included scope.
- Exit criteria: Complete A1–C2 five-skill path and interview/business coverage pass curriculum, device, accessibility, privacy, recovery and cost/failure gates; distribution preparation and limitations documented. Publication remains a separate action.

| Ticket | Type | Status | Dependencies |
| --- | --- | --- | --- |
| [SC-T040 · Audit full release curriculum and capability coverage](tickets/SC-T040.md) | delivery group | pending | [SC-T034](tickets/SC-T034.md), [SC-T035](tickets/SC-T035.md), [SC-T036](tickets/SC-T036.md), [SC-T037](tickets/SC-T037.md), [SC-T038](tickets/SC-T038.md), [SC-T039](tickets/SC-T039.md), [SC-T044](tickets/SC-T044.md) |
| [SC-T041 · Verify release reliability privacy and accessibility](tickets/SC-T041.md) | delivery group | pending | [SC-T040](tickets/SC-T040.md) |
| [SC-T042 · Prepare distribution recovery and release handoff](tickets/SC-T042.md) | delivery group | pending | [SC-T041](tickets/SC-T041.md) |
| [SC-T170 · Audit complete level and foundation publication coverage](tickets/SC-T170.md) | acceptance | pending | [SC-T034](tickets/SC-T034.md), [SC-T006](tickets/SC-T006.md) |
| [SC-T171 · Audit all-seven trainer workplace and practice capability claims](tickets/SC-T171.md) | acceptance | pending | [SC-T035](tickets/SC-T035.md), [SC-T036](tickets/SC-T036.md), [SC-T037](tickets/SC-T037.md), [SC-T038](tickets/SC-T038.md), [SC-T039](tickets/SC-T039.md), [SC-T044](tickets/SC-T044.md) |
| [SC-T172 · Audit all award families evidence states and unchanged economics](tickets/SC-T172.md) | acceptance | pending | [SC-T170](tickets/SC-T170.md), [SC-T171](tickets/SC-T171.md), [SC-T024](tickets/SC-T024.md), [SC-T025](tickets/SC-T025.md) |
| [SC-T173 · Freeze release regression matrix and measurable budgets](tickets/SC-T173.md) | decision | pending | [SC-T040](tickets/SC-T040.md) |
| [SC-T174 · Verify persistence upgrades retention export and reset recovery](tickets/SC-T174.md) | acceptance | pending | [SC-T173](tickets/SC-T173.md), [SC-T178](tickets/SC-T178.md) |
| [SC-T175 · Verify all supported native appearance and accessibility journeys](tickets/SC-T175.md) | acceptance | pending | [SC-T173](tickets/SC-T173.md) |
| [SC-T176 · Verify credential cost and network failure containment](tickets/SC-T176.md) | acceptance | pending | [SC-T173](tickets/SC-T173.md) |
| [SC-T177 · Define selected export and any explicit restore boundary](tickets/SC-T177.md) | decision | pending | [SC-T004](tickets/SC-T004.md), [SC-T028](tickets/SC-T028.md) |
| [SC-T178 · Export only explicitly selected retained learner data](tickets/SC-T178.md) | implementation | pending | [SC-T177](tickets/SC-T177.md), [SC-T015](tickets/SC-T015.md) |
| [SC-T179 · Select distribution signing identity and release recovery procedure](tickets/SC-T179.md) | decision | pending | [SC-T040](tickets/SC-T040.md) |
| [SC-T180 · Prepare a repeatable signed release candidate](tickets/SC-T180.md) | implementation | pending | [SC-T041](tickets/SC-T041.md), [SC-T179](tickets/SC-T179.md) |
| [SC-T181 · Write verified release and recovery handoff](tickets/SC-T181.md) | documentation | pending | [SC-T180](tickets/SC-T180.md) |
## Existing feature traceability

| Parent | Contributing tickets |
| --- | --- |
| SC-001 | [SC-T001](tickets/SC-T001.md), [SC-T006](tickets/SC-T006.md) |
| SC-002 | [SC-T002](tickets/SC-T002.md), [SC-T003](tickets/SC-T003.md) |
| SC-003 | [SC-T007](tickets/SC-T007.md), [SC-T010](tickets/SC-T010.md), [SC-T027](tickets/SC-T027.md), [SC-T044](tickets/SC-T044.md), [SC-T045](tickets/SC-T045.md) |
| SC-004 | [SC-T011](tickets/SC-T011.md), [SC-T013](tickets/SC-T013.md), [SC-T014](tickets/SC-T014.md), [SC-T017](tickets/SC-T017.md) |
| SC-005 | [SC-T004](tickets/SC-T004.md), [SC-T005](tickets/SC-T005.md), [SC-T008](tickets/SC-T008.md), [SC-T009](tickets/SC-T009.md), [SC-T010](tickets/SC-T010.md), [SC-T015](tickets/SC-T015.md), [SC-T019](tickets/SC-T019.md), [SC-T028](tickets/SC-T028.md) |
| SC-006 | [SC-T004](tickets/SC-T004.md), [SC-T011](tickets/SC-T011.md), [SC-T013](tickets/SC-T013.md), [SC-T014](tickets/SC-T014.md), [SC-T015](tickets/SC-T015.md), [SC-T016](tickets/SC-T016.md), [SC-T017](tickets/SC-T017.md), [SC-T021](tickets/SC-T021.md), [SC-T043](tickets/SC-T043.md) |
| SC-007 | [SC-T021](tickets/SC-T021.md), [SC-T022](tickets/SC-T022.md), [SC-T023](tickets/SC-T023.md), [SC-T038](tickets/SC-T038.md) |
| SC-008 | [SC-T005](tickets/SC-T005.md), [SC-T019](tickets/SC-T019.md), [SC-T020](tickets/SC-T020.md), [SC-T021](tickets/SC-T021.md), [SC-T026](tickets/SC-T026.md), [SC-T027](tickets/SC-T027.md), [SC-T028](tickets/SC-T028.md), [SC-T029](tickets/SC-T029.md), [SC-T030](tickets/SC-T030.md), [SC-T031](tickets/SC-T031.md), [SC-T032](tickets/SC-T032.md), [SC-T033](tickets/SC-T033.md), [SC-T034](tickets/SC-T034.md), [SC-T043](tickets/SC-T043.md), [SC-T044](tickets/SC-T044.md) |
| SC-009 | [SC-T015](tickets/SC-T015.md), [SC-T016](tickets/SC-T016.md), [SC-T024](tickets/SC-T024.md), [SC-T025](tickets/SC-T025.md), [SC-T045](tickets/SC-T045.md) |
| SC-010 | [SC-T035](tickets/SC-T035.md), [SC-T039](tickets/SC-T039.md), [SC-T044](tickets/SC-T044.md) |
| SC-011 | [SC-T027](tickets/SC-T027.md), [SC-T040](tickets/SC-T040.md), [SC-T041](tickets/SC-T041.md), [SC-T042](tickets/SC-T042.md), [SC-T043](tickets/SC-T043.md) |
| SC-012 | [SC-T037](tickets/SC-T037.md) |
| SC-013 | [SC-T036](tickets/SC-T036.md), [SC-T044](tickets/SC-T044.md) |
| SC-014 | [SC-T005](tickets/SC-T005.md), [SC-T006](tickets/SC-T006.md), [SC-T018](tickets/SC-T018.md), [SC-T026](tickets/SC-T026.md), [SC-T029](tickets/SC-T029.md), [SC-T030](tickets/SC-T030.md), [SC-T031](tickets/SC-T031.md), [SC-T032](tickets/SC-T032.md), [SC-T033](tickets/SC-T033.md), [SC-T034](tickets/SC-T034.md), [SC-T035](tickets/SC-T035.md), [SC-T040](tickets/SC-T040.md), [SC-T043](tickets/SC-T043.md), [SC-T044](tickets/SC-T044.md) |
| SC-015 | [SC-T003](tickets/SC-T003.md), [SC-T012](tickets/SC-T012.md), [SC-T017](tickets/SC-T017.md) |
| SC-016 | [SC-T036](tickets/SC-T036.md), [SC-T044](tickets/SC-T044.md) |

## Ticket-creation verification · 2026-10-17

Documentation checks passed: 74 Markdown files and 839 local links/anchors checked; all 42 tickets contain the required sections, start pending, appear in this index and form an acyclic dependency graph. External preset validation passed 30 checks. These are documentation/AI-structure checks only; no application build, device/provider call, curriculum publication or learner acceptance was performed.

## Learning acceptance documentation verification · 2026-10-19

Introductions criteria, IL-01–IL-10 and SC-T043 are recorded; the index/tracker now contain 43 pending tickets. Local Markdown target checks, ticket counts and dependency consistency checks passed; external preset validation passed 30 checks. These verify documentation only. Educator, learner, device and provider execution remains NOT_RUN.

## English Foundations coverage — adopted 2026-10-19

The [foundation specification](../../../product-specification/english-foundations.md) and [EF acceptance matrix](../testing/english-foundations-acceptance.md) extend existing milestones without changing ticket counts/dependencies. M0/SC-T006 owns explicit topic-to-CEFR child-objective mapping and publication gates. M3/SC-T018/SC-T020/SC-T043 includes only the bounded Introductions subset and its separated concept/use/retention evidence. M5/SC-T026 decomposes further objective batches; M6–M11 carry reviewed level-appropriate foundation coverage and revisits. M13/SC-T040 cannot close complete-release coverage with unaccounted required EF topics. All 43 tickets and milestones remain pending; grammar terminology never locks access to available levels.

## Specialized trainer scope — 2026-10-19

M3 adds bounded Teacher/Grammarian/Journalist method proof around unchanged INTRO-01 outcomes. M12/SC-T044 requires all seven reviewed trainer methods, activities and learning criteria, coordinated with workplace/communication coverage; M13/SC-T040 now depends on SC-T044. All seven roles remain required overall, including Creative Writer; early internal unavailable packs are labeled honestly. Current count is 44 pending tickets, M12 has six; prior 43-ticket figures are historical snapshots. See [trainer requirements](../product-specification/specialized-trainers.md) and [TR acceptance](../testing/specialized-trainer-acceptance.md).

## Course/practice clarification and reward proposal — 2026-10-19

M3 proof preserves identical required CEFR training across all seven presenting coaches; the three specialist packs remain optional separate practice. M12/SC-T035 explicitly tracks independently scoped turn-based conversation/interview delivery and deferred realtime capability research; SC-T044 preserves specialist/course boundaries. M4/SC-T025 must review/decompose the requested congratulatory-motion/badge/reward delivery proposal; SC-T007 owns native design specimens and SC-T024 evidence/history surfaces. Use [CP/RW acceptance](../testing/course-practice-and-rewards-acceptance.md). Counts/dependencies/status remain unchanged at 44 pending; proposal documentation is not artwork, Figma or runtime proof.

## Adopted award visual-system gates — 2026-10-19

The owner adopted [visual system v1](../../../product-specification/achievement-visual-design.md) for the 68-family catalog. M0/SC-T007 now verifies fidelity/native specimens of an accepted direction rather than selecting one again. M4/SC-T025/SC-T024 must implement reusable shell/subject/state/tier production and appropriate checkpoint/metric presentation through bounded children. M13/SC-T040 requires full included-instance mapping and AV/RW production/native evidence. Earlier proposal status is historical; all 44 tickets remain pending and no Figma, asset library or application work is completed by adoption.

## First-slice readiness refinement — 2026-10-21

SC-T001 is done as a scope decision; SC-T002–SC-T007 are Ready for planning. SC-T008 depends on architecture only and provides an engineering launch surface; SC-T007 still gates product navigation/UI through SC-T010. SC-T011 depends on local foundation/navigation, using the local capture contract from SC-T002; SC-T003 still gates cloud submission. SC-T006 now closes shared publication rules plus INTRO-01 review/mapping, with detailed later coverage required by each affected authoring batch and SC-T040. SC-T007 is a design-input gate; runtime and full AW production evidence stays with SC-T010–SC-T017 and SC-T024/SC-T025/SC-T040. These current refinements supersede earlier broader gate wording. No product scope expansion or implementation authorization.

## All-outline decomposition — 2026-10-21

All 22 original outlines are now delivery groups with 147 bounded child tickets (SC-T046–SC-T192). See [coverage and membership](decomposition.md). Original dependencies/acceptance retained; child memberships gate group closure without child-to-own-parent dependency cycles. 192 tracked tickets: 184 pending, one blocked, seven done; no implementation started.

## Curriculum preparation and publication dependencies — clarified 2026-10-21

A1–C2 manifest decision children SC-T073/089/103/116/129/140 require SC-T006 for their reviewed closure, rather than completion of an earlier runtime delivery group. Draft inventory, source research and proposed mappings may be prepared while review is pending, but cannot be labeled reviewed, close the decision ticket or authorize dependent author-and-review tickets. Those topic children still require their own frozen reviewed manifest; no exact volume or placement is approved by decomposition.

Reviewed topic preparation may overlap earlier-level engineering and learner acceptance. The corresponding integration children SC-T087/101/114/127/138/146 retain the original upstream delivery gate (SC-T028/029/030/031/032/033 respectively), in addition to their reviewed-topic and runtime prerequisites. Thus publication/delivery and parent closure retain the original sequence and all original acceptance criteria. Parent dependencies are closure gates, not prerequisites automatically inherited by every preparation child. Early inspection/staging is not publication or integration acceptance. No learner level-lock is introduced.

On 2026-10-21 the owner approved SC-T006 because a qualified educator review could not be performed. The shared checklist is accepted for that gate and is not a CEFR certificate. Each later batch still needs its own completeness record. This clarification changes scheduling edges only; it approves no content, new feature, scope change or application development.


## Automation execution sequence — 2026-10-21

Use [the ordered ticket runbook](execution-sequence.md) and its linked machine-readable queue for the preferred complete run order. Start SC-T008 → SC-T009 → SC-T010 → SC-T011 after explicit owner development authorization. Refresh exact status/dependencies, require actual acceptance evidence and treat delivery groups as closure audits. Skip completed baseline work; pause affected branches for real external/owner/reviewer/learner evidence and continue only eligible authorized work. No new general readiness review is required. No automation or app implementation is started by adding this plan.

M4 checkpoint, 2026-10-25: [SC-D004 connected focus/evidence](sc-d004-2026-10-25.md) is implementation-complete at awaiting_testing with phone/tablet regression and passing targeted retests. SC-T051 joins SC-T052/054; qualified content/device/manual/learning acceptance remains. SC-T024 stays pending for SC-T053/rewards and original prerequisites.
