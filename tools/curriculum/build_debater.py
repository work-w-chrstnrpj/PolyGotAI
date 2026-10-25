#!/usr/bin/env python3
"""Build the Debater & Argument track (Foundation stage, 2 units x 4 lessons): Resources/Tracks/track-debater.json.

All arguments, examples and tips are original wording. Ideas (claim, reason, evidence, rebuttal, common fallacies,
steelmanning) are standard teaching concepts; sources are credited for ideas only.
Run from the project root: python3 tools/curriculum/build_debater.py
"""
from track_lib import C, TF, READ, LISTEN, W, F, O, M, YOUR, build_manifest, write_track

SOURCES = [
    "Aristotle, Rhetoric (public-domain translations): reason and evidence as a basis for persuasion",
    "Toulmin, The Uses of Argument, and Rapoport's rules as described by Dennett (concepts only; no text copied)",
]

STAGES = [{"id": "foundation", "title": "Foundation", "units": [
    {"id": "build", "title": "Build an argument"},
    {"id": "answer", "title": "Answer and test arguments"},
]}]

LIBRARY = "Our town should build a new library. The old library has only 200 seats, but 1,500 people visit each week. A survey of 400 residents found that 78 percent want more study space."
MAYA = "Maya said that the school should add a recycling bin in each classroom. Leo replied that Maya wanted to waste money and ruin the school budget."
MAYOR = "The mayor said that we must either build the stadium or lose all our jobs. He did not mention any other choices."
CARS = "Argument A: The city should ban cars from the center because a study of three cities found 30 percent less pollution. Argument B: The city should not ban cars because my uncle drives and he likes it."

LESSONS = [
    ("db-claim-reason", "build", "Claim and reason", "DB-F-01",
     "A claim is what you want people to accept: “Schools should start later.” A reason answers “why?”: “because teenagers need more sleep.” A good argument joins them with “because.” A claim without a reason is only an opinion.",
     [
         C("Which sentence is a claim?", "Cities should have more parks.", "Parks have trees.", "The park opens at nine.", "I went to the park."),
         C("Which sentence is a reason for “Students should wear uniforms”?", "Uniforms make students feel equal.", "I like blue.", "The school is big.", "Uniforms are made of cloth."),
         C("Which sentence gives a claim and a reason?", "We should recycle because it saves resources.", "We should recycle.", "Recycling is a word.", "Because it saves resources."),
         C("What question does a reason answer?", "Why?", "Who?", "When?", "Where?"),
         C("Which sentence is NOT a reason?", "Everyone should buy bikes.", "Bikes are cheap to run.", "Bikes do not pollute.", "Bikes keep people fit."),
         W("Build the sentence.", "We should walk more because it is healthy.", "so", "but"),
         W("Build the sentence.", "Homework should be shorter because students need rest.", "but", "so"),
         F("Type the missing word: A claim is what you want people to ___.", "accept", "believe"),
         M("Match each part with its job.", [["Claim", "what you want people to accept"], ["Reason", "why the claim is true"], ["Because", "joins the reason to the claim"]]),
         O("Put the parts in order.", ["State your claim", "Give a reason", "Add an example"]),
         TF("True or false: A claim without a reason is only an opinion.", "True"),
         LISTEN("We should have a longer lunch break. Students are hungry and tired in the afternoon, and a longer break helps them focus.", "What is the claim?", "We should have a longer lunch break", "Students are hungry", "Students are tired", "Teachers like lunch"),
         LISTEN("We should have a longer lunch break. Students are hungry and tired in the afternoon, and a longer break helps them focus.", "What is one reason?", "Students are tired in the afternoon", "Lunch is at noon", "The school is old", "Teachers need a break"),
         YOUR("Write one claim about your school or workplace. Add two reasons with “because.”"),
     ]),
    ("db-evidence", "build", "Choose strong evidence", "DB-F-02",
     "Evidence is a fact, an example, a number or an expert's view that supports a reason. Strong evidence is specific, true and connected to the claim. Weak evidence is vague (“everyone knows”), only personal (“my cousin did this”) or about something else.",
     [
         C("Claim: School should start later. Which is the strongest evidence?", "A study found that students who sleep eight hours get better grades.", "Everyone knows teenagers are lazy.", "My cousin sleeps late.", "The school is on Main Street."),
         C("Claim: We need more bike lanes. Which evidence is strongest?", "Last year 40 cyclists were hurt on roads without bike lanes.", "I think bikes are cool.", "Cars are loud.", "Many people like riding."),
         C("Which evidence is vague?", "Many experts say so.", "The city counted 1,200 users in May.", "A survey of 300 students found 70 percent agree.", "The report was published in 2024."),
         C("Which is a good expert source?", "A doctor with 20 years of experience", "A stranger online", "A friend who heard it", "An advertisement"),
         C("Which sentence uses a number as evidence?", "Eighty percent of workers said they prefer remote work.", "Remote work is the future.", "Many workers like home.", "Offices are old."),
         READ(LIBRARY, "Which sentence is evidence from a survey?", "A survey of 400 residents found that 78 percent want more study space.", "Our town should build a new library.", "The old library has only 200 seats.", "1,500 people visit each week."),
         READ(LIBRARY, "What is the claim?", "Our town should build a new library", "The old library has 200 seats", "A survey found 78 percent", "1,500 people visit"),
         TF("True or false: “Everyone knows it” is strong evidence.", "False"),
         TF("True or false: Specific numbers can make evidence stronger.", "True"),
         M("Match each kind of evidence with an example.", [["Statistic", "78 percent of residents agree"], ["Example", "One school started later and grades rose"], ["Expert opinion", "A doctor says teens need nine hours of sleep"]]),
         F("Type the missing word: Strong evidence is ___ and true.", "specific"),
         O("Put the steps in order.", ["State your claim", "Find a fact that supports it", "Check that the fact is true and connected"]),
         YOUR("Write a claim and one piece of strong evidence for it. Say where the evidence comes from."),
     ]),
    ("db-structure", "build", "Order an argument", "DB-F-03",
     "A clear argument has four parts: claim, reason, evidence and conclusion. Start with the claim, say why, prove it, and finish by repeating the claim in a stronger way. Signpost each step with words like “first,” “for example” and “therefore.”",
     [
         O("Put this argument in order.", ["Cities should plant more trees.", "Trees cool the air in summer.", "For example, streets with trees can be five degrees cooler.", "Therefore, planting trees is a smart choice."]),
         O("Put this argument in order.", ["Phones should be banned in class.", "They distract students from learning.", "One study found grades rose after a ban.", "For these reasons, schools should ban phones in class."]),
         C("Which word starts the conclusion?", "Therefore", "For example", "Because", "First"),
         C("Which word introduces an example?", "For example", "Therefore", "However", "Finally"),
         C("Which sentence is a conclusion?", "So, we should open the library on Sundays.", "The library opens at nine.", "Many people read books.", "I was there last week."),
         C("What does a good conclusion do?", "Repeats the claim in a stronger way", "Adds a new unrelated topic", "Says sorry", "Ends with a joke only"),
         M("Match each signpost word with its job.", [["First", "starts the first point"], ["For example", "introduces evidence"], ["Therefore", "leads to the conclusion"], ["However", "shows a different view"]]),
         W("Build the sentence.", "First, I will give a reason.", "last", "never"),
         W("Build the sentence.", "Therefore, we should act now.", "However", "later"),
         F("Type the missing word: ___ example, many cities have done this.", "For"),
         TF("True or false: The conclusion repeats the claim.", "True"),
         LISTEN("I believe our school should have a garden. First, gardens teach students about food. For example, students can grow tomatoes and eat them. Therefore, a garden would be good for learning.", "Which word introduces the conclusion?", "Therefore", "First", "For example", "Believe"),
         YOUR("Write a four-sentence argument: claim, reason, example, conclusion."),
     ]),
    ("db-phrases", "build", "Phrases for arguing", "DB-F-04",
     "Good speakers use set phrases. To give an opinion: “In my opinion…,” “I believe…” To add a point: “Moreover…,” “Also…” To give an example: “For instance…” To contrast: “On the other hand…,” “However…” To conclude: “In conclusion…,” “To sum up…”",
     [
         M("Match each phrase with its job.", [["In my opinion", "give your view"], ["For instance", "give an example"], ["On the other hand", "show a different view"], ["In conclusion", "finish your argument"]]),
         C("Which phrase gives an example?", "For instance", "In conclusion", "However", "I believe"),
         C("Which phrase shows a contrast?", "On the other hand", "Moreover", "For example", "To sum up"),
         C("Which phrase adds another point?", "Moreover", "However", "In conclusion", "On the other hand"),
         C("Which phrase is best for finishing?", "To sum up", "For instance", "Also", "But"),
         C("Fill the gap: ___, I think cities need more parks.", "In my opinion", "On the other hand", "For instance", "However"),
         C("Fill the gap: Cars are fast. ___, they pollute the air.", "However", "For instance", "In my opinion", "First"),
         W("Build the sentence.", "In my opinion, it is a good plan.", "However", "never"),
         W("Build the sentence.", "On the other hand, it is expensive.", "For", "cheap"),
         F("Type the missing word: In ___, we should accept the plan.", "conclusion"),
         TF("True or false: “However” shows a contrast.", "True"),
         O("Put the argument in order.", ["In my opinion, remote work is good.", "Moreover, it saves travel time.", "However, some people feel alone.", "In conclusion, it works best with some office days."]),
         LISTEN("I think cycling is great. Moreover, it is cheap. However, it can be unsafe on busy roads. To sum up, cities need safe bike lanes.", "Which phrase shows a different view?", "However", "Moreover", "To sum up", "I think"),
         YOUR("Write four sentences about a topic you care about. Use “in my opinion,” “moreover,” “however” and “in conclusion.”"),
     ]),
    ("db-rebut", "answer", "A polite rebuttal", "DB-F-05",
     "A rebuttal answers another person's argument. First show you listened: “I see your point.” Then say where you disagree: “However, …” or “I'm not sure that's true, because …” Attack the argument, not the person.",
     [
         C("Which is the most polite start to a rebuttal?", "I see your point, but I see it differently.", "That is a stupid idea.", "You are wrong.", "Nobody agrees with you."),
         C("Which attacks the argument, not the person?", "The study you mention only had ten people.", "You never read anything.", "You are always late.", "Only a fool believes that."),
         C("Which phrase shows you listened?", "I understand what you mean.", "Be quiet.", "That's nonsense.", "Whatever."),
         C("Which phrase gives a reason to disagree?", "I'm not sure, because the numbers are old.", "Because I said so.", "No.", "That's boring."),
         C("Complete the rebuttal: “You say buses are cheap. ___, they are often late.”", "However", "Therefore", "For example", "First"),
         M("Match each phrase with its job.", [["I see your point", "shows you listened"], ["However", "starts your disagreement"], ["Because", "gives your reason"]]),
         O("Put the rebuttal in order.", ["I see your point about the cost.", "However, the plan will take five years.", "Because of that, I think we should look at other options."]),
         W("Build the sentence.", "I see your point, but I disagree.", "never", "because"),
         W("Build the sentence.", "I understand, but the data is old.", "so", "new"),
         F("Type the missing word: Attack the ___, not the person.", "argument"),
         TF("True or false: A rebuttal should insult the other person.", "False"),
         LISTEN("A says: Homework helps students learn. B says: I see your point. However, too much homework makes students tired, and tired students learn less.", "How does speaker B start?", "By showing they listened", "By insulting A", "By changing the topic", "By agreeing completely"),
         LISTEN("A says: Homework helps students learn. B says: I see your point. However, too much homework makes students tired, and tired students learn less.", "What is B's reason?", "Too much homework makes students tired", "Homework is free", "Students like homework", "Teachers are busy"),
         YOUR("Someone says: “Cars are better than buses.” Write a polite rebuttal with a reason."),
     ]),
    ("db-fallacy-people", "answer", "Straw man and personal attack", "DB-F-06",
     "A fallacy is a mistake in reasoning that makes an argument look stronger than it is. A straw man changes someone's argument into a weaker one and attacks that. An ad hominem attacks the person instead of the argument. Spot them and name them calmly.",
     [
         C("A says: “We should spend a little more on parks.” B says: “So you want the schools to have no money?” What is B doing?", "A straw man", "A fair summary", "An example", "A conclusion"),
         C("A says the report has a mistake. B says: “You failed math, so you cannot judge.” What is this?", "An ad hominem attack", "A strong reason", "Good evidence", "A fair question"),
         C("Which sentence is an ad hominem?", "You are too young to understand.", "The data show a 5 percent drop.", "The plan costs a lot.", "Many people disagree."),
         C("Which sentence is a straw man?", "You want shorter classes? So you want students to learn nothing!", "You want shorter classes? Please explain why.", "I disagree because the data are old.", "Let's look at the evidence."),
         C("What is a fallacy?", "A mistake in reasoning", "A kind of evidence", "A good conclusion", "A polite phrase"),
         M("Match each term with its meaning.", [["Straw man", "misrepresents the argument"], ["Ad hominem", "attacks the person"], ["Rebuttal", "answers the argument fairly"]]),
         TF("True or false: An ad hominem answers the argument.", "False"),
         TF("True or false: A straw man makes the other argument weaker than it really is.", "True"),
         F("Type the missing word: An ad hominem attacks the ___.", "person"),
         READ(MAYA, "What is Leo doing?", "Making a straw man", "Giving evidence", "Asking a question", "Agreeing with Maya"),
         LISTEN("You cannot trust Dan's plan because he is new here.", "What is the speaker doing?", "Attacking the person", "Giving evidence", "Summarizing fairly", "Asking for the facts"),
         O("Put the steps in order.", ["Listen to the argument", "Notice if it attacks the person or changes the argument", "Name the fallacy calmly"]),
         YOUR("Write a short straw-man reply and then a fair reply to this claim: “We should walk to school more often.”"),
     ]),
    ("db-fallacy-logic", "answer", "False dilemma and slippery slope", "DB-F-07",
     "A false dilemma says there are only two choices when there are more: “Either we ban cars or the city dies.” A slippery slope says one small step will lead to a disaster without proof: “If we allow short breaks, soon nobody will work.” Ask: Are there other choices? Is each step really certain?",
     [
         C("“Either we build a new road or the town will die.” Which fallacy?", "False dilemma", "Slippery slope", "Ad hominem", "Fair evidence"),
         C("“If we allow one late day, nobody will ever come on time again.” Which fallacy?", "Slippery slope", "False dilemma", "Fair evidence", "Good conclusion"),
         C("Which question helps you test a false dilemma?", "Are there other choices?", "Who said it?", "How old is it?", "Is it long?"),
         C("Which sentence is a false dilemma?", "You are either with us or against us.", "We could choose bus, train or bike.", "Some people like tea, others coffee.", "There are many options."),
         C("Which sentence is a slippery slope?", "If we allow phones today, soon students will never read again.", "Phones help students find information.", "Phones can distract students.", "The school has a phone rule."),
         M("Match each fallacy with its clue.", [["False dilemma", "only two choices are offered"], ["Slippery slope", "a small step leads to disaster"], ["Fair argument", "real reasons and evidence"]]),
         TF("True or false: A false dilemma ignores other choices.", "True"),
         TF("True or false: A slippery slope always has proof for each step.", "False"),
         F("Type the missing word: A false ___ gives only two choices.", "dilemma"),
         W("Build the question.", "Are there other choices?", "any", "those"),
         READ(MAYOR, "Which fallacy is the mayor using?", "A false dilemma", "A slippery slope", "An ad hominem", "A fair reason"),
         LISTEN("If we let students use calculators, they will stop thinking, then they will stop learning, and soon the school will close.", "Which fallacy is this?", "A slippery slope", "A false dilemma", "An ad hominem", "Strong evidence"),
         YOUR("Write one false dilemma and one fair alternative that offers more than two choices."),
     ]),
    ("db-weigh", "answer", "Weigh two arguments", "DB-F-08",
     "To decide between two arguments, compare them. Which has stronger evidence? Which reasons connect better to the claim? Are there fallacies? Be fair: state the best version of the other side before you answer it. This is called steelmanning.",
     [
         READ(CARS, "Which argument has stronger evidence?", "A, because it uses a study", "B, because it mentions a person", "Both are equal", "Neither gives a reason"),
         READ(CARS, "What is the weakness of Argument B?", "It uses a personal story, not evidence", "It uses a study", "It is too long", "It uses numbers"),
         C("What does “steelmanning” mean?", "Stating the strongest version of the other side", "Attacking the weakest point", "Ignoring the other side", "Agreeing with everyone"),
         C("Which is a fair way to start your answer?", "The strongest point on the other side is…", "The other side is silly…", "Nobody believes…", "I will not listen…"),
         C("Which question helps compare arguments?", "Which one has better evidence?", "Which one is longer?", "Which one is louder?", "Which one came first?"),
         M("Match each question with what it checks.", [["Is the evidence strong?", "quality of proof"], ["Does the reason connect to the claim?", "relevance"], ["Is there a fallacy?", "quality of reasoning"]]),
         O("Put the steps in order.", ["State the other side's best point", "Compare the evidence", "Give your conclusion and why"]),
         TF("True or false: A fair debater explains the other side accurately.", "True"),
         TF("True or false: The longest argument is always the best.", "False"),
         F("Type the missing word: Compare the ___ for each claim.", "evidence"),
         W("Build the question.", "Which argument is stronger?", "weaker", "one"),
         LISTEN("Argument one: We should extend the school day because a survey of 500 parents showed that 70 percent agree. Argument two: We should not, because it feels too long.", "Which argument gives evidence?", "Argument one", "Argument two", "Both of them", "Neither of them"),
         YOUR("Choose a topic. Write the strongest point for the other side first, then your answer to it."),
     ]),
]

if __name__ == "__main__":
    manifest = build_manifest("debater", "debater", STAGES, LESSONS, "Foundation", SOURCES)
    write_track("debater", manifest)
