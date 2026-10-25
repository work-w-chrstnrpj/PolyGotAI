# SpeechCoachAI

A native iPhone/iPad English learning project connecting grammar, vocabulary and speaking practice. Initially built for the owner, with eventual sharing. Speaking practice leads the first usable delivery: record a short introduction, replay it, and receive AI feedback afterward when connected.

## Current state

Implementation started on 2026-10-21 with SC-T008: a universal SwiftUI project and launch/test bootstrap. See [verified commands](docs/history/v1/commands/commands.md) and the [progress tracker](docs/history/v1/development-plan/progress.md). Local persistence has passed simulator and physical iPhone checks; navigation/preferences are under verification. Recording now has a signed iPhone build installed for owner/device checks, with synthetic recovery tests passing. Owner confirms clear iPhone replay and background/no-resume/self-review tests pass. Local provider Keychain setup is implemented and verified; online requests remain unavailable. Remaining physical acceptance, learning and online coaching stay pending; there is no backend or Git repository. Owner UI/UX decisions specify a complete A1–C2 five-skill public-release path with interview/business coverage. Nothing here claims a shipped feature.

The reusable Figma Page 1 was consolidated and visually reviewed locally on 2026-10-17; Page 2 removal was verified. Cloud sync and final owner/native/device acceptance remain unverified. Use the [AI UI handoff guide](docs/product-specification/ui-reference-guide.md) for exact templates/components, screenshots, asset selection and access fallbacks. The [local Figma design helper](tools/figma-local-helper/README.md) supports desktop inspection; its tooling checks do not prove app behavior.

## Product direction

Offline basic lessons, vocabulary and self-review; online personalized correction using learner-supplied AI-provider keys (BYOK), with provider usage billed to the learner’s account. No key is needed for offline study/self-review. English-first CEFR progression with learner-selectable available levels. Dedicated vocabulary experience includes Word of the Day, Anki-style repetition and custom topics. Speaking includes everyday communication, pronunciation, spontaneous speech and configurable interviews. Progress emphasizes recording comparisons, word recall and grammar improvement, supported by XP, badges and distinct completion/improvement milestones.

## Start here

- [Product specification](docs/history/v1/product-specification/product-specification.md): owner-confirmed intent and acceptance boundaries.
- [Technical design](docs/history/v1/tdd/tdd.md): canonical technical intent and unapproved architecture candidates.
- [Development plan](docs/history/v1/development-plan/development-plan.md): dependencies and next design/implementation gates.
- [Milestones and tickets](docs/history/v1/development-plan/milestones.md): 14 milestone gates and decomposed delivery tickets; exact statuses and evidence.
- [AI UI handoff guide](docs/product-specification/ui-reference-guide.md): how future agents use Page 1, component IDs, local screenshots and artwork alongside behavior contracts.
- [UI/UX decisions](docs/product-specification/ui-ux-design.md): owner-approved flows, coaches, backgrounds, rewards, privacy and open design gates.
- [Documentation index](docs/history/v1/README.md): contracts, data, testing, deployment and diagrams.
- [Agent rules](AGENTS.md) and [onboarding](docs/history/v1/getting-started.md): project conventions and AI guidance.

## Verify and maintain the preset

The generator is external; it is not installed in this project. See [commands](docs/history/v1/commands/commands.md). Preview synchronization and review managed-file replacements before applying it. Project docs are owned by SpeechCoachAI; keep project requirements out of portable roles/skills.

## Project-local design skills

Additional third-party skills are installed only in `.agents/skills/` and are separate from the reusable preset. No global installation is required. They are available for discovery on the next turn.

- [Apple Design Skill](https://github.com/NutshellEngineering/apple-design-skill), revision `119b6acc231e87ed56a64f0a8a73ce0a8606be55`: `apple-design-skill`, including its HIG references. Use for native iPhone/iPad interface design and review. Its unofficial mirror can lag Apple’s current guidelines.
- [Emil Kowalski’s skills](https://github.com/emilkowalski/skills), revision `2d228630ba1446365f614a108cb8252f1feda202`: `animate`, `animate-expo`, `animation-performance`, `animation-vocabulary`, `apple-design`, `ask-sonner`, `break-ui`, `emil-design-eng`, `find-animation-opportunities`, `improve-animations`, `mobile-native`, `pick-ui-library`, `prototype`, `review-animations`, and `write-swift`.

Select skills by their actual platform scope. Emil’s `apple-design` translates Apple principles for the web; it is distinct from the native HIG skill. Web, React Native/Expo, and Sonner guidance does not select the application stack or introduce dependencies. Native Apple conventions and project intent govern native designs. Installing these skills does not begin application implementation.

## Consolidated readiness baseline — 2026-10-21

Use [the full readiness review](docs/history/v1/development-plan/readiness-review.md) for approved decisions, complete remaining-choice ownership, stage gates and verification. Planning is sufficient for the first engineering slice; no additional general readiness/setup-review round is required. Setup is execution under SC-T008 after the owner starts development. Later choices gate only affected work. This historical readiness review is not a separate authorization gate; current implementation authorization and the active stabilization batch are recorded below. Provider, Git and publication gates remain separate.

## Current implementation authorization — 2026-10-21

Owner started implementation under the adopted sequence. Earlier development-hold statements are historical. SC-T008 owns the native bootstrap and separate simulator/physical evidence; later tickets retain their prerequisites. No scheduler or release is implied.


## Latest engineering checkpoint — 2026-10-22

Native application source exists under application/. The owner authorized [first-loop stabilization](docs/history/v1/development-plan/stabilization-2026-10-22.md) after reviewing UI and behavior. Current status is in [ticket progress](docs/history/v1/development-plan/progress.md), and actual source/verification limits are in the [stabilization evidence](docs/history/v1/testing/evidence/first-loop-stabilization/README.md). The local lesson/vocabulary/speaking loop and gated HTTP source exist. Live provider access remains disabled pending account evidence; neither 57 structurally available lessons nor passing fixtures establishes full curriculum or learning acceptance. No Git repository or release is created.

The next [offline recall recovery batch](docs/history/v1/development-plan/recall-recovery-2026-10-22.md) adds saved hidden drafts, stable rating-event identity, and Think/Write/Say self-check modes. Say is unrecorded learner-reported recall. [Exact checks and remaining acceptance](docs/history/v1/testing/evidence/recall-recovery-2026-10-22/README.md) stay separate from release or learning claims.

## A1 version recovery checkpoint — 2026-10-23

[SC-D007 implementation](docs/history/v1/development-plan/sc-d007-implementation-2026-10-23.md) supplies twelve personal-use A1 v3 previews alongside unchanged INTRO-01 and other levels. An unfinished v2 lesson opens its original content and responses; the activity list offers Saved versions and an explicit Start current version action. Offline teaching and optional concept/listening/workplace/check practice use existing components; optional check text is retained only after an explicit choice. [Verification](docs/history/v1/testing/evidence/sc-d007-2026-10-23/README.md) is distinct from qualified review, full A1 coverage, physical acceptance and actual learning results.

## Local conversation and interview preview — 2026-10-24

Open **Speech Lab → Conversation practice** or **Interview practice** for local text turns and the existing record/replay/self-review flow. Interview follow-ups quote your submitted answer. Online partner replies and live voice remain unavailable. Written work starts in memory; **Keep draft for 24 hours** enables local recovery, while final text/audio choices are independent. Only audio kept inside the recorder can remain available in saved practice history. A latest-session recovery slot is retained per mode; it is not a transcript library. See [integration and verification](docs/history/v1/development-plan/sc-d013-integration-2026-10-24.md) for exact limits and original ticket gates.

## Local communication practice — 2026-10-24

Open **Speech Lab → Communication practice** for your own task or an exact lesson-version link. In Learn, use **Extra practice → Communication practice** (or its toolbar entry). Local writing, optional recording/replay and self-review share the same explicitly saved practice for that source. Keep draft for 24 hours enables recovery; different lesson versions stay separate. Completion does not score sound, award mastery or complete a course. Published communication lessons/reference audio and online feedback are not delivered by this preview. See [review, integration and actual verification](docs/history/v1/development-plan/sc-d014-integration-2026-10-24.md).

## Learning resources — 2026-10-24

Open **Learn → Learning resources** to save an HTTPS link with a title, optional topic and personal notes, or save one of the source links. Search matches titles, topics, notes and destinations. Supported YouTube video/Shorts/channel links normalize to one destination; duplicate bookmarks ask you to edit the existing entry. Each saved card offers Edit, Remove and Open website. Removal confirms deletion of that bookmark and its notes.

Titles and notes remain available offline. Open website shows the actual destination and asks before leaving the app; offline connectivity or a refused system handoff leaves your bookmark intact. External sites can redirect, track or require sign-in. SpeechCoachAI does not download thumbnails, video, page text or transcripts, and it does not treat opening a link as lesson completion or evidence of learning.

Only **Save** persists your bookmark locally. Failed saves keep your edits for retry while the app remains open; Cancel asks before discarding changes. Unsaved drafts do not survive termination. Delete all learning data clears saved bookmarks and invalidates stale drafts. No provider submission or automatic resource export is enabled. See the [resource policy and exact limits](docs/contracts/resource-library-v1.md).

## Generated practice boundary — 2026-10-25

**Speech Lab → Generated practice** now opens the registered host, which explains why new variations are unavailable without an adopted generation policy. No production request callback is connected. Repaired local machinery supports compatible saved wording, explicit reveal/retention, local activity reports and durable removal through the existing protected store. A report does not submit a message or publish a correction. No generated variation completes/rescores a course or enrolls vocabulary automatically. [Review, actual checks and remaining policy/adapter/content work](docs/history/v1/development-plan/sc-d015-integration-2026-10-25.md).

Topic word suggestions and Word of the Day now have registered native entry points. Generation and daily selection are unavailable while original policy/content and implementation remain incomplete. Manual vocabulary is available offline. See [SC-D016 review and remaining scope](docs/history/v1/development-plan/sc-d016-integration-2026-10-25.md).

## SC-D002 first-introduction delivery — 2026-10-25

INTRO-01 v4 adds post-attempt review with valid wording alternatives, explanations, draft rubric anchors and specialist feedback priorities. Quiet practice answers the same follow-up outcome. Compare core examples before finishing; wrong answers still allow completion after review. Older v3/v2 work reopens its exact content. Personal-use implementation is awaiting testing; educator review, actual pilot and physical/owner acceptance are separate. [SC-D002 delivery](docs/history/v1/development-plan/sc-d002-2026-10-25/README.md).

### Local rewards and goals

Open **Today → XP/gold/achievements**, **Progress → achievements**, or **Settings → Rewards, wallet and achievements**. XP describes participation; gold comes from eligible local practice, with no real-money purchases. Wallet history shows each committed source and payment/debit. The first attempt with correction or self-review pays full credit, one meaningful same-date repeat half, further repeats zero. A recorded speaking self-review has one entitlement even inside a lesson. Displaying results or a badge never pays again.

The overview keeps all 68 adopted families visible, with categories, original criteria and explicit availability. Personal-use participation/completion can be earned; learning/CEFR/future or unsupported task awards stay unavailable. A lesson checkpoint is progress, not a collectible badge. **Reward preferences** offers separate active-minute/activity targets, explicit one-lesson daily plans, quiet/full/subtle/off celebrations, initially-off sounds/haptics/Freeze auto-use, optional timers and selected-day/time reminders. A daily plan requires its named tasks and final self-review; its bonus does not require the minute target. Background/idle time pauses; reminders require permission and never repeat after being ignored.

Two INTRO-01 v4 grammar activities offer optional additional hints/examples. Three daily hints are free, then 2 gold; a worked example costs 4. Cost/balance confirmation precedes a purchase; previously opened help reopens free. The usual explanation, correction, accessibility help, replay and retry remain free with zero gold. Freeze (20) and Repair (30 per missing date, up to seven) only protect continuity. Answer elimination and XP levels remain unavailable under the adopted decisions. Purchases and settings stay local in existing protected storage; delete-all clears them and invalidates old callbacks. [Policy, exact bindings and verification](docs/history/v1/development-plan/sc-d005-2026-10-25/README.md).
