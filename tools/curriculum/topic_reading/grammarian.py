"""Grammarian reading pages (Phase 13). Original wording, written 2026-10-26.
Topic order and level follow the Core Inventory and CEFR Companion Volume; no text is copied."""

READING = {
# ───────────────────────── Starter ─────────────────────────
'Nouns': [
    ('Common and proper nouns',
     'A noun is a word that names something: a person (teacher), a place (kitchen), a thing (phone) or an idea (luck). '
     'Most nouns are common nouns. They name any member of a group, so they start with a small letter unless they begin a sentence: '
     'a city, the river, my brother. A proper noun is the name of one particular person, place, day, month, company or event. '
     'It always starts with a capital letter, even in the middle of a sentence: London, the Amazon, Friday, July, Toyota. '
     'A quick test: if you can put "a" or "the" in front of it and it still means any one of many, it is common. '
     'If it is a name that points to one thing only, it is proper.',
     [('Common nouns', 'My aunt works in a bakery near the station.', 'aunt, bakery and station could be any aunt, bakery or station.'),
      ('Proper nouns', 'Aunt Rosa works at Lim’s Bakery in Leeds.', 'Each capital letter marks a name of one particular person, shop or city.'),
      ('Days and months', 'We fly to Lisbon on a Monday in April.', 'Days, months and cities are proper nouns in English, so they take capitals.')]),
    ('Singular and plural',
     'Singular means one; plural means more than one. Most nouns simply add -s: car, cars; idea, ideas. '
     'Nouns that end in -s, -ss, -sh, -ch, -x or -z add -es, because the extra syllable makes them easier to say: glass, glasses; dish, dishes; watch, watches. '
     'A consonant followed by -y changes to -ies (baby, babies), but a vowel followed by -y just adds -s (day, days; key, keys). '
     'Many nouns ending in -f or -fe change to -ves: knife, knives; leaf, leaves; half, halves. '
     'A small group of common nouns are irregular and must be learned: man, men; woman, women; child, children; person, people; foot, feet; tooth, teeth; mouse, mice. '
     'A few stay the same in both forms: sheep, fish, deer.',
     [('Add -es', 'Two buses stopped outside the church.', 'bus ends in -s, so it adds -es.'),
      ('Consonant + y', 'The libraries in both cities open at nine.', 'library and city change -y to -ies.'),
      ('Irregular', 'Three women and their children waited by the gate.', 'woman → women and child → children do not add -s.')]),
    ('Kinds of nouns',
     'Nouns can also be grouped by what they name. Concrete nouns name things you can see, hear, touch, taste or smell: chair, music, rain, coffee. '
     'Abstract nouns name ideas, feelings and qualities you cannot touch: freedom, fear, honesty, advice. '
     'Collective nouns name a group as one unit: team, family, audience, staff, class. In American English they usually take a singular verb (The team is ready); '
     'in British English a plural verb is also common when you think of the members (The team are arguing). '
     'Compound nouns are made of two or more words working as one noun. They can be written as one word (toothbrush), as two words (bus stop) or with hyphens (mother-in-law). '
     'Knowing the kind helps you choose articles and quantities: many abstract nouns are uncountable, so we say "some patience", not "a patience".',
     [('Abstract noun', 'Her honesty surprised everyone.', 'honesty is a quality, not something you can touch.'),
      ('Collective noun', 'The audience is waiting for the band.', 'audience names many people as one group.'),
      ('Compound noun', 'I left my sunglasses at the bus stop.', 'sunglasses is one word; bus stop is two words acting as one noun.')]),
    ('Countable and uncountable',
     'Countable nouns have a singular and a plural and can follow a number: one apple, three apples. '
     'Uncountable nouns have no plural and do not take a or an: water, rice, money, furniture, information, advice, homework. '
     'Use many and a few with countable nouns (many questions, a few chairs), and much and a little with uncountable nouns (much time, a little sugar). '
     'A lot of and some work with both. In questions and negatives we usually use any: "Is there any milk?" "We don’t have any eggs." '
     'To count an uncountable noun, put a counting word in front: a glass of water, a piece of advice, two pieces of information, a bottle of oil. '
     'Some nouns are both, with a change of meaning: "a coffee" (one cup) and "coffee" (the drink in general); "a light" (a lamp) and "light" (brightness).',
     [('Uncountable', 'Can you give me some advice about the course?', 'advice has no plural, so it takes some, not an.'),
      ('Few and little', 'We have a few eggs but only a little flour.', 'eggs can be counted; flour cannot.'),
      ('Counting word', 'She gave me two useful pieces of information.', 'pieces of turns uncountable information into something you can count.')]),
],
'Pronouns': [
    ('Personal pronouns',
     'A pronoun takes the place of a noun so we do not repeat it: "Sara called. She was late." '
     'Subject pronouns come before the verb and do the action: I, you, he, she, it, we, they. '
     'Object pronouns come after a verb or a preposition and receive the action: me, you, him, her, it, us, them. '
     'Compare "She helped us" with "We helped her". A useful check in pairs: take the other person away. '
     '"Tom and me went home" sounds wrong once you remove Tom ("me went home"), so the correct form is "Tom and I went home". '
     'In the same way, "between you and me" is correct because between is a preposition and needs an object pronoun. '
     'Use they for people in general, for a group, and for one person whose gender you do not know or who uses they.',
     [('Subject', 'They meet us at the café every Friday.', 'They does the meeting; us receives it.'),
      ('After a preposition', 'Please keep this between you and me.', 'between needs the object form me.'),
      ('Remove the other person', 'My brother and I painted the kitchen.', 'Without "my brother", you would say "I painted", so I is right.')]),
    ('Possessives',
     'Possessive words show who something belongs to. Possessive adjectives come before a noun: my, your, his, her, its, our, their. '
     'Possessive pronouns stand alone, with no noun after them: mine, yours, his, hers, ours, theirs. '
     'Compare "This is my bag" with "This bag is mine". Notice that none of these words uses an apostrophe. '
     'It’s with an apostrophe always means it is or it has; its with no apostrophe shows possession: "The dog wagged its tail." '
     'In the same way, they’re means they are, there points to a place, and their shows possession. '
     'For nouns, add ’s to show possession (Ana’s phone, the teacher’s desk) and only an apostrophe after a plural -s (the students’ books).',
     [('Adjective + noun', 'Their flat is bigger than our flat.', 'their and our come before a noun.'),
      ('Pronoun alone', 'That umbrella isn’t mine; I think it’s hers.', 'mine and hers stand alone, with no apostrophe.'),
      ('Its', 'The company changed its logo last year.', 'its shows possession; it’s would mean it is.')]),
    ('More pronouns',
     'Reflexive pronouns end in -self or -selves and refer back to the subject: "She taught herself Spanish." '
     'They are also used for emphasis: "I fixed it myself." Do not use them instead of a simple object: "Send it to me", not "to myself". '
     'Demonstrative pronouns point: this and these for things near you, that and those for things further away. '
     'Indefinite pronouns refer to people or things in general: someone, anybody, everyone, nothing, each. They take a singular verb: "Everyone is here." '
     'Relative pronouns (who, which, that, whose) join extra information to a noun: "the woman who called". '
     'Interrogative pronouns (who, what, which, whose) ask questions. Each kind does a different job, but all of them save you from repeating a noun.',
     [('Reflexive', 'The children made themselves a snack.', 'themselves refers back to the children.'),
      ('Demonstrative', 'These are mine, and those over there are yours.', 'these is near; those is further away.'),
      ('Indefinite', 'Somebody has left a coat on the train.', 'somebody takes the singular verb has.')]),
],
'Articles and determiners': [
    ('A, an and the',
     'A and an are indefinite articles. Use them with a singular countable noun when you mention something for the first time or mean any one: "I saw a fox." '
     'Choose by sound, not spelling: an before a vowel sound (an apple, an hour, an MP), a before a consonant sound (a book, a university, a one-way street). '
     'The is the definite article. Use it when both people know which one you mean: because it was mentioned before ("The fox ran away"), because there is only one (the sun, the internet), or because the rest of the sentence makes it clear (the book on the table). '
     'Use no article for plural or uncountable nouns in general statements: "Dogs need exercise." "Water boils at 100 degrees." '
     'Many fixed expressions also take no article: go to school, at home, by bus, have lunch.',
     [('First mention, then the', 'I bought a lamp and a rug. The lamp was cheap.', 'a introduces the lamp; the points back to it.'),
      ('Sound decides', 'It took an hour to find a uniform that fitted.', 'hour starts with a vowel sound; uniform starts with a "y" sound.'),
      ('General statement', 'Cats sleep for most of the day.', 'No article: cats in general, not particular cats.')]),
    ('Determiners and quantifiers',
     'A determiner comes before a noun and tells us which one or how much. Articles are determiners, and so are this/that/these/those, my/your/their, and quantity words. '
     'Quantifiers depend on whether the noun is countable. With plural countable nouns use many, a few, few, several, a number of. '
     'With uncountable nouns use much, a little, little, a great deal of. Some, any, a lot of, plenty of, no and enough work with both. '
     'A few and a little are positive (some, enough to be useful); few and little without a are negative (not enough): '
     '"I have a few friends here" sounds happy; "I have few friends here" sounds lonely. '
     'Each and every take a singular noun (every student), while all and both take a plural (all students, both hands).',
     [('Positive', 'There’s a little time left, so let’s finish the slide.', 'a little = some, enough to use.'),
      ('Negative', 'Few people came, so the hall felt empty.', 'few without a = not many, less than hoped.'),
      ('Every + singular', 'Every room has its own window.', 'every takes a singular noun and verb.')]),
],
'Adjectives and comparisons': [
    ('Adjectives',
     'An adjective describes a noun or pronoun. It can come before the noun (a quiet street) or after a linking verb such as be, look, seem, feel, become (the street is quiet; you look tired). '
     'English adjectives never change for plural or gender: a red car, two red cars. Do not add -s. '
     'Adjectives answer questions like what kind, which one, and how many: an old map, the last bus, three blue chairs. '
     'Some adjectives come from nouns or verbs and have typical endings: -ful (helpful), -less (careless), -ous (famous), -able (comfortable), -al (natural), -ive (active), -y (sunny). '
     'Recognising these endings helps you spot adjectives in a sentence and build your own.',
     [('Before the noun', 'We stayed in a small, friendly hotel.', 'small and friendly describe hotel.'),
      ('After a linking verb', 'The soup smells delicious.', 'smells is a linking verb, so it takes an adjective.'),
      ('No plural form', 'They have two young daughters.', 'young does not add -s for the plural noun.')]),
    ('Adjective order, -ed and -ing',
     'When several adjectives come before a noun, native speakers follow a usual order: opinion, size, age, shape, colour, origin, material, purpose, then the noun. '
     'So we say "a lovely old Italian leather bag", not "an Italian old leather lovely bag". Two or three adjectives are plenty in most sentences. '
     'Adjectives ending in -ed and -ing are easy to confuse. The -ed form describes how a person feels: bored, interested, tired, surprised. '
     'The -ing form describes the thing that causes the feeling: boring, interesting, tiring, surprising. '
     '"I was bored because the film was boring." If you say "I am boring", you are saying that you make other people bored.',
     [('Usual order', 'She wore a beautiful long green silk dress.', 'opinion – size – colour – material – noun.'),
      ('-ed feeling', 'The students were confused by the instructions.', 'confused describes how the students felt.'),
      ('-ing cause', 'The instructions were confusing.', 'confusing describes what caused the feeling.')]),
    ('Comparing things',
     'To compare two things, use a comparative + than. One-syllable adjectives add -er: tall, taller; cheap, cheaper. '
     'Double a final consonant after one short vowel (big, bigger) and change -y to -ier (easy, easier). '
     'Longer adjectives use more or less: more expensive, less comfortable. '
     'To pick out one thing from a group of three or more, use the superlative with the: the tallest, the easiest, the most expensive. '
     'Learn the irregular forms: good, better, the best; bad, worse, the worst; far, further, the furthest. '
     'To say two things are equal, use as + adjective + as: "My phone is as old as yours." In the negative, not as … as means less: "It isn’t as cold as yesterday."',
     [('Comparative', 'The train is faster and more comfortable than the bus.', 'fast + -er; comfortable is long, so it uses more.'),
      ('Superlative', 'This is the best pizza in town.', 'good → better → the best is irregular.'),
      ('Equal / not equal', 'The new flat isn’t as bright as the old one.', 'not as … as means less bright.')]),
],
'Adverbs': [
    ('What adverbs do',
     'An adverb describes a verb, an adjective, another adverb or a whole sentence. It answers questions such as how, when, where, how often and how much. '
     'Many adverbs of manner are formed by adding -ly to an adjective: quick, quickly; careful, carefully; happy, happily. '
     'Some common adverbs look exactly like adjectives: fast, hard, late, early, straight. "She works hard" (not "hardly"). '
     'Be careful: hardly means almost not, and lately means recently. Good is an adjective; its adverb is well: "She is a good singer. She sings well." '
     'Adverbs can also make adjectives stronger or weaker: very tired, quite good, extremely cold, a bit late.',
     [('Describes a verb', 'He closed the door quietly.', 'quietly tells us how he closed it.'),
      ('Good and well', 'You did a good job — you spoke really well.', 'good describes the noun job; well describes the verb spoke.'),
      ('Describes an adjective', 'The test was surprisingly easy.', 'surprisingly changes how easy we understand the test to be.')]),
    ('Kinds of adverbs and where they go',
     'Adverbs of manner (slowly, well) usually go after the verb or after the object: "She speaks English fluently", not "She speaks fluently English". '
     'Adverbs of frequency (always, usually, often, sometimes, rarely, never) go before the main verb but after be: "I often walk to work." "He is always late." '
     'Adverbs of time (today, yesterday, soon, already) and place (here, outside, upstairs) usually go at the end, or at the start for emphasis: "Tomorrow we leave." '
     'When several come together at the end, the usual order is manner, place, time: "She sang beautifully at the concert last night." '
     'Sentence adverbs such as unfortunately, honestly and clearly comment on the whole sentence and usually go first, followed by a comma.',
     [('Frequency', 'We usually have dinner at seven.', 'usually goes before the main verb have.'),
      ('Frequency with be', 'The shop is never open on Sundays.', 'With be, the adverb comes after the verb.'),
      ('Manner, place, time', 'He worked hard in the garden all afternoon.', 'how – where – when.')]),
],
'Conjunctions and interjections': [
    ('Coordinating conjunctions',
     'Conjunctions are joining words. Coordinating conjunctions join words, phrases or whole sentences of equal weight. '
     'The seven are easy to remember as FANBOYS: for, and, nor, but, or, yet, so. '
     'And adds information, but shows contrast, or gives a choice, so shows a result, yet means but surprisingly, nor adds a second negative, and for (formal) means because. '
     'When a coordinating conjunction joins two complete sentences, put a comma before it: "It was raining, so we stayed in." '
     'When it joins two short items, no comma is needed: "tea or coffee", "tired but happy".',
     [('Result', 'The road was closed, so we took the train.', 'so introduces the result; comma before it.'),
      ('Contrast', 'The flat is small but very bright.', 'but joins two adjectives that contrast.'),
      ('Choice', 'You can pay now or at the end of the month.', 'or offers two options.')]),
    ('Subordinating conjunctions and interjections',
     'Subordinating conjunctions introduce a clause that depends on another clause: because, although, when, while, if, unless, since, after, before, until. '
     'The clause they start cannot stand alone. "Because I was tired" is not a full sentence; it needs a main clause: "I went to bed early because I was tired." '
     'If the dependent clause comes first, put a comma after it: "Although it was late, we kept talking." '
     'Interjections are short words that show feeling or react quickly: oh, wow, oops, ouch, hey, well. '
     'They stand outside the grammar of the sentence and are followed by a comma or an exclamation mark: "Wow, that was fast!" They belong mostly in speech and informal writing.',
     [('Reason', 'We left early because the forecast was bad.', 'because introduces the reason; it cannot stand alone.'),
      ('Clause first', 'When the bell rings, put your pens down.', 'The dependent clause comes first, so a comma follows it.'),
      ('Interjection', 'Oops, I sent the email to the wrong person.', 'Oops shows a reaction and is followed by a comma.')]),
],
'Sentence building': [
    ('Subject and verb',
     'Every complete English sentence needs a subject and a verb. The subject is who or what the sentence is about; the verb says what the subject does or is. '
     '"Birds sing." "The meeting started." "I am hungry." English almost always needs a stated subject, even when the meaning is obvious: '
     'say "It is raining" and "It is three o’clock", with the empty subject it, not just "Is raining". '
     'The basic order is subject – verb – the rest. Questions and some special patterns change this order, but ordinary statements keep it. '
     'To find the subject, ask who or what before the verb: "Who started? The meeting."',
     [('Shortest sentence', 'Prices rose.', 'Prices is the subject; rose is the verb.'),
      ('Empty it', 'It is cold in here.', 'English needs a subject, so it fills the place.'),
      ('Longer subject', 'The woman in the red coat is my teacher.', 'The whole phrase "the woman in the red coat" is the subject.')]),
    ('Adding an object and more',
     'Many verbs need an object: the person or thing that receives the action. The order is subject – verb – object: "Kim plays the piano." '
     'Do not put an adverb between the verb and its object: "I like coffee very much", not "I like very much coffee". '
     'Some verbs take two objects, a person and a thing: give, send, show, tell, buy, lend. '
     'You can say "She gave me the key" or "She gave the key to me". '
     'Linking verbs such as be, become, seem and feel are followed by a complement, not an object; it describes the subject: "She became a doctor." "He seems calm." '
     'After the core, you can add place and time: "Kim plays the piano at school on Mondays."',
     [('Subject – verb – object', 'My neighbour repairs old bikes.', 'old bikes receives the action of repairs.'),
      ('Two objects', 'Can you send me the photos?', 'me is the person; the photos is the thing.'),
      ('Complement', 'The room felt warm.', 'warm describes the room; it is not an object.')]),
    ('Commands and requests',
     'A command (the imperative) uses the base form of the verb with no subject: "Sit down." "Turn left at the bank." "Be careful." '
     'For a negative command, add don’t: "Don’t touch that." "Don’t be late." '
     'Commands can sound too direct in English, so we soften them in most situations. Add please, or turn the command into a question with can, could or would: '
     '"Could you close the window, please?" "Would you mind waiting here?" (Would you mind is followed by -ing.) '
     'Let’s + base verb makes a suggestion that includes the speaker: "Let’s take a break." '
     'Commands are normal in instructions, recipes, signs and warnings, where short and clear is polite enough.',
     [('Instruction', 'Mix the flour and the eggs, then add milk.', 'Recipes use the base form with no subject.'),
      ('Polite request', 'Could you check this email for me, please?', 'Could you … please? is softer than a command.'),
      ('Suggestion', 'Let’s meet outside the cinema.', 'Let’s includes the speaker in the plan.')]),
],
'Be, have and do': [
    ('Am, is, are',
     'Be is the most common verb in English, and it is irregular. In the present: I am, you are, he/she/it is, we are, they are. '
     'In speech and informal writing we contract it: I’m, you’re, she’s, it’s, we’re, they’re. '
     'Use be for names, jobs, age, feelings, places and descriptions: "I’m Ana. I’m a nurse. I’m 30. I’m tired." Note that English uses be for age and for being hungry, cold or right: "I am 25", not "I have 25 years". '
     'For the negative, add not: "She isn’t here." "I’m not ready." '
     'For questions, move be in front of the subject: "Are you ready?" "Is it far?" Short answers repeat be: "Yes, I am." "No, it isn’t."',
     [('Age and feelings', 'My son is eight and he is always hungry.', 'English uses be, not have, for age and hunger.'),
      ('Negative', 'We aren’t at home this weekend.', 'aren’t = are not.'),
      ('Question', 'Is your office near the station?', 'is moves before the subject.')]),
    ('Have and has',
     'Have shows possession, relationships, illnesses and many everyday actions. In the present it is have for I, you, we, they and has for he, she and it. '
     '"I have two sisters." "She has a cold." "We have lunch at one." '
     'In British English you will also hear have got with the same meaning for possession: "I’ve got a car." '
     'For questions and negatives with ordinary have, use do or does: "Do you have a pen?" "He doesn’t have time." '
     'With have got, use have itself: "Have you got a pen?" "He hasn’t got time." Do not mix the two patterns: "Do you have…?" or "Have you got…?", never "Do you have got…?"',
     [('He / she / it', 'My brother has a small dog.', 'He, she and it take has.'),
      ('Everyday action', 'We usually have breakfast at seven.', 'have breakfast = eat breakfast.'),
      ('Question with do', 'Does your hotel have a pool?', 'does carries the question; have stays in the base form.')]),
    ('Do and does in questions',
     'Most verbs need a helper to make present simple questions. Use do with I, you, we, they and does with he, she, it. '
     'The order is (question word) + do/does + subject + base verb: "Do you like jazz?" "Where does she work?" '
     'Because does already shows the third person, the main verb loses its -s: "Does he play?" not "Does he plays?" '
     'Be does not use do: "Are you happy?" not "Do you are happy?" '
     'In questions about the subject itself, no do is needed: "Who lives here?" (the answer is the subject: "Maria lives here").',
     [('Yes/no question', 'Do they live near the park?', 'do + subject + base verb.'),
      ('Wh- question', 'What time does the film start?', 'does carries the -s, so start stays plain.'),
      ('Subject question', 'Who wants another coffee?', 'Who is the subject, so no do is used.')]),
    ('Don’t and doesn’t',
     'To make a present simple verb negative, put don’t (do not) or doesn’t (does not) before the base form. '
     'Use don’t with I, you, we, they and doesn’t with he, she, it: "I don’t eat meat." "She doesn’t drive." '
     'As in questions, the main verb loses its -s after doesn’t: "He doesn’t work on Fridays", not "He doesn’t works". '
     'Do not use don’t with be or with modal verbs: say "I’m not tired" and "I can’t swim". '
     'Do can also be the main verb, meaning perform an activity. Then you may see it twice: "I don’t do my homework at night." "What does she do?" (= What is her job?)',
     [('He / she / it', 'My phone doesn’t charge any more.', 'doesn’t + base verb charge, with no -s.'),
      ('Other subjects', 'We don’t watch much television.', 'we takes don’t.'),
      ('Do as main verb', 'He doesn’t do the dishes on Sundays.', 'doesn’t is the helper; do is the main verb.')]),
],
# ───────────────────────── Foundation ─────────────────────────
'Verbs': [
    ('Kinds of verbs',
     'Action verbs describe something someone does: run, write, decide. Linking verbs connect the subject to a description: be, seem, become, look, feel, sound. '
     'Auxiliary (helping) verbs work with a main verb to make tenses, questions and negatives: be, have, do. '
     'Modal verbs (can, could, will, would, should, must, may, might) add meaning such as ability, possibility or obligation and are followed by the base form. '
     'Verbs are also transitive or intransitive. A transitive verb needs an object: "She bought a ticket." An intransitive verb does not: "The baby slept." Many verbs can be both: "He opened the door" / "The door opened." '
     'Finally, state verbs describe situations rather than actions (know, like, believe, own, need) and are rarely used in continuous tenses: "I know", not "I am knowing".',
     [('Linking verb', 'The plan sounds good to me.', 'sounds links the plan to the description good.'),
      ('Auxiliary + main verb', 'They have finished the report.', 'have helps; finished is the main verb.'),
      ('State verb', 'I need a new charger.', 'need describes a state, so it stays simple, not continuous.')]),
    ('Regular and irregular verbs',
     'Regular verbs form the past simple and past participle with -ed: work, worked, worked; play, played, played. '
     'Spelling changes: add only -d after -e (live, lived), change consonant + y to -ied (study, studied), and double a final consonant after one stressed short vowel (stop, stopped; plan, planned). '
     'The -ed ending has three sounds: /t/ after voiceless sounds (walked), /d/ after voiced sounds (played) and /ɪd/ after t or d (wanted, needed). '
     'Irregular verbs have their own forms and must be learned: go, went, gone; take, took, taken; buy, bought, bought; put, put, put. '
     'The most common verbs in English are mostly irregular, so learning the top forty gives you most everyday sentences.',
     [('Spelling: double', 'The bus stopped and we planned our route.', 'stop and plan double the last consonant.'),
      ('Irregular past', 'She went to Rome and bought a hat.', 'go → went; buy → bought.'),
      ('Past participle', 'Have you ever taken the night train?', 'take → took → taken.')]),
    ('Phrasal verbs',
     'A phrasal verb is a verb plus one or two small words (particles) such as up, out, off, on, down, away: give up, find out, look after, run out of. '
     'The meaning is often different from the separate words, so learn each as a whole item: give up = stop trying; look after = take care of. '
     'Some phrasal verbs are separable: the object can go in the middle or after the particle: "Turn off the light" or "Turn the light off". '
     'But a pronoun object must go in the middle: "Turn it off", never "Turn off it". '
     'Others are inseparable; the object always follows: "She looks after her grandmother." "I ran into an old friend." '
     'A good dictionary shows which type a verb is, often with sb/sth in the position where the object goes.',
     [('Separable', 'Please fill in the form and hand it in.', 'The pronoun it goes between hand and in.'),
      ('Inseparable', 'We ran out of milk this morning.', 'ran out of cannot be split.'),
      ('New meaning', 'He finally gave up smoking.', 'give up means stop doing something.')]),
    ('Gerund or infinitive',
     'When one verb follows another, the second verb is either a gerund (-ing) or an infinitive (to + base form). The first verb decides. '
     'Verbs such as enjoy, avoid, finish, mind, suggest, keep and consider take -ing: "I enjoy cooking." '
     'Verbs such as want, decide, hope, plan, agree, promise, refuse and need take to: "We decided to leave." '
     'After a preposition, always use -ing: "She is good at drawing." "Thanks for coming." '
     'A few verbs take both with a change of meaning. "I stopped smoking" means I no longer smoke; "I stopped to smoke" means I stopped in order to smoke. '
     '"Remember to lock the door" is about the future; "I remember locking the door" is about a memory.',
     [('Verb + -ing', 'Do you mind waiting a few minutes?', 'mind is followed by -ing.'),
      ('Verb + to', 'They promised to call us tomorrow.', 'promise is followed by to + base verb.'),
      ('Change of meaning', 'I forgot to buy bread, so we have none.', 'forget to = not do it; forget doing = not remember a past action.')]),
],
'Prepositions': [
    ('Time and place',
     'Prepositions show how things relate in time and space. For time: use at for exact times and short moments (at 6 pm, at noon, at the weekend in British English), '
     'on for days and dates (on Monday, on 3 May, on my birthday), and in for longer periods (in July, in 2026, in the summer, in the morning). '
     'For place: use at for a point or a building as a place of activity (at the bus stop, at work, at the cinema), '
     'on for a surface or a line (on the table, on the wall, on the second floor, on Main Street), and in for an enclosed space or area (in the box, in the car, in Spain). '
     'Other useful prepositions: under, next to, between, opposite, behind, in front of, above, below. '
     'Learn fixed phrases as wholes: on the bus, in a taxi, at home, in bed, on time (punctual) and in time (early enough).',
     [('Time', 'The shop opens at nine on Saturdays in summer.', 'at an exact time, on a day, in a season.'),
      ('Place', 'Your keys are on the shelf in the kitchen.', 'on a surface; in a room.'),
      ('Fixed phrase', 'We got there just in time for the speech.', 'in time = early enough; on time = at the planned time.')]),
    ('Movement and fixed combinations',
     'Some prepositions show movement towards or through something: to (a destination), into (entering a space), onto (moving to a surface), out of, across, through, along, past, towards. '
     'Compare "She walked in the park" (her position) with "She walked into the park" (entering it). '
     'Arrive takes at for a building or point and in for a city or country: "We arrived at the hotel / in Rome", never "arrived to". '
     'Many adjectives, verbs and nouns are followed by a fixed preposition that must be learned with the word: good at, afraid of, interested in, depend on, listen to, wait for, a reason for, an increase in. '
     'When you learn a new word, learn its preposition too, and write the whole phrase in your notes.',
     [('Movement', 'The cat jumped onto the table and ran out of the room.', 'onto and out of show movement.'),
      ('Arrive', 'Our train arrived in Paris at noon.', 'arrive in a city; arrive at a place.'),
      ('Fixed combination', 'She is interested in history and good at maths.', 'interested in and good at are fixed pairs.')]),
],
'Questions': [
    ('Asking questions',
     'Yes/no questions put an auxiliary or be in front of the subject: "Are you ready?" "Can she swim?" "Did they call?" '
     'Wh- questions start with a question word and then follow the same order: question word + auxiliary + subject + main verb. '
     '"Where do you live?" "Why did he leave?" "How long have you been here?" '
     'Choose the question word for the information you want: who (person), what (thing), where (place), when (time), why (reason), which (choice from a set), whose (owner), how (way), how much/many (amount). '
     'When the question word is the subject, there is no auxiliary: "Who called you?" (someone called), but "Who did you call?" (you called someone). '
     'Indirect questions are more polite and use statement order: "Could you tell me where the station is?", not "where is the station".',
     [('Wh- question', 'When did you start learning English?', 'when + did + subject + base verb.'),
      ('Subject question', 'What happened at the meeting?', 'what is the subject, so no did.'),
      ('Indirect question', 'Do you know what time the bank closes?', 'Statement order: the bank closes.')]),
    ('Question tags and short answers',
     'A question tag is a short question added to the end of a statement, used to check information or invite agreement: "You’re coming, aren’t you?" '
     'Use the same auxiliary as the statement, or do/does/did if there is none. A positive statement takes a negative tag, and a negative statement takes a positive tag: '
     '"She lives here, doesn’t she?" "They didn’t call, did they?" The tag after I am is aren’t I. '
     'Falling intonation on the tag means you expect agreement; rising intonation means it is a real question. '
     'Short answers repeat the auxiliary rather than the whole verb: "Do you like it?" "Yes, I do." "Can she drive?" "No, she can’t." They sound more natural than just yes or no.',
     [('Positive → negative tag', 'It’s cold today, isn’t it?', 'is in the statement → isn’t in the tag.'),
      ('No auxiliary', 'You met him last year, didn’t you?', 'Past simple statement → did in the tag.'),
      ('Short answer', '"Have you finished?" "Yes, I have."', 'The answer repeats have.')]),
],
'Phrases, clauses and sentence structures': [
    ('Phrases and clauses',
     'A phrase is a group of words that works as one part of a sentence but has no subject-and-verb pair: the old red bus, in the morning, very quickly. '
     'A clause has a subject and a verb: "the bus arrived", "because it was late". '
     'Phrases are named after their main word: a noun phrase (a cup of tea), a verb phrase (has been waiting), a prepositional phrase (under the bridge), an adjective phrase (really proud of you). '
     'Knowing the difference helps you avoid fragments: "In the morning before work." is only phrases, so it is not a sentence. '
     'Add a clause and it becomes complete: "In the morning before work, I go for a run."',
     [('Noun phrase', 'A large cup of strong coffee helps me wake up.', 'The whole noun phrase is the subject.'),
      ('Prepositional phrase', 'We had lunch under the old oak tree.', 'under the old oak tree tells us where.'),
      ('Clause', 'The train left before we arrived.', 'Two clauses: the train left / we arrived.')]),
    ('Main and dependent clauses',
     'A main (independent) clause can stand alone as a sentence: "I stayed home." '
     'A dependent (subordinate) clause cannot; it begins with a word like because, when, if, although, who or that and depends on a main clause: "because I was ill". '
     'Dependent clauses do different jobs. Adverb clauses say when, why or under what condition: "If it rains, we’ll stay in." '
     'Relative clauses describe a noun: "the man who lives next door". Noun clauses act as a subject or object: "I know that she is right." '
     'When an adverb clause comes first, use a comma; when it comes after the main clause, usually no comma: "We’ll stay in if it rains."',
     [('Adverb clause first', 'Although the hotel was old, it was spotless.', 'The dependent clause comes first, so a comma follows.'),
      ('Relative clause', 'The book that you lent me is brilliant.', 'that you lent me describes the book.'),
      ('Noun clause', 'Nobody knows why the meeting was cancelled.', 'why the meeting was cancelled is the object of knows.')]),
    ('Four sentence structures',
     'A simple sentence has one main clause: "The guests arrived." It can still be long if it has many phrases. '
     'A compound sentence joins two main clauses with a coordinating conjunction (and, but, or, so) or a semicolon: "The guests arrived, and the music started." '
     'A complex sentence has one main clause and at least one dependent clause: "When the guests arrived, the music started." '
     'A compound-complex sentence has at least two main clauses and at least one dependent clause: "When the guests arrived, the music started, and everyone began to dance." '
     'Good writing mixes the four: short simple sentences for impact, compound sentences for balance, and complex ones to show how ideas depend on each other.',
     [('Simple', 'My grandfather grew tomatoes in his tiny garden.', 'One subject–verb pair: grandfather grew.'),
      ('Compound', 'The shop was closed, so we went home.', 'Two main clauses joined by so.'),
      ('Complex', 'Because the shop was closed, we went home.', 'A dependent because-clause plus one main clause.')]),
    ('Four sentence purposes',
     'Sentences are also grouped by what they do. A declarative sentence makes a statement and ends with a full stop: "The museum opens at ten." '
     'An interrogative sentence asks a question and ends with a question mark: "When does the museum open?" '
     'An imperative sentence gives a command, instruction or request: "Buy the tickets online." '
     'An exclamatory sentence shows strong feeling and ends with an exclamation mark, often beginning with what or how: "What a beautiful building!" "How fast she runs!" '
     'In formal writing most sentences are declarative; save exclamations for real emphasis.',
     [('Declarative', 'The last train leaves at midnight.', 'A statement ending in a full stop.'),
      ('Imperative', 'Keep your ticket until the end of the trip.', 'An instruction with no stated subject.'),
      ('Exclamatory', 'What a long day it has been!', 'What + noun phrase shows strong feeling.')]),
],
'Agreement and complete sentences': [
    ('Subject–verb agreement',
     'A verb must agree with its subject: a singular subject takes a singular verb and a plural subject takes a plural verb. In the present simple this mostly means the -s ending: "She works", "They work". '
     'Find the real subject and ignore phrases in between: "The box of old letters is in the attic" (the box is). '
     'Two subjects joined by and are plural: "Ana and Leo are here." With or and nor, the verb agrees with the nearer subject: "Either the manager or the assistants are coming." '
     'Indefinite pronouns such as everyone, somebody, each and nobody are singular: "Everybody wants a seat." '
     'With there is/there are, the verb agrees with the noun after it: "There are three messages for you."',
     [('Ignore the middle', 'The list of names is on the desk.', 'The subject is list, not names.'),
      ('Singular pronoun', 'Each of the rooms has a balcony.', 'Each is singular, so it takes has.'),
      ('There are', 'There are two reasons for the delay.', 'The verb agrees with reasons.')]),
    ('Fragments and run-ons',
     'A fragment is a group of words punctuated as a sentence but missing a subject, a verb or a main clause: "Because the bus was late." "Running for the train." '
     'Fix a fragment by joining it to a nearby sentence or by adding what is missing: "I was late because the bus was late." '
     'A run-on puts two main clauses together with no proper join. A comma splice uses only a comma: "It was late, we went home." '
     'Fix a run-on in one of four ways: a full stop ("It was late. We went home."), a comma + conjunction ("It was late, so we went home."), '
     'a semicolon ("It was late; we went home.") or a subordinating word ("Because it was late, we went home.").',
     [('Fragment fixed', 'We stayed inside because the storm was strong.', 'The because-clause is now attached to a main clause.'),
      ('Comma splice fixed', 'The café was full, so we sat outside.', 'A comma alone is not enough; so joins the clauses.'),
      ('Semicolon', 'The report is finished; I sent it this morning.', 'A semicolon joins two closely related main clauses.')]),
],
}

from .grammarian_upper import UPPER
READING.update(UPPER)

from .grammarian_more import MORE_READING
READING.update(MORE_READING)
