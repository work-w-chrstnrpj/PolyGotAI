#!/usr/bin/env python3
"""Journalist, Advanced stage (about C1-C2): 2 units x 4 lessons, added to track-journalist.json.

Original wording and invented cases. Ideas (documents, data checks, verifying images, accountability questions, long-form
structure, explanation, ethics, defamation basics) are standard reporting-teaching concepts; sources credited for ideas only.
This is language practice, not legal advice. Run from the project root: python3 tools/curriculum/stages/journalist_advanced.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from track_lib import C, TF, READ, LISTEN, W, F, O, M, YOUR, add_stage  # noqa: E402

SOURCES = [
    "Public-domain style and ethics guidance for reporters (concepts only; no text copied)",
    "Standard newsroom practice for records, data, verification, interviews and fairness (ideas only; original wording; cases are invented)",
]

STAGE = {"id": "advanced", "title": "Advanced", "units": [
    {"id": "investigate", "title": "Investigate and verify"},
    {"id": "depth", "title": "Depth and ethics"},
]}

BUDGET = "A town report says spending on road repair rose from 2 million to 3 million dollars in a year. The population of the town grew from 40,000 to 60,000 over the same period, and prices of asphalt rose by 30 percent."
POLL = "A website survey found that 80 percent of respondents oppose the new tax. The survey was shared by an anti-tax group, and 400 people answered. Respondents chose themselves."
PHOTO = "A photograph of a flooded street spreads online with the caption “Happening now downtown.” A search finds the same image on a news site from three years ago."
EVADE = "The mayor was asked whether the contract was awarded without a public tender. She replied only that the city always follows the rules and has a proud record of transparency."

LESSONS = [
    ("jn-a-records", "investigate", "Follow the documents", "JN-A-01",
     "Strong stories rest on documents: budgets, contracts, court files, inspection reports. Many are public records you can request. Read the original, not a summary. Note dates, names, amounts and signatures, and keep a timeline. Ask what a document does not say. When you request records, be specific and polite: the exact title, the date range and the office. Keep copies, and record how and when you obtained each one.",
     [
         C("Why read the original document?", "Summaries can omit or change details", "Originals are shorter", "Summaries are always wrong", "It saves paper"),
         C("What should you note when you read a document?", "Dates, names, amounts and signatures", "Only the title", "The font", "The page color"),
         C("What helps a request for records succeed?", "A specific title, date range and office", "A vague demand", "A threat", "A long letter about your hopes"),
         C("What question should you ask about a document?", "What does it not say?", "Is it heavy?", "Who printed it?", "Is it long?"),
         C("What should you record about each document?", "How and when you obtained it", "Its color", "Your mood", "The weather"),
         M("Match each record with what it can show.", [["Contract", "who agreed to what, and for how much"], ["Inspection report", "the condition of a building"], ["Court file", "claims and decisions in a case"]]),
         O("Put the steps in order.", ["Identify the document you need", "Request it with a specific description", "Read the original and build a timeline"]),
         TF("True or false: A summary can replace the original document.", "False"),
         F("Type the missing word: Keep a ___ of dates and events.", "timeline"),
         W("Build the sentence.", "I requested the contract by title and date.", "never", "request"),
         LISTEN("I did not rely on the press release. I asked for the signed contract, and it showed a clause the release did not mention: the price could rise by twenty percent.", "Why did the reporter ask for the contract?", "The press release left something out", "The contract was short", "The press release was perfect", "The mayor asked"),
         YOUR("Write a one-sentence request to a city office for the inspection report of a public swimming pool, with a date range."),
     ]),
    ("jn-a-data", "investigate", "Read data with suspicion", "JN-A-02",
     "Numbers can mislead even when they are accurate. Adjust for change in size: spending that rises while the population rises may be falling per person. Know the difference between a mean and a median: a few very high values pull the mean up. Ask how a survey chose its respondents: a self-selected poll shows only those who chose to answer. Report the margin of error. Compare like with like, and ask for the dataset when you can.",
     [
         READ(BUDGET, "What does the passage suggest about road spending per resident?", "It may have fallen once population growth is considered.", "It certainly doubled.", "It is unchanged.", "It is unknown and irrelevant."),
         READ(POLL, "What is the main weakness of this survey?", "Respondents chose themselves and were reached through one side.", "It was too short.", "It asked too many people.", "It had a clear question."),
         C("Why is the mean sometimes misleading?", "A few very high values can pull it up", "It is always smaller", "It ignores averages", "It is the same as the median"),
         C("What is a self-selected poll?", "Respondents chose to take part", "Respondents were randomly chosen", "Respondents were paid", "Respondents were experts"),
         C("What is the best way to compare spending over time?", "Adjust for population and prices", "Compare raw totals only", "Ignore prices", "Use the biggest number"),
         M("Match each concept with a question.", [["Per person", "Does the number account for size?"], ["Median", "What does the typical case look like?"], ["Margin of error", "How uncertain is the estimate?"]]),
         TF("True or false: A survey that people chose to answer represents everyone.", "False"),
         TF("True or false: Asking for the dataset can help check a claim.", "True"),
         F("Type the missing word: Report the margin of ___.", "error"),
         W("Build the question.", "How were the respondents chosen?", "does", "choose"),
         LISTEN("The average salary at the firm is eighty thousand dollars. But the owner earns three million. The typical worker earns closer to forty thousand.", "What is the speaker showing?", "How an extreme value pulls up the average", "That salaries are equal", "That the firm is poor", "That averages are never useful"),
         O("Put the checks in order.", ["Find the denominator", "Adjust for size and prices", "Check how the data were collected"]),
         YOUR("A report says accidents rose from 20 to 30 while traffic doubled. Write two careful sentences for a news story."),
     ]),
    ("jn-a-verify", "investigate", "Verify images and online claims", "JN-A-03",
     "Viral images and posts can be old, edited or from somewhere else. Check provenance: who first posted it and when? Run a reverse image search. Look at details that can be confirmed: signs, shadows, weather, landmarks. Contact the source and ask how they got it. Look for the same event in independent reports. If you cannot confirm it, label it clearly or leave it out. Speed is never a reason to publish unverified claims.",
     [
         READ(PHOTO, "What does the image search suggest?", "The image is old and not from the claimed event.", "The image is new.", "The image proves the flood.", "The caption is accurate."),
         C("What is provenance?", "The origin and history of the material", "A kind of filter", "A photo size", "A hashtag"),
         C("What does a reverse image search show?", "Where else the image has appeared", "The photographer's age", "The camera brand only", "The location of the viewer"),
         C("Which detail can you check to place a photo?", "Signs, weather and landmarks", "Its likes", "The caption's font", "The filter name"),
         C("What if you cannot confirm a claim?", "Label it or leave it out", "Publish it fast", "Assume it is true", "Delete your notes"),
         M("Match each check with its purpose.", [["Reverse search", "finds earlier appearances"], ["Contact the source", "learns how it was obtained"], ["Compare with reports", "tests independence"]]),
         O("Put the steps in order.", ["Find who posted it first", "Check details and run a reverse search", "Confirm with independent sources before publishing"]),
         TF("True or false: Speed is a good reason to skip verification.", "False"),
         F("Type the missing word: Check the ___ of the material.", "provenance", "origin"),
         W("Build the sentence.", "I cannot confirm where this was taken.", "never", "confirms"),
         LISTEN("The post says the video is from yesterday's storm. But the shop sign in the background closed two years ago. Either the video is old or the sign is wrong, and I will check.", "What detail raises doubt?", "The shop sign in the background", "The weather", "The time of day", "The caption's length"),
         YOUR("Write three steps you would take before sharing a dramatic photo of a fire that you found online."),
     ]),
    ("jn-a-accountability", "investigate", "Accountability questions", "JN-A-04",
     "When a powerful person avoids a question, ask again precisely. Keep questions short and closed when you need a fact: “Was a public tender held, yes or no?” Do not accept a general statement as an answer: note it and return to the point. Use silence: after a short answer, wait. Quote the exact evasion and the exact question in your story, so the reader can judge. Stay courteous and firm; the aim is the answer, not the confrontation.",
     [
         READ(EVADE, "Did the mayor answer the question?", "No, she replied in general terms.", "Yes, she said there was no tender.", "Yes, she said there was a tender.", "She asked a new question."),
         C("Which follow-up is best?", "Was a public tender held, yes or no?", "Why do you hate me?", "Is the city proud?", "Can we talk about the weather?"),
         C("What should you do with a general statement?", "Note it and return to the question", "Accept it", "Argue about it", "Leave"),
         C("What can silence do after a short answer?", "Invite the person to add more", "End the interview", "Confuse the reporter", "Anger the person"),
         C("How should you present an evasion in the story?", "Quote the question and the reply exactly", "Hide it", "Call the person a liar", "Skip it"),
         M("Match each move with its aim.", [["Closed question", "get a fact"], ["Return to the point", "avoid a drift"], ["Silence", "invite more"]]),
         O("Put the steps in order.", ["Ask a short, precise question", "Note and return if it is avoided", "Report the question and reply exactly"]),
         TF("True or false: Staying courteous reduces the chance of a firm answer.", "False"),
         F("Type the missing word: Return to the ___ if it is avoided.", "question", "point"),
         W("Build the question.", "Was a tender held, yes or no?", "does", "hold"),
         LISTEN("I appreciate that, but my question was narrower. Did the council compare any other offers before choosing this company?", "What is the reporter doing?", "Returning to a precise question", "Ending the interview", "Making an accusation", "Agreeing with the speaker"),
         YOUR("An official gives a general answer about safety. Write the precise follow-up question you would ask."),
     ]),
    ("jn-a-feature", "depth", "Structure a long feature", "JN-A-05",
     "A long feature needs architecture. Open with a scene or person, state the stakes in a nut paragraph, then move through sections: background, conflict, evidence and what comes next. Braid the human story and the explanation, returning to the person between sections. Use subheads or a clear change of scene. End with an image or a question that echoes the opening, not a summary. Cut anything that does not serve the central question.",
     [
         C("What does a nut paragraph do?", "States the stakes and why the story matters", "Lists the staff", "Ends the story", "Gives the weather"),
         C("What does it mean to braid a feature?", "Alternate the human story with explanation", "Tie two reports together with string", "Repeat the headline", "Remove quotes"),
         C("Which ending suits a feature?", "An image that echoes the opening", "A long summary of every point", "A new statistic", "An apology"),
         C("What should you cut?", "Anything that does not serve the central question", "The scene", "The nut paragraph", "The ending"),
         C("What can mark a change of section?", "A subhead or a clear change of scene", "A longer title", "A new font", "A joke"),
         M("Match each part with its job.", [["Opening scene", "draws the reader in"], ["Nut paragraph", "states the stakes"], ["Sections", "carry background, conflict and evidence"]]),
         O("Put the structure in order.", ["Open with a scene or person", "State the stakes", "Move through the sections, braiding story and explanation", "End with an echo of the opening"]),
         TF("True or false: A feature should end by repeating all its facts.", "False"),
         F("Type the missing word: The nut paragraph states the ___.", "stakes"),
         W("Build the sentence.", "The story returns to the family between sections.", "never", "return"),
         LISTEN("The piece opens with a woman measuring the water in her kitchen. Then it explains the city's pipe system. Then it returns to her, and ends with her standing by the same sink.", "Which technique is described?", "Braiding and an echo ending", "A summary lede", "A list", "A quote wall"),
         YOUR("Outline a feature about a local bakery closing: the opening scene, the stakes, three sections and the ending image."),
     ]),
    ("jn-a-explain", "depth", "Explain complexity clearly", "JN-A-06",
     "Complex topics lose readers when the writer assumes knowledge. Define each term the first time you use it, in plain words. Use one precise analogy, not three; test that it does not mislead. Layer information: give the simple version first, then add the detail that readers need. Use concrete examples and numbers they can picture. Cut jargon, or explain it in a clause. Your test is whether a smart friend outside the field could repeat your explanation.",
     [
         C("What should you do when you first use a technical term?", "Define it in plain words", "Skip it", "Use it twice", "Hide it"),
         C("How many analogies should you rely on?", "One precise analogy", "Five", "None ever", "As many as possible"),
         C("What does layering mean?", "Give the simple version first, then add detail", "Put the hardest part first", "Hide the topic", "Repeat the headline"),
         C("What test shows a clear explanation?", "A smart friend outside the field could repeat it", "It is full of terms", "It is very long", "It is very short"),
         C("What should you do with jargon?", "Cut it or explain it in a clause", "Add more", "Keep it unexplained", "Move it to the title"),
         M("Match each tool with its job.", [["Definition", "explains a term"], ["Analogy", "shows a familiar parallel"], ["Layering", "builds understanding gradually"]]),
         O("Put the explanation in order.", ["State the simple version", "Define key terms", "Add the detail readers need"]),
         TF("True or false: A misleading analogy is better than none.", "False"),
         F("Type the missing word: Explain jargon in a ___.", "clause", "phrase"),
         W("Build the sentence.", "Think of inflation as a slow leak.", "never", "inflations"),
         LISTEN("Interest is the price of borrowing. If you borrow a hundred dollars at five percent, you pay five dollars a year for using it. That is the idea; the details come next.", "What technique does the speaker use?", "A plain definition with a simple example", "A long list of terms", "A heavy analogy", "A joke"),
         YOUR("Explain what a budget deficit is in three sentences for a reader with no economics background."),
     ]),
    ("jn-a-ethics", "depth", "Ethics: harm, privacy and conflicts", "JN-A-07",
     "Journalists balance the public's right to know against possible harm. Ask: Is there a public interest, not just curiosity? Can a person be identified who should not be, such as a minor or a victim? Have you told sources how their words will be used? Disclose conflicts of interest: if you own shares in a company you cover, say so or step aside. Do not pay sources. Minimize harm without hiding the truth.",
     [
         C("What is the public interest test?", "Is the information of real importance to the public, not just curiosity?", "Is it popular?", "Does it get clicks?", "Is it new?"),
         C("Who may need extra protection when named?", "A minor or a victim", "A politician in public", "A company director", "A famous author"),
         C("What should you do with a conflict of interest?", "Disclose it or step aside", "Hide it", "Ignore it", "Pay someone"),
         C("Should you pay a source for information?", "No", "Always", "Only on Sundays", "If they ask nicely"),
         C("What does minimizing harm mean?", "Reducing needless damage without hiding the truth", "Hiding all hard facts", "Softening every fact", "Skipping the story"),
         M("Match each principle with an example.", [["Public interest", "a story about misused public funds"], ["Privacy", "not naming a child victim"], ["Disclosure", "stating that you own shares in the company"]]),
         O("Put the questions in order.", ["Is there a public interest?", "Who could be harmed?", "How can you reduce harm and stay truthful?"]),
         TF("True or false: Curiosity alone always justifies publication.", "False"),
         F("Type the missing word: Disclose any conflict of ___.", "interest"),
         W("Build the sentence.", "I own shares in that company.", "never", "owns"),
         LISTEN("I own a small number of shares in the firm I am writing about. I told my editor, and another reporter will cover the story so readers can trust it.", "What does the reporter do about the conflict?", "Discloses it and passes the story on", "Hides it", "Writes more strongly", "Quits the paper"),
         YOUR("A story could identify a teenager who witnessed a crime. Write two questions you would ask before deciding what to publish."),
     ]),
    ("jn-a-fair", "depth", "Truth, opinion and fair comment", "JN-A-08",
     "Accuracy protects readers and the writer. A statement of fact that is true and well sourced is the strongest position. Opinion is different: label it clearly and base it on stated facts. Be careful with serious allegations: have documents or two reliable sources, offer the person a chance to respond, and report their reply. When you report a statement from an official source or court, attribute it precisely. Corrections should be prominent and prompt. This is not legal advice; follow your editor's guidance.",
     [
         C("What is the strongest position for a statement of fact?", "It is true and well sourced", "It is popular", "It is short", "It is witty"),
         C("How should opinion be treated?", "Labeled and based on stated facts", "Presented as fact", "Hidden", "Made louder"),
         C("What do serious allegations need?", "Documents or two reliable sources and a chance to respond", "A single rumor", "A strong feeling", "A catchy headline"),
         C("What should you do when reporting an official statement?", "Attribute it precisely", "Rewrite it as your own claim", "Remove the source", "Exaggerate it"),
         C("How should corrections appear?", "Prominently and promptly", "Quietly and late", "Never", "In a footnote years later"),
         M("Match each type with its treatment.", [["Fact", "source and verify"], ["Opinion", "label and base on facts"], ["Allegation", "documents, two sources, right of reply"]]),
         O("Put the steps in order.", ["Gather documents or two reliable sources", "Offer the person a chance to respond", "Report the reply and attribute precisely"]),
         TF("True or false: A rumor is enough to publish a serious allegation.", "False"),
         F("Type the missing word: Offer a right of ___.", "reply", "response"),
         W("Build the sentence.", "According to the court filing, the firm denied it.", "never", "denies"),
         LISTEN("We contacted the company before publishing. Its spokesperson denied the claim and said the figures were wrong. We have included the full reply below our report.", "What fairness step did the newsroom take?", "Gave the company a chance to respond", "Ignored the company", "Deleted the reply", "Waited a year"),
         YOUR("Write one careful sentence that reports an allegation against a company, with attribution and its right of reply."),
     ]),
]

if __name__ == "__main__":
    add_stage("journalist", STAGE, LESSONS, "Advanced", SOURCES)
