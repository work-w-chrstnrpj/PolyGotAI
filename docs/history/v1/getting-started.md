# Getting Started with SpeechCoachAI

## Read before work

Read AGENTS.md, product specification, technical design and the matching development-plan item. Use `.ai/context-routing.md` and maps for discovery, then exact documents/source. SC-T008 provides a native bootstrap. Open `application/SpeechCoachAI.xcodeproj` or use the simulator command reference. Product features remain pending.

## Work modes

For design, distinguish owner-confirmed requirements from recommendations and unresolved choices. For implementation, use the [milestone/ticket index](development-plan/milestones.md) and [ticket workflow](development-plan/ticket-workflow.md), first resolve the matching scope/architecture gates and define acceptance. All 22 later outlines now have bounded children in the decomposition register; parent delivery groups close only on actual child evidence. For docs, keep product, technical, contract, test and deployment pages aligned without inventing commands or behavior.

The installed six roles are Software Engineer, System Architect, Frontend UI/UX Developer, Backend & Database Engineer, SQA Engineer and Technical Documentation Specialist. Mentor and Coach change explanation style. Skills live in `.agents/skills/`; use the smallest relevant workflow. Product planning, security and deployment responsibilities can be coordinated by these owners; additional specialist roles are not installed in this preset.

## Structure verification

Node.js 18+ is required by the external generator. See [command reference](commands/commands.md) for exact validation and preview commands. No local preset CLI or npm scripts exist. Native build/test commands are documented in the command reference.

## Updating guidance

Keep project requirements in AGENTS.md, docs and maps. Portable roles/skills remain canonical. Review external template changes before synchronizing; sync may refresh managed guidance/maps. Preserve local project customizations and inspect preview output. Do not force replacements or initialize source control as part of routine documentation work.

## Current blockers to running the app

SC-T002–SC-T004 now record architecture/OS, provider candidate and retention decisions. SC-T005 packaging and SC-T007 first-flow design inputs are complete as decisions/review. Actual build/device/signing work, qualified publication review, live-call prerequisites and runtime evidence remain assigned delivery work; see the consolidated readiness review. Application development is expressly on hold until the owner says to start; decisions do not provide a runnable app.

## Consolidated readiness baseline — 2026-10-21

Use [the full readiness review](development-plan/readiness-review.md) for approved decisions, complete remaining-choice ownership, stage gates and verification. Planning is sufficient for the first engineering slice; no additional general readiness/setup-review round is required. Setup is execution under SC-T008 after the owner starts development. Later choices gate only affected work. Development remains on hold; no app, provider call, Git initialization or publication is authorized by this review.

## Automation execution sequence — 2026-10-21

Use [the ordered ticket runbook](development-plan/execution-sequence.md) and its linked machine-readable queue for the preferred complete run order. Start SC-T008 → SC-T009 → SC-T010 → SC-T011 after explicit owner development authorization. Refresh exact status/dependencies, require actual acceptance evidence and treat delivery groups as closure audits. Skip completed baseline work; pause affected branches for real external/owner/reviewer/learner evidence and continue only eligible authorized work. No new general readiness review is required. No automation or app implementation is started by adding this plan.

## Active native setup — 2026-10-21

Owner authorized implementation; earlier development holds are historical. Run `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl list devices available`, then `bash tools/native/verify.sh SIMULATOR_UUID` from this project. The script builds and tests the shared scheme without signing and prints its unique output directory. Xcode 27.0/27A266a is available locally. Choose a simulator in Xcode to run the bootstrap interactively. Physical signing setup is pending; no account changes are needed for simulator work.

