# ADR-0004: FSRS-6 for spaced repetition

**Status:** accepted (retroactive)
**Date:** 2026-11-08
**Ticket:** #2
**Input:** docs/history-version.md, docs/tdd/tdd.md
**Supersedes:** none

## Context

Lexicon and vocabulary review need a scheduler that adapts to each learner without a server.

## Decision

Use the FSRS-6 algorithm through a pinned copy of swift-fsrs in `application/Vendor/swift-fsrs/`, wrapped by `Domain/ReviewSchedule.swift`. It is the only third-party dependency.

## Alternatives

- SM-2: simpler but less accurate.
- Own scheduler: cost without benefit.

## Consequences

Review cards store FSRS state in the learner document. Upgrading the library is a manual, tested change. The pinned copy must not be edited casually.
