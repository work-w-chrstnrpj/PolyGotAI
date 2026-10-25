# Reusable UI reference

> v2 (2026-10-25): still the guide for visuals and components. Behavior and copy now follow the [v2 overrides](ui-ux-design.md#v2-overrides--2026-10-25): no screen explains unavailable features. The per-ticket handoff record is replaced by the phase report in `development-plan/phases/`.

> Current readiness and remaining-choice authority: [consolidated readiness review](../history/v1/development-plan/readiness-review.md). Dated earlier pending statements are historical where superseded by recorded approvals; they are not additional start gates.
> Locally built and visually reviewed in Figma Desktop on 2026-10-17. Page 2 removal verified. Cloud persistence, owner walkthrough, accessibility and physical-device acceptance remain separate.

Use [Page 1 · SpeechCoachAI reusable UI reference](https://www.figma.com/design/B1A9qEN1B7I3NJKISX39Dx?node-id=41-1074) to assemble consistent UI without designing every route and state separately. Its original artwork and screen identity are retained. Product behavior comes from the [UI/UX decisions](ui-ux-design.md), [technical intent](../history/v1/tdd/tdd.md) and feature contracts.

## Agent read order and authority

For any future UI ticket, read this guide before choosing a screen or component. This is a handoff for later authorized implementation; it does not start app work or select a framework.

1. Read [technical intent](../history/v1/tdd/tdd.md), the scoped ticket and its readiness/dependencies in [ticket progress](../history/v1/development-plan/progress.md).
2. Read the relevant [UI/UX decisions](ui-ux-design.md), feature requirements, contracts and acceptance checks linked by that ticket. Use the [screen/state inventory](ui-screen-state-inventory.md) for behavior coverage, including states not individually drawn.
3. Select the Page 1 template, component families and relevant section screenshots below. Inspect the actual visual reference rather than implementing from this guide's descriptions alone.
4. Read later adopted extensions when relevant: [specialized trainers](../history/v1/product-specification/specialized-trainers.md), [course/practice boundaries](../history/v1/product-specification/learning-path-and-practice.md), [award visual system](achievement-visual-design.md) and [award raster assets](../../assets/awards/v1/README.md).

Product decisions and contracts govern behavior; Page 1 governs the retained visual identity and reusable composition. Later adopted requirements can extend the older reference: six illustrated coaches do not establish the seventh trainer's artwork, and a feedback screen does not establish validated pronunciation assessment. Keep existing implementation truth separate from intended changes once source exists. If sources conflict, record the exact references and resolve the affected decision before implementing it; do not silently invent a default or redesign the app.

## Access and screenshot fallback

The active file is `B1A9qEN1B7I3NJKISX39Dx`, Page 1 `0:1`, reference root `41:1074`. Page 2 `25:277` was removed locally. Old expanded-page links in historical reviews/manifests are not implementation targets. The local review evidence below is dated **2026-10-17**; cloud sync was unverified at that checkpoint and is not refreshed by this documentation.

- With a working Figma connection, inspect the relevant template and component masters, instance properties, variants, variable/style bindings, layout constraints and exportable artwork. Record what was actually inspected. For a node link, append `?node-id=2-37969` to the file URL for node `2:37969` (replace the existing query).
- Without MCP, use Figma Desktop and the [local helper instructions](../../tools/figma-local-helper/consolidation/README.md) if available. Confirm the active file/page before any Figma write. Inspection does not require rebuilding the kit or deleting pages.
- Without live Figma access, open the linked local PNGs below and use the [editable backup](../../tools/figma-local-helper/consolidation/review/SpeechCoachAI-Page1-UI-Reference-2026-10-17.fig) for structural inspection when possible. Its [integrity record](../../tools/figma-local-helper/consolidation/review/backup-integrity.json) identifies the saved copy. Record that implementation inputs came from this dated snapshot; do not claim live inspection or cloud persistence.
- Screenshots support composition, hierarchy, artwork and visual comparison. They do not reveal exact token values, constraints, component properties, hit targets, accessibility semantics or interaction behavior. Mark unavailable measurements/assets as unresolved rather than claiming screenshot estimates are inspected values. If a missing input blocks fidelity or behavior, document the scoped gap before dependent implementation.

| Local section screenshot | Inspect for |
| --- | --- |
| [00 · Start here](../../tools/figma-local-helper/consolidation/review/speechcoach-kit-00.png) | Reference usage and scope |
| [01 · Foundations](../../tools/figma-local-helper/consolidation/review/speechcoach-kit-01.png) | Typography, palette and original controls |
| [02 · Shared components/states](../../tools/figma-local-helper/consolidation/review/speechcoach-kit-02.png) | Rows, inputs, statuses and coaching cards |
| [03 · Page templates](../../tools/figma-local-helper/consolidation/review/speechcoach-kit-03.png) | Ten representative compositions |
| [04 · Speaking journey](../../tools/figma-local-helper/consolidation/review/speechcoach-kit-04.png) | Record, review, transcript, feedback and retention |
| [05 · Appearance/characters](../../tools/figma-local-helper/consolidation/review/speechcoach-kit-05.png) | Background directions, theme references and original coach art |
| [06 · Native adaptation](../../tools/figma-local-helper/consolidation/review/speechcoach-kit-06.png) | Regular-width specimen and assembly examples |

Open the relevant images at readable resolution; a folder listing or audit JSON alone is not visual inspection. Audit JSON records structure at its checkpoint, not rendered app behavior. Use `finish-report.json` for the post-removal page list; `report.json` predates removal.

## Canvas map

| Section | Node | Use |
| --- | --- | --- |
| 00 · Start here | `41:1075` | How to choose a recipe and preserve visual identity |
| 01 · Foundations & existing controls | `41:1088` | Original typography, palette, spacing, buttons, switches, answer options and tab bars |
| 02 · Shared building blocks & states | `41:1092` | Content rows, inputs, empty/loading/offline/error states and coaching cards |
| 03 · Page templates | `41:1187` | Ten representative dashboard, list, teaching, activity, mode, vocabulary, progress and settings recipes |
| 04 · Main speaking journey | `41:1222` | Recording, replay/re-record, transcript confirmation, feedback and independent retention; shared submission/offline rules |
| 05 · Appearance & character references | `41:1251` | Three free background directions, independent Light/Dark/System controls and original coach art |
| 06 · Native adaptation & AI assembly guide | `41:1265` | One regular-width iPad specimen, compact-width rules and assembly examples |

## Component selection

| Family | Main component/set | Reuse |
| --- | --- | --- |
| Button | `2:40308` | Existing primary, secondary, disabled, plain and palette variants |
| Switch | `2:40309` | Independent boolean preferences |
| Answer option | `2:40310` | Selected/unselected activity choices |
| Tab bar | `2:40311` | Existing navigation visual references; implement native adaptive navigation |
| Goal summary card | `2:40095` | Time/activity goals |
| Kit / Content row | `41:1105` | Default/selected list entries; editable Title and Detail properties |
| Kit / Input | `41:1127` | Default/focused/error/disabled fields; native editing and keyboard behavior |
| Kit / Status | `41:1155` | Empty/loading/offline/error content; specific recovery action from feature contract |
| Kit / Coaching card | `41:1177` | Teaching, feedback and encouragement |

New kit colors and spacing use scoped primitive/semantic aliases sampled from the original light visual treatment. Existing global variables/text styles remain available. Static dark/background examples do not establish complete theme bindings or runtime accessibility.

## Template and first-flow node selection

These are original frame IDs retained inside the consolidated reference, not separate application routes that must all be built.

| Recipe | Frame node | Typical use |
| --- | --- | --- |
| T01 Dashboard | `2:37969` | Today, daily plan and resume |
| T02 Dashboard detail | `2:38065` | Goal summaries and discoveries |
| T03 Browse/list | `2:38130` | Levels, topics and collections |
| T04 Teaching detail | `2:38212` | Explanations and examples |
| T05 Activity | `2:38252` | Prompt and answer controls |
| T06 Activity retry | `2:38294` | Supportive correction and retry |
| T07 Mode picker | `2:38336` | Practice-mode entry |
| T08 Vocabulary list | `2:38663` | Word search and browse |
| T09 Progress | `2:38732` | Evidence and history |
| T10 Settings | `2:38834` | Preferences and provider entry |
| Speaking · Record | `2:38407` | Deliberate local recording |
| Speaking · Take review | `2:38472` | Replay/re-record |
| Speaking · Confirm transcript | `2:38535` | Recognition versus learner edits |
| Speaking · Feedback | `2:38570` | Capability-specific coaching |
| Speaking · Save sheet | `2:38610` | Independent audio/text retention |

## Component and asset translation

Map each selected Figma family to a reusable native UI responsibility once architecture is selected: for example, Content row serves vocabulary entries with different content, and Status serves each feature's explicit empty/loading/offline/error state. Record the mapping from Figma master/variant to the actual source component and state inputs when those files exist. Reuse does not require a one-to-one wrapper for every Figma layer or a generic engine built ahead of the first slice.

Inspect semantic token bindings and original styles before defining app tokens. Preserve the original palette, typography hierarchy, shapes, artwork and background character; verify font availability/licensing and accessible contrast. An incomplete dark binding is a design gap, not permission to infer a complete theme from one screenshot. Use native editing, focus, safe areas, keyboard behavior, adaptive navigation and accessible semantics. Keep coach, background and Light/Dark/System choices independent.

Export discrete artwork from its editable/source asset where available; record source node/file, format, scale and licensing/provenance. Keep text, controls and state overlays native and editable. Never ship a full-screen screenshot or crop a section export as a substitute for functional UI or missing artwork. The award [manifest](../../assets/awards/v1/manifest.json) maps the 68 delivered base PNGs to AW identities; reuse those assets under the adopted visual rules. Reference-board PNGs and section screenshots are comparison inputs, not an asset catalog. Simplified small-size variants, vectors, native overlays and animation remain separate work.

## Assembly instructions for implementation

1. Select the closest Page 1 template and record its exact node ID in the implementation scope.
2. Reuse the component families above; supply content and explicit state variants rather than inventing a new visual treatment.
3. Read the behavior contracts for provider submission, credential handling, offline/retry behavior, retention, completion and rewards. A visual specimen does not resolve open product decisions.
4. Adapt layout to available width, larger text and keyboard visibility. Use native controls and navigation rather than copying canvas coordinates.
5. Add a new Figma specimen only when an interaction or composition is materially new. Continue tracking all behavior and QA cases in the inventory.

Examples: Vocabulary uses T08 plus Content row, Input and Status. A new lesson uses T04/T05/T06 plus Coaching card, Answer option and Button. Provider settings uses T10 and shared secure-input/confirmation patterns governed by the BYOK contracts.

## Required handoff record and verification

For each future UI scope, add this compact record to the ticket's implementation guidance/completion record. Keep it current as real source paths become available:

```text
Scope / ticket and readiness:
Behavior requirements, contracts and acceptance IDs:
Visual input: file, page, template/frame nodes, snapshot date or live-inspection date:
Component masters, selected variants/properties and token/style sources:
Screenshots actually opened and discrete artwork/manifest entries used:
Mapping to actual source files/components (unassigned until implementation exists):
State coverage: normal, empty, loading, error, offline, interruption/retry as applicable:
Native adaptation: compact/regular width, text size, keyboard, appearance, accessibility:
Conflicts, unavailable inputs and scoped blockers:
Verification evidence and remaining owner/device/provider checks:
```

Compare future rendered UI with the relevant reference at matched viewport size, content, state and appearance; capture app screenshots separately from Figma exports. Review hierarchy, spacing, type, controls and artwork, and explain intentional native adaptations. Check compact and regular widths, larger text, keyboard, all selected backgrounds/themes, contrast, VoiceOver and Reduce Motion in the appropriate runtime/device checks. A similar screenshot cannot establish navigation, recording, offline recovery, retention or provider correctness; run the ticket's separate behavioral acceptance.

Do not mark SC-003 or SC-T007 complete from reading this guide, export counts, helper checks or static comparison alone. Preserve owner walkthrough, native accessibility, physical-device and provider evidence as distinct gates. Missing state frames are addressed through shared patterns and behavioral tests; create another design specimen only for a materially new interaction/composition.

## Verification and history

All 22 original top-level frames/boards are retained inside the reference. Eight component sets and 67 instances were reported. Collapsed container heights, inherited instance labels and the recording indicator wrap were corrected. Seven section exports were visually inspected; corrected components, speaking and iPad examples received targeted follow-up review. The final audit reports no missing originals or horizontal overflow; retained instances do not depend on Page 2 component nodes. Page `25:277` was removed using normal recoverable Figma deletion, and the final page list contains only Page 1 (`0:1`).

Evidence: [final audit](../../tools/figma-local-helper/consolidation/review/finish-report.json), [pre-removal visual-review audit](../../tools/figma-local-helper/consolidation/review/report.json), and seven PNGs in the same folder. Prior expansion IDs in the build manifest and inventory are historical; use the active reference and shared pattern mappings.

An editable [local Figma backup](../../tools/figma-local-helper/consolidation/review/SpeechCoachAI-Page1-UI-Reference-2026-10-17.fig) was saved after removal, with its size and SHA-256 recorded in [backup integrity](../../tools/figma-local-helper/consolidation/review/backup-integrity.json). This preserves the local result while cloud sync is unverified.

This is a reusable design reference, not application implementation, a fully wired app prototype, blanket HIG compliance, or owner/device acceptance. Some retained screens illustrate an interaction while adjacent guidance specifies the fuller request/recovery behavior. No new implementation ticket or provider call was created.

## Adopted award system extension

The owner adopted [achievement visual system v1](achievement-visual-design.md), derived from the retained Page 1 foundations and artwork. Use its [accepted direction board](achievement-visual-proposal-v1.png) and all-68-family subject map for award shell/symbol/tier/state rendering. The board's proposal filename preserves generation history; the direction is now adopted. Continue using Page 1 controls/navigation/text patterns around these emblems.

Do not treat the generated board as 68 editable production assets or as proof of new Figma nodes/native accessibility. Per-lesson/topic/unit milestones remain native checkpoints and metric indicators are not seals. Small-size, dark/background, Dynamic Type, VoiceOver and motion quality require AV/RW verification. No Figma file/page was changed by this documentation adoption.

The 2026-10-20 [raster delivery](../../assets/awards/v1/README.md) adds 68 individual base masters with manifest/provenance; it supersedes any earlier implication that only the concept board exists. It does not add Figma nodes or complete native state/tier composition.

## Scoped first-flow review — 2026-10-21

Use [the SC-T007 readiness record](../history/v1/product-specification/first-flow-design-readiness.md) alongside this guide. It records screenshots actually inspected, backup integrity, exact recipe/component mappings, approved first-launch defaults, required behavior corrections and missing live master/asset inputs. It does not mark SC-T007 complete or verify cloud/native acceptance. Do not inherit sample text-on retention, six-role availability or audio-resubmission copy from the dated boards.

## SC-T007 live audit update — 2026-10-21

SC-T007 is now complete as a scoped design-input review: [live audit](../../tools/figma-local-helper/consolidation/review/readiness-2026-10-21/README.md) captures actual master/property, alias/style, literal fill and discrete image inputs. Use these exact inputs and documented native adaptation rules; dated screenshots are still comparison references, not assets. Owner confirmed Figma-generated coach origin; no independent license/exclusivity certification. Cloud persistence and all app/device acceptance remain separate.
