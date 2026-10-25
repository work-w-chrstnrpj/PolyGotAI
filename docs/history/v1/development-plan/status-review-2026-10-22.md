# Implementation versus acceptance review · 2026-10-22

Updated 2026-10-25 after exact source verification; later checkpoints and exact ticket headers supersede older counts.

The owner requested `awaiting_testing` for completed implementation. Only the remaining work determines this status; earlier green tests do not automatically close acceptance. A `requires_done` dependency still requires done. Current ticket header/status is authoritative over historical dated appendices.

| Ticket | Current status | Remaining work |
| --- | --- | --- |
| [SC-T011](tickets/SC-T011.md) | awaiting_testing | Capture/replay implemented; remaining 120-second cap, route/interruption and manual acceptance checks. |
| [SC-T012](tickets/SC-T012.md) | awaiting_testing | Keychain, explicit connection-check UI and gated transport are implemented; account prerequisite verification and live acceptance remain outstanding. |
| [SC-T013](tickets/SC-T013.md) | awaiting_testing | Transcript preparation, transport and confirmation implemented; live ASR and original acceptance remain unverified. |
| [SC-T014](tickets/SC-T014.md) | awaiting_testing | Validated coaching and retry presentation implemented; live response quality and acceptance remain unverified. |
| [SC-T015](tickets/SC-T015.md) | awaiting_testing | Retention/history/recovery implemented; remaining retention matrix, expiry/purge and manual acceptance checks. |
| [SC-T016](tickets/SC-T016.md) | awaiting_testing | Integrated offline/fixture speaking journey implemented; remaining full online and manual acceptance checks. |
| [SC-T017](tickets/SC-T017.md) | awaiting_testing | Verification-only ticket: RF matrix, real-provider and learner evidence remain to execute; no feature implementation is claimed by this status. |
| [SC-T018](tickets/SC-T018.md) | awaiting_testing | [SC-D002 personal-use v4 authoring/runtime](sc-d002-2026-10-25/README.md) includes alternatives, rubric anchors and differentiated specialist review; qualified editorial/assessment and actual acceptance remain. |
| [SC-T019](tickets/SC-T019.md) | awaiting_testing | Versioned bundle loader, optional grammar metadata and isolated invalid-content handling implemented; offline install/update/device and content acceptance remain. |
| [SC-T020](tickets/SC-T020.md) | awaiting_testing | Durable offline lesson and four separate foundation/specialist routes implemented; remaining physical, accessibility, reviewed-content and original acceptance checks. |
| [SC-T021](tickets/SC-T021.md) | awaiting_testing | Specialist speaking provenance, separate personal baseline/transfer/delayed checks and manual focus routes implemented; physical, content and learning acceptance remain. |
| [SC-T046](tickets/SC-T046.md) | awaiting_testing | Retention/session controls and prospective version policy implemented in SC-D003; remaining owner/device acceptance. |
| [SC-T047](tickets/SC-T047.md) | awaiting_testing | Review-credit/identity policy implemented; remaining original policy/acceptance verification. |
| [SC-T048](tickets/SC-T048.md) | awaiting_testing | Collection/enrollment identity implemented; remaining full retention/deletion and manual acceptance. |
| [SC-T049](tickets/SC-T049.md) | awaiting_testing | Offline recall/rating implemented; remaining original manual and spoken self-check acceptance. Optional online sentence feedback belongs to separate provider scope. |
| [SC-T050](tickets/SC-T050.md) | awaiting_testing | Atomic review/recovery implemented; remaining full interruption/clock and manual acceptance. |
| [SC-T051](tickets/SC-T051.md) | in_progress | Goal-aware recommendation and reviewed specialist/difficulty mappings remain incomplete; existing local ranking is tested. |
| [SC-T052](tickets/SC-T052.md) | awaiting_testing | Separate learning evidence/comparison history implemented; remaining comparison/deletion and manual acceptance. |
| [SC-T054](tickets/SC-T054.md) | awaiting_testing | Weekly counts and connected focus implemented; remaining original summary/manual acceptance. |
| [SC-T165](tickets/SC-T165.md) | awaiting_testing | Offline manual topics, shared edits and search/editor reliability implemented; remaining physical/manual acceptance. Generated topics belong to SC-T166. |

Grok delivered catalog and scheduler integrity implementation; Codex integrated and verified both. [Full SC-D004 handoff](../../../development-plan/handoffs/grok-sc-d004-2026-10-23.md) was delivered and [integrated by Codex](sc-d004-integration-2026-10-23.md) through the shared repository/project; Grok retains its exact source/test ownership. Rewards remain unapproved proposals.

Classification uses current exact ticket scope, existing source and linked simulator/physical evidence. In particular SC-T165 is offline manual topics; generation is SC-T166 and cannot keep SC-T165 in progress by itself. SC-T051 still lacks goals integration; testing the simpler local suggestion does not complete its full implementation.

Final 2026-10-23 counts: 11 done, 17 awaiting_testing, 3 in_progress, 161 pending, 0 blocked. [Connected runtime evidence](../testing/evidence/connected-practice-2026-10-23/README.md).

## SC-D003 follow-up — 2026-10-23

[Implemented controls, policy and exact evidence](sc-d003-2026-10-23.md) move SC-T046 to awaiting_testing. Current counts supersede earlier checkpoints: 11 done, 18 awaiting_testing, 2 in_progress, 161 pending. SC-T018 content and SC-T051 goal/recommendation integration still have development scope. Grok now has the [full SC-D004 handoff](../../../development-plan/handoffs/grok-sc-d004-2026-10-23.md), replacing the earlier narrow lane; delivered and integrated in [the Codex record](sc-d004-integration-2026-10-23.md); reviewed specialist mappings remain unfinished.

## SC-D017 resource-library checkpoint — 2026-10-24

Owner selected public HTTPS/normalized YouTube links and explicitly authorized implementation. [SC-T168/169 policy and native implementation](sc-d017-implementation-2026-10-24.md) are awaiting_testing. Original owner/device QA-11, actual external-site/real-connectivity and full accessibility/theme/background acceptance remain, along with prerequisite closure; SC-T039 stays pending roll-up. This is implementation completion, not done or pilot/publication acceptance. Current exact counts: 11 done, 35 awaiting_testing, 13 in_progress, 133 pending, 0 blocked. See [executed verification](../testing/evidence/sc-d017-2026-10-24/README.md).

## SC-D015 review/integration checkpoint — 2026-10-25

SC-T037/161–164 move from pending to in_progress after [owner-authorized review, repairs and local integration](sc-d015-integration-2026-10-25.md). Missing adopted generation/report policy, selected model/live adapter, reviewed content/fallback/correction and semantic validation prevent awaiting_testing, even with scoped synthetic/local success. Original prerequisites and actual acceptance remain. Counts: 128 pending, 18 in_progress, 35 awaiting_testing, 0 blocked, 11 done.

## SC-D016 reviewed integration — 2026-10-25

SC-T038/166/167 move to in_progress after owner-authorized review/fixes and local integration. Missing topic-aware generation contract/adapter, generated enrollment, daily selection/pool/policy and optional enrollment prevent awaiting_testing. SC-T165 stays awaiting_testing. Counts: 125 pending, 21 in_progress, 35 awaiting_testing, 0 blocked, 11 done.

## SC-D017 acceptance follow-up — 2026-10-25

SC-D017 query-preservation defect is repaired under the owner’s redirected scope; no verifiable Grok return was present. SC-T168/169 remain awaiting_testing after the repair, SC-T039/028 remain pending. Counts unchanged: 125 pending, 21 in_progress, 35 awaiting_testing, 0 blocked, 11 done. Actual physical/site/accessibility acceptance remains open. SC-D018 remains pending.

## SC-D002 completion checkpoint — 2026-10-25

SC-T018 authoring/runtime reaches awaiting_testing alongside SC-T019/020/021 after [named INTRO v4 delivery](sc-d002-2026-10-25/README.md). Qualified review and original actual acceptance remain open. SC-T043 is pending acceptance execution, not a missing-code claim. Counts are derived from current exact tickets in progress.md; preserve the concurrent SC-D004 status updates. No done/pilot/efficacy/publication inference.


## SC-D004 completion checkpoint — 2026-10-25

[SC-D004 connected focus/evidence](sc-d004-2026-10-25.md) is implementation-complete at awaiting_testing with phone/tablet regression and passing targeted retests. SC-T051 joins SC-T052/054; qualified content/device/manual/learning acceptance remains. SC-T024 stays pending for SC-T053/rewards and original prerequisites.
