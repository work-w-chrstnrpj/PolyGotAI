# ADR-0011: iPad uses a floating glass bar that matches the iPhone's tab bar

**Status:** accepted
**Date:** 2026-11-08
**Ticket:** owner request in chat (no ticket); log LOG-0111
**Input:** none
**Supersedes:** ADR-0010

## Context

ADR-0010 moved the iPad to the system tab bar, but iPadOS draws that bar at the top of the window as a small pill, which does not look like the iPhone's bottom bar. The owner wants the iPhone look at the bottom of the iPad, and does not want a two-column layout.

## Decision

On iPad, `AppShell` hides the system tab bar and shows `FloatingTabBar` at the bottom: a centered Liquid Glass capsule (at most 560 pt wide) with a filled symbol, label and tinted pill on the selected tab. It falls back to a material capsule before iOS 26. iPhone keeps the system tab bar. Screens are one column, at most 760 pt wide and centered, with an inline title on iPad. The two-column `AdaptiveStack` was removed.

## Alternatives

- System tab bar on iPad (ADR-0010): native, but at the top and not like the iPhone.
- Two-column cards (earlier LOG-0109): rejected by the owner.

## Consequences

The bar is custom code that must keep `navigation.<id>` identifiers, selection traits and VoiceOver labels (it does). One `TabView` stays underneath, so rotation keeps state. Visual parity with the system bar depends on `glassEffect` and may drift in later iOS versions.

**Note (2026-11-09, clarification, issue #3):** the floating bar is hidden while a practice screen is open (lesson player, jump test, Lexicon training, practice and action screens, Lab timed tests, Talk, Lab videos, recording), so it no longer covers the buttons at the bottom. The same `.practiceScreen(area:)` marker hides the iPhone tab bar. The bar is shown on every other screen as decided above.
