# UI/UX Interview Traceability Audit

> Current readiness and remaining-choice authority: [consolidated readiness review](../development-plan/readiness-review.md). Dated earlier pending statements are historical where superseded by recorded approvals; they are not additional start gates.
> Audited against the visible owner conversation on 2026-10-15. This is a requirements traceability record, not runtime verification.

All **90 numbered questions in eight rounds** are mapped below. Answers are faithful summaries, not verbatim transcripts. “Do recommendation” adopts the stated recommendation; it does not answer a separate subquestion with no recommended value. Later explicit corrections supersede earlier answers. Open details and assistant-selected defaults are labeled instead of promoted to owner decisions.

The effective specification is [UI/UX Design Decisions](../../../product-specification/ui-ux-design.md). Follow-up approvals are included after the eight rounds.

## Audit corrections

- Added free retry/explanation when gold is unavailable and exact cost disclosure before spending.
- Recorded answer-option elimination as paid optional help, with price still open.
- Corrected repeat rewards: the approved half-reward rule covers XP and gold; repeat XP is not wholly undecided.
- Explicitly retained open repeated-mistake fallback and end-of-break interaction details.
- Preserved superseded spendable-XP and locked-coach proposals as history, not current requirements.
- Distinguished delegated defaults, compound-answer ambiguity and later explicit confirmations.
- Corrected stale concept-board status: all three styles are retained; final artwork is still under refinement.

## Round 1: Personality and everyday use

| ID | Question/topic | Owner answer and effective interpretation | Specification |
| --- | --- | --- | --- |
| R1-Q01 | Desired feelings | Motivated, challenged, accomplished. | [Section](../../../product-specification/ui-ux-design.md#experience-and-launch-scope) |
| R1-Q02 | Visual personality | Blend of friendly and professional. | [Section](../../../product-specification/ui-ux-design.md#experience-and-launch-scope) |
| R1-Q03 | App references and dislikes | Duolingo lesson flow; original assets and style, no copied presentation. Other dislikes unspecified. | [Section](../../../product-specification/ui-ux-design.md#experience-and-launch-scope) |
| R1-Q04 | Coach tone and presence | Energetic and encouraging; character form resolved in later rounds. Example wording not supplied. | [Section](../../../product-specification/ui-ux-design.md#onboarding-and-coaches) |
| R1-Q05 | Session context | 20–25 minutes during work breaks. Quiet-practice need resolved later. | [Section](../../../product-specification/ui-ux-design.md#experience-and-launch-scope) |
| R1-Q06 | Device use and accessories | iPhone or iPad; no primary device or keyboard/Pencil/headphone preferences supplied. Later visual exploration is iPhone first, not an iPhone-only product. | [Section](../../../product-specification/ui-ux-design.md#time-accessibility-and-reminders) |
| R1-Q07 | Opening screen | Dashboard of today’s plan and progress. | [Section](../../../product-specification/ui-ux-design.md#navigation-and-daily-journey) |
| R1-Q08 | Guidance | Planned path with optional detours. | [Section](../../../product-specification/ui-ux-design.md#navigation-and-daily-journey) |
| R1-Q09 | Interface and teaching language | All English. | [Section](../../../product-specification/ui-ux-design.md#experience-and-launch-scope) |
| R1-Q10 | Motivation and comfort | Daily goals, configurable reminders, milestones, badges, activity analytics, XP and streaks. Personal accessibility needs not supplied; inclusive baseline approved later. | [Section](../../../product-specification/ui-ux-design.md#rewards-and-prototype-economy) |

## Round 2: Daily journey and coach presence

| ID | Question/topic | Owner answer and effective interpretation | Specification |
| --- | --- | --- | --- |
| R2-Q01 | Daily-plan creation | Automatic; approval of A adopts recommendation with focus change/activity replacement. | [Section](../../../product-specification/ui-ux-design.md#navigation-and-daily-journey) |
| R2-Q02 | Connected or separate sessions | Connected lesson: learn, practice words/sentences, apply in speaking. Independent tools remain available through navigation. | [Section](../../../product-specification/ui-ux-design.md#navigation-and-daily-journey) |
| R2-Q03 | Daily goal metric | Active learning time and activities completed; separate-goal completion rule selected in R3. | [Section](../../../product-specification/ui-ux-design.md#navigation-and-daily-journey) |
| R2-Q04 | Cannot speak at work | Offer quiet practice; full completion/streak credit approved in R3. | [Section](../../../product-specification/ui-ux-design.md#navigation-and-daily-journey) |
| R2-Q05 | Lesson control | Skip explanation, request another example, repeat, go back and leave/resume anytime. | [Section](../../../product-specification/ui-ux-design.md#navigation-and-daily-journey) |
| R2-Q06 | Challenge adaptation and struggle | Ask before harder version. Repeated-mistake fallback was not selected; keep open. | [Section](../../../product-specification/ui-ux-design.md#navigation-and-daily-journey) |
| R2-Q07 | Coach form and speech | Initially original illustrated character; profession animals chosen later; speech resolved in R8. | [Section](../../../product-specification/ui-ux-design.md#onboarding-and-coaches) |
| R2-Q08 | Reward prominence and sensory feedback | Game-like; enjoys sounds and haptics, with settings to control them. | [Section](../../../product-specification/ui-ux-design.md#rewards-and-prototype-economy) |
| R2-Q09 | Missed days | Reset streak, with an XP-traded continuation tool initially requested. Gold replaces spendable XP in R3; Freeze/Repair finalized later. | [Section](../../../product-specification/ui-ux-design.md#rewards-and-prototype-economy) |
| R2-Q10 | Reminder schedule | Configurable; details adopted in R8. No fixed personal reminder time supplied. | [Section](../../../product-specification/ui-ux-design.md#time-accessibility-and-reminders) |
| R2-Q11 | Opening mid-session | Choose between resume and starting something else. | [Section](../../../product-specification/ui-ux-design.md#navigation-and-daily-journey) |
| R2-Q12 | iPad layout | Adaptive: focus for exercises/recording, side-by-side explanations/feedback. | [Section](../../../product-specification/ui-ux-design.md#time-accessibility-and-reminders) |

## Round 3: First launch, goals and lesson behavior

| ID | Question/topic | Owner answer and effective interpretation | Specification |
| --- | --- | --- | --- |
| R3-Q01 | Onboarding | Do recommendation: editable nickname, goals, selected level, daily target, optional reminders; provider setup at first AI request. | [Section](../../../product-specification/ui-ux-design.md#onboarding-and-coaches) |
| R3-Q02 | First introduction entry | All three: start, preview example, skip to dashboard. | [Section](../../../product-specification/ui-ux-design.md#onboarding-and-coaches) |
| R3-Q03 | Coach character | Selectable Teacher, Journalist, Grammarian, Librarian, Businessman, Speaker; later animal styling and Business Professional label approved. Expression behavior later constrained by coach presence/art direction; not an unrestricted reaction system. | [Section](../../../product-specification/ui-ux-design.md#onboarding-and-coaches) |
| R3-Q04 | Combining time and activity goals | C: separate goals; completion reward for finishing plan without requiring full target minutes. | [Section](../../../product-specification/ui-ux-design.md#navigation-and-daily-journey) |
| R3-Q05 | Quiet-practice credit | Yes: full daily goal/streak credit. Speaking evidence stays separate. | [Section](../../../product-specification/ui-ux-design.md#navigation-and-daily-journey) |
| R3-Q06 | Break ending | Optional timer approved. Exact finish-current/save-and-exit UI and almost-over notice were not separately selected. | [Section](../../../product-specification/ui-ux-design.md#time-accessibility-and-reminders) |
| R3-Q07 | Skipping core work | Approve recommendation: optional explanations; skipped core exercises unfinished with comparable replacement; free exit/exploration. | [Section](../../../product-specification/ui-ux-design.md#navigation-and-daily-journey) |
| R3-Q08 | Correction timing and first mistake | Immediate; hint versus reveal remained unanswered here, resolved in R5 as brief explanation/retry. | [Section](../../../product-specification/ui-ux-design.md#navigation-and-daily-journey) |
| R3-Q09 | Hints and retry rewards | Hints cost gold, overriding free-hint recommendation. Accuracy bonus unanswered; participation rules approved later. | [Section](../../../product-specification/ui-ux-design.md#rewards-and-prototype-economy) |
| R3-Q10 | Streak tool type | Both Freeze and Repair. Limits/prices resolved or explicitly open later. | [Section](../../../product-specification/ui-ux-design.md#rewards-and-prototype-economy) |
| R3-Q11 | XP balance versus lifetime XP | XP levels up; gold earned/spent on actions. No spendable-XP balance. | [Section](../../../product-specification/ui-ux-design.md#rewards-and-prototype-economy) |
| R3-Q12 | Path and unavailable content | Answer mixed recommended order/confirmation with unavailable-content blocking/hiding. R4/R5 clarify free released-level choice and Coming later; no prerequisite locks. | [Section](../../../product-specification/ui-ux-design.md#navigation-and-daily-journey) |

## Round 4: Progression and speaking practice

| ID | Question/topic | Owner answer and effective interpretation | Specification |
| --- | --- | --- | --- |
| R4-Q01 | Lesson access clarification | Coming later; free level choice; release with at least complete English path. Scope clarified as A1–C2 in R5. | [Section](../../../product-specification/ui-ux-design.md#navigation-and-daily-journey) |
| R4-Q02 | Role changes versus appearance | Do recommendation: role tone/examples/focus differ, same objectives/quality, switch anytime. | [Section](../../../product-specification/ui-ux-design.md#onboarding-and-coaches) |
| R4-Q03 | Character appearance and role label | Animals styled as professions; Business Professional accepted. Multiple variants not specifically selected. | [Section](../../../product-specification/ui-ux-design.md#onboarding-and-coaches) |
| R4-Q04 | No-gold fallback and extra examples | Do recommendation: free retry/explanation; optional unanswered-exercise aid costs gold. Extra-example cost later adopted. | [Section](../../../product-specification/ui-ux-design.md#rewards-and-prototype-economy) |
| R4-Q05 | Gold earning sources | Every activity earns gold; later approved definition excludes opening/replaying/retry taps and requires genuine completed learning. | [Section](../../../product-specification/ui-ux-design.md#rewards-and-prototype-economy) |
| R4-Q06 | Freeze versus Repair | Do recommendation; Repair covers at most one missed week. Exact cooldown not answered. | [Section](../../../product-specification/ui-ux-design.md#rewards-and-prototype-economy) |
| R4-Q07 | Recording preparation | Optional talking points, hidden sample answer, optional three-second countdown. Separate preparation timer not selected. | [Section](../../../product-specification/ui-ux-design.md#speaking-and-feedback) |
| R4-Q08 | Recording screen and duration | Prompt/timer/audio levels/Pause/Stop; unrestricted pedagogical duration within technical maximum. Provider maximum queried later; app cap unresolved. | [Section](../../../product-specification/ui-ux-design.md#speaking-and-feedback) |
| R4-Q09 | After stopping and take selection | Do recommendation: Play/Re-record/Get AI Feedback/Finish with Self-review; preserve prior take until acceptance. Number of saved takes resolved later. | [Section](../../../product-specification/ui-ux-design.md#speaking-and-feedback) |
| R4-Q10 | Transcript checking | Always confirm initially with audio replay; immutable original recognition distinct from edits. | [Section](../../../product-specification/ui-ux-design.md#speaking-and-feedback) |
| R4-Q11 | Feedback presentation | Strength, two improvements, retry task, expandable detail. Highlights/list preference not explicitly answered here; adopted via R5 recommendation. | [Section](../../../product-specification/ui-ux-design.md#speaking-and-feedback) |
| R4-Q12 | Saving/interruption/leaving/AI failure | Ask Keep recording; interruption restart; ask before leaving; preserve work, explicit retry/self-review. Restart does not imply immediate destruction; clarified R5. | [Section](../../../product-specification/ui-ux-design.md#privacy-retention-and-recovery) |

## Round 5: Content, vocabulary and rewards

| ID | Question/topic | Owner answer and effective interpretation | Specification |
| --- | --- | --- | --- |
| R5-Q01 | Complete English path | A1–C2 complete sequence; all five skills; interview/business required at release. Exact authored volume/completeness criteria open. | [Section](../../../product-specification/ui-ux-design.md#experience-and-launch-scope) |
| R5-Q02 | Level/path movement | Choose any released level. Recommended lesson order/confirmation retained from clarification; no level locks. | [Section](../../../product-specification/ui-ux-design.md#navigation-and-daily-journey) |
| R5-Q03 | Lesson structure and exercise types | Do recommendation; randomized mixture of all seven proposed types, within objective/level/capability and quiet-mode constraints. | [Section](../../../product-specification/ui-ux-design.md#navigation-and-daily-journey) |
| R5-Q04 | Incorrect-answer behavior | Brief explanation with retry before reveal. Exact reveal threshold/learner Show answer action remains detailed-design work. | [Section](../../../product-specification/ui-ux-design.md#navigation-and-daily-journey) |
| R5-Q05 | Paid-help boundary | Approve proposed: explanations/accessibility/corrective feedback free; pre-answer clues, option elimination and extra worked examples can cost gold. Free allowance resolved later. | [Section](../../../product-specification/ui-ux-design.md#rewards-and-prototype-economy) |
| R5-Q06 | Gold activity definition and wrong answers | Do recommendation: genuine completed exercise/review/speaking-self-review; repeat reductions/limits. Incorrect-attempt credit explicitly approved in R6. No real-money purchase recommendation adopted. | [Section](../../../product-specification/ui-ux-design.md#rewards-and-prototype-economy) |
| R5-Q07 | Vocabulary review format | Recall → reveal meaning/audio/examples → Again/Hard/Good/Easy; meaning/production cards. Typing optional confirmed R6. | [Section](../../../product-specification/ui-ux-design.md#vocabulary) |
| R5-Q08 | Saving words | Quick save plus optional edits; deduplicate word/sense. Separate save/review enrollment confirmed R6. | [Section](../../../product-specification/ui-ux-design.md#vocabulary) |
| R5-Q09 | Custom topics | Generation/subtopics with preview/edit/select, level/count/purpose. Offline manual creation approved in R6. | [Section](../../../product-specification/ui-ux-design.md#vocabulary) |
| R5-Q10 | Interrupted and multiple takes | Keep interrupted take temporarily but restart fresh; accepted take default with explicitly saved extras. | [Section](../../../product-specification/ui-ux-design.md#speaking-and-feedback) |
| R5-Q11 | Recovery mechanics and inventory | Approve 1–7-day Repair, longer gap costs more, no invented activity evidence, beyond seven start new streak. As many Freeze items as owned; automatic consumption confirmed R8. | [Section](../../../product-specification/ui-ux-design.md#rewards-and-prototype-economy) |
| R5-Q12 | Quiet-mode persistence | Select every session; no remembered default or quiet-hours schedule adopted. | [Section](../../../product-specification/ui-ux-design.md#navigation-and-daily-journey) |

## Round 6: Navigation and visual identity

| ID | Question/topic | Owner answer and effective interpretation | Specification |
| --- | --- | --- | --- |
| R6-Q01 | Navigation labels | Questioned missing Speech Lab and navigation scope. Corrected to Today/Learn/Vocabulary/Speech Lab/Progress; explicitly approved R7. | [Section](../../../product-specification/ui-ux-design.md#navigation-and-daily-journey) |
| R6-Q02 | Dashboard priority and counters | Do recommendation, yes: learning plan first with goals/reviews/Word of Day/achievements. Counter prominence versus plan was not independently selected; retain plan-first recommendation, not a mandatory counter layout. | [Section](../../../product-specification/ui-ux-design.md#navigation-and-daily-journey) |
| R6-Q03 | Path presentation | C: illustrated unit headers with structured lesson lists. | [Section](../../../product-specification/ui-ux-design.md#navigation-and-daily-journey) |
| R6-Q04 | Art world/style | Forgotten Island mixed-style inspiration. Exact world not selected here; shared base with expressive shifts chosen R7, all three backgrounds selected later. | [Section](../../../product-specification/ui-ux-design.md#onboarding-and-coaches) |
| R6-Q05 | Cast and purchase access | Ask assistant to propose cast; earned with gold initially. R7 approves cast; R8 removes coach locks. | [Section](../../../product-specification/ui-ux-design.md#onboarding-and-coaches) |
| R6-Q06 | Coach presence and autoplay | Introductions, feedback, milestones. Automatic speech not answered here; tap-to-play adopted R8. | [Section](../../../product-specification/ui-ux-design.md#onboarding-and-coaches) |
| R6-Q07 | Color palette | Visual directions first. No fixed palette or prohibited colors selected. | [Section](../../../product-specification/ui-ux-design.md#selectable-background-styles) |
| R6-Q08 | Interface density | Balanced dashboards, focused exercises, useful iPad reference/navigation panels. | [Section](../../../product-specification/ui-ux-design.md#time-accessibility-and-reminders) |
| R6-Q09 | Celebrations | Do recommendation: inline routine rewards; separate lesson/milestone screen. Exact confetti/music/badge effects not selected. | [Section](../../../product-specification/ui-ux-design.md#rewards-and-prototype-economy) |
| R6-Q10 | Response to struggle | Gentler coach. Specific prohibited wording/behaviors not supplied. | [Section](../../../product-specification/ui-ux-design.md#experience-and-launch-scope) |
| R6-Q11 | Progress and social scope | Top three: consistency, skill-by-skill progress, achievements. Private for now; no competition/sharing approval. | [Section](../../../product-specification/ui-ux-design.md#rewards-and-prototype-economy) |
| R6-Q12 | Five remaining learning choices | Optional typing; separate Save/Add to review; wrong attempts earn gold after correction/self-review; accepted take plus optional extra saves; offline manual topics. | [Section](../../../product-specification/ui-ux-design.md#vocabulary) |

## Round 7: Characters, visual direction and access

| ID | Question/topic | Owner answer and effective interpretation | Specification |
| --- | --- | --- | --- |
| R7-Q01 | Main navigation and shared history | Yes to corrected navigation; linked and independent Speech Lab share objectives/history. | [Section](../../../product-specification/ui-ux-design.md#navigation-and-daily-journey) |
| R7-Q02 | Mixed-style interpretation | C: shared character base with sketch/comic/painterly expressive shifts. | [Section](../../../product-specification/ui-ux-design.md#onboarding-and-coaches) |
| R7-Q03 | Proposed cast | Good: elephant/fox/owl/bear/tiger/parrot for the six profession roles. Names/art not approved from later generated board. | [Section](../../../product-specification/ui-ux-design.md#onboarding-and-coaches) |
| R7-Q04 | Coach unlocks | Initially remove locks; all coaches unlocked. Overrides gold-earned coach access from R6. No cosmetics shop selected. | [Section](../../../product-specification/ui-ux-design.md#onboarding-and-coaches) |
| R7-Q05 | Distinct voices | Asked feasibility using Qwen TTS/STT; not yet approval at this point. R8 approves optional presets/tap-to-play/fallback/speed. | [Section](../../../product-specification/ui-ux-design.md#onboarding-and-coaches) |
| R7-Q06 | Three visual directions | Go: explore Creative Academy, Adventure Atlas, Mixed-Media Studio. Later retains all as selectable backgrounds. | [Section](../../../product-specification/ui-ux-design.md#selectable-background-styles) |
| R7-Q07 | Exercise visual energy | Do recommendation: expressive special moments, focused exercises; background movement pauses while reading/typing/recording. | [Section](../../../product-specification/ui-ux-design.md#onboarding-and-coaches) |
| R7-Q08 | Accessibility and themes | Approve baseline; Light/Dark/System. Personal needs unspecified; no assumption that accessibility needs are absent. | [Section](../../../product-specification/ui-ux-design.md#time-accessibility-and-reminders) |
| R7-Q09 | Skill progress and weekly summary | Go with recommendation: five-skill evidence, pronunciation/fluency under speaking where supported; XP distinct from proficiency; weekly suggested focus. | [Section](../../../product-specification/ui-ux-design.md#rewards-and-prototype-economy) |
| R7-Q10 | Free hints and automatic Freeze | Yes, yes. Interpreted as daily free allowance and automatic consumption of owned Freeze items; quantity/auto-use explicitly confirmed R8. | [Section](../../../product-specification/ui-ux-design.md#rewards-and-prototype-economy) |

## Round 8: Privacy, costs and remaining defaults

| ID | Question/topic | Owner answer and effective interpretation | Specification |
| --- | --- | --- | --- |
| R8-Q01 | Coach audio and speed | Yes, yes: preset voices where supported, tap-to-play/text fallback, speed controls. | [Section](../../../product-specification/ui-ux-design.md#onboarding-and-coaches) |
| R8-Q02 | Provider setup | Do recommendation: no key needed to start offline; explain BYOK at first online feature; Settings connection test. | [Section](../../../product-specification/ui-ux-design.md#onboarding-and-coaches) |
| R8-Q03 | Upload confirmation frequency | Once for initial provider/data/cost explanation; explicit action each later request. Changed provider/data scope redisclosure is a design safeguard, not a separately answered question. | [Section](../../../product-specification/ui-ux-design.md#privacy-retention-and-recovery) |
| R8-Q04 | Audio and text retention | Owner asks about voice recording and insists on save choice. Separate text retention not accepted by this answer alone; explicit later annotation says Do this for independent Keep transcript and feedback. | [Section](../../../product-specification/ui-ux-design.md#privacy-retention-and-recovery) |
| R8-Q05 | Deletion and export approach | Delegated best approach. Assistant selects saved-record Recently Deleted for 30 days, restore/permanent purge and export excluding keys. Exact semantics remain open. | [Section](../../../product-specification/ui-ux-design.md#privacy-retention-and-recovery) |
| R8-Q06 | Reminder content and scheduling | Generic wording. Configurable day/time and unfinished-goal schedule retained as proposed defaults under earlier configurable-reminder approval, not owner-selected actual schedule. | [Section](../../../product-specification/ui-ux-design.md#time-accessibility-and-reminders) |
| R8-Q07 | Free hint allowance and cost display | Yes to three daily free hints, visible exact gold cost and no automatic deduction on mistakes. | [Section](../../../product-specification/ui-ux-design.md#rewards-and-prototype-economy) |
| R8-Q08 | Automatic Freeze use | Yes to one item/day, automatic consumption, visible history and disable option; unlimited inventory. | [Section](../../../product-specification/ui-ux-design.md#rewards-and-prototype-economy) |
| R8-Q09 | Daily timezone | Device timezone. Travel/clock/reset deduplication unspecified. | [Section](../../../product-specification/ui-ux-design.md#time-accessibility-and-reminders) |
| R8-Q10 | Offline experience | Yes to lessons/reviews/recording/saved reference audio/self-review, clear alternatives and no automatic reconnect upload. | [Section](../../../product-specification/ui-ux-design.md#privacy-retention-and-recovery) |

## Follow-ups after Round 8

The final rules message had eight numbered items: F02–F09 below. F01 is its annotation; F10–F11 are subsequent owner decisions.

| ID | Topic | Answer/interpretation | Specification |
| --- | --- | --- | --- |
| F01 | Separate text saving | Explicit annotation: Do this for Keep transcript and feedback independent from audio saving. | [Section](../../../product-specification/ui-ux-design.md#privacy-retention-and-recovery) |
| F02 | Maximum recording time | Asked Qwen TTS/STT maxima; no approval of proposed five-minute app cap. Research is in ../api/qwen-capability-report.md; model limits and proof cap are separate from product limit. | [Section](../../../product-specification/ui-ux-design.md#speaking-and-feedback) |
| F03 | Recording controls | Approve tap start, Pause/Resume, Stop, optional countdown. | [Section](../../../product-specification/ui-ux-design.md#speaking-and-feedback) |
| F04 | Active learning time | Approve engaged learning; background/inactivity pause except audio playback. Idle threshold remains open. | [Section](../../../product-specification/ui-ux-design.md#time-accessibility-and-reminders) |
| F05 | Prototype reward values | Approve +10 XP/+2 gold exercise/review; +30/+6 speaking-self-review; +25/+10 daily plan; hint 2 gold after allowance; extra example 4; Freeze 20; Repair 30/day. No double lesson payout. | [Section](../../../product-specification/ui-ux-design.md#rewards-and-prototype-economy) |
| F06 | Repeat earning | Approve full first completion, half one meaningful repeat, no further gold that day; fresh scheduled review eligible; incorrect attempt participation after review. Further-repeat XP was not explicitly set. | [Section](../../../product-specification/ui-ux-design.md#rewards-and-prototype-economy) |
| F07 | AI waiting/failure | Approve status/Cancel/return to learning; preserve work, explicit potentially charged retry, no invented percent or auto retry. | [Section](../../../product-specification/ui-ux-design.md#speaking-and-feedback) |
| F08 | Microphone unavailable | Approve Settings/retry where appropriate/quiet practice, rest of app usable. | [Section](../../../product-specification/ui-ux-design.md#speaking-and-feedback) |
| F09 | Concept platform | iPhone first, then iPad adaptations; does not remove iPad product support. | [Section](../../../product-specification/ui-ux-design.md#onboarding-and-coaches) |
| F10 | All three backgrounds | Owner likes all three and requests setting; retain all as selectable backgrounds independent from Light/Dark/System and coach. Preview/local persistence/free access are assistant-selected implementation defaults stated in response. | [Section](../../../product-specification/ui-ux-design.md#selectable-background-styles) |
| F11 | Apple HIG during coding | Explicit owner request, confirmed: native apple-design-skill used for design/coding/review with current official API/HIG verification and physical acceptance. | [Section](../../../product-specification/ui-ux-design.md#apple-hig-workflow-during-design-and-implementation) |

## Still unresolved or awaiting validation

Historical interview gaps have since been partly resolved: minimum OS/stack, proof duration/countdown, first-launch background/appearance/presenter, separate save defaults, recovery/backup/deletion and first-proof provider candidate are recorded. Use the [complete current register](../development-plan/readiness-review.md#complete-remaining-choice-register) for genuinely remaining choices and their owner tickets; do not ask the earlier interview questions again. Later mode limits, full curriculum volumes, qualified review, voices, support/economy/time policies, export/distribution and actual device/provider evidence remain scoped delivery gates.

No application implementation or new implementation ticket is authorized by this audit. Provider/device evidence remains NOT_RUN.
