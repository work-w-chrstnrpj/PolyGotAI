#!/usr/bin/env python3
"""Build the Reading & Listening track (Starter stage, 2 units x 4 lessons): Resources/Tracks/track-reading-listening.json.

All passages, questions and tips are original wording. Listening items are read aloud by the on-device voice.
Run from the project root: python3 tools/curriculum/build_reading_listening.py
"""
from track_lib import C, TF, READ, LISTEN, W, F, O, M, L, YOUR, build_manifest, write_track

SOURCES = [
    "CEFR Companion Volume (reading and listening descriptors, A1-A2)",
    "Plain-language reading practice conventions (gist, detail, scanning); texts written for this app",
]

STAGES = [{"id": "starter", "title": "Starter", "units": [
    {"id": "gist-detail", "title": "Gist and detail"},
    {"id": "meaning", "title": "Main idea and meaning"},
]}]

BAKERY = "Sara opens a small bakery on Main Street. She bakes bread and cakes every morning. Many people come before work to buy fresh bread. Sara is tired, but she loves her job."
PHONE = "Tom lost his phone on the bus. He looked in his bag and his coat. Then he called his number from a friend's phone. A girl on the bus answered and gave the phone back."
LIBRARY = "The library will close early on Friday because of a staff meeting. It will close at 3 p.m. instead of 6 p.m. The library will open as usual on Saturday."
HOLIDAY = "Hi Mia! I'm in Lisbon with my family. The weather is warm and the food is great. Yesterday we visited an old castle. See you next week. Love, Ben."
TRIP = "The school trip is on Thursday. Students meet at the front gate at 8:15 a.m. The bus goes to the science museum. Students bring a packed lunch and a bottle of water. The bus comes back at 3:30 p.m."
GARDEN = "Lena has a small garden behind her house. She grows tomatoes, beans and flowers. Every evening she waters the plants. Last week a rabbit ate her lettuce, so now she has a fence."
HOURS = "Opening hours: Monday to Friday 9:00 a.m. to 6:00 p.m. Saturday 10:00 a.m. to 4:00 p.m. Sunday closed. Phone: 555-0142. Address: 12 Oak Road."
TICKETS = "Adult ticket: $4. Child ticket (under 12): $2. Day pass: $9. Children under 5 travel free."
MARKET = "Spring Market. Saturday 14 April. Stalls open at 9:00 a.m. Free parking at the Town Hall. Live music from 2:00 p.m."
WALK = "Walking is a good way to stay healthy. It is free, and you can do it anywhere. A short walk each day helps your heart and your mood. You do not need special shoes or a gym."
PETS = "Many people think cats and dogs cannot be friends. But in my house they sleep on the same bed. They play together in the garden. They even share the same food bowl."
LIB2 = "Our town library now offers more than books. You can borrow board games and tools. There is a free class for children every Saturday. Older people can learn to use a computer on Wednesday mornings."
RICE = "Rice is eaten in many countries. In Japan it is served with fish. In India it is cooked with spices. In Mexico it is often served with beans."
PARK = "The new park opened in May. It has 40 trees and two playgrounds. I think it is the most beautiful place in the city."

LESSONS = [
    ("rl-gist-read", "gist-detail", "Read for the gist", "RL-S-01",
     "The gist is the big idea of a text: what it is mostly about. Before you look for small facts, read the whole text once, quickly, and ask, “What is this about?” Do not stop for every new word.",
     [
         READ(BAKERY, "What is this text mostly about?", "Sara and her bakery", "A new street in town", "How to bake a cake", "People who are late for work"),
         READ(PHONE, "What is the gist of this story?", "Tom gets his lost phone back", "Tom buys a new phone", "A girl loses her bag", "The bus driver is late"),
         READ(LIBRARY, "What is the gist of this notice?", "The library closes early on one day", "The library is closing forever", "The library opens late on Saturday", "A new library opens on Friday"),
         READ(HOLIDAY, "What is the gist of this message?", "Ben tells Mia about his holiday", "Ben asks Mia for help", "Ben says he is sick", "Ben invites Mia to dinner"),
         READ(BAKERY, "Which title fits this text best?", "Sara's Bakery", "A Rainy Day", "A Trip to Lisbon", "The Quiet Library"),
         LISTEN("Welcome to the city museum. The museum is open every day from nine to five. Tickets are free for children.", "What is the gist?",
                "Information about a museum", "A story about a child", "A weather report", "A shopping list"),
         TF("True or false: The gist is the same as every small detail.", "False"),
         O("Put the steps in order.", ["Read the whole text once, quickly", "Ask yourself what it is mostly about", "Then look for small details"]),
         M("Match each sign with its gist.", [["Closed on Sunday", "The shop is not open on Sunday"], ["Back in ten minutes", "The person will return soon"], ["Wet floor", "Be careful where you walk"]]),
         F("Type the missing word: The gist is the main ___ of a text.", "idea"),
         W("Build the sentence.", "Read once for the gist.", "twice", "detail"),
         C("You meet a new word while you read for the gist. What should you do?", "Keep reading and think about the whole text", "Stop and look up every word", "Start again from the beginning", "Write the word ten times"),
         YOUR("Read a short text in English today. Write one sentence: what is it mostly about?"),
     ]),
    ("rl-detail-find", "gist-detail", "Find the detail", "RL-S-02",
     "A detail is one small fact: a name, a place, a time, a reason. Read the question first. Then read the text again and look for the words that answer it. Question words such as who, when and where tell you what kind of detail to find.",
     [
         READ(TRIP, "Where do students meet?", "At the front gate", "At the science museum", "On the bus", "In the classroom"),
         READ(TRIP, "What time does the bus come back?", "3:30 p.m.", "8:15 a.m.", "12:00 p.m.", "5:00 p.m."),
         READ(TRIP, "What do students bring?", "A packed lunch and a bottle of water", "Money for the museum café", "A hot meal from school", "Nothing at all"),
         READ(GARDEN, "Why does Lena have a fence?", "A rabbit ate her lettuce", "She likes the color", "Her neighbor asked her", "It rains a lot"),
         READ(GARDEN, "When does Lena water the plants?", "Every evening", "Every morning", "Once a week", "Only on Sunday"),
         READ(GARDEN, "Which plant does Lena grow?", "Beans", "Rice", "Apples", "Carrots"),
         LISTEN("The train to Boston leaves from platform four at ten past nine. Please have your ticket ready.", "Which platform does the train leave from?",
                "Platform four", "Platform ten", "Platform nine", "Platform five"),
         LISTEN("The train to Boston leaves from platform four at ten past nine. Please have your ticket ready.", "What time does the train leave?",
                "Ten past nine", "Ten to nine", "Nine thirty", "Four o'clock"),
         TF("True or false: To find a detail, you read the question first.", "True"),
         F("Type the missing question word: ___ do students meet? At the front gate.", "Where"),
         M("Match each question word with the detail it asks for.", [["Who", "a person"], ["When", "a time"], ["Where", "a place"], ["Why", "a reason"]]),
         O("Put the steps in order.", ["Read the question", "Find the matching words in the text", "Check that the answer fits"]),
         W("Build the sentence.", "Read the question first.", "last", "text"),
         YOUR("Write two questions about a text you read today, one with “who” and one with “when”. Then answer them."),
     ]),
    ("rl-scan-facts", "gist-detail", "Scan for facts", "RL-S-03",
     "To scan, move your eyes over the text and look for only one thing, such as a number, a name or a day. You do not read every word. Look for capital letters (names), digits (numbers) and special words like Monday.",
     [
         READ(HOURS, "What time does the shop open on Saturday?", "10:00 a.m.", "9:00 a.m.", "4:00 p.m.", "6:00 p.m."),
         READ(HOURS, "Which day is the shop closed?", "Sunday", "Saturday", "Monday", "Friday"),
         READ(HOURS, "What is the phone number?", "555-0142", "12 Oak Road", "9:00 a.m.", "555-0124"),
         READ(HOURS, "Which road is the shop on?", "Oak Road", "Main Road", "Elm Road", "Pine Road"),
         READ(TICKETS, "How much is a day pass?", "$9", "$4", "$2", "Free"),
         READ(TICKETS, "How much is a child ticket?", "$2", "$4", "$9", "Free"),
         READ(TICKETS, "Who travels free?", "Children under 5", "Children under 12", "All adults", "Nobody"),
         READ(MARKET, "On which day is the market?", "Saturday 14 April", "Sunday 14 April", "Saturday 4 April", "Friday 14 April"),
         READ(MARKET, "Where is the free parking?", "At the Town Hall", "At the market stalls", "On Oak Road", "At the library"),
         LISTEN("The flight to Rome is delayed by forty minutes. The new departure time is eleven fifteen.", "What is the new departure time?",
                "Eleven fifteen", "Eleven fifty", "Ten forty", "Forty minutes past ten"),
         TF("True or false: When you scan, you read every word.", "False"),
         F("Type the missing word: When you ___, you look for one thing only.", "scan"),
         C("You want to find a phone number in a long text. What do you look for?", "A group of digits", "A long word", "A capital letter", "A question mark"),
         M("Match what you look for with a clue.", [["A name", "a capital letter"], ["A price", "a dollar sign"], ["A time", "numbers with a colon"]]),
         O("Put the steps in order.", ["Decide what you are looking for", "Move your eyes quickly over the text", "Stop when you see the number, name or day"]),
         YOUR("Look at a bus timetable, a menu or a shop sign. Write one fact you found by scanning."),
     ]),
    ("rl-listen-key", "gist-detail", "Listen for key words", "RL-S-04",
     "When you listen, you cannot go back, so listen for the key words: the important names, numbers, places and actions. Little words like “the” and “a” are quiet and quick. Ask yourself: who is speaking, what do they want, and when or where?",
     [
         LISTEN("Hi, this is Dana from the dentist's office. Your appointment is on Tuesday at four o'clock. Please call us if you cannot come.", "Who is calling?",
                "Dana from the dentist's office", "A friend from school", "A teacher", "A taxi driver"),
         LISTEN("Hi, this is Dana from the dentist's office. Your appointment is on Tuesday at four o'clock. Please call us if you cannot come.", "When is the appointment?",
                "Tuesday at four o'clock", "Thursday at four o'clock", "Tuesday at ten o'clock", "Friday morning"),
         LISTEN("Hi, this is Dana from the dentist's office. Your appointment is on Tuesday at four o'clock. Please call us if you cannot come.", "What should you do if you cannot come?",
                "Call the office", "Send a letter", "Come anyway", "Wait for a text"),
         LISTEN("Attention, passengers. The bus to the airport leaves from stop five, not stop two. It leaves in ten minutes.", "Which stop does the bus leave from?",
                "Stop five", "Stop two", "Stop ten", "Stop one"),
         LISTEN("Attention, passengers. The bus to the airport leaves from stop five, not stop two. It leaves in ten minutes.", "Where does the bus go?",
                "To the airport", "To the station", "To the beach", "To the hospital"),
         LISTEN("I'd like a large coffee with milk and two sugars, please.", "What does the customer order?",
                "A large coffee with milk and sugar", "A small tea with lemon", "A glass of juice", "A coffee with no sugar"),
         L("The shop opens at nine thirty."),
         L("Turn left at the school."),
         TF("True or false: When you listen, you must understand every word.", "False"),
         C("Which words should you listen for most?", "Key words like names, numbers and places", "Words like “the” and “a”", "Only the first word", "Only the last word"),
         F("Type the missing word: Listen for key ___, not every word.", "words"),
         M("Match each question with what you listen for.", [["How many?", "a number"], ["Who?", "a name"], ["Where?", "a place"]]),
         O("Put the steps in order.", ["Read the question before you listen", "Listen once for the key words", "Listen again to check your answer"]),
         YOUR("Listen to a short announcement or a voice message today. Write down three key words you heard."),
     ]),
    ("rl-main-idea", "meaning", "Find the main idea", "RL-S-05",
     "The main idea is the one most important point of a text. The details support it. To find it, look at the first sentence, the last sentence, and the idea that most sentences are about.",
     [
         READ(WALK, "What is the main idea?", "Walking is a good way to stay healthy", "Special shoes are expensive", "Gyms are better than walking", "Walking is only for older people"),
         READ(WALK, "Which sentence gives the main idea, not a detail?", "Walking is a good way to stay healthy.", "It is free, and you can do it anywhere.", "A short walk each day helps your heart and your mood.", "You do not need special shoes or a gym."),
         READ(PETS, "What is the main idea?", "A cat and a dog can be good friends", "Cats are bigger than dogs", "Dogs do not like gardens", "Food bowls are expensive"),
         READ(LIB2, "What is the main idea?", "The library offers many things besides books", "The library only lends books", "The library is closed on Saturday", "The library is for children only"),
         READ(RICE, "Which title fits best?", "Rice around the world", "How to cook fish", "Beans in Mexico", "Spices in India"),
         LISTEN("Good sleep is important for students. When you sleep well, you remember more and feel happier. Try to go to bed at the same time every night.", "What is the main idea?",
                "Good sleep helps students", "Students should study at night", "Students should eat more", "Students need new beds"),
         TF("True or false: The main idea is usually a small detail.", "False"),
         F("Type the missing word: Details ___ the main idea.", "support"),
         O("Put the steps in order.", ["Read the whole text", "Ask what most sentences are about", "Say the main idea in one sentence"]),
         C("Where can you often find the main idea?", "In the first or last sentence", "In every small word", "Only in the title", "Never in the text"),
         M("Match each part of a text with its job.", [["Main idea", "the most important point"], ["Detail", "a fact that supports it"], ["Title", "a short name for the whole text"]]),
         W("Build the sentence.", "Details support the main idea.", "break", "small"),
         YOUR("Read a short article or post today. Write its main idea in one sentence."),
     ]),
    ("rl-context-meaning", "meaning", "Guess meaning from context", "RL-S-06",
     "When you meet a new word, do not stop. Look at the words around it. They often give a clue: a similar word, an opposite word, or an example. Then guess the meaning and check that the sentence still makes sense.",
     [
         READ("The soup was so scorching that I burned my tongue. I had to wait ten minutes before I could eat it.", "What does “scorching” mean?", "Very hot", "Very cold", "Very salty", "Very old"),
         READ("Maria is quite timid. She never speaks in class and she hides when guests arrive.", "What does “timid” mean?", "Shy and afraid", "Loud and funny", "Angry and rude", "Tall and strong"),
         READ("The road was narrow, so only one car could pass at a time.", "What does “narrow” mean?", "Not wide", "Very long", "Very new", "Full of cars"),
         READ("He was exhausted after the race. He lay on the grass and could not move.", "What does “exhausted” mean?", "Very tired", "Very happy", "Very hungry", "Very quick"),
         READ("It was a gloomy morning. The sky was dark and grey, and everyone felt sad.", "What does “gloomy” mean?", "Dark and sad", "Bright and warm", "Loud and busy", "Clean and new"),
         LISTEN("The weather was dreadful. It rained all day, and the wind was so strong that trees fell down.", "What does “dreadful” mean?", "Very bad", "Very nice", "Very short", "Very quiet"),
         C("In “The soup was scorching; I burned my tongue,” which words give the clue?", "I burned my tongue", "The soup", "My", "Was"),
         F("Type the missing word: The words around a new word give a ___.", "clue"),
         TF("True or false: You should always stop reading to look up a new word.", "False"),
         O("Put the steps in order.", ["Read the sentence around the word", "Look for a clue", "Guess the meaning", "Check that the sentence makes sense"]),
         M("Match each kind of clue with an example.", [["An opposite", "small, not big"], ["An example", "fruit, such as apples"], ["A similar word", "tiny, or very small"]]),
         W("Build the sentence.", "Look at the words around it.", "inside", "far"),
         YOUR("Find a new word in a text today. Write the word, your guess of its meaning, and the clue that helped you."),
     ]),
    ("rl-signal-words", "meaning", "Signal words", "RL-S-07",
     "Small words join ideas and tell you what comes next. “And” adds, “but” shows a difference, “because” gives a reason, and “so” gives a result. Notice them when you read or listen.",
     [
         C("Fill the gap: I was tired, ___ I went to bed early.", "so", "but", "or", "if"),
         C("Fill the gap: I like tea, ___ I do not like coffee.", "but", "so", "because", "or"),
         C("Fill the gap: He stayed home ___ it was raining.", "because", "but", "or", "so"),
         C("Fill the gap: Do you want pizza ___ pasta?", "or", "so", "because", "but"),
         READ("Ana wanted to play outside, but it was raining. Because the rain was heavy, she stayed inside, so she read a book.", "Why did Ana stay inside?", "It was raining heavily", "She was tired", "She had no friends", "Her book was new"),
         READ("Ana wanted to play outside, but it was raining. Because the rain was heavy, she stayed inside, so she read a book.", "Which word shows a result?", "so", "but", "because", "outside"),
         LISTEN("The train was late, so I missed my bus. But I called my friend, and she gave me a ride.", "Why did the speaker miss the bus?", "The train was late", "The speaker was asleep", "The bus was early", "The friend was late"),
         LISTEN("The train was late, so I missed my bus. But I called my friend, and she gave me a ride.", "What happened after the speaker called a friend?", "The friend gave a ride", "The friend was angry", "The bus came", "The speaker walked"),
         M("Match each signal word with its job.", [["and", "adds an idea"], ["but", "shows a difference"], ["because", "gives a reason"], ["so", "gives a result"]]),
         W("Build the sentence.", "I was cold, so I wore a jacket.", "but", "because"),
         W("Build the sentence.", "She is tired because she worked all day.", "so", "but"),
         TF("True or false: “But” shows a difference.", "True"),
         F("Type the missing word: “Because” gives a ___.", "reason"),
         YOUR("Write three sentences about your day. Use “so”, “but” and “because” once each."),
     ]),
    ("rl-fact-opinion", "meaning", "Fact or opinion?", "RL-S-08",
     "A fact can be checked: it is true or false. An opinion says what someone thinks or feels, and people can disagree. Words such as “I think”, “best”, “beautiful” and “should” often signal an opinion.",
     [
         C("Which sentence is a fact?", "Water boils at 100 degrees Celsius.", "Summer is the best season.", "Dogs are better than cats.", "This music is beautiful."),
         C("Which sentence is an opinion?", "This soup is delicious.", "The soup is hot.", "The soup has carrots.", "I made the soup on Monday."),
         C("Which sentence is a fact?", "The library opens at nine.", "The library is boring.", "The library should be bigger.", "The library is the best place."),
         C("Which word often signals an opinion?", "best", "Monday", "seven", "river"),
         C("Which sentence is an opinion?", "Everyone should learn to swim.", "Swimming is a sport.", "Pools have water.", "I swam on Friday."),
         READ(PARK, "Which sentence is an opinion?", "I think it is the most beautiful place in the city.", "The new park opened in May.", "It has 40 trees and two playgrounds.", "The park is in the city."),
         READ(PARK, "Which sentence is a fact?", "It has 40 trees and two playgrounds.", "It is the most beautiful place in the city.", "Everyone should visit it.", "It is better than the old park."),
         LISTEN("My brother is eighteen. He thinks pizza is the best food in the world.", "Which part is an opinion?", "Pizza is the best food in the world", "My brother is eighteen", "He is my brother", "He eats food"),
         TF("True or false: People can check a fact.", "True"),
         TF("True or false: “I think” often shows an opinion.", "True"),
         M("Match each word with its meaning.", [["Fact", "can be checked"], ["Opinion", "what someone thinks"], ["Signal word", "a clue such as “I think” or “best”"]]),
         F("Type the missing word: A fact can be ___.", "checked", "proved", "proven", "tested"),
         W("Build the sentence.", "Facts can be checked.", "opinions", "never"),
         YOUR("Write one fact and one opinion about your town."),
     ]),
]

if __name__ == "__main__":
    manifest = build_manifest("reading-listening", "readingListening", STAGES, LESSONS, "Starter", SOURCES)
    write_track("reading-listening", manifest)
