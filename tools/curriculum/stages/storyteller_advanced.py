#!/usr/bin/env python3
"""Storytelling, Advanced stage (about C1-C2): 2 units x 4 lessons, added to track-storyteller.json.

Original wording and original sample stories. Ideas (layered structure, restraint, shaping true events, voice and space,
live adaptation, adapting traditional tales, stories at work, consent and respect) are standard storytelling-teaching
concepts; sources credited for ideas only. Run from the project root: python3 tools/curriculum/stages/storyteller_advanced.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from track_lib import C, TF, READ, LISTEN, W, F, O, M, YOUR, add_stage  # noqa: E402

SOURCES = [
    "Oral-storytelling traditions and public-domain folktale collections (structure ideas only; no text copied)",
    "Common storytelling-workshop practice: layering, restraint, shaping true events, consent and cultural respect (original wording)",
]

STAGE = {"id": "advanced", "title": "Advanced", "units": [
    {"id": "art", "title": "The art of the told story"},
    {"id": "practice", "title": "Tell it in the real world"},
]}

RESTRAINT = "When the letter came, my father read it twice, folded it into his pocket, and went out to fix the gate. It was not broken."
PERSONAL = "When I was twelve I lied to my teacher about a broken window. For years I told this story as a joke. Last spring I finally told my teacher the truth, and she remembered nothing at all."
TOLD = "The old tale says that a fox tricked a crow into dropping her cheese. In my retelling, the crow is a new employee and the fox is her manager."
PITCH = "Our customer, a nurse named Ana, used to spend an hour every night writing notes by hand. After she began using our app, she finished in ten minutes and had time to read to her children."

LESSONS = [
    ("st-a-layers", "art", "Layered tellings", "ST-A-01",
     "Experienced tellers often tell two stories at once: the surface events and a deeper meaning underneath. A story about repairing a boat can also be about forgiveness. Choose a central image that holds both layers and let the surface story carry the deeper one without explaining it. Use a frame, such as returning to one object at the start and end, to unify the telling. Trust the audience to feel the second layer.",
     [
         C("What is a layered telling?", "A story that works on the surface and carries a deeper meaning", "A very long story", "A story told twice", "A story with many characters"),
         C("What is a central image?", "An image that holds both layers", "The title", "The first line", "The audience's name"),
         C("Should you explain the deeper meaning?", "No, trust the audience to feel it", "Yes, in every paragraph", "Only in the title", "Always at the start"),
         C("What does a frame do?", "Unifies the telling by returning to an object or moment", "Hides the plot", "Lengthens the story", "Replaces the ending"),
         C("A story about repairing a boat could also be about what?", "Forgiveness", "Boat prices", "Weather", "Fishing licenses"),
         M("Match each element with its role.", [["Surface story", "the events"], ["Deeper layer", "the meaning underneath"], ["Central image", "holds both together"]]),
         O("Put the steps in order.", ["Find the deeper meaning", "Choose an image that holds both layers", "Tell the surface story without explaining the meaning"]),
         TF("True or false: Explaining the deeper meaning makes it stronger.", "False"),
         F("Type the missing word: A ___ returns to one image at the start and end.", "frame"),
         W("Build the sentence.", "The boat is also a story about forgiveness.", "never", "forgive"),
         LISTEN("Every Sunday my grandfather mended the same net. Some weeks there was nothing left to mend, and he mended it anyway. When he was gone, I found it hanging in the shed, and I understood what he had been doing all those years.", "What is the deeper layer?", "Care and love expressed through routine", "Net prices", "Fishing skill", "The weather"),
         YOUR("Choose an everyday object. Write three sentences of a surface story that carries a deeper meaning without naming it."),
     ]),
    ("st-a-restraint", "art", "Restraint and implication", "ST-A-02",
     "The strongest moments are often the quietest. Instead of saying that your father was afraid, show what he did: he read the letter twice and went out to fix a gate that was not broken. Implication lets the listener do the emotional work and makes the feeling theirs. Cut the sentence that tells the audience what to feel. Stop at the moment of greatest tension; silence is part of the telling.",
     [
         READ(RESTRAINT, "What does the father's action imply?", "The letter upset him, and he is hiding it.", "He enjoys fixing gates.", "The gate needed fixing.", "The letter was good news."),
         C("What is implication?", "Letting the audience infer a feeling from action", "Explaining each feeling", "Skipping the plot", "Using adjectives"),
         C("Which sentence uses restraint?", "He folded the letter into his pocket and went out to fix the gate.", "He was terribly afraid and sad.", "He felt a very big emotion.", "He was upset."),
         C("What should you cut?", "The sentence that tells the audience what to feel", "The action", "The setting", "The first line"),
         C("What can silence do?", "Hold the tension", "End the story", "Confuse people", "Replace words"),
         M("Match each telling with its approach.", [["He was afraid.", "tells"], ["His hands would not stop shaking the paper.", "shows"], ["He read it twice and went to fix the gate.", "implies"]]),
         O("Put the revision in order.", ["Find a line that names a feeling", "Replace it with an action or detail", "Pause after the key moment"]),
         TF("True or false: Naming the feeling always moves an audience more than an action.", "False"),
         F("Type the missing word: Let the audience do the ___ work.", "emotional"),
         W("Build the sentence.", "He fixed a gate that was not broken.", "never", "break"),
         LISTEN("She set the table for four, though she lived alone now. Then she stood very still, and put one plate back in the cupboard.", "What does the action imply?", "She misses someone", "She is hungry", "She is tidy", "She is angry at plates"),
         YOUR("Rewrite “She was nervous before the interview” as a two-sentence action that implies it."),
     ]),
    ("st-a-true", "art", "Shape a true story", "ST-A-03",
     "Personal stories are not simply what happened; you choose what to tell. Pick one change, such as the moment you stopped lying. Compress time and cut side events, but do not invent facts you present as true. Be honest about your own part, including mistakes; audiences trust a teller who does not make themselves the hero of every moment. Reflect briefly at the end on what you learned. If real people appear, consider how they would feel hearing it.",
     [
         READ(PERSONAL, "What change does the story center on?", "From hiding a lie to telling the truth", "From joking to crying", "From school to work", "From childhood to old age"),
         C("What should a personal story center on?", "One change", "Every event of the year", "A list of facts", "Other people's secrets"),
         C("What can you do with time?", "Compress it and cut side events", "Add false events", "Make it longer", "Invent proof"),
         C("What should you not do with facts?", "Invent them and present them as true", "Select among them", "Order them", "Cut them"),
         C("Why admit your own mistakes?", "Audiences trust a teller who is honest about them", "It makes the story shorter", "It hides the plot", "It prevents laughter"),
         M("Match each choice with its effect.", [["One change", "gives the story focus"], ["Compressed time", "keeps the pace"], ["Honest mistakes", "builds trust"]]),
         O("Put the shaping in order.", ["Choose the change that matters", "Cut events that do not serve it", "End with a brief reflection"]),
         TF("True or false: A personal story should include everything that happened.", "False"),
         F("Type the missing word: Do not ___ facts you present as true.", "invent"),
         W("Build the sentence.", "I told my teacher the truth.", "never", "tells"),
         LISTEN("What I did next was not heroic. I hid in the library for an hour. Eventually my brother found me, and said only, You can go back, and I did.", "How does the teller present themselves?", "Honestly, without making themselves the hero", "As the hero of the story", "As a villain", "As a stranger"),
         YOUR("Write the first two sentences of a true story about a mistake you made, with one change in focus."),
     ]),
    ("st-a-body", "art", "Body, space and presence", "ST-A-04",
     "Your body tells the story too. Use space: give each character or place a spot on the stage and return to it, so the audience always knows who is speaking. Use stillness: a long pause with a still body can be stronger than movement. Let your eyes look at where the character would be. Keep gestures small and meaningful; a hand lifting a pretend cup says more than waving. Breathe from low in the body to keep your voice steady.",
     [
         C("Why give each character a spot in space?", "The audience knows who is speaking", "It uses more space", "It decorates the stage", "It hides the story"),
         C("What can stillness do?", "Make a moment powerful", "Confuse the story", "Replace words always", "End the telling"),
         C("Where should your eyes look when a character speaks to another?", "Where that character would be", "At your feet", "At the clock", "At your notes"),
         C("What kind of gesture works best?", "Small and meaningful", "Large and constant", "Random", "Hidden"),
         C("What helps keep the voice steady?", "Breathing from low in the body", "Holding your breath", "Speaking faster", "Whispering"),
         M("Match each tool with its effect.", [["A spot for each character", "clear speakers"], ["Stillness", "emphasis"], ["A small gesture", "meaning without distraction"]]),
         O("Put the preparation in order.", ["Decide where each character stands", "Practice the shifts between them", "Add stillness before key moments"]),
         TF("True or false: Big gestures on every line make a telling stronger.", "False"),
         F("Type the missing word: Breathe from ___ in the body.", "low"),
         W("Build the sentence.", "The old woman always stands on the left.", "never", "standing"),
         LISTEN("When the king speaks, I stand tall at the right and look up. When the child answers, I move to the left, bend my knees and look up at the king.", "How does the teller show who is speaking?", "By moving between spots and changing posture", "By shouting", "By using props", "By changing the story"),
         YOUR("Plan the spots and postures for two characters in a story about a meeting between a child and a grandparent."),
     ]),
    ("st-a-live", "practice", "Respond to a live audience", "ST-A-05",
     "A told story is a conversation with the audience. Watch for signals: leaning in means you have them; checking phones means you are losing them. Adjust your pace, shorten a detour or add a vivid detail. If something unexpected happens, such as a noise, acknowledge it briefly and return to the story. Keep an extra short ending ready for when time runs out. Leave a little space for laughter, and wait until it fades before continuing.",
     [
         C("What does an audience leaning in suggest?", "You have their attention", "They are leaving", "They are asleep", "They disagree"),
         C("What can you do if people check their phones?", "Shorten a detour or add a vivid detail", "Stop the story", "Speak louder only", "Apologize"),
         C("What should you do after an unexpected noise?", "Acknowledge briefly and return", "Ignore it forever", "Stop the telling", "Blame the audience"),
         C("Why have a short ending ready?", "Time may run out", "It looks neat", "It replaces the plot", "It hides the middle"),
         C("What should you do after laughter?", "Wait until it fades", "Talk over it", "Stop", "Repeat the joke"),
         M("Match each signal with a response.", [["Leaning in", "continue as planned"], ["Phones out", "shorten or sharpen"], ["A loud noise", "acknowledge and return"]]),
         O("Put the live adjustment in order.", ["Notice the audience's signals", "Adjust pace or length", "Return to the story with a clear line"]),
         TF("True or false: A teller should ignore the audience's signals.", "False"),
         F("Type the missing word: Wait until the laughter ___.", "fades"),
         W("Build the sentence.", "I will shorten this part.", "never", "short"),
         LISTEN("Well, that was a loud truck. It sounds like the story has a soundtrack tonight. Now, where were we? The boy had just reached the bridge.", "What does the teller do?", "Acknowledges the noise and returns to the story", "Stops the story", "Blames the audience", "Changes the plot"),
         YOUR("Write a short line you could say after a loud interruption to return smoothly to your story."),
     ]),
    ("st-a-retell", "practice", "Retell and adapt traditional tales", "ST-A-06",
     "Traditional tales belong to communities. You can retell them, but tell them with care. Keep the tale's core: what it is about and what changes. Adapt the setting, the characters and the language so they speak to your audience: a fox and a crow can become a manager and a new employee. Credit the source when you know it, and avoid presenting a sacred or culturally restricted story as your own entertainment without permission. Say what is yours and what is the tradition's.",
     [
         READ(TOLD, "What has the teller adapted?", "The setting and the characters", "The core idea", "The moral", "The animals' names only"),
         C("What should stay when you adapt a tale?", "The core: what it is about and what changes", "Nothing", "Only the title", "The setting"),
         C("What can you adapt?", "Setting, characters and language", "The meaning completely", "Credit", "Permission"),
         C("What should you do with the source?", "Credit it when you know it", "Hide it", "Claim it as yours", "Delete it"),
         C("What should you avoid without permission?", "Telling sacred or restricted stories as entertainment", "Telling any story", "Using animals", "Using humor"),
         M("Match each step with its example.", [["Keep the core", "someone is tricked by flattery"], ["Adapt the setting", "an office instead of a forest"], ["Credit the source", "this tale comes from an old collection"]]),
         O("Put the steps in order.", ["Understand the tale's core", "Adapt setting and characters for your audience", "Credit the source and say what is yours"]),
         TF("True or false: Every traditional story is open for any use.", "False"),
         F("Type the missing word: Credit the ___ when you know it.", "source"),
         W("Build the sentence.", "This tale comes from an older tradition.", "never", "traditions"),
         LISTEN("This tale is very old. I have changed the place and the names, but the heart of it, that flattery can make us foolish, is the same as in the original.", "What did the teller keep?", "The core idea", "The setting", "The names", "The ending date"),
         YOUR("Choose a folktale you know. Write how you would keep its core and adapt its setting, in three sentences."),
     ]),
    ("st-a-work", "practice", "Stories at work", "ST-A-07",
     "A story can make a case more memorable than data. A customer story needs a real person, a clear problem, a change and a result with a number: “Ana used to spend an hour on notes. Now it takes ten minutes.” Keep it short, true and specific. Get the person's permission to share their story. Close by linking the story to the decision you want from the audience.",
     [
         READ(PITCH, "What is the measurable result?", "Notes now take ten minutes instead of an hour.", "Ana reads to her children.", "Ana is a nurse.", "The app has a name."),
         C("What does a customer story need?", "A real person, a problem, a change and a result", "A joke and a song", "A long history of the company", "A list of features"),
         C("What should you get before sharing someone's story?", "Their permission", "Their address", "Their password", "A gift"),
         C("How should you close a business story?", "By linking it to the decision you want", "By changing the subject", "By apologizing", "By silence"),
         C("Which result is strongest?", "Notes dropped from one hour to ten minutes.", "People liked it a lot.", "It was nice.", "Customers were happy."),
         M("Match each part with an example.", [["Person", "Ana, a nurse"], ["Problem", "an hour of handwritten notes"], ["Result", "ten minutes and time for her children"]]),
         O("Put the story in order.", ["Introduce the person", "Show the problem and the change", "Give the result and link to the decision"]),
         TF("True or false: A made-up customer story presented as real is honest.", "False"),
         F("Type the missing word: Get the person's ___ to share their story.", "permission"),
         W("Build the sentence.", "Notes used to take an hour.", "never", "uses"),
         LISTEN("Before the app, Ana spent an hour on notes each night. Now she finishes in ten minutes. That is fifty minutes back for each of our nurses, which is why I am asking you to fund the roll-out.", "How does the speaker end?", "By linking the result to a request", "By changing the topic", "By telling a joke", "By apologizing"),
         YOUR("Write a three-sentence customer story with a real-sounding problem, a change and a number."),
     ]),
    ("st-a-ethics", "practice", "Whose story is it?", "ST-A-08",
     "Stories involve people. Before you tell a story with real people in it, ask: Is it mine to tell? Would they be hurt or exposed? Can I change names and identifying details? When the story is about someone else's pain, let them speak for themselves where possible, or ask for their consent. Avoid stereotypes: give characters from other cultures the same depth you give your own. Tell stories that leave people with dignity.",
     [
         C("What should you ask before telling a story with real people?", "Is it mine to tell?", "Is it long?", "Is it funny?", "Is it new?"),
         C("What can you change to protect someone?", "Names and identifying details", "The facts of the harm", "The conclusion only", "Nothing"),
         C("What should you do about someone else's pain?", "Ask their consent or let them speak for themselves", "Tell it without asking", "Make it funny", "Exaggerate"),
         C("How should you portray characters from other cultures?", "With the same depth as your own", "As stereotypes", "As villains", "As background"),
         C("What should a story leave people with?", "Dignity", "Fear", "Shame", "Nothing"),
         M("Match each question with its concern.", [["Is it mine to tell?", "ownership"], ["Could they be hurt or exposed?", "harm"], ["Have I asked their consent?", "respect"]]),
         O("Put the checks in order.", ["Ask whether the story is yours to tell", "Consider harm and exposure", "Ask consent or change identifying details"]),
         TF("True or false: Stereotypes are fine if the story is entertaining.", "False"),
         F("Type the missing word: Ask their ___ before telling someone's story.", "consent", "permission"),
         W("Build the sentence.", "I changed her name to protect her.", "never", "changing"),
         LISTEN("This story is about my friend's illness. I asked her first, and she said I could tell it if I changed the city and her name, because she wants the lesson shared but not her identity.", "What did the teller do before telling?", "Asked her permission", "Told it without asking", "Used her name", "Made it a joke"),
         YOUR("You want to tell a story about a family member's struggle. Write two questions you would ask them first."),
     ]),
]

if __name__ == "__main__":
    add_stage("storyteller", STAGE, LESSONS, "Advanced", SOURCES)
