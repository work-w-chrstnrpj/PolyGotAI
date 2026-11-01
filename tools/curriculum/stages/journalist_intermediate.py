#!/usr/bin/env python3
"""Journalist, Intermediate stage (about B1-B2): 2 units x 4 lessons, added to track-journalist.json.

Original wording. Ideas (two sources, on and off the record, balance, partial quotes, active voice, corrections) are standard
reporting-teaching concepts; sources are credited for ideas only.
Run from the project root: python3 tools/curriculum/stages/journalist_intermediate.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from track_lib import C, TF, READ, LISTEN, W, F, O, M, YOUR, add_stage  # noqa: E402

SOURCES = [
    "Public-domain style and ethics guidance for reporters (concepts only; no text copied)",
    "Standard newsroom practice for attribution, balance and corrections (ideas only; original wording)",
]

STAGE = {"id": "intermediate", "title": "Intermediate", "units": [
    {"id": "report", "title": "Report accurately"},
    {"id": "craft", "title": "Craft the story"},
]}

PARK = "The city council voted on Tuesday to close Pine Park for a year while workers replace the old playground. Council member Lena Ortiz said the equipment is unsafe. A neighbor, Kofi Mensah, said children will have nowhere to play. The council did not say where the money will come from."
RATE = "Robberies fell from 40 last year to 30 this year, according to the police. The city has about 200,000 people. Two years ago there were 55 robberies."
SHOP = "A fire damaged the Corner Bakery early Monday. The owner, Sam Cole, said no one was hurt. A fire officer said the cause may be a broken oven, but the report is not finished."

LESSONS = [
    ("jn-i-verify", "report", "Check facts with two sources", "JN-I-01",
     "A claim is stronger when two independent sources support it. Independent means they did not get the information from each other. Ask where a source got the facts: did they see it, or hear it from someone else? Say how you know: “according to the police report” or “said two witnesses.” If you cannot confirm a detail, leave it out or say it is unconfirmed.",
     [
         C("What makes a claim stronger?", "Two independent sources support it.", "One source repeats it twice.", "It sounds exciting.", "It is short."),
         C("What does “independent” mean for two sources?", "They did not get the facts from each other.", "They live far away.", "They have never met.", "They are famous."),
         C("Which question tests a source?", "Did you see it, or hear it from someone else?", "How old are you?", "Do you like the story?", "Is it a long story?"),
         READ(SHOP, "Which detail is still unconfirmed?", "The cause of the fire", "That a fire happened", "That no one was hurt", "The name of the bakery"),
         READ(SHOP, "How should the story describe the oven?", "The cause may be a broken oven, an officer said, but the report is not finished.", "A broken oven caused the fire.", "The owner broke the oven.", "The oven is new."),
         M("Match each phrase with how it tells the reader the source.", [["according to the police report", "names a document"], ["said two witnesses", "names people who saw it"], ["the cause is unconfirmed", "admits a gap"]]),
         TF("True or false: You can state an unconfirmed detail as a fact.", "False"),
         TF("True or false: Saying how you know builds the reader's trust.", "True"),
         F("Type the missing word: Ask where the source got the ___.", "facts"),
         W("Build the sentence.", "This detail is not confirmed.", "never", "yet"),
         LISTEN("Two people told me the road was closed. One saw the barrier herself. The other heard it from the first one.", "Are these two independent sources?", "No, the second heard it from the first", "Yes, they are fully independent", "Yes, because there are two", "No, because the road is closed"),
         O("Put the checking steps in order.", ["Find a claim", "Ask how the source knows it", "Look for a second, independent source"]),
         YOUR("A friend tells you a shop will close next month. Write two questions you would ask to check the story."),
     ]),
    ("jn-i-record", "report", "On the record, off the record", "JN-I-02",
     "Tell sources how you will use what they say. On the record means you can quote them by name. Background means you can use the information but not the name. Off the record means you cannot publish it. Agree on the rule before the information is shared, not after. Naming a person is usually best because readers can judge the source; use an anonymous source only when there is a real risk and a good reason.",
     [
         C("What does “on the record” mean?", "You may quote the person by name.", "You may not use anything.", "You must guess.", "You must keep it secret forever."),
         C("What does “off the record” mean?", "The information cannot be published.", "The person is famous.", "The talk was recorded.", "The story is long."),
         C("When should the rule be agreed?", "Before the information is shared", "After the story runs", "Never", "Only by email next year"),
         C("Why is naming a source usually better?", "Readers can judge who is speaking.", "It is shorter.", "It hides facts.", "It avoids questions."),
         C("When is an anonymous source reasonable?", "When there is a real risk and a good reason", "Whenever it saves time", "When the source is shy", "When the story is dull"),
         M("Match each term with its meaning.", [["On the record", "can quote by name"], ["Background", "can use the facts, not the name"], ["Off the record", "cannot be published"]]),
         TF("True or false: You can decide the rule after the source has spoken.", "False"),
         TF("True or false: A named source is usually easier for readers to trust.", "True"),
         F("Type the missing word: Agree the rule ___ the person speaks.", "before"),
         W("Build the sentence.", "Is this on the record?", "never", "about"),
         LISTEN("Before I ask my questions, I need to know: may I use your name, or would you like me to describe you as a city worker?", "What is the reporter doing?", "Agreeing how the information will be used", "Ending the interview", "Changing the story", "Asking for money"),
         O("Put the steps in order.", ["Explain how you will use the information", "Agree on the rule", "Ask your questions"]),
         YOUR("A person wants to give you information but not their name. Write two things you would ask or say."),
     ]),
    ("jn-i-numbers", "report", "Report numbers with context", "JN-I-03",
     "A number alone says little. Add a comparison, a base and a source. “Robberies fell from 40 to 30” becomes clearer with “in a city of 200,000,” and a trend over time. Say percent when the base is clear: a fall from 40 to 30 is 25 percent. Round when exactness does not matter: “about 200,000.” Never report a small change as a large trend.",
     [
         READ(RATE, "Which comparison gives the best context?", "The count from two years earlier", "The mood of the city", "The number of police cars", "The date of the next meeting"),
         READ(RATE, "By what percent did robberies fall from 40 to 30?", "25 percent", "10 percent", "75 percent", "30 percent"),
         C("Why add a base, like the size of the city?", "It shows whether the number is large or small.", "It makes the story longer.", "It hides the number.", "It is required by law."),
         C("When is rounding fine?", "When exactness does not matter", "Always", "Never", "Only for names"),
         C("Which phrase shows the source of a number?", "according to the police", "everyone knows", "it seems", "maybe"),
         M("Match each helper with its job.", [["Comparison", "shows the change"], ["Base", "shows the size"], ["Source", "shows where it came from"]]),
         TF("True or false: A small change should be reported as a big trend.", "False"),
         TF("True or false: A number with no source is hard to trust.", "True"),
         F("Type the missing word: Add a source for every ___.", "number"),
         W("Build the sentence.", "Robberies fell by a quarter.", "never", "quarters"),
         LISTEN("The number of buses fell from 50 to 45. That is a drop of ten percent, but the city says the new buses are larger and carry more people.", "What context does the speaker add?", "The new buses are larger", "The buses are red", "The city is small", "The drivers are new"),
         O("Put the steps in order.", ["Find the number and its source", "Compare it with an earlier number", "Say what the change means for readers"]),
         YOUR("Sales rose from 20 to 24 in one week. Write one careful sentence for a news story."),
     ]),
    ("jn-i-balance", "report", "Be fair and balanced", "JN-I-04",
     "Fair stories give the people involved a chance to respond. If you report a criticism, ask the person criticized for their side before you publish. Use neutral verbs: “said” is fairer than “claimed,” which suggests doubt. Do not use loaded words, such as “disaster” or “miracle,” unless a source says them. Balance does not mean pretending two unequal sides are equal; give more weight to the stronger evidence.",
     [
         READ(PARK, "Whose views does the story include?", "A council member and a neighbor", "Only the council", "Only the neighbor", "A police officer"),
         READ(PARK, "What question does the story leave unanswered?", "How the work will be paid for", "When the council met", "Who lives nearby", "How big the park is"),
         C("Why ask the person criticized for a reply?", "To be fair and complete", "To make the story longer", "To avoid the facts", "To please the editor"),
         C("Which verb is more neutral?", "said", "claimed", "confessed", "boasted"),
         C("Which word is loaded?", "disaster", "meeting", "vote", "report"),
         C("What does balance NOT mean?", "Treating weak and strong evidence as equal", "Hearing both sides", "Being fair", "Checking facts"),
         M("Match each habit with its effect.", [["Ask for a reply", "fair to the person"], ["Loaded word", "shows opinion"], ["Neutral verb", "keeps tone even"]]),
         TF("True or false: “Said” and “claimed” mean the same to a reader.", "False"),
         TF("True or false: You should give the person criticized a chance to respond.", "True"),
         F("Type the missing word: Use ___ verbs such as said.", "neutral"),
         W("Build the sentence.", "We asked the council for a reply.", "never", "asks"),
         LISTEN("The mayor said the plan will save money. A group of residents said it will raise their bills. We asked the city to explain the costs and are waiting for an answer.", "How does the reporter show fairness?", "Includes both views and asks for an answer", "Gives only the mayor's view", "Leaves out the residents", "Calls the plan a disaster"),
         YOUR("Rewrite this sentence in a neutral way: “The mayor’s terrible plan was a disaster, he claimed it would help.”"),
     ]),
    ("jn-i-lede", "craft", "News ledes and feature ledes", "JN-I-05",
     "A news lede gives the main facts in one or two sentences: who, what, when and where. A feature lede may start with a person or a scene to pull the reader in, but it must reach the point quickly in a “nut paragraph.” Choose the lede that fits the story: urgent news needs a direct lede; a human story can start with a moment. Avoid starting with a question or a weather report unless it truly matters.",
     [
         C("What does a news lede contain?", "The main facts: who, what, when and where", "A long background", "The weather", "The reporter's name"),
         C("What is a nut paragraph?", "The paragraph that tells the reader why the story matters", "A food story", "The last sentence", "A headline"),
         C("Which story suits a direct lede?", "An urgent fire", "A quiet profile of a baker", "A travel diary", "A poem"),
         READ(SHOP, "Which is the strongest news lede?", "A fire damaged the Corner Bakery early Monday, but no one was hurt, the owner said.", "Early Monday was cold.", "Sam Cole likes bread.", "Fires are bad."),
         C("Which lede is a feature lede?", "At five each morning, Sam Cole lights the oven he built himself.", "A fire damaged a bakery on Monday.", "Police say a crash blocked Main Street.", "The council voted on Tuesday."),
         M("Match each lede type with its use.", [["Direct news lede", "urgent news"], ["Feature lede", "a human story"], ["Nut paragraph", "explains why it matters"]]),
         O("Put a feature opening in order.", ["Start with a person or a moment", "Add a nut paragraph", "Give the facts and sources"]),
         TF("True or false: A feature lede may begin with a scene.", "True"),
         TF("True or false: Every story needs a weather report at the start.", "False"),
         F("Type the missing word: A ___ lede gives who, what, when and where.", "news"),
         W("Build the sentence.", "A fire damaged the bakery on Monday.", "never", "damages"),
         LISTEN("At five every morning, Sam Cole lights the oven he built himself. On Monday, a fire took it. The council has promised new funds for small shops, but the owner says that is not enough.", "Which sentence works as the nut paragraph?", "The council has promised funds, but the owner says it is not enough.", "At five every morning, Sam lights the oven.", "On Monday, a fire took it.", "He built the oven."),
         YOUR("Write a direct lede and a feature lede for the same event: a school closes for a day because of snow."),
     ]),
    ("jn-i-quote", "craft", "Quote and paraphrase well", "JN-I-06",
     "Use a direct quote when the words are vivid or the person matters. Use a paraphrase when the idea is clear but the wording is dull. Do not change words inside quotation marks. A partial quote is allowed if it does not change the meaning. Place attribution after the first sentence of a quote: “We need new equipment,” Ortiz said. “The old playground is unsafe.” Check every quote against your notes.",
     [
         C("When should you use a direct quote?", "When the words are vivid or the person matters", "When you forgot the idea", "For every sentence", "When the words are dull"),
         C("When is a paraphrase better?", "When the idea is clear but the wording is dull", "When the quote is perfect", "When you want to change the meaning", "Never"),
         C("What must you never do with words inside quotation marks?", "Change them", "Print them", "Check them", "Attribute them"),
         C("Which attribution placement is smooth?", "“We need new equipment,” Ortiz said. “The old playground is unsafe.”", "Ortiz said said said.", "“We need,” new “equipment.”", "Ortiz. “We need.”"),
         C("When is a partial quote acceptable?", "When it does not change the meaning", "Whenever you like", "When it sounds harsher", "Never"),
         M("Match each tool with its use.", [["Direct quote", "keeps the exact words"], ["Paraphrase", "puts the idea in your words"], ["Partial quote", "uses a few exact words"]]),
         TF("True or false: You may fix a speaker's grammar inside quotation marks.", "False"),
         TF("True or false: You should check every quote against your notes.", "True"),
         F("Type the missing word: Never ___ the words inside quotation marks.", "change"),
         W("Build the sentence.", "Ortiz said the equipment is unsafe.", "never", "unsave"),
         READ(PARK, "Which is a correct paraphrase of the neighbor's view?", "Mensah said the closure leaves children without a place to play.", "Mensah said he loves the playground.", "Mensah said the council lied.", "Mensah said the park is fine."),
         LISTEN("“I trust the equipment,” the manager said. Later she added that new parts would arrive in a week.", "Which part is a direct quote?", "I trust the equipment.", "Later she added.", "New parts would arrive.", "In a week."),
         YOUR("Turn this into a paraphrase: “Honestly, the thing is, we just don’t have the budget for it right now.”"),
     ]),
    ("jn-i-style", "craft", "Write clear news sentences", "JN-I-07",
     "News sentences are short, active and specific. Put the actor first: “The council closed the park” is clearer than “The park was closed by the council.” Use plain words: “use,” not “utilize.” Prefer the specific: “three workers,” not “several people.” Use the past tense for events that have ended. Cut words that do not add facts, such as “very” and “really.”",
     [
         C("Which sentence is active?", "The council closed the park.", "The park was closed by the council.", "Closing happened to the park.", "A closure of the park was done."),
         C("Which phrase is more specific?", "three workers", "several people", "some folks", "a few"),
         C("Which word is plain?", "use", "utilize", "commence", "endeavor"),
         C("Which tense usually fits a finished event?", "Past", "Future", "Conditional", "None"),
         C("Which words can you often cut?", "very and really", "who and where", "numbers", "names"),
         M("Match each habit with an example.", [["Active voice", "The council closed the park."], ["Specific detail", "three workers"], ["Plain word", "use"]]),
         O("Put the editing steps in order.", ["Find the actor", "Move it to the front", "Cut words that add no facts"]),
         TF("True or false: Passive voice is always clearer.", "False"),
         TF("True or false: Specific numbers make a sentence stronger.", "True"),
         F("Type the missing word: Write short, active and ___ sentences.", "specific"),
         W("Build the sentence.", "Workers will replace the playground.", "never", "replaced"),
         LISTEN("The playground was damaged by a storm. Rewritten: A storm damaged the playground.", "Why is the second sentence better?", "It puts the actor first", "It is longer", "It is passive", "It uses jargon"),
         YOUR("Rewrite in active voice: “The decision was made by the school board that the library would be closed.”"),
     ]),
    ("jn-i-correct", "craft", "Check, correct and headline", "JN-I-08",
     "Before you publish, check names, numbers, dates and quotes. Read the headline: does it match the story, or does it promise more than the facts show? If you find a mistake after publishing, correct it quickly and plainly: “An earlier version said 150 people attended. The correct number is 105.” Do not hide a correction. Readers trust a newsroom that fixes its errors.",
     [
         C("What should you check before publishing?", "Names, numbers, dates and quotes", "Only the font", "The weather", "Your lunch"),
         C("What makes a headline honest?", "It matches what the story shows.", "It is as loud as possible.", "It promises more than the facts.", "It has no verb."),
         C("What should you do after finding a mistake?", "Correct it quickly and plainly", "Hide it", "Blame someone", "Wait a year"),
         C("Which is a clear correction?", "An earlier version said 150 people attended. The correct number is 105.", "Oops, sorry about that, mistakes happen.", "Ignore previous number.", "Numbers change."),
         C("Why do corrections help trust?", "Readers see the newsroom fixes errors.", "They hide the story.", "They make the story longer.", "They remove names."),
         M("Match each check with what it protects.", [["Check names", "avoids hurting a person"], ["Check numbers", "keeps facts right"], ["Read the headline", "keeps the promise honest"]]),
         O("Put the steps in order.", ["Check names, numbers and quotes", "Read the headline against the story", "Publish and correct quickly if needed"]),
         TF("True or false: A headline may promise more than the story shows.", "False"),
         TF("True or false: A plain correction builds trust.", "True"),
         F("Type the missing word: Correct a mistake ___ and plainly.", "quickly"),
         W("Build the sentence.", "The correct number is 105.", "never", "correction"),
         LISTEN("Headline: Park closed forever. Story: The park will close for one year. The headline promises more than the facts show.", "What is wrong with the headline?", "It promises more than the facts show", "It is too short", "It has a number", "It names a person"),
         YOUR("Write a short correction for this mistake: a story said the event is on Friday, but it is on Saturday."),
     ]),
]

if __name__ == "__main__":
    add_stage("journalist", STAGE, LESSONS, "Intermediate", SOURCES)
