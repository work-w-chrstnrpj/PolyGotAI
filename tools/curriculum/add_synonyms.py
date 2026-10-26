#!/usr/bin/env python3
"""Add synonyms (tools/curriculum/lexdata/synonyms.py) to the Lexicon bank JSON files, in place.

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


def main() -> None:
    synonyms = load()
    used: set[str] = set()
    problems: list[str] = []
    total = 0
    for path in sorted(BANK.glob("lexicon-*.json")):
        data = json.loads(path.read_text(encoding="utf-8"))
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
