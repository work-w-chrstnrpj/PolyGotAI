#!/usr/bin/env python3
"""Add IPA (General American) and antonyms (tools/curriculum/lexdata/ipa_*.py) to the Lexicon bank, in place.

Keys are "lemma/pos". Run after build_lexicon.py and add_synonyms.py, from the project root:
python3 tools/curriculum/add_ipa.py
Fails when a bank word has no IPA, when a key matches no word, or when an antonym is the word or one of its synonyms.
"""
from __future__ import annotations

import ast
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BANK = ROOT / "application/SpeechCoachAI/Resources/Lexicon"
DATA = ROOT / "tools/curriculum/lexdata"
PARTS = ["ipa_a_aa", "ipa_a_ab", "ipa_b_aa", "ipa_b_ab", "ipa_c_aa", "ipa_c_ab"] + sorted(p.stem for p in DATA.glob("extra_*.py"))

# Counterparts rather than true opposites; left out of the antonym questions.
LOOSE = {"conversely/adverb", "exempt/adjective", "nephew/noun", "rest/verb", "income/noun", "contemporary/adjective",
         "acquire/verb", "launch/verb", "stillness/noun", "freedom/noun", "round trip/noun", "get up/verb", "hurry/verb"}


def literal(path: Path, name: str) -> dict:
    tree = ast.parse(path.read_text(encoding="utf-8"))
    for node in tree.body:
        target = node.target if isinstance(node, ast.AnnAssign) else (node.targets[0] if isinstance(node, ast.Assign) else None)
        if getattr(target, "id", "") == name:
            return ast.literal_eval(node.value)
    sys.exit(f"{path.name}: {name} not found")


def main() -> None:
    ipa: dict[str, str] = {}
    antonyms: dict[str, list[str]] = {}
    for part in PARTS:
        path = DATA / f"{part}.py"
        for key, value in literal(path, "IPA").items():
            key = key.replace("'", "\u2019")   # the bank uses typographic apostrophes
            if key in ipa and ipa[key] != value:
                sys.exit(f"{key}: two different IPA values")
            ipa[key] = value
        antonyms.update({k.replace("'", "\u2019"): [a.replace("'", "\u2019") for a in v]
                         for k, v in literal(path, "ANTONYMS").items() if k not in LOOSE})

    problems: list[str] = []
    used: set[str] = set()
    for path in sorted(BANK.glob("lexicon-*.json")):
        text = path.read_text(encoding="utf-8")
        data = json.loads(text)
        for word in data["words"]:
            key = f"{word['lemma']}/{word['pos']}"
            if key not in ipa:
                problems.append(f"{path.name}: {key}: no IPA")
                continue
            used.add(key)
            value = ipa[key]
            if not (value.startswith("/") and value.endswith("/")) or "ɹ" in value:
                problems.append(f"{key}: IPA must be /.../ with r, not ɹ")
            word["ipa"] = value
            opposite = antonyms.get(key, [])
            blocked = {word["lemma"].lower(), *[s.lower() for s in word.get("synonyms", [])]}
            if any(a.lower() in blocked or not a.strip() for a in opposite):
                problems.append(f"{key}: antonym is blank, the word or a synonym")
            if opposite:
                word["antonyms"] = opposite
            else:
                word.pop("antonyms", None)
        out = json.dumps(data, indent=2, ensure_ascii=False) + ("\n" if text.endswith("\n") else "")
        if out != text:
            path.write_text(out, encoding="utf-8")
    problems += [f"{key}: matches no bank word" for key in sorted(set(ipa) - used)]
    if problems:
        sys.exit("\n".join(problems))
    print(f"{len(used)} words with IPA, {sum(1 for k in used if k in antonyms)} with antonyms")


if __name__ == "__main__":
    main()
