# Celebrations, badges and reward delivery

> v2 (2026-10-25): rewards stay as implemented. Today shows streak and XP only; badges live in Progress. Ticket references are history.

> Owner adopted the complete catalog and achievement visual system on 2026-10-19 (Asia/Manila). Use the canonical [adopted visual specification](achievement-visual-design.md) for all badge/achievement/milestone surfaces and the retained board as its visual reference. The delivery hierarchy, static/quiet alternatives and initial motion targets below are design requirements; production assets, runtime checks and unresolved accounting/retention policies remain pending. Approved economy values are unchanged.

## Adopted delivery hierarchy

Use the native completion/result surface and accessible buttons as the base; routine rewards stay inline, lesson results use the existing completion page, and badge details live in Progress. Do not introduce an alert for ordinary success or a new navigation tab.

| Event | Adopted delivery | Information and next action |
| --- | --- | --- |
| Eligible exercise/review reward | Small inline acknowledgement beside the completed activity; no modal | Actual XP/gold delta and reason; preserve explanation/retry/next controls. Normal correctness feedback is not a fireworks event. |
| Lesson/session completion | Persistent result page after finish, with a brief coach congratulations | Completed activity/objective summary, itemized XP/gold, any eligible bonus and next practice; Continue is available immediately. Summarize underlying exercise awards instead of paying again. |
| New participation badge | One grouped badge reveal on the result page or next safe foreground boundary | Badge name, category, date and plain-language criterion; View details and Continue. Skipping motion never forfeits the badge. |
| Evidence-based learning milestone | Result/Progress card only after the reviewed evidence rule succeeds | Specific demonstrated objective and conditions, with Why earned? showing task/date/rubric/support and evidence availability; never imply general mastery. |
| Daily-plan goal / XP level | Combined completion summary or unobtrusive Today card | Actual eligible daily bonus; label XP level as participation level, not CEFR level. Freeze/Repair affects continuity only. |
| Several awards at once | One compact grouped summary; highest-significance reveal first | Consolidated badge list and net ledger changes; avoid serial pop-ups or repeated coach speech. |

Today shows today's completed goals and a recent achievement shortcut. Progress → Achievements shows badges by participation, consistency, reviewed course completion and evidence-based learning. Badge detail shows criterion, earned date/state, related practice and permitted evidence. Profile/Settings may show XP level and gold balance; wallet history explains credits/debits and purchases. Keep progress private with no leaderboard or automatic sharing flow.

## Adopted congratulatory motion

Purpose: acknowledge a meaningful completion and make an earned item understandable. Reserve larger delight for a first meaningful completion/new badge. Frequently repeated exercise rewards use minimal inline feedback. The selected coach may give a small profession-themed gesture (nod, notebook close, book lift, etc.); exact original artwork/gestures for each coach, especially Creative Writer, need review.

Adopted initial design targets, not Apple-mandated timings or measured runtime performance:

1. Commit the eligible result/reward before displaying earned success. Present readable result text and enabled controls immediately.
2. Reveal the result/badge with a gentle opacity/scale transition, target 200 ms from 0.96 to 1.0, ease-out. Avoid moving the reading surface or rolling counters needed to understand a balance.
3. For a rare badge, allow one contained coach gesture or decorative accent, target at most 800 ms. Optional small confetti belongs only around the badge, never over text/controls; no full-screen flash, perpetual sparkle or camera shake.
4. Keep the final badge/result static until explicit Continue/dismiss. Animation completion never enables a button, grants an award or auto-advances the lesson. Skip animation is available immediately; no timed dismissal for meaningful information.

Provide a static equivalent under system Reduce Motion, with the same content, rewards and actions. Add an optional Celebrations setting (full / subtle / off), subordinate to system motion preferences. Quiet mode and existing sound/haptic controls apply independently; optional sound/haptic is supplemental, never required to understand success. Do not autoplay coach speech. Keep focus stable, announce one concise accessible result, and provide standard labeled buttons with Dynamic Type/readable layouts on iPhone/iPad and all three backgrounds. Never celebrate during recording, listening playback, typing or an active assessment; defer/group until a safe result boundary. When app backgrounds, stop decorative playback and return to static results rather than resuming a surprise burst.

This follows the purpose/briefness/interruptibility direction in Apple's [Motion](https://developer.apple.com/design/human-interface-guidelines/motion) and [Feedback](https://developer.apple.com/design/human-interface-guidelines/feedback) guidance. Numeric targets, visual subject mappings and shell/state treatment are adopted project design requirements, not HIG requirements. Exact production gesture/art assets still require fidelity review. The implementation must use selected native tooling and actual device review; no web animation library or animation framework is selected here.

## Historical starter subset

The [complete v1 award/reward catalog](achievement-catalog.md) now owns the review inventory: 68 award families, including these seven carried-forward starter proposals and 61 proposed additions, plus operational/economic entries. The table below preserves the original subset for traceability; it is not the complete list or a final visual brief. Catalog/rule review must precede badge visuals.

The full catalog names/types/initial tiers and visual direction are owner-adopted; qualified learning-rule validation and production-art fidelity checks remain before activation. Each badge definition must have a stable rule/version and scope. These examples do not silently create currency bonuses.

| Example badge | Category | Proposed award condition / honest claim |
| --- | --- | --- |
| First Practice | Participation | First eligible completed activity with required correction/self-review; quiet practice is equally eligible. Does not mean speaking ability. |
| Introduction Completed | Completion | INTRO-01 core completion through spoken or quiet route; detail displays modality and does not say "fluent". |
| Back to Practice | Consistency | Three eligible sessions on distinct local dates; day/travel/repeat definitions must be resolved in SC-T025 before activation. Shows participation, not skill. |
| Words Recalled Later | Evidence-based learning | The specified selected senses meet the reviewed day-7/day-28 productive-recall rule with support/timing recorded; not recognition, attendance or all-vocabulary mastery. |
| Introduction in a New Situation | Evidence-based learning | INTRO-01 reviewed unfamiliar-task success plus required delayed recall; supporting checks and unavailable evidence are visible. No automatic overall CEFR advancement. |
| Grammar in Use | Evidence-based learning | Named EF child objective meets its reviewed productive, communicative and delayed/transfer criteria; a terminology quiz cannot earn it. |
| A1 Course Completed | Reviewed course completion | Required published A1 coverage and completion checklist actually closed; a single topic, XP level or coach session cannot earn it. This is not official certification. |

Badge states: not yet earned; earned; assessment not yet available; insufficient evidence; supporting evidence unavailable after deletion. Use plain-language text and distinct icons/labels rather than color alone. Do not show every learner an intimidating wall of advanced locked badges; highlight relevant available goals. A missing assessment or deleted recording is not proof of forgotten skill. Final policy for retaining historical awards versus invalidating current learning claims, and any currency reversal on data deletion, remains an explicit SC-T025/retention decision. Until resolved, do not preserve a current verified-skill claim without its required evidence, resurrect private data, deduct gold automatically or create debt.

## Reward accounting and presentation

Preserve the [approved UI/UX prototype economy](ui-ux-design.md#rewards-and-prototype-economy): XP progression, spendable gold, configured free hints, optional assistance purchases and Freeze/Repair. No new prices, multipliers or CEFR-linked currency are approved here. First completion/full, one meaningful repeat/half and nested activity deduplication still need exact event/day rules before coding; the design must show the actual awarded amount, repeat reason and bonus eligibility. Do not display illustrative amounts as if credited.

Proposed logical delivery: eligible persisted activity → evaluate versioned rule → idempotent reward/badge ledger commit → update balances/progress → enqueue optional presentation → display at safe boundary → acknowledge/dismiss. Viewing/replaying/skipping/dismissing a celebration is not an earning event. Reopening, offline/reconnect, switching trainer and repeated callback/taps must not re-award. A lesson summary identifies rewards already included; a daily bonus is a separate eligible event. A newly earned badge adds no XP/gold unless an explicitly approved economy rule says so.

Separate durable award identity from delivery/acknowledgement state. Batch pending presentations and persist display acknowledgement so restarts do not replay celebration sequences; a crash may leave an award quietly visible in history rather than risk repeated interruption. A failed local commit cannot show earned success; preserve eligible activity/recoverable status and retry local reconciliation without duplicate awards or automatic cloud calls. No cloud connection or AI success is required for eligible local participation credit. Keep exact transactions, ledger schema, day/clock policy, event deduplication, delivery queues and deletion/reversal behavior as design prerequisites, not assumed implementation.

## Production review and delivery

SC-T007/SC-003 reviews native result, badge-detail and motion/quiet/large-text specimens, preserving Page 1 as visual reference without claiming Figma edits. SC-T025 decomposes eligibility/ledger, reward surfaces/badge catalog and celebratory motion/accessibility into bounded reviewable children against the adopted catalog/system and unresolved operational contracts; SC-T024 supplies Progress/evidence links. Keep adopted design requirements distinct from unexecuted production/native checks. Use RW-QA01–RW-QA08 in [acceptance](../history/v1/testing/course-practice-and-rewards-acceptance.md). No change to ticket counts, release scope, economy values or application implementation is authorized by this design proposal alone.

## Owner adoption and proposed art direction

On 2026-10-19 the owner adopted the entire [68-family catalog](achievement-catalog.md), not just the original seven-item subset. Names/classifications/listed initial tiers no longer require a repeated selection step; qualified assessment and unresolved event/date/retention contracts remain activation work. [Visual proposal 01](achievement-visual-design.md) now supplies illustrated circle/shield/hexagon shells, category/role subjects, tier/state handling and a representative board. Art, exact motion and native/device quality remain unapproved/unverified; no economy values change.

## System adoption precedence

The owner’s adoption supersedes earlier proposal/pending-visual-direction wording in historical sections. All current and future catalog family instances use [the adopted system](achievement-visual-design.md), including noncollectible checkpoint rows and separate XP/gold metrics. No repeated approval of this direction is needed; implementation/asset quality and device acceptance still require their own evidence.
