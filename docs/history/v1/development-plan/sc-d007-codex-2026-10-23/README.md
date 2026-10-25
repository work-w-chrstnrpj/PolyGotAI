# SC-D007 — A1 curriculum authoring and integration checkpoint

Owner assigned SC-D007 directly to Codex on 2026-10-23 and clarified that the Grok handoff library is queued, not active work. No Grok assignment or response is assumed here. Mode: plan-first execution of the existing delivery ticket, with original prerequisite edges retained.

**Current implementation:** [The owner-authorized runtime continuation](../sc-d007-implementation-2026-10-23.md) integrates the personal-use previews with exact v2 archives. The candidate-only statements below describe the earlier preparation checkpoint and are superseded for runtime status by that continuation. Qualified review and actual acceptance remain open.

**Earlier preparation status: in progress.** A concrete unpublished candidate is authored and structurally checked. The owner approved the proposed thirteen-topic scope on 2026-10-23; qualified content review, original INTRO-01 gaps, reviewed integration and real learning acceptance remain outstanding. This is not a complete A1 delivery or an `awaiting_testing` claim.

## Owner scope approval — 2026-10-23

The owner answered **“Approve the proposed scope”** for the thirteen-topic proposal: exact INTRO-01 v3 reuse plus twelve proposed v3 revisions. [The decision record](scope-approval.json) binds that scope to the exact candidate hashes reviewed. The original proposal/review pack is retained unchanged; its pending-owner-scope language is historical and superseded by this record. Null approval fields in that original proposal are not evidence of qualified review or full publication approval.

SC-T073 stays in_progress because qualified mapping/depth, rubric/assets/rights review and full manifest acceptance remain open. This decision does not authorize live integration or waive expansion/learning gates.

## Reviewable deliverables

- [Readable complete review pack](review-pack.md): twelve original teaching notes, sixty concept checks, sixty sentence-production exercises with explanations, practical workplace links, pronunciation self-review and the exact candidate activities/answers. INTRO-01 version 3 is reused exactly.
- [Finite publication proposal](publication-manifest.json): all thirteen original A1 topics; exact lesson/objective/activity/sense/asset identities, proposed versions/core completion, foundation allocations, source/rights and unfilled review/decision records.
- [Candidate catalog](candidate-bundle/CurriculumCatalog.json): schema 1, isolated pack `speechcoach.a1.d007.candidate`, proposal 1. Twelve proposed v3 revisions and exact INTRO-01 v3 reuse. Total 250 runtime-shaped activities, including reserved tasks. Twelve separate editorial sidecars under `topics/` are additional review content, not live learner screens.
- Thirteen existing WAV files copied intact beside the candidate catalog. They retain the original rights provenance and SHA-256/size declarations. No new synthesis, cloud generation or provider request.
- [Structural validation](validate_candidate.py), [ten negative/boundary tests](test_candidate.py) and [production-code runtime checks](run_runtime_checks.py) with [Swift harness](RuntimeChecks.swift).

`editorialApprovalReference` is deliberately empty. The real loader decodes the candidate but keeps all lessons unavailable. Tests use a temporary synthetic reference solely to exercise the production loader; it is never added to live or candidate content. The existing personal-use catalog stays intact.

## Requirement coverage

| Requirement | Concrete work now | Remaining prerequisite/outcome |
| --- | --- | --- |
| SC-T029 | Thirteen-topic coverage and grammar/five-skill allocation; original scope retained | Reviewed complete-level depth, SC-T028, integration and all children; no certification claim |
| SC-T073 | Exact finite manifest and readable content/volume decision | Owner scope approved; qualified review of named version, descriptor mapping, depth, rubric/assets and rights remains |
| SC-T074 | Greetings teaching, agreement/questions/negatives, turn-taking, five production/five concept items, fresh situations | Scope approved; qualified allocation/content review remains |
| SC-T075 | Exact INTRO-01 v3 reuse and identity reconciliation | Original foundation/rubric/editorial/IL gaps remain; no redundant introduction/pilot |
| SC-T076 | Spelling, names/capitalization, noun/determiner/complement distinction, repair requests | Scope approved; qualified allocation/content review remains |
| SC-T077 | Counts/prices, singular/plural nouns, object and noun-phrase head | Scope approved; qualified allocation/content review remains |
| SC-T078 | Days/months/hours, time prepositions and phrases, unambiguous date alternatives | Scope approved; qualified allocation/content review remains |
| SC-T079 | Family/possessives/pronouns, have/has and adjective complements | Scope approved; qualified allocation/content review remains |
| SC-T080 | Home, there is/are, articles, adjective/noun and location phrases | Scope approved; qualified allocation/content review remains |
| SC-T081 | Routines, third-person agreement, do/does/base forms, frequency and coordination | Scope approved; qualified allocation/content review remains |
| SC-T082 | Food requests, countability, some, modal/base form, price and plural variants | Scope approved; qualified allocation/content review remains |
| SC-T083 | Shopping, demonstratives, object-pronoun reference and size requests | Scope approved; qualified allocation/content review remains |
| SC-T084 | Directions, understood imperative subjects, phrases and sentence boundaries | Scope approved; qualified allocation/content review remains |
| SC-T085 | Hobbies, preference/ability, can/cannot and basic coordination | Scope approved; qualified allocation/content review remains |
| SC-T086 | Weather, adjective/state vs current event, present continuous and negatives | Scope approved; qualified allocation/content review remains |
| SC-T087 | Candidate decodes/resolves offline; shared senses and INTRO identity preserved; history risk demonstrated | Approved topic versions; SC-T019/020/028 gates; live merge and explicit old-version access still unimplemented |
| SC-T088 | Bounded acceptance matrix below and separate actual check results | Reviewed integration, iPhone/iPad usability, qualified assessments and actual delayed/unfamiliar evidence |

The sixty mixed production items and sixty concept checks sample multiple child objectives. They are not five unseen items per child and cannot satisfy per-child EF-AC02/03 by count. Longer standalone foundation assessments and appropriate depth remain for reviewer allocation. All new child IDs are proposals, not adopted objective definitions. No content/reviewer/decision requirement is silently reclassified as testing-only.

## Checks actually run

Environment: macOS arm64; Apple Swift 6.4 (`swiftlang-6.4.0.34.1`); Python 3. Commands run from the repository root:

```sh
python3 docs/development-plan/sc-d007-codex-2026-10-23/author_candidate.py
python3 docs/development-plan/sc-d007-codex-2026-10-23/validate_candidate.py
python3 docs/development-plan/sc-d007-codex-2026-10-23/test_candidate.py
python3 docs/development-plan/sc-d007-codex-2026-10-23/run_runtime_checks.py
python3 docs/development-plan/sc-d007-codex-2026-10-23/render_review.py
```

PASS: 13 exact topic allocations, 13 intact assets, 250 activities; source-catalog SHA-256 unchanged. Ten boundary tests pass: complete candidate; invented approval rejected; INTRO rewrite rejected; changed sense rejected; reserved/core leak rejected; incorrect quiet link rejected; corrupt audio rejected; duplicate/missing topic rejected; path escape rejected.

PASS: actual production `CurriculumCatalog.swift`, `CurriculumCatalogLoader.swift`, `LessonJourney.swift`; the needed dependency declarations are extracted verbatim from `VocabularyLink.swift` and `PracticeSessionContext.swift`. No replacement loader/session is used. Thirteen synthetic sessions load offline, keep reserved tasks hidden, substitute quiet text, round-trip/recover drafts and allow participation completion without grading. Typed responses remain text evidence. All twelve changed versions refuse an old-v2 journey; that journey can still resume using its old lesson. A corrupt/missing audio file closes only affected lessons. See [source hashes](checks.md).

NOT_RUN: Xcode build, simulator, physical iPhone/iPad, accessibility/visual comparison, learner assessments, actual delayed checks, qualified editorial/listening review and live provider calls. Application/project/runtime files did not change; these checks are limited to content compatibility and domain behavior.

## Integration requirement demonstrated by checks

Do not overwrite the live catalog with this candidate. Current `LessonSession.begin` refuses different content versions. Changing twelve live lessons to v3 without retaining access to v2 would strand unfinished old journeys. A reviewed integration must retain/load the old lesson versions (including old assets and sense identity) for those journeys, or obtain an explicit compatible upgrade decision with truthful evidence. This access path is **not implemented** by the candidate and is not waived by a test pass.

After approval: (1) record reviewer/owner/expansion decisions against exact hashes; (2) resolve original INTRO-01 and required foundation assessment depth; (3) implement bounded old-version access and test existing v2 progress; (4) merge only reviewed A1 deltas, preserving A2–C2 and exact INTRO-01; (5) run selected hosted/UI offline/restart/quiet/incorrect-answer checks; (6) perform real device/learning acceptance. No new level-specific engine/store/screen is proposed.

## Remaining acceptance matrix

| Gate | What must be demonstrated | Current result |
| --- | --- | --- |
| QA-29 / EF-AC01/08 | Exact descriptor/task fit, difficulty, answers/variants, opportunities, rights and named qualified review | PENDING |
| QA-30/31 | Available-level bypass; old/new objective/rubric/sense history and live offline assets | Candidate structure PASS; live integration NOT_RUN |
| QA-32 / EF-AC02–05 | Separate first responses, support/mode, concept/production/use, intelligibility, retention and transfer | No learner results; mixed-item pack is not per-child mastery evidence |
| QA-33–37 / EF-AC06/07 | Foundation/contextual/focused access, honest completion/evidence and no duplicate scheduling/rewards | Domain constraints partly checked; full integrated foundation journeys NOT_RUN |
| Native | iPhone/iPad offline/restart, larger text, VoiceOver and actual recording/quiet flows on selected build | NOT_RUN for candidate |
| Publication | Approved manifest/topic versions, SC-T043 expansion/SC-T028 prerequisite evidence, reviewed integration | PENDING |

## Inputs and ownership

Read exact SC-T029/073–088 records, SC-T006/028, delivery/queue/workflow, technical intent, English curriculum/foundations/publication contract, real catalog/model/loader/journey/vocabulary/context sources and authoring tool. Official CEFR PDF and Core Inventory page were opened on 2026-10-23; references are mapping candidates, no descriptor text is copied.

No UI was designed or modified. The UI reference guide was read; no new template, Figma write or screenshot comparison is claimed. No Git repository exists; none was initialized. No user data/store, provider setting, credential, active Grok report, runtime source or live resource was changed. This folder belongs to Codex; queued Grok SC-D007 handoff must not be dispatched as a second writer over this work.
