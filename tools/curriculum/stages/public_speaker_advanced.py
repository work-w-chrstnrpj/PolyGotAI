#!/usr/bin/env python3
"""Public Speaking & Rhetoric, Advanced stage (about C1-C2): 2 units x 4 lessons, added to track-public-speaker.json.

Original wording and original sample lines. Ideas (credibility, rhetorical figures, metaphor, speech structures, reading the
room, hostile audiences, ceremonial speaking, camera presence) are standard rhetoric-teaching concepts; sources credited for ideas only.
Run from the project root: python3 tools/curriculum/stages/public_speaker_advanced.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from track_lib import C, TF, READ, LISTEN, W, F, O, M, YOUR, add_stage  # noqa: E402

SOURCES = [
    "Aristotle, Rhetoric and Cicero, De Oratore (public-domain translations): ethos, pathos, logos and the five canons",
    "Common speechwriting practice: rhetorical figures, problem-solution structure, ceremonial speaking (concepts only; original wording)",
]

STAGE = {"id": "advanced", "title": "Advanced", "units": [
    {"id": "rhetoric", "title": "Rhetorical craft"},
    {"id": "command", "title": "Command the room"},
]}

OPEN = "Good evening. I have spent twenty years teaching children to read, and in that time I have learned one thing that matters more than any method: nobody learns from someone who does not believe in them."
LINES = "We did not choose the storm, but we chose the shelter. We did not choose the loss, but we chose the repair."
PLAN = "First, show the audience a problem they feel. Second, show that it is serious and that it will not fix itself. Third, present your solution. Fourth, picture the future with the solution. Finally, ask for one specific action."
HECKLE = "A speaker is describing a new bus plan when a man in the third row shouts that the city never listens to anyone."

LESSONS = [
    ("ps-a-ethos", "rhetoric", "Credibility in the first minute", "PS-A-01",
     "Listeners decide quickly whether to trust you. Ethos is the trust you build through competence, goodwill and character. In the first minute show why you can speak on the topic, but briefly: one line of experience, not a résumé. Show goodwill by naming what you share with the audience. Then be consistent: confident claims, honest limits (“I do not know that yet”) and no exaggeration. One caught exaggeration costs more credibility than ten strong claims can earn.",
     [
         READ(OPEN, "How does the speaker build credibility?", "With one line of long experience and a belief about students", "With a list of awards", "With jokes about herself", "With statistics"),
         C("What is ethos?", "The trust you build in the audience", "A kind of statistic", "The final line", "A gesture"),
         C("What are the three sources of credibility?", "Competence, goodwill and character", "Money, fame and luck", "Voice, hair and clothes", "Slides, notes and a microphone"),
         C("Which opening shows goodwill?", "I know many of you have given up your evenings to be here, and I am grateful.", "I am the best qualified person here.", "You will be bored.", "I had little time to prepare."),
         C("What does admitting a limit do?", "It can raise credibility", "It always lowers credibility", "It ends the talk", "It hides the claim"),
         C("What does a caught exaggeration do?", "It damages trust more than strong claims can repair", "It makes the talk livelier", "It helps memory", "It pleases the audience"),
         M("Match each source with an example.", [["Competence", "twenty years of teaching"], ["Goodwill", "I am grateful you came"], ["Character", "I do not know that yet"]]),
         TF("True or false: Reading out a full résumé is the best way to build trust.", "False"),
         F("Type the missing word: Show goodwill by naming what you ___ with the audience.", "share"),
         W("Build the sentence.", "I do not know that yet.", "never", "yes"),
         LISTEN("I am not a lawyer, so I will not give legal advice. But I have helped forty families through this process, and I can tell you what they found hardest.", "How does the speaker build credibility?", "By stating a limit and a relevant experience", "By claiming to know everything", "By criticizing lawyers", "By telling a joke"),
         O("Put the opening in order.", ["Name what you share with the audience", "Give one line of relevant experience", "State your main message"]),
         YOUR("Write the first three sentences of a talk about a topic you know, building credibility without boasting."),
     ]),
    ("ps-a-figures", "rhetoric", "Figures that carry an idea", "PS-A-02",
     "Rhetorical figures give shape to ideas. Anaphora repeats the start of lines: “We will not tire, we will not yield.” Antithesis sets opposites side by side: “Ask not what… but what…” Chiasmus reverses a phrase: “Work to live; do not live to work.” A tricolon lists three: “faster, safer, cheaper.” Use a figure to sharpen one key idea, not every sentence. Overdecorated speech sounds false.",
     [
         READ(LINES, "Which figure does this passage use most clearly?", "Anaphora and antithesis", "Chiasmus only", "A list of three", "A question"),
         C("What is anaphora?", "Repeating the start of successive lines", "Reversing a phrase", "Listing three items", "Asking a question"),
         C("Which line is a chiasmus?", "Work to live; do not live to work.", "We will not tire, we will not yield.", "Faster, safer, cheaper.", "To be or not."),
         C("Which line is a tricolon?", "faster, safer, cheaper", "work to live and live to work", "we did not choose, we did not choose", "up and down"),
         C("Which line is an antithesis?", "We did not choose the storm, but we chose the shelter.", "We will not tire, we will not yield.", "Fast, faster, fastest.", "Why not?"),
         C("When should you use a figure?", "To sharpen one key idea", "In every sentence", "Never", "Only at the end of the year"),
         M("Match each figure with its description.", [["Anaphora", "repeated openings"], ["Antithesis", "opposites side by side"], ["Chiasmus", "reversed phrase"]]),
         TF("True or false: Overdecorated speech can sound false.", "True"),
         F("Type the missing word: A ___ lists three items.", "tricolon"),
         W("Build the sentence.", "We chose the shelter, not the storm.", "never", "choosing"),
         LISTEN("We will not be silent. We will not be moved. We will not be divided.", "Which figure is this?", "Anaphora", "Chiasmus", "Question", "Metaphor"),
         O("Put the steps in order.", ["Find the one idea that matters most", "Choose a figure that suits it", "Say it aloud and cut anything that sounds forced"]),
         YOUR("Write one line with anaphora and one chiasmus about learning."),
     ]),
    ("ps-a-metaphor", "rhetoric", "Metaphor and concrete images", "PS-A-03",
     "Abstract ideas become memorable through images. A metaphor shows one thing as another: “Debt is an anchor.” Choose one governing image and keep it consistent through a section; mixing metaphors confuses (“We must nip this bubble in the bud”). Make numbers concrete: “a thousand tons is about two hundred elephants.” Check that the image fits your values: a war metaphor for health care invites a certain attitude.",
     [
         C("What does a metaphor do?", "Shows one thing as another", "Gives a statistic", "Ends a speech", "Lists three items"),
         C("Which line mixes metaphors?", "We must nip this bubble in the bud.", "Debt is an anchor.", "The law is a fence.", "Time is a river."),
         C("Which makes a number concrete?", "A thousand tons is about two hundred elephants.", "A thousand tons is a thousand tons.", "The number is big.", "It is heavy."),
         C("Why keep one governing image in a section?", "It stays clear and memorable", "It makes the section shorter", "It hides the claim", "It replaces evidence"),
         C("What should you check about an image?", "That it fits your values and message", "That it is long", "That it is unusual only", "That it rhymes"),
         M("Match each image with the attitude it may carry.", [["War on a disease", "fight and enemy"], ["Garden of health", "care and growth"], ["Machine of the body", "repair and parts"]]),
         TF("True or false: Mixed metaphors can confuse listeners.", "True"),
         TF("True or false: A war metaphor has no effect on attitude.", "False"),
         F("Type the missing word: Debt is an ___.", "anchor"),
         W("Build the sentence.", "Think of the budget as a map.", "never", "maps"),
         LISTEN("Our city is a garden. Parks are its lungs, streets are its paths, and neighbors are the gardeners. A garden does not grow when everyone watches from the fence.", "Which governing image does the speaker use?", "A garden", "A machine", "A war", "A river"),
         O("Put the steps in order.", ["Choose one governing image", "Keep it consistent through the section", "Check that it fits your message and values"]),
         YOUR("Choose an abstract idea (trust, time, debt). Write a two-sentence metaphor that keeps one image."),
     ]),
    ("ps-a-structure", "rhetoric", "Structures that move people", "PS-A-04",
     "Some structures are designed to persuade. In problem-solution, you show a problem, prove its cause and present your solution. The motivated sequence adds steps: get attention, show the need, satisfy it with your plan, help people visualize the result and call for action. Choose the structure that fits the audience: a skeptical audience needs the problem proved; a friendly audience needs a clear action. Use signposts so listeners know where they are.",
     [
         READ(PLAN, "Which step asks the audience to picture the result?", "The fourth", "The first", "The second", "The fifth"),
         READ(PLAN, "What is the final step?", "Request a single concrete action from the audience", "Show the problem", "Present the solution", "Get attention"),
         C("What does the problem-solution structure do first?", "Shows a problem", "Gives the solution", "Asks for a vote", "Tells a joke"),
         C("What does a skeptical audience need most?", "The problem proved", "A long song", "A short title", "A joke"),
         C("What does a friendly audience need most?", "A clear action", "More doubt", "A long delay", "A new topic"),
         M("Match each step with its job.", [["Attention", "make them listen"], ["Need", "show why it matters"], ["Visualization", "help them picture the result"]]),
         O("Put the motivated sequence in order.", ["Get attention", "Show the need", "Satisfy it with your plan", "Visualize the result", "Call for action"]),
         TF("True or false: The best structure is the same for every audience.", "False"),
         F("Type the missing word: End with a call to ___.", "action"),
         W("Build the sentence.", "Let me show you the problem first.", "never", "shows"),
         LISTEN("Picture next summer: children walking to school on safe paths, with no traffic jam at the gate. That future is possible if you vote yes on Tuesday.", "Which step is this?", "Visualization and call for action", "Attention", "Need", "Introduction"),
         YOUR("Outline a five-step talk persuading your neighbors to start a community garden. One short sentence per step."),
     ]),
    ("ps-a-room", "command", "Read and adapt to the room", "PS-A-05",
     "Great speakers watch their audience and adjust. If faces look confused, slow down and add an example. If people look bored, shorten a section or ask a question. If time is cut, know your must-say points and drop the rest. Prepare modular sections so you can skip or expand. Check the room before you begin: where you will stand, how the microphone works and whether everyone can see.",
     [
         C("What should you do if faces look confused?", "Slow down and add an example", "Speak faster", "Ignore it", "Raise your voice"),
         C("What should you do if people look bored?", "Shorten a section or ask a question", "Add more slides", "Repeat the same point", "Apologize for ten minutes"),
         C("What if your time is cut?", "Say the must-say points and drop the rest", "Speak twice as fast", "Cancel", "Read everything"),
         C("Why prepare modular sections?", "You can skip or expand them", "They look neat", "They hide notes", "They replace the ending"),
         C("What should you check before you begin?", "The space, microphone and sightlines", "Your horoscope", "The weather in another city", "The audience's ages only"),
         M("Match each sign with a response.", [["Confused faces", "slow down and give an example"], ["Restless audience", "shorten or ask a question"], ["Less time", "keep must-say points"]]),
         O("Put the adjustment in order.", ["Notice the signal from the audience", "Decide what to change", "Change it smoothly and continue"]),
         TF("True or false: A good speaker keeps the plan exactly even when the room is lost.", "False"),
         F("Type the missing word: Know your must-say ___.", "points"),
         W("Build the sentence.", "I will skip the next section.", "never", "skipped"),
         LISTEN("I see some puzzled faces. Let me give you an example. Last year, a small shop cut its energy bill by a quarter by changing only its lights.", "Why does the speaker give an example?", "The audience looks confused", "The talk is over", "To fill time", "To end the talk"),
         YOUR("Write the three points you would never cut from a ten-minute talk on your favorite topic, if you were given only three minutes."),
     ]),
    ("ps-a-hostile", "command", "Difficult audiences and interruptions", "PS-A-06",
     "Interruptions and hostility test your poise. Stay calm and lower, not raise, your voice. Acknowledge the feeling without accepting the attack: “I hear that frustration, and I'd like to answer it.” Answer the real question behind the shout. If the person keeps disrupting, offer a limit: “I'll take that after the talk so everyone can hear the rest.” Do not mock or argue: the room is watching how you treat people.",
     [
         READ(HECKLE, "Which reply is the most effective?", "I hear that frustration. Let me tell you how this plan came from residents' suggestions.", "Sit down.", "That is not true at all.", "Be quiet or leave."),
         C("What should you do with your voice?", "Lower it and stay calm", "Raise it", "Whisper", "Shout back"),
         C("Which phrase acknowledges the feeling?", "I hear that frustration.", "You are wrong.", "That is absurd.", "No comment."),
         C("What is a polite limit?", "I'll take that after the talk so everyone can hear the rest.", "Stop talking.", "I refuse to listen.", "You will be removed."),
         C("Why should you avoid mocking an interrupter?", "The room watches how you treat people", "It wastes time", "It shortens the talk", "It is cold"),
         M("Match each move with its purpose.", [["Acknowledge", "calms the moment"], ["Answer the real question", "shows respect"], ["Set a limit", "protects the talk"]]),
         O("Put the response in order.", ["Stay calm", "Acknowledge the feeling", "Answer the real question or set a limit"]),
         TF("True or false: Arguing with an interrupter usually calms the room.", "False"),
         F("Type the missing word: Lower your ___, do not raise it.", "voice"),
         W("Build the sentence.", "I hear that frustration.", "never", "hears"),
         LISTEN("I understand that people feel unheard. That is why we held three public meetings. I'll take specific questions on that after the talk so I can finish the plan for everyone.", "What does the speaker do?", "Acknowledges and sets a limit", "Mocks the person", "Ignores the room", "Ends the talk"),
         YOUR("Write what you would say if someone shouts that your plan is a waste of money."),
     ]),
    ("ps-a-ceremony", "command", "Toasts, tributes and keynotes", "PS-A-07",
     "Ceremonial speaking has its own rules. A toast is short: say who you honor, tell one specific story or quality, and raise the glass with a clear last line. A tribute names what the person gave to others. A keynote opening should connect the theme to the audience's lives. Be warm but never cruel; humor should include the honoree, not mock them. Practice the timing: ceremonial speeches are remembered for brevity.",
     [
         C("How long should a toast usually be?", "Short", "Twenty minutes", "An hour", "As long as possible"),
         C("What should a toast include?", "Who you honor, one specific story and a clear last line", "A list of all duties", "A complaint", "A long history"),
         C("Which line is a good toast ending?", "To Maria: may we all be as generous as she is.", "And that is all I have to say, really.", "Please excuse the mistakes.", "Anyway, thanks."),
         C("What should humor do in a tribute?", "Include the honoree, not mock them", "Mock the honoree", "Replace the praise", "Avoid warmth"),
         C("Which opening works for a keynote?", "Connecting the theme to the audience's lives", "A long apology", "A list of rules", "A quiet cough"),
         M("Match each occasion with its aim.", [["Toast", "honor in a few words"], ["Tribute", "name what the person gave"], ["Keynote opening", "link the theme to the audience"]]),
         O("Put the toast in order.", ["Say who you are honoring", "Tell one specific story", "Raise the glass with a clear last line"]),
         TF("True or false: Ceremonial speeches are remembered for brevity.", "True"),
         F("Type the missing word: Humor should ___ the honoree.", "include", "honor"),
         W("Build the sentence.", "Please raise your glasses to Maria.", "never", "glass"),
         LISTEN("When our team lost the contract, Maria stayed late for a week, rewrote the proposal, and won it back. To Maria, who never gives up.", "What is the specific story?", "Maria saved the contract by working late", "Maria lost the contract", "Maria joined late", "Maria moved away"),
         YOUR("Write a 30-second toast for a friend's graduation with one specific story and a last line."),
     ]),
    ("ps-a-online", "command", "Speak on camera and online", "PS-A-08",
     "On camera your face and voice are all there is. Place the camera at eye level and look at the lens when you make a key point. Light your face from the front. Use a slightly more energetic voice than usual, because screens flatten energy. Keep gestures within the frame and slides simple. Test sound first, silence notifications, and plan how to recover if the connection fails: say where you will resume.",
     [
         C("Where should the camera be?", "At eye level", "Below your chin", "Above your head", "Behind you"),
         C("Where should you look to make a key point?", "At the lens", "At the screen corner", "At your notes", "At your hands"),
         C("Why use slightly more energy online?", "Screens flatten energy", "Microphones are broken", "Rooms are cold", "Slides are small"),
         C("How should you light your face?", "From the front", "From behind", "Not at all", "From the floor"),
         C("What should you do before you start?", "Test sound and silence notifications", "Skip the test", "Open many apps", "Cancel the camera"),
         M("Match each habit with its benefit.", [["Look at the lens", "feels like eye contact"], ["Front light", "shows your face"], ["Test sound", "avoids delays"]]),
         O("Put the setup in order.", ["Place the camera at eye level", "Check light and sound", "Silence notifications and begin"]),
         TF("True or false: You should plan how to recover if the connection fails.", "True"),
         F("Type the missing word: Look at the ___ to make eye contact.", "lens", "camera"),
         W("Build the sentence.", "Can everyone hear me clearly?", "never", "hears"),
         LISTEN("If I drop out, please wait a moment. When I come back I will start again from the second point, so you will not miss anything.", "What does the speaker prepare?", "A way to recover", "A new topic", "A joke", "A longer talk"),
         YOUR("Write a four-point checklist for a five-minute video talk you will record tonight."),
     ]),
]

if __name__ == "__main__":
    add_stage("public-speaker", STAGE, LESSONS, "Advanced", SOURCES)
