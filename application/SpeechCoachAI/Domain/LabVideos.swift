import Foundation

// Lab videos (Phase 15, expanded 2026-10-30): links only; each one opens YouTube and nothing is copied or embedded.
// Every ID and channel was checked with YouTube's oEmbed endpoint on 2026-10-30 (`tools/curriculum/check_lab_videos.py`).
// Titles are shortened for display. Channels are not a fixed list: the learner can mark favorites, which sort first.

enum LabVideoTopic: String, CaseIterable, Identifiable {
    case pronunciation, grammar, vocabulary, listening, speaking, voice, conversation, confidence
    case publicSpeaking, storytelling, persuasion, debate, writing, work
    var id: String { rawValue }
    var title: String {
        switch self {
        case .publicSpeaking: "Public speaking"
        case .persuasion: "Persuasion"
        case .debate: "Debate and reasoning"
        case .work: "Work and interviews"
        default: rawValue.capitalized
        }
    }
}

struct LabVideo: Equatable, Identifiable {
    /// The YouTube video ID.
    let id: String
    let title: String
    /// The YouTube channel name, exactly as YouTube reports it.
    let channel: String
    let topic: LabVideoTopic

    var url: URL { URL(string: "https://www.youtube.com/watch?v=\(id)")! }
}

enum LabVideoCatalog {
    static let all: [LabVideo] = [
        // pronunciation
        .init(id: "tw25CM1MXlU", title: "10 English Words You're (probably) Mispronouncing!", channel: "mmmEnglish", topic: .pronunciation),
        .init(id: "T91p6pTPpSY", title: "Speak English Clearly: The Imitation Technique", channel: "mmmEnglish", topic: .pronunciation),
        .init(id: "_Nh0osOwuSk", title: "10 English words that you pronounce INCORRECTLY", channel: "English with Lucy", topic: .pronunciation),
        .init(id: "m3g51xfopIE", title: "How to Improve Spoken American English - Sound like a Native Speaker", channel: "Rachel's English", topic: .pronunciation),
        .init(id: "q7SAt9h4sd0", title: "What Makes American English Sound American?", channel: "Rachel's English", topic: .pronunciation),
        .init(id: "X627czLUsGY", title: "Say These 100 DAILY WORDS in a British Accent! (MODERN RP)", channel: "English with Lucy", topic: .pronunciation),
        .init(id: "Vu6UVwkUgzc", title: "Syllables and Word Stress", channel: "Oxford Online English", topic: .pronunciation),
        // grammar
        .init(id: "veTo6eWJQrM", title: "Learn English Grammar: The 4 Conditionals", channel: "Learn English with Gill · engVid", topic: .grammar),
        .init(id: "du34F6p9rQ8", title: "Learn ALL 16 TENSES Easily in under 30 Minutes - Present, Past, Future, Conditional", channel: "English with Lucy", topic: .grammar),
        .init(id: "jul2urONzOQ", title: "English Sentence Structure", channel: "Oxford Online English", topic: .grammar),
        .init(id: "vd0yESrQMs0", title: "Learn English Tenses: PRESENT PERFECT", channel: "Learn English with Rebecca · engVid", topic: .grammar),
        .init(id: "XGw2-p2WuJk", title: "The Present Perfect Tense", channel: "mmmEnglish", topic: .grammar),
        .init(id: "4dr5lN1jqRE", title: "Learn English Grammar: The Sentence", channel: "Adam’s English Lessons · engVid", topic: .grammar),
        .init(id: "SceDmiBEESI", title: "Basic English Grammar: Parts of Speech – noun, verb, adjective, pronoun, adverb...", channel: "ENGLISH with James · engVid", topic: .grammar),
        .init(id: "TIUuTNoLPWE", title: "12 Confusing English Verbs", channel: "Learn English with Rebecca · engVid", topic: .grammar),
        // vocabulary
        .init(id: "Hm-n-_uqCvQ", title: "Learn the 100 Most Common Idioms in 30 Minutes (with examples)", channel: "English with Lucy", topic: .vocabulary),
        .init(id: "HD3IBffy6Z4", title: "LEARN 400 adjectives and synonyms & PRONOUNCE in 40 minutes", channel: "English with Lucy", topic: .vocabulary),
        .init(id: "O6T1DCB8iz8", title: "14 Overused English Words and Better Choices", channel: "linguamarina", topic: .vocabulary),
        .init(id: "jTP5bknxTi0", title: "20 Useful English Idioms That Native Speakers Use", channel: "linguamarina", topic: .vocabulary),
        .init(id: "B0heWo1XGhc", title: "A Fun Way to Learn 50 English Phrasal Verbs with Examples!", channel: "Learn English with Bob the Canadian", topic: .vocabulary),
        .init(id: "r7VKVXbaj_Y", title: "50+ COMMON ENGLISH PHRASAL VERBS", channel: "mmmEnglish", topic: .vocabulary),
        .init(id: "RnTpYKOLca4", title: "The Smart Way to Improve Your English: Collocations", channel: "mmmEnglish", topic: .vocabulary),
        .init(id: "CqRloBkyqQs", title: "Collocations in English", channel: "Oxford Online English", topic: .vocabulary),
        .init(id: "s_nk5khQM0Q", title: "50 Important Phrasal Verbs in English", channel: "Speak English With Vanessa", topic: .vocabulary),
        // listening
        .init(id: "aNYEtGxjGVc", title: "Slow English Listening and Fluency Practice (A1–A2)", channel: "English Unleashed: The Podcast", topic: .listening),
        .init(id: "26PrgjTboVQ", title: "6 Minute English: Are You Following Your Dreams?", channel: "BBC Learning English", topic: .listening),
        .init(id: "Y681hXWwhQY", title: "6 Minute English: The Benefits of Doing Nothing", channel: "BBC Learning English", topic: .listening),
        .init(id: "P26AE7NLx4Q", title: "Learn English with PODCASTS — Why Tom Holland DELETED His Instagram", channel: "Learn English With TV Series", topic: .listening),
        .init(id: "ZlO3xUl7Kdg", title: "Improve Your English Just by Listening (B1–B2)", channel: "Speak English with David & Alice ", topic: .listening),
        .init(id: "G1PnQBEImqU", title: "1 Hour of Slow English Shadowing", channel: "English Unleashed: The Podcast", topic: .listening),
        // speaking
        .init(id: "Rj5W40LjspA", title: "How to Be Disgustingly Articulate And Well Spoken", channel: "Vinh Giang", topic: .speaking),
        .init(id: "Sqh6rt1hN2A", title: "How to Explain Anything To Anyone (Even If It's Complex!)", channel: "Vinh Giang", topic: .speaking),
        .init(id: "Bhn71mwOjsA", title: "How to Answer ANY Question (Even If You Don't Know The Answer!)", channel: "Vinh Giang", topic: .speaking),
        .init(id: "HYNXzKU92Qs", title: "How to Speak When All Eyes Are On You...", channel: "Vinh Giang", topic: .speaking),
        .init(id: "r1i0a8zQnP0", title: "How to Speak Like a CEO", channel: "Alexander Lyon Communication Coach", topic: .speaking),
        .init(id: "YWocqAW7piQ", title: "How to Engage an Audience in Public Speaking 8 Tips", channel: "Alexander Lyon Communication Coach", topic: .speaking),
        .init(id: "zUBDMZNayj4", title: "How To Get Better At Public Speaking Fast", channel: "Charisma on Command", topic: .speaking),
        .init(id: "LDkvRFCm8No", title: "How can I speak English more fluently? Ask BBC Learning English", channel: "BBC Learning English", topic: .speaking),
        .init(id: "HAnw168huqA", title: "Think Fast, Talk Smart: Communication Techniques", channel: "Stanford Graduate School of Business", topic: .speaking),
        .init(id: "eIho2S0ZahI", title: "How to Speak So That People Want to Listen (Julian Treasure)", channel: "TED", topic: .speaking),
        .init(id: "KaA_mxga3PQ", title: "Speak English Fluently - 5 Steps to Improve Your English Fluency", channel: "Oxford Online English", topic: .speaking),
        .init(id: "5m-C5mwpmxU", title: "The 3-2-1 Speaking Trick That Forces You To Stop Rambling!", channel: "Vinh Giang", topic: .speaking),
        .init(id: "o3K_HbpWNpg", title: "Think Fast. Talk Smart (Matt Abrahams)", channel: "TEDx Talks", topic: .speaking),
        .init(id: "PiNN-HmHu7A", title: "9 Habits for Clearer Speaking (I Wish I Knew Sooner)", channel: "Vinh Giang", topic: .speaking),
        // voice
        .init(id: "hIFCxzdSGfU", title: "This Boring 9 Min/Day Exercise Helps You Instantly Speak Clearer!", channel: "Vinh Giang", topic: .voice),
        .init(id: "3B5gmNKFqSY", title: "3 Steps To Improve Your Speech Clarity", channel: "Vinh Giang", topic: .voice),
        .init(id: "5kpscm-ekFY", title: "How to Sound Friendly Without Losing Authority", channel: "Vinh Giang", topic: .voice),
        .init(id: "35Q4krRIz9o", title: "5 \"Low Status\" Speaking Habits That Make You Sound Weak", channel: "Vinh Giang", topic: .voice),
        .init(id: "Pxbwsk9toes", title: "How to Speak with Confidence and Authority", channel: "Alexander Lyon Communication Coach", topic: .voice),
        .init(id: "1XHXezdnL0A", title: "10-Minute Daily Vocal Workout", channel: "Cheryl Porter Vocal Coach", topic: .voice),
        .init(id: "l69yZ5xabbo", title: "15 Minute Morning Pronunciation Practice for English Learners", channel: "Accent's Way English with Hadar", topic: .voice),
        .init(id: "aeyn3kLd1Y0", title: "Voice Training: Improve the Sound of Your Voice", channel: "Voice Power Coach", topic: .voice),
        .init(id: "S5f0FKhPax0", title: "EASY 3-Step Exercise To INSTANTLY Improve Your Articulation!", channel: "Vinh Giang", topic: .voice),
        .init(id: "jTZt52mH5Z0", title: "Making Your Voice Deeper: The Sound of Authority", channel: "The Voice of Confidence - With Elisa James", topic: .voice),
        .init(id: "so9l8homNCE", title: "5 Easy Vocal Exercises To Develop A Powerful Sounding Voice", channel: "Vinh Giang", topic: .voice),
        // conversation
        .init(id: "elFdkfSNlpE", title: "How to Talk to Anyone (Even If You Don't Know What To Say!)", channel: "Vinh Giang", topic: .conversation),
        .init(id: "LQaEv6P4ooM", title: "Conversations Are Awkward Until You Ask These Questions!", channel: "Vinh Giang", topic: .conversation),
        .init(id: "-X13GINFYOY", title: "How to Enter Conversations (Even If You Have Nothing To Say!)", channel: "Vinh Giang", topic: .conversation),
        .init(id: "W-E6fqoKUrY", title: "How To Be Quick Witted In Any Conversation (Without Overthinking It)", channel: "Vinh Giang", topic: .conversation),
        .init(id: "7vO-hyPztgc", title: "How to Listen Like a CEO", channel: "Alexander Lyon Communication Coach", topic: .conversation),
        .init(id: "Ton2wuIDmrU", title: "How to Communicate with More Empathy", channel: "Alexander Lyon Communication Coach", topic: .conversation),
        .init(id: "-pkR_NCptqg", title: "Give Me 7 Minutes and I’ll Make You Dangerously Good at Small Talk", channel: "Charisma on Command", topic: .conversation),
        .init(id: "v750VZ7kLbs", title: "This Simple Trick Makes People Love Talking to You", channel: "Charisma on Command", topic: .conversation),
        .init(id: "I_tRSrPru94", title: "How to introduce yourself: Easy English Conversations", channel: "BBC Learning English", topic: .conversation),
        .init(id: "QXiAPiw7vfc", title: "If You Run Out Of Things To Say, Play This Simple Game", channel: "Charisma on Command", topic: .conversation),
        .init(id: "VTOO_9_ECA8", title: "How to Make Small Talk People Actually Enjoy", channel: "Charisma on Command", topic: .conversation),
        .init(id: "ikbcrpowlIs", title: "How to Talk to ANYONE (Once You Know Their Color!)", channel: "Vinh Giang", topic: .conversation),
        .init(id: "IRG-YubP1rw", title: "How to Get Good at Small Talk, and Even Enjoy It", channel: "Harvard Business Review", topic: .conversation),
        .init(id: "8vPXIsAqmjg", title: "100 Small Talk Questions and Answers", channel: "English with Lucy", topic: .conversation),
        .init(id: "7wUCyjiyXdg", title: "Active Listening Skills", channel: "Alexander Lyon Communication Coach", topic: .conversation),
        // confidence
        .init(id: "vb8WJgRAKUU", title: "You're Naturally Shy... So Here's How to Actually Be Confident", channel: "Vinh Giang", topic: .confidence),
        .init(id: "N97XYE0s7iY", title: "How I Deal With Nerves Before Big Conversations", channel: "Vinh Giang", topic: .confidence),
        .init(id: "tt6kECewfIU", title: "How to Speak with Confidence 6 Tips!", channel: "Alexander Lyon Communication Coach", topic: .confidence),
        .init(id: "L8dkjejG7fo", title: "Give me 8 Minutes and I'll Show You How To Build Confidence", channel: "Charisma on Command", topic: .confidence),
        .init(id: "PZP3ZKkNq5I", title: "How To Be Confident Under Pressure (Even if You're Shy)", channel: "Charisma on Command", topic: .confidence),
        .init(id: "CHvB1qgWAoI", title: "If You Only Watch One Charisma Video, Make It This", channel: "Charisma on Command", topic: .confidence),
        .init(id: "eVFzbxmKNUw", title: "How to be confident (even if you’re not)", channel: "TEDx Talks", topic: .confidence),
        .init(id: "KmOAznOQX-g", title: "Secrets From Psychology That Make People Respect You", channel: "Charisma on Command", topic: .confidence),
        .init(id: "_PZKok5_KVA", title: "How To Be Confident In Any Social Situation", channel: "Charisma on Command", topic: .confidence),
        .init(id: "Cjs7dyzLVco", title: "A dialogue to kill the fear of public speaking", channel: "TEDx Talks", topic: .confidence),
        .init(id: "1n83x5g8pQk", title: "Become a Confident English Speaker", channel: "Speak Confident English", topic: .confidence),
        .init(id: "aImrjNPrh30", title: "How I Overcame My Fear of Public Speaking", channel: "TEDx Talks", topic: .confidence),
        .init(id: "Edg54WnYqkE", title: "NEVER Feel Anxiety Again When Giving A Speech (5 EASY Methods)", channel: "Vinh Giang", topic: .confidence),
        .init(id: "ebkSxOSaQ4o", title: "How to Become Dangerously Confident (Without Faking It)", channel: "Vinh Giang", topic: .confidence),
        // publicSpeaking
        .init(id: "w82a1FT5o88", title: "How to Start a Speech", channel: "Conor Neill", topic: .publicSpeaking),
        .init(id: "cef35Fk7YD8", title: "You are contagious", channel: "TEDx Talks", topic: .publicSpeaking),
        .init(id: "QijH4UAqGD8", title: "Get comfortable with being uncomfortable", channel: "TED", topic: .publicSpeaking),
        .init(id: "7tzentBmmUc", title: "How to Start a Speech: The Best (and Worst) Speech Openers", channel: "Vanessa Van Edwards", topic: .publicSpeaking),
        .init(id: "-FOCpMAww28", title: "TED's secret to great public speaking", channel: "TED", topic: .publicSpeaking),
        .init(id: "v26CcifgEq4", title: "2016 World Champion of Public Speaking, Darren Tay Wen Jie", channel: "Toastmasters International", topic: .publicSpeaking),
        .init(id: "i5mYphUoOCs", title: "Public Speaking For Beginners", channel: "Alexander Lyon Communication Coach", topic: .publicSpeaking),
        // storytelling
        .init(id: "Nj-hdQMa3uA", title: "The magical science of storytelling", channel: "TEDx Talks", topic: .storytelling),
        .init(id: "xjKruwAfZWk", title: "How to make your writing suspenseful", channel: "TED-Ed", topic: .storytelling),
        .init(id: "KxDwieKpawg", title: "The clues to a great story", channel: "TED", topic: .storytelling),
        .init(id: "1rMnzNZkIX0", title: "Pixar in a Box: Introduction to Storytelling", channel: "Khan Academy Labs", topic: .storytelling),
        .init(id: "ZmNpeXTj2c4", title: "The Secret to Telling a Great Story — in Less Than 60 Seconds", channel: "TED", topic: .storytelling),
        .init(id: "4PqGPZtyFtw", title: "I tried Nelson’s 9 Steps for Story Writing (and it's brilliant)", channel: "Bookfox", topic: .storytelling),
        .init(id: "5HfeNDleTS4", title: "The ONLY 3 Ingredients You Need To Be A Better Storyteller!", channel: "Vinh Giang", topic: .storytelling),
        .init(id: "JOs-q7rXqdk", title: "4 ways to tell a great story", channel: "TED-Ed", topic: .storytelling),
        .init(id: "egf35OYyvz0", title: "The Moth: John Turturro, Stumbling in the Dark", channel: "The Moth", topic: .storytelling),
        // persuasion
        .init(id: "cFdCzN7RYbw", title: "Science Of Persuasion", channel: "Team Cialdini", topic: .persuasion),
        .init(id: "IDj1OBG5Tpw", title: "Harvard negotiator explains how to argue", channel: "Big Think", topic: .persuasion),
        .init(id: "3klMM9BkW5o", title: "How to use rhetoric to get what you want", channel: "TED-Ed", topic: .persuasion),
        .init(id: "tYv44wQYePg", title: "How to win a negotiation, with former FBI hostage chief Chris Voss", channel: "Big Think", topic: .persuasion),
        .init(id: "PPfhZsAGsEI", title: "How To Negotiate", channel: "Chris Voss & The Black Swan Group", topic: .persuasion),
        .init(id: "V-IVYaRJ9Ow", title: "Top 10 MOST Powerful Negotiation Tips", channel: "Chris Voss & The Black Swan Group", topic: .persuasion),
        .init(id: "G3hXvByzLHs", title: "6 ways to be more persuasive", channel: "TED-Ed", topic: .persuasion),
        // debate
        .init(id: "JY5t6iUzajk", title: "How To Win (Almost) Every Argument", channel: "Charisma on Command", topic: .debate),
        .init(id: "dItUGF8GdTw", title: "5 tips to improve your critical thinking", channel: "TED-Ed", topic: .debate),
        .init(id: "vNDYUlxNIAA", title: "This tool will help improve your critical thinking", channel: "TED-Ed", topic: .debate),
        .init(id: "_WjUFuW2J0A", title: "Train for any argument with Harvard’s former debate coach", channel: "Big Think", topic: .debate),
        .init(id: "XGVUHPl4YuI", title: "How To Effortlessly Defend Yourself In Any Argument", channel: "Charisma on Command", topic: .debate),
        .init(id: "HnJ1bqXUnIM", title: "What is Critical Thinking?", channel: "Macat", topic: .debate),
        .init(id: "Cum3k-Wglfw", title: "CRITICAL THINKING - Fundamentals: Introduction to Critical Thinking", channel: "Wireless Philosophy", topic: .debate),
        .init(id: "tZw0-ap7buo", title: "How dirty debaters win against better opponents", channel: "Big Think", topic: .debate),
        // writing
        .init(id: "RSoRzTtwgP4", title: "How to write descriptively", channel: "TED-Ed", topic: .writing),
        .init(id: "pHdzv1NfZRM", title: "Improve your Writing: Show, Not Tell", channel: "Business English Benjamin · engVid", topic: .writing),
        .init(id: "mMeNnX1FGgg", title: "Five Tips for Writing Your First Novel", channel: "Brandon Sanderson", topic: .writing),
        .init(id: "OV5J6BfToSw", title: "Linguistics, Style and Writing (Steven Pinker)", channel: "The Royal Institution", topic: .writing),
        .init(id: "btWlBHE0pe4", title: "How to communicate clearly", channel: "TED-Ed", topic: .writing),
        .init(id: "maL3IimaY3Y", title: "7 Writing Techniques so Good they should be Illegal", channel: "Bookfox", topic: .writing),
        .init(id: "nicgq7WLESU", title: "I Tried a 6-Step Formula for Writing Better Sentences", channel: "Bookfox", topic: .writing),
        .init(id: "sS-Txm3R3v8", title: "Zombie Nouns and the Passive Voice (Steven Pinker)", channel: "The Royal Institution", topic: .writing),
        // work
        .init(id: "kayOhGRcNt4", title: "Tell Me About Yourself - A Good Answer to This Interview Question", channel: "Linda Raynier", topic: .work),
        .init(id: "KCm6JVtoRdo", title: "Interview Questions and Answers! (How to PASS a JOB INTERVIEW!)", channel: "CareerVidz", topic: .work),
        .init(id: "fr-mwiyhZAo", title: "TOP 21 QUICK ANSWERS TO JOB INTERVIEW QUESTIONS!", channel: "CareerVidz", topic: .work),
        .init(id: "-JNjsOX0N0c", title: "English Job Interview Dos & Dont's!", channel: "Rachel's English", topic: .work),
        .init(id: "3Tu1jN65slw", title: "How to write professional emails in English", channel: "English with Alex · engVid", topic: .work),
        .init(id: "1XctnF7C74s", title: "8 Email Etiquette Tips - How to Write Better Emails at Work", channel: "Harvard Business Review", topic: .work),
        .init(id: "Ln_3AVoBRLk", title: "Practice a Job Interview in English", channel: "linguamarina", topic: .work),
        .init(id: "8laYlyAFd0o", title: "How to Introduce Yourself in English", channel: "linguamarina", topic: .work),
    ]

    static func videos(for topic: LabVideoTopic) -> [LabVideo] { all.filter { $0.topic == topic } }

    /// Every channel in the catalog, A–Z.
    static var channels: [String] { Array(Set(all.map(\.channel))).sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending } }

    /// Favorite channels first, then unwatched before watched; the catalog order is kept within each group.
    static func ordered(_ videos: [LabVideo], favorites: Set<String>, watched: [String: Date]) -> [LabVideo] {
        videos.enumerated().sorted { a, b in
            let keyA = (favorites.contains(a.element.channel) ? 0 : 1, watched[a.element.id] == nil ? 0 : 1, a.offset)
            let keyB = (favorites.contains(b.element.channel) ? 0 : 1, watched[b.element.id] == nil ? 0 : 1, b.offset)
            return keyA < keyB
        }.map(\.element)
    }

    /// How many catalog videos are marked watched (old IDs that left the catalog are not counted).
    static func watchedCount(_ watched: [String: Date]) -> Int { all.filter { watched[$0.id] != nil }.count }

    static func isValidID(_ id: String) -> Bool {
        id.count == 11 && id.unicodeScalars.allSatisfy { CharacterSet.alphanumerics.contains($0) || $0 == "-" || $0 == "_" }
    }
}

/// What the learner has done in the Lab extras: watched videos and fingerprints of past timed-test items.
/// Stored inside `SpeechLabState` as an optional JSON field, so older stores decode unchanged.
/// A finished Lab activity, kept only for badges: "talk.freeTalk", "talk.interview", "talk.scenario",
/// "timed.writing", "timed.reading" or "timed.analogies".
struct LabActivity: Codable, Equatable, Identifiable {
    static let maximumCount = 1_000
    static let kinds: Set<String> = Set(TalkMode.allCases.map { "talk." + $0.rawValue } + TimedTestKind.allCases.map { "timed." + $0.rawValue })
    var id: UUID
    var kind: String
    var date: Date
}

struct LabExtrasState: Codable, Equatable {
    static let maximumFingerprints = 400
    /// Video ID → when it was marked watched.
    var watched: [String: Date] = [:]
    /// Channels the learner marked as favorites; optional so older stores decode unchanged.
    var favoriteChannels: [String]?
    /// Kind raw value → fingerprints of past items, oldest first, capped per kind.
    var fingerprints: [String: [String]] = [:]
    /// Kind raw value → themes used recently, oldest first, so the next test picks a fresh one.
    var recentThemes: [String: [String]] = [:]
    /// v2 badges: finished Talk conversations and timed tests, oldest first; optional so older stores decode unchanged.
    var activities: [LabActivity]?

    /// Logs one finished activity. The same ID is never logged twice; the log keeps the newest `LabActivity.maximumCount`.
    mutating func log(_ activity: LabActivity) {
        var list = activities ?? []
        guard LabActivity.kinds.contains(activity.kind), !list.contains(where: { $0.id == activity.id }) else { return }
        list.append(activity)
        if list.count > LabActivity.maximumCount { list.removeFirst(list.count - LabActivity.maximumCount) }
        activities = list
    }

    mutating func setWatched(_ id: String, _ on: Bool, now: Date = .now) {
        guard LabVideoCatalog.isValidID(id) else { return }
        if on { watched[id] = watched[id] ?? now } else { watched[id] = nil }
    }

    mutating func setFavorite(_ channel: String, _ on: Bool) {
        var list = (favoriteChannels ?? []).filter { $0 != channel }
        if on, LabVideoCatalog.channels.contains(channel) { list.append(channel) }
        favoriteChannels = list
    }

    func hasSeen(_ fingerprint: String, kind: TimedTestKind) -> Bool { fingerprints[kind.rawValue]?.contains(fingerprint) == true }

    mutating func remember(_ test: TimedTest) {
        var list = fingerprints[test.kind.rawValue] ?? []
        for print in test.fingerprints where !list.contains(print) { list.append(print) }
        if list.count > Self.maximumFingerprints { list.removeFirst(list.count - Self.maximumFingerprints) }
        fingerprints[test.kind.rawValue] = list
        var themes = (recentThemes[test.kind.rawValue] ?? []).filter { $0 != test.theme }
        themes.append(test.theme)
        if themes.count > TimedTestKind.themes.count / 2 { themes.removeFirst(themes.count - TimedTestKind.themes.count / 2) }
        recentThemes[test.kind.rawValue] = themes
    }

    /// A random theme the learner has not had recently for this kind of test.
    func nextTheme(for kind: TimedTestKind, using generator: inout some RandomNumberGenerator) -> String {
        let recent = Set(recentThemes[kind.rawValue] ?? [])
        let fresh = TimedTestKind.themes.filter { !recent.contains($0) }
        return (fresh.isEmpty ? TimedTestKind.themes : fresh).randomElement(using: &generator)!
    }
}
