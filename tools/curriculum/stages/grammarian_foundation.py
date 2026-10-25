#!/usr/bin/env python3
"""Grammarian, Foundation stage (about A2-B1): 2 units x 4 lessons, added to track-grammarian.json.

Original wording. The British Council-EAQUALS Core Inventory and the CEFR Companion Volume supply only topic order and level.
Run from the project root: python3 tools/curriculum/stages/grammarian_foundation.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from track_lib import C, TF, READ, LISTEN, W, F, O, M, E, YOUR, add_stage  # noqa: E402

SOURCES = [
    "British Council-EAQUALS Core Inventory for General English (topic order and level)",
    "CEFR Companion Volume (A2-B1 descriptors)",
]

STAGE = {"id": "foundation", "title": "Foundation", "units": [
    {"id": "tenses", "title": "Past, present and future"},
    {"id": "forms", "title": "Useful forms"},
]}

DIARY = "Last Saturday Mia got up early. She made coffee, read the news and went to the market. She bought apples and some bread, then she met a friend for lunch."
PLAN = "Next week Ben is going to start a new job. He has already bought a suit. He thinks the first day will be difficult, but he hopes his team will be kind."

LESSONS = [
    ("gram-f-past", "tenses", "Past simple", "GRAM-F-01",
     "Use the past simple for finished actions at a known time: “I visited my aunt yesterday.” Regular verbs add -ed: work, worked. Many common verbs are irregular: go, went; see, saw; buy, bought. In questions and negatives use did + the base verb: “Did you see it?” “I didn't see it.” Time words that go with it: yesterday, last week, in 2019, two days ago.",
     [
         READ(DIARY, "What did Mia buy?", "Apples and bread", "Coffee and news", "A friend", "Lunch"),
         C("Choose the correct past form of “go”.", "went", "goed", "gone", "going"),
         C("Choose the correct past form of “buy”.", "bought", "buyed", "buying", "buys"),
         C("Which sentence is a correct question?", "Did you see the film?", "Did you saw the film?", "Do you saw the film?", "You did see the film?"),
         C("Which sentence is correct?", "I didn't see him.", "I didn't saw him.", "I not saw him.", "I don't saw him."),
         E("Yesterday I go to the market.", "Yesterday I went to the market."),
         E("She didn't went to school.", "She didn't go to school."),
         M("Match each verb with its past form.", [["see", "saw"], ["work", "worked"], ["have", "had"]]),
         TF("True or false: In a past question we use did + the base verb.", "True"),
         F("Type the past form of “write”.", "wrote"),
         W("Build the sentence.", "We visited my aunt last week.", "never", "visit"),
         LISTEN("I got up at six. I had a quick breakfast and caught the early bus.", "What did the speaker catch?", "The early bus", "A cold", "A train", "A taxi"),
         YOUR("Write three sentences about what you did last weekend, using the past simple."),
     ]),
    ("gram-f-present", "tenses", "Present simple or present continuous", "GRAM-F-02",
     "Use the present simple for habits and facts: “She walks to work.” Use the present continuous for actions happening now or around now: “She is walking to work today.” The continuous uses am/is/are + verb-ing. Words like always, usually and every day go with the simple. Words like now, at the moment and today go with the continuous. Some verbs, such as know, like and want, are usually not used in the continuous.",
     [
         C("Which sentence is a habit?", "She walks to work every day.", "She is walking to work now.", "She walked to work.", "She will walk to work."),
         C("Which sentence is happening now?", "He is reading at the moment.", "He reads every night.", "He read yesterday.", "He has read."),
         C("Choose the correct sentence.", "I know the answer.", "I am knowing the answer.", "I knowing the answer.", "I am know the answer."),
         C("Choose the correct form: “Look! It ___ .”", "is raining", "rains", "rain", "raining"),
         C("Choose the correct form: “She ___ coffee every morning.”", "drinks", "is drinking", "drink", "drinking"),
         E("They are play football now.", "They are playing football now."),
         E("I am wanting a glass of water.", "I want a glass of water."),
         M("Match each time word with the tense it usually goes with.", [["every day", "present simple"], ["at the moment", "present continuous"], ["last week", "past simple"]]),
         TF("True or false: “I am liking music” is the normal way to say it.", "False"),
         F("Type the missing word: She ___ working at the moment.", "is"),
         W("Build the sentence.", "We are studying right now.", "never", "study"),
         LISTEN("My brother usually cooks dinner, but tonight he is working late, so I am cooking.", "Who is cooking tonight?", "The speaker", "The brother", "A friend", "Nobody"),
         YOUR("Write one sentence about a habit and one about something happening right now."),
     ]),
    ("gram-f-future", "tenses", "Will and going to", "GRAM-F-03",
     "Use going to for plans you have already made and for things you can see will happen: “I'm going to visit my uncle.” “Look at those clouds. It's going to rain.” Use will for quick decisions, offers and predictions: “I'll help you.” “I think it will be fun.” The short form is 'll. Negative: won't.",
     [
         READ(PLAN, "Which sentence shows a plan?", "Ben is going to start a new job next week.", "He thinks it will be difficult.", "He hopes the team will be kind.", "He thinks about it."),
         C("The phone rings and you decide to answer at once. Choose the best form.", "I'll get it.", "I'm going to get it.", "I get it.", "I am getting it tomorrow."),
         C("Choose the best form for a plan: “This weekend we ___ visit my parents.”", "are going to", "will can", "going", "are will"),
         C("Look at the dark sky. Choose the best sentence.", "It's going to rain.", "It rains.", "It rained.", "It is rain."),
         C("Which is the short negative of “will not”?", "won't", "willn't", "don't will", "not will"),
         E("I will to call you tomorrow.", "I will call you tomorrow."),
         E("She going to buy a car.", "She is going to buy a car."),
         M("Match each sentence with its use.", [["I'll help you.", "an offer"], ["We're going to move in May.", "a plan"], ["I think it will be fine.", "a prediction"]]),
         TF("True or false: We use “will” for quick decisions.", "True"),
         F("Type the missing word: I think it ___ be fun.", "will"),
         W("Build the sentence.", "I am going to cook dinner.", "never", "going"),
         LISTEN("I haven't decided yet. Maybe I'll go to the cinema, or maybe I'll stay at home.", "Has the speaker made a plan?", "No", "Yes", "Only for tomorrow", "Only for Friday"),
         YOUR("Write one plan with “going to” and one offer with “I'll”."),
     ]),
    ("gram-f-compare", "tenses", "Compare things", "GRAM-F-04",
     "Use the comparative to compare two things: “This bag is cheaper than that one.” Short adjectives add -er (cheap, cheaper); longer ones use more (expensive, more expensive). Use the superlative for the top of three or more: “the cheapest,” “the most expensive.” Some are irregular: good, better, the best; bad, worse, the worst. Use “as … as” for equal things: “as big as.”",
     [
         C("Choose the correct sentence.", "My sister is taller than me.", "My sister is more tall than me.", "My sister is tallest than me.", "My sister is taller that me."),
         C("Choose the correct sentence.", "This is the most interesting book I know.", "This is the most interestinger book.", "This is the interesting book most.", "This is interestingest."),
         C("What is the comparative of “good”?", "better", "gooder", "more good", "best"),
         C("What is the superlative of “bad”?", "the worst", "the baddest", "the most bad", "worse"),
         C("Complete: “She is ___ her brother.” (equal height)", "as tall as", "taller as", "so tall than", "tall like than"),
         E("This phone is more cheap than that one.", "This phone is cheaper than that one."),
         E("He is the most tall boy in class.", "He is the tallest boy in class."),
         M("Match each adjective with its superlative.", [["big", "the biggest"], ["expensive", "the most expensive"], ["good", "the best"]]),
         TF("True or false: Long adjectives usually use “more”.", "True"),
         F("Type the comparative of “easy”.", "easier"),
         W("Build the sentence.", "She is as tall as her mother.", "never", "taller"),
         LISTEN("The blue bag is cheaper than the red one, but the green bag is the cheapest of all.", "Which bag costs the least?", "The green bag", "The red bag", "The blue bag", "All the same"),
         YOUR("Compare two foods or two cities with “than”, and name the best one with a superlative."),
     ]),
    ("gram-f-modal", "forms", "Can, should, must, have to", "GRAM-F-05",
     "Modal verbs add meaning. Can shows ability or permission: “I can swim.” Should gives advice: “You should rest.” Must shows a strong duty or a rule: “You must wear a seatbelt.” Have to is similar and is often used for rules from others: “I have to work on Saturday.” After a modal use the base verb with no to or -s: “She can swim,” not “She cans to swim.” Mustn't means do not; don't have to means it is not necessary.",
     [
         C("Which sentence gives advice?", "You should drink more water.", "You can drink water.", "You drank water.", "You are drinking water."),
         C("Choose the correct sentence.", "She can swim.", "She can swims.", "She cans swim.", "She can to swim."),
         C("Which sentence states a rule?", "You must wear a helmet.", "You might wear a helmet.", "You should wear a helmet.", "You could wear a helmet."),
         C("What does “You mustn't park here” mean?", "Parking here is not allowed.", "Parking here is not necessary.", "Parking here is optional.", "You may park here."),
         C("What does “You don't have to come” mean?", "It is not necessary to come.", "Coming is forbidden.", "You must come.", "You cannot come."),
         E("He should to see a doctor.", "He should see a doctor."),
         E("I must working tomorrow.", "I must work tomorrow."),
         M("Match each modal with its use.", [["can", "ability"], ["should", "advice"], ["must", "strong duty"]]),
         TF("True or false: After a modal we use the base verb.", "True"),
         F("Type the missing word: You ___ wear a seatbelt. (a rule)", "must"),
         W("Build the sentence.", "You should see a doctor.", "never", "sees"),
         LISTEN("You don't have to bring food, but you should bring a warm coat. It gets cold at night.", "What is necessary to bring?", "Nothing is necessary", "Food", "A warm coat is a rule", "A tent"),
         YOUR("Write one rule with “must”, one piece of advice with “should” and one thing that is not necessary with “don't have to”."),
     ]),
    ("gram-f-quant", "forms", "Countable and uncountable", "GRAM-F-06",
     "Countable nouns can be counted: one apple, two apples. Uncountable nouns cannot: water, rice, advice, information. Use many and a few with countable nouns; use much and a little with uncountable nouns. Use a lot of with both. In questions and negatives use any: “Do you have any milk?” In positive sentences use some: “I have some milk.” Words like advice and information are never plural.",
     [
         C("Choose the correct sentence.", "How much water do you drink?", "How many water do you drink?", "How much waters do you drink?", "How many waters do you drink?"),
         C("Choose the correct sentence.", "I need some advice.", "I need an advice.", "I need some advices.", "I need advices."),
         C("Choose the correct question.", "Do you have any apples?", "Do you have some apples?", "Do you have much apples?", "Do you has any apples?"),
         C("Which noun is uncountable?", "rice", "apple", "book", "chair"),
         C("Choose the correct phrase.", "a few friends", "a little friends", "much friends", "a few water"),
         E("There are too much people here.", "There are too many people here."),
         E("She gave me many informations.", "She gave me a lot of information."),
         M("Match each noun with its type.", [["bread", "uncountable"], ["sandwich", "countable"], ["a few", "used with countable nouns"]]),
         TF("True or false: “Information” has a plural form in normal English.", "False"),
         F("Type the missing word: How ___ time do we have?", "much"),
         W("Build the question.", "How many chairs do you need?", "much", "chair"),
         LISTEN("I'd like some water, please, and a few olives. Do you have any bread?", "What does the speaker ask about?", "Bread", "Water", "Olives", "Milk"),
         YOUR("Write four sentences about your kitchen using some, any, much and many correctly."),
     ]),
    ("gram-f-prep", "forms", "Prepositions of time and place", "GRAM-F-07",
     "For time: use at with clock times and night (at six, at night), on with days and dates (on Monday, on 5 May), and in with months, years, seasons and parts of the day (in July, in 2020, in the morning). For place: in a room or city, on a surface or street, at a point or event (at the bus stop, at the party). Learn common pairs as chunks: at home, on holiday, in bed, at work.",
     [
         C("Choose the correct preposition: “I will see you ___ Monday.”", "on", "at", "in", "to"),
         C("Choose the correct preposition: “The lesson starts ___ nine o'clock.”", "at", "on", "in", "for"),
         C("Choose the correct preposition: “She was born ___ 1999.”", "in", "on", "at", "of"),
         C("Choose the correct preposition: “We met ___ the bus stop.”", "at", "in", "on", "by"),
         C("Choose the correct preposition: “The book is ___ the table.”", "on", "at", "in the", "to"),
         E("I get up in seven o'clock.", "I get up at seven o'clock."),
         E("We have class at Tuesday.", "We have class on Tuesday."),
         M("Match each phrase with its preposition.", [["___ July", "in"], ["___ Sunday", "on"], ["___ night", "at"]]),
         TF("True or false: We say “in the morning” but “at night”.", "True"),
         F("Type the missing word: I am ___ home.", "at"),
         W("Build the sentence.", "We meet on Friday at noon.", "never", "in"),
         LISTEN("The film starts at eight on Saturday evening. Meet me at the cinema entrance.", "When does the film start?", "At eight on Saturday", "On eight at Saturday", "In Saturday", "At Sunday"),
         YOUR("Write three sentences about your week using at, on and in for time."),
     ]),
    ("gram-f-questions", "forms", "Ask questions", "GRAM-F-08",
     "Make questions with an auxiliary before the subject: “Do you live here?” “Did she call?” “Is he ready?” Wh- questions start with the question word: “Where do you work?” “What did he say?” When who or what is the subject, there is no auxiliary: “Who called you?” Do not add do to the verb be: “Where is she?” not “Where does she is?” End with a question mark.",
     [
         C("Choose the correct question.", "Where do you work?", "Where you work?", "Where does you work?", "Where work you?"),
         C("Choose the correct question.", "What did he say?", "What he said?", "What did he said?", "What does he said?"),
         C("Choose the correct question.", "Who called you?", "Who did call you?", "Who does called you?", "Who you called?"),
         C("Choose the correct question.", "Where is she?", "Where does she is?", "Where she is?", "Where is be she?"),
         C("Choose the correct question.", "Are you ready?", "Do you ready?", "You are ready?", "Ready are you?"),
         E("Where you live?", "Where do you live?"),
         E("What time does the class starts?", "What time does the class start?"),
         M("Match each question word with what it asks.", [["Where", "place"], ["When", "time"], ["Why", "reason"]]),
         TF("True or false: We use “do” with the verb “be”.", "False"),
         F("Type the missing word: ___ does the film start? (time)", "when", "What time"),
         W("Build the question.", "Where did you go?", "does", "went"),
         LISTEN("Excuse me, what time does the next train leave, and which platform is it?", "What does the speaker want to know?", "The time and the platform", "The price", "The weather", "The name of the station"),
         YOUR("Write four questions you would ask a new classmate, each starting with a different question word."),
     ]),
]

if __name__ == "__main__":
    add_stage("grammarian", STAGE, LESSONS, "Foundation", SOURCES)
