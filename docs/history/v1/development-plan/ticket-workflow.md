# Ticket workflow

> Current execution: owner-authorized [first-loop stabilization](stabilization-2026-10-22.md), 2026-10-22. Earlier dated authorization states below are historical where superseded. Native implementation exists; exact source and current evidence govern implementation claims.

## Hierarchy and ownership

Use milestones → existing SC-000–SC-016 feature groups → SC-Txxx tickets. A ticket may contribute to several parent items. Keep stable IDs and filenames; allocate the next unused SC-T number for follow-up children. Do not renumber when delivery order changes. Role ownership does not start delegation.

[Milestones and ticket index](milestones.md) owns milestone membership/dependencies. [Progress tracker](progress.md) is the consolidated monitoring view; ticket files own detailed status/readiness and evidence. Update ticket files, tracker rows/counts and review date together when progress changes; align milestone/parent status when its outcome changes. [Development plan](development-plan.md) retains feature status and approved product sequence. Product/technical/contracts remain authoritative for requirements; tickets link rather than override them.

## Scope and readiness

M0–M3 have detailed ticket specifications. The 22 former M4–M13 outlines are now delivery groups with detailed child tickets; see decomposition.md. Assign feature-sized delivery work through the [grouped delivery backlog](delivery-backlog/README.md); implement it in reviewable changes. The original SC-T delivery-group rows remain closure checks, not additional coding assignments. A detailed specification is not automatically ready. Resolve its dependencies and relevant design/contract choices first, identify actual source paths and executable checks, and record readiness. Broad outlines cannot be assigned as one implementation change.

Statuses are pending, in_progress, awaiting_testing, done and blocked. `awaiting_testing` means the ticket implementation is complete and only testing/acceptance evidence remains; it is not done and does not satisfy a dependency requiring done. Verification-only tickets waiting to execute may use it with that distinction explicit. `in_progress` means implementation/content/decision work remains. A discovered defect returns the affected ticket to in_progress. Missing code, content or product decisions must not be hidden in awaiting_testing. Readiness is separate: Ready for planning, Awaiting dependencies, Decomposed — child delivery pending, or Ready for implementation; recorded scoped setup/review/authorization holds remain explicit. Missing owner decisions or qualified review remain explicit blockers; elapsed time and documentation approval do not supply those decisions. Independent preparation can proceed when its own prerequisites are satisfied.

Each executable ticket should deliver one observable result across the necessary layers. Split when outcomes, prerequisites, unresolved decisions or acceptance demonstrations differ. Do not split merely by screen, UI/data layer or number of files. Curriculum authoring and implementation have separate evidence and owners. Later level outlines split into bounded unit/topic batches plus engineering tickets only for new behavior.

## Ticket sections

1. Identity: ID, milestone, parent work, type, owner, status and readiness.
2. Outcome: concrete learner or engineering result and purpose.
3. Sources and dependencies: canonical intent, contracts/design references and prerequisite tickets.
4. Scope and decisions: included work, exclusions and unresolved choices.
5. Required behavior and constraints: happy path plus applicable offline/error/restart/privacy/accessibility behavior.
6. Implementation guidance and affected areas: known paths and boundaries; distinguish suggestions from requirements.
7. Acceptance criteria: observable pass/fail outcomes, including relevant content review.
8. Verification: meaningful checks and required fixture/device/provider/owner evidence.
9. Completion record: actual artifacts, results, limitations and tracker updates.

Scale detail to risk and scope. Do not duplicate every system rule in every ticket or invent commands/source paths before tooling exists.

## Closure and evidence

A ticket is done only when its own acceptance and checks are satisfied and the completion record links actual evidence. Document-only decision tickets do not claim runtime behavior. A milestone closes only when its required outcomes are demonstrated, associated blocking defects are resolved and relevant owner/content/device/provider acceptance is recorded. Parent SC items close only when their whole adopted scope is delivered, not when one child completes.

Use NOT_RUN, PASS, FAIL or BLOCKED for checks; record build/device/OS/content/rubric/provider versions where applicable. Reuse the recorded-feedback evidence format for the speaking proof. Store sanitized execution evidence under docs/testing/evidence/ when it exists; no placeholder evidence proves execution. Never include secrets or private learner payloads.

Ticket creation authorizes planning artifacts, not automatic provider calls, secret/account changes, destructive operations, release publication or Git initialization. Follow existing project rules when those actions are reached.

## Current owner authorization — 2026-10-21

Documentation/ticket refinement and SC-T001 decision work are authorized. Application development is explicitly on hold until the owner says to start. Ready for planning/implementation and completed prerequisites are readiness evidence, not development authorization. Do not scaffold the app, initialize Git or make provider calls under this documentation task.

Design-input gates close with reviewed references and specified native behavior; implemented accessibility/device evidence closes under the affected delivery/acceptance tickets. Later curriculum completeness must be refined before the affected publication, while only the first-topic subset gates first-topic authoring. No acceptance requirement is dropped by staging it.

## Decomposed delivery groups — 2026-10-21

Parent status stays pending until every required child and original group acceptance is satisfied. Keep original parent prerequisites plus child membership as a roll-up closure condition; children depend on original prerequisites or sibling/cross-group outcomes, never their own parent. Track both execution and closure edges when checking for cycles. Counts include delivery groups and must not be interpreted as weighted product progress. Content decision manifests freeze exact IDs/volume/reviews before authoring; candidate topic names are not approved CEFR placements. Unknown real defects/new activity types receive evidence-backed follow-ups when discovered, not fabricated completion or speculative requirements.

## Curriculum preparation and publication dependencies — clarified 2026-10-21

A1–C2 manifest decision children SC-T073/089/103/116/129/140 require SC-T006 for their reviewed closure, rather than completion of an earlier runtime delivery group. Draft inventory, source research and proposed mappings may be prepared while review is pending, but cannot be labeled reviewed, close the decision ticket or authorize dependent author-and-review tickets. Those topic children still require their own frozen reviewed manifest; no exact volume or placement is approved by decomposition.

Reviewed topic preparation may overlap earlier-level engineering and learner acceptance. The corresponding integration children SC-T087/101/114/127/138/146 retain the original upstream delivery gate (SC-T028/029/030/031/032/033 respectively), in addition to their reviewed-topic and runtime prerequisites. Thus publication/delivery and parent closure retain the original sequence and all original acceptance criteria. Parent dependencies are closure gates, not prerequisites automatically inherited by every preparation child. Early inspection/staging is not publication or integration acceptance. No learner level-lock is introduced.

On 2026-10-21 the owner approved SC-T006 because a qualified educator review could not be performed. The shared checklist is accepted for that gate and is not a CEFR certificate. Each later batch still needs its own completeness record. This clarification changes scheduling edges only; it approves no content, new feature, scope change or application development.


## Consolidated readiness baseline — 2026-10-21

Use [the full readiness review](readiness-review.md) for approved decisions, complete remaining-choice ownership, stage gates and verification. Planning is sufficient for the first engineering slice; no additional general readiness/setup-review round is required. Setup is execution under SC-T008 after the owner starts development. Later choices gate only affected work. Development remains on hold; no app, provider call, Git initialization or publication is authorized by this review.

## Automation execution sequence — 2026-10-21

Use the [grouped delivery backlog](delivery-backlog/README.md) for assignment scope. Use [the ordered ticket runbook](execution-sequence.md) and its linked machine-readable queue for underlying prerequisites and acceptance gates. Start SC-T008 → SC-T009 → SC-T010 → SC-T011 after explicit owner development authorization. Refresh exact status/dependencies, require actual acceptance evidence and treat delivery groups as closure audits. Skip completed baseline work; pause affected branches for real external/owner/reviewer/learner evidence and continue only eligible authorized work. No new general readiness review is required. No automation or app implementation is started by adding this plan.

## Implementation kickoff — 2026-10-21

Owner instructed: “Start implementation based on the sequence we derive.” This authorizes serial bounded implementation under the adopted execution sequence and supersedes earlier development-hold statements. SC-T008 is active. Git initialization, live provider calls, account changes and publication retain their separate gates. Current status/evidence is in the [progress tracker](progress.md) and exact ticket; the queue is a dispatch view, not an unattended scheduler.


## Continuous execution authorization — 2026-10-21

Owner authorized continuous ticket execution in sequence, asking only when personal intervention/effort or a required decision is needed. Continue eligible work autonomously; keep default serial ownership, exact prerequisites and acceptance evidence. This does not create a scheduler or authorize unrelated external actions, destructive operations or publishing. SC-T008 completed; SC-T009 active.


## Feature-sized assignments — 2026-10-23

The owner requested larger tickets organized around usable features. [The delivery backlog](delivery-backlog/README.md) is the assignment view: 20 active-scope SC-D delivery tickets plus one completed foundation record. Existing SC-T IDs remain stable requirement, dependency and evidence records. This supersedes the earlier default of assigning one child at a time; it does not remove prerequisite, decision or acceptance gates. Work through eligible requirements within a delivery ticket in coherent implementation batches, including its UI, persistence and relevant checks. Finish the eligible batch before returning for another tiny assignment.

Implementation-complete work with only testing/acceptance remaining is `awaiting_testing`; missing code, content or decisions remains unfinished. Group summaries distinguish partial implementation from actual active ownership. Completing a delivery ticket requires its mapped requirements and all original roll-up acceptance, including cross-group requirements. Do not create new all-or-nothing barriers between whole delivery tickets. The older queue remains the prerequisite index, not an instruction to dispatch each child separately. Regrouping changes no existing SC-T status and starts no implementation or agent assignment.
