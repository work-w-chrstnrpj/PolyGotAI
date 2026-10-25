# SC-T013 local submission preparation — 2026-10-21

Status: **in_progress**, engineering preparation only. Recording/credential acceptance dependencies remain open. No live request, real key access, HTTP transport, transcript confirmation UI or provider compatibility proof is claimed.

`Infrastructure/Providers/ASRPreparation.swift` reads an original only after CaptureFile validates WAV container/actual signed-16 mono PCM/duration/size. AVAudioConverter creates a separate in-memory 16 kHz signed-16 mono copy. A bounded loop rejects converter errors/nonprogress or over-limit output. A minimal WAV header is encoded explicitly little endian. The candidate JSON uses `qwen3-asr-flash`, one user input_audio data URL, English and no ITN, no stream. It checks actual <=4 MiB WAV and <=6 MiB JSON; no arbitrary model/destination or credential enters this object. Nothing is persisted or sent.

Simulator tests PASS in `application/.build/asr-preparation-simulator.xcresult`: eight test functions (including three conversion cases) cover 1, 1.25 and 120 seconds, normalized copy storage metadata/duration, exact request data URL/body and unchanged original bytes. [Summary](simulator-summary.json). Existing recovery/session tests in that targeted suite also pass. The fixtures use synthetic PCM only, not owner recordings. A 120-second fixture validates preparation, not real microphone auto-stop or real provider acceptance. Measured memory/latency/real ASR remain open.

Official candidate reference rechecked 2026-10-21: [Qwen ASR](https://www.alibabacloud.com/help/en/model-studio/qwen-asr-api-reference), including inline Base64 audio and Singapore workspace endpoint. Actual account model access/terms/quota/retention and explicit submission remain gated under SC-T012 before any request. Original/confirmed transcript lifecycle and cancellation/unknown outcomes remain to implement; local preparation does not deliver online transcription.

## Physical iPhone follow-up

The same targeted CaptureRecoveryTests suite passed on owner iPhone 15 Plus, iOS 27.0.1 (`asr-preparation-device.xcresult`), including actual on-device conversion of synthetic 1/1.25/120-second originals. [Phone result](iphone-summary.json). No owner audio was read; no provider request was sent. This verifies local converter behavior on phone, not ASR/provider compatibility or complete SC-T013 acceptance.

## Durable request and transcript follow-up

`transcription-lifecycle-v1.xcresult`: complete hosted simulator suite PASS (36 functions at that checkpoint). `transcription-lifecycle-device.xcresult`: focused lifecycle suite PASS on physical iPhone. [Simulator lifecycle summary](lifecycle-simulator-summary.json), [phone lifecycle summary](lifecycle-iphone-summary.json).

Added candidate bounded ASRRecognition response decoding (<=256 KiB wire response, nonempty <=12,000-scalar transcript, expected model, one completed assistant choice; confidence remains nil). Repository blocks duplicate prepared/sent stage requests, records explicit transitions, atomically completes recognition/request metadata, and creates immutable local confirmation revisions including unchanged confirmations. Reopen cancels prepared unsent work and marks sent work unknown; no operation dispatches network work. Invalid/stale/cancelled result, duplicate completion, explicit retry IDs, storage-commit failure rollback and restart behavior have synthetic coverage. Model decoding is provisional until actual account output is verified; no transcript UI/live transport or provider compatibility claim.

Owner reports physical iPad unavailable; continue other authorized work, leaving required physical-iPad gates pending. Do not ask again absent a new need/change.
