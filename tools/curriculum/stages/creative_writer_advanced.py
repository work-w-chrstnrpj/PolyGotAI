#!/usr/bin/env python3
"""Creative Writing, Advanced stage (about C1-C2): 2 units x 4 lessons, added to track-creative-writer.json.

Original wording and original sample passages. Ideas (narrative distance, non-linear structure, theme and motif, unreliable
narration, sentence rhythm, research, long-project routines, final self-editing) are standard craft concepts; sources
credited for ideas only. Run from the project root: python3 tools/curriculum/stages/creative_writer_advanced.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from track_lib import C, TF, READ, LISTEN, W, F, O, M, YOUR, add_stage  # noqa: E402

SOURCES = [
    "Public-domain essays and handbooks on style and fiction craft (concepts only; no text copied)",
    "Common creative-writing workshop practice: distance, structure, motif, irony, rhythm, revision (original wording)",
]

STAGE = {"id": "advanced", "title": "Advanced", "units": [
    {"id": "mastery", "title": "Master the craft"},
    {"id": "project", "title": "Finish a project"},
]}

CLOSE = "She stood at the window. The rain was cold. She felt the glass under her palm and thought, I have wasted all of it."
FAR = "That winter the town learned to live without the mill. Some left, some stayed, and the river kept its own counsel."
LIAR = "I have never lied to my sister, I told the inspector, and I held out my ink-stained hands as proof, as if honesty were a matter of clean fingers."
RHYTHM = "He ran. The street blurred, the lamps blurred, the faces at the windows blurred, until there was only the sound of his own breath and the certainty, long and slow and heavy, that he would not be caught."

LESSONS = [
    ("cw-a-distance", "mastery", "Narrative distance", "CW-A-01",
     "Narrative distance is how close the narrator stands to a character's mind. Close distance uses thoughts and sensations: “I have wasted all of it.” Far distance summarizes from above: “The town learned to live without the mill.” Move between them on purpose. Close distance builds feeling at key moments; far distance covers time and context quickly. A sudden jump you did not intend confuses readers.",
     [
         READ(CLOSE, "Which detail creates close distance?", "The direct thought: I have wasted all of it.", "She stood at the window.", "The rain was cold.", "The glass was there."),
         READ(FAR, "What kind of distance does this passage use?", "Far, summarizing the whole town", "Close, inside one mind", "Second person", "Dialogue"),
         C("What is narrative distance?", "How close the narrator stands to a character's mind", "How long the story is", "How far the setting is", "How loud the narrator is"),
         C("When is close distance most useful?", "For key moments of feeling", "For long time jumps", "For lists", "For titles"),
         C("When is far distance most useful?", "To cover time and context quickly", "To show a single thought", "To end a sentence", "To name a character"),
         M("Match each sentence with its distance.", [["The town learned to live without the mill.", "far, covering a community"], ["I have wasted all of it, she thought.", "close, inside a mind"], ["Years passed in a blur of work.", "far, covering time"]]),
         TF("True or false: An unintended sudden jump in distance can confuse readers.", "True"),
         F("Type the missing word: Close distance uses a character's thoughts and ___.", "sensations", "feelings"),
         W("Build the sentence.", "The narrator moves closer here.", "never", "close"),
         LISTEN("Nobody in the village spoke of the flood that year. Then Anna, alone at the table, felt the old fear rise in her chest like cold water.", "Where does the distance become close?", "At Anna at the table", "At the village", "At the flood", "At the year"),
         O("Put the steps in order.", ["Decide what the moment needs", "Choose a close or far distance", "Revise any jump you did not intend"]),
         YOUR("Write one sentence in far distance and one in close distance about the same event: a train leaves a station."),
     ]),
    ("cw-a-structure", "mastery", "Beyond three acts", "CW-A-02",
     "Chronological order is only one choice. A frame story wraps a tale inside another situation. A braided structure alternates two timelines. A fragmented structure presents pieces that the reader assembles. Each choice creates questions: what does the reader know first? Choose a structure that serves your theme, and make the connections between parts clear enough that readers feel guided, not lost.",
     [
         C("What is a frame story?", "A tale wrapped inside another situation", "A story about picture frames", "A story with no end", "A story in a single sentence"),
         C("What is a braided structure?", "Alternating two timelines", "A story told in one line", "A story with no characters", "A list"),
         C("What does a fragmented structure ask of the reader?", "To assemble pieces", "To skip reading", "To rewrite it", "To read backward only"),
         C("What is a reason to choose a non-chronological structure?", "It serves the theme or the questions you want the reader to ask", "It is easier", "It is shorter", "It hides the plot"),
         C("What must you provide in a complex structure?", "Clear connections between parts", "More confusion", "Fewer words", "No endings"),
         M("Match each structure with a use.", [["Frame story", "a tale told inside another situation"], ["Braided", "two timelines side by side"], ["Fragmented", "pieces the reader assembles"]]),
         O("Put the choice in order.", ["Identify the theme", "Choose a structure that serves it", "Check that the reader can follow the connections"]),
         TF("True or false: Chronological order is the only possible structure.", "False"),
         F("Type the missing word: A ___ story wraps one tale inside another.", "frame"),
         W("Build the sentence.", "The two timelines meet at the end.", "never", "timeline"),
         LISTEN("The novel moves between a daughter in the present and her mother as a young woman. Each chapter ends on an image that the next chapter, in the other time, echoes.", "What structure is this?", "Braided", "Frame story", "Fragmented", "Chronological"),
         YOUR("Outline a short story told with a braided structure: name the two timelines and the image where they meet."),
     ]),
    ("cw-a-motif", "mastery", "Theme and motif", "CW-A-03",
     "Theme is the underlying idea a story explores, such as loyalty or loss. A motif is an image, sound or object that returns and gathers meaning: a broken clock, a door left open. Do not state the theme; let the motif carry it. Introduce the motif early, vary it with each return, and let its final appearance change its meaning. If a motif appears only once, it is a detail, not a motif.",
     [
         C("What is a motif?", "An image or object that returns and gathers meaning", "A single detail that never returns", "A character's name", "The title"),
         C("What is theme?", "The underlying idea a story explores", "The first sentence", "The setting only", "A rhyme"),
         C("How should a theme be handled?", "Let the motif carry it instead of stating it", "State it in the first line", "Hide it completely", "Repeat it in every paragraph"),
         C("What makes a motif effective?", "Each return adds or changes meaning", "It never changes", "It appears once", "It is explained"),
         C("What is an object that appears only once?", "A detail", "A theme", "A motif", "A frame"),
         M("Match each item with its role.", [["Theme", "the underlying idea"], ["Motif", "a returning image"], ["Detail", "a single specific touch"]]),
         O("Put the steps in order.", ["Choose a motif that connects to the theme", "Introduce it early", "Change its meaning with each return"]),
         TF("True or false: A good writer announces the theme in a speech by a character.", "False"),
         F("Type the missing word: A ___ returns and gathers meaning.", "motif"),
         W("Build the sentence.", "The broken clock returns at the end.", "never", "clocks"),
         LISTEN("In the first scene the clock on the wall is broken, and nobody notices. In the middle it is broken and everyone avoids looking at it. In the last scene, someone finally winds it, and the room goes quiet.", "How does the motif change?", "From ignored to avoided to repaired", "It stays the same", "It disappears", "It becomes a person"),
         YOUR("Choose a motif (a door, a river, a coat). Write three sentences showing it at the start, middle and end of a story."),
     ]),
    ("cw-a-unreliable", "mastery", "Unreliable narrators and irony", "CW-A-04",
     "An unreliable narrator is one whose account the reader cannot fully trust, because of bias, ignorance, self-deception or deliberate lies. The reader senses the gap between what the narrator says and what the facts show. That gap is dramatic irony. To build it, give the narrator a motive for bending the truth and plant small signals: contradictions, defensive overstatements, details the narrator does not understand. Do not announce the lie; let the reader find it.",
     [
         READ(LIAR, "What suggests the narrator may be unreliable?", "The over-eager proof of honesty with ink-stained hands", "The mention of an inspector", "The mention of a sister", "The word ink"),
         C("What is an unreliable narrator?", "One whose account cannot be fully trusted", "A narrator who is late", "A narrator who is a child", "A narrator in third person"),
         C("What is dramatic irony?", "The reader knows more than the narrator says", "A joke", "A long speech", "A cliff"),
         C("Which signal suggests unreliability?", "Defensive overstatement", "A short sentence", "A plain description", "A chapter title"),
         C("Should the writer announce that the narrator lies?", "No, let the reader find it", "Yes, in the first line", "Yes, in a footnote", "Always"),
         M("Match each signal with its effect.", [["Contradiction", "makes the reader doubt"], ["Defensive overstatement", "suggests something to hide"], ["A detail the narrator misreads", "creates irony"]]),
         O("Put the steps in order.", ["Give the narrator a motive", "Plant small signals", "Let the reader discover the gap"]),
         TF("True or false: An unreliable narrator always tells outright lies.", "False"),
         F("Type the missing word: The gap between words and facts creates ___ irony.", "dramatic"),
         W("Build the sentence.", "I have never lied to anyone, he said.", "never", "lies"),
         LISTEN("I am perfectly calm, said Edith, for the fourth time, and she gripped the arms of the chair until her knuckles went white.", "What does the detail suggest?", "She is not calm", "She is happy", "She is tired", "She is cold"),
         YOUR("Write four sentences from a narrator who says he is not jealous, with two signals that show he is."),
     ]),
    ("cw-a-rhythm", "project", "Sentence rhythm and syntax", "CW-A-05",
     "Variety makes prose alive. Short sentences strike; long sentences accumulate, carry feeling or hold a moment open. Use parallel structure to build momentum, and a sudden short sentence to break it. Place the important word at the end, where the stress falls. Read aloud and mark where your breath stops. If every sentence has the same length and shape, rhythm dies; if every sentence is a flourish, nothing stands out.",
     [
         READ(RHYTHM, "How does the final sentence work?", "It accumulates clauses to hold a long, heavy feeling.", "It is a single word.", "It is a question.", "It is dialogue."),
         C("What do short sentences do?", "Strike and speed up", "Hold a moment open", "Describe weather", "Replace verbs"),
         C("What do long sentences do?", "Accumulate, carry feeling or hold a moment", "Always confuse", "Always speed up", "End a story"),
         C("Where does stress fall in a sentence?", "At the end", "At the beginning only", "On the first word", "Nowhere"),
         C("What happens if all sentences have the same length?", "Rhythm dies", "Rhythm improves", "The story ends", "Nothing"),
         M("Match each technique with its effect.", [["Parallel structure", "builds momentum"], ["Short sentence after long ones", "breaks the pattern"], ["Important word last", "puts stress where it lands"]]),
         O("Put the revision in order.", ["Read the passage aloud", "Mark where the rhythm is flat", "Vary sentence length and place key words at the end"]),
         TF("True or false: Reading aloud helps you hear rhythm.", "True"),
         F("Type the missing word: Put the important word at the ___.", "end"),
         W("Build the sentence.", "He ran, and he did not look back.", "never", "runs"),
         LISTEN("The house was empty. Rooms stretched out in silence, one after another, each holding the shape of the family that used to live there. She waited. Nothing.", "Which sentence breaks the rhythm?", "Nothing.", "The house was empty.", "She waited.", "Rooms stretched out."),
         YOUR("Write six sentences about a storm arriving, varying length on purpose. Underline the shortest."),
     ]),
    ("cw-a-research", "project", "Research without losing the story", "CW-A-06",
     "Good fiction feels true. Research the details your story depends on: a profession, a place, a period. Interview people, read primary sources, visit if you can. But research serves the story. Choose the few telling details, not everything you learned. Check facts that a reader could easily check, and ask someone from the community you write about to read it. If you are not sure you can portray a group fairly, listen first and write with care.",
     [
         C("What is the purpose of research in fiction?", "To make the story feel true", "To fill the pages", "To avoid imagination", "To impress readers"),
         C("How many details should you use?", "The few telling ones", "Everything you learned", "None", "Only dates"),
         C("What helps with unfamiliar communities?", "Listening and asking someone from the community to read it", "Guessing", "Ignoring differences", "Using stereotypes"),
         C("Which source is primary?", "A letter written at the time", "A summary written later", "A film adaptation", "A rumor"),
         C("Why check easily verifiable facts?", "Readers will notice errors", "Facts are boring", "It makes the story longer", "It adds characters"),
         M("Match each step with its purpose.", [["Interview", "learn lived detail"], ["Read primary sources", "get the period right"], ["Cut extra facts", "keep the story moving"]]),
         O("Put the research in order.", ["Decide what the story depends on", "Gather facts and telling details", "Use only what serves the story"]),
         TF("True or false: A writer should include every fact learned.", "False"),
         F("Type the missing word: Choose the telling ___.", "details"),
         W("Build the sentence.", "I interviewed a nurse for this scene.", "never", "interview"),
         LISTEN("I spent a week reading letters from the 1920s. I learned a hundred facts, but I used only three in the scene: the smell of coal, a ration of tea, and a coat with a missing button.", "What did the writer do with the research?", "Chose a few telling details", "Used all of it", "Ignored it", "Copied the letters"),
         YOUR("List three details you would research for a scene in a hospital kitchen at night, and one you would leave out."),
     ]),
    ("cw-a-draft", "project", "Draft a long project", "CW-A-07",
     "A long project needs routines. Set a regular time and a realistic target, such as 300 words a day. Write the first draft without stopping to polish; leave notes for yourself in brackets. Outline loosely: know the next three scenes. Keep a project file with names, timeline and open questions. Finish the draft before you rewrite; the shape appears only when there is something to shape. Reward finished pages, not perfect ones.",
     [
         C("What helps with a long project?", "A regular time and a realistic target", "Waiting for inspiration", "Editing each line twice", "Starting many projects at once"),
         C("What should you do in the first draft?", "Keep going without polishing", "Polish each sentence", "Stop at each error", "Delete the early chapters"),
         C("What should you leave in the draft when you are unsure?", "Notes in brackets", "Nothing", "Empty pages", "Random words"),
         C("What belongs in a project file?", "Names, timeline and open questions", "Only the title", "Only the ending", "Only a photo"),
         C("Why finish the draft before you rewrite?", "The shape appears only when there is something to shape", "It is faster in all cases", "Rewriting is forbidden", "It hides errors"),
         M("Match each habit with its benefit.", [["Daily target", "builds momentum"], ["Brackets", "keeps you moving"], ["Project file", "tracks facts and questions"]]),
         O("Put the process in order.", ["Set a routine and target", "Write the draft without polishing", "Rewrite after the draft is finished"]),
         TF("True or false: A perfect first draft is the goal.", "False"),
         F("Type the missing word: Reward finished pages, not ___ ones.", "perfect"),
         W("Build the sentence.", "I write three hundred words a day.", "never", "writes"),
         LISTEN("My rule is simple. Three hundred words every morning before I check my phone. If I do not know a name or a date, I write it in brackets and keep going. I fix the brackets at the end.", "What does the writer do about missing details?", "Writes them in brackets and continues", "Stops writing", "Deletes the scene", "Asks a friend each time"),
         YOUR("Plan your own writing routine in four sentences: time, target, what you do when stuck, and when you rewrite."),
     ]),
    ("cw-a-final", "project", "The final edit and sharing", "CW-A-08",
     "Before you share a finished piece, do three passes. First pass: structure and scenes; cut what does not move the story. Second: sentences; strengthen verbs, remove repetition, vary rhythm. Third: proofreading; check spelling, punctuation and consistency of names and facts. Read the piece aloud and on a different screen or on paper. Then choose where to share it: a trusted reader, a workshop, a contest, a magazine. Read the rules of each place carefully and follow them.",
     [
         C("What is the first pass?", "Structure and scenes", "Spelling only", "Titles only", "Fonts"),
         C("What is the second pass?", "Sentences: verbs, repetition and rhythm", "Page numbers", "Margins", "Cover design"),
         C("What is the third pass?", "Proofreading: spelling, punctuation, consistency", "Deleting chapters", "Changing the plot", "Adding scenes"),
         C("How can you see errors more easily?", "Read aloud and on paper or a different screen", "Read faster", "Read once", "Never read again"),
         C("What should you do with a contest or magazine?", "Read and follow its rules", "Ignore its rules", "Send anything", "Wait years"),
         M("Match each pass with its focus.", [["First", "structure"], ["Second", "sentences"], ["Third", "proofreading"]]),
         O("Put the finish in order.", ["Revise structure", "Polish sentences", "Proofread, then share"]),
         TF("True or false: Proofreading comes before structure.", "False"),
         F("Type the missing word: Read the ___ of each magazine carefully.", "rules", "guidelines"),
         W("Build the sentence.", "I proofread the whole story twice.", "never", "proofreads"),
         LISTEN("On the first pass I cut a whole scene because it did not move the story. On the second I replaced the weak verbs. On the third I fixed a name that changed spelling in chapter four.", "What did the third pass fix?", "A name that changed spelling", "A weak verb", "A scene", "The ending"),
         YOUR("Write a short submission note to a literary magazine for a 1,500-word story: title, genre and one line about the story."),
     ]),
]

if __name__ == "__main__":
    add_stage("creative-writer", STAGE, LESSONS, "Advanced", SOURCES)
