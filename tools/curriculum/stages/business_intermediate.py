#!/usr/bin/env python3
"""Business & Professional, Intermediate stage (about B1-B2): 2 units x 4 lessons, added to track-business.json.

Original wording. Ideas (agendas and actions, polite push-back, insight-first data talks, problem-impact-ask, follow-up
emails, receiving feedback) are standard workplace-communication concepts; sources are credited for ideas only.
Run from the project root: python3 tools/curriculum/stages/business_intermediate.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from track_lib import C, TF, READ, LISTEN, W, F, O, M, YOUR, add_stage  # noqa: E402

SOURCES = [
    "Common workplace-communication practice: agendas, action items and clear requests (concepts only; original wording)",
    "Plain English guidance for professional writing (ideas only; no text copied)",
]

STAGE = {"id": "intermediate", "title": "Intermediate", "units": [
    {"id": "lead", "title": "Lead and persuade at work"},
    {"id": "connect", "title": "Connect and follow up"},
]}

AGENDA = "Agenda for Thursday, 30 minutes: 1. Last week's results (5 minutes). 2. The delay in the supplier's delivery (15 minutes). 3. Decisions and who does what (10 minutes)."
CHART = "Sales of our new plan rose from 120 to 180 a month after the price change. Most of the new buyers were students. Returns stayed flat at 4 percent."
EMAIL = "Hi Dana, I'm following up on my message from Monday about the training dates. Could you confirm whether the 12th or the 19th works for your team by Thursday? Thanks, Omar."

LESSONS = [
    ("bz-i-meeting", "lead", "Run a meeting well", "BZ-I-01",
     "A good meeting has a purpose, an agenda and a time limit. Send the agenda in advance. Start on time, state the goal, and give each point a time. During the meeting, keep to the agenda: “Let's park that and come back to it.” At the end, summarize decisions and name who will do what by when. Send notes the same day.",
     [
         READ(AGENDA, "How long is the meeting?", "30 minutes", "15 minutes", "Five minutes", "An hour"),
         READ(AGENDA, "Which item has the most time?", "The supplier delay", "Last week's results", "Decisions and who does what", "Coffee"),
         C("What should you do before the meeting?", "Send the agenda", "Wait and see", "Cancel the room", "Ask for lunch"),
         C("Which sentence keeps the meeting on track?", "Let's park that and come back to it.", "Talk about anything.", "We have no plan.", "I have to go."),
         C("What belongs at the end of a meeting?", "Decisions and who will do what by when", "A new topic", "A joke", "A longer agenda"),
         C("When should you send the notes?", "The same day", "Next month", "Never", "After a year"),
         M("Match each part with its purpose.", [["Agenda", "keeps the topics clear"], ["Time limit", "keeps the talk short"], ["Action list", "shows who does what"]]),
         O("Put a meeting in order.", ["State the goal", "Go through the agenda points", "Summarize decisions and actions"]),
         TF("True or false: A meeting should end with named actions and dates.", "True"),
         F("Type the missing word: Send the agenda in ___.", "advance"),
         W("Build the sentence.", "Let's park that for now.", "never", "parked"),
         LISTEN("To sum up: Ana will confirm the budget by Friday. Raj will book the room for next week. I will send the notes today.", "How many actions does the speaker list?", "Three", "Two", "Four", "One"),
         YOUR("Write a three-point agenda for a 20-minute team meeting, with a time for each point."),
     ]),
    ("bz-i-pushback", "lead", "Push back politely", "BZ-I-02",
     "Sometimes you need to say no, or not yet, to a request. Start with the shared goal, then give the limit and an option: “I want to help the launch succeed. I can't finish it by Friday, but I can have a first version by Tuesday.” Offer choices instead of a flat refusal. Use “can't” for a real limit and “prefer” for a choice. Stay calm and specific.",
     [
         C("Which reply pushes back politely?", "I want the launch to succeed. I can't finish by Friday, but I can send a first version Tuesday.", "No way.", "That is your problem.", "Maybe, whatever."),
         C("What should you start with?", "The shared goal", "A complaint", "A threat", "Silence"),
         C("Which phrase offers an option?", "But I can have a first version by Tuesday.", "Never.", "That is impossible.", "Ask someone else."),
         C("Which word describes a real limit?", "can't", "prefer", "maybe", "like"),
         C("Which statement is specific?", "I need two more days to test it.", "I need more time.", "It is hard.", "I am busy."),
         M("Match each phrase with its job.", [["I want the launch to succeed", "shows the shared goal"], ["I can't finish by Friday", "states the limit"], ["but I can send a draft Tuesday", "offers an option"]]),
         O("Put the reply in order.", ["Name the shared goal", "State the limit", "Offer an option"]),
         TF("True or false: A flat refusal is always the most polite choice.", "False"),
         F("Type the missing word: Offer an ___, not just a refusal.", "option"),
         W("Build the sentence.", "I can't finish it by Friday.", "never", "cannot"),
         LISTEN("I'd love to take on the new report. This week I can't add anything, because I'm finishing the budget. I could start next Monday.", "What option does the speaker offer?", "To start next Monday", "To refuse forever", "To skip the budget", "To quit"),
         LISTEN("I'd love to take on the new report. This week I can't add anything, because I'm finishing the budget. I could start next Monday.", "Why can't the speaker add work now?", "The budget is not finished", "The report is boring", "The week is short", "The office is closed"),
         YOUR("Your manager asks for a report by tomorrow, but you need three days. Write a polite push-back with an option."),
     ]),
    ("bz-i-data", "lead", "Present data with a message", "BZ-I-03",
     "When you present numbers, lead with the insight, then show the proof. “Our new plan sells better after the price change” is stronger than “Here is a chart of sales.” Use one message per chart and point to the key number. Say what it means for the listeners: “So we should keep the lower price.” End with a recommendation or a question.",
     [
         READ(CHART, "What is the best insight to open with?", "The lower price brought many more buyers, mostly students.", "Here is some data.", "Charts are helpful.", "Returns are a topic."),
         READ(CHART, "What stayed the same?", "Returns", "Sales", "The number of students", "The price"),
         C("What should you lead with?", "The insight", "The raw data", "An apology", "A long history"),
         C("How many messages should one chart carry?", "One", "Five", "As many as fit", "None"),
         C("What should you say after showing a number?", "What it means for the listeners", "Nothing", "Another number", "Goodbye"),
         C("How should a data talk end?", "With a recommendation or a question", "With silence", "With a joke", "With a new topic"),
         M("Match each step with its example.", [["Insight", "The lower price brought more buyers."], ["Proof", "Sales rose from 120 to 180 a month."], ["Meaning", "So we should keep the price."]]),
         O("Put the talk in order.", ["State the insight", "Show the key number", "Give your recommendation"]),
         TF("True or false: You should show a chart without saying what it means.", "False"),
         F("Type the missing word: Lead with the ___, then show the proof.", "insight"),
         W("Build the sentence.", "So we should keep the lower price.", "never", "keeps"),
         LISTEN("The takeaway is simple. Our returns stayed at four percent, even though sales grew by half. So the growth did not hurt quality.", "What is the takeaway?", "Growth did not hurt quality", "Returns doubled", "Sales fell", "Quality fell"),
         YOUR("Write the opening sentence and the recommendation for this fact: “Calls dropped from 300 to 200 a week after the new help page.”"),
     ]),
    ("bz-i-escalate", "lead", "Raise a problem clearly", "BZ-I-04",
     "To raise a problem, use three parts: the problem, the impact, and your request. “The shipment is late (problem). We cannot start training on Monday (impact). Could you approve a different supplier by Wednesday? (request).” Stick to facts, say what you already tried, and make the request specific, with a date. Avoid blame; focus on the fix.",
     [
         C("What are the three parts of a clear problem report?", "Problem, impact, request", "Joke, story, goodbye", "Name, age, hobby", "Weather, time, place"),
         C("Which sentence is the request?", "Could you approve a different supplier by Wednesday?", "The shipment is late.", "We cannot start training.", "It is a bad week."),
         C("Which sentence is the impact?", "We cannot start training on Monday.", "The shipment is late.", "Please help.", "I am worried."),
         C("What should you also say?", "What you already tried", "Who is guilty", "How tired you are", "Your favorite color"),
         C("Which request is specific?", "Please approve the supplier by Wednesday.", "Please do something.", "Fix it.", "Help me soon."),
         M("Match each part with an example.", [["Problem", "The shipment is late."], ["Impact", "Training cannot start Monday."], ["Request", "Please approve a new supplier by Wednesday."]]),
         O("Put the message in order.", ["State the problem", "Say the impact", "Make a specific request"]),
         TF("True or false: A good report focuses on blame.", "False"),
         F("Type the missing word: Make a specific ___ with a date.", "request"),
         W("Build the sentence.", "Could you approve it by Wednesday?", "never", "approved"),
         LISTEN("The printer order is delayed by a week. That means we cannot send the brochures to clients on time. I have called the supplier twice. Could you approve a local printer by tomorrow?", "What has the speaker already tried?", "Calling the supplier twice", "Sending the brochures", "Cancelling the order", "Hiring staff"),
         YOUR("Write a three-sentence message that reports a late delivery: problem, impact and request."),
     ]),
    ("bz-i-followup", "connect", "Follow up without nagging", "BZ-I-05",
     "A good follow-up is short, polite and easy to answer. Remind the person what it is about, ask one clear question, and give a date. “Could you confirm the 12th or the 19th by Thursday?” is easier to answer than “Any news?” Thank the person. If you still hear nothing, wait a few days and follow up once more with a new angle, not a louder one.",
     [
         READ(EMAIL, "What does Omar ask Dana to do?", "Choose a training date by Thursday", "Send a gift", "Join a meeting today", "Write a report"),
         READ(EMAIL, "Why is this follow-up easy to answer?", "It asks one clear question and gives a date.", "It is very long.", "It is angry.", "It has no question."),
         C("Which follow-up is better?", "Could you confirm the 12th or the 19th by Thursday?", "Any news?", "Why have you not answered?", "Hello?"),
         C("How many clear questions should a follow-up ask?", "One", "Five", "None", "As many as possible"),
         C("What should you do if there is still no reply?", "Wait a few days and follow up once more", "Send ten messages a day", "Give up forever", "Call every hour"),
         M("Match each part with its job.", [["Reminder", "says what it is about"], ["Clear question", "makes it easy to answer"], ["Date", "shows when you need the answer"]]),
         O("Put the follow-up in order.", ["Say what it is about", "Ask one clear question", "Give a date and say thanks"]),
         TF("True or false: A louder tone is the best second follow-up.", "False"),
         F("Type the missing word: Give a ___ for the answer.", "date"),
         W("Build the sentence.", "I'm following up on my earlier message.", "never", "follows"),
         LISTEN("Hi Dana, just a quick reminder about the training dates. Could you let me know by Thursday if the twelfth or the nineteenth works? Thank you.", "What is the deadline for the answer?", "Thursday", "Monday", "The twelfth", "The nineteenth"),
         YOUR("You asked a colleague for a document four days ago. Write a short, polite follow-up."),
     ]),
    ("bz-i-network", "connect", "Small talk and networking", "BZ-I-06",
     "At an event, start with an easy question: “What brings you here today?” Listen and ask a follow-up about something they said. Share a little about yourself in one or two sentences. Offer something useful, such as an idea or a link. To leave politely, thank them and name a next step: “It was great to meet you. I'll send you that article.” Then exchange contact details.",
     [
         C("Which is a good opening question?", "What brings you here today?", "How much do you earn?", "Are you important?", "Why are you here alone?"),
         C("What should you do after the person answers?", "Ask a follow-up about what they said", "Look at your phone", "Change the subject at once", "Walk away"),
         C("Which line is a polite exit?", "It was great to meet you. I'll send you that article.", "I have to go, bye.", "This is boring.", "You talk too much."),
         C("What can you offer to be useful?", "An idea or a link", "A complaint", "A secret", "A bill"),
         C("How much should you share about yourself at first?", "One or two sentences", "Your whole life story", "Nothing at all", "Only numbers"),
         M("Match each step with an example.", [["Open", "What brings you here today?"], ["Follow up", "How did you get into that field?"], ["Exit", "It was great to meet you."]]),
         O("Put the conversation in order.", ["Ask an opening question", "Listen and ask a follow-up", "Exit politely with a next step"]),
         TF("True or false: A follow-up question shows you listened.", "True"),
         F("Type the missing word: It was great to ___ you.", "meet"),
         W("Build the sentence.", "What brings you here today?", "never", "bring"),
         LISTEN("It was great to meet you. I'll send you that article about remote teams tomorrow. Here is my card.", "What does the speaker promise?", "To send an article", "To call tonight", "To visit", "To write a report"),
         YOUR("Write a short exchange at a conference: an opening question, one follow-up and a polite exit."),
     ]),
    ("bz-i-call", "connect", "Calls and video meetings", "BZ-I-07",
     "On a call, speak a little slower and more clearly than usual. Say who you are and why you are calling. Ask for permission to record. Spell names or numbers when needed: “That's M-A-R-I-A.” Confirm important details by repeating them. If the connection is bad, say so and offer a fix: “I can't hear you well. Could we turn off the video?” Mute when you are not speaking.",
     [
         C("How should you speak on a call?", "A little slower and more clearly", "Very fast", "In a whisper", "With your mouth full"),
         C("Which opening is clear?", "Hello, this is Omar from the training team. I'm calling about the dates.", "Hi.", "Guess who?", "Why are you quiet?"),
         C("How can you check you heard a number correctly?", "Repeat it back", "Ignore it", "Write nothing", "Say it twice quickly"),
         C("Which line handles a bad connection?", "I can't hear you well. Could we turn off the video?", "You are too quiet.", "This is your fault.", "Goodbye."),
         C("When should you mute yourself?", "When you are not speaking", "All the time", "When you speak", "Never"),
         M("Match each habit with its purpose.", [["Spell names", "avoid mistakes"], ["Repeat numbers", "confirm details"], ["Mute", "reduce noise"]]),
         TF("True or false: You should ask permission before recording a call.", "True"),
         TF("True or false: You should speak faster on a call to save time.", "False"),
         F("Type the missing word: Spell the name ___ you need to.", "when"),
         W("Build the sentence.", "Could you repeat that, please?", "never", "repeated"),
         LISTEN("Just to confirm: the meeting is at three thirty on Wednesday, room B twelve. Is that correct?", "What is the speaker doing?", "Confirming details", "Cancelling", "Complaining", "Introducing"),
         O("Put the call in order.", ["Say who you are and why you call", "Discuss the main points", "Confirm the next step"]),
         YOUR("Write the first two sentences you would say when you call a client about a delayed order."),
     ]),
    ("bz-i-receive", "connect", "Receive feedback", "BZ-I-08",
     "Feedback can feel personal, but it helps you grow. Listen without interrupting. Ask a question to understand: “Could you give me an example?” Summarize what you heard: “So you'd like shorter updates.” Thank the person, then decide what to change. You do not have to agree with everything, but respond with respect. Follow up later and show the change.",
     [
         C("What should you do first when you get feedback?", "Listen without interrupting", "Argue", "Leave", "Change the subject"),
         C("Which question helps you understand?", "Could you give me an example?", "Who told you that?", "Why are you rude?", "Are you done?"),
         C("Which sentence summarizes what you heard?", "So you'd like shorter updates.", "That is wrong.", "I know.", "Okay, whatever."),
         C("Do you have to agree with every point?", "No, but you should respond with respect", "Yes, always", "No, and ignore it", "Yes, in writing"),
         C("What shows you took feedback seriously?", "Following up later with a change", "Saying nothing", "Forgetting it", "Blaming a colleague"),
         M("Match each step with its example.", [["Listen", "wait until the person finishes"], ["Ask", "Could you give me an example?"], ["Summarize", "So you'd like shorter updates."]]),
         O("Put the steps in order.", ["Listen to the feedback", "Ask a question and summarize", "Thank the person and decide what to change"]),
         TF("True or false: Interrupting helps you understand feedback.", "False"),
         F("Type the missing word: Thank the person for the ___.", "feedback"),
         W("Build the sentence.", "Thank you, that is helpful.", "never", "helps"),
         LISTEN("Thanks for telling me. So you'd like my updates to be shorter and to start with the main point. I'll try that this week and ask you again on Friday.", "What will the speaker do?", "Write shorter updates", "Stop writing updates", "Ask for a new job", "Delay the update"),
         YOUR("A colleague says your emails are too long. Write a short, respectful reply that summarizes and promises one change."),
     ]),
]

if __name__ == "__main__":
    add_stage("business", STAGE, LESSONS, "Intermediate", SOURCES)
