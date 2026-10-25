#!/usr/bin/env python3
"""Debater & Argument, Advanced stage (about C1-C2): 2 units x 4 lessons, added to track-debater.json.

Original wording and original sample passages. Ideas (warrants, burden of proof, charity, cruxes, framing, layered rebuttal,
reasoning under uncertainty, impact comparison) are standard argument-teaching concepts; sources credited for ideas only.
Run from the project root: python3 tools/curriculum/stages/debater_advanced.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from track_lib import C, TF, READ, LISTEN, W, F, O, M, YOUR, add_stage  # noqa: E402

SOURCES = [
    "Toulmin, The Uses of Argument (concepts only: claim, grounds, warrant, backing, qualifier, rebuttal; no text copied)",
    "Rapoport's rules as described by Dennett, and the principle of charity (concepts only; original wording)",
]

STAGE = {"id": "advanced", "title": "Advanced", "units": [
    {"id": "rigor", "title": "Argue with rigor"},
    {"id": "arena", "title": "Win the exchange"},
]}

TOWN = "The council argues that because crime fell after cameras were installed, cameras reduce crime. The report does not say whether lighting, policing or the number of residents also changed during the same year."
WARRANT = "Claim: the district should ban cars on Market Street. Grounds: air tests show three times the safe level of fine dust there. Unstated link: if the air is unsafe, the authority must act to protect people's health."
SPEED = "One side says a lower speed limit will save lives. The other replies that drivers will simply ignore it. Neither side has said how many accidents happen at present, or whether lower limits were enforced elsewhere."
FUND = "A proposal would move ten percent of the sports budget to music lessons. Supporters stress that every child can take part in music. Opponents stress that sports teach teamwork. Both sides agree that the school budget is fixed."

LESSONS = [
    ("db-a-warrant", "rigor", "Warrants and hidden assumptions", "DB-A-01",
     "Every argument rests on a link between its grounds and its claim. Toulmin called this link the warrant. It is often unstated: “The air is unsafe, so the authority must act” assumes that authorities are responsible for health. A warrant can be attacked even when the grounds are true. Name it, test it, and add a qualifier when you cannot be certain: “probably,” “in most cases,” “unless…”",
     [
         READ(WARRANT, "What is the unstated link in this argument?", "Authorities are responsible for protecting public health.", "Cars are expensive.", "Market Street is long.", "Dust is not measurable."),
         READ(WARRANT, "Which objection attacks the warrant rather than the grounds?", "Even unsafe air does not oblige the authority to ban cars; it might use filters instead.", "The tests were done in the wrong season.", "The dust levels were mistyped.", "The street name is wrong."),
         C("What is a warrant?", "The link that connects the grounds to the claim", "The final conclusion", "A statistic", "A quotation"),
         C("Why can a warrant be attacked even when the grounds are true?", "True grounds may not justify that claim", "True grounds never matter", "Warrants are facts", "Claims need no support"),
         C("Which word is a qualifier?", "probably", "therefore", "because", "never"),
         C("Which sentence adds a sensible qualifier?", "In most cases, lower speed limits reduce serious injuries.", "Lower speed limits always save everyone.", "Speed limits are legal.", "Nobody drives fast."),
         M("Match each element with its role.", [["Grounds", "the evidence offered"], ["Warrant", "the link to the claim"], ["Qualifier", "limits how strong the claim is"]]),
         TF("True or false: A warrant is always stated in the argument.", "False"),
         TF("True or false: True grounds guarantee that the claim follows.", "False"),
         F("Type the missing word: The ___ connects the grounds to the claim.", "warrant"),
         W("Build the sentence.", "The argument rests on an unstated assumption.", "never", "assume"),
         LISTEN("The data are accurate. My objection is to the step from the data to the policy. The numbers show a problem, but they do not show that this policy is the right response.", "What is the speaker attacking?", "The link between the data and the policy", "The accuracy of the data", "The speaker's honesty", "The date of the report"),
         YOUR("Take the claim “Schools should start later.” Write the grounds, the warrant you would need, and one qualifier."),
     ]),
    ("db-a-burden", "rigor", "Burden of proof", "DB-A-02",
     "The burden of proof is the duty to support a claim. In most debates the side proposing a change must show why it is needed; the status quo is presumed acceptable until shown otherwise. Shifting the burden unfairly is a trick: “Prove that it will not work” demands proof of a negative. Say plainly who must prove what: “The proposal carries the burden of showing that the benefits exceed the costs.”",
     [
         C("Who usually carries the burden of proof?", "The side proposing a change", "The side defending the current situation", "The audience", "The judges"),
         C("What does presumption mean here?", "The current situation is accepted until shown to be inadequate", "Everything is true", "The change is automatic", "Nothing can be decided"),
         C("Which demand shifts the burden unfairly?", "Prove that it will never fail.", "Show your evidence.", "Explain your reasons.", "Define your terms."),
         C("Which sentence states the burden clearly?", "The proposal must show that its benefits exceed its costs.", "Nobody has to show anything.", "Both sides are wrong.", "Proof is boring."),
         READ(SPEED, "Who has failed to meet the burden of proof so far?", "Both sides, because neither has given baseline figures.", "Only the first side.", "Only the second side.", "Neither side needs to."),
         M("Match each role with its duty.", [["Proposer", "show why change is needed"], ["Opponent", "test the case and show its weaknesses"], ["Judge", "weigh who met the burden"]]),
         TF("True or false: It is reasonable to demand proof of a negative such as “prove it will never fail.”", "False"),
         TF("True or false: The status quo is usually presumed acceptable until shown otherwise.", "True"),
         F("Type the missing word: The proposer carries the ___ of proof.", "burden"),
         W("Build the sentence.", "The proposal must justify the change.", "never", "justifies"),
         LISTEN("My opponent says I must prove the policy will work everywhere. That is not the burden. I must show it is likely to work here, and I have given three local examples.", "How does the speaker redefine the burden?", "Likely to work here", "Certain to work everywhere", "Impossible to prove", "Not required"),
         O("Put the steps in order.", ["Identify who proposes a change", "State what they must prove", "Test whether the proof was given"]),
         YOUR("Write one sentence that states who carries the burden in a debate on banning plastic bags, and what they must show."),
     ]),
    ("db-a-charity", "rigor", "Charity and the strongest version", "DB-A-03",
     "The principle of charity says: interpret an opponent's argument in the strongest reasonable way before you answer it. If you defeat a weak version, you have defeated nothing. State their case so well that they would say, “Yes, that is what I meant.” This is steelmanning. Then answer the strongest point. Charity also protects you: it stops you from winning a point that does not matter.",
     [
         READ(FUND, "Which statement of the opponents' case is the most charitable?", "Sports build teamwork, and a smaller sports budget could weaken a rare chance to learn it.", "They hate music.", "They want children to be violent.", "They do not understand budgets."),
         C("What is the principle of charity?", "Interpret the opponent's argument in its strongest reasonable form", "Give money to the opponent", "Avoid disagreement", "Agree with everyone"),
         C("What is steelmanning?", "Stating the strongest version of the other side", "Attacking the weakest point", "Repeating your claim", "Ignoring evidence"),
         C("What does the opponent hope to say after your summary?", "Yes, that is what I meant.", "That is nonsense.", "I did not say that.", "I do not care."),
         C("Why does charity protect you?", "It stops you from winning a point that does not matter", "It ends the debate", "It hides your claim", "It removes evidence"),
         M("Match each version with its quality.", [["They want children to be violent.", "a straw man"], ["Sports teach teamwork that is hard to replace.", "a charitable version"], ["Sports are fine.", "too vague to answer"]]),
         O("Put the steps in order.", ["Listen to the opponent's case", "Restate it in its strongest form", "Answer the strongest point"]),
         TF("True or false: Defeating a weak version of an argument defeats the argument.", "False"),
         F("Type the missing word: State their case so well that they say, “Yes, that is what I ___.”", "meant"),
         W("Build the sentence.", "Let me state your position as strongly as I can.", "never", "weak"),
         LISTEN("Before I disagree, let me put your view in its best form. You think the plan is too fast, not too costly. Is that fair? If so, here is my answer to that worry.", "What is the speaker doing?", "Restating the opposing view charitably", "Attacking a straw man", "Changing the subject", "Agreeing completely"),
         YOUR("Pick a topic you disagree with. Write the strongest two-sentence version of the other side."),
     ]),
    ("db-a-crux", "rigor", "Find the crux", "DB-A-04",
     "Many debates stall because the sides argue about different things. The crux is the point where the disagreement actually lies. Ask: is it about facts (what is true), values (what matters most) or definitions (what a word means)? Fact disputes need evidence; value disputes need weighing; definition disputes need agreement on terms. Once you name the crux, you can stop talking past each other.",
     [
         READ(FUND, "Where does the disagreement lie?", "In what matters more: universal participation or teamwork", "In the size of the budget", "In whether music exists", "In the school's address"),
         C("What is the crux of a debate?", "The point where the disagreement really lies", "The loudest argument", "The introduction", "The title"),
         C("A dispute about whether crime fell is mainly about what?", "Facts", "Values", "Definitions", "Manners"),
         C("A dispute about whether a sports team is more important than a choir is mainly about what?", "Values", "Facts", "Dates", "Spelling"),
         C("A dispute about what counts as “poverty” is mainly about what?", "Definitions", "Weather", "Values only", "Budgets only"),
         M("Match each dispute type with what settles it.", [["Fact", "evidence"], ["Value", "weighing priorities"], ["Definition", "agreeing on terms"]]),
         TF("True or false: Naming the crux helps sides stop talking past each other.", "True"),
         TF("True or false: A value dispute can be settled by one statistic alone.", "False"),
         F("Type the missing word: Ask what the real ___ of the disagreement is.", "crux"),
         W("Build the question.", "Is this about facts or values?", "does", "fact"),
         LISTEN("We both agree the cost is the same. We disagree on whether speed or safety should come first. That is a question of values, not data.", "What is the crux?", "Whether speed or safety comes first", "The cost", "The data", "The date"),
         O("Put the steps in order.", ["List where the sides agree", "Locate where they differ", "Name the type of dispute and what would settle it"]),
         YOUR("Choose a debate you know. Write where both sides agree and the single crux."),
     ]),
    ("db-a-frame", "arena", "Frames and reframes", "DB-A-05",
     "A frame is the way an issue is described, and it shapes what seems reasonable. “Tax relief” suggests a burden; “public investment” suggests a benefit. Notice the frame in an argument and ask whether it is fair. You can reframe by describing the same facts in terms of different values: not “a ban on cars” but “streets for people.” Use frames honestly: a fair frame is one you could defend to the other side.",
     [
         C("What is a frame?", "The way an issue is described", "A picture border", "A number", "A rule of the debate"),
         C("Which phrase frames a tax as a burden?", "tax relief", "public investment", "shared cost", "community fund"),
         C("What is a reframe?", "Describing the same facts in terms of other values", "Changing the facts", "Ignoring the question", "Repeating the claim"),
         C("Which is a reframe of “ban cars”?", "streets for people", "a loss of freedom", "a forced rule", "a heavy penalty"),
         C("When is a frame fair?", "When you could defend it to the other side", "When it wins the vote", "When it is loud", "When it is short"),
         M("Match each phrase with the feeling it suggests.", [["tax relief", "something heavy to remove"], ["public investment", "something that builds value"], ["red tape", "something that blocks you"]]),
         TF("True or false: The words we choose can change what seems reasonable.", "True"),
         TF("True or false: A reframe changes the facts.", "False"),
         F("Type the missing word: Ask whether the ___ is fair.", "frame"),
         W("Build the sentence.", "That is a loaded way to put it.", "never", "load"),
         LISTEN("You call it a handout. I call it a safety net. The money is the same; the frame is different, and so is the question we are answering.", "What is the speaker pointing out?", "The same money can be framed in two ways", "The money is different", "The speaker is angry", "The plan is illegal"),
         O("Put the steps in order.", ["Notice the frame in the argument", "Ask whether it is fair", "Offer a fair alternative frame if needed"]),
         YOUR("Write two different frames for the same policy: a four-day school week."),
     ]),
    ("db-a-layer", "arena", "Layered rebuttal", "DB-A-06",
     "A strong rebuttal has layers. First label the point you answer: “On their second argument…” Then state the claim of your answer, give your reason and show the impact: “…it does not follow, because the sample was small, so the policy rests on weak evidence.” Where possible, offer more than one layer: your answer is true, and even if it were not, the effect is small. Be brief and keep them in order.",
     [
         C("What should you do first in a rebuttal?", "Label the point you are answering", "Attack the speaker", "Repeat your own case", "Ask for a break"),
         C("Which sentence shows the impact?", "So the policy rests on weak evidence.", "Because the sample was small.", "On their second point.", "It does not follow."),
         C("Which sentence gives a layer starting with “even if”?", "Even if their figure were correct, the effect would still be small.", "Their figure is correct.", "Figures are boring.", "They have a figure."),
         C("Why offer more than one layer?", "If one fails, another may still stand", "To use time", "To confuse the judges", "To avoid reasons"),
         C("How should you deliver the layers?", "Briefly and in order", "As fast as possible", "In random order", "In a whisper"),
         M("Match each step with its example.", [["Label", "On their second argument…"], ["Claim", "it does not follow"], ["Reason", "because the sample was small"], ["Impact", "so the policy rests on weak evidence"]]),
         O("Put the layered rebuttal in order.", ["Label the point", "State your answer and reason", "Say why it matters, then add an even-if layer"]),
         TF("True or false: A rebuttal should always include a reason.", "True"),
         F("Type the missing word: Show the ___ of your answer.", "impact"),
         W("Build the sentence.", "Even if that were true, it would not matter.", "never", "was"),
         LISTEN("On their second point: it does not follow, because the sample was ten people. So the policy rests on weak evidence. And even if the effect were real, it is tiny.", "How many layers does the speaker use?", "Two", "One", "Three", "Four"),
         LISTEN("On their second point: it does not follow, because the sample was ten people. So the policy rests on weak evidence. And even if the effect were real, it is tiny.", "Which phrase starts the second layer?", "And even if", "On their second point", "Because", "So the policy"),
         YOUR("Answer this claim with a labeled, layered rebuttal: “Homework always improves grades.”"),
     ]),
    ("db-a-risk", "arena", "Argue under uncertainty", "DB-A-07",
     "Often nobody knows what will happen. Compare options by probability (how likely), magnitude (how big) and reversibility (can it be undone?). A small chance of a huge, permanent harm can outweigh a likely small gain. Be precise about uncertainty: “likely,” “plausible” and “possible” are not the same. Avoid false certainty on either side: “It will certainly work” and “It could never work” both need proof.",
     [
         C("Which three questions compare risky options?", "How likely, how big, can it be undone?", "How old, how tall, how red?", "Who, where, when?", "What color, what size, what price?"),
         C("A very small chance of a huge permanent harm can sometimes do what?", "Outweigh a likely small gain", "Be ignored", "Prove the gain", "End the debate"),
         C("Which word expresses the highest probability?", "likely", "possible", "conceivable", "remote"),
         C("Which sentence avoids false certainty?", "It is likely to work, though not certain.", "It will certainly work.", "It could never work.", "Everyone knows it works."),
         C("What does reversibility mean?", "Whether the decision can be undone", "Whether the plan is long", "Whether it is popular", "Whether it is cheap"),
         M("Match each term with its question.", [["Probability", "How likely is it?"], ["Magnitude", "How big is it?"], ["Reversibility", "Can it be undone?"]]),
         TF("True or false: “Possible” and “likely” mean the same thing.", "False"),
         TF("True or false: A harm that cannot be undone deserves extra weight.", "True"),
         F("Type the missing word: Ask whether the harm can be ___.", "undone", "reversed"),
         W("Build the sentence.", "The risk is small but permanent.", "never", "permanently"),
         LISTEN("The benefit is likely but small. The harm is unlikely, but if it happened it could not be reversed. So I would wait for more evidence before acting.", "Why does the speaker prefer to wait?", "The possible harm is permanent", "The benefit is huge", "The harm is likely", "Waiting is cheap"),
         O("Put the steps in order.", ["List the possible outcomes", "Estimate how likely and how big each is", "Check which can be undone and weigh them"]),
         YOUR("Compare two options for a city facing flood risk. Write one sentence about probability, one about magnitude and one about reversibility."),
     ]),
    ("db-a-close", "arena", "Weigh and close", "DB-A-08",
     "In a closing speech, do not repeat everything. Identify the two or three issues that decide the debate, say who won each and why, and explain why those issues outweigh the rest. This is called weighing or impact comparison: “Even if they win the cost point, our point concerns lives, which matters more.” Compare size, likelihood and who is affected. End with a clear, short statement of why your side should win.",
     [
         C("What should a closing speech do?", "Identify the issues that decide the debate and weigh them", "Repeat every argument", "Introduce new evidence", "Apologize"),
         C("Which sentence weighs arguments?", "Even if they win the cost point, our point concerns lives, which matters more.", "We said many things.", "Costs exist.", "Please vote for us."),
         C("What can you compare when you weigh?", "Size, likelihood and who is affected", "Spelling and font", "Length of speeches", "Names of speakers"),
         C("How many deciding issues should you aim for?", "Two or three", "Twenty", "None", "One hundred"),
         C("How should you end?", "With a clear, short statement of why your side should win", "With a joke", "With silence", "With new evidence"),
         M("Match each step with its purpose.", [["Identify key issues", "focus the judges"], ["Say who won each", "show your case is stronger"], ["Weigh them", "show why your wins matter more"]]),
         O("Put the closing in order.", ["Name the two or three deciding issues", "Say who won each and why", "Weigh them and state why your side wins"]),
         TF("True or false: A closing speech should bring in brand-new evidence.", "False"),
         F("Type the missing word: ___ means comparing the importance of arguments.", "weighing"),
         W("Build the sentence.", "Our point matters more than theirs.", "never", "most"),
         LISTEN("There are two issues in this debate: cost and safety. They won cost by a little. We won safety by a lot, and safety affects every student, every day. That is why we should win.", "How does the speaker weigh the issues?", "Safety outweighs the small cost win", "Cost outweighs safety", "Both issues are equal", "Neither issue matters"),
         YOUR("Write a four-sentence closing for a debate on whether cities should ban cars from the center."),
     ]),
]

if __name__ == "__main__":
    add_stage("debater", STAGE, LESSONS, "Advanced", SOURCES)
