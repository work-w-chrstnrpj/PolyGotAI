#!/usr/bin/env python3
"""Advertising & Copywriting, Advanced stage (about C1-C2): 2 units x 4 lessons, added to track-copywriter.json.

Original wording and invented brands. Ideas (positioning, brand voice, long copy, honest use of persuasion principles,
taglines, transcreation, substantiation and disclosure, briefs) are standard copywriting-teaching concepts; sources
credited for ideas only. Not legal advice. Run from the project root: python3 tools/curriculum/stages/copywriter_advanced.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from track_lib import C, TF, READ, LISTEN, W, F, O, M, YOUR, add_stage  # noqa: E402

SOURCES = [
    "Classic advertising principles from public-domain and widely taught sources (concepts only; no text copied)",
    "Plain-language and honest-advertising guidance (ideas only; original wording; all brands in examples are invented)",
]

STAGE = {"id": "advanced", "title": "Advanced", "units": [
    {"id": "strategy", "title": "Message strategy"},
    {"id": "craft", "title": "Craft and responsibility"},
]}

BRIEF = "Brand: Harbor Bikes, a repair shop. Audience: commuters who ride every day. Problem: they fear a breakdown on the way to work. Promise: repairs finished by the next morning. Proof: 3,000 repairs last year, 92 percent done overnight. Tone: calm, practical, a little dry."
CLAIM = "Our toothpaste is clinically proven to remove stains. In a four-week study of 60 people, 41 saw a lighter shade. Results vary."
SLOGAN = "Harbor Bikes. Back on the road by morning."
GLOBAL = "An English slogan, “We make mornings easy,” is translated word for word into another language, where the word chosen for “easy” also suggests carelessness."

LESSONS = [
    ("cp-a-position", "strategy", "Positioning: one proposition", "CP-A-01",
     "Positioning is the place your brand holds in the customer's mind compared with alternatives. Find the single proposition that is true, relevant and different: the one reason to choose you. A brand that tries to be best at everything is remembered for nothing. State it in one sentence: “For commuters who depend on their bike, Harbor is the repair shop that finishes overnight.” Every ad then supports that sentence.",
     [
         READ(BRIEF, "What is the single proposition?", "Overnight repair for people who ride every day", "Selling new bikes", "Low prices on all parts", "Weekend tours"),
         C("What is positioning?", "The place a brand holds in the customer's mind", "The place a shop is built", "The place of a logo", "A kind of poster"),
         C("What three qualities should the proposition have?", "True, relevant and different", "Long, loud and funny", "New, red and big", "Cheap, fast and free"),
         C("What happens to a brand that tries to be best at everything?", "It is remembered for nothing", "It wins all customers", "It saves money", "It needs no ads"),
         C("What should every ad do?", "Support the one proposition", "Introduce a new idea", "Hide the brand", "Copy competitors"),
         M("Match each element with the brief.", [["Audience", "commuters who ride daily"], ["Promise", "repairs by the next morning"], ["Proof", "92 percent done overnight"]]),
         O("Put the steps in order.", ["Understand the audience's real problem", "Find what is true and different about you", "State it in one sentence"]),
         TF("True or false: A good proposition is true, relevant and different.", "True"),
         F("Type the missing word: Find the one reason to ___ you.", "choose"),
         W("Build the sentence.", "We fix your bike overnight.", "never", "fixes"),
         LISTEN("We tested three ideas: lowest price, widest range and fastest repair. Only the third was true for us, mattered to commuters, and was different from the other shops.", "Which idea became the proposition?", "Fastest repair", "Lowest price", "Widest range", "Biggest shop"),
         YOUR("Write a one-sentence proposition for a neighborhood bakery that opens at 5 a.m."),
     ]),
    ("cp-a-voice", "strategy", "Brand voice and consistency", "CP-A-02",
     "A brand speaks in many places: ads, packaging, emails, error messages. A voice guide keeps it recognizable: a few adjectives (calm, practical, a little dry), words to prefer and words to avoid, and examples of the voice in different situations. Voice stays constant; tone changes with the moment, serious for an apology, lighter for a greeting. Test copy by covering the logo: could it be any brand? If so, sharpen it.",
     [
         C("What is a voice guide for?", "Keeping the brand recognizable across places", "Choosing a logo", "Setting prices", "Writing contracts"),
         C("What stays constant?", "The voice", "The tone", "The price", "The date"),
         C("What changes with the moment?", "The tone", "The voice entirely", "The brand name", "The product"),
         C("What test shows whether copy is distinctive?", "Cover the logo and ask whether it could be any brand", "Count the words", "Read it fast", "Ask a friend to guess the price"),
         C("What does a voice guide include?", "A few adjectives, words to prefer and avoid, and examples", "A single slogan", "A map", "A budget"),
         M("Match each situation with a suitable tone.", [["An apology", "serious and clear"], ["A greeting", "light and warm"], ["An error message", "calm and practical"]]),
         O("Put the guide-making in order.", ["Choose three adjectives", "List words to prefer and avoid", "Write examples for different situations"]),
         TF("True or false: A brand should use a completely different voice in each channel.", "False"),
         F("Type the missing word: The voice stays ___; the tone changes.", "constant", "the same"),
         W("Build the sentence.", "Cover the logo and read it again.", "never", "covers"),
         LISTEN("Error: your bike repair slot has been rebooked. Sorry for the change. Your new time is Thursday at nine, and your bike will be ready by Friday morning.", "What does the message show?", "A calm and practical tone", "A joking tone", "An angry tone", "A formal legal tone"),
         YOUR("Write three adjectives for the voice of a quiet library cafe, and one example sentence in that voice."),
     ]),
    ("cp-a-long", "strategy", "Long copy that keeps momentum", "CP-A-03",
     "Long copy works when readers are serious about a decision, such as an expensive product or a course. It must keep earning the next sentence. Open with the strongest hook, address a clear problem, and move through benefits, proof, objections and an offer. Use subheads so readers can scan and re-enter, short paragraphs, and sentences that start with the reader's concerns. End each section with a reason to read on. Cut anything that does not move the reader toward the decision.",
     [
         C("When does long copy work?", "When readers are serious about a decision", "When readers are in a hurry", "When there is no product", "When the page is empty"),
         C("What should every sentence do?", "Earn the next sentence", "Fill space", "Show off", "Repeat the headline"),
         C("What helps readers scan and re-enter?", "Subheads and short paragraphs", "Long blocks of text", "Small type", "Footnotes"),
         C("What should you cut?", "Anything that does not move the reader toward the decision", "The hook", "The offer", "The proof"),
         C("What can end each section?", "A reason to read on", "A full stop and silence", "A new ad", "The price"),
         M("Match each section with its job.", [["Hook", "earns attention"], ["Proof", "builds belief"], ["Offer", "makes the next step clear"]]),
         O("Put the long page in order.", ["Hook and problem", "Benefits, proof and answers to objections", "Offer and clear next step"]),
         TF("True or false: Long copy is better than short copy in every case.", "False"),
         F("Type the missing word: Use ___ so readers can scan.", "subheads", "headings"),
         W("Build the sentence.", "Every paragraph earns the next one.", "never", "earning"),
         LISTEN("This course costs six hundred dollars, so you will have questions. Let me answer the five I hear most, starting with the one that stops most people: do I have the time?", "How does the speaker keep the reader going?", "By promising answers to real concerns", "By hiding the price", "By asking for money at once", "By ending the page"),
         YOUR("Outline a long sales page for an online photography course: six subheads in order."),
     ]),
    ("cp-a-psych", "strategy", "Persuasion principles, used honestly", "CP-A-04",
     "Research describes patterns in decisions: people follow what others do (social proof), dislike losses more than they like equal gains (loss aversion), and judge by comparison (anchoring). These can help you communicate, but they can also mislead. Use them honestly: show real numbers of real customers, describe a real cost of waiting, and compare with a fair alternative. If you would be uncomfortable explaining the technique to the customer, do not use it.",
     [
         C("What is social proof?", "People follow what others do", "A signed paper", "A discount", "A guarantee"),
         C("What is loss aversion?", "People dislike losses more than they like equal gains", "People like all losses", "People ignore costs", "People love change"),
         C("What is anchoring?", "Judging by comparison with a reference point", "A kind of rope", "A deadline", "A slogan"),
         C("Which use of social proof is honest?", "Three thousand real customers repaired their bikes with us.", "Everyone in the world loves us.", "Thousands of invented reviews.", "A fake counter."),
         C("What test helps you judge a technique?", "Would you be comfortable explaining it to the customer?", "Does it win a prize?", "Is it short?", "Is it cheap?"),
         M("Match each principle with an honest use.", [["Social proof", "real customer numbers"], ["Loss aversion", "a real cost of waiting"], ["Anchoring", "a fair comparison"]]),
         O("Put the steps in order.", ["Pick a principle that fits the real situation", "Support it with true facts", "Check that you could explain it to the customer"]),
         TF("True or false: Techniques based on psychology are always acceptable.", "False"),
         F("Type the missing word: People often follow what ___ do.", "others"),
         W("Build the sentence.", "Waiting has a real cost.", "never", "costs"),
         LISTEN("I could say only two places remain. But we have forty, so I won't. Instead I'll say what is true: the next course starts in June, and the early price ends on the first.", "Why does the speaker avoid the claim?", "It would be false", "It is too long", "It is too cheap", "It is boring"),
         YOUR("Write one honest line using social proof and one honest line describing the cost of waiting for a language course."),
     ]),
    ("cp-a-tagline", "craft", "Taglines: rhythm and wordplay", "CP-A-05",
     "A tagline is a short line that a brand repeats. It should be easy to say and hard to forget. Rhythm helps: short words, a clear beat, perhaps repetition or a pair of contrasts. Wordplay can be memorable when it clarifies; it fails when readers must work to understand it. “Back on the road by morning” promises a benefit in plain words. Test aloud, test with people who do not know the product, and check that the line is true.",
     [
         READ(SLOGAN, "What does this tagline do well?", "It states a clear benefit in plain, rhythmic words.", "It uses a complicated pun.", "It lists prices.", "It hides the brand."),
         C("What should a tagline be?", "Easy to say and hard to forget", "Long and detailed", "Full of numbers", "Private"),
         C("What helps rhythm?", "Short words and a clear beat", "Long words", "Many commas", "Silence"),
         C("When does wordplay fail?", "When readers must work to understand it", "When it is short", "When it rhymes", "When it is honest"),
         C("How should you test a tagline?", "Aloud, and with people who do not know the product", "Silently, alone", "Only with experts", "Never"),
         M("Match each technique with its example.", [["Contrast", "Small price, big difference"], ["Repetition", "Fresh today, fresh tomorrow"], ["Plain benefit", "Back on the road by morning"]]),
         O("Put the steps in order.", ["Write ten options", "Say them aloud", "Test the best with strangers"]),
         TF("True or false: A clever pun is always better than a clear benefit.", "False"),
         F("Type the missing word: A tagline should be easy to ___.", "say", "remember"),
         W("Build the sentence.", "Back on the road by morning.", "never", "roads"),
         LISTEN("Option one: Rapid repairs, rapturous riders. Option two: Back on the road by morning. People understood the second at once, and the first made them ask what it meant.", "Why did the second win?", "People understood it at once", "It was longer", "It had a pun", "It rhymed"),
         YOUR("Write three taglines for a night-shift coffee truck, then circle the one you would test."),
     ]),
    ("cp-a-global", "craft", "Write for other cultures", "CP-A-06",
     "Words and images do not travel unchanged. Translation moves the meaning; transcreation rebuilds the message so that it works in the new culture. A slogan that is lucky in one language may be rude or flat in another. Check colors, numbers, humor and symbols with someone from the culture. Keep the proposition constant and adapt the expression. Plan time for local review before launch.",
     [
         READ(GLOBAL, "What is the problem?", "A word-for-word translation carries an unwanted second meaning.", "The slogan is too short.", "The slogan has no verb.", "The audience is too large."),
         C("What is transcreation?", "Rebuilding the message so it works in the new culture", "Copying word for word", "Deleting the ad", "Adding a logo"),
         C("What should stay constant in a global campaign?", "The proposition", "Every word", "The jokes", "The colors"),
         C("Who should check cultural details?", "Someone from the culture", "Anyone nearby", "The printer", "The lawyer only"),
         C("What can differ across cultures?", "Colors, numbers, humor and symbols", "Nothing", "Only language", "Only prices"),
         M("Match each task with its aim.", [["Translation", "move the meaning"], ["Transcreation", "rebuild the effect"], ["Local review", "catch errors before launch"]]),
         O("Put the steps in order.", ["Keep the proposition", "Adapt the expression with local help", "Review locally before launch"]),
         TF("True or false: A slogan always works the same in every language.", "False"),
         F("Type the missing word: Plan time for local ___ before launch.", "review"),
         W("Build the sentence.", "The meaning changes in translation.", "never", "translated"),
         LISTEN("In the new market we kept the promise, a fast and calm repair, but changed the slogan, because the literal translation sounded like a threat.", "What did the team change?", "The slogan's wording", "The promise", "The product", "The price"),
         YOUR("Explain in two sentences why you would not use a word-for-word translation of a pun."),
     ]),
    ("cp-a-truth", "craft", "Substantiation and disclosure", "CP-A-07",
     "Advertising claims must be truthful and supported by evidence you hold before you publish. A claim such as “clinically proven” needs a proper study and an accurate summary, not a small test described as proof. Disclose material limits clearly near the claim: sample size, “results vary,” conditions of an offer. Comparative claims must compare like with like. Paid endorsements must be disclosed as such. Rules differ by country, so follow your region's rules and ask a qualified adviser. This is language practice, not legal advice.",
     [
         READ(CLAIM, "What is the weakness of “clinically proven” here?", "A small four-week study supports a modest result, not proof.", "The toothpaste is too white.", "The study was too long.", "The numbers are missing."),
         C("When must you hold the evidence for a claim?", "Before you publish it", "After a complaint", "Never", "After a year"),
         C("Where should important limits be disclosed?", "Clearly near the claim", "In tiny type at the end", "Not at all", "In another language"),
         C("What must comparative claims do?", "Compare like with like", "Compare anything", "Avoid evidence", "Use a famous name"),
         C("How should a paid endorsement be shown?", "Disclosed as paid", "Hidden", "Called independent", "Called a coincidence"),
         M("Match each requirement with its meaning.", [["Substantiation", "evidence held beforehand"], ["Disclosure", "clear statement of limits"], ["Fair comparison", "like with like"]]),
         O("Put the checks in order.", ["Gather evidence for the claim", "State the claim accurately", "Disclose limits clearly next to it"]),
         TF("True or false: “Results vary” in small print removes the need for evidence.", "False"),
         F("Type the missing word: Disclose a paid ___.", "endorsement"),
         W("Build the sentence.", "We hold the evidence for this claim.", "never", "holds"),
         LISTEN("In a study of sixty adults over four weeks, forty-one saw a lighter shade. That is the evidence. So we say: most people in our study saw a lighter shade. We do not say proven for everyone.", "How does the speaker keep the claim honest?", "By describing the study accurately", "By saying proven for everyone", "By hiding the numbers", "By removing the claim"),
         YOUR("Rewrite “The best coffee in the world, proven!” as an honest claim with one disclosed limit."),
     ]),
    ("cp-a-brief", "craft", "Work from a brief", "CP-A-08",
     "A brief tells you what the work must achieve. Read it for the audience, the problem, the single message, the proof, the tone and the practical limits (format, length, deadline). Ask questions before you write: Who exactly? What should they do? What do they believe now? When you present copy, link each choice to the brief: “Because commuters fear a breakdown, the headline promises the next morning.” Take feedback on the work, not on yourself, and revise toward the brief.",
     [
         READ(BRIEF, "Which brief element tells you the writing style?", "Tone: calm, practical, a little dry", "Audience: commuters", "Proof: 3,000 repairs", "Brand: Harbor Bikes"),
         C("What does a brief tell you?", "What the work must achieve", "How to dress", "When to eat", "Who to hire"),
         C("What should you do before you write?", "Ask questions about the audience and the goal", "Write at once", "Skip the brief", "Copy last year's ad"),
         C("How should you present copy?", "Link each choice to the brief", "Say it is clever", "Say nothing", "Hide the brief"),
         C("What kind of feedback should you listen for?", "Feedback on the work, not on yourself", "Feedback on your personality", "No feedback", "Only praise"),
         M("Match each question with what it clarifies.", [["Who exactly?", "the audience"], ["What should they do?", "the action"], ["What do they believe now?", "the starting point"]]),
         O("Put the process in order.", ["Read the brief for message, audience and limits", "Ask questions to close the gaps", "Write, present against the brief, and revise"]),
         TF("True or false: Revising toward the brief is part of the job.", "True"),
         F("Type the missing word: Link each choice to the ___.", "brief"),
         W("Build the sentence.", "The headline answers the commuter's fear.", "never", "fears"),
         LISTEN("The brief says our audience is nervous commuters, so the headline promises a fixed bike by morning. The tone is calm, as required. I kept the copy to forty words, the limit in the brief.", "How does the speaker present the work?", "By linking choices to the brief", "By ignoring the brief", "By changing the audience", "By adding a joke"),
         YOUR("Write four questions you would ask a client before writing an ad for a new language school."),
     ]),
]

if __name__ == "__main__":
    add_stage("copywriter", STAGE, LESSONS, "Advanced", SOURCES)
