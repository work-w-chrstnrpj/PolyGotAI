# CEFR course, coach support and independent practice

> Owner clarification recorded 2026-10-19 (Asia/Manila). Product requirements, not implemented features. This clarification takes precedence over earlier wording implying a trainer choice changes the CEFR lesson method or required activities.

## Four distinct contexts

| Context | What determines the training | Coach's role | Effect on course progress |
| --- | --- | --- | --- |
| CEFR course in Learn | Reviewed curriculum defines objectives, sequence, level/difficulty, teaching/activity structure, required content, completion and assessment | Selected coach presents the same lesson and grounded feedback; changes in character/voice/tone or optional explanatory framing cannot alter required teaching, answers, rubric or assessment support | Completing the defined lesson updates its course progress; switching coach never substitutes activities, changes difficulty or adds requirements |
| Specialist practice | Learner chooses a skill/objective and a reviewed trainer pack | Profession-specific method, activities, follow-ups and feedback from the seven-trainer specification | Records optional practice evidence linked to shared objectives; does not complete an unattempted CEFR lesson, move the learner to another level or change the course |
| AI conversation in Speech Lab | Learner chooses free discussion or an everyday scenario, available level/support and feedback preference | Conversation partner; coach optionally shapes conversational style and agreed feedback focus | Turn-linked conversation practice/evidence only; no automatic course advancement |
| Interview practice in Speech Lab | Learner chooses role, interview type, topic/preparation and available turn mode | Interviewer asks a question, receives an answer, asks relevant follow-ups and offers review/retry; Business Professional is the suggested default, not a lock | Interview/English-delivery evidence distinct from course completion; technical correctness coaching stays optional |

The curriculum is the course; coaches support it and offer optional specialties. Speech Lab supplies independent practice. There is no mandatory seven-coach circuit or profession-specific rewrite of a CEFR lesson. Learners may freely select available levels under existing policy; a course recommendation is not a prerequisite lock.

## Coach switch and return rules

On a CEFR lesson, switching Teacher → Writer → Journalist preserves lesson/objective/version, order, difficulty, core items, answer rules, completion and independent assessment. A Writer cannot replace required grammar with story writing, and a Journalist cannot add required interviewing questions. An optional refresher/example is labeled assistance and cannot modify a frozen independent test. Voice/character preferences may change at a safe boundary without restarting a test when only presentation changes; any substantive support/task/rubric change requires a separate attempt and loss of independent comparability.

Learners can explicitly leave for a related specialist session and return to the saved CEFR position. Identify the new context and objective before beginning; do not silently convert lesson feedback into another mode. Shared objective/source-attempt references prevent duplicate rewards/evidence, while specialist performance stays separately interpretable. The existing INTRO-01 core pack/rubric remains unchanged whichever coach presents it; the three early specialist packs are additional choices outside that required flow.

## AI conversation behavior and staged delivery

AI conversation is an intended distinct capability, not another name for uploading a monologue for corrections. The interaction loop is learner turn → relevant AI response/question → learner reply, with visible turn history, Stop/End and feedback at the chosen supported timing. Offer everyday role-play and free discussion; state scenario/objective and available language/support before starting. Session limits, context retention, costs, transport and exact first-delivery modality require specification before implementation.

Recorded-feedback delivery remains first. A subsequent bounded turn-based conversation can use text or recorded turns once scoped and supported; neither is automatically a live voice call. Natural realtime voice with streaming, turn-taking and learner interruption remains desired later work requiring provider/audio/transport investigation and an explicit release decision. Do not label recorded one-shot feedback as conversation, or promise streaming/interruptions from an untested provider. No implementation date or new provider is selected by this clarification.

Basic reviewed scenarios, solo rehearsal and saved self-review remain useful offline. Fresh personalized AI replies require supported online capability and an authorized request/session policy. No-key/offline/failure preserves the learner's work and offers solo practice; it cannot pretend an AI partner is replying. Define paid session consent, cancellation, turn/request identity, context window/privacy and explicit retries before enabling interactive requests; do not infer ongoing billable-session consent from a previous one-shot feedback request.

## Interview behavior and boundaries

Initially emphasize software engineering, with configurable roles as already adopted. Choose an available interview type such as introduction/behavioral/role-specific; author/review the actual included inventory before showing it as available. The delivered interview loop must include at least one relevant response-dependent follow-up, an afterward English/organization review and an optional answer retry. A single fixed prompt plus feedback can be useful answer rehearsal but does not satisfy interactive interview acceptance.

Preserve learner-supplied experience and factual uncertainty. Fictional practice personas are explicit; never invent employment, achievements or numbers. Do not impose STAR/PREP terminology as a success requirement, infer confidence from speech, or equate technical fluency with English proficiency. Text, recorded turns and realtime voice must be labeled honestly. Realtime interviewing inherits the deferred live-conversation investigation; turn-based interviews need not wait for that capability.

## Acceptance and ownership

Use CP-QA01–CP-QA08 in [course/practice and reward acceptance](../testing/course-practice-and-rewards-acceptance.md). SC-T018/SC-T020/SC-T021/SC-T043 verify CEFR invariance around INTRO-01; SC-T007/SC-T010 design/route contexts; SC-T035 decomposes conversation/interview delivery and deferred live research; SC-T044 implements specialty packs only in explicit specialist context. SC-T040 audits included capability claims. All content/device/provider/learner checks remain NOT_RUN.
