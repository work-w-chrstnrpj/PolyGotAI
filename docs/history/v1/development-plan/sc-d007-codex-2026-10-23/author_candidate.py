#!/usr/bin/env python3
"""Author an isolated, unpublished A1 review candidate. Never writes app resources.

All added wording below is original agent-authored material, not educator reviewed.
The proposed volume is a decision for SC-T073, not an approved product default.
"""
import copy
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
LIVE = ROOT / 'application/SpeechCoachAI/Resources/Curriculum'

# lesson: teaching, foundation allocation, five production items (prompt/answer/note),
# five concept checks, baseline, unfamiliar, delayed-7, delayed-28, pronunciation, workplace.
TOPICS = {
'a1-greetings': {
 'teaching': 'A greeting opens a conversation. Hello works at many times. Good morning is for the morning; good evening is for meeting someone in the evening. Good night usually ends an evening conversation. In I am fine, I is a subject pronoun, am is a linking verb, and fine describes the subject. A question with be puts the verb before the subject: Are you ready? Thank you and goodbye help close an exchange.',
 'foundations': ['EF-01-PRON-01','EF-01-ADJ-01','EF-01-INTERJ-01','EF-02-SP-01','EF-03-BE-01'],
 'production': [
  ['Build a sentence with I / fine. Add the form of be.','I am fine.','Use am with I; fine describes I.'],
  ['Ask whether your partner is ready. Use you and be.','Are you ready?','In this be question, are comes before you.'],
  ['Make this negative: I am tired.','I am not tired. / I’m not tired.', 'Put not after am; the contraction is also valid.'],
  ['Reply to How are you? Say you are well and thank the person.','I am well, thank you. / I’m fine, thanks.','Several short polite replies work; fine and well need not mean identical feelings.'],
  ['Join these messages with and: I am fine. I am ready.','I am fine and I am ready. / I am fine and ready.','And adds a related idea; the repeated subject and verb can be omitted here.']],
 'concepts': [
  ['In Hello, I am Ana, which word is a greeting?','Hello.'],
  ['In I am fine, which word names the speaker without using a name?','I; it is a subject pronoun.'],
  ['In I am fine, what is the complete predicate?','am fine; fine is a subject complement, not an object.'],
  ['Why is Are you ready? a question rather than You are ready? in the neutral written pattern?','Are comes before the subject you; the sentence ends with a question mark.'],
  ['Which usually closes an evening visit: Good evening or Good night?','Good night; Good evening normally greets someone.']],
 'baseline':'You meet a person at a morning class. Start a short conversation and close it politely. Use your own words before any model.',
 'transfer':'You meet a new neighbor in the evening. Greet them, ask if they are well, reply as the neighbor, and close the exchange.',
 'day7':'At an afternoon community event, greet a volunteer, ask if they are ready, answer as the volunteer, and say goodbye.',
 'day28':'At a morning workplace reception, greet the receptionist, ask how they are, give a short reply as that person, and close politely.',
 'pronunciation':'Replay the greeting clip. Notice the stress in MORning and THANK you. Record your own greeting if you wish; compare whether the greeting and reply can be understood. Text alone cannot show pronunciation.',
 'workplace':'Greet a receptionist and ask for repetition: Could you say that again, please?'
},
'a1-alphabet': {
 'teaching':'English letters have names used when spelling. A written name begins with a capital letter. In My name is Ben, name is a noun and my shows whose name it is. Is links the subject my name to Ben. Use How do you spell it? to request letters and Please repeat that to repair a misunderstanding. Letter names and the sounds inside a word are different.',
 'foundations':['EF-01-NOUN-01','EF-01-DET-01','EF-02-SP-01','EF-02-BOUND-01','EF-03-BE-01'],
 'production':[
  ['Correct the capital letters: my name is ben.','My name is Ben.','Start a sentence and a personal name with capitals.'],
  ['Build a question with How / do / you / spell / it.','How do you spell it?','Use do before you, followed by base-form spell.'],
  ['Complete with a possessive determiner: I am Ben. ___ name is Ben.','My','My describes a noun connected with I.'],
  ['Build a sentence with The name / start / with B.','The name starts with B.','A singular subject takes starts in the simple present.'],
  ['Ask politely for the letters to be repeated.','Please repeat the letters. / Could you repeat the letters, please?','These are valid polite requests; no single phrase is mandatory.']],
 'concepts':[
  ['In My name is Ben, which word is a common noun?','name; Ben is a proper noun.'],
  ['Does my replace the noun name, or come before it?','It comes before name; here it is a possessive determiner.'],
  ['In My name is Ben, is Ben an object?','No. It is the subject complement after linking verb is.'],
  ['What punctuation ends How do you spell it?','A question mark.'],
  ['Do the letter name B and the sound at the start of Ben have to be identical?','No. A letter name is different from the sound represented in a word.']],
 'baseline':'Choose a fictional name. Say or write the name and spell it without a model.',
 'transfer':'A library clerk mishears the surname Kim. Give the name, spell it, and politely ask the clerk to repeat it.',
 'day7':'A course form asks for the name Lee. State the name, spell it, and check that the listener understood.',
 'day28':'A phone message asks for the street name Oak. Give and spell the word, then politely request confirmation.',
 'pronunciation':'Listen to A, N, A in the clip. Pause between the letter names. If recording, ask whether the separate letters can be heard; do not infer sound accuracy from typed spelling.',
 'workplace':'Spell a fictional surname for a visitor badge; never require a real private name.'
},
'a1-numbers': {
 'teaching':'Use one with a singular count noun and two or more with a plural: one ticket, two tickets. How many asks about a count; How much asks about a price. In I need two tickets, I is the subject, need two tickets is the predicate, and two tickets is the direct object. The noun phrase two tickets has the head tickets. Give invented prices rather than personal financial details.',
 'foundations':['EF-01-NOUN-NUM-01','EF-01-DET-01','EF-02-OBJ-01','EF-04-NP-01'],
 'production':[
  ['Write 14 in words.','fourteen','Fourteen is 14; forty is 40.'],
  ['Use ticket in the right form: I need two ___.','tickets','Two calls for a plural count noun.'],
  ['Build a count question with How many / tickets / do / you / need.','How many tickets do you need?','Place How many tickets before do you need.'],
  ['Ask the price of one ticket.','How much is one ticket? / How much does one ticket cost?','Both ask about price; how many asks about quantity.'],
  ['Correct this message: I need one tickets.','I need one ticket.','One takes a singular count noun.']],
 'concepts':[
  ['In I need two tickets, what is the subject?','I.'],
  ['In I need two tickets, what is the direct object?','two tickets; it is what is needed.'],
  ['What is the head noun in two tickets?','tickets; two modifies its quantity.'],
  ['Which asks about quantity: how many or how much?','How many, with a count noun.'],
  ['Why does one ticket have no plural s?','One refers to a single countable item.']],
 'baseline':'Ask for an invented number of tickets and ask the price before seeing a model.',
 'transfer':'At a museum desk, ask for three adult tickets. Then ask the total price and repeat a fictional price to check it.',
 'day7':'At a community sale, ask for four cups and ask their total price. Use invented prices.',
 'day28':'A class needs six notebooks. Request them, ask the total price, and confirm the count.',
 'pronunciation':'Compare two and ten in the clip. Practice separating the count from the price with a pause. A written numeral demonstrates quantity, not intelligibility.',
 'workplace':'Ask for a small number of visitor passes and confirm the count.'
},
'a1-dates': {
 'teaching':'Use on with a named day, at with a clock time, and in with a month: on Friday, at three, in March. These are prepositional phrases that add time information to a clause. In The class starts at nine, The class is the subject and starts at nine is the predicate. English date orders differ; say the month in words to avoid ambiguity. A date, an hour, and a month are different kinds of information.',
 'foundations':['EF-01-PREP-01','EF-02-SP-01','EF-03-PRES-01','EF-04-PP-01'],
 'production':[
  ['Complete: The class is ___ Tuesday.','on','Use on with a named day.'],
  ['Complete: It starts ___ ten.','at','Use at for a clock time.'],
  ['Complete: The course begins ___ April.','in','Use in with a month.'],
  ['Ask the time of a meeting using What time.','What time is the meeting?','The be verb comes before the subject in this question.'],
  ['Write the appointment clearly: Monday / May 4 / nine in the morning.','The appointment is on Monday, May 4, at nine in the morning. / The appointment is at nine in the morning on Monday, 4 May.','Both month/day and day/month wording can be clear; no year or real appointment is required.']],
 'concepts':[
  ['Which phrase gives a day in on Friday at three?','on Friday.'],
  ['Which phrase gives a clock time in on Friday at three?','at three.'],
  ['In The class starts at nine, what is the predicate?','starts at nine.'],
  ['In at nine, what type of word is at?','A preposition.'],
  ['Why can writing 04/05 without context confuse someone?','Different date conventions can mean April 5 or May 4; writing the month name helps.']],
 'baseline':'Tell someone an invented appointment day and time. Ask them to confirm the time.',
 'transfer':'A new classmate asks when a club meets. Give Wednesday at half past five in the evening, then ask if that time is possible.',
 'day7':'Arrange an invented library visit for Saturday at ten in the morning. Ask the other person to repeat the time.',
 'day28':'Tell a coworker an invented training date using a month name and clock time; ask them to confirm the day.',
 'pronunciation':'Listen for the stressed day and hour in the recording. Pause between the day and the time when needed. A clear text date is not evidence of spoken stress.',
 'workplace':'Confirm a fictional meeting day and time without using a private calendar.'
},
'family-01': {
 'teaching':'Family words can be used with invented people. My and her go before nouns; I and she can be subjects. Use has with she or he and have with I, you, we or they. A possessive ending can show a relationship: Lina is Mina’s sister. In She is kind, kind is an adjective describing the subject after be. A relationship description does not require sharing real family information.',
 'foundations':['EF-01-NOUN-01','EF-01-PRON-01','EF-01-DET-01','EF-01-ADJ-01','EF-03-HAVE-01'],
 'production':[
  ['Complete: She ___ a brother.','has','Use has with she.'],
  ['Complete: They ___ a sister.','have','Use have with they.'],
  ['Replace Lina with a subject pronoun: Lina is a teacher.','She is a teacher. / They are a teacher.','She is valid when appropriate for Lina; singular they with are is also valid when chosen.'],
  ['Show the relationship using a possessive: Mina has a sister. Lina is that sister.','Lina is Mina’s sister. / Lina is Mina\'s sister.','The possessive ending attaches to the name Mina.'],
  ['Build a description with My brother / kind / be.','My brother is kind.','Kind is an adjective complement after is.']],
 'concepts':[
  ['In Her sister is kind, which word names a family relationship?','sister; it is a noun.'],
  ['In Her sister is kind, which word is an adjective?','kind.'],
  ['In Her sister is kind, what is the complete subject?','Her sister.'],
  ['How do She and her differ in She knows her sister?','She is the subject pronoun; her before sister is a possessive determiner.'],
  ['Why is She have a brother changed to She has a brother?','Third-person singular she takes has in the simple present.']],
 'baseline':'Describe two invented people and say where they live, without consulting a model.',
 'transfer':'A visitor sees a fictional family photo. Name two people, explain their relationships, and describe one person.',
 'day7':'Introduce two invented relatives to a new classmate. Say one thing each person does and where they live.',
 'day28':'Describe two people in an imaginary household to a new neighbor. Use a relationship and one personal quality.',
 'pronunciation':'Listen for brother in the clip. Compare the number of syllables with your own optional recording. No typed answer or speech recognition result establishes a sound-level score.',
 'workplace':'Introduce an invented emergency-contact relationship without entering real contact details.'
},
'a1-home': {
 'teaching':'There is introduces one thing; there are introduces plural things. A and an introduce a single countable thing; the can point to one already known. Next to and in are prepositions used to locate things. In There is a small table, a small table is a noun phrase with head table. An adjective often comes before the noun: a small table. Descriptions may use imaginary homes.',
 'foundations':['EF-01-DET-01','EF-01-ADJ-01','EF-01-PREP-01','EF-03-THERE-01','EF-04-NP-01','EF-04-PP-01'],
 'production':[
  ['Complete: There ___ a chair in the kitchen.','is','Use is with a single chair.'],
  ['Complete: There ___ two chairs in the kitchen.','are','Use are with plural chairs.'],
  ['Put these words in order: a / table / small.','a small table','The adjective small goes before the head noun table.'],
  ['Complete with an article: There is ___ orange chair.','an','Use an before a vowel sound, as in orange.'],
  ['Build a location sentence: The kitchen / next to / the living room.','The kitchen is next to the living room.','Add the be verb; next to the living room gives location.']],
 'concepts':[
  ['In a small table, which word is the head noun?','table.'],
  ['In a small table, which word describes the noun?','small; it is an adjective.'],
  ['Why use There are with two chairs?','The described things are plural.'],
  ['What does next to tell us?','A location beside another thing.'],
  ['In an orange chair, does an depend on the spelling or the following sound?','The following sound; orange starts with a vowel sound.']],
 'baseline':'Describe an imaginary room and locate two things before reading the examples.',
 'transfer':'A guest needs somewhere to put a bag. Name a room, say what is in it, and explain where to leave the bag.',
 'day7':'Describe a fictional study room to a friend: say what one thing and two other things are, and locate one.',
 'day28':'Help a new housemate find a key in an invented home. Name the room and describe its position beside another object.',
 'pronunciation':'Replay kitchen and living room. Notice the main stress in each phrase. Compare your optional spoken description for intelligibility rather than awarding a pronunciation grade.',
 'workplace':'Describe where two objects are in an imaginary office.'
},
'routine-01': {
 'teaching':'Use the simple present for routines: I work; she works. With he or she, a regular statement usually adds s or es. Questions use do or does followed by a base verb: Does she work? Negatives use do not or does not plus the base: She does not work. Usually is an adverb of frequency; it often goes before a main verb. And connects ideas without creating a new tense.',
 'foundations':['EF-01-VERB-01','EF-01-ADV-01','EF-01-CONJ-01','EF-02-ORDER-01','EF-03-PRES-01','EF-05-PRESENT-01'],
 'production':[
  ['Complete: She ___ at nine. Use start.','starts','Use starts for third-person singular she.'],
  ['Ask about his routine: ___ he work on Sunday?','Does','Does begins this third-person singular present question.'],
  ['Complete the negative: He does not ___ on Sunday. Use work.','work','Does already carries the agreement; use base-form work.'],
  ['Put usually in this sentence: I eat lunch at noon.','I usually eat lunch at noon.','Usually normally goes before the main verb eat.'],
  ['Join with and: I study in the morning. I cook at night.','I study in the morning and I cook at night. / I study in the morning and cook at night.','And joins related routine events; repeated I may be omitted.']],
 'concepts':[
  ['In She starts at nine, which word is the main verb?','starts.'],
  ['In Does he work?, which word is the auxiliary?','Does.'],
  ['Why is Does he works? changed to Does he work?','Does carries present agreement; the main verb stays in its base form.'],
  ['What does usually add to a routine?','Frequency: it happens often, though not necessarily every time.'],
  ['What relationship does and show in I study and I cook?','It adds a related action; it is a coordinating conjunction.']],
 'baseline':'Describe an invented weekday from morning to night and ask about someone else’s routine.',
 'transfer':'A new teammate asks about a day off. Describe morning, lunch and evening, then ask what they usually do.',
 'day7':'Describe a fictional neighbor’s weekday using she or he, then ask whether that person works on Saturday.',
 'day28':'Describe an imagined change between your weekday and Sunday routines, including one thing you do not do.',
 'pronunciation':'Listen for starts in the recording and the word after it. If recording, replay the ending without treating transcription accuracy as a pronunciation test.',
 'workplace':'Describe an invented workday and ask a colleague about a usual start time.'
},
'food-01': {
 'teaching':'I would like and Can I have make useful requests. Some nouns are countable, such as a sandwich; others often name an amount without a number, such as water. Some water is a useful phrase. In Can I have water?, can is a modal auxiliary and have stays in the base form. The request Can I have…? does not by itself demonstrate physical ability. Take turns and ask for repetition when necessary.',
 'foundations':['EF-01-NOUN-COUNT-01','EF-01-DET-01','EF-01-VERB-01','EF-02-OBJ-01','EF-05-CAN-01'],
 'production':[
  ['Request tea politely using would like.','I would like tea, please. / I’d like tea, please.','Would like is followed by the thing requested; contraction is valid.'],
  ['Complete: Can I ___ a sandwich?','have','After modal can, use the base form have.'],
  ['Complete with a useful quantity word: Can I have ___ water?','some','Water here is uncountable; some water is natural.'],
  ['Ask the price of the sandwich using How much.','How much is the sandwich?','How much asks about its price.'],
  ['Make the order plural: I would like one sandwich. Change one to two.','I would like two sandwiches.','Two takes a plural noun; sandwich adds es.']],
 'concepts':[
  ['In I would like a sandwich, what is being requested?','a sandwich; the noun phrase is the object of would like.'],
  ['Which is countable here: sandwich or water?','Sandwich; water names an uncountable substance in this use.'],
  ['In Can I have water?, which word is the modal auxiliary?','Can.'],
  ['Why is Can I has water? incorrect in this request?','A modal is followed by a base verb, here have.'],
  ['Does a typed polite order show that its pronunciation is clear?','No. Text can show wording; pronunciation needs relevant audio evidence.']],
 'baseline':'Order an invented drink and snack and ask the price, without looking at the example.',
 'transfer':'At a small station kiosk, ask for a drink and two snacks, ask the price, and politely ask for repetition.',
 'day7':'At an imaginary cafe, order soup and water and ask the price. Reply to a request to repeat one item.',
 'day28':'At a community picnic stall, request juice and two sandwiches, ask the total price, and close the exchange politely.',
 'pronunciation':'Replay the water request and notice which words carry the request. Compare an optional recording for whether the drink and snack are understandable; there is no automated sound assessment.',
 'workplace':'Place a fictional simple lunch order for yourself; no business negotiation is required.'
},
'a1-shopping': {
 'teaching':'This often points to one thing nearby; these points to more than one. Use it for a singular thing and them for plural things when the reference is clear. Too big means bigger than suitable, rather than simply very big. In I will take them, them is an object pronoun. Smaller is a useful size phrase here; a complete comparison system is developed later. Valid shop vocabulary differs by English variety.',
 'foundations':['EF-01-DET-01','EF-01-PRON-OBJ-01','EF-01-ADJ-01','EF-02-OBJ-01','EF-03-REF-01'],
 'production':[
  ['Ask the price of one hat using How much.','How much is this hat? / How much is the hat?','Use is for one hat.'],
  ['Complete: These shoes ___ too big.','are','These shoes is a plural subject.'],
  ['Replace shoes with an object pronoun: I will take the shoes.','I will take them. / I’ll take them.','Use them for the plural shoes.'],
  ['Replace hat with an object pronoun: I will take the hat.','I will take it. / I’ll take it.','Use it for the singular hat.'],
  ['Ask politely for a smaller shirt.','Do you have a smaller shirt? / Can I have a smaller shirt, please?','Both are valid requests; smaller expresses the desired size change.']],
 'concepts':[
  ['In These shoes are big, does these point to one or more than one?','More than one.'],
  ['In I will take them, what sentence role does them have?','Object; it refers back to the things being chosen.'],
  ['How does too big differ from big?','Too big means the size is beyond what is suitable for this purpose.'],
  ['What is the singular counterpart of these hats?','this hat.'],
  ['Does smaller in a shopping phrase prove full knowledge of comparative grammar?','No. A useful phrase is only evidence of the form and use attempted.']],
 'baseline':'Ask a price and a size question for an imagined item, then state a choice.',
 'transfer':'Buy gloves for a fictional friend. Ask their price and whether a smaller pair is available, then say which pair you choose.',
 'day7':'At an imaginary book sale, ask the price of two books, check the total, and say you will take them.',
 'day28':'At a market stall, ask for a larger hat and its price, then choose it or politely decline.',
 'pronunciation':'Replay shirt and twenty dollars. If recording, check whether the item and price question are understandable. American dollars in a model are invented content, not a current price.',
 'workplace':'Ask the price of a fictional office notebook and request a different size.'
},
'a1-places': {
 'teaching':'Use Where is…? to ask about one place. Imperatives give instructions with a base verb: Go straight. Turn left. Their subject you is understood, so these are complete instructions, not missing-subject errors. Prepositional phrases locate a place: next to the bank, on the right. Then orders the steps. A simple map can be imagined; no actual location is needed.',
 'foundations':['EF-01-PREP-01','EF-02-IMP-01','EF-02-BOUND-01','EF-04-PP-01','EF-04-CLAUSE-01'],
 'production':[
  ['Ask where the library is. Use Where.','Where is the library?','Put is before the singular subject the library.'],
  ['Give an instruction with turn and left.','Turn left.','An imperative uses the base verb; you is understood.'],
  ['Give two instructions using go straight and then turn right.','Go straight, then turn right. / Go straight. Then turn right.','Both punctuated forms give an ordered sequence.'],
  ['Complete the location: The bank is next ___ the cafe.','to','Next to is a location phrase.'],
  ['Repair this run-on with full stops: Go straight turn left the library is on the right.','Go straight. Turn left. The library is on the right.','Separate instructions and the statement with sentence boundaries.']],
 'concepts':[
  ['Is Turn left a complete instruction even without a written subject?','Yes. Its imperative subject you is understood.'],
  ['What is the preposition phrase in The bank is next to the cafe?','next to the cafe.'],
  ['What does then show in Go straight, then turn right?','The order of the directions.'],
  ['In Where is the bank?, what is the subject?','the bank.'],
  ['Why is Go straight turn left hard to read without punctuation?','It runs two instructions together without a clear boundary.']],
 'baseline':'Ask for a place and give two directions on an imaginary map.',
 'transfer':'A visitor asks for the clinic. Give two turns and name the building beside it, then ask whether the directions are clear.',
 'day7':'Help a new student find a library from an imagined entrance. Give two steps and one landmark.',
 'day28':'Help a fictional colleague find the reception desk. Give two ordered steps and one location phrase.',
 'pronunciation':'Replay left and past the bank. Pause between directions in an optional recording. Do not treat a correctly drawn or typed route as spoken intelligibility evidence.',
 'workplace':'Give a visitor two simple directions to an imaginary reception area.'
},
'a1-hobbies': {
 'teaching':'Use like with something you enjoy: I like music. Use play for many games and sports: I play soccer. She likes adds present-tense agreement. Can and cannot describe ability: I can swim; I cannot swim. A modal is followed by the base verb, so She can swim has no s on swim. And adds a related idea; but can contrast two ideas. Soccer and football can be valid variety choices when the intended sport is clear.',
 'foundations':['EF-01-VERB-01','EF-01-CONJ-01','EF-03-PRES-01','EF-05-CAN-01','EF-04-CLAUSE-01'],
 'production':[
  ['Complete: She ___ music. Use like.','likes','Third-person singular she takes likes.'],
  ['Ask if your partner likes movies using Do.','Do you like movies?','Use do with you and base-form like.'],
  ['Complete: She can ___ . Use swim.','swim','A modal takes the base form, not swims.'],
  ['Write a negative ability sentence with I / can / swim.','I cannot swim. / I can’t swim. / I can not swim.','Cannot and can’t are common; separate can not can be valid with the intended negative meaning.'],
  ['Join with but: I like soccer. I do not play it.','I like soccer, but I do not play it. / I like soccer but don’t play it.','But marks a contrast; a repeated subject can be omitted.']],
 'concepts':[
  ['In She can swim, which word is the main verb?','swim; can is a modal auxiliary.'],
  ['Why is She can swims changed to She can swim?','After a modal, the main verb stays in the base form.'],
  ['Does liking a sport always mean being able to play it?','No. Preference and ability are different meanings.'],
  ['What does but add in I like soccer, but I do not play it?','A contrast between liking it and not playing it.'],
  ['Is likes needed in Does she like music?','No. Does carries the agreement; like remains the base form.']],
 'baseline':'Describe a fictional hobby, say when you do it, and ask someone about a hobby.',
 'transfer':'At a new club, say one activity you enjoy and one you can do, then ask another member about their interests.',
 'day7':'Describe an imagined friend’s weekend hobby and one thing they cannot do. Ask a follow-up question.',
 'day28':'Join an imaginary community group. Mention two interests, contrast one ability or preference, and ask what another person likes.',
 'pronunciation':'Replay soccer and movies. Notice word stress. In an optional recording, check that a listener can distinguish the intended hobby; no automated pass is produced.',
 'workplace':'Answer a simple fictional team icebreaker about an interest; this is not interview assessment.'
},
'a1-weather': {
 'teaching':'Use it with weather: It is cold. It here does not refer to a person or object. A present continuous phrase uses be plus an ing form for what is happening now: It is raining. This differs from a routine such as It rains a lot in winter. An adjective describes a state, as in cold. A short message can combine weather with a practical suggestion, without making the suggestion a grammar prerequisite.',
 'foundations':['EF-01-ADJ-01','EF-01-PRON-01','EF-03-BE-01','EF-05-CONT-01','EF-04-CLAUSE-01'],
 'production':[
  ['Complete: It ___ cold today.','is','Use is with weather subject it.'],
  ['Build a sentence about now: It / rain. Use the present continuous.','It is raining. / It’s raining.','Use is plus raining for an event happening now.'],
  ['Make this negative: It is raining.','It is not raining. / It isn’t raining. / It’s not raining.','Put not after is; both contractions are valid.'],
  ['Ask about current weather using What / weather / like.','What is the weather like? / What’s the weather like?','Like here asks for a description, rather than preference.'],
  ['Choose a simple-present routine form: It ___ a lot in winter. Use rain.','rains','With it, routine simple-present rain takes s.']],
 'concepts':[
  ['In It is cold, which word is an adjective?','cold.'],
  ['In It is raining, which word is the auxiliary?','is; it supports the ing-form raining.'],
  ['How do It is raining and It rains a lot in winter differ?','The first describes what is happening now; the second a usual pattern.'],
  ['Does weather it in It is cold have to refer to a named object?','No. It serves as the subject in a weather expression.'],
  ['In What is the weather like?, does like mean enjoy?','No. It asks for a description in this question pattern.']],
 'baseline':'Describe imaginary weather now and say one thing you need because of it.',
 'transfer':'A visitor asks about the weather before leaving. Describe what is happening now and suggest a useful item to take.',
 'day7':'At an imagined outdoor event, describe current weather, say whether it is raining, and suggest one practical action.',
 'day28':'An imaginary colleague asks whether to walk outside. Describe current weather and a usual seasonal pattern, then answer the practical question.',
 'pronunciation':'Replay cold and coat in the model. Compare your optional recording for whether the weather and item can be understood. A text response cannot assess the vowel contrast.',
 'workplace':'Give a short fictional weather update before an outdoor work task.'
}}


# Exact target links per production item, rather than tagging every item with every strand.
TARGETS = {
'a1-greetings': [['EF-03-BE-01'],['EF-03-BE-01'],['EF-03-BE-01'],['EF-03-BE-01'],['EF-01-CONJ-01','EF-04-CLAUSE-01']],
'a1-alphabet': [['EF-02-BOUND-01'],['EF-03-PRES-01'],['EF-01-DET-01'],['EF-03-PRES-01'],['EF-02-IMP-01']],
'a1-numbers': [['EF-01-NOUN-NUM-01'],['EF-01-NOUN-NUM-01'],['EF-01-DET-01','EF-03-PRES-01'],['EF-03-BE-01'],['EF-01-NOUN-NUM-01']],
'a1-dates': [['EF-01-PREP-01'],['EF-01-PREP-01'],['EF-01-PREP-01'],['EF-03-BE-01'],['EF-04-PP-01']],
'family-01': [['EF-03-HAVE-01'],['EF-03-HAVE-01'],['EF-01-PRON-01'],['EF-01-NOUN-POSS-01'],['EF-01-ADJ-01','EF-03-BE-01']],
'a1-home': [['EF-03-THERE-01'],['EF-03-THERE-01'],['EF-04-NP-01'],['EF-01-DET-01'],['EF-04-PP-01','EF-03-BE-01']],
'routine-01': [['EF-03-PRES-01'],['EF-03-PRES-01'],['EF-03-PRES-01'],['EF-01-ADV-01'],['EF-01-CONJ-01','EF-04-CLAUSE-01']],
'food-01': [['EF-02-OBJ-01'],['EF-05-CAN-01'],['EF-01-NOUN-COUNT-01','EF-01-DET-01'],['EF-03-BE-01'],['EF-01-NOUN-NUM-01']],
'a1-shopping': [['EF-03-BE-01'],['EF-03-BE-01','EF-01-DET-01'],['EF-01-PRON-OBJ-01'],['EF-01-PRON-OBJ-01'],['EF-01-ADJ-01','EF-03-PRES-01']],
'a1-places': [['EF-03-BE-01'],['EF-02-IMP-01'],['EF-02-IMP-01','EF-02-BOUND-01'],['EF-01-PREP-01'],['EF-02-BOUND-01']],
'a1-hobbies': [['EF-03-PRES-01'],['EF-03-PRES-01'],['EF-05-CAN-01'],['EF-05-CAN-01'],['EF-01-CONJ-01','EF-04-CLAUSE-01']],
'a1-weather': [['EF-03-BE-01'],['EF-05-CONT-01'],['EF-05-CONT-01'],['EF-03-BE-01'],['EF-03-PRES-01']]
}


def digest(data):
    return hashlib.sha256(data).hexdigest()


def save(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False) + '\n')


def build():
    approval = HERE / 'scope-approval.json'
    if approval.exists():
        recorded = json.loads(approval.read_text())
        for name, expected in recorded['approvedCandidateHashes'].items():
            assert digest((HERE / name).read_bytes()) == expected, f'Approved candidate changed: {name}'
        print('Scope-approved candidate is intact; preserved without rewriting. See integration-record.json for runtime delivery.')
        return
    source = (LIVE / 'CurriculumCatalog.json').read_bytes()
    catalog = json.loads(source)
    lessons = [copy.deepcopy(x) for x in catalog['lessons'] if x['level'] == 'A1']
    assert set(TOPICS) == {x['id'] for x in lessons if x['id'] != 'intro-01'}
    base_by_id = {x['id']: x for x in catalog['lessons']}
    records = []
    for index, lesson in enumerate(lessons):
        lid = lesson['id']
        original = copy.deepcopy(lesson)
        if lid == 'intro-01':
            records.append({'lessonID':lid, 'ticket':'SC-T075', 'mode':'exact_reuse', 'contentVersion':lesson['contentVersion'],
                'objectiveID':lesson['objectiveId'], 'lessonSHA256':digest(json.dumps(lesson,sort_keys=True).encode()),
                'requiredActivityIDs':[a['id'] for a in lesson['activities'] if a['required']],
                'reference':'Existing INTRO-01 version 3 and SC-T018/SC-T043; no second introduction course.',
                'remaining':'Existing INTRO-01 foundation/rubric/qualified-review and IL gates remain with their original records.'})
            continue
        spec = TOPICS[lid]
        lesson['contentVersion'] = '3'
        # New version may change exercises; old version remains in the live catalog/history.
        # Keep source vocabulary identities and all existing non-grammar activity IDs.
        lesson['activities'] = [a for a in lesson['activities'] if a['kind'] != 'grammar']
        grammar = []
        for n,(prompt,answer,note) in enumerate(spec['production'],1):
            grammar.append({'id':f'{lid}-production-v3-{n}','kind':'grammar','required':True,
                'prompt':prompt,'answer':answer,'explanation':note,
                'childObjectiveIds':TARGETS[lid][n-1]})
        first_recall = next(i for i,a in enumerate(lesson['activities']) if a['kind']=='recall')
        lesson['activities'][first_recall:first_recall] = grammar
        # Reserve genuinely separate situations; never present them in ordinary practice.
        for key in ['baseline','day7','day28']:
            lesson['activities'].append({'id':f'{lid}-{key}-v3','kind':'guidedSpeaking','required':False,
                'prompt':spec[key], 'answer':'Human review against the named topic rubric; no automatic pass.',
                'withheldFromPractice':True})
        transfer = next(a for a in lesson['activities'] if a.get('withheldFromPractice') and 'transfer' in a['id'])
        transfer['prompt'] = spec['transfer']
        transfer['answer'] = 'Judge the requested communication separately from targeted grammar; too few target opportunities means not assessed.'
        # Fix the source numbers task's unrelated price request and expand explicit support.
        listening = next(a for a in lesson['activities'] if a['kind']=='listening')
        reading = next(a for a in lesson['activities'] if a['kind']=='reading')
        topic_record = {
            'lessonID':lid,'ticket':f'SC-T{74 if index == 0 else 74+index:03}',
            'mode':'proposed_revision','sourceVersion':original['contentVersion'],'contentVersion':'3',
            'objectiveID':lesson['objectiveId'],'unitID':f'A1-D007-U{index+1:02}',
            'editorialState':'ready_for_review','ownerManifestApproval':None,'qualifiedReviewer':None,
            'teaching':spec['teaching'],'childObjectiveIDs':sorted(set(spec['foundations']) | {x for targets in TARGETS[lid] for x in targets}),
            'foundationEvidenceLimit':'These mixed items sample the allocated strands. They are not five unseen items per child objective and do not establish EF-AC02/03 mastery.',
            'conceptChecks':[{'id':f'{lid}-concept-{n}','prompt':p,'answer':a} for n,(p,a) in enumerate(spec['concepts'],1)],
            'pronunciationSelfReview':spec['pronunciation'],'workplaceApplication':spec['workplace'],
            'quietPolicy':'Use the existing quietText alternative for guidedSpeaking. Text records communication/grammar attempts only; speaking and pronunciation remain unassessed.',
            'support':{'beforeAttempt':'Offer teaching, original examples and replay on request; record use as support.',
                       'afterAttempt':'Reveal the example only after the first attempt; preserve the original and label retries.',
                       'repairPhrase':'Could you say that again, please?',
                       'privacy':'Invented names, families, homes, work and prices are valid; no retained private recording is required.'},
            'coreCompletionProposal':{'requiredActivityIDs':[a['id'] for a in lesson['activities'] if a['required']],
                'rule':'Attempt every required core activity with the existing speaking/quiet substitution, review examples/corrections, and attempt self-review. Accuracy never gates participation completion.',
                'additionalConceptChecks':'Editorial sidecar only; not silently added to core completion.',
                'baselineAndDelayed':'Optional, separate journals; not core or vocabulary schedule credit.'},
            'assessment':{'rubricVersion':f'{lesson["objectiveId"]}-draft-1',
                'communication':'Record which requested message components are conveyed, absent, or not assessed; accept effective alternatives.',
                'grammar':'Record target opportunities and first-response forms individually; do not infer opportunities from prompt presence.',
                'vocabulary':'Use existing itemId plus senseId. Exposure and productive use do not schedule recognition.',
                'reading':{'activityID':reading['id'],'acceptedAlternatives':'Short factual answers and equivalent paraphrases matching the passage; no exact-string scoring.'},
                'listening':{'activityID':listening['id'],'acceptedAlternatives':'Short factual answers or equivalent paraphrases matching the recording; reading a transcript is assisted text evidence.'},
                'speaking':'Only an actual recorded/listened-to attempt supports speaking evidence; human listener records intelligibility with qualifications/conditions.',
                'pronunciation':'Unassessed without qualified listening to retained/consented audio; no acoustic inference from text or ASR.',
                'thresholds':'No new numeric pass or CEFR threshold selected. Existing EF/IL criteria require their recorded review.',
                'comparison':'Baseline before teaching; ordinary practice separate; unfamiliar context plus fresh day-7/day-28 prompts. Log support, modality, actual interval and prior exposure. These tasks are not calibrated comparable forms.'},
            'reservedTaskIDs':{key:f'{lid}-{key}-v3' for key in ['baseline','day7','day28']},
            'sourceLessonSHA256':digest(json.dumps(original,sort_keys=True).encode()),
            'rights':'New wording is original agent-authored material prepared 2026-10-23; existing wording/audio retain the live pack rightsReference. No external exercises/descriptors copied.',
            'descriptorReferences':['CV20-OC48-A1','CV20-RC54-A1','CV20-OP62-A1','CV20-IE78-A1','CV20-GA132-A1'],
            'descriptorMappingState':'Candidate scale links only; exact task/descriptor fit and A1 depth await qualified review.'
        }
        save(HERE/'topics'/f'{lid}.json',topic_record)
        records.append({k:topic_record[k] for k in ['lessonID','ticket','mode','sourceVersion','contentVersion','objectiveID','unitID','childObjectiveIDs','coreCompletionProposal']})
    used_assets = {a['assetId'] for l in lessons for a in l['activities'] if a.get('assetId')}
    assets = [copy.deepcopy(a) for a in catalog['assets'] if a['id'] in used_assets]
    bundle = {k:copy.deepcopy(v) for k,v in catalog.items() if k not in ['assets','lessons']}
    bundle.update(packId='speechcoach.a1.d007.candidate',contentVersion='proposal-1',
        editorialApprovalReference='',rightsReference='Original candidate text; existing asset provenance is retained in publication-manifest.json.',
        assets=assets,lessons=lessons)
    for a in assets:
        raw=(LIVE/a['relativePath']).read_bytes()
        assert len(raw)==a['byteCount'] and digest(raw)==a['sha256']
        dest=HERE/'candidate-bundle'/a['relativePath']; dest.parent.mkdir(parents=True,exist_ok=True); dest.write_bytes(raw)
    save(HERE/'candidate-bundle/CurriculumCatalog.json',bundle)
    proposal={
        'id':'SC-D007-A1-proposal-1','editorialState':'ready_for_review','publicationApproved':False,
        'ownerApproval':None,'qualifiedReviewer':None,'expansionDecision':None,
        'authorization':'Owner assigned SC-D007 to Codex on 2026-10-23; clarified queued Grok handoffs are not active assignments.',
        'sourceCatalogSHA256':digest(source),'sourcePackID':catalog['packId'],'sourcePackVersion':catalog['contentVersion'],
        'sourceEditorialReference':catalog['editorialApprovalReference'],'sourceRightsReference':catalog['rightsReference'],
        'scope':'All 13 topics in the adopted A1 outline, with exact INTRO-01 v3 reuse and 12 proposed v3 topic revisions. This finite volume is proposed for SC-T073 approval, not silently frozen.',
        'lessons':records,'assets':assets,
        'grammarCoverage':{
            'wordTypes':['a1-alphabet','family-01','a1-home','routine-01','a1-places','a1-greetings'],
            'numberAndPossession':['a1-numbers','family-01'],
            'subjectPredicateObjectsComplements':['a1-greetings','a1-alphabet','a1-numbers','family-01','a1-dates'],
            'beAndPresentAgreement':['intro-01','a1-greetings','family-01','routine-01','a1-hobbies'],
            'questionsNegativesAuxiliaries':['intro-01','a1-greetings','routine-01','a1-weather'],
            'thereIsAre':['a1-home'],'canCannot':['food-01','a1-hobbies'],'imperatives':['a1-places'],
            'phrasesClausesBoundaries':['a1-alphabet','a1-dates','a1-home','a1-places','a1-hobbies'],
            'presentContinuous':['a1-weather']},
        'laterLevelBoundary':'Full pronoun taxonomy, complex clauses, tense/aspect inventory and comparative systems remain at later reviewed depths; an A1 phrase is not whole-strand mastery.',
        'sources':[
            {'id':'CV20','title':'CEFR Companion volume (2020)','url':'https://rm.coe.int/cefr-companion-volume-with-new-descriptors-2020/16809ea0d4','accessed':'2026-10-23','use':'Scale/page references only; no descriptor text reproduced; editorial mapping pending.'},
            {'id':'CORE','title':'British Council–EAQUALS Core Inventory','url':'https://www.teachingenglish.org.uk/publications/case-studies-insights-and-research/british-council-eaquals-core-inventory-general','accessed':'2026-10-23','use':'English-specific curriculum planning reference; no content copied.'}],
        'blockedEdges':{
            'SC-T073':'Owner/qualified review of exact finite volume, depth, asset and rubric allocation still missing.',
            'SC-T074–SC-T086':'Candidate authoring is complete for the bounded proposal; qualified review and approved manifest missing; INTRO-01 original gaps are retained.',
            'SC-T087':'Requires approved topic versions and SC-T028 pilot closure. Candidate bundle is isolated and deliberately unavailable.',
            'SC-T088':'Requires integrated reviewed pack plus real native, qualified assessment, retention and unfamiliar-task evidence.'},
        'integrationPolicy':'Never overwrite the live catalog from this script. After recorded approval, use a checked delta merge preserving all non-A1 lessons, old journeys, shared senses and reviewed INTRO-01. Retain the old version for existing journeys or supply an explicitly approved compatibility path; current runtime refuses mismatched versions.'
    }
    save(HERE/'publication-manifest.json',proposal)
    assert (LIVE/'CurriculumCatalog.json').read_bytes()==source
    print(f'Authored {len(records)} topic allocations, {len(TOPICS)} teaching/review sidecars, {len(assets)} exact reused audio assets; live catalog unchanged.')

if __name__=='__main__':
    build()
