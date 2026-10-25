#!/usr/bin/env python3
"""Convert the twelve A1 topic lessons from content v3 to v4: a coach tip plus typed, auto-checked exercises.

* The exact v3 lesson is copied into `archivedLessons`, so saved v3 work reopens unchanged.
* Activity ids, answers and explanations stay the same. Each reading, listening, grammar and recall activity gains
  an `exercise` spec; guided speaking, self-review and quiet-text activities stay open.
* INTRO-01 is not touched.

Run once from the project root: python3 tools/curriculum/convert_a1_v4.py
"""
from __future__ import annotations

import copy
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CATALOG = ROOT / "application/SpeechCoachAI/Resources/Curriculum/CurriculumCatalog.json"


def choice(*options: str, prompt: str | None = None) -> dict:
    """The first option is the correct one; the app shuffles the buttons."""
    return {"type": "choice", "options": list(options), "accepted": [options[0]], **({"prompt": prompt} if prompt else {})}


def bank(accepted: list[str], tiles: list[str], prompt: str | None = None) -> dict:
    return {"type": "wordBank", "options": tiles, "accepted": accepted, **({"prompt": prompt} if prompt else {})}


def fill(*accepted: str, prompt: str | None = None) -> dict:
    return {"type": "fillBlank", "accepted": list(accepted), **({"prompt": prompt} if prompt else {})}


# lesson id -> tip, reading choices, listening choices, five grammar exercises
LESSONS: dict[str, dict] = {
    "a1-greetings": {
        "tip": "Say “Hello” any time, “Good morning” before noon and “Good evening” after dark. Answer “How are you?” with “I am fine, thank you,” and say “Goodbye” when you leave.",
        "reading": choice("Good evening.", "Good morning.", "Good afternoon.", "Good night."),
        "listening": choice("The speaker is fine.", "The speaker is tired.", "The speaker is late.", "The speaker is ready."),
        "grammar": [
            bank(["I am fine."], ["I", "am", "fine.", "is", "are"]),
            bank(["Are you ready?"], ["Are", "you", "ready?", "Is", "am"]),
            bank(["I am not tired.", "I’m not tired."], ["I", "am", "not", "tired.", "is", "no"]),
            choice("I am well, thank you.", "I am well, goodbye.", "You are well, thank you.", "Am I well, thank you?",
                   prompt="Reply to “How are you?” Say you are well and thank the person."),
            bank(["I am fine and ready.", "I am fine and I am ready."], ["I", "am", "fine", "and", "ready.", "but", "are"]),
        ],
    },
    "a1-alphabet": {
        "tip": "Every English letter has a name, like “B” (bee) and “N” (en). A written name starts with a capital letter. To ask for spelling say “How do you spell it?” and to hear something again say “Please repeat that.”",
        "reading": choice("B.", "E.", "N.", "A."),
        "listening": choice("A, N, A.", "A, N, N.", "E, N, A.", "A, M, A."),
        "grammar": [
            choice("My name is Ben.", "my name is ben.", "My name is ben.", "my name is Ben.", prompt="Which sentence has the capital letters correct?"),
            bank(["How do you spell it?"], ["How", "do", "you", "spell", "it?", "does", "spells"]),
            choice("My", "Me", "I", "Mine"),
            bank(["The name starts with B."], ["The", "name", "starts", "with", "B.", "start", "is"]),
            choice("Please repeat the letters.", "Letters repeat please.", "You repeat the letters now.", "Repeating are the letters.",
                   prompt="Which is a polite way to ask for the letters again?"),
        ],
    },
    "a1-numbers": {
        "tip": "Count with one, two, three. Numbers 13–19 end in “-teen” and tens end in “-ty”: fourteen is 14 and forty is 40. Ask “How many?” about a count and “How much?” about a price. After one use a singular noun; after two or more use a plural.",
        "reading": choice("Fifteen.", "Five.", "Fifty.", "Fourteen."),
        "listening": choice("Two.", "Three.", "Twelve.", "Twenty."),
        "grammar": [
            fill("fourteen"),
            fill("tickets"),
            bank(["How many tickets do you need?"], ["How", "many", "tickets", "do", "you", "need?", "does", "much"]),
            bank(["How much is one ticket?", "How much does one ticket cost?"], ["How", "much", "is", "one", "ticket?", "many", "are"]),
            choice("I need one ticket.", "I need one tickets.", "I need ones ticket.", "I needs one ticket."),
        ],
    },
    "a1-dates": {
        "tip": "Use “on” with days (on Monday), “at” with clock times (at three) and “in” with months (in March). Ask about time with “What time is the meeting?”",
        "reading": choice("March.", "Monday.", "April.", "Nine."),
        "listening": choice("On Friday at three.", "On Monday at three.", "On Friday at nine.", "In March at three."),
        "grammar": [
            choice("on", "at", "in"),
            choice("at", "on", "in"),
            choice("in", "on", "at"),
            bank(["What time is the meeting?"], ["What", "time", "is", "the", "meeting?", "are", "day"]),
            bank(["The appointment is on Monday, May 4, at nine in the morning.", "The appointment is at nine in the morning on Monday, 4 May."],
                 ["The", "appointment", "is", "on", "Monday", "May", "4", "at", "nine", "in", "the", "morning", "are", "of"]),
        ],
    },
    "family-01": {
        "tip": "Use “have” with I, you, we and they, and “has” with he, she and it: “She has a brother.” Add ’s to a name to show who someone belongs to: “Lina is Mina’s sister.” Use “is” to describe a person: “My brother is kind.”",
        "reading": choice("Lina is Mina’s sister.", "Lina is Mina’s mother.", "Lina is Mina’s teacher.", "Lina is Mina’s neighbor."),
        "listening": choice("Sam is the speaker’s brother.", "Sam is the speaker’s father.", "Sam is the speaker’s friend.", "Sam is the speaker’s teacher."),
        "grammar": [
            choice("has", "have", "is"),
            choice("have", "has", "is"),
            choice("She is a teacher.", "He is a teacher.", "It is a teacher.", "I is a teacher."),
            bank(["Lina is Mina’s sister.", "Lina is Mina's sister."], ["Lina", "is", "Mina’s", "sister.", "Mina", "are", "has"]),
            bank(["My brother is kind."], ["My", "brother", "is", "kind.", "are", "kinds"]),
        ],
    },
    "a1-home": {
        "tip": "Use “There is” for one thing and “There are” for more than one: “There is a chair. There are two chairs.” Say “a” before a consonant sound and “an” before a vowel sound: a table, an orange chair. Say where things are with “next to.”",
        "reading": choice("Upstairs.", "Downstairs.", "Next to the kitchen.", "In the bedroom."),
        "listening": choice("The kitchen.", "The bedroom.", "The bathroom.", "The garden."),
        "grammar": [
            choice("is", "are", "am"),
            choice("are", "is", "am"),
            bank(["a small table"], ["a", "small", "table", "tables", "an"]),
            choice("an", "a", "two"),
            bank(["The kitchen is next to the living room."], ["The", "kitchen", "is", "next", "to", "the", "living", "room.", "are", "in"]),
        ],
    },
    "routine-01": {
        "tip": "Use the simple present for daily routines: “I get up at six.” With he, she and it, add -s: “She starts at nine.” After “does” and “does not” use the base verb: “Does he work on Sunday?” Put “usually” before the main verb.",
        "reading": choice("Mina studies in the morning.", "Mina studies at night.", "Mina studies at six.", "Mina studies on Sunday."),
        "listening": choice("The speaker starts work at nine.", "The speaker starts work at six.", "The speaker starts work at noon.", "The speaker starts work at ten."),
        "grammar": [
            choice("starts", "start", "starting"),
            choice("Does", "Do", "Is"),
            choice("work", "works", "working"),
            bank(["I usually eat lunch at noon."], ["I", "usually", "eat", "lunch", "at", "noon.", "usual", "eats"]),
            bank(["I study in the morning and cook at night.", "I study in the morning and I cook at night."],
                 ["I", "study", "in", "the", "morning", "and", "cook", "at", "night.", "but", "studies"]),
        ],
    },
    "food-01": {
        "tip": "Order politely with “I would like tea, please” or “Can I have a sandwich?” Ask a price with “How much is the sandwich?” Use “some” with things you can’t count, like water. Add -es to make “sandwiches.”",
        "reading": choice("Mina wants tea.", "Mina wants water.", "Mina wants juice.", "Mina wants coffee."),
        "listening": choice("The speaker asks for a cake.", "The speaker asks for a sandwich.", "The speaker asks for tea.", "The speaker asks for a menu."),
        "grammar": [
            bank(["I would like tea, please.", "I’d like tea, please."], ["I", "would", "like", "tea,", "please.", "want", "can"]),
            choice("have", "has", "having"),
            choice("some", "many", "several"),
            bank(["How much is the sandwich?"], ["How", "much", "is", "the", "sandwich?", "many", "are"]),
            bank(["I would like two sandwiches."], ["I", "would", "like", "two", "sandwiches.", "sandwich", "sandwichs", "one"]),
        ],
    },
    "a1-shopping": {
        "tip": "Ask the price with “How much is this?” For more than one thing say “How much are these?” Use “it” for one thing and “them” for more than one: “I will take it. I will take them.” Say “too big” when a size doesn’t fit.",
        "reading": choice("Shoes.", "A hat.", "A shirt.", "A coat."),
        "listening": choice("A smaller shirt.", "A bigger shirt.", "A cheaper hat.", "A receipt."),
        "grammar": [
            bank(["How much is this hat?", "How much is the hat?"], ["How", "much", "is", "this", "hat?", "are", "these"]),
            choice("are", "is", "am"),
            choice("I will take them.", "I will take it.", "I will take they.", "I will take him."),
            choice("I will take it.", "I will take them.", "I will take he.", "I will take her."),
            bank(["Do you have a smaller shirt?"], ["Do", "you", "have", "a", "smaller", "shirt?", "is", "big"]),
        ],
    },
    "a1-places": {
        "tip": "Start a question about a place with “Where is …?” Give directions with the base verb: “Turn left. Go straight.” Use “next to” for a place beside another place, and start politely with “Excuse me.”",
        "reading": choice("On the right.", "On the left.", "Straight ahead.", "Behind you."),
        "listening": choice("On the left, past the bank.", "On the right, past the bank.", "On the left, before the bank.", "Next to the library."),
        "grammar": [
            bank(["Where is the library?"], ["Where", "is", "the", "library?", "are", "what"]),
            bank(["Turn left."], ["Turn", "left.", "turns", "you"]),
            bank(["Go straight, then turn right.", "Go straight. Then turn right."], ["Go", "straight,", "then", "turn", "right.", "goes", "left"]),
            choice("to", "at", "on"),
            choice("Go straight. Turn left. The library is on the right.", "Go straight turn left. The library is on the right.",
                   "Go straight. Turn left the library. Is on the right.", "Go. Straight turn left the library is on the right.",
                   prompt="Which version has the full stops in the right places?"),
        ],
    },
    "a1-hobbies": {
        "tip": "Say what you like with “I like …” and what you play with “I play …” With he, she and it, add -s: “She likes music.” After “can” use the base verb: “She can swim.” Join opposite ideas with “but.”",
        "reading": choice("On Sunday.", "On Saturday.", "On Monday.", "At night."),
        "listening": choice("Soccer.", "Piano.", "Tennis.", "Cards."),
        "grammar": [
            choice("likes", "like", "liking"),
            bank(["Do you like movies?"], ["Do", "you", "like", "movies?", "does", "likes"]),
            choice("swim", "swims", "swimming"),
            bank(["I cannot swim.", "I can’t swim.", "I can not swim."], ["I", "cannot", "swim.", "swims", "am"]),
            bank(["I like soccer, but I do not play it.", "I like soccer but don’t play it."],
                 ["I", "like", "soccer", "but", "I", "do", "not", "play", "it.", "and", "does"]),
        ],
    },
    "a1-weather": {
        "tip": "Describe the weather with “It is …”: “It is cold. It is sunny.” For something happening now use “is raining.” For a habit use “rains”: “It rains a lot in winter.” Ask “What is the weather like?” and take “a coat” when it is cold.",
        "reading": choice("Hot and sunny.", "Cold and rainy.", "Cold and sunny.", "Hot and rainy."),
        "listening": choice("A coat.", "An umbrella.", "Water.", "A hat."),
        "grammar": [
            choice("is", "are", "am"),
            bank(["It is raining.", "It’s raining."], ["It", "is", "raining.", "rains", "are"]),
            bank(["It is not raining.", "It isn’t raining.", "It’s not raining."], ["It", "is", "not", "raining.", "no", "rains"]),
            bank(["What is the weather like?", "What’s the weather like?"], ["What", "is", "the", "weather", "like?", "are", "how"]),
            choice("rains", "rain", "raining"),
        ],
    },
}


def norm(text: str) -> str:
    text = text.lower().replace("’", "'").replace("-", " ")
    return " ".join(w.strip(".,!?;:\"") for w in text.split())


def check_answer(lesson_id: str, activity: dict, built: dict) -> None:
    """The typed answer must agree with the answer the lesson already teaches (any ' / ' alternative)."""
    original = [norm(part) for part in activity["answer"].split(" / ")]
    given = norm(built["accepted"][0])
    if given not in original:
        print(f"CHECK {lesson_id}/{activity['id']}: exercise answer {built['accepted'][0]!r} vs lesson answer {activity['answer']!r}")


# (lesson id, recall index) -> prompt, where the generic rewrite reads badly with the answer buttons.
RECALL_OVERRIDES = {
    ("food-01", 2): "Choose the drink you ask for here: Can I have ___?",
    ("food-01", 3): "Choose the phrase for the list of food: Can I see ___?",
    ("a1-greetings", 3): "Choose a short answer to “How are you?”",
}


def recall_prompt(prompt: str) -> str:
    """Turn a 'Write …' recall prompt into a 'Choose …' prompt that fits answer buttons."""
    rest = re.sub(r"^Write ", "", prompt)
    if re.match(r"^(a|one) .*(sentence|question)", rest):
        return "Choose the best start for " + rest[0].lower() + rest[1:]
    return "Choose " + rest[0].lower() + rest[1:]


def convert(lesson: dict) -> dict:
    spec = LESSONS[lesson["id"]]
    lesson["contentVersion"] = "4"
    lesson["tip"] = spec["tip"]
    lesson["trackId"] = "course"
    acts = lesson["activities"]
    reading = next(a for a in acts if a["kind"] == "reading")
    listening = next(a for a in acts if a["kind"] == "listening")
    grammar = [a for a in acts if a["kind"] == "grammar"]
    recall = [a for a in acts if a["kind"] == "recall"]
    assert len(grammar) == 5 and len(recall) == 5 == len(lesson["senses"]), lesson["id"]

    for activity, key in ((reading, "reading"), (listening, "listening")):
        built = dict(spec[key])
        built.pop("prompt", None)
        activity["exercise"] = built
        check_answer(lesson["id"], activity, built)

    for activity, built in zip(grammar, spec["grammar"]):
        built = dict(built)
        override = built.pop("prompt", None)
        if override:
            activity["prompt"] = override
        activity["exercise"] = built
        check_answer(lesson["id"], activity, built)

    lemmas = [s["lemma"] for s in lesson["senses"]]
    for index, activity in enumerate(recall):
        correct = lemmas[index]
        others = [lemmas[(index + step) % 5] for step in (1, 2, 3)]
        activity["prompt"] = RECALL_OVERRIDES.get((lesson["id"], index)) or recall_prompt(activity["prompt"])
        activity["exercise"] = {"type": "choice", "options": [correct] + others, "accepted": [correct]}
    return lesson


def main() -> int:
    catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
    archived = catalog.setdefault("archivedLessons", [])
    converted = 0
    for index, lesson in enumerate(catalog["lessons"]):
        if lesson["id"] not in LESSONS:
            continue
        if lesson["contentVersion"] != "3":
            print("skip", lesson["id"], "version", lesson["contentVersion"])
            continue
        archived.append(copy.deepcopy(lesson))
        catalog["lessons"][index] = convert(lesson)
        converted += 1
    if "--dry" in sys.argv:
        print("dry run: nothing written")
        return 0
    CATALOG.write_text(json.dumps(catalog, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print("converted", converted, "lessons; archived lessons now", len(archived))
    return 0


if __name__ == "__main__":
    sys.exit(main())
