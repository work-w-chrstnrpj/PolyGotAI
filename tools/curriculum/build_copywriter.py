#!/usr/bin/env python3
"""Build the Advertising & Copywriting track (Foundation stage, 2 units x 4 lessons): Resources/Tracks/track-copywriter.json.

All ads, lines and tips are original wording. Concepts (features versus benefits, value proposition, headlines, honest
claims, AIDA, calls to action, tone, editing) are standard copywriting teaching, credited for ideas only. Every example
uses invented products.
Run from the project root: python3 tools/curriculum/build_copywriter.py
"""
from track_lib import C, TF, READ, LISTEN, W, F, O, M, YOUR, build_manifest, write_track

SOURCES = [
    "Hopkins, Scientific Advertising (1923, public domain): plain, specific, honest selling (concepts only)",
    "US Federal Trade Commission truth-in-advertising principles (US government, public domain; summarized) and the AIDA model (concept)",
]

STAGES = [{"id": "foundation", "title": "Foundation", "units": [
    {"id": "message", "title": "Know your message"},
    {"id": "copy", "title": "Write the copy"},
]}]

BACKPACK = "The new backpack has padded straps and a waterproof base. Students can carry heavy books comfortably, and their things stay dry on rainy days."
BAKERY = "A small bakery wanted to tell people about its bread, its coffee, its cakes, its delivery, its shop hours, its music nights and its new tables on one poster. People walked past and remembered nothing. Later, the poster said only: “Fresh bread, every morning at six.” Sales rose."
GYM = "A gym tried two posters. One said, “The best gym in town.” The other said, “Open 24 hours: train before work or after midnight.” The second poster brought in twice as many new members."
SHOP = "A shop advertised free delivery but charged a delivery fee at the last step. Customers felt tricked, wrote angry reviews and stopped buying. The shop changed the ad to say, “Free delivery on orders over $40.” Complaints stopped."
SOCKS = "Tired of cold feet? Our wool socks use soft, thick fibers that trap heat. Picture a winter walk with warm, dry feet all day. Buy a pair this week and get the second pair half price."
SCHOOL = "A language school changed its button from “Click here” to “Book your free first lesson.” Within a month, sign-ups doubled."
SOUP = "A soup company used to write, “Customers are advised that product consumption should occur within three days.” After a rewrite, the can said, “Eat me within three days.” People smiled and remembered the brand."
EDIT = "A writer fixed a line. Before: “Our company provides a very wide variety of really good high-quality services at excellent prices for many different people.” After: “Plumbing, painting and repairs at fair prices, in one call.” The client chose the second version."

LESSONS = [
    ("cp-benefit", "message", "Features and benefits", "CP-F-01",
     "A feature says what a product has: “a 20-hour battery.” A benefit says what it does for the customer: “you can use it all week without charging.” People buy benefits. First learn who your customer is and what they want, then turn each feature into a benefit.",
     [
         C("Which is a feature?", "The phone has a 20-hour battery.", "You can go all week without charging.", "You will never miss a call.", "You will feel free."),
         C("Which is a benefit?", "You can use it all week without charging.", "It has a 20-hour battery.", "It is made of aluminum.", "It has a 6-inch screen."),
         C("Turn this feature into a benefit: “The bag is waterproof.”", "Your things stay dry in any weather.", "The bag is made of plastic.", "The bag has two zips.", "The bag is gray."),
         C("Turn this feature into a benefit: “The app sends reminders.”", "You never forget an important task.", "The app is colorful.", "The app has an icon.", "The app is new."),
         C("Who buys benefits?", "Customers", "Only factories", "Only designers", "Nobody"),
         C("What should you know before writing copy?", "Who the customer is and what they want", "The weather", "The writer's favorite color", "The printer's name"),
         M("Match each feature with its benefit.", [["A 20-hour battery", "use it all week without charging"], ["A waterproof coat", "stay dry in a storm"], ["A lightweight laptop", "carry it easily all day"]]),
         O("Put the steps in order.", ["Learn who the customer is", "List the product's features", "Turn each feature into a benefit"]),
         TF("True or false: A benefit says what a product does for the customer.", "True"),
         TF("True or false: A feature and a benefit are the same thing.", "False"),
         F("Type the missing word: Customers buy ___.", "benefits"),
         W("Build the sentence.", "Turn features into benefits.", "never", "hide"),
         READ(BACKPACK, "Which sentence names a benefit?", "Students can carry heavy books comfortably.", "The backpack has padded straps.", "It has a waterproof base.", "The backpack is new."),
         LISTEN("This kettle boils in sixty seconds. That means your morning tea is ready before your toast is done.", "What is the benefit?", "Tea is ready before the toast is done", "The kettle has a lid", "The kettle is white", "The kettle uses electricity"),
         YOUR("Choose a product you own. Write two features and turn each into a benefit."),
     ]),
    ("cp-idea", "message", "One big idea", "CP-F-02",
     "Give your message one big idea. A value proposition says what you offer, who it is for and why it is better, in one clear sentence: “Quick, healthy lunches for busy students.” Too many ideas confuse people. If everything is important, nothing is.",
     [
         C("Which is a clear value proposition?", "Quick, healthy lunches for busy students", "Food", "We have many good things for everyone", "The best of everything"),
         C("What does a value proposition include?", "What you offer, who it is for and why it is better", "Only the price", "Only the logo", "Only a slogan"),
         C("Which message has one big idea?", "Fresh bread, baked every morning.", "Fresh bread, cheap phones, cars, flowers and free insurance.", "Everything for everyone.", "Stuff you may like."),
         C("Why is one idea better than many?", "People remember one clear idea", "Many ideas are free", "One idea is longer", "It avoids the customer"),
         C("Which is too vague?", "The best quality for everyone", "Waterproof shoes for city runners", "Fast delivery in 30 minutes", "A free trial for new users"),
         O("Put the steps in order.", ["Decide who the customer is", "Decide what you offer", "Say why it is better in one sentence"]),
         M("Match each part with an example.", [["Offer", "quick, healthy lunches"], ["Customer", "busy students"], ["Why better", "ready in five minutes"]]),
         TF("True or false: A good message has one big idea.", "True"),
         TF("True or false: A vague message is easy to remember.", "False"),
         F("Type the missing word: A value ___ says what you offer and why it is better.", "proposition"),
         W("Build the sentence.", "One message, one big idea.", "never", "ten"),
         READ(BAKERY, "Why did the second poster work better?", "It had one clear idea", "It had more words", "It had a longer list", "It had no information"),
         LISTEN("We make shoes for people who walk all day. Soft soles, no sore feet.", "Who is the customer?", "People who walk all day", "Children only", "Office managers", "Athletes only"),
         YOUR("Write a one-sentence value proposition for a product, a club or a service you know."),
     ]),
    ("cp-headline", "message", "Headlines that work", "CP-F-03",
     "A headline has one job: make people want to read the next line. Good headlines promise a benefit, raise a question, use a number or say something new. Keep them short and specific. Avoid vague words like “great” and “best” with no proof.",
     [
         C("Which headline promises a clear benefit?", "Cut your commute in half with a folding bike", "Bikes", "Great bikes for everyone", "Our company"),
         C("Which headline uses a number?", "Five ways to sleep better tonight", "Sleep better", "Sleep", "Good sleep"),
         C("Which headline raises a question?", "Tired of slow Wi-Fi?", "Wi-Fi is good", "Our Wi-Fi", "Wi-Fi"),
         C("Which headline is too vague?", "The best product ever", "Fix a leaking tap in ten minutes", "Save 20 percent this week", "Learn English in your lunch break"),
         C("What is a headline's main job?", "Make people want to read the next line", "List every feature", "Show the price only", "Explain the company's history"),
         M("Match each headline type with an example.", [["Benefit", "Sleep better in one week"], ["Question", "Tired of slow Wi-Fi?"], ["Number", "Seven tips for faster mornings"]]),
         O("Put the steps in order.", ["Know the main benefit", "Write ten short headlines", "Choose the clearest one"]),
         TF("True or false: A good headline is specific.", "True"),
         TF("True or false: “Best product ever” is a strong headline with no proof.", "False"),
         F("Type the missing word: A headline should make people want to read the ___ line.", "next"),
         W("Build the headline.", "Cut your commute in half.", "never", "double"),
         READ(GYM, "Why did the second headline work better?", "It was specific and promised a clear benefit", "It was shorter", "It used a joke", "It had no information"),
         LISTEN("Learn to cook in thirty minutes a day. No experience needed.", "What does the headline promise?", "Cooking skills in thirty minutes a day", "A free kitchen", "A new job", "A trip"),
         YOUR("Write three different headlines for the same product: one with a benefit, one with a question and one with a number."),
     ]),
    ("cp-honest", "message", "Honest claims", "CP-F-04",
     "Advertising must be true. Do not claim what you cannot prove, hide important costs or invent reviews. Say “up to” when results vary, and keep your proof ready. Honest copy builds trust, and trust sells again and again. Laws in many countries protect customers from false claims.",
     [
         C("Which claim can you prove?", "Delivery within 24 hours in our city", "The best in the world", "Everyone loves it", "Works miracles"),
         C("Which is a hidden-cost problem?", "Showing “$9” but adding fees at checkout", "Showing the full price", "Listing all fees", "Showing a final price early"),
         C("Which is a fake review?", "A review written by the company and signed with a made-up name", "A review from a verified customer", "A customer's real photo", "A rating given after purchase"),
         C("When results vary, which wording is honest?", "Save up to 20 percent", "Save 20 percent for sure", "Save a fortune", "Save everything"),
         C("Why does honest copy sell more over time?", "It builds trust", "It is shorter", "It has more words", "It uses fewer pictures"),
         M("Match each practice with its result.", [["Proof ready", "claims you can defend"], ["Hidden fees", "angry customers"], ["Fake reviews", "lost trust"]]),
         O("Put the steps in order.", ["Write the claim", "Check you can prove it", "Add the conditions clearly"]),
         TF("True or false: Advertising claims must be true.", "True"),
         TF("True or false: Making up reviews is acceptable.", "False"),
         F("Type the missing word: Keep ___ ready for every claim.", "proof", "evidence"),
         W("Build the sentence.", "Honest copy builds trust.", "never", "breaks"),
         READ(SHOP, "What was wrong with the first ad?", "It hid a cost the customer later had to pay", "It was too short", "It used a picture", "It had no price"),
         LISTEN("Our battery lasts up to ten hours, depending on how you use it. We test it ourselves and show the results on our website.", "Which words make this claim honest?", "Up to ten hours, depending on use", "The best battery on Earth", "Never needs charging", "Everyone agrees"),
         YOUR("Rewrite this claim so it is honest and provable: “The best phone in the world, guaranteed.”"),
     ]),
    ("cp-aida", "copy", "A short ad with AIDA", "CP-F-05",
     "AIDA is a simple plan for a short ad: Attention (a strong headline), Interest (a fact or story that fits the reader), Desire (show the benefit and how life improves) and Action (say what to do next). Keep each part short, and let each lead to the next.",
     [
         O("Put the AIDA ad in order.", ["Tired of slow mornings?", "Our bike gets you to work in ten minutes.", "Imagine arriving relaxed and on time every day.", "Order yours today."]),
         C("What does the first A in AIDA stand for?", "Attention", "Action", "Audience", "Answer"),
         C("What does I stand for?", "Interest", "Idea", "Image", "Income"),
         C("What does D stand for?", "Desire", "Design", "Deadline", "Detail"),
         C("What does the second A stand for?", "Action", "Attention", "Advertising", "Answer"),
         C("Which sentence creates desire?", "Imagine waking up fully rested every day.", "The mattress has springs.", "The mattress is rectangular.", "The mattress is sold in stores."),
         M("Match each AIDA part with its job.", [["Attention", "stop the reader"], ["Interest", "give a fact that fits the reader"], ["Desire", "show the benefit"], ["Action", "say what to do next"]]),
         W("Build the sentence.", "Order yours today.", "never", "later"),
         TF("True or false: Each AIDA part leads to the next.", "True"),
         TF("True or false: An ad should skip the action step.", "False"),
         F("Type the missing word: AIDA starts with ___.", "attention"),
         READ(SOCKS, "Which sentence is the action step?", "Buy a pair this week and get the second pair half price.", "Tired of cold feet?", "Our wool socks use soft, thick fibers that trap heat.", "Picture a winter walk with warm, dry feet all day."),
         LISTEN("Never miss a bus again. Our app tells you exactly when it arrives. Imagine leaving home right on time. Download it free today.", "Which sentence creates desire?", "Imagine leaving home right on time", "Download it free today", "Never miss a bus again", "It tells you when the bus arrives"),
         YOUR("Write a five-line ad using AIDA for a product you know."),
     ]),
    ("cp-cta", "copy", "Call to action", "CP-F-06",
     "A call to action (CTA) tells the reader exactly what to do next. Start with a strong verb: Buy, Join, Try, Book, Download. Be clear and specific: “Book your free class” beats “Click here.” Add a reason or a deadline if you can: “Book today and get a free lesson.”",
     [
         C("Which CTA is clearest?", "Book your free class today", "Click", "Maybe you can think about it", "Look around"),
         C("Which word makes a strong CTA verb?", "Join", "Perhaps", "Possibly", "Eventually"),
         C("Which CTA adds a reason?", "Join today and get your first month free", "Join", "Join us", "Join maybe"),
         C("Which CTA is vague?", "Learn more", "Download the free guide now", "Book your table for two", "Start your free trial"),
         C("Where should a CTA usually go?", "At the end, easy to see", "Hidden in the middle", "Before the headline", "Nowhere"),
         M("Match each CTA verb with its goal.", [["Buy", "complete a purchase"], ["Join", "become a member"], ["Download", "get a file"], ["Book", "reserve a time"]]),
         O("Put the steps in order.", ["Decide what you want the reader to do", "Choose a strong verb", "Add a reason or a deadline"]),
         W("Build the sentence.", "Join today and save.", "never", "maybe"),
         TF("True or false: A CTA should be clear and specific.", "True"),
         TF("True or false: A CTA should use long, polite hints.", "False"),
         F("Type the missing word: Start a CTA with a strong ___.", "verb"),
         READ(SCHOOL, "Why did the new button work better?", "It said exactly what would happen", "It was longer", "It was in a different color", "It had no verb"),
         LISTEN("Start your free trial today. No card needed. Cancel any time.", "What is the call to action?", "Start your free trial today", "Cancel any time", "No card needed", "Pay now"),
         YOUR("Write three calls to action for one product: one with a reason, one with a deadline and one very short."),
     ]),
    ("cp-tone", "copy", "Voice and tone", "CP-F-07",
     "Tone is how your words sound: friendly, serious, playful, expert. Choose a tone that fits the audience and the product, and keep it the same everywhere. Write as if you are talking to one person: use “you” and short words. Never sound rude, and never talk down to people.",
     [
         C("Which tone fits a children's toy?", "Playful and warm", "Cold and legal", "Bored", "Angry"),
         C("Which tone fits a bank's security warning?", "Clear and serious", "Silly", "Sarcastic", "Playful"),
         C("Which line is friendly?", "We're here whenever you need us.", "Contact the undersigned.", "Your query has been logged.", "Process terminated."),
         C("Which line speaks to one person?", "You can start in two minutes.", "All users may begin.", "Customers are advised to start.", "The system begins."),
         C("Why keep the same tone everywhere?", "It builds a recognizable brand", "It uses fewer words", "It makes copy longer", "It confuses people"),
         M("Match each product with a fitting tone.", [["Kids' game", "playful"], ["Medical advice", "calm and clear"], ["Luxury watch", "elegant"]]),
         O("Put the steps in order.", ["Think about who the reader is", "Choose the tone", "Write as if talking to one person"]),
         TF("True or false: Tone should fit the audience.", "True"),
         TF("True or false: It is fine to talk down to readers.", "False"),
         F("Type the missing word: Use “you” to talk to one ___.", "person"),
         W("Build the sentence.", "We're here whenever you need us.", "never", "undersigned"),
         READ(SOUP, "What did the rewrite change?", "It made the tone friendly and direct", "It made the text longer", "It removed the information", "It made it more legal"),
         LISTEN("Hi there. Hungry? Our soups are ready in three minutes. Just heat and enjoy.", "Which tone is this?", "Friendly and playful", "Cold and legal", "Angry", "Sad"),
         YOUR("Write the same two sentences about a coffee shop in a playful tone and in a serious tone."),
     ]),
    ("cp-edit", "copy", "Edit for clarity", "CP-F-08",
     "Edit your copy. Cut extra words. Replace vague words with concrete ones: “fast” becomes “ready in five minutes.” Use active verbs and short sentences. Read it aloud: if you stumble, rewrite. Check facts, names and prices last. One idea, one reader, one action.",
     [
         C("Which version is more concrete?", "Ready in five minutes", "Very quick", "Fast service", "Really speedy"),
         C("Which version uses an active verb?", "We deliver your order today.", "Your order will be delivered by us today.", "Delivery of the order is made today.", "The order's delivery today is planned."),
         C("Which is shorter and clearer?", "Save 20 percent today.", "Our company would like to offer you a saving of twenty percent on your purchases on this day.", "A saving may be made today.", "It is possible to save some money today."),
         C("What should you check last?", "Facts, names and prices", "The color of the text", "The font only", "The writer's name"),
         C("How can you test copy quickly?", "Read it aloud", "Print it in red", "Show it to nobody", "Count the commas"),
         O("Put the editing steps in order.", ["Cut extra words", "Make vague words concrete", "Read it aloud", "Check facts and prices"]),
         M("Match each edit with its result.", [["Cut extra words", "shorter copy"], ["Use concrete words", "clearer pictures"], ["Use active verbs", "stronger sentences"]]),
         W("Build the sentence.", "Cut every extra word.", "never", "add"),
         TF("True or false: Reading copy aloud helps you find weak lines.", "True"),
         TF("True or false: Longer copy is always better.", "False"),
         F("Type the missing word: Replace vague words with ___ ones.", "concrete", "specific"),
         READ(EDIT, "Why is the “after” version better?", "It is shorter, concrete and clear", "It is longer", "It has more adjectives", "It is more vague"),
         LISTEN("Fresh bread, baked at six, on your table by seven.", "Which detail is concrete?", "Baked at six", "Fresh", "Good", "Many"),
         YOUR("Edit this line: “Our shop offers a really wide range of excellent products at very good prices.” Make it shorter and concrete."),
     ]),
]

if __name__ == "__main__":
    manifest = build_manifest("copywriter", "copywriter", STAGES, LESSONS, "Foundation", SOURCES)
    write_track("copywriter", manifest)
