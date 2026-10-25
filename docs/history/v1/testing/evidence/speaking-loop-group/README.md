# Speaking-loop group — integrated implementation and acceptance

Date: 2026-10-21 (Asia/Manila). Scope: SC-T010–SC-T017. Owner explicitly requested grouped development with integrated tests at the end; earlier serial checkpoints are historical. This is an internal build, not a release/publication. No Git repository, backend or scheduler was created.

## Connected implementation

- Native compact tabs/regular sidebar → Speech Lab → deliberate microphone permission/capture/pause/stop/replay → explicit candidate acceptance. Fresh sessions use distinct IDs; recovered takes retain frozen session/coach/source context. Retries keep separate take IDs and one completion per session.
- Separate native disclosure sheets for selected-audio transcription and confirmed-text coaching. Each submission/retry requires a button press. Original recognition stays immutable; local confirmation/edit creates a new revision. Coaching displays only current-revision feedback, retains older associations and says speech/acoustic fluency not assessed. No audio goes into the coaching request.
- Keychain add/replace/remove and gated potentially billable text-connection check. An attribute indicator means saved, not verified. Production HTTP uses a fixed validated Singapore endpoint, ephemeral session, no persistent caches/cookies/background queue, refuses redirects, bounds request/response size and has 60/45-second ASR/coaching timeouts. Errors never expose raw bodies/keys. No app-level automatic retry or fallback.
- Live access is fail-closed: no reviewed ProviderVerification resource is bundled. A valid record must bind exact workspace/models, permission/quota evidence, retention disclosure and expiry; a saved key or settings checkbox cannot bypass this. Account-applicable verification/live access remains pending. No real provider request has been made.
- Independent voice and text save toggles start off; self-review can finish without provider/network/retention. Saved history identifies first/retry take and component availability. Component-level Recently Deleted, restore, exact 30-day expiry and confirmed permanent purge use the existing journal/repository. Temporary discard bypasses trash. Minimal completion identities survive individual deletion; participation is never presented as mastery/XP/assessment. No economy activated.
- Group UI uses native editing/sheets/dialogs/navigation with existing Kit semantic colors and original artwork. Inputs: dated local Page 1 speaking journey, T09 progress/history, T10 settings, exact audited token/asset map. No Figma cloud-sync claim. At accessibility sizes, status icons stack above full-width titles; native sidebar label styling replaces custom selected ink.

## Isolated test mode

Debug UI tests may provide a UUID in SC_SPEAKING_FIXTURE. This opens a separate Application Support/SpeakingUITest-UUID store, seeds synthetic silent WAV audio, and injects an in-process fixture provider with an obvious TEST FIXTURE banner and synthetic retention disclosure. No fixture reaches an HTTP transport or production credential service. Release builds ignore this variable. Normal launches never seed sample history/transcripts/feedback. Test mode does not certify a real provider.

## Verification recorded 2026-10-21

Simulator checks below passed on the current source. SC-T010–SC-T017 stay **in_progress**. A passing fixture journey does not close physical-device, live-provider, educator, or owner-usefulness gates. The earlier nine completed tickets are unchanged.

- iPhone 18 Pro Max simulator, iOS 27: `application/.build/speaking-rotation-max-v8.xcresult` passed the integrated fixture journey. Recover, accept, transcribe, confirm, coach, rotate to landscape with both save switches still on, finish with voice and transcript/feedback saved, relaunch, history, delete, and restore. The practice sheet is anchored outside the tab/sidebar switch, so rotation does not dismiss the take. The save/finish bar is pinned to the review scroll and the coaching control is tapped only once it sits above that bar.
- iPhone 18 Pro simulator, iOS 27: `application/.build/speaking-background-v2.xcresult` passed background stop. After Home and return, replay is available, recording does not resume, and finish without either save says the take was not saved.
- iPad (A16) simulator, iOS 27: `application/.build/speaking-ipad-contrast-v1.xcresult` passed dark appearance, larger text, and Today contrast. The selected sidebar row uses OnAccent on the accent fill.
- Physical iPad (A16), iPadOS 27.0.1 (24A446), 2026-10-21: navigation/relaunch, dark contrast, larger text, Today contrast, and background persistence passed (`ipad-device-acceptance-v4.xcresult`, `v5`, `v7`). Background stop and finish-without-saving passed in `v5`. The fixture journey, rotation, history, delete, and restore passed in `v6`. Manual VoiceOver was not run. Live provider calls were not sent.
- Hosted unit coverage in the earlier `speaking-unit-and-shell.xcresult` passed; that bundle’s background UI failure is superseded by `speaking-background-v2.xcresult`. Do not read the older bundle as the current background result.

## RF acceptance boundaries

| Check | Established so far | Remaining |
| --- | --- | --- |
| RF-01 | Owner confirms clear iPhone replay; original format and 1/1.25/120-second conversion fixtures pass | iPad listening; full capture cap/pause timing and durable real take matrix |
| RF-02 | Background stop and no silent resume passed on the physical iPad in `ipad-device-acceptance-v5.xcresult`, and earlier on the iPhone 18 Pro simulator in `speaking-background-v2.xcresult` | Denied/revoked mic, actual route/call/lock matrix |
| RF-03 | Phone self-review without retention passed earlier; the same finish-without-saving path passed on the physical iPad in `v5` | Route/lock/call and the 120-second cap |
| RF-04 | Synthetic real Keychain lifecycle/protection passed phone and signed simulator | Actual locked access, live destination/account acceptance |
| RF-05 | Local conversion and candidate payload/response fixtures | Real ASR/model/region compatibility |
| RF-06 | Immutable original and edited/unchanged confirmations; fixture UI integration | Real recognition/edit/coaching acceptance |
| RF-07 | Strict fixed not_assessed status; no acoustic score fields | Actual provider content/qualified quality evaluation |
| RF-08 | Invalid/extra/missing/stale payload rejection and typed atomic commits | Actual malformed provider/error behavior |
| RF-09 | Explicit cancel/retry, unknown-outcome fixtures, offline preservation | Real key/quota/network/timeouts and billing evidence |
| RF-10 | Duplicate task/stage/result/completion suppression, explicit unique retry IDs | Current integrated phone validation |
| RF-11 | Synthetic filesystem/commit fault and restart coverage | Measured actual disk-full/lock behavior |
| RF-12 | Four retention combinations, restart/trash/restore/purge/expiry fixtures and simulator UI restore | Current phone run; broader actual system cleanup matrix |
| RF-13 | No pedagogical or performance claim made | 20-call latency/cost and qualified quality sample gates |
| RF-14 | Production access disabled without reviewed exact-account evidence | Account permission/model/quota/retention evidence; owner response pending |
| RF-15 | Owner says replay clear; native larger-text/audit checks recorded | Manual VoiceOver/Reduce Motion and owner usefulness of actual feedback |

Physical iPad is unavailable per owner; do not repeatedly ask for it. Preset validation checks structure only. No owner audio/key/provider response is copied into this evidence.
