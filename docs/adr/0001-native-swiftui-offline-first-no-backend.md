# ADR-0001: Native SwiftUI app, offline first, no backend

**Status:** accepted (retroactive)
**Date:** 2026-11-08
**Ticket:** #2
**Input:** docs/history-version.md, docs/tdd/tdd.md
**Supersedes:** none

## Context

The app is built first for the owner on iPhone and iPad and may be shared later. Lessons must work with no network, and there is no budget or need to run servers.

## Decision

Build a native Swift and SwiftUI universal app for iOS and iPadOS 17+ with no backend. All learning works offline; optional AI calls go from the device to the provider.

## Alternatives

- Cross-platform framework: heavier, weaker access to on-device speech and Keychain.
- Own backend: adds hosting, accounts and privacy duties for no current benefit.

## Consequences

No server cost and no account system. Everything that needs the network must be optional and degrade quietly. Android and web are out of scope. Sharing the app later means TestFlight or App Store work, not backend work.
