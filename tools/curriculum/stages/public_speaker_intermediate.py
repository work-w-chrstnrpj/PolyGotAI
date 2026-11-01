#!/usr/bin/env python3
"""Public Speaking & Rhetoric, Intermediate stage (about B1-B2): 2 units x 4 lessons, added to track-public-speaker.json.

Original wording. Ideas (one main message, the rule of three, spoken style, eye contact, slide design, handling questions)
are standard speaking-teaching concepts; sources are credited for ideas only.
Run from the project root: python3 tools/curriculum/stages/public_speaker_intermediate.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from track_lib import C, TF, READ, LISTEN, W, F, O, M, YOUR, add_stage  # noqa: E402

SOURCES = [
    "Aristotle, Rhetoric and Cicero, De Oratore (public-domain translations): arrangement, style and delivery as parts of speaking",
    "Common public-speaking practice (one main message, the rule of three, plain spoken style); concepts only, no text copied",
]

STAGE = {"id": "intermediate", "title": "Intermediate", "units": [
    {"id": "craft", "title": "Craft the talk"},
    {"id": "present", "title": "Present with confidence"},
]}

DRAFT = "Today I want to talk about recycling. Recycling is good. There are many kinds of recycling. Some people recycle and some do not. Recycling has a long history. Thank you."
SLIDE = "A slide has 90 words in small type. The speaker turns to the screen and reads each line aloud while the audience reads along."
TALK = "Good morning. In the next five minutes I will give you one idea: a ten-minute walk after lunch can change your afternoon. I have three reasons. First, it lifts your energy. Second, it clears your head. Third, it costs nothing."

LESSONS = [
    ("ps-i-goal", "craft", "Goal, audience, one message", "PS-I-01",
     "Before you write a word, answer three questions. Who is listening? What do I want them to know, feel or do? What is the one message they should remember tomorrow? If you cannot say it in one sentence, the talk is not ready. Test it: “After my talk, the audience will…”",
     [
         C("Which question helps you plan a talk?", "Who is listening?", "How long is my hair?", "Is the room red?", "What is on TV?"),
         C("What is a “main message”?", "The one idea you want remembered", "Every fact you know", "The title of the room", "The name of the host"),
         C("Which sentence states a clear goal?", "After my talk, the audience will start walking after lunch.", "I will talk about walking and many other things.", "Walking exists.", "I like talks."),
         C("A talk has five unrelated ideas. What is the likely result?", "The audience remembers little.", "The audience remembers everything.", "The talk is shorter.", "The talk is perfect."),
         READ(DRAFT, "What is the main weakness of this draft?", "It has no clear main message.", "It is too exciting.", "It has too many numbers.", "It is too formal."),
         M("Match each question with what it clarifies.", [["Who is listening?", "the audience"], ["What should they do?", "the goal"], ["What must they remember?", "the main message"]]),
         TF("True or false: A talk is ready when you cannot say its message in one sentence.", "False"),
         TF("True or false: Knowing your audience helps you choose examples.", "True"),
         F("Type the missing word: Decide your one main ___ first.", "message"),
         W("Build the sentence.", "After my talk, they will try it.", "never", "tried"),
         LISTEN("My talk is for new students. I want them to feel welcome and to visit the library this week. If they remember one thing, it should be: the library is free and open late.", "What is the main message?", "The library is free and open late", "The talk is long", "Students are new", "The week is busy"),
         O("Put the planning steps in order.", ["Think about the audience", "Decide the goal", "Write the one-sentence message"]),
         YOUR("Pick a topic you know well. Write who is listening and one sentence that starts: “After my talk, the audience will…”"),
     ]),
    ("ps-i-three", "craft", "The rule of three", "PS-I-02",
     "Listeners remember about three points. Three is enough to feel complete and short enough to recall. Tell them the plan at the start: “I have three reasons.” Number the points as you go, and finish with a one-line recap. If you have six ideas, group them into three or cut the weakest.",
     [
         READ(TALK, "How many reasons does the speaker promise?", "Three", "Two", "Five", "One"),
         READ(TALK, "Which words help the listener follow the order?", "First, second, third", "Good morning", "Next five minutes", "Costs nothing"),
         C("Why is three a useful number of points?", "It is complete but easy to remember.", "It is lucky.", "It is the law.", "It is the longest possible."),
         C("You have six ideas for a five-minute talk. What should you do?", "Group them or cut the weakest", "Read all six quickly", "Add four more", "Stop the talk"),
         C("What belongs at the end?", "A one-line recap", "A new topic", "A long list of thanks", "A joke about the clock"),
         M("Match each part with its job.", [["Preview", "tells the plan"], ["Numbered points", "help listeners follow"], ["Recap", "helps them remember"]]),
         O("Put the talk in order.", ["Tell the plan: I have three reasons", "Give the three reasons in order", "End with a one-line recap"]),
         TF("True or false: Telling the plan at the start helps listeners follow.", "True"),
         F("Type the missing word: Listeners remember about ___ points.", "three"),
         W("Build the sentence.", "I have three reasons for you.", "never", "four"),
         LISTEN("To sum up: walking lifts your energy, clears your head and costs nothing. That is why I walk after lunch.", "What is the speaker doing?", "Giving a recap", "Starting the talk", "Asking a question", "Changing the topic"),
         LISTEN("To sum up: walking lifts your energy, clears your head and costs nothing. That is why I walk after lunch.", "How many benefits does the recap list?", "Three", "Two", "Four", "One"),
         YOUR("Write the preview sentence and the three headings for a talk called “Why I read every day.”"),
     ]),
    ("ps-i-story", "craft", "Stories and examples", "PS-I-03",
     "A fact informs; a story helps people feel. A short story has a person, a problem and a change, and it ends with a point: “That is why I now…” Keep it under a minute and cut details that do not help. Turn big numbers into something you can picture: “Ten thousand steps is about a walk from here to the river and back.”",
     [
         C("What does a short story need?", "A person, a problem and a change", "A list of numbers", "A long introduction", "Three jokes"),
         C("Why add a point at the end of a story?", "So the audience knows why you told it", "To make it longer", "To end the talk", "To hide the story"),
         C("How long should a story in a short talk be?", "Under a minute", "Ten minutes", "As long as possible", "One word"),
         C("Which sentence makes a number easier to picture?", "Ten thousand steps is about a walk to the river and back.", "Ten thousand is a number.", "Steps are measured.", "Numbers are everywhere."),
         C("What should you do with details that do not help?", "Cut them", "Add more", "Read them slowly", "Explain them twice"),
         M("Match each part with its example.", [["Person", "my neighbor Rosa"], ["Problem", "she could not sleep"], ["Change", "she started walking after dinner"]]),
         O("Put the story in order.", ["Introduce a person", "Show the problem", "Show the change and the point"]),
         TF("True or false: Every detail in a story must stay.", "False"),
         F("Type the missing word: End the story with a ___.", "point"),
         W("Build the sentence.", "That is why I now walk daily.", "never", "walks"),
         LISTEN("My neighbor Rosa slept badly for a year. Then she started walking after dinner. Within a month she slept through the night. That is why I now walk after dinner too.", "What is the speaker's point?", "Walking after dinner helps sleep", "Rosa moved away", "Dinner is late", "Neighbors talk"),
         LISTEN("My neighbor Rosa slept badly for a year. Then she started walking after dinner. Within a month she slept through the night. That is why I now walk after dinner too.", "What changed for Rosa?", "She started walking after dinner", "She changed jobs", "She bought a bed", "She moved house"),
         YOUR("Write a three-sentence story with a person, a problem and a change. Add one sentence that gives the point."),
     ]),
    ("ps-i-spoken", "craft", "Write for the ear", "PS-I-04",
     "Spoken language is different from written language. Use short sentences and common words. Contractions such as “it's” and “we're” sound natural. Repeat the key phrase so it sticks. Say numbers simply: “about two thirds” is easier to hear than “66.7 percent.” Read your script aloud and mark every place where you run out of breath.",
     [
         C("Which sentence is better for the ear?", "We lost about two thirds of our sales.", "Sales declined by approximately 66.7 percent.", "A reduction of the sales occurred.", "Sales exhibited a decline."),
         C("Why use short sentences when speaking?", "Listeners cannot re-read.", "They look neat.", "They save paper.", "They are always louder."),
         C("Which word sounds natural in speech?", "we're", "we are not able to", "henceforth", "notwithstanding"),
         C("Why repeat a key phrase?", "It helps people remember it.", "It fills time.", "It confuses people.", "It makes the talk formal."),
         C("How can you find places where a sentence is too long?", "Read the script aloud", "Print it in color", "Read it silently", "Ask the clock"),
         M("Match each written style with its spoken version.", [["Approximately 66.7 percent", "about two thirds"], ["We are unable to proceed", "we can't go on"], ["Subsequently", "then"]]),
         TF("True or false: Contractions are fine in a spoken talk.", "True"),
         TF("True or false: A long, complex sentence is easiest to follow when heard.", "False"),
         F("Type the missing word: Read your script ___ to find long sentences.", "aloud"),
         W("Build the sentence.", "We're ready to begin.", "never", "are"),
         LISTEN("Think about it. About two thirds of us walk to work. Two thirds. That means most of this room walks.", "Which phrase does the speaker repeat?", "Two thirds", "Walk to work", "Think about it", "This room"),
         O("Put the editing steps in order.", ["Write the first draft", "Read it aloud", "Shorten the long sentences"]),
         YOUR("Rewrite this for speaking: “Approximately seventy-five percent of respondents indicated satisfaction.”"),
     ]),
    ("ps-i-eyes", "present", "Eyes, hands and movement", "PS-I-05",
     "Look at people, not at the floor or the slide. Hold one thought and look at one person until it ends, then move to someone else. This feels like talking to individuals, not to a crowd. Keep your hands open and use gestures that match your words. Move on purpose: step forward for a key point, then stay still. Nervous pacing distracts.",
     [
         C("How should you use eye contact?", "Look at one person for one thought, then move on", "Stare at the back wall", "Look at the floor", "Look at the slide"),
         C("Why is this helpful?", "It feels like talking to individuals.", "It saves time.", "It hides notes.", "It makes the room dark."),
         C("Which gesture is helpful?", "An open hand that matches the words", "Hands hidden in pockets throughout", "Pointing at people", "Waving randomly"),
         C("When is a step forward useful?", "For a key point", "Every few seconds", "When you forget the words", "At the end of every sentence"),
         C("What is a problem with nervous pacing?", "It distracts the audience.", "It helps memory.", "It wakes people up.", "It is always allowed."),
         M("Match each habit with its effect.", [["Looking at one person per thought", "connects with the room"], ["Pacing quickly", "distracts the listeners"], ["Open hands", "look friendly and clear"]]),
         TF("True or false: Reading from the slide shows confidence.", "False"),
         TF("True or false: Moving on purpose can mark an important point.", "True"),
         F("Type the missing word: Look at one person until the thought ___.", "ends"),
         W("Build the sentence.", "I look at one person.", "never", "looks"),
         LISTEN("When I make a key point, I take one step forward. Then I stay still while I say it, and I look at someone near the front.", "When does the speaker move?", "For a key point", "After every word", "Never", "At the end"),
         O("Put the habit in order.", ["Finish a thought", "Look at a new person", "Start the next thought"]),
         YOUR("Describe in two sentences how you will use your eyes and hands in a one-minute talk."),
     ]),
    ("ps-i-slides", "present", "Slides that help", "PS-I-06",
     "Slides should support you, not replace you. Use one idea per slide, large type, and as few words as you can. A picture or a single number is often stronger than a list. Do not read the slide aloud; the audience reads faster than you speak. Face the audience, not the screen, and give them a moment to look before you speak.",
     [
         READ(SLIDE, "What is wrong with this presentation?", "The slide has too many words and the speaker reads it.", "The slide is too colorful.", "The screen is too big.", "The speaker is too quiet."),
         C("How many ideas should one slide hold?", "One", "Ten", "As many as fit", "Twenty"),
         C("Which slide is stronger?", "A single large number with a short label", "A full paragraph in small type", "Ten bullet points", "A copy of your notes"),
         C("Why not read the slide aloud?", "People read faster than you speak.", "It is illegal.", "It wastes light.", "Slides cannot be read."),
         C("Where should you look while speaking?", "At the audience", "At the screen", "At your shoes", "At the ceiling"),
         M("Match each slide habit with its result.", [["One idea per slide", "easy to follow"], ["Small type", "hard to read"], ["Reading it aloud", "boring"]]),
         TF("True or false: A picture can be stronger than a list of words.", "True"),
         TF("True or false: More words on a slide make a talk clearer.", "False"),
         F("Type the missing word: Use one ___ per slide.", "idea"),
         W("Build the sentence.", "Let them look first.", "never", "looks"),
         LISTEN("Here is the number that matters: forty percent. Let it sit for a moment. Now let me tell you why it surprised us.", "What does the speaker do after showing the number?", "Pauses so the audience can look", "Reads the whole slide", "Turns off the screen", "Leaves the room"),
         O("Put the steps in order.", ["Show the slide", "Pause so people can look", "Explain it in your own words"]),
         YOUR("Describe one slide you could use in a talk about your city: what is on it, and what you say."),
     ]),
    ("ps-i-questions", "present", "Answer questions", "PS-I-07",
     "Questions are a chance to show you listened. Listen to the whole question. Repeat or rephrase it so everyone hears: “So you are asking about cost.” Answer in two or three sentences. If you do not know, say so: “I don't know yet, but I'll find out and send it to you.” Do not guess or argue. Thank the person and move on.",
     [
         C("What should you do first when someone asks a question?", "Listen to the whole question", "Answer at once", "Look at the clock", "Say you are tired"),
         C("Why repeat the question?", "So everyone hears it", "To waste time", "To disagree", "To hide the answer"),
         C("Which reply is honest when you do not know?", "I don't know yet, but I'll find out.", "Everyone knows that.", "That is a silly question.", "Maybe, maybe not, who cares."),
         C("How long should an answer be?", "Two or three sentences", "Ten minutes", "One word", "A whole new talk"),
         C("Which reply handles a hostile question calmly?", "Thank you. Here is what the data show.", "You are wrong!", "I will not answer you.", "Be quiet."),
         M("Match each step with its example.", [["Repeat", "So you are asking about cost."], ["Answer", "It costs 50 dollars a month."], ["Close", "Thank you. Next question?"]]),
         O("Put the steps in order.", ["Listen to the whole question", "Repeat it for the room", "Answer in two or three sentences"]),
         TF("True or false: You should guess when you do not know an answer.", "False"),
         F("Type the missing word: Say so if you do not ___.", "know"),
         W("Build the sentence.", "I will find out for you.", "never", "found"),
         LISTEN("So you are asking whether the plan costs more than last year. The answer is about ten percent more. I can send you the full table after the talk.", "What does the speaker do first?", "Repeats the question", "Argues", "Ignores it", "Ends the talk"),
         LISTEN("So you are asking whether the plan costs more than last year. The answer is about ten percent more. I can send you the full table after the talk.", "What does the speaker offer?", "To send the full table", "To cancel the plan", "To lower the cost", "To leave"),
         YOUR("Write how you would answer a question you cannot answer yet, in two sentences."),
     ]),
    ("ps-i-recover", "present", "Recover from mistakes", "PS-I-08",
     "Everyone makes mistakes. The audience notices less than you think. If you lose your place, pause and breathe. Look at your notes. Say a bridge sentence such as “Let me say that again.” If you say a wrong fact, correct it calmly: “Sorry, it was 1,500, not 15,000.” Do not apologize for a long time. Keep going: confidence is how you recover, not how you avoid mistakes.",
     [
         C("What is the first step if you lose your place?", "Pause and breathe", "Run away", "Speak faster", "Apologize for a minute"),
         C("Which sentence is a good bridge?", "Let me say that again.", "I am so bad at this.", "Everything is wrong.", "Never mind."),
         C("How should you correct a wrong fact?", "Calmly, in one sentence", "Ignore it", "Argue with it", "Apologize five times"),
         C("What is a good attitude toward mistakes?", "Recover and keep going", "Stop the talk", "Hide", "Blame the room"),
         C("How much do audiences usually notice small mistakes?", "Less than the speaker thinks", "Everything", "Nothing at all ever", "Only the loud ones"),
         M("Match each problem with a fix.", [["Lost your place", "pause and check notes"], ["Wrong number", "correct it calmly"], ["Dry mouth", "take a sip of water"]]),
         O("Put the recovery in order.", ["Pause and breathe", "Check your notes", "Say a bridge sentence and continue"]),
         TF("True or false: A long apology helps the audience forget a mistake.", "False"),
         F("Type the missing word: Pause and ___ if you lose your place.", "breathe"),
         W("Build the sentence.", "Sorry, it was fifteen hundred.", "never", "thousands"),
         LISTEN("Sorry, I said 15,000. The correct number is 1,500. Now, where was I? Yes, the second reason.", "What does the speaker do?", "Corrects the number and continues", "Stops the talk", "Argues", "Blames someone"),
         LISTEN("Sorry, I said 15,000. The correct number is 1,500. Now, where was I? Yes, the second reason.", "Which phrase helps the speaker find the place?", "Now, where was I?", "Sorry", "The correct number", "Yes"),
         YOUR("Write two bridge sentences you could say if you forget your next point."),
     ]),
]

if __name__ == "__main__":
    add_stage("public-speaker", STAGE, LESSONS, "Intermediate", SOURCES)
