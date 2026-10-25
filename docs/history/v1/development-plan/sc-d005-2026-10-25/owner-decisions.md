# SC-D005 owner adoption — 2026-10-25

Authority: the owner requested SC-D005 implementation through at least `awaiting_testing`, then answered the two pending policy questions with **“Adopt these recommendations (recommended)”** and **“Use this binding policy (recommended)”**. This is the canonical adoption record. The original Grok preparation files remain unchanged historical proposals.

Policy ID: `SC-D005-owner-2026-10-25`; economy version: `rewards-personal-1`; award binding version: `aw-personal-1`.

| Choice | Adopted behavior |
| --- | --- |
| Activity/repeat identity | Exact lesson activity ID plus content version; persisted source journey/event identity prevents replay payment. Fresh scheduled sense-review opportunities remain separately eligible. First full credit, one meaningful same-local-date repeat half, subsequent repeats zero XP/gold. Integer fractions round down. Ordinary Retry/replay does not create a fresh activity event. |
| Base economy | Exercise or explicit rated review +10 XP/+2 gold; recorded speaking plus self-review +30/+6. Nested speaking replaces the exercise entitlement; any remaining difference is an auditable adjustment. No stacked +40/+8. |
| Quiet practice | Eligible text attempts with correction/self-review count toward plan and actual practice dates; they do not claim speech assessment. Non-speaking exercise amounts apply. |
| Plans | Learner explicitly chooses one installed ready lesson/version for the date. Its finite required task IDs, including final self-review, must be completed after starting. One +25 XP/+10 gold bonus per date; the time target is independent. No completion or badge pays again. |
| XP | Show participation total only. No adopted level curve, level names, cap or CEFR equivalence. |
| Hints/assists | Three free hints per device-local date, then 2 gold; extra worked example 4 gold. Explicit cost/balance confirmation even for zero-cost hints. Purchased help for the same exact activity/kind reopens free. Normal explanations, correction, replay, retry and accessibility remain free with zero gold. Answer elimination stays unavailable until a price is chosen. |
| Date/clock | Store the event date; repeated callbacks retain source identity across restart/travel. A backward local date does not refill hints or issue new currency. Learning persistence remains usable. Protected UTC/uptime is the existing repository clock; there is no trusted server clock. |
| Streak | Eligible exercise, rated review or completed speaking self-review counts one actual date, including quiet practice. Protected dates are labeled continuity only. No attendance or skill evidence is backfilled. |
| Freeze | 20 gold per item; explicit purchase. Auto-use initially off. When enabled, consume one owned item per missing date, oldest first; purchasing never enables it. |
| Repair | Explicit 30 gold per missing date, one through seven dates. Another repair needs a new eligible practice date after the previous purchase. Works before or after today's resumed practice. Protection never pays XP or creates evidence. |
| Initial settings | Celebrations full; quiet, music, effects, haptics, Freeze auto-use, reminders and break timer off. Goals unset until the learner chooses them. |
| Active time | Engaged learning surfaces only. Shared focus ownership prevents a sheet and its parent counting twice. Pause background and after 60 seconds without interaction; uninterrupted learning audio/capture bypasses inactivity while foreground. Persist time separately from activity/plan goals. |
| Reminders/timer | Learner selects weekdays/time and an actual goal, then explicitly saves; request system permission only then. One generic nonrepeating notification; no private lock-screen payload or repeated ignored nudges. Goal completion/disable/reset cancels the applicable request. Optional manually started timer pauses background, survives navigation and ends with static notice, no automatic save/finish/reward. |
| Evidence deletion | Participation totals/receipts remain under normal retention policy; a badge that depends on removed evidence displays supporting-evidence-unavailable. Delete-all clears the ledger, inventory, goals and awards and invalidates old callbacks. |
| Personal-use bindings | Applicable participation/completion binds exact installed lesson/content versions, sense IDs and persisted practice events. All 68 families remain visible with original criteria. Qualified learning, CEFR completion, future content and unsupported modes remain unavailable until their own reviewed manifest and actual evidence exist. This approval is not educator review. |

The personal-use optional help set is finite: INTRO-01 v4 `grammar-be-am` and `grammar-be-is` have original additional scaffolds/worked examples. Other activities keep their free comparison/retry paths; no fabricated priced aid is shown. The next reviewed help-content expansion must bind its own exact IDs/version.

There are no real-money purchases, live provider requests, new credentials, schema migration, automatic content publication or learner-data reset in this implementation pass.
