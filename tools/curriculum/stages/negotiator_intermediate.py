#!/usr/bin/env python3
"""Persuasion & Negotiation, Intermediate stage (about B1-B2): 2 units x 4 lessons, added to track-negotiator.json.

Original wording. Ideas (target and limit, a best alternative, trading, labeling feelings, confirming agreements) are standard
negotiation-teaching concepts; sources are credited for ideas only.
Run from the project root: python3 tools/curriculum/stages/negotiator_intermediate.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from track_lib import C, TF, READ, LISTEN, W, F, O, M, YOUR, add_stage  # noqa: E402

SOURCES = [
    "Aristotle, Rhetoric (public-domain translations): ethos, pathos and logos",
    "Fisher and Ury, Getting to Yes (1981), as a source of ideas: interests, options and a best alternative (concepts only; no text copied)",
]

STAGE = {"id": "intermediate", "title": "Intermediate", "units": [
    {"id": "bargain", "title": "Bargain and trade"},
    {"id": "tense", "title": "Handle tense moments"},
]}

BIKE = "Ana is selling her used bike. She wants 200 dollars but would accept 150. A buyer offers 100. Ana can also keep the bike, because she rides it to work."
OFFICE = "Sam asks his manager for a day working from home each week. The manager worries that the team will see Sam less. Sam suggests a trial for one month, with a short update every Friday."
SHOP = "A customer says: “Your price is too high. Another shop sells the same lamp for 20 dollars less.” The shop owner knows the lamp comes with a two-year warranty that the other shop does not offer."

LESSONS = [
    ("ng-i-prepare", "bargain", "Prepare before you talk", "NG-I-01",
     "Strong negotiators prepare three numbers or points. Your target is what you hope to get. Your limit is the worst result you will accept. Your best alternative is what you will do if there is no deal. Knowing your best alternative keeps you calm, because you can say no. Think about the other side too: what do they need most?",
     [
         READ(BIKE, "What is Ana's limit?", "150 dollars", "200 dollars", "100 dollars", "Keeping the bike"),
         READ(BIKE, "What is Ana's best alternative?", "Keeping the bike and riding it to work", "Selling it for 100 dollars", "Giving it away", "Buying a new bike"),
         C("What does “target” mean in a negotiation?", "What you hope to get", "The worst result you accept", "What the other side wants", "The first thing you say"),
         C("Why is a best alternative useful?", "It lets you say no calmly.", "It forces you to agree.", "It makes the talk longer.", "It hides your target."),
         C("What does “limit” mean?", "The worst result you will accept", "Your ideal result", "The other side's name", "The time of the meeting"),
         C("Which step is smart before you meet?", "Think about what the other side needs", "Decide to agree to anything", "Avoid all numbers", "Arrive late"),
         M("Match each term with its meaning.", [["Target", "the result you hope for"], ["Limit", "the worst result you accept"], ["Best alternative", "what you do without a deal"]]),
         TF("True or false: You should prepare your limit before the meeting.", "True"),
         TF("True or false: A best alternative makes you more desperate.", "False"),
         F("Type the missing word: Know your ___ before you talk.", "limit"),
         W("Build the sentence.", "I can walk away if needed.", "never", "must"),
         LISTEN("I want 5,000 dollars for the project. I will accept 4,000, but not less. If they say no, I have another client who wants the same work.", "What is the speaker's limit?", "4,000 dollars", "5,000 dollars", "The other client", "Zero dollars"),
         YOUR("You want to ask for a pay rise. Write your target, your limit and your best alternative in three short sentences."),
     ]),
    ("ng-i-anchor", "bargain", "Make the first offer", "NG-I-02",
     "The first number often sets the range for the talk. If you know the market, start with a bold but reasonable offer and give a reason: “I would like 220 dollars, because the bike has new tires.” A reason makes a number feel fair. Avoid a number you cannot defend. When the other side starts, do not jump to the middle at once; ask about their reasons first.",
     [
         C("Why does the first number matter?", "It often sets the range for the talk.", "It ends the talk.", "It must be the middle.", "It is always rejected."),
         C("Which first offer includes a reason?", "I would like 220 dollars because the bike has new tires.", "I want 220 dollars.", "Give me 220 dollars now.", "220."),
         C("The buyer says 100 for a 200-dollar bike. What is a good first reply?", "Can you tell me how you chose that number?", "Fine, 150.", "No way, goodbye.", "Okay, 100."),
         C("Which first offer is hard to defend?", "A price twice the market price with no reason", "A price slightly above the market with a reason", "A price near the market", "A range with reasons"),
         READ(BIKE, "What is a reasonable bold first offer for Ana to make?", "220 dollars, because the tires are new", "50 dollars", "1,000 dollars", "Nothing"),
         M("Match each move with its effect.", [["Give a reason", "makes the number feel fair"], ["Ask about their reasons", "shows you want to understand"], ["Jump to the middle", "gives away your room to bargain"]]),
         TF("True or false: A reason makes a first offer feel more fair.", "True"),
         TF("True or false: You should jump to the middle as soon as they speak.", "False"),
         F("Type the missing word: Give a ___ for your number.", "reason"),
         W("Build the sentence.", "I would like two hundred dollars.", "never", "gave"),
         LISTEN("My first price is 250 dollars. The photos show the full set, and I included two extra batteries.", "How does the speaker justify the price?", "By naming what is included", "By threatening to leave", "By asking for a gift", "By lowering the number"),
         O("Put the steps in order.", ["Research the usual price", "Make a first offer with a reason", "Listen to their answer before you move"]),
         YOUR("You sell a used laptop. Write your first offer and one reason that makes it sound fair."),
     ]),
    ("ng-i-trade", "bargain", "Trade, don't give in", "NG-I-03",
     "Giving in means you lose something and get nothing. Trading means you give something and ask for something. Use “if… then…”: “If you can pay today, I can lower the price.” Look for things that cost you little but matter to them, such as speed, a warranty, or a clear schedule. Trade one point at a time and keep a list of what you have given.",
     [
         READ(OFFICE, "What does Sam offer in exchange?", "A trial and a weekly update", "A bigger salary", "A new office", "Extra holidays"),
         C("What is the difference between giving in and trading?", "In a trade you ask for something in return.", "Trading is always rude.", "Giving in is polite.", "There is no difference."),
         C("Which sentence is a trade?", "If you can pay today, I can lower the price.", "I will lower the price.", "Fine, you win.", "Maybe later."),
         C("Which concession costs you little but may matter a lot to them?", "A clear delivery date", "Giving them your job", "Doubling the price", "Closing the shop"),
         C("Why keep a list of what you have given?", "So you can ask for something in return.", "So you can forget it.", "So you can hide it.", "So you can argue about colors."),
         M("Match each sentence with its job.", [["If you pay today, I can lower the price.", "offers a trade"], ["I will lower the price.", "gives in with no return"], ["Can you also add a warranty?", "asks for something back"]]),
         O("Put the trade in order.", ["Say what you can give", "Ask for something in return", "Check that both sides agree"]),
         TF("True or false: You should trade one point at a time.", "True"),
         F("Type the missing word: If you pay today, ___ I can lower the price.", "then"),
         W("Build the sentence.", "If you order today, I will add free delivery.", "never", "gave"),
         LISTEN("If you sign a two-year contract, then I can offer a ten percent discount. If you want one year, the price stays the same.", "What does the speaker offer for a two-year contract?", "A ten percent discount", "A free phone", "A refund", "A new office"),
         LISTEN("If you sign a two-year contract, then I can offer a ten percent discount. If you want one year, the price stays the same.", "What happens with a one-year contract?", "The price stays the same", "The price drops", "The deal is cancelled", "The service is free"),
         YOUR("A friend asks you to move your holiday. Write a reply that trades: say what you can give and what you need back."),
     ]),
    ("ng-i-ask", "bargain", "Ask and listen", "NG-I-04",
     "Good negotiators learn before they push. Ask open questions: “What matters most to you in this deal?” Then stay quiet and listen. Show you heard by naming the feeling or the need: “It sounds like speed is the most important point for you.” People often say the real reason after a short silence. Take notes and repeat key words back.",
     [
         C("Which question is open?", "What matters most to you in this deal?", "Do you want it?", "Is it Tuesday?", "Is it cheap?"),
         C("Which sentence shows you heard the need?", "It sounds like speed is the most important point for you.", "Hurry up.", "I do not care.", "Speed is boring."),
         C("What often happens after a short silence?", "The other person adds the real reason.", "The deal ends.", "The price doubles.", "Nothing is said ever again."),
         C("Which tool helps you remember key points?", "Taking notes", "Talking faster", "Looking away", "Changing the topic"),
         READ(SHOP, "What does the shop owner know that the customer may not?", "The lamp has a two-year warranty.", "The lamp is cheap.", "The other shop is closed.", "The customer is wrong."),
         READ(SHOP, "Which question helps the owner learn what the customer values?", "What is most important to you in a lamp?", "Why are you complaining?", "Do you want to leave?", "Is the lamp too bright?"),
         M("Match each move with its purpose.", [["Open question", "invites a full answer"], ["Silence", "gives time to add more"], ["Name the need", "shows you understood"]]),
         TF("True or false: You should listen before you push your own offer.", "True"),
         F("Type the missing word: An open question cannot be answered with yes or ___.", "no"),
         W("Build the sentence.", "It sounds like price matters most.", "never", "sound"),
         LISTEN("It sounds like you want the repair done this week. Is that the most important thing for you, or is the price just as important?", "What is the speaker doing?", "Checking what the other person needs", "Refusing the job", "Raising the price", "Ending the talk"),
         YOUR("A customer says: “I need it faster.” Write a reply that names the need and asks one open question."),
     ]),
    ("ng-i-objection", "tense", "Handle objections", "NG-I-05",
     "An objection is a reason someone says no. Do not argue at once. First, acknowledge it: “I understand the price is a worry.” Second, ask a question to understand it: “Compared with what?” Third, answer with a fact or an option. Often the objection is not the real problem, so listen for what sits behind it.",
     [
         READ(SHOP, "Which reply acknowledges the objection first?", "I understand that the price matters to you.", "You are wrong about the price.", "Everyone pays this price.", "Please leave."),
         C("What is the first step with an objection?", "Acknowledge it", "Argue back", "Change the subject", "Lower the price"),
         C("Which question explores a price objection?", "Compared with what?", "Why are you here?", "Do you like blue?", "Is it Monday?"),
         C("Which answer uses a fact?", "It comes with a two-year warranty.", "Trust me.", "It is better.", "Everyone likes it."),
         C("Why listen for what sits behind an objection?", "The stated reason may not be the real worry.", "Objections are always lies.", "It saves time.", "It ends the talk."),
         M("Match each step with its example.", [["Acknowledge", "I understand the price is a worry."], ["Ask", "Compared with what?"], ["Answer", "It includes a two-year warranty."]]),
         O("Put the steps in order.", ["Acknowledge the worry", "Ask a question to understand it", "Answer with a fact or an option"]),
         TF("True or false: An objection should be answered with an argument before you understand it.", "False"),
         F("Type the missing word: First, ___ the objection.", "acknowledge"),
         W("Build the sentence.", "I understand the price is a worry.", "never", "are"),
         LISTEN("I hear that the price feels high. Can I ask what you are comparing it with? Some shops sell a cheaper model, but it has no warranty.", "What does the speaker do first?", "Acknowledges the worry", "Lowers the price", "Argues back", "Ends the call"),
         LISTEN("I hear that the price feels high. Can I ask what you are comparing it with? Some shops sell a cheaper model, but it has no warranty.", "Which fact does the speaker add?", "A cheaper model has no warranty", "The shop is closing", "The lamp is new", "The price will rise"),
         YOUR("A client says: “Your service is too slow.” Write a three-part reply: acknowledge, ask, answer."),
     ]),
    ("ng-i-firm", "tense", "Firm and friendly", "NG-I-06",
     "You can say no and stay friendly. Give a reason, then offer what you can do: “I can't move the deadline, but I can send a draft on Wednesday.” Say the same message calmly if the person pushes again; this is called the broken record. Keep your voice steady and avoid blaming words like “always” and “never.” Firm means clear, not angry.",
     [
         C("Which reply is firm and friendly?", "I can't move the deadline, but I can send a draft on Wednesday.", "No. Stop asking.", "Do whatever you want.", "You always do this."),
         C("What does the broken record technique mean?", "Repeating your message calmly", "Raising your voice", "Leaving the room", "Giving in"),
         C("Which words should you avoid in a tense moment?", "always and never", "I can and I will", "thank you", "please"),
         C("What does “firm” mean here?", "Clear and steady", "Angry and loud", "Silent", "Unsure"),
         C("Which reply offers an alternative?", "I can't do Friday, but Monday works.", "I can't do Friday.", "Friday is bad.", "Never Friday."),
         M("Match each reply with its style.", [["I can't do Friday, but Monday works.", "firm and friendly"], ["You always change the plan!", "blaming"], ["Whatever.", "unclear"]]),
         TF("True or false: Firm means angry.", "False"),
         TF("True or false: You can repeat your message calmly if the person pushes again.", "True"),
         F("Type the missing word: Give a reason, then offer an ___.", "alternative"),
         W("Build the sentence.", "I understand, but I cannot change it.", "never", "cant"),
         LISTEN("I know the deadline is tight. I can't add more work this week, but I can take the report on Monday.", "What does the speaker offer?", "To take the report on Monday", "To work all night", "To cancel the report", "To pay for it"),
         O("Put the reply in order.", ["Say that you understand", "Say what you cannot do", "Offer what you can do"]),
         YOUR("A neighbor asks you to lend your car again. Write a firm and friendly reply that says no and offers another way to help."),
     ]),
    ("ng-i-calm", "tense", "Calm a tense moment", "NG-I-07",
     "When voices rise, slow down. Take a breath and lower your pace. Use “I” statements: “I feel worried when plans change late.” Name the shared goal: “We both want this project to finish on time.” Suggest a short break if the talk goes in circles. People listen better when they feel safe.",
     [
         C("Which sentence is an “I” statement?", "I feel worried when plans change late.", "You never plan.", "Everybody hates this.", "That is your fault."),
         C("Which sentence names a shared goal?", "We both want the project to finish on time.", "You should be quiet.", "I am right.", "It is late."),
         C("What can you suggest if the talk goes in circles?", "A short break", "A louder voice", "A new argument", "Silence forever"),
         C("What helps first when voices rise?", "Slow down and breathe", "Talk faster", "Interrupt", "Leave without a word"),
         C("Why do “I” statements help?", "They describe your feeling without blaming.", "They end the talk.", "They sound strong.", "They are longer."),
         M("Match each tool with its effect.", [["I statement", "describes your feeling"], ["Shared goal", "reminds both sides of what they need"], ["Short break", "gives time to calm down"]]),
         TF("True or false: Blaming words usually calm a tense moment.", "False"),
         TF("True or false: A shared goal can help two sides work together.", "True"),
         F("Type the missing word: Take a deep ___ before you answer.", "breath"),
         W("Build the sentence.", "We both want a fair result.", "never", "wants"),
         LISTEN("I feel worried when the plan changes at the last minute. We both want the event to go well. Can we take five minutes and then decide together?", "What does the speaker suggest?", "A five-minute break", "A new event", "A shorter talk", "A different team"),
         LISTEN("I feel worried when the plan changes at the last minute. We both want the event to go well. Can we take five minutes and then decide together?", "What is the shared goal?", "The event should go well", "The plan should change again", "The talk should end", "The team should grow"),
         YOUR("A teammate keeps interrupting you. Write what you would say, using an I statement and a shared goal."),
     ]),
    ("ng-i-close", "tense", "Close and confirm", "NG-I-08",
     "A deal is not finished until both sides know what was agreed. Summarize in plain words: “So I will send the file on Friday, and you will pay half on Monday.” Check: “Is that right?” Agree on the next step and the date. For important deals, send a short message afterward with the same points. This prevents later confusion.",
     [
         C("Why summarize the agreement?", "So both sides know what was agreed.", "To make the talk longer.", "To avoid the next step.", "To change the price."),
         C("Which sentence checks the summary?", "Is that right?", "Whatever.", "Who cares?", "Goodbye."),
         C("What should you agree on at the end?", "The next step and its date", "A new argument", "The weather", "Nothing"),
         C("What helps after an important deal?", "A short message with the same points", "Silence", "A new price", "A surprise"),
         C("Which summary is clear?", "I will send the file on Friday, and you will pay half on Monday.", "We will see.", "Things are fine.", "It is done."),
         M("Match each action with its purpose.", [["Summarize", "make the agreement clear"], ["Check", "find a mistake early"], ["Send a message", "keep a record"]]),
         O("Put the closing in order.", ["Summarize what was agreed", "Ask if it is right", "Set the next step and the date"]),
         TF("True or false: A short follow-up message prevents confusion.", "True"),
         F("Type the missing word: So I will send the file ___ Friday.", "on"),
         W("Build the question.", "Is that right?", "does", "it"),
         LISTEN("So, to confirm: I will deliver the chairs on the fifth, and you will pay half when they arrive. Is that right?", "What is the speaker doing?", "Confirming the agreement", "Raising the price", "Cancelling the order", "Making a joke"),
         LISTEN("So, to confirm: I will deliver the chairs on the fifth, and you will pay half when they arrive. Is that right?", "When will half be paid?", "When the chairs arrive", "On the first", "Next year", "Before delivery"),
         YOUR("Write a short message that confirms a deal: who does what, and by when."),
     ]),
]

if __name__ == "__main__":
    add_stage("negotiator", STAGE, LESSONS, "Intermediate", SOURCES)
