# ADR-0010: iPad uses the system tab bar

**Status:** superseded by ADR-0011
**Date:** 2026-11-08
**Ticket:** owner request in chat (no ticket); log LOG-0110
**Input:** none
**Supersedes:** ADR-0009

## Context

ADR-0009 kept a custom bottom bar on iPad. The owner found the iPad UI poor next to the iPhone, which uses the system tab bar, and asked for the same system tab bar on iPad.

## Decision

`AppShell` uses one system `TabView` on iPhone and iPad. On iPadOS 18 and later it uses the plain tab bar style (`.tabBarOnly`), never the sidebar. iPadOS places that bar at the top of the window; there is no bottom tab bar on iPad.

## Alternatives

- Keep the custom bottom bar: not native, no system glass, more code to maintain.
- `sidebarAdaptable` style: brings the sidebar back, which the owner removed.

## Consequences

Native look, behaviour and accessibility on both devices; the custom bar and its code are gone. The `navigation.<id>` accessibility identifiers sit on the tab content, so UI tests that tap by tab title (`app.tabBars.buttons`) are the reliable path. On iPadOS 17 the system shows the bar at the bottom.
