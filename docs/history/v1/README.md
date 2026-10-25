# SpeechCoachAI Documentation Index

This is the project-owned record of the 2026-10-15 brainstorm. No application implementation exists. IN_PROGRESS means design work still contains unresolved choices; COMPLETE must not imply unimplemented behavior is shipped.

| Document | Purpose |
| --- | --- |
| [Ticket execution sequence](development-plan/execution-sequence.md) | Complete dependency-safe run order, closure audits and automation gates |
| [Machine-readable execution queue](development-plan/execution-sequence.json) | Ordered unfinished records, completed baseline, prerequisites and dispatch policies |
| [Product specification](product-specification/product-specification.md) | Confirmed goals, workflows, acceptance and product questions |
| [UI/UX decisions](../../product-specification/ui-ux-design.md) | Owner interview decisions, prototype economy and remaining design gates |
| [Screen and state inventory](../../product-specification/ui-screen-state-inventory.md) | 70 reusable UI families, state coverage, source mappings and ordered Figma gap plan |
| [UI/UX interview audit](product-specification/ui-ux-interview-audit.md) | All 90 round questions and later approvals mapped to effective decisions, superseded choices and open details |
| [First-flow readiness](product-specification/first-flow-design-readiness.md) | Scoped visual/native handoff and remaining design inputs |
| [Publication readiness](product-specification/curriculum-publication-readiness.md) | Shared publication checklist and proposed mappings; qualified review pending |
| [AI UI handoff guide](../../product-specification/ui-reference-guide.md) | Agent read order, exact template/component IDs, screenshot map, local fallback, asset rules and verification record |
| [Figma design review](../../product-specification/figma-design-review.md) | Editable iPhone draft link, observed inventory, corrections and remaining validation |
| [English curriculum](../../product-specification/english-curriculum.md) | Proposed American English topics across A1–C2 and authoring gates |
| [Communication training](product-specification/communication-training.md) | Frameworks, public speaking and general communication practice |
| [Technical design](tdd/tdd.md) | Canonical technical intent, candidates and architecture gaps |
| [Approved recommendations](development-plan/approved-recommendations.md) | Adopted learning defaults and Qwen trial evaluation |
| [Development plan](development-plan/development-plan.md) | Speaking-first dependency sequence and delivery gates |
| [Milestones and tickets](development-plan/milestones.md) | M0–M13 gates, 192 tracked tickets including delivery groups and children and parent traceability |
| [Ticket progress](development-plan/progress.md) | All ticket statuses/readiness, milestone counts, next actions and evidence |
| [Decomposition coverage](development-plan/decomposition.md) | All 22 delivery groups, bounded children and retained acceptance |
| [Ticket workflow](development-plan/ticket-workflow.md) | Ticket sections, readiness, decomposition and evidence-based closure |
| [Project structure](project-structure/project-structure.md) | Actual tree versus proposed modules |
| [Qwen capability report](../../api/qwen-capability-report.md) | Verified public capabilities and unexecuted proof record |
| [Recorded-feedback contracts](../../contracts/recorded-feedback-v1.md) | Transcript, coaching and local persistence v1 baseline |
| [Device/provider acceptance](../../testing/recorded-feedback-acceptance.md) | Proof matrix, provisional targets and evidence gates |
| [API](../../api/api-specification.md) | Online capability draft; no implemented endpoints |
| [Data](database/data-model.md) | Conceptual records, evidence and retention decisions |
| [Testing](testing/test-specification.md) | Planned checks and acceptance; no claimed test execution |
| [Deployment](deployment/deployment.md) | Readiness decisions; no configured release environment |
| [Diagrams](../../diagrams/README.md) | Conceptual system, flow and entity relationships |
| [Getting started](getting-started.md) | Contributor/agent onboarding |
| [Commands](commands/commands.md) | Verified external preset CLI; app commands unavailable |
| [AI guidelines](guidelines/ai-structure-guidelines.md) | Installed roles and safe preset maintenance |

The initial pasted summary supplied ideas; subsequent owner answers supersede its realtime-first scope, navigation and vocabulary assumptions. Proposed stack, providers, multilingual expansion and release scope still need decisions. Source files will become implementation truth once built.

## Consolidated readiness baseline — 2026-10-21

Use [the full readiness review](development-plan/readiness-review.md) for approved decisions, complete remaining-choice ownership, stage gates and verification. Planning is sufficient for the first engineering slice; no additional general readiness/setup-review round is required. Setup is execution under SC-T008 after the owner starts development. Later choices gate only affected work. Development remains on hold; no app, provider call, Git initialization or publication is authorized by this review.
