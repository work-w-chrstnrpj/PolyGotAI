# ADR-0005: On-device speech recognition and synthesis only

**Status:** accepted (retroactive)
**Date:** 2026-11-08
**Ticket:** #2
**Input:** docs/history-version.md, docs/tdd/tdd.md
**Supersedes:** none

## Context

Dictation, Lab and Talk need speech in and out. The owner wants free, private use and rejected paid or cloud voices for the base experience (rework decision, 2026-10-26).

## Decision

Use `AVSpeechSynthesizer` and `SFSpeechRecognizer` with `requiresOnDeviceRecognition = true`. Pronunciation measures are free and on-device. Recognition output may be shown as "We heard: …" and is never presented as a pronunciation score.

## Alternatives

- Cloud ASR and TTS by default: cost, privacy and offline loss.
- Pronunciation scoring from ASR text: misleading, so not offered.

## Consequences

Works offline and free. Quality depends on the device voices and recognizer. Anything beyond that is optional AI (ADR-0006).
