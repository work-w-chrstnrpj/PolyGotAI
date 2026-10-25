# Introductions learning acceptance protocol

> Planned on 2026-10-19 (Asia/Manila). Every check is NOT_RUN. This is an internal four-week owner pilot, not a delivery estimate, published efficacy study or authorization for provider/account changes.

## Preconditions and frozen protocol

Use [INTRO-01 and its rubric](../product-specification/introductions-learning-loop.md). SC-T018 supplies the reviewed pack; SC-T021 supplies the connected local journey; SC-T017 supplies separate device/provider proof. SC-T043 owns pilot execution. Qualified educator review must cover level, task equivalence, rubric anchors, answers/alternatives, threshold suitability and rights before enrolling the owner. Record reviewer, date, versions and unresolved limitations. A missing qualified reviewer leaves the corresponding gate BLOCKED; self-review does not replace it.

Freeze baseline, practice and reserved transfer sets; use different transfer prompts at day 7 and day 28. Pilot default: up to 30 seconds of preparation, a topic-only prompt with no model/word bank, and one spoken simple follow-up with at most one verbatim repetition. No coaching or corrective hints during assessment. There is no speaking-speed or minimum-word target; record duration and the app's selected recording cap. Review accessibility accommodations in advance, keep them consistent and report the support provided. Changed conditions require a separate comparison or an explicit noncomparable label.

With owner agreement, plan three practice sessions per week for four weeks, approximately 10–15 minutes each, using recall → production → focused feedback/self-review → retry. This is a pilot exposure plan, not a mandatory daily product setting. Log actual sessions, support, external study and deviations. Check outcomes even when attendance differs; report actual exposure rather than silently excluding inconvenient results.

Obtain separate consent for assessment participation and permitted local audio/text evidence. Use fictional facts if preferred. Blinded audio review needs optional audio retention consent; if declined, live review may support a limited observation but the blinded comparison gate remains unavailable. Never override retention or retain private payloads in project documents. Deletion or withdrawal removes affected evidence from the evaluable set; it cannot become an automatic pass/fail or durable unsupported badge.

## Schedule

| Point | Procedure | Evidence |
| --- | --- | --- |
| Before teaching | Independent introduction and related follow-up; unaided recall of the five selected senses; initial confidence/usefulness expectations | Baseline rubric dimensions, prior knowledge, assistance and assessment conditions |
| Initial learning | Reviewed pack, model comprehension, grammar and productive recall; guided recording or quiet completion; self-review/optional supported feedback and retry | First responses versus corrected attempts; completion and support distinct from assessment |
| Day 7 ±2 days | Delayed five-sense productive recall before answers/review, then reserved transfer task A | Actual delay/practice exposure; unaided recall; independent unfamiliar-task rubric |
| Between checks | Continue the agreed practice plan, using practice-only prompts and targeted support | Actual practice, hints, corrections, requests and failures |
| Day 28 ±3 days | Delayed recall before review, repeat original baseline and reserved transfer task B; collect owner feedback | Rehearsal versus transfer kept separate; retention; rubric changes; reported usefulness/confidence |

Day-zero baseline and day-28 repeat are not sufficient alone: transfer and delayed recall must be reported separately. First-attempt assessment results remain unchanged after corrective practice. A missed window or insufficient evidence is explicitly recorded and does not establish the planned learning signal.

## Acceptance matrix

| ID | Required observation / pass boundary | Owner | Result |
| --- | --- | --- | --- |
| IL-01 | Educator approves minimum pack, equivalents, reserved tasks, anchors and initial thresholds before baseline; any change has a prospective version | Educator / Documentation | NOT_RUN |
| IL-02 | Independent baseline offered without teaching/answer leakage; refusal preserves learning access; assessment conditions and prior knowledge recorded | SQA / owner | NOT_RUN |
| IL-03 | Core completion follows INTRO-01 on iPhone and iPad with installed assets, no key/network; wrong answers corrected/reviewed; quiet completion never yields speech evidence; restart preserves progress | SQA | NOT_RUN |
| IL-04 | Feedback normally offers up to two grounded actionable changes and a retry; valid output may contain zero changes; self-review fallback works without a request; no invented acoustic scores | SQA / educator | NOT_RUN |
| IL-05 | Hints, model exposure and support label attempts as assisted; first responses, recognition, production, retention and transfer remain separate; retries do not duplicate rewards/review events | SQA | NOT_RUN |
| IL-06 | Day-7 recall ≥4/5 and transfer A meets the independent task criterion; timing, actual exposure and failed/missing dimensions reported | Educator / owner | NOT_RUN |
| IL-07 | Day-28 recall ≥4/5 and transfer B meets the independent task criterion; repeated baseline scored separately; no unsupported total proficiency score | Educator / owner | NOT_RUN |
| IL-08 | Qualified reviewer scores retained audio in randomized order with dates/XP/earlier scores hidden; each dimension has supporting observations; afterward compare human judgments with AI feedback and resolve material false corrections/unsupported claims | Educator / SQA | NOT_RUN |
| IL-09 | Seeded difficulty cases produce the corresponding explained retrieval/grammar/follow-up/clarity suggestion; manual choice works; insufficient evidence avoids diagnosis; explanations/retry remain free | SQA | NOT_RUN |
| IL-10 | Confidence/usefulness, accessibility and engagement collected separately; consent, decline/delete/missing evidence, quota/network failures and actual usage handled honestly | SQA / owner | NOT_RUN |

IL-04 and IL-08 supplement, rather than replace, the existing RF-13 feedback-quality sample gate. Human ratings are the pilot assessment reference; app-generated assessments remain unvalidated until reviewed. Record disagreements, false corrections and necessary remediation; parsing success is not educational quality.

## Evidence and decision record

For each check record ID, date, reviewer, device/OS/build, content/task/rubric versions, provider/model where used, actual elapsed time, support/accommodations, source-attempt references, expected/actual result, PASS/FAIL/BLOCKED/NOT_RUN, sanitized artifact reference and defects/retest. Sensitive audio/transcripts stay only in consented protected storage. A private ID or aggregate observation is sufficient in the repository; no raw learner recordings or transcripts in logs, tickets or committed evidence.

Report all enrolled participants (initially the owner), prior ability, completed/missing checks, actual practice and each rubric dimension. For a baseline below ceiling, the initial positive learning signal requires IL-06 and IL-07 plus at least one dimension improving by one level on day-28 transfer versus comparable baseline, with no decline in task success. At ceiling report maintenance/transfer, not gain. Missing evidence or changed conditions yield insufficient evidence; unsuccessful results remain visible. These criteria are diagnostic starting points, not a statistically validated mastery rule.

SC-T043 closes only when content/functional/feedback/privacy checks pass, learning results are reported, blocking defects are resolved and the owner/educator record an expansion decision. A positive learning signal supports cautious expansion. If no signal, ceiling effects or insufficient evidence prevent that conclusion, revise the learning task/protocol and repeat the relevant checks before expansion; an educator/owner may instead document a bounded next experiment with explicit rationale and limitations. Never mark efficacy PASS merely to close a ticket. SC-T026 must link that decision before course expansion; SC-T027 later repeats evaluation across the small course and more learners as scoped.

The final report separates functional delivery, individual task success, observed learning change, usability and engagement. A single-owner before/after pilot cannot establish causal effectiveness, general CEFR advancement or superiority to competitors. Do not publish those claims without a suitable broader comparative evaluation.

## Connected English Foundations checks

SC-T043 additionally executes applicable [EF-QA01–EF-QA08](english-foundations-acceptance.md) for the Introductions foundation subset authored by SC-T018 and delivered by SC-T020. Report the optional concept check separately from the five existing controlled grammar items and independent INTRO-01 performance. The day-7/day-28 windows may also host fresh five-response grammar-production checks for selected foundation targets; these are separate from IL-06/IL-07 five-sense vocabulary recall and do not change those thresholds. Preserve actual target opportunities and task comparability; third-person grammar needs its own reviewed task when absent from a self-introduction. Participation/assessment remains voluntary and retention remains opt-in; missing grammar evidence cannot establish grammar retention. Content review must freeze these checks before baseline. All EF results remain NOT_RUN.

## Trainer-method proof additions

Under SC-T043, execute applicable [TR-QA checks](specialized-trainer-acceptance.md) for the reviewed Teacher/Grammarian/Journalist paths: actual activity/scaffold/feedback differences, shared progress, source-faithful specialty questioning where included and unchanged INTRO-01 completion/independent assessment. Freeze the selected trainer/method for comparable assessments. Specialty criteria and delayed checks are reported separately from IL and EF results; a switched/assisted practice task cannot become an improved independent baseline score. No requirement to deliver all seven full packs in this pilot; SC-T044 owns remaining coverage. All results remain NOT_RUN.
