#!/usr/bin/env python3
"""Advertising & Copywriting, Intermediate stage (about B1-B2): 2 units x 4 lessons, added to track-copywriter.json.

Original wording and invented products. Ideas (reader research, proof, answering objections, mini-stories, subject lines,
page structure, testing one change, honest urgency) are standard copywriting-teaching concepts; sources credited for ideas only.
Run from the project root: python3 tools/curriculum/stages/copywriter_intermediate.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from track_lib import C, TF, READ, LISTEN, W, F, O, M, YOUR, add_stage  # noqa: E402

SOURCES = [
    "Classic advertising principles from public-domain and widely taught sources (concepts only; no text copied)",
    "Plain-language and honest-advertising guidance (ideas only; original wording; products in examples are invented)",
]

STAGE = {"id": "intermediate", "title": "Intermediate", "units": [
    {"id": "persuade", "title": "Persuade with proof"},
    {"id": "channels", "title": "Write for each channel"},
]}

REVIEWS = "Customers of the Lumo desk lamp say: “It turns on with one touch.” “The light is soft, so my eyes don't hurt after work.” One buyer adds that the cord could be longer."
PAGE = "Lumo desk lamp. Soft light that is kind to your eyes. 4.6 stars from 1,200 buyers. Two-year warranty. Try it for 30 days and return it free if you don't love it. Buy now."
EMAIL = "Subject: Your cart is waiting. Hi Sam, you left a Lumo lamp in your cart. It is still in stock, and shipping is free until Friday."

LESSONS = [
    ("cp-i-reader", "persuade", "Learn from your reader", "CP-I-01",
     "Good copy starts with the reader's words, not yours. Read customer reviews and notes. Look for the problem they describe and the phrases they repeat. “The light is soft, so my eyes don't hurt” tells you the benefit that matters. Use their words in your headline: it will sound true. Also note complaints; they show what you must answer.",
     [
         READ(REVIEWS, "Which benefit appears in the reviews?", "A soft light that is easy on the eyes", "A very low price", "A free gift", "A large size"),
         READ(REVIEWS, "What complaint appears?", "The cord is too short.", "The light is too soft.", "The lamp is too heavy.", "The lamp is expensive."),
         C("Where should you look for the reader's words?", "Reviews and customer notes", "Your own opinion only", "A dictionary", "An old poster"),
         C("Why use the reader's phrases in a headline?", "It sounds true to other readers.", "It makes it longer.", "It hides the product.", "It adds jokes."),
         C("What do complaints show you?", "What you must answer", "What to hide", "What to delete", "What to ignore"),
         M("Match each item with how it helps.", [["Repeated phrase", "shows what readers value"], ["Complaint", "shows a worry to answer"], ["Problem described", "shows the need"]]),
         O("Put the research in order.", ["Read the reviews", "Mark repeated phrases and problems", "Use the phrases in your copy"]),
         TF("True or false: You should ignore the words customers use.", "False"),
         F("Type the missing word: Use the reader's own ___.", "words"),
         W("Build the sentence.", "Customers like the soft light.", "never", "likes"),
         LISTEN("I read fifty reviews. Thirty people mentioned eye strain. Only two mentioned the color. So the headline should talk about tired eyes, not about color.", "What should the headline talk about?", "Tired eyes", "Color", "Price", "Shipping"),
         YOUR("List two phrases a customer might use about a backpack, and write a headline that uses one of them."),
     ]),
    ("cp-i-proof", "persuade", "Proof makes claims believable", "CP-I-02",
     "A claim like “soft, kind light” is easier to believe with proof. Use numbers (“4.6 stars from 1,200 buyers”), a guarantee (“30 days, free returns”), a short customer quote, or a clear demonstration. Be specific: “1,200 buyers” beats “thousands.” Never invent proof. If you have little proof, say less and be honest about what you can show.",
     [
         READ(PAGE, "Which phrase is a guarantee?", "Return it free if you don't love it.", "Soft light that is kind to your eyes.", "4.6 stars from 1,200 buyers.", "Buy now."),
         READ(PAGE, "Which phrase is a number as proof?", "4.6 stars from 1,200 buyers", "Soft light", "Buy now", "Try it"),
         C("Why add proof to a claim?", "It makes the claim easier to believe.", "It makes the claim louder.", "It hides the price.", "It adds a joke."),
         C("Which is more specific?", "1,200 buyers", "thousands of buyers", "lots of buyers", "many people"),
         C("What should you do if you have little proof?", "Say less and stay honest", "Invent a number", "Hide the product", "Copy another ad"),
         M("Match each proof with its type.", [["4.6 stars from 1,200 buyers", "numbers"], ["30-day free returns", "guarantee"], ["“It turns on with one touch.”", "customer quote"]]),
         TF("True or false: You may invent proof if the product is good.", "False"),
         TF("True or false: A guarantee reduces the buyer's risk.", "True"),
         F("Type the missing word: Never invent ___.", "proof"),
         W("Build the sentence.", "Try it for thirty days.", "never", "tries"),
         LISTEN("Our tea is grown on one farm. Here is the farmer's name, the date it was picked, and a photo of the field.", "What kind of proof is this?", "Showing where it comes from", "A famous name", "A discount", "A contest"),
         O("Put the steps in order.", ["Make a claim", "Add one piece of proof", "Make the proof specific"]),
         YOUR("Your product is a reusable water bottle. Write one claim and two kinds of honest proof for it."),
     ]),
    ("cp-i-objection", "persuade", "Answer the reader's doubts", "CP-I-03",
     "Before people buy, they have doubts: Is it worth the price? Will it work for me? What if I don't like it? Good copy answers the doubts it can. Use a short section called “Questions” or add a line near the button: “Free returns for 30 days.” Answer honestly. If the cord is short, say so and offer a solution: “Includes a 2-meter extension.”",
     [
         C("What are objections?", "Doubts that stop people from buying", "Jokes in the ad", "Colors in the logo", "Names of the writers"),
         C("Which line answers the doubt “What if I don't like it?”", "Free returns for 30 days.", "Best lamp ever.", "Buy now.", "Soft light."),
         C("Where can you answer doubts?", "Near the button or in a questions section", "In the footer only", "Nowhere", "In the headline only"),
         C("The cord is short. What should you do?", "Say so and offer a solution", "Hide it", "Blame the buyer", "Delete the reviews"),
         C("Which answer is honest and helpful?", "The cord is 1 meter; we include a 2-meter extension.", "The cord is perfect.", "Nobody cares about cords.", "Please do not ask."),
         M("Match each doubt with an answer.", [["Is it worth the price?", "Two-year warranty"], ["Will it fit my desk?", "Size: 30 by 12 cm"], ["What if I don't like it?", "Free returns"]]),
         TF("True or false: You should answer doubts honestly.", "True"),
         TF("True or false: Hiding a real weakness builds trust.", "False"),
         F("Type the missing word: Answer the reader's ___.", "doubts"),
         W("Build the sentence.", "Free returns for thirty days.", "never", "return"),
         LISTEN("People ask if the lamp is bright enough for reading. It gives light equal to a 60-watt bulb, and you can dim it for comfort.", "What doubt does this answer?", "Is it bright enough?", "Is it cheap?", "Is it blue?", "Is it heavy?"),
         O("Put the steps in order.", ["Find the common doubt", "Write a short, honest answer", "Place it near the button"]),
         YOUR("Write three questions a customer might have about a phone case, with one honest answer each."),
     ]),
    ("cp-i-story", "persuade", "A mini-story in copy", "CP-I-04",
     "A very short story can sell an idea. Use a person, a problem and a change in two or three sentences: “Mira worked late and her eyes hurt. She switched to a soft-light lamp. Now she finishes the day without a headache.” Keep it true and keep it about the reader's situation. End on the benefit, then give the next step.",
     [
         C("What does a mini-story need?", "A person, a problem and a change", "A joke and a price", "A map", "A long list"),
         C("Which is a mini-story?", "Mira worked late and her eyes hurt. She switched lamps. Now she finishes without a headache.", "The lamp is soft.", "Buy the lamp.", "Eyes are important."),
         C("How long should it be?", "Two or three sentences", "Ten paragraphs", "One word", "A whole page"),
         C("Where should the story end?", "On the benefit, then a next step", "On a question", "On a joke", "On the price"),
         C("What must a mini-story be?", "True", "Funny", "Long", "Secret"),
         M("Match each part with its example.", [["Person", "Mira"], ["Problem", "her eyes hurt after late work"], ["Change", "she switched to a soft-light lamp"]]),
         O("Put the mini-story in order.", ["Introduce the person", "Show the problem", "Show the change and the benefit"]),
         TF("True or false: A made-up story presented as a real customer is honest.", "False"),
         F("Type the missing word: End on the ___.", "benefit"),
         W("Build the sentence.", "She finishes the day with ease.", "never", "finish"),
         LISTEN("Omar kept missing his bus. He put the schedule on his phone's home screen. Now he is never late.", "What is the benefit?", "He is never late", "He found a phone", "He missed a bus", "He moved home"),
         LISTEN("Omar kept missing his bus. He put the schedule on his phone's home screen. Now he is never late.", "What was the problem?", "He kept missing his bus", "He lost his phone", "He moved home", "He was never late"),
         YOUR("Write a three-sentence mini-story for a notebook: person, problem, change."),
     ]),
    ("cp-i-email", "channels", "Subject lines and short emails", "CP-I-05",
     "In email, the subject line decides whether the message is opened. Keep it short, specific and honest: “Free shipping until Friday” is better than “Amazing offer!!!” Use the reader's name sparingly. In the body, put the main message first, use short paragraphs and give one clear button or link. Do not trick people with “Re:” or fake urgency.",
     [
         READ(EMAIL, "What is the main message of this email?", "The lamp is in stock, and shipping is free until Friday.", "The lamp is new.", "Sam is a customer.", "The cart is full."),
         C("Which subject line is better?", "Free shipping until Friday", "Amazing offer!!!", "Hello", "Open this now!!!"),
         C("What should the body put first?", "The main message", "A long story", "The signature", "A list of rules"),
         C("How many clear links or buttons should an email have?", "One main one", "Ten", "None", "As many as possible"),
         C("Which trick should you avoid?", "Starting the subject with a fake “Re:”", "Using a short subject", "Being specific", "Being honest"),
         M("Match each part with its aim.", [["Subject line", "gets the email opened"], ["First line", "states the main message"], ["Button", "makes the next step clear"]]),
         TF("True or false: A short, specific subject is usually clearer.", "True"),
         TF("True or false: Fake urgency builds long-term trust.", "False"),
         F("Type the missing word: Put the main message ___.", "first"),
         W("Build the sentence.", "Shipping is free until Friday.", "never", "freed"),
         LISTEN("Subject: Your size is back in stock. Body: The grey jacket in medium is available again. Order today and it ships tomorrow.", "What is the main message?", "The jacket is back in stock", "The jacket is gone", "The store is closing", "The price rose"),
         O("Put the email in order.", ["Write a specific subject", "State the main message first", "Add one clear button"]),
         YOUR("Write a subject line and a two-sentence email telling a customer their order has shipped."),
     ]),
    ("cp-i-page", "channels", "A simple page that sells", "CP-I-06",
     "A page works best when it follows the reader's questions. Start with a clear headline and a short line that says who it is for. Then show the benefits, the proof and answers to doubts. End with one clear action. Use headings so people can scan, short paragraphs, and a picture that shows the product in use. Put the button where the decision happens.",
     [
         READ(PAGE, "Which part is the call to action?", "Buy now.", "Soft light.", "4.6 stars.", "Two-year warranty."),
         C("What should a page start with?", "A clear headline", "A long terms list", "A joke", "The price only"),
         C("What follows the headline?", "Benefits, proof and answers to doubts", "More headlines", "A contest", "A map"),
         C("How many main actions should a page ask for?", "One", "Five", "Zero", "Ten"),
         C("Why use headings?", "People can scan the page", "They look strange", "They hide text", "They add words"),
         M("Match each part with its job.", [["Headline", "states the main benefit"], ["Proof", "makes the claims believable"], ["Button", "makes the next step clear"]]),
         O("Put the page in order.", ["Headline and who it is for", "Benefits, proof and answers", "One clear action"]),
         TF("True or false: A picture that shows the product in use can help.", "True"),
         TF("True or false: A page should ask for five different actions.", "False"),
         F("Type the missing word: End with one clear ___.", "action"),
         W("Build the sentence.", "Try it for thirty days.", "never", "tried"),
         LISTEN("Headline: Light that is kind to your eyes. Below it: who the lamp is for, three benefits, customer ratings, the warranty, and a single button that says Try it free.", "What is the single action?", "Try it free", "Read more", "Call us", "Share"),
         YOUR("List the six parts of a simple sales page for a language course, in order."),
     ]),
    ("cp-i-test", "channels", "Test one change", "CP-I-07",
     "Copywriters test ideas instead of arguing about them. In an A/B test, half the readers see version A and half see version B. Change only one thing, such as the headline, so you know what made the difference. Decide in advance what counts as success, such as more clicks. Wait for enough readers before you decide. A result from ten people is not reliable.",
     [
         C("What is an A/B test?", "Two versions shown to different readers", "A test of spelling", "A grading system", "An ad on two pages at once"),
         C("How many things should you change per test?", "One", "Five", "As many as possible", "None"),
         C("What should you decide before the test?", "What counts as success", "The final winner", "The color of the report", "Nothing"),
         C("Why wait for enough readers?", "A small group can mislead", "It is polite", "It costs less", "It ends the test"),
         C("Which result is least reliable?", "Version B won with ten readers", "Version B won with ten thousand readers", "Version B won in two weeks with steady numbers", "Both versions were close"),
         M("Match each step with its purpose.", [["Change one thing", "know what made the difference"], ["Set a goal", "know what success means"], ["Wait for enough readers", "avoid a lucky result"]]),
         O("Put the test in order.", ["Choose one change", "Show both versions to different readers", "Compare the results"]),
         TF("True or false: You can change the headline, the picture and the price in one test and know which mattered.", "False"),
         F("Type the missing word: Change one ___ at a time.", "thing"),
         W("Build the sentence.", "We tested two headlines.", "never", "tests"),
         LISTEN("Headline A got 40 clicks and headline B got 55 clicks, each from about a thousand readers. The difference is probably real.", "What does the speaker conclude?", "B is probably better", "A is better", "Both failed", "The test is too small"),
         YOUR("Write two versions of a headline for a bike helmet and say what you would count as success."),
     ]),
    ("cp-i-urgent", "channels", "Honest urgency and fine print", "CP-I-08",
     "Urgency means a real reason to act now. “Sale ends Friday” is honest if the sale really ends Friday. “Only 3 left!” must be true. Fake countdowns and invented scarcity damage trust and can be against the rules. Put important conditions in plain words near the offer, not hidden: “Free shipping on orders over 40 dollars.” Clear terms reduce complaints.",
     [
         C("When is urgency honest?", "When there is a real deadline or limit", "When it sounds exciting", "When competitors do it", "When the writer is tired"),
         C("Which line is honest if true?", "Sale ends Friday.", "Only 1 left!!! (but there are 500)", "Last chance forever!", "Everyone is buying right now!"),
         C("What does fake scarcity do?", "Damages trust", "Builds trust", "Saves money", "Shortens the page"),
         C("Where should conditions appear?", "In plain words near the offer", "Hidden in tiny print", "Nowhere", "Only in the footer"),
         C("Which line states a condition clearly?", "Free shipping on orders over 40 dollars.", "Free shipping (terms apply).", "Shipping, maybe.", "Ask us."),
         M("Match each line with its type.", [["Sale ends Friday", "real deadline"], ["Only 3 left (when 300 are left)", "fake scarcity"], ["Free over 40 dollars", "clear condition"]]),
         TF("True or false: A countdown timer that restarts for every visitor is honest.", "False"),
         TF("True or false: Clear terms can reduce complaints.", "True"),
         F("Type the missing word: Put conditions in ___ words.", "plain"),
         W("Build the sentence.", "The sale really ends Friday.", "never", "end"),
         LISTEN("Only three left in the warehouse, and we cannot restock before June. If you need one for the summer, order this week.", "Why is this urgency honest?", "It is based on real stock", "It uses a timer", "It is loud", "It is secret"),
         O("Put the steps in order.", ["Check that the limit is real", "State the limit plainly", "Put the conditions near the offer"]),
         YOUR("Write one honest urgent line and one clear condition for a concert ticket offer."),
     ]),
]

if __name__ == "__main__":
    add_stage("copywriter", STAGE, LESSONS, "Intermediate", SOURCES)
