# Approved Learning and Delivery Recommendations

> Current readiness and remaining-choice authority: [consolidated readiness review](readiness-review.md). Dated earlier pending statements are historical where superseded by recorded approvals; they are not additional start gates.
> Status: IN_PROGRESS
> Owner approved the gap-review recommendations on 2026-10-15. Decisions below guide implementation; no code, provider integration or account configuration has been completed.

## Adopted defaults

| Area | Approved recommendation | Work remaining |
| --- | --- | --- |
| Public release / internal sequence | Complete A1–C2 five-skill path plus interview/business coverage; internally prove recorded feedback, then one A1 topic | Define completeness/content volume; see ../product-specification/ui-ux-design.md |
| Curriculum | Introductions as the first authoring target; reviewed objectives, prerequisites, examples, vocabulary, activities and assessment | Qualified educator review and original/permitted assets |
| Completion | Core activity completion distinct from mastery; optional AI feedback never blocks offline completion | Define core activities per lesson type |
| Feedback | Separate grammar, vocabulary, organization and supported speech observations; default two prioritized improvements, configurable detail | Versioned response schema/rubric and quality evaluation |
| Transcripts | Learner can correct recognized text before final grammar/content feedback; retain original recognition separately | Define edit lifecycle; edits are never pronunciation evidence |
| Provider | One provider ecosystem initially; Qwen via Alibaba Cloud Model Studio selected for development evaluation | Exact models/region, API/terms compatibility and real-device proof |
| Pronunciation | Reference audio, replay and supported observations first; precise sound scores only after validated assessment | Capability validation and suitable audio |
| Review | Evaluate FSRS; distinct meaning/productive-use cards; initially only explicit rated reviews advance schedules | Library/license, parameters, clock/migration tests; lessons retain separate evidence |
| Generated content | Reviewed templates, validation and fallbacks; report-incorrect-activity action | Reporting storage/privacy and content-resolution workflow |
| Personalization | Explainable suggestions based on goals, due reviews and recent difficulties; manual level choice | Ranking/defaults and evidence definitions; automatic placement deferred |
| Retention | Independent opt-in audio and transcript/feedback saving; saved records support 30-day Recently Deleted and permanent purge; declined temporary audio bypasses recovery | Concrete lifecycle, storage, export/restore and recovery tests |
| Settings | Global defaults, mode defaults and session overrides; unavailable capabilities explained | Precedence proposed: session → mode → global → app default; exact defaults require spec |
| Rewards | XP levels and spendable gold; three free daily hints; Freeze/Repair and prototype values per UI/UX record | Event deduplication, repeat rules and learner tuning |
| Foundation | Select app stack/store/OS/content/signing and repeatable checks; backend only if necessary | Architecture decision record; no stack chosen by this approval |
| Learning evaluation | Repeat baseline and related unfamiliar task, test vocabulary retention, collect owner usefulness feedback | Define comparable tasks and educator-reviewed rubrics |

Scope approval does not close technical investigation or select unresolved parameters. Learner-configurable preferences remain the default policy. No timetable or full A1–C2 launch promise is established.

## Qwen development evaluation

Owner favors Qwen speech models for trial-based development. Evaluate Alibaba Cloud Model Studio as the first BYOK ecosystem; exact speech, text-feedback and reference-voice models remain candidates. A provider ecosystem may require separate models for transcription, coaching and speech synthesis. ASR is not pronunciation assessment, and TTS is not feedback. General audio understanding does not establish calibrated sound-level scoring.

Public information verified 2026-10-15: [pricing](https://www.alibabacloud.com/help/en/model-studio/model-pricing) lists Singapore/International `qwen3-asr-flash` and `qwen3-asr-flash-filetrans` trial allowances of 36,000 seconds (10 hours), and `qwen-audio-3.1-asr-flash` a 1,000,000-token allowance. Eligible Qwen Omni variants also list token-based trials. These are examples to investigate, not selected deployment models; offers change and actual account eligibility is unverified.

[New-user quota rules](https://www.alibabacloud.com/help/en/model-studio/new-free-quota) describe model-specific allowances, generally 90-day validity for eligible activations, account/RAM shared usage and Singapore/International eligibility. Check each model's pricing entry and the account console rather than extrapolating one allowance to all speech models. Older activations may have different terms. ASR access can require individual model enablement. Tokens are not minutes or requests.

Before trial calls: verify exact model/region/endpoint, remaining allowance and expiry, required access, compatible general-purpose key and Free Quota Only availability; enable Free Quota Only for selected eligible models and confirm it took effect. The provider says it is disabled by default and continued use can incur pay-as-you-go charges. Do not assume automatic free-only fallback or switch models silently. Storage/upload services may have separate costs not covered by model quota. No console changes, credentials or real-provider calls have been performed.

## Proof acceptance

On iPhone/iPad, use an owner-configured Keychain credential to test a short English recording, preserve recognized text and learner edits, produce structured grammar/vocabulary/organization feedback, replay/retry and retain permitted history. Check latency, billing units, bad key/quota/network cases and native-client requirements. Compare outputs against reviewed examples including recognition mistakes and valid American/British alternatives. Stop free-only calls when the allowance is unavailable; use fixtures/self-review until explicitly configured otherwise. Record observed capabilities before committing integration choices.

The first proof does not require realtime dialogue, full curriculum generation or precise pronunciation scores. Keep adapters replaceable so development trial availability does not become a permanent product dependency.

## Subsequent UI/UX decisions

The [owner interview record](../../../product-specification/ui-ux-design.md) supersedes conflicting earlier defaults, including navigation, complete public-release scope, gold/XP rules, retention and selectable backgrounds. Native Apple HIG skill use is required during design/coding/review; visuals and device/provider evidence remain pending.

## Effectiveness adoption — 2026-10-19

Owner adopted the following recommendations; documentation adoption is complete, with content, implementation and learning validation still pending.

| Area | Adopted requirement | Delivery / acceptance owner |
| --- | --- | --- |
| Outcome-led teaching | Practical independent communication outcome governs teaching, vocabulary, grammar and comprehension | SC-T001 / SC-T018; [INTRO-01](../product-specification/introductions-learning-loop.md) |
| Feedback into practice | Up to two grounded prioritized actions, optional reduced-support retry, valid zero-correction output and offline self-review | SC-T014 / SC-T020 / SC-T021; IL-04 |
| Evidence | Distinguish recognition, unaided recall, productive use, delayed retention and transfer from completion/XP | SC-T021 / SC-T024; IL-05–IL-08 |
| Adaptation | Difficulty-responsive suggestions with a reason and manual choice; insufficient evidence uses goals/due reviews | SC-T024; IL-09 |
| Trust / engagement | Qualified rubric review, audio-only evidence for intelligibility, confidence self-report, free core learning help/retries | SC-T018 / SC-T025 / SC-T043; IL-01/IL-08–IL-10 |
| Prove before expanding | Four-week owner Introductions pilot, delayed recall and unfamiliar tasks, blinded audio review when consented, explicit expansion decision | SC-T043 before SC-T026; [protocol](../testing/introductions-learning-acceptance.md) |

The linked first-topic criteria define concrete scope now; SC-T001 still resolves remaining first-proof defaults and volume/design details. Numeric targets are initial pilot defaults requiring educator review before use, not established mastery/CEFR cutoffs. Failed, missing and ceiling results remain visible. A single-owner pilot cannot establish causal effectiveness or superiority to another product. Complete public-release scope is unchanged.

## English Foundations adoption — 2026-10-19

Owner adopted [English Foundations](../../../product-specification/english-foundations.md): explicit word types; subject/predicate/object/complement and sentence construction; subject–verb agreement and verb forms; phrases/clauses; progressive grammar. The sequence belongs within Learn with independent/contextual access, shared CEFR-linked objectives, reviewed mappings and no prerequisite level locks. Concept identification, controlled production, communication and delayed/transfer evidence are distinct (EF-AC01–EF-AC08).

SC-T006 owns coverage/publication mapping; SC-T018/SC-T020 deliver the bounded Introductions subset; SC-T043 includes its learner checks without replacing IL/vocabulary measures. SC-T026 and later level outlines decompose remaining coverage; SC-T040 audits all required topics. Numeric EF thresholds are initial operational defaults requiring educator review. No new application work, public curriculum, technology or additional navigation tab is claimed.

## Seven specialized trainers — adopted 2026-10-19

Owner adopted [Teacher, Grammarian, Librarian, Journalist, Business Professional, Speaker and Creative Writer](../product-specification/specialized-trainers.md) as unlocked profession-specific trainers. Methods, activities, follow-ups, feedback and learning criteria differ; shared language standards, curriculum evidence, optional retention and capabilities remain consistent. Creative Writer's animal/artwork/name/voice are open design choices. Learn/Speech Lab/Today use skill-based selection, explained suggestions and manual choice without mandatory seven-role circuits.

SC-T018/SC-T020/SC-T021/SC-T043 prove three early methods around INTRO-01; SC-T007/SC-T010 cover selection/reference behavior, SC-T024 suggestions, SC-T035 workplace and SC-T036 communication/audio practice. New SC-T044 owns decomposed all-seven pack coverage and TR learning checks before SC-T040 release audit. Initial numeric criteria need educator review; no content, implementation or efficacy is completed by this adoption.

## Course independence and reward-design request — 2026-10-19

Owner clarification adopts [fixed CEFR training across coach choice](../product-specification/learning-path-and-practice.md), separate optional specialties and independent AI conversation/interview practice. This supersedes any trainer-method wording suggesting seven CEFR lesson variants. Recorded feedback remains first; turn-based scope and later realtime capability are separate investigations, not delivery claims. Apply CP-QA01–08 via SC-T018/SC-T020/SC-T021/SC-T043/SC-T035/SC-T044.

Owner requested a documented [congratulations/badge/reward proposal](../../../product-specification/celebrations-badges-and-rewards.md). Its display hierarchy, example badge catalog, motion timing/gestures and settings are proposals requiring review, not newly approved economy rules or art. Existing privacy, free-help, accessibility, participation/evidence distinction and prototype values remain adopted. SC-T007/SC-T025/SC-T024 own review/decomposition and RW-QA01–08; no implementation or runtime acceptance is claimed.

## Catalog-first request — 2026-10-19

Owner requested the full list of badges/achievements/milestones before visuals. [Catalog v1](../../../product-specification/achievement-catalog.md) provides the complete draft award-family inventory against current scope, separates the seven prior proposals from new proposed additions, and lists existing economic/operational entries. This request approves catalog preparation and sequencing, not all new family names/tiers or extra payouts. SC-T025 must review exact scope/rules and classification before visual design; no economy values, coach-independent CEFR rules or learning-evidence requirements change.

## Full catalog adoption — 2026-10-19

Owner explicitly adopted [catalog v1](../../../product-specification/achievement-catalog.md): all 68 families, names, existing classifications and listed initial tiers, including the previously proposed 61 additions. This supersedes prior notes saying the additions need initial selection. Unresolved operational/content-instance contracts and qualified learning review remain separate from owner scope adoption; existing economy values are unchanged.

Owner requested the subsequent [achievement visual proposal](../../../product-specification/achievement-visual-design.md). One local ImageGen concept board and all-family subject mappings are available for review; at that stage visual direction awaited adoption; the later adoption entry supersedes that status. Production exports, native/motion/accessibility and Figma/device acceptance remain pending.

## Achievement visual direction adopted — 2026-10-19

Owner adopted [visual system v1](../../../product-specification/achievement-visual-design.md) after catalog adoption. This supersedes prior statements that its visual direction, shells, mapped subjects, category palette, trainer signatures, tier/state/surface treatments and initial composition/motion targets await selection. Use the system for all 68 families, retaining noncollectible checkpoints and separate metric indicators. Production files, exact native rendering choices, accessibility/device tests and operational activation rules remain pending; they do not reopen the direction. SC-T007/SC-T025/SC-T024/SC-T040 own production/fidelity/audit work, with AV-QA01–08 and existing RW checks.

## First-slice decision and sequencing refinement — 2026-10-21

Owner approved ticket/dependency refinement without product expansion and expressly withheld application-development authorization. SC-T001 now consolidates existing scope plus the owner-selected 1–120 second internal-proof range (subject to feasibility) and countdown off initially. General recording maximum, architecture, provider compatibility, first-flow appearance and editorial review remain with their existing owners. See its decision record and the current milestone/tracker state; no runtime evidence is implied.

## Architecture/retention research decisions — 2026-10-21

SC-T002/SC-T003/SC-T004 completed as documented decisions/research. Owner selected minimum OS 17+, no learner-data device backups, 24-hour interrupted recovery and preserved participation credits on individual purge; canonical technical/retention records hold details. Qwen remains a proof candidate with account/International terms and RF execution open. No runtime acceptance or app development authorization.

## First-launch/content readiness — 2026-10-21

Owner confirmed Creative Academy initial background, System appearance and Elephant Teacher initial presenter. Independent free selection and fixed CEFR training remain unchanged. Owner has no qualified reviewer; publication review remains pending. SC-T005 selects bundled reviewed offline resources/versioning within existing scope; SC-T006/SC-T007 explicitly retain editorial/design input and owner-walkthrough gates. No app implementation authorized.

## SC-T007 live audit update — 2026-10-21

SC-T007 source/component/token/artwork checks complete; owner confirmed original coach images were generated for this project in Figma. Existing first-launch defaults and approved artwork identity preserved. No new art, app scope or implementation authorized; SC-T006 qualified educator review remains pending.
