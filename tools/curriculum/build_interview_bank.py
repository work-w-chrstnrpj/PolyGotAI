#!/usr/bin/env python3
"""Build Resources/SpeechLab/speechlab-interview.json: the scripted question bank for the hands-free Interview (Phase 5b).

Every question has two fixed follow-ups, chosen by a rule, never by AI: `followUpShort` is used when the answer was brief,
`followUpLong` when it was already long. Original wording. Run from the project root: python3 tools/curriculum/build_interview_bank.py
"""
from __future__ import annotations

import json
from pathlib import Path

OUT = Path(__file__).resolve().parents[2] / "application/SpeechCoachAI/Resources/SpeechLab/speechlab-interview.json"

# (id, stage, level, title, question, follow-up when the answer was short, follow-up when it was long)
SETS = {
    "general": [
        ("open-1", "opening", "A1", "Your name", "Hello. Please tell me your name and where you are from.", "Can you tell me a little more about that place?", "What do you like most about it?"),
        ("open-2", "opening", "A2", "Your day", "Hi. How has your day been so far?", "What did you do this morning?", "What was the best part of it?"),
        ("core-1", "core", "A2", "Your week", "What do you do during the week?", "What does a normal day look like?", "Which part of the week do you enjoy most?"),
        ("core-2", "core", "A2", "Free time", "What do you like to do in your free time?", "How often do you do that?", "How did you start doing it?"),
        ("core-3", "core", "A2", "People", "Tell me about your family or the people you live with.", "What do you usually do together?", "What is it like to live with them?"),
        ("core-4", "core", "B1", "A place", "Describe a place you like to visit.", "What can a visitor do there?", "Why would you recommend it to a friend?"),
        ("core-5", "core", "B1", "Learning", "What is something new you learned recently?", "How did you learn it?", "How will you use it in the future?"),
        ("core-6", "core", "B1", "A meal", "Tell me about a meal you enjoyed.", "Who was with you?", "What made that meal special?"),
        ("core-7", "core", "B2", "A habit", "What is one habit you would like to change, and why?", "What makes it hard to change?", "What would be the first small step?"),
        ("core-8", "core", "B2", "Change of plans", "Describe a time when plans changed and you had to adjust.", "How did you feel at that moment?", "What did that experience teach you?"),
        ("core-9", "core", "C1", "Daily life", "How has your daily life changed over the last few years?", "Which change has mattered most?", "Would you go back to the way things were?"),
        ("close-1", "closing", "A2", "Anything else", "Is there anything else you would like to tell me?", "Is there something you would like to ask me?", "Thank you. That was clear and well organized."),
        ("close-2", "closing", "B1", "Next", "What would you like to learn or do next?", "Why does that interest you?", "What will you do to get started?"),
    ],
    "job": [
        ("open-1", "opening", "A2", "Introduction", "Thank you for coming in. Please introduce yourself.", "Can you tell me a little about your background?", "Which part of your background is most useful for this role?"),
        ("open-2", "opening", "B1", "Background", "Tell me a little about your work or study background.", "What was your main job in that role?", "What was the most important thing you learned there?"),
        ("core-1", "core", "A2", "Interest", "Why are you interested in this job?", "What do you know about our company?", "What would you like to do here in the first month?"),
        ("core-2", "core", "A2", "Strengths", "What are your main strengths?", "Can you give an example of one strength?", "How did you build that strength?"),
        ("core-3", "core", "B1", "A task", "Tell me about a task you did well.", "What was your part in the task?", "What would you do differently next time?"),
        ("core-4", "core", "B1", "A problem", "Describe a problem you solved at work or school.", "What did you do first?", "How did you know the solution worked?"),
        ("core-5", "core", "B1", "Teamwork", "How do you work with other people?", "Can you describe a team you enjoyed?", "How do you handle a disagreement in a team?"),
        ("core-6", "core", "B1", "Time", "How do you manage your time when you are very busy?", "What do you do first when everything is urgent?", "Tell me about a time this plan worked well."),
        ("core-7", "core", "B2", "A mistake", "Tell me about a time you made a mistake. What did you do?", "What did you learn from it?", "How do you prevent that kind of mistake now?"),
        ("core-8", "core", "B2", "Feedback", "How do you react when someone gives you critical feedback?", "Can you give a recent example?", "What changed after that feedback?"),
        ("core-9", "core", "B2", "Future", "Where do you see yourself in three years?", "What skills do you want to build?", "How does this job fit into that plan?"),
        ("core-10", "core", "C1", "Why you", "Why should we choose you for this role?", "What makes your experience different?", "What result could you deliver in the first six months?"),
        ("close-1", "closing", "B1", "Questions", "Do you have any questions for us?", "Is there anything about the team you would like to know?", "Thank you. Those are thoughtful questions."),
        ("close-2", "closing", "B1", "Last words", "Is there anything you would like to add before we finish?", "Is there one last point you want me to remember?", "Thank you for your time today."),
    ],
    "study": [
        ("open-1", "opening", "A2", "Welcome", "Welcome. Please tell me about yourself.", "What do you study, or what would you like to study?", "What made you choose that subject?"),
        ("open-2", "opening", "B1", "Background", "Tell me about your education so far.", "What was your favorite subject?", "What did that subject teach you about yourself?"),
        ("core-1", "core", "A2", "Subject", "Why do you want to study this subject?", "When did you first become interested in it?", "What would you like to do with it?"),
        ("core-2", "core", "B1", "A course", "What did you enjoy most in your last course?", "Can you describe one lesson?", "What would you change about that course?"),
        ("core-3", "core", "B1", "A project", "Describe a project you worked on.", "What was your role in it?", "What was the hardest part, and how did you solve it?"),
        ("core-4", "core", "B1", "Study time", "How do you organize your study time?", "Where do you usually study?", "What do you do when you feel tired or lose focus?"),
        ("core-5", "core", "B2", "A hard topic", "Tell me about a difficult topic and how you learned it.", "What helped you most?", "How would you explain it to a beginner?"),
        ("core-6", "core", "B2", "Groups", "How do you work in a group?", "What role do you usually take?", "How do you deal with a group member who does not help?"),
        ("core-7", "core", "B2", "After study", "What do you want to do after you finish your studies?", "Why does that appeal to you?", "What is your plan if the first option does not work?"),
        ("core-8", "core", "C1", "An idea", "What is a book, article or idea that influenced you?", "What was its main point?", "Do you still agree with it today?"),
        ("close-1", "closing", "B1", "Questions", "Do you have any questions for us?", "Is there something about the program you would like to know?", "Thank you. Those are thoughtful questions."),
        ("close-2", "closing", "B1", "Last words", "Is there anything you would like to add?", "Is there one last point you want me to remember?", "Thank you for your time today."),
    ],
}
TITLES = {"general": "Get to know you", "job": "Job interview", "study": "Study interview"}


def build() -> None:
    items = []
    for set_id, rows in SETS.items():
        for key, stage, level, title, text, short, long in rows:
            items.append({"id": f"interview-{set_id}-{key}", "set": set_id, "setTitle": TITLES[set_id], "stage": stage, "level": level,
                          "title": title, "text": text, "followUpShort": short, "followUpLong": long})
    credits = "Original SpeechCoachAI interview questions and follow-ups, written 2026-10-25. Fixed rules choose each follow-up; no AI is used."
    doc = {"version": 1, "credits": credits, "items": items}
    text = json.dumps(doc, indent=2, ensure_ascii=False).replace("'", "’")
    OUT.write_text(text + "\n", encoding="utf-8")
    print(f"wrote {OUT.name}: {len(items)} questions in {len(SETS)} sets")


if __name__ == "__main__":
    build()
