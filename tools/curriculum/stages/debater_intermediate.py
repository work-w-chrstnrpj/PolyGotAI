#!/usr/bin/env python3
"""Debater & Argument, Intermediate stage (about B1-B2): 2 units x 4 lessons, added to track-debater.json.

Original wording. The ideas (source checks, correlation and cause, definitions, cross-examination, conceding a point) are
standard argument-teaching concepts; sources are credited for ideas only.
Run from the project root: python3 tools/curriculum/stages/debater_intermediate.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from track_lib import C, TF, READ, LISTEN, W, F, O, M, YOUR, add_stage  # noqa: E402

SOURCES = [
    "Aristotle, Rhetoric (public-domain translations): reason and evidence as a basis for persuasion",
    "Toulmin, The Uses of Argument, and Rapoport's rules as described by Dennett (concepts only; no text copied)",
]

STAGE = {"id": "intermediate", "title": "Intermediate", "units": [
    {"id": "evidence", "title": "Use evidence well"},
    {"id": "case", "title": "Structure a case"},
]}

POOL = "A local group says the new pool will bring 40,000 visitors a year. The group is paid by the company that will build the pool. Its report is two years old and does not say how it counted visitors."
SLEEP = "In a school of 600 students, those who eat breakfast score higher on tests. A reporter writes that breakfast makes students smarter. The report does not mention sleep, family income or how the students were chosen."
BIKES = "A city added bike lanes in March. By December, bike trips had grown from 1,000 to 1,500 a week, and car trips on the same streets had fallen by 5 percent."
PHONE = "Our school should keep phones in lockers during class. Phones distract students, and distracted students learn less. In one trial, a school that used lockers saw test scores rise by 3 points."

LESSONS = [
    ("db-i-sources", "evidence", "Check your sources", "DB-I-01",
     "Before you use a fact, ask four questions: Who wrote it? Do they know the subject? Is it recent? Do they gain something if you believe it? A source that gains from your belief is not worthless, but you should look for a second source. Say it plainly: “This comes from the company that sells the product, so I checked another report.”",
     [
         READ(POOL, "Why should you be careful with this report?", "The writers earn money if the pool is built.", "The report has a long title.", "The pool is large.", "The group lives nearby."),
         READ(POOL, "Which missing detail would make the number easier to trust?", "How the visitors were counted", "The name of the architect", "The color of the pool", "The age of the group's members"),
         C("Which source is most likely to be reliable on a medical question?", "A review by a team of doctors", "A post by a friend", "An advertisement for a vitamin", "A video with many likes"),
         C("A report is ten years old and the topic changes fast. What should you do?", "Look for newer evidence", "Trust it more", "Ignore the topic", "Quote it without a date"),
         C("Which sentence admits a source may be biased?", "The company wrote this, so I also checked an independent study.", "The company wrote this, so it must be true.", "Nobody writes anything for a reason.", "All reports are the same."),
         M("Match each question with what it checks.", [["Who wrote it?", "the author"], ["Is it recent?", "the date"], ["Do they gain from it?", "a possible bias"]]),
         TF("True or false: A source that gains from your belief should be checked against another source.", "True"),
         TF("True or false: A popular post is always a reliable source.", "False"),
         F("Type the missing word: Check who ___ the report.", "wrote"),
         W("Build the sentence.", "I checked a second source.", "never", "twice"),
         LISTEN("The study was paid for by a soft drink company. Another study, from a university, found a different result.", "What does the speaker suggest?", "Compare the two studies", "Ignore both studies", "Trust the first study", "Stop reading"),
         O("Put the steps in order.", ["Find who wrote the source", "Check the date and the topic", "Compare it with a second source"]),
         YOUR("You read that a product is “the best in the world” on the maker's own website. Write two questions you would ask before you believe it."),
     ]),
    ("db-i-numbers", "evidence", "Numbers that mislead", "DB-I-02",
     "Numbers feel strong, but they can mislead. A “50 percent rise” from 2 cases to 3 cases is small in real life. Ask how big the group was and how people were chosen. A percentage point is a different thing from a percent: a rise from 10 percent to 15 percent is 5 percentage points, or a 50 percent rise. Always ask: compared with what?",
     [
         C("Cases rose from 2 to 3. A headline says “50 percent rise.” What should you ask?", "How many people were in the group?", "Who wrote the headline?", "What color is the chart?", "Why is the number round?"),
         C("A rate goes from 10 percent to 15 percent. How many percentage points is that?", "5", "15", "50", "10"),
         C("The same rise, from 10 percent to 15 percent, is a rise of what percent?", "50 percent", "5 percent", "15 percent", "10 percent"),
         C("Which phrase asks for a fair comparison?", "Compared with what?", "How big is the chart?", "Who liked it?", "Is it red?"),
         C("A survey asked ten friends of the writer. What is the weakness?", "The group is small and not chosen fairly.", "The survey was fast.", "The friends were kind.", "The numbers were round."),
         READ(BIKES, "Which number would help you judge the size of the change?", "How many car trips there were at the start", "The name of the mayor", "The width of the lanes", "The color of the bikes"),
         READ(BIKES, "What is the best way to describe the change in bike trips?", "They grew by half.", "They doubled.", "They fell by half.", "They stayed the same."),
         M("Match each term with its meaning.", [["Percent", "a share out of 100"], ["Percentage point", "the gap between two percents"], ["Sample", "the people who were asked"]]),
         TF("True or false: A big percentage always means a big change.", "False"),
         F("Type the missing word: A small ___ can give a misleading result.", "sample"),
         W("Build the question.", "How many people were asked?", "much", "were"),
         LISTEN("Sales went up 200 percent. Last month we sold one chair. This month we sold three.", "Why is the speaker warning you?", "The real change is small.", "The shop is closing.", "The chairs are cheap.", "The sales are falling."),
         YOUR("A poster says: “Nine out of ten people love our juice!” Write two questions that test the claim."),
     ]),
    ("db-i-cause", "evidence", "Cause or coincidence?", "DB-I-03",
     "Two things can happen together without one causing the other. Ice cream sales and sunburns both rise in summer, but ice cream does not cause sunburn. A third factor, hot weather, explains both. When you read “X leads to Y,” ask whether something else could explain both, and whether X came first. Use careful words: “is linked to” is safer than “causes.”",
     [
         READ(SLEEP, "What is the problem with the reporter's claim?", "Other factors could explain the scores.", "The school is too large.", "The students are tired.", "The test was short."),
         READ(SLEEP, "Which phrase fits the evidence better?", "Eating breakfast is linked to higher scores.", "Breakfast makes students smarter.", "Breakfast ruins tests.", "Students should skip lunch."),
         C("Ice cream sales and sunburns both rise in July. What explains both?", "Hot weather", "Ice cream", "Sunscreen", "School holidays"),
         C("Which word is safest when you only see a pattern?", "linked", "caused", "proved", "forced"),
         C("Which question tests a cause claim?", "Could something else explain both?", "Is the chart colorful?", "Who is the author?", "Is the number round?"),
         C("A town paints its bus stops green, and bus use rises. What should you check?", "Whether anything else changed that year", "The paint brand", "The size of the sign", "The mayor's age"),
         M("Match each word with how strongly it claims.", [["Causes", "a strong claim"], ["Is linked to", "a careful claim"], ["May be a coincidence", "a doubtful claim"]]),
         TF("True or false: If two things rise together, one must cause the other.", "False"),
         TF("True or false: A third factor can explain two patterns at once.", "True"),
         F("Type the missing word: The effect cannot come ___ the cause.", "before"),
         W("Build the sentence.", "This may be a coincidence.", "never", "proves"),
         LISTEN("Cities with more libraries also have lower crime. But cities with more libraries also tend to have more money, and money may explain both.", "What is the speaker doing?", "Pointing to another explanation", "Proving the cause", "Closing the libraries", "Ignoring the data"),
         YOUR("Write one example of two things that happen together but do not cause each other, and name the third factor."),
     ]),
    ("db-i-analogy", "evidence", "Examples and analogies", "DB-I-04",
     "One example is a story, not proof. Three examples help, but a fair sample helps more. An analogy compares two situations: “Banning phones is like banning pencils.” It is strong only if the two situations are alike in the way that matters. Test it: In what way are they alike, and in what important way are they different?",
     [
         C("A friend says: “My uncle ate bacon every day and lived to 95, so bacon is healthy.” What is the weakness?", "One example does not prove a rule.", "Bacon is salty.", "Ninety-five is old.", "The uncle was famous."),
         C("Which is the strongest kind of support for a rule?", "A large, fair sample", "One lucky story", "A loud voice", "A famous name"),
         C("“Banning phones is like banning pencils.” What should you ask?", "How are the two things alike and different?", "Who owns the pencils?", "Why are phones black?", "Is the word “ban” formal?"),
         C("Which analogy is stronger for “A team needs one captain”?", "A boat needs one person steering.", "A team is like a banana.", "A captain is like a cloud.", "Games are like Tuesday."),
         C("What does an analogy do?", "It compares two situations.", "It counts the votes.", "It names the author.", "It ends the debate."),
         M("Match each item with its strength.", [["One story", "weak support"], ["A fair sample", "stronger support"], ["A fair analogy", "helps explain an idea"]]),
         TF("True or false: An analogy is strong when the two situations differ in the way that matters.", "False"),
         TF("True or false: Three examples can still be a weak sample.", "True"),
         F("Type the missing word: A fair ___ includes many kinds of people.", "sample"),
         W("Build the question.", "In what way are they alike?", "how", "much"),
         READ(PHONE, "What kind of evidence does the speaker give for the trial?", "A result from one school", "A survey of every school", "A story about a friend", "A famous quote"),
         LISTEN("Learning to debate is like learning to swim. You can read about it, but you only improve by practicing in the water.", "What is the speaker comparing?", "Debate and swimming", "Books and water", "Pools and schools", "Teachers and coaches"),
         YOUR("Write an analogy for “A good argument needs evidence,” then name one way the two things are different."),
     ]),
    ("db-i-case", "case", "Build a case in four parts", "DB-I-05",
     "A clear case has four parts. First, state your claim. Second, give a reason. Third, support it with evidence. Fourth, link back: “This is why the school should keep phones in lockers.” Use signposts so listeners can follow: “My first reason is…, my second reason is…” End by repeating your claim in fresh words.",
     [
         C("What is the fourth part of a clear case?", "Link back to the claim", "Start with a joke", "List your friends", "Change the topic"),
         C("Which sentence is a link back?", "That is why the school should keep phones in lockers.", "Phones are small.", "I have a phone.", "Some students read."),
         C("Which phrase is a signpost?", "My second reason is cost.", "Well, so, yes.", "That is all.", "I think maybe."),
         READ(PHONE, "Which sentence is the evidence?", "In one trial, a school that used lockers saw test scores rise by 3 points.", "Our school should keep phones in lockers during class.", "Phones distract students.", "Distracted students learn less."),
         READ(PHONE, "Which sentence is the claim?", "Our school should keep phones in lockers during class.", "Phones distract students.", "Test scores rose by 3 points.", "Distracted students learn less."),
         O("Put the four parts of a case in order.", ["State the claim", "Give a reason", "Support it with evidence", "Link back to the claim"]),
         M("Match each part with its job.", [["Claim", "what you want people to accept"], ["Reason", "why it is true"], ["Evidence", "the proof for the reason"], ["Link back", "ties the proof to the claim"]]),
         TF("True or false: A case should end by repeating the claim in fresh words.", "True"),
         F("Type the missing word: My first ___ is cost.", "reason"),
         W("Build the sentence.", "That is why we should act now.", "never", "because"),
         LISTEN("My claim is that cities need more trees. My first reason is heat: trees cool streets. My second reason is health: shade lowers the risk of sunburn. That is why cities need more trees.", "How many reasons does the speaker give?", "Two", "One", "Three", "Four"),
         LISTEN("My claim is that cities need more trees. My first reason is heat: trees cool streets. My second reason is health: shade lowers the risk of sunburn. That is why cities need more trees.", "Which words link back to the claim?", "That is why cities need more trees.", "My first reason is heat.", "Trees cool streets.", "My claim is that cities need more trees."),
         YOUR("Choose a topic. Write a four-part case in four short sentences: claim, reason, evidence, link back."),
     ]),
    ("db-i-define", "case", "Define your terms", "DB-I-06",
     "Many arguments fail because the two sides use one word in different ways. If you debate “Is school fair?”, decide what “fair” means: equal tools, equal chances, or equal results? State your definition early: “By ‘fair,’ I mean that every student has the same chance.” Keep the topic narrow enough to finish: “Should our school start later?” is easier than “Is school good?”",
     [
         C("Why should you define a key word early?", "So both sides argue about the same thing.", "To make the speech longer.", "To hide your claim.", "To avoid evidence."),
         C("Which sentence defines a term?", "By “fair,” I mean that every student has the same chance.", "Fairness is nice.", "Some people dislike school.", "I will talk for five minutes."),
         C("Which topic is narrow enough for a short debate?", "Should our school start later?", "Is school good?", "Is life fair?", "Is the world changing?"),
         C("Two people argue about “success.” One means money, one means happiness. What is the problem?", "They use the word in different ways.", "They both agree.", "They need more money.", "They need a longer speech."),
         C("Which phrase introduces a definition?", "By this word, I mean…", "Well, you know…", "As everybody says…", "To be honest…"),
         M("Match each topic with its problem.", [["Is school good?", "too wide"], ["Should our school start later?", "narrow and clear"], ["Is it fair?", "the key word needs defining"]]),
         TF("True or false: A wide topic is easier to finish than a narrow one.", "False"),
         TF("True or false: Different definitions can make two people seem to disagree when they do not.", "True"),
         F("Type the missing word: A narrow ___ is easier to debate.", "topic"),
         W("Build the sentence.", "By fair, I mean equal chances.", "never", "money"),
         LISTEN("Before we start, let me define the word “healthy.” By healthy, I mean a person who eats well, sleeps enough and moves every day.", "What is the speaker doing?", "Defining a word", "Telling a story", "Asking for votes", "Ending the debate"),
         LISTEN("Before we start, let me define the word “healthy.” By healthy, I mean a person who eats well, sleeps enough and moves every day.", "Which habit is NOT in the definition?", "Taking vitamins", "Eating well", "Sleeping enough", "Moving every day"),
         YOUR("Choose the word “successful.” Write a one-sentence definition for a debate about school."),
     ]),
    ("db-i-question", "case", "Ask sharp questions", "DB-I-07",
     "Good questions test an argument without attacking the person. A clarifying question asks what a word means: “What do you mean by ‘safe’?” An evidence question asks for proof: “How do you know?” An assumption question asks what must be true: “Does this plan assume everyone has a car?” Keep your tone calm and curious, and ask one question at a time.",
     [
         C("Which is an evidence question?", "How do you know that?", "What do you mean by safe?", "Who is next?", "Is it Monday?"),
         C("Which is a clarifying question?", "What do you mean by “cheap”?", "Where is your proof?", "Who is your teacher?", "Why are you smiling?"),
         C("Which is an assumption question?", "Does this plan assume everyone owns a car?", "Is the room cold?", "Can I go first?", "Is the speaker tall?"),
         C("Which question attacks the person?", "Are you even smart enough to ask this?", "How do you know that?", "What do you mean?", "Can you give an example?"),
         C("How many questions should you ask at once?", "One", "Five", "As many as possible", "None"),
         M("Match each question with its type.", [["What do you mean by safe?", "clarifying"], ["What is your proof?", "evidence"], ["Must everyone own a car?", "assumption"]]),
         O("Put a cross-question in order.", ["Ask what the word means", "Ask for evidence", "Say what you learned"]),
         TF("True or false: A good question can be calm and still be challenging.", "True"),
         F("Type the missing word: Ask one question at a ___.", "time"),
         W("Build the question.", "What do you mean by cheap?", "how", "does"),
         LISTEN("Speaker A says the new bus line will help everyone. Speaker B asks: Who exactly is everyone? Do people who live far from the line benefit?", "What kind of question does B ask?", "A clarifying question", "A personal attack", "A joke", "A closing statement"),
         LISTEN("Speaker A says the new bus line will help everyone. Speaker B asks: Who exactly is everyone? Do people who live far from the line benefit?", "What does B test?", "The word “everyone”", "The price of tickets", "A's clothing", "The speed of buses"),
         YOUR("Someone says: “Online classes are better.” Write three questions: one clarifying, one for evidence and one about an assumption."),
     ]),
    ("db-i-concede", "case", "Concede, then refute", "DB-I-08",
     "A strong speaker admits what is true before answering. This is called conceding a point. It shows fairness and makes your answer stronger. Use patterns like “You are right that the plan costs money, but the savings are bigger” or “Even if the plan is slow, it is safer.” Do not concede everything: grant the part that is true and answer the part that is not.",
     [
         C("Which sentence concedes a point and then answers?", "You are right that it costs money, but the savings are bigger.", "That is not true at all.", "You are always wrong.", "I do not want to talk."),
         C("What is the purpose of conceding a fair point?", "It shows fairness and strengthens your answer.", "It ends the debate.", "It hides your claim.", "It insults the other side."),
         C("Which phrase accepts a point for the sake of argument?", "Even if", "As a result", "For example", "In addition"),
         C("Complete the sentence: “___ the plan is slow, it is safer.”", "Even if", "Because", "Unless", "So that"),
         C("Which reply grants the true part only?", "You are right about the cost, but not about the time.", "You are wrong about everything.", "I agree with everything.", "I will not answer."),
         M("Match each phrase with its job.", [["You are right that…", "grants a point"], ["but…", "starts your answer"], ["Even if…", "accepts a point for the argument"]]),
         O("Put the reply in order.", ["You are right that it costs a lot.", "But the savings are bigger over time.", "That is why I support the plan."]),
         TF("True or false: You should concede every point the other side makes.", "False"),
         F("Type the missing word: Grant the part that is ___.", "true"),
         W("Build the sentence.", "Even if it is slow, it is safer.", "never", "while"),
         LISTEN("You are right that the course is hard. But the students who finish it say they learned more than in any other class. So the difficulty is worth it.", "What does the speaker concede?", "The course is hard", "The course is useless", "The course is free", "The course is short"),
         LISTEN("You are right that the course is hard. But the students who finish it say they learned more than in any other class. So the difficulty is worth it.", "What is the speaker's answer?", "Students learned more", "Students quit early", "The course should end", "The teachers agree"),
         YOUR("Write a reply that concedes one true point against uniforms and then answers it."),
     ]),
]

if __name__ == "__main__":
    add_stage("debater", STAGE, LESSONS, "Intermediate", SOURCES)
