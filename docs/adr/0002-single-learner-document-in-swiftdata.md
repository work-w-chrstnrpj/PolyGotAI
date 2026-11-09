# ADR-0002: One learner document in SwiftData, no migrations

**Status:** accepted (retroactive)
**Date:** 2026-11-08
**Ticket:** #2
**Input:** docs/history-version.md, docs/tdd/tdd.md
**Supersedes:** none

## Context

Learner state (journeys, reviews, rewards, preferences) changes shape often. SwiftData migrations are costly and risky for a single owner's real progress data.

## Decision

Store the learner as one Codable JSON document in a single SwiftData `StateRow` (schema `LearnerSchemaV1`), with attempt and file-intent rows beside it. Add new data as optional fields with hand-written `CodingKeys`. No SwiftData migration without owner approval.

## Alternatives

- Many SwiftData models: each change needs a migration.
- Core Data or SQLite: no gain for one learner's data.

## Consequences

New fields are cheap and old documents still decode. A new field silently fails to persist if it is missing from `CodingKeys`, `init(from:)` or `encode(to:)`. Stored enum cases are never renamed or removed. Every write checks the data epoch and rolls back on failure. Querying across the document is manual. See docs/database/data-model.md.
