# Test Specification

> Status: IN_PROGRESS
> Product acceptance strategy plus SC-T008 executable bootstrap configuration and UI launch checks; product acceptance remains NOT_RUN.

## Test layers

- Unit: scheduler ratings/state, recognition versus production histories, level availability, preference precedence, reward eligibility/deduplication and evidence summaries.
- Persistence integration: restart survival, optional recording deletion, orphan recovery, content updates and future schema migrations.
- Provider contracts: structured feedback validation, uncertainty, unsupported pronunciation, cancellation, retry identity and error mapping using fixtures.
- Device/system: microphone denial/revocation, interruptions, headphones/routes, offline transitions, replay and recording lifecycle on iPhone and iPad.
- Manual acceptance: understandable coach feedback, helpful word suggestions, curriculum correctness, recording comparisons, VoiceOver, Dynamic Type and accessible audio controls.

## Priority acceptance scenarios

| ID | Scenario | Expected boundary |
| --- | --- | --- |
| QA-01 | First introduction online | Record, replay/re-record, explicitly submit, receive afterward feedback; optional baseline save |
| QA-02 | First introduction offline | Record/playback/self-review work; online correction unavailable clearly; no silent upload |
| QA-03 | Feedback fails/retry | Local attempt remains; retry creates no duplicate reward or feedback submission side effect |
| QA-04 | Recall ratings | Failed recall uses Again; Hard represents successful recall; recognition/use remain separate |
| QA-05 | Typed vocabulary sentence | Speaking optional; grammar feedback does not automatically mark vocabulary forgotten |
| QA-06 | Level selection | Bypass possible for available levels; planned curriculum never appears completed/available falsely |
| QA-07 | Preferences | Persisted defaults and scoped overrides behave as defined once designed |
| QA-08 | Custom topic | Immediate and subtopic paths produce reviewable selectable content |
| QA-09 | Comparison | All four prompt formats link correct earlier/recent recordings; unavailable/deleted audio handled |
| QA-10 | Milestones | Participation separate from assessed skill; improvement identifies evidence and rule |
| QA-11 | Resources | Curated/personal cards open correct valid links; no unsupported video-derived claims |
| QA-12 | Assessment uncertainty | Uncertain transcript not definitive error; unavailable scores not fabricated |

## Evaluation and release gates

Calibrate pronunciation capabilities against suitable human review before claiming reliable scores. Define comparable grammar tasks and vocabulary retention evidence before granting improvement badges. Owner feedback on actual devices is separate from simulated/provider tests. No build or installation alone closes usability, accessibility or speech-quality acceptance.

Specify latency, recording duration, device/OS support, cost and failure tolerances after technology investigation; no invented numeric targets. Before beta, validate privacy/deletion, account/usage controls if adopted, content accuracy and recovery. See [development plan](../development-plan/development-plan.md).

## Commands and current evidence

See [commands](../commands/commands.md) for native simulator verification. SC-T008 hosts Swift Testing checks for universal/minimum-OS metadata and absent sensitive bootstrap capabilities, plus XCUITest launch/relaunch checks. These do not prove persistence, audio, provider behavior, minimum-OS runtime compatibility or physical accessibility. Dated execution evidence lives under evidence/SC-T008/.

## American English, curriculum and usability acceptance additions

- Verify American spelling, vocabulary and reference audio are consistent; valid British alternatives are explained without false grammar/pronunciation errors.
- Review each published lesson's CEFR outcome mapping, level suitability, task/assessment alignment, provenance and reuse rights. Curriculum references are not automatic certification.
- Evaluate delayed vocabulary recall and use in new sentences; compare repeat-prompt practice with new related speaking tasks before claiming transferable improvement.
- Test whether learners can start practice, understand prioritized feedback, replay/retry and select a next step without excessive setup. Validate on iPhone/iPad with accessibility and actual learner feedback.
- Track engagement separately from learning evidence; XP and completion alone must not establish proficiency improvement.

## Dynamic generation acceptance

| ID | Scenario | Expected result |
| --- | --- | --- |
| QA-13 | Generate across configured activity types | Objective, level, target language variety and learner preferences remain consistent |
| QA-14 | Malformed, ambiguous or incorrect generated question/answer | Reject before presentation; reviewed fallback available; model self-validation alone is insufficient |
| QA-15 | Offline, timeout, cancellation or quota failure | Bundled/cached validated practice remains usable; attempts retained; no duplicate rewards |
| QA-16 | New vocabulary context | Same word sense/card/schedule preserved; answer not inadvertently revealed |
| QA-17 | Repeatable assessment versus novel practice | Presented task/rubric frozen; comparability required before trend or improvement badge |
| QA-18 | Generated pronunciation or video activity | Supported audio/assessment required; video URL alone never treated as source content |
| QA-19 | Cache/content version change | Incompatible variants excluded; historical attempts keep their exact prompts and grading version |

Use deterministic provider fixtures for contracts and separately sample generated content for qualified curriculum review, answer validity, diversity, difficulty and American English consistency. Repeated wording tests must allow intentional repetition; novelty is not a quality metric on its own. Numeric quality thresholds and generation budget await design. These are planned tests, not executed application checks.

## Communication training acceptance

- QA-20: Reviewed framework lessons link to guided/free speaking practice with configurable scaffolds and offline self-review.
- QA-21: Feedback separates structure, English and supported delivery observations; effective natural responses are not penalized for omitting acronym labels.
- QA-22: Transcript-only input produces no vocal/body-language or confidence claims; intentional pauses and valid accents are not automatic errors.
- QA-23: Scenario generation respects level/framework objective; comparisons retain rubric/version and task conditions; fictional examples never become claimed learner achievements.

Framework content requires source/rights review and qualified editorial assessment. These are planned acceptance checks, not executed tests.

## Practical technique acceptance

- QA-24: Technique lesson is accessible from Lessons and Speech Lab; both entry points share objective identity and progress.
- QA-25: Clarity, listening, persuasion, delivery and difficult-conversation drills respect level, settings, offline availability and generation-validation policy.
- QA-26: Feedback preserves meaning when encouraging conciseness, permits appropriate fillers/pauses, and avoids rigid sentence/point/time rules. No unsupported intelligence, empathy, confidence or eye-contact scoring.
- QA-27: Listening feedback uses the source exchange; persuasion examples preserve facts/uncertainty; emotional interpretations are tentative.
- QA-28: Optional routine supports selected activities without treating completion as mastery; cross-mode practice creates no duplicate rewards.

These remain planned scenarios; content efficacy and feedback quality require editorial and learner review.

## Level curriculum acceptance

- QA-29: Each published unit has reviewed objective/CEFR mapping, level suitability, prerequisites, answer/rubric validity and content/audio rights.
- QA-30: A1–C2 planned topics are distinguished from installed/available content; bypass works for available content without false completion.
- QA-31: Recurring topics preserve objective/version history; dynamic variations respect approved difficulty and do not invent curriculum progression.
- QA-32: Listening/reading/speaking evidence matches the claimed outcome; framework recall, XP and lesson completion alone do not establish proficiency.

These are planned acceptance gates; no curriculum or app tests have been executed.

## Integrated lessons and vocabulary acceptance

- QA-33: A lesson interleaves concise teaching and objective-linked activities; guided/focused/review entry paths preserve shared progress. Exact completion policy must be specified before execution.
- QA-34: Offline basic learning/self-review remains usable without AI feedback; vocabulary speaking is optional and Speech Lab remains independently accessible.
- QA-35: Lesson vocabulary can be optionally enrolled in Vocabulary Builder; repeated enrollment/shared references do not duplicate the same item/sense card.
- QA-36: Recognition/productive-use evidence stays separate; exposure alone does not advance scheduling; one attempt creates no duplicate reviews/rewards.
- QA-37: Hint/answer exposure and personal-entry reconciliation follow an explicitly approved scheduler-credit/identity policy; no policy is assumed from lesson completion.

These are planned acceptance scenarios, not executed app tests.

## BYOK acceptance

- QA-38: Add/replace/remove credentials via masked settings; secrets stored only in Keychain and excluded from logs/database/exports; local deletion distinguished from provider revocation.
- QA-39: No-key/offline mode preserves lessons, vocabulary, recording and self-review; AI capability availability matches the chosen provider.
- QA-40: Invalid/revoked key, rate limit, balance exhaustion and network failure preserve attempts, provide useful recovery and avoid uncontrolled retry charges.
- QA-41: Verify selected provider's official native-client API/key requirements and secure destinations; no key forwarded to unapproved endpoints/backends.
- QA-42: Provider billing/processing disclosure and potentially billable connection checks are clear; local usage estimates/limits are not claimed as provider-wide guarantees.

Use synthetic credentials/fixtures for automated tests; never commit real keys or log them in evidence. Real-provider acceptance requires an owner-configured credential and appropriate usage limits. These remain planned checks.

## Articulation Training acceptance

- QA-43: Learner selects speech-production or expression focus, sees a short reviewed explanation/example and can record, replay and retry with configured support.
- QA-44: Offline/no-key instruction and self-review work; precise sound feedback is shown only when audio and validated provider capability support it.
- QA-45: Word-finding/paraphrase tasks connect to shared vocabulary without duplicate cards, review credits or rewards; speaking remains optional in Vocabulary Builder.
- QA-46: Feedback separates sound production, grammar, word use and organization; valid variants and thoughtful pauses are accepted; no clinical diagnosis, inferred confidence or forced speed/accent target.
- QA-47: Comparisons preserve target/difficulty and rubric/provider version; changed prompts or unsupported measurements do not automatically yield improvement badges.

These checks remain planned and require content/provider and learner validation for any released mode.

## Approved-default and Qwen proof checks

- QA-48: Corrected transcripts affect grammar/content feedback without overwriting original recognition or becoming pronunciation evidence.
- QA-49: Default two prioritized improvements and selectable detail; core offline completion independent of AI submission.
- QA-50: Qwen model/region/key/native-client compatibility and quota units verified; expired/exhausted free-only usage offers fixtures/self-review, with no silent paid/model fallback.
- QA-51: Explicit rated reviews alone advance scheduling initially; incorrect-activity reports preserve variant identity without unnecessary private payloads.
- QA-52: Compare baseline, related new task and delayed recall using reviewed criteria; learner usefulness evidence remains distinct from XP.

These are planned checks. No real-provider account allowance, integration or learning efficacy has been verified.

## Pre-ticket execution baseline

Use the [recorded-feedback acceptance matrix](../../../testing/recorded-feedback-acceptance.md) for RF-01–RF-15 and provisional performance/content-quality targets. All runtime outcomes remain NOT_RUN; provider/device gates require actual evidence. This supplies numeric targets for the bounded technical proof; the subsequently adopted Introductions protocol supplies initial learning-pilot criteria. Wider app targets remain undecided. The earlier UI/UX-before-ticket gate has been followed by owner authorization to create tickets on 2026-10-17. The [milestone roadmap](../development-plan/milestones.md) now tracks planned implementation and acceptance; no runtime check is closed by ticket creation.

## Design coverage versus execution

[Screen/state inventory](../../../product-specification/ui-screen-state-inventory.md) walkthroughs W01–W16 cover the planned UI journeys and recovery cases against existing QA requirements. All walkthroughs remain NOT_RUN until actually performed against identified frames/variants and recorded. Inventory link validation or Figma generation does not establish functional, accessibility, learner-quality or physical-device results.

## Introductions learning acceptance — adopted 2026-10-19

[IL-01–IL-10](introductions-learning-acceptance.md) makes QA-49/QA-52 concrete for the first topic: reviewed outcome/pack/rubric, independent baseline, both-device offline/quiet completion, actionable feedback/retry, assistance/evidence separation, day-7/day-28 recall and unfamiliar tasks, blinded qualified audio review, explained practice suggestions and consent/accessibility checks. All results remain NOT_RUN.

Use the linked protocol's initial thresholds only after educator review; they replace no wider-app quality thresholds. Human assessment, AI-feedback validity, functional delivery, learning change and engagement are reported separately. SC-T043 owns the first-topic pilot before SC-T026 course expansion; SC-T027 extends evaluation to the small course. Existing RF device/provider gates still apply.

## English Foundations acceptance — adopted 2026-10-19

Use [EF-QA01–EF-QA08](english-foundations-acceptance.md) against [EF-AC01–EF-AC08](../../../product-specification/english-foundations.md): explicit topic/CEFR mapping, concept versus production checks, natural target opportunities, unfamiliar communication, delayed grammar use, shared/offline entry, completion/recovery/accessibility and correct teaching of word classes/sentence functions. These are bounded learning requirements, not official CEFR grammar thresholds or executed tests.

SC-T018/SC-T020/SC-T043 cover only the Introductions subset initially. Existing IL vocabulary recall, communication and RF provider/device checks remain separate. Later course/level children must name their covered foundation objectives, reviewed mapping and acceptance IDs. All results remain NOT_RUN.

## Seven specialized trainer acceptance — adopted 2026-10-19

[TR-QA01–TR-QA10](specialized-trainer-acceptance.md) checks all-seven availability, authentic method/activity differentiation, each trainer's learning criteria, delayed/unfamiliar tasks, source/fiction integrity, capability boundaries and shared switching/progress/rewards. Teacher/Grammarian/Journalist are the bounded INTRO-01 proof; SC-T044 children cover full seven-role delivery before SC-T040 public audit. Existing EF/IL/RF checks remain independently applicable. Numeric targets are initial educator-reviewed operational criteria, not established CEFR scores. All runtime/content/learner results remain NOT_RUN.

## Course invariance and proposed reward delivery acceptance

[CP-QA01–CP-QA08 and RW-QA01–RW-QA08](course-practice-and-rewards-acceptance.md) adds fixed CEFR training across all coaches, explicit specialty detours, real back-and-forth conversation and interview follow-ups with honest turn modes, plus proposed ledger-before-presentation, grouped/skippable/static celebrations and evidence-grounded badge details. RW proposal decisions must be settled before runtime implementation; existing economy values stay authoritative. All checks are NOT_RUN. SC-T043 covers early course invariance, SC-T035 later conversation/interview work, SC-T044 specialist separation, and SC-T025 reward/animation children.

## SC-T009 executable coverage — 2026-10-21

`LearnerRepositoryTests.swift` now exercises synthetic on-disk persistence, all retention combinations, staged/journaled finalization failures, restart/reconciliation, deletion/restore/expiry, stale callbacks/epoch reset, file integrity/path/symlink checks and corrupt-store preservation. Both simulator classes pass 19 aggregate checks including bootstrap UI. Device-only alias failures prompted a path-boundary fix; final physical suite awaits unlocked device. See evidence/SC-T009/README.md. Actual audio/provider/lock-unlock/minimum-OS and curriculum acceptance remain NOT_RUN; fault injection is not their substitute.

## SC-T010/011 runtime checkpoint — 2026-10-21

SC-T010 focused iPhone navigation/settings/dark/larger-text checks passed; iPad accessibility contrast still reports an unidentified SwiftUI node after a real sidebar contrast correction. Full native VoiceOver/Reduce Motion walkthrough remains open. See [SC-T010 evidence](evidence/SC-T010/README.md).

SC-T011 final simulator run passed 28 reported cases (24 Swift Testing functions with parameterized cases, one XCTest UI method). New tests use synthetic WAV originals and private temporary stores, exercise capture references/restart, invalid short/float input, exact expiry, saved-original retention and distinct retry IDs. The UI check opens without a key, verifies no capture before deliberate Start, and closes to Speech Lab. Signed device build/install passed. Owner replay check requested; actual iPhone/iPad RF-01–03/interruption/120-second/route/lock/retention acceptance remains open. [SC-T011 evidence](evidence/SC-T011/README.md) records the distinction and known integration limitations.

## Credential/device follow-up — 2026-10-21

[SC-T012](evidence/SC-T012/README.md): synthetic Keychain lifecycle/protection/scope tests PASS on signed simulator and physical iPhone; masked-entry/no-live-action UI PASS on iPhone. A saved key is never labeled verified. [SC-T011](evidence/SC-T011/README.md): owner replay clarity PASS and physical Home/return/no-resume/self-review-without-saving PASS; route/lock/cap/physical-iPad acceptance stays open. iPad simulator largest-text walkthrough now passes separately from the unresolved contrast test; splitting tests does not count contrast as passing.

## Request/transcript/coaching fixture checkpoint — 2026-10-21

Full simulator hosted suite passed 42 test functions/seven suites, including parameterized cases. Transcription lifecycle also passes its focused physical iPhone suite: duplicate taps, cancel/late result, unknown-outcome restart, immutable original/edited/unchanged confirmation, atomic commit fault rollback and bounded response rejection. Coaching fixtures cover strict key/type/category/length/count/evidence/not_assessed/hints-only rules and repository exact-revision/duplicate/after-edit handling. See SC-T013/014 evidence. These are synthetic engineering results, not actual provider quality/transport or native transcript/feedback UI acceptance. Physical iPad remains unavailable per owner.

## Owner-authorized grouped integration verification

SC-T010–SC-T017 are one explicit implementation/testing group, superseding ticket-by-ticket broad retests. Essential compile/security checks remain during development. The integrated fixture test traverses selected take → explicit ASR disclosure → original recognition → local confirmation → separate coaching disclosure → grounded not_assessed feedback → independent save → relaunch → history → component delete/restore. Repository integration tests cover all four retention choices, expiry/purge, cancellation/unknown outcomes and completion deduplication. Physical microphone/background checks remain separate from synthetic provider tests. Current final results and open RF gates live in evidence/speaking-loop-group/README.md.

## First-loop repair regressions — 2026-10-22

See [execution evidence](evidence/first-loop-stabilization/README.md) for actual results. LessonJourneyTests cover draft/position recovery, legacy optional fields, immutable unaided answers, assistance, actual recorded participation, quiet alternatives and separate repeat attempts. VocabularyLinkTests and CustomVocabularyTests cover lesson meanings, same-spelling/different-sense identity, topic removal and missing-meaning rating refusal. Existing scheduler/credit/recovery and provider tests remain required.

UI journeys now include Today → lesson → unsubmitted draft → relaunch/resume → quiet completion → word enrollment → reveal/rate, plus lesson → actual recording/self-review without retention → return to the lesson without typing. Existing recording/background, synthetic provider/history, navigation, appearance, large-text and contrast journeys remain independent. Use isolated synthetic fixture stores for these journeys. Screenshot review supplements behavioral assertions; it does not establish educator, device, manual VoiceOver or learning acceptance.

## Offline recall recovery coverage — 2026-10-22

SC-T048–SC-T050 cover QA-04/34/36/37 through hidden-draft/reveal recovery, immutable first response/mode, stable event identity and atomic failure/retry. Think/Write/Say self-checks need no provider or microphone. UI journeys cover collection-only save then enrollment, typing/restart, reveal/restart, two-card progression, successful Hard, missed Again, and accessibility-size Think mode. Provider-gated QA-05 sentence coaching remains open. Exact executed results and physical/manual limits: [recall evidence](evidence/recall-recovery-2026-10-22/README.md).

## Today/Progress reliability follow-up — 2026-10-22

SC-T051/052/054 cover primary-action/reason agreement, explicit override and restart, consistent Today/Progress focus, confidence save/clear/restart, injected write failures, reset epoch rejection, local midnight/timezone recomputation and half-open weekly boundaries. Exact results and source/UI checkpoints: [daily-flow evidence](evidence/daily-flow-2026-10-22/README.md). Runtime notification wiring is distinct from deterministic calendar fixtures; manual system-clock/device and learning acceptance remain separately open.


## SC-D003 review controls and SC-D004 preference integration — 2026-10-23

`ReviewDeliveryTests` (in ReviewScheduleTests.swift) verifies prospective settings, resume-first session slicing, collection enrollment, parameter provenance/legacy decoding, save failure/history protection and learner-reset guards. `DailyProgressDeliveryTests.swift` supplies Grok's preference ranking/draft/persistence/integrated-board fixtures; Codex owns its project registration. Focused UI journeys are `testReviewOptionsPersistAndLimitOneSession` and `testPracticePreferencePersistsAndConnectsToday`. Retain the existing hidden-draft/reveal/rating recovery journey as regression evidence.

Use synthetic isolated stores and preserve failed result bundles. Audit contrast only with the subject text visible: scroll a row fully above the system floating tab bar rather than exempting it. Current [evidence](evidence/sc-d003-2026-10-23/README.md) separates hosted behavior, simulator UI, a setup event-synthesis timeout, physical/appearance/accessibility acceptance and reviewed specialist/content gaps. No fixture result proves provider access or learner effectiveness.


SC-D004 review-fix regression adds controller failure/retry/clear/reset integration cases and makes the existing preference UI journey navigate away with an unsaved choice. It uses individual control identifiers, replacing the historical label workaround. [Exact results and command](evidence/sc-d004-review-fixes-2026-10-23/README.md) keep hosted fault injection distinct from real simulator navigation.


SC-D006 SmallA1CourseTests is now registered in the hosted target. The focused run includes that suite plus CurriculumCatalogTests and LessonJourneyTests: [the initial version-2 checkpoint passed 26 per simulator; a later recheck after concurrent source changes had 24 passes and 2 failures](evidence/sc-d006-integration-2026-10-23/README.md). This covers approved identities, resume/isolation and asset availability, not a full course UI walkthrough or learner/educator/pilot acceptance.

SC-D006 failed-test repair: [26 selected hosted tests pass per simulator](evidence/sc-d006-test-fixes-2026-10-23/README.md), including all four SmallA1CourseTests. Exact archived-version lookup, exclusion of newer revisions and unchanged saved work after identity rejection are covered. This supersedes the two historical failures above.

## SC-D007 version and optional-practice regression — 2026-10-23

[Actual evidence](evidence/sc-d007-2026-10-23/README.md) covers exact v2 drafts/first responses/tasks and repository reopen, missing/ambiguous archives, explicit v3 switching, archived optional-source recovery, non-retained participation, retained first/retry distinctions, and exact speaking prompt/provenance. Final phone selection passed 37 hosted plus two UI cases; tablet passed 151 hosted and both UI cases across run/retest. Initial failures are retained. These checks support scoped implementation only; qualified topic/depth/descriptor/answer/rubric/rights review, complete physical/accessibility acceptance and actual learner/delay/transfer evidence remain outstanding.

## SC-D014 local integration regression — 2026-10-24

`CommunicationDeliveryTests` now runs in the real hosted target. Fixtures cover unpublished items, text-versus-sound boundaries, zero/two-action validation, initial/retry/support identity, task/slot cancellation, declined retention, exact-source archive recovery, distinct content versions, unknown-outcome recovery, failed-write preservation, expiry, delete-all epoch protection, and owned-file/private-prompt cleanup. New BootstrapLaunchTests exercise Learn-to-Speech-Lab recovery/End/discard/new practice and native independent recording return. [Executed evidence](evidence/sc-d014-integration-2026-10-24/README.md) owns counts/builds/results. These checks contribute no qualified-content, real-provider, physical-audio, unfamiliar/delayed-learning or release acceptance claim.

## SC-D017 resource verification — 2026-10-24

`ResourceLibraryDeliveryTests` covers rejected schemes/credentials/private-host syntax, YouTube canonical duplicates, preserved general query semantics, explicit save/reopen/edit/remove, rollback/retry, stale revision/epoch/open intents, delete-all, curated provenance and settings preservation. Two isolated BootstrapLaunchTests journeys cover saved notes/edit/restart/search, destination confirmation/cancel and synthetic system refusal, plus offline source save and unsaved discard. Fixture failure/offline overrides require DEBUG plus a UUID `SC_SPEAKING_FIXTURE`; neither opens a real website. Actual external handoff/site load and offline device transitions remain QA-11 manual acceptance, as do full VoiceOver/themes/backgrounds/large text. See [resource contract](../../../contracts/resource-library-v1.md).

## SC-D015 review regressions — 2026-10-25

The registered GeneratedPracticeDeliveryTests and GeneratedPracticeRepairTests cover synthetic policy/transport refusals, source/kind/policy pinning, full-content identity and compatible cache, explicit retention/non-resurrection, report status/version/expiry/export, stale epoch/exact-prior-record, real store reopen, rollback, durable deletion and unknown-outcome recovery. UI fixtures prove the production policy gate and synthetic report/wording save/restart/removal; they send no provider request. Exact executed runs and source boundaries are in [SC-D015 evidence](evidence/sc-d015-integration-2026-10-25/README.md). Full provider/semantic/content/device/accessibility/learning acceptance remains separate, and missing production policy/adapter/content is still implementation work.

## SC-D016 reviewed integration — 2026-10-25

VocabularyDiscoveryDeliveryTests covers one-shot request settlement, malformed/late/duplicate callbacks, full policy/source/choice pinning, reset/restart privacy, hidden edits/reveal, blocked enrollment, same-day pin stability and no credit. BootstrapLaunchTests adds an isolated production unavailable-state/draft-restart journey. Actual runs and remaining physical/accessibility/content/provider scope are in [SC-D016 evidence](evidence/sc-d016-integration-2026-10-25/README.md). A real isolated repository test verifies exact pin reopen, failed-write rollback, stale/changed-record rejection and reset invalidation. Production supplies no reviewed pool or daily selection action.

## SC-D017 acceptance follow-up — 2026-10-25

ResourceLibraryAcceptanceTests adds eight uncovered test definitions for additional YouTube hosts, credential/suffix/encoded-host boundaries, raw-query preservation and real repository reopen/duplicate/open identity. BootstrapLaunchTests adds testResourceRealSystemHandoffAndReturnPreservesNotes without an open-failure/offline override. Actual run results and remaining acceptance are in [follow-up evidence](evidence/sc-d017-acceptance-2026-10-25/README.md); browser foreground is not page-load/redirect or physical proof.


## SC-D004 focused regression — 2026-10-25

[Implementation scope](../development-plan/sc-d004-2026-10-25.md) adds hosted checks for all four focus mappings, local-day expiration, legacy Codable values, failed writes and stale epochs, unavailable saved versions/completed-course filtering, feedback reason provenance, missing/different rubric/provider comparability, completion-time weekly attribution and hidden recall exclusion. The new UI journey checks all four focus choices through restart, Today/Progress consistency and actual practice navigation; recall/listening verifies written retention defaults off. Existing preference recovery and lesson/journey checks run with the bounded batch. Simulator results do not replace physical VoiceOver/Dynamic Type, qualified content review or learning acceptance.

## SC-D002 first-introduction delivery — 2026-10-25

IntroductionDeliveryTests covers exact v4 minimum counts/quiet outcome, post-reveal/exact-version/no-reserved guide binding, asset/audio checksums, protected exact-v3 reopen/rejection, seven-presenter invariance, specialist provenance, frozen baseline source/exposure/legacy decoding, unscored comparison-before-completion and legacy preservation, plus malformed guide rejection. Two native journeys verify new guide/rubric visibility and skipped-core refusal plus full restart/quiet/course/vocabulary flow. [Actual runs and remaining acceptance](evidence/sc-d002-2026-10-25/README.md); source/fixture success is not educator, provider, physical or longitudinal learning proof.

## SC-D005 executable reward checks — 2026-10-25

`RewardDeliveryTests` checks actual adopted amounts, event/date identity, integer half/zero limits, nonstacked speaking adjustment, fresh rated opportunities, hints and quotes, cancellation/stale/duplicate/failed purchase behavior, owned Freeze use and Repair boundaries/cooldown, failed source-save rollback, reopen/delete-all invalidation, plan final self-review/no time dependency, active/idle/audio/background and focus ownership, settings/reminder dates/goal cancellation predicates, acknowledgments, all 68 art hashes/native thumbnail decodes and unavailable learning criteria. The UUID-isolated Debug-only reward UI fixture finishes the real INTRO-01 v4 domain journey through the repository; it never grants arbitrary wallet currency and is unavailable in Release.

Native phone/tablet journeys test cancellation/one confirmed purchase/restart and dark/large-text preferences/unavailable learning details. [Evidence](evidence/sc-d005-2026-10-25/README.md) retains initial failures and retests. Fixtures are not physical notification/haptic/VoiceOver acceptance, qualified educational review or actual learner improvement. Original RW/AV and retention acceptance remain required before done.
