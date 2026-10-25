# First-flow design readiness — SC-T007

> Current readiness and remaining-choice authority: [consolidated readiness review](../development-plan/readiness-review.md). Dated earlier pending statements are historical where superseded by recorded approvals; they are not additional start gates.
> Reviewed 2026-10-21 using the dated local 2026-10-17 Page 1 snapshot. Owner accepted this documented direction on 2026-10-21 while retaining listed open checks. Read-only live Figma component/token/image inspection completed later on 2026-10-21; see the evidence update below. No Figma document write or app implementation occurred.

## Scope and inputs

Purpose: prepare navigation/settings and the internal introduction record → replay → explicit ASR → confirm text → explicit coaching → retry/self-review → independent save journey. Platforms: native iPhone/iPad, minimum OS 17. INTRO-01 teaching follows later under existing tickets; no new feature scope. Owner confirmed Creative Academy first-launch background, System appearance and Elephant Teacher initial presenter on 2026-10-21. All remain independently changeable; required CEFR course is invariant across presenters.

Visual input: Figma file B1A9qEN1B7I3NJKISX39Dx, Page 1 0:1, reference root 41:1074. Opened local section screenshots 01 foundations, 02 shared states, 03 templates, 04 speaking, 05 appearance/characters and 06 native adaptation at readable resolution; reviewed audit/kit-builder sources as historical structure evidence. Local .fig backup matches recorded 7,620,066 bytes and SHA-256 f739ad80b829712247192c846f39b284153d60f2295a921724a2ca4e84932a92. ZIP members include canvas and image assets; archive presence does not establish discrete asset mapping/export rights. Cloud sync remains unverified. Page 2 is not a target and was not reopened/recreated.

## Navigation shell and references

| Future scope | Page 1 recipe / exact frame | Shared components / relevant states | Selected future source responsibility |
| --- | --- | --- | --- |
| SC-T010 shell / first entry | T01 2:37969, T07 2:38336 | Tab bar 2:40311; Button 2:40308; Content row 41:1105; Status 41:1155 | Features navigation/preferences, no fake completed destinations |
| SC-T012 provider/settings | T10 2:38834 | Input 41:1127, Switch 2:40309, Button/Status | Features settings; Infrastructure Keychain/provider; no key in visible diagnostics |
| SC-T011 capture | Record 2:38407 | Button; Status; recording indicator and accessible duration | Features speech; Infrastructure Audio |
| SC-T011 review / SC-T015 history | Take review 2:38472 | Button; Coaching card 41:1177; Content row; Status | Features speech/history; local file/metadata repositories |
| SC-T013 confirmation | Confirm transcript 2:38535 | Input; Button; Status | Features speech transcript review; immutable domain revisions |
| SC-T014 feedback | Feedback 2:38570 | Coaching card; Button; Status | Features feedback; complete validated text domain values |
| SC-T015 retention | Save sheet 2:38610 | Two independent Switch controls; Button; Status | Features history/retention; deletion journal/domain operations |
| SC-T020 lesson later | T04 2:38212, T05 2:38252, T06 2:38294 | Coaching card, Answer option 2:40310, Button/Status | Features learning; reviewed resource pack |

These are planned responsibilities under application/SpeechCoachAI, not existing components or file declarations. Exact component/variant/token-to-source mapping must be recorded before affected UI coding. Dated audit reports 7 Button, 2 Switch, 2 Answer option, 8 Tab bar, 2 Content row, 4 Input, 4 Status and 2 Coaching card variants; it does not expose current live properties. Historical kit.js describes State variants and editable Title/Detail text; its creation-time aliases and values cannot substitute for inspecting the saved masters/bindings. Do not infer measured spacing/constraints from raster size.

## Primary content and corrections to carry forward

Retain cream/teal/ink surfaces, readable native type hierarchy, cards, rounded controls and original mixed-media artwork. Use the Apple system font through native text styles, matching hierarchy and weight; never bundle downloaded SF Pro font binaries. Prior Figma license/application evidence is historical; native system-font access avoids treating font files as redistributable app assets. No redesign or full-screen-image implementation.

| Observed dated specimen | Required behavior in the handoff |
| --- | --- |
| Recording prompt asks about a small win, includes decorative waveform and elapsed time | Replace sample content with approved introduction task; meter only actual local input, never imply sound analysis from static art; use approved 1–120 s proof/countdown off |
| Confirm text specimen says continuing sends this take and confirmed transcript | Correct disclosure: ASR sends chosen audio first; later text coaching sends confirmed text/task preferences only. Separate explicit requests, provider/data/charge disclosure, no resend of audio with text |
| Feedback always shows two improvements | Up to two grounded improvements, valid zero-correction output; text-only speech status not assessed |
| Save specimen has audio off/text on | This is an example state, not consent/default. Both initially off under opt-in retention; confirm independent choices, save failure and discard outcomes |
| Cast/settings specimen says six coaches/all modes available | Seven adopted roles, no locks; unavailable internal packs/modes labeled truthfully, not promised available by an illustration. Creative Writer identity/artwork remains unresolved |
| Retry specimen reveals the answer immediately | First-topic answer-reveal/repeated-error policy remains content/SC-T020 design work; do not infer it from a static sample |
| Fixed phone safe-area dimensions and baseline type sizes | Use runtime safe areas, native controls and scalable text; do not hardcode specimen status-bar heights or scale a phone canvas onto iPad |

## Supporting patterns and state contract

Normal: user deliberately starts recording, sample answer hidden unless requested, pause/resume only for voluntary pause; stop returns to review. Re-record preserves current take until replacement accepted. Finish self-review works without key/network; selecting a quiet alternative records text-only evidence. Self-review notes are private payload and follow explicit retention choice.

Empty/unavailable: keep five navigation destinations stable and explain unavailable internal content. A selectable presenter is not an available specialty pack. New take/resume and saved-history entry use the same attempt identity. In CEFR lesson context, presenter switching changes presentation only; separate optional specialist entry saves course position and returns there. Frozen assessment support/content cannot silently change.

Loading: describe actual ASR/coaching stage, provide Cancel and preserve local practice; no invented percentage. Error/offline: expose typed recovery, replay/self-review and explicit retry with possible-charge explanation; never upload on reconnect. Missing key offers setup or offline route. Malformed/oversize/stale response cannot replace valid prior data.

Interruption/lock/background/route loss: finalize recoverable partial take, stop microphone, require a fresh take to continue, never silently restart. Restore the interrupted take only before its approved 24-hour deadline; unavailable protected files require unlock. Ask before abandoning active recording; dismissing a presentation must not silently destroy recovery data. Separate confirmable permanent purge from recoverable trash.

Retention: present both independent choices with clear outcome for neither/audio/text/both, preserve self-review regardless of optional AI success; show durable save failure honestly. Recently Deleted supplies restore, 30-day expiry and permanent purge per SC-T004. No key field in export/history. Purge hides private material immediately while cleanup may be pending; credit/evidence distinctions remain SC-T024/025.

## Native adaptation and accessibility

Compact iPhone or narrow iPad windows use a single content column, five native labeled destinations and navigation stacks; temporary capture/review can be self-contained presentations with explicit Close/Finish. Regular iPad windows use available space for browse/content and optional reference/feedback alongside; collapse at narrow width or large text, preserving selection and source context. Preserve approved destination names rather than fixed canvas coordinates. On OS versions offering native tab/sidebar adaptation use the appropriate available system behavior; OS 17 gets supported navigation composition, not unavailable newer APIs. Exact API availability remains implementation verification.

Dynamic Type/Bold Text: native text roles, multiline labels, vertical action stacks when needed, no clipped transcript or capped readable feedback. Keyboard: scroll active input/actions into view; secure provider entry with reveal deliberately controlled, no screenshot/log exposure; keep cancel/back reachable. VoiceOver: logical heading/prompt/control/status order; meaningful action labels, recording state/duration at useful intervals rather than every meter frame, separate transcript original/edit labels, feedback category/evidence/limitations, independent save switches and destructive-action purpose. Decorative art ignored by accessibility; no sound/color-only status. Gesture actions have visible alternatives.

Reduce Motion/quiet: no background motion during reading/typing/recording, no decorative motion needed to complete tasks; static equivalents and usable immediate actions. Do not auto-play coach/reference audio in quiet mode. Contrast and targets must be measured in actual render across selected backgrounds/Light/Dark/System; minimum project control target 44 × 44 pt, never inferred from screenshot pixels. Full award/motion production and AV/RW evidence remain with SC-T025, not this first-flow design-input review.

Sources: local Apple HIG skill articles for tab bars, iPadOS, accessibility and typography; [current tab-bar guidance](https://developer.apple.com/design/human-interface-guidelines/tab-bars), [accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility) and [font guidance](https://developer.apple.com/documentation/technologyoverviews/fonts) checked 2026-10-21. Native font redistribution/usage restrictions and runtime API availability are distinct from static HIG intent.

## Live component/token/artwork audit and closure — 2026-10-21

The [live audit record](../../../../tools/figma-local-helper/consolidation/review/readiness-2026-10-21/README.md) supersedes earlier inspection limitations in this document. Figma Desktop URL confirmed the exact SpeechCoachAI file/Page 1; a fixed-purpose read-only local plugin captured 2,156 nodes, eight component sets/actual property definitions, 67 resolvable instances, four collections/75 variables, seven text styles and 17 image hashes. The Plugin API omitted fileKey; the record distinguishes that limitation from UI-confirmed identity and matched document/page/root guards. No document mutation or selection change was performed by the inspector.

[Components](../../../../tools/figma-local-helper/consolidation/review/readiness-2026-10-21/components.json) record full property keys, variant IDs, measured reference geometry and bindings. [Resolved tokens](../../../../tools/figma-local-helper/consolidation/review/readiness-2026-10-21/resolved-tokens.json) distinguish collection-scoped aliases from literal original-control values. All aliases resolve. Theme light/Dark pairs exist, but Kit has a single light-baseline mode; the audit documents a native semantic mapping using inspected existing Theme values, not automatic Figma theme behavior. Actual rendered states/accessibility remain implementation verification.

[Artwork manifest](../../../../tools/figma-local-helper/consolidation/review/readiness-2026-10-21/artwork-manifest.json) maps all 17 live hashes/21 uses to exact discrete source JPEGs from the integrity-verified saved .fig. All decode with recorded dimensions and SHA-256. The contact sheet of all 17 was visually inspected, along with full-size first-flow greeting/portrait/Speech Lab assets. Images have opaque baked paper backgrounds, not transparency; preserve their card treatment and aspect ratio. No screenshot crop, image regeneration or image-file modification was used. Source exports are audit inputs, not an app asset catalog already installed in a target.

Owner confirmed on 2026-10-21: the original Page 1 coach images were generated for this project in Figma. Record this as owner-attested origin/project reuse, not independent copyright or license certification; original model/prompt/service-term records were not recovered. No new artwork or rights claim was invented. First-flow initial Teacher art is available from existing originals; Creative Writer/full-seven-trainer art remains later scope.

Owner already accepted the documented corrected behavior/layout direction and initial defaults. SC-T007 is now done as a bounded design-input review. The evidence record makes adaptation decisions and source properties explicit so affected work need not guess tokens or crop screenshots. Source border pairs at approximately 1.66:1 light and 2.56:1 dark must not be the sole control/state cue; native boundaries/focus and labels are mandatory verification inputs. The measured switch visual is 51 × 31; preserve it within an adequate native touch target rather than treating its visible dimensions as the hit area. Static token math is not full rendered compliance.

Remaining existing gates: SC-T010–SC-T017 native theme/state contrast, Dynamic Type/VoiceOver/keyboard/Reduce Motion, touch targets, audio/privacy/provider behavior and owner device usability; SC-T025 full AW/native motion; SC-T044 seventh-role/full trainer work. SC-T006 is owner-approved without a qualified educator review. Cloud sync remains unverified, with the verified backup and local read-only inspection available as the permitted handoff. SC-T008 awaits setup review and explicit owner development authorization. No app scope expansion or application implementation.
