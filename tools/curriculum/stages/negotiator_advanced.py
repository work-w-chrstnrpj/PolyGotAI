#!/usr/bin/env python3
"""Persuasion & Negotiation, Advanced stage (about C1-C2): 2 units x 4 lessons, added to track-negotiator.json.

Original wording and invented situations. Ideas (interests and criteria, packages, counter-anchoring, cross-cultural style,
common pressure tactics, authority and approval, repairing a relationship) are standard negotiation-teaching concepts;
sources credited for ideas only.
Run from the project root: python3 tools/curriculum/stages/negotiator_advanced.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from track_lib import C, TF, READ, LISTEN, W, F, O, M, YOUR, add_stage  # noqa: E402

SOURCES = [
    "Aristotle, Rhetoric (public-domain translations): ethos, pathos and logos",
    "Fisher and Ury, Getting to Yes (1981), and later negotiation research (concepts only; no text copied)",
]

STAGE = {"id": "advanced", "title": "Advanced", "units": [
    {"id": "strategy", "title": "Negotiate strategically"},
    {"id": "pressure", "title": "Complex and tense deals"},
]}

DEAL = "A software firm wants a two-year contract. The client cares most about a fast launch and low risk. The firm cares most about steady income and a reference it can show to others. Price is the only issue they have discussed so far."
EXEC = "Lena is told by a supplier that the offer expires at five o'clock. Later she learns that the supplier extended the same offer to another client last month."
TEAM = "At the meeting, the buyer says she likes the terms. Then she adds that she must consult her finance director before she can agree to anything."

LESSONS = [
    ("ng-a-criteria", "strategy", "Interests, options and criteria", "NG-A-01",
     "Move the talk from positions to interests and then to options. Ask what each side needs and why. Brainstorm several options before you judge them. Then agree on objective criteria, such as market price, expert opinion or a precedent, so the choice is based on a standard, not on who pushes harder. “Let's use the average price of the last three comparable deals” turns a battle of wills into a shared problem.",
     [
         READ(DEAL, "What is the most promising way to widen the deal?", "Trade a fast launch and a reference for a steady two-year income.", "Argue only about price.", "End the talk.", "Ask for a longer contract with no changes."),
         C("What should you do before judging options?", "Brainstorm several options", "Choose the first idea", "Reject all ideas", "Wait for the other side"),
         C("Which is an objective criterion?", "The average price of comparable deals", "Whoever speaks louder", "My personal feeling", "The mood in the room"),
         C("Why use objective criteria?", "They turn a battle of wills into a shared problem", "They end the talk", "They hide interests", "They guarantee a win"),
         C("Which question explores interests?", "What does this outcome do for you?", "What is your lowest price?", "Why are you here?", "Will you sign now?"),
         M("Match each step with its purpose.", [["Ask why", "uncover interests"], ["Brainstorm", "create options"], ["Agree a criterion", "choose fairly"]]),
         O("Put the steps in order.", ["Uncover each side's interests", "Generate options together", "Agree on a standard to choose"]),
         TF("True or false: Fixing on price alone usually widens the possible deals.", "False"),
         F("Type the missing word: Use an objective ___ to decide.", "criterion", "standard"),
         W("Build the sentence.", "Let's agree on a fair standard first.", "never", "standards"),
         LISTEN("We both want a fair price. Rather than argue, can we use what three similar offices paid last year? That gives us a neutral number.", "What is the speaker proposing?", "An objective standard", "A threat", "A deadline", "A discount"),
         YOUR("Two neighbors disagree about a shared fence. Write an interest each side may have and one objective criterion to settle the cost."),
     ]),
    ("ng-a-alt", "strategy", "Strengthen your alternative", "NG-A-02",
     "Your power comes less from toughness than from your best alternative. Before a talk, improve it: ask a second supplier for a quote, check another job offer, prepare a fallback plan. Estimate the other side's alternative too; if theirs is weak, you may ask for more. Never bluff about an alternative you do not have. If you are asked, say what is true: “I have options, and I would prefer to work with you.”",
     [
         C("Where does negotiation power mainly come from?", "A strong best alternative", "A loud voice", "A long speech", "A secret"),
         C("How can you improve your alternative before the talk?", "Get a second quote", "Wait", "Stop preparing", "Agree to anything"),
         C("Why estimate the other side's alternative?", "If it is weak, you may reasonably ask for more", "To mock them", "To avoid the talk", "To lower your price"),
         C("What should you never do about your alternative?", "Bluff about one you do not have", "Improve it", "Think about it", "Estimate it"),
         C("Which reply is honest?", "I have options, and I would prefer to work with you.", "I have ten offers.", "I will leave tomorrow.", "Nobody else wants you."),
         M("Match each action with its effect.", [["Get a second quote", "strengthens your alternative"], ["Estimate their alternative", "shows how much room they have"], ["Bluff", "risks your credibility"]]),
         TF("True or false: A bluff that is discovered can damage your credibility.", "True"),
         TF("True or false: You should ignore the other side's alternative.", "False"),
         F("Type the missing word: Improve your best ___ before the talk.", "alternative"),
         W("Build the sentence.", "I would prefer to work with you.", "never", "preferring"),
         LISTEN("Before I met the client, I asked two other firms for quotes. That way I knew I could walk away at a fair price, and I could speak calmly.", "Why did the speaker get other quotes?", "To strengthen a walk-away option", "To hide the first quote", "To waste time", "To bluff"),
         O("Put the preparation in order.", ["List your alternatives", "Improve the best one", "Estimate the other side's"]),
         YOUR("You are applying for a job and want to negotiate pay. Write two ways to strengthen your alternative before you talk."),
     ]),
    ("ng-a-package", "strategy", "Packages and trade-offs", "NG-A-03",
     "When there are several issues, negotiate them together as a package rather than one by one. Each side values the issues differently, so you can trade what costs you little for what matters to them: this is how both gain. Offer two or three equivalent packages and see which one they prefer: it reveals their priorities. Avoid agreeing to a single issue early, because you lose your flexibility.",
     [
         READ(DEAL, "Which package fits both sides' interests?", "A fast launch plus a reference, with a two-year contract at a steady price", "A low price only", "A one-month trial only", "A launch next year"),
         C("Why negotiate several issues as a package?", "You can trade what costs you little for what matters to them", "It is shorter", "It hides the price", "It avoids all choices"),
         C("Why offer two or three equivalent packages?", "Their choice reveals their priorities", "It confuses them", "It ends the talk", "It lowers your price"),
         C("What is the risk of agreeing to one issue early?", "You lose flexibility", "You gain time", "You gain power", "You end the talk"),
         C("What does “equivalent” mean here?", "Of similar value to you", "Exactly the same", "Cheaper", "Worse"),
         M("Match each issue with who may value it more.", [["Fast launch", "the client"], ["A reference", "the firm"], ["Low risk", "the client and the firm"]]),
         TF("True or false: Each side usually values the issues in the same way.", "False"),
         TF("True or false: Trading across issues can make both sides better off.", "True"),
         F("Type the missing word: Negotiate the issues together as a ___.", "package"),
         W("Build the sentence.", "Here are two packages for you to compare.", "never", "packs"),
         LISTEN("Option one: a faster delivery at the standard price. Option two: standard delivery with a ten percent discount. Which do you prefer? Either works for us.", "What is the speaker doing?", "Offering equivalent packages", "Refusing to trade", "Raising the price", "Ending the talk"),
         O("Put the steps in order.", ["List all the issues", "Rank what each side values", "Offer equivalent packages and learn from the choice"]),
         YOUR("Two issues: delivery date and price. Write two equivalent packages you could offer a customer."),
     ]),
    ("ng-a-counter", "strategy", "Respond to an extreme first offer", "NG-A-04",
     "If the other side opens with an extreme number, do not let it set the range. Do not counter at once with a number that moves toward theirs. Instead, question the basis: “What is this figure based on?” Name your own reference point: “Comparable deals are closer to this range.” You may also decline to respond to a figure that lacks support: “Let's put that to one side and look at the criteria.” Stay calm and curious.",
     [
         C("What is the first move after an extreme opening offer?", "Question what the figure is based on", "Counter with a number halfway", "Walk out", "Accept"),
         C("Why not move toward an extreme number at once?", "It lets their number set the range", "It is rude", "It is slow", "It shows kindness"),
         C("Which phrase names your own reference point?", "Comparable deals are closer to this range.", "That is silly.", "I do not know.", "Whatever you like."),
         C("Which reply declines an unsupported figure politely?", "Let's put that to one side and look at the criteria.", "That is absurd.", "No. Goodbye.", "I give up."),
         C("What tone should you keep?", "Calm and curious", "Angry and loud", "Silent", "Sarcastic"),
         M("Match each move with its aim.", [["Question the basis", "test the figure"], ["Name a reference", "set your own anchor"], ["Set it aside", "avoid being pulled toward it"]]),
         O("Put the response in order.", ["Ask what the figure is based on", "Name your own reference point", "Move to shared criteria"]),
         TF("True or false: Moving halfway at once accepts the other side's range.", "True"),
         F("Type the missing word: What is this figure ___ on?", "based"),
         W("Build the question.", "What is this figure based on?", "does", "base"),
         LISTEN("That number is far from anything comparable. Can you walk me through how you reached it? Then I will show you the range I am looking at.", "What does the speaker do first?", "Asks how the number was reached", "Names a counter figure", "Accepts the number", "Leaves the room"),
         LISTEN("That number is far from anything comparable. Can you walk me through how you reached it? Then I will show you the range I am looking at.", "What will the speaker show next?", "The range they are looking at", "A threat", "A gift", "The door"),
         YOUR("A seller names a price twice the market price. Write a calm reply that questions the basis and names your reference."),
     ]),
    ("ng-a-culture", "pressure", "Across cultures", "NG-A-05",
     "Communication styles differ across cultures and organizations. In some contexts people say “no” directly; in others they say “this will be difficult” and expect you to understand. Silence can mean thinking, respect or disagreement. Some groups decide in the meeting; others decide afterward with seniors. Do not assume your own style is the standard. Ask politely how decisions are made, and check meaning: “Do I understand that this is not possible?”",
     [
         C("Which statement is cautious about culture?", "Styles differ, so I will check what is meant.", "Everyone talks like me.", "Silence always means yes.", "Direct is always better."),
         C("What might “this will be difficult” mean?", "A polite no", "A promise", "An offer", "A joke"),
         C("What can silence mean?", "Thinking, respect or disagreement", "Always agreement", "Always anger", "Nothing"),
         C("How can you check meaning politely?", "Do I understand that this is not possible?", "Say yes or no.", "Stop talking.", "Repeat louder."),
         C("What should you ask about decisions?", "How decisions are made", "How tall people are", "Who is oldest", "Where lunch is"),
         M("Match each style with how it may sound.", [["Direct", "No, we cannot."], ["Indirect", "That may be difficult."], ["Silent pause", "may show thinking"]]),
         TF("True or false: Your own style is the standard everywhere.", "False"),
         TF("True or false: Checking meaning politely prevents misunderstanding.", "True"),
         F("Type the missing word: Styles ___ across cultures.", "differ", "vary"),
         W("Build the sentence.", "Do I understand you correctly?", "never", "understood"),
         LISTEN("In our company the team discusses the offer after the meeting and the director decides the next day. I do not mean to delay; it is how we work.", "What does the speaker explain?", "How decisions are made", "Why they dislike the offer", "That they refuse", "That they are angry"),
         O("Put the steps in order.", ["Notice a message you cannot read", "Ask politely how they mean it", "Confirm what you understood"]),
         YOUR("Write one polite question you could ask to learn how a partner company makes decisions."),
     ]),
    ("ng-a-pressure", "pressure", "Pressure tactics", "NG-A-06",
     "Some negotiators use pressure: false deadlines, a good cop and a bad cop, a final offer that is not final, or asking for a small extra at the end (“nibbling”). Recognize the tactic and name it calmly without accusing: “I notice the deadline is very tight. Can you tell me what happens if we need another day?” Test whether it is real. You can slow down, take a break and return to criteria.",
     [
         READ(EXEC, "What should Lena infer about the deadline?", "It may have been used as pressure, not as a real limit.", "It is certainly real.", "The supplier is honest.", "The offer was cancelled."),
         C("Which is an example of nibbling?", "Asking for a small extra after the deal is nearly agreed", "Offering a discount", "Asking for a break", "Saying thank you"),
         C("What is the good cop and bad cop tactic?", "One person is harsh and the other seems friendly", "Two police officers", "Two equal offers", "A silent partner"),
         C("Which reply names a tactic calmly?", "I notice the deadline is very tight. What happens if we need another day?", "You are lying.", "I hate this.", "Fine, I accept."),
         C("How can you test a deadline?", "Ask what happens if the date passes", "Ignore it", "Accept at once", "Shout"),
         M("Match each tactic with a calm reply.", [["False deadline", "Can we check what happens if we need a day?"], ["Final offer", "Is there any flexibility on other terms?"], ["Nibbling", "Let's review the whole package before adding anything."]]),
         TF("True or false: You should accuse the other side of lying at once.", "False"),
         TF("True or false: You may take a break to slow a pressured moment.", "True"),
         F("Type the missing word: Test whether the deadline is ___.", "real"),
         W("Build the sentence.", "Let's slow down and review the whole deal.", "never", "slows"),
         LISTEN("This is my final offer. But, since we are friends, if you agree now I will also add free delivery. I need an answer by noon.", "Which signs of pressure does the speaker use?", "A final offer and a short deadline", "A long delay", "A refusal", "A silence"),
         O("Put the steps in order.", ["Notice the tactic", "Name it calmly or ask a testing question", "Return to criteria and the whole package"]),
         YOUR("A salesperson says the price rises tomorrow. Write a calm reply that tests the deadline."),
     ]),
    ("ng-a-authority", "pressure", "Authority and approval", "NG-A-07",
     "Many deals need approval from someone not in the room. Find out early who decides and what they care about: “Who else will weigh in on this?” If the other person says “I must check with my director,” ask how you can help her present the case: “Would a one-page summary help?” Make sure you have authority too: say what you can commit to today and what needs approval. Avoid agreeing in principle when the real decision sits elsewhere.",
     [
         READ(TEAM, "What should you do next?", "Ask how to help her present the case to the director.", "Stop the talk.", "Assume the deal is done.", "Threaten her."),
         C("Why ask who decides early?", "So you can address the real decision-maker's concerns", "To pressure the team", "To waste time", "To end the talk"),
         C("Which offer helps the buyer?", "Would a one-page summary help you present this?", "Please decide now.", "That is your problem.", "Goodbye."),
         C("What should you clarify about your own authority?", "What you can commit to today", "Your age", "Your hobbies", "Your commute"),
         C("What is the risk of agreeing in principle?", "The real decision may sit elsewhere", "You gain time", "You gain power", "The talk ends"),
         M("Match each question with its purpose.", [["Who else will weigh in?", "find the decision-maker"], ["What do they care about?", "address their concerns"], ["What can you commit to today?", "set limits on your own authority"]]),
         O("Put the steps in order.", ["Learn who approves the deal", "Help the contact prepare the case", "Be clear about what you can commit to"]),
         TF("True or false: A verbal agreement always binds the absent decision-maker.", "False"),
         F("Type the missing word: Ask who else will ___ in.", "weigh"),
         W("Build the sentence.", "Who else needs to approve this?", "never", "approves"),
         LISTEN("I can agree to the price and the schedule today. The warranty terms need my manager's approval, so I will bring them to her this afternoon.", "What needs approval?", "The warranty terms", "The price", "The schedule", "The meeting time"),
         YOUR("Write a short message offering a one-page summary to help a buyer present your proposal to her director."),
     ]),
    ("ng-a-repair", "pressure", "Repair and renegotiate", "NG-A-08",
     "Deals sometimes go wrong. If you must renegotiate or repair trust, begin with facts and responsibility, not blame: “We missed the delivery date. Here is what happened and what we propose.” Acknowledge the impact on the other side, offer a concrete fix, and ask what they need. When you renegotiate a signed deal, explain what changed and keep the parts that still work. The aim is a working relationship, not a win.",
     [
         C("How should a repair begin?", "With facts and responsibility", "With blame", "With a joke", "With silence"),
         C("Which sentence acknowledges impact?", "We know the delay cost you a week of sales.", "It was not our fault.", "Delays happen.", "You also made mistakes."),
         C("What should a repair include?", "A concrete fix", "A vague promise", "A new threat", "A long delay"),
         C("When renegotiating a signed deal, what should you explain?", "What changed", "Who is guilty", "Why you are tired", "Your holiday plans"),
         C("What is the aim of a repair?", "A working relationship", "A win", "A punishment", "A delay"),
         M("Match each step with an example.", [["Facts", "We missed the date by five days."], ["Impact", "This cost you a week."], ["Fix", "We will deliver free next month."]]),
         O("Put the repair in order.", ["State what happened", "Acknowledge the impact", "Offer a concrete fix and ask what they need"]),
         TF("True or false: Blaming the other side helps rebuild trust.", "False"),
         F("Type the missing word: Offer a concrete ___.", "fix", "remedy"),
         W("Build the sentence.", "We missed the date, and we are sorry.", "never", "miss"),
         LISTEN("We missed the delivery date by five days. I know that cost you a week of sales. We will deliver your next order free and give you a weekly update until we are back on schedule.", "What fix does the speaker offer?", "A free order and weekly updates", "A discount only", "An excuse", "A new contract"),
         LISTEN("We missed the delivery date by five days. I know that cost you a week of sales. We will deliver your next order free and give you a weekly update until we are back on schedule.", "How does the speaker begin?", "With the facts", "With blame", "With a joke", "With a threat"),
         YOUR("Write a short repair message to a client after you made a mistake: facts, impact, fix."),
     ]),
]

if __name__ == "__main__":
    add_stage("negotiator", STAGE, LESSONS, "Advanced", SOURCES)
