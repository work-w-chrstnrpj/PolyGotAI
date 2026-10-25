#!/usr/bin/env python3
"""Validate the bundled course catalog and coach track files.

Usage: python3 tools/curriculum/validate.py [--quiet]

Checks (mirrors ExerciseSpec.problem() in the app, plus authoring rules):
  * lesson ids are unique across the course and every track
  * activity ids are unique inside a lesson
  * every typed exercise has the fields its type needs
  * choice/wordBank answers are covered by the options
  * track lessons have a tip, a trackId/unitId that match their file, and sources
Exit code 1 when any problem is found.
"""
from __future__ import annotations

import glob
import json
import os
import re
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
RES = os.path.join(ROOT, "application", "SpeechCoachAI", "Resources")
TYPES = {"choice", "wordBank", "fillBlank", "match", "order", "spotError", "listenType", "speak", "open"}


def norm(text: str) -> str:
    text = text.lower().replace("’", "'").replace("-", " ")
    return " ".join(re.sub(r"[.,!?;:\"]", "", w).strip("'") for w in text.split() if w.strip(".,!?;:\"'"))


def blank(values) -> bool:
    return not values or any(not str(v).strip() for v in values)


def exercise_problem(ex: dict, has_clip: bool) -> str | None:
    kind = ex.get("type")
    if kind not in TYPES:
        return f"unknown exercise type {kind!r}"
    options, accepted = ex.get("options"), ex.get("accepted")
    if kind == "open":
        return None
    if kind == "choice":
        if blank(options) or blank(accepted):
            return "choice needs options and accepted"
        if len(options) < 2:
            return "choice needs at least two options"
        if len(set(options)) != len(options):
            return "duplicate options"
        if any(a not in options for a in accepted):
            return "accepted answer is not an option"
    elif kind == "wordBank":
        if blank(options) or blank(accepted):
            return "wordBank needs options and accepted"
        pool = [norm(o) for o in options]
        for tile in accepted[0].split():
            tile = norm(tile)
            if not tile:
                continue
            if tile not in pool:
                return f"tile {tile!r} missing from options"
            pool.remove(tile)
    elif kind in {"fillBlank", "spotError", "listenType", "speak"}:
        if blank(accepted):
            return f"{kind} needs accepted"
        if kind in {"listenType", "speak"} and not (ex.get("audioText") or "").strip() and not has_clip:
            return f"{kind} needs audioText or a clip"
        if kind == "spotError" and blank(options):
            return "spotError needs the sentence tokens in options"
    elif kind == "match":
        pairs = ex.get("pairs") or []
        if len(pairs) < 3 or any(len(p) != 2 or not p[0] or not p[1] for p in pairs):
            return "match needs three or more pairs"
        if len({p[0] for p in pairs}) != len(pairs) or len({p[1] for p in pairs}) != len(pairs):
            return "duplicate match side"
    elif kind == "order":
        items = ex.get("items") or []
        if len(items) < 3 or blank(items) or len(set(items)) != len(items):
            return "order needs three or more distinct items"
    return None


def check_lesson(lesson: dict, where: str, errors: list, track_id: str | None = None, unit_id: str | None = None):
    lid = lesson.get("id", "?")
    seen = set()
    for act in lesson.get("activities", []):
        aid = act.get("id", "?")
        if aid in seen:
            errors.append(f"{where}: {lid}: duplicate activity id {aid}")
        seen.add(aid)
        if act.get("kind") == "listening" and not act.get("assetId"):
            errors.append(f"{where}: {lid}/{aid}: kind listening needs a recorded clip (assetId); use kind grammar with audioText")
        ex = act.get("exercise")
        if ex is not None:
            problem = exercise_problem(ex, bool(act.get("assetId")))
            if problem:
                errors.append(f"{where}: {lid}/{aid}: {problem}")
    if track_id is not None:
        if not (lesson.get("tip") or "").strip():
            errors.append(f"{where}: {lid}: track lesson needs a tip")
        if lesson.get("trackId") != track_id:
            errors.append(f"{where}: {lid}: trackId {lesson.get('trackId')!r} != {track_id!r}")
        if lesson.get("unitId") != unit_id:
            errors.append(f"{where}: {lid}: unitId {lesson.get('unitId')!r} != {unit_id!r}")
        if blank(lesson.get("sources")):
            errors.append(f"{where}: {lid}: track lesson needs sources")
        if not any(a.get("exercise", {}).get("type") not in (None, "open") for a in lesson.get("activities", [])):
            errors.append(f"{where}: {lid}: track lesson needs at least one auto-checked exercise")


def main() -> int:
    errors: list[str] = []
    ids: dict[str, str] = {}
    counts = {"course": 0, "track": 0, "typed": 0}

    course_path = os.path.join(RES, "Curriculum", "CurriculumCatalog.json")
    with open(course_path, encoding="utf-8") as fh:
        catalog = json.load(fh)
    for lesson in catalog.get("lessons", []):
        lid = lesson["id"]
        if lid in ids:
            errors.append(f"course: duplicate lesson id {lid} (also in {ids[lid]})")
        ids[lid] = "course"
        counts["course"] += 1
        counts["typed"] += sum(1 for a in lesson["activities"] if a.get("exercise"))
        check_lesson(lesson, "course", errors)
    for lesson in catalog.get("archivedLessons", []):
        check_lesson(lesson, "course(archived)", errors)

    coaches = {"grammarian", "readingListening", "debater", "negotiator", "publicSpeaker",
               "journalist", "creativeWriter", "business", "storyteller", "copywriter"}
    awards = open(os.path.join(RES, "Rewards", "AwardCatalog.json"), encoding="utf-8").read()
    # Track file: a curriculum manifest plus a "track" object {id, coach, stages:[{id,title,units:[{id,title}]}]}.
    for path in sorted(glob.glob(os.path.join(RES, "Tracks", "track-*.json"))):
        name = os.path.basename(path)
        with open(path, encoding="utf-8") as fh:
            data = json.load(fh)
        track = data.get("track") or {}
        track_id = track.get("id")
        if not track_id or f"track-{track_id}.json" != name:
            errors.append(f"{name}: track.id must match the file name")
        if track.get("coach") not in coaches:
            errors.append(f"{name}: unknown coach {track.get('coach')!r}")
        units = {u["id"] for stage in track.get("stages", []) for u in stage.get("units", [])}
        if not units:
            errors.append(f"{name}: no units")
        for lesson in data.get("lessons", []):
            lid = lesson["id"]
            if lid in ids:
                errors.append(f"{name}: duplicate lesson id {lid} (also in {ids[lid]})")
            ids[lid] = name
            counts["track"] += 1
            counts["typed"] += sum(1 for a in lesson["activities"] if a.get("exercise"))
            check_lesson(lesson, name, errors, track_id, lesson.get("unitId"))
            if lesson.get("unitId") not in units:
                errors.append(f"{name}: {lid}: unitId {lesson.get('unitId')!r} is not in the track")
            if f'"{lid}@{lesson["contentVersion"]}"' not in awards:
                errors.append(f"{name}: {lid}: not listed in AwardCatalog.json contentTargetIDs (earns no XP)")


    # Lexicon bank: lexicon-*.json = {group:{id,title,level,tagline,sources}, words:[{lemma,pos,meaning,examples,wrong}]}
    pos_ok = {"noun", "verb", "adjective", "adverb", "preposition", "conjunction", "pronoun", "phrase"}
    seen_words: dict[str, str] = {}
    lexicon_words = 0
    for path in sorted(glob.glob(os.path.join(RES, "Lexicon", "lexicon-*.json"))):
        name = os.path.basename(path)
        with open(path, encoding="utf-8") as fh:
            data = json.load(fh)
        group = data.get("group", {})
        if not group.get("id") or blank(group.get("sources")):
            errors.append(f"{name}: group needs an id and sources")
        for word in data.get("words", []):
            lexicon_words += 1
            lemma = word.get("lemma", "")
            key = f"{norm(lemma)}|{word.get('pos')}"
            if key in seen_words:
                errors.append(f"{name}: duplicate word {lemma!r} ({word.get('pos')}), also in {seen_words[key]}")
            seen_words[key] = name
            if word.get("pos") not in pos_ok:
                errors.append(f"{name}: {lemma}: unknown part of speech {word.get('pos')!r}")
            if not (word.get("meaning") or "").strip() or len(word.get("meaning", "")) > 140:
                errors.append(f"{name}: {lemma}: meaning missing or too long")
            examples = word.get("examples") or []
            if not examples:
                errors.append(f"{name}: {lemma}: needs an example")
            for ex in examples:
                if ex.count("{") != 1 or ex.count("}") != 1 or ex.index("{") > ex.index("}") or ex[ex.index("{") + 1:ex.index("}")].strip() == "":
                    errors.append(f"{name}: {lemma}: example needs exactly one {{marked}} form: {ex!r}")
            wrong = word.get("wrong") or []
            if not wrong or any(("{" in w or "}" in w or not w.strip()) for w in wrong):
                errors.append(f"{name}: {lemma}: needs wrong-usage sentences without braces")
    counts["lexicon"] = lexicon_words

    if "--quiet" not in sys.argv:
        print(f"lexicon words: {counts.get('lexicon', 0)}")
        print(f"course lessons: {counts['course']}, track lessons: {counts['track']}, typed exercises: {counts['typed']}")
    for error in errors:
        print("ERROR", error)
    if errors:
        print(f"{len(errors)} problem(s)")
        return 1
    if "--quiet" not in sys.argv:
        print("OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
