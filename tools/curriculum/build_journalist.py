#!/usr/bin/env python3
"""Build the Journalist track (Foundation stage, 2 units x 4 lessons): Resources/Tracks/track-journalist.json.

All stories, questions and tips are original wording. Conventions used (5 Ws and H, open and closed questions, the
inverted pyramid, attribution) are common newsroom practice; the SPJ Code of Ethics is cited for ideas only.
Run from the project root: python3 tools/curriculum/build_journalist.py
"""
from track_lib import C, TF, READ, LISTEN, W, F, O, M, L, YOUR, build_manifest, write_track

SOURCES = [
    "Common newsroom conventions: the 5 Ws and H, the inverted pyramid, attribution (concepts only)",
    "Society of Professional Journalists, Code of Ethics (accuracy and fairness; summarized, not quoted)",
]

STAGES = [{"id": "foundation", "title": "Foundation", "units": [
    {"id": "questions", "title": "Ask good questions"},
    {"id": "write", "title": "Write the story"},
]}]

FIRE = "A fire broke out at a furniture store on Elm Street on Monday night. Firefighters put out the fire in two hours. No one was hurt. Officials think an electrical problem caused it."
CHEF = "A chef tells a reporter that she makes all the bread by hand every morning at four o'clock."
PRINCIPAL = "The school principal spoke to students on Monday. “Every student will get a free book,” said Ms. Park. The students cheered."
BUS = "A school bus caught fire near Pine Park on Tuesday morning. All 24 children got off safely. The driver, Lee Wong, called for help. The bus was 12 years old."
CAT = "Firefighters saved a cat from a tall tree in Oak Park on Sunday. The cat, named Milo, had been in the tree for two days."
BAKERY = "A bakery on River Road closed on Friday. The owner, Sam Cole, said rising prices were the reason. Some neighbors think the bread was too expensive."
COUNCIL = "The city council voted on Monday to build a new bike lane on Pine Street. The lane will cost 300,000 dollars. Supporters say it will make the street safer. Some shop owners worry that they will lose parking spaces."

LESSONS = [
    ("jn-five-ws", "questions", "The 5 Ws and H", "JN-F-01",
     "A news story answers six questions: Who? What? Where? When? Why? and How? Reporters check that every story answers them. If an answer is missing, ask another question.",
     [
         M("Match each question word with what it asks for.", [["Who", "a person or group"], ["Where", "a place"], ["When", "a time or date"], ["Why", "a reason"]]),
         READ(FIRE, "Where did the fire happen?", "At a furniture store on Elm Street", "At a school", "In a forest", "At the fire station"),
         READ(FIRE, "When did the fire happen?", "Monday night", "Sunday morning", "Friday evening", "Tuesday at noon"),
         READ(FIRE, "Who put out the fire?", "Firefighters", "Neighbors", "Police officers", "Store workers"),
         READ(FIRE, "Why did the fire start, according to officials?", "They think an electrical problem caused it", "A storm hit the store", "A car hit the building", "The cause is known for sure"),
         C("A reporter writes: “The mayor opened a new bridge in Dover on Friday.” Which question is still missing?", "Why was the bridge needed?", "Who opened it?", "Where is it?", "When did it open?"),
         C("A story says what happened but not when. What should the reporter ask?", "When did it happen?", "Who is the mayor?", "How tall is the building?", "Where is the city?"),
         LISTEN("Two students won a science prize at Oakwood School on Thursday. They built a small machine that cleans water.", "Who won the prize?", "Two students", "A teacher", "The whole school", "A scientist"),
         LISTEN("Two students won a science prize at Oakwood School on Thursday. They built a small machine that cleans water.", "What did they build?", "A machine that cleans water", "A robot dog", "A new school", "A water bottle"),
         TF("True or false: A news story should answer who, what, where, when, why and how.", "True"),
         F("Type the missing word: ___ asks for a person.", "Who"),
         W("Build the question.", "Who did it and when?", "where", "why"),
         L("The meeting is on Friday at ten."),
         YOUR("Think of one event from your day. Write one sentence that answers who, what, where and when."),
     ]),
    ("jn-open-closed", "questions", "Open and closed questions", "JN-F-02",
     "A closed question has a short answer, such as yes or no. An open question starts with words like what, how or why and invites a longer answer. Reporters use open questions to get stories and closed questions to check facts.",
     [
         C("Which is an open question?", "How did you feel when you won?", "Did you win?", "Are you happy?", "Is it Friday?"),
         C("Which is a closed question?", "Is the park open today?", "Why do you like the park?", "How was your day?", "What happened next?"),
         C("Make an open question from “Do you like your job?”", "What do you like about your job?", "Is your job good?", "Do you have a job?", "Does your boss like you?"),
         C("Make an open question from “Was the game exciting?”", "What made the game exciting?", "Did you watch the game?", "Was it long?", "Is it over?"),
         W("Build the question.", "How did you start your business?", "Did", "Is"),
         W("Build the question.", "What was the hardest part?", "Was", "Is"),
         F("Type a missing word: ___ did you decide to move here?", "Why", "How"),
         M("Match each question with the answer it usually gets.", [["Is the store open?", "a short yes or no"], ["Why did you open the store?", "a longer answer with reasons"], ["What happened on your first day?", "a story"]]),
         O("Put the words in order.", ["What", "happened", "after", "the", "storm?"]),
         TF("True or false: A closed question usually gets a long answer.", "False"),
         TF("True or false: Open questions often start with what, how or why.", "True"),
         LISTEN("Did you enjoy the festival? Yes. What was your favorite part? The street musicians, because they played songs from many countries.", "Which question was open?", "What was your favorite part?", "Did you enjoy the festival?", "Both of them", "Neither of them"),
         YOUR("Write one closed question and one open question for a classmate about their weekend."),
     ]),
    ("jn-follow-up", "questions", "Follow-up questions", "JN-F-03",
     "A follow-up question builds on what the person just said. It shows you listened, and it gets details. Good follow-ups are “Can you give an example?”, “What happened next?” and “Why was that important?”",
     [
         C("The mayor says: “We will fix the old bridge.” Which is the best follow-up?", "When will the work start?", "What is your favorite color?", "Do you like bridges?", "How old are you?"),
         C("A baker says: “Business has been hard this year.” Which is the best follow-up?", "What has made it hard?", "What is your name?", "Where is the bank?", "Is bread healthy?"),
         C("A student says: “I was nervous before the exam.” Which is the best follow-up?", "What did you do to calm down?", "Which day is it?", "Is the school big?", "Do you like exams?"),
         C("Someone says: “We moved here last year.” Which question ignores what was said?", "What is the capital of France?", "Why did you move?", "How do you like it here?", "Where did you live before?"),
         READ(CHEF, "Which follow-up question builds on this?", "Why do you start so early?", "How tall are you?", "Do you like the news?", "What city is this?"),
         M("Match each question with what it does.", [["Can you give an example?", "gets a clear detail"], ["What happened next?", "moves the story forward"], ["Why was that important?", "gets a reason"]]),
         O("Put the steps in order.", ["Listen to the answer", "Pick one interesting point", "Ask a question about that point"]),
         F("Type the missing word: A follow-up question builds on the ___.", "answer"),
         TF("True or false: A follow-up question shows you were listening.", "True"),
         W("Build the question.", "Can you give an example?", "Do", "some"),
         LISTEN("My brother started a small garden at school. Now every class uses the vegetables for lunch.", "Which follow-up fits best?", "How did he get the idea?", "What time is lunch?", "Who is the principal?", "Where is the bus?"),
         L("Can you tell me more about that?"),
         YOUR("A friend says: “I changed my job last month.” Write two follow-up questions."),
     ]),
    ("jn-quote-attribute", "questions", "Quote and attribute", "JN-F-04",
     "A quote uses a person's exact words inside quotation marks. Attribution says who said them: “said Maria Lopez.” Use “said” most of the time. Never change the words inside the quotation marks. If you change them, it is a paraphrase, not a quote.",
     [
         C("Which sentence is punctuated correctly?", "“I love this town,” said Mia.", "“I love this town”, said Mia.", "“I love this town” said Mia.", "I love this town, said Mia."),
         C("Which sentence is a direct quote?", "The coach said, “We played our best.”", "The coach said they played their best.", "The coach was happy.", "The coach left early."),
         C("Which one is a paraphrase?", "The mayor said the road will close on Monday.", "The mayor said, “The road will close on Monday.”", "“The road will close,” said the mayor.", "The mayor said, “Close it!”"),
         C("Which verb is the most neutral for attribution?", "said", "shouted", "complained", "bragged"),
         C("What should you NOT do with a quote?", "Change the words inside the quotation marks", "Add the speaker's name", "Put it in quotation marks", "Use it in the second paragraph"),
         READ(PRINCIPAL, "Who said the words in quotation marks?", "Ms. Park", "The students", "The reporter", "Every student"),
         F("Type the missing word: “We start at nine,” ___ the teacher.", "said"),
         M("Match each term with its meaning.", [["Quote", "the exact words a person said"], ["Paraphrase", "the same idea in your own words"], ["Attribution", "who said the words"]]),
         O("Put the steps in order.", ["Write the person's exact words in quotation marks", "Add who said them", "Check that the words are exact"]),
         TF("True or false: Attribution tells the reader who said something.", "True"),
         TF("True or false: You may change a few words inside quotation marks.", "False"),
         W("Build the sentence.", "“I am proud,” said Ana.", "asked", "shouted"),
         YOUR("Write one sentence with a quote and attribution about something someone said to you this week."),
     ]),
    ("jn-pyramid", "write", "The inverted pyramid", "JN-F-05",
     "News stories put the most important facts first and the smaller details later. The shape is an upside-down pyramid: wide at the top with the key facts, and narrow at the bottom with extra details. If a reader stops after the first paragraph, they still know the story.",
     [
         O("Put the paragraphs of a news story in the usual order.", ["A bridge in Dover will close for repairs from Monday, the city said.", "The work will take six weeks and cost two million dollars.", "Drivers can use Mill Road instead, and extra buses will run.", "The bridge was built in 1962."]),
         C("Which fact belongs in the first paragraph?", "A bridge in Dover will close on Monday.", "The bridge was painted green in 1990.", "The mayor likes bridges.", "A café sells coffee near the bridge."),
         C("Which fact is the least important, so it goes last?", "The bridge was built in 1962.", "The bridge will close on Monday.", "Repairs will take six weeks.", "Drivers can use Mill Road."),
         C("Why do reporters use the inverted pyramid?", "Readers get the key facts even if they stop early", "It is a shape for school buildings", "It makes stories longer", "It puts jokes first"),
         C("What shape describes a news story?", "An upside-down pyramid", "A circle", "A straight line", "A square"),
         READ(BUS, "Which sentence is best for the first line of the news story?", "A school bus caught fire near Pine Park on Tuesday morning.", "The bus was 12 years old.", "The driver called for help.", "All 24 children got off safely."),
         LISTEN("Police closed Main Street today after a water pipe broke. The street will open again tomorrow. The pipe was installed in 1985.", "Which fact is the least important?", "The pipe was installed in 1985", "Main Street was closed", "A pipe broke", "The street opens tomorrow"),
         TF("True or false: The most important facts go at the top.", "True"),
         TF("True or false: A news story starts with the smallest detail.", "False"),
         M("Match each part of the story with its job.", [["Top", "the key facts"], ["Middle", "important details"], ["Bottom", "extra background"]]),
         F("Type the missing word: The most ___ facts come first.", "important"),
         W("Build the sentence.", "Put the key facts first.", "last", "small"),
         YOUR("Write three sentences about something that happened today. Put the most important fact first."),
     ]),
    ("jn-headlines", "write", "Headlines and ledes", "JN-F-06",
     "A headline is a short title that tells the main news. It uses short, strong words and often drops small words like “the” and “a.” The lede is the first sentence of the story. It gives the most important facts clearly in one sentence.",
     [
         C("Which headline is best for a story about a bridge closing?", "Dover bridge to close for six weeks", "A thing is happening", "Bridge", "Many people live in Dover and some like bridges and others do not"),
         C("Which headline is the clearest?", "Town opens new library on Main Street", "Something new", "A building", "Library library library"),
         C("Which words do headlines often drop?", "“the” and “a”", "Names and numbers", "Verbs and nouns", "Dates and places"),
         C("Which is a good lede?", "A water pipe broke on Main Street on Monday, closing the road for a day.", "Pipes are interesting.", "Main Street is a street.", "Water is a liquid."),
         C("Which lede answers who, what and when?", "Two students won a science prize on Thursday.", "Prizes are nice.", "Science is fun, and many people like it.", "The school has a big gate."),
         READ(CAT, "Which headline fits this story best?", "Firefighters rescue cat from Oak Park tree", "Tree grows in park", "Cat is named Milo", "Sunday is a good day"),
         W("Build a short headline.", "Town opens new park", "the", "a", "is"),
         W("Build a short headline.", "Mayor opens bridge", "the", "was"),
         F("Type the missing word: The ___ is the first sentence of the story.", "lede", "lead"),
         TF("True or false: A headline should be long and detailed.", "False"),
         TF("True or false: The lede gives the most important facts.", "True"),
         M("Match each term with its job.", [["Headline", "a short title with the main news"], ["Lede", "the first sentence with the key facts"], ["Byline", "the name of the writer"]]),
         O("Put the steps in order.", ["Find the main news", "Write a short headline", "Write a lede with the key facts"]),
         YOUR("Write a headline and a one-sentence lede about something that happened at school or work this week."),
     ]),
    ("jn-fact-opinion", "write", "Fact, opinion and doubt", "JN-F-07",
     "Reporters separate what is known from what is thought. A fact can be checked. An opinion is a view. When the facts are not sure, use careful words such as “police said,” “may have” and “according to.” Never state a guess as a fact.",
     [
         C("Which sentence states a fact?", "The shop opens at nine.", "The shop is the best in town.", "The shop should open earlier.", "The shop is probably nice."),
         C("The cause of a fire is not sure. Which sentence is the most careful?", "Officials said the fire may have started in the kitchen.", "The fire started in the kitchen.", "The fire was a disaster.", "The cook caused the fire."),
         C("Which words show a source?", "according to the police", "I feel that", "probably", "maybe"),
         C("Which sentence is an opinion?", "It was the worst storm ever.", "The storm hit on Tuesday.", "The storm lasted six hours.", "Trees fell on Oak Road."),
         C("A witness says the man was “about 40.” How should a reporter write it?", "The man was about 40, a witness said.", "The man was exactly 40.", "The man was young.", "The man was 39."),
         READ(BAKERY, "Which sentence is an opinion?", "Some neighbors think the bread was too expensive.", "A bakery on River Road closed on Friday.", "The owner is Sam Cole.", "The owner gave a reason."),
         READ(BAKERY, "Who gave the reason for closing?", "The owner, Sam Cole", "Some neighbors", "The reporter", "The customers"),
         M("Match each phrase with what it shows.", [["according to", "a source"], ["may have", "not sure"], ["I think", "an opinion"]]),
         TF("True or false: A reporter should state a guess as a fact.", "False"),
         TF("True or false: “Police said” tells the reader where the information came from.", "True"),
         F("Type the missing word: Reporters name their ___.", "sources", "source"),
         W("Build the sentence.", "Police said it was an accident.", "think", "maybe"),
         YOUR("Write two sentences about something you are not sure about. Use “may” or “according to.”"),
     ]),
    ("jn-summarize", "write", "Summarize a source fairly", "JN-F-08",
     "To summarize, write the main points in your own words and keep the meaning the same. Do not add your opinion, and do not leave out facts that change the meaning. Name the source: “The report says…”",
     [
         READ(COUNCIL, "Which is the fairest summary?", "The council voted to build a bike lane; supporters say it is safer, and some shop owners worry about parking.", "The council made a terrible choice about bikes.", "The council voted to build a bike lane and everybody agreed.", "Shop owners lost their parking spaces and are angry."),
         READ(COUNCIL, "Which summary adds an opinion?", "The council wasted money on a silly bike lane.", "The council voted for a new bike lane on Pine Street.", "The lane will cost 300,000 dollars.", "Supporters say the lane will make the street safer."),
         READ(COUNCIL, "Which detail is a key fact for a short summary?", "The council voted to build a bike lane.", "The meeting began at six.", "The room was warm.", "A man wore a hat."),
         C("A summary should be...", "much shorter than the original", "longer than the original", "full of your opinions", "word for word the same"),
         C("Which phrase names the source?", "The report says", "In my view", "It seems", "Everyone knows"),
         TF("True or false: You may leave out facts that change the meaning.", "False"),
         TF("True or false: A good summary uses your own words.", "True"),
         O("Put the steps in order.", ["Read the source carefully", "Find the main points", "Write them in your own words", "Check that the meaning is the same"]),
         M("Match each summary mistake with its result.", [["Adding your opinion", "unfair"], ["Leaving out a key fact", "misleading"], ["Copying word for word", "not a summary"]]),
         F("Type the missing word: A summary keeps the same ___.", "meaning"),
         W("Build the sentence.", "The report says costs will rise.", "think", "lower"),
         LISTEN("Local farmers say the dry summer cut their harvest by a third. The government plans to give them extra help.", "Which is the best summary?", "Dry weather cut harvests, and the government plans to help farmers.", "The government made a bad plan for farmers.", "Farmers had a big harvest.", "The summer was wet."),
         YOUR("Summarize a short news story you read or heard this week in two sentences. Name the source."),
     ]),
]

if __name__ == "__main__":
    manifest = build_manifest("journalist", "journalist", STAGES, LESSONS, "Foundation", SOURCES)
    write_track("journalist", manifest)
