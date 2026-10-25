#!/usr/bin/env python3
"""Business & Professional, Advanced stage (about C1-C2): 2 units x 4 lessons, added to track-business.json.

Original wording and invented companies. Ideas (stakeholder alignment, executive summaries, asks with risk and return,
difficult conversations, global teams, contract language, crisis communication, bridging in Q&A) are standard
workplace-communication concepts; sources credited for ideas only.
Run from the project root: python3 tools/curriculum/stages/business_advanced.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from track_lib import C, TF, READ, LISTEN, W, F, O, M, YOUR, add_stage  # noqa: E402

SOURCES = [
    "Common workplace-communication practice: executive summaries, stakeholder mapping, crisis communication (concepts only; original wording)",
    "Plain English guidance for professional and contract writing (ideas only; no text copied; companies in examples are invented)",
]

STAGE = {"id": "advanced", "title": "Advanced", "units": [
    {"id": "influence", "title": "Lead with influence"},
    {"id": "context", "title": "Work across contexts"},
]}

SUMMARY = "Recommendation: replace the current supplier by March. Reason: late deliveries cost us an estimated 400,000 dollars last year, and the new supplier has offered a penalty clause. Risk: a three-week transition. Decision needed from the board by 15 January."
CLAUSE = "The supplier shall deliver the goods on or before 1 June. If delivery is late, the supplier shall pay two percent of the order value for each full week of delay, up to a maximum of ten percent."
LEAK = "The company learned on Tuesday that customer email addresses were exposed for six hours. About 2,000 customers were affected. No passwords were included. The fault has been fixed."

LESSONS = [
    ("bz-a-stakeholders", "influence", "Map and align stakeholders", "BZ-A-01",
     "A good idea fails when the wrong people hear about it late. List the stakeholders: who decides, who is affected, who can block. For each, note what they care about and what they fear. Speak to the key ones before the meeting, so the meeting confirms instead of surprises. Use their language: finance cares about cost and risk, operations about workload, customers about service. Ask for objections early; an early “no” is cheaper than a late one.",
     [
         C("What is a stakeholder?", "A person or group affected by or able to influence a decision", "A kind of share", "A meeting room", "A budget line"),
         C("Why speak to key people before the meeting?", "So the meeting confirms rather than surprises", "To avoid the meeting", "To hide the plan", "To save time only"),
         C("What does finance mainly care about?", "Cost and risk", "Office decoration", "Team names", "Parking"),
         C("Why ask for objections early?", "An early no is cheaper than a late one", "Objections are boring", "It ends the project", "It hides the plan"),
         C("What should you note for each stakeholder?", "What they care about and what they fear", "Their age", "Their address", "Their lunch"),
         M("Match each group with a likely concern.", [["Finance", "cost and risk"], ["Operations", "workload"], ["Customers", "service quality"]]),
         O("Put the steps in order.", ["List the stakeholders", "Learn what each cares about", "Speak to the key ones before the meeting"]),
         TF("True or false: Surprising the decision-makers in the meeting is a good strategy.", "False"),
         F("Type the missing word: Ask for ___ early.", "objections"),
         W("Build the sentence.", "Who can block this decision?", "never", "blocks"),
         LISTEN("I spoke to finance last week. Their concern is the cost in year two, so I have added a savings table. Operations worry about the workload, so I have proposed a phased start.", "What did the speaker do before the meeting?", "Addressed stakeholders' concerns", "Cancelled the plan", "Ignored finance", "Asked for a bigger budget"),
         YOUR("List three stakeholders for a plan to move your team to a four-day week and one concern each may have."),
     ]),
    ("bz-a-summary", "influence", "Write an executive summary", "BZ-A-02",
     "Executives read the first lines and decide how much more to read. An executive summary leads with the recommendation, then gives the reason, the risk and the decision needed, with a date. Use numbers, not adjectives: “cost us 400,000 dollars” rather than “cost us a lot.” Keep it to one page. Everything in the summary must also appear, supported, in the body. Remove background that a decision-maker already knows.",
     [
         READ(SUMMARY, "What does the summary ask of the board?", "A decision by 15 January", "A new supplier name", "A meeting next year", "A budget for staff"),
         READ(SUMMARY, "Which element states the risk?", "Switching suppliers takes about three weeks", "Late deliveries cost money", "A penalty clause was offered", "The board decides"),
         C("What should an executive summary lead with?", "The recommendation", "The history", "The table of contents", "The author's biography"),
         C("Which is better: “cost us a lot” or “cost us 400,000 dollars”?", "cost us 400,000 dollars", "cost us a lot", "both are the same", "neither"),
         C("How long should it be?", "One page", "Twenty pages", "One line only", "As long as the body"),
         M("Match each element with its role.", [["Recommendation", "what you propose"], ["Reason", "why"], ["Decision needed", "what the reader must do and by when"]]),
         O("Put the summary in order.", ["Recommendation", "Reason with numbers", "Risk and decision needed with a date"]),
         TF("True or false: The summary should include claims not supported in the body.", "False"),
         F("Type the missing word: Use numbers, not ___.", "adjectives"),
         W("Build the sentence.", "Decision needed by fifteen January.", "never", "needs"),
         LISTEN("Recommendation: approve the new system. Reason: it will save two hundred hours a month. Risk: training takes four weeks. We need your decision by Friday.", "What is the risk?", "Training takes four weeks", "It will save hours", "The system is new", "The decision is late"),
         YOUR("Write a four-sentence executive summary recommending that your office adopt a new booking tool."),
     ]),
    ("bz-a-ask", "influence", "Make the ask: value, risk and return", "BZ-A-03",
     "When you ask for money, time or authority, make it easy to say yes. State the ask first and specifically: “I am requesting 50,000 dollars to pilot the system for six months.” Show the expected return and how you will measure it. Be honest about risks and what you will do about them. Offer a smaller first step if the full ask is large. Agree on what success will look like, so the later review is fair.",
     [
         C("How should you state an ask?", "First and specifically", "At the end, vaguely", "Hidden in an appendix", "Only in conversation"),
         C("Which request is specific?", "I am requesting 50,000 dollars to pilot the system for six months.", "I would love some help.", "We need more money.", "Please support us."),
         C("Why offer a smaller first step?", "It lowers the risk of saying yes", "It hides the plan", "It lengthens the process", "It removes the review"),
         C("Why agree on success measures in advance?", "The later review is fair", "To avoid reviews", "To hide results", "To win arguments"),
         C("How should you treat risks?", "Be honest about them and say how you will manage them", "Hide them", "Make them sound large", "Skip them"),
         M("Match each part of an ask with its example.", [["Ask", "50,000 dollars for a six-month pilot"], ["Return", "save 200 hours a month"], ["Measure", "monthly time reports"]]),
         O("Put the ask in order.", ["State the ask clearly", "Show return and risk", "Agree how success will be measured"]),
         TF("True or false: A pilot can make a large ask easier to approve.", "True"),
         F("Type the missing word: Agree on how success will be ___.", "measured"),
         W("Build the sentence.", "I am requesting a six month pilot.", "never", "request"),
         LISTEN("I am asking for a six-month pilot at fifty thousand dollars. If it saves two hundred hours a month, as I expect, it pays for itself by the ninth month. We will review it together in month six.", "What measure of success is mentioned?", "Two hundred hours saved a month", "The number of meetings", "The staff mood", "The office size"),
         YOUR("Write the opening three sentences of an email asking your manager to fund a course."),
     ]),
    ("bz-a-hard", "influence", "Hard conversations at work", "BZ-A-04",
     "Bad news and performance problems need preparation. Choose a private time and a calm place. State the purpose at the start: “I want to talk about the missed deadlines.” Give specific examples, not general judgments. Listen to the other person's view before deciding anything. Agree on what will change and when you will check. Speak with respect: you can be direct without being harsh. Document the agreement afterward.",
     [
         C("Where should a hard conversation take place?", "In private and calm", "In front of the team", "In a corridor", "By text only"),
         C("What should you do at the start?", "State the purpose", "Hide it", "Make a joke", "Blame"),
         C("Which is a specific example?", "Three reports were late in March.", "You are lazy.", "You never care.", "Everyone complains."),
         C("What should you do before deciding?", "Listen to the other person's view", "Interrupt", "End the talk", "Repeat the complaint"),
         C("What should you do afterward?", "Document the agreement", "Forget it", "Tell the team", "Post it online"),
         M("Match each step with its example.", [["Purpose", "I want to talk about the missed deadlines."], ["Example", "Three reports were late in March."], ["Next step", "Let's check in again on the 20th."]]),
         O("Put the conversation in order.", ["State the purpose", "Give examples and listen", "Agree on changes and a check date"]),
         TF("True or false: Direct communication must be harsh.", "False"),
         F("Type the missing word: Document the ___ afterward.", "agreement"),
         W("Build the sentence.", "I want to talk about the deadlines.", "never", "talks"),
         LISTEN("I want to talk about the March deadlines. Three reports were late. Before I say more, I would like to hear what has been happening from your side.", "What does the speaker do?", "Gives an example and invites the other view", "Blames the listener", "Ends the talk", "Changes the subject"),
         YOUR("Write the first three sentences you would say to a colleague whose work has been late three times."),
     ]),
    ("bz-a-global", "context", "Work across time zones and cultures", "BZ-A-05",
     "Global teams need explicit habits. Choose meeting times that rotate the inconvenience. Send the agenda and materials in advance, so non-native speakers can prepare. Speak clearly, avoid idioms and sports metaphors, and confirm understanding in writing. Do not assume silence means agreement. Use plain, specific dates: “Friday 12 June, 5 p.m. London time.” Record decisions in a shared place.",
     [
         C("Why send materials in advance?", "Non-native speakers can prepare", "To fill the inbox", "To avoid meetings", "To impress people"),
         C("Which date format is clearest for a global team?", "Friday 12 June, 5 p.m. London time", "Friday next", "Soon", "End of the week"),
         C("What should you avoid with a global team?", "Idioms and sports metaphors", "Plain language", "Written summaries", "Shared notes"),
         C("What can silence mean?", "Agreement, doubt or a language barrier", "Always agreement", "Always disagreement", "Nothing"),
         C("Where should decisions be recorded?", "In a shared place", "Only in memory", "On a private note", "On a napkin"),
         M("Match each habit with its benefit.", [["Rotate meeting times", "shares the inconvenience"], ["Plain dates with time zone", "avoids confusion"], ["Written follow-up", "confirms understanding"]]),
         O("Put the habits in order.", ["Send the agenda and materials", "Speak clearly and avoid idioms", "Confirm decisions in writing"]),
         TF("True or false: Silence always means agreement.", "False"),
         F("Type the missing word: Name the time ___ in every invitation.", "zone"),
         W("Build the sentence.", "Let me confirm that in writing.", "never", "confirmed"),
         LISTEN("Because we work across four time zones, I will rotate the meeting times each month, send the notes within an hour, and write every date with its time zone.", "What habit does the speaker describe?", "Rotating times and clear written notes", "Meeting only in one city", "Skipping notes", "Using idioms"),
         YOUR("Write the invitation line for a meeting between London and Singapore, with the time in both cities."),
     ]),
    ("bz-a-clause", "context", "Precise language in agreements", "BZ-A-06",
     "Contracts and formal agreements need precise language. Shall states an obligation; may states permission; must states a requirement. Avoid vague words like “promptly” or “reasonable” unless they are defined. Specify who does what, by when and what happens if it is not done. Define terms once and use them consistently. This is language practice, not legal advice: for real contracts, ask a qualified lawyer.",
     [
         READ(CLAUSE, "What is the maximum penalty for delay?", "Ten percent of the order value", "Two percent in total", "Nothing", "Half the order value"),
         READ(CLAUSE, "What triggers a penalty?", "Delivery after 1 June", "Delivery before 1 June", "A change of price", "An inspection"),
         C("What does “shall” usually express in a contract?", "An obligation", "A permission", "A hope", "A joke"),
         C("What does “may” usually express?", "Permission", "Obligation", "Prohibition", "Certainty"),
         C("Why avoid undefined words like “promptly”?", "They are open to different readings", "They are too short", "They are impolite", "They are rare"),
         M("Match each word with its meaning.", [["shall", "an obligation"], ["may", "a permission"], ["must not", "a prohibition"]]),
         O("Put the clause elements in order.", ["Who must act", "What they must do and by when", "What happens if they do not"]),
         TF("True or false: Defining a term once and using it consistently reduces confusion.", "True"),
         F("Type the missing word: Specify who does what and by ___.", "when"),
         W("Build the sentence.", "The supplier shall deliver by the first of June.", "never", "delivers"),
         LISTEN("The client may cancel within thirty days. If the client cancels after thirty days, the client shall pay for work already completed.", "Which part is a permission?", "The client may cancel within thirty days", "The client shall pay", "Thirty days", "Work completed"),
         YOUR("Write one clear sentence of an agreement: who delivers what, by when, and the consequence of delay. (Practice only, not legal advice.)"),
     ]),
    ("bz-a-crisis", "context", "Communicate in a crisis", "BZ-A-07",
     "In a crisis, speed and honesty matter. Say what happened, what you know, what you do not know yet and what you are doing about it. Apologize clearly when you are responsible, without excuses. Tell affected people directly and first, then the public. Give an update time even when there is no news: “We will update you at 3 p.m.” Do not speculate or blame. Afterward, explain what you will change.",
     [
         READ(LEAK, "Which fact is reassuring?", "No passwords were included.", "The leak lasted six hours.", "About 2,000 people were affected.", "The company learned on Tuesday."),
         C("What should a crisis message include?", "What happened, what you know, what you do not know, and what you are doing", "Only an apology", "Only the cause", "Only excuses"),
         C("Who should hear first?", "The affected people", "The press only", "The competitors", "Nobody"),
         C("Which apology is clear?", "We are sorry. This was our error, and we are fixing it.", "Mistakes were made.", "We regret any misunderstanding.", "It was a minor issue."),
         C("What should you do when there is no news?", "Give a time for the next update", "Stay silent", "Guess", "Blame someone"),
         M("Match each element with its example.", [["Facts", "Addresses were exposed for six hours."], ["Unknowns", "We do not yet know if any were copied."], ["Action", "We have fixed the fault and are contacting customers."]]),
         O("Put the message in order.", ["Say what happened", "Apologize and say what you are doing", "Set a time for the next update"]),
         TF("True or false: Speculating about the cause helps in a crisis.", "False"),
         F("Type the missing word: Give a time for the next ___.", "update"),
         W("Build the sentence.", "We will update you at three.", "never", "updates"),
         LISTEN("We are sorry. On Tuesday, a fault exposed customer email addresses for six hours. We have fixed it. We do not yet know whether anyone copied them. We will update you at three o'clock.", "What does the speaker say they do not know?", "Whether anyone copied the addresses", "What time it happened", "Whether it is fixed", "How many customers were affected"),
         YOUR("Write a three-sentence message to customers after a delivery system failure: what happened, what you are doing, when you will update."),
     ]),
    ("bz-a-bridge", "context", "Answer tough questions in public", "BZ-A-08",
     "In a panel or press Q&A, answer the question briefly, then bridge to your key message. Bridging phrases: “What matters most is…” and “The important point is…”. Do not repeat a negative word from the question: if asked “Is the product failing?”, do not say “The product is not failing”; say what is true. If you do not know, say so and offer to follow up. Never say “no comment.” Keep answers short and prepare three key messages.",
     [
         C("What does bridging mean in a Q&A?", "Moving from your answer to your key message", "Building a physical bridge", "Skipping the question", "Changing the subject angrily"),
         C("Which phrase is a bridge?", "What matters most is…", "No comment.", "I have no idea.", "That is a silly question."),
         C("Why avoid repeating a negative word from the question?", "It can plant the negative idea", "It is polite", "It is shorter", "It is required"),
         C("What should you say if you do not know?", "I don't know yet, but I will find out and follow up.", "No comment.", "Everyone knows that.", "Next question."),
         C("How many key messages should you prepare?", "Three", "Thirty", "None", "One hundred"),
         M("Match each response with its use.", [["Short answer", "respond to the question"], ["Bridge", "move to your message"], ["Follow-up offer", "handle what you do not know"]]),
         O("Put the answer in order.", ["Answer briefly", "Bridge to your key message", "Support it with one fact"]),
         TF("True or false: “No comment” is a helpful public answer.", "False"),
         F("Type the missing word: What ___ most is the customer's safety.", "matters"),
         W("Build the sentence.", "The important point is customer safety.", "never", "points"),
         LISTEN("Yes, there was a delay. What matters most is that every customer has been contacted, and the new system has already cut waiting times by half.", "How does the speaker bridge?", "From the delay to the customers and the new system", "From a joke to a story", "From a question to silence", "From the fact to blame"),
         YOUR("A journalist asks: “Is your company in trouble?” Write a short answer that is honest and bridges to a key message."),
     ]),
]

if __name__ == "__main__":
    add_stage("business", STAGE, LESSONS, "Advanced", SOURCES)
