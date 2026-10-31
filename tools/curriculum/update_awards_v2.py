"""v2 badge update (2026-10-30). Idempotent: run it again and the file does not change.

- Hides badges whose feature is gone or that need assessed evidence nothing in the app collects ("hidden").
- Keeps badges only reachable through the hidden introduction lesson for learners who already hold them ("legacy").
- Renames AW-P-05 and rewires Talk and course badges to what the app does now (AwardEvaluator.swift).
- Adds new badges for coaches, Lexicon, Lab videos and timed tests. They use an SF Symbol until artwork exists.

Run from the project root: python3 tools/curriculum/update_awards_v2.py
"""
import json
from pathlib import Path

PATH = Path("application/SpeechCoachAI/Resources/Rewards/AwardCatalog.json")
RULE = "aw-personal-2"
BINDING = "SC-owner-2026-10-30"
LIVE = "personalUseParticipation"

LEGACY = {"AW-P-02", "AW-TR-01C", "AW-TR-02C", "AW-TR-04C"}
REWIRED = {
    "AW-P-05": dict(title="First Spoken Answer",
                    criteria="Record your first spoken answer in a lesson's speaking step."),
    "AW-P-06": dict(criteria="Finish a first Talk conversation (free talk or scenario) with at least two replies."),
    "AW-P-07": dict(criteria="Finish a first Talk interview with at least two replies."),
    "AW-CV-01": dict(criteria="Finish 5, 10, 25 and 50 Talk conversations (free talk or scenario).", tiers=[5, 10, 25, 50]),
    "AW-IV-01": dict(criteria="Finish 5, 10 and 25 Talk interviews.", tiers=[5, 10, 25]),
    "AW-CR-10": dict(criteria="Finish every course lesson from A1 to C2."),
}
for i, rank in enumerate(["A1", "A2", "B1", "B2", "C1", "C2"]):
    REWIRED[f"AW-CR-{i + 4:02d}"] = dict(criteria=f"Finish every {rank} course lesson.")

# id, title, classification, criteria, symbol, tiers, reused art (family id) or None
NEW = [
    ("AW-TK-01", "First Coach Lesson", "Completion badge", "Finish a first lesson with any coach.", "person.fill.checkmark", None, None),
    ("AW-TK-03", "Grammarian Completed", "Completion badge", "Finish every Grammarian lesson.", None, None, "AW-TR-02C"),
    ("AW-TK-04", "Pronunciation Completed", "Completion badge", "Finish every Pronunciation coach lesson.", "mouth", None, None),
    ("AW-TK-05", "Coaches Completed", "Tiered completion badge", "Finish every lesson of 1, 3, 6 and 11 coaches.", "person.3.fill", [1, 3, 6, 11], None),
    ("AW-TK-06", "All-round Learner", "Completion badge", "Finish at least one lesson with every coach.", "circle.hexagongrid.fill", None, None),
    ("AW-LX-01", "Words Reviewed", "Tiered participation badge", "Rate 50, 250, 1,000 and 5,000 Lexicon reviews.", "rectangle.stack.fill", [50, 250, 1000, 5000], None),
    ("AW-LX-02", "Lexicon Days", "Tiered consistency badge", "Review Lexicon words on 7, 30 and 100 different days.", "calendar", [7, 30, 100], None),
    ("AW-LX-05", "Your Own Topic", "Participation badge", "Make your first own word topic in Lexicon.", "text.badge.plus", None, None),
    ("AW-LX-06", "Words in Action", "Tiered participation badge", "Use 10, 50 and 100 words correctly in Lexicon in Action.", "text.bubble.fill", [10, 50, 100], None),
    ("AW-VD-01", "First Video", "Participation badge", "Watch a first Lab video.", "play.rectangle.fill", None, None),
    ("AW-VD-02", "Videos Watched", "Tiered participation badge", "Watch 10, 25, 50 and 100 Lab videos.", "play.square.stack.fill", [10, 25, 50, 100], None),
    ("AW-VD-03", "Video Topics Completed", "Tiered completion badge", "Watch every video in 1, 5 and 14 Lab topics.", "checkmark.rectangle.stack.fill", [1, 5, 14], None),
    ("AW-TT-01", "First Timed Test", "Participation badge", "Finish a first Lab timed test.", "timer", None, None),
    ("AW-TT-02", "Timed Tests", "Tiered participation badge", "Finish 5, 25 and 100 Lab timed tests.", "stopwatch.fill", [5, 25, 100], None),
    ("AW-TT-03", "All Three Tests", "Completion badge", "Finish one writing, one reading and one analogies timed test.", "checklist", None, None),
    # 2026-10-31
    ("AW-LX-07", "Enricher Rounds", "Tiered participation badge", "Finish 1, 10 and 50 Vocabulary Enricher rounds.", "sparkles", [1, 10, 50], None),
    ("AW-LX-08", "Perfect Round", "Tiered participation badge", "Get every question right in 1, 10 and 25 Practice or Vocabulary Enricher rounds.", "star.circle.fill", [1, 10, 25], None),
    ("AW-CR-11", "Fast Track", "Completion badge", "Pass a rank test with a perfect score and skip a level.", "hare.fill", None, None),
]
# New badges go after this family so the "next to earn" tiles show current features first.
INSERT_AFTER = "AW-C-05"


def main() -> None:
    text = PATH.read_text(encoding="utf-8")
    rows = json.loads(text)
    by_id = {row["id"]: row for row in rows}

    for row in rows:
        # 2026-10-31: no "Title — {placeholder}" badge names; the checkpoint reads as a plain count.
        row["title"] = "Lessons Completed" if row["id"] == "AW-CR-01" else row["title"].split(" — ")[0]
        fid = row["id"]
        if fid in REWIRED:
            row.update(REWIRED[fid])
            row.update(availability=LIVE, unavailableReason="", ruleVersion=RULE, bindingVersion=BINDING)
            row.pop("visibility", None)
        elif fid in LEGACY:
            row["visibility"] = "legacy"
        elif row["availability"] == "unavailable":
            row["visibility"] = "hidden"

    template = by_id["AW-P-06"]
    new_rows = []
    for fid, title, classification, criteria, symbol, tiers, art in NEW:
        source = by_id.get(art) if art else None
        row = {key: template[key] for key in template if key not in ("visibility", "tiers", "symbol")}
        row.update(id=fid, title=title, classification=classification, criteria=criteria,
                   shell="Completion shield" if "ompletion" in classification else "Participation circle",
                   filename=source["filename"] if source else "", sha256=source["sha256"] if source else "",
                   subject=source["subject"] if source else title, collectible=True, ruleVersion=RULE,
                   availability=LIVE, unavailableReason="", manifestOwner="AwardEvaluator", ruleTemplate="R-V2-STORED-STATE",
                   bindingVersion=BINDING, finiteSet="Worked out from stored learner data.", contentTargetIDs=[])
        if symbol:
            row["symbol"] = symbol
        if tiers:
            row["tiers"] = tiers
        new_rows.append(row)

    rows = [row for row in rows if row["id"] not in {n[0] for n in NEW}]
    at = next(i for i, row in enumerate(rows) if row["id"] == INSERT_AFTER) + 1
    rows[at:at] = new_rows

    out = json.dumps(rows, indent=2, ensure_ascii=False) + ("\n" if text.endswith("\n") else "")
    if out != text:
        PATH.write_text(out, encoding="utf-8")
    shown = [r for r in rows if r.get("visibility") is None]
    print(f"{len(rows)} families: {len(shown)} shown, "
          f"{sum(r.get('visibility') == 'legacy' for r in rows)} legacy, {sum(r.get('visibility') == 'hidden' for r in rows)} hidden")


if __name__ == "__main__":
    main()
