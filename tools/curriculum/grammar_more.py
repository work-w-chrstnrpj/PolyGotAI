"""Grammarian expansion (2026-10-30, owner: "still incomplete"). Original wording, written for this app.

Twenty-one topic lessons the Phase 13 consolidation did not cover, or covered in one page: the tenses one by one,
verb patterns, phrasal verbs, quantities, indirect and noun clauses, the passive in every tense, cleft sentences,
ellipsis and more. Topic order and level follow the British Council–EAQUALS Core Inventory; no text is copied.

`MORE` places each lesson in a stage and unit, before or after an existing topic. `ITEMS` holds 16 checked
exercises per lesson; reading pages live in `topic_reading/grammarian_more.py`.
"""

CREDITS = ['British Council-EAQUALS Core Inventory for General English (topic order and level)',
           'CEFR Companion Volume (grammatical accuracy descriptors)']

# (stage, unit, title, anchor): anchor is ('after' | 'before', existing or earlier new title).
MORE = [
    ('starter', 'parts-of-speech', 'Possessive ’s and of', ('after', 'Pronouns')),
    ('starter', 'parts-of-speech', 'Much, many, a few and a little', ('after', 'Articles and determiners')),
    ('starter', 'sentences', 'There is and there are', ('after', 'Sentence building')),
    ('starter', 'sentences', 'This, that, these and those', ('after', 'There is and there are')),
    ('starter', 'be-have-do', 'Can, can’t and could', ('after', 'Be, have and do')),
    ('foundation', 'tenses', 'Present simple and present continuous', ('before', 'Verbs')),
    ('foundation', 'tenses', 'Past simple and past continuous', ('after', 'Present simple and present continuous')),
    ('foundation', 'tenses', 'Talking about the future', ('after', 'Past simple and past continuous')),
    ('foundation', 'tenses', 'Used to and would', ('after', 'Talking about the future')),
    ('foundation', 'forms', 'Indirect questions', ('after', 'Questions')),
    ('foundation', 'forms', 'Prepositions after words', ('after', 'Prepositions')),
    ('foundation', 'word-classes', 'Gerunds and infinitives', ('after', 'Verbs')),
    ('foundation', 'word-classes', 'Phrasal verbs', ('after', 'Gerunds and infinitives')),
    ('foundation', 'word-classes', 'So, such, too and enough', ('after', 'Phrasal verbs')),
    ('intermediate', 'tense-map', 'Present perfect simple and continuous', ('before', 'Tenses')),
    ('intermediate', 'tense-map', 'Past perfect simple and continuous', ('before', 'Tenses')),
    ('intermediate', 'tense-map', 'Future continuous and future perfect', ('before', 'Tenses')),
    ('intermediate', 'complex', 'Noun clauses', ('after', 'Reported speech')),
    ('advanced', 'voice-mood', 'The passive in every tense', ('after', 'Active, passive and causative voice')),
    ('advanced', 'nuance', 'Cleft sentences', ('before', 'Formal language and noun phrases')),
    ('advanced', 'nuance', 'Ellipsis and substitution', ('after', 'Cleft sentences')),
]


# ── Authoring helpers: each returns one activity in the catalog's exercise format. ──

def C(prompt, answer, wrong, why):
    """Multiple choice. The answer is listed first on purpose; the app shuffles options."""
    return {'kind': 'grammar', 'required': True, 'prompt': prompt, 'answer': answer, 'explanation': why,
            'exercise': {'type': 'choice', 'options': [answer] + wrong, 'accepted': [answer]}}


def F(prompt, accepted, why):
    """Type the missing word(s); the prompt shows ___ for the gap."""
    accepted = [accepted] if isinstance(accepted, str) else accepted
    return {'kind': 'grammar', 'required': True, 'prompt': 'Type the missing word: ' + prompt, 'answer': accepted[0],
            'explanation': why, 'exercise': {'type': 'fillBlank', 'accepted': accepted}}


def E(wrong, correct, why):
    """Spot the error, then write the sentence correctly."""
    correct = [correct] if isinstance(correct, str) else correct
    return {'kind': 'grammar', 'required': True,
            'prompt': f'Find the mistake, then write the sentence correctly. “{wrong}”', 'answer': correct[0],
            'explanation': why, 'exercise': {'type': 'spotError', 'options': wrong.split(), 'accepted': correct}}


def M(prompt, pairs, why):
    return {'kind': 'grammar', 'required': True, 'prompt': prompt,
            'answer': ' | '.join(f'{a} → {b}' for a, b in pairs), 'explanation': why,
            'exercise': {'type': 'match', 'pairs': [list(p) for p in pairs]}}


def W(sentence, extra, why):
    """Build the sentence from tiles, with distractor tiles."""
    return {'kind': 'grammar', 'required': True, 'prompt': 'Build the sentence.', 'answer': sentence, 'explanation': why,
            'exercise': {'type': 'wordBank', 'options': sentence.split() + extra, 'accepted': [sentence]}}


def O(sentence, why):
    """Put the words in order (every word must be different)."""
    return {'kind': 'grammar', 'required': True, 'prompt': 'Put the words in order.', 'answer': sentence, 'explanation': why,
            'exercise': {'type': 'order', 'items': sentence.split()}}


def L(sentence, why):
    return {'kind': 'grammar', 'required': True, 'prompt': 'Listen, then write the sentence.', 'answer': sentence,
            'explanation': why, 'exercise': {'type': 'listenType', 'audioText': sentence, 'accepted': [sentence]}}


ITEMS = {}

# ───────────────────────── Starter ─────────────────────────

w = 'Use ’s for people and animals, and of for things and parts.'
ITEMS['Possessive ’s and of'] = [
    C('Choose the correct phrase for the bag that belongs to Maria.', 'Maria’s bag', ['the bag Maria', 'bag Maria’s'], w),
    F('Two girls share one bedroom. It is the ___ bedroom.', ['girls’', "girls'"], 'A plural that ends in -s takes only an apostrophe.'),
    C('Choose the correct phrase for the toys of several children.', 'the children’s toys', ['the toys children', 'the childs’ toys'], 'An irregular plural without -s adds ’s: children’s, women’s.'),
    C('Choose the natural phrase for the top part of a page.', 'the top of the page', ['the page’s top', 'the top page’s'], w),
    C('Choose the correct sentence.', 'This is my sister’s phone.', ['This is my sister phone.', 'This is phone my sister’s.'], w),
    C('Which phrase means the car belongs to James?', 'James’s car', ['James car’s', 'Jame’s car'], 'A name ending in -s can add ’s: James’s, or just an apostrophe: James’.'),
    C('Choose the correct question about ownership.', 'Whose keys are these?', ['Who’s keys are these?', 'Whose are these keys belong?'], 'Whose asks who something belongs to; who’s means who is.'),
    C('Choose the natural phrase.', 'the end of the film', ['the film’s end of', 'the end’s film'], w),
    F('This is my ___ house. (My parents own it.)', ['parents’', "parents'"], 'Parents is a regular plural, so the apostrophe goes after the -s.'),
    F('The name ___ the street is Station Road.', 'of', w),
    E('This is Peters coat.', ['This is Peter’s coat.', "This is Peter's coat."], 'A person who owns something takes ’s.'),
    E('The womens’ team won the final.', ['The women’s team won the final.', "The women's team won the final."], 'Women is already plural, so it adds ’s.'),
    M('Match each owner with the correct form.', [('one boy', 'the boy’s bike'), ('two boys', 'the boys’ bikes'), ('the men', 'the men’s shoes')], 'The apostrophe shows whether there is one owner or more.'),
    W('My brother’s friend lives in Rome.', ['brothers', 'of'], w),
    O('Whose umbrella is this?', 'Whose asks who something belongs to.'),
    L('We stayed at my uncle’s flat for a week.', w),
]

w = 'Many and a few go with countable nouns; much and a little go with uncountable nouns.'
ITEMS['Much, many, a few and a little'] = [
    C('Choose the correct question.', 'How many apples do you want?', ['How much apples do you want?', 'How many apple do you want?'], w),
    C('Choose the correct question.', 'How much time do we have?', ['How many time do we have?', 'How much times do we have?'], w),
    C('Which word fits? “I have ___ friends in this city, so I am not lonely.”', 'a few', ['a little', 'much'], 'A few is used with plural countable nouns and means some, enough to help.'),
    C('Which word fits? “There is ___ milk left, enough for one coffee.”', 'a little', ['a few', 'many'], 'A little is used with uncountable nouns and means a small amount.'),
    C('Which sentence sounds the most natural in everyday speech?', 'We have a lot of work today.', ['We have much work today.', 'We have many work today.'], 'In positive sentences, a lot of usually sounds more natural than much.'),
    C('Choose the correct negative.', 'There isn’t much traffic this morning.', ['There isn’t many traffic this morning.', 'There aren’t much traffic this morning.'], w),
    C('Which word fits? “Very ___ people came, so the room felt empty.”', 'few', ['little', 'much'], 'Few without a sounds negative: not many.'),
    C('Which word fits? “We had ___ money, so we stayed at home.”', 'little', ['few', 'many'], 'Little without a sounds negative: not much.'),
    F('How ___ chairs do we need for the meeting?', 'many', w),
    F('I only need a ___ sugar in my tea.', 'little', w),
    E('How much people live in your building?', 'How many people live in your building?', 'People is plural and countable, so use many.'),
    E('I need a few information about the course.', ['I need a little information about the course.', 'I need some information about the course.'], 'Information is uncountable, so use a little or some.'),
    M('Match each word with a noun it goes with.', [('many', 'a large number'), ('much', 'a large amount'), ('a few', 'a small number'), ('a little', 'a small amount')], w),
    W('We only have a few eggs left.', ['little', 'much'], w),
    O('How much luggage are you taking?', 'Luggage is uncountable, so ask how much.'),
    L('There were only a few seats left on the train.', w),
]

w = 'Use there is with one thing or an uncountable noun, and there are with plural nouns.'
ITEMS['There is and there are'] = [
    C('Choose the correct sentence about one park.', 'There is a park near my house.', ['There are a park near my house.', 'It has a park near my house.'], w),
    C('Choose the sentence about several students.', 'There are twelve students in the class.', ['There is twelve students in the class.', 'Have twelve students in the class.'], w),
    C('Which word fits? “There ___ some rice in the pot.”', 'is', ['are', 'have'], 'Rice is uncountable, so use there is.'),
    C('Choose the correct question.', 'Are there any shops nearby?', ['Is there any shops nearby?', 'There are any shops nearby?'], 'In a question, put is or are before there.'),
    C('Someone asks, “Is there a bank near here?” There is one. Choose the reply.', 'Yes, there is.', ['Yes, there are.', 'Yes, it is.'], 'A bank is singular, so the short answer uses there is.'),
    C('Choose the sentence about yesterday.', 'There were many cars on the road yesterday.', ['There was many cars on the road yesterday.', 'There are many cars on the road yesterday.'], 'In the past, use there was with one thing and there were with plurals.'),
    C('Choose the correct negative.', 'There isn’t any sugar left.', ['There aren’t any sugar left.', 'There isn’t no sugar left.'], 'Use isn’t any or is no, not both negatives together.'),
    C('Which question asks about a number?', 'How many rooms are there?', ['How much rooms are there?', 'How many rooms there are?'], 'How many + plural noun + are there?'),
    F('There ___ three windows in the kitchen.', 'are', w),
    F('There ___ a big storm last night.', 'was', 'Use there was for one thing in the past.'),
    E('In my town have a beautiful old market.', ['In my town there is a beautiful old market.', 'There is a beautiful old market in my town.'], 'English says there is, not have, to show that something exists.'),
    E('There is two chairs by the door.', 'There are two chairs by the door.', w),
    M('Match each start with an ending.', [('There is', 'a lamp on the desk now.'), ('There are', 'two lamps on the desk now.'), ('There was', 'a party last week.'), ('There were', 'two parties last week.')], w),
    W('There is no milk in the fridge.', ['are', 'have'], w),
    O('Are there any eggs left?', 'In a question, are comes before there.'),
    L('There is a small garden behind the house.', w),
]

w = 'This and these are near you; that and those are farther away. This and that are singular; these and those are plural.'
ITEMS['This, that, these and those'] = [
    C('You are holding one pen. Choose the sentence.', 'This pen is mine.', ['These pen is mine.', 'That pens is mine.'], w),
    C('You point at a house across the street. Choose the sentence.', 'That house is very old.', ['This houses is very old.', 'Those house is very old.'], w),
    C('You are holding two shoes. Choose the sentence.', 'These shoes are too small.', ['This shoes are too small.', 'These shoe is too small.'], w),
    C('You point at birds in a far tree. Choose the sentence.', 'Look at those birds!', ['Look at that birds!', 'Look at these bird!'], w),
    C('Choose the polite way to introduce a friend.', 'This is my friend Ana.', ['That is my friend Ana.', 'These is my friend Ana.'], 'Use this is to introduce a person standing with you.'),
    C('On the phone, how do you say who you are?', 'Hi, this is Tom.', ['Hi, I am this Tom.', 'Hi, these is Tom.'], 'On the phone, say this is + your name.'),
    C('Which word fits? “___ days, many people work from home.”', 'These', ['Those', 'That'], 'These days means now; in those days means in the past.'),
    C('Which word fits? “In ___ days, there were no mobile phones.”', 'those', ['these', 'this'], w),
    F('Are ___ your keys over there on the table?', 'those', w),
    F('I love ___ song! Can you turn it up?', ['this', 'that'], 'Use this or that for one song you are hearing.'),
    E('These book is very interesting.', ['This book is very interesting.', 'These books are very interesting.'], 'These goes with plural nouns.'),
    E('Those is my car in the car park.', 'That is my car in the car park.', 'Use that with one thing that is far away.'),
    M('Match each phrase with its meaning.', [('this cup', 'one cup near me'), ('those cups', 'cups far from me'), ('these cups', 'cups near me'), ('that cup', 'one cup far from me')], w),
    W('Those mountains look beautiful today.', ['That', 'this'], w),
    O('Is this seat free?', w),
    L('These flowers are from our garden.', w),
]

w = 'Can + base verb for ability and permission now; could + base verb for ability in the past and polite requests.'
ITEMS['Can, can’t and could'] = [
    C('Choose the correct sentence.', 'She can speak three languages.', ['She can speaks three languages.', 'She cans speak three languages.'], 'Can never changes, and the verb after it has no -s.'),
    C('Choose the correct question.', 'Can you swim?', ['Do you can swim?', 'Can you to swim?'], 'Questions put can before the subject; do is not used.'),
    C('Choose the correct negative.', 'I can’t find my glasses.', ['I don’t can find my glasses.', 'I can’t to find my glasses.'], w),
    C('Choose the sentence about ability in the past.', 'When I was five, I could ride a bike.', ['When I was five, I can ride a bike.', 'When I was five, I could rode a bike.'], 'Could is the past of can for general ability.'),
    C('Which request is the most polite?', 'Could you help me with this box?', ['You help me with this box.', 'Can you to help me with this box?'], 'Could you…? is softer than can you…?'),
    C('Choose the sentence that asks for permission.', 'Can I open the window?', ['Can I to open the window?', 'Do I can open the window?'], w),
    C('Someone asks, “Can you drive?” You can. Choose the reply.', 'Yes, I can.', ['Yes, I can drive it.', 'Yes, I do.'], 'Short answers repeat can: Yes, I can. No, I can’t.'),
    C('Choose the sentence that means it was not possible.', 'We couldn’t sleep because of the noise.', ['We can’t slept because of the noise.', 'We didn’t could sleep because of the noise.'], 'Couldn’t is the past negative of can.'),
    F('I ___ hear you. The music is too loud.', ['can’t', "can't", 'cannot'], w),
    F('___ you tell me the time, please?', ['Could', 'Can'], 'Could and can both start a request; could is more polite.'),
    E('He can plays the guitar very well.', 'He can play the guitar very well.', 'After can, use the base verb with no -s.'),
    E('Do you can come tomorrow?', 'Can you come tomorrow?', 'Make a question by moving can before the subject.'),
    M('Match each sentence with its use.', [('Can I sit here?', 'permission'), ('I can cook pasta.', 'ability now'), ('Could you pass the salt?', 'polite request'), ('I could read at four.', 'ability in the past')], w),
    W('Could you close the door, please?', ['to', 'closed'], w),
    O('My grandfather could fix anything.', 'Could shows ability in the past.'),
    L('Sorry, I can’t come to the party on Saturday.', w),
]

# ───────────────────────── Foundation: tenses ─────────────────────────

w = 'Present simple for habits and facts; present continuous for actions happening now or around now.'
ITEMS['Present simple and present continuous'] = [
    C('Choose the sentence about a daily habit.', 'I walk to work every day.', ['I am walking to work every day.', 'I walking to work every day.'], w),
    C('Choose the sentence about this moment.', 'Be quiet, the baby is sleeping.', ['Be quiet, the baby sleeps.', 'Be quiet, the baby sleeping.'], w),
    C('Choose the correct present simple sentence.', 'My brother works in a hospital.', ['My brother work in a hospital.', 'My brother is work in a hospital.'], 'With he, she or it, the present simple verb adds -s.'),
    C('Choose the correct question.', 'Does she like coffee?', ['Does she likes coffee?', 'Is she like coffee?'], 'After does, use the base verb with no -s.'),
    C('Choose the correct sentence.', 'I know the answer.', ['I am knowing the answer.', 'I knowing the answer.'], 'State verbs such as know, like and want are rarely used in the continuous.'),
    C('Choose the sentence about a temporary situation.', 'I’m staying with my aunt this month.', ['I stay with my aunt this month.', 'I staying with my aunt this month.'], 'Use the continuous for something temporary that is true around now.'),
    C('Choose the sentence about a scientific fact.', 'Water boils at 100 degrees Celsius.', ['Water is boiling at 100 degrees Celsius.', 'Water boil at 100 degrees Celsius.'], 'Facts that are always true use the present simple.'),
    C('Which question asks about right now?', 'What are you doing?', ['What you doing are?', 'What you are doing?'], 'What do you do? usually asks about someone’s job.'),
    F('Look! It ___ snowing.', ['is', '’s', "'s"], w),
    F('She never ___ meat. She is a vegetarian.', 'eats', 'With she, the present simple verb adds -s.'),
    E('I am usually get up at seven.', 'I usually get up at seven.', 'A routine uses the present simple, without am.'),
    E('He don’t work on Sundays.', ['He doesn’t work on Sundays.', "He doesn't work on Sundays."], 'With he, she or it, use doesn’t.'),
    M('Match each sentence with its meaning.', [('She works at a bank.', 'her regular job'), ('She’s working from home this week.', 'a temporary arrangement'), ('She’s talking on the phone.', 'happening now')], w),
    W('They are watching a film at the moment.', ['watch', 'does'], w),
    O('How often do you visit your parents?', 'How often asks about habits, so use the present simple.'),
    L('My sister is studying for her exams this week.', w),
]

w = 'Past simple for finished actions; past continuous for an action in progress at a past moment.'
ITEMS['Past simple and past continuous'] = [
    C('Choose the correct sentence about last weekend.', 'We visited my grandparents last weekend.', ['We were visiting my grandparents last weekend every day.', 'We visit my grandparents last weekend.'], w),
    C('Choose the sentence about an action in progress at eight o’clock last night.', 'At eight o’clock I was cooking dinner.', ['At eight o’clock I cooked dinner every day.', 'At eight o’clock I am cooking dinner.'], w),
    C('Choose the sentence where a short action interrupts a longer one.', 'I was walking home when it started to rain.', ['I walked home when it was starting to rain.', 'I was walking home when it was start to rain.'], 'The longer background action is continuous; the short interruption is simple.'),
    C('Choose the correct past question.', 'Did you see the match?', ['Did you saw the match?', 'Were you see the match?'], 'After did, use the base verb.'),
    C('Choose the correct past negative.', 'She didn’t call me yesterday.', ['She didn’t called me yesterday.', 'She not called me yesterday.'], w),
    C('Choose the sentence about two actions in progress at the same time.', 'While I was reading, my brother was playing games.', ['While I read, my brother was play games.', 'While I was reading, my brother played games all the time.'], 'While often joins two continuous actions happening together.'),
    C('Choose the correct form of go.', 'They went to Spain in 2019.', ['They goed to Spain in 2019.', 'They were go to Spain in 2019.'], 'Go is irregular: go, went, gone.'),
    C('Choose the correct sentence.', 'What were you doing when the lights went out?', ['What did you doing when the lights went out?', 'What were you do when the lights went out?'], w),
    F('I ___ my keys yesterday, but I found them this morning. (lose)', 'lost', 'Lose is irregular: lose, lost.'),
    F('The phone rang while we ___ having lunch.', 'were', 'Use were with we in the past continuous.'),
    E('I was knowing her name, but I forgot it.', 'I knew her name, but I forgot it.', 'Know is a state verb, so use the past simple.'),
    E('When did you arrived?', 'When did you arrive?', 'After did, use the base verb.'),
    M('Match each verb with its past simple form.', [('buy', 'bought'), ('think', 'thought'), ('take', 'took'), ('write', 'wrote')], 'Many common verbs are irregular in the past simple.'),
    W('She was sleeping when the doorbell rang.', ['slept', 'ringing'], w),
    O('What did you have for breakfast?', 'Past questions use did + base verb.'),
    L('I was driving to work when I saw the accident.', w),
]

w = 'Going to for plans and evidence, will for decisions now and predictions, present continuous for arrangements.'
ITEMS['Talking about the future'] = [
    C('You decide right now to help. Choose the sentence.', 'I’ll carry that bag for you.', ['I’m going to carry that bag for you.', 'I carry that bag for you.'], 'Will is used for a decision made at the moment of speaking.'),
    C('You made this plan last week. Choose the sentence.', 'I’m going to paint my bedroom this weekend.', ['I paint my bedroom this weekend.', 'I’m painting my bedroom last weekend.'], 'Going to is used for a plan you have already decided.'),
    C('Dark clouds are in the sky. Choose the prediction.', 'It’s going to rain.', ['It rains.', 'It’s raining tomorrow.'], 'Use going to for a prediction based on what you can see now.'),
    C('You have a fixed appointment. Choose the most natural sentence.', 'I’m seeing the dentist on Tuesday.', ['I see the dentist on Tuesday maybe.', 'I will to see the dentist on Tuesday.'], 'The present continuous is common for fixed arrangements with other people.'),
    C('Choose the sentence about a timetable.', 'The train leaves at 6:15 tomorrow.', ['The train is going to leaves at 6:15 tomorrow.', 'The train will leaving at 6:15 tomorrow.'], 'Timetables and schedules often use the present simple.'),
    C('Choose the correct promise.', 'I won’t tell anyone your secret.', ['I don’t will tell anyone your secret.', 'I won’t to tell anyone your secret.'], 'Will is often used for promises; the negative is won’t.'),
    C('Choose the correct sentence about the future.', 'When I get home, I’ll call you.', ['When I will get home, I’ll call you.', 'When I get home, I call you yesterday.'], 'After when, if and as soon as, use the present simple for the future.'),
    C('Choose an opinion about the future.', 'I think people will travel to Mars one day.', ['I think people travel to Mars one day.', 'I think people are traveling to Mars one day.'], 'Use will for predictions based on opinion, often after I think.'),
    F('Look out! You’re ___ to drop those plates!', 'going', 'Use going to when something is about to happen.'),
    F('The film ___ at eight, so let’s meet at half past seven.', ['starts', 'begins'], w),
    E('I will to visit my cousin next summer.', ['I will visit my cousin next summer.', 'I’m going to visit my cousin next summer.'], 'After will, use the base verb with no to.'),
    E('If it will rain, we will stay inside.', 'If it rains, we will stay inside.', 'After if, use the present simple for the future.'),
    M('Match each sentence with its use.', [('I’ll answer it!', 'decision now'), ('We’re going to buy a car.', 'plan'), ('She’s meeting Ali at six.', 'arrangement'), ('The bus leaves at nine.', 'timetable')], w),
    W('We are going to move house in May.', ['will', 'moving'], w),
    O('What time does your flight leave?', 'A timetable uses the present simple.'),
    L('I think you will love this book.', w),
]

w = 'Used to and would describe past habits that have stopped; be used to means be familiar with.'
ITEMS['Used to and would'] = [
    C('Choose the sentence about a past habit that has stopped.', 'I used to play football every weekend.', ['I use to play football every weekend now.', 'I used to playing football every weekend.'], 'Used to + base verb: a past habit or state that is no longer true.'),
    C('Choose the correct question.', 'Did you use to live in Paris?', ['Did you used to live in Paris?', 'Used you to live in Paris?'], 'After did, write use to without -d.'),
    C('Choose the correct negative.', 'She didn’t use to like vegetables.', ['She didn’t used to like vegetables.', 'She used not like vegetables.'], w),
    C('Which sentence can use would instead of used to?', 'Every summer we used to swim in the lake.', ['I used to have a red bike.', 'He used to be very shy.'], 'Would works for repeated past actions, not for past states like have or be.'),
    C('Choose the sentence that means the night shift is now normal for him.', 'He is used to working at night.', ['He used to work at night.', 'He is used to work at night.'], 'Be used to + -ing means something is familiar and no longer strange.'),
    C('Choose the sentence about becoming familiar.', 'I’m slowly getting used to the cold weather.', ['I’m slowly getting used to the cold weather yesterday.', 'I’m slowly get used to the cold weather.'], 'Get used to + noun or -ing describes the process of becoming familiar.'),
    C('Choose the correct sentence about a past state.', 'There used to be a cinema here.', ['There would be a cinema here.', 'There use to be a cinema here.'], 'For past states, use used to, not would.'),
    C('Choose the correct sentence.', 'When I was a child, my grandmother would tell me stories.', ['When I was a child, my grandmother would told me stories.', 'When I was a child, my grandmother would telling me stories.'], 'Would + base verb can describe repeated actions in the past.'),
    F('I ___ to have long hair, but now it is short.', 'used', w),
    F('Are you used to ___ on the left? (drive)', 'driving', 'After be used to, use the -ing form.'),
    E('I am used to wake up early.', ['I am used to waking up early.', 'I used to wake up early.'], 'Be used to is followed by -ing.'),
    E('We would live in a small village.', ['We used to live in a small village.'], 'Live is a state here, so use used to, not would.'),
    M('Match each sentence with its meaning.', [('I used to smoke.', 'I smoked before, not now.'), ('I’m used to noise.', 'Noise feels normal to me.'), ('I’m getting used to it.', 'It is becoming normal.')], w),
    W('My father used to work in a bank.', ['would', 'uses'], w),
    O('Did your family use to have pets?', 'After did, write use to.'),
    L('It took me a month to get used to the new job.', w),
]

# ───────────────────────── Foundation: forms and words ─────────────────────────

w = 'In an indirect question, the words after the question word follow statement order: subject, then verb.'
ITEMS['Indirect questions'] = [
    C('Make “Where is the station?” more polite.', 'Could you tell me where the station is?', ['Could you tell me where is the station?', 'Could you tell me where does the station is?'], w),
    C('Make “What time does the shop open?” indirect.', 'Do you know what time the shop opens?', ['Do you know what time does the shop open?', 'Do you know what time opens the shop?'], 'Remove do or does and put the verb after the subject.'),
    C('Make “Is the museum open today?” indirect.', 'Do you know if the museum is open today?', ['Do you know is the museum open today?', 'Do you know if is the museum open today?'], 'For a yes/no question, use if or whether.'),
    C('Choose the correct indirect question.', 'I wonder why she left so early.', ['I wonder why did she leave so early.', 'I wonder why she did left so early.'], w),
    C('Choose the correct sentence.', 'Can you tell me how much this costs?', ['Can you tell me how much does this cost?', 'Can you tell me how much costs this?'], w),
    C('Choose the correct sentence.', 'I don’t know where he lives.', ['I don’t know where he does live.', 'I don’t know where does he live.'], w),
    C('Make “Did they win?” indirect.', 'Do you know whether they won?', ['Do you know whether did they win?', 'Do you know whether they did won?'], 'Remove did and use the past form of the verb.'),
    C('Choose the correct indirect question.', 'Could you explain what this word means?', ['Could you explain what does this word mean?', 'Could you explain what means this word?'], w),
    F('Do you know ___ the bus stops here? (yes/no question)', ['if', 'whether'], 'Use if or whether for an indirect yes/no question.'),
    F('Could you tell me where the toilets ___?', 'are', w),
    E('Do you know what time is it?', 'Do you know what time it is?', 'After the question word, use subject + verb.'),
    E('Can you tell me where do you work?', 'Can you tell me where you work?', 'Remove do in an indirect question.'),
    M('Match each direct question with its indirect form.', [('Where is it?', '…where it is.'), ('When does it start?', '…when it starts.'), ('Is it free?', '…if it is free.')], w),
    W('Do you know where the nearest bank is?', ['does', 'can'], w),
    O('I wonder who sent this letter.', 'When who is the subject, the order stays the same.'),
    L('Could you tell me how long the journey takes?', w),
]

w = 'Many verbs, adjectives and nouns are followed by a fixed preposition; learn them as one phrase.'
ITEMS['Prepositions after words'] = [
    C('Choose the correct phrase.', 'interested in music', ['interested on music', 'interested for music'], w),
    C('Choose the correct sentence.', 'It depends on the weather.', ['It depends of the weather.', 'It depends from the weather.'], w),
    C('Choose the correct sentence.', 'She is afraid of spiders.', ['She is afraid from spiders.', 'She is afraid with spiders.'], w),
    C('Choose the correct sentence.', 'I’m looking forward to the holidays.', ['I’m looking forward for the holidays.', 'I’m looking forward at the holidays.'], w),
    C('Choose the correct sentence.', 'He apologised for being late.', ['He apologised of being late.', 'He apologised to being late.'], 'Apologise to a person for something.'),
    C('Choose the correct sentence.', 'We are proud of our team.', ['We are proud for our team.', 'We are proud on our team.'], w),
    C('Choose the correct sentence.', 'Can you explain this rule to me?', ['Can you explain me this rule?', 'Can you explain this rule for me how?'], 'Explain something to someone.'),
    C('Choose the correct sentence.', 'There is a big difference between the two plans.', ['There is a big difference of the two plans.', 'There is a big difference among of the two plans.'], 'A difference between two things.'),
    F('I’m very good ___ remembering names.', 'at', 'Good at, bad at.'),
    F('Please listen ___ the instructions carefully.', 'to', 'Listen to someone or something.'),
    E('She is married with a doctor.', 'She is married to a doctor.', 'Married to a person.'),
    E('I agree to you completely.', 'I agree with you completely.', 'Agree with a person; agree to a plan or request.'),
    M('Match each word with its preposition.', [('worried', 'about'), ('responsible', 'for'), ('similar', 'to'), ('rely', 'on')], w),
    W('He is tired of waiting for the bus.', ['from', 'with'], 'Tired of something; wait for something.'),
    O('Who does this umbrella belong to?', 'Belong to a person; the preposition can end a question.'),
    L('I’m not very keen on horror films.', w),
]

w = 'Some verbs take -ing, some take to + verb, and a few change meaning with each.'
ITEMS['Gerunds and infinitives'] = [
    C('Choose the correct sentence.', 'I enjoy cooking for my friends.', ['I enjoy to cook for my friends.', 'I enjoy cook for my friends.'], 'Enjoy is followed by -ing.'),
    C('Choose the correct sentence.', 'We decided to stay at home.', ['We decided staying at home.', 'We decided stay at home.'], 'Decide is followed by to + verb.'),
    C('Choose the correct sentence.', 'Swimming is good exercise.', ['Swim is good exercise.', 'To swimming is good exercise.'], 'An -ing form can be the subject of a sentence.'),
    C('Choose the correct sentence.', 'She is good at solving problems.', ['She is good at solve problems.', 'She is good at to solve problems.'], 'After a preposition, use -ing.'),
    C('Choose the sentence that means you stopped smoking.', 'I stopped smoking last year.', ['I stopped to smoke last year.', 'I stopped smoke last year.'], 'Stop + -ing ends an activity; stop + to means stop in order to do something.'),
    C('Choose the sentence about something you must not forget to do.', 'Remember to lock the door.', ['Remember locking the door.', 'Remember lock the door.'], 'Remember to do: do it later. Remember doing: recall a past action.'),
    C('Choose the correct sentence.', 'Would you like to come with us?', ['Would you like coming with us?', 'Would you like come with us?'], 'Would like is followed by to + verb.'),
    C('Choose the correct sentence.', 'He avoided answering the question.', ['He avoided to answer the question.', 'He avoided answer the question.'], 'Avoid is followed by -ing.'),
    F('I hope ___ see you again soon.', 'to', 'Hope is followed by to + verb.'),
    F('Do you mind ___ the window? (open)', 'opening', 'Mind is followed by -ing.'),
    E('I want learning French.', 'I want to learn French.', 'Want is followed by to + verb.'),
    E('Thank you for help me.', 'Thank you for helping me.', 'After for, use -ing.'),
    M('Match each phrase with its meaning.', [('stop smoking', 'quit the habit'), ('stop to smoke', 'pause in order to smoke'), ('remember to call', 'not forget to call later'), ('remember calling', 'recall a call you made')], w),
    W('She keeps forgetting her password.', ['to', 'forget'], 'Keep is followed by -ing.'),
    O('We are planning to visit Japan.', 'Plan is followed by to + verb.'),
    L('I’m thinking about changing my job.', w),
]

w = 'A phrasal verb is a verb plus a small word; together they have one meaning.'
ITEMS['Phrasal verbs'] = [
    C('Which phrasal verb means to stop doing a habit?', 'give up', ['give in', 'give out'], w),
    C('Which phrasal verb means to search for information?', 'look up', ['look after', 'look out'], w),
    C('Choose the sentence that means to take care of someone.', 'She looks after her little brother.', ['She looks for her little brother.', 'She looks up her little brother.'], w),
    C('Choose the correct sentence with a pronoun.', 'Turn it off, please.', ['Turn off it, please.', 'Turn it please off.'], 'With a separable phrasal verb, a pronoun goes between the verb and the particle.'),
    C('Which sentence means the meeting will not happen?', 'They called off the meeting.', ['They called up the meeting.', 'They called back the meeting.'], 'Call off means cancel.'),
    C('Which phrasal verb means to have a good relationship?', 'get on with', ['get over with', 'get by with'], w),
    C('Choose the sentence that means you will not tolerate it any more.', 'I won’t put up with this noise.', ['I won’t put off this noise.', 'I won’t put on this noise.'], 'Put up with means tolerate.'),
    C('Choose the sentence that means you arrived without warning.', 'My cousin turned up at midnight.', ['My cousin turned down at midnight.', 'My cousin turned over at midnight.'], 'Turn up means arrive or appear.'),
    F('Don’t give ___! You can do it.', 'up', w),
    F('Can you pick me ___ from the station at six?', 'up', 'Pick someone up: collect them.'),
    E('I need to put off them until Friday.', ['I need to put them off until Friday.'], 'A pronoun goes between the verb and the particle.'),
    E('She turned down it because the pay was low.', ['She turned it down because the pay was low.'], 'A pronoun goes before the particle: turned it down.'),
    M('Match each phrasal verb with its meaning.', [('find out', 'discover'), ('run out of', 'have none left'), ('set up', 'start or arrange'), ('come across', 'find by chance')], w),
    W('We ran out of milk this morning.', ['over', 'with'], w),
    O('Please fill in this form.', 'Fill in means complete a form.'),
    L('I came across an old photo while I was cleaning.', w),
]

w = 'So + adjective, such + (a) adjective + noun; too means more than enough; enough comes after an adjective.'
ITEMS['So, such, too and enough'] = [
    C('Choose the correct sentence.', 'The film was so long that I fell asleep.', ['The film was such long that I fell asleep.', 'The film was so a long that I fell asleep.'], 'So goes before an adjective on its own.'),
    C('Choose the correct sentence.', 'It was such a beautiful day.', ['It was so a beautiful day.', 'It was such beautiful day.'], 'Such a goes before adjective + singular noun.'),
    C('Choose the correct sentence.', 'They are such kind people.', ['They are such a kind people.', 'They are so kind people.'], 'With a plural noun, use such without a.'),
    C('Choose the sentence that means the coffee is more hot than you want.', 'This coffee is too hot to drink.', ['This coffee is hot enough to drink.', 'This coffee is very hot to drink.'], 'Too + adjective + to: it is not possible because of the degree.'),
    C('Choose the correct sentence.', 'He isn’t old enough to drive.', ['He isn’t enough old to drive.', 'He isn’t old too to drive.'], 'Enough goes after an adjective.'),
    C('Choose the correct sentence.', 'Do we have enough chairs?', ['Do we have chairs enough for?', 'Do we have too chairs?'], 'Enough goes before a noun.'),
    C('Choose the correct sentence.', 'There are too many people in this room.', ['There are too much people in this room.', 'There are so much people in this room.'], 'Too many with countable nouns, too much with uncountable nouns.'),
    C('Choose the correct sentence.', 'I was so tired that I went to bed at eight.', ['I was such tired that I went to bed at eight.', 'I was too tired that I went to bed at eight.'], 'So + adjective + that shows a result.'),
    F('The box is ___ heavy for me to lift.', 'too', w),
    F('She speaks ___ quickly that I can’t follow her.', 'so', 'So also goes before an adverb.'),
    E('The question was enough easy for everyone.', 'The question was easy enough for everyone.', 'Enough goes after the adjective.'),
    E('We had so a good time at the party.', 'We had such a good time at the party.', 'Before a + adjective + noun, use such.'),
    M('Match each start with a natural ending.', [('It was such a', 'cold night.'), ('It was so', 'cold.'), ('It wasn’t warm', 'enough.'), ('It was too cold', 'to swim.')], w),
    W('The shelf is too high for me to reach.', ['enough', 'so'], w),
    O('Is the room big enough for twenty people?', w),
    L('It was such an interesting talk that nobody left early.', w),
]

# ───────────────────────── Intermediate ─────────────────────────

w = 'Present perfect links the past to now; the continuous form stresses how long an activity has been going on.'
ITEMS['Present perfect simple and continuous'] = [
    C('Choose the sentence about experience in your life.', 'I have visited Egypt twice.', ['I visited Egypt twice already now.', 'I have been visiting Egypt twice.'], 'For a number of times, use the present perfect simple.'),
    C('Choose the sentence that stresses a long activity until now.', 'I have been waiting for an hour.', ['I have waited since an hour.', 'I am waiting for an hour.'], 'Have been + -ing + for shows how long an activity has continued.'),
    C('Choose the correct sentence with since.', 'She has worked here since 2020.', ['She has worked here for 2020.', 'She works here since 2020.'], 'Since + a point in time; for + a length of time.'),
    C('Choose the sentence about a finished time.', 'I saw that film last night.', ['I have seen that film last night.', 'I have been seeing that film last night.'], 'With a finished time such as last night, use the past simple.'),
    C('Your hands are dirty because of an activity just now. Choose the sentence.', 'I’ve been fixing the car.', ['I’ve fixed the car for hours since.', 'I fix the car.'], 'The continuous form explains a present result of a recent activity.'),
    C('Choose the sentence about a result you can see now.', 'Someone has broken the window.', ['Someone has been breaking the window.', 'Someone broke the window tomorrow.'], 'A single completed action with a present result uses the simple form.'),
    C('Choose the correct question.', 'How long have you known Sara?', ['How long have you been knowing Sara?', 'How long do you know Sara?'], 'State verbs like know use the simple form, even for duration.'),
    C('Choose the correct sentence with yet.', 'Have you finished your homework yet?', ['Did you finish your homework already yet?', 'Have you finished yet your homework?'], 'Yet usually goes at the end of a question or negative.'),
    F('We have lived in this flat ___ six years.', 'for', 'For + a length of time.'),
    F('I’ve ___ been to Australia. (at no time in my life)', 'never', w),
    E('I have been knowing him since school.', 'I have known him since school.', 'Know is a state verb, so use the simple form.'),
    E('She has gone to the bank yesterday.', ['She went to the bank yesterday.'], 'Yesterday is a finished time, so use the past simple.'),
    M('Match each word with what it shows.', [('for', 'a length of time'), ('since', 'a starting point'), ('yet', 'expected but not happened'), ('already', 'sooner than expected')], 'These words often go with the present perfect.'),
    W('They have been building that bridge for two years.', ['since', 'built'], w),
    O('Have you ever eaten Korean food?', 'Ever asks about any time in your life.'),
    L('I have just sent you the report.', 'Just goes between have and the past participle.'),
]

w = 'The past perfect shows that one past action happened before another past action.'
ITEMS['Past perfect simple and continuous'] = [
    C('Choose the sentence that shows the film started first.', 'When we arrived, the film had already started.', ['When we arrived, the film already started after.', 'When we had arrived, the film starts.'], w),
    C('Choose the correct sentence.', 'She was tired because she had been running.', ['She was tired because she has been running.', 'She was tired because she had been run.'], 'Had been + -ing explains a past situation by an earlier activity.'),
    C('Choose the correct past perfect form.', 'I had never seen snow before that winter.', ['I have never seen snow before that winter.', 'I had never saw snow before that winter.'], 'Had + past participle: seen, not saw.'),
    C('Choose the sentence where the order is clear without the past perfect.', 'I closed the window and went to bed.', ['I had closed the window after I went to bed.', 'I closed the window after I had gone to bed first before.'], 'When actions are told in order, the past simple is enough.'),
    C('Choose the correct sentence.', 'By the time the police came, the thief had escaped.', ['By the time the police came, the thief has escaped.', 'By the time the police had came, the thief escaped.'], 'By the time + past simple, then the earlier action in the past perfect.'),
    C('Choose the correct question.', 'Had you met him before the party?', ['Did you had met him before the party?', 'Have you met him before the party yesterday?'], 'Questions put had before the subject.'),
    C('Choose the sentence about an activity that lasted until a past moment.', 'They had been living there for ten years when the house burned down.', ['They have been living there for ten years when the house burned down.', 'They had lived there since ten years when the house burned down.'], 'Had been + -ing + for: how long something continued before a past event.'),
    C('Choose the correct reported sentence.', 'He told me he had lost his wallet.', ['He told me he has lost his wallet yesterday.', 'He told me he had lose his wallet.'], 'Reported speech often moves a past action back to the past perfect.'),
    F('I couldn’t get in because I ___ forgotten my key.', 'had', w),
    F('Her eyes were red. She had been ___. (cry)', 'crying', 'Had been + -ing.'),
    E('When I got to the station, the train has left.', ['When I got to the station, the train had left.', 'When I got to the station, the train had already left.'], 'The earlier past action needs had + past participle.'),
    E('He had went home before I arrived.', 'He had gone home before I arrived.', 'The past participle of go is gone.'),
    M('Match each start with its ending.', [('The ground was wet', 'because it had been raining.'), ('I didn’t recognise her', 'because she had changed so much.'), ('He was nervous', 'because he had never flown before.')], w),
    W('She had already eaten when I called.', ['has', 'ate'], w),
    O('How long had you been waiting?', 'The question asks about duration before a past moment.'),
    L('We had been driving for hours when we finally found a hotel.', w),
]

w = 'Future continuous for actions in progress at a future time; future perfect for actions finished before a future time.'
ITEMS['Future continuous and future perfect'] = [
    C('Choose the sentence about an action in progress at ten tomorrow.', 'At ten tomorrow I’ll be sitting an exam.', ['At ten tomorrow I’ll have sit an exam.', 'At ten tomorrow I sit an exam yesterday.'], 'Will be + -ing: in progress at a future moment.'),
    C('Choose the sentence about something finished before Friday.', 'I’ll have finished the report by Friday.', ['I’ll be finished the report by Friday.', 'I’ll have finish the report by Friday.'], 'Will have + past participle: complete before a future time.'),
    C('Choose the polite question about plans.', 'Will you be using the car this evening?', ['Will you have use the car this evening?', 'Are you will using the car this evening?'], 'The future continuous can ask politely about someone’s plans.'),
    C('Choose the correct sentence with by.', 'By 2030, they will have built the new airport.', ['By 2030, they will be build the new airport.', 'By 2030, they have built the new airport.'], 'By + future time often goes with the future perfect.'),
    C('Choose the correct sentence.', 'Don’t call at eight; we’ll be having dinner.', ['Don’t call at eight; we’ll have had dinner since.', 'Don’t call at eight; we have dinner.'], w),
    C('Choose the correct sentence about duration.', 'Next month I will have worked here for five years.', ['Next month I will work here since five years.', 'Next month I have worked here for five years.'], 'Will have + past participle + for: duration up to a future point.'),
    C('Choose the correct negative.', 'She won’t have arrived by noon.', ['She won’t has arrived by noon.', 'She won’t have arrive by noon.'], w),
    C('Choose the correct sentence.', 'This time next week, we’ll be lying on a beach.', ['This time next week, we’ll have lie on a beach.', 'This time next week, we lie on a beach.'], 'This time next week often goes with the future continuous.'),
    F('By the time you get home, I’ll have ___ dinner. (cook)', 'cooked', 'Will have + past participle.'),
    F('Don’t worry, I’ll ___ waiting for you at the gate.', 'be', 'Will be + -ing.'),
    E('By next year I will finish my degree already.', ['By next year I will have finished my degree.', 'By next year I will already have finished my degree.'], 'By + future time needs will have + past participle.'),
    E('At midnight I will sleeping.', ['At midnight I will be sleeping.'], 'The future continuous needs will be + -ing.'),
    M('Match each sentence with its meaning.', [('I’ll be working at six.', 'in progress at six'), ('I’ll have worked by six.', 'finished before six'), ('I’ll work at six.', 'start at six')], w),
    W('By June, she will have saved enough money.', ['be', 'saving'], w),
    O('Will you be coming to the meeting?', 'A polite question about plans.'),
    L('In ten years, robots will be doing much of this work.', w),
]

w = 'A noun clause does the job of a noun; it often begins with that, what, whether or a question word.'
ITEMS['Noun clauses'] = [
    C('Choose the correct sentence.', 'What you said was very helpful.', ['What did you say was very helpful.', 'That what you said was very helpful.'], 'A noun clause can be the subject; it uses statement order.'),
    C('Choose the correct sentence.', 'I think that she is right.', ['I think what she is right.', 'I think that is she right.'], 'That introduces a statement as an object; it can often be left out.'),
    C('Choose the correct sentence.', 'Whether we go depends on the weather.', ['If we go it depends on the weather.', 'Whether do we go depends on the weather.'], 'Use whether, not if, at the start of a subject clause.'),
    C('Choose the correct sentence.', 'The problem is that we have no time.', ['The problem is what we have no time.', 'The problem is that have we no time.'], 'That + clause can follow be.'),
    C('Choose the correct sentence.', 'I can’t remember where I parked the car.', ['I can’t remember where did I park the car.', 'I can’t remember where parked I the car.'], 'Question words inside a sentence use statement order.'),
    C('Choose the correct sentence.', 'It is surprising that he didn’t call.', ['It is surprising what he didn’t call.', 'It is surprising that didn’t he call.'], 'It + adjective + that-clause is a common pattern.'),
    C('Choose the sentence where what means the thing that.', 'This is exactly what I needed.', ['This is exactly that I needed.', 'This is exactly which I needed.'], 'What can mean the thing that.'),
    C('Choose the correct sentence.', 'Nobody knows who will win.', ['Nobody knows who will win it who.', 'Nobody knows who does win will.'], 'A question word can introduce a noun clause as the object.'),
    F('I’m not sure ___ I can come. (yes or no)', ['whether', 'if'], 'Whether or if introduces a yes/no idea.'),
    F('___ he told you is not true.', 'What', 'What + clause can be the subject.'),
    E('I don’t understand what does this mean.', 'I don’t understand what this means.', 'Use statement order after the question word.'),
    E('The fact what she resigned surprised everyone.', 'The fact that she resigned surprised everyone.', 'The fact is followed by that.'),
    M('Match each word with its job in a noun clause.', [('that', 'introduces a statement'), ('whether', 'introduces a yes/no idea'), ('what', 'means the thing that')], w),
    W('Do you know why the meeting was cancelled?', ['did', 'has'], w),
    O('How she did it remains a mystery.', 'The noun clause is the subject.'),
    L('She explained that the project would be delayed.', w),
]

# ───────────────────────── Advanced ─────────────────────────

w = 'The passive uses be in the right tense + past participle; the object of the active sentence becomes the subject.'
ITEMS['The passive in every tense'] = [
    C('Choose the present continuous passive.', 'The road is being repaired.', ['The road is repairing.', 'The road is be repaired.'], 'Is/are being + past participle.'),
    C('Choose the present perfect passive.', 'The tickets have been sold.', ['The tickets have sold by.', 'The tickets have being sold.'], 'Have/has been + past participle.'),
    C('Choose the past perfect passive.', 'The house had been sold before we saw it.', ['The house had sold before we saw it.', 'The house had being sold before we saw it.'], 'Had been + past participle.'),
    C('Choose the future passive.', 'The results will be announced tomorrow.', ['The results will announced tomorrow.', 'The results will be announce tomorrow.'], 'Will be + past participle.'),
    C('Choose the modal passive.', 'This form must be signed by a parent.', ['This form must signed by a parent.', 'This form must be sign by a parent.'], 'Modal + be + past participle.'),
    C('Choose the impersonal passive.', 'It is said that the castle is haunted.', ['It says that the castle is haunted by people.', 'It is saying that the castle is haunted.'], 'It is said/believed that… reports what people in general say.'),
    C('Choose the sentence with the same meaning: “People believe he is in Spain.”', 'He is believed to be in Spain.', ['He believes to be in Spain.', 'He is believed being in Spain.'], 'Subject + is believed to + verb.'),
    C('Choose the past continuous passive.', 'The room was being cleaned when I arrived.', ['The room was cleaning when I arrived.', 'The room was been cleaned when I arrived.'], 'Was/were being + past participle.'),
    F('The bridge ___ built in 1890.', 'was', 'Past simple passive: was/were + past participle.'),
    F('Your order has ___ sent. (send)', 'been', 'Has been + past participle.'),
    E('The letter was wrote by my grandmother.', 'The letter was written by my grandmother.', 'Use the past participle written.'),
    E('The new hospital will opened next year.', 'The new hospital will be opened next year.', 'Will be + past participle.'),
    M('Match each tense with its passive form.', [('present simple', 'is made'), ('past simple', 'was made'), ('present perfect', 'has been made'), ('future', 'will be made')], w),
    W('The meeting has been postponed until Monday.', ['postpone', 'being'], w),
    O('Why was the flight cancelled?', 'Question: was + subject + past participle.'),
    L('The winners will be contacted by email.', w),
]

w = 'A cleft sentence splits one idea into two clauses to focus on one part: It was… that…, What… is….'
ITEMS['Cleft sentences'] = [
    C('Focus on who found the key. Choose the sentence.', 'It was Maya who found the key.', ['It was Maya found who the key.', 'Was Maya that found the key.'], 'It + be + focus + who/that + rest.'),
    C('Focus on the time. Choose the sentence.', 'It was on Monday that we met.', ['It was on Monday when that we met.', 'On Monday it was we met that.'], w),
    C('Focus on what you need. Choose the sentence.', 'What I need is a long holiday.', ['What I need it is a long holiday.', 'That I need is a long holiday.'], 'What + clause + be + focus.'),
    C('Choose the correct cleft sentence.', 'What surprised me was his honesty.', ['What surprised me were his honesty.', 'What did surprise me was his honesty.'], 'The verb agrees with the focused singular phrase.'),
    C('Focus on an action. Choose the sentence.', 'What we did was call the police.', ['What we did was we called the police that.', 'What we did it was call the police.'], 'What + subject + did + was + base verb.'),
    C('Choose the sentence that corrects a mistake politely.', 'It wasn’t Tom who broke it; it was me.', ['It wasn’t Tom which broke it; it was me.', 'It wasn’t Tom broke it who; it was me.'], 'Use who for people in it-clefts.'),
    C('Choose the correct sentence.', 'All I want is some peace and quiet.', ['All what I want is some peace and quiet.', 'All I want it is some peace and quiet.'], 'All + clause + be + focus means the only thing.'),
    C('Choose the correct sentence.', 'The reason why I called is to say thank you.', ['The reason why I called it is to say thank you.', 'The reason of why I called is to say thank you.'], 'The reason (why)… is… is another cleft pattern.'),
    F('It ___ my sister who taught me to swim.', 'was', w),
    F('___ I love about this city is the food.', 'What', w),
    E('What I really need it is more time.', 'What I really need is more time.', 'Do not repeat the subject with it.'),
    E('It was in Paris where that they got married.', ['It was in Paris that they got married.', 'It was in Paris where they got married.'], 'Use that (or where) once, not both.'),
    M('Match each plain sentence with its cleft form.', [('Sam called.', 'It was Sam who called.'), ('I want tea.', 'What I want is tea.'), ('We left at six.', 'It was at six that we left.')], w),
    W('It was the noise that kept me awake.', ['who', 'what'], w),
    O('What matters most is your health.', w),
    L('It was only later that I understood what she meant.', w),
]

w = 'Ellipsis leaves out words the listener can recover; substitution replaces them with so, not, do, one or ones.'
ITEMS['Ellipsis and substitution'] = [
    C('“Is it going to rain?” Choose the natural reply that means yes.', 'I think so.', ['I think it.', 'I think yes so.'], 'So replaces a whole clause after think, hope and expect.'),
    C('“Will they be late?” Choose the natural reply that means no.', 'I hope not.', ['I don’t hope so.', 'I hope no.'], 'Hope not is the negative; I don’t hope so is not used.'),
    C('Choose the sentence that avoids repeating the noun.', 'I don’t like the red shirt; I prefer the blue one.', ['I don’t like the red shirt; I prefer the blue.', 'I don’t like the red shirt; I prefer the blue it.'], 'One replaces a singular countable noun.'),
    C('Choose the correct sentence.', 'These shoes are nice, but the black ones are cheaper.', ['These shoes are nice, but the black one are cheaper.', 'These shoes are nice, but the black are cheaper ones.'], 'Ones replaces a plural noun.'),
    C('Choose the sentence that avoids repeating the verb phrase.', 'She speaks Italian, and so does her brother.', ['She speaks Italian, and so speaks her brother.', 'She speaks Italian, and so is her brother.'], 'So + auxiliary + subject means also.'),
    C('Choose the correct reply to “I can’t swim.”', 'Neither can I.', ['Neither I can.', 'So can’t I.'], 'Neither + auxiliary + subject agrees with a negative.'),
    C('Choose the natural short reply to “Have you finished?”', 'Yes, I have.', ['Yes, I have finished it done.', 'Yes, I finished have.'], 'A short answer keeps the auxiliary and leaves out the rest.'),
    C('Choose the sentence with natural ellipsis.', 'I wanted to stay, but I couldn’t.', ['I wanted to stay, but I couldn’t it.', 'I wanted to stay, but I couldn’t so.'], 'After a modal, the repeated verb can be left out.'),
    F('“Is the shop open on Sunday?” “I don’t think ___.”', 'so', w),
    F('I’ve lost my pen. Can you lend me ___?', 'one', 'One replaces a pen.'),
    E('Will it rain? I don’t think it.', ['Will it rain? I don’t think so.'], 'Use so, not it, to replace a clause.'),
    E('He likes jazz, and so I do.', 'He likes jazz, and so do I.', 'After so, put the auxiliary before the subject.'),
    M('Match each remark with a natural reply.', [('I love this song.', 'So do I.'), ('I didn’t see it.', 'Neither did I.'), ('Is it true?', 'I’m afraid so.')], w),
    W('She said she would help, and she did.', ['so', 'it'], 'Did replaces the whole verb phrase.'),
    O('Which one would you like?', 'One replaces a noun already mentioned.'),
    L('You don’t have to come, but I hope you will.', w),
]
