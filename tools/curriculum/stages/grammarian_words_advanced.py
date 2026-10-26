#!/usr/bin/env python3
"""Grammarian, Advanced stage (about C1-C2): new units "Voice and mood" (3) and "Common errors" (4).

Phase 11 (2026-10-26). Original wording. The British Council-EAQUALS Core Inventory and the CEFR Companion Volume
supply only topic order and level. Pairs that differ only by an apostrophe (its / it's) are practised with described
choices, because the app's answer check ignores punctuation.
Run from the project root: python3 tools/curriculum/stages/grammarian_words_advanced.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from track_lib import C, TF, READ, LISTEN, W, F, M, E, YOUR, add_units  # noqa: E402

SOURCES = [
    "British Council-EAQUALS Core Inventory for General English (topic order and level)",
    "CEFR Companion Volume (C1-C2 descriptors)",
]

UNITS = [
    {"id": "voice-mood", "title": "Voice and mood"},
    {"id": "common-errors", "title": "Common errors"},
]

LESSONS = [
    # ---- Voice and mood ----
    ("gram-a-causative", "voice-mood", "Have something done", "GRAM-A-11",
     "The causative says that someone else does a job for you: have + object + past participle. “I had my hair cut.” (A hairdresser cut it.) “We're having the kitchen painted.” Get works the same way and is more informal: “I need to get my phone fixed.” It can also describe something bad that happened to you: “He had his bike stolen.” Compare: “I cut my hair” means you did it yourself.",
     [
         C("Who cut the hair in “I had my hair cut”?", "Someone else, such as a hairdresser", "The speaker", "Nobody", "The speaker's friend, by mistake"),
         C("Choose the correct form: “We are going to ___ the roof repaired.”", "have", "make", "do", "let"),
         C("Choose the correct form: “She got her car ___ last week.”", "serviced", "service", "servicing", "to service"),
         C("Choose the correct sentence.", "I need to have my eyes tested.", "I need to have tested my eyes by someone.", "I need to have my eyes test.", "I need to have my eyes testing."),
         C("What does “They had their passports stolen” mean?", "Someone stole their passports", "They stole passports", "They asked someone to steal them", "They lost them on purpose"),
         E("I'm having my suit clean tomorrow.", "I'm having my suit cleaned tomorrow."),
         E("Where did you have your photo take?", "Where did you have your photo taken?"),
         M("Match each sentence with its meaning.", [["I painted the fence.", "I did it myself"], ["I had the fence painted.", "someone did it for me"], ["I got the fence painted at last.", "informal: someone did it"]]),
         TF("True or false: “Get something done” is usually more informal than “have something done”.", "True"),
         F("Type the past participle that fits: “We had a new window ___ (put) in.”", "put"),
         W("Build the sentence.", "He had his laptop repaired in town.", "repair", "himself"),
         YOUR("Write two sentences about services you pay for, using have or get something done."),
     ]),
    ("gram-a-mood", "voice-mood", "Indicative, imperative, subjunctive", "GRAM-A-12",
     "Mood shows the speaker's attitude. The indicative states facts and asks questions: “She lives here.” The imperative gives orders and requests: “Sit down.” The subjunctive talks about wishes, demands and unreal situations. After verbs like insist, suggest, recommend and demand, formal English uses the base verb for every person: “I suggest that he leave early.” In unreal conditions, “were” is used for all persons: “If I were you, …” “I wish she were here.”",
     [
         C("Which mood is “Please close the door”?", "Imperative", "Indicative", "Subjunctive", "Interrogative tense"),
         C("Choose the formal subjunctive: “The doctor recommended that he ___ more.”", "rest", "rests", "rested", "is resting"),
         C("Choose the best form: “If I ___ you, I would apologise.”", "were", "am", "be", "was being"),
         C("Choose the formal subjunctive: “It is essential that every student ___ on time.”", "be", "is", "was", "being"),
         C("Which mood is “Water boils at 100 degrees”?", "Indicative", "Imperative", "Subjunctive", "Conditional mood only"),
         E("The manager insisted that he arrives early.", "The manager insisted that he arrive early."),
         E("If he was the manager, he would change the rules.", "If he were the manager, he would change the rules."),
         M("Match each sentence with its mood.", [["Take a seat.", "imperative"], ["They live in Rome.", "indicative"], ["I suggest she apply now.", "subjunctive"]]),
         TF("True or false: In formal writing, “I demand that he be told the truth” is correct.", "True"),
         F("Type the subjunctive form of “be” for “If she ___ here, she would help.”", "were"),
         READ("The committee requested that each member submit a written report before the meeting and that no report exceed two pages.", "What is the limit on each report?", "No more than two pages", "At least two pages", "Exactly one page", "No limit at all"),
         YOUR("Write one sentence each in the imperative, the indicative and the subjunctive."),
     ]),
    ("gram-a-mixed-conditionals", "voice-mood", "Mixed conditionals", "GRAM-A-13",
     "A mixed conditional mixes times. Past cause, present result: if + past perfect, would + verb. “If I had taken the job, I would be rich now.” Present cause, past result: if + past simple, would have + past participle. “If she were more careful, she wouldn't have lost her keys.” Use them when the cause and the result belong to different times.",
     [
         C("Choose the correct form: “If I had studied medicine, I ___ a doctor now.”", "would be", "would have been yesterday", "will be", "am"),
         C("Choose the correct form: “If he weren't so shy, he ___ to her at the party last night.”", "would have spoken", "would speak tomorrow", "will speak", "speaks"),
         C("What does “If I hadn't missed the flight, I would be in Rome now” mean?", "I missed the flight, so I am not in Rome", "I am in Rome now", "I will miss the flight", "I didn't want to go to Rome"),
         C("Which sentence is a mixed conditional?", "If we had left earlier, we would be there by now.", "If we leave earlier, we will be there.", "If we left earlier, we would be there.", "If we had left earlier, we would have been there."),
         C("Choose the correct form: “If I ___ English as a child, I would be fluent today.”", "had learned", "learned yesterday", "have learned", "learn"),
         E("If she had saved money, she would has a car now.", "If she had saved money, she would have a car now."),
         E("If I would have known, I would be there now.", "If I had known, I would be there now."),
         M("Match each sentence with its time pattern.", [["If I had slept, I'd feel better now.", "past cause, present result"], ["If I were brave, I'd have spoken up.", "present cause, past result"], ["If I had slept, I'd have felt better.", "past cause, past result"]]),
         TF("True or false: “If I didn't love you, I wouldn't have come all this way” mixes a present cause with a past result.", "True"),
         F("Type the missing word: “If they had booked earlier, they ___ be sitting at the front now.”", "would"),
         W("Build the sentence.", "If I had listened, I would know the answer.", "will", "knew"),
         YOUR("Write one mixed conditional about a past choice that changes your life today."),
     ]),
    # ---- Common errors ----
    ("gram-a-confusables", "common-errors", "Its, your, their and friends", "GRAM-A-21",
     "Some words sound alike but mean different things. Your = belonging to you; you're = you are. Their = belonging to them; there = in that place (or “there is”); they're = they are. Its = belonging to it; it's = it is or it has. Then = after that; than = in comparisons. Lose = not have any more; loose = not tight. Test yourself by expanding: if “it is” fits, write it's.",
     [
         C("Choose the correct word: “___ going to be late if we don't hurry.”", "We're", "Where", "Wear", "Ware"),
         C("Choose the correct word: “Put the boxes over ___ .”", "there", "their", "they're", "theirs"),
         C("Choose the correct word: “Is this ___ umbrella?”", "your", "you're", "yore", "you"),
         C("Choose the correct word: “She is taller ___ her brother.”", "than", "then", "that", "thon"),
         C("“The company changed ___ name.” Which word fits?", "its, the one with no apostrophe", "it's, the one with an apostrophe", "it is", "its', with an apostrophe after s"),
         C("Choose the correct word: “These jeans are too ___ ; I need a belt.”", "loose", "lose", "lost", "loss"),
         E("Their going to the cinema tonight.", "They're going to the cinema tonight."),
         E("I'll call you and than we can decide.", "I'll call you and then we can decide."),
         M("Match each word with its meaning.", [["they're", "they are"], ["their", "belonging to them"], ["there", "in that place"]]),
         TF("True or false: “It's been a long day” uses it's correctly, meaning “it has”.", "True"),
         F("Type the right word: “Don't ___ your keys again!” (lose / loose)", "lose"),
         YOUR("Write three sentences that use your and you're, their and there correctly."),
     ]),
    ("gram-a-tricky-pairs", "common-errors", "Affect, fewer, whom", "GRAM-A-22",
     "Affect is usually a verb (to influence); effect is usually a noun (a result): “Stress affects sleep.” “Stress has an effect on sleep.” Use fewer with countable nouns and less with uncountable: fewer people, less noise. Who is a subject; whom is an object, mostly in formal English and after prepositions: “Who called?” “To whom did you write?” Use “between” for two and “among” for more than two.",
     [
         C("Choose the correct word: “The new law will ___ many families.”", "affect", "effect", "affection", "effective"),
         C("Choose the correct word: “The medicine had no ___ .”", "effect", "affect", "affects", "affecting"),
         C("Choose the correct word: “There were ___ cars on the road today.”", "fewer", "less", "lesser", "few of"),
         C("Choose the correct word: “Please make ___ noise.”", "less", "fewer", "few", "lesser of"),
         C("Choose the formal word: “To ___ should I send the invoice?”", "whom", "who", "whose", "who's"),
         C("Choose the correct word: “Divide the cake ___ the two children.”", "between", "among", "amid", "within"),
         E("Less than ten people came to the meeting.", "Fewer than ten people came to the meeting."),
         E("The weather effected our plans.", "The weather affected our plans."),
         M("Match each word with the noun it fits.", [["fewer", "mistakes"], ["less", "sugar"], ["among", "the five friends"]]),
         TF("True or false: “Who did you meet?” is normal in everyday English, while “Whom did you meet?” is more formal.", "True"),
         F("Type the right word: “Climate change has a big ___ on farming.” (affect / effect)", "effect"),
         YOUR("Write sentences using affect, effect, fewer and less."),
     ]),
    ("gram-a-modifiers", "common-errors", "Dangling modifiers", "GRAM-A-23",
     "A modifier is a word or phrase that describes something. It should sit next to the thing it describes. A dangling modifier has nothing correct to describe: “Walking to work, the rain started” (the rain wasn't walking). Fix it by naming the right subject: “Walking to work, I got caught in the rain.” A misplaced modifier is in the wrong place: “She almost drove her kids to school every day” should be “She drove her kids to school almost every day.”",
     [
         C("What is wrong with “Running for the bus, my phone fell out”?", "It sounds as if the phone was running", "It has no verb", "It is a question", "Nothing is wrong"),
         C("Choose the best fix for “Having finished the report, the computer was switched off.”", "Having finished the report, I switched off the computer.", "Having finished the report, the computer switched off.", "Having finished, the report was switched off.", "The computer, having finished, was switched off."),
         C("Which sentence has a misplaced modifier?", "She almost drove her kids to school every day.", "She eats vegetables every day.", "Tired after the trip, we went to bed early.", "He slowly opened the door."),
         C("Choose the clearest sentence.", "When I was a child, my mother taught me to swim.", "As a child, my mother taught me to swim.", "As a child, swimming was taught to me by my mother.", "Being a child, my mother taught swimming."),
         C("Who is “young and nervous” in “Young and nervous, the interview was hard for Tom”?", "It should be Tom, but the sentence says the interview", "The interview", "The interviewer", "Nobody"),
         TF("True or false: “Covered in mud, the dog jumped into the bath” is correct, because the dog is covered in mud.", "True"),
         TF("True or false: “Looking out of the window, the mountains were beautiful” is correct.", "False"),
         M("Match each opening with a correct ending.", [["After eating lunch,", "we went back to work."], ["Excited about the news,", "she called her parents."], ["To win the game,", "you need a strategy."]]),
         C("Choose the best fix for “Driving home, a deer jumped onto the road.”", "While I was driving home, a deer jumped onto the road.", "Driving home, the road had a deer.", "A deer, driving home, jumped onto the road.", "Driving home, a deer jumped onto me."),
         READ("Built in 1890, the bridge is the oldest in the city. Visitors often walk across it at sunset to take photos.", "What was built in 1890?", "The city's oldest bridge", "The visitors' hotel", "A photo studio", "The sunset tower"),
         F("Type the word that the opening should describe: “Smiling warmly, ___ welcomed the guests.” (the host / the door)", "the host"),
         YOUR("Write two sentences that begin with an -ing phrase and describe the right subject."),
     ]),
    ("gram-a-parallel", "common-errors", "Parallel structure", "GRAM-A-24",
     "Parallel structure means using the same grammatical form for items that go together, especially in lists and pairs. Not: “I like swimming, to read and cooking.” But: “I like swimming, reading and cooking.” Pairs like both…and, either…or, not only…but also should be followed by the same form: “She is not only clever but also kind.” Parallel sentences are easier to read and sound more polished.",
     [
         C("Choose the parallel sentence.", "She enjoys hiking, cycling and swimming.", "She enjoys hiking, to cycle and swimming.", "She enjoys to hike, cycling and swim.", "She enjoys hike, cycling and to swim."),
         C("Choose the parallel sentence.", "The job requires patience, skill and energy.", "The job requires patience, being skilled and energy.", "The job requires being patient, skill and to be energetic.", "The job requires patience, skilled and energetic."),
         C("Choose the parallel sentence.", "He is not only talented but also hard-working.", "He is not only talented but also works hard.", "He not only is talented but also hard-working.", "He is not only talent but also hard-working."),
         C("Choose the parallel sentence.", "We can either take the train or rent a car.", "We can either take the train or renting a car.", "We either can take the train or a car rented.", "We can either taking the train or rent a car."),
         C("What is wrong with “The plan is cheap, quick and it is easy”?", "The last item is a clause, not an adjective like the others", "It needs a question mark", "Cheap should be cheaply", "Nothing is wrong"),
         E("My goals are to learn Spanish, to travel and saving money.", "My goals are to learn Spanish, to travel and to save money."),
         E("She likes reading books and to watch films.", "She likes reading books and watching films."),
         M("Match each start with the parallel ending.", [["I came, I saw,", "I conquered."], ["Both the teacher and", "the students agreed."], ["Not only fast but also", "reliable"]]),
         TF("True or false: “To err is human; to forgive, divine” is an example of parallel structure.", "True"),
         F("Type the parallel form: “He likes running, swimming and ___ (ride) bikes.”", "riding"),
         W("Build the parallel sentence.", "The hotel was clean, quiet and comfortable.", "comfort", "quietly"),
         YOUR("Write a sentence with a list of three actions in the same form, and one with not only … but also."),
     ]),
]

if __name__ == "__main__":
    add_units("grammarian", "advanced", UNITS, LESSONS, "C1-C2", SOURCES, position="end")
