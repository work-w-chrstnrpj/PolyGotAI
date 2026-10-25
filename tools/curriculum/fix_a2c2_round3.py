#!/usr/bin/env python3
"""Round 3 fixes to the A2-C2 course lessons (content v3), from docs/reviews/opencode-proofread-lessons-2026-10-25.md.

The catalog is already v3, so convert_a2c2_v3.py cannot be re-run; this script patches it in place and is safe to run twice.
Run from the project root: python3 tools/curriculum/fix_a2c2_round3.py
"""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CATALOG = ROOT / "application/SpeechCoachAI/Resources/Curriculum/CurriculumCatalog.json"
ID_KEYS = {"id", "itemId", "senseId", "assetId", "lessonId", "objectiveId", "trackId", "unitId"}

# American words (non-A1 lessons only; ids are never rewritten).
WORDS = [(r"\bfilm\b", "movie"), (r"\bFilm\b", "Movie"), (r"\bholiday\b", "vacation"), (r"\bcancelled\b", "canceled"),
         (r"\bflat\b", "apartment"), (r"\bShop owners\b", "Store owners"), (r"\bbill\b", "check")]

# Flip these True/False items to true statements (the key was False in 43 of 44 items).
TRUE_STATEMENTS = {
    "a2-travel-tf": "Mina stayed with her aunt in Chicago.",
    "a2-appointments-tf": "Mina needs to reschedule her Friday appointment.",
    "a2-eating-tf": "The server said the kitchen would replace the soup.",
    "a2-leisure-tf": "Mina stayed home because she was too tired.",
    "a2-past-tf": "Mina has already visited the museum.",
    "a2-problems-tf": "Mina used the stairs because the elevator was broken.",
    "b1-education-tf": "Mina used to study law.",
    "b1-technology-tf": "Mina uses a shared calendar instead of a paper notebook.",
    "b1-culture-tf": "Mina's office expects people to arrive a little early.",
    "b1-achievements-tf": "Mina had stopped training for a year before she finished the 10k.",
    "b1-unexpected-tf": "The talk had started by the time Mina reached the hall.",
    "b2-leadership-tf": "Mina invites bad news early, even when it slows the meeting.",
    "b2-social-tf": "Mina wants both the new rail line and protections for the people who live beside the stations.",
    "b2-ethics-tf": "Mina will not keep a data field that has no named use.",
    "b2-present-tf": "Mina tells new speakers to state the ask before the history.",
    "b2-disagree-tf": "Mina says the disagreement is about evidence, not about respect.",
    "c1-research-tf": "Mina refuses to treat ten conversations as a market.",
    "c1-policy-tf": "Mina puts the exception next to the rule.",
    "c1-debate-tf": "The two groups share the aim but disagree about which measure to trust.",
    "c1-culture-tf": "Mina waits rather than treating a pause as a yes.",
    "c2-abstract-tf": "Mina separates privacy from secrecy.",
    "c2-culture-tf": "Mina translates a local saying into plain speech when the room does not know it.",
}

# Prompts that asked for a clause while only a connector is accepted: ask for the word, accept only the word.
WORD_PROMPTS = {
    "b1-education-recall-because": "Write the word that gives a reason.",
    "b1-relationships-recall-although": "Write the word that starts a contrast.",
    "b1-entertainment-recall-while": "Write the word that links two things true at the same time.",
    "b1-culture-recall-usually": "Write the word for a repeated custom.",
    "b1-culture-recall-whereas": "Write the word that sets two customs side by side.",
    "b1-community-recall-started": "Write the past verb for beginning a local project.",
    "b2-social-recall-while": "Write the word that links two effects that happen together.",
    "b2-disagree-recall-although": "Write the word that admits a point before your choice.",
    "c1-research-recall-although": "Write the word that admits a limit before the claim.",
    "c1-problems-recall-unless": "Write the word for the condition the partial fix ignores.",
    "c1-policy-recall-or": "Write the word that warns of the consequence.",
    "c1-debate-recall-whereas": "Write the word that contrasts two sources.",
}

# (activity id, field, old, new) edits to a single prompt.
PROMPTS = [
    ("b1-technology-read", "she had better write the time down", "she wrote the time down"),
    ("a2-invitations-g1", "Fill in the blank: ___ you like to come?", "Invite politely: ___ you like to come?"),
    ("b2-environment-listen", "What did more than the poster campaign?", "What cut more than the poster campaign?"),
    ("b2-media-read", "Mina treats a viral clip as if it were the whole event.", "Mina refuses to treat a viral clip as if it were the whole event."),
    ("c1-change-read", "the old and new side by side", "the old and new tools side by side"),
    ("c1-policy-g2", "Result: Write it down", "Warning: Write it down"),
    ("c1-culture-g1", "Contrast: A direct no", "Addition: A direct no"),
    ("c2-debate-recall-is-not", "Choose the best start for a sentence that separates facts from what follows.", "Choose the words that separate the two claims."),
]


def rewrite_strings(node, fn, key=None):
    if isinstance(node, dict):
        return {k: rewrite_strings(v, fn, k) for k, v in node.items()}
    if isinstance(node, list):
        return [rewrite_strings(v, fn, key) for v in node]
    if isinstance(node, str) and key not in ID_KEYS:
        return fn(node)
    return node


def americanize(text: str) -> str:
    for pattern, replacement in WORDS:
        text = re.sub(pattern, replacement, text)
    return text.replace("'", "’")


def main() -> None:
    catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
    lessons = [l for l in catalog["lessons"] if l["level"] != "A1"]
    touched = {"words": 0, "tf": 0, "recall": 0, "typed": 0, "prompts": 0}
    activities = {a["id"]: a for l in lessons for a in l["activities"]}

    before = json.dumps(lessons, ensure_ascii=False)
    for index, lesson in enumerate(catalog["lessons"]):
        if lesson["level"] != "A1":
            catalog["lessons"][index] = rewrite_strings(lesson, americanize)
    touched["words"] = int(json.dumps([l for l in catalog["lessons"] if l["level"] != "A1"], ensure_ascii=False) != before)
    lessons = [l for l in catalog["lessons"] if l["level"] != "A1"]
    activities = {a["id"]: a for l in lessons for a in l["activities"]}

    for activity_id, statement in TRUE_STATEMENTS.items():
        activity = activities[activity_id]
        activity["prompt"] = "True or false: " + statement.replace("'", "’")
        activity["answer"] = "True"
        activity["exercise"]["accepted"] = ["True"]
        touched["tf"] += 1

    for activity_id, prompt in WORD_PROMPTS.items():
        activity = activities[activity_id]
        connector = activity["exercise"]["accepted"][0]
        activity["prompt"] = prompt
        activity["answer"] = connector
        activity["exercise"]["accepted"] = [connector]
        touched["typed"] += 1

    for activity_id, old, new in PROMPTS:
        activity = activities[activity_id]
        new = new.replace("'", "’")
        if old in activity["prompt"]:
            activity["prompt"] = activity["prompt"].replace(old, new)
            touched["prompts"] += 1
        elif new not in activity["prompt"]:
            raise SystemExit(f"{activity_id}: prompt does not contain {old!r}")

    history = activities["c2-interpret-recall-history"]
    full = history["answer"]
    history["exercise"]["options"][0] = full
    history["exercise"]["accepted"] = [full]

    for activity in activities.values():
        exercise = activity.get("exercise") or {}
        if activity["kind"] == "recall" and exercise.get("type") == "choice":
            if activity["answer"] != exercise["accepted"][0]:
                activity["answer"] = exercise["accepted"][0]
                touched["recall"] += 1

    CATALOG.write_text(json.dumps(catalog, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print("patched:", touched)


if __name__ == "__main__":
    main()
