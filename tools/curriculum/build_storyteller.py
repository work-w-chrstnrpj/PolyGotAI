#!/usr/bin/env python3
"""Build the Storytelling track (Foundation stage, 2 units x 4 lessons): Resources/Tracks/track-storyteller.json.

All stories, lines and tips are original wording. Ideas (small true moments, story arc and stakes, specific detail,
hook and landing, voice and pause, listener awareness, trimming) come from common oral-storytelling teaching.
Run from the project root: python3 tools/curriculum/build_storyteller.py
"""
from track_lib import C, TF, READ, LISTEN, W, F, O, M, YOUR, build_manifest, write_track

SOURCES = [
    "Aesop's fables and the Brothers Grimm (public domain): classic story shapes, retold in original wording",
    "Common oral-storytelling teaching: story arc, stakes, hook and landing (concepts only)",
]

STAGES = [{"id": "foundation", "title": "Foundation", "units": [
    {"id": "shape", "title": "Shape the story"},
    {"id": "tell", "title": "Tell it aloud"},
]}]

DANA = "Last June, Dana missed the last train home. She had no money for a taxi and no phone battery. A kind guard let her charge her phone, and she called her sister. Dana now always carries a small charger."
PABLO = "Pablo wanted to win the cooking contest. The night before, his oven broke. He could not afford a new one, so he asked his neighbor, who had never helped him before. She baked his cake and, to his surprise, became a close friend."
ROSA = "The kitchen was small. My grandmother, Rosa, stood by the stove in her yellow apron, stirring soup that smelled of garlic. The old radio on the shelf crackled with a song from her village."
ELENA = "At the start, Elena was afraid of the dark. At the end, she turned off the light and walked to bed, humming. The last line of her story was: “The dark was just a room I had not met yet.” She smiled."
KOFI = "Kofi told his story in a very flat voice, at the same speed all the way through. When he reached the exciting part, he did not slow down or pause. The audience looked at their phones."
HANA = "Hana described her coach in her story. She lowered her voice, crossed her arms, and said, “Again.” Then she moved on to the next scene."
OMAR = "While Omar told his story, a few people frowned and looked at each other. He noticed, stopped, and explained who his uncle was. Then the frowns disappeared and he continued."
BEN = "Ben's story was five minutes long. He told how he found a wallet, but spent three minutes describing his trip to the city. After he cut the trip, the story took two minutes, and the audience loved it."

LESSONS = [
    ("st-moment", "shape", "Pick one small moment", "ST-F-01",
     "A good story is often one small moment, not a whole life. Choose a moment when something changed: a surprise, a mistake, a first time. Ask: What happened? Why did it matter? What did I learn or feel? A true, small moment beats a long list of events.",
     [
         C("Which is the best choice for a two-minute story?", "The day I got lost on my first bus ride alone", "My whole life from age one", "Everything I did last year", "All my school years"),
         C("What makes a moment worth a story?", "Something changed", "Nothing happened", "It was very long", "It was the same as every day"),
         C("Which question helps you find the meaning?", "Why did this moment matter?", "What color was the bus?", "Who sat behind me?", "What time was lunch?"),
         C("Which is a small moment?", "The first time I cooked dinner for my family", "My whole career", "A decade of work", "Every Sunday for ten years"),
         C("Which is too big for one story?", "My entire childhood", "The day I lost my keys", "My first bike ride", "A surprise phone call"),
         M("Match each prompt with an example moment.", [["A first time", "I rode a train alone"], ["A mistake", "I sent the email to the wrong person"], ["A surprise", "A stranger returned my wallet"]]),
         O("Put the steps in order.", ["Pick one small moment", "Ask why it mattered", "Decide how it starts and ends"]),
         TF("True or false: A story can be about one small moment.", "True"),
         TF("True or false: A two-minute story should cover your whole life.", "False"),
         F("Type the missing word: Choose a moment when something ___.", "changed"),
         W("Build the sentence.", "Pick one small moment.", "never", "large"),
         READ(DANA, "What is the moment that changed things?", "Dana missed the last train home", "Dana bought a charger", "Dana has a sister", "Dana likes trains"),
         LISTEN("I want to tell you about the day I forgot my speech. I stood up, looked at the room, and my mind was empty. So I told them the truth.", "What is the story about?", "A moment when the speaker forgot a speech", "A long career", "A holiday", "A cooking class"),
         YOUR("List three small moments from your life that could be stories. Choose one and say why it mattered."),
     ]),
    ("st-arc", "shape", "Want, obstacle, change", "ST-F-02",
     "Most stories have an arc: a person wants something, something gets in the way, they try, and something changes. Add stakes: what could be lost? Without stakes, there is no reason to care. Tell what happens in order, and make each step cause the next.",
     [
         C("What is an arc?", "A change from the start to the end", "A list of names", "A picture", "A joke"),
         C("What are stakes?", "What the character could win or lose", "The ticket price", "The setting", "The title"),
         C("Which sentence has the higher stakes?", "If she misses the bus, she will lose her job interview.", "If she misses the bus, she will wait.", "She likes buses.", "Buses run all day."),
         C("Which sentence shows an obstacle?", "The bridge was closed, so he had to find another way.", "He walked.", "He was tall.", "The sun came out."),
         C("Which sentence links events by cause?", "Because the bridge was closed, he took the long road and met his old teacher.", "He walked. He ate. He slept.", "Then. Then. Then.", "A bridge. A road. A teacher."),
         O("Put the arc in order.", ["She wants to catch the last bus", "The bus leaves early", "She runs across the town", "She catches it and learns to leave earlier"]),
         M("Match each arc part with its question.", [["Want", "What does the person want?"], ["Obstacle", "What gets in the way?"], ["Stakes", "What could be lost?"], ["Change", "What is different at the end?"]]),
         TF("True or false: A story needs a change.", "True"),
         TF("True or false: Stakes make listeners care.", "True"),
         F("Type the missing word: Stakes show what could be ___.", "lost"),
         W("Build the sentence.", "Make each step cause the next.", "never", "skip"),
         READ(PABLO, "What is the obstacle?", "His oven broke", "He won the contest", "He had a neighbor", "He liked cooking"),
         LISTEN("Maya wanted to speak at the town meeting, but her voice shook. If she stayed silent, the park would close. She took a breath and began.", "What are the stakes?", "The park could close", "Maya's voice shakes", "The meeting is long", "The town is small"),
         YOUR("Tell a story in four sentences: want, obstacle, action, change."),
     ]),
    ("st-detail", "shape", "Details that make it real", "ST-F-03",
     "Details make a story real: a name, a place, a sound, a number. “My uncle's green van with the broken door” is better than “a vehicle.” But keep only the details that help the story, and let one or two strong details do the work.",
     [
         C("Which is more vivid?", "My uncle's green van with the broken door", "A vehicle", "A thing", "Some transport"),
         C("Which detail gives a number?", "It took us forty minutes in the rain.", "It took a while.", "It was long.", "It was slow."),
         C("Which detail names a place?", "We waited outside the bakery on Cedar Street.", "We waited somewhere.", "We waited.", "We were in a place."),
         C("Which detail should you cut?", "The color of the tablecloth, if it does not matter to the story", "The sound of the door slamming right before the crash", "The name of the person who helped", "The broken umbrella that saved her"),
         C("How many strong details are usually enough for a moment?", "One or two", "As many as possible", "None", "Twenty"),
         M("Match each plain phrase with a more specific one.", [["a car", "a rusty blue taxi"], ["a sound", "a loud, sudden bang"], ["a person", "my grandmother, Rosa"]]),
         O("Put the steps in order.", ["Write the plain sentence", "Find the vague words", "Replace them with specific details"]),
         TF("True or false: Specific details help listeners picture the story.", "True"),
         TF("True or false: Every detail should be included.", "False"),
         F("Type the missing word: Replace vague words with ___ details.", "specific"),
         W("Build the sentence.", "Use details that help the story.", "never", "extra"),
         READ(ROSA, "Which detail appeals to the sense of smell?", "The soup smelled of garlic.", "The apron was yellow.", "The radio was old.", "The kitchen was small."),
         LISTEN("We waited for forty minutes outside the bakery on Cedar Street. It was raining, and my brother's shoes were soaked through.", "How long did they wait?", "Forty minutes", "Four hours", "One hour", "Ten minutes"),
         YOUR("Take this plain sentence: “We went to a place and ate something.” Rewrite it with three specific details."),
     ]),
    ("st-hook", "shape", "Hook and landing", "ST-F-04",
     "Open with a hook: a surprising line, a strong image or a question. Then land the ending: return to your opening image or finish with the change. Don't end with “and that's my story.” Pause, say your last line, and stop.",
     [
         C("Which is the best hook?", "The first time I saw the sea, I was thirty-two and terrified.", "Hello, I want to tell you a story.", "Um, so, this is about the sea.", "I will now begin."),
         C("Which ending “lands”?", "Now, whenever it rains, I smile and take the long way home.", "So, that's it.", "Yeah, that's all.", "Thank you for listening to my entire story again."),
         C("What can you do with your last line?", "Return to the opening image", "Add a new unrelated story", "Apologize", "Ask for the time"),
         C("Which opening uses a question as a hook?", "Have you ever sat in a stranger's car and trusted them?", "I am here to talk.", "Today is Monday.", "Let me start now."),
         C("What should you do after your last line?", "Pause, then stop", "Keep talking to fill the silence", "Say sorry", "Repeat the first line"),
         O("Put the story parts in order.", ["A strong hook", "The middle of the story", "A landing that returns to the opening"]),
         M("Match each tool with its job.", [["Hook", "grabs attention at the start"], ["Landing", "finishes with the change"], ["Pause", "lets the last line sink in"]]),
         TF("True or false: A hook should come in the first sentence.", "True"),
         TF("True or false: You should end by saying “and that's my story.”", "False"),
         F("Type the missing word: A ___ grabs attention in the first line.", "hook"),
         W("Build the sentence.", "Return to the opening image.", "never", "ignore"),
         READ(ELENA, "How does the ending land?", "It shows how Elena changed", "It repeats the first sentence only", "It lists facts", "It introduces a new character"),
         LISTEN("Have you ever been so afraid that you laughed? That is what happened to me on the highest bridge in town.", "What kind of hook is this?", "A question", "A joke only", "An apology", "A list"),
         YOUR("Write a hook and a landing line for a one-minute story about a time you were afraid."),
     ]),
    ("st-voice", "tell", "Voice, pace and pauses", "ST-F-05",
     "In storytelling your voice carries the story. Slow down for important moments, speed up a little for action, lower your voice for secrets, and pause before a surprise. Silence is a tool. Practice by telling the story aloud, not by reading it silently.",
     [
         C("How do you build suspense?", "Slow down and pause before the surprise", "Speak faster and faster with no pause", "Say it in a flat voice", "Skip the pause"),
         C("What should you do for an action scene?", "Speed up a little", "Whisper", "Pause between every word", "Stay silent"),
         C("How can you share a secret in a story?", "Lower your voice", "Shout", "Walk away", "Laugh"),
         C("What does a pause do?", "Gives the audience time to imagine", "Wastes time", "Hides mistakes", "Ends the story"),
         C("Which practice method helps most?", "Telling the story aloud several times", "Reading it silently once", "Memorizing every word", "Never practicing"),
         M("Match each moment with a voice choice.", [["Action scene", "speed up a little"], ["Secret", "lower the voice"], ["Surprise", "pause before it"]]),
         O("Put the steps in order.", ["Tell the story aloud", "Notice where you rush", "Add pauses and slow down"]),
         TF("True or false: Silence can be part of storytelling.", "True"),
         TF("True or false: You should tell every sentence at the same speed.", "False"),
         F("Type the missing word: Pause before the ___.", "surprise", "twist"),
         W("Build the sentence.", "Slow down before the surprise.", "never", "faster"),
         LISTEN("The door opened slowly. There was nobody there. Then I felt a hand on my shoulder.", "Where would a storyteller pause?", "Before “Then I felt a hand on my shoulder”", "After the word “The”", "Only between “door” and “opened”", "Never"),
         READ(KOFI, "What should Kofi change?", "Use pauses and change his pace", "Tell a shorter joke", "Read faster", "Whisper everything"),
         YOUR("Tell a one-minute story aloud. Mark where you paused and where you sped up."),
     ]),
    ("st-people", "tell", "Bring people to life", "ST-F-06",
     "When you retell what someone said, give them a voice: a different pace, pitch or word. Say, “My mother looked at me and said, ‘You are late again.’” Keep it brief. Use “said,” and show the person with a gesture or a face, not a long imitation.",
     [
         C("Which is a clear way to share what someone said?", "My mother looked at me and said, “You are late again.”", "Then something was said.", "Someone talked.", "Words happened."),
         C("How should you show a different person speaking?", "Change your pace, pitch or face a little", "Use an insulting accent", "Read it from a list", "Whisper only"),
         C("Which should you avoid?", "Making fun of someone's accent", "Using a small gesture", "Changing your tone", "Pausing before the quote"),
         C("How long should an imitation be?", "Brief, just enough to show the person", "As long as possible", "Longer than the story", "There is no limit"),
         C("Which tag is the plainest?", "said", "hissed", "bellowed", "declared"),
         M("Match each tool with its effect.", [["A small gesture", "shows the person's mood"], ["A change of pace", "separates the speakers"], ["A short quote", "keeps the story moving"]]),
         O("Put the steps in order.", ["Choose one important line", "Decide how the person sounds", "Say it briefly and move on"]),
         TF("True or false: Short quotes keep a story moving.", "True"),
         TF("True or false: Imitating a person's accent to mock them is fine.", "False"),
         F("Type the missing word: Use a ___ gesture to show the person.", "small"),
         W("Build the sentence.", "My mother looked at me and said.", "never", "shouted"),
         READ(HANA, "How does Hana show the coach?", "With a lower voice, crossed arms and one short word", "With a long speech", "By not mentioning the coach", "By laughing at the coach"),
         LISTEN("My grandfather looked at the sky and said, quietly, rain by noon. He was never wrong.", "How does the speaker show the grandfather?", "With a quiet quote and a short fact", "With a long speech", "By shouting", "With a joke"),
         YOUR("Retell a short line someone once said to you. Write how you would say it aloud and what gesture you would use."),
     ]),
    ("st-listeners", "tell", "Read your listeners", "ST-F-07",
     "A story is shared with listeners. Look at them, watch their faces and adjust: if they look lost, slow down; if they laugh, wait for the laugh to finish; if they lean in, keep going. You can ask a short question. Start where they are, not where you are.",
     [
         C("What should you do if listeners look lost?", "Slow down and add a detail", "Speed up", "Stop looking at them", "Read from the page"),
         C("What should you do when listeners laugh?", "Wait until the laugh finishes", "Talk over it", "Skip the next part", "Leave"),
         C("Which is a good way to involve listeners?", "Ask a short question", "Ignore everyone", "Look only at your notes", "Whisper to yourself"),
         C("Where should your eyes go?", "To different listeners", "To the floor", "To the ceiling", "To your phone"),
         C("What does “start where they are” mean?", "Begin with something the listeners know or feel", "Begin with a long introduction about you", "Begin with the ending", "Begin with unrelated facts"),
         M("Match each listener signal with your response.", [["Confused faces", "slow down and clarify"], ["Laughter", "pause and wait"], ["Leaning in", "keep the energy"]]),
         O("Put the steps in order.", ["Look at the listeners", "Notice their reactions", "Adjust your pace or detail"]),
         TF("True or false: A good storyteller watches the listeners.", "True"),
         TF("True or false: You must ignore laughter.", "False"),
         F("Type the missing word: Look at different ___.", "listeners", "people"),
         W("Build the sentence.", "Watch the faces in the room.", "never", "floor"),
         READ(OMAR, "What did Omar do well?", "He noticed the confusion and clarified", "He ignored the audience", "He told it faster", "He changed the story"),
         LISTEN("Does anyone here remember their first day at a new school? I do. I stood at the gate for ten minutes.", "How does the speaker involve the listeners?", "By asking a short question", "By telling a joke", "By reading a list", "By staying silent"),
         YOUR("Write two questions you could ask listeners at the start of a story about your first day somewhere new."),
     ]),
    ("st-trim", "tell", "Trim and practice", "ST-F-08",
     "Most first drafts are too long. Cut what does not move the story: repeated details, side trips, long explanations. Aim for two minutes, about 250 to 300 words. Tell it aloud, time it and trim again. Keep the hook, the turning point and the landing.",
     [
         C("About how many words make a two-minute story?", "250 to 300", "50", "1,000", "3,000"),
         C("What should you cut first?", "Details that do not move the story", "The hook", "The turning point", "The landing"),
         C("What must stay in the story?", "The hook, the turning point and the landing", "Every side story", "Every date", "All the names"),
         C("How do you check the length?", "Tell it aloud and time it", "Count the letters", "Guess", "Ask a stranger"),
         C("Which is a side trip?", "A long explanation of how your uncle met his wife, in a story about a lost phone", "The moment you lost the phone", "The ending", "The opening hook"),
         O("Put the steps in order.", ["Write or plan the story", "Tell it aloud and time it", "Cut what does not move the story", "Practice again"]),
         M("Match each part with its job.", [["Hook", "wakes the listener"], ["Turning point", "the moment of change"], ["Landing", "the final line"]]),
         TF("True or false: Most first drafts are too long.", "True"),
         TF("True or false: You should cut the turning point.", "False"),
         F("Type the missing word: Time your story ___.", "aloud"),
         W("Build the sentence.", "Cut what does not help.", "never", "add"),
         READ(BEN, "What did Ben cut?", "A long side trip", "The hook", "The ending", "The wallet"),
         LISTEN("I found a wallet on the bus. I opened it and saw a photo of a child. I knew I had to find the owner.", "Which part is the turning point?", "Seeing the photo and deciding to find the owner", "Taking the bus", "Opening the door", "Buying a ticket"),
         YOUR("Tell your story aloud, time it and cut it to two minutes. Write what you cut."),
     ]),
]

if __name__ == "__main__":
    manifest = build_manifest("storyteller", "storyteller", STAGES, LESSONS, "Foundation", SOURCES)
    write_track("storyteller", manifest)
