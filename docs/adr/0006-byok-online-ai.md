# ADR-0006: Online AI only with the learner's own key

**Status:** accepted (retroactive)
**Date:** 2026-11-08
**Ticket:** #2
**Input:** docs/history-version.md, docs/tdd/tdd.md
**Supersedes:** none

## Context

Some features (Talk conversation, Lab feedback, specialized Lexicon) need a language model. There is no backend to hold shared keys or pay for usage.

## Decision

Online AI is bring-your-own-key. The learner's provider key lives in Keychain (`ProviderCredentialStore`). Clients in `Infrastructure/Providers/` call the provider directly, only when the learner starts a session, after a cost and privacy disclosure. Responses pass `ValidatedCoachingContent` before use. The first provider is Alibaba Qwen (free-tier models).

## Alternatives

- Shared key through our backend: needs a server (ADR-0001) and carries abuse and cost risk.
- No online AI: loses the specialist coaching features.

## Consequences

No server cost, and the learner controls their data. Features need a key to work, so they must hide or degrade without one. Provider clients must treat responses as untrusted. Adding a second provider means a new client behind the same gates.
