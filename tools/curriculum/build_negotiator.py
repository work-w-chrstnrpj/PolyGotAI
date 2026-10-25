#!/usr/bin/env python3
"""Build the Persuasion & Negotiation track (Foundation stage, 2 units x 4 lessons): Resources/Tracks/track-negotiator.json.

All scenarios, phrases and tips are original wording. The ideas (ethos, pathos, logos; interests versus positions;
making offers and conditional concessions) are standard teaching concepts and are credited for ideas only.
Run from the project root: python3 tools/curriculum/build_negotiator.py
"""
from track_lib import C, TF, READ, LISTEN, W, F, O, M, YOUR, build_manifest, write_track

SOURCES = [
    "Aristotle, Rhetoric (public-domain translations): ethos, pathos, logos",
    "Fisher, Ury and Patton, Getting to Yes, and Cialdini's influence principles (concepts only; no text copied)",
]

STAGES = [{"id": "foundation", "title": "Foundation", "units": [
    {"id": "persuade", "title": "Persuade"},
    {"id": "negotiate", "title": "Negotiate"},
]}]

PLAYGROUND = "Our school needs a new playground. Last year nine children were hurt on the old equipment. Imagine your own child on the old slide. As a parent and a safety officer, I want every child to be safe."
SKATE = "Our town has no safe place to skate. We want to build a small skate park near the river. Young people will have a place to exercise and meet friends. Please vote yes on Tuesday."
SELLER = "A seller told a customer, “This offer ends in five minutes, and you will regret it forever if you wait.” The customer had not seen the price."

LESSONS = [
    ("ng-appeals", "persuade", "Ethos, pathos, logos", "NG-F-01",
     "Aristotle named three ways to persuade: ethos (trust: who is speaking), pathos (feeling: stories and emotions) and logos (logic: facts and reasons). Strong persuasion often uses all three.",
     [
         C("“As a nurse for 20 years, I can tell you…” Which appeal is this?", "Ethos", "Pathos", "Logos", "None of them"),
         C("“Imagine a child with no safe place to play.” Which appeal is this?", "Pathos", "Ethos", "Logos", "None of them"),
         C("“Studies show a 30 percent drop in accidents.” Which appeal is this?", "Logos", "Pathos", "Ethos", "None of them"),
         C("Which word means trust and credibility?", "Ethos", "Pathos", "Logos", "Humor"),
         C("Which appeal uses facts and reasons?", "Logos", "Ethos", "Pathos", "Humor"),
         M("Match each appeal with its tool.", [["Ethos", "your experience and honesty"], ["Pathos", "a story that moves people"], ["Logos", "facts and clear reasons"]]),
         TF("True or false: Strong persuasion can use ethos, pathos and logos together.", "True"),
         TF("True or false: Pathos means logic.", "False"),
         F("Type the missing word: Logos means facts and ___.", "logic", "reasons", "reason"),
         READ(PLAYGROUND, "Which sentence is pathos?", "Imagine your own child on the old slide.", "Last year nine children were hurt on the old equipment.", "Our school needs a new playground.", "I am a safety officer."),
         READ(PLAYGROUND, "Which sentence is logos?", "Last year nine children were hurt on the old equipment.", "Imagine your own child on the old slide.", "As a parent and a safety officer, I want every child to be safe.", "Our school needs a new playground."),
         LISTEN("Hello, I am Doctor Rivera. I have treated children for twenty years. Please vaccinate your children on time.", "Which appeal does the speaker use first?", "Ethos", "Pathos", "Logos", "Humor"),
         YOUR("Write three sentences to persuade a friend to join a club. Use ethos, pathos and logos once each."),
     ]),
    ("ng-audience", "persuade", "Know your audience", "NG-F-02",
     "Persuasion works best when you know your audience: what they care about, what they already know and what they worry about. Use their words, give benefits that matter to them, and answer their worries before they ask.",
     [
         C("You want to persuade a busy manager to try a new tool. Which benefit fits best?", "It saves two hours a week.", "It has a nice color.", "Many students use it.", "It was invented in 2020."),
         C("You want to persuade parents to join a school event. Which benefit fits best?", "Your children will make friends and learn new skills.", "The event is on a Thursday.", "The hall has a big stage.", "Teachers wear name tags."),
         C("Which question helps you know your audience?", "What do they care about?", "What is my favorite color?", "How long is my coat?", "What time is it?"),
         C("Which opening is best for teenagers?", "Want to earn money before the summer?", "Dear Sir or Madam, I wish to inform you…", "In the year 1850…", "Attention all senior citizens…"),
         C("Which is a worry you could answer early?", "It costs too much.", "The sky is blue.", "I like apples.", "Today is Monday."),
         M("Match each audience with a likely concern.", [["Parents", "safety and cost"], ["Teenagers", "fun and friends"], ["Managers", "time and results"]]),
         O("Put the steps in order.", ["Find out what the audience cares about", "Choose the benefit that matters most to them", "Answer their worries"]),
         TF("True or false: The same message works for every audience.", "False"),
         TF("True or false: A benefit says how the audience's life gets better.", "True"),
         F("Type the missing word: Know your ___ before you speak.", "audience"),
         W("Build the sentence.", "Know what they care about.", "ignore", "never"),
         LISTEN("Hi everyone. I know you are busy, so I will be quick. This app saves you an hour every day.", "How does the speaker show they understand the audience?", "By saying they know the audience is busy", "By telling a long story", "By using difficult words", "By asking for money"),
         YOUR("Choose a product or an event. Write one sentence to persuade parents and one to persuade teenagers."),
     ]),
    ("ng-pitch", "persuade", "A simple pitch", "NG-F-03",
     "A short pitch has four steps: the problem, your solution, the benefit and the next step. “Many people lose their keys. Our key tag lets you find them with your phone. You will never be late again. Order one today.”",
     [
         O("Put the pitch in order.", ["Many people waste time looking for parking.", "Our app shows free spaces near you.", "You will arrive on time and feel calm.", "Download it today."]),
         C("Which sentence states the problem?", "Many students feel stressed before exams.", "Our club teaches calm breathing.", "You will feel calm.", "Join us on Monday."),
         C("Which sentence states the solution?", "Our club teaches calm breathing.", "Many students feel stressed.", "You will sleep better.", "Join us on Monday."),
         C("Which sentence states the benefit?", "You will sleep better and feel calm.", "Many students feel stressed.", "Our club has a room.", "The club meets on Monday."),
         C("Which sentence is the next step?", "Sign up at the front desk today.", "Stress is common.", "Calm is good.", "We have many members."),
         M("Match each step with its job.", [["Problem", "what is wrong"], ["Solution", "your idea"], ["Benefit", "how life gets better"], ["Next step", "what to do now"]]),
         TF("True or false: A pitch should end with a clear next step.", "True"),
         TF("True or false: A pitch starts with a long list of facts about you.", "False"),
         F("Type the missing word: A short pitch starts with a ___.", "problem"),
         W("Build the sentence.", "Our app saves you time.", "wastes", "never"),
         W("Build the sentence.", "Sign up today.", "later", "never"),
         LISTEN("Many people forget to drink water. Our bottle reminds you with a light. You will feel better every day. Buy yours this week.", "Which part is the benefit?", "You will feel better every day", "Many people forget to drink water", "Our bottle reminds you with a light", "Buy yours this week"),
         READ(SKATE, "Which sentence is the call to action?", "Please vote yes on Tuesday.", "Our town has no safe place to skate.", "We want to build a small skate park near the river.", "Young people will have a place to exercise and meet friends."),
         YOUR("Write a four-sentence pitch for something you would like to change at home, at school or at work."),
     ]),
    ("ng-ethics", "persuade", "Persuade or manipulate?", "NG-F-04",
     "Ethical persuasion is honest: true facts, real benefits and respect for the other person's choice. Manipulation uses lies, pressure, fear or tricks to stop people from thinking. Ask: would I be happy if they knew exactly what I was doing?",
     [
         C("Which is ethical persuasion?", "Giving true facts and letting the person decide", "Hiding the price", "Saying “only today, no time to think”", "Making up a fake review"),
         C("Which is manipulation?", "“Buy now or something terrible will happen to you!”", "“Here are the facts. You decide.”", "“This helps because…”", "“I recommend it, and here is why.”"),
         C("Which is a pressure tactic?", "“Only one left! Decide in 30 seconds!”", "“Take your time to think.”", "“Here is a free sample.”", "“Compare prices first.”"),
         C("A seller says a product fixes everything. It does not. What is this?", "A lie", "A fair benefit", "A question", "A pitch step"),
         C("Which question tests your ethics?", "Would I be happy if they knew what I was doing?", "Will I win?", "Is it fast?", "Is it loud?"),
         M("Match each tactic with its effect.", [["Honest facts", "build trust"], ["Fake reviews", "break trust"], ["Time pressure", "stops people thinking"]]),
         TF("True or false: Ethical persuasion respects the other person's choice.", "True"),
         TF("True or false: A small lie is fine if it helps you win.", "False"),
         F("Type the missing word: Manipulation often uses fear and ___.", "pressure"),
         READ(SELLER, "What is the seller doing?", "Using pressure and fear", "Giving honest facts", "Asking a fair question", "Offering a refund"),
         LISTEN("I recommend this jacket because it is warm and fairly priced. Take your time. You can try it on and compare.", "Why is this ethical?", "It gives honest reasons and lets the customer decide", "It uses fear", "It hides the price", "It forces a choice"),
         W("Build the sentence.", "Respect the other person's choice.", "ignore", "their"),
         YOUR("Write two sentences: one honest way and one manipulative way to ask a friend to lend you money. Say which is better and why."),
     ]),
    ("ng-interests", "negotiate", "Interests, not positions", "NG-F-05",
     "A position is what someone says they want: “I want the window open.” An interest is why: “I need fresh air.” Two people can have opposite positions and still share interests. Ask “why?” to find the interest, then look for a deal that meets both.",
     [
         C("Is this a position or an interest? “I want the front seat.”", "A position", "An interest"),
         C("Is this a position or an interest? “I get sick in the back seat.”", "An interest", "A position"),
         C("Two sisters want the last orange. One needs the juice. The other needs the peel for a cake. What is the best solution?", "Share it: one takes the juice, the other the peel", "Cut it in two equal pieces and waste the rest", "Let the older one have it", "Throw it away"),
         C("Which question helps find an interest?", "Why is that important to you?", "Who is right?", "How loud can you shout?", "What is your name?"),
         C("“I want the window open.” “I want it closed.” What are these?", "Positions", "Interests", "Facts", "Questions"),
         M("Match each word with its meaning.", [["Position", "what you say you want"], ["Interest", "why you want it"], ["Solution", "a deal that meets both interests"]]),
         O("Put the steps in order.", ["Ask why each side wants it", "Find the shared interests", "Suggest a solution that meets both"]),
         TF("True or false: Opposite positions can have shared interests.", "True"),
         TF("True or false: Asking why helps you find interests.", "True"),
         F("Type the missing word: An interest is the ___ behind a position.", "reason", "why"),
         W("Build the question.", "Why is that important to you?", "who", "what"),
         LISTEN("I want to work from home on Fridays. My manager wants everyone in the office. When we talked, I said I need quiet time to finish reports. My manager said she wants good teamwork.", "What is the manager's interest?", "Good teamwork", "Quiet time to finish reports", "Working from home on Fridays", "A shorter day"),
         YOUR("Think of a disagreement you had. Write each person's position and each person's interest."),
     ]),
    ("ng-offer", "negotiate", "Make an offer", "NG-F-06",
     "In a negotiation, make a clear offer: say what you want and what you give. Start a little better than what you need, so you have room to move. Offer choices: “I can do A, or B.” Useful phrases: “I would like…,” “How about…?” and “Would you consider…?”",
     [
         C("Which is a clear offer?", "I can pay $50 if you deliver it on Friday.", "Maybe something.", "I do not know.", "Whatever."),
         C("Which phrase proposes an idea politely?", "How about meeting at ten instead?", "Do it.", "That is your problem.", "No way."),
         C("Which phrase asks someone to think about a change?", "Would you consider a smaller order?", "Give me that.", "Why not?", "Because."),
         C("You need to sell your bike for at least $40. What should your first price be?", "A little above $40, such as $55", "Exactly $40", "$10", "Nothing"),
         C("Which gives the other side a choice?", "I can do Monday or Wednesday. Which is better?", "Monday only. Take it or leave it.", "Never.", "Whenever."),
         M("Match each phrase with its use.", [["How about…?", "suggest an idea"], ["Would you consider…?", "ask politely for a change"], ["I would like…", "say what you want"]]),
         O("Put the offer in order.", ["Say what you want", "Say what you can give", "Ask for a reply"]),
         W("Build the question.", "How about meeting at noon?", "never", "what"),
         W("Build the sentence.", "I can pay on Friday.", "never", "if"),
         F("Type the missing word: ___ you consider a smaller order?", "Would"),
         TF("True or false: A clear offer says what you want and what you give.", "True"),
         TF("True or false: You should start exactly at your lowest price.", "False"),
         LISTEN("I would like to buy two tickets for Saturday. How about seventy dollars for both? I can pay now.", "What does the buyer offer?", "Seventy dollars for two tickets", "Forty dollars for one ticket", "One hundred dollars for four", "Nothing yet"),
         YOUR("Write an offer to buy a used bike. Say what you want, what you can pay and when."),
     ]),
    ("ng-concede", "negotiate", "If you…, I will…", "NG-F-07",
     "A concession gives something. A conditional concession gives something if you get something: “If you deliver on Friday, I will pay the full price.” The pattern is “If you…, I will…” It keeps you safe and makes a fair trade.",
     [
         C("Which is a conditional concession?", "If you deliver on Friday, I will pay now.", "I will pay now.", "Pay now.", "You must deliver."),
         C("Fill the gap: If you lower the price, I ___ two.", "will buy", "bought", "buying", "buys"),
         C("Fill the gap: If you ___ the room, I will pay extra.", "clean", "cleaned", "will clean", "cleaning"),
         C("Why is a conditional concession safer than a plain one?", "You give something only if you get something", "You give everything", "You give nothing", "It ends the talk"),
         C("Which sentence makes a trade?", "If you give me two weeks, I will finish the whole job.", "I will finish the job.", "Give me two weeks.", "The job is big."),
         W("Build the sentence.", "If you wait, I will help.", "helped", "waited"),
         W("Build the sentence.", "If you pay today, I will give a discount.", "gave", "paid"),
         F("Type the missing word: If you agree, I ___ start tomorrow.", "will"),
         M("Match each part with its job.", [["If you…", "what you ask for"], ["I will…", "what you give"], ["Trade", "each side gives something"]]),
         O("Put the sentence in order.", ["If you agree to a one-year contract,", "I will lower the monthly price", "by ten percent."]),
         TF("True or false: A conditional concession starts with “If.”", "True"),
         LISTEN("If you can deliver the sofa on Saturday, I will pay the full price. If it comes later, I will need a discount.", "When will the buyer pay the full price?", "If the sofa arrives on Saturday", "If the sofa arrives later", "Never", "If the buyer is free"),
         YOUR("Write two “If you…, I will…” sentences for a negotiation about a shared task at home or at work."),
     ]),
    ("ng-refuse", "negotiate", "Say no politely", "NG-F-08",
     "You can refuse and still keep a good relationship. Thank the person, say no clearly, give a short reason if you wish, and offer another choice. Softening words such as “unfortunately” and “I'm afraid” make the no gentler. Do not say “maybe” if you mean no.",
     [
         C("Which is the most polite refusal?", "Thank you for asking, but I'm afraid I can't this week.", "No.", "I won't. Stop asking.", "Whatever."),
         C("Which softening word starts a polite refusal?", "Unfortunately,", "Obviously,", "Never,", "Stop,"),
         C("Which refusal offers another choice?", "I can't on Friday, but I could help on Monday.", "I can't.", "No way.", "Ask someone else."),
         C("You mean no. Which reply is honest?", "I'm sorry, but I can't do it.", "Maybe, we will see.", "I will try, but I won't.", "Sure!"),
         C("Which phrase makes a refusal gentler?", "I'm afraid I can't", "I never will", "You must not", "I always refuse"),
         M("Match each part with its job.", [["Thank the person", "shows respect"], ["Say no clearly", "avoids confusion"], ["Offer another choice", "keeps the relationship"]]),
         O("Put the refusal in order.", ["Thank you for the invitation.", "Unfortunately, I can't come on Saturday.", "Could we meet next week instead?"]),
         W("Build the sentence.", "I'm afraid I can't help today.", "will", "never"),
         W("Build the sentence.", "Thank you, but I can't.", "and", "never"),
         F("Type the missing word: Thank you for asking, but I'm ___ I can't.", "afraid"),
         TF("True or false: Saying “maybe” when you mean no is clear and honest.", "False"),
         TF("True or false: You can say no and still be polite.", "True"),
         LISTEN("Thank you for the offer. Unfortunately, I can't take the job because I'm moving next month. I hope we can work together another time.", "Why does the speaker refuse?", "Because they are moving next month", "Because the pay is low", "Because they are angry", "Because the job is boring"),
         YOUR("A friend asks you to help move house on a day when you are busy. Write a polite refusal that offers another choice."),
     ]),
]

if __name__ == "__main__":
    manifest = build_manifest("negotiator", "negotiator", STAGES, LESSONS, "Foundation", SOURCES)
    write_track("negotiator", manifest)
