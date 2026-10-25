#!/usr/bin/env python3
"""Grammarian, Intermediate stage (about B1-B2): 2 units x 4 lessons, added to track-grammarian.json.

Original wording. The British Council-EAQUALS Core Inventory and the CEFR Companion Volume supply only topic order and level.
Run from the project root: python3 tools/curriculum/stages/grammarian_intermediate.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from track_lib import C, TF, READ, LISTEN, W, F, O, M, E, YOUR, add_stage  # noqa: E402

SOURCES = [
    "British Council-EAQUALS Core Inventory for General English (topic order and level)",
    "CEFR Companion Volume (B1-B2 descriptors)",
]

STAGE = {"id": "intermediate", "title": "Intermediate", "units": [
    {"id": "time", "title": "Time and tense"},
    {"id": "complex", "title": "Build complex sentences"},
]}

LIFE = "Dara has lived in Lisbon for six years. She moved there in 2019 after she finished university. Since then she has changed jobs twice, and she has just started a third."

LESSONS = [
    ("gram-i-perfect", "time", "Present perfect: since and for", "GRAM-I-01",
     "Use the present perfect (have/has + past participle) for situations that began in the past and continue now, or for results that matter now. Use for with a length of time (for six years) and since with a starting point (since 2019). “I have lived here for six years” means I still live here. Words that go with it: ever, never, already, yet, just. Past participles: been, gone, done, seen, written, taken.",
     [
         READ(LIFE, "What has Dara done since she moved?", "Changed jobs twice and begun a third", "Studied at university", "Bought a house", "Moved to Porto"),
         C("Choose the correct sentence.", "I have lived here since 2019.", "I live here since 2019.", "I am living here since 2019.", "I lived here since 2019."),
         C("Choose the correct sentence.", "She has worked here for ten years.", "She works here for ten years.", "She is working here ten years.", "She worked here since ten years."),
         C("Which word fits: “I have ___ finished my homework.”", "just", "yesterday", "last week", "ago"),
         C("Which is the correct past participle of “write”?", "written", "wrote", "writed", "writing"),
         E("He has went to Paris three times.", "He has been to Paris three times."),
         E("We know each other since 2015.", "We have known each other since 2015."),
         M("Match each word with how it is used.", [["for", "a length of time"], ["since", "a starting point"], ["just", "a very recent action"]]),
         TF("True or false: “I have lived here for six years” means I still live here.", "True"),
         F("Type the missing word: She has lived here ___ 2019.", "since"),
         W("Build the sentence.", "They have known us for years.", "never", "knew"),
         LISTEN("I've worked at this hospital since 2018. I've seen a lot of changes, but I haven't been bored once.", "How long has the speaker worked there?", "Since 2018", "For two weeks", "Until 2018", "Next year"),
         YOUR("Write three sentences about your life using the present perfect with for, since and just."),
     ]),
    ("gram-i-pp", "time", "Present perfect or past simple?", "GRAM-I-02",
     "Use the past simple for a finished time: “I saw that film last year.” Use the present perfect when the time is not given or still connects to now: “I have seen that film” (at some time in my life), “I've lost my keys” (I still don't have them). Do not use the present perfect with finished time words such as yesterday, last week or in 2010. Ask “When?” and you will need the past simple.",
     [
         C("Choose the correct sentence.", "I saw him yesterday.", "I have seen him yesterday.", "I have saw him yesterday.", "I see him yesterday."),
         C("Choose the correct sentence.", "Have you ever been to Japan?", "Did you ever been to Japan?", "Have you ever went to Japan?", "Are you ever been to Japan?"),
         C("Choose the correct sentence.", "She lost her phone, so she can't call you.", "She lose her phone, so she can't call you.", "She has lost her phone yesterday.", "She losed her phone."),
         C("Which time word goes with the past simple?", "last week", "ever", "just", "yet"),
         C("Which time word goes with the present perfect?", "already", "in 2010", "yesterday", "two days ago"),
         E("I have visited Rome in 2018.", "I visited Rome in 2018."),
         E("Did you ever try sushi?", "Have you ever tried sushi?"),
         M("Match each sentence with its tense.", [["I saw her on Monday.", "past simple"], ["I have seen her today.", "present perfect"], ["Did you see him last night?", "a question about finished time"]]),
         TF("True or false: “Yesterday” goes with the present perfect.", "False"),
         F("Type the missing word: Have you ___ been to London?", "ever"),
         W("Build the sentence.", "I have never eaten snails.", "never", "ate"),
         LISTEN("I've lost my keys. I last had them this morning. I was in the kitchen at eight.", "Which sentence uses the present perfect?", "I've lost my keys.", "I was in the kitchen.", "I last had them.", "At eight."),
         YOUR("Write two sentences: one with the present perfect about your life, and one with the past simple about last weekend."),
     ]),
    ("gram-i-cond", "time", "If sentences: real and unreal", "GRAM-I-03",
     "First conditional: if + present, will + base verb, for real possibilities: “If it rains, we'll stay home.” Second conditional: if + past, would + base verb, for unreal or unlikely situations: “If I won the lottery, I would travel.” In the unreal case, use were for all persons in formal English: “If I were you, I'd apologize.” Do not use will in the if-part.",
     [
         C("Choose the correct sentence.", "If it rains, we'll stay home.", "If it will rain, we stay home.", "If it rains, we stayed home.", "If it rain, we'll stay home."),
         C("Choose the correct sentence.", "If I won the lottery, I would travel.", "If I win the lottery, I would travel.", "If I would win the lottery, I travel.", "If I winned the lottery, I would travel."),
         C("Which sentence gives advice?", "If I were you, I'd apologize.", "If I am you, I apologize.", "If I would be you, I apologize.", "If I was you will apologize."),
         C("Which is a real possibility?", "If I have time, I'll call you.", "If I had wings, I would fly.", "If I were a bird, I would sing.", "If I won, I'd cry."),
         C("Which is an unreal situation?", "If I were taller, I would play basketball.", "If I see her, I'll tell her.", "If it snows, we'll ski.", "If you call, I'll answer."),
         E("If it will rain tomorrow, we will stay home.", "If it rains tomorrow, we will stay home."),
         E("If I would have more money, I would buy a house.", "If I had more money, I would buy a house."),
         M("Match each pattern with its use.", [["if + present, will + verb", "a real possibility"], ["if + past, would + verb", "an unreal situation"], ["If I were you, I'd…", "advice"]]),
         TF("True or false: We use “will” in the if-part of a first conditional.", "False"),
         F("Type the missing word: If I ___ you, I would wait.", "were"),
         W("Build the sentence.", "If it rains, I'll stay home.", "never", "will"),
         LISTEN("If I had more time, I would learn the piano. But I work late every night, so I probably won't start this year.", "Does the speaker have more time?", "No", "Yes", "Sometimes", "Only in summer"),
         YOUR("Write one real condition (first conditional) and one unreal wish (second conditional)."),
     ]),
    ("gram-i-passive", "time", "The passive voice", "GRAM-I-04",
     "Use the passive when the action matters more than who did it, or when the doer is unknown: “The window was broken.” Form: be + past participle. Present: “English is spoken here.” Past: “The bridge was built in 1990.” Add by + doer only if it is useful: “The book was written by a student.” Only transitive verbs have a passive; you cannot say “It was happened.”",
     [
         C("Choose the passive sentence.", "The window was broken last night.", "Someone broke the window.", "The window breaks easily.", "A storm broke it."),
         C("Choose the correct form: “English ___ in many countries.”", "is spoken", "speaks", "is speaking", "spoke"),
         C("Choose the correct sentence.", "The bridge was built in 1990.", "The bridge built in 1990.", "The bridge was build in 1990.", "The bridge is built in 1990 yesterday."),
         C("Which sentence needs “by”?", "The book was written by a student.", "The window was broken.", "The letter was sent.", "The door was locked."),
         C("Which verb can NOT be used in the passive?", "happen", "build", "write", "send"),
         E("The cake was ate by the children.", "The cake was eaten by the children."),
         E("A new school is build in our town.", "A new school is being built in our town."),
         M("Match each sentence with its tense.", [["The room is cleaned daily.", "present passive"], ["The room was cleaned yesterday.", "past passive"], ["The room will be cleaned tomorrow.", "future passive"]]),
         TF("True or false: In the passive, the doer must always be mentioned.", "False"),
         F("Type the missing word: The letter ___ sent yesterday.", "was"),
         W("Build the sentence.", "The report was finished on Friday.", "never", "finish"),
         LISTEN("The museum was opened in 1950. It is visited by two million people every year.", "What happened in 1950?", "The museum opened", "A visit ended", "A new law began", "Two million people came"),
         YOUR("Rewrite in the passive: “Workers repaired the road last month.”"),
     ]),
    ("gram-i-relative", "complex", "Relative clauses", "GRAM-I-05",
     "A relative clause adds information about a noun. Use who for people, which for things and that for either in defining clauses: “The woman who lives next door is a doctor.” “The book that I read was long.” Use where for places: “That is the cafe where we met.” Use commas around extra information, and use which, not that: “My car, which is old, still runs.” You can leave out who/which/that when it is the object: “The film (that) we saw was great.”",
     [
         C("Choose the correct sentence.", "The man who called you is my uncle.", "The man which called you is my uncle.", "The man where called you is my uncle.", "The man whose called you is my uncle."),
         C("Choose the correct sentence.", "This is the cafe where we met.", "This is the cafe who we met.", "This is the cafe which we met there.", "This is the cafe whom we met."),
         C("Which sentence has extra information with commas?", "My car, which is old, still runs.", "My car, that is old, still runs.", "My car, who is old, still runs.", "My car, where is old, still runs."),
         C("Which word can be left out?", "The film (that) we saw was great.", "The woman who lives here is kind.", "The man who called is tall.", "The girl who sings is my sister."),
         C("Which word is for people?", "who", "which", "where", "when"),
         E("The book who I read was long.", "The book that I read was long."),
         E("I know a place which you can swim there.", "I know a place where you can swim."),
         M("Match each word with its use.", [["who", "people"], ["which", "things"], ["where", "places"]]),
         TF("True or false: “That” can replace “which” in a clause with commas.", "False"),
         F("Type the missing word: That is the school ___ I studied.", "where"),
         W("Build the sentence.", "The woman who lives here is a doctor.", "never", "which"),
         LISTEN("The restaurant where we had lunch was recommended by a friend who loves seafood.", "Who recommended the restaurant?", "A friend who loves seafood", "The waiter", "A newspaper", "The speaker"),
         YOUR("Combine into one sentence with a relative clause: “I met a man. He works at the airport.”"),
     ]),
    ("gram-i-reported", "complex", "Reported speech", "GRAM-I-06",
     "When we report what someone said, the tense usually moves back one step: “I am tired” becomes She said (that) she was tired. Present simple becomes past simple; will becomes would; can becomes could. Pronouns and time words change too: “I will come tomorrow” becomes He said he would come the next day. For questions use if or the question word, and normal word order: “Where do you live?” becomes She asked where I lived.",
     [
         C("Choose the correct report: “I am tired,” she said.", "She said she was tired.", "She said she is tired.", "She said I was tired.", "She said her tired."),
         C("Choose the correct report: “I will call you,” he said.", "He said he would call me.", "He said he will call you.", "He said I would call him.", "He said he calls me."),
         C("Choose the correct report: “Where do you live?” she asked.", "She asked where I lived.", "She asked where did I live.", "She asked where do I live.", "She asked me live where."),
         C("“I can swim.” becomes…", "He said he could swim.", "He said he can swim.", "He said I can swim.", "He said he swims can."),
         C("“I'll come tomorrow.” becomes…", "He said he would come the next day.", "He said he will come tomorrow.", "He said I come tomorrow.", "He said he came the next day."),
         E("She said me that she was late.", "She told me that she was late."),
         E("He asked me where did I work.", "He asked me where I worked."),
         M("Match each direct speech with its reported form.", [["I am tired", "she was tired"], ["I will go", "he would go"], ["I can drive", "she could drive"]]),
         TF("True or false: In reported questions the word order is the same as in a statement.", "True"),
         F("Type the missing word: She said she ___ tired.", "was"),
         W("Build the sentence.", "He asked if I was ready.", "never", "am"),
         LISTEN("She told me that she would call the next day, and she asked if I could meet her on Friday.", "What did she ask?", "If I could meet her on Friday", "If I would call", "Where I lived", "Who called"),
         YOUR("Report these words: “I'm leaving tomorrow,” said Tom. “Do you need help?” asked Ana."),
     ]),
    ("gram-i-deduce", "complex", "Must, might and can't", "GRAM-I-07",
     "Use modal verbs to say how sure you are. Must means you are almost certain it is true: “He must be tired; he worked all night.” Might or may means it is possible: “She might be at home.” Can't means you are almost certain it is false: “That can't be his coat; it is too small.” For the past use modal + have + past participle: “He must have left.” “She can't have known.”",
     [
         C("Choose the best sentence: He worked all night, so he ___ tired.", "must be", "can't be", "might not", "will being"),
         C("Choose the best sentence: That coat is too small, so it ___ his.", "can't be", "must be", "might being", "will be"),
         C("Which sentence shows a possibility?", "She might be at home.", "She must be at home.", "She can't be at home.", "She is home."),
         C("Choose the correct past form: “He ___ left; his coat is gone.”", "must have", "must", "can have", "might to have"),
         C("Which means you are almost sure it is NOT true?", "She can't have known.", "She must have known.", "She might have known.", "She could know."),
         E("He must to be tired.", "He must be tired."),
         E("She can't knew the answer.", "She can't have known the answer."),
         M("Match each modal with how sure it is.", [["must", "almost certain it is true"], ["might", "possible"], ["can't", "almost certain it is false"]]),
         TF("True or false: “Must” can show that you are almost certain something is true.", "True"),
         F("Type the missing word: It ___ be Tom; he is abroad.", "can't", "cannot"),
         W("Build the sentence.", "She might be at home.", "never", "being"),
         LISTEN("The lights are on, so someone must be home. But nobody answers. They might be asleep, or they might not want visitors.", "How sure is the speaker that someone is home?", "Almost sure", "Not sure at all", "Certain it is empty", "Sure nobody is there"),
         YOUR("Write three guesses about why a friend is late, using must, might and can't."),
     ]),
    ("gram-i-link", "complex", "Link ideas: although, however, despite", "GRAM-I-08",
     "Use linking words to connect contrasting ideas. Although, even though and while introduce a clause: “Although it was raining, we went out.” Despite and in spite of are followed by a noun or -ing: “Despite the rain, we went out.” However and nevertheless start a new sentence and take a comma: “It was raining. However, we went out.” Use because and so for reasons and results, and therefore for a formal result.",
     [
         C("Choose the correct sentence.", "Although it was cold, we went swimming.", "Although it was cold, but we went swimming.", "Despite it was cold, we went swimming.", "Although the cold, we went swimming."),
         C("Choose the correct sentence.", "Despite the rain, we went out.", "Despite it rained, we went out.", "Despite of the rain, we went out.", "Despite the rain but we went out."),
         C("Choose the correct sentence.", "It was late. However, we kept working.", "It was late. Although, we kept working.", "It was late. But however, we kept working.", "However it was late we kept. Working."),
         C("Which word shows a result?", "so", "although", "despite", "however"),
         C("Which is more formal for a result?", "therefore", "so", "and", "but"),
         E("Despite he was tired, he kept running.", "Despite being tired, he kept running."),
         E("Although he was ill, but he went to work.", "Although he was ill, he went to work."),
         M("Match each word with its use.", [["although", "introduces a clause of contrast"], ["despite", "is followed by a noun or -ing"], ["therefore", "shows a formal result"]]),
         TF("True or false: “Although” and “but” can be used together in one sentence.", "False"),
         F("Type the missing word: ___ the rain, we went out.", "despite", "in spite of"),
         W("Build the sentence.", "Although it was late, we kept working.", "never", "but"),
         LISTEN("The train was delayed. However, we reached the meeting on time because the taxi was fast.", "Which word shows contrast?", "However", "Because", "Time", "Taxi"),
         YOUR("Write one sentence with although and one with despite about the same situation."),
     ]),
]

if __name__ == "__main__":
    add_stage("grammarian", STAGE, LESSONS, "Intermediate", SOURCES)
