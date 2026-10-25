#!/usr/bin/env python3
"""Reading & Listening Comprehension, Foundation stage (about A2-B1): 2 units x 4 lessons, added to track-reading-listening.json.

Original wording and original passages. Ideas (skimming, topic sentences, reference words, sequence words, listening for
numbers and instructions, speaker purpose, quick notes) are standard teaching concepts; sources credited for ideas only.
Run from the project root: python3 tools/curriculum/stages/reading_listening_foundation.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from track_lib import C, TF, READ, LISTEN, W, F, O, M, YOUR, add_stage  # noqa: E402

SOURCES = [
    "British Council-EAQUALS Core Inventory for General English (topic order and level)",
    "CEFR Companion Volume (reading and listening descriptors, A2-B1)",
]

STAGE = {"id": "foundation", "title": "Foundation", "units": [
    {"id": "texts", "title": "Read longer texts"},
    {"id": "live", "title": "Listen in real time"},
]}

CLUB = "The town library runs a reading club for adults. It meets on the first Thursday of every month at six in the evening. Members choose a new book together, and anyone can join for free. Last month fifteen people came to talk about a mystery novel. The club also has a snack table, where members bring cookies or fruit."
BIKE = "Many cities now offer shared bikes. People pick up a bike at a station, ride to another station and leave it there. The service is cheap for short trips, but it can be expensive for a whole day. It is popular with tourists. Some residents like it too because they do not need to buy or repair a bike."
RECIPE = "First, wash the rice twice. Next, put it in a pot with two cups of water. After that, cook it on low heat for fifteen minutes. Finally, leave the lid on for five more minutes before you serve it."
MAYA = "Maya moved to a new city in March. At first she felt lonely, so she joined a running group. It meets twice a week. Now she has a few close friends there, and she says it changed her year."

LESSONS = [
    ("rl-f-skim", "texts", "Skim, then scan", "RL-F-01",
     "Skimming means reading fast to get the general idea: look at the title, the first sentence of each paragraph and the last line. Scanning means looking for one fact, such as a name, number or date, without reading every word. Skim first to know what the text is, then scan for the detail you need. Do not stop at every new word.",
     [
         READ(CLUB, "What is the club mostly about?", "Adults who read and talk about books together", "A snack shop", "A children's class", "A new library building"),
         READ(CLUB, "How often does the club meet?", "Once a month, on a Thursday", "Every Thursday", "Twice a month", "On weekends"),
         C("What does skimming mean?", "Reading fast to get the general idea", "Reading every word slowly", "Looking for one fact", "Writing notes"),
         C("What does scanning mean?", "Looking for one specific fact", "Reading for the general idea", "Reading aloud", "Translating"),
         C("Which should you do first?", "Skim to know what the text is", "Scan for a detail", "Look up every word", "Read the last page"),
         M("Match each task with the skill.", [["Read the title and first lines", "skim"], ["Find a phone number", "scan"], ["Read every word carefully", "neither"]]),
         TF("True or false: You should stop at every new word when you skim.", "False"),
         TF("True or false: Scanning is useful for finding names and numbers.", "True"),
         F("Type the missing word: ___ means looking for one fact.", "scanning", "scan"),
         W("Build the sentence.", "I skim the text first.", "never", "skims"),
         LISTEN("To find the price, I do not read the whole page. I look for the numbers and the word dollars.", "Which skill is the speaker using?", "Scanning", "Skimming", "Translating", "Writing"),
         O("Put the steps in order.", ["Look at the title", "Skim for the general idea", "Scan for the detail you need"]),
         YOUR("Write what you would do to find the opening hours on a long web page. Use the words skim or scan."),
     ]),
    ("rl-f-topic", "texts", "Paragraphs and topic sentences", "RL-F-02",
     "A paragraph usually has one main idea. The topic sentence states it, often at the start. The other sentences give details, examples or reasons. Read the first sentence of each paragraph to follow the text quickly. If you can say what each paragraph is about in a few words, you have understood the structure.",
     [
         READ(BIKE, "Which sentence is the topic sentence?", "Many cities now offer shared bikes.", "It is popular with tourists.", "People pick up a bike at a station.", "Some residents like it too."),
         READ(BIKE, "Which detail supports the idea that bikes are cheap?", "The service is cheap for short trips.", "It is popular with tourists.", "People ride to another station.", "Many cities offer bikes."),
         C("What does a topic sentence do?", "States the main idea of the paragraph", "Ends the text", "Gives a number", "Gives a title"),
         C("Where is a topic sentence often found?", "At the start of the paragraph", "In the title only", "At the end of the page", "Nowhere"),
         C("What do the other sentences usually give?", "Details, examples or reasons", "The title", "A new topic", "A joke"),
         M("Match each sentence with its role.", [["Many cities offer shared bikes.", "topic sentence"], ["It is cheap for short trips.", "a detail about price"], ["It is popular with tourists.", "a detail about users"]]),
         O("Put the reading steps in order.", ["Read the first sentence of each paragraph", "Say each paragraph's idea in a few words", "Read the details you need"]),
         TF("True or false: A paragraph usually has one main idea.", "True"),
         F("Type the missing word: A ___ sentence states the main idea.", "topic"),
         W("Build the sentence.", "This paragraph is about shared bikes.", "never", "share"),
         LISTEN("The first paragraph is about the club's rules. The second paragraph is about the books members choose. The third is about the snack table.", "What is the second paragraph about?", "The books members choose", "The snack table", "The club's rules", "The library building"),
         LISTEN("The first paragraph is about the club's rules. The second paragraph is about the books members choose. The third is about the snack table.", "How many paragraphs does the speaker mention?", "Three", "Two", "Four", "One"),
         YOUR("Write a topic sentence and one detail for a paragraph about your favorite place."),
     ]),
    ("rl-f-ref", "texts", "What does “it” mean?", "RL-F-03",
     "Writers avoid repeating words, so they use pronouns such as it, they, this and them. To understand a text, find what each pronoun points to. It usually refers to the nearest noun before it that fits. “The club is free. It meets monthly.” Here it means the club. If you are unsure, replace the pronoun with the noun and check that the sentence makes sense.",
     [
         READ(MAYA, "What does “it” refer to in “She says it changed her year”?", "Joining the running group", "The new city", "March", "The year"),
         READ(MAYA, "What does “there” refer to in “friends there”?", "The running group", "Her old home", "A shop", "A school"),
         C("In “The club is free. It meets monthly,” what is “it”?", "The club", "It meets monthly", "The library", "The price"),
         C("What does a pronoun do?", "Replaces a noun so it is not repeated", "Starts a paragraph", "Ends a sentence", "Gives a date"),
         C("How can you check what a pronoun means?", "Replace it with the noun and see if it makes sense", "Delete it", "Guess", "Translate it"),
         M("Match each pronoun with what it could replace.", [["they", "several people"], ["it", "one thing"], ["them", "people or things as the object"]]),
         TF("True or false: A pronoun usually refers to a noun that came earlier.", "True"),
         TF("True or false: You should ignore pronouns when you read.", "False"),
         F("Type the missing word: Replace the pronoun with the ___ to check.", "noun"),
         W("Build the sentence.", "It means the running group.", "never", "they"),
         LISTEN("Tom bought a bike and a helmet. He uses them every day. The bike is old, but it works well.", "What does “them” mean?", "The bike and the helmet", "Tom and his friend", "The days", "The shops"),
         LISTEN("Tom bought a bike and a helmet. He uses them every day. The bike is old, but it works well.", "What works well?", "The bike", "The helmet", "The day", "The shop"),
         YOUR("Write two sentences. In the second one, use a pronoun that clearly refers to a noun in the first."),
     ]),
    ("rl-f-sequence", "texts", "Follow a sequence", "RL-F-04",
     "Instructions and stories often use time words to show order: first, then, next, after that, finally. They help you picture what happens and in which order. When you read instructions, number the steps. If the order is not clear, look for words like before and after. “Before you serve it” means serving comes later than the earlier steps.",
     [
         READ(RECIPE, "What do you do after you cook the rice on low heat?", "Leave the lid on for five more minutes", "Wash the rice", "Add two cups of water", "Serve at once"),
         READ(RECIPE, "Which word shows the last step?", "Finally", "First", "Next", "After that"),
         C("Which word shows the beginning?", "First", "Finally", "After that", "Then"),
         C("What does “before you serve it” tell you?", "Serving comes later", "Serving comes first", "Serving never happens", "Serving happens in the middle"),
         C("What helps with instructions?", "Numbering the steps", "Skipping steps", "Reading only the last line", "Guessing"),
         M("Match each word with its position.", [["First", "start"], ["Next", "middle"], ["Finally", "end"]]),
         O("Put the steps in order.", ["Wash the rice", "Cook it for fifteen minutes", "Leave the lid on and serve"]),
         TF("True or false: Time words help you see the order of steps.", "True"),
         F("Type the missing word: ___, wash the rice twice.", "first"),
         W("Build the sentence.", "After that, add the water.", "never", "adds"),
         LISTEN("First, open the box. Next, take out the parts. After that, follow the picture. Finally, check that everything is tight.", "What is the last step?", "Check that everything is tight", "Open the box", "Take out the parts", "Follow the picture"),
         LISTEN("First, open the box. Next, take out the parts. After that, follow the picture. Finally, check that everything is tight.", "What comes after taking out the parts?", "Follow the picture", "Check everything", "Open the box", "Throw away the box"),
         YOUR("Write three steps to make tea, using first, next and finally."),
     ]),
    ("rl-f-numbers", "live", "Numbers, times and prices", "RL-F-05",
     "In speech, numbers go quickly, and some sound alike: thirteen and thirty, fifteen and fifty. Listen for the stress: thirTEEN has stress on the end; THIRty on the start. Times can be said in different ways: “half past four,” “four thirty.” Prices: “twelve fifty” can mean 12.50. Write the numbers as digits while you listen.",
     [
         LISTEN("The train leaves at four thirty from platform thirteen.", "Which platform?", "Thirteen", "Thirty", "Fifty", "Fifteen"),
         LISTEN("The train leaves at four thirty from platform thirteen.", "What time does it leave?", "Four thirty", "Four thirteen", "Three thirty", "Five thirty"),
         LISTEN("The ticket costs twelve fifty, and the museum guide costs five dollars.", "How much is the ticket?", "12.50", "12.15", "5.50", "50"),
         C("Which pair sounds alike?", "fifteen and fifty", "one and two", "six and nine", "ten and eleven"),
         C("Where is the stress in “thirteen”?", "At the end", "At the start", "There is none", "In the middle"),
         C("Which is another way to say 4:30?", "half past four", "a quarter to four", "half past three", "four o'clock"),
         M("Match each spoken form with the number.", [["fifteen", "15"], ["fifty", "50"], ["a quarter past six", "6:15"]]),
         TF("True or false: “Twelve fifty” can mean 12.50.", "True"),
         F("Type the number: thirty", "30", "thirty"),
         W("Build the sentence.", "It costs twelve fifty.", "never", "twelves"),
         O("Put the listening steps in order.", ["Listen for the number words", "Write them as digits", "Check the stress to avoid mistakes"]),
         LISTEN("The class starts at a quarter past nine, and it ends at ten forty-five.", "When does the class end?", "10:45", "9:15", "10:15", "9:45"),
         YOUR("Write the time, the price and the number you hear in this sentence: “It leaves at half past five and costs eighteen dollars.”"),
     ]),
    ("rl-f-instruct", "live", "Follow spoken instructions", "RL-F-06",
     "To follow spoken instructions, listen for action words: turn, press, open, wait. Listen for order words and for numbers. Repeat or write short notes: left 2nd street. If you miss a step, ask politely: “Could you repeat the last part?” Repeat the full set at the end to check: “So I go left, then walk two blocks.”",
     [
         LISTEN("Turn left at the bank. Walk two blocks. The pharmacy is on your right, next to the bakery.", "Where is the pharmacy?", "On the right, next to the bakery", "On the left", "Behind the bank", "Across the park"),
         LISTEN("Turn left at the bank. Walk two blocks. The pharmacy is on your right, next to the bakery.", "How many blocks do you walk?", "Two", "Three", "One", "Five"),
         C("Which words signal actions?", "turn, press, open, wait", "bank, bakery, park", "left, right, near", "two, three, four"),
         C("What can you say if you miss a step?", "Could you repeat the last part?", "Be quiet.", "I know.", "Goodbye."),
         C("How can you check you understood?", "Repeat the full set of steps", "Say nothing", "Walk away", "Ask for money"),
         M("Match each phrase with its function.", [["Turn left", "an action"], ["Two blocks", "a number or distance"], ["Could you repeat that?", "a request for help"]]),
         O("Put the directions in order.", ["Turn left at the bank", "Walk two blocks", "Find the pharmacy on the right"]),
         TF("True or false: It is polite to ask someone to repeat a step.", "True"),
         F("Type the missing word: Could you ___ that, please?", "repeat"),
         W("Build the sentence.", "So I turn left, then walk two blocks.", "never", "walking"),
         LISTEN("Press the green button. Wait for the beep. Then enter your number and press the star.", "What do you do after the beep?", "Enter your number", "Press the green button", "Wait again", "Hang up"),
         LISTEN("Press the green button. Wait for the beep. Then enter your number and press the star.", "Which button comes last?", "The star", "The green button", "The red button", "The number one"),
         YOUR("Write three short spoken instructions for getting from the door of your home to the nearest shop."),
     ]),
    ("rl-f-speaker", "live", "Who is speaking and why?", "RL-F-07",
     "Before you listen, ask: Who is speaking? Who are they speaking to? What do they want? The answers help you predict the words. A shop assistant speaks differently from a friend. Listen for clues: the greeting, the words used and the tone (friendly, formal, upset). The purpose might be to inform, ask, invite, complain or thank.",
     [
         LISTEN("Good morning, thank you for calling Blue Bank. How can I help you today?", "Who is probably speaking?", "A bank employee", "A friend", "A teacher", "A tourist"),
         LISTEN("Hey! Are you free on Saturday? We're having a small party at my place.", "What is the purpose?", "To invite", "To complain", "To thank", "To sell"),
         LISTEN("I ordered this jacket last week and it still hasn't arrived. This is the third time I'm calling.", "What is the speaker's purpose?", "To complain", "To invite", "To thank", "To inform"),
         C("Which clue helps you identify the speaker?", "The words and tone they use", "The weather", "The color of the room", "The time"),
         C("Which tone fits an apology?", "Sorry and polite", "Loud and joking", "Silent", "Angry"),
         M("Match each purpose with an example.", [["Invite", "Are you free on Saturday?"], ["Thank", "Thanks so much for your help."], ["Complain", "This is the third time I'm calling."]]),
         TF("True or false: Asking who is speaking can help you predict what you will hear.", "True"),
         TF("True or false: The tone never tells you anything.", "False"),
         F("Type the missing word: Listen for the speaker's ___.", "purpose"),
         W("Build the question.", "Who is speaking?", "does", "speaks"),
         LISTEN("Thanks so much for the lift yesterday. I really appreciate it. I owe you a coffee!", "What is the purpose?", "To thank", "To complain", "To invite", "To order"),
         O("Put the listening steps in order.", ["Ask who is speaking", "Predict what they want", "Listen and check your guess"]),
         YOUR("Write one short sentence a speaker might say to invite a friend, and one to complain politely."),
     ]),
    ("rl-f-notes", "live", "Take quick notes", "RL-F-08",
     "You cannot write every word. Note only key words: names, numbers, places, dates and actions. Use short forms and symbols: Mon, 3pm, →, @. Leave out small words like a, the and is. After listening, use your notes to write one or two full sentences. If you miss a detail, leave a blank and keep listening.",
     [
         LISTEN("The meeting is on Tuesday at three o'clock in room twelve. Please bring your laptop and the sales report.", "Which notes are best?", "Tue 3pm, room 12, laptop + sales report", "The meeting is on Tuesday and I need to bring things", "Tuesday", "Meeting"),
         LISTEN("The meeting is on Tuesday at three o'clock in room twelve. Please bring your laptop and the sales report.", "Which room?", "Twelve", "Two", "Thirteen", "Twenty"),
         C("What should you note?", "Names, numbers, places and dates", "Every word", "Only small words", "Nothing"),
         C("Which note is a short form of “Monday at nine in the morning”?", "Mon 9am", "Mn 9", "Mondaying nine", "M9 in"),
         C("What do you do if you miss a detail?", "Leave a blank and keep listening", "Stop listening", "Guess wildly", "Leave the room"),
         M("Match each short note with its meaning.", [["Mon 9am", "Monday at nine in the morning"], ["bus → station", "go by bus to the station"], ["@ cafe", "at the cafe"]]),
         O("Put the note-taking steps in order.", ["Listen for key words", "Write short notes", "Write full sentences from your notes"]),
         TF("True or false: You should write every word you hear.", "False"),
         F("Type the missing word: Leave out small words like a and ___.", "the"),
         W("Build the sentence.", "I leave a blank and keep listening.", "never", "left"),
         LISTEN("On Friday we visit the museum at ten. Lunch is at one at the cafe next to the station. We return by bus at four.", "Which note matches?", "Fri: museum 10, lunch 1 cafe, bus back 4", "Fri: park 10, lunch 2", "Sat: museum", "Fri: cafe only"),
         YOUR("Write short notes for this message: “The party is on Saturday at eight at Maria's house. Bring a drink.”"),
     ]),
]

if __name__ == "__main__":
    add_stage("reading-listening", STAGE, LESSONS, "Foundation", SOURCES)
