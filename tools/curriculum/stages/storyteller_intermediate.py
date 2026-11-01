#!/usr/bin/env python3
"""Storytelling, Intermediate stage (about B1-B2): 2 units x 4 lessons, added to track-storyteller.json.

Original wording and original sample stories. Ideas (and-but-therefore, character through choices, setup and payoff,
adapting to time and audience, practice and review) are standard storytelling-teaching concepts; sources credited for ideas only.
Run from the project root: python3 tools/curriculum/stages/storyteller_intermediate.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from track_lib import C, TF, READ, LISTEN, W, F, O, M, YOUR, add_stage  # noqa: E402

SOURCES = [
    "Oral-storytelling traditions and public-domain folktale collections (structure ideas only; no text copied)",
    "Common storytelling-workshop practice: and, but, therefore; setup and payoff; time-boxed tellings (original wording)",
]

STAGE = {"id": "intermediate", "title": "Intermediate", "units": [
    {"id": "build", "title": "Build the story"},
    {"id": "perform", "title": "Tell it with presence"},
]}

LOST = "Rita lost her father's old watch on the way to the market. She searched every stall, but nobody had seen it. Then a boy brought it to her, because he had heard its tick under a cart."
RACE = "Luis wanted to win the town race, so he trained every morning. But on race day it rained hard and the road turned to mud. He ran slowly, laughed, and finished last, with the happiest face in the crowd."

LESSONS = [
    ("st-i-abt", "build", "And, but, therefore", "ST-I-01",
     "Many good stories move on three small words. “And” sets the scene. “But” brings the problem. “Therefore” shows what happens because of it. “Rita lost the watch, but no one had seen it, therefore she searched every stall.” If your story only uses “and then,” it is a list. Look for the “but” and the “therefore” and put them early.",
     [
         READ(LOST, "Which word brings the problem?", "but", "and", "then", "because"),
         C("Which word shows a result?", "therefore", "and", "maybe", "also"),
         C("Which sentence sets the scene?", "Rita went to the market and bought bread.", "But the watch was missing.", "Therefore she cried.", "No one knew."),
         C("A story that only uses “and then” is mostly what?", "A list", "A mystery", "A poem", "A song"),
         C("Where should the “but” appear?", "Early in the story", "Only at the end", "Nowhere", "In the title"),
         M("Match each word with its job.", [["And", "sets the scene"], ["But", "brings the problem"], ["Therefore", "shows the result"]]),
         O("Put the story in order.", ["Rita walks to the market", "She loses the watch", "She searches every stall"]),
         TF("True or false: “But” helps a story move forward.", "True"),
         TF("True or false: “And then” again and again makes a strong plot.", "False"),
         F("Type the missing word: Rita lost the watch, ___ no one had seen it.", "but"),
         W("Build the sentence.", "She lost it, but she kept looking.", "never", "kept"),
         LISTEN("Tom wanted to bake a cake, but the oven was broken, therefore he baked it on a campfire.", "What is the result?", "He baked on a campfire", "He bought a cake", "He gave up", "He fixed the oven"),
         YOUR("Tell a short story with “and,” “but” and “therefore” in three sentences."),
     ]),
    ("st-i-choice", "build", "Show character through choices", "ST-I-02",
     "We learn who a person is by what they choose when it costs them something. A kind person might give up their seat; a stubborn person might refuse help. Let the character make a hard choice in your story, and show it with an action, not a label. “She handed him her umbrella and walked on in the rain” says more than “She was kind.”",
     [
         C("How do we best learn about a character?", "By what they choose when it costs something", "By their age", "By their address", "By a list of adjectives"),
         C("Which sentence shows kindness?", "She handed him her umbrella and walked on in the rain.", "She was kind.", "Kindness is good.", "He was wet."),
         C("Which shows stubbornness?", "He pushed the helping hand away and kept dragging the box.", "He was stubborn.", "The box was heavy.", "He sat down."),
         C("Why make a choice cost something?", "The cost makes the choice meaningful", "It makes the story longer", "It hides the plot", "It adds jokes"),
         READ(RACE, "What does Luis's choice on race day show?", "He enjoys the race more than winning.", "He hates mud.", "He is lazy.", "He is angry."),
         M("Match each action with the trait it suggests.", [["Gives away a seat", "kind"], ["Refuses all help", "stubborn"], ["Arrives early every day", "reliable"]]),
         TF("True or false: A label such as “brave” shows more than an action.", "False"),
         TF("True or false: A choice that costs nothing tells us little.", "True"),
         F("Type the missing word: Show the trait with an ___, not a label.", "action"),
         W("Build the sentence.", "He gave her his last coin.", "never", "gives"),
         LISTEN("The bus was late again. Nina gave her seat to a stranger, stood by the door and smiled at the baby in the stroller.", "What does Nina's action suggest?", "She is generous", "She is lost", "She is angry", "She is late"),
         O("Put the character moment in order.", ["Show a problem", "Let the character choose", "Show the cost of the choice"]),
         YOUR("Show that a character is honest without using the word “honest.” Write two or three sentences."),
     ]),
    ("st-i-senses", "build", "Details for the ear", "ST-I-03",
     "Listeners cannot see the page, so they need to see the scene in their minds. Use details from the senses: what the place smelled like, the sound of a door, the feel of a cold handle. Pick two or three details, not twenty. Name them in simple words. A concrete detail makes a listener say, “I know that place.”",
     [
         C("Why do spoken stories need sense details?", "Listeners must picture the scene", "They fill time", "They replace the plot", "They make words longer"),
         C("How many details should you use for one scene?", "Two or three", "Twenty", "None", "One hundred"),
         C("Which phrase uses a sense detail?", "the smell of bread and wet stone", "a nice place", "a big thing", "something good"),
         C("Which detail is concrete?", "a cold metal handle", "a feeling", "something old", "a thing"),
         C("What reaction do you want?", "“I know that place.”", "“I am lost.”", "“That is too long.”", "“Who is that?”"),
         M("Match each sense with a detail.", [["Smell", "bread and wet stone"], ["Sound", "a door that sticks and squeaks"], ["Touch", "a cold metal handle"]]),
         TF("True or false: Plain words are fine for sense details.", "True"),
         TF("True or false: Twenty details make a scene clearer.", "False"),
         F("Type the missing word: Use details from the ___.", "senses"),
         W("Build the sentence.", "The door squeaked loudly.", "never", "squeak"),
         LISTEN("The market smelled of oranges and rain. A man shouted prices, and my shoes stuck to the wet stones.", "Which sense is NOT used?", "Taste", "Smell", "Sound", "Touch"),
         O("Put the steps in order.", ["Picture the place", "Choose two or three sense details", "Say them in simple words"]),
         YOUR("Describe a bus stop in the rain with three sense details."),
     ]),
    ("st-i-funny", "build", "Setup, surprise and payoff", "ST-I-04",
     "Humor and surprise work in three steps. The setup creates an expectation. The surprise breaks it. The payoff is the moment people laugh or gasp. Plant a small detail early and bring it back later: “the red umbrella” can return at the end. Keep jokes short, and leave a tiny pause before the surprise. If the audience does not react, keep going calmly.",
     [
         C("What does the setup do?", "Creates an expectation", "Ends the story", "Tells the title", "Introduces the audience"),
         C("What is the payoff?", "The moment people laugh or gasp", "The first line", "The title", "The thank you"),
         C("What is a callback?", "Bringing an early detail back later", "A phone call", "A new title", "A loud ending"),
         C("What helps before the surprise?", "A tiny pause", "A long apology", "A loud shout", "A new topic"),
         C("What should you do if the audience does not react?", "Keep going calmly", "Stop and leave", "Repeat the joke five times", "Blame the audience"),
         M("Match each step with its job.", [["Setup", "builds an expectation"], ["Surprise", "breaks the expectation"], ["Payoff", "gets the reaction"]]),
         O("Put the joke in order.", ["Build the expectation", "Break it with a surprise", "Pause for the reaction"]),
         TF("True or false: A detail planted early can pay off later.", "True"),
         TF("True or false: A long explanation makes a joke funnier.", "False"),
         F("Type the missing word: Plant a small detail ___ and use it later.", "early"),
         W("Build the sentence.", "And then the red umbrella came back.", "never", "return"),
         LISTEN("At the start, Leo says he never loses his umbrella. At the end of the story, the umbrella is on a stranger's head. Leo smiles and says, Well, I never lose it. Someone borrows it.", "What is the callback?", "The umbrella", "The stranger", "The smile", "The start"),
         YOUR("Write a three-sentence story with a setup, a surprise and a callback."),
     ]),
    ("st-i-voices", "perform", "Voices and gestures", "ST-I-05",
     "Use your voice to show who is speaking. Change pace, pitch or volume a little for each character, and keep each voice steady. A small shift is enough: you do not need to do an accent. Use one or two gestures that fit the story, such as holding a pretend cup. Keep your body open to the audience, and stay in the story: do not break to comment on your own voices.",
     [
         C("How can you show a different character?", "Change pace, pitch or volume a little", "Shout every line", "Whisper the whole story", "Use a long pause"),
         C("Do you need to do an accent?", "No, a small shift is enough", "Yes, always", "Only for children", "Only at the end"),
         C("Why keep each voice steady?", "Listeners can tell who is speaking", "It saves breath", "It shortens the story", "It hides the plot"),
         C("Which gesture suits a story?", "Holding a pretend cup", "Pointing at the audience", "Checking your phone", "Hiding your hands"),
         C("What should you avoid?", "Breaking the story to comment on your voices", "Practicing", "Listening", "Smiling"),
         M("Match each tool with its effect.", [["Slower pace", "feels calm or serious"], ["Higher pitch", "feels lighter or younger"], ["Softer volume", "feels secret or close"]]),
         TF("True or false: A small change in voice is enough.", "True"),
         TF("True or false: Big gestures on every word help the story.", "False"),
         F("Type the missing word: Keep each character's voice ___.", "steady"),
         W("Build the sentence.", "She spoke softly and slowly.", "never", "soft"),
         LISTEN("Grandpa spoke slowly and low: Come here, little one. The girl answered quickly and high: I am coming!", "How are the two voices different?", "Grandpa is slow and low, the girl quick and high", "Both are loud", "Both are slow", "They are the same"),
         O("Put the steps in order.", ["Decide how each character sounds", "Practice the two voices", "Tell the story and keep the voices steady"]),
         YOUR("Write a two-line dialogue between a tired parent and an excited child, with a note on how each voice sounds."),
     ]),
    ("st-i-time", "perform", "One story, three lengths", "ST-I-06",
     "A story must fit the time you have. Keep a 30-second version with only the want, the problem and the change. Keep a three-minute version that adds two or three details and a short scene. Know the one moment you will never cut. When time is short, cut background first, then side characters, but keep the turning point. Practice with a timer.",
     [
         C("What belongs in a 30-second version?", "The want, the problem and the change", "Every detail", "Four side stories", "A long introduction"),
         C("What can a three-minute version add?", "Two or three details and a short scene", "A second plot", "A lecture", "A list of names"),
         C("What should you cut first when time is short?", "Background", "The turning point", "The ending", "The want"),
         C("What must you keep?", "The turning point", "All side characters", "The longest description", "The date"),
         C("How can you check timing?", "Practice with a timer", "Guess", "Ask the room", "Skip it"),
         M("Match each version with its size.", [["30 seconds", "want, problem, change"], ["3 minutes", "adds details and a scene"], ["Never cut", "the turning point"]]),
         O("Put the cuts in order.", ["Cut background first", "Cut side characters next", "Keep the turning point"]),
         TF("True or false: You can cut the turning point if time is short.", "False"),
         F("Type the missing word: Practice with a ___.", "timer"),
         W("Build the sentence.", "I need a thirty second version.", "never", "thirty-second"),
         LISTEN("Short version: Rita lost her father's watch, a boy found it by its tick, and she learned to listen. Long version adds the market, the cart and the boy's name.", "What does the short version keep?", "The want, problem and change", "The boy's name", "The market description", "The cart"),
         LISTEN("Short version: Rita lost her father's watch, a boy found it by its tick, and she learned to listen. Long version adds the market, the cart and the boy's name.", "What does the long version add?", "The market, the cart and the name", "A new ending", "A new problem", "A song"),
         YOUR("Write your own 30-second version of a story you know, in three sentences."),
     ]),
    ("st-i-open", "perform", "Openings, endings and callbacks", "ST-I-07",
     "Open with something that makes people lean in: a moment, a question, or a strange fact. Do not start with “I am going to tell you a story.” End with a line that echoes the opening, so the story feels complete. A final image or a short sentence works better than a long moral. Leave a pause after the last line before you say thank you.",
     [
         C("Which opening makes listeners lean in?", "The night my brother vanished, I was holding a spoon.", "I am going to tell you a story.", "Hello.", "This is a story."),
         C("What makes an ending feel complete?", "A line that echoes the opening", "A long moral", "A new topic", "An apology"),
         C("Which ending is stronger?", "I still keep the spoon.", "And that is the end of my story, and the moral is to always be careful.", "Thanks for listening to all of that.", "So yeah."),
         C("What should you do after the last line?", "Pause", "Run", "Explain it", "Start again"),
         C("Which opening should you avoid?", "I am going to tell you a story.", "A strange noise woke me up.", "Nobody believed me.", "It started with a letter."),
         M("Match each tool with its job.", [["Opening moment", "makes people lean in"], ["Echo in the ending", "shows the story is complete"], ["Pause", "lets the ending land"]]),
         TF("True or false: A long moral is the best ending.", "False"),
         TF("True or false: An ending can echo the opening.", "True"),
         F("Type the missing word: End with a final ___.", "image"),
         W("Build the sentence.", "I still keep the spoon.", "never", "kept"),
         LISTEN("It started with a spoon. A silver spoon, left on the step. Years later, I still keep it by my bed.", "How does the ending connect to the opening?", "It returns to the spoon", "It introduces a new person", "It changes the topic", "It ends with a moral"),
         O("Put the story frame in order.", ["Open with a strong moment", "Tell the middle", "End with an echo of the opening"]),
         YOUR("Write an opening line and an ending line that echo each other."),
     ]),
    ("st-i-review", "perform", "Practice, record, improve", "ST-I-08",
     "You improve fastest when you tell a story out loud, listen back and change one thing. Record yourself on your phone. Listen for pace, pauses and filler words such as “um.” Choose one change for the next telling: slow down at the turning point, for example. Tell it to a friend and ask, “Where were you most interested? Where did you drift?”",
     [
         C("How can you improve a spoken story?", "Tell it aloud, listen back and change one thing", "Read it silently", "Never practice", "Change everything each time"),
         C("What can you listen for in a recording?", "Pace, pauses and fillers", "Only the title", "The color of the room", "The brand of the phone"),
         C("How many changes should you try per telling?", "One", "Ten", "None", "Fifty"),
         C("Which question gets useful feedback?", "Where did you drift?", "Did you like me?", "Is it Friday?", "Was it long?"),
         C("Which change is specific?", "Slow down at the turning point.", "Be better.", "Try harder.", "Fix it."),
         M("Match each step with its purpose.", [["Record", "hear yourself"], ["Choose one change", "keep practice focused"], ["Ask a friend", "learn what worked"]]),
         O("Put the practice in order.", ["Tell the story aloud", "Listen to the recording", "Choose one change and try again"]),
         TF("True or false: Changing everything at once is the best way to practice.", "False"),
         F("Type the missing word: Listen for filler words such as ___.", "um"),
         W("Build the sentence.", "I will slow down at the turning point.", "never", "slows"),
         LISTEN("I listened to my recording. I rush the middle and say um too often. Next time I will slow down at the turning point.", "What change will the speaker try?", "Slow down at the turning point", "Remove the ending", "Speak louder", "Add a song"),
         YOUR("Write one thing you would listen for in a recording of your story and one change you would try."),
     ]),
]

if __name__ == "__main__":
    add_stage("storyteller", STAGE, LESSONS, "Intermediate", SOURCES)
