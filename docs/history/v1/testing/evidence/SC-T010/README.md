# SC-T010 navigation and preferences evidence — 2026-10-21

Implementation exists. The ticket remains **in_progress**. iPad (A16) simulator dark appearance, larger text, and Today contrast passed in `application/.build/speaking-ipad-contrast-v1.xcresult` after the selected sidebar row was drawn with OnAccent on the accent fill. Physical iPad, manual VoiceOver, and owner accessibility acceptance are still open. Do not infer full accessibility acceptance from the simulator scan.

Native five destinations adapt to tabs on compact layouts and a sidebar on regular layouts. Settings persist background (explicit preview/Apply), appearance, seven-role coach and countdown independently. Session coach/quiet overrides preserve frozen defaults/source IDs. Unimplemented curriculum, rewards, specialty packs and provider features are labeled honestly.

## Checks actually executed

- Hosted preference/domain and persistence tests: 20 passed in `application/.build/verification/run-3Gibrg/tests.xcresult`. UI failures in that same result are retained, not counted as passes.
- iPhone simulator: navigation/relaunch and background preview/persistence passed in the full runs; final targeted dark/larger-text checks passed in `application/.build/shell-targeted-v2.xcresult`.
- Owner iPhone 15 Plus, iOS 27.0.1: navigation/relaunch and background preview/persistence passed in `shell-phone-device.xcresult`. Larger text passed in `shell-phone-targeted-v2.xcresult`; dark contrast/hit-region/descriptions passed in `shell-phone-dark-final.xcresult` after scoping an occluded-row finding. Earlier failed audits remain recorded.
- iPad A16 simulator, iOS 27: navigation, background persistence and dark mode passed in `shell-ipad.xcresult`. An earlier larger-text run stopped at a contrast failure. The selected sidebar row was corrected to OnAccent on the accent fill. A later scan (`shell-ipad-native-final.xcresult`) still reported an unidentified SwiftUI.AccessibilityNode. The follow-up `speaking-ipad-contrast-v1.xcresult` passed `testDarkAppearance`, `testLargerTextAndAccessibility`, and `testTodayContrast`. That passes the previously failing simulator scan. It does not replace a physical iPad or a manual VoiceOver walkthrough.
- Physical iPad, full manual VoiceOver, owner accessibility acceptance and minimum iOS 17 runtime: NOT_RUN. No new custom motion/autoplay was added; native transitions alone do not prove a manual Reduce Motion walkthrough.

## Audit scope

Contrast, hit-region and sufficient-description scans are used, plus Dynamic Type on the normal stable Today viewport. At the largest accessibility text size, the phone test scrolls to and verifies the next action is reachable and captures settings. Native scroll clipping was producing reports for text hidden by bars, so generic `.textClipped` scanning is not counted as passing; screenshots and reachable actions supplement it. Contrast exclusions are limited to the three named background rows and their Preview background/selected labels when clipped by or above the opaque Appearance navigation bar. Visible preview labels are not excluded. An unidentified issue is never filtered.

Screenshots in this folder capture the final iPhone simulator Today/large-text/settings and appearance. `asset-map.json` traces eleven unmodified original discrete assets to inspected nodes/hashes. Figma Today context was read live, then the MCP plan limit required the project-authorized dated local fallback. Used templates: T01 2:37969, T07 2:38336, T10 2:38834; shared Card/Status/Coaching/native buttons and toggles preserve the audited semantic palette. No Figma write/cloud-sync claim.

## Physical iPad — 2026-10-21

Owner connected a wired iPad (A16), iPadOS 27.0.1 (24A446), Developer Mode on. Signed development install of `com.personal.SpeechCoachAI` ran the UI suite on the device. These cases passed:

- `testLaunchRelaunchAndAllDestinations`, `testDarkAppearance`, and `testLargerTextAndAccessibility` in `application/.build/ipad-device-acceptance-v4.xcresult`
- `testTodayContrast` in `application/.build/ipad-device-acceptance-v5.xcresult`
- `testBackgroundPreviewApplyAndRestart` in `application/.build/ipad-device-acceptance-v7.xcresult`

The same runs also passed offline recording entry and masked provider settings. Background stop and the fixture speaking loop are recorded under SC-T011 and the speaking-loop group. Earlier failures in v4–v6 were the microphone prompt, an iPad sidebar button taken as Back, and iPadOS 27 accessibility queries; the UI test now scrolls to the saved-background caption, returns with the Progress back button, and allows the microphone prompt. Those fixes do not change product behavior.

Manual VoiceOver was confirmed by the owner on this iPad on 2026-10-21: VoiceOver is working. On 2026-10-22 the owner reported the requested speaking close-out is working. This ticket is **done**. The 120-second recording cap and a call or headphones route were not recorded as separate results, so they stay with SC-T011.

## Next action

Physical iPad navigation, dark contrast, larger text, Today contrast, and background persistence passed. The owner confirmed VoiceOver and the requested speaking close-out. SC-T011 stays open for the recording cap and a call or headphones route. Provider, educator, and learner outcome gates stay separate.

## Separate large-text retest

`application/.build/recording-context-ipad.xcresult` passed the full larger-text/reachable-action/settings walkthrough plus Dynamic Type, hit-region and sufficient-description scans after contrast was split into `testTodayContrast`. [iPad screenshot](ipad-largest-type-scrolled.png) visually inspected: next action remains reachable; content scrolls. The separate Today contrast scan later passed in `speaking-ipad-contrast-v1.xcresult`. No blanket filter was added to ignore an unidentified node.
