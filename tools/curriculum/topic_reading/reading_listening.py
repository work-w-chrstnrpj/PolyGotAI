"""Reading & Listening Comprehension reading pages (Phase 13). Original wording, written 2026-10-26."""

READING = {
'Gist and supporting details': [
    ('Reading for the gist',
     'The gist is the big idea of a text: what it is mostly about. Before looking for small facts, read the whole text once, quickly, and ask, "What is this about?" '
     'Look at the title, any pictures, and the first and last sentences; they often carry the main idea. '
     'Do not stop for every new word. Most unknown words do not change the gist, and stopping breaks your understanding of the whole. '
     'When you have finished, try to say the gist in one short sentence. If you can, you are ready to look for details.',
     [('Text', 'The café on Mill Street is closing after 40 years. The owner, now 70, wants to retire.', 'A short news item.'),
      ('Gist', 'A long-running café is closing because its owner is retiring.', 'The big idea in one sentence.'),
      ('Not the gist', 'The café is on Mill Street.', 'True, but only a detail.')]),
    ('Finding details',
     'A detail is a single fact: a name, a place, a time, a number, a reason. To find details efficiently, read the question first, so you know what you are looking for. '
     'The question word tells you what kind of detail to find: who → a person, when → a time, where → a place, how many → a number, why → a reason (often after because). '
     'Then go back to the text and look for words that match or mean the same as the question. Check the sentences around your answer to make sure it fits exactly.',
     [('Question', 'When does the new library open?', '"When" → look for a time or date.'),
      ('In the text', 'The library will open its doors on 3 September.', 'The detail answers "when".'),
      ('Paraphrase', 'Q: Why did the match stop? Text: Play ended early because of heavy rain.', 'The text uses different words; "because" signals the reason.')]),
],
'Scanning and listening for key words': [
    ('Scanning for facts',
     'Scanning means moving your eyes quickly over a text to find one specific piece of information, without reading every word. '
     'It is how you use a timetable, a menu, a phone list or a search result. '
     'Before you scan, decide exactly what you are looking for and what it will look like: a capital letter for a name, digits for a number or price, a day or month name for a date. '
     'Let your eyes move down the page looking for that shape, then stop and read carefully around it.',
     [('Look for digits', 'Find the price of the museum ticket: look for £ or numbers.', 'Numbers stand out.'),
      ('Look for capitals', 'Find the name of the manager: look for capitalised words.', 'Names start with capitals.'),
      ('Look for day names', 'Which day is the market? Scan for Monday… Sunday.', 'Days are easy to spot.')]),
    ('Listening for key words',
     'When you listen, you usually cannot go back, so you cannot catch every word. Focus on the key words: names, numbers, places, times and main verbs. '
     'In English, these content words are stressed — said louder and longer — while small words like the, a, to and of are quick and quiet. '
     'Before listening, predict what you might hear from the situation: at a train station, expect platforms, times and destinations. '
     'While listening, ask yourself: who is speaking, what do they want, and when or where?',
     [('Stressed words', 'The TRAIN to LEEDS leaves from PLATFORM FOUR.', 'The stressed words carry the message.'),
      ('Predict', 'Doctor’s surgery: appointment, time, name, symptoms.', 'Know what to listen for.'),
      ('Ignore weak words', '"…the… to… from…" can be missed without losing the meaning.', 'Focus on the content words.')]),
],
'Main ideas and context clues': [
    ('Finding the main idea',
     'The main idea is the single most important point of a text or paragraph; the other sentences support it with details, examples and reasons. '
     'Writers often state it in the first sentence, sometimes in the last. To check, ask: which idea are most of the sentences about? '
     'Be careful not to choose an idea that is too narrow (a single detail) or too broad (bigger than the text). '
     'A good main-idea sentence could be the title of the paragraph.',
     [('Paragraph', 'Cycling to work saves money. It also keeps you fit, and it is often faster than driving in traffic.', 'Several supporting points.'),
      ('Main idea', 'Cycling to work has several benefits.', 'Covers all the details.'),
      ('Too narrow', 'Cycling saves money.', 'Only one of the points.')]),
    ('Guessing meaning from context',
     'When you meet a new word, keep reading — the words around it often explain it. Look for clues: a synonym or definition ("enormous, or very large"), '
     'an opposite ("Unlike his outgoing sister, Tom is shy"), an example ("citrus fruits, such as lemons and oranges"), or the general situation. '
     'Also notice the type of word: is it a noun, a verb, an adjective? Then guess the meaning and check that the sentence still makes sense. '
     'Use a dictionary afterwards for words you meet often or that seem essential.',
     [('Definition clue', 'The building is fragile — easily broken — so please don’t touch the walls.', 'The meaning is given.'),
      ('Contrast clue', 'Unlike the noisy city, the village was tranquil.', 'tranquil is the opposite of noisy.'),
      ('Example clue', 'She loves legumes, such as beans, lentils and peas.', 'The examples explain the word.')]),
],
'Signals, facts and opinions': [
    ('Signal words',
     'Signal words are small words and phrases that show how ideas connect and what is coming next. '
     'Addition: and, also, in addition. Contrast: but, however, although. Reason: because, since. Result: so, therefore, as a result. '
     'Example: for example, such as. Sequence: first, then, finally. Conclusion: in conclusion, overall. '
     'Noticing them helps you predict the next idea and follow the writer’s or speaker’s thinking. A however often signals that the most important point is about to come.',
     [('Contrast', 'The hotel was cheap. However, it was far from the beach.', 'However signals a different point.'),
      ('Result', 'The road was icy, so the school closed.', 'so shows the result.'),
      ('Example', 'Many sports, such as rowing and cycling, use the legs.', 'such as introduces examples.')]),
    ('Fact or opinion?',
     'A fact can be checked and shown to be true or false: "The bridge is 300 metres long." '
     'An opinion expresses what someone thinks, feels or believes, and people can reasonably disagree: "The bridge is beautiful." '
     'Signals of opinion include I think, I believe, in my view, should, must, and judging words such as best, worst, beautiful, terrible, important. '
     'Many texts mix the two. Separating them helps you decide what to accept as information and what to treat as someone’s view.',
     [('Fact', 'The film lasts two hours and ten minutes.', 'Can be checked.'),
      ('Opinion', 'The film is far too long.', 'A judgement others may not share.'),
      ('Mixed', 'At two hours and ten minutes, the film is far too long.', 'A fact used to support an opinion.')]),
],
'Skimming and paragraph structure': [
    ('Skim, then scan',
     'Skimming and scanning are both fast reading skills, used for different purposes. '
     'Skimming means reading quickly to get the general idea: look at the title, headings, the first sentence of each paragraph and the last paragraph. '
     'Scanning means searching for one specific fact — a name, a number, a date — without reading everything. '
     'Use them together: skim first to understand what the text is and where things are, then scan the right section for the detail you need. '
     'Neither involves stopping at every unknown word.',
     [('Skim', 'Read title + first lines: “A guide to visiting the old town.”', 'General idea in seconds.'),
      ('Scan', 'Find the opening time: look for numbers and “a.m.”', 'One specific fact.'),
      ('Combine', 'Skim to find the “Tickets” section, then scan it for the student price.', 'Skim to locate, scan to find.')]),
    ('Paragraphs and topic sentences',
     'A well-written paragraph usually develops one main idea. The topic sentence states that idea, most often at the start. '
     'The other sentences support it with details, examples, reasons or explanations, and a final sentence may conclude or lead to the next paragraph. '
     'Reading the first sentence of each paragraph lets you follow a long text quickly. '
     'To check your understanding, try to label each paragraph in a few words: "causes", "an example", "the solution".',
     [('Topic sentence', 'Bees are essential for farming.', 'States the main idea.'),
      ('Support', 'They pollinate about a third of the crops we eat, including apples and almonds.', 'Gives evidence.'),
      ('Label', 'Paragraph 2: why bees matter.', 'A short summary of the paragraph.')]),
],
'Reference and sequence': [
    ('Reference words',
     'Writers avoid repeating nouns by using reference words: pronouns (it, they, them, he, she), demonstratives (this, that, these, those) and phrases such as the former, the latter, such. '
     'To understand a text, you need to know what each one points to. Usually it refers to the nearest earlier noun that fits in number and meaning. '
     'This and that can refer to a whole idea, not just a noun. If you are unsure, replace the reference word with the noun or idea and check that the sentence still makes sense.',
     [('Pronoun', 'The club is free. It meets every Monday.', 'It = the club.'),
      ('Whole idea', 'Prices rose by 20%. This caused protests.', 'This = the rise in prices.'),
      ('Check by replacing', 'The students thanked the teachers because they had helped them.', 'they = the teachers; them = the students.')]),
    ('Following a sequence',
     'Instructions, processes and stories often use sequence words to show order: first, then, next, after that, before, while, finally. '
     'They help you picture what happens and in which order. When following instructions, number the steps as you read. '
     'Be careful with before and after: in "Before you serve it, add salt", adding salt comes first even though it is mentioned second. '
     'Time expressions — at first, later, the next day, eventually — do the same job in stories.',
     [('Steps', 'First, open the app. Then tap “Settings”. Finally, choose “Language”.', 'Clear order.'),
      ('Before', 'Before you leave, turn off the lights.', 'Turning off the lights happens first.'),
      ('Story time', 'At first she hated the city. Eventually, it felt like home.', 'Shows change over time.')]),
],
'Numbers and spoken instructions': [
    ('Numbers, times and prices',
     'Numbers go by fast in speech, and some sound alike. Listen for the stress: thirTEEN, fourTEEN, fifTEEN have stress at the end; THIRty, FORty, FIFty at the start. '
     'Times can be said in different ways: "half past four", "four thirty", "sixteen thirty". '
     'Prices are often said without the currency word for the cents: "twelve fifty" usually means 12.50. '
     'Write numbers as digits while you listen, and check any important number by repeating it back.',
     [('Stress', 'The bus leaves at four-fif-TEEN (4:15), not FOR-ty (4:40).', 'Stress tells you which number.'),
      ('Time', '“A quarter to nine” = 8:45.', 'Learn the common ways to say times.'),
      ('Check', '“Sorry — was that thirteen or thirty?”', 'Ask when it matters.')]),
    ('Following spoken instructions',
     'To follow spoken instructions, listen for three things: action verbs (turn, press, open, wait, take), order words (first, then, after) and numbers or places. '
     'Make very short notes as you listen: "L, 2nd st, R at bank". '
     'If you miss a step, ask politely: "Sorry, could you repeat the last part?" '
     'At the end, repeat the whole set back to check: "So I turn left, walk two streets, then turn right at the bank?" This catches mistakes before you act on them.',
     [('Action + order', '“Go straight on, then take the second left.”', 'Verbs and order words carry the instruction.'),
      ('Short notes', 'straight → 2nd L → bank on R', 'Key words and symbols only.'),
      ('Check back', 'So it’s the second left, and the bank is on the right?', 'Confirms the instructions.')]),
],
'Speakers, purpose and notes': [
    ('Who is speaking and why?',
     'Before and during listening, ask: Who is speaking? Who are they speaking to? What do they want? The answers help you predict words and understand meaning. '
     'A shop assistant, a friend and a news reader all speak differently. Listen for clues in the greeting, the vocabulary and the tone — friendly, formal, worried, annoyed. '
     'The purpose may be to inform, ask, invite, complain, apologise, persuade or thank. '
     'Understanding the purpose often helps you guess the parts you did not catch.',
     [('Situation', '“Good morning, Westbank Hotel, how can I help?”', 'A receptionist on the phone.'),
      ('Purpose: complain', '“I’m afraid the room is still not clean, and this is the second time.”', 'Tone and words show a complaint.'),
      ('Purpose: invite', '“We’re having a few people round on Saturday — fancy coming?”', 'Informal invitation.')]),
    ('Taking quick notes',
     'You cannot write every word while listening, so note only the key words: names, numbers, places, dates and actions. '
     'Use short forms and symbols: Mon, 3pm, →, @, +, ↑ (increase), ✗ (no). Leave out small words such as a, the and is. '
     'After listening, use your notes to write one or two full sentences while your memory is fresh. '
     'If you miss something, leave a gap and keep listening; trying to catch up on one word can make you miss the next three.',
     [('Spoken', '“The meeting has been moved from Monday to Wednesday at three, in Room 12.”', 'Full message.'),
      ('Notes', 'mtg Mon → Wed 3pm, Rm 12', 'Key facts with symbols.'),
      ('Rewritten', 'The meeting is now on Wednesday at 3 p.m. in Room 12.', 'Full sentence from the notes.')]),
],
'Inference, purpose and tone': [
    ('Reading between the lines',
     'Writers do not always say everything directly. An inference is a conclusion you reach from clues in the text combined with what you already know. '
     'If a story says that a man shook rain from his umbrella and stamped his wet boots, you can infer that it is raining, even though the text never says so. '
     'Good inferences fit all the clues and do not go beyond them. Ask: what clues support this? Is there another possible explanation?',
     [('Clues', 'The shop sign says “Back in 10 minutes”, but letters are piling up behind the door.', 'Evidence in the text.'),
      ('Inference', 'The owner has been away for longer than planned.', 'A conclusion from the clues.'),
      ('Too far', 'The owner has moved to another country.', 'Goes beyond the evidence.')]),
    ('Purpose and tone',
     'Every text has a purpose: to inform, persuade, entertain, instruct or warn. Tone is the writer’s attitude towards the subject and the reader: neutral, enthusiastic, critical, humorous, worried. '
     'Word choice is the main clue. "A tragic mistake" is critical; "a few changes" is neutral; "an incredible opportunity" is enthusiastic. '
     'Asking "Why was this written, and by whom?" helps you decide how far to trust it: an advertisement wants you to buy; a report wants you to understand.',
     [('Neutral', 'The council approved the new car park on Tuesday.', 'Facts without judgement.'),
      ('Critical', 'The council rushed through yet another ugly car park.', 'Loaded words show disapproval.'),
      ('Persuasive purpose', 'Don’t miss out — book your place today!', 'Wants the reader to act.')]),
],
'Arguments and summaries': [
    ('Following an argument',
     'An argument has a claim (what the writer wants you to accept), reasons and evidence, and often a counterclaim (the other side) with a response. '
     'Find the claim first; it is often in the introduction or conclusion. Then find the reasons: words like because, since and therefore signal them. '
     'Words like but, however, although and some people argue signal an opposing view. '
     'A strong text deals fairly with the other side. Finally, judge: do the reasons and evidence actually support the claim?',
     [('Claim', 'Cities should plant more trees.', 'What the writer wants you to accept.'),
      ('Reason + evidence', 'Trees cool streets: shaded areas can be up to 5°C cooler in summer.', 'Support for the claim.'),
      ('Counterclaim', 'Some argue trees are expensive to maintain; however, they reduce air-conditioning costs.', 'The other side and a response.')]),
    ('Summarising a text',
     'A summary gives the main points of a text in your own words, much shorter than the original. '
     'Find the main idea and the two or three most important supporting points. Leave out examples, repetition and minor details, and do not add your own opinion. '
     'Use reporting phrases to show these are someone else’s ideas: "The writer argues that…", "According to the report…". '
     'A good summary makes sense to someone who has not read the original.',
     [('Reporting phrase', 'The article argues that four-day weeks increase productivity.', 'Shows whose idea it is.'),
      ('Key support', 'It cites a trial in which output rose while sick days fell.', 'One main piece of evidence.'),
      ('Not a summary', 'I think four-day weeks are a great idea.', 'Adds opinion instead of summarising.')]),
],
'Attitude and lecture notes': [
    ('Listening for attitude',
     'In speech, how something is said can change its meaning. Stress shows what the speaker thinks is important or contrasting: '
     '"I didn’t say HE took it" (someone else did) is different from "I didn’t SAY he took it" (I suggested it). '
     'Intonation matters too: a falling tone usually signals certainty or a statement; a rising tone often signals a question, doubt or an unfinished thought. '
     'Tone of voice can even reverse the words: "Oh, great" said in a flat voice often means the opposite. Listen to the music of speech as well as the words.',
     [('Stress', 'I wanted the BLUE one.', 'Contrast: not another colour.'),
      ('Falling tone', 'It’s finished.', 'Certain statement.'),
      ('Sarcasm', '“Oh, wonderful,” he said, looking at the flat tyre.', 'Words and situation do not match.')]),
    ('Taking notes from a talk',
     'In talks and lectures, speakers signal structure: "There are three reasons…", "Let me give an example…", "The key point is…", "To sum up…". '
     'Listen for these signposts and use them to organise your notes. '
     'Try a simple layout: main points on the left, details and examples on the right; or short numbered lists. Mark questions you want to ask with a "?". '
     'Review your notes the same day, fill in gaps and add a one-line summary at the top while you still remember.',
     [('Signpost', '“The second factor is cost.”', 'Write “2. cost” as a new heading.'),
      ('Two columns', 'Main: 2. cost | Detail: prices up 30% since 2020', 'Points and support separated.'),
      ('Review', 'Summary: three factors — time, cost, staff.', 'Added the same day.')]),
],
'Comparing sources and bias': [
    ('Comparing two sources',
     'When two texts describe the same event, compare them carefully. Which facts do both include? Which appear in only one? Do the numbers match? '
     'Is one more detailed, more recent or more careful in its language? Do they use different words for the same thing? '
     'Differences can come from different sources, different times or different attitudes. '
     'Start by listing the facts both agree on, then examine the differences and look for a reason for each.',
     [('Agree', 'Both reports say the fire started at 2 a.m. in the kitchen.', 'Shared facts are more reliable.'),
      ('Differ', 'Source A says 12 people were evacuated; Source B says 20.', 'A difference to investigate.'),
      ('Different words', 'One says “protesters”, the other “rioters”.', 'Word choice reveals attitude.')]),
    ('Spotting loaded words and bias',
     'Bias is a leaning towards one side. Loaded words carry strong feelings: "The council forced through a pointless lane" is more loaded than "The council approved a new lane". '
     'Other signs of bias include one-sided evidence, missing voices (only one side is quoted) and phrases like obviously or everyone knows. '
     'A biased text is not necessarily false, but you should check its claims in another source. '
     'A useful exercise: replace loaded words with neutral ones and see what facts remain.',
     [('Loaded', 'Greedy landlords are squeezing helpless tenants.', 'Strong emotional words.'),
      ('Neutral', 'Rents have risen by 8% this year.', 'The fact without feeling.'),
      ('Missing voice', 'Only the developer is quoted in the article about the new towers.', 'One side is absent.')]),
],
'Implication and rhetorical moves': [
    ('Irony, understatement and implication',
     'Writers often mean more, less or the opposite of what they literally say. Irony says one thing while signalling another: '
     'praising a train company’s "reliable" timetable and then advising readers to allow an extra hour. '
     'Understatement deliberately plays something down: "a slight delay" for a day of chaos. '
     'Implication leaves a conclusion unsaid for the reader to draw. To read these, notice the gap between the words and the situation, and ask what the writer wants you to conclude.',
     [('Irony', 'Another “quick” meeting — only three hours this time.', 'Says quick, means slow.'),
      ('Understatement', 'The hurricane caused some damage to the roof.', 'Plays down a serious event.'),
      ('Implication', 'The new manager has many talents. Punctuality is not one of them.', 'Implies he is often late.')]),
    ('Rhetorical moves in a text',
     'Persuasive texts use recognisable moves. A false dilemma offers only two options. A loaded contrast sets "us" against "them" or good against bad. '
     'Rhetorical questions imply an answer. Repetition builds emotion. Appeals to authority or fear can stand in for evidence. '
     'Spotting a move does not mean the argument is wrong; it means you should look past the style to the evidence. '
     'Ask: what am I being asked to believe or do, and what support is given?',
     [('False dilemma', 'Either we build the road, or the town dies.', 'Ignores other options.'),
      ('Rhetorical question', 'Who would trust a company like that?', 'Implies "nobody".'),
      ('Appeal to fear', 'Without this product, your family is at risk.', 'Fear instead of evidence.')]),
],
'Evidence and synthesis': [
    ('Evaluating evidence and methods',
     'When a text cites research, ask how the study was done. Who took part, how many, and how were they chosen? Was there a comparison (control) group? '
     'Who paid for it, and could that influence the result? Does the conclusion go further than the data allows? '
     'A claim that one thing causes another needs more than a correlation. Treat a single study with caution and look for others that repeat the result. '
     'The question is not whether a study is perfect, but how far its conclusion can be trusted.',
     [('Sample', 'The study surveyed 30 volunteers from one gym.', 'Small and not representative.'),
      ('Control group', 'Half the patients got the drug; half got a placebo.', 'Allows a fair comparison.'),
      ('Overreach', 'Data: coffee drinkers live longer. Headline: coffee makes you live longer.', 'Correlation reported as cause.')]),
    ('Synthesising several sources',
     'Synthesis means building one view from several sources, rather than summarising each in turn. '
     'Group the sources by idea: where do they agree, where do they disagree, and do they answer different questions? Weigh their quality: sample, method, date. '
     'Then state a position that accounts for all of them, and attribute each point: '
     '"Surveys of managers suggest gains, but a controlled trial with call-centre staff found losses, so the effect may depend on the type of work."',
     [('Agreement', 'Three studies found that remote work reduced commuting stress.', 'Combines shared findings.'),
      ('Disagreement', 'However, two found lower team collaboration.', 'Notes the conflict.'),
      ('Position', 'Remote work seems to help individuals but may cost teamwork.', 'One view that fits all the sources.')]),
],
'Long talks and reduced speech': [
    ('Long talks and digressions',
     'In a long lecture or talk, speakers digress, go back, qualify and repeat. Follow the main thread by listening for signposts: '
     '"To return to my main point…", "The second issue is…", "In other words…". '
     'Separate main points from asides: "By the way…", "That reminds me…" often mark a digression. '
     'Keep a running outline, leave gaps for what you miss, and use the speaker’s summary at the end to check and complete it. If you lose the thread, do not panic — rejoin at the next signpost.',
     [('Digression marker', '“By the way, I once met her in Lisbon…”', 'A side story, not a main point.'),
      ('Return marker', '“Anyway, back to the main question.”', 'The thread resumes.'),
      ('Restatement', '“In other words, cost is the real problem.”', 'Repeats the key idea.')]),
    ('Fast, reduced and accented speech',
     'Natural speech is not careful dictionary speech. Words blend and reduce: going to becomes "gonna", want to becomes "wanna", did you sounds like "didja", and of often becomes a short "uh". '
     'Small function words are weak and fast, while content words carry the stress. '
     'Accents vary in vowels, consonants and rhythm, so familiar words can sound new. '
     'To train your ear, listen to the same short clip several times, check with captions afterwards, and focus first on the stressed words. Context often fills the gaps.',
     [('Reduced', '“Whaddaya wanna do?” = What do you want to do?', 'Words blend together.'),
      ('Weak forms', '“A cup of tea” sounds like “a cuppa tea”.', 'of reduces to a short sound.'),
      ('Train', 'Listen once for the gist, again for stressed words, then check captions.', 'A step-by-step method.')]),
],
'Debates and shifts in register': [
    ('Following a debate or interview',
     'In debates and interviews, speakers disagree, interrupt and talk over each other. Keep track of who holds which position: note each speaker’s claim in a word or two. '
     'Listen for stance markers that show attitude: frankly, I’d argue that, to be fair, with respect. '
     'Notice when a speaker concedes ("I accept that…"), deflects (answers a different question) or changes the subject. '
     'Do not confuse a speaker repeating an opponent’s view ("You say that…") with their own. Afterwards, summarise each position in one sentence.',
     [('Stance marker', '“Frankly, the plan won’t work.”', 'Shows strong personal view.'),
      ('Concession', '“I accept the costs are high, but…”', 'Admits a point before disagreeing.'),
      ('Reported view', '“You claim the trains are faster — they’re not.”', 'The first part is the opponent’s view.')]),
    ('Tone shifts and register',
     'Skilled speakers and writers often change tone within one piece: from formal to personal, serious to playful, distant to direct. '
     'Notice the signals: shorter sentences, everyday vocabulary, contractions, humour, or direct address to "you". '
     'A shift often marks something important — moving from policy language to a personal story can signal the emotional centre of a speech. '
     'Ask what the shift does for the audience. Reading tone means hearing how the speaker stands towards the topic and the listener.',
     [('Formal', '“The proposal requires further consideration.”', 'Distant and impersonal.'),
      ('Shift to personal', '“But let me tell you about my father’s farm.”', 'Signals a turn to emotion.'),
      ('Direct address', '“You know this. You’ve felt it.”', 'Speaks straight to the listener.')]),
],
}
