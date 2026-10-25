"""Shared helpers for building coach track files (Resources/Tracks/track-<coach>.json).

Every build_<coach>.py script imports this module, defines its units and lessons with the helpers below, and calls
`write_track(...)`. All lesson text is original wording written for this app.
"""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RES = ROOT / "application/SpeechCoachAI/Resources"
AWARDS = RES / "Rewards/AwardCatalog.json"
VERSION = "1"


# ---- Exercise helpers. Each returns {"prompt", "answer", "exercise", optional "kind"} ----

def C(prompt, correct, *wrong, kind="grammar"):
    """Multiple choice. The first option is the right one; the app shuffles the buttons."""
    return {"kind": kind, "prompt": prompt, "answer": correct,
            "exercise": {"type": "choice", "options": [correct, *wrong], "accepted": [correct]}}


def TF(prompt, answer, kind="grammar"):
    return C(prompt, answer, "False" if answer == "True" else "True", kind=kind)


def READ(passage, question, correct, *wrong):
    """A reading question. The passage is shown in its own card above the question."""
    assert question.endswith("?") and ". " not in question, question
    assert passage.endswith("."), f"passage must end with a period so the app can split it from the question: {passage!r}"
    return C(f"Read this. {passage} {question}", correct, *wrong, kind="reading")


def LISTEN(audio, question, correct, *wrong):
    """A listening question: the phone voice reads `audio`, then the learner chooses."""
    # kind stays "grammar": the course kind "listening" requires a recorded clip, while these use the on-device voice
    item = C(f"Listen. {question}", correct, *wrong, kind="grammar")
    item["exercise"]["audioText"] = audio
    return item


def W(prompt, answer, *extra, accepted=None):
    tiles = answer.split() + list(extra)
    return {"kind": "grammar", "prompt": prompt, "answer": answer,
            "exercise": {"type": "wordBank", "options": tiles, "accepted": accepted or [answer]}}


def F(prompt, *accepted):
    return {"kind": "grammar", "prompt": prompt, "answer": accepted[0],
            "exercise": {"type": "fillBlank", "accepted": list(accepted)}}


def O(prompt, items):
    return {"kind": "grammar", "prompt": prompt, "answer": " | ".join(items), "exercise": {"type": "order", "items": items}}


def M(prompt, pairs):
    return {"kind": "grammar", "prompt": prompt, "answer": " | ".join(f"{a} → {b}" for a, b in pairs),
            "exercise": {"type": "match", "pairs": pairs}}


def E(sentence, fixed, prompt="Find the mistake, then write the sentence correctly."):
    return {"kind": "grammar", "prompt": f"{prompt} “{sentence}”", "answer": fixed,
            "exercise": {"type": "spotError", "options": sentence.split(), "accepted": [fixed]}}


def L(text):
    return {"kind": "grammar", "prompt": "Listen, then write the sentence.", "answer": text,
            "exercise": {"type": "listenType", "audioText": text, "accepted": [text]}}


def YOUR(prompt):
    return {"kind": "grammar", "prompt": f"Your turn. {prompt}", "answer": "Any clear try is fine.", "exercise": {"type": "open"}}


# ---- Building ----

def build_manifest(coach_id: str, coach: str, stages: list, lessons: list, level_label: str, sources: list) -> dict:
    """`lessons` rows: (id, unit_id, title, objective_id, tip, items). Returns the track file contents."""
    built = []
    for lesson_id, unit, title, objective, tip, items in lessons:
        activities = []
        for index, item in enumerate(items, start=1):
            kind = item.get("kind", "grammar")
            body = {k: v for k, v in item.items() if k != "kind"}
            activities.append({"id": f"{lesson_id}-{index:02d}", "kind": kind, "required": True, **body})
        built.append({"id": lesson_id, "contentVersion": VERSION, "level": level_label, "title": title,
                      "objectiveId": objective, "trackId": coach_id, "unitId": unit, "tip": tip,
                      "sources": sources, "senses": [], "activities": activities})
    return {
        "schemaVersion": 1, "packId": f"speechcoach.track.{coach_id}", "contentVersion": VERSION, "locale": "en-US",
        "minimumSchemaVersion": 1,
        "editorialApprovalReference": "Authored 2026-10-25 for the owner's personal use. Qualified editorial review is pending. Completion records practice, not an English level.",
        "rightsReference": "Original SpeechCoachAI wording written 2026-10-25. Cited sources supply structure and ideas only; no text is copied.",
        "assets": [], "track": {"id": coach_id, "coach": coach, "stages": stages}, "lessons": built,
    }


def register_rewards(lesson_ids: list) -> int:
    """Make sure every award list that holds the A1 v4 lessons also holds these lessons (a lesson earns nothing otherwise)."""
    text = AWARDS.read_text(encoding="utf-8")
    wanted = [f"{lesson}@{VERSION}" for lesson in lesson_ids]
    touched = 0

    def patch(match: re.Match) -> str:
        nonlocal touched
        body = match.group(2)
        if '"a1-weather@4"' not in body:
            return match.group(0)
        missing = [w for w in wanted if f'"{w}"' not in body]
        if not missing:
            return match.group(0)
        found = re.findall(r'\n(\s*)"', body)
        indent = found[-1] if found else "      "
        trimmed = body.rstrip()
        tail = body[len(trimmed):]
        extra = "".join(f',\n{indent}"{m}"' for m in missing)
        touched += 1
        return match.group(1) + trimmed + extra + tail + match.group(3)

    updated = re.sub(r'("contentTargetIDs":\s*\[)(.*?)(\])', patch, text, flags=re.S)
    if updated != text:
        AWARDS.write_text(updated, encoding="utf-8")
    return touched


def curl(value):
    """Use typographic apostrophes in every learner-facing string."""
    if isinstance(value, str):
        return value.replace("'", "\u2019")
    if isinstance(value, list):
        return [curl(v) for v in value]
    if isinstance(value, dict):
        return {k: curl(v) for k, v in value.items()}
    return value


def write_track(coach_id: str, manifest: dict) -> None:
    manifest = curl(manifest)
    out = RES / f"Tracks/track-{coach_id}.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    touched = register_rewards([lesson["id"] for lesson in manifest["lessons"]])
    activities = sum(len(lesson["activities"]) for lesson in manifest["lessons"])
    print(f"wrote {out.relative_to(ROOT)}: {len(manifest['lessons'])} lessons, {activities} activities; reward lists updated: {touched}")
