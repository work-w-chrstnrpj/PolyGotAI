#!/usr/bin/env python3
"""Apply reading formatting (tools/curriculum/reading_format/*.json) to the bundled lessons, in place.

The coach reading pages and the course coach tips were single paragraphs. The formatting files give the same words with
blank-line paragraphs, "- " bullets and **bold** key forms (rendered by FormattedText in the app). Keys are
"lessonID/pageID" for track reading pages and the lesson id for course tips (course-tips.json).

Run after build_topic_lessons.py (which rewrites the track files), from the project root:
python3 tools/curriculum/format_reading.py
Fails when a key matches nothing, or when a formatted text changes the words (only a joining "and"/"or" may go).
"""
from __future__ import annotations

import difflib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RES = ROOT / "application/SpeechCoachAI/Resources"
DATA = ROOT / "tools/curriculum/reading_format"
DROPPABLE = {"and", "or"}


def words(text: str) -> list[str]:
    return re.findall(r"\w+", text.lower())


def plain(text: str) -> str:
    return text.replace("**", "").replace("\n- ", "\n").removeprefix("- ").replace("\n", " ")


def same_words(original: str, formatted: str) -> bool:
    """True when the formatted text keeps the original words (a joining and/or may be dropped)."""
    a, b = words(plain(original)), words(plain(formatted))
    for op, i1, i2, _, _ in difflib.SequenceMatcher(None, a, b, autojunk=False).get_opcodes():
        if op == "equal" or (op == "delete" and set(a[i1:i2]) <= DROPPABLE):
            continue
        return False
    return True


def write(path: Path, data, text: str) -> bool:
    out = json.dumps(data, indent=2, ensure_ascii=False) + ("\n" if text.endswith("\n") else "")
    if out != text:
        path.write_text(out, encoding="utf-8")
        return True
    return False


def main() -> None:
    pages: dict[str, str] = {}
    for path in sorted(DATA.glob("part-*.json")):
        pages.update(json.loads(path.read_text(encoding="utf-8")))
    tips_path = DATA / "course-tips.json"
    tips: dict[str, str] = json.loads(tips_path.read_text(encoding="utf-8")) if tips_path.exists() else {}
    problems, used = [], set()

    for path in sorted((RES / "Tracks").glob("track-*.json")):
        text = path.read_text(encoding="utf-8")
        data = json.loads(text)
        for lesson in data["lessons"]:
            for page in lesson.get("reading") or []:
                key = f"{lesson['id']}/{page['id']}"
                if key not in pages:
                    continue
                used.add(key)
                if not same_words(page["explanation"], pages[key]):
                    problems.append(f"{key}: the formatted text changes the words")
                    continue
                page["explanation"] = pages[key]
        write(path, data, text)

    catalog = RES / "Curriculum/CurriculumCatalog.json"
    text = catalog.read_text(encoding="utf-8")
    data = json.loads(text)
    lessons = data["lessons"] if isinstance(data, dict) else data
    for lesson in lessons:
        key = lesson.get("id")
        if key in tips and lesson.get("tip"):
            used.add(key)
            if not same_words(lesson["tip"], tips[key]):
                problems.append(f"{key}: the formatted tip changes the words")
                continue
            lesson["tip"] = tips[key]
    write(catalog, data, text)

    problems += [f"{key}: matches no reading page or course tip" for key in sorted(set(pages) | set(tips)) if key not in used]
    if problems:
        sys.exit("\n".join(problems))
    print(f"formatted {len(used & set(pages))} reading pages and {len(used & set(tips))} course tips")


if __name__ == "__main__":
    main()
