# SC-D002 first-introduction delivery — 2026-10-25

Owner authorized SC-D002, then requested completion at least to `awaiting_testing`. Codex owns this bounded content/runtime/integration pass. Existing loader/course/specialist/check implementation and valid earlier evidence are reused. SC-D018 is not part of this pass. The other active SC-D004 batch owns Today/Progress/recommendation behavior; its source changes are preserved and test/device execution must be serialized.

## Delivered changes

- INTRO-01 v4 keeps all existing activity IDs, five shared senses, three reading and three listening questions, five grammar and five recall items, guided attempt/self-review, quiet alias and reserved tasks. Its 18 core activities are unchanged in volume. Exact v3 is archived beside v2, so old drafts, first answers and completion remain bound to their source version. Other lessons/audio are unchanged.
- The quiet alias now asks for an answer to the same related follow-up rather than a question back. Alex’s listening answer key no longer assumes a gender from a name/voice. Reference audio and checksum stay unchanged.
- Bundled `IntroductionReviewGuide.json` supplies 19 activity reviews with valid alternatives, explanations and counterexamples; four rubric dimensions with twelve anchor descriptions and not-assessed boundaries; six self-review prompts; and version-specific method/feedback/criteria guides for foundations, Teacher, Grammarian and Journalist. No raw learner evidence or publisher wording is embedded.
- `IntroductionReviewGuide` validates its named version/draft state and binds activity reviews to exact lesson version and reveal state. The existing lesson player displays alternatives after an attempt is revealed; it never shows reserved assessment answers. Optional-pack guidance follows exact pack version and appears only with an already-revealed practice example. A guide is advisory content, not an automatic grader.
- V4 completion requires comparing the six comprehension, five grammar and five recall examples after trying. Unscored open responses cannot determine which were wrong, so all sixteen use the same free comparison step. Incorrect answers may still complete after review; original first responses remain unchanged. No new activity or accuracy threshold is added. V2/v3 retain their original completion behavior.
- Personal check snapshots now freeze optional source-content version and teaching-exposure state at start. Prompt repetition is a separate existing field. Earlier snapshots decode with missing values and show unavailable comparability rather than inferring an old baseline from the current course state. This is an optional Codable extension in existing storage, not a SwiftData migration.
- `complete_intro.py` applies the bounded update/archive safely and refreshes the guide asset manifest; the original authoring helper preserves later named INTRO versions. The new guide/domain/view/tests are registered in the real targets. Existing SC-D004 recommendation tests exposed an old archive-less test call, which is adapted to the current API without changing the other batch’s implementation.

## Content/standards record

[Coverage/reviewer checklist](coverage.md) and [machine-readable content audit](content-audit.json) freezes counts, versions, rights, asset checksums and unavailable review. Wording is original agent-authored personal-use material. SC-T006’s owner direction allows personal use without hiring an educator; it does not supply qualified rubric/descriptor review, task comparability or a public-release/CEFR certificate. Both facts remain explicit.

The Council of Europe [global scale](https://www.coe.int/en/web/common-european-framework-reference-languages/table-1-cefr-3.3-common-reference-levels-global-scale), [phonological competence](https://www.coe.int/en/web/common-european-framework-reference-languages/phonological-competence), and official [2020 Companion volume](https://rm.coe.int/cefr-companion-volume-with-new-descriptors-2020/16809ea0d4) were inspected on 2026-10-25. Candidate mapping uses overall oral production/experience p.62, information exchange p.78, oral comprehension p.48, reading comprehension p.54 and grammatical accuracy p.132. These support bounded authoring connections; exact task/descriptor suitability and thresholds remain a qualified-review acceptance check. No descriptors are copied into the app or transformed into verified level scores.

## Requirements and remaining acceptance

| Ticket | Delivered implementation/authoring | Remaining acceptance |
| --- | --- | --- |
| SC-T018 | Minimum pack, foundation/specialist routes, alternatives/explanations/rubric anchors/criteria/source/rights and version compatibility | Qualified editorial/assessment review of the named personal-use draft, original content/owner acceptance |
| SC-T019 | Existing version-aware bundle loader/assets, new hashed guide and exact historical lesson | Offline install/update/device and content acceptance |
| SC-T020 | Existing resume/quiet/course flow plus v4 comparison-before-completion and post-reveal review | Actual device/accessibility/owner acceptance; no learning result implied |
| SC-T021 | Existing shared vocabulary, recording/provenance/return, focus choices, personal checks; frozen check source/exposure added | Original provider/device/prerequisite and connected learning acceptance |
| SC-T043 | [Concrete prospective protocol](pilot-protocol.json), named task/rubric/source and decision boundaries prepared | Consent, reviewer, actual four-week/day-7/day-28 observations, blinded audio/feedback review and an actual expansion decision |

SC-T043 is an acceptance ticket: drafting its protocol is not executing a pilot. It remains pending until actual activation/prerequisites. No fake participant, dates, consent, human judgment or expansion approval. Learning, audio and text retention remain voluntary; decline or deletion means the corresponding evidence is unavailable. Existing self-paced checks do not falsely claim the timed prospective protocol.

## Pilot execution package

Use [pilot-protocol.json](pilot-protocol.json) together with the existing IL/EF/TR criteria. First resolve qualified reviewer, exact reviewed versions, accommodations, actual preparation/recording limits and consent. Baseline precedes teaching; declining never blocks the course. Log actual exposure, support, external study and deviations. Day 7 ±2: five-sense productive recall before reveal and neighbor transfer; day 28 ±3: recall, repeated baseline and classmate transfer. Keep grammar/specialty evidence separate. Use only consented protected audio for actual blinded listening; text cannot establish intelligibility. No learner payload goes in repository docs. Record every unavailable/failed dimension and the real decision: cautious expansion with limits, rework/retest, or justified bounded next experiment. Insufficient evidence is not efficacy.

## UI and verification

Read the UI guide and local Page 1 template snapshot; native DisclosureGroup API and its official documentation JSON were checked on 2026-10-25; reused T04/T05/T06, shared Kit cards/text/disclosure and native flow. The guide expands inside the current review step rather than adding a second course engine. Appearance/background remain existing preferences; larger text, VoiceOver and physical acceptance remain separately scoped. No Figma writes or live-design inspection.

Actual executed runs, initial failures/retests and screenshot scope are recorded in [evidence](../../testing/evidence/sc-d002-2026-10-25/README.md). Synthetic learner stores only; no live provider call, owner-data reset, migration or physical install.

Authoring/runtime status: SC-D002 awaits testing, with SC-T018/019/020/021 awaiting_testing and SC-T043 pending actual acceptance. Qualified/public review gates remain separate. See [grouped report](../grouped-ticket-report-2026-10-25.md).

Final scoped verification passed: 262 hosted tests on iPad A16, eight focused introduction regressions on phone, and both final iPhone 18 Pro Max UI journeys covering restart/quiet completion/vocabulary and post-reveal rubric/skipped-core refusal. Initial stale-test and simulator bootstrap failures are retained in evidence.
