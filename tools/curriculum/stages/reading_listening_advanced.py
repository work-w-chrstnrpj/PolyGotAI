#!/usr/bin/env python3
"""Reading & Listening Comprehension, Advanced stage (about C1-C2): 2 units x 4 lessons, added to track-reading-listening.json.

Original wording and original passages. Ideas (implicit meaning and irony, rhetorical devices, evaluating evidence,
synthesis, following long talks, accents and reduced speech, stance in debate, shifts of register) are standard teaching
concepts; sources credited for ideas only. Run from the project root: python3 tools/curriculum/stages/reading_listening_advanced.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from track_lib import C, TF, READ, LISTEN, W, F, O, M, YOUR, add_stage  # noqa: E402

SOURCES = [
    "British Council-EAQUALS Core Inventory for General English (topic order and level)",
    "CEFR Companion Volume (reading and listening descriptors, C1-C2)",
]

STAGE = {"id": "advanced", "title": "Advanced", "units": [
    {"id": "analysis", "title": "Analyze texts critically"},
    {"id": "complex", "title": "Follow complex speech"},
]}

IRONY = "The minister praised the new timetable as a triumph of planning, shortly before announcing that commuters should allow an extra hour for their journeys."
DEVICE = "We are told that the choice is between progress and tradition. But a town that cannot protect its past has no future worth building, and a plan that ignores its people is not progress at all."
STUDY = "A study of 120 volunteers found that those who drank green tea daily scored higher on a memory test. The volunteers were recruited through a tea company's newsletter, and the study was funded by the same company."
S1 = "Source one argues that remote work raises productivity, citing a survey of 300 managers."
S2 = "Source two argues that remote work lowers productivity, citing a trial of 40 call-center staff."

LESSONS = [
    ("rl-a-implicit", "analysis", "Irony, understatement and implication", "RL-A-01",
     "Writers often mean more, less or the opposite of what they say. Irony says one thing while signaling another: praising a timetable and then advising everyone to allow an extra hour. Understatement plays down: “a slight delay” for a day of chaos. Implication leaves a conclusion unsaid. To read these, notice the gap between the words and the situation, and ask what the writer wants you to conclude. Context is your main clue.",
     [
         READ(IRONY, "What is the effect of the minister's praise?", "It is ironic, because the next information contradicts it.", "It shows genuine success.", "It is a neutral report.", "It is an apology."),
         C("What is irony?", "Saying one thing while signaling another meaning", "Repeating a phrase", "Giving a number", "Asking a question"),
         C("What is understatement?", "Playing down something serious", "Exaggerating", "Naming a source", "Giving advice"),
         C("What is implication?", "Leaving a conclusion unsaid for the reader to draw", "Writing a summary", "Citing evidence", "Giving a definition"),
         C("What is your main clue to irony?", "The gap between the words and the situation", "The font", "The length", "The title"),
         M("Match each sentence with its device.", [["A slight delay, said of a day of chaos", "understatement"], ["What a wonderful day, said in a storm", "irony"], ["Her chair was empty again", "implication"]]),
         TF("True or false: A writer always means exactly what the words say.", "False"),
         F("Type the missing word: Notice the gap between the words and the ___.", "situation"),
         W("Build the sentence.", "The writer clearly means the opposite.", "never", "mean"),
         LISTEN("Oh, wonderful. The one day I forget my umbrella, and the sky decides to open. Truly a perfect morning.", "What is the speaker's tone?", "Ironic", "Sincere", "Joyful", "Neutral"),
         O("Put the steps in order.", ["Read the statement", "Compare it with the situation", "Decide what the writer wants you to conclude"]),
         YOUR("Write one ironic sentence and one understatement about a day of heavy traffic."),
     ]),
    ("rl-a-rhetoric", "analysis", "Rhetorical moves in a text", "RL-A-02",
     "Persuasive texts use recognizable moves. A false dilemma presents two options as the only ones. Loaded contrast pits good against bad. Rhetorical questions imply an answer. Repetition builds emotion. Appeals to authority or fear stand in for evidence. Spotting them does not mean the argument is wrong; it means you should look at the evidence behind the style. Ask: what is being asked of me, and what support is given?",
     [
         READ(DEVICE, "Which move does the first sentence use?", "A false dilemma between progress and tradition", "A statistic", "A personal story", "An expert quotation"),
         C("What is a false dilemma?", "Presenting two options as the only ones", "A true choice", "A list of facts", "A joke"),
         C("What does a rhetorical question do?", "Implies an answer", "Asks for data", "Ends an argument", "Names a source"),
         C("What does repetition do?", "Builds emotion and emphasis", "Proves a claim", "Hides a claim", "Ends a paragraph"),
         C("What is a good response to a persuasive style?", "Look at the evidence behind it", "Believe it", "Ignore all of it", "Skip the text"),
         M("Match each move with its effect.", [["False dilemma", "narrows the choices"], ["Rhetorical question", "implies the answer"], ["Appeal to fear", "stands in for evidence"]]),
         O("Put the analysis in order.", ["Notice the persuasive moves", "Ask what is being asked of you", "Check the evidence behind the claims"]),
         TF("True or false: Spotting a rhetorical move proves that an argument is wrong.", "False"),
         F("Type the missing word: Ask what ___ is given.", "support", "evidence"),
         W("Build the sentence.", "This presents only two options.", "never", "present"),
         LISTEN("Do you want a safe city, or do you want chaos? Surely every sensible person knows which to choose. Vote yes.", "Which moves does the speaker use?", "A false dilemma and a rhetorical question", "A statistic and a quotation", "A story and a joke", "A definition and an example"),
         YOUR("Write a short persuasive paragraph with a rhetorical question and a false dilemma. Then name both."),
     ]),
    ("rl-a-evidence", "analysis", "Evaluate evidence and methods", "RL-A-03",
     "When a text cites a study, ask how it was done. Who took part, and how were they chosen? How many? Was there a comparison group? Who paid for it, and could that affect the result? Does the conclusion go beyond the data? A claim of cause needs more than a correlation. Treat a single study with caution and look for replication. The question is not whether the study is perfect but how far the conclusion can be trusted.",
     [
         READ(STUDY, "What is a weakness of the green tea study?", "Volunteers came from a company newsletter and the company paid.", "The study had too few tea types.", "The memory test was too hard.", "The volunteers were too young."),
         C("Which question tests sample quality?", "How were participants chosen?", "What color was the room?", "Who wrote the headline?", "Was the test long?"),
         C("Why ask who paid for a study?", "Funding may affect the design or the reporting", "Funding is always dishonest", "It does not matter", "Because it is polite"),
         C("What does a comparison group allow?", "Checking whether the effect differs from no treatment", "Making the study longer", "Hiding results", "Ignoring size"),
         C("What does a claim of cause need?", "More than a correlation", "Only a correlation", "A catchy title", "A large font"),
         M("Match each question with what it checks.", [["How many took part?", "sample size"], ["Was there a comparison group?", "whether the effect is real"], ["Who paid?", "possible bias"]]),
         O("Put the evaluation in order.", ["Identify the claim", "Check how the study was done", "Decide how far the conclusion can be trusted"]),
         TF("True or false: A single study settles the question.", "False"),
         F("Type the missing word: Look for ___ of the result.", "replication"),
         W("Build the question.", "How were the volunteers recruited?", "does", "recruit"),
         LISTEN("The study is interesting, but only forty people took part, there was no comparison group, and the sponsor sells the product. I would call the result a hint, not a finding.", "What is the speaker's conclusion?", "The result is only a hint", "The result is proven", "The result is false", "The result is irrelevant"),
         YOUR("A report claims a new app improves memory. Write three questions you would ask about the study."),
     ]),
    ("rl-a-synth", "analysis", "Synthesize several sources", "RL-A-04",
     "Synthesis means building one view from several sources. Do not summarize each in turn. Group the sources by idea: where do they agree, disagree, or answer different questions? Weigh their quality: sample, method, date. Then state a position that accounts for all of them: “Surveys of managers suggest gains, but a controlled trial of call-center staff found losses, so the effect may depend on the type of work.” Attribute each point clearly.",
     [
         READ(S1 + " " + S2, "Which sentence is the best synthesis?", "The effect may depend on the work: a manager survey suggests gains, while a small call-center trial found losses.", "Remote work is good.", "Remote work is bad.", "Both sources are the same."),
         C("What is synthesis?", "Building one view from several sources", "Summarizing each source in turn", "Copying one source", "Ignoring sources"),
         C("How should you organize several sources?", "Group them by idea", "List them one by one", "Hide differences", "Drop the weaker ones"),
         C("What should you weigh?", "Sample, method and date", "Font and length", "Titles", "Authors' ages"),
         C("What should you do with each point?", "Attribute it clearly", "Remove its source", "Exaggerate it", "Repeat it"),
         M("Match each step with its task.", [["Group", "find agreement and disagreement"], ["Weigh", "judge quality"], ["State", "give a position that fits all"]]),
         O("Put the synthesis in order.", ["Read all the sources", "Group by idea and weigh quality", "State a position that accounts for all"]),
         TF("True or false: Synthesis means summarizing one source after another.", "False"),
         F("Type the missing word: Attribute each ___ clearly.", "point"),
         W("Build the sentence.", "The evidence suggests the effect varies.", "never", "varying"),
         LISTEN("Source A surveyed managers. Source B ran a controlled trial. They measure different things, so I would not call them in conflict. Together they suggest that perceived and measured productivity can differ.", "What is the speaker's synthesis?", "Perceived and measured productivity can differ", "Source A is wrong", "Source B is wrong", "Nothing can be learned"),
         YOUR("Two articles disagree on whether students should wear uniforms. Write two sentences that synthesize them."),
     ]),
    ("rl-a-lecture", "complex", "Long talks and digressions", "RL-A-05",
     "In a long lecture or talk, speakers digress, return, qualify and repeat. Follow the main thread: listen for signposts (“to return to my main point,” “the second issue”), and for restatements (“in other words”). Separate main points from asides: “by the way” and “this reminds me” mark digressions. Keep a running outline, leave gaps for what you miss, and use the summary at the end to check it. Do not panic if you lose a detail: rejoin at the next signpost.",
     [
         C("Which phrase signals a digression?", "By the way", "To sum up", "The second issue", "In conclusion"),
         C("Which phrase signals a return to the main point?", "To return to my main point", "This reminds me", "By the way", "Incidentally"),
         C("What does “in other words” introduce?", "A restatement", "A new topic", "A joke", "A question"),
         C("What should you do if you lose a detail?", "Rejoin at the next signpost", "Stop listening", "Panic", "Leave"),
         C("What helps check your notes?", "The summary at the end", "The first line", "The title", "The room"),
         M("Match each phrase with its function.", [["By the way", "starts an aside"], ["To return to my main point", "gets back to the thread"], ["In other words", "restates"]]),
         O("Put the listening steps in order.", ["Catch the main thread through signposts", "Mark asides as asides", "Check your outline against the summary"]),
         TF("True or false: Every sentence in a lecture is equally important.", "False"),
         F("Type the missing word: Rejoin at the next ___.", "signpost"),
         W("Build the sentence.", "To return to my main point, costs matter.", "never", "returns"),
         LISTEN("By the way, I once visited that harbor; it was lovely. But to return to my main point: the second issue is cost. In other words, we cannot afford to delay.", "What is the second issue?", "Cost", "The harbor", "A visit", "Beauty"),
         LISTEN("By the way, I once visited that harbor; it was lovely. But to return to my main point: the second issue is cost. In other words, we cannot afford to delay.", "Which part is the aside?", "I once visited that harbor", "The second issue is cost", "We cannot afford to delay", "In other words"),
         YOUR("Write a short outline with two main points and one aside for a talk about city parks."),
     ]),
    ("rl-a-reduced", "complex", "Fast, reduced and accented speech", "RL-A-06",
     "Natural speech is not careful speech. Words blend and reduce: “going to” becomes “gonna,” “want to” becomes “wanna,” “did you” sounds like “didja.” Function words are weak and quick; content words carry stress. Accents differ in vowels, consonants and rhythm, so a word may sound unlike the dictionary form. To train your ear, listen to the same speaker several times, use captions to check afterward, and focus on the stressed words first. Context often fills the gaps.",
     [
         C("What does “gonna” stand for?", "going to", "gone to", "got to", "gotten"),
         C("What does “wanna” stand for?", "want to", "was not", "wonder", "want"),
         C("Which words are usually stressed?", "Content words", "Function words", "Every word equally", "Only the first word"),
         C("What can help fill gaps in fast speech?", "Context", "A dictionary", "Silence", "A louder volume"),
         C("What is a good way to train your ear?", "Listen several times and check with captions afterward", "Listen once only", "Skip hard parts always", "Never use captions"),
         M("Match each spoken form with its written form.", [["gonna", "going to"], ["wanna", "want to"], ["didja", "did you"]]),
         O("Put the practice in order.", ["Listen for the stressed words", "Listen again for the rest", "Check with captions"]),
         TF("True or false: Accents can make a word sound different from its dictionary form.", "True"),
         F("Type the missing word: I'm ___ call her tomorrow. (going to)", "gonna"),
         W("Build the sentence.", "I want to go home.", "never", "wanna"),
         LISTEN("Didja see what happened? I was gonna tell ya, but he'd already gone. I dunno what we're gonna do.", "What does “dunno” mean?", "I don't know", "I do know", "I did not", "I do not go"),
         LISTEN("Didja see what happened? I was gonna tell ya, but he'd already gone. I dunno what we're gonna do.", "What was the speaker going to do?", "Tell someone", "Leave", "Cook", "Call a taxi"),
         YOUR("Write four reduced spoken forms you know and their written forms."),
     ]),
    ("rl-a-debate", "complex", "Follow a debate or interview", "RL-A-07",
     "In a debate or interview, speakers disagree, interrupt and talk across each other. Track who holds which position; note each speaker's claim in a word or two. Listen for stance markers: “frankly,” “I'd argue that,” “to be fair.” Notice when a speaker concedes, deflects or changes the subject. Do not confuse a speaker repeating an opponent's view (“You say that…”) with their own. After listening, summarize each position in one sentence.",
     [
         C("What should you track in a debate?", "Who holds which position", "Who speaks loudest", "Who is oldest", "Who sits closest"),
         C("What do stance markers show?", "The speaker's attitude or position", "The time", "The place", "The topic only"),
         C("Which phrase is a stance marker?", "I'd argue that", "In 1998", "On Tuesday", "Next to the door"),
         C("What does “You say that…” usually introduce?", "The opponent's view", "The speaker's own view", "A joke", "A conclusion"),
         C("What does deflecting mean?", "Avoiding a question by changing the focus", "Answering fully", "Agreeing", "Repeating the question"),
         M("Match each signal with its meaning.", [["To be fair", "a concession is coming"], ["Frankly", "a direct opinion follows"], ["You say that", "reports the other side"]]),
         O("Put the steps in order.", ["Note each speaker's claim", "Listen for stance and concessions", "Summarize each position in one sentence"]),
         TF("True or false: A speaker repeating an opponent's view is stating their own view.", "False"),
         F("Type the missing word: I'd ___ that costs are too high.", "argue"),
         W("Build the sentence.", "To be fair, she has a point.", "never", "fairly"),
         LISTEN("You say that the plan is too costly. To be fair, the first year is expensive. But I'd argue that over ten years it pays for itself, and frankly, doing nothing costs more.", "What does the speaker concede?", "The first year is expensive", "The plan is cheap", "The plan is useless", "The opponent is wrong about everything"),
         LISTEN("You say that the plan is too costly. To be fair, the first year is expensive. But I'd argue that over ten years it pays for itself, and frankly, doing nothing costs more.", "What is the speaker's own position?", "The plan pays for itself over time", "The plan is too costly", "The plan should stop", "Nothing can be known"),
         YOUR("Write one-sentence summaries of two opposing positions on school uniforms."),
     ]),
    ("rl-a-register", "complex", "Tone shifts and subtle register", "RL-A-08",
     "Skilled speakers and writers change tone within a single piece: formal to confiding, serious to playful, distant to personal. Notice the signals: sentence length, vocabulary, direct address (“you”), humor and contractions. A shift often marks something important: the move from policy language to a personal story signals a turning point. Ask what the shift does for the audience. Reading for tone is not only decoding words; it is hearing how the writer or speaker stands toward the topic and the reader.",
     [
         C("What can a shift in tone signal?", "Something important or a turning point", "An error always", "The end of a text", "A typing mistake"),
         C("Which feature suggests a more personal tone?", "Direct address with “you”", "Passive voice", "Long Latin words", "Footnotes"),
         C("Which feature suggests formal tone?", "Long sentences and precise vocabulary", "Contractions", "Slang", "Exclamations"),
         C("What should you ask about a shift?", "What it does for the audience", "How long it is", "Who typed it", "Where it appears on the page"),
         C("What is reading for tone?", "Hearing how the writer stands toward the topic and the reader", "Counting adjectives", "Checking spelling", "Skimming"),
         M("Match each signal with the tone it suggests.", [["Short sentences, direct address", "intimate"], ["Long sentences, technical terms", "formal"], ["Jokes and contractions", "playful"]]),
         O("Put the reading in order.", ["Notice a change in vocabulary or sentence length", "Ask what it signals", "Decide what the shift does for the audience"]),
         TF("True or false: Tone cannot change within one piece of writing.", "False"),
         F("Type the missing word: A change in ___ can mark a turning point.", "tone"),
         W("Build the sentence.", "The tone becomes more personal here.", "never", "personally"),
         LISTEN("The committee has resolved to postpone the review pending further consultation. But let me tell you what that means. It means that a family I know, with two small children, will wait another year for a home.", "What does the shift do?", "Makes the policy personal", "Makes the policy more formal", "Ends the talk", "Adds a joke"),
         YOUR("Write three sentences that begin formal and end personal, about a topic you care about."),
     ]),
]

if __name__ == "__main__":
    add_stage("reading-listening", STAGE, LESSONS, "Advanced", SOURCES)
