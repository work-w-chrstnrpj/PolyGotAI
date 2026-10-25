# SpeechCoach Design Helper

**Latest owner scope, 2026-10-17:** consolidate Page 1 into a reusable reference and remove Page 2 after verification. Use the separate [Page 1 kit helper](consolidation/README.md) for that work. The operations below target the superseded Page 2 draft and should not be used to continue expanding it by default.

Project-local Figma development plugin. It uses Figma's in-editor Plugin API, with no cloud MCP call, local server, package installation, credentials or external networking. This is design tooling, not SpeechCoachAI application implementation.

## Import and run

1. Open the existing SpeechCoachAI design in **Figma Desktop**.
2. Choose **Plugins → Development → Import plugin from manifest**.
3. Select this folder's **manifest.json**.
4. Run **SpeechCoach Design Helper** from Plugins → Development.
5. Click **Inspect design** first. The plugin refuses to operate without the known expansion page and onboarding anchor.
6. Click **Repair prototype routes** to connect the documented destinations, fix text/vocabulary disclosure routes, connect the four independent retention choices, add a separate replacement-take recording specimen and preserve existing non-click interactions.
7. Click **Build iPad layouts** for three regular-width specimens (Learn, Speech Lab and Progress) and a portrait learning specimen. Existing Page 1 nodes are never edited. Re-running reuses named local frames.
8. Use **Show screen** / **Export PNG** with IDs such as `TD-01`, `SP-11`, `IPAD-Learn` and `IPAD-Portrait`. Save the JSON report after each operation.

**Refine visuals** repairs local text/key-row reflow, copies Page 1 coach art to selected moments and adds background motifs to theme previews. **Add design states** adds 13 keyboard, larger-text, validation/recovery, compact-width and focus specimens. After changing source and rebuilding, close and rerun the plugin to load the new bundle; an already-running plugin keeps its previous code.

Runtime evidence on October 17: repair, iPad, refinement and state operations ran. The saved audit lists 18 local additions and zero unlinked action buttons among the 149 base frames. Reviewed exports: `IPAD-Learn-reviewed.png`, `KEYBOARD-Missing-reflow.png`, `LARGE-Save.png`. Figma cloud sync remains unconfirmed; other frames and complete walkthroughs remain under review.

Operations edit Page 2 and support normal Figma Undo. A failed operation may leave partial work; inspect the error/report and canvas before retrying. The helper contains no permanent-delete operation. It does not provide a generic JavaScript execution endpoint.

## Build and verify

From the project root:

```sh
node tools/figma-local-helper/build.mjs
node tools/figma-local-helper/verify.mjs
```

`code.js` is the importable distributable. Edit `plugin.js` / `routing.cjs` and rebuild. `screens.json` captures the 149 authored draft definitions; the frame ledger is `docs/product-specification/figma-build-manifest.json`.

## Acceptance boundary

Local verification checks route integrity, the four retention transitions, disclosure separation, wrong-file rejection, no network/destructive operations, and JavaScript syntax. It does **not** prove Figma runtime success, visual quality, HIG compliance or physical-device behavior.

The helper repairs navigation specimens; it does not implement scoring, real typing, voice capture, provider requests, spending, deletion, exports or notifications for the product. iPad actions may lead to compact reference screens for journeys without a regular-width variant. Page 1 artwork integration, full background refinement, complete state coverage and owner walkthrough acceptance remain separate work.
