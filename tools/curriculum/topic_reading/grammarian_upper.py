"""Grammarian reading pages, Intermediate and Advanced (Phase 13). Original wording, written 2026-10-26."""

UPPER = {
# ───────────────────────── Intermediate ─────────────────────────
'Tenses': [
    ('How English tenses work',
     'An English tense combines a time (past, present or future) with an aspect. The simple aspect sees an action as a complete fact or a habit. '
     'The continuous aspect (be + -ing) sees it as in progress at a moment. The perfect aspect (have + past participle) connects an earlier action to a later point. '
     'The perfect continuous combines both: an activity in progress up to a later point. Three times × four aspects gives the twelve tenses. '
     'You do not need all twelve equally. Most everyday English uses the present simple, present continuous, past simple, present perfect and will/going to. '
     'When choosing, ask two questions: When is it? How am I looking at it: as a fact, as something in progress, or as something connected to a later moment?',
     [('Simple: a fact', 'Water boils at 100 degrees.', 'Always true, so present simple.'),
      ('Continuous: in progress', 'Sorry, I can’t talk — I’m driving.', 'Happening now, so present continuous.'),
      ('Perfect: connected', 'I’ve lost my keys, so I can’t get in.', 'A past action with a result now.')]),
    ('Present simple or present continuous',
     'Use the present simple for habits, routines, permanent situations and facts: "She works in a bank." "The sun rises in the east." Add -s for he, she, it. '
     'Use the present continuous (am/is/are + -ing) for actions happening now or around now, and for temporary situations: "She’s working from home this week." '
     'Frequency words (always, usually, every day) often signal the simple; time words like now, at the moment, today and this week often signal the continuous. '
     'State verbs (know, like, want, believe, belong, seem) normally stay in the simple even when they are true now: "I know the answer", not "I’m knowing". '
     'The present continuous is also used for fixed future arrangements: "We’re meeting the client on Friday."',
     [('Routine', 'He usually takes the bus to work.', 'A habit, with usually.'),
      ('Temporary', 'He’s taking the train this week because his bike is broken.', 'Only for now, so continuous.'),
      ('State verb', 'This bag belongs to my sister.', 'belong is a state, so simple.')]),
    ('Past simple and past continuous',
     'The past simple describes finished actions at a finished time: "I called her yesterday." "They lived in Rome in 2015." '
     'Questions and negatives use did + base verb: "Did you see it?" "I didn’t go." '
     'The past continuous (was/were + -ing) describes an action in progress at a moment in the past: "At eight o’clock I was having dinner." '
     'The two are often used together: the continuous sets the background and the simple tells the shorter event that interrupted it. '
     '"I was walking home when it started to rain." Use while before the longer background action: "While I was cooking, the phone rang." '
     'Two past continuous actions with while show two things happening at the same time.',
     [('Finished past', 'We visited Kyoto three years ago.', 'ago marks a finished time.'),
      ('Background + event', 'She was reading when the lights went out.', 'Long action in progress, short action interrupts.'),
      ('Two at once', 'While he was washing up, I was drying.', 'Both actions in progress together.')]),
    ('Present perfect',
     'The present perfect (have/has + past participle) links the past to now. Use it for experiences in your life up to now, with no specific time: "I’ve been to Mexico." '
     'Use it for past actions with a present result: "She’s broken her arm" (it is still broken), and for situations that started in the past and continue now, with for and since: '
     '"We’ve lived here for six years / since 2020." For is a length of time; since is the starting point. '
     'Already, yet, just and ever are common with this tense: "Have you finished yet?" "I’ve just eaten." '
     'Do not use the present perfect with a finished time expression such as yesterday, last week or in 2019. Then use the past simple: "I saw it last week."',
     [('Experience', 'Have you ever tried Ethiopian food?', 'ever = at any time in your life up to now.'),
      ('For and since', 'She has worked here since March.', 'since marks the starting point.'),
      ('Present result', 'Someone has taken my chair!', 'The chair is gone now.')]),
    ('Present perfect or past simple?',
     'Ask whether the time is finished or still open. The past simple belongs to a finished time, stated or understood: "I lost my wallet on Tuesday." '
     'The present perfect looks at the past from now, with no finished time stated: "I’ve lost my wallet" (and I still don’t have it). '
     'News often starts with the present perfect and continues with the past simple once the time is fixed: '
     '"The prime minister has resigned. She announced it at a press conference this morning." '
     'Time expressions help: yesterday, ago, last year and in 2018 go with the past simple; for, since, ever, never, yet, so far and this week (if it is not over) go with the present perfect. '
     'American English often uses the past simple with just, already and yet: "Did you eat yet?"',
     [('Open time', 'I’ve written three emails this morning.', 'It is still morning, so the period is open.'),
      ('Finished time', 'I wrote three emails yesterday.', 'yesterday is finished.'),
      ('News, then detail', 'A new bridge has opened. It cost £40 million.', 'Present perfect for news, past simple for the details.')]),
    ('Perfect continuous tenses',
     'The present perfect continuous (have/has been + -ing) stresses an activity that has been going on up to now, often with how long, for or since: '
     '"I’ve been waiting for forty minutes." It can also explain a present situation: "Your eyes are red — have you been crying?" '
     'Compare it with the present perfect simple, which stresses the result or the number completed: "I’ve read three chapters" (result) versus "I’ve been reading all afternoon" (activity). '
     'The past perfect (had + past participle) shows that one past action happened before another: "When we arrived, the film had already started." '
     'The past perfect continuous (had been + -ing) shows how long something was in progress before a past moment: "She had been working there for ten years when she left."',
     [('Activity up to now', 'We’ve been looking for a flat since January.', 'The search is still going on.'),
      ('Earlier past', 'By the time I got to the shop, it had closed.', 'The closing happened before I arrived.'),
      ('Duration before past', 'He was tired because he had been driving all night.', 'The driving went on until the moment of being tired.')]),
    ('Talking about the future',
     'English has several ways to talk about the future, and the choice depends on how you see the event. '
     'Use will for decisions made at the moment of speaking, offers, promises and predictions based on opinion: "I’ll get the door." "I think it’ll be fine." '
     'Use going to for plans already decided and for predictions based on present evidence: "We’re going to move in June." "Look at the sky — it’s going to rain." '
     'Use the present continuous for fixed arrangements with other people: "I’m seeing the dentist at four." The present simple is used for timetables: "The train leaves at 7.15." '
     'The future continuous (will be + -ing) describes an action in progress at a future time: "This time tomorrow I’ll be flying to Lima." '
     'The future perfect (will have + past participle) describes something complete before a future time: "By June we’ll have finished the project."',
     [('Instant decision', 'It’s cold — I’ll close the window.', 'Decided now, so will.'),
      ('Evidence', 'Watch out! That glass is going to fall.', 'You can see it about to happen.'),
      ('Complete before', 'By the time you arrive, we’ll have eaten.', 'Eating will be finished before you arrive.')]),
],
'Modals': [
    ('Ability, advice and obligation',
     'Modal verbs (can, could, should, must, may, might, will, would) are followed by the base form without to, never add -s, and make questions without do: "Can she drive?" '
     'Can shows ability and permission: "I can swim." "You can sit here." Could is past ability or a more polite request: "Could you help me?" '
     'Should gives advice or says what is right: "You should see a doctor." '
     'Must shows strong obligation, often from the speaker: "I must call my mum." Have to shows obligation from outside, like rules: "We have to wear a helmet." '
     'In the negative they differ sharply: mustn’t means it is not allowed ("You mustn’t smoke here"), while don’t have to means it is not necessary ("You don’t have to come").',
     [('Advice', 'You should back up your files every week.', 'should + base verb gives advice.'),
      ('Not allowed', 'You mustn’t park in front of the gate.', 'mustn’t = it is forbidden.'),
      ('Not necessary', 'You don’t have to bring food; lunch is included.', 'don’t have to = there is no need.')]),
    ('Deduction: must, might, can’t',
     'Modals also show how sure we are about something. Must means you are almost certain it is true: "The lights are on, so they must be home." '
     'Might, may and could mean it is possible: "She might be in a meeting." '
     'Can’t means you are almost certain it is not true: "That can’t be Tom; he’s in Brazil." (Use can’t, not mustn’t, for negative deduction.) '
     'For the past, use the modal + have + past participle: "He must have missed the bus." "They might have forgotten." "She can’t have seen us." '
     'These forms let you reason from evidence without claiming more certainty than you have.',
     [('Certain yes', 'You’ve been travelling all day — you must be exhausted.', 'Strong conclusion from evidence.'),
      ('Possible', 'The parcel might arrive tomorrow.', 'Possible, not sure.'),
      ('Past deduction', 'The ground is wet; it must have rained last night.', 'must have + past participle for the past.')]),
    ('Past modals and hedging',
     'Should have + past participle expresses regret or criticism about the past: "I should have left earlier" (but I didn’t). '
     'Could have + past participle shows a past possibility that did not happen: "You could have been hurt." '
     'Needn’t have means you did something that was not necessary: "You needn’t have brought a gift." '
     'In careful speech and academic writing, modals are also used to hedge, that is, to avoid sounding too certain: '
     '"This may suggest…", "The results could indicate…", "It would seem that…". '
     'Hedging is not weakness; it shows that your claim matches your evidence. Combine modals with words like possibly, likely and appears to for a measured tone.',
     [('Regret', 'We should have booked a table.', 'It was a good idea, but we didn’t do it.'),
      ('Unnecessary', 'You needn’t have waited for me.', 'You waited, but it was not necessary.'),
      ('Hedging', 'These figures may indicate a change in demand.', 'may softens the claim to fit the evidence.')]),
],
'Conditionals and wishes': [
    ('Real and unreal conditionals',
     'A conditional sentence has an if-clause (the condition) and a main clause (the result). '
     'The zero conditional is for things that are always true: if + present, present. "If you heat ice, it melts." '
     'The first conditional is for a real, possible future: if + present, will + base verb. "If it rains tomorrow, we’ll stay in." Do not put will in the if-clause. '
     'The second conditional is for unreal or unlikely situations now or in the future: if + past simple, would + base verb. "If I had more time, I would learn the piano." '
     'In formal English, use were for all persons: "If I were you, I’d accept." '
     'Unless means if not: "We’ll miss the train unless we leave now."',
     [('First conditional', 'If you finish early, you can go home.', 'A real possibility in the future.'),
      ('Second conditional', 'If I lived by the sea, I would swim every day.', 'Not true now; imagined.'),
      ('Unless', 'Unless you hurry, you’ll be late.', 'unless = if you don’t.')]),
    ('Past regrets and wishes',
     'The third conditional imagines a different past and its result: if + past perfect, would have + past participle. '
     '"If we had left earlier, we would have caught the train." Both halves are about the past and both are untrue: we did not leave early and did not catch it. '
     'Wish and if only express regret. For the present, use the past simple: "I wish I had a car" (I don’t). '
     'For the past, use the past perfect: "I wish I had studied harder" (I didn’t). '
     'To complain about someone else’s annoying behaviour, use wish + would: "I wish he would stop talking." '
     'Suppose, imagine and what if work the same way: "What if we had taken the other road?"',
     [('Third conditional', 'If she had seen the sign, she wouldn’t have turned left.', 'She didn’t see it, and she did turn left.'),
      ('Present wish', 'I wish I knew the answer.', 'I don’t know it now.'),
      ('Past wish', 'If only I had brought an umbrella!', 'I didn’t bring one, and I regret it.')]),
    ('Mixed conditionals',
     'Sometimes the condition and the result are at different times, so we mix the patterns. '
     'A past condition with a present result: if + past perfect, would + base verb. "If I had taken that job, I would live in Paris now." '
     'A present condition with a past result: if + past simple, would have + past participle. "If I weren’t afraid of flying, I would have gone to the wedding." (I am afraid, so I didn’t go.) '
     'To build one, decide the time of each half separately and use the matching form. '
     'Mixed conditionals are useful for talking about how past decisions shape the present, and how lasting traits shaped the past.',
     [('Past → present', 'If I had saved more, I wouldn’t be worried now.', 'Past condition, present result.'),
      ('Present → past', 'If he spoke German, he would have got the job.', 'He doesn’t speak German, so he didn’t get it.'),
      ('Check each half', 'If we had planted trees then, the street would be greener today.', 'then → past perfect; today → would + base.')]),
],
'Relative and reduced clauses': [
    ('Relative clauses',
     'A relative clause gives information about a noun. Use who for people, which for things and animals, and that for either in defining clauses. '
     'Whose shows possession ("the woman whose car was stolen"), where refers to places and when to times. '
     'A defining clause tells us which one we mean and has no commas: "The students who passed got a certificate" (only those students). '
     'A non-defining clause adds extra information about something already identified; it has commas and cannot use that: '
     '"My brother, who lives in Oslo, is visiting." '
     'In defining clauses you can leave out the relative pronoun when it is the object: "the film (that) we watched".',
     [('Defining', 'The phone that I bought last week has stopped working.', 'Tells us which phone; no commas.'),
      ('Non-defining', 'Lisbon, which I visited in May, is very hilly.', 'Extra information, between commas.'),
      ('Whose', 'That’s the neighbour whose dog barks all night.', 'whose shows the dog belongs to the neighbour.')]),
    ('Participle and reduced clauses',
     'Relative and adverb clauses can often be shortened with a participle. An -ing participle has an active meaning: '
     '"the man sitting by the window" = the man who is sitting by the window. '
     'A past participle has a passive meaning: "the cars made in this factory" = the cars that are made here. '
     'Participle clauses can also replace adverb clauses: "Feeling tired, she went to bed early" (because she felt tired). '
     '"Having finished the report, he went home" shows that one action was completed before the other. '
     'The subject of the participle must be the subject of the main clause; otherwise the sentence dangles.',
     [('Active -ing', 'People living near the airport complain about the noise.', 'people who live near the airport.'),
      ('Passive -ed', 'The paintings stolen last year were found in a garage.', 'the paintings that were stolen.'),
      ('Sequence', 'Having checked the figures, she sent the report.', 'She checked them first, then sent it.')]),
],
'Reported speech': [
    ('Reporting what people said',
     'Reported (indirect) speech tells what someone said without quoting the exact words. '
     'After a past reporting verb such as said or told, the tense usually moves one step back: present → past, past → past perfect, will → would, can → could. '
     '"I’m tired" → She said (that) she was tired. "We won" → They said they had won. '
     'Pronouns, times and places change to fit the new situation: today → that day, tomorrow → the next day, here → there. '
     'Use say without a person (she said that…) and tell with a person (she told me that…). '
     'Reported questions use statement order and no question mark: "Where do you live?" → He asked where I lived. Yes/no questions use if or whether: She asked if I was ready. '
     'Reported commands use tell/ask + to: "Wait here" → He told us to wait there. '
     'When the fact is still true, the tense can stay: "She said she lives in Rome."',
     [('Tense moves back', '"I’ll call you." → He said he would call me.', 'will becomes would.'),
      ('Reported question', '"Are you coming?" → She asked whether I was coming.', 'whether + statement order.'),
      ('Reported command', '"Don’t be late." → The coach told us not to be late.', 'told + object + not to.')]),
    ('Reporting verbs',
     'Said and told are the most common reporting verbs, but many others show the speaker’s purpose more precisely, and each has its own pattern. '
     'Verb + to-infinitive: agree, offer, promise, refuse, threaten ("She agreed to help"). '
     'Verb + object + to-infinitive: advise, ask, encourage, invite, remind, warn ("He reminded me to lock the door"). '
     'Verb + -ing: admit, deny, suggest, recommend ("They denied taking the money"; "She suggested meeting at six"). '
     'Verb + that-clause: explain, complain, admit, insist ("He explained that the train was late"). '
     'Choosing the right verb lets you report the meaning of a whole sentence in a few words: "Shall I carry that?" → He offered to carry it.',
     [('Offer', '"I’ll drive you home." → She offered to drive me home.', 'offer + to-infinitive.'),
      ('Remind', '"Don’t forget your passport." → Mum reminded me to take my passport.', 'remind + object + to.'),
      ('Deny', '"I didn’t break it!" → He denied breaking it.', 'deny + -ing.')]),
],
'Linking ideas and cohesion': [
    ('Contrast: although, however, despite',
     'English has several ways to show contrast, and each fits a different grammar. '
     'Although, though and even though join two clauses in one sentence: "Although it was cold, we swam." '
     'However and nevertheless link two separate sentences or clauses joined by a semicolon, and are followed by a comma: "It was cold. However, we swam." '
     'Despite and in spite of are prepositions, so they are followed by a noun or an -ing form, not a clause: "Despite the cold, we swam." "In spite of feeling ill, she went to work." '
     'To use them before a clause, add the fact that: "Despite the fact that it was cold…". '
     'Whereas and while compare two contrasting facts: "I like tea, whereas my sister prefers coffee."',
     [('Clause', 'Although the train was late, we made the meeting.', 'although + subject + verb.'),
      ('Sentence link', 'The plan is risky. However, it is our best option.', 'However starts a new sentence, with a comma.'),
      ('Noun or -ing', 'Despite the traffic, they arrived early.', 'despite + noun, not a clause.')]),
    ('Cohesion across sentences',
     'Cohesion is what makes a text hang together. Writers use several tools. '
     'Reference words point back to something already mentioned: this, that, these, it, they, such. "The council raised parking fees. This angered local shops." '
     'Make sure the reference is clear: "this" should point to one obvious idea, and you can add a noun to be safe: "This decision angered local shops." '
     'Linking words show the relationship between ideas: addition (moreover, in addition), cause and result (therefore, as a result), contrast (however, on the other hand), sequence (first, then, finally). '
     'Repetition and synonyms keep a topic visible without monotony. Substitution (one, do so) and ellipsis (leaving out repeated words) avoid needless repetition.',
     [('Reference + noun', 'Sales fell by 10%. This drop worried investors.', 'This drop names exactly what this refers to.'),
      ('Result link', 'The road was flooded; as a result, the school closed.', 'as a result shows cause and effect.'),
      ('Substitution', 'I wanted a blue mug, but they only had green ones.', 'ones replaces mugs.')]),
],
'Punctuation': [
    ('Capitals and end marks',
     'Start every sentence with a capital letter, and capitalise proper nouns: names of people, places, days, months, languages, nationalities and organisations. '
     'The pronoun I is always a capital. Seasons are not capitalised in English: spring, summer. '
     'End a statement with a full stop (period in American English), a direct question with a question mark, and a strong exclamation with an exclamation mark. '
     'Use only one end mark, and avoid strings of exclamation marks in formal writing. '
     'An indirect question is a statement, so it ends with a full stop: "She asked when the train left."',
     [('Capitals', 'In June, Maria and I visited Spain and spoke Spanish every day.', 'Month, names, I, country and language take capitals.'),
      ('Question mark', 'Have you seen the new schedule?', 'A direct question ends with ?.'),
      ('Indirect question', 'He wondered why the shop was closed.', 'Not a direct question, so a full stop.')]),
    ('Commas',
     'Commas separate parts of a sentence so the reader can follow it. Use them between items in a list: "eggs, milk and bread". '
     '(The comma before and in a list, the Oxford comma, is optional, but use it when it prevents confusion.) '
     'Put a comma after an introductory word, phrase or clause: "However, …", "After lunch, …", "When we arrived, …". '
     'Put a comma before a coordinating conjunction that joins two main clauses: "It was late, so we left." '
     'Use a pair of commas around extra information that could be removed: "My boss, who is very patient, explained it again." '
     'Do not put a single comma between a subject and its verb, and do not join two sentences with a comma alone.',
     [('List', 'We need flour, sugar, butter and eggs.', 'Commas separate the items.'),
      ('Introductory clause', 'If you have questions, call me.', 'Comma after the opening if-clause.'),
      ('Extra information', 'Our teacher, Ms Okafor, is from Lagos.', 'A pair of commas around removable information.')]),
    ('Apostrophes',
     'Apostrophes do two jobs. First, they show missing letters in contractions: do not → don’t, it is → it’s, they are → they’re, I would → I’d. '
     'Second, they show possession. Add ’s to a singular noun (the cat’s bowl, James’s book) and to plural nouns that do not end in -s (the children’s toys, women’s rights). '
     'For plural nouns ending in -s, add only the apostrophe: the students’ results, my parents’ house. '
     'Never use an apostrophe to make an ordinary plural: one apple, two apples (not apple’s). '
     'Possessive pronouns have no apostrophe: its, yours, hers, ours, theirs.',
     [('Contraction', 'They’re sure it’s going to rain.', 'they are, it is.'),
      ('Plural possessive', 'The players’ shirts were washed.', 'Many players, so the apostrophe follows the -s.'),
      ('Irregular plural', 'The children’s room is upstairs.', 'children has no -s, so add ’s.')]),
    ('Colons, semicolons and dashes',
     'A semicolon joins two main clauses that are closely related, without a conjunction: "The shop is closed; it reopens on Monday." '
     'It can also separate list items that already contain commas: "Paris, France; Lima, Peru; and Osaka, Japan." '
     'A colon introduces something that explains or completes what comes before it: a list, an example or a conclusion. '
     'The part before the colon should be a complete sentence: "You need three things: patience, practice and time." '
     'A dash marks a sharp break or adds emphasis, and a pair of dashes can replace a pair of commas for extra information: '
     '"The answer — if there is one — will take time." Dashes are more informal than colons, so use them sparingly in formal writing.',
     [('Semicolon', 'The first test was easy; the second was much harder.', 'Two related main clauses, no conjunction.'),
      ('Colon', 'There was only one problem: nobody had the key.', 'The colon introduces the explanation.'),
      ('Dashes', 'My grandmother — who is ninety — still swims daily.', 'Dashes set off the extra information with emphasis.')]),
    ('Quotation marks and direct speech',
     'Quotation marks show someone’s exact words. Start the quotation with a capital letter, and put the punctuation that belongs to the speech inside the marks: '
     '"We’re leaving," she said. She said, "We’re leaving." '
     'If the quoted sentence is a question, the question mark goes inside: "Are you ready?" he asked. '
     'When the reporting clause interrupts one sentence, the second part continues with a small letter: "I think," she said, "that we should wait." '
     'Start a new paragraph each time the speaker changes. American English usually uses double marks (" ") and British English often single marks (‘ ’); choose one and use it consistently.',
     [('Comma inside', '"I’ll be there at six," Leo promised.', 'The comma belongs to the speech and goes inside.'),
      ('Question inside', '"Where is the exit?" asked the visitor.', 'The question mark is part of the quoted question.'),
      ('Interrupted sentence', '"If you hurry," she said, "you can catch it."', 'The second part continues with a small letter.')]),
],
# ───────────────────────── Advanced ─────────────────────────
'Active, passive and causative voice': [
    ('The passive voice',
     'In an active sentence the subject does the action: "The committee approved the plan." '
     'In a passive sentence the subject receives the action: "The plan was approved (by the committee)." Form it with be in the right tense + past participle: is made, was built, has been sold, will be announced. '
     'Use the passive when the doer is unknown, obvious or unimportant ("My bike was stolen"), when you want to focus on the action or result, and in formal, scientific and news writing. '
     'Add by + agent only if it is useful information. '
     'Do not overuse it: active sentences are usually clearer and shorter. Only verbs with an object can be made passive, so "The accident happened" has no passive form.',
     [('Unknown doer', 'The window was broken during the night.', 'We don’t know who broke it.'),
      ('Focus on result', 'The new hospital will be opened next spring.', 'The hospital matters more than who opens it.'),
      ('With agent', 'The novel was written by a sixteen-year-old.', 'by + agent is surprising, so it is worth adding.')]),
    ('Have something done',
     'The causative have/get something done says that someone else does a job for you, usually because you arrange or pay for it. '
     'Form: have + object + past participle. "I had my hair cut." "We’re having the kitchen painted." '
     'Get is more informal: "I need to get my car repaired." '
     'The same form can describe something bad that happened to you: "He had his wallet stolen on the metro." '
     'With an active meaning, have + person + base verb and get + person + to + verb mean you make or persuade someone to do something: '
     '"I had the mechanic check the brakes." "She got her brother to help her move."',
     [('Service', 'We’re having solar panels installed next week.', 'Someone else will install them for us.'),
      ('Bad experience', 'She had her bag taken at the station.', 'Something was done to her bag, not arranged by her.'),
      ('Persuade', 'I finally got my son to tidy his room.', 'get + person + to + verb.')]),
],
'Mood and emphasis': [
    ('Indicative, imperative, subjunctive',
     'Mood shows the speaker’s attitude to an action. The indicative states facts and asks questions: "The office opens at nine." '
     'The imperative gives commands and instructions: "Close the door." '
     'The subjunctive is for wishes, demands and imagined situations. Today it appears in two main patterns. '
     'After verbs and adjectives of demand or importance (suggest, insist, recommend, essential, vital) formal English uses the base form for every person: '
     '"The doctor recommended that he rest." "It is vital that she be informed." British English often uses should instead: "that he should rest". '
     'The past subjunctive were is used in unreal conditions and wishes: "If I were taller…" "I wish it were Friday."',
     [('Indicative', 'The meeting starts at ten.', 'A plain statement of fact.'),
      ('Subjunctive of demand', 'The manager insisted that every invoice be checked.', 'be, not is, after insisted that.'),
      ('Unreal were', 'If she were here, she would know what to do.', 'were for an imagined present.')]),
    ('Inversion for emphasis',
     'In formal and rhetorical English, some negative or limiting expressions can be placed at the start of a sentence for emphasis. '
     'When they are, the subject and the auxiliary change places, as in a question. '
     '"I have never seen such a mess" → "Never have I seen such a mess." '
     'Common triggers are never, rarely, seldom, hardly … when, no sooner … than, not only … but also, only then, under no circumstances, little. '
     '"Not only did she win, but she also broke the record." "Under no circumstances should you open this door." '
     'Inversion also replaces if in formal conditionals: "Had I known" = If I had known; "Should you need help" = If you need help. Use it for emphasis, not in every sentence.',
     [('Negative adverbial', 'Rarely do we see such talent at this age.', 'Rarely first → do we see.'),
      ('Not only', 'Not only is the flat cheap, but it is also central.', 'Not only first → is the flat.'),
      ('Conditional', 'Had we left earlier, we would have missed the storm.', 'Had we left = If we had left.')]),
],
'Formal language and noun phrases': [
    ('Formal structures',
     'Formal English, used in reports, applications and academic writing, prefers certain structures. '
     'It avoids contractions (do not, rather than don’t) and uses one-word verbs instead of phrasal verbs: investigate rather than look into, tolerate rather than put up with. '
     'It uses impersonal patterns: "It is recommended that…", "It has been suggested that…", "There is evidence that…". '
     'It uses the passive where the doer is not important, and cleft sentences for focus: "What the data shows is…", "It was the cost that caused concern." '
     'Formal does not mean complicated. A formal sentence should still be clear and as short as the idea allows.',
     [('One-word verb', 'The committee will investigate the complaint.', 'investigate replaces look into.'),
      ('Impersonal', 'It is recommended that staff update their passwords.', 'The advice is given without naming who gives it.'),
      ('Cleft', 'What concerns us most is the delay.', 'The cleft structure puts focus on the delay.')]),
    ('Register: formal and informal',
     'Register is the level of formality you choose for a situation. The same message can be said in very different ways: '
     '"Can you send it over?" (informal) / "Could you send it to me, please?" (neutral) / "I would be grateful if you could forward the document." (formal). '
     'Informal English uses contractions, phrasal verbs, short sentences, everyday words and direct questions. '
     'Formal English uses full forms, Latin-based vocabulary (obtain, assist, require), longer sentences and indirect, polite forms. '
     'Choose by your reader and purpose: a message to a friend, an email to a colleague and a letter to an official each need a different register. '
     'Mixing registers in one text, such as "Dear Sir, thanks a lot!", sounds odd.',
     [('Informal', 'Thanks for getting back to me so fast!', 'Phrasal verb, contraction, exclamation.'),
      ('Formal', 'Thank you for your prompt reply.', 'Full forms and precise vocabulary.'),
      ('Polite formal request', 'I would be grateful if you could confirm the date.', 'Indirect and courteous.')]),
    ('Dense noun phrases',
     'Academic and professional writing often packs information into long noun phrases instead of clauses. '
     '"Because prices rose quickly, people bought less" becomes "The rapid rise in prices led to a fall in consumption." '
     'This process, called nominalisation, turns verbs and adjectives into nouns: rise → a rise, decide → a decision, important → importance. '
     'Noun phrases can be built up with adjectives, nouns used as modifiers and prepositional phrases: "a two-year government study of urban air quality". '
     'Used well, nominalisation makes writing concise and objective. Overused, it hides who did what and becomes hard to read, so keep a balance with clear verbs.',
     [('Clause → noun phrase', 'The introduction of the new policy caused confusion.', 'Instead of "When they introduced the new policy, people were confused."'),
      ('Stacked modifiers', 'The city published a five-year public transport plan.', 'Several modifiers before the noun plan.'),
      ('Too dense', 'The implementation of the improvement of the process was delayed.', 'Better: "We were slow to improve the process."')]),
],
'Confusable words': [
    ('Its, your, their and friends',
     'Some of the most frequent errors in English writing come from words that sound the same but are spelled differently. '
     'Its (possessive) / it’s (it is, it has). Your (possessive) / you’re (you are). Their (possessive) / there (place, or there is) / they’re (they are). '
     'Whose (possessive) / who’s (who is, who has). Then (time, next) / than (comparison). Lose (verb, opposite of find) / loose (adjective, not tight). '
     'The quickest check for the apostrophe forms is to expand them: if "it is" or "you are" fits, use the apostrophe; if not, use the possessive.',
     [('Expand to check', 'You’re late, and your coffee is cold.', 'you are late / your coffee.'),
      ('Three forms', 'They’re putting their bags over there.', 'they are / possessive / place.'),
      ('Then and than', 'It’s cheaper than the bus, and then it’s faster too.', 'than compares; then shows sequence.')]),
    ('Affect, fewer, whom and other pairs',
     'Affect is usually a verb (to influence): "The weather affects my mood." Effect is usually a noun (a result): "The weather has an effect on my mood." '
     'Fewer is for countable nouns (fewer cars) and less for uncountable ones (less traffic). '
     'Who is a subject and whom an object: "Who called?" "To whom should I write?" In everyday speech who is often used for both, but whom is expected after a preposition in formal writing. '
     'Other common pairs: complement (complete or match) and compliment (praise); principle (a rule) and principal (main, or a head teacher); '
     'stationary (not moving) and stationery (paper and pens); advice (noun) and advise (verb).',
     [('Affect / effect', 'The new law will affect small firms; its effect is unclear.', 'affect is the verb; effect is the noun.'),
      ('Fewer / less', 'Fewer people came, so we spent less money.', 'people can be counted; money cannot.'),
      ('Whom', 'The candidate whom we interviewed was excellent.', 'whom is the object of interviewed.')]),
],
'Modifiers and parallel structure': [
    ('Dangling and misplaced modifiers',
     'A modifier is a word or phrase that describes something. It should sit next to what it describes. '
     'A dangling modifier has nothing in the sentence to describe: "Walking to school, the rain started" suggests the rain was walking. '
     'Fix it by making the subject of the main clause the one doing the action: "Walking to school, I got caught in the rain." '
     'A misplaced modifier is in the wrong position: "She almost drove her kids to school every day" means she nearly drove them but didn’t; '
     '"She drove her kids to school almost every day" is what was meant. '
     'Words like only, just, almost and nearly change meaning depending on where they go, so place them right before the word they limit.',
     [('Dangling fixed', 'Looking out of the window, I saw a fox.', 'I is the one looking, so the modifier fits.'),
      ('Only placed well', 'He only eats fish on Fridays.', 'Compare: "Only he eats fish on Fridays" — a different meaning.'),
      ('Misplaced fixed', 'She served the cake on a plate to the guests.', 'Not "She served the cake to the guests on a plate."')]),
    ('Parallel structure',
     'Parallel structure means using the same grammatical form for items that have the same job in a sentence. '
     'Lists, comparisons and pairs joined by and, or, but, both … and, either … or, not only … but also should match. '
     '"She likes hiking, swimming and to cycle" is unbalanced; "She likes hiking, swimming and cycling" is parallel. '
     'In paired structures, put the same kind of word after each half: "You can either call or email" (verb, verb), not "either call or by email". '
     'Parallelism makes sentences easier to read and gives speeches their rhythm: "We came, we saw, we conquered."',
     [('Matching list', 'The job involves planning events, managing budgets and training staff.', 'Three -ing phrases.'),
      ('Paired structure', 'The course is both practical and enjoyable.', 'both + adjective, and + adjective.'),
      ('Comparison', 'Writing a plan is easier than following it.', 'Writing … following, two matching -ing forms.')]),
],
}
