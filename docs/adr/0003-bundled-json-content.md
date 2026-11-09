# ADR-0003: Bundled JSON content with versioned lessons

**Status:** accepted (retroactive)
**Date:** 2026-11-08
**Ticket:** #2
**Input:** docs/history-version.md, docs/tdd/tdd.md
**Supersedes:** none

## Context

The course, ten coach tracks, the word bank and Lab drills are large, hand-authored and must work offline. Learners resume lessons across content updates.

## Decision

Ship content as JSON in `Resources/` (Curriculum, Tracks, Lexicon, SpeechLab), authored and validated by scripts in `tools/curriculum/`. Loaders validate at launch and hide invalid lessons. Each journey records the lesson `contentVersion`; old versions stay in `archivedLessons`.

## Alternatives

- Remote content service: needs a backend (see ADR-0001).
- Content in Swift code: hard to author at scale and to validate.

## Consequences

Content updates ship with the app. Saved work reopens exactly as it was. Archived lessons grow the bundle. Content changes need both the validation scripts and the content tests to pass.
