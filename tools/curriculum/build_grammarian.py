#!/usr/bin/env python3
"""Build the Grammarian track (Starter stage, 2 units x 4 lessons) as Resources/Tracks/track-grammarian.json.

All wording is original to this app. The British Council-EAQUALS Core Inventory and the CEFR Companion Volume only
supply the order and level of the topics. Also registers the lessons as XP/gold targets in AwardCatalog.json
(a lesson earns nothing until `lessonID@version` is listed there).

Run from the project root: python3 tools/curriculum/build_grammarian.py
"""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RES = ROOT / "application/SpeechCoachAI/Resources"
OUT = RES / "Tracks/track-grammarian.json"
AWARDS = RES / "Rewards/AwardCatalog.json"
VERSION = "1"
SOURCES = [
    "British Council-EAQUALS Core Inventory for General English (topic order and level)",
    "CEFR Companion Volume (A1 descriptors)",
]


def C(prompt, correct, *wrong):
    return {"prompt": prompt, "answer": correct, "exercise": {"type": "choice", "options": [correct, *wrong], "accepted": [correct]}}


def TF(prompt, answer):
    return C(prompt, answer, "False" if answer == "True" else "True")


def W(prompt, answer, *extra, accepted=None):
    tiles = answer.split() + list(extra)
    return {"prompt": prompt, "answer": answer, "exercise": {"type": "wordBank", "options": tiles, "accepted": accepted or [answer]}}


def F(prompt, *accepted):
    return {"prompt": prompt, "answer": accepted[0], "exercise": {"type": "fillBlank", "accepted": list(accepted)}}


def O(prompt, items):
    return {"prompt": prompt, "answer": " ".join(items), "exercise": {"type": "order", "items": items}}


def M(prompt, pairs):
    return {"prompt": prompt, "answer": "; ".join(f"{a} = {b}" for a, b in pairs), "exercise": {"type": "match", "pairs": pairs}}


def E(sentence, fixed):
    return {"prompt": f"Find the mistake, then write the sentence correctly. {sentence}", "answer": fixed,
            "exercise": {"type": "spotError", "options": sentence.split(), "accepted": [fixed]}}


def L(text):
    return {"prompt": "Listen, then write the sentence.", "answer": text, "exercise": {"type": "listenType", "audioText": text, "accepted": [text]}}


def YOUR(prompt):
    return {"prompt": f"Your turn. {prompt}", "answer": "Any clear try is fine.", "exercise": {"type": "open"}}


UNITS = [
    {"id": "sentences", "title": "Build sentences"},
    {"id": "be-have-do", "title": "Be, have and do"},
]

LESSONS = [
    # ---------- Unit 1: Build sentences ----------
    ("gram-sent-subject", "sentences", "Subject and verb", "GRAM-S-01",
     "A sentence needs a subject (who or what) and a verb (the action or state). Put the subject first: “Maria runs.” “The dog sleeps.” Begin with a capital letter and end with a period.",
     [
         C("Which one is a complete sentence?", "Maria runs.", "Runs fast.", "Maria and the park.", "In the morning."),
         C("Pick the subject: “The dog sleeps.”", "The dog", "sleeps", "The", "dog sleeps"),
         C("Pick the verb: “Tom reads every day.”", "reads", "Tom", "every", "day"),
         W("Build the sentence.", "Birds fly.", "flies", "bird"),
         W("Build the sentence.", "The baby smiles.", "smile", "a"),
         F("Type the verb: “Lena sings.”", "sings"),
         O("Put the words in order.", ["Dogs", "bark", "loudly."]),
         M("Match each verb with its meaning.", [["run", "move fast on foot"], ["sleep", "rest at night"], ["eat", "take in food"]]),
         E("Play children in the park.", "Children play in the park."),
         L("The baby sleeps."),
         C("Which sentence starts correctly?", "She sings.", "she sings.", "She sings", "Sings she."),
         TF("True or false: A sentence needs a subject and a verb.", "True"),
         YOUR("Write three short sentences about your day. Each needs a subject and a verb."),
     ]),
    ("gram-sent-object", "sentences", "Add an object", "GRAM-S-02",
     "Many sentences add an object, the person or thing that receives the action: “Sam eats an apple.” Keep the order subject, verb, object. English does not move the object to the front.",
     [
         C("Pick the object: “Sam eats an apple.”", "an apple", "Sam", "eats", "Sam eats"),
         C("Which sentence has the right order?", "Anna reads a book.", "Reads Anna a book.", "Anna a book reads.", "A book Anna reads."),
         W("Build the sentence.", "We watch a movie.", "watches", "an"),
         W("Build the sentence.", "They buy bread.", "buys", "a"),
         F("Type the object: “Lila drinks water.”", "water"),
         F("Type the object: “We open the window.”", "the window", "window"),
         O("Put the words in order.", ["My", "sister", "cooks", "dinner."]),
         M("Match each verb with the thing that goes with it.", [["drink", "water"], ["read", "a book"], ["kick", "a ball"]]),
         E("Open I the door.", "I open the door."),
         L("She cleans the kitchen."),
         C("Which sentence has a subject, a verb and an object?", "Paul kicks the ball.", "Paul kicks.", "Kicks the ball.", "The ball in the park."),
         TF("True or false: In “Sam eats an apple,” the object is Sam.", "False"),
         YOUR("Write two sentences about what you eat or drink. Use a subject, a verb and an object."),
     ]),
    ("gram-sent-command", "sentences", "Commands and requests", "GRAM-S-03",
     "A command starts with the verb: “Open the door.” Add “please” to be polite: “Please open the door.” To say what not to do, start with “Don't”: “Don't run.”",
     [
         C("Which one is a command?", "Close the door.", "She closes the door.", "The door is closed.", "Do you close the door?"),
         C("Which is the polite request?", "Please sit down.", "Please down sit.", "Sit, down please.", "Down please sit."),
         W("Build the command.", "Open the window, please.", "opens", "a", accepted=["Open the window, please.", "Please open the window."]),
         W("Build the command.", "Don't run.", "Do", "not", "runs", accepted=["Don't run.", "Do not run."]),
         C("Which sentence tells someone NOT to do something?", "Don't touch it.", "Touch it.", "You touch it.", "I touch it."),
         F("Type the missing word: ___ be late.", "Don't", "Do not"),
         O("Put the words in order.", ["Please", "close", "the", "door."]),
         M("Match each situation with a fitting command.", [["Someone is at the door.", "Come in, please."], ["The baby is asleep.", "Be quiet, please."], ["Your friend is lost.", "Follow me."]]),
         E("Please you sit down.", "Please sit down."),
         L("Please open the book."),
         TF("True or false: A command usually starts with the verb.", "True"),
         C("Which word makes a command polite?", "please", "very", "and", "not"),
         YOUR("Write three commands for a visitor to your home. Use “please” in one."),
     ]),
    ("gram-sent-join", "sentences", "Join with and, but, or", "GRAM-S-04",
     "Join ideas with a small word. Use “and” to add, “but” to show a difference, and “or” to give a choice: “I like tea and coffee.” “I like tea, but I don't like coffee.” “Do you want tea or coffee?”",
     [
         C("You want to add two things: I have a pen ___ a notebook.", "and", "but", "or", "not"),
         C("You want to show a difference: I am small, ___ my brother is tall.", "but", "and", "or", "so"),
         C("You offer a choice: Would you like tea ___ coffee?", "or", "and", "but", "so"),
         W("Build the sentence.", "I like tea and coffee.", "but", "or"),
         W("Build the sentence.", "She is tired, but she is happy.", "and", "or"),
         F("Type the missing word: Do you want rice ___ noodles?", "or"),
         O("Put the words in order.", ["We", "eat", "rice", "and", "beans."]),
         M("Match each small word with its job.", [["and", "adds an idea"], ["but", "shows a difference"], ["or", "gives a choice"]]),
         L("I like apples and oranges."),
         C("Which sentence is correct?", "Tom has a dog and a cat.", "Tom has a dog a cat and.", "Tom and has a dog a cat.", "Tom has and a dog cat."),
         TF("True or false: We use “or” to give a choice.", "True"),
         YOUR("Write three sentences about yourself. Use and, but and or once each."),
     ]),
    # ---------- Unit 2: Be, have and do ----------
    ("gram-be-amisare", "be-have-do", "Am, is, are", "GRAM-B-01",
     "Use “am” with I, “is” with he, she and it, and “are” with you, we and they: “I am ready.” “She is ready.” “They are ready.”",
     [
         C("I ___ a student.", "am", "is", "are", "be"),
         C("She ___ a doctor.", "is", "am", "are", "be"),
         C("They ___ at home.", "are", "am", "is", "be"),
         C("It ___ cold today.", "is", "am", "are", "be"),
         W("Build the sentence.", "We are friends.", "is", "am"),
         W("Build the sentence.", "He is not late.", "are", "am"),
         F("Type the missing word: You ___ my friend.", "are"),
         F("Type the missing word: My name ___ Ana.", "is"),
         O("Put the words in order.", ["The", "bus", "is", "late."]),
         M("Match each pronoun with the form of be.", [["I", "am"], ["she", "is"], ["we", "are"]]),
         E("They is happy.", "They are happy."),
         L("We are in the kitchen."),
         YOUR("Write four sentences about you and your family. Use am, is and are."),
     ]),
    ("gram-be-have", "be-have-do", "Have and has", "GRAM-B-02",
     "Use “has” with he, she, it and with one person or thing: “She has a bike.” Use “have” with I, you, we and they: “We have a car.”",
     [
         C("I ___ a new phone.", "have", "has", "haves", "am"),
         C("He ___ two sisters.", "has", "have", "haves", "is"),
         C("They ___ a big garden.", "have", "has", "haves", "are"),
         C("My cat ___ green eyes.", "has", "have", "haves", "is"),
         W("Build the sentence.", "She has a red bag.", "have"),
         W("Build the sentence.", "We have two dogs.", "has"),
         F("Type the missing word: Tom ___ a bike.", "has"),
         F("Type the missing word: You ___ my book.", "have"),
         O("Put the words in order.", ["The", "teacher", "has", "a", "pen."]),
         M("Match each thing with what it has.", [["A bike", "has two wheels"], ["A hand", "has five fingers"], ["A week", "has seven days"]]),
         E("She have a blue pen.", "She has a blue pen."),
         L("He has a small house."),
         TF("True or false: We say “He have a car.”", "False"),
         YOUR("Write four sentences about what you and your family have. Use have and has."),
     ]),
    ("gram-be-do", "be-have-do", "Do and does in questions", "GRAM-B-03",
     "To ask a yes/no question, start with “Do” or “Does.” Use “Does” with he, she and it: “Does she like tea?” Use “Do” with I, you, we and they: “Do you like tea?” After Do or Does, the main verb stays simple: like, not likes.",
     [
         C("___ you like music?", "Do", "Does", "Are", "Is"),
         C("___ she play tennis?", "Does", "Do", "Is", "Are"),
         C("___ they live here?", "Do", "Does", "Is", "Has"),
         C("Which question is correct?", "Does he work here?", "Does he works here?", "Do he work here?", "He does work here?"),
         W("Build the question.", "Do you speak English?", "Does", "speaks"),
         W("Build the question.", "Does Maria like pizza?", "Do", "likes"),
         F("Type the missing word: ___ your brother play football?", "Does"),
         O("Put the words in order.", ["Do", "they", "walk", "to", "school?"]),
         M("Match each question with a short answer.", [["Do you like tea?", "Yes, I do."], ["Does she swim?", "No, she doesn't."], ["Do they know you?", "Yes, they do."]]),
         E("Does he plays the guitar?", "Does he play the guitar?"),
         L("Do you like coffee?"),
         TF("True or false: We say “Does she likes music?”", "False"),
         YOUR("Write four questions for a new friend. Start two with Do and two with Does."),
     ]),
    ("gram-be-dont", "be-have-do", "Don't and doesn't", "GRAM-B-04",
     "To say no, use “do not” (don't) or “does not” (doesn't) before the simple verb: “I don't like rain.” “He doesn't like rain.” Use doesn't with he, she and it.",
     [
         C("I ___ like fish.", "don't", "doesn't", "isn't", "not"),
         C("She ___ drink coffee.", "doesn't", "don't", "isn't", "not"),
         C("We ___ have a car.", "don't", "doesn't", "aren't", "not"),
         C("Which sentence is correct?", "He doesn't eat meat.", "He doesn't eats meat.", "He don't eat meat.", "He not eat meat."),
         W("Build the sentence.", "They don't live here.", "doesn't", "lives"),
         W("Build the sentence.", "My dad doesn't cook.", "don't", "cooks"),
         F("Type the missing word: The shop ___ open on Sunday.", "doesn't", "does not"),
         O("Put the words in order.", ["I", "don't", "watch", "TV", "today."]),
         M("Match each sentence with its negative.", [["I like tea.", "I don't like tea."], ["She likes tea.", "She doesn't like tea."], ["They like tea.", "They don't like tea."]]),
         E("She don't like milk.", "She doesn't like milk."),
         L("We don't have time."),
         TF("True or false: We say “He doesn't likes it.”", "False"),
         YOUR("Write four things you don't do on Sunday. Then write one thing your friend doesn't do."),
     ]),
]


def build() -> dict:
    lessons = []
    for lesson_id, unit, title, objective, tip, items in LESSONS:
        activities = []
        for index, item in enumerate(items, start=1):
            activity = {"id": f"{lesson_id}-{index:02d}", "kind": "grammar", "required": True, **item}
            activities.append(activity)
        lessons.append({
            "id": lesson_id, "contentVersion": VERSION, "level": "Starter", "title": title, "objectiveId": objective,
            "trackId": "grammarian", "unitId": unit, "tip": tip, "sources": SOURCES, "senses": [], "activities": activities,
        })
    return {
        "schemaVersion": 1,
        "packId": "speechcoach.track.grammarian",
        "contentVersion": VERSION,
        "locale": "en-US",
        "minimumSchemaVersion": 1,
        "editorialApprovalReference": "Authored 2026-10-25 for the owner's personal use. Qualified editorial review is pending. Completion records practice, not an English level.",
        "rightsReference": "Original SpeechCoachAI wording written 2026-10-25. The Core Inventory and CEFR Companion Volume supply only the topic order and level; no text is copied.",
        "assets": [],
        "track": {"id": "grammarian", "coach": "grammarian", "stages": [{"id": "starter", "title": "Starter", "units": UNITS}]},
        "lessons": lessons,
    }


def register_rewards(lesson_ids: list[str]) -> int:
    """Append `lessonID@version` after the last A1 target in every award that lists A1 v4 lessons."""
    text = AWARDS.read_text(encoding="utf-8")
    anchor = re.compile(r'^(\s*)"a1-weather@4"(,?)\n', re.M)
    new_ids = [f"{lesson}@{VERSION}" for lesson in lesson_ids]

    def add(match: re.Match) -> str:
        indent = match.group(1)
        # already registered: the new ids follow the last A1 target
        if f'"{new_ids[0]}"' in text[match.end():match.end() + 200]:
            return match.group(0)
        lines = [f'{indent}"a1-weather@4",\n'] + [f'{indent}"{i}"' + (",\n" if n < len(new_ids) - 1 else "") for n, i in enumerate(new_ids)]
        tail = ",\n" if match.group(2) else "\n"
        return "".join(lines) + tail

    updated, count = anchor.subn(add, text)
    if updated != text:
        AWARDS.write_text(updated, encoding="utf-8")
    return count


if __name__ == "__main__":
    data = build()
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    touched = register_rewards([lesson["id"] for lesson in data["lessons"]])
    exercises = sum(len(lesson["activities"]) for lesson in data["lessons"])
    print(f"wrote {OUT.relative_to(ROOT)}: {len(data['lessons'])} lessons, {exercises} activities; reward lists touched: {touched}")
