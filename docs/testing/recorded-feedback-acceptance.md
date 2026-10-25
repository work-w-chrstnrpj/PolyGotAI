# Recorded Introduction — Device and Provider Acceptance

> **v2 note (2026-10-25):** kept for online AI coaching, which is now Phase 6 in the [development plan](../development-plan/development-plan.md). Sections that mention v1 tickets, Speech Lab trainers or delivery groups are history; see [history-version.md](../history-version.md).

> Status: IN_PROGRESS
> Planned matrix, not execution evidence. All runtime results are NOT_RUN. Provisional engineering targets below are proposed for the proof, not measured performance or promises.

## Environments and evidence

Run on at least one physical iPhone and one physical iPad supported by the eventual minimum OS, on owner Wi-Fi and a constrained/interrupted connection. Record device model/OS, build revision, provider/model snapshot or alias/date, region, protocol, rubric version, sample duration and request/usage identifiers without secrets. Simulator/fixture checks supplement but do not close microphone, routing, interruption or learner-quality acceptance. No executable app exists; iOS/iPadOS 17+ is selected, with actual target-device OS unverified.

Use fictional/synthetic recordings and educator-reviewed expected outcomes for reproducible provider checks. Owner recordings require consent, minimal private content and defined retention. Evidence must omit credentials and private audio/transcripts; sensitive sample artifacts remain local and are explicitly opted in. Screenshots redact secrets. Document account quota checks without key values.

## Provisional performance/quality targets

- Recording/replay controls respond within 500 ms in 95% of 20 local operations per device, with no missing saved files. Timing is from user action to visible/local operation acknowledgment, not provider latency.
- ASR of 30–60 seconds: p95 at most 30 seconds from dispatch to complete validated transcript, across 20 calls on the stated normal Wi-Fi setup. Coaching: p95 at most 20 seconds from dispatch to validated feedback, across the same sample size. End-to-end excludes learner editing time. These are initial acceptance targets to revise transparently if proof evidence shows unrealistic expectations.
- Stage timeout: provisional 60 seconds for ASR and 45 seconds for text coaching; no automatic billable retry. Device/network conditions and sample length must accompany timing results.
- Feedback evaluation: 20 reviewed sample cases spanning valid American/British usage, known grammar issues, short/uncertain recognition, word-finding and coherent/incoherent answers. At least 18/20 cases meet reviewer criteria for grounded, accurate, useful feedback; zero fabricated numeric scores, false accomplishments or dangerous credential disclosures. Failures need categorized examples and remediation/retest, not an aggregate success claim.
- Successful parse/schema/identity validation for all accepted fixture payloads; every intentionally invalid fixture rejected. Valid zero-improvement output supported. Runtime outputs all go through validation, with provider rejection/fallback rate recorded independently of pedagogical quality.
- Record actual per-stage usage/cost and quota unit if available for 20 calls. No session-cost threshold is approved yet; compare measured cost before setting product budgets. Complete acceptance within confirmed trial allowance or pause rather than allowing unapproved paid fallback.

## Matrix

| ID | Check | Required result | Current result |
| --- | --- | --- | --- |
| RF-01 | Local record/replay/save on both devices | Audio intelligible, 1–120 s limits enforced, durable saved asset and restart survival | NOT_RUN |
| RF-02 | Microphone denied/revoked, interruption, route change | Clear recovery; no silent overwrite or restart of recording; retained partial audio handled explicitly | NOT_RUN |
| RF-03 | Offline/no-key self-review | Record/playback/finish works; no cloud request, no lost local progress | NOT_RUN |
| RF-04 | Key lifecycle and destination | Keychain add/replace/remove; secure verified host; no key in logs/store/export/crash evidence | NOT_RUN |
| RF-05 | Actual Qwen transcription | Compatible format/region/model, original immutable text, absent confidence remains null | NOT_RUN |
| RF-06 | Confirmation/edit before coaching | Feedback uses confirmed revision; old feedback stays tied to old revision | NOT_RUN |
| RF-07 | Speech assessment boundary | Text proof shows not_assessed; no acoustic/CEFR/confidence score fabricated | NOT_RUN |
| RF-08 | Invalid/truncated/extra-field/stale response | Reject safely, preserve valid local data; late deleted-attempt callbacks discarded | NOT_RUN |
| RF-09 | Bad key/quota/rate-limit/offline/timeout | Typed errors, no automatic billable retry or silent model switch; unknown billing outcome acknowledged | NOT_RUN |
| RF-10 | Repeated taps/cancel/retry | Single in-flight request per stage; distinct explicit retry IDs; no duplicate local attempt/result/reward | NOT_RUN |
| RF-11 | Crash/disk-full/file failure | Recover or expose recoverable attempt, no corrupt success; orphan reconciliation; no silent resubmission | NOT_RUN |
| RF-12 | Save/discard/deletion/temporary cleanup | Opt-in retention, correct replay availability, cleanup survives restart; no resurrection | NOT_RUN |
| RF-13 | Latency, schema and reviewer sample gates | Meet or transparently revise targets with evidence before closing proof | NOT_RUN |
| RF-14 | Provider trial/terms/retention | Account eligibility/protection and native-client/data policy recorded; no assumed free allocation | NOT_RUN |
| RF-15 | Owner usefulness/accessibility | Owner can review and retry meaningfully; VoiceOver/Dynamic Type controls tested when UI exists | NOT_RUN |

## Evidence record format

For every executed row, capture: test ID; date; device/OS/build; preconditions; sample ID; procedure; expected/actual outcome; PASS/FAIL/BLOCKED; sanitized artifact reference; latency/usage where relevant; defect/retest note. NOT_RUN is distinct from BLOCKED; do not mark PASS from documentation research or schema checks alone. Evidence index belongs under `docs/testing/evidence/` when executions occur; none are currently available.

## Gates and exclusions

Provider feasibility can close only after RF-04–RF-09, RF-13 and RF-14 have actual evidence, with unresolved model/terms limitations recorded. Physical recording/persistence feasibility requires RF-01–RF-03 and RF-10–RF-12. Learner experience acceptance RF-15 follows UI/UX and implementation. No single successful API call closes educational quality or native-device acceptance.

No realtime conversation, complete A1 level, advanced pronunciation, sync or production readiness is claimed. The owner initially deferred implementation-ticket creation until UI/UX discussion, then authorized ticket creation on 2026-10-17. This document remains the proof acceptance baseline, linked from the [milestone roadmap](../history/v1/development-plan/milestones.md); all runtime results remain NOT_RUN. See [contracts](../contracts/recorded-feedback-v1.md) and [Qwen report](../api/qwen-capability-report.md).

## UI/UX acceptance additions awaiting implementation

Apply [owner UI/UX decisions](../product-specification/ui-ux-design.md) alongside this technical proof. Verify independent audio/text save choices, interrupted-take preservation with restart, leave confirmation, 30-day saved-record recovery/permanent purge, explicit billable retries, generic reminders, quiet mode, free level choice, XP/gold deduplication and Freeze/Repair rules. Test all three backgrounds with Light/Dark/System, Dynamic Type, VoiceOver and reduced motion on iPhone and iPad. Verify native HIG choices against current official guidance and owner usability evidence. All checks remain NOT_RUN. RF-01’s 120-second proof cap is approved subject to feasibility; it is not the general recording maximum.

## Decision handoff — 2026-10-21

SC-T002 selected iOS/iPadOS 17+, SwiftUI/AVFAudio/local-only SwiftData/URLSession/Keychain; SC-T003 selected a documented Qwen candidate with RF-14 account/International terms unresolved. The 1–120 second proof range is owner-approved (not a general app limit), countdown initially off. Timeouts selected for first proof: ASR 60 seconds/coaching 45 seconds; latency/quality targets remain provisional.

RF-11/12 must execute the four save combinations, component/whole deletion, exact 30-day deadline, 24-hour interrupted recovery, locked/disk-full/store-sidecar failure, pending purge reconciliation, stale callback/epoch rejection, preserved participation versus unavailable skill evidence and delete-all reset. Verify all learner-data backup exclusions and no implicit restore; platform backup flags cannot guarantee historic copies never reappear. Manual-export copies are outside local deletion. No application test has run; the SC-T004 walkthrough is specification review only.

## First-flow design and content handoff — 2026-10-21

SC-T007 review requires separate audio-ASR and confirmed-text coaching disclosures, zero-to-two improvements, initially unselected independent retention choices, truthful seven-role/internal capability states and approved Creative Academy/System/Elephant Teacher defaults. Test native keyboard, Dynamic Type, VoiceOver, interruption/retention/quiet states after implementation. SC-T005 bundles required local reference content; SC-T006 educator mapping/rubric review remains pending. Static reference inspection does not pass these runtime checks.
