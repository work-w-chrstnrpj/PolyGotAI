# SC-T011 recording checkpoint — 2026-10-21

Status: **in_progress**. Signed app installed on the owner iPhone 15 Plus, iOS 27.0.1. Owner confirmed microphone playback is clear ("It’s clear") after the requested record → stop → replay check. This is intelligibility evidence, not a save/finish/interruption result. SC-T010's remaining iPad accessibility finding still gates completed acceptance. No provider call, Git initialization, release or reviewed curriculum publication.

## Implemented boundary

Native explicit microphone request, optional three-second countdown (default off), AVAudioRecorder mono signed-16 PCM WAV capture targeting 44.1 kHz, metering, manual pause/resume, 120-second recording budget, AVAudioPlayer replay, distinct retry IDs, explicit candidate acceptance, self-review finish and optional voice saving. Text/feedback is absent and therefore not saved. A system interruption, lost input route, background or protected-data event stops capture; it never silently resumes. Leave offers draft retention or explicit discard.

A durable optional pendingCaptureID is encoded in the existing v1 attempt snapshot before capture writes into the private staging namespace. Existing snapshots decode absent optional fields without a SwiftData migration. Reconciliation retains referenced drafts. Closed audio is inspected for its actual storage format/duration, then goes through the existing journaled finalization/checksum path. Short/unreadable drafts remain available for explicit discard/recovery until the 24-hour deadline. A valid take is never overwritten by starting another.

## Executed checks

- Simulator build: PASS (`/tmp/speechcoach-recording-build.log`).
- Signed iPhone build and install: PASS (`/tmp/speechcoach-recording-device-build.log`, `/tmp/speechcoach-recording-install.log`). This proves build/install, not microphone fidelity or the full workflow.
- Final simulator tests: PASS, `application/.build/capture-domain-v2.xcresult`; [exported summary](simulator-summary.json) reports 28 cases including parameterized cases. Swift Testing reports 24 functions across four suites, plus one XCTest UI method. No microphone capture was started by this automated UI check.
- New synthetic real-WAV tests: pending capture survives close/reopen and finalizes verified original; subsecond take rejected but retained until explicit discard; exact 24-hour expiry removes the retry draft while preserving saved original; floating-point PCM rejected rather than labeled signed-16. Existing persistence/settings checks passed in the same run.
- UI entry: Speech Lab → recording opens without a key; capture does not start before deliberate action; Close returns to Speech Lab. [Screenshot](offline-recording-ready.png) visually inspected against the approved dated Page 1 speaking-journey fallback, Record 2:38407 / Review 2:38472. Original prompt uses approved introduction facts rather than sample story copy.
- Earlier `capture-domain-v1.xcresult` failed an obsolete bootstrap no-microphone-description assertion and an expiry test whose clock included elapsed uptime. Updated required-capability assertion and deterministic expiry clock passed in v2; those failures were not counted as passes.

## Open acceptance

RF-01–03 on actual iPhone **and iPad**, intelligibility, actual route/format, permission denial/revocation, pause-time exclusion and 120-second auto-stop, phone call/headphones, background/lock, restart/recovery, disk-full and UI independent retention remain open. Owner listening result is PASS; physical iPad was not available. Native accessibility/Reduce Motion/large-text recording review is pending. A runtime AVAudioSession warning advises asynchronous activation; responsiveness targets have not been measured. Do not claim device acceptance or timing from the synthetic tests.

Session preference integration was corrected after this initial checkpoint: effective coach and frozen defaults, session ID and source lesson now persist with attempts without changing learner defaults. Optional JSON fields remain backward compatible; declined private context is removed. The recording UI provides no role-specific training. Full owner/device acceptance remains open. Provider conversion, key setup and assessment stay with later tickets.

## Owner iPhone playback result

2026-10-21: owner reported “It’s clear” after the requested 5–10-second capture/stop/replay check on iPhone 15 Plus, iOS 27.0.1. RF-01 intelligibility subcheck PASS by owner report; remaining RF-01–03 scope stays open. No owner audio/transcript was retrieved, copied or committed.

## Follow-up verified recovery/context checks

`recording-context-device.xcresult`: 27 hosted functions PASS on physical iPhone. `recording-context-ipad.xcresult`: the same hosted functions plus larger-text/hit-region/description walkthrough PASS on iPad simulator. Exported summaries: [phone](iphone-context-summary.json), [iPad simulator](ipad-context-summary.json). Added exact 120-second validation (removed 0.1-second tolerance), WAV signature/size checks before reading, expired-capture maintenance before finalization, old-snapshot decode coverage, immutable session/source/preference snapshot and declined-context removal. Keep-for-later now dismisses only after all draft updates succeed; inactive audio sessions are not needlessly deactivated.

Large-text walkthrough and contrast scan are separate tests so an existing contrast failure does not prevent collecting large-text evidence. This separation does not mark contrast as passing. Physical Keychain tests and UI later passed under SC-T012; no live provider calls.

## Physical background/self-review retest

`recording-background-device.xcresult` PASS on owner iPhone: deliberate Start, wait for at least two seconds captured, Home → activate, recoverable replay button present and recording-stop button absent, explicit Use this take → Finish self-review with voice toggle off, completion states recording not saved, Done returns. [Result summary](iphone-background-summary.json). No audio was exported or uploaded; tests did not inspect speech content. This closes those scoped physical background/no-key/self-review subchecks, not permission denial, physical iPad, lock/route/call, pause-time exclusion or full 120-second auto-stop acceptance.

Owner update: physical iPad unavailable on 2026-10-21; owner explicitly requested continuing other work. That note is historical.

## Physical iPad background and fixture — 2026-10-21

Wired iPad (A16), iPadOS 27.0.1 (24A446). `testRecordingStopsOnBackgroundAndFinishesWithoutSaving` passed in `application/.build/ipad-device-acceptance-v5.xcresult`: Start, at least two seconds captured, Home, return, replay available, recording does not resume, finish with voice off says the take was not saved. The microphone prompt was allowed during the test. `testIntegratedSpeakingLoopFixtureAndHistory` passed in `application/.build/ipad-device-acceptance-v6.xcresult` using the synthetic fixture store, including rotation, save, history, delete, and restore. No live provider call. This does not close permission denial, lock, route, call, pause-time exclusion, the 120-second cap, or iPad listening. RF-01 intelligibility on this iPad remains owner listening. Ticket stays **in_progress**.
