# Development Plan

> Current readiness and remaining-choice authority: [consolidated readiness review](readiness-review.md). Dated earlier pending statements are historical where superseded by recorded approvals; they are not additional start gates.
> Status: IN_PROGRESS
> Adopted execution sequence; implementation started with SC-T008 on 2026-10-21. No delivery date is committed.

Implementation tickets were created at owner request on 2026-10-17. Use the [milestone roadmap and ticket index](milestones.md) and [ticket workflow](ticket-workflow.md). M0–M3 contain detailed specifications; all 22 later outlines now retain delivery-group IDs with bounded child tickets in decomposition.md. At initial creation all tickets remained pending; ticket creation does not close architecture/design gates or begin application implementation. Existing SC items below retain their feature-level status.

Use the [progress tracker](progress.md) for the consolidated ticket table, milestone counts, readiness, next actions and evidence.

Statuses: pending, in_progress, awaiting_testing, done, blocked. Awaiting testing distinguishes completed implementation from accepted delivery; exact child tickets own the status. A completed document adoption does not mean the product is implemented. Roles below indicate responsibility, not active delegation.

| ID | Work and owner | Status | Dependencies | Acceptance and verification |
| --- | --- | --- | --- | --- |
| SC-000 | Adopt intent into docs — Documentation | done | Owner brainstorm | Reviewed 2026-10-15: project pages aligned; proposals/open choices labeled; 14 preset checks passed without warnings; relative Markdown links checked in 27 files with no broken targets. Application implementation remains pending. |
| SC-001 | First-slice scope and defaults — Software Engineer with owner | in_progress | SC-000 | Apply adopted INTRO-01 minimum pack/core completion and initial pilot criteria; settle remaining first-proof defaults, lesson packaging and broader release volume; see approved-recommendations.md |
| SC-002 | Architecture/provider investigation — Architect, Backend | pending | SC-001 | Evaluate Qwen/Alibaba Cloud Model Studio first (exact models/region unselected); compare app/audio/store/scheduler candidates; verify BYOK native-client API/terms compatibility and conditional service needs; define Keychain, learner billing, privacy and minimum OS; record approved decisions |
| SC-003 | Screen and accessibility design — Frontend | in_progress | SC-001 | Owner now requests one reusable Page 1 reference with foundations, components, page templates, main parts, speaking journey and AI usage recipes; remove Page 2 after verification. Desktop consolidation and Page 2 removal verified locally; 22 original frames/boards retained in seven sections, shared state labels/reflow corrected and reviewed. Cloud sync remains unverified. The 70-family inventory remains behavior/QA coverage, not a frame-per-state design requirement. Final visual/native/accessibility review remains pending. |
| SC-004 | Recorded-feedback technical spike — Software Engineer, Backend | in_progress | SC-002, SC-015 minimum credential path | Capture/replay; explicit online submission; validated response; offline/error/cancel behavior; microphone/device evidence |
| SC-005 | App foundation and offline state — Software Engineer | in_progress | SC-002, SC-003 | Approved structure, preference precedence, local persistence, restart/deletion tests and repeatable build |
| SC-006 | First speaking learning loop — Frontend, Backend | in_progress | SC-004, SC-005 | Intro → recording → focused afterward feedback/self-review → reduced-support retry → opt-in history; preserve assistance and baseline/practice/transfer identity; IL-02/IL-04/IL-05; SC-T043 evaluates learning |
| SC-007 | Vocabulary daily review — Software Engineer | in_progress | SC-005, scheduler decision | Meaning/production cards, typed sentences/optional speaking, honest ratings, Word of Day, custom-topic paths, shared lesson item/sense references and optional enrollment; define review-credit/deduplication policy |
| SC-008 | English Foundations and connected grammar curriculum — Software Engineer, SQA | in_progress | SC-005, content review, SC-014 A1 authoring gate | Short teaching interleaved with activities, offline practice, flexible speaking/feedback/review and embedded vocabulary; apply INTRO-01 core completion and bounded EF-01/02/03 subset; shared CEFR grammar objectives and focused/contextual Learn access; EF-AC01–EF-AC08 / EF-QA checks and QA-33–QA-37 |
| SC-009 | History and engagement — Software Engineer, SQA | in_progress | SC-006, SC-007 | Four comparison prompt formats; separate recognition/recall/use/retention/transfer with assistance and missing-evidence context; XP distinct from skill; IL-05/IL-09/IL-10 and reviewed achievement thresholds |
| SC-010 | Resources and speaking expansion — Frontend, Backend | in_progress | SC-006, SC-001 | Curated/personal YouTube cards; interview/spontaneous/everyday/pronunciation modes as prioritized; technical coaching optional |
| SC-011 | Beta readiness — SQA, Software Engineer, Documentation | pending | Approved release scope | Real-device/audio/accessibility/privacy checks, content review, cost/failure evaluation and documented deployment/recovery |
| SC-012 | Dynamic activity generation — Architect, Backend, Software Engineer, SQA | pending | SC-002, reviewed objectives/templates; before beta if included in release | Define constraints, structured generation/validation, reviewed fallbacks, compatible offline cache, stable card/attempt identity and assessment eligibility; execute QA-13–QA-19 for adopted modes |
| SC-013 | Communication/public-speaking track — Architect, Frontend, Software Engineer, SQA | in_progress | SC-001, reviewed framework content; SC-006 and SC-012 for online practice | Select framework/technique subset; shared Lessons/Speech Lab teaching and progress; original lessons/scaffolds; differentiated feedback; optional routine; offline self-review; comparable progress; QA-20–QA-28 for included capabilities |
| SC-014 | Level curriculum authoring and review — Documentation, Architect, SQA with qualified educator | in_progress | SC-001, curriculum format decision | Expand topic outline into mapped units/lessons; review INTRO-01 pack/rubric/initial thresholds and the SC-T043 expansion decision, then complete A1–C2 five-skill public-release coverage; review sources/rights, prerequisites and outcome assessments; QA-29–QA-32 for published content; define completeness and volume |
| SC-015 | BYOK configuration and credentials — Architect, Software Engineer, SQA | in_progress | SC-002 provider/transport decision; before online slice | Secure Keychain credential lifecycle, capability availability, billing disclosure, safe errors and no-key offline access; QA-38–QA-42 |
| SC-016 | Articulation Training — Frontend, Software Engineer, SQA | in_progress | SC-001, SC-006; reviewed references and capability validation; BYOK for cloud feedback | Select activity subset; reuse speech/vocabulary/communication components; distinct production/expression feedback; offline fallback and configurable drills; QA-43–QA-47 for release inclusion |

## Approved delivery sequence

The owner approved this incremental approach. Resolve scope/architecture/design prerequisites first; the numbered stages describe delivery order, not a promise to implement the whole backlog or a rigid ban on parallel preparation.

1. Prove the speaking loop: record, replay, explicitly request online feedback, retry and save history according to retention preferences (SC-004–SC-006, with required foundation). Verify offline self-review and failure recovery.
2. Build one complete A1 topic: connect reviewed teaching, grammar, embedded vocabulary, supported activities, speaking and review (a bounded subset of SC-007/SC-008/SC-014). Introductions is the approved first authoring target; minimum activity volume is now adopted in INTRO-01, with lesson packaging and remaining defaults tracked by SC-001. Apply [INTRO-01](../product-specification/introductions-learning-loop.md): reviewed minimum pack and rubric, concrete offline/quiet completion, optional independent baseline, focused feedback/retry and delayed unfamiliar tasks. SC-T043 runs the four-week owner pilot and records the educator/owner expansion decision before course expansion; see [IL-01–IL-10](../testing/introductions-learning-acceptance.md).
3. Make proven components reusable and expand to a small reviewed A1 course. Reuse activity types and versioned content; add new code only when a genuinely new behavior is needed. Define the course volume before claiming completeness.
4. Test with the owner and iterate on teaching quality, usefulness, accessibility and iPhone/iPad UI/UX. Begin owner feedback during earlier stages too; source/build checks alone do not close learner acceptance. Revisit issues before broader expansion.
5. Expand progressively: add reviewed topics, activity types and modes as the foundation proves useful. A2–C2 and interview/business coverage are required for the owner-selected public release; smaller stages are internal proofs. Other backlog coverage remains subject to scope decisions.

Each stage needs a bounded outcome, exclusions, relevant checks and learner evidence. All implementation remains pending. AI generation may assist practice once its constraints/validation are ready; it is not necessary to delay the first reviewed topic until every generation capability is complete.

## Development effort versus learning time

Published guided-learning hour estimates describe learner study, repetition and exposure, not unique lesson runtime to author or engineer. Do not estimate development by converting approximately 1,000 study hours into 1,000 hours of bespoke content or code. Actual engineering and authoring effort requires scoped activity types, content volume, integration work and quality gates; no duration estimate is committed here.

## Scope gates

SC-004 proves record-then-feedback first. Natural realtime conversation with streaming, turn-taking and interruption remains a later product backlog capability; provider/transport research and release timing are deferred. It is not the initial acceptance requirement. Owner UI/UX decisions now require a complete A1–C2 five-skill path plus interview/business communication for public release; exact completeness criteria remain open. Earlier speaking/one-topic stages are internal increments. Other languages, sync, accounts and embedded video remain deferred. All desired product capabilities remain in the backlog even when not selected for the first slice.

Do not estimate dates or mark implementation done without source and verification. Every implementation ticket should name usable outcome, exclusions, affected files, acceptance and checks. Update this table when owner-approved scope or verified status changes.

## Approved gap-review recommendations

Owner approved [learning and delivery defaults](approved-recommendations.md), including Qwen trial-based development evaluation. SC-001/SC-002 remain pending for concrete implementation contracts; documentation approval does not complete provider proof or app work. Apply QA-48–QA-52 to the corresponding delivered capabilities.

## Pre-ticket documentation preparation

Prepared the [Qwen research/proof report](../../../api/qwen-capability-report.md), [v1 feedback/transcript/persistence contracts](../../../contracts/recorded-feedback-v1.md) and [device/provider acceptance criteria](../../../testing/recorded-feedback-acceptance.md). Document preparation is complete for review; actual provider/device proof remains NOT_RUN and existing implementation work stays pending. The owner initially required UI/UX discussion before implementation-ticket creation. That discussion and ticket-structure review were followed by explicit authorization to create tickets on 2026-10-17; see the [milestone roadmap](milestones.md). Contracts alone still do not authorize runtime work or close outstanding decisions.

## UI/UX interview progress

[Owner decisions](../../../product-specification/ui-ux-design.md) are recorded; SC-003 is in progress, with final visual concepts and walkthrough acceptance pending. Implementation tickets are now recorded in the milestone roadmap; provider/device proof remains NOT_RUN.

An [editable Figma iPhone draft](../../../product-specification/figma-design-review.md) now exists. Typography/license, sync confirmation, requirement/state completeness and final owner acceptance remain pending; SC-003 stays in_progress.

The [screen/state inventory](../../../product-specification/ui-screen-state-inventory.md) now defines remaining Figma batches, source coverage and NOT_RUN walkthroughs. SC-003 remains in_progress; the milestone roadmap now records implementation tickets. A complete inventory is separate from completing its designs and acceptance.

## Learning acceptance adoption — 2026-10-19

At effectiveness adoption, all 43 implementation/decision/content/acceptance tickets remained pending; the specialized-trainer update below adds SC-T044. [SC-T043](tickets/SC-T043.md) adds the M3 first-topic learner gate. M3 now needs functional/content evidence and a recorded pilot/expansion decision; M4 preparation may overlap, while SC-T026 course expansion depends on SC-T043. SC-T027 later extends validation across the small course. The four-week pilot duration is a learner-observation window after prerequisites, not a promised delivery date.

Recognition, recall, productive use, retention and transfer must remain distinct from completion/XP. Numeric INTRO-01 criteria are initial pilot defaults needing educator review before baseline. Human-rated communication, model feedback quality, native usability, privacy and engagement have separate evidence. A failed or inconclusive pilot triggers revision/retest or an explicitly bounded next experiment; it does not permit a general efficacy claim. Existing complete A1–C2 public-release scope remains unchanged.

## English Foundations delivery — adopted 2026-10-19

The required [English Foundations sequence](../../../product-specification/english-foundations.md) explicitly covers word types, sentence structure/roles, agreement/verb forms, phrases/clauses and progressive grammar. It connects to CEFR can-do lessons through shared child objectives and reviewed descriptor references. Exact level placements and completeness are editorial decisions, not inferred from a grammar label. Follow [EF-QA01–EF-QA08](../testing/english-foundations-acceptance.md).

| Existing work | Concrete adopted scope / acceptance |
| --- | --- |
| SC-T006 / SC-014 | Map every required EF topic to reviewed child objectives, CEFR lesson/descriptor references and delivery batches; unresolved published mappings block publication. |
| SC-T018 / SC-T020 / SC-008 | Teach the Introductions noun/pronoun, subject/predicate, be and present-agreement subset; keep the five existing grammar items and optional terminology diagnostic separate from INTRO-01 completion. Focused/contextual entry shares evidence and returns to the original lesson. |
| SC-T043 | Include the subset's concept, controlled-use, communication and delayed-use checks alongside the existing four-week pilot, with separate results and no claim that grammar labels prove proficiency. |
| SC-T026 and M6–M11 level tickets | Decompose remaining foundation objectives into bounded authoring/activity batches at suitable depth after the existing expansion decision. Revisit concepts rather than requiring a complete grammar course before speaking. |
| SC-T040 / SC-011 | Audit full foundation inventory, CEFR-linked reviewed content and applicable evidence before public-release completeness; no required topic silently omitted. |

No extra ticket or milestone is needed for this adoption: the existing owners/tickets now carry these requirements, while later outlines still require decomposition. At foundations adoption, the 43 existing tickets remained pending. Native stack, authored lesson quantities, reviewed level mappings and runtime/learner proof are not settled by this documentation. Initial EF thresholds require educator review; terminology, controlled use and transferable communication remain distinct.

## Specialized trainer delivery — adopted 2026-10-19

The [seven-trainer contract](../product-specification/specialized-trainers.md) defines profession-specific teaching sequences, activities, follow-ups, feedback and learning criteria for explicitly selected specialist practice. The required CEFR course remains fixed whichever coach presents it. All seven roles are unlocked, with shared CEFR/EF evidence and manual selection. [TR-QA01–TR-QA10](../testing/specialized-trainer-acceptance.md) distinguishes genuine training methods from character changes.

| Delivery scope | Existing / new owner tickets | Gate |
| --- | --- | --- |
| Seven-role selection and safe switching | SC-T007 / SC-T010 under SC-003/SC-005 | Method preview, honest pack availability, shared progress and frozen assessment; seventh character visual/voice decisions still open |
| First three methods around Introductions | SC-T018 / SC-T020 / SC-T021 / SC-T043 under SC-006/SC-008/SC-014 | Teacher guided/faded practice, Grammarian construction and Journalist follow-up/source tasks; existing core counts and independent rubric unchanged |
| Explained trainer suggestions | SC-T024 under SC-009 | Skill/evidence-based reason, available reviewed task and manual override; no forced seven-coach circuit |
| Full seven trainer packs | [SC-T044](tickets/SC-T044.md), coordinated with SC-T035 workplace and SC-T036 communication/articulation | Decompose bounded method/objective packs; include Librarian, Business Professional, Speaker and Creative Writer; define level-by-role volume and TR learning criteria |
| Public-release audit | SC-T040 / SC-011 | Require SC-T044 plus all-seven actual reviewed pack/learning/device evidence; seven selection cards are insufficient |

Creative Writer covers written expression and separately evaluated spoken storytelling; animal/name/artwork/voice remain owner design decisions. No new tab, mandatory realtime dialogue, seven-agent infrastructure or per-trainer provider selection is adopted. Reviewer-approved numeric thresholds are initial task criteria, not CEFR cutoffs or efficacy guarantees. All 44 tickets remain pending; earlier 43-ticket counts record prior documentation snapshots. M12 now has six tickets and SC-T040 explicitly depends on SC-T044.

## CEFR invariance and independent AI practice — 2026-10-19

The [course/practice contract](../product-specification/learning-path-and-practice.md) is the authoritative clarification: curriculum determines CEFR objectives/sequence/difficulty/teaching/core activities/completion/assessment; all coaches present/support the same course. Profession-specific methods apply to optional separate specialist practice. SC-T018/SC-T020/SC-T021/SC-T043 prove this around INTRO-01 with CP-QA01–03/08; SC-T044 must preserve it across all seven.

SC-T035 now explicitly owns decomposition of independent AI conversation and interactive interview modes: back-and-forth turn history, relevant interview follow-ups, review/retry, configurable role/type and honest modality availability. First delivery still proves recorded monologue feedback. Later turn-based conversation scope/transport/auth/cost/retention must be specified; natural realtime streaming, turn-taking and interruption remain deferred capability/release investigation. Neither existing one-shot feedback nor a mascot proves live AI conversation. CP-QA04–07 closes only against actual included modes.

## Celebration, badge and reward delivery proposal — 2026-10-19

[The requested proposal](../../../product-specification/celebrations-badges-and-rewards.md) covers inline routine gains, persistent lesson/session result, grouped optional badge reveal, Progress detail/evidence, actual XP/gold itemization and a proposed catalog. Native celebratory motion is immediately skippable with Continue available at once; Reduce Motion/quiet/static/accessibility alternatives are required. Proposed numerical timings, gestures and badge names/thresholds await owner/native/educator review as appropriate; approved economy values are unchanged.

SC-T007 reviews design specimens; SC-T025 must decompose proposal decisions, event/rule/ledger identity, badge/result surfaces and motion/device/accessibility checks into bounded children. SC-T024 supplies reward/evidence history. Test RW-QA01–08 separately from learner progress and provider proof; display/skip/replay cannot generate awards. No new ticket/count/dependency/status is introduced: all 44 remain pending. App implementation, animation assets, Figma edits and runtime acceptance are not performed by this documentation.

## Complete award catalog review before visuals — 2026-10-19

Owner requested a complete inventory before badge visual design. [Catalog v1](../../../product-specification/achievement-catalog.md) now records 68 award families, eight operational indicators and eight economic entries, with seven carried-forward starter proposals distinguished from 61 new proposals. This is a family inventory across current product scope, not a claim of 68 fixed finished badges, approved new rules or delivered capabilities.

SC-T025 owns explicit catalog selection, badge-versus-milestone classification, tiers, exact reviewed earning conditions, content-instance sets and overlap/event identity; only then refine visuals and implementation children. SC-T024 uses the catalog for truthful Progress/evidence states, and SC-T040 audits included award/capability coverage. Existing XP/gold amounts and all 44 ticket statuses/dependencies/counts remain unchanged. No badge visuals, animation assets or Figma writes occur in this step. Unavailable course/AI/audio capabilities and unresolved criteria block related award activation.

## Catalog adoption and initial visual proposal — historical record

Owner adopted all 68 catalog families/names/classifications/listed initial tiers and requested visual design next. Earlier catalog-selection language above is a historical pre-adoption snapshot, not a requirement to ask again. [The catalog](../../../product-specification/achievement-catalog.md) records adoption; [visual proposal 01](../../../product-specification/achievement-visual-design.md) provides a representative Page 1-inspired board and a subject/presentation mapping for all 68 families.

SC-T007 reviews visual specimens; SC-T025 refines unresolved eligibility/instance/rubric/event/operational gates and asset/implementation children against the adopted scope; SC-T024 integrates state/evidence surfaces. At that stage the direction awaited adoption; the later visual-system adoption below supersedes that status. The board remains distinct from production assets or live Figma/UI. All 44 tickets remain pending with unchanged dependencies/counts; no production badge library or application implementation is claimed.

## Achievement visual system adopted — 2026-10-19

Owner adopted [illustrated achievement seals v1](../../../product-specification/achievement-visual-design.md) for the complete 68-family catalog and its future instances. Earlier visual-proposal/pending-direction notes are historical; no repeated approval of the accepted direction is required. All mapped subjects, three collectible shell types, category accents, seven trainer tool signatures, tier/state treatments, checkpoint/metric separation, surfaces and initial motion targets are delivery requirements.

| Work / owner | Required next outcome | Verification boundary |
| --- | --- | --- |
| SC-T007 / Frontend | Production/native specimens follow the accepted direction and retained Page 1 controls | AV-QA01–08 fidelity and native review; no claim of Figma edits from this adoption |
| SC-T025 / Software Engineer with content/design/SQA | Decompose editable shell/subject masters, small-size/state/tier variants and result/reveal integration into bounded children alongside existing ledger/eligibility work | Complete family/instance mapping plus AV/RW checks; adopted direction is not a shipped asset library |
| SC-T024 / Software Engineer | Progress overview/details, milestones and wallet use correct accepted visual/evidence semantics | Accessible category/criterion/state and actual reward identity; no duplicate awards |
| SC-T040 / SQA and Documentation | Release audit accounts for all included AW instances, production asset references and theme/accessibility states | Actual production/native evidence, not the reference PNG alone |

No new ticket/status/dependency/count changes: all 44 tickets remain pending. Catalog/economy/coach-independent CEFR rules stay unchanged. Asset generation, Figma writes, app coding, motion implementation and runtime/device verification are subsequent scoped work; this request updates their adopted requirements.

## Authorized award artwork production — 2026-10-19

The owner requested actual assets for all 68 families. [SC-T045](tickets/SC-T045.md) isolates this asset-production child of SC-T025, independently authorized from the adopted catalog/design rather than waiting on scheduler/runtime prerequisites. Generate separate transparent PNG earned/base masters plus exact prompt/source records, manifest and review gallery under assets/awards/v1/. Preserve checkpoint versus collectible and trainer-pair semantics. Raster masters do not substitute for vectors, native state overlays, actual app rewards, Figma implementation or device acceptance.

SC-009/M4 is in_progress for this bounded preparation only; the broader runtime scope remains unimplemented. SC-T045 completed on 2026-10-20: all 68 base PNG masters and prompt/source/gallery records were delivered and statically checked. Track 45 tickets (44 pending, one done). Vector/small-size/native work and broader reward runtime remain pending.

## Agent UI handoff documentation — 2026-10-21

The [UI reference guide](../../../product-specification/ui-reference-guide.md) now specifies agent read order/source authority, exact retained template/component IDs, seven local screenshot links, desktop/backup fallbacks, asset reuse, design-to-source mapping and separate visual/behavior/native acceptance. AGENTS, onboarding links, the application map and SC-T007 route agents to this workflow. This is documentation preparation only: SC-003 remains in_progress, SC-T007 remains pending and no application work or design/device acceptance was executed.

## Readiness refinement and SC-T001 closure — 2026-10-21

Owner authorized ticket/dependency refinement and scope decisions only, with no app expansion. Application development must await a subsequent explicit owner instruction. SC-T001 is done using adopted INTRO-01/CEFR requirements plus owner-confirmed proof range 1–120 seconds subject to feasibility and countdown off initially. SC-001 remains in_progress for SC-T006 publication work. Six remaining M0 tickets are Ready for planning; none is complete.

SC-T008 bootstrap no longer waits for product design; SC-T010 still does. Offline SC-T011 no longer waits for provider selection; SC-T002 must specify local capture feasibility and SC-T003/SC-T013 still validate submission. SC-T007 now gates reviewed design inputs rather than future runtime/all-award production. SC-T006 establishes shared publication rules and the first-topic subset; later levels retain pre-publication detail/review and complete-release audit. No new tickets or capabilities were added. See the current tracker for counts and next actions.

## SC-T002–SC-T004 decision/research completion — 2026-10-21

Architecture, provider-candidate investigation and retention reconciliation are documented and their scoped tickets done. SC-002/SC-015 retain pending implementation/provider proof; SC-005/SC-006 are not implemented. Owner selected OS 17+, no learner device backups, 24-hour interrupted recovery and preserved participation credits on individual purge. See canonical technical/contract/provider records. Next planning: SC-T005/SC-T006/SC-T007, then reassess first-slice readiness. No scope expansion, app creation or development authorization.

## SC-T005–SC-T007 readiness work — 2026-10-21

SC-T005 done as bundle-first offline content/version decision, with no new download service or app work. SC-T006 publication/checklist and proposed first-topic mapping prepared but blocked on actual qualified review; owner has no reviewer. SC-T007 first-flow dated visual handoff/defaults/corrections prepared, in_progress pending used asset/master/provenance inputs and owner walkthrough. SC-001/SC-003 remain in_progress; no parent implementation is complete. Current counts: 45 total, 37 pending, one blocked, one in_progress, six done. No dependency removal, scope expansion or app-development authorization.

Owner review update, 2026-10-21: accepted the documented SC-T007 behavior/layout direction with listed open checks retained. This does not close used master/property/asset/provenance verification, interactive/native acceptance or authorize development.

## SC-T007 live audit update — 2026-10-21

SC-T007 now done as a design-input review with actual component/token/source-art inspection and owner-confirmed provenance. SC-T006 stays blocked; all other pending implementation tickets retain their checks and owner development hold. Current totals: 45 tickets, 37 pending, one blocked and seven done, none in_progress. M0 has six done/one blocked and cannot close its qualified content gate. Next scope is readiness/setup review, not app implementation.

## Complete outline decomposition — 2026-10-21

Owner authorized decomposition of all remaining outlines. Created 147 children under 22 retained groups; [coverage register](decomposition.md) records membership, original acceptance and dependency semantics. Current 192 tickets include groups: 184 pending, one blocked, seven done. No group/ticket implementation or curriculum authoring started; no approved product scope, counts, prices, provider defaults or visual identity expanded. Qualified educator review remains blocked under SC-T006; development authorization remains withheld.

## Consolidated full-plan readiness audit — 2026-10-21

[The complete review](readiness-review.md) supersedes earlier next-review/setup-review recommendations. All 192 records and adopted scope were checked together. Corrected stale summaries, clarified early completion versus later economics, staged future AW instance binding, assigned typed-feedback/word-finding/optional-voice ownership, consolidated remaining decisions and preserved signed-artifact evidence. Added explicit policy/capability edges SC-T167→SC-T055 and SC-T183→SC-T158; SC-T159 explicitly references SC-T012. No tickets added or marked delivered; 184 pending, one blocked and seven done. No app implementation, provider calls, publication, Git initialization or expanded product scope. No further general planning review is required before owner-authorized SC-T008 kickoff; later choices and evidence gate only their named work. Verification details are in readiness-audit.json.

## Automation execution sequence — 2026-10-21

Use [the ordered ticket runbook](execution-sequence.md) and its linked machine-readable queue for the preferred complete run order. Start SC-T008 → SC-T009 → SC-T010 → SC-T011 after explicit owner development authorization. Refresh exact status/dependencies, require actual acceptance evidence and treat delivery groups as closure audits. Skip completed baseline work; pause affected branches for real external/owner/reviewer/learner evidence and continue only eligible authorized work. No new general readiness review is required. No automation or app implementation is started by adding this plan.

## Implementation kickoff — 2026-10-21

Owner instructed: “Start implementation based on the sequence we derive.” This authorizes serial bounded implementation under the adopted execution sequence and supersedes earlier development-hold statements. SC-T008 is active. Git initialization, live provider calls, account changes and publication retain their separate gates. Current status/evidence is in the [progress tracker](progress.md) and exact ticket; the queue is a dispatch view, not an unattended scheduler.

## SC-T006 owner approval — 2026-10-21

The owner approved SC-T006 because a qualified educator review could not be performed. The shared publication checklist is accepted for that gate. It is not a CEFR certificate. Later batches still supply their own completeness records. Earlier notes that leave SC-T006 blocked are historical.


## Owner-authorized stabilization — 2026-10-22

The owner requested implementation after reviewing poor UI/behavior. [First-loop stabilization](stabilization-2026-10-22.md) is the current bounded execution batch. Reuse the existing ticket IDs and retain the full public target; focus current work on connected recording, lesson and vocabulary outcomes before further expansion. Current status and actual acceptance are recorded in progress.md and the linked evidence, not the raw ticket count.

## Offline recall recovery batch — 2026-10-22

SC-007 remains in_progress. Owner authorized the next bounded SC-T048–SC-T050 pass: stable review-event identity, hidden-draft/reveal recovery and optional Think/Write/Say self-check modes. [Plan and coverage](recall-recovery-2026-10-22.md), [verification evidence](../testing/evidence/recall-recovery-2026-10-22/README.md). Original parent acceptance and remaining provider/device/learning gates remain open.

## Today and Progress reliability — 2026-10-22

SC-009 remains in_progress. Owner authorized Codex’s SC-T051/052/054 app follow-up while Grok prepares reward policy proposals separately. Matching primary actions, explicit daily overrides, confidence autosave/retry/reset protection and fresh day/week summaries are in the [bounded batch](daily-flow-2026-10-22.md). [Actual verification](../testing/evidence/daily-flow-2026-10-22/README.md) remains distinct from parent completion. No reward policy, price or award activation was integrated.

## INTRO optional practice integration — 2026-10-23

SC-005/SC-008 remain in_progress at parent level. Catalog validation/metadata and four durable offline practice routes are implemented in [the bounded batch](intro-runtime-2026-10-23.md); [verification](../testing/evidence/intro-practice-2026-10-23/README.md) separates simulator coverage from remaining physical/content/learning acceptance. Grok’s next exclusive coding lane is scheduler integrity, while Codex owns runtime integration and canonical status.

## Connected speaking and personal-check delivery — 2026-10-23

SC-T021 runtime is implemented and awaiting testing; SC-006/SC-008 remain in progress at parent level. [Exact scope](connected-practice-2026-10-23.md) connects specialist speaking, separate personal checks, retained conditions, restart and progress. Grok scheduler safety is integrated without policy changes. Content/physical/learning acceptance remains separate.

## SC-D003 delivery — 2026-10-23

[SC-D003 vocabulary/review implementation](sc-d003-2026-10-23.md) now includes learner retention/session controls and prospective parameter/version policy, preserving existing identity/recovery/evidence rules. SC-T046–050 await testing/acceptance; SC-T022/023 and SC-007 remain open for their full original roll-up and prerequisites. See [evidence](../testing/evidence/sc-d003-2026-10-23/README.md). The [full SC-D004 Grok handoff](../../../development-plan/handoffs/grok-sc-d004-2026-10-23.md) reserves disjoint source/test files while Codex owns shared integration and verification.


## SC-D004 review repairs — 2026-10-23

Owner authorized Codex to fix unsaved preference loss during iPad navigation and child identifier collisions after Grok's delivery. [Implemented repair and ownership](sc-d004-review-fixes-2026-10-23.md), [29 selected tests pass per simulator](../testing/evidence/sc-d004-review-fixes-2026-10-23/README.md). Existing status/counts remain: SC-T051 in_progress for reviewed specialist mappings; SC-D004 partially implemented. No physical/content/learning acceptance inferred.

## SC-D007 A1 candidate — 2026-10-23

SC-008/SC-014 remain in_progress. Owner assigned SC-D007 to Codex. The [unpublished A1 candidate](sc-d007-codex-2026-10-23/README.md) has twelve topic revisions, exact INTRO-01 reuse and actual structural/domain checks. Missing manifest/review/depth, historical-version access and real native/learner acceptance prevent closure; no live curriculum change.


## SC-D006 personal-use test integration — 2026-10-23

Codex corrected the [Grok handoff](../../../development-plan/sc-d006-grok-2026-10-23/README.md) and registered SmallA1CourseTests. The [initial version-2 checkpoint passed 26 tests per simulator; the later workspace recheck had 24 passes and 2 failures](../testing/evidence/sc-d006-integration-2026-10-23/README.md) following concurrent version-3/runtime edits. The [repair run passes 26 selected tests per simulator](../testing/evidence/sc-d006-test-fixes-2026-10-23/README.md), resolving both failures; UI acceptance remains separate. Personal-use metadata and resume-identity checking do not close the original course/content/pilot records. Their full prerequisite and acceptance gates remain open; no status was promoted to done or awaiting_testing from this limited integration.

## SC-D007 implementation delivery — 2026-10-23

SC-008/SC-014 remain in_progress. The owner-authorized [personal-use A1 implementation](sc-d007-implementation-2026-10-23.md) now retains exact v2 course versions, keeps old attempts/drafts usable, and provides offline teaching plus separate optional topic practice through existing runtime components. SC-T073–087 are awaiting_testing; SC-T029 remains in_progress and SC-T088 pending. Qualified review, original INTRO-01 obligations, prerequisite closure and actual native/learner acceptance are unchanged.

## SC-D013 local integration — 2026-10-24

SC-010 and SC-T035/150/151 are in_progress. Owner-authorized [local conversation/interview integration](sc-d013-integration-2026-10-24.md) connects text turns, native recording and explicit local recovery/retention. Full online behavior, adopted contracts, qualified content and original actual acceptance remain open. SC-D014 is separately dispatched to Grok.

## SC-D014 local integration — 2026-10-24

SC-013/SC-016 and SC-T036/154–159 are in_progress. [Review and integration](sc-d014-integration-2026-10-24.md) connects eligible local communication practice, exact-source recovery and native recording across Learn/Speech Lab. Missing release selection, reviewed content/reference playback, online/capability implementation and original acceptance remain explicit. SC-T160 stays pending.

## SC-D017 resource library — 2026-10-24

SC-010 remains in_progress. The [owner-authorized resource library](sc-d017-implementation-2026-10-24.md) connects Learn, curated/personal cards, local notes/search/edit/remove, offline state and deliberate external opening under the [selected HTTPS policy](../../../contracts/resource-library-v1.md). SC-T168/169 are awaiting_testing; SC-T039 parent closure and original SC-T028 acceptance remain pending. No resource export, embedded media, metadata fetching, provider call or curriculum-completion claim. Current executed results and remaining device/accessibility/external-site acceptance are in the linked evidence.

## SC-D015 reviewed integration — 2026-10-25

SC-012 remains in_progress. [Codex review/fixes/integration](sc-d015-integration-2026-10-25.md) register the returned local generation/report machinery with exact protected-store recovery/deletion and a fail-closed Speech Lab host. SC-T037/161–164 remain in_progress: production policy/model/adapter, content and semantic validation are incomplete alongside original actual acceptance. No generation grant, live request, automatic enrollment or qualified review is inferred.

## SC-D016 reviewed integration — 2026-10-25

SC-007 remains in_progress. SC-T038/166/167 now have repaired registered discovery/daily screens and synthetic lifecycle checks; production generation/enrollment and daily selection remain incomplete. SC-T165 manual topics stays awaiting_testing.

## SC-D017 acceptance follow-up — 2026-10-25

SC-010 remains in_progress. The owner redirected this pass from SC-D018 to SC-D017 after no Grok completion return could be verified. Encoded query/identity behavior is repaired with new source/storage regression coverage and native handoff checks. Original resource/pilot and actual acceptance remain open; SC-D018 is deferred.

## SC-D002 first-introduction delivery — 2026-10-25

SC-014 personal-use INTRO-01 authoring and existing course integration reach awaiting_testing under owner-authorized SC-D002. SC-T018 joins SC-T019/020/021 at awaiting_testing; SC-T043 remains pending actual acceptance execution. Named content/rubric/alternatives/source records and prospective protocol are prepared; qualified review, original prerequisites and actual learner/device evidence remain open. [Delivery and evidence](sc-d002-2026-10-25/README.md).


## SC-D004 completion checkpoint — 2026-10-25

[SC-D004 connected focus/evidence](sc-d004-2026-10-25.md) is implementation-complete at awaiting_testing with phone/tablet regression and passing targeted retests. SC-T051 joins SC-T052/054; qualified content/device/manual/learning acceptance remains. SC-T024 stays pending for SC-T053/rewards and original prerequisites.
