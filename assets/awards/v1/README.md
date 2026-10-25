# Award raster masters v1

Delivered 2026-10-20: **68 individually generated transparent PNG masters**, one per adopted AW family, including three unframed lesson/topic/unit milestone icons. All are 1254 × 1254 RGBA. Built-in ImageGen generated each asset separately using the adopted reference board.

- [Review gallery](gallery.html): labeled, paginated artwork with light/dark surface and small-size toggles.
- [Manifest](manifest.json): all 68 mappings, dimensions, hashes, alpha analysis and static review notes.
- [Verification](verification.json): 68 unique files; no structural PNG/transparency failures. Main silhouettes have 57–153 px minimum margins at alpha ≥128; faint edge pixels can extend beyond them.
- `masters/`: final earned/base illustrations; `prompts/` and [generation plan](generation-plan.json): exact original prompts/reference paths; `records/`: generated-source provenance and inspection notes.
- The lesson checkpoint was regenerated as a loose page; the rejected original and revised prompt are preserved.

Run `python3 assets/awards/v1/build-index.py` from the project root to refresh the manifest/gallery. It analyzes PNGs and packages metadata/HTML without changing artwork pixels.

Static inspection covered every family subject and shell. This is raster artwork delivery: simplified 32 pt variants, editable vectors, native text/state/tier overlays, animations, earning behavior and device/accessibility acceptance remain separate work. Gallery browser execution was not verified because local browser use was disabled in Work settings.
