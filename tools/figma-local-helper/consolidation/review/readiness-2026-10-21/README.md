# SC-T007 live component, token and artwork checks

> Inspected 2026-10-21. Fixed-purpose local plugin; no Figma document writes, app implementation or new artwork. Qualified educator review remains pending.

## Identity and evidence

Figma Desktop showed the exact SpeechCoachAI file URL and Page 1. The local development Plugin API does not expose fileKey here; the inspector records null rather than inventing an API identity. It checks editor type, any available key, SpeechCoachAI document name, current Page 1 ID and retained root 41:1074. Only one Page 1 is reported. See live-report.json and summary.json; source helper at ../../read-only-audit/.

Inspected 2156 nodes, 8 component sets, 67 instances, four variable collections/75 variables, seven text styles and 17 image hashes. All instance main-component IDs resolve within the captured reference. All 17 image hashes have exact image entries in the integrity-verified saved .fig; decoded dimensions/checksums/uses recorded.

## Components and exact inputs

| Family / set | Exposed properties | Verified variant IDs |
| --- | --- | --- |
| Button 2:40308 | Label#2:13: TEXT; Style: primary/secondary/disabled/plain; Configuration: 1/2/3/4/5/6/7 | 2:40073 Style=primary, Configuration=1, 2:40076 Style=secondary, Configuration=2, 2:40079 Style=disabled, Configuration=3, 2:40122 Style=primary, Configuration=4, 2:40149 Style=primary, Configuration=5, 2:40176 Style=primary, Configuration=6, 2:40251 Style=plain, Configuration=7 |
| Switch 2:40309 | State: on/off | 2:40082 State=on, 2:40085 State=off |
| Answer option 2:40310 | Label#2:14: TEXT; State: unselected/selected; Configuration: 1/2 | 2:40279 State=unselected, Configuration=1, 2:40283 State=selected, Configuration=2 |
| Tab bar 2:40311 | Configuration: 1/2/3/4/5/6/7/8 | 2:40119 Configuration=1, 2:40146 Configuration=2, 2:40173 Configuration=3, 2:40200 Configuration=4, 2:40224 Configuration=5, 2:40248 Configuration=6, 2:40275 Configuration=7, 2:40307 Configuration=8 |
| Kit / Content row 41:1105 | Title#41:4: TEXT; Detail#41:5: TEXT; State: Default/Selected | 41:1099 State=Default, 41:1102 State=Selected |
| Kit / Input 41:1127 | Title#41:14: TEXT; Detail#41:15: TEXT; State: Default/Focused/Error/Disabled | 41:1115 State=Default, 41:1118 State=Focused, 41:1121 State=Error, 41:1124 State=Disabled |
| Kit / Status 41:1155 | Title#41:24: TEXT; Detail#41:25: TEXT; State: Empty/Loading/Offline/Error | 41:1143 State=Empty, 41:1146 State=Loading, 41:1149 State=Offline, 41:1152 State=Error |
| Kit / Coaching card 41:1177 | Title#41:30: TEXT; Detail#41:31: TEXT; State: Default/Selected | 41:1171 State=Default, 41:1174 State=Selected |

Configuration numbers are historical visual specimens, not a complete Cartesian product of Style/Configuration and not application state IDs. Label#… and Title#…/Detail#… property keys are captured verbatim in components.json. Four shared families really expose editable text and State variants. Original control fills are mostly literal values (e.g. primary Button 2:40073); do not claim these originals are variable-bound. Switch visual is 51 × 31, so native hit areas must be at least the project 44 × 44 target; no stretching of its artwork is implied. Main first-flow frames are 393 × 852; these are reference canvas dimensions, not fixed device layout.

## Token resolution and native appearance handoff

resolved-tokens.json preserves all variable IDs, collections, modes, alias targets, actual values and readable hex. All aliases resolve locally without cycles/missing targets. Each collection has a single Mode 1. Theme has explicit light and Dark aliases; Kit semantics is light-baseline only. No automatic Light/Dark mode binding is present. Do not confuse scoped tokens with identical names in different collections.

| Role | Verified Theme light | Verified Theme dark |
| --- | --- | --- |
| background | #F7F4EC | #142421 |
| surface | #FFFFFF | #213531 |
| text | #213D39 | #F4F6EF |
| secondary | #526963 | #BDCFC8 |
| accent | #176C60 | #9AD3B9 |
| soft | #E1EBE3 | #2D4940 |
| onAccent | #FFFFFF | #142421 |
| border | #BBCDC3 | #55756A |
| danger | #A83132 | #FFB6B5 |
| atlas | #EDF4FA | #172935 |
| studio | #F1EFF8 | #242139 |
| gold | #73511D | #F3CF84 |

Kit semantic aliases resolve to canvas #F7F4EC, ink #213D39, accent #176C60, white #FFFFFF, muted #526963, soft #E1EBE3 and error #9B3D35; spacing 8/16/24, card radius 18, control radius 12. New shared components bind padding 16, gap 8, radius 18 and state-specific white/soft fills to these actual aliases. They are reference constraints; native control sizing/text reflow takes precedence. Actual text styles (IDs and metrics) are in live-report.json: body 17/23, headline 17 semibold/23, title 32/38, hero 24/30, caption 13/18; kit body 17 at 135%, kit headline 20 at 130%. Four SF Pro weights appear in the saved reference. Native system text roles preserve this hierarchy and scale, rather than bundling font files.

Documented native adaptation: resolve System appearance at runtime, keeping background and coach independent. Canvas uses Theme background/backgroundDark (or atlas/studio pairs for those styles). Content surfaces, text, secondary text, action/on-action, soft selection, border and destructive/error roles use their corresponding verified Theme light/Dark pair. For the Kit light Error specimen preserve its exact #9B3D35; its dark semantic adaptation uses the existing Theme dangerDark #FFB6B5 on surfaceDark. This mapping is a documented adaptation from inspected source roles, not a claim that the Figma components already switch themes. Preserve opaque foreground surfaces and original artwork proportions; no invented dark artwork or new environment assets. Actual visual/accessibility comparison remains SC-T010–SC-T017.

contrast-pairs.json contains computed opaque source-token pairs only. Primary/secondary/action/error text pairs shown there exceed 4.5:1. Borders may be below 3:1 and must not be the sole affordance for an input or selection; native control boundaries/focus/text labels must be verified. No claim of full WCAG/HIG compliance, rendered contrast, opacity/backdrop safety or complete disabled-state coverage.

## Artwork source and provenance

artwork-manifest.json connects every live image hash/use/node ancestry to source-images/<hash>.jpg and a SHA-256. These are exact discrete original image files from the saved archive, not crops of a screen or AI regenerations. All 17 are opaque JPEGs with baked paper/cream backgrounds; use the original opaque artwork cards, never assume transparency. No extracted image was modified. The gallery is a source review aid, not production/runtime visual proof.

Owner confirmed on 2026-10-21 that the original Page 1 coach images were generated for SpeechCoachAI in Figma. This fills the origin record with owner attestation; original generation prompts/model/service-term snapshot were not recovered. Technical source trace is verified; independent authorship/exclusive copyright or legal/license certification is not claimed. Existing award PNG provenance remains separate and unchanged.

| First-flow role | Original source / node |
| --- | --- |
| Teacher greeting / initial presenter | b09098c10015eb7a22310223135c8e03ede0fba3, node 2:37997; same source in appearance and native-adaptation examples |
| Teacher lesson specimen | fb24dc564c555e10d121cda844a3fc7001835d18, node 2:38231 |
| Speaker Speech Lab welcome | 62901042eaa0f3394d25af1a13420c345f362ecd, node 2:38354 |
| Speaker feedback | 9bc3ddd4ed1ed7ee3884a74d145895d22e4db04b, node 2:38587 |
| Speaker completion/save context | 1b66bd3fce2c616484574542dc7aa829a05a0775, node 2:38626 |
| Initial Teacher selection portrait | 91e7aedb2b987a46192ed30ac5679078c6d3920b, node 2:39259 |

First-flow presenter selection must use the selected role’s verified art rather than the sample screen’s fixed Parrot. The existing Teacher greeting/portrait supplies the approved initial presenter without new artwork. Full seven-trainer identity/pack delivery and any refined style-specific environment art stay under existing later scope; no new asset creation is authorized by this audit. Do not invent Creative Writer art from the six-role board.

## Readiness decision

The previously missing first-flow component/property, literal-versus-bound token and discrete artwork/source-provenance inputs have now been inspected and recorded. Owner already accepted the corrected behavior/layout direction and defaults. SC-T007 can close as this bounded design-input review with the explicit appearance/native/asset-use mappings above. It does not require a Figma rewrite or a new frame per state.

Remaining gates are existing work: SC-T010–SC-T017 native adaptation, actual dark/selected/disabled contrast, hit targets, Dynamic Type/VoiceOver/keyboard/Reduce Motion, recording/privacy/provider behavior and owner device usability; SC-T044 seventh-role artwork and packs; SC-T025 full award production/motion; SC-T006 qualified educator review remains blocked. Cloud persistence still UNVERIFIED; verified backup plus current local inspection is the permitted input. SC-T008 still awaits setup review and explicit development authorization. No product expansion or app source created.

All 17 discrete source images were visually reviewed in the contact sheet; initial Teacher greeting/selection and Speech Lab artwork were additionally opened full-size. Border-cue interpretation follows [W3C non-text contrast guidance](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html); token math is not blanket control compliance.
