"""Journalist reading pages (Phase 13). Original wording, written 2026-10-26."""

READING = {
'News questions: the 5 Ws and H': [
    ('The 5 Ws and H',
     'Every news story answers six questions: Who? What? Where? When? Why? and How? '
     'Reporters use them as a checklist before writing and again before publishing. If one answer is missing, the reader will notice the gap, so go back and ask. '
     'Not every answer carries equal weight. In a fire, what happened and whether anyone was hurt matter most; in an election, who won. '
     'The most important answers belong in the first sentence. Why and how often take longer to find and may come later in the story, or in a follow-up. '
     'If an answer is not yet known, say so clearly rather than guessing.',
     [('Who and what', 'A 14-year-old student won the national science prize on Monday.', 'Who and what lead.'),
      ('Where and when', 'The ceremony took place at the City Museum in Leeds.', 'Place and time are precise.'),
      ('Why and how', 'Her project used old phone parts to measure air pollution.', 'Explains the achievement.')]),
    ('Open and closed questions',
     'A closed question can be answered in a word or two, often yes or no: "Was the school closed today?" "How many people were injured?" '
     'Closed questions are good for checking facts and pinning down details. '
     'An open question starts with what, how, why or tell me about, and invites a longer answer: "What happened when the alarm went off?" '
     'Open questions get stories, feelings and details you would never think to ask about. '
     'A good interview usually starts open, to let the person talk, and then uses closed questions to confirm names, numbers and times.',
     [('Open', 'What did you see when you arrived?', 'Invites a full account.'),
      ('Closed', 'Did the fire start before or after midnight?', 'Pins down one fact.'),
      ('Open to start', 'Tell me about the day the factory closed.', 'Lets the person choose what matters.')]),
],
'Follow-ups, quotations and attribution': [
    ('Follow-up questions',
     'A follow-up question builds on what the person has just said. It shows you are listening, and it often produces the best details. '
     'Useful follow-ups include "Can you give me an example?", "What happened next?", "Why was that important to you?" and "How did you feel at that moment?" '
     'Listen for vague words — a lot, soon, many, problems — and ask for specifics: "How many is a lot?" '
     'Do not move to your next prepared question if the answer opened a better one. Your list of questions is a guide, not a script.',
     [('Ask for specifics', '"You said there were problems — what kind of problems?"', 'Turns a vague word into facts.'),
      ('Sequence', '"And after the bus stopped, what did the driver do?"', 'Moves the story forward.'),
      ('Example', '"Can you tell me about one family you helped?"', 'Gets a human detail.')]),
    ('Quoting and attributing',
     'A direct quote uses a person’s exact words inside quotation marks. Attribution tells the reader who said them: "We will reopen on Monday," said Maria López, the school’s head teacher. '
     'Use said most of the time; it is neutral. Words like claimed, admitted or insisted suggest doubt or guilt, so use them only when they are accurate. '
     'Never change the words inside quotation marks. If you rephrase the idea in your own words, it is a paraphrase and takes no quotation marks, but it still needs attribution: '
     'López said the school would reopen on Monday. '
     'Give a person’s full name and role the first time, and usually the surname after that.',
     [('Direct quote', '"The bridge is safe to use," said engineer Tomás Reyes.', 'Exact words in quotation marks.'),
      ('Paraphrase', 'Reyes said the bridge was safe to use.', 'Same meaning, own words, still attributed.'),
      ('Loaded verb', 'Reyes claimed the bridge was safe.', '"Claimed" suggests doubt; use only if justified.')]),
],
'News structure, ledes and headlines': [
    ('The inverted pyramid',
     'Most news stories follow the inverted pyramid: the most important facts come first, followed by supporting details, background and less important information. '
     'The shape is an upside-down triangle — wide at the top with the key facts, narrow at the bottom. '
     'This structure serves readers who stop early: even after one paragraph, they know the news. It also helps editors, who can cut from the bottom without losing the core of the story. '
     'After the lede, add the next most important facts, then quotes, then context and background.',
     [('Top', 'Floods closed 12 schools in the northern district on Tuesday.', 'The key fact first.'),
      ('Middle', 'About 3,000 students were sent home. Officials expect schools to reopen on Thursday.', 'Supporting details.'),
      ('Bottom', 'The district last flooded in 2019, when the river rose two metres.', 'Background that can be cut if needed.')]),
    ('Headlines and ledes',
     'A headline is a short title that tells the main news and makes people want to read. News headlines use short, strong words, the present tense for past events, and often drop small words like the and a: '
     '"Storm closes city schools". '
     'The lede is the first sentence of the story. A news lede gives the most important facts — usually who, what, when and where — clearly, in about 25–35 words. '
     'Write the lede first; if you cannot, you may not yet know what the story is. The headline and lede must agree; a headline should never promise more than the story shows.',
     [('Headline', 'Council approves new cycle lanes', 'Present tense, no articles.'),
      ('Lede', 'The city council voted on Wednesday to build 20 kilometres of cycle lanes by 2027.', 'Who, what, when in one sentence.'),
      ('Overpromise', 'Cars banned from city centre!', 'Not true if only lanes are planned.')]),
],
'Facts, opinions and fair summaries': [
    ('Fact, opinion and doubt',
     'Reporters separate what is known from what someone thinks. A fact can be checked: a date, a vote count, a quote from a document. '
     'An opinion is a view or judgement: "The new law is unfair." In a news story, opinions belong to named sources, not to the reporter. '
     'When facts are not certain, choose careful words: according to, police said, may have, is believed to, has not been confirmed. '
     'Never present a guess as a fact. "The fire was caused by a cigarette" needs proof; "Fire officials said the fire may have started from a cigarette" reports what is known.',
     [('Fact', 'The bridge closed at 6 a.m. on Monday.', 'Checkable.'),
      ('Attributed opinion', '"This decision is a mistake," said opposition leader Rui Costa.', 'The opinion belongs to the source.'),
      ('Careful wording', 'The suspect is believed to have left the country, police said.', 'Uncertainty is clear.')]),
    ('Summarising a source fairly',
     'Journalists often summarise reports, speeches and studies. A fair summary keeps the original meaning while using fewer words of your own. '
     'Pick out the main points and the most important evidence. Do not add your opinion, and do not leave out facts that would change how readers understand it — such as a limitation the authors mention. '
     'Keep qualifiers: if a study says a drug "may reduce" symptoms, do not write that it "cures" them. '
     'Name the source clearly: "The report, published by the Health Ministry on Tuesday, says…".',
     [('Faithful', 'The study of 400 adults found that walking daily may lower blood pressure.', 'Keeps size and caution.'),
      ('Unfair', 'Walking cures high blood pressure, scientists say.', 'Drops "may" and overstates the finding.'),
      ('Includes limits', 'The authors said the results need to be tested in older people.', 'A limit that changes the meaning.')]),
],
'Verification and source agreements': [
    ('Checking facts with two sources',
     'A claim is much stronger when two independent sources support it. Independent means they did not get the information from each other or from the same original source. '
     'Always ask how a source knows: did they see it themselves, read it in a document, or hear it from someone else? First-hand information is stronger than second-hand. '
     'Tell readers how you know: "according to the police report", "said two witnesses who saw the crash". '
     'If you cannot confirm a detail, leave it out or clearly label it as unconfirmed. Being second with the right story is better than being first with the wrong one.',
     [('Independent', 'Both the hospital and the fire service confirmed four people were injured.', 'Two separate sources agree.'),
      ('Ask how', '"Did you see it yourself, or did someone tell you?"', 'Checks whether it is first-hand.'),
      ('Label', 'Local reports, which could not be independently confirmed, say the mayor will resign.', 'Honest about uncertainty.')]),
    ('On the record and off the record',
     'Tell sources how you will use what they say, and agree on the rule before the information is shared, not after. '
     'On the record means you can publish what they say and use their name. '
     'On background means you can use the information but must not name the person; you might describe them ("a senior official"). '
     'Off the record means you cannot publish the information at all; it may only guide your reporting. '
     'Named sources are best because readers can judge who is speaking. Use anonymous sources only when there is real risk to the person and a strong public interest, and explain why they are not named.',
     [('Agree first', '"Before we start — is this on the record?"', 'Sets the rule in advance.'),
      ('Background', 'A senior council official, who asked not to be named because the talks are private, said…', 'Explains the anonymity.'),
      ('Off the record', 'Information you may use to ask others, but not publish.', 'Guides reporting only.')]),
],
'Numbers and fair representation': [
    ('Reporting numbers with context',
     'A number alone says little. Add a comparison, a base and a source. "Robberies fell from 40 to 30" becomes much clearer with "in a city of 200,000" and with the trend over the last five years. '
     'Give a percentage only when the base is clear: a fall from 40 to 30 is 25%. Round when precision does not matter: "about 200,000", "nearly a third". '
     'Never report a small change as a big trend, and be careful with records and firsts. '
     'Always say where the numbers come from and over what period.',
     [('With base', 'Unemployment rose to 6.2%, up from 5.8% a year earlier, official figures show.', 'Comparison and source.'),
      ('Rounded', 'Nearly 9,000 people attended — about a third more than last year.', 'Easy to picture.'),
      ('Overstated', 'Crime soars as thefts rise from 3 to 5.', 'Too few cases for "soars".')]),
    ('Being fair and balanced',
     'Fair stories give the people involved a chance to respond. If you report a criticism of a person or organisation, contact them before publishing and include their answer, or say they did not respond. '
     'Use neutral verbs and words: said is fairer than claimed; avoid loaded words such as disaster, scandal or miracle unless a named source uses them. '
     'Balance does not mean treating two unequal positions as equal. If the evidence strongly supports one side, say so; giving equal space to a fringe view can mislead readers.',
     [('Right of reply', 'The company did not respond to requests for comment by Tuesday evening.', 'Shows they were asked.'),
      ('Neutral', 'The minister said the plan would save money.', 'Not "the minister boasted".'),
      ('Weighted', 'Almost all climate scientists agree; a small number disagree.', 'Reflects the real balance of evidence.')]),
],
'Ledes, quotations and paraphrases': [
    ('News ledes and feature ledes',
     'A news lede, also called a straight or hard lede, gives the main facts in one or two sentences: who, what, when and where. It suits urgent news. '
     'A feature lede may start with a person, a scene or a surprising detail to draw the reader in. It must then reach the point quickly in a "nut paragraph" that says why the story matters now. '
     'Choose the lede that fits the story: a factory fire needs a direct lede; a story about one family’s recovery from the fire can begin with a moment. '
     'Avoid opening with a question, a dictionary definition or the weather unless it truly matters.',
     [('News lede', 'A fire destroyed a furniture factory in Porto early on Sunday, leaving 80 workers without jobs.', 'Direct and factual.'),
      ('Feature lede', 'Every morning for 22 years, Rosa Lima unlocked the factory gate at 6:45. On Sunday, there was no gate to unlock.', 'Begins with a person and a moment.'),
      ('Nut paragraph', 'She is one of 80 workers now facing the town’s highest unemployment in a decade.', 'Says why it matters.')]),
    ('Quoting and paraphrasing well',
     'Use a direct quote when the words are vivid, emotional or important because of who said them. Use a paraphrase when the idea matters but the wording is dull or long. '
     'Never change the words inside quotation marks. A partial quote is allowed if it does not change the meaning: The mayor called the plan "a long-overdue fix". '
     'Place the attribution after the first sentence of a longer quote: "We need new equipment," Ortiz said. "The old playground is unsafe." '
     'Check every quote against your notes or recording before publishing.',
     [('Vivid quote', '"I heard the roof go, like a train passing overhead," said resident Ana Silva.', 'Words worth keeping exactly.'),
      ('Paraphrase', 'The director said the budget would be reviewed in the spring.', 'Dull wording summarised.'),
      ('Partial quote', 'The judge described the evidence as "overwhelming".', 'One powerful word quoted.')]),
],
'Clear sentences and corrections': [
    ('Writing clear news sentences',
     'News sentences are short, active and specific. Put the actor first: "The council closed the park" is clearer than "The park was closed by the council". '
     'Use plain words: use, not utilise; start, not commence; about, not approximately, when precision is not needed. '
     'Prefer the specific to the general: "three workers", not "several people"; "Tuesday", not "recently". '
     'Use the past tense for events that have happened, and keep one main idea per sentence. Cut words that add no facts, such as very, really and in order to.',
     [('Active', 'Police arrested two men on Friday.', 'Actor first, clear action.'),
      ('Specific', 'Six families lost their homes.', 'Not "a number of people were affected".'),
      ('Plain', 'The hospital will start building in May.', 'Not "Construction will commence".')]),
    ('Checking, correcting and headlines',
     'Before publishing, check names (spelling and titles), numbers, dates and quotes against your notes and documents. '
     'Read the headline last: does it match the story, or does it promise more than the facts show? '
     'If you find a mistake after publication, correct it quickly and plainly, and say what changed: "An earlier version of this story said 150 people attended. The correct number is 105." '
     'Do not hide or quietly change errors. Readers trust a newsroom that fixes its mistakes openly.',
     [('Name check', 'Is it “Katherine” or “Catherine” on her business card?', 'Names are the most common errors.'),
      ('Clear correction', 'Correction: an earlier version gave the wrong date for the vote. It was 4 June.', 'States the fix plainly.'),
      ('Headline check', 'Story: “may close”. Headline: “will close”.', 'The headline overstates the story.')]),
],
'Documents and data': [
    ('Following the documents',
     'Strong stories often rest on documents: budgets, contracts, court files, inspection reports, company accounts. Many are public records that you can request. '
     'Read the original, not someone’s summary. Note dates, names, amounts and signatures, and build a timeline. '
     'Ask what a document does not say: a missing year, a blank signature, a contract with no tender. '
     'When you request records, be specific and polite: the exact title, the date range and the office that holds them. Keep copies and note how and when you obtained each one.',
     [('Specific request', 'I am requesting all inspection reports for Riverside Care Home from January 2023 to June 2025.', 'Exact records and dates.'),
      ('Timeline', 'Contract signed 3 May; payment made 5 May; tender published 20 May.', 'The order of dates reveals a problem.'),
      ('What’s missing', 'The 2024 audit, required by law, is not in the file.', 'Absence can be the story.')]),
    ('Reading data with suspicion',
     'Numbers can mislead even when they are accurate. Adjust for size: spending that rises while the population grows may be falling per person. '
     'Know the difference between a mean (average) and a median (middle value): a few very high incomes pull the mean up, so the median often describes a typical person better. '
     'Ask how a survey chose its respondents: an online poll where anyone can vote shows only those who chose to answer. Report the margin of error for polls. '
     'Compare like with like, and ask for the full dataset when you can, not just the chart.',
     [('Per person', 'Spending rose 10%, but the population grew 15%, so spending per resident fell.', 'Adjusted for size.'),
      ('Median', 'The median salary is £28,000; the mean is £41,000 because of a few very high earners.', 'The median shows the typical worker.'),
      ('Self-selected', '80% of readers who answered our online poll want a new stadium.', 'Not a representative sample.')]),
],
'Verification and accountability': [
    ('Verifying images and online claims',
     'Viral images and posts can be old, edited or from somewhere else entirely. Check provenance: who first posted it, and when? '
     'Run a reverse image search to find earlier copies. Look for details you can confirm: street signs, shop names, weather, shadows, landmarks, language on posters. '
     'Contact the person who posted it and ask how they got it. Look for the same event in independent reports. '
     'If you cannot confirm it, label it clearly as unverified or leave it out. Speed is never a good reason to publish an unverified claim.',
     [('Reverse search', 'The “flood today” photo first appeared online in 2017.', 'An old image recycled.'),
      ('Details', 'The road signs in the video are in Portuguese, not Spanish.', 'Detail contradicts the claimed location.'),
      ('Label', 'This video, which we have not been able to verify, appears to show…', 'Honest labelling.')]),
    ('Asking accountability questions',
     'When a powerful person avoids a question, ask it again, precisely. Keep questions short, and use closed questions when you need a specific fact: "Was a public tender held — yes or no?" '
     'Do not accept a general statement as an answer; note it and return to your question. '
     'Use silence: after a short or evasive answer, wait. People often fill the silence with more information. '
     'In your story, quote both the exact question and the exact non-answer, so readers can judge. Stay courteous and firm; the goal is the answer, not a confrontation.',
     [('Closed and precise', 'Did your department know about the leak before 1 March?', 'One clear fact.'),
      ('Return to it', 'I understand safety is a priority. But did you know before 1 March?', 'Acknowledges, then repeats.'),
      ('Report the evasion', 'Asked three times whether the minister had seen the report, the spokesperson said only that “processes were followed”.', 'Readers can judge.')]),
],
'Features and explanations': [
    ('Structuring a long feature',
     'A long feature needs a clear design. Open with a scene or a person, then state the stakes in a nut paragraph: what is happening, why it matters now. '
     'Then move through sections: background, conflict, evidence, and what happens next. Braid the human story with the explanation, returning to the main person between sections so readers stay connected. '
     'Use subheadings or clear changes of scene. End with an image, moment or quote that echoes the opening, not with a summary. '
     'Cut anything that does not serve the central question.',
     [('Opening scene', 'At 5 a.m., the only light in the village is the bakery.', 'Puts the reader in a place.'),
      ('Return to the person', 'Back at the bakery, Joana counts the loaves: fewer each year.', 'Braids the human story through.'),
      ('Echo ending', 'At 5 a.m., the bakery light comes on again — for now.', 'Closes the circle.')]),
    ('Explaining complexity clearly',
     'Complex topics lose readers when the writer assumes knowledge. Define each technical term the first time you use it, in plain words. '
     'Give the simple version first, then add the detail readers need. Use one precise analogy, and check that it does not mislead. '
     'Use concrete examples and numbers people can picture: "enough water to fill 40 Olympic pools". Cut jargon, or explain it in a short clause. '
     'A good test: could a smart friend outside the field repeat your explanation correctly?',
     [('Define in passing', 'Inflation — the rise in prices over time — reached 7%.', 'Definition in a short clause.'),
      ('Simple first', 'The vaccine teaches the body to recognise the virus. Here’s how.', 'The core idea before the detail.'),
      ('Picture the number', '1 billion litres, about the volume of 400 Olympic pools.', 'Makes scale real.')]),
],
'Privacy, ethics and fair comment': [
    ('Ethics: harm, privacy and conflicts',
     'Journalists balance the public’s right to know against the harm a story may cause. Ask: is there a real public interest, or only curiosity? '
     'Could the story identify someone who should be protected, such as a child or a victim of crime? Have sources understood how their words will be used? '
     'Declare conflicts of interest: if you own shares in a company you cover, or a relative works there, tell your editor and step aside. Do not pay sources for information. '
     'The aim is to minimise harm without hiding the truth.',
     [('Public interest', 'The mayor’s use of public money is news; her children’s school grades are not.', 'Interest versus curiosity.'),
      ('Protect identity', 'A 15-year-old witness, who cannot be named, said…', 'Protects a minor.'),
      ('Conflict', 'I can’t cover this company — my brother is on its board.', 'Declares and steps aside.')]),
    ('Truth, opinion and fair comment',
     'Accuracy protects readers and writers. A true, well-sourced statement of fact is the strongest position a journalist can take. '
     'Opinion is different: label it clearly as opinion and base it on facts you state. '
     'Be especially careful with serious allegations: have documents or at least two reliable sources, give the person a chance to respond, and report their reply. '
     'When you report what an official or a court said, attribute it precisely. Make corrections promptly and visibly. '
     'Laws differ between countries; this is not legal advice, so follow your editor’s guidance.',
     [('Labelled opinion', 'Opinion: The council’s plan puts cars before children.', 'Clearly marked as a view.'),
      ('Based on facts', 'The plan adds 400 parking spaces and no new crossings.', 'Facts that support the view.'),
      ('Serious allegation', 'Two former employees and internal emails say… The company denies the claims.', 'Sources plus the reply.')]),
],
}
