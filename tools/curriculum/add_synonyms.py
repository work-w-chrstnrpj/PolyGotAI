#!/usr/bin/env python3
"""Add synonyms (tools/curriculum/lexdata/synonyms.py) to the older Lexicon bank words, in place, after build_lexicon.py.

Keys are a lemma, or "lemma/pos" when one lemma has two parts of speech. Fails on duplicate keys, on keys that
match no word, and on a synonym equal to its word. Run from the project root:
python3 tools/curriculum/add_synonyms.py
"""
from __future__ import annotations

import ast
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BANK = ROOT / "application/SpeechCoachAI/Resources/Lexicon"
SOURCE = ROOT / "tools/curriculum/lexdata/synonyms.py"


def load() -> dict[str, list[str]]:
    tree = ast.parse(SOURCE.read_text(encoding="utf-8"))
    for node in tree.body:
        if isinstance(node, ast.AnnAssign) and getattr(node.target, "id", "") == "SYNONYMS":
            keys = [ast.literal_eval(k) for k in node.value.keys]
            dupes = sorted({k for k in keys if keys.count(k) > 1})
            if dupes:
                sys.exit(f"duplicate keys: {dupes}")
            return ast.literal_eval(node.value)
    sys.exit("SYNONYMS not found")


def phase14_groups() -> set[str]:
    """Group ids of the Phase 14 packs; their words carry their own synonyms in lexdata/more_*.py."""
    sys.path.insert(0, str(SOURCE.parent.parent))
    from lexdata import more_a1, more_a2, more_b1, more_b2, more_c1, more_c2
    import importlib
    extras = [importlib.import_module(f"lexdata.{path.stem}") for path in sorted((SOURCE.parent).glob("extra_*.py"))]
    return {pack[1] for module in (more_a1, more_a2, more_b1, more_b2, more_c1, more_c2, *extras) for pack in module.PACKS}


def main() -> None:
    synonyms = load()
    skip_groups = phase14_groups()
    used: set[str] = set()
    problems: list[str] = []
    total = 0
    for path in sorted(BANK.glob("lexicon-*.json")):
        data = json.loads(path.read_text(encoding="utf-8"))
        if data["group"]["id"] in skip_groups:
            continue
        for word in data["words"]:
            key = f"{word['lemma']}/{word['pos']}"
            if key not in synonyms:
                key = word["lemma"]
            values = synonyms.get(key)
            if values is None:
                word.pop("synonyms", None)
                continue
            used.add(key)
            if any(v.strip().lower() == word["lemma"].lower() or not v.strip() for v in values):
                problems.append(f"{key}: synonym blank or same as the word")
            word["synonyms"] = values
            total += 1
        path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    unused = sorted(set(synonyms) - used)
    if unused:
        problems.append(f"keys that match no word: {unused}")
    if problems:
        sys.exit("\n".join(problems))
    print(f"synonyms added to {total} words")


if __name__ == "__main__":
    main()
