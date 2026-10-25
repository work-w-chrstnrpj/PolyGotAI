#!/usr/bin/env python3
"""Convert the A2-C2 course lessons from content v2 to v3: a coach tip plus typed, auto-checked exercises.

Same plan as convert_a1_v4.py. The exact v2 lesson is copied into `archivedLessons`, so saved v2 work reopens unchanged.
Per lesson the data modules in tools/curriculum/a2c2/ supply: a tip, answer choices for the reading and listening
questions, four grammar exercises, one true-or-false statement and one dictation sentence. The five recall items are
built automatically from the lesson's own vocabulary. Original wording throughout.

Run once from the project root: python3 tools/curriculum/convert_a2c2_v3.py   (add --dry to check without writing)
"""
from __future__ import annotations

import copy
import importlib
import json
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(HERE.parent.parent))
from track_lib import register_rewards  # noqa: E402

ROOT = HERE.parents[1]
CATALOG = ROOT / "application/SpeechCoachAI/Resources/Curriculum/CurriculumCatalog.json"
NEW_VERSION = "3"


def ch(*options: str, prompt: str | None = None, newanswer: str | None = None) -> dict:
    """Multiple choice. The first option is the correct one; the app shuffles the buttons.
    `newanswer` also rewrites the lesson's stored answer, for items whose old gap and answer did not fit together."""
    return {"type": "choice", "options": list(options), "accepted": [options[0]], **({"prompt": prompt} if prompt else {}),
            **({"newanswer": newanswer} if newanswer else {})}


def fill(*accepted: str, prompt: str | None = None) -> dict:
    return {"type": "fillBlank", "accepted": list(accepted), **({"prompt": prompt} if prompt else {})}


def bank(accepted: list[str], tiles: list[str], prompt: str | None = None) -> dict:
    return {"type": "wordBank", "options": tiles, "accepted": accepted, **({"prompt": prompt} if prompt else {})}


def load_lessons() -> dict[str, dict]:
    lessons: dict[str, dict] = {}
    for name in ("a2", "b1", "b2", "c1", "c2"):
        path = HERE / "a2c2" / f"{name}.py"
        if path.exists():
            module = importlib.import_module(f"a2c2.{name}")
            lessons.update(module.build(ch, fill, bank))
    return lessons


def norm(text: str) -> str:
    text = text.lower().replace("’", "'").replace("-", " ").replace("/", " ")
    return " ".join(w.strip(".,!?;:\"") for w in text.split())


def check_answer(lesson_id: str, activity: dict, built: dict) -> None:
    original = [norm(part) for part in activity["answer"].split(" / ")] + [norm(activity["answer"])]
    given = norm(built["accepted"][0])
    if given not in original:
        print(f"CHECK {lesson_id}/{activity['id']}: exercise answer {built['accepted'][0]!r} vs lesson answer {activity['answer']!r}")


def clean_gap_prompt(prompt: str) -> str:
    """'Fill the gap. I ___ here.' -> 'Fill in the blank: I ___ here.' so the sentence shows the blank."""
    if "___" not in prompt:
        return prompt
    match = re.match(r"^([A-Za-z][A-Za-z ]{2,28})\. (?=\S)", prompt)
    if not match:
        return prompt
    label = match.group(1)
    label = "Fill in the blank" if label == "Fill the gap" else label
    return f"{label}: {prompt[match.end():]}"


def recall_prompt(prompt: str) -> str:
    rest = re.sub(r"^Write ", "", prompt)
    if re.match(r"^(a|one) .*(sentence|question)", rest):
        return "Choose the best start for " + rest[0].lower() + rest[1:]
    return "Choose " + rest[0].lower() + rest[1:]


def convert(lesson: dict, spec: dict) -> dict:
    lesson["contentVersion"] = NEW_VERSION
    lesson["tip"] = spec["tip"]
    lesson["trackId"] = "course"
    acts = lesson["activities"]
    reading = next(a for a in acts if a["kind"] == "reading")
    listening = next(a for a in acts if a["kind"] == "listening")
    grammar = [a for a in acts if a["kind"] == "grammar"]
    recall = [a for a in acts if a["kind"] == "recall"]
    assert len(grammar) == len(spec["gram"]) and len(recall) == len(lesson["senses"]), (lesson["id"], len(grammar), len(recall), len(lesson["senses"]))

    for activity, key in ((reading, "read"), (listening, "listen")):
        options = spec[key]
        built = ch(*options)
        activity["exercise"] = built
        check_answer(lesson["id"], activity, built)

    for activity, item in zip(grammar, spec["gram"]):
        built = dict(item) if isinstance(item, dict) else ch(*item)
        override = built.pop("prompt", None)
        new_answer = built.pop("newanswer", None)
        activity["prompt"] = override or clean_gap_prompt(activity["prompt"])
        if new_answer:
            activity["answer"] = new_answer
        activity["exercise"] = built
        check_answer(lesson["id"], activity, built)

    statement, is_true, why = spec["tf"]
    answer = "True" if is_true else "False"
    true_false = {"id": f"{lesson['id']}-tf", "kind": "reading", "required": True, "prompt": f"True or false: {statement}", "answer": answer,
                  "explanation": why, "exercise": {"type": "choice", "options": ["True", "False"], "accepted": [answer]}}
    acts.insert(acts.index(listening) + 1, true_false)
    sentence = spec["dict"]
    dictation = {"id": f"{lesson['id']}-dictation", "kind": "grammar", "required": True, "prompt": "Listen, then write the sentence.", "answer": sentence,
                 "explanation": "Listen for each word, then check the spelling.",
                 "exercise": {"type": "listenType", "audioText": sentence, "accepted": [sentence]}}
    acts.insert(acts.index(true_false) + 1, dictation)

    lemmas = [s["lemma"] for s in lesson["senses"]]
    count = len(lemmas)
    for index, activity in enumerate(recall):
        correct = lemmas[index]
        others = [lemmas[(index + step) % count] for step in (1, 2, 3)]
        if " " not in correct and "…" not in correct:
            accepted = [correct]
            original = activity["answer"].strip(". ")
            if norm(original) != norm(correct):
                accepted.append(original)
            activity["exercise"] = {"type": "fillBlank", "accepted": accepted}
        else:
            activity["prompt"] = recall_prompt(activity["prompt"])
            activity["exercise"] = {"type": "choice", "options": [correct] + others, "accepted": [correct]}
    return lesson


def main() -> int:
    specs = load_lessons()
    catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
    archived = catalog.setdefault("archivedLessons", [])
    converted: list[str] = []
    for index, lesson in enumerate(catalog["lessons"]):
        if lesson["id"] not in specs:
            continue
        if lesson["contentVersion"] != "2":
            print("skip", lesson["id"], "version", lesson["contentVersion"])
            continue
        archived.append(copy.deepcopy(lesson))
        catalog["lessons"][index] = convert(lesson, specs[lesson["id"]])
        converted.append(lesson["id"])
    missing = [l["id"] for l in catalog["lessons"] if l["level"] != "A1" and l["contentVersion"] == "2" and l["id"] not in specs]
    print(f"converted {len(converted)} lessons; not yet authored: {len(missing)}")
    if "--dry" in sys.argv:
        print("dry run: nothing written")
        return 0
    CATALOG.write_text(json.dumps(catalog, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    touched = register_rewards(converted, NEW_VERSION)
    print(f"archived lessons now {len(archived)}; reward lists updated: {touched}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
