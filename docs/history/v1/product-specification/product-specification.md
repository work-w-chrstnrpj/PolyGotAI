# SpeechCoachAI Product Specification

> Status: IN_PROGRESS
> Product intent recorded 2026-10-15. No application implementation exists. Owner UI/UX intent and full-path public-release target are recorded; detailed screens, content volume and implementation readiness remain open.

## Owner direction change — 2026-10-25

The owner set a new direction: Learn holds the CEFR A1–C2 course plus ten specialist coach tracks (Grammarian; Reading & Listening Comprehension; Debater & Argument; Persuasion & Negotiation; Public Speaking & Rhetoric, verbal and nonverbal; Journalist; Creative Writing (fiction); Business & Professional; Storytelling; Advertising & Copywriting). Coach lessons move out of Speech Lab. Speech Lab focuses on articulation, dictation, voice and phonetics. Lesson content may be derived from open and well-known sources, written in original wording. This supersedes the seven-trainer and Speech Lab scope below where they conflict. Delivery plan and open decisions: [direction plan](../../../development-plan/direction-2026-10-25/README.md).

## Goal and audience

Help learners improve English grammar, vocabulary, pronunciation, fluency, and speaking confidence through connected structured learning and speaking practice. Initially built for the owner, with eventual sharing to other learners. Grammar, vocabulary, and speaking have equal product importance; speaking practice leads the first usable delivery.

The owner's strongest difficulty is retrieving words while speaking, followed by constructing correct sentences, pronunciation, and long pauses. Priority order: everyday conversations; pronunciation and clarity; grammar while speaking; confidence; interviews; presentations; workplace communication. All are goals, not promises for the first release.

## Confirmed product direction

- Native iPhone and iPad; English first; CEFR progression beginning at A1. Learners may bypass levels rather than being locked by completion. Available content must be distinguished from planned levels.
- Basic lessons, vocabulary, local recording/playback and self-review offline. Personalized AI correction requires connectivity.
- Grammar combines explanations, examples, and exercises. Controlled variation within an objective is recommended; randomness is not an approved curriculum algorithm.
- Learner-selectable behaviors default to configurable settings unless the owner explicitly chooses a fixed approach. Useful defaults and session overrides are proposed; exact defaults remain open.
- Correction timing, personality, hints versus corrected answers versus a combination are configurable. Speaking is optional in vocabulary practice.
- Vocabulary combines recommendations and personal words. Today includes Word of the Day; Vocabulary includes daily Anki-style review and custom topic sets. Topic creation offers immediate generation or narrowing through subtopics.
- Missing-word assistance supplies English suggestions; accepted input languages and translation approach remain to be decided.
- Interview practice initially favors software engineering, with configurable role. English and answer delivery lead; technical correctness coaching is optional.
- Spontaneous speech, everyday scenarios, personal introductions, and interview answers all support recording comparison.
- Video resources combine curated and personal YouTube bookmarks displayed as thumbnail/link cards. Embedded playback is optional future investigation.
- Game-like engagement includes points, badges and milestones. Completion achievements and evidence-based improvement achievements are distinct.

## First speaking journey

1. Brief introduction to the coach and a prompt to introduce yourself.
2. Learner records, replays, and optionally re-records their introduction.
3. Connected learner requests feedback afterward; this first encounter is not a live AI exchange.
4. Learner reviews focused feedback, optionally saves vocabulary, retries, or finishes.
5. Participation points and a completion milestone may be awarded. Optional saved recording becomes a baseline for later comparison.

Offline recording and self-review remain useful. No automatic deferred upload is approved. This introduction must not lock a CEFR level or be represented as official certification.

## Feature requirements and acceptance boundaries

| ID | Requirement | Acceptance expectation |
| --- | --- | --- |
| PR-01 | Level choice | Learner can choose available levels without mandatory placement or prerequisite completion. |
| PR-02 | Offline study | Installed basic lesson/vocabulary content and saved self-review work without network; AI actions clearly require connection. |
| PR-03 | Intro recording | Replay/re-record works; AI feedback follows submission; baseline saving is optional. |
| PR-04 | Configurable learning | Settings affect subsequent sessions; temporary overrides have clear scope; exact defaults require design. |
| PR-05 | Daily vocabulary | Learn meaning and create sentences; spoken use optional; self-rating follows attempted recall. |
| PR-06 | Custom topic | Both direct generation and subtopic narrowing exist; generated content can be reviewed before selection. |
| PR-07 | Speaking modes | Everyday, pronunciation, interview and spontaneous practice are explicit backlog capabilities; first-release subset awaits scope decision. |
| PR-08 | Progress | Compare earlier/recent recordings for all four prompt formats; show recall and grammar evidence rather than unsupported scores. |
| PR-09 | Engagement | Reward participation independently of performance; improvement achievements explain supporting evidence. |
| PR-10 | Resources | Curated/personal cards open their corresponding YouTube link; do not infer video understanding from a URL. |
| PR-11 | Speech feedback | Precise pronunciation ratings require validated assessment; uncertain recognition does not become a definitive grammar mistake. |

## Proposed experience organization

Approved main sections: Today, Learn, Vocabulary, Speech Lab and Progress, with Settings accessible from the profile. See [UI/UX decisions](../../../product-specification/ui-ux-design.md); final screen layouts remain under review. Lessons connect learning objectives to vocabulary and speaking. Repeat the same prompt or use a comparable new prompt when examining improvement; task difficulty and assessment version must remain visible.

## Not committed for initial delivery

Other languages, synchronization, accounts, monetization, embedded YouTube playback and advanced pronunciation scoring. Owner UI/UX decisions now require a complete A1–C2 path for public release; this supersedes the earlier limited-release proposal. The initial draft named Spanish, Japanese, Greek and Hebrew as expansion ideas; only English-first is currently confirmed. Listening and reading are now required parts of the complete public-release path; exact content depth and acceptance remain to specify. Natural live AI conversation with streaming, turn-taking and learner interruption remains a desired later capability from the original vision; release timing and implementation are deferred behind the recorded-feedback experience.

## Open product decisions

Remaining decisions include exact release content volume/completeness, detailed speaking-mode coverage, recording maximum, curriculum sourcing/editorial review, evidence-based milestone thresholds, reward deduplication, recovery/export contracts and device acceptance. English-only UI, 20–25-minute daily practice, navigation, optional independent audio/text saving, reminders, accessibility direction and prototype economy are adopted in [UI/UX decisions](../../../product-specification/ui-ux-design.md). Progress remains private. Resolve remaining implementation contracts before tickets claim readiness.

## American English and learning quality direction

Owner alignment recorded 2026-10-15: American English is the default learning variety. Use American spelling, vocabulary, examples and reference voices; explain valid alternatives rather than automatically treating British usage as incorrect. CEFR progression describes communicative abilities independently of this variety choice. Pronunciation practice targets clear, intelligible communication, with American reference pronunciation rather than a requirement to erase the learner's accent.

The owner values Duolingo's structured teaching experience as inspiration. SpeechCoachAI must develop its own content and interaction design; no claim about competitor effectiveness or missing features is adopted as verified fact. Product quality means learners can retrieve vocabulary, construct sentences and communicate in new situations, alongside an accessible, polished native experience.

Proposed learning loop: understand an objective → practice grammar and vocabulary → use them in a speaking task → review focused feedback → retry → revisit later → attempt a new related situation. Completion and XP encourage participation; evidence from delayed recall and comparable speaking tasks supports improvement claims.

UI/UX acceptance should include clear next actions, manageable feedback, convenient record/replay/retry controls, accessible iPhone/iPad layouts and settings that offer useful defaults without requiring extensive setup. Exact screens, numeric usability targets and visual design await design and learner testing.

## Curriculum alignment proposal

Use the official CEFR Companion Volume as the outcome reference and the British Council–EAQUALS Core Inventory as an English curriculum planning aid, adapted to American English. Neither resource alone guarantees alignment. Create original reviewed activities and track each lesson's descriptor reference, level, learning objective, grammar/vocabulary targets, speaking task, assessment criteria, source provenance and editorial review. These references are proposed; copying or licensing content has not been approved.

References: [CEFR purposes](https://www.coe.int/en/web/common-european-framework-reference-languages/uses-and-objectives), [Companion Volume](https://www.coe.int/en/web/common-european-framework-reference-languages/cefr-companion-volume-and-its-language-versions), [Core Inventory](https://www.teachingenglish.org.uk/article/british-council-eaquals-core-inventory-general-english-0), [CEFR phonological competence](https://www.coe.int/en/web/common-european-framework-reference-languages/phonological-competence).

## Dynamic examples and activities

Approved product direction: use a reviewed learning structure with AI-generated variations to make practice relevant and varied while preserving repetition and objective alignment. This is desired behavior, not implemented functionality or a commitment to include every mode in the first release. Fresh/familiar practice preferences are configurable; assessments retain comparability requirements.

| Area | Dynamic practice application | Stable learning boundary |
| --- | --- | --- |
| Grammar lessons | Interest-based example sentences | Current objective and approved explanation |
| Grammar exercises | Correction, completion, sentence-building and dialogue variants | Valid answers, explanations and target grammar |
| Vocabulary | Contextual examples, recall situations and sentence challenges | Word sense, recall target, card identity and schedule |
| Custom topic sets | Topic/subtopic ideas, words, phrases and examples | Learner level, selected topic and reviewable selection |
| AI conversations | Contextual follow-ups and situations | Level, coaching preferences and learning purpose |
| Everyday role-play | Characters, requests and scenario complications | Defined communication task and difficulty |
| Spontaneous speech | New prompts and follow-up challenges | Selected preparation/duration and appropriate level |
| Interview trainer | Role-specific questions and answer-based follow-ups | English/delivery goals; technical coaching remains optional |
| Pronunciation | Sentences containing a selected sound/stress target | Valid reference audio and supported assessment |
| Review | Fresh practice of previous difficulties | Existing objective and comparable challenge |
| Today | Personalized daily speaking/sentence tasks | Learning goals and workload preferences |
| Recording comparisons | Related new prompts alongside repeated baselines | Comparable task conditions; novelty alone is not improvement |

Resource follow-up activities may use learner notes or legitimately available reviewed content, never presumed knowledge of a linked video.

Acceptance: generated activities stay within the selected objective/level and American English defaults; invalid or unavailable generation offers reviewed practice; offline lessons remain usable; valid answer alternatives are handled; repeatable assessments and vocabulary schedules are preserved. Clearly distinguish generated practice from editorially reviewed content without burdening the learner with provider details.

## Public speaking and general communication

Add a communication learning track covering message organization, public speaking, active listening, audience awareness and respectful interaction, linked to Speech Lab and vocabulary. See [Communication training](communication-training.md) for the requested framework catalog, proposed PREP/BLUF/STAR/SCQA/SBI starting sequence, practice loop, settings and acceptance boundaries. Framework use complements CEFR learning rather than certifying a proficiency level. Release coverage remains to be selected.

## Practical communication techniques

Expand the [communication track](communication-training.md#practical-technique-curriculum) to teach clarity/organization, listening/conversation, ethical persuasion, delivery and difficult conversations. Proposed Speech Lab Communication Practice includes short teaching moments before drills, using the same lessons/progress as the Lessons track. An optional daily routine connects to Today and Progress. User-configurable guided/free practice remains available; no separate tab, mandatory daily checklist or new video capability is assumed.

## A1–C2 topic outline

The [American English curriculum outline](../../../product-specification/english-curriculum.md) records proposed topics per level across everyday themes, grammar, vocabulary, speaking, pronunciation and communication. It guides future unit/lesson authoring; CEFR mappings and sequence require editorial review. A1 remains the initial content focus, with A2–C2 expansion planned. Available-level bypass does not make planned content available.

## Bring Your Own Key (BYOK)

Owner-confirmed initial direction: learners supply their own credentials for supported AI providers; the developer does not fund shared AI usage. Provider requests consume the learner's provider account allowance/billing. App pricing/distribution remains undecided; BYOK does not determine commercial status or content rights.

Settings must support selecting a supported provider, adding/replacing/removing a key and checking connection/capabilities with clear disclosure if a check can incur usage. Keep keys masked; never request keys through chat or documentation. No key is required for offline lessons, vocabulary review, recording/playback, saved feedback or self-review. Fresh cloud generation/correction needs connectivity and a usable key for the relevant capability. A key alone does not guarantee every speech/assessment mode is supported.

Explain provider billing, data processing and error recovery before cloud use. Invalid/revoked credentials, rate limits or exhausted balance must preserve local attempts and offer offline fallback. App usage controls can limit app requests but must not be described as a guaranteed provider-wide spending cap. Multiple-provider routing, defaults and usage controls need design; one supported provider may be sufficient initially.

## Articulation Training

Include a dedicated Speech Lab Articulation Training mode for clear speech production and clear expression of ideas. Link reviewed teaching and reference examples to recording/replay, supported feedback and retry. Reuse pronunciation, vocabulary and communication objectives, with configurable focus and optional review enrollment. See [Articulation Training](communication-training.md#articulation-training-in-speech-lab) for activities, BYOK/offline behavior and evidence limits. This is desired product scope, not an implemented mode or clinical service; first-release inclusion remains open.

## Approved learning defaults

The owner approved the [gap-review recommendations](../development-plan/approved-recommendations.md): Introductions as the first A1 authoring target; core completion separate from mastery; default two prioritized corrections with more detail selectable; editable transcripts before grammar/content feedback; explicit rated vocabulary reviews alone advance schedules initially; incorrect-activity reporting; explainable practice suggestions; opt-in recording retention; and learner-tested rewards/evaluation. Implementation parameters remain to be specified. Qwen is the first development provider ecosystem for evaluation, not a promise of permanently free AI or precise pronunciation support.

## Owner UI/UX interview decisions

See [UI/UX decisions](../../../product-specification/ui-ux-design.md) for the approved experience. Current navigation is Today, Learn, Vocabulary, Speech Lab and Progress, superseding the earlier Home/Lessons/Activity proposal. All seven specialized trainer roles, including Creative Writer, are unlocked; see [trainer methods and learning criteria](specialized-trainers.md). Complete A1–C2 coverage across grammar, vocabulary, speaking, listening and reading, with interview/business communication, is the public-release target. Exact authored volume and completeness criteria remain open. The linked decision record supersedes earlier conflicting design/default proposals while implementation remains pending.

## Adopted effectiveness requirements — 2026-10-19

The owner adopted outcome-led teaching, actionable feedback/retry, separate recognition/recall/use/retention/transfer evidence, difficulty-responsive explainable practice, trustworthy assessment and learner validation before expansion. The central product question is: what can the learner now communicate independently that was difficult before? Engagement metrics do not answer it, and no competitor-effectiveness claim is assumed.

The [Introductions learning loop](introductions-learning-loop.md) is the authoritative first-topic outcome, minimum activity pack, completion policy, rubric and initial pilot thresholds. It defines three relevant introduction facts and one follow-up, free offline/quiet completion, supported versus independent attempts, delayed productive recall and unfamiliar-task transfer. These requirements supersede earlier open first-topic completion defaults only within this bounded topic. Lesson count and the broader release volume remain unresolved. First-session friendly onboarding remains distinct from optional formal baseline assessment.

Progress must distinguish participation, recognition, recall, productive use, retention and transfer; separate listening/reading checks and learner-reported confidence remain visible. No single AI rating, repeated script, shorter pause or accent imitation establishes proficiency. Hints never gate free explanations, correction, accessibility or retries; existing optional gold-priced assistance remains available without becoming a prerequisite for learning.

Apply [the four-week acceptance protocol](../testing/introductions-learning-acceptance.md) before course expansion. Numeric thresholds are initial operational criteria requiring educator review, not research-validated cutoffs. Individual results and pilot limitations must be reported before an expansion decision; general effectiveness claims require broader comparative evidence.

## Adopted English Foundations sequence — 2026-10-19

Provide [English Foundations](../../../product-specification/english-foundations.md) within Learn, independently accessible and linked to CEFR lessons: nouns/pronouns and other word types; subject/predicate/object/complement and sentence formation; subject–verb agreement and verb forms; phrases/clauses; and progressive grammar including tense/aspect, modals, conditionals, passive voice and reported speech. The linked specification defines the explicit topic inventory, shared objective contract, initial CEFR lesson connections and EF-AC01–EF-AC08 learning criteria. These are required coverage, not implemented/published lessons or an official CEFR-prescribed grammar order.

Teach concepts through examples and practical use. Assess knowing the grammar concept separately from producing correct sentences and communicating independently; terminology quizzes never gate CEFR speaking success. Contextual refreshers and focused lessons share objective history, permit return to the originating lesson, work offline with installed assets and never lock available levels. Initial delivery is the bounded Introductions subset; later grammar expands through reviewed level/topic batches. Complete public-release coverage must account for every required foundation topic at suitable depth; educator review still owns exact mappings and completeness.

## Specialized trainer adoption — 2026-10-19

The [seven specialized trainers](specialized-trainers.md) are required product scope: Teacher, Grammarian, Librarian, Journalist, Business Professional, Speaker and Creative Writer. Their professions govern specialist-practice teaching methods, activities, follow-ups, feedback and learning acceptance; in the CEFR course each presents/supports the same reviewed training requirements. This supersedes the earlier optional-focus/tone-only model; universal language accuracy, valid alternatives and reviewed CEFR/EF outcomes remain shared.

Learn recommends a trainer for an objective, Speech Lab offers available focused sessions, and Today explains suggestions from goals/observed needs with manual override. Learners need not visit every trainer to complete a lesson. Creative Writer supports written expression and separately assessed spoken storytelling; its animal/visual identity remains undecided. Core instruction/self-review stays offline with installed packs, and specialized AI feedback remains capability/BYOK dependent.

Role-specific fresh-task and delayed criteria are defined in the linked contract and [TR acceptance matrix](../testing/specialized-trainer-acceptance.md). Initial thresholds require qualified review, not official CEFR cutoffs. SC-T044 tracks all-seven pack delivery; the public-release audit requires actual reviewed availability/evidence, not seven cosmetic selection cards. First internal proof uses Teacher/Grammarian/Journalist around INTRO-01, with the other roles still required later.

## CEFR course invariance, conversation and interviews — 2026-10-19

[The course/practice contract](learning-path-and-practice.md) clarifies that curriculum—not selected coach—determines CEFR objectives, sequence/difficulty, required teaching/activities, completion and assessment. All seven coaches can present/support that same course; their profession-specific methods belong in explicitly selected specialist practice. Switching coach preserves course progress/standards. Optional specialist evidence does not automatically complete lessons or advance CEFR levels.

Speech Lab also includes intended AI conversation (free/scenario-based back-and-forth) and interactive interview practice (question, answer, relevant follow-up, review/retry). Software engineering remains the initial interview emphasis with configurable role; technical correctness coaching is optional. Recorded-feedback comes first; later turn-based conversation/interview scope and natural realtime voice investigation must be specified separately. Do not claim live streaming/interruptions or label a single corrected monologue as conversation.

## Congratulatory animation, badges and reward presentation proposal

The requested [design proposal](../../../product-specification/celebrations-badges-and-rewards.md) defines where awards appear, brief skippable coach/badge motion, persistent accessible results, a proposed badge catalog, earned/evidence-unavailable states and delivery after an eligible local award commit. It preserves approved economy values and independent participation versus learning evidence. Motion/catalog/timing decisions await review; app, artwork and learner/device results remain NOT_RUN. Apply CP/RW acceptance in the [combined matrix](../testing/course-practice-and-rewards-acceptance.md).

## Complete award inventory before visuals — 2026-10-19

The [v1 badge/achievement/milestone/reward catalog](../../../product-specification/achievement-catalog.md) consolidates current product scope before visual design: 68 award families (seven existing starter proposals plus 61 newly proposed additions), eight operational milestones/indicators and eight economic event/tool entries. Categories cover participation, consistency, coach-independent CEFR course completion, English Foundations, vocabulary/comprehension/transfer, conversation, interviews, communication, articulation, writing and all seven trainers.

The family count is not the final number of badge images: lesson/topic/unit/objective instances depend on reviewed authored content. All additional names/tiers and badge-versus-milestone choices are draft for review, not new approved economy, new feature availability or implemented awards. The catalog records earning conditions, scope/provenance, evidence/capability prerequisites and explicit unknowns. Review inventory/rules first, then proceed to visuals; existing approved economy and private progress rules remain unchanged.

## Catalog adoption and initial visual proposal — historical record

Owner adopted the complete [68-family catalog](../../../product-specification/achievement-catalog.md), including family names, badge-versus-milestone classification and listed initial tiers. This supersedes earlier wording that all 61 additions still await catalog selection. Exact content-instance sets, qualified learning-rubric validation, capability availability and open operational rules still gate activation; no badge bonus or change to approved XP/gold values is introduced.

Owner then requested a visual proposal. [Illustrated achievement seals](../../../product-specification/achievement-visual-design.md) maps all 68 families to proposed shells/subjects and provides a representative local concept board using retained Page 1 style references. At that proposal stage the direction had not yet been adopted; the subsequent visual-system adoption below supersedes that status. Production artwork, Figma execution and implemented rewards remain separate.

## Achievement visual system adopted — 2026-10-19

Owner adopted [illustrated achievement seals v1](../../../product-specification/achievement-visual-design.md) for all badges, achievements and milestones in the 68-family catalog. This supersedes earlier visual-proposal status. Use warm paper/enamel illustration, deep-ink outlines and the retained Page 1 palette; participation/consistency circles, completion shields and learning hexagons preserve claim type. All 68 mapped subjects and seven trainer signatures, numeric tier tabs, accessible evidence/availability states, themed surfaces and initial celebration targets are required design references.

Per-lesson/topic/unit milestones remain checkpoint rows rather than collectible seals, and XP/gold/operational entries remain separate metrics. Apply the system to all future instances without adding rewards, changing earning rules or affecting the coach-independent CEFR path. Production vectors/small-size assets, Figma/native implementation and actual accessibility/device/runtime results remain pending; the accepted board is the direction reference, not proof of a shipped library.


## Award base artwork delivered — 2026-10-20

The [68-family raster library](../../../../assets/awards/v1/README.md) supplies individually generated transparent PNG illustrations, including milestone icons and every trainer pair. See the [adopted visual system delivery record](../../../product-specification/achievement-visual-design.md#raster-library-delivered--2026-10-20) for static checks and remaining vector/small-size/native work. Actual earning, state overlays and celebrations are not implemented by this asset delivery.
