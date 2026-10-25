#!/usr/bin/env python3
"""Reading & Listening Comprehension, Intermediate stage (about B1-B2): 2 units x 4 lessons, added to track-reading-listening.json.

Original wording and original passages. Ideas (inference, purpose and tone, argument structure, summary, stress and attitude,
lecture notes, comparing sources, bias) are standard teaching concepts; sources credited for ideas only.
Run from the project root: python3 tools/curriculum/stages/reading_listening_intermediate.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from track_lib import C, TF, READ, LISTEN, W, F, O, M, YOUR, add_stage  # noqa: E402

SOURCES = [
    "British Council-EAQUALS Core Inventory for General English (topic order and level)",
    "CEFR Companion Volume (reading and listening descriptors, B1-B2)",
]

STAGE = {"id": "intermediate", "title": "Intermediate", "units": [
    {"id": "infer", "title": "Read between the lines"},
    {"id": "listen2", "title": "Listen for meaning"},
]}

SHOP = "The owner of the corner shop put a handwritten sign on the door: “Back in ten minutes.” An hour later the shutters were still down, and a pile of letters had grown on the step."
TRAIN = "A new train line will open next year, and supporters say it will cut travel time by half. Critics point out that tickets will cost twice as much, and that three villages will lose their bus service. The company says it will review prices after one year."
PARK = "The city plans to close the old market and turn it into a car park. Shop owners say customers will not walk far from the car park. The mayor says parking is the biggest complaint she hears from residents."
AD = "Don't miss out! Thousands of happy customers have already switched to Brightline. Our unbeatable plan is the smartest choice for anyone who values their time. Join the winning team today."
PAPER1 = "Local paper: The council approved the new bike lane by seven votes to four after a three-hour debate. The lane will cost 300,000 dollars and open in June."
PAPER2 = "Blog post: The council forced through a pointless bike lane that wastes 300,000 dollars of our money. Residents were ignored."

LESSONS = [
    ("rl-i-infer", "infer", "Read between the lines", "RL-I-01",
     "A writer does not always say everything. An inference is a conclusion you reach from clues in the text plus what you already know. When a shop sign says “Back in ten minutes” but an hour has passed and letters are piling up, you can infer that the owner is away longer than planned. Check that your inference fits all the clues, and avoid going beyond them.",
     [
         READ(SHOP, "What can you reasonably infer from the passage?", "The owner has been away longer than planned.", "The shop was robbed.", "The owner likes letters.", "The shop sells sign boards."),
         READ(SHOP, "Which clue supports your inference?", "The shutters were still down an hour later.", "The sign was handwritten.", "The shop is on a corner.", "The letters were small."),
         C("What is an inference?", "A conclusion based on clues plus what you know", "A direct quote", "A guess with no clues", "A title"),
         C("Which inference is too far?", "The owner has been kidnapped.", "The owner is late.", "The owner is away.", "The owner forgot the time."),
         C("What should you check?", "That the inference fits all the clues", "That it is exciting", "That it is long", "That it is a quote"),
         M("Match each clue with a fair inference.", [["Wet umbrella by the door", "it has been raining"], ["Empty plate and crumbs", "someone has eaten"], ["Packed suitcase", "someone is about to travel"]]),
         TF("True or false: An inference should fit all the clues in the text.", "True"),
         TF("True or false: You can draw any conclusion you like.", "False"),
         F("Type the missing word: An ___ comes from clues plus what you know.", "inference"),
         W("Build the sentence.", "The clues suggest he is late.", "never", "suggested"),
         LISTEN("Her coat was wet, her bag was heavy, and she kept looking at the clock. Maybe she was late for something important.", "What does the speaker infer?", "She was in a hurry", "She was bored", "She liked the rain", "She lost her coat"),
         O("Put the steps in order.", ["Notice the clues", "Think about what they suggest", "Check that your conclusion fits every clue"]),
         YOUR("Write a three-sentence scene with clues, and then one inference a reader could make."),
     ]),
    ("rl-i-purpose", "infer", "Purpose and tone", "RL-I-02",
     "Every text has a purpose: to inform, persuade, entertain or warn. Tone is the writer's attitude: neutral, enthusiastic, critical, humorous. Look at the word choice. “A tragic mistake” is critical; “a few changes” is neutral. An ad wants you to act; a report wants you to understand. Asking “Why was this written?” helps you decide how far to trust it.",
     [
         READ(AD, "What is the purpose of this text?", "To persuade people to buy a service", "To report the news", "To warn about danger", "To teach grammar"),
         READ(AD, "Which word shows an enthusiastic tone?", "unbeatable", "switched", "plan", "customers"),
         READ(TRAIN, "What is the tone of this passage?", "Neutral, giving both sides", "Angry", "Joking", "Excited"),
         C("Which phrase sounds critical?", "a tragic mistake", "a few changes", "a plan", "a meeting"),
         C("Which phrase sounds neutral?", "a few changes", "a disaster", "a miracle", "a scandal"),
         C("Why ask “Why was this written?”", "It helps you decide how far to trust it.", "It changes the text.", "It saves time.", "It makes the text shorter."),
         M("Match each text with its likely purpose.", [["An advertisement", "to persuade"], ["A news report", "to inform"], ["A warning sign", "to warn"]]),
         TF("True or false: Word choice can show the writer's attitude.", "True"),
         F("Type the missing word: The writer's attitude is the ___.", "tone"),
         W("Build the sentence.", "The purpose is to inform readers.", "never", "informs"),
         LISTEN("What a wonderful, life-changing product! You simply must buy it today before it sells out.", "What is the speaker's purpose?", "To persuade", "To inform neutrally", "To warn", "To apologize"),
         O("Put the steps in order.", ["Read the text", "Notice the word choice", "Decide the purpose and tone"]),
         YOUR("Write two short sentences about the same park: one with a neutral tone and one with an enthusiastic tone."),
     ]),
    ("rl-i-argument", "infer", "Follow an argument", "RL-I-03",
     "An argument has a claim, reasons and sometimes a counterclaim. To follow it, find the claim first: what does the writer want you to accept? Then find the reasons and the evidence. Words like because, since and therefore signal reasons. But, however and although signal a different view. A strong text answers the other side. Ask: do the reasons actually support the claim?",
     [
         READ(PARK, "What is the mayor's main reason?", "Residents complain about parking more than anything else.", "Shop owners like the market.", "The market is old.", "Customers walk far."),
         READ(PARK, "What do the shop owners fear?", "Shoppers will not want to walk from the car park to the stalls.", "The mayor will resign.", "The market will move.", "The city will grow."),
         C("What is a claim?", "What the writer wants you to accept", "A fact from a table", "The title", "A date"),
         C("Which word signals a reason?", "because", "however", "although", "but"),
         C("Which word signals a different view?", "however", "since", "therefore", "because"),
         M("Match each word with its job.", [["Because", "gives a reason"], ["Therefore", "gives a result"], ["However", "turns to a different view"]]),
         O("Put the reading steps in order.", ["Find the claim", "Find the reasons and evidence", "Decide if they support the claim"]),
         TF("True or false: A strong text answers the other side.", "True"),
         TF("True or false: Every reason in a text supports the claim well.", "False"),
         F("Type the missing word: Look for the claim ___.", "first"),
         W("Build the sentence.", "The reason supports the claim.", "never", "supporting"),
         LISTEN("We should keep the library open on Sundays because many students work during the week. Some say it costs too much. However, the extra cost is small compared with the benefit.", "What is the speaker's claim?", "The library should open on Sundays", "The library costs too much", "Students should not work", "Sundays are quiet"),
         LISTEN("We should keep the library open on Sundays because many students work during the week. Some say it costs too much. However, the extra cost is small compared with the benefit.", "Which word turns to a different view?", "However", "Because", "Some", "Week"),
         YOUR("Write a claim and two reasons about whether schools should start later."),
     ]),
    ("rl-i-summary", "infer", "Summarize a text", "RL-I-04",
     "A summary gives the main points in your own words, much shorter than the original. Find the main idea, then the two or three key supports. Leave out examples, repetition and small details. Do not add your opinion. Use reporting phrases: “The writer argues that…” “According to the report…”. A good summary can be understood without reading the original.",
     [
         READ(TRAIN, "Which is the best summary?", "A new train line will be faster, but tickets will cost more and some villages will lose buses.", "Trains are fun.", "The company will review prices, and that is all.", "Critics are always wrong."),
         C("What does a summary contain?", "The main idea and key supports", "Every example", "The writer's biography", "The full text"),
         C("What should you leave out?", "Examples and small details", "The main idea", "The key reasons", "The conclusion"),
         C("Which phrase begins a summary?", "The writer argues that…", "I personally think…", "Once upon a time…", "Wow…"),
         C("Should you add your opinion to a summary?", "No", "Yes, always", "Only in the first line", "Only in the last line"),
         M("Match each part with whether it belongs in a summary.", [["Main idea", "keep"], ["A long example", "leave out"], ["Your own opinion", "do not add"]]),
         O("Put the steps in order.", ["Find the main idea", "Find two or three key supports", "Write them in your own words"]),
         TF("True or false: A good summary can be understood without the original.", "True"),
         F("Type the missing word: According to the report, prices will ___.", "rise", "increase", "go up"),
         W("Build the sentence.", "The writer argues that prices will rise.", "never", "argue"),
         LISTEN("The talk was about sleep. The speaker said that adults need seven to nine hours, that bad sleep hurts memory, and that a fixed bedtime helps. She gave a long example about her own family.", "What is the best summary?", "Adults need enough sleep, which helps memory; a fixed bedtime helps.", "A story about a family", "Sleep is boring", "Bedtime is at nine"),
         YOUR("Write a two-sentence summary of a news story or article you read recently."),
     ]),
    ("rl-i-stress", "listen2", "Listen for attitude", "RL-I-05",
     "In speech, how something is said can change its meaning. Stress on a word shows what matters most: “I didn't say HE took it” differs from “I didn't SAY he took it.” Rising intonation at the end often shows a question or doubt; falling intonation shows a statement or certainty. A speaker who says “Oh, great” with a flat voice may not be happy at all. Listen for tone as well as words.",
     [
         LISTEN("Oh, great. Another meeting at seven in the morning.", "How does the speaker probably feel?", "Annoyed", "Delighted", "Proud", "Curious"),
         LISTEN("It's fine. Really. I'm fine. (said quietly with a sigh)", "What does the sigh suggest?", "The speaker is not really fine", "The speaker is delighted", "The speaker is angry at the sun", "The speaker is asleep"),
         C("What does rising intonation at the end often show?", "A question or doubt", "A command", "A joke only", "The end of a story"),
         C("What does falling intonation often show?", "A statement or certainty", "A question", "Surprise", "Silence"),
         C("What does stress on a word show?", "What matters most", "The speaker's age", "The topic", "The place"),
         M("Match each clue with its meaning.", [["Stress on a word", "shows what matters most"], ["Rising ending", "often shows a question"], ["A sigh", "may show tiredness or annoyance"]]),
         TF("True or false: Tone can change the meaning of the same words.", "True"),
         TF("True or false: Only the words matter, never the tone.", "False"),
         F("Type the missing word: Listen for tone as well as ___.", "words"),
         W("Build the sentence.", "She sounded annoyed, not happy.", "never", "annoy"),
         O("Put the listening steps in order.", ["Hear the words", "Notice the stress and tone", "Decide what the speaker feels"]),
         LISTEN("You are coming to the party? (rising voice, surprised)", "What does the rising voice suggest?", "Surprise or a question", "A command", "A refusal", "Anger"),
         YOUR("Write the sentence “That is a great idea” in two ways: once sincere and once sarcastic, and describe the voice."),
     ]),
    ("rl-i-lecture", "listen2", "Notes from a talk", "RL-I-06",
     "In a talk or lecture, speakers signal structure: “There are three reasons,” “Let me give an example,” “To sum up.” Listen for these signposts and use them to organize your notes. Write the main points on the left and details on the right, or use short numbered lists. Mark questions you want to ask later. After the talk, review your notes the same day and fill gaps.",
     [
         LISTEN("There are three reasons cities need trees. First, they cool the air. Second, they clean the air. Third, they make streets more pleasant.", "How many reasons does the speaker give?", "Three", "Two", "Four", "One"),
         LISTEN("There are three reasons cities need trees. First, they cool the air. Second, they clean the air. Third, they make streets more pleasant.", "What is the second reason?", "They clean the air", "They cool the air", "They are pleasant", "They hide noise"),
         C("What are signposts?", "Words that show the structure of a talk", "Street signs", "Quotations", "Titles"),
         C("What does “To sum up” signal?", "The conclusion", "A new topic", "A question", "A break"),
         C("When should you review your notes?", "The same day", "After a year", "Never", "Before the talk"),
         M("Match each signpost with its meaning.", [["There are three reasons", "a list is coming"], ["For example", "an example follows"], ["To sum up", "the conclusion"]]),
         O("Put the note-taking in order.", ["Listen for signposts", "Write main points and details", "Review and fill gaps the same day"]),
         TF("True or false: Signposts help you organize your notes.", "True"),
         F("Type the missing word: Mark questions to ask ___.", "later"),
         W("Build the sentence.", "Let me give you an example.", "never", "gives"),
         LISTEN("Let me give an example. In one town, planting two hundred trees lowered street temperatures by two degrees.", "What does the speaker give?", "An example", "A conclusion", "A question", "A warning"),
         LISTEN("To sum up: trees cool, clean and beautify cities, and they pay for themselves in health and comfort.", "What is the speaker doing?", "Summing up", "Starting the talk", "Giving an example", "Asking a question"),
         YOUR("Write short notes for this: “Two causes of stress at work are workload and unclear goals. For example, …”"),
     ]),
    ("rl-i-compare", "listen2", "Compare two sources", "RL-I-07",
     "When two texts describe the same event, compare them. What facts do both include? What does only one include? Do their numbers match? Is one more detailed or more careful? Do they use different words for the same thing? Differences may come from different sources or different attitudes. Put the common facts together first, then examine the differences.",
     [
         READ(PAPER1, "Which fact do both texts share?", "The council approved a bike lane that costs 300,000 dollars.", "The lane will open in June.", "The debate lasted three hours.", "Residents were ignored."),
         READ(PAPER2, "Which claim appears only in the blog post?", "Residents' views were not heard.", "The lane costs 300,000 dollars.", "The council voted.", "The lane is a bike lane."),
         C("What should you look at first?", "The facts both sources share", "The loudest words", "The longest text", "The date"),
         C("Which detail is only in the local paper?", "The vote was seven to four.", "The lane is a waste.", "The cost is 300,000 dollars.", "The council acted."),
         C("What can explain differences between sources?", "Different attitudes or information", "Nothing", "The paper size", "The font"),
         M("Match each question with what it checks.", [["Do the numbers match?", "accuracy"], ["What does only one include?", "extra information"], ["What words do they use?", "attitude"]]),
         O("Put the steps in order.", ["List the shared facts", "List what only one source says", "Decide what the differences suggest"]),
         TF("True or false: Different words for the same event can show different attitudes.", "True"),
         F("Type the missing word: Compare the ___ in both sources.", "facts", "numbers"),
         W("Build the sentence.", "Both sources mention the cost.", "never", "mentions"),
         LISTEN("Source A says three hundred people came. Source B says nearly three thousand. They cannot both be right, so I would check a third source.", "What does the speaker do?", "Looks for a third source", "Accepts both", "Ignores the numbers", "Chooses the bigger number"),
         LISTEN("Source A says three hundred people came. Source B says nearly three thousand. They cannot both be right, so I would check a third source.", "What is the problem?", "The numbers do not match", "The date is old", "The place is wrong", "The names are missing"),
         YOUR("Write two things the news report and the blog post have in common, and two they do not."),
     ]),
    ("rl-i-bias", "listen2", "Spot loaded words and bias", "RL-I-08",
     "Bias is a leaning toward one side. Loaded words carry feeling: “The council forced through a pointless lane” is more loaded than “The council approved a lane.” Look for one-sided evidence, missing voices and words like obviously and everyone knows. A biased text is not always false, but you should check its claims in a second source. Replace loaded words with neutral ones to see what the facts are.",
     [
         READ(PAPER2, "Which words in the blog post are loaded?", "forced through a pointless lane", "bike lane", "300,000 dollars", "the council"),
         C("What is bias?", "A leaning toward one side", "A kind of fact", "A paragraph", "A title"),
         C("Which phrase is neutral?", "The council approved the lane.", "The council forced through a pointless lane.", "The council wasted our money.", "The council ignored everyone."),
         C("Which phrase signals a one-sided claim?", "everyone knows", "according to the report", "the data show", "the survey found"),
         C("What should you do with a biased text?", "Check its claims in a second source", "Believe it fully", "Delete it", "Ignore all facts"),
         M("Match each loaded phrase with a neutral version.", [["a pointless lane", "a bike lane"], ["wasted our money", "spent 300,000 dollars"], ["ignored residents", "did not ask residents"]]),
         O("Put the steps in order.", ["Underline loaded words", "Replace them with neutral words", "Check the remaining facts in another source"]),
         TF("True or false: A biased text is always false.", "False"),
         TF("True or false: Replacing loaded words helps you see the facts.", "True"),
         F("Type the missing word: ___ words carry strong feeling.", "loaded"),
         W("Build the sentence.", "The text leans toward one side.", "never", "lean"),
         LISTEN("Everyone knows this new tax is a disaster. Only a fool would support it.", "What is wrong with this statement?", "It uses loaded, one-sided language", "It is too short", "It has no verbs", "It names a source"),
         YOUR("Rewrite this in neutral words: “The mayor's ridiculous plan will obviously ruin the town.”"),
     ]),
]

if __name__ == "__main__":
    add_stage("reading-listening", STAGE, LESSONS, "Intermediate", SOURCES)
