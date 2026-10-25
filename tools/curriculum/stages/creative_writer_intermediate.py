#!/usr/bin/env python3
"""Creative Writing, Intermediate stage (about B1-B2): 2 units x 4 lessons, added to track-creative-writer.json.

Original wording and original sample passages. Ideas (voice, concrete detail, figurative language, conflict and stakes,
subtext, scene and summary, revision) are standard craft concepts; sources are credited for ideas only.
Run from the project root: python3 tools/curriculum/stages/creative_writer_intermediate.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from track_lib import C, TF, READ, LISTEN, W, F, O, M, YOUR, add_stage  # noqa: E402

SOURCES = [
    "Public-domain essays and handbooks on style and fiction craft (concepts only; no text copied)",
    "Common creative-writing workshop practice: concrete detail, subtext, scene and summary, revision (original wording)",
]

STAGE = {"id": "intermediate", "title": "Intermediate", "units": [
    {"id": "craft", "title": "Sharpen the craft"},
    {"id": "revise", "title": "Shape and revise"},
]}

BUS = "The 7:10 bus smelled of wet wool and old coffee. Mara pressed her forehead to the cold window and counted the lamp posts, because counting was easier than thinking about the letter in her bag."
KITCHEN = "“You didn't have to come,” Dad said, wiping a clean counter. “I know,” said Jun, and put the bag by the door where he could reach it quickly."
DRAFT = "It was a really very cold day. Anna was sad because she was lonely. She walked to the shop and then she bought some bread and then she walked home and then she was still sad."

LESSONS = [
    ("cw-i-voice", "craft", "Find a voice", "CW-I-01",
     "Voice is the way a story sounds: the choice of words, the length of sentences and the attitude behind them. A cheerful narrator and a tired narrator describe the same street differently. Choose a voice that fits the story and keep it steady. Read your pages aloud: if a sentence sounds like someone else, rewrite it in the voice you chose.",
     [
         C("What is “voice” in writing?", "The way the story sounds, from word choice to attitude", "The loudness of the reader", "The font", "The title"),
         C("Which narrator sounds tired?", "The street went on and on, the way streets do when you have no strength left.", "What a bright, glorious morning it was!", "Three quick steps, and I was there.", "The street was in the city."),
         C("Why keep the voice steady?", "Readers trust a narrator who sounds consistent.", "It saves paper.", "It makes the story longer.", "It hides the plot."),
         C("How can you test your voice?", "Read the pages aloud", "Count the pages", "Print in color", "Skip the middle"),
         M("Match each style with its effect.", [["Short sentences", "quick, tense"], ["Long flowing sentences", "slow, dreamy"], ["Plain words", "honest, direct"]]),
         READ(BUS, "Which word best describes the narrator's voice?", "Quiet and watchful", "Loud and silly", "Formal and cold", "Angry and rushed"),
         TF("True or false: The same street can sound different through a cheerful and a tired narrator.", "True"),
         TF("True or false: A sentence that sounds like someone else is fine to keep.", "False"),
         F("Type the missing word: Read your pages ___ to hear the voice.", "aloud"),
         W("Build the sentence.", "The street felt long that day.", "never", "feels"),
         LISTEN("Rain again. The kind that does not fall so much as hang, as if the sky were too tired to finish the job.", "What is the mood of the voice?", "Weary", "Excited", "Angry", "Proud"),
         O("Put the steps in order.", ["Choose the voice for the story", "Write a page in that voice", "Read it aloud and fix the sentences that do not match"]),
         YOUR("Describe a kitchen at midnight in two sentences with a tired voice, then in two sentences with a cheerful voice."),
     ]),
    ("cw-i-detail", "craft", "Specific, surprising details", "CW-I-02",
     "A detail is specific when only this person or place could have it. “A car” is general; “a green car with one brown door” is specific. Choose details that tell the reader something about character or feeling, not just appearance. One surprising detail can do more than five ordinary ones. Ask of every detail: What does this show?",
     [
         C("Which phrase is more specific?", "a green car with one brown door", "a car", "a vehicle", "a thing with wheels"),
         C("Which detail tells us about character?", "She kept every receipt in a shoebox labeled “Proof.”", "She had a box.", "The box was nearby.", "The box was made of paper."),
         C("What question helps you choose details?", "What does this show?", "How long is it?", "Is it red?", "Who else has one?"),
         C("Why use one surprising detail?", "It can show more than several ordinary ones.", "It makes the story shorter.", "It hides the plot.", "It replaces the ending."),
         READ(BUS, "Which detail shows Mara's feelings?", "She counts lamp posts to avoid thinking about the letter.", "The bus has windows.", "It is seven ten.", "The coffee is old."),
         M("Match each pair of details with how they work.", [["a dog", "general"], ["a three-legged dog that guards a broom", "specific and surprising"], ["a nice man", "vague"]]),
         TF("True or false: A detail should show something about a person or feeling.", "True"),
         TF("True or false: More details always make a scene better.", "False"),
         F("Type the missing word: Choose the ___ detail, not the usual one.", "surprising"),
         W("Build the sentence.", "He kept a spare key in a boot.", "never", "keys"),
         LISTEN("Her grandfather always carried two umbrellas: one for himself and one for whoever he met.", "What does the detail show?", "He is generous", "He is forgetful", "It rains often", "He sells umbrellas"),
         O("Put the revision in order.", ["Find a general detail", "Ask what it should show", "Replace it with a specific one"]),
         YOUR("Rewrite “a messy room” with three specific details that show the person who lives there."),
     ]),
    ("cw-i-figure", "craft", "Simile, metaphor, and when to stop", "CW-I-03",
     "A simile compares with “like” or “as”: “Her laugh was like a door slamming.” A metaphor says one thing is another: “The city was a machine.” Fresh comparisons help readers see. Avoid clichés such as “cold as ice.” Use one strong image rather than three weak ones, and make sure the comparison fits the mood of the scene.",
     [
         C("Which sentence is a simile?", "Her laugh was like a door slamming.", "The city was a machine.", "She laughed.", "The door slammed."),
         C("Which sentence is a metaphor?", "The city was a machine.", "The city was like a machine.", "The city was big.", "The city hums."),
         C("Which phrase is a cliché?", "cold as ice", "cold as a shut refrigerator at midnight", "cold like old coins", "cold in her bones, slowly"),
         C("How many strong images do you need in a short scene?", "One strong image is often enough", "Ten", "None allowed", "Exactly five"),
         C("What should a comparison match?", "The mood of the scene", "The length of the title", "The reader's age", "The page number"),
         M("Match each type with how it compares.", [["Simile", "uses like or as"], ["Metaphor", "says one thing is another"], ["Cliché", "an overused comparison"]]),
         TF("True or false: A fresh comparison is usually better than a cliché.", "True"),
         TF("True or false: Three weak images are better than one strong image.", "False"),
         F("Type the missing word: A ___ compares with “like” or “as.”", "simile"),
         W("Build the sentence.", "The night was a black coat.", "never", "nights"),
         LISTEN("The silence in the house was like a held breath, waiting for someone to speak first.", "What kind of comparison is this?", "A simile", "A metaphor", "A cliché", "A question"),
         O("Put the steps in order.", ["Notice a general description", "Think of something that shares its feeling", "Write the comparison and check the mood"]),
         YOUR("Write one fresh simile and one metaphor about a waiting room."),
     ]),
    ("cw-i-conflict", "craft", "Conflict and stakes", "CW-I-04",
     "A story moves when someone wants something and something stands in the way. That is conflict. The obstacle can be a person, a rule, a place or a fear inside the character. Stakes are what the character could lose or win. Raise the stakes slowly: let the reader see why it matters. If nothing could be lost, there is little to read for.",
     [
         C("What is conflict?", "Someone wants something and something stands in the way", "A loud argument only", "The title", "A happy ending"),
         C("What are stakes?", "What the character could lose or win", "The number of pages", "The setting", "The narrator's name"),
         C("Which is an inner obstacle?", "Fear of speaking in public", "A locked door", "A storm", "A bus"),
         C("Which is an outer obstacle?", "A closed bridge", "Doubt", "Shame", "Hope"),
         C("Why raise the stakes slowly?", "So the reader sees why it matters", "To end faster", "To avoid the plot", "To add characters"),
         READ(BUS, "What might Mara fear?", "What the letter will change", "The bus driver", "The cold window", "The lamp posts"),
         M("Match each item with what it adds.", [["Want", "gives the character a goal"], ["Obstacle", "makes the goal hard"], ["Stakes", "shows why it matters"]]),
         TF("True or false: A story with nothing to lose usually feels flat.", "True"),
         F("Type the missing word: Conflict needs a want and an ___.", "obstacle"),
         W("Build the sentence.", "She could lose her home.", "never", "loses"),
         LISTEN("Tom must finish the race to win the money for his sister's surgery. But his shoe has just broken, and the finish line is two miles away.", "What are the stakes?", "His sister's surgery", "A new pair of shoes", "A medal", "A holiday"),
         O("Put the setup in order.", ["Give the character a want", "Add an obstacle", "Show what could be lost"]),
         YOUR("Write the want, the obstacle and the stakes for a character who must return a library book today."),
     ]),
    ("cw-i-subtext", "revise", "Say it without saying it", "CW-I-05",
     "In real life people often do not say what they mean. Subtext is the meaning under the words. In dialogue, let characters talk about one thing while feeling another. Use actions and objects to carry the feeling. In the kitchen scene, Jun puts the bag where he can reach it quickly: the words are polite, but the action says he may leave. Do not explain the subtext; trust the reader.",
     [
         READ(KITCHEN, "What does Jun's action suggest?", "He may leave soon.", "He is hungry.", "He loves cleaning.", "He is cold."),
         READ(KITCHEN, "What is Dad probably feeling?", "Nervous or sad that Jun will go", "Angry about dinner", "Bored", "Proud of the counter"),
         C("What is subtext?", "The meaning under the words", "A kind of title", "A long speech", "A footnote"),
         C("Which line has more subtext?", "“It's fine,” she said, and folded the same napkin again.", "“I am sad,” she said.", "“I feel sad because of my brother,” she said.", "She was sad."),
         C("Should the narrator explain the subtext?", "No, trust the reader", "Yes, always", "Only at the end", "Only in the title"),
         M("Match each action with what it may suggest.", [["Checking the phone again and again", "waiting for news"], ["Wiping a clean counter", "nervousness"], ["Standing near the door", "wanting to leave"]]),
         TF("True or false: Dialogue should always say exactly what characters feel.", "False"),
         TF("True or false: Objects and actions can carry feeling.", "True"),
         F("Type the missing word: Let actions carry the ___.", "feeling"),
         W("Build the sentence.", "It's fine, she said.", "never", "fines"),
         LISTEN("“Nice of you to call,” Dad said. He turned the radio up a little. “I didn't expect it.”", "What does turning up the radio suggest?", "He is hiding his feelings", "He loves music", "He is deaf", "He is angry at the radio"),
         O("Put the steps in order.", ["Decide the true feeling", "Have the characters talk about something else", "Add an action that hints at the feeling"]),
         YOUR("Write four lines of dialogue where two friends argue about a borrowed jacket but really mean something else."),
     ]),
    ("cw-i-pace", "revise", "Control the pace", "CW-I-06",
     "Pace is how fast the story moves. Summary covers time quickly: “For three weeks she wrote every night.” A scene slows down and shows moment by moment, with dialogue and detail. Use summary for the in-between and scenes for what matters most. Short sentences speed up the action; longer ones slow the mood. If the story drags, cut or summarize; if it rushes, expand the key moment into a scene.",
     [
         C("Which sentence is summary?", "For three weeks she wrote every night.", "She picked up the pen, hand shaking, and wrote one line.", "“Go,” he whispered.", "The door creaked open."),
         C("When should you use a scene?", "For what matters most", "For every minute", "Never", "For the title only"),
         C("What do short sentences do?", "Speed up the action", "Slow the mood", "Hide the plot", "End the story"),
         C("The story drags. What can you do?", "Cut or summarize", "Add more detail everywhere", "Add a map", "Repeat the opening"),
         C("The key moment is only one sentence. What can you do?", "Expand it into a scene", "Delete it", "Hide it", "Summarize it twice"),
         M("Match each tool with its effect.", [["Summary", "moves through time quickly"], ["Scene", "shows a moment closely"], ["Long sentence", "slows the mood"]]),
         TF("True or false: Every moment needs the same amount of space.", "False"),
         TF("True or false: Summary is useful for the in-between parts.", "True"),
         F("Type the missing word: Use a ___ for the moment that matters most.", "scene"),
         W("Build the sentence.", "Weeks passed in silence.", "never", "pass"),
         LISTEN("Three winters went by. Then, one gray morning, the letter came. Mara held it in both hands and did not move.", "Where does the pace slow down?", "At the letter", "In the first sentence", "At the end of the winters", "Nowhere"),
         O("Put the decision in order.", ["Find the key moment", "Write it as a close scene", "Summarize the time around it"]),
         YOUR("Summarize a week of waiting in one sentence, then write the moment the news arrives as a three-sentence scene."),
     ]),
    ("cw-i-revise", "revise", "Revise: cut, move, sharpen", "CW-I-07",
     "Writing becomes good in revision. First read the whole draft for shape: does it have a clear want, an obstacle and a change? Then cut what repeats or does not matter. Move parts to a better place. Last, sharpen sentences: replace weak words such as “really” and “very,” and choose stronger verbs. Revise in rounds, one job at a time, and put the draft away for a day between rounds.",
     [
         READ(DRAFT, "What is the weakest feature of this draft?", "It repeats “and then” and tells feelings without showing them.", "It has too many characters.", "It is too short.", "It uses too many numbers."),
         C("What should you do first in revision?", "Read the whole draft for shape", "Fix every comma", "Delete the title", "Add adjectives"),
         C("What can you cut?", "What repeats or does not matter", "The want", "The obstacle", "The ending"),
         C("Which words are often weak?", "really and very", "wanted and fear", "door and street", "Mara and Dad"),
         C("Why put the draft away for a day?", "You see problems more clearly afterward.", "It saves ink.", "It improves the paper.", "It ends the story."),
         M("Match each round with its job.", [["Shape", "check want, obstacle and change"], ["Cut and move", "remove repeats and reorder"], ["Sharpen", "choose stronger words"]]),
         O("Put the rounds in order.", ["Read for shape", "Cut and move parts", "Sharpen the sentences"]),
         TF("True or false: Good writers usually revise in rounds.", "True"),
         TF("True or false: You should fix every word in the first round.", "False"),
         F("Type the missing word: Replace weak words with a stronger ___.", "verb"),
         W("Build the sentence.", "I cut the repeated lines.", "never", "cuts"),
         LISTEN("The first draft said: She was really very tired. The revision says: She dragged her feet up the stairs. The second shows the tiredness.", "Why is the revision better?", "It shows instead of telling", "It is longer", "It has more adverbs", "It has no verb"),
         YOUR("Revise this: “He was really angry and then he went out and then he slammed the door.”"),
     ]),
    ("cw-i-share", "revise", "Share your work and receive feedback", "CW-I-08",
     "Feedback helps you see what you cannot see. Tell readers what kind of help you want: “Is the ending clear?” Listen without defending. Notice where several readers agree; that is probably a real problem. When you give feedback, begin with what works, name one thing that confused you, and describe your reaction rather than ordering a change: “I got lost in the middle” is more useful than “Rewrite the middle.”",
     [
         C("What should you do when you ask for feedback?", "Say what kind of help you want", "Say nothing", "Hide the draft", "Ask them to rewrite it"),
         C("What should you do while you receive feedback?", "Listen without defending", "Argue each point", "Leave early", "Delete the story"),
         C("When several readers agree, what does it often mean?", "There is probably a real problem", "They are all wrong", "The story is perfect", "They like the title"),
         C("Which comment is most useful?", "I got lost in the middle when the narrator changed.", "I hate it.", "Rewrite everything.", "Make it better."),
         C("How should you begin when you give feedback?", "With what works", "With a list of mistakes", "With your own story", "With a joke"),
         M("Match each action with its purpose.", [["Ask a focused question", "gets useful answers"], ["Listen", "lets you understand"], ["Describe your reaction", "shows what the reader felt"]]),
         O("Put the feedback in order.", ["Say what works", "Name one thing that confused you", "Describe your reaction"]),
         TF("True or false: Defending your draft helps you learn from readers.", "False"),
         TF("True or false: A focused question usually gets a more useful answer.", "True"),
         F("Type the missing word: Begin with what ___.", "works"),
         W("Build the sentence.", "I got lost in the middle.", "never", "lose"),
         LISTEN("I loved the opening image. I got a little lost when the narrator changed in the third scene. Was that on purpose?", "What does the reader do first?", "Names what works", "Gives an order", "Rewrites the scene", "Asks for money"),
         YOUR("You read a friend's story. Write three sentences of feedback: one thing that works, one thing that confused you, one question."),
     ]),
]

if __name__ == "__main__":
    add_stage("creative-writer", STAGE, LESSONS, "Intermediate", SOURCES)
