#!/usr/bin/env python3
"""Build the predefined Lexicon bank: Resources/Lexicon/lexicon-*.json (packs of about 40 words per CEFR rank, plus field packs).

Every meaning and sentence is original wording written for this app. Word choice follows general-purpose and academic
frequency ideas (no list text is copied or bundled). Each entry is
(lemma, part of speech, meaning, example with the word form in {braces}, wrong usage 1, wrong usage 2).
Wrong-usage sentences are grammatical but use the word in a way that does not fit its meaning, or break a pattern of the word.

Run from the project root: python3 tools/curriculum/build_lexicon.py, then python3 tools/curriculum/add_synonyms.py
"""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "application/SpeechCoachAI/Resources/Lexicon"

SOURCES = [
    "Words and CEFR levels chosen by the authors from general knowledge of English; meanings, examples and sentences are original",
    "Word-list licences checked 2026-10-25: CEFR-J Wordlist 1.5 (Tono Laboratory, TUFS; free with citation, A1-B2) and NGSL/NAWL (CC BY-SA 4.0) were not copied; Oxford 3000 and English Vocabulary Profile terms were not confirmed, so they were not used",
]

EVERYDAY = [
    ("happy", "adjective", "Feeling pleased and cheerful.", "Mina was {happy} when her friend called.", "I am happy because my dog is very sick.", "Yesterday she happy to see us."),
    ("buy", "verb", "To get something by paying money for it.", "We {buy} bread at the corner shop.", "I buy a new coat, so the shop pays me money.", "Yesterday I buy a new phone."),
    ("kitchen", "noun", "The room where people cook food.", "Dad is making soup in the {kitchen}.", "We take a hot shower in the kitchen.", "A kitchen is a person who cooks."),
    ("window", "noun", "An opening in a wall that lets in light and air.", "Please open the {window}; it is hot.", "Please close the window so the fresh air can come in.", "She cut the bread with a window."),
    ("quickly", "adverb", "In a short time; fast.", "She ate her breakfast {quickly} and ran to school.", "He walked quickly, so he arrived after a very long hour.", "She is a very quickly runner."),
    ("tired", "adjective", "Needing rest or sleep.", "I am {tired} after a long day at work.", "I slept ten hours, so I am very tired and full of energy.", "She tired very much last night."),
    ("friend", "noun", "A person you like and know well.", "My {friend} lives next door.", "A friend is someone you do not know at all.", "He friend me a book yesterday."),
    ("cook", "verb", "To prepare food by heating it.", "I {cook} rice for dinner every evening.", "I cooked dinner with cold water and no heat.", "She cooks the television for dinner."),
    ("weather", "noun", "The conditions outside, such as sun, rain, wind or cold.", "The {weather} is sunny today.", "The weather is my brother's name.", "The weathers are sunny today."),
    ("street", "noun", "A road in a town with buildings on the sides.", "The bakery is on the next {street}.", "We drive on the street from the kitchen to the bedroom.", "I sat on the streets and read a street."),
    ("early", "adverb", "Before the usual or expected time.", "We arrived {early} and waited for the doors to open.", "I arrived early, so I missed the beginning of the film.", "She comes early than me."),
    ("market", "noun", "A place where people buy and sell food and goods.", "Grandma buys fresh fish at the {market}.", "The market is a room where we sleep.", "He markets yesterday to buy apples."),
    ("wash", "verb", "To clean something with water.", "Please {wash} your hands before lunch.", "I wash my hands with dirty sand.", "He washes his car yesterday."),
    ("library", "noun", "A place where you can read or borrow books.", "She borrowed three books from the {library}.", "We buy bread at the library.", "A library is a kind of soup."),
    ("ticket", "noun", "A piece of paper that lets you enter or travel.", "I need a {ticket} for the train.", "A ticket is a kind of soup.", "The ticket was cheap, so it cost one thousand dollars."),
    ("borrow", "verb", "To take something and give it back later.", "Can I {borrow} your pen for a minute?", "I borrow my sister a pen.", "Please borrow me your pen and keep it forever."),
    ("birthday", "noun", "The day each year when you were born.", "Her {birthday} is in March.", "My birthday is every day of the week.", "Today is my birthday of the winter."),
    ("lunch", "noun", "The meal you eat in the middle of the day.", "We have {lunch} at noon.", "I eat lunch while I sleep.", "She lunches a letter."),
    ("careful", "adjective", "Paying attention so you do not make a mistake or get hurt.", "Be {careful}; the floor is wet.", "He was very careful, so he fell down three times.", "She is careful at the stairs of."),
    ("lose", "verb", "To not be able to find something.", "Don't {lose} your keys again.", "I lose my keys, so I know exactly where they are.", "He lose his wallet yesterday."),
    ("bedroom", "noun", "A room where you sleep.", "My {bedroom} has a small desk and a lamp.", "We cook dinner in the bedroom oven.", "He bedroomed a cold shower."),
    ("answer", "verb", "To say or write something after a question, or to pick up a ringing phone.", "Please {answer} the phone.", "I answer a question before anyone asks me.", "She answers to the question of the teacher."),
    ("cheap", "adjective", "Not costing much money.", "These shoes were {cheap}, so I bought two pairs.", "The shoes were cheap, so they cost a lot of money.", "This is the most cheap shop."),
    ("visit", "verb", "To go and see a person or place for a short time.", "We {visit} my grandparents on Sundays.", "I visit my aunt and I never see her.", "She visits to her aunt on Sundays."),
    ("neighbor", "noun", "A person who lives near you.", "Our {neighbor} waters our plants when we travel.", "My neighbor lives on the moon and has never been near my house.", "She neighbors very kind."),
    ("bottle", "noun", "A container with a narrow neck for liquid.", "He drank water from a plastic {bottle}.", "I put the milk in a bottle made of paper with no lid and no bottom.", "She bottles of water on the table."),
    ("listen", "verb", "To pay attention to a sound.", "I like to {listen} to music on the bus.", "I listen the radio with my eyes.", "He listens a book on the shelf."),
    ("ready", "adjective", "Prepared and able to start.", "Dinner is {ready}; come and eat.", "I am ready, so I need one more hour to start.", "She readies for school."),
    ("empty", "adjective", "With nothing inside.", "The box was {empty}, so I threw it away.", "The glass is empty and full of juice.", "He emptys the bottle yesterday."),
    ("enjoy", "verb", "To like doing or having something.", "I {enjoy} walking in the park.", "I enjoy going to the dentist because I hate it.", "She enjoys to swim."),
    ("bridge", "noun", "A structure that lets people cross a river.", "We walked across the {bridge} to the other side.", "We swam under the bridge to the top of the sky.", "A bridge is a kind of fruit."),
    ("sleep", "verb", "To rest with your eyes closed at night.", "Babies {sleep} a lot.", "I sleep with my eyes open and talk all night.", "He sleeped well last night."),
    ("jacket", "noun", "A short coat.", "Take a {jacket}; it may get cold.", "She ate a jacket for breakfast.", "He jacket his coat on the chair."),
    ("hungry", "adjective", "Wanting to eat.", "I am {hungry}; let's have lunch.", "I am hungry because I just ate three big meals.", "She is hungry of a sandwich."),
    ("carry", "verb", "To hold something and take it from one place to another.", "Can you {carry} this bag for me?", "I carry the weather in my hand.", "He carried the bag to he home."),
    ("village", "noun", "A very small town in the countryside.", "My grandparents live in a quiet {village}.", "The village has two million people and a huge airport.", "She villages to work by bus."),
    ("repeat", "verb", "To say or do something again.", "Please {repeat} the question.", "I repeat the word for the first time.", "He repeat the song again."),
    ("beautiful", "adjective", "Very nice to look at or hear.", "The garden looks {beautiful} in spring.", "The garden looks very beautiful and ugly.", "She sings beautiful."),
    ("plan", "noun", "An idea about what you will do.", "What is your {plan} for the weekend?", "I put my plan in the oven for ten minutes.", "He plans of the dog a shoe."),
    ("clean", "adjective", "Not dirty.", "Please put on a {clean} shirt.", "The floor is clean because it is covered with mud.", "He is clean the room now."),
]

WORK = [
    ("schedule", "noun", "A list of times when things will happen.", "My {schedule} is full on Monday.", "I eat my schedule for lunch.", "The schedule are on the wall."),
    ("deadline", "noun", "The last time or day by which something must be done.", "The {deadline} for the report is Friday.", "We finished the work a week after the deadline, so we were early.", "Please do it in the deadline."),
    ("meeting", "noun", "An event where people come together to talk about work.", "We have a {meeting} at ten o'clock.", "I wore my meeting on my feet.", "She meetings with her manager."),
    ("colleague", "noun", "A person you work with.", "My {colleague} helped me with the spreadsheet.", "A colleague is a person you have never heard of and never work with.", "He colleagues a long report."),
    ("manager", "noun", "A person who is in charge of a team or a place.", "The {manager} thanked us for our hard work.", "The manager is a person who never decides anything and works for no one.", "She managers the team."),
    ("salary", "noun", "Money an employee gets regularly for their work.", "He got a higher {salary} after the promotion.", "I pay my salary to the company every month.", "She salaries ten thousand pesos."),
    ("invoice", "noun", "A paper that lists what a customer must pay.", "Please send the {invoice} by email.", "An invoice is a list of the books you want to read.", "He invoice us for the work."),
    ("appointment", "noun", "A planned time to meet someone.", "I have a dentist {appointment} at four.", "I met a stranger on the street by appointment, but we never planned it.", "She appointment the doctor."),
    ("customer", "noun", "A person who buys goods or services.", "The {customer} asked for a refund.", "The customer sells the goods to the shop.", "He customers many things."),
    ("report", "noun", "A document that gives information about something.", "She wrote a short {report} on sales.", "I ate a report for breakfast.", "He reports are on his desk."),
    ("project", "noun", "A piece of work that is planned with a goal.", "Our team finished the {project} on time.", "The project is a small yellow bird.", "She projects a new idea last week."),
    ("team", "noun", "A group of people who work together.", "Our {team} meets every Monday.", "I am the only person in our team of twelve.", "He teams in the sales department."),
    ("task", "noun", "A piece of work that must be done.", "Writing emails is my first {task} each day.", "My task is something I never need to do.", "She tasks many jobs today."),
    ("budget", "noun", "A plan for how much money you will spend.", "We need to stay within the {budget}.", "We spent twice our budget, so we saved money.", "He budgets a sunny river."),
    ("contract", "noun", "A written agreement between people or companies.", "Both sides signed the {contract}.", "We signed the contract, but nobody agreed to anything.", "She contract the new worker."),
    ("employee", "noun", "A person who is paid to work for a company.", "Each {employee} gets a security badge.", "The employee pays the company a salary every month.", "He employee at the bank."),
    ("supervisor", "noun", "A person who watches and guides the work of others.", "My {supervisor} checks the schedule every morning.", "A supervisor is a worker who watches nobody and guides no one.", "She supervisors a team."),
    ("resume", "noun", "A short document that lists your jobs and skills.", "Send your {resume} with the application form.", "My resume is a list of my favorite foods.", "He resumes in the box."),
    ("interview", "noun", "A formal meeting where someone asks you questions about a job.", "I have a job {interview} on Tuesday.", "The interview asked me twenty questions.", "She interview with the manager."),
    ("promote", "verb", "To give someone a higher job.", "They will {promote} her to manager next month.", "They promoted him, so he lost his job.", "He promoted to the manager."),
    ("office", "noun", "A place where people do desk work.", "I take the bus to the {office}.", "I cook dinner in the office of my pocket.", "She office at nine."),
    ("department", "noun", "One part of a large company or organization.", "She works in the sales {department}.", "The department is a big company with no parts.", "He departments in the building."),
    ("client", "noun", "A person or company that pays for your services.", "Our {client} wants a new logo.", "Our client works for us and gets a salary.", "She clients the company."),
    ("delay", "noun", "A time when something happens later than planned.", "There is a one-hour {delay} at the airport.", "The delay made the train arrive early.", "He delay the flight."),
    ("remind", "verb", "To help someone remember something.", "Please {remind} me to call the bank.", "I remind a letter to the bank.", "She reminds me about to call."),
    ("attach", "verb", "To fix one thing to another, such as a file to an email.", "Please {attach} the document to your email.", "I attach the document by deleting it from the email.", "He attached with the file."),
    ("submit", "verb", "To give a document or work to someone for a decision.", "You must {submit} the form by noon.", "I submit the form by throwing it away.", "She submitted for the report."),
    ("review", "verb", "To look at something again to check it.", "I will {review} your report tonight.", "I review the report before I write it.", "He reviews to the document."),
    ("apply", "verb", "To ask formally for a job or a place.", "She decided to {apply} for the new position.", "I apply a new job, so they ask me to leave.", "He applied to a job."),
    ("hire", "verb", "To give someone a job.", "The company will {hire} three new workers.", "The company hired him, so he lost his job.", "They hires many workers."),
    ("shift", "noun", "A set period of time when a person works.", "He works the night {shift} at the hospital.", "My shift is a week of vacations.", "She shift every night."),
    ("overtime", "noun", "Extra hours of work after the normal day.", "I worked two hours of {overtime} last night.", "I left work early, so I did a lot of overtime.", "He overtimes yesterday."),
    ("agenda", "noun", "A list of things to talk about at a meeting.", "The {agenda} has five items.", "The agenda lists what we did last year, not what we will discuss.", "She agendas many things."),
    ("feedback", "noun", "Comments that tell you how well you did something.", "I asked my boss for {feedback} on my presentation.", "I gave my boss feedback by saying nothing at all.", "He feedbacks us."),
    ("workload", "noun", "The amount of work a person has to do.", "Her {workload} is heavy this week.", "My workload is small because I have too much to do.", "She workloads many tasks."),
    ("supply", "noun", "An amount of something that is available to use.", "The office has a good {supply} of paper.", "We have a big supply, so we have no paper.", "He supply of the shops."),
    ("order", "verb", "To ask for goods or food to be brought to you.", "We will {order} pizza for lunch.", "I order a pizza, so I make it myself.", "She orders me about food."),
    ("discount", "noun", "A lower price than the usual one.", "The shop gave me a ten percent {discount}.", "A discount makes the price go up.", "He discount a lot on shoes."),
    ("warehouse", "noun", "A large building where goods are stored.", "The goods are kept in a {warehouse}.", "I live in a warehouse for my bank account.", "She warehouses in the town."),
    ("receipt", "noun", "A paper that shows you paid for something.", "Keep the {receipt} in case you need to return it.", "The shop gave me a receipt before I paid.", "He receipts of the shop."),
]

ACADEMIC = [
    ("analyze", "verb", "To study something carefully to understand it.", "Scientists {analyze} the data from the experiment.", "I analyze the report without reading it.", "She analyzed to the data."),
    ("argue", "verb", "To give reasons to show that something is true or false.", "Some people {argue} that homework is helpful.", "He argues the table with milk.", "I argued of the idea."),
    ("assume", "verb", "To think that something is true without checking.", "Don't {assume} that everyone has a phone.", "I assumed the answer after I checked every fact twice.", "She assumes to know it."),
    ("benefit", "noun", "A good result or advantage.", "One {benefit} of exercise is better sleep.", "One benefit of the storm is that it destroyed our roof.", "He benefits of a lot."),
    ("concept", "noun", "An idea about how something works or what it means.", "The {concept} of time is hard to explain.", "My concept is a warm sandwich.", "She concepts the lesson."),
    ("consequence", "noun", "A result of an action or event.", "Missing the deadline had serious {consequences}.", "The consequence came before the action.", "He consequences of the choice."),
    ("contrast", "noun", "A clear difference between two things.", "There is a sharp {contrast} between the two cities.", "There is a big contrast because the two cities are exactly the same.", "She contrast two ideas."),
    ("define", "verb", "To say exactly what a word or idea means.", "The teacher asked us to {define} the term.", "I define the table to the moon.", "She defined to the word."),
    ("evidence", "noun", "Facts or signs that show something is true.", "The police found new {evidence}.", "Evidence is a person who tells stories.", "The evidences are on the desk."),
    ("factor", "noun", "One of the things that affect a result.", "Cost is an important {factor} in the decision.", "A factor is a result that has no cause.", "She factors the decision."),
    ("function", "noun", "The purpose or normal job of something.", "The {function} of the heart is to pump blood.", "The function of a key is to cut bread.", "He functions of the machine."),
    ("impact", "noun", "A strong effect on something.", "The new law had a big {impact} on small shops.", "The law had a big impact, but nothing changed.", "She impacts of the law."),
    ("indicate", "verb", "To show or point to something.", "The results {indicate} that the plan works.", "The results indicate nothing, so we know exactly what happened.", "He indicated to the sign."),
    ("individual", "noun", "One single person, not a group.", "Each {individual} has different needs.", "An individual is a big group of people.", "She individual of the group."),
    ("interpret", "verb", "To explain what something means.", "People can {interpret} the poem in different ways.", "I interpret the poem by not reading it.", "He interpreted of the sign."),
    ("issue", "noun", "A problem or topic that people discuss.", "Climate change is an important {issue}.", "An issue is something no one talks about or thinks about.", "She issues of the city."),
    ("method", "noun", "A particular way of doing something.", "This {method} saves a lot of time.", "The method is the final answer of the test.", "He methods the research."),
    ("obtain", "verb", "To get something, often with effort.", "You can {obtain} a permit at the town hall.", "I obtained a permit by giving it away.", "She obtains from a license."),
    ("occur", "verb", "To happen.", "The accident did not {occur} at night.", "The event occurred, but nothing happened.", "He occurs to the street."),
    ("principle", "noun", "A basic rule or idea that guides how you act or think.", "Honesty is a basic {principle} in science.", "A principle is the person who runs a school.", "She principles of the club."),
    ("process", "noun", "A series of steps that lead to a result.", "Making cheese is a long {process}.", "The process has no steps and no end.", "He process the milk for cheese."),
    ("require", "verb", "To need something or make it necessary.", "The job will {require} two years of experience.", "The job requires nothing, so you must bring many documents.", "She requires to have a license."),
    ("research", "noun", "Careful study to find new facts.", "Her {research} shows how children learn.", "I did research by guessing without looking at any facts.", "He researches are on the shelf."),
    ("respond", "verb", "To answer or react to something.", "Please {respond} to the email by Friday.", "I responded the email yesterday.", "She responds the letter."),
    ("role", "noun", "The part someone or something plays in a situation.", "Parents play an important {role} in learning.", "A role is a kind of bread.", "He roles in the project."),
    ("significant", "adjective", "Important enough to have a clear effect.", "There was a {significant} change in the numbers.", "The change was significant because it was too small to notice.", "She significants a result."),
    ("source", "noun", "A place, person or thing where information or something else comes from.", "The report names its {source} for each fact.", "The report's source is a kind of soup.", "He sources of the river."),
    ("structure", "noun", "The way parts are arranged to make a whole.", "The {structure} of the essay is clear.", "The essay has no structure, so every part is in perfect order.", "She structure the paragraph."),
    ("survey", "noun", "A set of questions asked to many people to learn their opinions.", "The {survey} asked students about their sleep.", "The survey asked only one person and no questions.", "He surveys of the class."),
    ("theory", "noun", "An idea that tries to explain how or why something happens.", "Darwin's {theory} explains how species change.", "A theory is a fact that nobody can explain.", "She theory the results."),
    ("trend", "noun", "A general change or direction over time.", "There is a growing {trend} toward working from home.", "A trend is something that happens only once.", "He trends of the market."),
    ("variety", "noun", "A number of different kinds of things.", "The store sells a wide {variety} of teas.", "The store has a wide variety, so every product is the same.", "She varieties of cakes."),
    ("version", "noun", "A form of something that is a little different from others.", "This is the newest {version} of the app.", "This version is exactly the same as every other one.", "He versions the app."),
    ("compare", "verb", "To look at things to see how they are alike or different.", "Let's {compare} the two phones before we buy one.", "I compare one phone without looking at the other.", "She compares at the prices."),
    ("conclude", "verb", "To decide something after thinking about the facts.", "We {conclude} that the plan is safe.", "I concluded the answer before I knew any facts.", "He concludes to the idea."),
    ("create", "verb", "To make something new.", "Artists {create} new things every day.", "I created a painting that already existed.", "She creates of a song."),
    ("estimate", "verb", "To guess an amount using the facts you have.", "Can you {estimate} how long the trip will take?", "I estimate the exact number after I measure it.", "He estimates to the cost."),
    ("focus", "verb", "To give all your attention to one thing.", "I cannot {focus} when the room is noisy.", "I focus on ten different things at the same time.", "She focuses at the work."),
    ("involve", "verb", "To include someone or something as a necessary part.", "The job will {involve} a lot of travel.", "The plan involves nobody and nothing.", "He involves to the group."),
    ("maintain", "verb", "To keep something in good condition or at the same level.", "It is hard to {maintain} a healthy diet when you travel.", "We maintain the road by letting it break.", "She maintains of the house."),
]

import sys  # noqa: E402

sys.path.insert(0, str(Path(__file__).resolve().parent))
from lexdata import a1, a2, b1, b2, c1, c2, fields  # noqa: E402
from lexdata import more_a1, more_a2, more_b1, more_b2, more_c1, more_c2  # noqa: E402

REGISTERS = {"everyday", "formal", "term", "jargon", "slang", "informal", "literary"}
JARGON = {"stakeholder", "outsource", "milestone", "turnover", "touch base", "leverage", "paradigm"}

# Level of each original word (judged by the authors). Original words keep their ids and both wrong sentences.
WORK_LEVELS = {
    "A2": ["schedule", "meeting", "colleague", "manager", "appointment", "customer", "report", "team", "office", "order"],
    "B2": ["invoice", "contract", "supervisor", "overtime", "agenda", "workload", "supply", "warehouse"],
}
ACADEMIC_B1 = ["argue", "benefit", "process", "compare", "create"]


def legacy(rows, group_id, level, register):
    return [dict(zip(("lemma", "pos", "meaning", "example", "wrong1", "wrong2"), row), cefr=level, register=register,
                 id=f"{group_id}.{LexiconSlug(row[0])}", wrong_count=2) for row in rows]


def LexiconSlug(text: str) -> str:
    text = "".join(ch.lower() if ch.isalnum() else "-" for ch in text)
    return "-".join(part for part in text.split("-") if part)


def fresh(rows, level, register):
    """New words keep one wrong-usage sentence: the second drafted sentences were not natural enough to ship."""
    out = []
    for row in rows:
        lemma, pos, meaning, example, wrong1 = row[:5]
        override = row[5] if len(row) > 5 and row[5] in REGISTERS else None
        out.append(dict(lemma=lemma, pos=pos, meaning=meaning, example=example, wrong1=wrong1, wrong2=None, cefr=level,
                        register="jargon" if lemma in JARGON else (override or register), id=None, wrong_count=1))
    return out


def rich(rows, level, register):
    """Phase 14 words: (lemma, pos, meaning, example, wrong, "synonym; synonym"[, register]). One wrong sentence each."""
    out = []
    for row in rows:
        lemma, pos, meaning, example, wrong1, synonyms = row[:6]
        override = row[6] if len(row) > 6 else None
        if override is not None and override not in REGISTERS:
            raise SystemExit(f"{lemma}: unknown register {override}")
        out.append(dict(lemma=lemma, pos=pos, meaning=meaning, example=example, wrong1=wrong1, wrong2=None, cefr=level,
                        register=override or register, id=None, wrong_count=1,
                        synonyms=[v.strip() for v in synonyms.split(";") if v.strip()]))
    return out


def level_keys():
    """Keys (normalized lemma, pos) of every word in the level groups; field packs must not repeat them."""
    return {(LexiconKey(row["lemma"]), row["pos"]) for _, _, _, _, _, rows in GROUPS for row in rows}


def LexiconKey(text: str) -> str:
    return " ".join("".join(ch for ch in text.lower() if ch.isalnum() or ch in " -").split())


_TAKEN: set | None = None


def unique_field_rows(rows):
    global _TAKEN
    if _TAKEN is None:
        _TAKEN = level_keys()
    taken = _TAKEN
    out = []
    for row in rows:
        key = (LexiconKey(row["lemma"]), row["pos"])
        if key not in taken:
            taken.add(key)
            out.append(row)
    return out


def pick(rows, lemmas):
    wanted = set(lemmas)
    return [row for row in rows if row[0] in wanted]


def not_in(rows, lemmas):
    skip = set(lemmas)
    return [row for row in rows if row[0] not in skip]


A2_WORK = WORK_LEVELS["A2"]
B2_WORK = WORK_LEVELS["B2"]
B1_WORK = [row[0] for row in WORK if row[0] not in A2_WORK and row[0] not in B2_WORK]
B2_ACADEMIC = [row[0] for row in ACADEMIC if row[0] not in ACADEMIC_B1]

GROUPS = [
    ("01-a1-everyday", "everyday-a1", "Everyday A1", "A1", "Words for daily life", legacy(EVERYDAY, "everyday-a1", "A1", "everyday")),
    ("02-a1-people-places", "a1-people-places", "People and places", "A1", "Who and where", fresh(a1.PEOPLE_PLACES, "A1", "everyday")),
    ("03-a1-food-time", "a1-food-time", "Food and time", "A1", "Meals, days and actions", fresh(a1.FOOD_TIME, "A1", "everyday")),
    ("04-a2-travel-health", "a2-travel-health", "Travel and health", "A2", "Trips and feeling well", fresh(a2.TRAVEL_HEALTH, "A2", "everyday")),
    ("05-a2-home-town", "a2-home-town", "Home and town", "A2", "Where you live", fresh(a2.HOME_TOWN, "A2", "everyday")),
    ("06-a2-work-basics", "a2-work-basics", "Work and study basics", "A2", "School, office and screens",
     legacy(pick(WORK, A2_WORK), "work-office", "A2", "everyday") + fresh(a2.WORK_BASICS, "A2", "everyday")),
    ("07-b1-work", "b1-work", "Work and careers", "B1", "Jobs and the workplace",
     legacy(pick(WORK, B1_WORK), "work-office", "B1", "everyday") + fresh(b1.WORK_EXTRA, "B1", "everyday")),
    ("08-b1-society", "b1-society", "Society and the world", "B1", "People, rules and news",
     legacy(pick(ACADEMIC, ACADEMIC_B1), "academic-basics", "B1", "everyday") + fresh(b1.SOCIETY, "B1", "everyday")),
    ("09-b1-feelings", "b1-feelings", "Feelings and character", "B1", "How people feel and act", fresh(b1.FEELINGS, "B1", "everyday")),
    ("10-b2-work-terms", "b2-work-terms", "Business terms", "B2", "Words for company life",
     legacy(pick(WORK, B2_WORK), "work-office", "B2", "term") + fresh(b2.WORK_TERMS_EXTRA, "B2", "term")),
    ("11-b2-academic", "b2-academic", "Academic basics", "B2", "Words for study and reports",
     legacy(pick(ACADEMIC, B2_ACADEMIC), "academic-basics", "B2", "term") + fresh(b2.ACADEMIC_EXTRA, "B2", "term")),
    ("12-b2-opinion", "b2-opinion", "Opinion and argument", "B2", "Say what you think", fresh(b2.OPINION, "B2", "formal")),
    ("13-c1-nuance", "c1-nuance", "Shades of meaning", "C1", "Precise describing words", fresh(c1.NUANCE, "C1", "formal")),
    ("14-c1-professional", "c1-professional", "Professional verbs", "C1", "Formal work language", fresh(c1.PROFESSIONAL, "C1", "formal")),
    ("15-c1-abstract", "c1-abstract", "Abstract ideas", "C1", "Words for big ideas", fresh(c1.ABSTRACT, "C1", "formal")),
    ("16-c2-precision", "c2-precision", "Exact and rare", "C2", "Precise, uncommon words", fresh(c2.PRECISION, "C2", "formal")),
    ("17-c2-idioms", "c2-idioms", "Idioms and informal English", "C2", "How people really talk", fresh(c2.IDIOM_REGISTER, "C2", "informal")),
    ("18-c2-literary", "c2-literary", "Literary language", "C2", "Words from stories and poems", fresh(c2.LITERARY, "C2", "literary")),
]

# Phase 14 packs (about 2,400 words in all): each module lists (stem, group id, title, tagline, register, rows) per pack.
# They follow the older packs of the same rank. File numbers are assigned in build(), so packs stay in rank order.
LEVEL_ORDER = ["A1", "A2", "B1", "B2", "C1", "C2"]
for level, module in zip(LEVEL_ORDER, (more_a1, more_a2, more_b1, more_b2, more_c1, more_c2)):
    for stem, group_id, title, tagline, register, rows in module.PACKS:
        GROUPS.append((stem, group_id, title, level, tagline, rich(rows, level, register)))
# Expansion 2026-10-30 (B1–C2 to about 1,000 words each): lexdata/extra_<rank>_<n>.py, same row format, after the packs above.
import importlib  # noqa: E402

EXTRA_MODULES = sorted(Path(__file__).resolve().parent.joinpath("lexdata").glob("extra_*.py"))
for path in EXTRA_MODULES:
    module = importlib.import_module(f"lexdata.{path.stem}")
    for stem, group_id, title, tagline, register, rows in module.PACKS:
        GROUPS.append((stem, group_id, title, module.LEVEL, tagline, rich(rows, module.LEVEL, register)))
GROUPS.sort(key=lambda group: LEVEL_ORDER.index(group[3]))

# Field packs (L2.3): opt-in groups, never the default, never suggested as "Next", not in the daily word unless switched on.
FIELD_GROUPS = [
    ("19-field-business", "field-business", "Business and finance", "B2", "Money, deals and companies", unique_field_rows(fresh(fields.BUSINESS, "B2", "term"))),
    ("20-field-tech", "field-tech", "Technology", "B2", "Computers, apps and networks", unique_field_rows(fresh(fields.TECH, "B2", "term"))),
    ("21-field-health", "field-health", "Health and medicine", "B2", "Doctors, illness and care", unique_field_rows(fresh(fields.HEALTH, "B2", "term"))),
    ("22-field-travel", "field-travel", "Travel", "B1", "Trips, airports and hotels", unique_field_rows(fresh(fields.TRAVEL, "B1", "term"))),
    ("23-field-law", "field-law", "Law", "C1", "Courts, contracts and rights", unique_field_rows(fresh(fields.LAW, "C1", "term"))),
]


# Per-word fixes from the Lexicon proofread: neutral words in formal/term groups are everyday, and easier idioms and
# literary words keep their own (lower) CEFR level inside the C2 group, so a B1 or B2 learner meets them in the daily word.
EVERYDAY_WORDS = {
    "disagree", "support", "suggest", "advantage", "disadvantage", "attitude", "debate",
    "vague", "thorough", "trivial", "deliberate", "notorious", "obsolete", "mundane", "versatile",
    "role", "issue", "individual", "respond", "occur", "require", "focus", "involve",
    "challenge", "priority", "resource", "approve", "propose", "objective", "efficient",
}
LOWER_LEVEL_WORDS = {
    "broke": "B1", "hang out": "B1", "figure out": "B1", "mess up": "B1", "chill out": "B1",
    "break the ice": "B2", "under the weather": "B2", "hit the sack": "B2", "spill the beans": "B2",
    "once in a blue moon": "B2", "the last straw": "B2",
    "wander": "B1", "fade": "B1", "drift": "B2", "dusk": "B2", "stillness": "B2", "murmur": "B2",
    "hush": "C1", "veil": "C1", "glimmer": "C1", "ember": "C1",
}


def apply_word_fixes() -> None:
    seen_everyday, seen_level = set(), set()
    for _, _, _, level, _, rows in GROUPS:
        for row in rows:
            if row["lemma"] in EVERYDAY_WORDS and row["register"] in {"formal", "term"}:
                row["register"] = "everyday"
                seen_everyday.add(row["lemma"])
            if row["lemma"] in LOWER_LEVEL_WORDS and level == "C2":
                row["cefr"] = LOWER_LEVEL_WORDS[row["lemma"]]
                seen_level.add(row["lemma"])
    missing = (EVERYDAY_WORDS - seen_everyday) | (set(LOWER_LEVEL_WORDS) - seen_level)
    if missing:
        print("WARNING: word fixes not applied to:", sorted(missing))


def curl(value):
    """Use typographic apostrophes in every learner-facing string."""
    if isinstance(value, str):
        return value.replace("'", "\u2019")
    if isinstance(value, list):
        return [curl(v) for v in value]
    if isinstance(value, dict):
        return {k: curl(v) for k, v in value.items()}
    return value


# Field pack sizes before Phase 14: a new level word must never take a word out of a field pack (its id would change).
FIELD_SIZES = {"field-business": 27, "field-tech": 30, "field-health": 28, "field-travel": 29, "field-law": 30}


def check_bank() -> None:
    problems, seen = [], {}
    for _, group_id, _, _, _, rows in [*GROUPS, *FIELD_GROUPS]:
        for row in rows:
            key = (LexiconKey(row["lemma"]), row["pos"])
            if key in seen:
                problems.append(f"{row['lemma']} ({row['pos']}) in {group_id} repeats {seen[key]}")
            seen[key] = group_id
            if row["example"].count("{") != 1 or "{" in row["wrong1"] or len(row["meaning"]) > 140:
                problems.append(f"{group_id}: {row['lemma']}: example marker, wrong sentence or meaning length")
            if any(LexiconKey(v) == LexiconKey(row["lemma"]) for v in row.get("synonyms", [])):
                problems.append(f"{group_id}: {row['lemma']}: synonym equals the word")
    for _, group_id, _, _, _, rows in FIELD_GROUPS:
        if len(rows) != FIELD_SIZES[group_id]:
            problems.append(f"{group_id}: {len(rows)} words, expected {FIELD_SIZES[group_id]} (a level word took a field word)")
    if problems:
        raise SystemExit("\n".join(problems))


def build() -> None:
    check_bank()
    apply_word_fixes()
    OUT.mkdir(parents=True, exist_ok=True)
    for old in OUT.glob("lexicon-*.json"):
        old.unlink()
    total = 0
    for number, (stem, group_id, title, level, tagline, rows) in enumerate([*GROUPS, *FIELD_GROUPS], start=1):
        is_field = number > len(GROUPS)
        stem = f"{number:03d}-{stem.split('-', 1)[1] if stem[:2].isdigit() else stem}"
        words = []
        for row in rows:
            word = {"lemma": row["lemma"], "pos": row["pos"], "meaning": row["meaning"], "examples": [row["example"]],
                    "wrong": [row["wrong1"]] + ([row["wrong2"]] if row["wrong2"] else []), "cefr": row["cefr"], "register": row["register"]}
            if row["id"]:
                word["id"] = row["id"]
            if row.get("synonyms"):
                word["synonyms"] = row["synonyms"]
            words.append(word)
        header = {"id": group_id, "title": title, "level": level, "tagline": tagline, "sources": SOURCES}
        if is_field:
            header["kind"] = "field"
        path = OUT / f"lexicon-{stem}.json"
        path.write_text(json.dumps(curl({"schemaVersion": 2, "group": header, "words": words}), indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        total += len(words)
        print(f"wrote {path.relative_to(ROOT)}: {len(words)} words")
    print(f"total {total} words in {len(GROUPS)} level groups and {len(FIELD_GROUPS)} field packs")


if __name__ == "__main__":
    build()
