# Figma iPhone Design Review

> v2 (2026-10-25): design record kept as is. The visual design is retained in v2.

> Status: IN_PROGRESS — approach updated 2026-10-17. Editable drafts are not final owner acceptance, full HIG compliance, or application implementation. The dated October 16 inventory below is historical evidence, not a current full-canvas audit.

[SpeechCoachAI · iPhone UI Design](https://www.figma.com/design/B1A9qEN1B7I3NJKISX39Dx) is the current design file. It was initially created through the signed-in Figma browser when plugin editing tools were unavailable; editing tools became connected on October 17. No sharing permissions or paid plan were changed by this documentation update.

## Current result: Page 1 consolidated, Page 2 removed

Completed through Figma Desktop and the local helper on 2026-10-17, without additional MCP calls. [Page 1 reference](https://www.figma.com/design/B1A9qEN1B7I3NJKISX39Dx?node-id=41-1074) contains seven organized sections: usage, original foundations/controls, shared components/states, ten template recipes, the main speaking journey, appearance/character references and native adaptation/AI assembly guidance. All 22 original frames/boards retain their IDs and artwork. Eight component sets and 67 instances are present.

Visual review of all seven section exports exposed collapsed horizontal-container heights and repeated instance defaults; both were corrected. State examples now distinguish focused/disabled/error and empty/loading/offline/error content. Recording-label wrap and quiet-practice copy were corrected. Targeted post-fix exports passed visual review. The [final audit](../../tools/figma-local-helper/consolidation/review/finish-report.json) reports 22 retained originals, no missing originals or horizontal overflow, no retained Page 2 component dependencies and removal of page `25:277`; the resulting page list contains only Page 1 (`0:1`).

Use the [UI reference guide](ui-reference-guide.md) for exact section/component IDs and assembly instructions. SC-003 remains in progress for owner/native/accessibility acceptance. Application implementation and provider/device proof remain NOT_RUN. Figma's latest desktop state still reports pending reconnect/sync; **cloud persistence is UNVERIFIED**. A local editable `.fig` backup was saved after removal and its integrity recorded alongside the review exports. The connection-failure and pre-consolidation notes below are historical and superseded by this local result.

## Earlier local-plugin evidence, 2026-10-17

### Latest owner correction: one reusable reference page

The owner requested retaining Page 1, removing Page 2, and improving Page 1 to cover reusable foundations, components, page templates/main parts and the speaking journey, with clear AI usage recipes. This supersedes the earlier instruction to refine every expanded Page 2 screen. The inventory remains a behavior/QA coverage tool, not a requirement to polish one frame per entry.

Live local inspection confirmed Page 1 (`0:1`) contains 20 original screen frames plus its foundations and reusable-component boards, four component sets (Button, Switch, Answer option, Tab bar), a goal-summary component, SF Pro text and five shared text styles. Both pages were still present at inspection. A separate [Page 1 kit helper](../../tools/figma-local-helper/consolidation/README.md) was imported and its read-only inspection ran. The construction bundle was subsequently prepared and syntax-checked; **kit construction, visual validation and Page 2 removal are NOT_RUN / unverified**. The connector reports its Starter tool-call limit. Desktop automation then repeatedly failed to act reliably, including `noWindowsAvailable` for coordinate actions and an inaccessible plugin iframe. The original canvas remains the last verified design state. Figma still warns that some changes await reconnect; cloud persistence is unverified.

The rest of this section and the dated expansion records below describe the earlier work; they do not override the new reduced design scope.

**Desktop retry:** native-menu launches and local helper execution were retried. Export save dialogs appeared, but no review file could be saved. An explicit plugin-console diagnostic then reported `Unable to establish connection to Figma after 10 seconds. Please check your internet connection.` This supersedes the tentative inference that reaching export dialogs proved successful construction. Page 1 consolidation remains unverified, and Page 2 remains visible/not verified as removed. Reconnect Figma before continuing; preserve unsynced work.

Desktop access now works. The local helper ran successfully: repaired documented routing (including separate text/vocabulary disclosures and independent retention choices), added a replacement-take capture specimen, built four iPad layouts, reused Page 1 coach artwork on 13 introduction/dashboard/feedback/milestone/theme frames, and added distinct editable motifs to six theme previews. Page 1 was preserved.

Thirteen further specimens cover keyboard-visible typing/correction/open response, larger-text Today/save/recording, nickname validation, duplicate words, unavailable audio, empty recognition/generation, compact width and visible keyboard focus. There are **167 expansion frames**: the original 149 plus 18 local additions. Exact additional IDs and latest audit are in the build manifest; original 149 frame IDs remain stable.

The local audit reports all 149 base frames present, zero unlinked action buttons, 775 prototype connections and no invalid destinations. This is structural evidence only; it does not prove all branches, the added-frame interactions or the 16 walkthroughs. The helper's sample lesson sequence still needs per-exercise feedback review.

Visual exports exposed collapsed iPad text and keyboard key rows. Targeted fixes were applied and re-exported: iPad Learn now has readable sidebar/content/reference panes; the keyboard-visible missing-word screen has legible keys and actions above the keyboard; the larger-text save screen reflows with separate audio/text controls. The other specimens still need individual readable-scale review. These exports and the audit JSON are stored with the helper.

**Persistence boundary:** Figma reports changes saved locally, waiting to sync when reconnected. Latest cloud persistence is unverified. Earlier desktop-ID and missing-plugin-runtime notes below are historical and superseded by this run. Visual polish to Page 1's standard, complete background artwork, full theme/accessibility coverage and owner walkthrough acceptance remain unfinished.

## Page roles and visual review

Owner clarification, 2026-10-17: **Page 1 remains the preferred visual reference.** Preserve its original character artwork, personality, backgrounds and polished composition, with its typography, colors and spacing informing the expanded screens. This is a visual-direction preference, not blanket acceptance of every Page 1 detail.

**Page 2 (`02 · Complete flows & states`, page ID `25:277`) was the superseded expansion draft and is now removed.** Its repeated, simpler layouts were built for coverage. Do not recreate or continue polishing all its frames by default; the owner selected one reusable Page 1 reference.

Page 2 remains an unfinished design draft. A named frame, a linked action or coverage of a screen family does not establish that all states are complete, the journey is usable, or the visual design is accepted. This documentation update does not independently audit the current canvas or upgrade coverage statuses.

## Committed expansion evidence, 2026-10-17

The connected tools populated **149 new editable frames** on [Page 2](https://www.figma.com/design/B1A9qEN1B7I3NJKISX39Dx?node-id=25-277): representative drafts for all 70 inventory families plus 79 state variants. Page 1 was preserved and remains the preferred visual reference. The [build manifest](figma-build-manifest.json) records every new frame ID, direct link and the current verification boundary.

Four committed content batches returned frame bounds and text/instance counts. Actions, switches, answer choices and tab bars reuse existing components. Shared SF Pro styles and aliased brand variables were added with explicit scopes and iOS syntax. The Starter file permits one variable mode, so separate light/dark variables support the six palette specimens.

Today and multiple-choice screenshots were reviewed at readable scale. Primary-label wrapping was corrected across 58 first-batch action labels; a subsequent native-browser overview showed the corrected single-line labels and populated expansion page. Longer content intentionally scrolls within fixed action regions. This is partial visual evidence, not an audit of all frames.

The final connector inspection was blocked by the **Figma MCP Starter tool-call limit**, separate from Figma AI credits. Manual input then reported changed-app errors. The attempted manual iPad SVG import was not confirmed and is excluded from the 149-frame count.

Known unfinished work:

- Rewire earlier actions to later-created state variants and verify all 16 walkthroughs, including the multiple-choice result. The prototype is only partially connected.
- Route vocabulary generation and typed coaching through their dedicated disclosure variants; their earlier draft actions still lead to the shared recording disclosure.
- Wire save switches among the four retention specimens and complete countdown, replacement-take acceptance and failure branches.
- AX-03 is a 393 × 852 reference placeholder, **not a completed iPad adaptation**. Regular-width split layouts, compact-width and hardware-keyboard specimens remain.
- Add keyboard-visible, validation, long-content and further large-text states. Representative family presence does not complete every state in the inventory.
- Carry Page 1 artwork and composition into Page 2. New appearance specimens cover palette/theme combinations; original environment artwork, coach integration and final visual polish remain draft.
- Complete readable-scale visual, contrast, target-size, native-sheet and assistive-focus checks. No runtime, provider or physical-device acceptance was performed; OPEN product contracts remain open.

The dated October 16 tables retain the historical gap audit. Current frame presence is recorded separately in the manifest and inventory JSON; it does not upgrade final design acceptance.

## Project-local desktop helper, 2026-10-17

The owner installed and signed into Figma Desktop. A dependency-free [local plugin](../../tools/figma-local-helper/README.md) was prepared to inspect the existing file, repair documented routes and independent retention switches, build three regular-width iPad specimens plus a portrait learning specimen, and export screenshots. The plugin has no network access, generic script execution or node-deletion operation. It checks the existing page/onboarding anchor before editing Page 2.

`build.mjs` and `verify.mjs` passed local checks for 149 definitions, all routing destinations, disclosure separation, all four retention choices, explicit recording start, network/destructive-operation guards, wrong-file rejection and bundled JavaScript syntax. **Figma runtime execution is NOT_RUN.** These checks do not change the committed-frame inventory or establish that route/iPad repairs occurred.

Native app discovery reports the running bundle `com.figma.Desktop`; app binding rejects it as Invalid app, while name/path binding instead targets the unavailable `com.figma.Desktop.dua`. This is a desktop-control registration mismatch after installation, not a Figma login failure. Manual plugin import/run or refreshed desktop-control registration is needed before runtime evidence can be collected. Preserve Page 1 as the preferred visual reference.

## Engineer handoff

Start with the [current agent UI handoff guide](ui-reference-guide.md) for exact node and screenshot mappings, component/asset translation, access fallbacks and the required ticket record. Dated runtime/access failures below or above are historical checkpoints; they do not override the verified local consolidation described at the top.

The frontend/UI/UX engineer should combine the following inputs:

| Input | How to use it |
| --- | --- |
| Page 1 and subsequently reviewed visual refinements | Reference for visual identity, composition, artwork, typography, color and spacing. |
| Page 1 templates, main parts and speaking journey | Select the nearest reusable recipe and components; document which pattern serves each implementation scope. Expanded Page 2 links are historical and should not become new dependencies. |
| Reusable components and tokens | Inspect actual instances, bindings and properties; reuse consistent buttons, cards, switches and selected/disabled/loading/error states. Do not infer reuse merely from visual similarity. |
| Appearance and platform specimens | Guide all three backgrounds, Light/Dark/System, larger text and iPad adaptations. Static examples do not prove runtime adaptation. |
| Product decisions, technical intent and contracts | Define rewards, retention, offline behavior, provider requests and other behavior that visuals cannot fully specify. Resolve blocking open decisions before coding the affected behavior. |
| Native Apple HIG skill and current official guidance | Guide native navigation, controls, accessibility and platform behavior while preserving the app's visual identity. |

For each implementation scope, record the exact Figma frame/component IDs and relevant behavior-doc links. Inspect editable structure, properties, measurements and discrete assets through the connected Figma tools; use screenshots for visual comparison. Translate design intent into native controls and adaptive layouts rather than copying fixed canvas coordinates. Generated code or Figma properties do not select the implementation stack or establish correct framework APIs.

Before handoff, inspect the consolidated Page 1 reference, shared normal/empty/error/loading/interrupted patterns and main speaking journey. Page 2 removal was already verified locally on 2026-10-17; do not repeat deletion or use its historical nodes. Preserve original artwork and component dependencies, and record the selected retained node IDs. Use product contracts for behaviors not individually drawn. During implementation, compare the running UI with the reviewed design and separately validate navigation, data behavior, iPhone/iPad adaptation, larger text, VoiceOver, contrast and reduced motion. Keep visual approval, implementation verification and physical-device acceptance distinct. This guidance creates no implementation ticket and authorizes no app implementation by itself.

## Observed inventory, 2026-10-16

Twenty screen frames plus a foundations board and a reusable-components area are visible in the layer panel:

- Today: Creative Academy, Goals and discoveries, Adventure Atlas, Mixed-Media Studio, Creative Academy dark.
- Learn: Open levels.
- Lesson: Explanation, Choose an answer, Gentle retry.
- Speech Lab: Modes, Recording, Take review, Confirm transcript, AI feedback, Save sheet.
- Vocabulary: Your words.
- Progress: Your learning rhythm.
- Profile: Settings.
- Appearance: Styles and theme.
- Coaches: Everyone is welcome.

The Today frame is an editable vertical auto-layout frame at 393 × 852. The native Select all text layers command selected 578 text layers after component creation; this confirms substantial editable text rather than a complete-screen raster. Full semantic structure, variable bindings, instance reuse and prototype wiring have not been programmatically audited.

## Review and corrections, 2026-10-16

Six literal backslash-n strings were replaced in headings using Figma Find/Replace. The Today heading was visually verified afterward without the escape string. It shows a connected 23-minute plan, Resume/Choose another, quiet-practice switch and five labeled navigation tabs.

Owner explicitly authorized accepting the Apple SF Pro license and applying the font. On resuming, the license dialog was already closed and the font-family control showed SF Pro for all 578 selected text layers. No additional license acceptance click was necessary or performed in this resumed turn. Today, Save sheet and Appearance were visually inspected after the change; no obvious text clipping was observed on these three frames. This is not a full-screen or Dynamic Type audit.

## Limitations recorded on 2026-10-16

These observations describe the initial browser-generated draft. They must be refreshed against subsequent editing before being presented as current blockers or completed work; Figma AI credits are not required for direct plugin editing.

- Figma reports exhausted daily AI credits, disabling further prompts. Existing generated work is present; the task eventually reported Prompt was unsuccessful. Do not treat its generated first pass as a completed quality audit.
- Figma has reported intermittent connection/sync warnings; cloud persistence of the latest changes must be confirmed before final handoff.
- SF Pro is verified for the 578 selected text layers; broader text-size, weight, reflow and accessibility checks remain pending.
- Inspect/fix quiet-mode copy: Today currently says Listening & typing. No mic needed; it should explain silent practice without implying automatic audio.
- Save sheet visually verified: separate Keep this recording and Keep transcript and feedback switches, Save selected and Don’t save anything. Example shows audio off/text on; default text opt-in policy still needs review.
- Appearance visually verified: all three free background choices and independent Light/Dark/System control. Verify all unlocked coach roles, native tab behavior, contrast, body typography, touch targets and safe areas at readable scale.
- Onboarding, provider/key disclosure, offline/error/interruption states, vocabulary recall/rating states, reward/tool details, larger-text layouts and iPad adaptations are not verified as delivered. Add missing states rather than claiming the initial inventory covers all requirements.
- Background styles need original environment artwork refinement beyond palette variants; reviewed characters/assets and final copy remain draft.
- Generated sample calendar text is illustrative and must not be mistaken for verified current-day UI.

Source of intent: [UI/UX decisions](ui-ux-design.md) and [interview audit](../history/v1/product-specification/ui-ux-interview-audit.md). No new implementation ticket, app code, provider call, or physical-device acceptance occurred.

## Coverage inventory, 2026-10-16

The [screen/state inventory](ui-screen-state-inventory.md) maps current requirements to 70 families: 3 have a specific visual check, 12 have a named observed frame, 6 have only partial evidence, and 49 have no verified matching design. These are family coverage labels, not counts of finished screens. Evidence uses the last recorded canvas observation and has not been refreshed by this documentation task. The inventory provides remaining design batches and walkthroughs; none of those gaps were filled in Figma by writing the inventory.

## SC-T007 dated-snapshot review — 2026-10-21

Current review used the six relevant consolidated section PNGs, historical audit/builder sources and integrity-verified saved .fig backup; no live Figma read/write occurred. [First-flow readiness](../history/v1/product-specification/first-flow-design-readiness.md) records required copy/state corrections, native adaptations and pending master/property/asset/provenance/owner-walkthrough gates. Cloud persistence remains unverified. Do not interpret earlier saved locally/578-font history as current structural/asset acceptance.

## SC-T007 live audit update — 2026-10-21

SC-T007 live read-only audit completed on actual SpeechCoachAI file/Page 1. Eight component sets, 75 variables, 67 resolvable instances and 17 image sources recorded; all images match exact entries in the integrity-verified local backup. Owner confirmed Figma generation for this project. See first-flow-design-readiness.md and its evidence links; no design writes, asset regeneration, cloud-sync verification or app runtime acceptance.
