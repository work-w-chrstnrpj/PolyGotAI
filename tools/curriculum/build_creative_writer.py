#!/usr/bin/env python3
"""Build the Creative Writing (fiction) track (Foundation stage, 2 units x 4 lessons): Resources/Tracks/track-creative-writer.json.

All passages, lines and tips are original wording. Craft ideas (character want and flaw, mood, sensory detail,
show versus tell, dialogue, point of view, plot shape) are standard teaching concepts, credited for ideas only.
Run from the project root: python3 tools/curriculum/build_creative_writer.py
"""
from track_lib import C, TF, READ, LISTEN, W, F, O, M, YOUR, build_manifest, write_track

SOURCES = [
    "Freytag, Technique of the Drama (public domain): the shape of a plot (concept only)",
    "Aristotle, Poetics (public domain translations), and common creative-writing craft teaching (concepts only; all examples original)",
]

STAGES = [{"id": "foundation", "title": "Foundation", "units": [
    {"id": "people-place", "title": "People and places"},
    {"id": "scenes", "title": "Scenes and plot"},
]}]

OMAR = "Omar always carried a small notebook. He wanted to be a famous cartoonist, but he hid every drawing because he feared people would laugh. When his teacher asked to see his work, his hands shook."
LIBRARY = "The old library smelled of dust and rain. A single lamp hummed in the corner, and the clock above the door had stopped at midnight."
BAKERY = "Mara stepped into the bakery. The air smelled of warm butter and sugar. A bell rang above the door, and the tiled floor felt cool under her feet."
JIN = "Jin looked at the empty chair across the table. He folded the napkin into a small square, then into an even smaller one. Finally, he stood up and left before the food arrived."
DAD = "“Where were you?” Dad asked. “Out.” Lena kept her eyes on her shoes. “Out where?” “Just out.” He sighed."
FIRST = "I heard footsteps behind me. My heart pounded, but I did not turn around. I counted my steps and kept walking."
THIRD = "Sam stared at the closed door. He wondered if he should knock. His hand felt heavy, and he could not decide."
PHONE = "The phone rang at three in the morning. Nobody called at three in the morning. Mia sat up and stared at the name on the screen: her own."

LESSONS = [
    ("cw-character", "people-place", "Create a character", "CW-F-01",
     "A fiction character feels real when we know what they want, what stops them, and one small detail only they have. Give them a want (to win a race), a flaw (too proud to ask for help) and a habit or an object (always twists a ring). Then show them making a choice.",
     [
         C("Which sentence tells us what a character wants?", "Mina wants to win the school race before her brother does.", "Mina has brown hair.", "Mina lives in a house.", "Mina is a girl."),
         C("Which is a flaw?", "He is too proud to ask for help.", "He is tall.", "He has a red coat.", "He lives by the sea."),
         C("Which detail makes a character memorable?", "She always twists a silver ring when she lies.", "She is nice.", "She is a person.", "She walks."),
         C("Why do characters need a want?", "A want gives the story a direction", "It makes the story shorter", "It removes conflict", "It replaces the plot"),
         C("Which character has a clear conflict?", "Ravi wants to join the band but is afraid to play in front of people.", "Ravi plays guitar.", "Ravi is in the band.", "Ravi likes music."),
         READ(OMAR, "What does Omar want?", "To be a famous cartoonist", "To become a teacher", "To hide his notebook forever", "To win a race"),
         READ(OMAR, "What is Omar's fear?", "That people will laugh at his drawings", "That he will lose his notebook", "That his teacher will move away", "That he will win"),
         M("Match each part of a character with an example.", [["Want", "to win the race"], ["Flaw", "too proud to ask for help"], ["Detail", "always twists a ring"]]),
         O("Put the steps in order.", ["Decide what the character wants", "Add something that stops them", "Add one memorable detail"]),
         TF("True or false: A character with no want makes a story feel aimless.", "True"),
         TF("True or false: A flaw can make a character more believable.", "True"),
         F("Type the missing word: A character's ___ is what they are trying to get.", "want", "goal"),
         LISTEN("Lena wanted to cross the river before dark. She was afraid of water, but her sister was waiting on the other side.", "What does Lena want?", "To cross the river before dark", "To stay home", "To swim for fun", "To find her bag"),
         YOUR("Create a character in three sentences: what they want, what stops them, and one small detail."),
     ]),
    ("cw-setting", "people-place", "Setting and mood", "CW-F-02",
     "Setting is where and when a scene happens. It also sets the mood: a quiet lake feels calm, a crowded station feels tense. Choose two or three details that create the feeling you want, instead of describing everything.",
     [
         C("Which setting detail creates a tense mood?", "The station was packed, and every clock ticked louder than the last.", "The lake was calm and still.", "The garden smelled of roses.", "The room was quiet and warm."),
         C("Which detail creates a calm mood?", "The lake lay still under the soft evening light.", "The alarm rang again and again.", "Crowds pushed through the gate.", "Thunder shook the windows."),
         C("What does setting include?", "Where and when a scene happens", "Only the weather", "Only the characters' names", "Only the title"),
         C("How many details are best for a setting?", "Two or three strong ones", "Every detail you can think of", "None", "Only the weather"),
         C("Which opening shows a lonely mood?", "The streetlights flickered, and the empty bus stop stayed silent.", "A crowd cheered happily.", "Friends laughed over dinner.", "A band played loudly."),
         READ(LIBRARY, "What mood does this setting create?", "Quiet and mysterious", "Loud and joyful", "Hot and busy", "Bright and silly"),
         READ(LIBRARY, "Which detail suggests that time has stopped?", "The clock had stopped at midnight.", "The lamp hummed.", "The library smelled of dust.", "It was raining."),
         M("Match each setting with a mood.", [["A crowded station", "tense"], ["A still lake at dusk", "calm"], ["An empty street at night", "lonely"]]),
         TF("True or false: A setting can create a mood.", "True"),
         TF("True or false: You must describe everything in a place.", "False"),
         F("Type the missing word: Setting means where and ___ a scene happens.", "when"),
         O("Put the steps in order.", ["Choose the mood you want", "Pick two or three details that create it", "Write the scene"]),
         W("Build the sentence.", "The room was quiet and cold.", "never", "loud"),
         LISTEN("The market was loud and crowded. Vendors shouted prices, and the smell of fried bread filled the air.", "What mood does this setting create?", "Busy and lively", "Silent and sad", "Cold and empty", "Dark and scary"),
         YOUR("Describe a place in three sentences so that it feels calm or tense. Use two or three details."),
     ]),
    ("cw-senses", "people-place", "Use the five senses", "CW-F-03",
     "Good description uses all five senses, not only sight: what we see, hear, smell, taste and touch. One precise detail can make a scene alive. “The bread smelled of warm butter” tells more than “The bread was nice.”",
     [
         C("Which sentence uses the sense of smell?", "The kitchen smelled of burnt toast.", "The kitchen was big.", "The kitchen was white.", "The kitchen had a table."),
         C("Which sentence uses the sense of sound?", "The old door creaked on its hinges.", "The door was brown.", "The door had a handle.", "The door was in the hall."),
         C("Which sentence uses touch?", "The blanket felt rough and warm against her cheek.", "The blanket was red.", "The blanket smelled sweet.", "The blanket made no sound."),
         C("Which sentence uses taste?", "The soup tasted sharp and salty.", "The soup was in a bowl.", "The soup looked orange.", "The soup was hot to hold."),
         C("Which sentence is more specific?", "The bread smelled of warm butter.", "The bread was nice.", "The bread was good.", "The bread was fine."),
         C("How many senses can you use in a description?", "Five", "One", "Two", "Seven"),
         M("Match each sense with a detail.", [["Sight", "a red kite in the sky"], ["Sound", "a distant church bell"], ["Smell", "fresh coffee"], ["Touch", "cold, wet grass"]]),
         O("Put the steps in order.", ["Choose the moment", "List what you see, hear, smell, taste and feel", "Pick the two strongest details"]),
         TF("True or false: Good description uses more than the sense of sight.", "True"),
         TF("True or false: “It was nice” is a specific detail.", "False"),
         F("Type the missing word: Taste, touch, sight, smell and ___ are the five senses.", "hearing", "sound"),
         W("Build the sentence.", "The air smelled of rain.", "never", "taste"),
         READ(BAKERY, "Which sense does “A bell rang above the door” use?", "Hearing", "Smell", "Taste", "Touch"),
         LISTEN("The campfire crackled. Smoke stung my eyes, and the marshmallow tasted sweet and burnt.", "Which sense does the word “crackled” use?", "Hearing", "Taste", "Touch", "Smell"),
         YOUR("Write a four-sentence description of a meal or a street. Use at least three different senses."),
     ]),
    ("cw-show-tell", "people-place", "Show, don't tell", "CW-F-04",
     "Telling states a feeling: “He was nervous.” Showing lets the reader see it: “His hands shook as he checked the clock again.” Show the important moments through actions, words and the body. Use telling for small, quick facts.",
     [
         C("Which sentence shows the feeling?", "Her hands shook as she opened the letter.", "She was nervous.", "She felt scared.", "She was worried."),
         C("Which sentence tells instead of shows?", "He was angry.", "He slammed the door so hard the glass rang.", "His jaw tightened, and he said nothing.", "He crushed the note in his fist."),
         C("Which line shows that a character is tired?", "He rubbed his eyes and leaned on the wall to stay upright.", "He was tired.", "He felt very sleepy.", "He wanted rest."),
         C("Which line shows happiness?", "She laughed, grabbed her friend's hands and spun in a circle.", "She was happy.", "She felt joy.", "She was glad."),
         C("When is telling useful?", "For small, quick facts that don't need a scene", "For every emotion", "Never", "Only in dialogue"),
         C("How can you show fear?", "A pounding heart, a dry mouth and quick glances at the door", "The word “scared” repeated", "Describing the weather only", "A long list of names"),
         M("Match each telling sentence with a showing sentence.", [["She was cold.", "Her teeth chattered and she pulled her coat tight."], ["He was bored.", "He tapped his pencil and watched the clock."], ["They were proud.", "They stood tall and grinned at the trophy."]]),
         O("Put the steps in order.", ["Name the feeling for yourself", "Think of what the body does", "Write the action instead of the word"]),
         TF("True or false: Showing uses actions, words and the body.", "True"),
         TF("True or false: You should tell every detail of every scene.", "False"),
         F("Type the missing word: Show, don't ___.", "tell"),
         W("Build the sentence.", "His hands shook as he waited.", "never", "smiled"),
         READ(JIN, "How does the writer show Jin's feeling?", "Through his actions", "By saying he is sad", "By naming the restaurant", "By describing the weather"),
         LISTEN("She pressed her lips together and stared at the floor. The room went silent. She did not say a word.", "Which feeling is shown?", "Upset or uncomfortable", "Excited", "Proud", "Sleepy"),
         YOUR("Take the telling sentence “He was nervous.” Rewrite it as one or two showing sentences."),
     ]),
    ("cw-dialogue", "scenes", "Write dialogue", "CW-F-05",
     "Dialogue should sound like real people: short lines, interruptions, and a different voice for each speaker. Use “said” for most lines, and start a new paragraph for each new speaker. Good dialogue also shows what people want or hide.",
     [
         C("Which line sounds most like real speech?", "“I can't, Dad. Not tonight.”", "“I am unable to comply with your request at this time.”", "“Greetings, father. I shall decline.”", "“It is not possible, honorable father.”"),
         C("Which tag is the plainest and best for most lines?", "said", "exclaimed loudly", "declared dramatically", "announced proudly"),
         C("How do you show a new speaker?", "Start a new paragraph", "Use capital letters", "Use a longer line", "Add a title"),
         C("Which line is more natural between friends?", "“Morning! You're early.”", "“Good morning, my esteemed colleague, how fare you?”", "“Salutations. I observe that you are early.”", "“Greetings, honored friend.”"),
         C("Why do writers keep dialogue lines short?", "Real people speak in short bursts", "Short lines are required by law", "Long lines are impossible", "It saves paper"),
         C("Which line hints that a character is hiding something?", "“I'm fine,” she said, and quickly closed the door.", "“I'm fine,” she said, and smiled at the camera.", "“I'm fine,” she said, and sat down.", "“I'm fine,” she said, and made tea."),
         READ(DAD, "What does Lena's short answer suggest?", "She is hiding something", "She is very happy", "She is giving details", "She is lost"),
         M("Match each dialogue tool with its effect.", [["Short lines", "feel like real speech"], ["Interruptions", "show tension"], ["“Said”", "keeps attention on the words"]]),
         O("Put the exchange in order.", ["“Did you finish the report?”", "“Almost.”", "“Almost?”", "“I'll send it tonight, I promise.”"]),
         TF("True or false: Each new speaker starts a new paragraph.", "True"),
         TF("True or false: Dialogue should sound like a formal essay.", "False"),
         F("Type the missing word: Most dialogue tags just say “___.”", "said"),
         W("Build the sentence.", "I can't tonight, Dad.", "never", "shall"),
         LISTEN("Where were you? Out. Out where? Just out. He sighed.", "What do the short answers show?", "The speaker does not want to explain", "The speaker is excited", "The speaker is lost", "The speaker loves the weather"),
         YOUR("Write a six-line dialogue where one person hides something. Use short lines."),
     ]),
    ("cw-pov", "scenes", "Point of view", "CW-F-06",
     "Point of view (POV) is who tells the story. First person uses “I”: we know only what the narrator knows. Third person limited uses “he” or “she” but stays close to one character's thoughts. Omniscient sees into everyone's mind. Pick one and stay with it in a scene.",
     [
         C("Which sentence is first person?", "I opened the door and froze.", "She opened the door and froze.", "They opened the door and froze.", "The door opened."),
         C("Which sentence is third person?", "He opened the door and froze.", "I opened the door and froze.", "You open the door and freeze.", "We opened the door."),
         C("In first person, what does the reader know?", "Only what the narrator knows", "Everything about everyone", "Nothing", "Only the weather"),
         C("Which sentence goes inside two characters' minds (omniscient)?", "Ana feared the test, while Ben secretly hoped she would fail.", "Ana feared the test.", "Ben hoped.", "The test began."),
         C("Which sentence stays close to one character (third limited)?", "Ana's stomach twisted as she looked at the first question.", "Ana's stomach twisted, and Ben smiled, and the teacher sighed, and the cat slept.", "The test began.", "Everyone felt different things at once."),
         C("Why keep a consistent point of view in a scene?", "Switching suddenly confuses the reader", "It makes the story shorter", "It is required for dialogue", "It changes the title"),
         M("Match each point of view with its clue.", [["First person", "uses “I” or “we”"], ["Third person limited", "stays with one character's thoughts"], ["Omniscient", "enters many minds"]]),
         TF("True or false: First person uses “I.”", "True"),
         TF("True or false: You may change the point of view in every sentence.", "False"),
         F("Type the missing word: In third person, the narrator uses “he,” “she” or ___.", "they"),
         O("Put the steps in order.", ["Choose who tells the story", "Decide how much they know", "Keep that view through the scene"]),
         READ(FIRST, "Which point of view is this?", "First person", "Third person limited", "Omniscient", "Second person"),
         READ(THIRD, "Which point of view is this?", "Third person limited", "First person", "Omniscient", "Second person"),
         LISTEN("I walked home alone. I wondered if the others were angry with me.", "Which point of view is this?", "First person", "Third person", "Omniscient", "Second person"),
         YOUR("Write the same moment twice, once in first person and once in third person limited: someone waiting for news."),
     ]),
    ("cw-plot", "scenes", "Plot shape", "CW-F-07",
     "A simple plot has a beginning (meet the character and the problem), a rising middle (things get harder), a climax (the biggest moment) and an ending (what changes). Each step should follow from the one before: because of this, then that.",
     [
         C("What happens in the climax?", "The biggest, most tense moment", "The story begins", "The character is introduced", "The title appears"),
         C("What belongs in the beginning?", "The character and the problem", "The final decision", "The credits", "The ending twist"),
         C("What does the rising middle do?", "Makes things harder for the character", "Solves everything", "Introduces nothing", "Ends the story"),
         C("Which links events best?", "Because of this, then that", "And then, and then, and then", "Nothing connects", "Random events"),
         C("Which is a story ending?", "Mina crossed the finish line, finally trusting her own pace.", "Mina has brown hair.", "The race began.", "Mina met her coach."),
         O("Put the plot parts in order.", ["Beginning", "Rising middle", "Climax", "Ending"]),
         O("Put the story events in order.", ["Mina signs up for the race but feels slow.", "She trains alone and falls behind.", "On race day she nearly quits at the hill.", "She keeps going and finishes, proud of her own pace."]),
         M("Match each plot part with its job.", [["Beginning", "introduces the problem"], ["Rising middle", "makes it harder"], ["Climax", "the biggest moment"], ["Ending", "shows what changed"]]),
         TF("True or false: Events in a plot should be linked by cause.", "True"),
         TF("True or false: The climax is the quietest moment.", "False"),
         F("Type the missing word: The ___ is the biggest moment of the story.", "climax"),
         W("Build the sentence.", "Things get harder in the middle.", "never", "easier"),
         LISTEN("At first, Tomas could not swim. Each week he practiced, but he sank. On the last day, a child fell in the pool, and Tomas jumped in and helped.", "What is the climax?", "Tomas jumps in and helps the child", "Tomas cannot swim", "Tomas practices each week", "The pool is open"),
         YOUR("Write a four-sentence story with a beginning, a harder middle, a climax and an ending."),
     ]),
    ("cw-start-end", "scenes", "Beginnings and endings", "CW-F-08",
     "Begin as close to the action as you can: a moment, a question, a problem. Skip long background. End with a change, not a summary: show what is different for the character now. A good ending feels both surprising and right.",
     [
         C("Which opening starts close to the action?", "The key would not turn, and the footsteps were getting closer.", "My name is Tom and I am going to tell you a story about my life.", "Once there was a world with many things in it.", "Let me explain the history of keys."),
         C("Which ending shows a change?", "Anna put down the phone and, for the first time, said no.", "And that is the end of the story.", "Anna lived.", "The end."),
         C("Which opening makes the reader ask a question?", "On the morning my brother disappeared, his bed was still warm.", "I woke up.", "It was a day.", "There was a house."),
         C("Which ending is a weak summary?", "So the lesson of this story is that friends are important.", "Leo handed her the last ticket and walked away, smiling.", "The door closed, and the room felt different.", "She lit the lamp, and the street looked new."),
         C("What should an ending show?", "What has changed for the character", "A list of rules", "Every character's age", "A new unrelated plot"),
         M("Match each tool with its effect.", [["A question in the first line", "makes readers curious"], ["Starting in action", "creates energy"], ["A change at the end", "makes it satisfying"]]),
         O("Put the steps in order.", ["Start at a moment of action", "Build the problem", "End with a change"]),
         TF("True or false: A good opening can start in the middle of an action.", "True"),
         TF("True or false: An ending should repeat the whole story.", "False"),
         F("Type the missing word: End with a ___ for the character.", "change"),
         W("Build the sentence.", "The key would not turn.", "never", "door"),
         READ(PHONE, "What makes this a strong opening?", "It starts with a strange event that raises a question", "It explains the whole backstory", "It lists every character", "It gives the ending"),
         LISTEN("The letter was still in his hand when the train left. He did not run after it. For the first time in years, he was not afraid.", "How does this ending work?", "It shows a change in the character", "It summarizes the lesson", "It introduces a new story", "It lists facts"),
         YOUR("Write a two-sentence opening that starts in action and a one-sentence ending that shows a change."),
     ]),
]

if __name__ == "__main__":
    manifest = build_manifest("creative-writer", "creativeWriter", STAGES, LESSONS, "Foundation", SOURCES)
    write_track("creative-writer", manifest)
