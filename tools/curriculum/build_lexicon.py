#!/usr/bin/env python3
"""Build the predefined Lexicon bank: Resources/Lexicon/lexicon-*.json (3 groups x 40 words).

Every meaning and sentence is original wording written for this app. Word choice follows general-purpose and academic
frequency ideas (no list text is copied or bundled). Each entry is
(lemma, part of speech, meaning, example with the word form in {braces}, wrong usage 1, wrong usage 2).
Wrong-usage sentences are grammatical but use the word in a way that does not fit its meaning, or break a pattern of the word.

Run from the project root: python3 tools/curriculum/build_lexicon.py
"""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "application/SpeechCoachAI/Resources/Lexicon"

SOURCES = ["Word choice guided by general-purpose and academic frequency ideas (NGSL and AWL families); all meanings and sentences are original."]

EVERYDAY = [
    ("happy", "adjective", "Feeling pleased and cheerful.", "Mina was {happy} when her friend called.", "I am happy because my dog is very sick.", "Yesterday she happy to see us."),
    ("buy", "verb", "To get something by paying money for it.", "We {buy} bread at the corner shop.", "I buy a new coat, so the shop pays me money.", "Yesterday I buy a new phone."),
    ("kitchen", "noun", "The room where people cook food.", "Dad is making soup in the {kitchen}.", "We take a hot shower in the kitchen.", "A kitchen is a person who cooks."),
    ("window", "noun", "An opening in a wall that lets in light and air.", "Please open the {window}; it is hot.", "It is freezing, so please open the window wide.", "She cut the bread with a window."),
    ("quickly", "adverb", "In a short time; fast.", "She ate her breakfast {quickly} and ran to school.", "He walked quickly, so he arrived after a very long hour.", "She is a very quickly runner."),
    ("tired", "adjective", "Needing rest or sleep.", "I am {tired} after a long day at work.", "I slept ten hours, so I am very tired and full of energy.", "She tired very much last night."),
    ("friend", "noun", "A person you like and know well.", "My {friend} lives next door.", "A friend is someone you do not know at all.", "He friend me a book yesterday."),
    ("cook", "verb", "To prepare food by heating it.", "I {cook} rice for dinner every evening.", "I cooked dinner with cold water and no heat.", "She cooks the television for dinner."),
    ("weather", "noun", "The sun, rain, wind or cold outside.", "The {weather} is sunny today.", "The weather is my brother's name.", "The weathers are sunny today."),
    ("street", "noun", "A road in a town with buildings on the sides.", "The bakery is on the next {street}.", "We drive on the street from the kitchen to the bedroom.", "I sat on the streets and read a street."),
    ("early", "adverb", "Before the usual or expected time.", "We arrived {early} and waited for the doors to open.", "I arrived early, so I missed the beginning of the film.", "She comes early than me."),
    ("market", "noun", "A place where people buy and sell food and goods.", "Grandma buys fresh fish at the {market}.", "The market is a room where we sleep.", "He markets yesterday to buy apples."),
    ("wash", "verb", "To clean something with water.", "Please {wash} your hands before lunch.", "I wash my hands with dirty sand.", "He washes his car yesterday."),
    ("library", "noun", "A place where you can read or borrow books.", "She borrowed three books from the {library}.", "We buy bread at the library.", "A library is a kind of soup."),
    ("ticket", "noun", "A piece of paper that lets you enter or travel.", "I need a {ticket} for the train.", "A ticket is a kind of soup.", "The ticket was cheap, so it cost one thousand dollars."),
    ("borrow", "verb", "To take something and give it back later.", "Can I {borrow} your pen for a minute?", "I borrow my sister a pen.", "Please borrow me your pen and keep it forever."),
    ("birthday", "noun", "The day each year when you were born.", "Her {birthday} is in March.", "My birthday is every day of the week.", "Today is my birthday of the winter."),
    ("lunch", "noun", "The meal you eat in the middle of the day.", "We have {lunch} at noon.", "I eat lunch at midnight, before breakfast.", "She lunches a letter."),
    ("careful", "adjective", "Paying attention so you do not make a mistake or get hurt.", "Be {careful}; the floor is wet.", "He was very careful, so he fell down three times.", "She is careful at the stairs of."),
    ("lose", "verb", "To not be able to find something.", "Don't {lose} your keys again.", "I lose my keys, so I know exactly where they are.", "He lose his wallet yesterday."),
    ("bedroom", "noun", "A room where you sleep.", "My {bedroom} has a small desk and a lamp.", "We cook dinner in the bedroom oven.", "He bedroomed a cold shower."),
    ("answer", "verb", "To say or write something after a question.", "Please {answer} the phone.", "I answer a question before anyone asks me.", "She answers to the question of the teacher."),
    ("cheap", "adjective", "Not costing much money.", "These shoes were {cheap}, so I bought two pairs.", "The shoes were cheap, so they cost a lot of money.", "This is the most cheap shop."),
    ("visit", "verb", "To go and see a person or place for a short time.", "We {visit} my grandparents on Sundays.", "I visit my aunt and I never see her.", "She visits to her aunt on Sundays."),
    ("neighbor", "noun", "A person who lives near you.", "Our {neighbor} waters our plants when we travel.", "My neighbor lives in another country, far from my house.", "She neighbors very kind."),
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
    ("repeat", "verb", "To say or do something again.", "Please {repeat} the question.", "I repeat the word once and only one time.", "He repeat the song again."),
    ("beautiful", "adjective", "Very nice to look at or hear.", "The garden looks {beautiful} in spring.", "The garden looks very beautiful and ugly.", "She sings beautiful."),
    ("plan", "noun", "An idea about what you will do.", "What is your {plan} for the weekend?", "I put my plan in the oven for ten minutes.", "He plans of the dog a shoe."),
    ("clean", "adjective", "Not dirty.", "Please put on a {clean} shirt.", "The floor is clean because it is covered with mud.", "He is clean the room now."),
]

WORK = [
    ("schedule", "noun", "A list of times when things will happen.", "My {schedule} is full on Monday.", "I eat my schedule for lunch.", "The schedule are on the wall."),
    ("deadline", "noun", "The last time or day by which something must be done.", "The {deadline} for the report is Friday.", "We finished the work a week after the deadline, so we were early.", "Please do it in the deadline."),
    ("meeting", "noun", "An event where people come together to talk about work.", "We have a {meeting} at ten o'clock.", "I wore my meeting on my feet.", "She meetings with her manager."),
    ("colleague", "noun", "A person you work with.", "My {colleague} helped me with the spreadsheet.", "My colleague lives in another company and I have never met her.", "He colleagues a long report."),
    ("manager", "noun", "A person who is in charge of a team or a place.", "The {manager} thanked us for our hard work.", "The manager follows all the orders of the new employee.", "She managers the team."),
    ("salary", "noun", "Money an employee gets regularly for their work.", "He got a higher {salary} after the promotion.", "I pay my salary to the company every month.", "She salaries ten thousand pesos."),
    ("invoice", "noun", "A paper that lists what a customer must pay.", "Please send the {invoice} by email.", "The invoice shows the date of our next holiday.", "He invoice us for the work."),
    ("appointment", "noun", "A planned time to meet someone.", "I have a dentist {appointment} at four.", "I met a stranger on the street by appointment, but we never planned it.", "She appointment the doctor."),
    ("customer", "noun", "A person who buys goods or services.", "The {customer} asked for a refund.", "The customer sells the goods to the shop.", "He customers many things."),
    ("report", "noun", "A document that gives information about something.", "She wrote a short {report} on sales.", "I ate a report for breakfast.", "He reports are on his desk."),
    ("project", "noun", "A piece of work that is planned with a goal.", "Our team finished the {project} on time.", "The project is a small yellow bird.", "She projects a new idea last week."),
    ("team", "noun", "A group of people who work together.", "Our {team} meets every Monday.", "I am the only person in our team of twelve.", "He teams in the sales department."),
    ("task", "noun", "A piece of work that must be done.", "Writing emails is my first {task} each day.", "My task is something I never need to do.", "She tasks many jobs today."),
    ("budget", "noun", "A plan for how much money you will spend.", "We need to stay within the {budget}.", "We spent twice our budget, so we saved money.", "He budgets a sunny river."),
    ("contract", "noun", "A written agreement between people or companies.", "Both sides signed the {contract}.", "We signed the contract, but nobody agreed to anything.", "She contract the new worker."),
    ("employee", "noun", "A person who is paid to work for a company.", "Each {employee} gets a security badge.", "The employee pays the company a salary every month.", "He employee at the bank."),
    ("supervisor", "noun", "A person who watches and guides the work of others.", "My {supervisor} checks the schedule every morning.", "My supervisor is the newest worker and has no team.", "She supervisors a team."),
    ("resume", "noun", "A short document that lists your jobs and skills.", "Send your {resume} with the application form.", "My resume is a list of my favorite foods.", "He resumes in the box."),
    ("interview", "noun", "A formal meeting where someone asks you questions about a job.", "I have a job {interview} on Tuesday.", "At the interview, I asked the manager all the questions and she said nothing.", "She interview with the manager."),
    ("promote", "verb", "To give someone a higher job.", "They will {promote} her to manager next month.", "They promoted him, so he lost his job.", "He promoted to the manager."),
    ("office", "noun", "A place where people do desk work.", "I take the bus to the {office}.", "I cook dinner in the office of my pocket.", "She office at nine."),
    ("department", "noun", "One part of a large company or organization.", "She works in the sales {department}.", "The department is a big company with no parts.", "He departments in the building."),
    ("client", "noun", "A person or company that pays for your services.", "Our {client} wants a new logo.", "Our client works for us and gets a salary.", "She clients the company."),
    ("delay", "noun", "A time when something happens later than planned.", "There is a one-hour {delay} at the airport.", "The delay made the train arrive early.", "He delay the flight."),
    ("remind", "verb", "To help someone remember something.", "Please {remind} me to call the bank.", "I remind a letter to the bank.", "She reminds me about to call."),
    ("attach", "verb", "To fix one thing to another, such as a file to an email.", "Please {attach} the document to your email.", "I attach the document by deleting it from the email.", "He attached with the file."),
    ("submit", "verb", "To give a document or work to someone for a decision.", "You must {submit} the form by noon.", "I submit the form to myself and nobody reads it.", "She submitted for the report."),
    ("review", "verb", "To look at something again to check it.", "I will {review} your report tonight.", "I review the report before I write it.", "He reviews to the document."),
    ("apply", "verb", "To ask formally for a job or a place.", "She decided to {apply} for the new position.", "I apply a new job, so they ask me to leave.", "He applied to the a job."),
    ("hire", "verb", "To give someone a job.", "The company will {hire} three new workers.", "The company hired him, so he lost his job.", "They hires many workers."),
    ("shift", "noun", "A set period of time when a person works.", "He works the night {shift} at the hospital.", "My shift is a week of holidays.", "She shift every night."),
    ("overtime", "noun", "Extra hours of work after the normal day.", "I worked two hours of {overtime} last night.", "I left work early, so I did a lot of overtime.", "He overtimes yesterday."),
    ("agenda", "noun", "A list of things to talk about at a meeting.", "The {agenda} has five items.", "We read the agenda after the meeting ended.", "She agendas many things."),
    ("feedback", "noun", "Comments that tell you how well you did something.", "I asked my boss for {feedback} on my presentation.", "I gave my boss feedback before I did the presentation.", "He feedbacks us."),
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
    ("evidence", "noun", "Facts or signs that show something is true.", "The police found new {evidence}.", "He has no evidence, but he is completely sure it is a fact.", "The evidences are on the desk."),
    ("factor", "noun", "One of the things that affect a result.", "Cost is an important {factor} in the decision.", "A factor is a result that has no cause.", "She factors the decision."),
    ("function", "noun", "The purpose or normal job of something.", "The {function} of the heart is to pump blood.", "The function of a key is to cut bread.", "He functions of the machine."),
    ("impact", "noun", "A strong effect on something.", "The new law had a big {impact} on small shops.", "The law had a big impact, but nothing changed.", "She impacts of the law."),
    ("indicate", "verb", "To show or point to something.", "The results {indicate} that the plan works.", "The results indicate that nobody knows anything.", "He indicated to the sign."),
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
    ("respond", "verb", "To answer or react to something.", "Please {respond} to the email by Friday.", "I responded before I read the email.", "She responds the letter."),
    ("role", "noun", "The part someone or something plays in a situation.", "Parents play an important {role} in learning.", "A role is a kind of bread.", "He roles in the project."),
    ("significant", "adjective", "Important enough to have a clear effect.", "There was a {significant} change in the numbers.", "The change was significant because it was too small to notice.", "She significants a result."),
    ("source", "noun", "A place, person or thing where information or something else comes from.", "The report names its {source} for each fact.", "The report has no source and no one wrote it.", "He sources of the river."),
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

GROUPS = [
    ("1-everyday", {"id": "everyday-a1", "title": "Everyday A1", "level": "A1", "tagline": "Words for daily life"}, EVERYDAY),
    ("2-work", {"id": "work-office", "title": "Work and office", "level": "A2-B1", "tagline": "Words for the workplace"}, WORK),
    ("3-academic", {"id": "academic-basics", "title": "Academic basics", "level": "B1-B2", "tagline": "Words for study and reports"}, ACADEMIC),
]


def build() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for stem, header, rows in GROUPS:
        words = []
        for lemma, pos, meaning, example, wrong1, wrong2 in rows:
            words.append({"lemma": lemma, "pos": pos, "meaning": meaning, "examples": [example], "wrong": [wrong1, wrong2]})
        data = {"schemaVersion": 1, "group": {**header, "sources": SOURCES}, "words": words}
        path = OUT / f"lexicon-{stem}.json"
        path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        print(f"wrote {path.relative_to(ROOT)}: {len(words)} words")


if __name__ == "__main__":
    build()
