# ADR-0009: iPad uses the bottom tab bar in both orientations

**Status:** superseded by ADR-0010
**Date:** 2026-11-08
**Ticket:** owner bug report in chat (no ticket); log LOG-0104
**Input:** none
**Supersedes:** none

## Context

Phase 0 (item 0.7) used a custom sidebar on iPad in landscape and a custom bottom bar in portrait. On the owner's iPad A16 the landscape sections could not be tapped, and the owner asked for one selector in both orientations.

## Decision

On iPad, `AppShell` shows the same custom bottom tab bar in portrait and landscape. The sidebar was removed. iPhone keeps the system tab bar. Selection and open screens survive rotation because one `TabView` stays in place.

## Alternatives

- Fix the sidebar hit-testing: the cause was never reproduced and a second layout still doubles the surface to test.
- System `sidebarAdaptable` tab style: changes the approved visual design.

## Consequences

One navigation layout to maintain on iPad. Landscape loses a permanent labelled list, but each tab is one tap away. `ui-ux-design.md` and `progress.md` item 0.7 were updated. The `navigation.<id>` accessibility identifiers are unchanged.
