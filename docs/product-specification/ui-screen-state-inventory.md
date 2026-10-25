# UI Screen and State Inventory

> v2 (2026-10-25): visual state reference. Speech Lab families for conversation, interview and communication now belong to Learn → Coaches; new Speech Lab screens (Phonetics, Articulation, Dictation, Voice) reuse existing card, list, recorder and feedback patterns.

> Current readiness and remaining-choice authority: [consolidated readiness review](../history/v1/development-plan/readiness-review.md). Dated earlier pending statements are historical where superseded by recorded approvals; they are not additional start gates.
> Status: IN_PROGRESS — updated 2026-10-17. The 70 families track behavior and QA; prior dedicated Page 2 drafts are removed. Shared Page 1 pattern references are current in the JSON inventory. Full state/prototype coverage, visual refinement, open decisions and runtime acceptance remain incomplete. No application code or new implementation ticket.

## Historical expansion build evidence

**Owner scope correction, 2026-10-17:** this inventory tracks behavioral and QA coverage. It no longer implies a separate polished Figma frame for every family/state. The owner requests one reusable Page 1 reference with shared components, representative page templates, main parts and the speaking journey, followed by Page 2 removal. Existing expansion IDs below remain historical draft evidence; Page 2 removal and shared replacement references are now verified locally; see [UI reference guide](ui-reference-guide.md).

The [Figma build manifest](figma-build-manifest.json) records 70 populated family frames and 79 state variants created on October 17. Each JSON family includes a current frame reference and retains its original October 16 evidence. **DRAFT_BUILT** means an editable representative frame exists, not that every state or walkthrough has passed. The iPad family is a reference placeholder. Page 1 remains the preferred visual direction; Page 2 requires refinement. See [current review and limitations](figma-design-review.md).

The tables below retain the original gap audit and interview traceability. Use the manifest and JSON frame references for current artifact presence.

## Scope and evidence boundary

This is the next design deliverable authorized by the owner: a screen/state inventory, source traceability and ordered Figma gap plan. It does not claim that the missing frames were created in Figma. Full public release remains a complete A1–C2 five-skill path with interview/business coverage; iPhone first is the design order, not a reduced platform or curriculum scope. Other desired modes/resources are included but precise release depth remains open.

Sources: [owner decisions](ui-ux-design.md), [90-question audit](../history/v1/product-specification/ui-ux-interview-audit.md), [product specification](../history/v1/product-specification/product-specification.md), [communication/articulation](../history/v1/product-specification/communication-training.md), [Figma review](figma-design-review.md), [technical intent](../history/v1/tdd/tdd.md), [QA acceptance](../history/v1/testing/test-specification.md) and [recording contracts](../contracts/recorded-feedback-v1.md). Source files remain implementation truth when they exist.

Figma evidence below is the **last recorded observation on 2026-10-16**, not a fresh live canvas audit. Existing file: [SpeechCoachAI · iPhone UI Design](https://www.figma.com/design/B1A9qEN1B7I3NJKISX39Dx). Twenty screen frames, foundations and reusable components were observed. Art/style duplicates and a split Today composition do not equal twenty distinct complete journeys.

- **VISUAL:** relevant frame visually inspected; only stated content checked, not full acceptance.
- **SEEN:** named frame observed in layers, without complete interaction/state review.
- **PARTIAL:** a control/shared artifact exists but this family is not fully designed or verified.
- **GAP:** no matching design verified; not proof that an uninspected canvas could not contain it.

A family is a reusable route or surface, **not a demand for one standalone full-screen frame**. Sheets, overlays, activity variants and shared failures should reuse components. States listed are required design coverage from approved behavior or ordinary recovery needs, not new owner-approved thresholds, provider support or curriculum content. Proposed entry/exit composition is a design recommendation subject to walkthrough.

This inventory contains **70 families** across **12 areas**. The companion [JSON inventory](ui-screen-state-inventory.json) contains the same family IDs for tracking.

## ON: First launch and coaching

Interview trace: `R1-Q04`, `R1-Q06`, `R1-Q09`, `R3-Q01`, `R3-Q02`, `R3-Q03`, `R4-Q02`, `R4-Q03`, `R6-Q05`, `R6-Q06`, `R7-Q03`, `R7-Q04`, `R7-Q05`, `R8-Q01`, `R8-Q02`.

| ID / family | Entry, actions and exit | Required states and behavior | Last Figma evidence |
| --- | --- | --- | --- |
| **ON-01 · Welcome and learning goals** | First launch → nickname/goals → setup; skip optional setup and revisit in Settings. | New, partially entered, invalid nickname, resumed setup, skipped. | GAP |
| **ON-02 · Level and daily-target setup** | Welcome → freely select available CEFR level and time/activity targets → Today. | A1–C2 choices; explanatory help; unavailable marked Coming later; edit later; no placement lock. | GAP |
| **ON-03 · Coach selection and preview** | Onboarding or Profile → role preview → select/switch coach → return. | All seven trainer roles unlocked; selected/unselected; published versus planned packs; method/activity preview; Creative Writer artwork pending; optional voice preview loading/failure/unavailable; never autoplay. | SEEN: Coaches · Everyone is welcome |
| **ON-04 · Introduction invitation** | Setup → Start recording / Preview example / Skip to dashboard. | First visit, example playing/paused/unavailable, skipped and re-entered. | GAP |

## TD: Today and session control

Interview trace: `R1-Q05`, `R1-Q07`, `R1-Q08`, `R2-Q01`, `R2-Q02`, `R2-Q03`, `R2-Q04`, `R2-Q10`, `R2-Q11`, `R3-Q04`, `R3-Q05`, `R3-Q06`, `R6-Q02`, `R5-Q12`, `R8-Q09`, `F04`.

| ID / family | Entry, actions and exit | Required states and behavior | Last Figma evidence |
| --- | --- | --- | --- |
| **TD-01 · Daily dashboard** | Today tab → automatic connected plan; Start/Resume/Choose another; reviews and Word of Day. | New learner, active plan, partial, complete, no due reviews, no history, offline; separate time/activity indicators; XP/gold/streak. | VISUAL: Today · Creative Academy; SEEN: Today · Goals and discoveries |
| **TD-02 · Plan focus and replacement sheet** | Choose another → focus/task replacement → return with current progress preserved. | Suggested plan, alternatives, offline-compatible replacement, no suitable content, cancel. | GAP |
| **TD-03 · Quiet-session choice** | Session start or session switch → silent alternatives → same goals/streak credit. | Off/on; only current session; no automatic microphone/audio; reference playback is deliberate. | PARTIAL: Today quiet switch; copy needs correction |
| **TD-04 · Break timer and resume controller** | Optional timer → pause/continue/leave; relaunch → Resume or another activity. | Running, paused, ending, elapsed, idle/background, resumed; never discard work on timeout; precise ending UX OPEN. | GAP |
| **TD-05 · Optional communication routine** | Today shortcut → choose practice checklist/workload → shared technique tasks and completion. | Opted out, selected items, partial/complete, offline fallback; participation not mastery; exact reset rules OPEN. | GAP |

## LR: Curriculum and lesson shell

Interview trace: `R1-Q03`, `R2-Q05`, `R2-Q06`, `R3-Q07`, `R3-Q08`, `R3-Q12`, `R4-Q01`, `R5-Q01`, `R5-Q02`, `R5-Q03`, `R5-Q04`, `R6-Q03`.

| ID / family | Entry, actions and exit | Required states and behavior | Last Figma evidence |
| --- | --- | --- | --- |
| **LR-01 · Level, units and lessons** | Learn → free level choice → illustrated unit header → structured lesson list. | Available, unstarted, partial, completed, content absent/outdated, Coming later; public launch still requires complete path. | SEEN: Learn · Open levels |
| **LR-02 · Skip-ahead confirmation** | Later lesson selected → explain suggested order → continue or cancel. | No prerequisite lock, cancel preserves location; avoid repeated confirmation policy until decided. | GAP |
| **LR-03 · Lesson objective and explanation** | Open lesson → objective/examples → Skip/Continue/Another example/back. | First/revisit, example audio unavailable, offline, long content, related vocabulary, original versus validated AI variant. | SEEN: Lesson · Explanation |
| **LR-04 · Lesson continuation and completion** | Core steps → application/self-review → completion → retry/next/Today. | Skipped core replacement, partial, offline completed, AI optional, resume position, distinct completion versus mastery; exact core criteria OPEN. | GAP |
| **LR-05 · Challenge and refresher sheet** | Suggested harder variant → accept/decline; repeated mistakes → support options. | Permission before difficulty change, gentler coaching, retain objective; reveal/refresher thresholds OPEN. | GAP |
| **LR-06 · Report incorrect activity** | Activity menu → identify issue → local confirmation/queued report status. | Reviewed/generated item, invalid answer alternative, cancel, storage failure; external report destination/privacy OPEN. | GAP |

## EX: Reusable activity types and assistance

Interview trace: `R2-Q08`, `R3-Q09`, `R5-Q05`, `R5-Q06`, `R6-Q08`, `F05`, `F06`.

| ID / family | Entry, actions and exit | Required states and behavior | Last Figma evidence |
| --- | --- | --- | --- |
| **EX-01 · Multiple-choice response** | Lesson/activity → choose → Check → feedback. | Unselected/selected, disabled Check, submitted, correct/incorrect, retry, alternate-valid-answer. | SEEN: Lesson · Choose an answer; Lesson · Gentle retry |
| **EX-02 · Sentence building** | Prompt → arrange tokens → Check → retry/continue. | Empty, partial, reordered, reset, submitted; accessible move controls instead of drag-only. | GAP |
| **EX-03 · Typed missing-word response** | Prompt → keyboard entry → Check. | Empty/partial, keyboard visible, long text, correct/incorrect, accepted valid alternatives. | GAP |
| **EX-04 · Sentence correction** | Faulty sentence → edit/select correction → Check. | Selection, edit, undo local edit, submission, explanation; input method is a draft design choice. | GAP |
| **EX-05 · Listening comprehension** | Explicit play → listen/replay → answer → review. | Loading, playing/paused, speed, replay, reference unavailable, quiet alternative; answer/transcript reveal policy OPEN. | GAP |
| **EX-06 · Reading comprehension** | Passage → objective-linked questions → feedback. | Short/long passage, scroll/restore, selection/reference, large text, optional saved vocabulary. | GAP |
| **EX-07 · Reading aloud** | Reference and prompt → optional listen → shared recording flow → supported review. | Audio unavailable, microphone denied, quiet replacement, supported/unsupported sound feedback. | GAP |
| **EX-08 · Open response** | Prompt → typed or permitted spoken response → Check/self-review → feedback. | Draft, keyboard, long/empty answer, offline-reviewed rules versus online coaching, save/resume. | GAP |
| **EX-09 · Hint, extra example and result panel** | Help → free allowance or explicit gold spend → clue; submitted mistake → free explanation and retry. | 3 free hints/day, paid 2 gold, extra example 4, insufficient gold, cancelled spend, repeat taps; option-elimination price OPEN. | PARTIAL: lesson hint and gentle-retry examples only |

## VO: Vocabulary collections and recall

Interview trace: `R1-Q10`, `R4-Q04`, `R5-Q07`, `R5-Q08`, `R5-Q09`, `R6-Q12`, `R8-Q10`.

| ID / family | Entry, actions and exit | Required states and behavior | Last Figma evidence |
| --- | --- | --- | --- |
| **VO-01 · Vocabulary home and search** | Vocabulary tab → due reviews/collection/word/topic. | No words, no due cards, results/no results, offline, recognition/production categories. | SEEN: Vocabulary · Your words |
| **VO-02 · Recall prompt and reveal** | Start due review → think/optional type → Reveal → rate. | Meaning/production prompts, answer hidden, typed optional, reveal, hint exposure; optional speech. | GAP |
| **VO-03 · Recall rating and queue summary** | Revealed card → Again/Hard/Good/Easy → next/finish. | Rating semantics, undo policy OPEN, no due cards, interrupted queue, offline; avoid rating before reveal. | GAP |
| **VO-04 · Word detail, quick-save and editing** | Lesson/feedback/search → Save to collection; separately Add to review; edit sense/example/topic/note. | Already saved, duplicate sense, existing card, unsaved edits/cancel, audio speed/failure, missing fields. | GAP |
| **VO-05 · Topic setup and manual creation** | Custom topic → direct generation or subtopic narrowing; set level/count/purpose; manual path offline. | Manual fields, selected subtopic, generated request awaiting provider, no-key/offline alternative. | GAP |
| **VO-06 · Generated word preview and enrollment** | Generate → preview/edit/select words → collection and optional review enrollment. | Loading/cancel, rejected content, empty/duplicate results, partial selection, explicit retry, local success/failure. | GAP |
| **VO-07 · Collections and topic management** | Collection → words → rename/edit/delete → return. | Empty, personal versus recommended topic, remove from collection versus review unenrollment; deletion consequences OPEN. | GAP |

## SP: Speech Lab and attempt lifecycle

Interview trace: `R4-Q07`, `R4-Q08`, `R4-Q09`, `R4-Q10`, `R4-Q11`, `R4-Q12`, `R5-Q10`, `R7-Q01`, `F01`, `F02`, `F03`, `F07`, `F08`.

| ID / family | Entry, actions and exit | Required states and behavior | Last Figma evidence |
| --- | --- | --- | --- |
| **SP-01 · Mode hub** | Speech Lab tab → AI conversation (free/scenario), interview, everyday/pronunciation/business/spontaneous/communication/articulation setup; honest text/recorded/live availability. | No recent attempts, suggestions, offline, unsupported capabilities clearly explained. | SEEN: Speech Lab · Modes; full mode coverage needs review |
| **SP-02 · Everyday, spontaneous and presentation setup** | Mode → level/purpose/topic/prompt and optional scaffold → record. | Reviewed/fresh prompt, sample hidden, optional talking points/countdown, retry comparable prompt; duration cap OPEN. | PARTIAL: shared recording prompt, dedicated setup absent |
| **SP-03 · Interview and business setup** | Select role/audience/scenario/focus → objective-linked prompt → recording. | Software-engineering default from product, configurable role, optional technical coaching, factual sample stories, no employer achievements invented. | GAP |
| **SP-04 · Pronunciation and articulation setup** | Choose sound/reference or expression/word-retrieval focus → reviewed example → shared practice. | Target/reference, speed/repetitions/scaffold, reference missing, acoustic assessment unavailable, quiet fallback; no clinical claims. | GAP |
| **SP-05 · Communication techniques and scaffolds** | Learn or Speech Lab → technique/example → scaffold/no framework → solo practice. | Clarity, concise speech, listen/respond, persuasion, delivery, difficult conversations; stable objective/progress; exact release subset OPEN. | GAP |
| **SP-06 · Ready, countdown, recording and pause** | Explicit Start → optional countdown → capture → Pause/Resume/Stop. | Prompt/talking points, elapsed time/waveform, permission denied, input route, no signal, technical limit, interruption/restart, leave confirmation. | SEEN: Speech Lab · Recording; non-recording states GAP |
| **SP-07 · Take review and replacement** | Stop → Play/Re-record/Get AI Feedback/Finish self-review → retain prior take until replacement accepted. | Playing/paused, accept replacement/cancel, extra take save, interrupted partial replay, invalid audio. | SEEN: Speech Lab · Take review |
| **SP-08 · Transcription and transcript confirmation** | Explicit submission/disclosure → ASR status → audio-backed text confirmation/edit. | Uncertain/empty recognition, original versus edited, stale revision, cancel, failed ASR, no-key/offline. | SEEN: Speech Lab · Confirm transcript; request states GAP |
| **SP-09 · Coaching feedback and detail** | Confirmed transcript → request status → strength/two improvements/retry → expandable evidence. | No corrections, useful corrections, highlighted text/list, unsupported sound scores, invalid/stale result, follow-up vocabulary save. | SEEN: Speech Lab · AI feedback |
| **SP-10 · Local self-review and retry** | Finish self-review or feedback → reflection/checklist → meaningful retry/finish. | No AI/no key, optional learner confidence, no invented automatic confidence score, retry identity, equal eligible participation. | PARTIAL: self-review action shown; dedicated flow GAP |
| **SP-11 · Independent retention sheet** | Finish → Keep recording and/or Keep transcript/feedback → Save selected or Don’t save anything. | Four audio/text combinations, no text available, durable save/failure, temporary cleanup disclosure; default switches OPEN. | VISUAL: Speech Lab · Save sheet |
| **SP-12 · Saved attempt and comparison** | Progress/history → prior/current attempt → replay/text comparison/retry/export/delete. | Four prompt formats, comparable/new-task context, missing/deleted audio, no baseline, provider/rubric differences; no unsupported trend. | GAP |
| **SP-13 · Missing-word assistance** | Prompt preparation or expression practice → describe intended meaning → English suggestions → return to draft. | No suggestion, suitable alternatives, offline reference or unavailable AI, cancelled request; never overwrite learner answer; exact aid pricing OPEN. | GAP |

## PG: Progress and private evidence

Interview trace: `R2-Q09`, `R3-Q10`, `R3-Q11`, `R4-Q05`, `R4-Q06`, `R5-Q11`, `R6-Q09`, `R6-Q10`, `R6-Q11`, `R7-Q09`, `R7-Q10`, `R8-Q07`, `R8-Q08`.

| ID / family | Entry, actions and exit | Required states and behavior | Last Figma evidence |
| --- | --- | --- | --- |
| **PG-01 · Progress overview and weekly summary** | Progress tab → consistency/skill evidence/achievements → detail. | No evidence, sparse week, active week, chosen date range, XP distinct from proficiency; private. | SEEN: Progress · Your learning rhythm |
| **PG-02 · Activity history and skill detail** | Summary → five-skill detail or activity timeline → lesson/review/attempt. | Filtering, empty, missing audio, discarded text, source/version; aggregate effects of deletion OPEN. | GAP |
| **PG-03 · Milestone and badge detail** | Achievement → criteria and evidence → related practice. | Adopted v1 seals: participation circles, completion shields, learning hexagons and mapped subject/tiers; native criterion/date/claim labels and all five evidence/availability states; noncollectible milestones remain checkpoints; no leaderboard/share flow. | GAP |
| **PG-04 · Lesson and milestone celebrations** | Completion → reward summary → explicit Continue. | ADOPTED v1 presentation: mapped seal/subject/state, committed XP/gold itemization, half-repeat reason, grouped reveal, immediate Continue/skip, static Reduce Motion, quiet/sound/haptic settings and safe-boundary delivery; no double count or timed result dismissal. | GAP |
| **PG-05 · Gold wallet and purchase confirmation** | Reward balance → tool/help item → cost/remaining balance → explicit buy. | Enough/insufficient gold, cancelled/repeated tap, no-money purchase, reward history, no penalties for errors. | GAP |
| **PG-06 · Freeze inventory and auto-use** | Streak detail → buy Freeze (20 gold), inventory, auto-use preference and history. | Zero/many inventory, one per missed day, auto-use disabled, no cap; timezone edge handling OPEN. | GAP |
| **PG-07 · Repair and expired streak** | Missed-day gap → review cost (30 gold/day) → repair/decline. | 1–7 days eligible, >7 unavailable, inadequate gold, purchase failure/repeat taps; cooldown OPEN; no fabricated study days. | GAP |

## ST: Preferences, providers and reminders

Interview trace: `R2-Q07`, `R7-Q08`, `R8-Q03`, `R8-Q06`.

| ID / family | Entry, actions and exit | Required states and behavior | Last Figma evidence |
| --- | --- | --- | --- |
| **ST-01 · Profile and learning preferences** | Profile → nickname/goals/defaults/mode defaults/session overrides → return. | Edit/cancel/persist, precedence session→mode→global→app, capability unavailable; exact defaults OPEN. | SEEN: Profile · Settings |
| **ST-02 · Appearance and background preview** | Settings → preview/apply any of three backgrounds; independently Light/Dark/System. | Selected/unselected, cancel preview, dark, large text, reduced motion, all free, current coach preserved; default OPEN. | VISUAL: Appearance · Styles and theme; SEEN: three Today styles and dark |
| **ST-03 · Sound, voice and accessibility preferences** | Settings → separate music/effects/coach speech/haptic controls; explicit reference/coach audio. | Muted, quiet session override, preset voice unavailable, loading/failure, playback speed, system accessibility interaction. | GAP |
| **ST-04 · Reminders and notification access** | Settings/onboarding → chosen days/time/unfinished-goal condition → permission request when appropriate. | Allowed/denied/system settings, no reminders, schedule edit/cancel, generic preview, ignored reminder no repeat. | GAP |
| **ST-05 · Provider connection and credential lifecycle** | First AI request/Settings → masked key → explicit test → return; replace/remove key. | No key, testing possibly billable, success, invalid/revoked, unsupported model/region, remove-local versus provider revoke. | GAP |
| **ST-06 · Upload and cost disclosure** | Before first online feature → provider/data/cost explanation → submit or stay local. | First disclosure, changed provider/data scope, explicit subsequent request/retry, cancelled disclosure; no automatic upload. | GAP |

## PR: Privacy, storage and data control

Interview trace: `R8-Q04`, `R8-Q05`.

| ID / family | Entry, actions and exit | Required states and behavior | Last Figma evidence |
| --- | --- | --- | --- |
| **PR-01 · Storage and retained history** | Settings → storage usage/saved items → selected cleanup/export. | Temporary/saved audio, text-only, storage full, recoverable orphan; no unsolicited eviction of saved recordings. | GAP |
| **PR-02 · Export selection and share sheet** | History/Settings → select recordings/text → prepare → system share/export. | No selected data, mixed retention, unavailable files, failure/cancel; keys excluded; format/destination defaults OPEN. | GAP |
| **PR-03 · Delete and Recently Deleted** | Saved record → confirm soft-delete → Recently Deleted → restore/permanent purge. | 30-day expiry, no resurrection by late callbacks, restore failure, already purged, audio/text dependencies; permanent purge explicit. | GAP |
| **PR-04 · Delete all learning data** | Settings → scope/consequences → deliberate confirmation → completion or recoverable failure. | Retained keys versus learning data distinction, partial failure, Recently Deleted behavior OPEN; no silent account/provider deletion. | GAP |

## RS: Resources and content support

Interview trace: Existing product PR-10 and resource requirements; not introduced by the eight rounds..

| ID / family | Entry, actions and exit | Required states and behavior | Last Figma evidence |
| --- | --- | --- | --- |
| **RS-01 · Resource bookmarks and link cards** | Learn supporting resources → curated/personal YouTube card → external destination. | Empty, invalid/unavailable link, thumbnail absent, offline, return to lesson; no inferred video-content knowledge. | GAP |
| **RS-02 · Add/edit bookmark and learner notes** | Resource list → valid URL/title/topic/notes → save/edit/remove. | Invalid input, unsaved edits, duplicate link, cancellation, local failure; embedded playback remains deferred. | GAP |

## SY: Shared recovery surfaces

Interview trace: `R2-Q12`, `R3-Q12`, `R6-Q01`.

| ID / family | Entry, actions and exit | Required states and behavior | Last Figma evidence |
| --- | --- | --- | --- |
| **SY-01 · Online request lifecycle surface** | ASR/coaching/generation/TTS → truthful stage/Cancel → result or recoverable failure. | Offline, no key, auth/quota/rate-limit/timeout unknown outcome, provider failure, invalid result, unsupported capability; explicit retry, no fake %. | GAP |
| **SY-02 · Recording interruptions and input access** | Recording → permission/route/call/background issue → recover partial or restart/quiet. | Denied/revoked, call, headset disconnect, no input, crash recovery; never silently resume capture. | GAP |
| **SY-03 · Draft, storage and content recovery** | Any task → leave/relaunch/storage/version issue → restore compatible work or explain repair. | Unsaved edits, draft recovery/expiry, disk full, corrupt file, content changed, save failure; preserve available work. | GAP |
| **SY-04 · Consistent shell and feedback components** | All top-level tabs → own stack; task modal → dismiss/return. | Selected/pressed/disabled/focus/error, back/close distinction, keyboard-safe action bar, accessible labels, neutral empty state. | PARTIAL: reusable-components area exists; bindings/prototype not audited |

## AX: Visual and platform validation

Interview trace: `R1-Q01`, `R1-Q02`, `R1-Q10`, `R6-Q04`, `R6-Q07`, `R7-Q02`, `R7-Q06`, `R7-Q07`, `F09`, `F10`, `F11`.

| ID / family | Entry, actions and exit | Required states and behavior | Last Figma evidence |
| --- | --- | --- | --- |
| **AX-01 · Style/theme and artwork specimens** | Shared foundations → light/dark specimens for all three background styles → consistent controls. | Character/illustration shifts, no moving backdrop during concentration, contrast, SF Pro, no locked art; original assets still draft. | PARTIAL: foundations, coach art and Today styles; not all style/theme combinations checked |
| **AX-02 · Large-text and assistive interaction specimens** | Core journeys → larger Dynamic Type/VoiceOver/keyboard alternatives → same actions and content. | Reflow, scrolling, focus order, 44pt targets, labels, no color/sound-only signals, drag alternative, reduced-motion celebration. | GAP |
| **AX-03 · iPad adaptive layouts** | Same routes → regular-width sidebar/multi-pane references and focused recording/exercise → compact width. | Portrait/landscape, split width, hardware keyboard/focus, keyboard occlusion, no assumed Pencil dependency. | GAP |

## Source-coverage cross-check

All 90 interview questions are referenced by the area mappings above. Appearance/personality questions govern shared visual constraints, rather than requiring extra screens. A mapping demonstrates traceability, not that every compound subquestion was answered. Superseded locked coaches/spendable XP remain superseded.

| Follow-up | Families |
| --- | --- |
| F01 independent text saving | SP-11, PR-01–04 |
| F02 model versus product duration | SP-02, SP-06, SY-01; recording cap remains OPEN |
| F03 recording controls | SP-06–07 |
| F04 active-time counting | TD-01, TD-04, SY-03 |
| F05 prototype economy | EX-09, PG-04–07 |
| F06 repeat rewards | EX-09, PG-04–05; further-repeat XP remains OPEN |
| F07 waiting/failure | SP-08–10, SY-01 |
| F08 microphone access | SP-06, SY-02 |
| F09 iPhone-first | AX-03 follows iPhone walkthroughs |
| F10 all three backgrounds | ST-02, AX-01 |
| F11 native HIG skill | SY-04, AX-01–03 and every component choice |

| Product acceptance | Primary coverage |
| --- | --- |
| PR-01 free levels | ON-02, LR-01–02 |
| PR-02 offline | TD-03, EX-05–08, VO-01–07, SP-10, SY-01 |
| PR-03 introduction | ON-04, SP-06–11 |
| PR-04 configurable learning | TD-02–04, ST-01–05 |
| PR-05 vocabulary reviews | VO-02–04 |
| PR-06 custom topics | VO-05–06 |
| PR-07 speaking modes | SP-01–05 |
| PR-08 evidence/comparison | SP-12, PG-01–02 |
| PR-09 rewards | PG-03–07 |
| PR-10 resources | RS-01–02 |
| PR-11 assessment honesty | SP-04, SP-08–09, PG-02 |

## Shared state contract

Each family must show a populated/default composition and the applicable states below. Do not draw an unnecessary spinner/error on purely local static content. Define transition, visible message, primary recovery action, preserved data and exit for each applicable failure.

| Shared state | Visual/action requirement | Must preserve |
| --- | --- | --- |
| First use / empty / no result | Explain purpose and offer a useful next step; no fake activity/chart history | Free navigation and setup skip |
| Loading / processing | Truthful stage and Cancel where cancellable; no fabricated percent | Current attempt and navigation context |
| Offline / missing capability | Explain unavailable action; local alternative, key setup where relevant | Offline study/self-review and goal eligibility |
| Permission denied / revoked | Settings link and quiet alternative; no endless prompt loop | Draft/take where recoverable |
| Invalid input / uncertain recognition | Inline explanation; correction/confirmation rather than unsupported grading | Original recognition and edits |
| AI timeout / rate limit / quota / bad key | Specific useful recovery; explicit potentially billable retry; unknown billing outcome honest | Valid local audio/transcript/attempt |
| Leave / cancel / interrupted | Distinguish leaving, cancelling remote consumption and discarding; confirm destructive local effect | Accepted take until replacement accepted |
| Saved / failed save | Success only after durable storage; retry without overwriting other work | Recoverable local files/text |
| Deleted / recoverable / purged | Explicit scope, 30-day recovery for saved records, permanent purge choice | No late callback resurrection; no claim of provider deletion |
| Insufficient gold / repeat tap | Exact cost, cancel and free learning fallback; one transaction | XP level and nonnegative balance |
| Content update / unavailable | Explain compatibility/availability; no silent answer/rubric change mid-attempt | Frozen prompt and historical provenance |
| Keyboard / large text / rotated | Reflow and scroll to all actions, predictable focus and dismissal | Entered answer and selected options |

## Figma work order

These are design batches under SC-003, **not newly created implementation tickets**. Every batch includes its failure/empty/disabled states and applicable accessibility examples. All batches remain required before final design readiness for included release behavior; order is not permission to ship a subset.

| Batch | Deliverable and families | Review exit |
| --- | --- | --- |
| 0 · Repair first-pass foundations | EX-09, SY-04, AX-01; inspect font sizes/targets/contrast/instances; fix quiet copy; verify sync | Editable hierarchy, reusable states, no copy/retention contradictions, reliable save |
| 1 · First session and speech loop | ON-01–04, TD-01–04, SP-01–11, ST-05–06, SY-01–03 | First launch → optional setup → recording → transcript → feedback/self-review → independent save; permissions/offline/interruption shown |
| 2 · Connected curriculum | LR-01–06, EX-01–09; complete all activity types, skip/back/resume/challenge | Any released level → lesson → varied practice → application → completion, with valid alternatives |
| 3 · Vocabulary | VO-01–07 and shared request/help components | Save versus enroll, recall-before-reveal, ratings, custom topic preview and offline manual flow |
| 4 · Modes and learning evidence | SP-02–05 refinements, SP-12–13, TD-05, PG-01–03, RS-01–02 | Interview/business, communication/articulation and comparison respect evidence limits |
| 5 · Rewards and preferences | PG-04–07, ST-01–04, PR-01–04 | Exact gold costs, Freeze/Repair, reminders, audio controls, deletion/export walkthroughs |
| 6 · Platform and accessibility closure | AX-01–03; all previous families | Three background styles × Light/Dark; System follows appearance; large-text/reduced-motion/VoiceOver layouts; iPad regular/compact adaptations |

Within each batch use native HIG components and SF Pro; verify relevant current Apple documentation when coding. Native system dialogs, notification prompts, share sheets and Settings are annotated handoffs, not custom imitations. Reuse real instances/variants; artwork remains discrete assets, never flattened full-screen UI. Return Figma node IDs when editing tools are available. Inspect actual edited output before changing evidence status.

Owner clarification, 2026-10-17: Page 1 remains the preferred visual reference; Page 2 (`02 · Complete flows & states`) expands coverage and must inherit that visual quality. Coverage-first draft layouts do not supersede the preferred style or satisfy design readiness. Apply the [engineer handoff guidance](figma-design-review.md#engineer-handoff) and review both visual fidelity and state/journey completeness. The historical evidence labels in this inventory are unchanged by this clarification.

## Journey walkthrough checklist

All statuses below are **NOT_RUN**: these are planned design reviews, not executed QA. Record the Figma node/variant and owner feedback when actually walked through.

| ID | Scenario and expected continuity | Families |
| --- | --- | --- |
| W01 | New learner skips optional setup, previews intro, selects any level; no key needed | ON, LR, TD |
| W02 | Work-break quiet session completes daily plan without mic/automatic audio or lost streak credit | TD, EX, PG |
| W03 | Connected lesson includes each response type, back/repeat, paid/free help, skipped core replacement, harder-task consent | LR, EX |
| W04 | Speaking: record/pause/stop/replay, cancel re-record replacement, explicit ASR → confirm edits → coaching → retry | SP, SY |
| W05 | Interrupted call/route loss/denied mic; partial take retained and fresh recording required; leave asks first | SP-06–07, SY-02–03 |
| W06 | Save audio only / text only / both / neither; storage failure; reopen text-only attempt without fake Play | SP-11–12, PR |
| W07 | Missing key, bad key, quota, timeout, cancel and late result; resume offline; no silent retry/upload | ST-05–06, SY-01 |
| W08 | Word save separately from enrollment; duplicate sense; recall/reveal/rate; missed review or grammar error does not silently reset card | VO |
| W09 | Generated topic cancel/failure/preview/edit/select and offline manual topic creation | VO-05–07 |
| W10 | Interview/business, articulation and listening drills use shared objectives and honest assessment; unsupported sound scoring absent | SP-02–05, EX-05 |
| W11 | First/half-repeat reward, insufficient gold, Freeze consumption, 1/7/>7-day Repair, no double awards | PG-04–07, EX-09 |
| W12 | Empty/sparse progress, skill evidence, private achievements, comparable/unavailable recording pairs | PG-01–03, SP-12 |
| W13 | Three backgrounds independent from theme and coach; larger text, keyboard and reduced-motion equivalents preserve actions | ST-02–03, AX |
| W14 | Generic reminder denied/ignored/configured; day boundary/travel represented only after rules settled | ST-04, TD-04 |
| W15 | Export excludes keys; saved record restore/permanent purge; declined temporary audio bypasses recovery; no cloud-deletion promise | PR |
| W16 | iPad compact/regular/landscape, focus and VoiceOver, offline resources link-out and return | AX-03, RS |

## Open decisions that block detailed states

These already-open details need a design proposal or owner choice before finalizing the affected states. They do not justify inventing answers or reopening settled decisions.

| Decision | Affected families | Required resolution |
| --- | --- | --- |
| D01 recording and storage limits | SP-02, SP-06, PR-01, SY | Product cap, encoding/file size, warning/stop and cleanup; provider maxima are not product approval |
| D02 curriculum completeness | ON-02, LR, SP-03–05 | Authored volume, every level/skill coverage, included specialist/technique subset and core completion; no smaller public release substituted |
| D03 learning support | LR-05, EX-05, EX-09 | Reveal/repeated-mistake policy, listening transcript reveal, option-elimination price and assistance scope |
| D04 timer/day transitions | TD-04, ST-04, PG-06–07 | Idle/ending behavior, travel/clock changes, hint reset and reward day identity |
| D05 economy eligibility | EX-09, PG-04–07 | Meaningful repeat/event deduplication, XP beyond second completion, Repair cooldown, no false mastery |
| D06 retention/deletion | SP-11–12, PR | Switch defaults, draft expiry, restore/purge dependencies, export format, delete-all recovery/key scope |
| D07 provider/audio | ST-03, ST-05–06, SP-08–09 | Model/region/voice/terms, supported evidence, TTS availability/caching, latency/error details |
| D08 final visual assets | ON-03, ST-02, AX | Initial background, character names/voice/art details, illustration refinement; all coaches/backgrounds remain unlocked |
| D09 accessibility/devices | AX | Owner device/accessory needs, minimum OS, physical input/accessibility acceptance; design preference is not runtime proof |
| D10 optional adjacent content | LR-06, RS, SP-05 | Report delivery/privacy, resources/bookmark details and exact specialist subset; no new tab or live dialogue implied |

## Completion rules

A family may move from GAP to SEEN only with a matching observed Figma node; to VISUAL only after readable-scale inspection of the specified states. A complete family requires source links, state variants, entry/exit/recovery, retained-data behavior and component semantics. These observed labels alone never mean accepted. Final design readiness requires all applicable families/states covered, open blocking decisions resolved, walkthrough evidence, iPad/accessibility adaptation, and owner review. App/provider/device QA remains a separate gate.

## Deferred boundaries

Accounts/sync, monetization, custom-background uploads, public leaderboards/sharing, embedded video, video/body-language analysis, realtime AI turn-taking and precise unvalidated pronunciation scores are not added by this inventory. Their absence is intentional scope control, not an unnoticed screen gap.
