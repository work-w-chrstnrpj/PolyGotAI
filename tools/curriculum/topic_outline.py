"""Phase 13 editorial outline. Each topic gathers related micro-lessons, never learner data."""
# Non-grammar tracks retain their unit/stage order, with two broader lessons per unit.
TITLES = {
'business': ['Introductions and meetings','Emails and status updates','Structured answers: PREP and STAR','Plain language and feedback','Meetings and polite pushback','Data and escalation','Follow-up and networking','Calls and receiving feedback','Stakeholders and executive summaries','Requests and difficult conversations','Working across contexts','Crisis communication and tough questions'],
'copywriter': ['Benefits and the central message','Headlines and truthful claims','AIDA and calls to action','Tone and editing','Reader research and proof','Objections and stories','Emails and landing pages','Testing and honest urgency','Positioning and brand voice','Long copy and ethical persuasion','Taglines across cultures','Claims, disclosure and the brief'],
'creative-writer': ['Character and setting','Sensory detail: show and tell','Dialogue and point of view','Plot, beginnings and endings','Voice and specific detail','Figurative language and conflict','Subtext and pacing','Revision and feedback','Narrative distance and structure','Theme, motif and unreliable narration','Rhythm and research','Finishing and sharing a project'],
'debater': ['Claims, reasons and evidence','Argument structure and language','Rebuttal and fair representation','Logical traps and weighing arguments','Sources and numbers','Causation and analogy','Case structure and definitions','Questions, concessions and refutation','Warrants and burden of proof','Charity and the crux','Framing and layered rebuttal','Uncertainty and closing arguments'],
'journalist': ['News questions: the 5 Ws and H','Follow-ups, quotations and attribution','News structure, ledes and headlines','Facts, opinions and fair summaries','Verification and source agreements','Numbers and fair representation','Ledes, quotations and paraphrases','Clear sentences and corrections','Documents and data','Verification and accountability','Features and explanations','Privacy, ethics and fair comment'],
'negotiator': ['Persuasive appeals and audience','Pitches and ethical persuasion','Interests and offers','Concessions and polite refusals','Preparation and first offers','Trading and listening','Objections and boundaries','De-escalation and confirmation','Criteria and alternatives','Packages and counteroffers','Culture and pressure tactics','Authority and renegotiation'],
'public-speaker': ['Openings, closings and signposts','Rhythm, contrast and questions','Pause, stress and vocal variety','Body language and nerves','Audience, purpose and structure','Stories and language for the ear','Movement and slides','Questions and recovery','Credibility and rhetorical figures','Metaphor and speech structures','Adapting to difficult audiences','Ceremonies and online speaking'],
'reading-listening': ['Gist and supporting details','Scanning and listening for key words','Main ideas and context clues','Signals, facts and opinions','Skimming and paragraph structure','Reference and sequence','Numbers and spoken instructions','Speakers, purpose and notes','Inference, purpose and tone','Arguments and summaries','Attitude and lecture notes','Comparing sources and bias','Implication and rhetorical moves','Evidence and synthesis','Long talks and reduced speech','Debates and shifts in register'],
'storyteller': ['The moment and the story arc','Detail, hooks and endings','Voice and believable people','Audience awareness and rehearsal','Causality and character choices','Details, setup and payoff','Presence and story length','Callbacks and deliberate practice','Layers, restraint and implication','True stories and physical presence','Live audiences and traditional tales','Workplace stories and ownership'],
}

# Grammar is grouped by subject across the old stages: one Nouns lesson covers all kinds.
GRAMMAR = [
('starter','parts-of-speech','Nouns',['gram-s-nouns','gram-s-plurals','gram-f-noun-kinds','gram-f-quant']),
('starter','parts-of-speech','Pronouns',['gram-s-pronouns','gram-s-possessives','gram-f-pronoun-kinds']),
('starter','parts-of-speech','Articles and determiners',['gram-s-articles','gram-f-quantifiers']),
('starter','parts-of-speech','Adjectives and comparisons',['gram-s-adjectives','gram-f-adjective-order','gram-f-compare']),
('starter','parts-of-speech','Adverbs',['gram-s-adverbs','gram-f-adverb-kinds']),
('starter','parts-of-speech','Conjunctions and interjections',['gram-s-joiners','gram-sent-join']),
('starter','sentences','Sentence building',['gram-sent-subject','gram-sent-object','gram-sent-command']),
('starter','be-have-do','Be, have and do',['gram-be-amisare','gram-be-have','gram-be-do','gram-be-dont']),
('foundation','word-classes','Verbs',['gram-f-verb-kinds','gram-f-irregular','gram-f-phrasal','gram-i-gerund-infinitive']),
('foundation','forms','Prepositions',['gram-f-prep']),
('foundation','forms','Questions',['gram-f-questions']),
('foundation','sentence-parts','Phrases, clauses and sentence structures',['gram-f-phrase-clause','gram-f-clause-kinds','gram-f-sentence-structures','gram-f-sentence-purposes']),
('foundation','sentence-parts','Agreement and complete sentences',['gram-f-agreement','gram-f-fragments']),
('intermediate','tense-map','Tenses',['gram-f-past','gram-f-present','gram-f-future','gram-i-perfect','gram-i-pp','gram-i-past-continuous','gram-i-pp-continuous','gram-i-past-perfect','gram-i-future-forms','gram-i-tense-map']),
('intermediate','time','Modals',['gram-f-modal','gram-i-deduce','gram-a-hedge']),
('intermediate','time','Conditionals and wishes',['gram-i-cond','gram-a-hypo','gram-a-mixed-conditionals']),
('intermediate','complex','Relative and reduced clauses',['gram-i-relative','gram-a-participle']),
('intermediate','complex','Reported speech',['gram-i-reported']),
('intermediate','complex','Linking ideas and cohesion',['gram-i-link','gram-a-cohesion']),
('intermediate','punctuation','Punctuation',['gram-i-capitals-ends','gram-i-commas','gram-i-apostrophes','gram-i-colons-dashes','gram-i-quotes']),
('advanced','voice-mood','Active, passive and causative voice',['gram-i-passive','gram-a-causative']),
('advanced','voice-mood','Mood and emphasis',['gram-a-mood','gram-a-inversion']),
('advanced','style','Formal language and noun phrases',['gram-a-formal','gram-a-register','gram-a-noun']),
('advanced','common-errors','Confusable words',['gram-a-confusables','gram-a-tricky-pairs']),
('advanced','common-errors','Modifiers and parallel structure',['gram-a-modifiers','gram-a-parallel']),
]

# New applied tasks for topics that used to contain only one short lesson.
EXTRAS = {
'Prepositions': [
('Choose the sentence for an event on a particular day.', 'The workshop is on Friday.', ['The workshop is at Friday.','The workshop is in Friday.']),
('Choose the sentence for a clock time.', 'The doors open at nine.', ['The doors open on nine.','The doors open in nine.']),
('Choose the sentence for a month.', 'They travel in October.', ['They travel on October.','They travel at October.']),
('Choose the sentence that places the keys inside the bag.', 'The keys are in the bag.', ['The keys are above the bag.','The keys are beside the bag.']),
('Which phrase describes the space separating two houses?', 'between the houses', ['during the houses','until the houses']),
('Choose the sentence about a journey toward a destination.', 'We are going to the library.', ['We are going during the library.','We are going until the library.']),
],
'Questions': [
('Choose a question about a completed trip.', 'Where did you go?', ['Where did you went?','Where you did go?']),
('Ask about the owner of a coat.', 'Whose coat is this?', ['Who coat is this?','Whose is this coat belongs?']),
('Choose a question about a regular habit.', 'When does Lena work?', ['When does Lena works?','When Lena does work?']),
('Choose the yes/no question.', 'Are they ready?', ['They are ready.','They ready are.']),
('Ask about an amount of water.', 'How much water do we need?', ['How many water do we need?','How water much we need?']),
('Ask about the number of chairs.', 'How many chairs are there?', ['How much chairs are there?','How chairs many there are?']),
],
'Reported speech': [
('Yesterday Mina said, “I am tired.” Choose a report of her words.', 'Mina said that she was tired.', ['Mina said that I am tired.','Mina said that she were tired.']),
('Yesterday Jo said, “I can help.” Choose a report of those words.', 'Jo said that he could help.', ['Jo said that he could helps.','Jo said that he can helped.']),
('Report a question about a name.', 'She asked what my name was.', ['She asked what was my name.','She asked what my name did.']),
('Report the instruction “Please wait.”', 'He asked us to wait.', ['He asked us wait.','He asked that to wait us.']),
('Report “Do you work here?” as an indirect question.', 'She asked whether I worked there.', ['She asked did I work there.','She asked whether worked I there.']),
('Choose the reporting verb for words directed to a named listener.', 'Mina told Jo the news.', ['Mina said Jo the news.','Mina told to Jo the news.']),
],
}
