#!/usr/bin/env python3
"""Round 3: remove the give-aways found by the OpenCode audit (docs/reviews/opencode-giveaway-audit-2026-10-25.md).

Patches the bundled JSON in place; idempotent (each item is set to its final text). Backup: application/.build/backup/.
Covers: answers printed word for word in the prompt, options that differ only by case or punctuation, dictation
sentences already printed in the lesson, and the ten worst answer-longest choice items.
The answer is options[0] in the files on purpose; the app shuffles choices when it shows them.
"""
import glob, json, os, shutil

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
RES = os.path.join(ROOT, "application", "SpeechCoachAI", "Resources")

# id -> (prompt or None, options with the answer first, or None for dictation)
CHOICE = {
    "jn-five-ws-02": (None, ["In a shop that sells furniture", "At a school", "In a forest", "At the fire station"]),
    "jn-five-ws-03": (None, ["Monday night", "In two hours", "Friday evening", "Tuesday at noon"]),
    "jn-five-ws-05": (None, ["An electrical fault, but officials are not certain", "A storm hit the store", "A car hit the building", "The cause is known for sure"]),
    "jn-quote-attribute-01": (None, ["“I love this town,” said Mia.", "“I love this town,” said to Mia.", "“I love this town” Mia, said.", "Said Mia, I love this town."]),
    "jn-quote-attribute-03": (None, ["The mayor said the road will close on Monday.", "The mayor said, “Close the road on Monday!”", "“The road will close,” said the mayor.", "The mayor said, “Close it!”"]),
    "gram-sent-subject-11": (None, ["She sings.", "she sing", "Sings she.", "Sing she."]),
    "cp-benefit-13": (None, ["Students can carry heavy books comfortably.", "The new backpack has padded straps.", "A waterproof base.", "The backpack is new."]),
    "st-moment-12": (None, ["A guard helped her use her phone", "Dana missed the last train home", "Dana bought a charger", "Dana likes trains"]),
    "st-arc-12": (None, ["His oven broke", "Pablo wanted to win the cooking contest", "He won the contest", "He had a neighbor"]),
    "rl-detail-find-01": (None, ["At the front gate", "The science museum", "On the bus", "In the classroom"]),
    "rl-detail-find-03": (None, ["Food and water from home", "Money for the museum café", "A hot meal from school", "Nothing at all"]),
    "rl-detail-find-04": (None, ["An animal got into the garden and ate a plant", "She likes the color", "Her neighbor asked her", "It rains a lot"]),
    "rl-detail-find-05": (None, ["Every evening", "Last week", "Every morning", "Only on Sunday"]),
    "rl-scan-facts-04": ("Read this. Opening hours: Monday to Friday 9:00 a.m. to 6:00 p.m. Saturday 10:00 a.m. to 4:00 p.m. Sunday closed. Phone: 555-0142. Address: 12 Oak Road. Parking: behind the shop on Pine Road. Which road is the shop on?",
                         ["Oak Road", "Pine Road", "Main Road", "Elm Road"]),
    "rl-scan-facts-07": ("Read this. Adult ticket: $4. Children under 12: $2. Day pass: $9. Children under 5 travel free. Who travels free?",
                         ["Children under 5", "Children under 12", "All adults", "Nobody"]),
    "rl-scan-facts-08": ("Read this. Spring Market. Saturday, April 14. Stalls open at 9:00 a.m. Free parking at the Town Hall. Live music from 2:00 p.m. Clean-up: Sunday, April 15, at the library. On which day is the market?",
                         ["Saturday, April 14", "Sunday, April 15", "Saturday, April 4", "Friday, April 14"]),
    "rl-scan-facts-09": ("Read this. Spring Market. Saturday, April 14. Stalls open at 9:00 a.m. Free parking at the Town Hall. Live music from 2:00 p.m. Clean-up: Sunday, April 15, at the library. Where is the free parking?",
                         ["At the Town Hall", "At the library", "At the market stalls", "On Oak Road"]),
    "rl-main-idea-01": (None, ["Daily walking is an easy way to keep healthy", "Special shoes are expensive", "Gyms are better than walking", "Walking is only for older people"]),
    "cw-character-06": (None, ["To be well known for his cartoons", "To become a teacher", "To hide his notebook forever", "To win a race"]),
    "a1-greetings-read": (None, ["Good evening.", "Good morning.", "Good afternoon.", "How are you?"]),
    "a1-alphabet-production-v3-1": ("Which sentence is correct?", ["My name is Ben.", "My is name Ben.", "Name my is Ben.", "My name Ben is."]),
    "a1-places-read": (None, ["On the right.", "On the left.", "Go straight.", "Behind you."]),
    "a1-places-production-v3-5": ("Which version is in the right order?", ["Go straight. Turn left. The library is on the right.", "Go straight left turn. Library the is on right.", "Turn left straight go. The library right is on.", "The library right is. Go straight turn left on."]),
    "a1-hobbies-read": ("Read this. Mina plays the piano on Sunday. She cooks on Monday. When does she play the piano?", ["On Sunday.", "On Monday.", "On Saturday.", "At night."]),
    "a1-weather-read": ("Read this. Yesterday it was cold and rainy. Today it is hot and sunny. Mina wants water. What is the weather like today?", ["Hot and sunny.", "Cold and rainy.", "Cold and sunny.", "Hot and rainy."]),
    "a2-health-read": (None, ["For about a day.", "For one week.", "Since Monday.", "Since this morning."]),
    "a2-eating-read": (None, ["It was not hot enough.", "The soup was too salty.", "The bowl was dirty.", "The server was late."]),
    "a2-invitations-read": (None, ["He has other plans.", "He does not like coffee.", "He is on vacation.", "He is sick."]),
    "a2-leisure-read": (None, ["She had no energy.", "She had no ticket.", "She did not like music.", "The concert was canceled."]),
    "a2-work-read": (None, ["Do a coworker’s job for a while.", "Answer all the email.", "Close the office.", "Write a report."]),
    "a2-problems-read": (None, ["The elevator did not work.", "She missed the train.", "Her phone was broken.", "She woke up late."]),
    "b1-career-read": (None, ["To a job in planning.", "To a job in support.", "To a job in design.", "To a job in sales."]),
    "b1-relationships-read": (None, ["About two years.", "Since last month.", "For ten years.", "Since yesterday."]),
    "b1-entertainment-read": (None, ["A TV show that is not long.", "A long movie.", "A music show.", "A news program."]),
    "b1-achievements-read": (None, ["A ten-kilometer race.", "A marathon.", "A half marathon.", "A swimming race."]),
    "b1-unexpected-read": (None, ["In the back rows.", "At the front.", "Outside the hall.", "In the first row."]),
    "b2-projects-read": (None, ["Waiting a little longer.", "An earlier date.", "A bigger team.", "A public launch."]),
    "b2-media-read": (None, ["A video that spread online.", "A news report.", "A court case.", "A weather map."]),
    "b2-social-read": (None, ["Current residents near the stations.", "Commuters on the new line.", "People who live far away.", "The owners of the trains."]),
    "b2-ethics-read": (None, ["A clear explanation.", "A longer form.", "A free gift.", "A new field."]),
    "b2-environment-read": (None, ["The office heating change.", "The reusable cups.", "The poster campaign.", "The bicycles."]),
    "c1-research-read": (None, ["The whole market.", "A pilot.", "A diary.", "A rumor."]),
    "c1-sensitive-read": (None, ["Why someone acted, without proof.", "A pattern she has seen.", "A rule she wrote.", "A deadline she set."]),
    "c2-abstract-read": (None, ["Who sets the limit.", "How much people hide.", "What a rule says.", "Why a secret is kept."]),
    "c2-interpret-read": (None, ["The most orderly reading.", "The longest reading.", "The oldest reading.", "The loudest reading."]),
    "c2-debate-read": (None, ["Agreeing about what happened.", "Agreement on the plan.", "Agreement on the date.", "Agreement on the budget."]),
    # answer-longest: make every option the same shape and length
    "jn-headlines-04": (None, ["A water pipe broke on Main Street on Monday, closing the road for a day.", "Water pipes are old and often break when it gets cold outside.", "Main Street is a long road with many shops and a few cafés.", "Many people use Main Street every day to go to work and school."]),
    "jn-summarize-01": (None, ["The council voted to build a bike lane; supporters say it is safer, and some shop owners worry about parking.", "The council made a terrible choice about bikes, and the shop owners are right to be angry about it.", "The council voted to build a bike lane and everybody agreed that it was a very good plan.", "Shop owners lost their parking spaces on Pine Street and are now angry with the city council."]),
    "ps-open-close-03": (None, ["Last winter, my bus broke down in the snow, and a stranger changed my mind about people.", "Today I will talk about why sleep is important for students and for people who work.", "Good morning, everyone. My talk has three parts, and the first part is about sleep.", "Sleep is a topic that many people have studied for a long time in many countries."]),
    "ps-open-close-04": (None, ["So the next time you feel tired, protect your sleep. Start tonight.", "That is all I wanted to say today, so I think I am finished now. Goodbye.", "Sorry, I ran out of time, so I will stop here and you can ask me questions.", "Um, I think that is about it, so thank you for listening to me today."]),
    "st-arc-05": (None, ["Because the bridge was closed, he took the long road and met his old teacher.", "He walked to the bridge, he ate his lunch there, and then he slept in the park.", "Then he went home. Then he saw a dog. Then he saw a bird in a tree nearby.", "A bridge, a road, a teacher, a lunch, a park, a dog and a bird in a tree."]),
    "st-trim-05": (None, ["A long explanation of how your uncle met his wife, in a story about a lost phone", "The moment you lost the phone and ran back along the street to look for it", "The ending, where you find the phone and say thank you to the kind stranger", "The opening hook, where you tell the listener that you lost your phone on a bus"]),
    "bz-sbi-05": (None, ["In today’s meeting, you spoke over Ana twice, and she stopped sharing her ideas.", "You are always rude to other people in meetings, and you should stop doing it now.", "I think Ana does not like you, and that is why she does not speak when you do.", "You always ruin our meetings, and I am tired of how you act with the whole team."]),
    "cw-character-05": (None, ["Ravi wants to join the band but is afraid to play in front of people.", "Ravi plays the guitar every day after school and also writes songs in his room.", "Ravi is in the band with his two friends, and they play together on Saturdays.", "Ravi likes music very much, and he listens to new songs on his phone all day."]),
    "cw-show-tell-04": (None, ["She laughed, grabbed her friend’s hands and spun in a circle.", "She felt very happy, and she was glad about the news she had just heard.", "She was so happy that she could not say what the feeling was or why it came.", "She felt great joy inside, and everyone could see that she was in a good mood."]),
    "cw-start-end-03": (None, ["On the morning my brother disappeared, his bed was still warm.", "I woke up at seven o’clock and got out of bed to go downstairs for breakfast.", "It was a day in the middle of the week, and the weather was quite nice outside.", "There was a house at the end of our street, and it had a green door and a tree."]),
}

DICTATION = {
    "a1-greetings-dictation": "Good morning. I am fine, thanks.",
    "a1-alphabet-dictation": "Mina spells her name.",
    "a1-numbers-dictation": "Ben buys twelve eggs.",
    "family-01-dictation": "Mina has a brother.",
    "a1-home-dictation": "The kitchen is downstairs.",
    "routine-01-dictation": "Mina gets up at seven.",
    "food-01-dictation": "I would like coffee and a salad.",
    "a1-places-dictation": "The bank is on the left.",
    "a1-hobbies-dictation": "Ben plays football on Saturday.",
    "a1-weather-dictation": "The weather is cold today.",
    "a2-travel-dictation": "Ben took the bus to Boston in July.",
    "c1-debate-dictation": "The team trusts the incident log, whereas the manager trusts the survey.",
    "c2-abstract-dictation": "A boundary is a decision about who may see what.",
}


def main() -> int:
    paths = sorted(glob.glob(os.path.join(RES, "Tracks", "track-*.json"))) + [os.path.join(RES, "Curriculum", "CurriculumCatalog.json")]
    backup = os.path.join(ROOT, "application", ".build", "backup")
    os.makedirs(backup, exist_ok=True)
    done = set()
    for path in paths:
        with open(path, encoding="utf-8") as fh:
            data = json.load(fh)
        changed = False
        for lesson in data["lessons"]:
            for act in lesson["activities"]:
                aid, ex = act["id"], act.get("exercise") or {}
                if aid in CHOICE:
                    prompt, options = CHOICE[aid]
                    act["answer"] = options[0]
                    if prompt:
                        act["prompt"] = prompt
                    ex["options"], ex["accepted"] = options, [options[0]]
                    done.add(aid)
                    changed = True
                elif aid in DICTATION:
                    text = DICTATION[aid]
                    act["answer"], ex["audioText"], ex["accepted"] = text, text, [text]
                    done.add(aid)
                    changed = True
        if changed:
            shutil.copy(path, os.path.join(backup, os.path.basename(path) + ".pre-giveaways"))
            with open(path, "w", encoding="utf-8") as fh:
                json.dump(data, fh, ensure_ascii=False, indent=2)
                fh.write("\n")
    missing = (set(CHOICE) | set(DICTATION)) - done
    print(f"patched {len(done)} items" + (f"; NOT FOUND: {sorted(missing)}" if missing else ""))
    return 1 if missing else 0


if __name__ == "__main__":
    raise SystemExit(main())
