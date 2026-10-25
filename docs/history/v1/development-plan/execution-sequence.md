# Ticket execution sequence

Current allocation, 2026-10-25: owner assigned [SC-D002 completion](sc-d002-2026-10-25/README.md) to Codex. SC-T018/019/020/021 are awaiting_testing; SC-T043 remains pending actual acceptance. Independent SC-D004 work retains its source/status/evidence and native runs must serialize. SC-D017 follow-up is recorded; SC-D018 remains deferred. Older dispatch snapshots below are historical.

> Assignment scope, updated 2026-10-23: use the [20 feature-sized delivery tickets](delivery-backlog/README.md). The SC-T queue below retains requirement-level prerequisites and closure checks; it is not the primary list of individual coding assignments. Dated dispatch snapshots below are historical; inspect current ticket files and ownership handoffs before work.

> Current dispatch snapshot: 2026-10-22. The first-loop repair remains recorded. Codex’s active batch is [SC-T051/052/054 Today/Progress reliability](daily-flow-2026-10-22.md); recall recovery and earlier daily evidence remain recorded. Grok’s isolated reward proposals do not change dispatch or authorize reward implementation. SC-T024 and SC-T053 stay open. Historical SC-T010 owner/device acceptance is retained; changed layouts have scoped regression. Exact ticket dependencies and acceptance govern closure.

Start with **SC-T008 → SC-T009 → SC-T010 → SC-T011**. Continue using the full queue below; ticket numbers alone are not a valid run order.

The [machine-readable queue](execution-sequence.json) currently has 11 completed records and 181 unfinished records: 159 executable tickets and 22 delivery-group closure checks. The numbered historical route below retains completed entries for traceability; skip them. The [readiness review](readiness-review.md) retains prior decisions; the current batch supersedes the old single-ticket dispatch scope.

## Dispatch rules

1. Implementation has owner authorization. Execute the current bounded batch; this queue does not authorize publishing, Git initialization, account changes or live calls without their existing gates.
2. Re-read the exact ticket and its contracts, then choose the earliest eligible queue item whose `requires_done` prerequisites are actually complete. The fixed order is a preferred serial route, not a replacement for dependencies. Use one feature-sized delivery ticket per implementation lane; process eligible requirements together. Parallel lanes require disjoint file ownership and coordinated integration.
3. Execute bounded work and relevant verification. Resolve only genuinely unapproved material choices; use approved decisions and routine engineering judgment. Provisional fixture work may proceed before live-provider proof, but live calls keep their prerequisite gates.
4. Record actual evidence and synchronize the ticket, progress, milestone and feature tracker. Do not mark done merely because code was generated. An original SC-T group row remains a closure check. An SC-D delivery ticket is the larger implementation assignment; work in reviewable changes until its eligible scope is complete, retaining every child and original parent acceptance requirement.
5. If an item is blocked, stop its affected branch and select another eligible item within the authorized scope. If none exists, yield with one consolidated blocker list and the specific event/input needed. Never bypass a prerequisite to keep an automation busy.
6. Reparse current status on resume. Skip genuinely completed work, resume partial work from verified state, and refresh affected ordering when scope/dependencies/membership change. Snapshot hashes identify the planning baseline; ordinary status/evidence updates do not require restarting the plan.

## Stage overview

| Stage | Preferred work | Stop / completion boundary |
| --- | --- | --- |
| 1 | SC-T008–SC-T011 | Build/test setup → local state → navigation/preferences → offline recording. Signing/device evidence is distinct from simulator work. |
| 2 | SC-T012–SC-T017 | Candidate BYOK/ASR/coaching, retention/history and integration; account prerequisites before calls, actual RF/device acceptance before proof closure. |
| 3 | SC-T006, SC-T018–SC-T021, SC-T043 | SC-T006 is owner-approved without a qualified educator review. Actual four-week learning and expansion decisions cannot be fabricated. |
| 4 | SC-T046–SC-T062; close SC-T022–SC-T025 | Scheduler decisions first; vocabulary, evidence and economics interleave according to dependencies. Can proceed during a learning wait where eligible. |
| 5 | SC-T063–SC-T072; close SC-T026–SC-T028 | Actual SC-T043 expansion decision first, then bounded course, prospective evaluation and observed pilot repairs. |
| 6 | SC-T073–SC-T147; close SC-T029–SC-T034 | Six reviewed manifests and 57 topic/reuse batches; integration retains original delivery gates. |
| 7 | SC-T148–SC-T169, SC-T182–SC-T192; close SC-T035–SC-T039/SC-T044 | Conversation, communication, generation, resources and seven methods; cross-group voice/content prerequisites may reorder numeric IDs. SC-T153 is research, not realtime implementation. |
| 8 | SC-T170–SC-T181; close SC-T040–SC-T042 | Full claims audit, regression, selected export and tested signed handoff. Export SC-T177/178 precedes dependent privacy acceptance despite its parent being SC-T042. Publishing is not implicit. |

Stages are a navigation/priority view, not global barriers. Example: while SC-T043 waits for actual day-28 evidence, SC-T046 and eligible daily-loop work can proceed after SC-T021; later draft curriculum preparation can overlap only under its documented review/publication rules. The numbered queue below is one valid complete serial route assuming required external evidence becomes available.

## Complete preferred queue

“Run” means execute that bounded ticket; “Close group” means verify original acceptance and all required child evidence. Every linked ticket retains its detailed prerequisites and gates.

### 1 · Native foundation and offline recording

| Order | Ticket | Action | Prerequisites that must be done |
| ---: | --- | --- | --- |
| 1 | [SC-T008 · Create runnable native project and verification commands](tickets/SC-T008.md) | Run | [SC-T002](tickets/SC-T002.md) |
| 2 | [SC-T009 · Implement local state and recovery foundation](tickets/SC-T009.md) | Run | [SC-T008](tickets/SC-T008.md), [SC-T004](tickets/SC-T004.md) |
| 3 | [SC-T010 · Implement adaptive navigation and local preferences](tickets/SC-T010.md) | Run | [SC-T008](tickets/SC-T008.md), [SC-T009](tickets/SC-T009.md), [SC-T007](tickets/SC-T007.md) |
| 4 | [SC-T011 · Record replay and retry an introduction offline](tickets/SC-T011.md) | Run | [SC-T009](tickets/SC-T009.md), [SC-T010](tickets/SC-T010.md) |

### 2 · Speaking feedback and history proof

| Order | Ticket | Action | Prerequisites that must be done |
| ---: | --- | --- | --- |
| 5 | [SC-T012 · Implement BYOK setup and authorized requests](tickets/SC-T012.md) | Run | [SC-T003](tickets/SC-T003.md), [SC-T008](tickets/SC-T008.md), [SC-T010](tickets/SC-T010.md) |
| 6 | [SC-T013 · Transcribe and confirm a recorded attempt](tickets/SC-T013.md) | Run | [SC-T011](tickets/SC-T011.md), [SC-T012](tickets/SC-T012.md) |
| 7 | [SC-T014 · Validate and present text coaching with retry](tickets/SC-T014.md) | Run | [SC-T013](tickets/SC-T013.md) |
| 8 | [SC-T015 · Save speech history and recover deleted records](tickets/SC-T015.md) | Run | [SC-T011](tickets/SC-T011.md), [SC-T009](tickets/SC-T009.md), [SC-T004](tickets/SC-T004.md) |
| 9 | [SC-T016 · Integrate first speaking session and truthful progress](tickets/SC-T016.md) | Run | [SC-T014](tickets/SC-T014.md), [SC-T015](tickets/SC-T015.md) |
| 10 | [SC-T017 · Verify device provider and learner proof gates](tickets/SC-T017.md) | Run | [SC-T016](tickets/SC-T016.md) |

### 3 · Qualified first topic and learning proof

| Order | Ticket | Action | Prerequisites that must be done |
| ---: | --- | --- | --- |
| 11 | [SC-T006 · Define curriculum publication and level-completeness gates](tickets/SC-T006.md) | Run | [SC-T001](tickets/SC-T001.md) |
| 12 | [SC-T018 · Author and review A1 Introductions topic](tickets/SC-T018.md) | Run | [SC-T001](tickets/SC-T001.md), [SC-T006](tickets/SC-T006.md), [SC-T005](tickets/SC-T005.md) |
| 13 | [SC-T019 · Load versioned lessons and required offline assets](tickets/SC-T019.md) | Run | [SC-T005](tickets/SC-T005.md), [SC-T009](tickets/SC-T009.md), [SC-T018](tickets/SC-T018.md) |
| 14 | [SC-T020 · Complete and resume the first lesson offline](tickets/SC-T020.md) | Run | [SC-T019](tickets/SC-T019.md), [SC-T010](tickets/SC-T010.md), [SC-T001](tickets/SC-T001.md) |
| 15 | [SC-T021 · Connect lesson vocabulary speaking and shared progress](tickets/SC-T021.md) | Run | [SC-T020](tickets/SC-T020.md), [SC-T017](tickets/SC-T017.md) |
| 16 | [SC-T043 · Validate the Introductions learning loop before expansion](tickets/SC-T043.md) | Run | [SC-T018](tickets/SC-T018.md), [SC-T021](tickets/SC-T021.md) |

### 4 · Vocabulary, daily focus and rewards

| Order | Ticket | Action | Prerequisites that must be done |
| ---: | --- | --- | --- |
| 17 | [SC-T046 · Select scheduler library and versioned parameters](tickets/SC-T046.md) | Run | [SC-T021](tickets/SC-T021.md) |
| 18 | [SC-T047 · Define review eligibility and shared sense identity](tickets/SC-T047.md) | Run | [SC-T046](tickets/SC-T046.md) |
| 19 | [SC-T022 · Decide scheduler and review-credit policy](tickets/SC-T022.md) | Close group | [SC-T021](tickets/SC-T021.md), [SC-T046](tickets/SC-T046.md), [SC-T047](tickets/SC-T047.md) |
| 20 | [SC-T048 · Enroll shared vocabulary senses without duplicate cards](tickets/SC-T048.md) | Run | [SC-T022](tickets/SC-T022.md) |
| 21 | [SC-T049 · Complete an offline recall and rated review](tickets/SC-T049.md) | Run | [SC-T048](tickets/SC-T048.md) |
| 22 | [SC-T050 · Persist due queues and recover interrupted reviews](tickets/SC-T050.md) | Run | [SC-T049](tickets/SC-T049.md) |
| 23 | [SC-T023 · Deliver vocabulary enrollment and daily reviews](tickets/SC-T023.md) | Close group | [SC-T022](tickets/SC-T022.md), [SC-T048](tickets/SC-T048.md), [SC-T049](tickets/SC-T049.md), [SC-T050](tickets/SC-T050.md) |
| 24 | [SC-T051 · Suggest next practice with an explanation and override](tickets/SC-T051.md) | Run | [SC-T023](tickets/SC-T023.md) |
| 25 | [SC-T052 · Display separate learning evidence and comparison history](tickets/SC-T052.md) | Run | [SC-T023](tickets/SC-T023.md) |
| 26 | [SC-T054 · Show weekly summaries and connected daily focus](tickets/SC-T054.md) | Run | [SC-T051](tickets/SC-T051.md), [SC-T052](tickets/SC-T052.md) |
| 27 | [SC-T055 · Settle reward event and local-day policies](tickets/SC-T055.md) | Run | [SC-T023](tickets/SC-T023.md) |
| 28 | [SC-T056 · Define finite AW instances and reviewed earning rules](tickets/SC-T056.md) | Run | [SC-T055](tickets/SC-T055.md), [SC-T006](tickets/SC-T006.md) |
| 29 | [SC-T057 · Commit participation credits and gold spending once](tickets/SC-T057.md) | Run | [SC-T055](tickets/SC-T055.md) |
| 30 | [SC-T058 · Deliver free hints and explicit optional assistance purchases](tickets/SC-T058.md) | Run | [SC-T057](tickets/SC-T057.md) |
| 31 | [SC-T059 · Deliver Freeze inventory and Repair continuity](tickets/SC-T059.md) | Run | [SC-T057](tickets/SC-T057.md) |
| 32 | [SC-T060 · Track daily goals break timer and private reminders](tickets/SC-T060.md) | Run | [SC-T057](tickets/SC-T057.md) |
| 33 | [SC-T061 · Prepare adopted native award artwork and state overlays](tickets/SC-T061.md) | Run | [SC-T056](tickets/SC-T056.md), [SC-T045](tickets/SC-T045.md) |
| 34 | [SC-T053 · Show achievement criteria and evidence availability](tickets/SC-T053.md) | Run | [SC-T052](tickets/SC-T052.md), [SC-T056](tickets/SC-T056.md), [SC-T057](tickets/SC-T057.md), [SC-T061](tickets/SC-T061.md) |
| 35 | [SC-T024 · Implement daily recommendations and progress evidence](tickets/SC-T024.md) | Close group | [SC-T023](tickets/SC-T023.md), [SC-T051](tickets/SC-T051.md), [SC-T052](tickets/SC-T052.md), [SC-T053](tickets/SC-T053.md), [SC-T054](tickets/SC-T054.md) |
| 36 | [SC-T062 · Present committed results and skippable celebrations](tickets/SC-T062.md) | Run | [SC-T057](tickets/SC-T057.md), [SC-T056](tickets/SC-T056.md), [SC-T061](tickets/SC-T061.md) |
| 37 | [SC-T025 · Implement approved rewards and goal lifecycle](tickets/SC-T025.md) | Close group | [SC-T023](tickets/SC-T023.md), [SC-T055](tickets/SC-T055.md), [SC-T056](tickets/SC-T056.md), [SC-T057](tickets/SC-T057.md), [SC-T058](tickets/SC-T058.md), [SC-T059](tickets/SC-T059.md), [SC-T060](tickets/SC-T060.md), [SC-T061](tickets/SC-T061.md), [SC-T062](tickets/SC-T062.md) |

### 5 · Small course, evaluation and stabilization

| Order | Ticket | Action | Prerequisites that must be done |
| ---: | --- | --- | --- |
| 38 | [SC-T063 · Freeze the small A1 course topic and objective manifest](tickets/SC-T063.md) | Run | [SC-T043](tickets/SC-T043.md), [SC-T006](tickets/SC-T006.md) |
| 39 | [SC-T064 · Author the small-course personal and routine topic batch](tickets/SC-T064.md) | Run | [SC-T063](tickets/SC-T063.md) |
| 40 | [SC-T065 · Author the small-course everyday needs topic batch](tickets/SC-T065.md) | Run | [SC-T063](tickets/SC-T063.md) |
| 41 | [SC-T066 · Run the bounded small A1 course using proven activities](tickets/SC-T066.md) | Run | [SC-T064](tickets/SC-T064.md), [SC-T065](tickets/SC-T065.md), [SC-T021](tickets/SC-T021.md) |
| 42 | [SC-T026 · Expand proven patterns into a bounded A1 course](tickets/SC-T026.md) | Close group | [SC-T043](tickets/SC-T043.md), [SC-T063](tickets/SC-T063.md), [SC-T064](tickets/SC-T064.md), [SC-T065](tickets/SC-T065.md), [SC-T066](tickets/SC-T066.md) |
| 43 | [SC-T067 · Freeze small-course learning and owner evaluation protocol](tickets/SC-T067.md) | Run | [SC-T026](tickets/SC-T026.md), [SC-T024](tickets/SC-T024.md), [SC-T025](tickets/SC-T025.md) |
| 44 | [SC-T068 · Execute small-course learning and usefulness evaluation](tickets/SC-T068.md) | Run | [SC-T067](tickets/SC-T067.md) |
| 45 | [SC-T069 · Validate small-course native daily journeys](tickets/SC-T069.md) | Run | [SC-T067](tickets/SC-T067.md) |
| 46 | [SC-T027 · Validate teaching usefulness and native usability](tickets/SC-T027.md) | Close group | [SC-T026](tickets/SC-T026.md), [SC-T024](tickets/SC-T024.md), [SC-T025](tickets/SC-T025.md), [SC-T067](tickets/SC-T067.md), [SC-T068](tickets/SC-T068.md), [SC-T069](tickets/SC-T069.md) |
| 47 | [SC-T070 · Freeze blocking pilot defects and reuse opportunities](tickets/SC-T070.md) | Run | [SC-T027](tickets/SC-T027.md) |
| 48 | [SC-T071 · Extract only demonstrated reusable activity behavior](tickets/SC-T071.md) | Run | [SC-T070](tickets/SC-T070.md) |
| 49 | [SC-T072 · Close and retest the frozen blocking pilot defect batch](tickets/SC-T072.md) | Run | [SC-T070](tickets/SC-T070.md), [SC-T071](tickets/SC-T071.md) |
| 50 | [SC-T028 · Generalize demonstrated patterns and resolve pilot defects](tickets/SC-T028.md) | Close group | [SC-T027](tickets/SC-T027.md), [SC-T070](tickets/SC-T070.md), [SC-T071](tickets/SC-T071.md), [SC-T072](tickets/SC-T072.md) |

### 6 · Complete A1–C2 curriculum

| Order | Ticket | Action | Prerequisites that must be done |
| ---: | --- | --- | --- |
| 51 | [SC-T073 · Freeze A1 unit objective and publication manifest](tickets/SC-T073.md) | Run | [SC-T006](tickets/SC-T006.md) |
| 52 | [SC-T074 · Author and review A1 topic: Greetings](tickets/SC-T074.md) | Run | [SC-T073](tickets/SC-T073.md) |
| 53 | [SC-T075 · Reconcile A1 introductions coverage with the reviewed INTRO-01 pack](tickets/SC-T075.md) | Run | [SC-T073](tickets/SC-T073.md) |
| 54 | [SC-T076 · Author and review A1 topic: alphabet and spelling](tickets/SC-T076.md) | Run | [SC-T073](tickets/SC-T073.md) |
| 55 | [SC-T077 · Author and review A1 topic: numbers](tickets/SC-T077.md) | Run | [SC-T073](tickets/SC-T073.md) |
| 56 | [SC-T078 · Author and review A1 topic: dates and time](tickets/SC-T078.md) | Run | [SC-T073](tickets/SC-T073.md) |
| 57 | [SC-T079 · Author and review A1 topic: family](tickets/SC-T079.md) | Run | [SC-T073](tickets/SC-T073.md) |
| 58 | [SC-T080 · Author and review A1 topic: home](tickets/SC-T080.md) | Run | [SC-T073](tickets/SC-T073.md) |
| 59 | [SC-T081 · Author and review A1 topic: daily routines](tickets/SC-T081.md) | Run | [SC-T073](tickets/SC-T073.md) |
| 60 | [SC-T082 · Author and review A1 topic: food](tickets/SC-T082.md) | Run | [SC-T073](tickets/SC-T073.md) |
| 61 | [SC-T083 · Author and review A1 topic: shopping](tickets/SC-T083.md) | Run | [SC-T073](tickets/SC-T073.md) |
| 62 | [SC-T084 · Author and review A1 topic: places and directions](tickets/SC-T084.md) | Run | [SC-T073](tickets/SC-T073.md) |
| 63 | [SC-T085 · Author and review A1 topic: hobbies](tickets/SC-T085.md) | Run | [SC-T073](tickets/SC-T073.md) |
| 64 | [SC-T086 · Author and review A1 topic: weather](tickets/SC-T086.md) | Run | [SC-T073](tickets/SC-T073.md) |
| 65 | [SC-T087 · Integrate reviewed A1 packs without changing learner history](tickets/SC-T087.md) | Run | [SC-T074](tickets/SC-T074.md), [SC-T075](tickets/SC-T075.md), [SC-T076](tickets/SC-T076.md), [SC-T077](tickets/SC-T077.md), [SC-T078](tickets/SC-T078.md), [SC-T079](tickets/SC-T079.md), [SC-T080](tickets/SC-T080.md), [SC-T081](tickets/SC-T081.md), [SC-T082](tickets/SC-T082.md), [SC-T083](tickets/SC-T083.md), [SC-T084](tickets/SC-T084.md), [SC-T085](tickets/SC-T085.md), [SC-T086](tickets/SC-T086.md), [SC-T019](tickets/SC-T019.md), [SC-T020](tickets/SC-T020.md), [SC-T028](tickets/SC-T028.md) |
| 66 | [SC-T088 · Accept A1 five-skill completeness and learning evidence](tickets/SC-T088.md) | Run | [SC-T087](tickets/SC-T087.md) |
| 67 | [SC-T029 · Complete reviewed A1 five-skill curriculum](tickets/SC-T029.md) | Close group | [SC-T028](tickets/SC-T028.md), [SC-T006](tickets/SC-T006.md), [SC-T073](tickets/SC-T073.md), [SC-T074](tickets/SC-T074.md), [SC-T075](tickets/SC-T075.md), [SC-T076](tickets/SC-T076.md), [SC-T077](tickets/SC-T077.md), [SC-T078](tickets/SC-T078.md), [SC-T079](tickets/SC-T079.md), [SC-T080](tickets/SC-T080.md), [SC-T081](tickets/SC-T081.md), [SC-T082](tickets/SC-T082.md), [SC-T083](tickets/SC-T083.md), [SC-T084](tickets/SC-T084.md), [SC-T085](tickets/SC-T085.md), [SC-T086](tickets/SC-T086.md), [SC-T087](tickets/SC-T087.md), [SC-T088](tickets/SC-T088.md) |
| 68 | [SC-T089 · Freeze A2 unit objective and publication manifest](tickets/SC-T089.md) | Run | [SC-T006](tickets/SC-T006.md) |
| 69 | [SC-T090 · Author and review A2 topic: Travel](tickets/SC-T090.md) | Run | [SC-T089](tickets/SC-T089.md) |
| 70 | [SC-T091 · Author and review A2 topic: transportation](tickets/SC-T091.md) | Run | [SC-T089](tickets/SC-T089.md) |
| 71 | [SC-T092 · Author and review A2 topic: appointments](tickets/SC-T092.md) | Run | [SC-T089](tickets/SC-T089.md) |
| 72 | [SC-T093 · Author and review A2 topic: health](tickets/SC-T093.md) | Run | [SC-T089](tickets/SC-T089.md) |
| 73 | [SC-T094 · Author and review A2 topic: eating out](tickets/SC-T094.md) | Run | [SC-T089](tickets/SC-T089.md) |
| 74 | [SC-T095 · Author and review A2 topic: invitations](tickets/SC-T095.md) | Run | [SC-T089](tickets/SC-T089.md) |
| 75 | [SC-T096 · Author and review A2 topic: leisure](tickets/SC-T096.md) | Run | [SC-T089](tickets/SC-T089.md) |
| 76 | [SC-T097 · Author and review A2 topic: work routines](tickets/SC-T097.md) | Run | [SC-T089](tickets/SC-T089.md) |
| 77 | [SC-T098 · Author and review A2 topic: past experiences](tickets/SC-T098.md) | Run | [SC-T089](tickets/SC-T089.md) |
| 78 | [SC-T099 · Author and review A2 topic: future plans](tickets/SC-T099.md) | Run | [SC-T089](tickets/SC-T089.md) |
| 79 | [SC-T100 · Author and review A2 topic: everyday problems](tickets/SC-T100.md) | Run | [SC-T089](tickets/SC-T089.md) |
| 80 | [SC-T101 · Integrate reviewed A2 packs without changing learner history](tickets/SC-T101.md) | Run | [SC-T090](tickets/SC-T090.md), [SC-T091](tickets/SC-T091.md), [SC-T092](tickets/SC-T092.md), [SC-T093](tickets/SC-T093.md), [SC-T094](tickets/SC-T094.md), [SC-T095](tickets/SC-T095.md), [SC-T096](tickets/SC-T096.md), [SC-T097](tickets/SC-T097.md), [SC-T098](tickets/SC-T098.md), [SC-T099](tickets/SC-T099.md), [SC-T100](tickets/SC-T100.md), [SC-T019](tickets/SC-T019.md), [SC-T020](tickets/SC-T020.md), [SC-T029](tickets/SC-T029.md) |
| 81 | [SC-T102 · Accept A2 five-skill completeness and learning evidence](tickets/SC-T102.md) | Run | [SC-T101](tickets/SC-T101.md) |
| 82 | [SC-T030 · Complete reviewed A2 five-skill curriculum](tickets/SC-T030.md) | Close group | [SC-T029](tickets/SC-T029.md), [SC-T006](tickets/SC-T006.md), [SC-T089](tickets/SC-T089.md), [SC-T090](tickets/SC-T090.md), [SC-T091](tickets/SC-T091.md), [SC-T092](tickets/SC-T092.md), [SC-T093](tickets/SC-T093.md), [SC-T094](tickets/SC-T094.md), [SC-T095](tickets/SC-T095.md), [SC-T096](tickets/SC-T096.md), [SC-T097](tickets/SC-T097.md), [SC-T098](tickets/SC-T098.md), [SC-T099](tickets/SC-T099.md), [SC-T100](tickets/SC-T100.md), [SC-T101](tickets/SC-T101.md), [SC-T102](tickets/SC-T102.md) |
| 83 | [SC-T103 · Freeze B1 unit objective and publication manifest](tickets/SC-T103.md) | Run | [SC-T006](tickets/SC-T006.md) |
| 84 | [SC-T104 · Author and review B1 topic: Education](tickets/SC-T104.md) | Run | [SC-T103](tickets/SC-T103.md) |
| 85 | [SC-T105 · Author and review B1 topic: career goals](tickets/SC-T105.md) | Run | [SC-T103](tickets/SC-T103.md) |
| 86 | [SC-T106 · Author and review B1 topic: relationships](tickets/SC-T106.md) | Run | [SC-T103](tickets/SC-T103.md) |
| 87 | [SC-T107 · Author and review B1 topic: technology](tickets/SC-T107.md) | Run | [SC-T103](tickets/SC-T103.md) |
| 88 | [SC-T108 · Author and review B1 topic: entertainment](tickets/SC-T108.md) | Run | [SC-T103](tickets/SC-T103.md) |
| 89 | [SC-T109 · Author and review B1 topic: culture](tickets/SC-T109.md) | Run | [SC-T103](tickets/SC-T103.md) |
| 90 | [SC-T110 · Author and review B1 topic: community](tickets/SC-T110.md) | Run | [SC-T103](tickets/SC-T103.md) |
| 91 | [SC-T111 · Author and review B1 topic: personal achievements](tickets/SC-T111.md) | Run | [SC-T103](tickets/SC-T103.md) |
| 92 | [SC-T112 · Author and review B1 topic: decisions](tickets/SC-T112.md) | Run | [SC-T103](tickets/SC-T103.md) |
| 93 | [SC-T113 · Author and review B1 topic: unexpected situations](tickets/SC-T113.md) | Run | [SC-T103](tickets/SC-T103.md) |
| 94 | [SC-T114 · Integrate reviewed B1 packs without changing learner history](tickets/SC-T114.md) | Run | [SC-T104](tickets/SC-T104.md), [SC-T105](tickets/SC-T105.md), [SC-T106](tickets/SC-T106.md), [SC-T107](tickets/SC-T107.md), [SC-T108](tickets/SC-T108.md), [SC-T109](tickets/SC-T109.md), [SC-T110](tickets/SC-T110.md), [SC-T111](tickets/SC-T111.md), [SC-T112](tickets/SC-T112.md), [SC-T113](tickets/SC-T113.md), [SC-T019](tickets/SC-T019.md), [SC-T020](tickets/SC-T020.md), [SC-T030](tickets/SC-T030.md) |
| 95 | [SC-T115 · Accept B1 five-skill completeness and learning evidence](tickets/SC-T115.md) | Run | [SC-T114](tickets/SC-T114.md) |
| 96 | [SC-T031 · Complete reviewed B1 five-skill curriculum](tickets/SC-T031.md) | Close group | [SC-T030](tickets/SC-T030.md), [SC-T006](tickets/SC-T006.md), [SC-T103](tickets/SC-T103.md), [SC-T104](tickets/SC-T104.md), [SC-T105](tickets/SC-T105.md), [SC-T106](tickets/SC-T106.md), [SC-T107](tickets/SC-T107.md), [SC-T108](tickets/SC-T108.md), [SC-T109](tickets/SC-T109.md), [SC-T110](tickets/SC-T110.md), [SC-T111](tickets/SC-T111.md), [SC-T112](tickets/SC-T112.md), [SC-T113](tickets/SC-T113.md), [SC-T114](tickets/SC-T114.md), [SC-T115](tickets/SC-T115.md) |
| 97 | [SC-T116 · Freeze B2 unit objective and publication manifest](tickets/SC-T116.md) | Run | [SC-T006](tickets/SC-T006.md) |
| 98 | [SC-T117 · Author and review B2 topic: Professional projects](tickets/SC-T117.md) | Run | [SC-T116](tickets/SC-T116.md) |
| 99 | [SC-T118 · Author and review B2 topic: leadership](tickets/SC-T118.md) | Run | [SC-T116](tickets/SC-T116.md) |
| 100 | [SC-T119 · Author and review B2 topic: media](tickets/SC-T119.md) | Run | [SC-T116](tickets/SC-T116.md) |
| 101 | [SC-T120 · Author and review B2 topic: social issues](tickets/SC-T120.md) | Run | [SC-T116](tickets/SC-T116.md) |
| 102 | [SC-T121 · Author and review B2 topic: innovation](tickets/SC-T121.md) | Run | [SC-T116](tickets/SC-T116.md) |
| 103 | [SC-T122 · Author and review B2 topic: ethics](tickets/SC-T122.md) | Run | [SC-T116](tickets/SC-T116.md) |
| 104 | [SC-T123 · Author and review B2 topic: environment](tickets/SC-T123.md) | Run | [SC-T116](tickets/SC-T116.md) |
| 105 | [SC-T124 · Author and review B2 topic: presentations](tickets/SC-T124.md) | Run | [SC-T116](tickets/SC-T116.md) |
| 106 | [SC-T125 · Author and review B2 topic: negotiation](tickets/SC-T125.md) | Run | [SC-T116](tickets/SC-T116.md) |
| 107 | [SC-T126 · Author and review B2 topic: disagreements](tickets/SC-T126.md) | Run | [SC-T116](tickets/SC-T116.md) |
| 108 | [SC-T127 · Integrate reviewed B2 packs without changing learner history](tickets/SC-T127.md) | Run | [SC-T117](tickets/SC-T117.md), [SC-T118](tickets/SC-T118.md), [SC-T119](tickets/SC-T119.md), [SC-T120](tickets/SC-T120.md), [SC-T121](tickets/SC-T121.md), [SC-T122](tickets/SC-T122.md), [SC-T123](tickets/SC-T123.md), [SC-T124](tickets/SC-T124.md), [SC-T125](tickets/SC-T125.md), [SC-T126](tickets/SC-T126.md), [SC-T019](tickets/SC-T019.md), [SC-T020](tickets/SC-T020.md), [SC-T031](tickets/SC-T031.md) |
| 109 | [SC-T128 · Accept B2 five-skill completeness and learning evidence](tickets/SC-T128.md) | Run | [SC-T127](tickets/SC-T127.md) |
| 110 | [SC-T032 · Complete reviewed B2 five-skill curriculum](tickets/SC-T032.md) | Close group | [SC-T031](tickets/SC-T031.md), [SC-T006](tickets/SC-T006.md), [SC-T116](tickets/SC-T116.md), [SC-T117](tickets/SC-T117.md), [SC-T118](tickets/SC-T118.md), [SC-T119](tickets/SC-T119.md), [SC-T120](tickets/SC-T120.md), [SC-T121](tickets/SC-T121.md), [SC-T122](tickets/SC-T122.md), [SC-T123](tickets/SC-T123.md), [SC-T124](tickets/SC-T124.md), [SC-T125](tickets/SC-T125.md), [SC-T126](tickets/SC-T126.md), [SC-T127](tickets/SC-T127.md), [SC-T128](tickets/SC-T128.md) |
| 111 | [SC-T129 · Freeze C1 unit objective and publication manifest](tickets/SC-T129.md) | Run | [SC-T006](tickets/SC-T006.md) |
| 112 | [SC-T130 · Author and review C1 topic: Strategy](tickets/SC-T130.md) | Run | [SC-T129](tickets/SC-T129.md) |
| 113 | [SC-T131 · Author and review C1 topic: research](tickets/SC-T131.md) | Run | [SC-T129](tickets/SC-T129.md) |
| 114 | [SC-T132 · Author and review C1 topic: organizational change](tickets/SC-T132.md) | Run | [SC-T129](tickets/SC-T129.md) |
| 115 | [SC-T133 · Author and review C1 topic: complex problems](tickets/SC-T133.md) | Run | [SC-T129](tickets/SC-T129.md) |
| 116 | [SC-T134 · Author and review C1 topic: policy](tickets/SC-T134.md) | Run | [SC-T129](tickets/SC-T129.md) |
| 117 | [SC-T135 · Author and review C1 topic: sensitive workplace discussions](tickets/SC-T135.md) | Run | [SC-T129](tickets/SC-T129.md) |
| 118 | [SC-T136 · Author and review C1 topic: specialist debates](tickets/SC-T136.md) | Run | [SC-T129](tickets/SC-T129.md) |
| 119 | [SC-T137 · Author and review C1 topic: cross-cultural communication](tickets/SC-T137.md) | Run | [SC-T129](tickets/SC-T129.md) |
| 120 | [SC-T138 · Integrate reviewed C1 packs without changing learner history](tickets/SC-T138.md) | Run | [SC-T130](tickets/SC-T130.md), [SC-T131](tickets/SC-T131.md), [SC-T132](tickets/SC-T132.md), [SC-T133](tickets/SC-T133.md), [SC-T134](tickets/SC-T134.md), [SC-T135](tickets/SC-T135.md), [SC-T136](tickets/SC-T136.md), [SC-T137](tickets/SC-T137.md), [SC-T019](tickets/SC-T019.md), [SC-T020](tickets/SC-T020.md), [SC-T032](tickets/SC-T032.md) |
| 121 | [SC-T139 · Accept C1 five-skill completeness and learning evidence](tickets/SC-T139.md) | Run | [SC-T138](tickets/SC-T138.md) |
| 122 | [SC-T033 · Complete reviewed C1 five-skill curriculum](tickets/SC-T033.md) | Close group | [SC-T032](tickets/SC-T032.md), [SC-T006](tickets/SC-T006.md), [SC-T129](tickets/SC-T129.md), [SC-T130](tickets/SC-T130.md), [SC-T131](tickets/SC-T131.md), [SC-T132](tickets/SC-T132.md), [SC-T133](tickets/SC-T133.md), [SC-T134](tickets/SC-T134.md), [SC-T135](tickets/SC-T135.md), [SC-T136](tickets/SC-T136.md), [SC-T137](tickets/SC-T137.md), [SC-T138](tickets/SC-T138.md), [SC-T139](tickets/SC-T139.md) |
| 123 | [SC-T140 · Freeze C2 unit objective and publication manifest](tickets/SC-T140.md) | Run | [SC-T006](tickets/SC-T006.md) |
| 124 | [SC-T141 · Author and review C2 topic: Abstract ideas](tickets/SC-T141.md) | Run | [SC-T140](tickets/SC-T140.md) |
| 125 | [SC-T142 · Author and review C2 topic: competing interpretations](tickets/SC-T142.md) | Run | [SC-T140](tickets/SC-T140.md) |
| 126 | [SC-T143 · Author and review C2 topic: sophisticated debate](tickets/SC-T143.md) | Run | [SC-T140](tickets/SC-T140.md) |
| 127 | [SC-T144 · Author and review C2 topic: cultural references](tickets/SC-T144.md) | Run | [SC-T140](tickets/SC-T140.md) |
| 128 | [SC-T145 · Author and review C2 topic: complex multidisciplinary problems](tickets/SC-T145.md) | Run | [SC-T140](tickets/SC-T140.md) |
| 129 | [SC-T146 · Integrate reviewed C2 packs without changing learner history](tickets/SC-T146.md) | Run | [SC-T141](tickets/SC-T141.md), [SC-T142](tickets/SC-T142.md), [SC-T143](tickets/SC-T143.md), [SC-T144](tickets/SC-T144.md), [SC-T145](tickets/SC-T145.md), [SC-T019](tickets/SC-T019.md), [SC-T020](tickets/SC-T020.md), [SC-T033](tickets/SC-T033.md) |
| 130 | [SC-T147 · Accept C2 five-skill completeness and learning evidence](tickets/SC-T147.md) | Run | [SC-T146](tickets/SC-T146.md) |
| 131 | [SC-T034 · Complete reviewed C2 five-skill curriculum](tickets/SC-T034.md) | Close group | [SC-T033](tickets/SC-T033.md), [SC-T006](tickets/SC-T006.md), [SC-T140](tickets/SC-T140.md), [SC-T141](tickets/SC-T141.md), [SC-T142](tickets/SC-T142.md), [SC-T143](tickets/SC-T143.md), [SC-T144](tickets/SC-T144.md), [SC-T145](tickets/SC-T145.md), [SC-T146](tickets/SC-T146.md), [SC-T147](tickets/SC-T147.md) |

### 7 · Adopted expanded practice and seven trainers

| Order | Ticket | Action | Prerequisites that must be done |
| ---: | --- | --- | --- |
| 132 | [SC-T148 · Define conversation interview turn and workplace contracts](tickets/SC-T148.md) | Run | [SC-T028](tickets/SC-T028.md), [SC-T006](tickets/SC-T006.md) |
| 133 | [SC-T149 · Author reviewed workplace communication and interview scenarios](tickets/SC-T149.md) | Run | [SC-T148](tickets/SC-T148.md) |
| 134 | [SC-T150 · Deliver explicit text or recorded-turn conversation](tickets/SC-T150.md) | Run | [SC-T148](tickets/SC-T148.md), [SC-T149](tickets/SC-T149.md), [SC-T017](tickets/SC-T017.md) |
| 135 | [SC-T151 · Deliver response-dependent interview follow-ups and retry](tickets/SC-T151.md) | Run | [SC-T150](tickets/SC-T150.md) |
| 136 | [SC-T152 · Validate workplace and conversational practice boundaries](tickets/SC-T152.md) | Run | [SC-T151](tickets/SC-T151.md) |
| 137 | [SC-T153 · Record later realtime feasibility and release decision](tickets/SC-T153.md) | Run | [SC-T017](tickets/SC-T017.md) |
| 138 | [SC-T035 · Deliver interview business and expanded speaking coverage](tickets/SC-T035.md) | Close group | [SC-T028](tickets/SC-T028.md), [SC-T006](tickets/SC-T006.md), [SC-T148](tickets/SC-T148.md), [SC-T149](tickets/SC-T149.md), [SC-T150](tickets/SC-T150.md), [SC-T151](tickets/SC-T151.md), [SC-T152](tickets/SC-T152.md), [SC-T153](tickets/SC-T153.md) |
| 139 | [SC-T154 · Freeze communication and articulation teaching subsets](tickets/SC-T154.md) | Run | [SC-T028](tickets/SC-T028.md) |
| 140 | [SC-T155 · Author reviewed organization listening and interaction drills](tickets/SC-T155.md) | Run | [SC-T154](tickets/SC-T154.md), [SC-T006](tickets/SC-T006.md) |
| 141 | [SC-T156 · Author reviewed articulation and delivery reference drills](tickets/SC-T156.md) | Run | [SC-T154](tickets/SC-T154.md), [SC-T006](tickets/SC-T006.md) |
| 142 | [SC-T157 · Deliver shared offline communication and articulation practice](tickets/SC-T157.md) | Run | [SC-T155](tickets/SC-T155.md), [SC-T156](tickets/SC-T156.md), [SC-T021](tickets/SC-T021.md) |
| 143 | [SC-T158 · Validate the audio assessment boundary before sound feedback](tickets/SC-T158.md) | Run | [SC-T156](tickets/SC-T156.md), [SC-T003](tickets/SC-T003.md) |
| 144 | [SC-T159 · Deliver supported focused communication feedback](tickets/SC-T159.md) | Run | [SC-T157](tickets/SC-T157.md), [SC-T158](tickets/SC-T158.md), [SC-T014](tickets/SC-T014.md), [SC-T012](tickets/SC-T012.md) |
| 145 | [SC-T160 · Validate communication articulation and fresh-task evidence](tickets/SC-T160.md) | Run | [SC-T159](tickets/SC-T159.md) |
| 146 | [SC-T036 · Deliver communication and articulation practice](tickets/SC-T036.md) | Close group | [SC-T028](tickets/SC-T028.md), [SC-T154](tickets/SC-T154.md), [SC-T155](tickets/SC-T155.md), [SC-T156](tickets/SC-T156.md), [SC-T157](tickets/SC-T157.md), [SC-T158](tickets/SC-T158.md), [SC-T159](tickets/SC-T159.md), [SC-T160](tickets/SC-T160.md) |
| 147 | [SC-T161 · Define bounded generation validation and reporting policy](tickets/SC-T161.md) | Run | [SC-T028](tickets/SC-T028.md), [SC-T003](tickets/SC-T003.md) |
| 148 | [SC-T162 · Generate and validate one explicit practice request safely](tickets/SC-T162.md) | Run | [SC-T161](tickets/SC-T161.md), [SC-T014](tickets/SC-T014.md) |
| 149 | [SC-T163 · Reuse compatible variants without resetting learning identities](tickets/SC-T163.md) | Run | [SC-T162](tickets/SC-T162.md) |
| 150 | [SC-T164 · Record and resolve incorrect-activity reports locally](tickets/SC-T164.md) | Run | [SC-T163](tickets/SC-T163.md) |
| 151 | [SC-T037 · Generate validated practice with offline fallbacks](tickets/SC-T037.md) | Close group | [SC-T028](tickets/SC-T028.md), [SC-T003](tickets/SC-T003.md), [SC-T161](tickets/SC-T161.md), [SC-T162](tickets/SC-T162.md), [SC-T163](tickets/SC-T163.md), [SC-T164](tickets/SC-T164.md) |
| 152 | [SC-T165 · Create and edit custom vocabulary topics offline](tickets/SC-T165.md) | Run | [SC-T023](tickets/SC-T023.md) |
| 153 | [SC-T166 · Preview select and enroll generated topic vocabulary](tickets/SC-T166.md) | Run | [SC-T165](tickets/SC-T165.md), [SC-T037](tickets/SC-T037.md) |
| 154 | [SC-T167 · Deliver a stable Word of the Day with offline fallback](tickets/SC-T167.md) | Run | [SC-T166](tickets/SC-T166.md), [SC-T055](tickets/SC-T055.md) |
| 155 | [SC-T038 · Deliver Word of Day and custom vocabulary topics](tickets/SC-T038.md) | Close group | [SC-T023](tickets/SC-T023.md), [SC-T037](tickets/SC-T037.md), [SC-T165](tickets/SC-T165.md), [SC-T166](tickets/SC-T166.md), [SC-T167](tickets/SC-T167.md) |
| 156 | [SC-T168 · Decide resource destinations metadata and thumbnail rights](tickets/SC-T168.md) | Run | [SC-T028](tickets/SC-T028.md) |
| 157 | [SC-T169 · Save curated and personal resource cards safely](tickets/SC-T169.md) | Run | [SC-T168](tickets/SC-T168.md) |
| 158 | [SC-T039 · Deliver supporting resource bookmarks](tickets/SC-T039.md) | Close group | [SC-T028](tickets/SC-T028.md), [SC-T168](tickets/SC-T168.md), [SC-T169](tickets/SC-T169.md) |
| 159 | [SC-T182 · Freeze all-seven role objective and level coverage matrix](tickets/SC-T182.md) | Run | [SC-T028](tickets/SC-T028.md), [SC-T006](tickets/SC-T006.md) |
| 160 | [SC-T183 · Resolve Creative Writer character and optional voice design](tickets/SC-T183.md) | Run | [SC-T182](tickets/SC-T182.md), [SC-T007](tickets/SC-T007.md), [SC-T158](tickets/SC-T158.md) |
| 161 | [SC-T184 · Run explicit specialist packs with safe switch and course return](tickets/SC-T184.md) | Run | [SC-T182](tickets/SC-T182.md), [SC-T021](tickets/SC-T021.md) |
| 162 | [SC-T185 · Author and review Teacher specialist pack coverage](tickets/SC-T185.md) | Run | [SC-T182](tickets/SC-T182.md) |
| 163 | [SC-T186 · Author and review Grammarian specialist pack coverage](tickets/SC-T186.md) | Run | [SC-T182](tickets/SC-T182.md) |
| 164 | [SC-T187 · Author and review Librarian specialist pack coverage](tickets/SC-T187.md) | Run | [SC-T182](tickets/SC-T182.md) |
| 165 | [SC-T188 · Author and review Journalist specialist pack coverage](tickets/SC-T188.md) | Run | [SC-T182](tickets/SC-T182.md), [SC-T155](tickets/SC-T155.md) |
| 166 | [SC-T189 · Author and review Business Professional specialist pack coverage](tickets/SC-T189.md) | Run | [SC-T182](tickets/SC-T182.md), [SC-T149](tickets/SC-T149.md) |
| 167 | [SC-T190 · Author and review Speaker specialist pack coverage](tickets/SC-T190.md) | Run | [SC-T182](tickets/SC-T182.md), [SC-T156](tickets/SC-T156.md), [SC-T158](tickets/SC-T158.md) |
| 168 | [SC-T191 · Author and review Creative Writer specialist pack coverage](tickets/SC-T191.md) | Run | [SC-T182](tickets/SC-T182.md), [SC-T183](tickets/SC-T183.md), [SC-T155](tickets/SC-T155.md) |
| 169 | [SC-T192 · Validate all-seven specialist methods and retained learning](tickets/SC-T192.md) | Run | [SC-T184](tickets/SC-T184.md), [SC-T185](tickets/SC-T185.md), [SC-T186](tickets/SC-T186.md), [SC-T187](tickets/SC-T187.md), [SC-T188](tickets/SC-T188.md), [SC-T189](tickets/SC-T189.md), [SC-T190](tickets/SC-T190.md), [SC-T191](tickets/SC-T191.md) |
| 170 | [SC-T044 · Deliver and validate seven specialized trainer packs](tickets/SC-T044.md) | Close group | [SC-T028](tickets/SC-T028.md), [SC-T006](tickets/SC-T006.md), [SC-T182](tickets/SC-T182.md), [SC-T183](tickets/SC-T183.md), [SC-T184](tickets/SC-T184.md), [SC-T185](tickets/SC-T185.md), [SC-T186](tickets/SC-T186.md), [SC-T187](tickets/SC-T187.md), [SC-T188](tickets/SC-T188.md), [SC-T189](tickets/SC-T189.md), [SC-T190](tickets/SC-T190.md), [SC-T191](tickets/SC-T191.md), [SC-T192](tickets/SC-T192.md) |

### 8 · Full release verification and handoff

| Order | Ticket | Action | Prerequisites that must be done |
| ---: | --- | --- | --- |
| 171 | [SC-T170 · Audit complete level and foundation publication coverage](tickets/SC-T170.md) | Run | [SC-T034](tickets/SC-T034.md), [SC-T006](tickets/SC-T006.md) |
| 172 | [SC-T171 · Audit all-seven trainer workplace and practice capability claims](tickets/SC-T171.md) | Run | [SC-T035](tickets/SC-T035.md), [SC-T036](tickets/SC-T036.md), [SC-T037](tickets/SC-T037.md), [SC-T038](tickets/SC-T038.md), [SC-T039](tickets/SC-T039.md), [SC-T044](tickets/SC-T044.md) |
| 173 | [SC-T172 · Audit all award families evidence states and unchanged economics](tickets/SC-T172.md) | Run | [SC-T170](tickets/SC-T170.md), [SC-T171](tickets/SC-T171.md), [SC-T024](tickets/SC-T024.md), [SC-T025](tickets/SC-T025.md) |
| 174 | [SC-T040 · Audit full release curriculum and capability coverage](tickets/SC-T040.md) | Close group | [SC-T034](tickets/SC-T034.md), [SC-T035](tickets/SC-T035.md), [SC-T036](tickets/SC-T036.md), [SC-T037](tickets/SC-T037.md), [SC-T038](tickets/SC-T038.md), [SC-T039](tickets/SC-T039.md), [SC-T044](tickets/SC-T044.md), [SC-T170](tickets/SC-T170.md), [SC-T171](tickets/SC-T171.md), [SC-T172](tickets/SC-T172.md) |
| 175 | [SC-T173 · Freeze release regression matrix and measurable budgets](tickets/SC-T173.md) | Run | [SC-T040](tickets/SC-T040.md) |
| 176 | [SC-T175 · Verify all supported native appearance and accessibility journeys](tickets/SC-T175.md) | Run | [SC-T173](tickets/SC-T173.md) |
| 177 | [SC-T176 · Verify credential cost and network failure containment](tickets/SC-T176.md) | Run | [SC-T173](tickets/SC-T173.md) |
| 178 | [SC-T177 · Define selected export and any explicit restore boundary](tickets/SC-T177.md) | Run | [SC-T004](tickets/SC-T004.md), [SC-T028](tickets/SC-T028.md) |
| 179 | [SC-T178 · Export only explicitly selected retained learner data](tickets/SC-T178.md) | Run | [SC-T177](tickets/SC-T177.md), [SC-T015](tickets/SC-T015.md) |
| 180 | [SC-T174 · Verify persistence upgrades retention export and reset recovery](tickets/SC-T174.md) | Run | [SC-T173](tickets/SC-T173.md), [SC-T178](tickets/SC-T178.md) |
| 181 | [SC-T041 · Verify release reliability privacy and accessibility](tickets/SC-T041.md) | Close group | [SC-T040](tickets/SC-T040.md), [SC-T173](tickets/SC-T173.md), [SC-T174](tickets/SC-T174.md), [SC-T175](tickets/SC-T175.md), [SC-T176](tickets/SC-T176.md) |
| 182 | [SC-T179 · Select distribution signing identity and release recovery procedure](tickets/SC-T179.md) | Run | [SC-T040](tickets/SC-T040.md) |
| 183 | [SC-T180 · Prepare a repeatable signed release candidate](tickets/SC-T180.md) | Run | [SC-T041](tickets/SC-T041.md), [SC-T179](tickets/SC-T179.md) |
| 184 | [SC-T181 · Write verified release and recovery handoff](tickets/SC-T181.md) | Run | [SC-T180](tickets/SC-T180.md) |
| 185 | [SC-T042 · Prepare distribution recovery and release handoff](tickets/SC-T042.md) | Close group | [SC-T041](tickets/SC-T041.md), [SC-T177](tickets/SC-T177.md), [SC-T178](tickets/SC-T178.md), [SC-T179](tickets/SC-T179.md), [SC-T180](tickets/SC-T180.md), [SC-T181](tickets/SC-T181.md) |

## Automation handoff

An orchestrator reads `execution-sequence.json`, refreshes exact ticket status and evaluates the named gate policies before dispatch. There are no runnable app commands yet; SC-T008 establishes them. This is a task queue, not a shell script or assertion that each task needs no human evidence.

SC-T006 is owner-approved without a qualified educator review. SC-T043 and later learning acceptance require real elapsed-time observations. Provider/account, hardware, rights and owner-choice gates remain explicit. Report them together when relevant rather than starting another general readiness-review cycle. Do not auto-create notifications, new chats, recurring jobs or external messages.

Suggested runner instruction:

> Work through the ticket execution sequence within the scope I explicitly authorize. Re-read each exact ticket and approved contracts, select the earliest eligible item, execute its bounded work and required checks, record evidence, and synchronize progress. Use approved decisions; ask only about remaining material choices. Stop affected branches for missing external/qualified/owner evidence and continue only independently eligible authorized work. Never infer publication, account changes, destructive operations or Git initialization from the queue.

The suggested instruction is a reusable handoff, not an instruction to start execution in this conversation.

## Continuous execution authorization — 2026-10-21

Owner authorized continuous ticket execution in sequence, asking only when personal intervention/effort or a required decision is needed. Continue eligible work autonomously; keep default serial ownership, exact prerequisites and acceptance evidence. This does not create a scheduler or authorize unrelated external actions, destructive operations or publishing. SC-T008 completed; SC-T009 active.

## Related-ticket batches — 2026-10-21

Owner authorized working related tickets as one batch. Build the siblings, run one simulator pass, and update their status together. Save the iPad walkthrough for the end of the batch. A batch does not close a ticket whose real gate is still open, and it does not turn a delivery-group parent into one code change.

- Speaking loop: SC-T010–SC-T017. Source is already grouped. What remains is Reduce Motion, the recording matrix, and a live account.
- Lesson loop: SC-T018–SC-T021. SC-T043 stays out until four real weeks of learning exist.
- Review loop: SC-T046–SC-T050. SC-T022 and SC-T023 close only after those children have evidence.

## Expedited engineering checkpoint — 2026-10-21

SC-T010 shell is implemented but iPad accessibility verification remains open. SC-T011 source development proceeds against that shell; its device/dependency acceptance is not waived. Focused relevant checks replace repeated broad runs when no source change justifies them. No additional agent, scheduler or release is created. Exact tickets/evidence govern completion.

## Continued local preparation

SC-T012 local Keychain/masked settings pass phone and signed-simulator tests; real-account/transport acceptance stays open. SC-T013 implements local separate-copy conversion and candidate request-body preparation under the existing provisional-engineering gate. Exact current ticket statuses remain authoritative; no live call, account change or acceptance waiver.

## Request and feedback continuation

SC-T013 durable request/transcript lifecycle and SC-T014 strict feedback/revision-bound commit are fixture-verified on simulator and physical iPhone. One source slice runs at a time while earlier tickets remain in_progress for acceptance. Owner reports iPad unavailable and explicitly directs other work to continue; physical-iPad acceptance stays pending. Live transport and transcript/feedback UI remain undelivered. Completed count stays nine, not inferred from source progress.

## Owner-authorized grouped delivery

SC-T010–SC-T017 are explicitly authorized as one speaking-loop implementation group; build the connected feature before integrated testing, keeping essential compile/data/security checks during work. See speaking-loop-group.md. This supersedes serial ticket dispatch for the group, not individual acceptance/provider/device gates. No agent delegation/scheduler/publication or acceptance waiver is inferred.

## Implementation versus testing queue — 2026-10-23

Owner requested `awaiting_testing` for implementation-complete tickets. Refresh exact ticket headers; [status review](status-review-2026-10-22.md) gives individual reasons. Do not dispatch awaiting-testing tickets for more implementation unless a verified defect reopens them. They still do not satisfy `requires_done`; acceptance is not waived. `verification_pending_tickets` now contains only awaiting-testing tickets; `implementation_remaining_tickets` contains unfinished code/content/decisions. Older dated in-progress/verification lists are historical.

Current bounded Codex work is [personal vocabulary editing/search](vocabulary-editing-2026-10-22.md). Concurrent Grok work is restricted to new `intro-content-preparation/` files according to the [handoff](../../../development-plan/handoffs/grok-intro-content-2026-10-22.md). App/build resources and canonical status integration remain exclusively Codex-owned. Handoff preparation does not confirm Grok started. Previously completed reward proposals remain unapproved until their actual owner choices are resolved.
