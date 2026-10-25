# Decomposition and requirement coverage

> Created 2026-10-21 at owner request. All 22 former outlines decomposed into bounded children; no app implementation, content authoring or product decisions executed. Parent delivery remains pending.

## How to read this register

SC-T022–SC-T042 and SC-T044 retain stable IDs as delivery groups. Child IDs start at SC-T046. Dependencies on a parent require its actual delivered closure. Every child has scope, explicit dependencies, owning responsibility, acceptance, affected areas, verification and evidence placeholders. Pending child count is tracking detail, not weighted completion.

Decision children must settle still-open choices before dependent implementation/content. No scheduler/library/price/model, course volume, framework subset or new character is silently selected. Existing approved values and scope remain unchanged. Each curriculum topic child is a bounded pack under its prerequisite reviewed level manifest; its exact objective/lesson volume is still a gated editorial decision, not an invented quantity. Existing Introductions/small-course packs must be referenced/reused rather than recreated.

Qualified educator review remains pending under blocked SC-T006. Development remains on hold until explicit owner instruction. No cloud/provider call, deployment, signing change or Git initialization is authorized.

Execution graph = recorded Dependencies plus delivery-group closure edges to children. It must stay acyclic; membership is not an execution dependency from child to its own parent. New issue-specific tests/repair tickets and genuinely missing activity types may be registered when real evidence exists; they are not invented in this decomposition.

## Group and child index

| Delivery group | Milestone | Children | New ticket range |
| --- | --- | ---: | --- |
| [SC-T022](tickets/SC-T022.md) | M4 | 2 | SC-T046–SC-T047 |
| [SC-T023](tickets/SC-T023.md) | M4 | 3 | SC-T048–SC-T050 |
| [SC-T024](tickets/SC-T024.md) | M4 | 4 | SC-T051–SC-T054 |
| [SC-T025](tickets/SC-T025.md) | M4 | 8 | SC-T055–SC-T062 |
| [SC-T026](tickets/SC-T026.md) | M5 | 4 | SC-T063–SC-T066 |
| [SC-T027](tickets/SC-T027.md) | M5 | 3 | SC-T067–SC-T069 |
| [SC-T028](tickets/SC-T028.md) | M5 | 3 | SC-T070–SC-T072 |
| [SC-T029](tickets/SC-T029.md) | M6 | 16 | SC-T073–SC-T088 |
| [SC-T030](tickets/SC-T030.md) | M7 | 14 | SC-T089–SC-T102 |
| [SC-T031](tickets/SC-T031.md) | M8 | 13 | SC-T103–SC-T115 |
| [SC-T032](tickets/SC-T032.md) | M9 | 13 | SC-T116–SC-T128 |
| [SC-T033](tickets/SC-T033.md) | M10 | 11 | SC-T129–SC-T139 |
| [SC-T034](tickets/SC-T034.md) | M11 | 8 | SC-T140–SC-T147 |
| [SC-T035](tickets/SC-T035.md) | M12 | 6 | SC-T148–SC-T153 |
| [SC-T036](tickets/SC-T036.md) | M12 | 7 | SC-T154–SC-T160 |
| [SC-T037](tickets/SC-T037.md) | M12 | 4 | SC-T161–SC-T164 |
| [SC-T038](tickets/SC-T038.md) | M12 | 3 | SC-T165–SC-T167 |
| [SC-T039](tickets/SC-T039.md) | M12 | 2 | SC-T168–SC-T169 |
| [SC-T040](tickets/SC-T040.md) | M13 | 3 | SC-T170–SC-T172 |
| [SC-T041](tickets/SC-T041.md) | M13 | 4 | SC-T173–SC-T176 |
| [SC-T042](tickets/SC-T042.md) | M13 | 5 | SC-T177–SC-T181 |
| [SC-T044](tickets/SC-T044.md) | M12 | 11 | SC-T182–SC-T192 |

## SC-T022 · Decide scheduler and review-credit policy

Original scope and acceptance are retained verbatim in the parent file. Allocation below states which child carries each requirement; all group criteria still gate closure.

| Child | Outcome / dependency |
| --- | --- |
| [SC-T046](tickets/SC-T046.md) | Select scheduler library and versioned parameters; prerequisites: SC-T021 |
| [SC-T047](tickets/SC-T047.md) | Define review eligibility and shared sense identity; prerequisites: SC-T046 |

### Retained parent acceptance coverage

- **AC1** — Approved policy preserves separate recall/use evidence and accepts only eligible explicit rated reviews initially.
  Accountable children: [SC-T046](tickets/SC-T046.md), [SC-T047](tickets/SC-T047.md). All applicable inherited constraints remain mandatory across the group.
- **AC2** — Decision includes deterministic examples and migration/clock failure scenarios.
  Accountable children: [SC-T046](tickets/SC-T046.md), [SC-T047](tickets/SC-T047.md). All applicable inherited constraints remain mandatory across the group.

## SC-T023 · Deliver vocabulary enrollment and daily reviews

Original scope and acceptance are retained verbatim in the parent file. Allocation below states which child carries each requirement; all group criteria still gate closure.

| Child | Outcome / dependency |
| --- | --- |
| [SC-T048](tickets/SC-T048.md) | Enroll shared vocabulary senses without duplicate cards; prerequisites: SC-T022 |
| [SC-T049](tickets/SC-T049.md) | Complete an offline recall and rated review; prerequisites: SC-T048 |
| [SC-T050](tickets/SC-T050.md) | Persist due queues and recover interrupted reviews; prerequisites: SC-T049 |

### Retained parent acceptance coverage

- **AC1** — Offline rated reviews advance only the intended card once; exposure/grammar feedback cannot silently alter recall.
  Accountable children: [SC-T049](tickets/SC-T049.md), [SC-T050](tickets/SC-T050.md). All applicable inherited constraints remain mandatory across the group.
- **AC2** — Repeated enrollment cannot duplicate cards; restart retains schedule/evidence.
  Accountable children: [SC-T048](tickets/SC-T048.md), [SC-T050](tickets/SC-T050.md). All applicable inherited constraints remain mandatory across the group.

## SC-T024 · Implement daily recommendations and progress evidence

Original scope and acceptance are retained verbatim in the parent file. Allocation below states which child carries each requirement; all group criteria still gate closure.

| Child | Outcome / dependency |
| --- | --- |
| [SC-T051](tickets/SC-T051.md) | Suggest next practice with an explanation and override; prerequisites: SC-T023 |
| [SC-T052](tickets/SC-T052.md) | Display separate learning evidence and comparison history; prerequisites: SC-T023 |
| [SC-T053](tickets/SC-T053.md) | Show achievement criteria and evidence availability; prerequisites: SC-T052, SC-T056, SC-T057, SC-T061 |
| [SC-T054](tickets/SC-T054.md) | Show weekly summaries and connected daily focus; prerequisites: SC-T051, SC-T052 |

### Retained parent acceptance coverage

- **AC1** — Use the adopted family shell/subject/tier/state mapping for Progress overview and details, course checkpoints and wallet/goal indicators. Preserve accessible native labels, criteria/support evidence and noncollectible milestone semantics; verify applicable AV-QA and RW-QA checks.
  Accountable children: [SC-T053](tickets/SC-T053.md). All applicable inherited constraints remain mandatory across the group.
- **AC2** — Reference stable AW catalog families/instances in Progress with truthful category/earned/insufficient/unavailable evidence. Distinguish eight operational indicators from collectible awards and XP/gold; never present the adopted family count as finished visuals or all planned levels/capabilities as earnable.
  Accountable children: [SC-T053](tickets/SC-T053.md). All applicable inherited constraints remain mandatory across the group.
- **AC3** — Show badge category, criterion, earned/evidence availability and permitted supporting task context in Progress with itemized reward history, following the reviewable reward proposal. Participation/XP levels never become CEFR advancement or verified skill; RW-QA02/07/08 supplement existing progress checks.
  Accountable children: [SC-T053](tickets/SC-T053.md), [SC-T054](tickets/SC-T054.md). All applicable inherited constraints remain mandatory across the group.
- **AC4** — Refined children offer skill-based trainer suggestions with a reason and manual override: retrieval/comprehension to Librarian, agreement/construction to Grammarian, follow-up/listening to Journalist, workplace purpose to Business Professional, supported delivery to Speaker, storytelling/expression to Writer and guided foundations to Teacher. Use available reviewed packs and evidence/goals; do not diagnose or imply all-seven availability from selection alone.
  Accountable children: [SC-T051](tickets/SC-T051.md). All applicable inherited constraints remain mandatory across the group.
- **AC5** — Refined children must implement the INTRO-01 difficulty-to-practice mappings with a plain-language reason and manual override, checking retrieval, grammar, follow-up and clarity cases plus insufficient evidence (IL-09). Display recognition/recall/use/retention/transfer separately with assistance and missing-evidence state; confidence is self-report, not inferred from audio.
  Accountable children: [SC-T051](tickets/SC-T051.md), [SC-T052](tickets/SC-T052.md). All applicable inherited constraints remain mandatory across the group.
- **AC6** — Suggestions are explainable and do not imply automatic CEFR placement.
  Accountable children: [SC-T051](tickets/SC-T051.md). All applicable inherited constraints remain mandatory across the group.
- **AC7** — Comparison retains task/rubric/provider context; participation and assessed improvement remain distinct.
  Accountable children: [SC-T052](tickets/SC-T052.md). All applicable inherited constraints remain mandatory across the group.

## SC-T025 · Implement approved rewards and goal lifecycle

Original scope and acceptance are retained verbatim in the parent file. Allocation below states which child carries each requirement; all group criteria still gate closure.

| Child | Outcome / dependency |
| --- | --- |
| [SC-T055](tickets/SC-T055.md) | Settle reward event and local-day policies; prerequisites: SC-T023 |
| [SC-T056](tickets/SC-T056.md) | Define finite AW instances and reviewed earning rules; prerequisites: SC-T055, SC-T006 |
| [SC-T057](tickets/SC-T057.md) | Commit participation credits and gold spending once; prerequisites: SC-T055 |
| [SC-T058](tickets/SC-T058.md) | Deliver free hints and explicit optional assistance purchases; prerequisites: SC-T057 |
| [SC-T059](tickets/SC-T059.md) | Deliver Freeze inventory and Repair continuity; prerequisites: SC-T057 |
| [SC-T060](tickets/SC-T060.md) | Track daily goals break timer and private reminders; prerequisites: SC-T057 |
| [SC-T061](tickets/SC-T061.md) | Prepare adopted native award artwork and state overlays; prerequisites: SC-T056, SC-T045 |
| [SC-T062](tickets/SC-T062.md) | Present committed results and skippable celebrations; prerequisites: SC-T057, SC-T056, SC-T061 |

### Retained parent acceptance coverage

- **AC1** — Decomposed asset/result/motion children must implement adopted visual system v1 across every AW family/instance with reusable shells/state/tier overlays and exact subject IDs. Produce editable masters and appropriate small/native variants as scoped; verify AV-QA01–08 plus RW-QA01–08 without generating new payouts or requiring visual-direction approval again.
  Accountable children: [SC-T061](tickets/SC-T061.md), [SC-T056](tickets/SC-T056.md), [SC-T062](tickets/SC-T062.md). All applicable inherited constraints remain mandatory across the group.
- **AC2** — The owner adopted all 68 AW families, names, classifications and initial tiers on 2026-10-19. Do not ask for catalog selection again. Resolve parameterized content sets, role/modality/capability prerequisites, qualified evidence/rule validation, overlap/deduplication and unresolved dates/XP/deletion policies before activation. The owner adopted visual system v1 and its 68-family subject/state/tier map; no repeated direction-selection approval is required. Production exports and runtime quality still need verification. Preserve eight listed economic entries with unchanged approved amounts; no reward per badge or collectible just for selecting a coach.
  Accountable children: [SC-T056](tickets/SC-T056.md), [SC-T055](tickets/SC-T055.md). All applicable inherited constraints remain mandatory across the group.
- **AC3** — Before implementation decompose the adopted reward design into bounded decision/eligibility-ledger, result/badge surfaces and native motion/accessibility children. Validate adopted catalog learning thresholds and resolve motion/gesture settings, repeat/day/event identity and deletion/reversal policy explicitly. Verify RW-QA01–08: ledger precedes earned UI, no award on animation/display/skip, immediately usable Continue, grouped safe-boundary delivery, static Reduce Motion/quiet alternatives and durable evidence details. Preserve approved economy amounts; initial motion/art direction and the 68-family catalog are adopted; asset fidelity, accessibility and runtime quality remain unverified.
  Accountable children: [SC-T057](tickets/SC-T057.md), [SC-T062](tickets/SC-T062.md). All applicable inherited constraints remain mandatory across the group.
- **AC4** — Refined children must verify that no gold/hint limit blocks explanations, correction, accessibility, replay or retry, while preserving optional gold-priced aids. Participation awards cannot establish mastery, retention or transfer; missing evidence cannot support improvement claims. Include IL-05/IL-10 alongside reward deduplication checks.
  Accountable children: [SC-T058](tickets/SC-T058.md), [SC-T056](tickets/SC-T056.md). All applicable inherited constraints remain mandatory across the group.
- **AC5** — Repeat/retry/offline/restart paths cannot duplicate rewards; hint and day-boundary behavior follows approved policy.
  Accountable children: [SC-T057](tickets/SC-T057.md), [SC-T058](tickets/SC-T058.md), [SC-T059](tickets/SC-T059.md). All applicable inherited constraints remain mandatory across the group.
- **AC6** — Rewards never establish mastery; reminders respect permissions/privacy and learner settings.
  Accountable children: [SC-T060](tickets/SC-T060.md), [SC-T057](tickets/SC-T057.md). All applicable inherited constraints remain mandatory across the group.

## SC-T026 · Expand proven patterns into a bounded A1 course

Original scope and acceptance are retained verbatim in the parent file. Allocation below states which child carries each requirement; all group criteria still gate closure.

| Child | Outcome / dependency |
| --- | --- |
| [SC-T063](tickets/SC-T063.md) | Freeze the small A1 course topic and objective manifest; prerequisites: SC-T043, SC-T006 |
| [SC-T064](tickets/SC-T064.md) | Author the small-course personal and routine topic batch; prerequisites: SC-T063 |
| [SC-T065](tickets/SC-T065.md) | Author the small-course everyday needs topic batch; prerequisites: SC-T063 |
| [SC-T066](tickets/SC-T066.md) | Run the bounded small A1 course using proven activities; prerequisites: SC-T064, SC-T065, SC-T021 |

### Retained parent acceptance coverage

- **AC1** — During decomposition, create bounded foundation child-objective authoring/activity batches under EF-01–EF-05, linked both ways to their CEFR lessons. Specify included topics, descriptor references, alternatives, completion, and EF-AC/EF-QA acceptance per batch. Reuse proven activity types; later grammar depth is delivered through the corresponding level batches rather than front-loading the whole inventory into A1.
  Accountable children: [SC-T063](tickets/SC-T063.md), [SC-T064](tickets/SC-T064.md), [SC-T065](tickets/SC-T065.md). All applicable inherited constraints remain mandatory across the group.
- **AC2** — Course expansion requires the completed SC-T043 report and explicit educator/owner expansion decision under the IL protocol. No learning signal or insufficient evidence requires rework/retest or a documented bounded next experiment; do not infer effectiveness from app completion. Every new topic needs a practical independent outcome, separate skill evidence, delayed check and reviewed unfamiliar task suited to that objective.
  Accountable children: [SC-T063](tickets/SC-T063.md). All applicable inherited constraints remain mandatory across the group.
- **AC3** — Every included topic has reviewed five-skill coverage appropriate to its objectives and local required assets.
  Accountable children: [SC-T064](tickets/SC-T064.md), [SC-T065](tickets/SC-T065.md), [SC-T066](tickets/SC-T066.md). All applicable inherited constraints remain mandatory across the group.
- **AC4** — A bounded small course is labeled accurately; no claim of complete A1 before M6.
  Accountable children: [SC-T063](tickets/SC-T063.md), [SC-T066](tickets/SC-T066.md). All applicable inherited constraints remain mandatory across the group.

## SC-T027 · Validate teaching usefulness and native usability

Original scope and acceptance are retained verbatim in the parent file. Allocation below states which child carries each requirement; all group criteria still gate closure.

| Child | Outcome / dependency |
| --- | --- |
| [SC-T067](tickets/SC-T067.md) | Freeze small-course learning and owner evaluation protocol; prerequisites: SC-T026, SC-T024, SC-T025 |
| [SC-T068](tickets/SC-T068.md) | Execute small-course learning and usefulness evaluation; prerequisites: SC-T067 |
| [SC-T069](tickets/SC-T069.md) | Validate small-course native daily journeys; prerequisites: SC-T067 |

### Retained parent acceptance coverage

- **AC1** — Extend the first-topic SC-T043 evaluation to the scoped small course; retain its baseline, delayed recall, unseen transfer, blinded human review and assistance distinctions. Refine child tickets with cohort/sample plan and comparison conditions before execution. Report all enrolled/missing outcomes and limits; owner usefulness, confidence, accessibility and XP do not substitute for learning evidence or public causal claims.
  Accountable children: [SC-T067](tickets/SC-T067.md), [SC-T068](tickets/SC-T068.md). All applicable inherited constraints remain mandatory across the group.
- **AC2** — Evidence separates usefulness, learning, accessibility and engagement; limitations remain explicit.
  Accountable children: [SC-T068](tickets/SC-T068.md), [SC-T069](tickets/SC-T069.md). All applicable inherited constraints remain mandatory across the group.
- **AC3** — Findings have severity and remedial tickets; blocking defects prevent milestone closure.
  Accountable children: [SC-T068](tickets/SC-T068.md), [SC-T069](tickets/SC-T069.md). All applicable inherited constraints remain mandatory across the group.

## SC-T028 · Generalize demonstrated patterns and resolve pilot defects

Original scope and acceptance are retained verbatim in the parent file. Allocation below states which child carries each requirement; all group criteria still gate closure.

| Child | Outcome / dependency |
| --- | --- |
| [SC-T070](tickets/SC-T070.md) | Freeze blocking pilot defects and reuse opportunities; prerequisites: SC-T027 |
| [SC-T071](tickets/SC-T071.md) | Extract only demonstrated reusable activity behavior; prerequisites: SC-T070 |
| [SC-T072](tickets/SC-T072.md) | Close and retest the frozen blocking pilot defect batch; prerequisites: SC-T070, SC-T071 |

### Retained parent acceptance coverage

- **AC1** — Remediation evidence closes blocking pilot issues.
  Accountable children: [SC-T072](tickets/SC-T072.md). All applicable inherited constraints remain mandatory across the group.
- **AC2** — Reusable activities serve multiple reviewed topics without topic-specific screen duplication or changed historical results.
  Accountable children: [SC-T071](tickets/SC-T071.md). All applicable inherited constraints remain mandatory across the group.

## SC-T029 · Complete reviewed A1 five-skill curriculum

Original scope and acceptance are retained verbatim in the parent file. Allocation below states which child carries each requirement; all group criteria still gate closure.

| Child | Outcome / dependency |
| --- | --- |
| [SC-T073](tickets/SC-T073.md) | Freeze A1 unit objective and publication manifest; prerequisites: SC-T006 |
| [SC-T074](tickets/SC-T074.md) | Author and review A1 topic: Greetings; prerequisites: SC-T073 |
| [SC-T075](tickets/SC-T075.md) | Reconcile A1 introductions coverage with the reviewed INTRO-01 pack; prerequisites: SC-T073 |
| [SC-T076](tickets/SC-T076.md) | Author and review A1 topic: alphabet and spelling; prerequisites: SC-T073 |
| [SC-T077](tickets/SC-T077.md) | Author and review A1 topic: numbers; prerequisites: SC-T073 |
| [SC-T078](tickets/SC-T078.md) | Author and review A1 topic: dates and time; prerequisites: SC-T073 |
| [SC-T079](tickets/SC-T079.md) | Author and review A1 topic: family; prerequisites: SC-T073 |
| [SC-T080](tickets/SC-T080.md) | Author and review A1 topic: home; prerequisites: SC-T073 |
| [SC-T081](tickets/SC-T081.md) | Author and review A1 topic: daily routines; prerequisites: SC-T073 |
| [SC-T082](tickets/SC-T082.md) | Author and review A1 topic: food; prerequisites: SC-T073 |
| [SC-T083](tickets/SC-T083.md) | Author and review A1 topic: shopping; prerequisites: SC-T073 |
| [SC-T084](tickets/SC-T084.md) | Author and review A1 topic: places and directions; prerequisites: SC-T073 |
| [SC-T085](tickets/SC-T085.md) | Author and review A1 topic: hobbies; prerequisites: SC-T073 |
| [SC-T086](tickets/SC-T086.md) | Author and review A1 topic: weather; prerequisites: SC-T073 |
| [SC-T087](tickets/SC-T087.md) | Integrate reviewed A1 packs without changing learner history; prerequisites: SC-T074, SC-T075, SC-T076, SC-T077, SC-T078, SC-T079, SC-T080, SC-T081, SC-T082, SC-T083, SC-T084, SC-T085, SC-T086, SC-T019, SC-T020, SC-T028 |
| [SC-T088](tickets/SC-T088.md) | Accept A1 five-skill completeness and learning evidence; prerequisites: SC-T087 |

### Retained parent acceptance coverage

- **AC1** — A1 completeness includes the educator-reviewed foundational word types, sentence roles/order, be/present agreement and basic phrases/clauses in the EF coverage matrix. Verify contextual and focused access, concept versus production/use evidence and applicable EF-QA checks; advanced EF coverage remains mapped to later level tickets rather than being mislabeled available at A1.
  Accountable children: [SC-T073](tickets/SC-T073.md), [SC-T088](tickets/SC-T088.md). All applicable inherited constraints remain mandatory across the group.
- **AC2** — A1 coverage/volume satisfies the M0 checklist with qualified editorial evidence; no official certification claim.
  Accountable children: [SC-T073](tickets/SC-T073.md), [SC-T088](tickets/SC-T088.md). All applicable inherited constraints remain mandatory across the group.
- **AC3** — Published required lessons/assets work offline under documented local-installation preconditions; no key/cloud generation needed for core completion.
  Accountable children: [SC-T087](tickets/SC-T087.md). All applicable inherited constraints remain mandatory across the group.
- **AC4** — Available-level bypass is preserved; historical attempts and progression survive compatible content updates.
  Accountable children: [SC-T087](tickets/SC-T087.md). All applicable inherited constraints remain mandatory across the group.
- **AC5** — Applicable QA-29–QA-37, device checks and learner evidence are recorded; unfinished content is labeled honestly.
  Accountable children: [SC-T088](tickets/SC-T088.md). All applicable inherited constraints remain mandatory across the group.

## SC-T030 · Complete reviewed A2 five-skill curriculum

Original scope and acceptance are retained verbatim in the parent file. Allocation below states which child carries each requirement; all group criteria still gate closure.

| Child | Outcome / dependency |
| --- | --- |
| [SC-T089](tickets/SC-T089.md) | Freeze A2 unit objective and publication manifest; prerequisites: SC-T006 |
| [SC-T090](tickets/SC-T090.md) | Author and review A2 topic: Travel; prerequisites: SC-T089 |
| [SC-T091](tickets/SC-T091.md) | Author and review A2 topic: transportation; prerequisites: SC-T089 |
| [SC-T092](tickets/SC-T092.md) | Author and review A2 topic: appointments; prerequisites: SC-T089 |
| [SC-T093](tickets/SC-T093.md) | Author and review A2 topic: health; prerequisites: SC-T089 |
| [SC-T094](tickets/SC-T094.md) | Author and review A2 topic: eating out; prerequisites: SC-T089 |
| [SC-T095](tickets/SC-T095.md) | Author and review A2 topic: invitations; prerequisites: SC-T089 |
| [SC-T096](tickets/SC-T096.md) | Author and review A2 topic: leisure; prerequisites: SC-T089 |
| [SC-T097](tickets/SC-T097.md) | Author and review A2 topic: work routines; prerequisites: SC-T089 |
| [SC-T098](tickets/SC-T098.md) | Author and review A2 topic: past experiences; prerequisites: SC-T089 |
| [SC-T099](tickets/SC-T099.md) | Author and review A2 topic: future plans; prerequisites: SC-T089 |
| [SC-T100](tickets/SC-T100.md) | Author and review A2 topic: everyday problems; prerequisites: SC-T089 |
| [SC-T101](tickets/SC-T101.md) | Integrate reviewed A2 packs without changing learner history; prerequisites: SC-T090, SC-T091, SC-T092, SC-T093, SC-T094, SC-T095, SC-T096, SC-T097, SC-T098, SC-T099, SC-T100, SC-T019, SC-T020, SC-T029 |
| [SC-T102](tickets/SC-T102.md) | Accept A2 five-skill completeness and learning evidence; prerequisites: SC-T101 |

### Retained parent acceptance coverage

- **AC1** — A2 coverage/volume satisfies the M0 checklist with qualified editorial evidence; no official certification claim.
  Accountable children: [SC-T089](tickets/SC-T089.md), [SC-T102](tickets/SC-T102.md). All applicable inherited constraints remain mandatory across the group.
- **AC2** — Published required lessons/assets work offline under documented local-installation preconditions; no key/cloud generation needed for core completion.
  Accountable children: [SC-T101](tickets/SC-T101.md). All applicable inherited constraints remain mandatory across the group.
- **AC3** — Available-level bypass is preserved; historical attempts and progression survive compatible content updates.
  Accountable children: [SC-T101](tickets/SC-T101.md). All applicable inherited constraints remain mandatory across the group.
- **AC4** — Applicable QA-29–QA-37, device checks and learner evidence are recorded; unfinished content is labeled honestly.
  Accountable children: [SC-T102](tickets/SC-T102.md). All applicable inherited constraints remain mandatory across the group.

## SC-T031 · Complete reviewed B1 five-skill curriculum

Original scope and acceptance are retained verbatim in the parent file. Allocation below states which child carries each requirement; all group criteria still gate closure.

| Child | Outcome / dependency |
| --- | --- |
| [SC-T103](tickets/SC-T103.md) | Freeze B1 unit objective and publication manifest; prerequisites: SC-T006 |
| [SC-T104](tickets/SC-T104.md) | Author and review B1 topic: Education; prerequisites: SC-T103 |
| [SC-T105](tickets/SC-T105.md) | Author and review B1 topic: career goals; prerequisites: SC-T103 |
| [SC-T106](tickets/SC-T106.md) | Author and review B1 topic: relationships; prerequisites: SC-T103 |
| [SC-T107](tickets/SC-T107.md) | Author and review B1 topic: technology; prerequisites: SC-T103 |
| [SC-T108](tickets/SC-T108.md) | Author and review B1 topic: entertainment; prerequisites: SC-T103 |
| [SC-T109](tickets/SC-T109.md) | Author and review B1 topic: culture; prerequisites: SC-T103 |
| [SC-T110](tickets/SC-T110.md) | Author and review B1 topic: community; prerequisites: SC-T103 |
| [SC-T111](tickets/SC-T111.md) | Author and review B1 topic: personal achievements; prerequisites: SC-T103 |
| [SC-T112](tickets/SC-T112.md) | Author and review B1 topic: decisions; prerequisites: SC-T103 |
| [SC-T113](tickets/SC-T113.md) | Author and review B1 topic: unexpected situations; prerequisites: SC-T103 |
| [SC-T114](tickets/SC-T114.md) | Integrate reviewed B1 packs without changing learner history; prerequisites: SC-T104, SC-T105, SC-T106, SC-T107, SC-T108, SC-T109, SC-T110, SC-T111, SC-T112, SC-T113, SC-T019, SC-T020, SC-T030 |
| [SC-T115](tickets/SC-T115.md) | Accept B1 five-skill completeness and learning evidence; prerequisites: SC-T114 |

### Retained parent acceptance coverage

- **AC1** — B1 coverage/volume satisfies the M0 checklist with qualified editorial evidence; no official certification claim.
  Accountable children: [SC-T103](tickets/SC-T103.md), [SC-T115](tickets/SC-T115.md). All applicable inherited constraints remain mandatory across the group.
- **AC2** — Published required lessons/assets work offline under documented local-installation preconditions; no key/cloud generation needed for core completion.
  Accountable children: [SC-T114](tickets/SC-T114.md). All applicable inherited constraints remain mandatory across the group.
- **AC3** — Available-level bypass is preserved; historical attempts and progression survive compatible content updates.
  Accountable children: [SC-T114](tickets/SC-T114.md). All applicable inherited constraints remain mandatory across the group.
- **AC4** — Applicable QA-29–QA-37, device checks and learner evidence are recorded; unfinished content is labeled honestly.
  Accountable children: [SC-T115](tickets/SC-T115.md). All applicable inherited constraints remain mandatory across the group.

## SC-T032 · Complete reviewed B2 five-skill curriculum

Original scope and acceptance are retained verbatim in the parent file. Allocation below states which child carries each requirement; all group criteria still gate closure.

| Child | Outcome / dependency |
| --- | --- |
| [SC-T116](tickets/SC-T116.md) | Freeze B2 unit objective and publication manifest; prerequisites: SC-T006 |
| [SC-T117](tickets/SC-T117.md) | Author and review B2 topic: Professional projects; prerequisites: SC-T116 |
| [SC-T118](tickets/SC-T118.md) | Author and review B2 topic: leadership; prerequisites: SC-T116 |
| [SC-T119](tickets/SC-T119.md) | Author and review B2 topic: media; prerequisites: SC-T116 |
| [SC-T120](tickets/SC-T120.md) | Author and review B2 topic: social issues; prerequisites: SC-T116 |
| [SC-T121](tickets/SC-T121.md) | Author and review B2 topic: innovation; prerequisites: SC-T116 |
| [SC-T122](tickets/SC-T122.md) | Author and review B2 topic: ethics; prerequisites: SC-T116 |
| [SC-T123](tickets/SC-T123.md) | Author and review B2 topic: environment; prerequisites: SC-T116 |
| [SC-T124](tickets/SC-T124.md) | Author and review B2 topic: presentations; prerequisites: SC-T116 |
| [SC-T125](tickets/SC-T125.md) | Author and review B2 topic: negotiation; prerequisites: SC-T116 |
| [SC-T126](tickets/SC-T126.md) | Author and review B2 topic: disagreements; prerequisites: SC-T116 |
| [SC-T127](tickets/SC-T127.md) | Integrate reviewed B2 packs without changing learner history; prerequisites: SC-T117, SC-T118, SC-T119, SC-T120, SC-T121, SC-T122, SC-T123, SC-T124, SC-T125, SC-T126, SC-T019, SC-T020, SC-T031 |
| [SC-T128](tickets/SC-T128.md) | Accept B2 five-skill completeness and learning evidence; prerequisites: SC-T127 |

### Retained parent acceptance coverage

- **AC1** — B2 coverage/volume satisfies the M0 checklist with qualified editorial evidence; no official certification claim.
  Accountable children: [SC-T116](tickets/SC-T116.md), [SC-T128](tickets/SC-T128.md). All applicable inherited constraints remain mandatory across the group.
- **AC2** — Published required lessons/assets work offline under documented local-installation preconditions; no key/cloud generation needed for core completion.
  Accountable children: [SC-T127](tickets/SC-T127.md). All applicable inherited constraints remain mandatory across the group.
- **AC3** — Available-level bypass is preserved; historical attempts and progression survive compatible content updates.
  Accountable children: [SC-T127](tickets/SC-T127.md). All applicable inherited constraints remain mandatory across the group.
- **AC4** — Applicable QA-29–QA-37, device checks and learner evidence are recorded; unfinished content is labeled honestly.
  Accountable children: [SC-T128](tickets/SC-T128.md). All applicable inherited constraints remain mandatory across the group.

## SC-T033 · Complete reviewed C1 five-skill curriculum

Original scope and acceptance are retained verbatim in the parent file. Allocation below states which child carries each requirement; all group criteria still gate closure.

| Child | Outcome / dependency |
| --- | --- |
| [SC-T129](tickets/SC-T129.md) | Freeze C1 unit objective and publication manifest; prerequisites: SC-T006 |
| [SC-T130](tickets/SC-T130.md) | Author and review C1 topic: Strategy; prerequisites: SC-T129 |
| [SC-T131](tickets/SC-T131.md) | Author and review C1 topic: research; prerequisites: SC-T129 |
| [SC-T132](tickets/SC-T132.md) | Author and review C1 topic: organizational change; prerequisites: SC-T129 |
| [SC-T133](tickets/SC-T133.md) | Author and review C1 topic: complex problems; prerequisites: SC-T129 |
| [SC-T134](tickets/SC-T134.md) | Author and review C1 topic: policy; prerequisites: SC-T129 |
| [SC-T135](tickets/SC-T135.md) | Author and review C1 topic: sensitive workplace discussions; prerequisites: SC-T129 |
| [SC-T136](tickets/SC-T136.md) | Author and review C1 topic: specialist debates; prerequisites: SC-T129 |
| [SC-T137](tickets/SC-T137.md) | Author and review C1 topic: cross-cultural communication; prerequisites: SC-T129 |
| [SC-T138](tickets/SC-T138.md) | Integrate reviewed C1 packs without changing learner history; prerequisites: SC-T130, SC-T131, SC-T132, SC-T133, SC-T134, SC-T135, SC-T136, SC-T137, SC-T019, SC-T020, SC-T032 |
| [SC-T139](tickets/SC-T139.md) | Accept C1 five-skill completeness and learning evidence; prerequisites: SC-T138 |

### Retained parent acceptance coverage

- **AC1** — C1 coverage/volume satisfies the M0 checklist with qualified editorial evidence; no official certification claim.
  Accountable children: [SC-T129](tickets/SC-T129.md), [SC-T139](tickets/SC-T139.md). All applicable inherited constraints remain mandatory across the group.
- **AC2** — Published required lessons/assets work offline under documented local-installation preconditions; no key/cloud generation needed for core completion.
  Accountable children: [SC-T138](tickets/SC-T138.md). All applicable inherited constraints remain mandatory across the group.
- **AC3** — Available-level bypass is preserved; historical attempts and progression survive compatible content updates.
  Accountable children: [SC-T138](tickets/SC-T138.md). All applicable inherited constraints remain mandatory across the group.
- **AC4** — Applicable QA-29–QA-37, device checks and learner evidence are recorded; unfinished content is labeled honestly.
  Accountable children: [SC-T139](tickets/SC-T139.md). All applicable inherited constraints remain mandatory across the group.

## SC-T034 · Complete reviewed C2 five-skill curriculum

Original scope and acceptance are retained verbatim in the parent file. Allocation below states which child carries each requirement; all group criteria still gate closure.

| Child | Outcome / dependency |
| --- | --- |
| [SC-T140](tickets/SC-T140.md) | Freeze C2 unit objective and publication manifest; prerequisites: SC-T006 |
| [SC-T141](tickets/SC-T141.md) | Author and review C2 topic: Abstract ideas; prerequisites: SC-T140 |
| [SC-T142](tickets/SC-T142.md) | Author and review C2 topic: competing interpretations; prerequisites: SC-T140 |
| [SC-T143](tickets/SC-T143.md) | Author and review C2 topic: sophisticated debate; prerequisites: SC-T140 |
| [SC-T144](tickets/SC-T144.md) | Author and review C2 topic: cultural references; prerequisites: SC-T140 |
| [SC-T145](tickets/SC-T145.md) | Author and review C2 topic: complex multidisciplinary problems; prerequisites: SC-T140 |
| [SC-T146](tickets/SC-T146.md) | Integrate reviewed C2 packs without changing learner history; prerequisites: SC-T141, SC-T142, SC-T143, SC-T144, SC-T145, SC-T019, SC-T020, SC-T033 |
| [SC-T147](tickets/SC-T147.md) | Accept C2 five-skill completeness and learning evidence; prerequisites: SC-T146 |

### Retained parent acceptance coverage

- **AC1** — C2 coverage/volume satisfies the M0 checklist with qualified editorial evidence; no official certification claim.
  Accountable children: [SC-T140](tickets/SC-T140.md), [SC-T147](tickets/SC-T147.md). All applicable inherited constraints remain mandatory across the group.
- **AC2** — Published required lessons/assets work offline under documented local-installation preconditions; no key/cloud generation needed for core completion.
  Accountable children: [SC-T146](tickets/SC-T146.md). All applicable inherited constraints remain mandatory across the group.
- **AC3** — Available-level bypass is preserved; historical attempts and progression survive compatible content updates.
  Accountable children: [SC-T146](tickets/SC-T146.md). All applicable inherited constraints remain mandatory across the group.
- **AC4** — Applicable QA-29–QA-37, device checks and learner evidence are recorded; unfinished content is labeled honestly.
  Accountable children: [SC-T147](tickets/SC-T147.md). All applicable inherited constraints remain mandatory across the group.

## SC-T035 · Deliver interview business and expanded speaking coverage

Original scope and acceptance are retained verbatim in the parent file. Allocation below states which child carries each requirement; all group criteria still gate closure.

| Child | Outcome / dependency |
| --- | --- |
| [SC-T148](tickets/SC-T148.md) | Define conversation interview turn and workplace contracts; prerequisites: SC-T028, SC-T006 |
| [SC-T149](tickets/SC-T149.md) | Author reviewed workplace communication and interview scenarios; prerequisites: SC-T148 |
| [SC-T150](tickets/SC-T150.md) | Deliver explicit text or recorded-turn conversation; prerequisites: SC-T148, SC-T149, SC-T017 |
| [SC-T151](tickets/SC-T151.md) | Deliver response-dependent interview follow-ups and retry; prerequisites: SC-T150 |
| [SC-T152](tickets/SC-T152.md) | Validate workplace and conversational practice boundaries; prerequisites: SC-T151 |
| [SC-T153](tickets/SC-T153.md) | Record later realtime feasibility and release decision; prerequisites: SC-T017 |

### Retained parent acceptance coverage

- **AC1** — Decompose independent Speech Lab conversation and interview scope under CP-QA04–08: actual back-and-forth replies, response-dependent interview follow-ups, feedback/retry, configurable role/type and factual accuracy. Select supported text/recorded turn modality and release inclusion before delivery claims; record future realtime streaming/turn-taking/interruption investigation separately after the first recorded proof. Define authorization/context/cost/cancel/retry/retention per turn/session before enabling requests; a single monologue correction is not conversation or interactive interviewing.
  Accountable children: [SC-T148](tickets/SC-T148.md), [SC-T150](tickets/SC-T150.md), [SC-T151](tickets/SC-T151.md), [SC-T152](tickets/SC-T152.md), [SC-T153](tickets/SC-T153.md). All applicable inherited constraints remain mandatory across the group.
- **AC2** — Map Tiger Business Professional method/activity packs and reviewed workplace learning criteria to shared curriculum under SC-T044; include audience/purpose, grounded facts, next action and realistic follow-up. No invented accomplishments or mandatory framework labels. Reuse recorded/quiet practice; current scope does not assume realtime conversation.
  Accountable children: [SC-T149](tickets/SC-T149.md), [SC-T152](tickets/SC-T152.md). All applicable inherited constraints remain mandatory across the group.
- **AC3** — Required interview/business coverage passes curriculum and learner review, with offline instruction/self-review.
  Accountable children: [SC-T149](tickets/SC-T149.md), [SC-T152](tickets/SC-T152.md). All applicable inherited constraints remain mandatory across the group.
- **AC4** — Feedback helps express actual experience; no invented employment facts or unsupported speech scores.
  Accountable children: [SC-T151](tickets/SC-T151.md), [SC-T152](tickets/SC-T152.md). All applicable inherited constraints remain mandatory across the group.

## SC-T036 · Deliver communication and articulation practice

Original scope and acceptance are retained verbatim in the parent file. Allocation below states which child carries each requirement; all group criteria still gate closure.

| Child | Outcome / dependency |
| --- | --- |
| [SC-T154](tickets/SC-T154.md) | Freeze communication and articulation teaching subsets; prerequisites: SC-T028 |
| [SC-T155](tickets/SC-T155.md) | Author reviewed organization listening and interaction drills; prerequisites: SC-T154, SC-T006 |
| [SC-T156](tickets/SC-T156.md) | Author reviewed articulation and delivery reference drills; prerequisites: SC-T154, SC-T006 |
| [SC-T157](tickets/SC-T157.md) | Deliver shared offline communication and articulation practice; prerequisites: SC-T155, SC-T156, SC-T021 |
| [SC-T158](tickets/SC-T158.md) | Validate the audio assessment boundary before sound feedback; prerequisites: SC-T156, SC-T003 |
| [SC-T159](tickets/SC-T159.md) | Deliver supported focused communication feedback; prerequisites: SC-T157, SC-T158, SC-T014, SC-T012 |
| [SC-T160](tickets/SC-T160.md) | Validate communication articulation and fresh-task evidence; prerequisites: SC-T159 |

### Retained parent acceptance coverage

- **AC1** — Map Fox Journalist, Parrot Speaker and Creative Writer methods to reviewed communication/articulation/storytelling packs under SC-T044. Separate source fidelity, audio delivery and written/unaided spoken narrative evidence; label fiction and preserve personal facts. Speaker precision still requires validated audio capability; no full-role delivery claim from a mascot/tone change.
  Accountable children: [SC-T155](tickets/SC-T155.md), [SC-T156](tickets/SC-T156.md), [SC-T159](tickets/SC-T159.md), [SC-T160](tickets/SC-T160.md). All applicable inherited constraints remain mandatory across the group.
- **AC2** — QA-20–QA-28 and QA-43–QA-47 pass for included modes; shared entry points cannot duplicate progress/rewards.
  Accountable children: [SC-T157](tickets/SC-T157.md), [SC-T159](tickets/SC-T159.md), [SC-T160](tickets/SC-T160.md). All applicable inherited constraints remain mandatory across the group.
- **AC3** — Transcript-only feedback cannot infer vocal delivery/confidence; no clinical or body-language scoring.
  Accountable children: [SC-T158](tickets/SC-T158.md), [SC-T159](tickets/SC-T159.md), [SC-T160](tickets/SC-T160.md). All applicable inherited constraints remain mandatory across the group.

## SC-T037 · Generate validated practice with offline fallbacks

Original scope and acceptance are retained verbatim in the parent file. Allocation below states which child carries each requirement; all group criteria still gate closure.

| Child | Outcome / dependency |
| --- | --- |
| [SC-T161](tickets/SC-T161.md) | Define bounded generation validation and reporting policy; prerequisites: SC-T028, SC-T003 |
| [SC-T162](tickets/SC-T162.md) | Generate and validate one explicit practice request safely; prerequisites: SC-T161, SC-T014 |
| [SC-T163](tickets/SC-T163.md) | Reuse compatible variants without resetting learning identities; prerequisites: SC-T162 |
| [SC-T164](tickets/SC-T164.md) | Record and resolve incorrect-activity reports locally; prerequisites: SC-T163 |

### Retained parent acceptance coverage

- **AC1** — QA-13–QA-19 and QA-51 pass; invalid generation falls back without losing work or automatic billable retry.
  Accountable children: [SC-T162](tickets/SC-T162.md), [SC-T163](tickets/SC-T163.md), [SC-T164](tickets/SC-T164.md). All applicable inherited constraints remain mandatory across the group.
- **AC2** — Novel wording cannot change objective, level, card identity, scheduler or assessment comparability.
  Accountable children: [SC-T161](tickets/SC-T161.md), [SC-T163](tickets/SC-T163.md). All applicable inherited constraints remain mandatory across the group.

## SC-T038 · Deliver Word of Day and custom vocabulary topics

Original scope and acceptance are retained verbatim in the parent file. Allocation below states which child carries each requirement; all group criteria still gate closure.

| Child | Outcome / dependency |
| --- | --- |
| [SC-T165](tickets/SC-T165.md) | Create and edit custom vocabulary topics offline; prerequisites: SC-T023 |
| [SC-T166](tickets/SC-T166.md) | Preview select and enroll generated topic vocabulary; prerequisites: SC-T165, SC-T037 |
| [SC-T167](tickets/SC-T167.md) | Deliver a stable Word of the Day with offline fallback; prerequisites: SC-T166, SC-T055 |

### Retained parent acceptance coverage

- **AC1** — Save and Add to review remain separate; optional speech and sense identity rules persist.
  Accountable children: [SC-T165](tickets/SC-T165.md), [SC-T166](tickets/SC-T166.md). All applicable inherited constraints remain mandatory across the group.
- **AC2** — Offline manual creation works; invalid generated content cannot silently enroll cards or expose answers early.
  Accountable children: [SC-T165](tickets/SC-T165.md), [SC-T166](tickets/SC-T166.md), [SC-T167](tickets/SC-T167.md). All applicable inherited constraints remain mandatory across the group.

## SC-T039 · Deliver supporting resource bookmarks

Original scope and acceptance are retained verbatim in the parent file. Allocation below states which child carries each requirement; all group criteria still gate closure.

| Child | Outcome / dependency |
| --- | --- |
| [SC-T168](tickets/SC-T168.md) | Decide resource destinations metadata and thumbnail rights; prerequisites: SC-T028 |
| [SC-T169](tickets/SC-T169.md) | Save curated and personal resource cards safely; prerequisites: SC-T168 |

### Retained parent acceptance coverage

- **AC1** — QA-11 passes with validated destinations and clear external navigation.
  Accountable children: [SC-T168](tickets/SC-T168.md), [SC-T169](tickets/SC-T169.md). All applicable inherited constraints remain mandatory across the group.
- **AC2** — Resource failure does not block offline lesson completion; no unapproved embedding/content extraction.
  Accountable children: [SC-T169](tickets/SC-T169.md). All applicable inherited constraints remain mandatory across the group.

## SC-T040 · Audit full release curriculum and capability coverage

Original scope and acceptance are retained verbatim in the parent file. Allocation below states which child carries each requirement; all group criteria still gate closure.

| Child | Outcome / dependency |
| --- | --- |
| [SC-T170](tickets/SC-T170.md) | Audit complete level and foundation publication coverage; prerequisites: SC-T034, SC-T006 |
| [SC-T171](tickets/SC-T171.md) | Audit all-seven trainer workplace and practice capability claims; prerequisites: SC-T035, SC-T036, SC-T037, SC-T038, SC-T039, SC-T044 |
| [SC-T172](tickets/SC-T172.md) | Audit all award families evidence states and unchanged economics; prerequisites: SC-T170, SC-T171, SC-T024, SC-T025 |

### Retained parent acceptance coverage

- **AC1** — Audit all 68 adopted families and release-included instances against the exact visual mapping and AV-QA01–08/RW-QA evidence: no unmapped award, wrong category shell, collectible checkpoint substitution or currency-as-skill seal. Production asset/device evidence, rather than the accepted concept board alone, closes implementation coverage.
  Accountable children: [SC-T172](tickets/SC-T172.md). All applicable inherited constraints remain mandatory across the group.
- **AC2** — Audit each release-included AW family and parameterized instance against reviewed rule/content/evidence/capability availability and no duplicate economics. All 68 families and listed initial tiers are adopted; required domain coverage and any later owner-approved changes/exclusions must be recorded before claiming an implemented complete badge system.
  Accountable children: [SC-T172](tickets/SC-T172.md). All applicable inherited constraints remain mandatory across the group.
- **AC3** — Audit course/coach invariance, independently labeled conversation/interview availability and reviewed reward/badge/motion decisions using applicable CP/RW checks. Deferred live capability is not delivered by turn-based practice; adopted artwork direction/timing/catalog is not implementation evidence.
  Accountable children: [SC-T171](tickets/SC-T171.md), [SC-T172](tickets/SC-T172.md). All applicable inherited constraints remain mandatory across the group.
- **AC4** — Require SC-T044 all-seven pack/coverage evidence and applicable TR-QA01–TR-QA10 content/device/learner checks before complete-release acceptance. All seven methods/activities must be represented with reviewed level-appropriate volume; unavailable packs, unresolved seventh-character design or missing specialty evidence remain explicit gaps.
  Accountable children: [SC-T171](tickets/SC-T171.md). All applicable inherited constraints remain mandatory across the group.
- **AC5** — Audit all required English Foundations topics EF-01–EF-05 across delivered levels and their child-objective/CEFR lesson mapping. Require actual qualified review, available content/assets and applicable EF-QA evidence for each required location; planned entries or terminology quizzes cannot close coverage or prove CEFR proficiency.
  Accountable children: [SC-T170](tickets/SC-T170.md). All applicable inherited constraints remain mandatory across the group.
- **AC6** — Required A1–C2 and interview/business coverage passes; internal proofs are not substituted for public scope.
  Accountable children: [SC-T170](tickets/SC-T170.md), [SC-T171](tickets/SC-T171.md). All applicable inherited constraints remain mandatory across the group.
- **AC7** — Any optional release deferral is explicit and retains backlog tracking; scope changes require owner agreement.
  Accountable children: [SC-T170](tickets/SC-T170.md), [SC-T171](tickets/SC-T171.md). All applicable inherited constraints remain mandatory across the group.

## SC-T041 · Verify release reliability privacy and accessibility

Original scope and acceptance are retained verbatim in the parent file. Allocation below states which child carries each requirement; all group criteria still gate closure.

| Child | Outcome / dependency |
| --- | --- |
| [SC-T173](tickets/SC-T173.md) | Freeze release regression matrix and measurable budgets; prerequisites: SC-T040 |
| [SC-T174](tickets/SC-T174.md) | Verify persistence upgrades retention export and reset recovery; prerequisites: SC-T173, SC-T178 |
| [SC-T175](tickets/SC-T175.md) | Verify all supported native appearance and accessibility journeys; prerequisites: SC-T173 |
| [SC-T176](tickets/SC-T176.md) | Verify credential cost and network failure containment; prerequisites: SC-T173 |

### Retained parent acceptance coverage

- **AC1** — Required regression has identified builds and sanitized evidence; unresolved blockers prevent release.
  Accountable children: [SC-T173](tickets/SC-T173.md), [SC-T174](tickets/SC-T174.md), [SC-T175](tickets/SC-T175.md), [SC-T176](tickets/SC-T176.md). All applicable inherited constraints remain mandatory across the group.
- **AC2** — Credentials excluded from export/backup; export/restore and recoverable deletion semantics match agreed contracts.
  Accountable children: [SC-T174](tickets/SC-T174.md). All applicable inherited constraints remain mandatory across the group.
- **AC3** — Owner/device/provider/content acceptance are separately recorded; unsupported assessments remain unavailable.
  Accountable children: [SC-T173](tickets/SC-T173.md), [SC-T175](tickets/SC-T175.md), [SC-T176](tickets/SC-T176.md). All applicable inherited constraints remain mandatory across the group.

## SC-T042 · Prepare distribution recovery and release handoff

Original scope and acceptance are retained verbatim in the parent file. Allocation below states which child carries each requirement; all group criteria still gate closure.

| Child | Outcome / dependency |
| --- | --- |
| [SC-T177](tickets/SC-T177.md) | Define selected export and any explicit restore boundary; prerequisites: SC-T004, SC-T028 |
| [SC-T178](tickets/SC-T178.md) | Export only explicitly selected retained learner data; prerequisites: SC-T177, SC-T015 |
| [SC-T179](tickets/SC-T179.md) | Select distribution signing identity and release recovery procedure; prerequisites: SC-T040 |
| [SC-T180](tickets/SC-T180.md) | Prepare a repeatable signed release candidate; prerequisites: SC-T041, SC-T179 |
| [SC-T181](tickets/SC-T181.md) | Write verified release and recovery handoff; prerequisites: SC-T180 |

### Retained parent acceptance coverage

- **AC1** — Repeatable release build and chosen distribution preparation checks pass.
  Accountable children: [SC-T180](tickets/SC-T180.md), [SC-T179](tickets/SC-T179.md). All applicable inherited constraints remain mandatory across the group.
- **AC2** — Release documentation names evidence and remaining limitations; no publishing or production change follows from ticket creation alone.
  Accountable children: [SC-T181](tickets/SC-T181.md), [SC-T179](tickets/SC-T179.md). All applicable inherited constraints remain mandatory across the group.

## SC-T044 · Deliver and validate seven specialized trainer packs

Original scope and acceptance are retained verbatim in the parent file. Allocation below states which child carries each requirement; all group criteria still gate closure.

| Child | Outcome / dependency |
| --- | --- |
| [SC-T182](tickets/SC-T182.md) | Freeze all-seven role objective and level coverage matrix; prerequisites: SC-T028, SC-T006 |
| [SC-T183](tickets/SC-T183.md) | Resolve Creative Writer character and optional voice design; prerequisites: SC-T182, SC-T007, SC-T158 |
| [SC-T184](tickets/SC-T184.md) | Run explicit specialist packs with safe switch and course return; prerequisites: SC-T182, SC-T021 |
| [SC-T185](tickets/SC-T185.md) | Author and review Teacher specialist pack coverage; prerequisites: SC-T182 |
| [SC-T186](tickets/SC-T186.md) | Author and review Grammarian specialist pack coverage; prerequisites: SC-T182 |
| [SC-T187](tickets/SC-T187.md) | Author and review Librarian specialist pack coverage; prerequisites: SC-T182 |
| [SC-T188](tickets/SC-T188.md) | Author and review Journalist specialist pack coverage; prerequisites: SC-T182, SC-T155 |
| [SC-T189](tickets/SC-T189.md) | Author and review Business Professional specialist pack coverage; prerequisites: SC-T182, SC-T149 |
| [SC-T190](tickets/SC-T190.md) | Author and review Speaker specialist pack coverage; prerequisites: SC-T182, SC-T156, SC-T158 |
| [SC-T191](tickets/SC-T191.md) | Author and review Creative Writer specialist pack coverage; prerequisites: SC-T182, SC-T183, SC-T155 |
| [SC-T192](tickets/SC-T192.md) | Validate all-seven specialist methods and retained learning; prerequisites: SC-T184, SC-T185, SC-T186, SC-T187, SC-T188, SC-T189, SC-T190, SC-T191 |

### Retained parent acceptance coverage

- **AC1** — Implement role-specific pedagogy only in explicit specialist context. All seven presenting coaches must preserve reviewed CEFR training under CP-QA01–03/08; optional practice cannot change course progression or silently replace required activities. Distinguish true method changes from presentation-only switching.
  Accountable children: [SC-T184](tickets/SC-T184.md). All applicable inherited constraints remain mandatory across the group.
- **AC2** — All seven roles have reviewed published packs with their specified method, activities, feedback and role-specific learning criteria; level-by-role volume is explicitly agreed and gaps visible.
  Accountable children: [SC-T182](tickets/SC-T182.md), [SC-T185](tickets/SC-T185.md), [SC-T186](tickets/SC-T186.md), [SC-T187](tickets/SC-T187.md), [SC-T188](tickets/SC-T188.md), [SC-T189](tickets/SC-T189.md), [SC-T190](tickets/SC-T190.md), [SC-T191](tickets/SC-T191.md). All applicable inherited constraints remain mandatory across the group.
- **AC3** — TR-QA01–TR-QA10 executed for applicable packs, with all seven specialty checks and delayed evidence represented at closure; partial availability cannot satisfy complete trainer coverage.
  Accountable children: [SC-T192](tickets/SC-T192.md). All applicable inherited constraints remain mandatory across the group.
- **AC4** — Shared progress/attempt provenance, switching, independent assessment and no-duplicate rewards work; fiction/personal facts and modality evidence remain separate.
  Accountable children: [SC-T184](tickets/SC-T184.md), [SC-T192](tickets/SC-T192.md). All applicable inherited constraints remain mandatory across the group.
- **AC5** — Content/functional/feedback/privacy defects are resolved/retested; actual learner results, failures and limitations are reported without claiming efficacy from completion.
  Accountable children: [SC-T192](tickets/SC-T192.md). All applicable inherited constraints remain mandatory across the group.
- **AC6** — SC-T040 release audit includes actual pack/content/device/learner evidence; unresolved visual/voice choices have an explicit completion decision, not invented approval.
  Accountable children: [SC-T183](tickets/SC-T183.md), [SC-T192](tickets/SC-T192.md). All applicable inherited constraints remain mandatory across the group.
## Completeness checks

Every original group has children; every original acceptance bullet appears above; every existing level topic has a named content child. Level decision children allocate all grammar/EF, vocabulary, pronunciation/communication and workplace requirements across those topic packs and reviewed assessments before publication. Role pack children inherit the full role-specific method/learning contract; all-seven acceptance audits coverage. Release groups explicitly audit all original public requirements rather than using ticket counts as evidence.

No parent marked done from decomposition. Child statuses/readiness must change only with actual decisions/evidence. Provider/account/device/editorial/learner results remain NOT_RUN.

## Decomposition verification — 2026-10-21

PASS: 192 required ticket records, 147 pending children under all 22 retained groups; reciprocal parent links and exact original acceptance preserved; explicit coverage allocation; roadmap/tracker status/dependencies; local Markdown targets; execution graph and combined group-closure graph acyclic. All 57 existing A1–C2 outline topics have a bounded content/reuse child; reviewed depth/volume still gated by decision manifests. External preset validation passed 30 checks. [Machine-readable evidence](decomposition-verification.json). No app/Git created or implementation/content/qualified review/provider/device/learner execution performed.

## Curriculum preparation and publication dependencies — clarified 2026-10-21

A1–C2 manifest decision children SC-T073/089/103/116/129/140 require SC-T006 for their reviewed closure, rather than completion of an earlier runtime delivery group. Draft inventory, source research and proposed mappings may be prepared while review is pending, but cannot be labeled reviewed, close the decision ticket or authorize dependent author-and-review tickets. Those topic children still require their own frozen reviewed manifest; no exact volume or placement is approved by decomposition.

Reviewed topic preparation may overlap earlier-level engineering and learner acceptance. The corresponding integration children SC-T087/101/114/127/138/146 retain the original upstream delivery gate (SC-T028/029/030/031/032/033 respectively), in addition to their reviewed-topic and runtime prerequisites. Thus publication/delivery and parent closure retain the original sequence and all original acceptance criteria. Parent dependencies are closure gates, not prerequisites automatically inherited by every preparation child. Early inspection/staging is not publication or integration acceptance. No learner level-lock is introduced.

On 2026-10-21 the owner approved SC-T006 because a qualified educator review could not be performed. The shared checklist is accepted for that gate and is not a CEFR certificate. Each later batch still needs its own completeness record. This clarification changes scheduling edges only; it approves no content, new feature, scope change or application development.


## Consolidated full-plan readiness audit — 2026-10-21

[The complete review](readiness-review.md) supersedes earlier next-review/setup-review recommendations. All 192 records and adopted scope were checked together. Corrected stale summaries, clarified early completion versus later economics, staged future AW instance binding, assigned typed-feedback/word-finding/optional-voice ownership, consolidated remaining decisions and preserved signed-artifact evidence. Added explicit policy/capability edges SC-T167→SC-T055 and SC-T183→SC-T158; SC-T159 explicitly references SC-T012. No tickets added or marked delivered; 184 pending, one blocked and seven done. No app implementation, provider calls, publication, Git initialization or expanded product scope. No further general planning review is required before owner-authorized SC-T008 kickoff; later choices and evidence gate only their named work. Verification details are in readiness-audit.json.
