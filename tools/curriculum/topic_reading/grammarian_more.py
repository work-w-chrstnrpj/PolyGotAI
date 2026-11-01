"""Reading pages for the Grammarian expansion (2026-10-30). Original wording; same format as grammarian.py:
(heading, explanation, [(label, example sentence, note), ...])."""

MORE_READING = {
# ───────────────────────── Starter ─────────────────────────
'Possessive ’s and of': [
    ('Who owns it: ’s',
     'To show that something belongs to a person or an animal, add ’s to the owner: Anna’s phone, the dog’s bed, my teacher’s car. '
     'The owner comes first and the thing comes second. When the owner is a regular plural that already ends in -s, add only the apostrophe: '
     'my parents’ flat, the students’ results. Irregular plurals that do not end in -s add ’s as usual: the men’s room, people’s ideas. '
     'A name that ends in -s can take ’s or just an apostrophe; both are accepted: Chris’s idea, Chris’ idea.',
     [('One owner', 'My friend’s brother is a pilot.', 'One friend, so ’s goes on friend.'),
      ('Plural owners', 'The players’ shirts were soaked with rain.', 'Many players already end in -s, so only the apostrophe is added.'),
      ('Irregular plural', 'She designs women’s clothes.', 'Women does not end in -s, so it takes ’s.')]),
    ('Things and parts: of',
     'For things, places and parts of something, English usually uses of instead: the door of the car, the end of the street, '
     'the middle of the night, the title of the book. Many fixed time and place phrases still use ’s: today’s news, the world’s population, '
     'a week’s holiday. Whose asks about the owner: Whose jacket is this? Do not confuse it with who’s, which means who is.',
     [('A part', 'Write your name at the top of the form.', 'A part of a thing usually uses of.'),
      ('Time phrase', 'Did you read yesterday’s paper?', 'Time expressions often take ’s.'),
      ('Asking', 'Whose car is parked outside?', 'Whose asks who something belongs to.')]),
],
'Much, many, a few and a little': [
    ('Countable and uncountable amounts',
     'Countable nouns have a plural (one chair, two chairs), so they go with many and a few. Uncountable nouns have no plural '
     '(water, money, advice, information, furniture), so they go with much and a little. In questions we ask How many…? for things we count '
     'and How much…? for amounts. In ordinary positive sentences, a lot of or lots of is more natural than much and works with both kinds: '
     'a lot of friends, a lot of time. Much is common in questions and negatives: Is there much traffic? We don’t have much time.',
     [('Countable', 'How many tickets did you buy?', 'Tickets can be counted, so use many.'),
      ('Uncountable', 'We don’t have much bread.', 'Bread is uncountable, so use much in a negative.'),
      ('Either kind', 'She has lots of energy and lots of ideas.', 'Lots of works with uncountable and plural nouns.')]),
    ('A few and few, a little and little',
     'A few and a little are positive: they mean some, not many, but enough. Few and little without a are negative: they mean almost none, '
     'and often suggest a problem. Compare: I have a few friends here, so I’m happy. I have few friends here, so I feel lonely. '
     'Very few and very little make the negative meaning stronger. Quite a few means a fairly large number.',
     [('Positive', 'Add a little salt and stir.', 'A little: a small but useful amount.'),
      ('Negative', 'Few tourists visit the village in winter.', 'Few: almost none.'),
      ('Fairly many', 'Quite a few people asked about the job.', 'Quite a few means more than expected.')]),
],
'There is and there are': [
    ('Saying that something exists',
     'Use there is and there are to say that something exists or to mention it for the first time. There is goes with a singular noun '
     'or an uncountable noun; there are goes with a plural noun. In speech, there is is usually shortened to there’s. Many languages '
     'use a verb like have for this idea, but English does not: say There is a museum in my town, not In my town have a museum. '
     'After there is or there are we often add where the thing is: on the table, in the city, near the station.',
     [('Singular', 'There’s a pharmacy next to the bank.', 'One pharmacy, so there is.'),
      ('Plural', 'There are two cafés on this street.', 'Two cafés, so there are.'),
      ('Uncountable', 'There is some juice in the fridge.', 'Juice is uncountable, so there is.')]),
    ('Questions, negatives and the past',
     'For questions, put is or are first: Is there…? Are there…? Short answers repeat there with is, isn’t, are or aren’t, and a short '
     'yes answer is never contracted. For negatives, use there isn’t or there aren’t, often with any, or use '
     'there is no / there are no. To count, ask How many… are there? In the past, use there was and there were.',
     [('Negative', 'There aren’t any taxis at this hour.', 'Aren’t any for a plural negative.'),
      ('Question', 'Is there a lift in this building?', 'Is comes before there in a question.'),
      ('Past', 'There were forty guests at the wedding.', 'Were for a plural in the past.')]),
],
'This, that, these and those': [
    ('Near and far, one and many',
     'This and these point to things near the speaker; that and those point to things farther away. This and that are singular; '
     'these and those are plural. They can come before a noun (this book, those trees) or stand alone (I like this. Are those yours?). '
     'Distance can be in space or in time: this week is now, that week was in the past.',
     [('Near, one', 'This bag is really heavy.', 'The bag is close to the speaker.'),
      ('Far, many', 'Can you see those hills?', 'The hills are far away and plural.'),
      ('Standing alone', 'That looks delicious!', 'That can be used without a noun.')]),
    ('Everyday uses',
     'We use this is to introduce people (This is my colleague, Dev) and to say who we are on the phone (Hello, this is Mia). '
     'That can refer back to something just said: That’s a great idea. These days means nowadays; in those days means at a time in the past.',
     [('Introduction', 'This is my neighbour, Mr Park.', 'Use this is for someone next to you.'),
      ('Reacting', 'That’s a good point.', 'That refers to what someone just said.'),
      ('Nowadays', 'These days, I cycle to work.', 'These days means at the present time.')]),
],
'Can, can’t and could': [
    ('Can and can’t',
     'Can is a modal verb. It has the same form with every subject and is followed by the base verb, with no to and no -s: '
     'She can drive. We use it for ability (I can type fast), for permission (You can sit here) and for possibility (It can be cold at night). '
     'The negative is cannot or can’t. Questions put can before the subject, without do: Can you hear me? Short answers repeat can or can’t after the '
     'subject.',
     [('Ability', 'My son can count to a hundred.', 'Can + base verb, with no -s.'),
      ('Permission', 'You can use my laptop.', 'Can gives permission.'),
      ('Question', 'Can they speak Portuguese?', 'Can comes before the subject.')]),
    ('Could',
     'Could is the past of can for general ability: When I was young, I could run fast. Its negative, couldn’t, is common for something '
     'that was not possible on one occasion: I couldn’t open the jar. Could is also a polite way to make a request (Could you help me?) '
     'or to ask for permission (Could I leave early?). It can also suggest a possibility: We could take the train.',
     [('Past ability', 'At ten, she could play the piano.', 'General ability in the past.'),
      ('Not possible', 'They couldn’t find a parking space.', 'Couldn’t: it was not possible.'),
      ('Polite request', 'Could you speak a little more slowly?', 'Could makes a request softer.')]),
],
# ───────────────────────── Foundation ─────────────────────────
'Present simple and present continuous': [
    ('Habits and facts: present simple',
     'Use the present simple for routines (I get up at seven), things that are generally true (She lives in Lyon) and facts (The sun rises '
     'in the east). With he, she and it, the verb adds -s or -es: works, watches, goes. Questions and negatives use do or does with the base verb: '
     'Do you drive? He doesn’t eat fish. Frequency words such as always, usually, often, sometimes and never go before the main verb.',
     [('Routine', 'We usually have lunch at one.', 'Usually goes before the main verb.'),
      ('He, she, it', 'My cousin teaches maths.', 'Teach adds -es after my cousin.'),
      ('Question', 'Does your flat have a balcony?', 'Does + subject + base verb.')]),
    ('Now and around now: present continuous',
     'Use am, is or are + -ing for an action happening at the moment of speaking (She’s on the phone; she’s talking to her boss) and for '
     'a temporary situation around now (I’m reading a great novel this week). Words such as now, at the moment, today and this week often '
     'go with it. State verbs — know, like, love, want, need, believe, own, understand — describe states rather than actions, so they '
     'normally stay in the simple form: I want a coffee, not I am wanting a coffee.',
     [('At this moment', 'Listen, someone is knocking at the door.', 'An action in progress now.'),
      ('Temporary', 'He’s working nights this month.', 'True for now, not forever.'),
      ('State verb', 'I understand your question.', 'Understand is a state, so it stays simple.')]),
],
'Past simple and past continuous': [
    ('Finished actions: past simple',
     'Use the past simple for an action that started and finished in the past, often with a time phrase such as yesterday, last week, '
     'in 2015 or two days ago. Regular verbs add -ed (walk, walked); many common verbs are irregular (go, went; see, saw; buy, bought). '
     'Questions and negatives use did + base verb: Did you call her? I didn’t see it. A story is usually a chain of past simple verbs: '
     'I opened the door, looked around and switched on the light.',
     [('Time phrase', 'We moved to Manila in 2018.', 'A finished time, so the past simple.'),
      ('Irregular', 'She bought a new bike last month.', 'Buy is irregular: bought.'),
      ('Negative', 'I didn’t hear the alarm.', 'Didn’t + base verb.')]),
    ('In progress: past continuous',
     'Use was or were + -ing for an action that was in progress at a moment in the past (At nine o’clock I was watching the news) and to set '
     'the background of a story (The sun was shining and the birds were singing). When a short action interrupts a longer one, the longer '
     'action is continuous and the short one is simple, often joined by when or while: I was cooking when the phone rang.',
     [('At a past moment', 'At midnight they were still talking.', 'In progress at that moment.'),
      ('Background', 'It was snowing heavily when we left the café.', 'The snow is the background; leaving is the event.'),
      ('Two at once', 'While he was driving, she was reading the map.', 'Two actions in progress at the same time.')]),
],
'Talking about the future': [
    ('Will and going to',
     'English has no single future tense. Use going to for plans and intentions already decided (We’re going to get married in June) and '
     'for predictions based on evidence you can see now (Look at that queue; we’re going to be late). Use will for decisions made at the '
     'moment of speaking (It’s cold. I’ll close the window), for offers and promises (I’ll help you) and for predictions based on opinion '
     '(I think it will be a close game). The negative of will is won’t.',
     [('Plan', 'I’m going to start a cooking class.', 'Already decided before speaking.'),
      ('Instant decision', 'The phone’s ringing. I’ll get it.', 'Decided at this moment.'),
      ('Opinion', 'I’m sure you’ll pass the test.', 'A prediction based on belief.')]),
    ('Present forms with future meaning',
     'The present continuous is common for fixed arrangements, usually with a time and other people involved: I’m meeting Rosa for lunch '
     'tomorrow. The present simple is used for timetables and schedules: The concert starts at eight. After time words such as when, '
     'after, before, as soon as and until, and after if, use a present tense even though the meaning is future: I’ll text you when I arrive.',
     [('Arrangement', 'We’re flying to Cebu on Friday.', 'A booked plan.'),
      ('Timetable', 'Our class finishes at half past four.', 'A fixed schedule.'),
      ('After when', 'I’ll pay you back when I get my salary.', 'Present after when, future meaning.')]),
],
'Used to and would': [
    ('Used to and would for the past',
     'Used to + base verb describes habits and states in the past that are no longer true: I used to bite my nails. She used to have long hair. '
     'Questions and negatives use did and use to, without -d: Did you use to walk to school? I didn’t use to like olives. '
     'Would + base verb can also describe repeated past actions, especially in stories and memories: Every Sunday my dad would make pancakes. '
     'Would is not used for past states: say I used to own a motorbike, not I would own a motorbike.',
     [('Past habit', 'I used to go swimming before work.', 'Something I did regularly but no longer do.'),
      ('Past state', 'This café used to be a bookshop.', 'A state, so used to, not would.'),
      ('Memory', 'In summer we would sleep on the roof.', 'Would for repeated past actions.')]),
    ('Be used to and get used to',
     'Be used to means something is familiar and no longer strange; it is followed by a noun or an -ing form: I’m used to the noise. '
     'She’s used to working long hours. Get used to describes the process of becoming familiar: It took me months to get used to driving on '
     'the left. Do not mix them up with used to + base verb, which is only about the past.',
     [('Familiar', 'He’s used to cold showers.', 'Cold showers feel normal to him.'),
      ('With -ing', 'Are you used to getting up so early?', 'Be used to + -ing.'),
      ('Becoming familiar', 'You’ll soon get used to the new system.', 'Get used to: the process.')]),
],
'Indirect questions': [
    ('Polite questions inside a sentence',
     'An indirect question starts with a polite phrase such as Could you tell me…, Do you know…, Can you explain… or I wonder…. '
     'After the question word, the order changes back to a statement: subject, then verb. Do, does and did disappear, and the main verb takes '
     'its normal form: Where does she live? → Do you know where she lives? When did it happen? → Can you tell me when it happened? '
     'Indirect questions sound softer and more polite, so they are common with strangers, at work and in shops.',
     [('With is', 'Could you tell me where the ticket office is?', 'Subject the ticket office, then is.'),
      ('Without does', 'Do you know when the library closes?', 'Does disappears; close takes -s.'),
      ('Without did', 'Can you tell me why the train stopped?', 'Did disappears; stop takes -ed.')]),
    ('Yes/no questions and punctuation',
     'A yes/no question has no question word, so add if or whether: Is he at home? → Do you know if he is at home? '
     'The whole sentence takes a question mark only when the opening phrase is a question (Do you know…?). After a statement such as '
     'I wonder…, I’m not sure… or I don’t know…, end with a full stop.',
     [('With if', 'Do you know if this seat is taken?', 'If introduces a yes/no question.'),
      ('With whether', 'Could you check whether my parcel has arrived?', 'Whether means the same as if here.'),
      ('Statement', 'I’m not sure what time it starts.', 'The opening is a statement, so a full stop.')]),
],
'Prepositions after words': [
    ('Verbs and prepositions',
     'Many verbs are followed by a particular preposition, and the choice is not always logical, so it is best to learn the pair: '
     'listen to, wait for, depend on, belong to, apologise for, agree with someone, think about, look at, pay for. '
     'When the preposition is followed by a verb, use the -ing form: She apologised for keeping us waiting. '
     'In questions the preposition often moves to the end: What are you looking at?',
     [('Verb + to', 'This bike belongs to my sister.', 'Belong to a person.'),
      ('Verb + for', 'We waited for the rain to stop.', 'Wait for something.'),
      ('At the end', 'What are you worried about?', 'The preposition can end a question.')]),
    ('Adjectives and nouns with prepositions',
     'Adjectives also have fixed partners: good at, bad at, interested in, afraid of, proud of, tired of, keen on, responsible for, '
     'similar to, different from, married to. Some nouns do too: a reason for, an increase in, a difference between, an answer to, '
     'advice on. Using the wrong preposition rarely stops people understanding you, but it is one of the clearest signs of a learner.',
     [('Adjective', 'He’s really good at chess.', 'Good at an activity.'),
      ('Adjective + -ing', 'I’m tired of cooking every night.', 'Tired of + -ing.'),
      ('Noun', 'There has been an increase in prices.', 'An increase in something.')]),
],
'Gerunds and infinitives': [
    ('Verb + -ing or to + verb',
     'When one verb follows another, the second verb is either an -ing form (a gerund) or to + base verb (an infinitive), depending on the '
     'first verb. Verbs often followed by -ing include enjoy, finish, mind, avoid, suggest, keep, practise and consider: I don’t mind waiting. '
     'Verbs often followed by to + verb include want, need, decide, hope, plan, promise, agree, refuse, learn and would like: She refused to pay. '
     'There is no rule that predicts every verb, so learn them in short phrases.',
     [('-ing', 'Have you finished reading the report?', 'Finish + -ing.'),
      ('to + verb', 'They agreed to share the cost.', 'Agree + to + verb.'),
      ('Would like', 'I’d like to book a table for two.', 'Would like + to + verb.')]),
    ('Other uses and changes in meaning',
     'An -ing form can be the subject of a sentence (Running clears my head) and is always used after a preposition (She’s interested in '
     'learning Korean). A few verbs take both forms with a change of meaning. Stop doing means end the activity; stop to do means pause in '
     'order to do it. Remember to do and forget to do look forward to a task; remember doing looks back at something you did. '
     'Try doing means experiment; try to do means make an effort.',
     [('Subject', 'Learning a language takes patience.', 'An -ing form as the subject.'),
      ('After a preposition', 'Thanks for coming to the meeting.', 'For + -ing.'),
      ('Meaning change', 'We stopped to buy some water.', 'Paused in order to buy water.')]),
],
'Phrasal verbs': [
    ('What a phrasal verb is',
     'A phrasal verb is a verb plus a small word such as up, down, out, off, on, in or over. Together they make a new meaning that is often '
     'hard to guess from the parts: give up means stop, look after means take care of, find out means discover. Phrasal verbs are very '
     'common in everyday speech, while a single formal verb is often used in writing: find out / discover, put off / postpone, '
     'call off / cancel.',
     [('Stop a habit', 'He gave up coffee last year.', 'Give up: stop doing something.'),
      ('Discover', 'Did you find out who won?', 'Find out: get information.'),
      ('Tolerate', 'I can’t put up with his jokes any more.', 'Put up with: tolerate.')]),
    ('Where the object goes',
     'Many phrasal verbs are separable: a noun object can go before or after the small word (Turn the lights off / Turn off the lights). '
     'But a pronoun object such as it, them or her must go in the middle: Turn them off, not Turn off them. Some phrasal verbs cannot be '
     'separated (look after the baby, look after her), and some take no object at all (The plane took off).',
     [('Noun object', 'Please switch off your phones.', 'A noun can come after off.'),
      ('Pronoun object', 'Here’s the form. Please fill it in.', 'It goes between fill and in.'),
      ('No object', 'The car broke down on the motorway.', 'Break down takes no object.')]),
],
'So, such, too and enough': [
    ('So and such',
     'So and such make a quality stronger. So goes before an adjective or adverb on its own: so tired, so quickly. Such goes before a noun '
     'phrase: such a long day (singular), such long days (plural), such good advice (uncountable). Both can be followed by that + a result: '
     'The soup was so salty that nobody finished it. It was such a funny film that we watched it twice.',
     [('So + adjective', 'The test was so easy!', 'So before an adjective alone.'),
      ('Such a + noun', 'She’s such a good listener.', 'Such a before adjective + singular noun.'),
      ('Result', 'He spoke so softly that we couldn’t hear him.', 'So… that shows the result.')]),
    ('Too and enough',
     'Too means more than is acceptable, and it goes before an adjective or adverb: too hot, too slowly. Too much and too many go before '
     'nouns. Enough means as much as is needed; it goes after an adjective or adverb (warm enough, fast enough) but before a noun (enough money). '
     'Both often continue with to + verb or for + person: This bag is too heavy for me. She’s old enough to vote.',
     [('Too + adjective', 'These jeans are too tight.', 'More than is comfortable.'),
      ('Adjective + enough', 'Is the water warm enough to swim in?', 'Enough after the adjective.'),
      ('Enough + noun', 'We don’t have enough time to visit both museums.', 'Enough before the noun.')]),
],
# ───────────────────────── Intermediate ─────────────────────────
'Present perfect simple and continuous': [
    ('Present perfect simple',
     'Have or has + past participle connects a past action with the present. Use it for experiences at an unstated time (I’ve been to Seoul), '
     'for changes with a present result (She’s cut her hair), and for situations that started in the past and continue now (We’ve known each '
     'other for years). Common words with it are ever, never, just, already, yet, for and since. Do not use it with a finished time such as '
     'yesterday or in 2019; those need the past simple.',
     [('Experience', 'Have you ever tried surfing?', 'Ever: at any time in your life.'),
      ('Present result', 'I’ve lost my wallet, so I can’t pay.', 'The loss matters now.'),
      ('Up to now', 'He has lived abroad since 2015.', 'Since + a starting point.')]),
    ('Present perfect continuous',
     'Have or has been + -ing stresses the activity itself and how long it has continued up to now: I’ve been studying all afternoon. It is also '
     'used to explain a present situation by a recent activity: You look hot. Have you been running? Compare: I’ve read your report '
     '(finished) and I’ve been reading your report (the activity, maybe not finished). State verbs such as know, own and believe stay in '
     'the simple form.',
     [('How long', 'It has been raining since early this morning.', 'The activity continues up to now.'),
      ('Explaining', 'Her eyes are tired because she’s been staring at a screen.', 'A recent activity explains the present.'),
      ('Finished or not', 'I’ve painted two rooms, and I’ve been painting all day.', 'Simple counts results; continuous stresses the activity.')]),
],
'Past perfect simple and continuous': [
    ('One past action before another',
     'Had + past participle shows that one action happened before another action in the past. It makes the order clear when we tell events '
     'out of order: When I got to the cinema, the film had started (it started first). Words such as already, just, never, before and by the '
     'time often go with it. If events are told in the order they happened, the past simple is enough: I finished work and went home.',
     [('Earlier action', 'She had left by the time I arrived.', 'Leaving happened first.'),
      ('Never before', 'I had never eaten durian until that trip.', 'Experience up to a past moment.'),
      ('Explaining the past', 'He was upset because he had failed the test.', 'The earlier failure explains his feeling.')]),
    ('Past perfect continuous',
     'Had been + -ing describes an activity that continued up to a moment in the past, often with for or since: We had been walking for three '
     'hours when we saw the lake. It can also explain a past situation by an earlier activity: The road was wet because it had been raining. '
     'In reported speech, the present perfect and the past simple often move back to the past perfect: “I’ve finished” → She said she had finished.',
     [('Duration', 'They had been waiting for an hour when the bus came.', 'How long before the bus came.'),
      ('Cause', 'His clothes were dirty because he had been gardening.', 'An earlier activity explains the dirt.'),
      ('Reported', 'He said he had already paid.', 'The report moves back to had paid.')]),
],
'Future continuous and future perfect': [
    ('Future continuous',
     'Will be + -ing describes an action that will be in progress at a particular time in the future: At nine tomorrow I’ll be driving to '
     'work. It is often used with this time next week, at this time tomorrow or in a year’s time. It also asks politely about someone’s plans '
     'without sounding like a request: Will you be staying for dinner?',
     [('In progress', 'At noon tomorrow we’ll be flying over the Pacific.', 'In the middle of the flight at noon.'),
      ('This time next year', 'This time next year she’ll be studying in Canada.', 'An activity in progress then.'),
      ('Polite question', 'Will you be needing a taxi later?', 'A polite way to ask about plans.')]),
    ('Future perfect',
     'Will have + past participle describes an action that will be complete before a time in the future. It is often used with by: By Friday, '
     'I’ll have read the whole book. With for, it shows a length of time up to a future point: In June we’ll have been married for ten years. '
     'The negative is won’t have: They won’t have finished by then.',
     [('Complete before', 'By the end of the year, we’ll have paid off the loan.', 'Finished before that point.'),
      ('Duration', 'Next week I’ll have lived here for a year.', 'Length of time up to a future point.'),
      ('Negative', 'The paint won’t have dried by tonight.', 'Won’t have + past participle.')]),
],
'Noun clauses': [
    ('Clauses that act as nouns',
     'A noun clause is a clause that does the job of a noun: it can be the subject, the object or the complement of a sentence. '
     'Statements become noun clauses with that (I know that you’re busy), yes/no ideas with whether or if (I doubt whether it will work), and '
     'wh- ideas with a question word (Tell me where you were). Inside a noun clause, the order is always subject + verb, never question order.',
     [('Object with that', 'She said that the shop was closed.', 'That introduces what she said.'),
      ('Object with whether', 'We haven’t decided whether we’ll go.', 'Whether introduces a yes/no idea.'),
      ('Object with a wh- word', 'Do you remember where we met?', 'Statement order after where.')]),
    ('Noun clauses as subjects and after it',
     'A noun clause can begin a sentence: What she said made sense. Whether we win doesn’t matter. That he lied is clear. When the subject '
     'clause is long, English usually moves it to the end and puts it at the start: It is clear that he lied. It doesn’t matter whether we win. '
     'What can mean the thing that: What I like about this job is the freedom. The fact that… is a common way to name a whole statement.',
     [('Subject', 'What happened next surprised everyone.', 'What happened next is the subject.'),
      ('With it', 'It’s strange that nobody noticed.', 'It stands in for the that-clause.'),
      ('The fact that', 'The fact that she apologised helped a lot.', 'The fact that + a full statement.')]),
],
# ───────────────────────── Advanced ─────────────────────────
'The passive in every tense': [
    ('Forming the passive',
     'A passive verb is be in the right tense + past participle. Only be changes for tense: is made, is being made, was made, was being made, '
     'has been made, had been made, will be made, will have been made. After a modal, use be + past participle: can be done, must be checked, '
     'should have been sent. We choose the passive when the action matters more than the doer, when the doer is unknown or obvious, or to keep '
     'the topic at the start of the sentence. Add by + doer only when it is useful.',
     [('Continuous', 'Your car is being washed right now.', 'Is being + past participle.'),
      ('Perfect', 'Three new species have been discovered.', 'Have been + past participle.'),
      ('Modal', 'All bags should be kept under the seat.', 'Should be + past participle.')]),
    ('Reporting with the passive',
     'In news and formal writing, the passive reports what people in general say or believe without naming them. There are two patterns: '
     'It is said / believed / thought that + clause (It is thought that the fire started in the kitchen) and subject + is said / believed + to '
     'infinitive (The fire is thought to have started in the kitchen). Use to have + past participle for an earlier action.',
     [('It pattern', 'It is believed that the painting is a copy.', 'It + passive + that-clause.'),
      ('Subject pattern', 'The painting is believed to be a copy.', 'Subject + passive + to be.'),
      ('Earlier action', 'The thieves are said to have escaped by boat.', 'To have + past participle for the past.')]),
],
'Cleft sentences': [
    ('It-clefts',
     'A cleft sentence divides one statement into two parts to put the focus on one piece of information. An it-cleft uses It + be + the '
     'focused part + who/that + the rest: It was Lena who booked the hotel (not someone else). It was in May that we moved (not another month). '
     'Use who or that for people and that for things, times and places. It-clefts are useful for correcting someone or for contrast: '
     'It isn’t the price that worries me; it’s the quality.',
     [('Focus on a person', 'It was my grandfather who built this house.', 'The focus is on who built it.'),
      ('Focus on a time', 'It was only at midnight that the music stopped.', 'The focus is on when.'),
      ('Contrast', 'It’s not the heat that bothers me; it’s the humidity.', 'Two clefts set up a contrast.')]),
    ('Wh-clefts and all-clefts',
     'A wh-cleft starts with a what-clause, then be, then the focus: What I need is a good night’s sleep. To focus on an action, use what + '
     'subject + do + be + base verb: What we did was ask the neighbours. All… is works the same way but means “the only thing”: All I want is '
     'an answer. The verb be usually agrees with the focused phrase, and the subject is not repeated with it.',
     [('Focus on a thing', 'What impressed me most was the view.', 'What-clause + was + focus.'),
      ('Focus on an action', 'What she did was write to the manager.', 'Did… was + base verb.'),
      ('The only thing', 'All you have to do is press this button.', 'All… is means the only thing.')]),
],
'Ellipsis and substitution': [
    ('Substitution: so, not, one and do',
     'To avoid repeating words, English replaces them with short forms. So replaces a whole clause after think, hope, expect, suppose, believe '
     'and be afraid: “Is she coming?” “I suppose so.” The negative uses not with hope and be afraid (I’m afraid not) and usually '
     'don’t… so with think and believe (I don’t think so). One and ones replace countable nouns: the blue one, the old ones. '
     'Do, does and did can replace a verb phrase: She runs faster than I do.',
     [('So', '“Will the shop be open?” “I expect so.”', 'So replaces the shop will be open.'),
      ('Not', '“Can you come tonight?” “I’m afraid not.”', 'Not replaces I can’t come.'),
      ('Ones', 'I prefer the smaller ones.', 'Ones replaces a plural noun already mentioned.')]),
    ('Ellipsis: leaving words out',
     'Ellipsis means leaving out words the listener can easily recover. After an auxiliary or a modal, the rest of the verb phrase can be '
     'dropped: I haven’t finished yet, but I will. Short answers keep only the auxiliary: Yes, she can. No, they haven’t. To agree, use '
     'so + auxiliary + subject after a positive (“I’m hungry.” “So am I.”) and neither or nor + auxiliary + subject after a negative '
     '(“I don’t eat meat.” “Neither do I.”).',
     [('After a modal', 'He promised to call, and he did.', 'Did replaces called.'),
      ('Agreeing', '“I’ve been to Rome.” “So have I.”', 'So + have + I.'),
      ('Negative agreement', '“She can’t come.” “Nor can Ben.”', 'Nor + auxiliary + subject.')]),
],
}
