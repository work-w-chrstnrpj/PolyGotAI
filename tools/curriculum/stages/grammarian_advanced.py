#!/usr/bin/env python3
"""Grammarian, Advanced stage (about C1-C2): 2 units x 4 lessons, added to track-grammarian.json.

Original wording. The British Council-EAQUALS Core Inventory and the CEFR Companion Volume supply only topic order and level.
Run from the project root: python3 tools/curriculum/stages/grammarian_advanced.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from track_lib import C, TF, READ, LISTEN, W, F, O, M, E, YOUR, add_stage  # noqa: E402

SOURCES = [
    "British Council-EAQUALS Core Inventory for General English (topic order and level)",
    "CEFR Companion Volume (C1-C2 descriptors)",
]

STAGE = {"id": "advanced", "title": "Advanced", "units": [
    {"id": "nuance", "title": "Precision and nuance"},
    {"id": "style", "title": "Register and style"},
]}

LETTER = "Dear Ms Okafor, I am writing to enquire whether the position remains open. Should you require further information, I would be pleased to supply it. I look forward to hearing from you."
CHAT = "Hey, just checking if the job's still going. Let me know if you need anything else from me. Cheers."

LESSONS = [
    ("gram-a-inversion", "nuance", "Inversion for emphasis", "GRAM-A-01",
     "After some negative or restrictive adverbials, English puts the auxiliary before the subject, like a question: “Never have I seen such a view.” “Not only did she win, but she also broke the record.” “Rarely does he complain.” “Hardly had we arrived when it began to rain.” This is formal and emphatic. Without an auxiliary, add do/does/did. Use it sparingly for effect. In conditionals, “Should you need help…” and “Had I known…” replace if.",
     [
         C("Choose the correct sentence.", "Never have I seen such a view.", "Never I have seen such a view.", "Never I saw have such a view.", "Never have seen I such a view."),
         C("Choose the correct sentence.", "Not only did she win, but she also broke the record.", "Not only she won, but she also broke the record.", "Not only she did win, but also broke.", "Not only won she, but broke."),
         C("Choose the correct sentence.", "Hardly had we arrived when it began to rain.", "Hardly we had arrived when it began to rain.", "Hardly had arrived we when it began to rain.", "Hardly we arrived when had it rained."),
         C("Which sentence replaces “If you need help”?", "Should you need help, call me.", "Do you need help, call me.", "Would you need help, call me.", "Have you need help, call me."),
         C("Which sentence replaces “If I had known”?", "Had I known, I would have come.", "If had I known, I came.", "Have I known, I would come.", "Did I know, I came."),
         E("Rarely he complains about the weather.", "Rarely does he complain about the weather."),
         E("Under no circumstances you should open this door.", "Under no circumstances should you open this door."),
         M("Match each opening with its meaning.", [["Never have I", "at no time in my life"], ["Hardly had we…when", "just after"], ["Not only did she…", "and also"]]),
         TF("True or false: Inversion is used for emphasis and is rather formal.", "True"),
         F("Type the missing word: Never ___ I seen such a view.", "have"),
         W("Build the sentence.", "Rarely does he complain.", "never", "complains"),
         LISTEN("Not only did the team meet the deadline, but it also came in under budget. Rarely has a project gone so smoothly.", "How many examples of inversion do you hear?", "Two", "One", "Three", "None"),
         YOUR("Write two sentences about a surprising experience, one with “Never have I…” and one with “Not only…”."),
     ]),
    ("gram-a-hypo", "nuance", "Hypotheticals, regrets and wishes", "GRAM-A-02",
     "Third conditional: if + past perfect, would have + past participle, for unreal past situations: “If I had left earlier, I would have caught the train.” Mixed conditionals combine times: “If I had studied medicine, I would be a doctor now.” Wish and if only express regret or desire: “I wish I knew the answer” (present), “I wish I had studied” (past), “I wish he would stop” (annoyance). After “would rather” and “it's time” the past tense has present or future meaning: “It's time we left.”",
     [
         C("Choose the correct sentence.", "If I had left earlier, I would have caught the train.", "If I would have left earlier, I caught the train.", "If I left earlier, I would catch the train yesterday.", "If I had left earlier, I would catch the train."),
         C("Choose the correct mixed conditional.", "If I had studied medicine, I would be a doctor now.", "If I studied medicine, I would have been a doctor now.", "If I had studied medicine, I had been a doctor.", "If I would study medicine, I am a doctor."),
         C("Choose the correct sentence about a past regret.", "I wish I had studied harder.", "I wish I studied harder yesterday.", "I wish I would study harder yesterday.", "I wish I have studied harder."),
         C("Choose the correct sentence about annoyance.", "I wish he would stop talking.", "I wish he stops talking.", "I wish he stopped talking tomorrow.", "I wish he will stop talking."),
         C("Choose the correct sentence.", "It's time we left.", "It's time we leave now.", "It's time we will leave.", "It's time we are leaving."),
         E("If I would have known, I would have helped.", "If I had known, I would have helped."),
         E("I wish I can speak French.", "I wish I could speak French."),
         M("Match each sentence with its time.", [["If I had left, I would have caught it.", "unreal past"], ["I wish I knew.", "present wish"], ["If I had studied, I would be rich now.", "past cause, present result"]]),
         TF("True or false: We use “would” in the if-clause of a third conditional.", "False"),
         F("Type the missing word: I wish I ___ the answer. (present)", "knew"),
         W("Build the sentence.", "If I had known, I would have called.", "never", "knowing"),
         LISTEN("If I had taken that job, I would be living in Berlin now. Sometimes I wish I had said yes, but I am happy where I am.", "Where does the speaker live?", "Not in Berlin", "In Berlin", "In Paris", "On a boat"),
         YOUR("Write one third conditional about a past decision and one mixed conditional about its present result."),
     ]),
    ("gram-a-hedge", "nuance", "Past modals and hedging", "GRAM-A-03",
     "Past modals: should have + participle criticizes or regrets (“You should have called”); could have shows past possibility (“We could have won”); might have shows a past possibility you are unsure about; needn't have means it was not necessary but you did it. Hedging softens claims in careful writing: “It seems that…”, “This may suggest…”, “tends to”, “to some extent.” Use hedges to match your certainty, not to avoid commitment.",
     [
         C("Choose the correct sentence.", "You should have called me.", "You should called me.", "You should have call me.", "You should to have called me."),
         C("Which means it was not necessary but I did it?", "I needn't have gone.", "I mustn't have gone.", "I can't have gone.", "I shouldn't go."),
         C("Which sentence is a hedge?", "This may suggest that the policy is working.", "This proves the policy works.", "The policy is perfect.", "Everyone knows it works."),
         C("Choose the correct sentence.", "They might have missed the bus.", "They might missed the bus.", "They might have miss the bus.", "They might to have missed the bus."),
         C("Why use hedging?", "To match your certainty to the evidence", "To avoid saying anything", "To lengthen the text", "To sound angry"),
         E("She should of told us earlier.", "She should have told us earlier."),
         C("Which version hedges “The results prove that the method is better” appropriately?", "The results suggest that the method may be better.", "The results prove definitely that the method is better.", "The method is better, obviously.", "Nobody doubts the method."),
         M("Match each form with its meaning.", [["should have done", "criticism or regret"], ["could have done", "a past possibility"], ["needn't have done", "unnecessary action"]]),
         TF("True or false: Hedging means refusing to commit to anything.", "False"),
         F("Type the missing word: You should ___ called me.", "have"),
         W("Build the sentence.", "It seems that prices are rising.", "never", "seemed"),
         LISTEN("The data suggest that the program may have improved attendance, although other factors could have played a part. More research is needed.", "What is the speaker doing?", "Making a careful claim", "Making a certain claim", "Refusing to speak", "Making a joke"),
         YOUR("Rewrite “This proves the teaching method is better” with careful hedging, in one sentence."),
     ]),
    ("gram-a-noun", "nuance", "Dense noun phrases", "GRAM-A-04",
     "Academic and professional English packs information into noun phrases. Nominalization turns verbs or adjectives into nouns: “decide” becomes “the decision,” “different” becomes “the difference.” “Prices rose sharply” can become “the sharp rise in prices.” Add modifiers before and after the noun: “a recent, widely discussed report on urban transport.” Balance: too many nouns in a row become heavy. Use a verb when the action matters more than the idea.",
     [
         C("Choose the nominalization of “decide”.", "decision", "decisive", "decidedly", "decided"),
         C("Which phrase is a nominalized form of “Prices rose sharply”?", "the sharp rise in prices", "prices that sharp rose", "sharply rise of price", "the prices rising sharp"),
         C("Which phrase is a dense noun phrase?", "a recent, widely discussed report on urban transport", "report", "it reported", "to report on it"),
         C("What is the risk of too many nouns in a row?", "The sentence becomes heavy", "The sentence becomes simple", "The verbs disappear", "Nothing"),
         C("When is a verb better?", "When the action matters more than the idea", "Never", "In titles only", "In numbers"),
         M("Match each verb or adjective with its noun.", [["different", "difference"], ["decide", "decision"], ["fail", "failure"]]),
         E("The company's decide caused many problems.", "The company's decision caused many problems."),
         E("There was a significantly rise in unemployment.", "There was a significant rise in unemployment."),
         TF("True or false: Nominalization makes writing more compact and formal.", "True"),
         F("Type the noun for “improve”.", "improvement"),
         W("Build the sentence.", "The decision caused many problems.", "never", "decides"),
         LISTEN("The widespread adoption of remote work has led to a decline in demand for city-center offices.", "Which phrase is the nominalized idea of people adopting remote work widely?", "The widespread adoption of remote work", "A decline in demand", "City-center offices", "Has led to"),
         YOUR("Rewrite as a noun phrase: “Many people use public transport less than before.”"),
     ]),
    ("gram-a-participle", "style", "Participle and reduced clauses", "GRAM-A-05",
     "Participle clauses add information compactly. Present participle for simultaneous or causal action: “Walking home, I met an old friend.” Past participle for passive meaning: “Written in 1920, the book is still read.” Perfect participle for an earlier action: “Having finished, she left.” The subject of the participle must be the subject of the main clause, or you create a misplaced modifier: “Walking home, the rain started” is wrong. Reduced relative clauses: “the man standing there.”",
     [
         C("Choose the correct sentence.", "Walking home, I met an old friend.", "Walking home, an old friend met me yesterday while rain.", "I walking home met an old friend.", "Walk home, I met an old friend."),
         C("Choose the correct sentence.", "Having finished, she left.", "Finish, she left.", "Having finish, she left.", "Finishing, she had left before."),
         C("Choose the sentence with a past participle clause.", "Written in 1920, the book is still read.", "Writing in 1920, the book is still read.", "Having wrote in 1920, the book is read.", "Write in 1920, the book is read."),
         C("Which sentence has a misplaced modifier?", "Walking home, the rain started.", "Walking home, I got wet.", "Having arrived, I called.", "Written in 1920, the book is read."),
         C("Which phrase is a reduced relative clause?", "the man standing there", "the man who he stands", "the standing man", "the man to stand"),
         C("Which sentence fixes the misplaced modifier in “Walking down the street, the rain began to fall”?", "Walking down the street, I felt the rain begin to fall.", "Walking down the street, the rain was falling on.", "Walk down the street, the rain began to fall.", "The rain, walking down the street, began to fall."),
         E("Having wrote the report, he sent it.", "Having written the report, he sent it."),
         M("Match each form with its meaning.", [["Walking home, I…", "at the same time"], ["Having finished, I…", "an earlier action"], ["Written in 1920, the book…", "passive meaning"]]),
         TF("True or false: The subject of a participle clause should be the subject of the main clause.", "True"),
         F("Type the missing word: ___ finished, she left. (earlier action)", "having"),
         W("Build the sentence.", "Having read the report, I called him.", "never", "reads"),
         LISTEN("Exhausted after a long flight, she went straight to bed. Having slept for twelve hours, she felt like a new person.", "Which clause shows an earlier action?", "Having slept for twelve hours", "Exhausted after a long flight", "She went to bed", "A new person"),
         YOUR("Write two sentences with participle clauses about your morning, one present and one perfect."),
     ]),
    ("gram-a-formal", "style", "Formal structures", "GRAM-A-06",
     "Formal English uses structures that casual speech avoids. The subjunctive appears after verbs of demand or suggestion: “She insisted that he be present.” “It is essential that every student complete the form.” “Were it not for your help, we would have failed.” Passive and impersonal forms keep a neutral tone: “It is suggested that…”, “Attention is drawn to…” Use these in letters, reports and rules; they sound stiff in friendly chat.",
     [
         READ(LETTER, "Which phrase uses an inverted conditional?", "Should you require further information", "I am writing to enquire", "I look forward to hearing", "Dear Ms Okafor"),
         C("Choose the correct sentence.", "She insisted that he be present.", "She insisted that he is present.", "She insisted him to be present.", "She insisted that he being present."),
         C("Choose the correct sentence.", "It is essential that every student complete the form.", "It is essential that every student completes the form.", "It is essential every student to complete the form.", "It is essential that every student will complete."),
         C("Choose the correct sentence.", "Were it not for your help, we would have failed.", "If were not for your help, we failed.", "Was it not for your help, we would failed.", "Were it not for your help, we fail."),
         C("Which tone does “It is suggested that…” have?", "Neutral and formal", "Friendly and casual", "Angry", "Humorous"),
         E("The manager recommended that he leaves early.", "The manager recommended that he leave early."),
         E("It is important that she will arrive on time.", "It is important that she arrive on time."),
         M("Match each phrase with its register.", [["Should you require further information", "formal"], ["Let me know if you need anything", "informal"], ["It is suggested that", "formal and impersonal"]]),
         TF("True or false: Formal structures are always best in friendly messages.", "False"),
         F("Type the missing word: It is essential that she ___ present. (subjunctive)", "be"),
         W("Build the sentence.", "I suggest that he be informed.", "never", "informs"),
         LISTEN("The committee recommends that the proposal be rejected. It is suggested that a revised version be submitted next month.", "How many formal subjunctive or impersonal forms can you hear?", "Two", "None", "One", "Five"),
         YOUR("Write two sentences for a formal notice using “It is essential that…” and “Should you…”."),
     ]),
    ("gram-a-register", "style", "Register: formal and informal", "GRAM-A-07",
     "Register is the level of formality. Compare two messages: a formal letter says “I am writing to enquire whether the position remains open”; a chat says “just checking if the job's still going.” Informal English uses contractions, phrasal verbs (find out, put up with), ellipsis and slang; formal English prefers full forms, single verbs of Latin origin (discover, tolerate), precise vocabulary and longer sentences. Match the register to audience and purpose; mixing registers sounds awkward.",
     [
         READ(CHAT, "Which feature is informal?", "Contractions and cheerful sign-off", "Long Latin verbs", "Subjunctive forms", "Passive voice"),
         READ(LETTER, "Which feature is formal?", "Full forms and polite conditionals", "Slang", "Contractions", "Emoji"),
         C("Which is the formal equivalent of “find out”?", "discover", "dig up", "look around", "sort out"),
         C("Which is the informal equivalent of “tolerate”?", "put up with", "endure", "accept", "undergo"),
         C("What should you match to the audience and purpose?", "The register", "The font", "The time of day", "The paper size"),
         M("Match each informal phrase with a formal one.", [["find out", "discover"], ["put off", "postpone"], ["ask for", "request"]]),
         C("Which version of “Dear Sir, just wanted to ask if you've got any jobs going” has the right register?", "Dear Sir, I am writing to ask whether you have any vacancies.", "Dear Sir, got any jobs, mate?", "Dear Sir, jobs?", "Dear Sir, hey, what's up with the jobs?"),
         C("Which version of “I wish to inform you that I shall be unable to attend the gathering tonight” suits a message to a friend?", "Hi Sam, I can't make it tonight.", "Hi Sam, I hereby regret my absence.", "Hi Sam, it is regrettable that attendance is impossible.", "Hi Sam, I am unable to attend per the invitation."),
         TF("True or false: Mixing very formal and very informal language sounds awkward.", "True"),
         F("Type the formal verb for “put off”.", "postpone"),
         W("Build the sentence.", "I would like to request more information.", "never", "ask"),
         LISTEN("Hi team, just a heads-up: the meeting's moved to three. Cheers. And the formal version: Please note that the meeting has been rescheduled to three o'clock.", "Which version is formal?", "Please note that the meeting has been rescheduled", "Just a heads-up", "Cheers", "The meeting's moved"),
         YOUR("Write the same message twice, once to a friend and once to a company: you cannot attend an event."),
     ]),
    ("gram-a-cohesion", "style", "Cohesion across sentences", "GRAM-A-08",
     "Cohesion is what makes sentences hold together. Use reference (this, that, the former), substitution (do so, one) and ellipsis (leaving out repeated words: “Some agreed; others did not”). Discourse markers signal structure: in the first place, moreover, by contrast, in sum. Put known information first and new information last so each sentence builds on the one before. Avoid starting every sentence the same way. Read your paragraph aloud: if you stumble, a link is missing.",
     [
         C("Which word links back to the idea in the previous sentence?", "This", "Some", "Another", "Yesterday"),
         C("Which sentence uses substitution?", "Some students wanted to leave early and did so.", "Some students wanted to leave early and left early.", "Students early left want some.", "Early students left wanted."),
         C("Which sentence uses ellipsis?", "Some agreed; others did not.", "Some agreed; others did not agree.", "Some agreed; others agreed not.", "Some agreed; not others."),
         C("Which marker shows contrast?", "By contrast", "Moreover", "In sum", "In the first place"),
         C("Which marker adds a point?", "Moreover", "By contrast", "However", "Nevertheless"),
         M("Match each marker with its job.", [["In the first place", "begins a list"], ["Moreover", "adds another point"], ["In sum", "summarizes"]]),
         C("Which version combines “Prices rose. Prices fell later. Prices stayed low.” most smoothly?", "Prices rose, then fell and stayed low.", "Prices rose. Prices fell. Prices stayed.", "Prices, rose, fell, stayed, low.", "Rose prices fell low stayed."),
         O("Put the paragraph in order.", ["Many cities are building bike lanes.", "This reduces traffic and pollution.", "By contrast, some drivers resist the change."]),
         TF("True or false: Putting known information first helps sentences link.", "True"),
         F("Type the missing word: Some agreed; others did ___.", "not"),
         W("Build the sentence.", "Moreover, the plan saves money.", "never", "saving"),
         LISTEN("In the first place, the plan is cheap. Moreover, it is fast. By contrast, the alternative is slow and costly. In sum, the plan is the better choice.", "Which marker introduces the conclusion?", "In sum", "In the first place", "Moreover", "By contrast"),
         YOUR("Write a four-sentence paragraph with a reference word, two discourse markers and one example of ellipsis."),
     ]),
]

if __name__ == "__main__":
    add_stage("grammarian", STAGE, LESSONS, "Advanced", SOURCES)
