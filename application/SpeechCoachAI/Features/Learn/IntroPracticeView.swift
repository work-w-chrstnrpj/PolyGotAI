import SwiftUI

/// Optional personal-use practice, separate from the required course and reserved assessments.
enum IntroPracticePack: String, CaseIterable, Identifiable {
    case foundations, teacher, grammarian, journalist
    var id: String { "intro-01-pack-\(rawValue)" }
    var title: String {
        switch self {
        case .foundations: "English foundations"
        case .teacher: "Teacher practice"
        case .grammarian: "Grammarian practice"
        case .journalist: "Journalist practice"
        }
    }
    var method: String {
        switch self {
        case .foundations: "Notice word classes, sentence parts and agreement."
        case .teacher: "Read a model, use a frame, then try without it."
        case .grammarian: "Notice, contrast, repair, then use the pattern."
        case .journalist: "Read for facts, ask follow-up questions, then summarize."
        }
    }
    var teaching: [(String, String)] {
        switch self {
        case .foundations:
            [("Words and their jobs", "A noun names a person, place, thing or role. A pronoun can stand for a noun. In ‘She is a teacher’, she is a pronoun and the subject; teacher is a noun inside the predicate."),
             ("Subject and predicate", "The subject is who or what the sentence is about. The predicate includes the verb and the rest of the message. In ‘She works as a teacher’, She is the subject and works as a teacher is the predicate."),
             ("Complement or object?", "In ‘She is a teacher’, a teacher describes the subject after be: it is a subject complement. In ‘I study English’, English is the object of study. A noun is not always the subject."),
             ("Match the subject", "I am · you are · he/she is · they are. Use the base form with I/you/they: I study. Add -s or -es with he/she: He studies. After do/does, use the base form: Does she work?"),
             ("A phrase or a clause", "In a shop is a phrase. He works in a shop is a clause with a subject and a verb. ‘Listen!’ is an instruction with you understood. Short answers can be natural in conversation; they are not automatically mistakes.")]
        case .teacher:
            [("Make a connection", "Tell someone your chosen name, what you do and one interest. Invented details are welcome. You will read a model, use support, then try with less help.")]
        case .grammarian:
            [("Notice one difference", "I study English. She studies English. The subject changes the verb. Compare ‘She is a teacher’ with ‘She works as a teacher’: both are complete messages, with different verbs.")]
        case .journalist:
            [("Keep source facts separate", "Read the source, gather the stated facts, ask for a missing detail and summarize. A question or an invented detail is not a fact from the source.")]
        }
    }
    var steps: [IntroPracticeStep] {
        func step(_ suffix: String, _ prompt: String, _ example: String, support: Bool = false, concept: Bool = false) -> IntroPracticeStep {
            IntroPracticeStep(id: "\(id)-\(suffix)", prompt: prompt, example: example, supported: support, concept: concept)
        }
        let review = step("review", "Review your work. What would you keep, and what would you try differently next time?", "I checked my message and chose one thing to practise next.")
        switch self {
        case .foundations:
            return [
                step("noun", "In ‘Mina studies English’, which noun names a person?", "Mina names the person. English is also a noun, but it names what Mina studies.", concept: true),
                step("pronoun", "In ‘I like cooking’, which word is the subject pronoun?", "I is the subject pronoun.", concept: true),
                step("predicate", "In ‘She works as a teacher’, write the whole predicate.", "works as a teacher — the verb and the words that finish the message.", concept: true),
                step("complement", "In ‘She is a teacher’, is ‘a teacher’ the subject, an object, or a subject complement?", "A subject complement. It describes or renames she after be.", concept: true),
                step("agreement", "Repair ‘He study English’ and explain why the verb changes.", "He studies English. The subject he takes studies.", concept: true),
                step("produce-am", "Write a complete sentence introducing yourself as a student. Start with I.", "I am a student. I'm a student is also valid."),
                step("produce-is", "Write a complete sentence saying that Luis is a classmate.", "Luis is a classmate. Luis is my classmate is also valid."),
                step("produce-study", "Write a sentence saying that you study art. Start with I.", "I study art."),
                step("produce-studies", "Write a sentence saying that Luis studies art. Use he.", "He studies art."),
                step("produce-question", "Ask whether Luis likes music. Use does.", "Does Luis like music? Use the base form like after does."),
                step("apply", "Introduce a fictional classmate named Luis. Say what he does and one thing he likes. Use he.", "Luis studies art. He likes walking. This is one example; other details can be valid."), review]
        case .teacher:
            return [
                step("model", "Read: ‘Hello. My name is Noor. I study art. I like walking.’ What does Noor study?", "Noor studies art.", support: true),
                step("frame", "Use this frame: My name is ___. I study / I work ___. I like ___. Someone asks: What do you like? Answer them.", "Check for a name, a role, an interest and an answer to the question. Invented details are welcome.", support: true),
                step("fade", "Introduce yourself again with a name, a role and an interest. Then answer: What do you like? Try without looking back at the frame.", "Check the same four parts. This is practice with reduced support, not an independent assessment."),
                step("fresh-subject", "Complete: ___ am a new student.", "I"),
                step("fresh-are", "Complete: They ___ my classmates.", "are"),
                step("fresh-studies", "Complete: Noor ___ art. Use study in the simple present.", "studies"),
                step("fresh-like", "Complete: I ___ walking. Use like in the simple present.", "like"),
                step("fresh-does", "Complete: ___ Noor like walking?", "Does"), review]
        case .grammarian:
            return [
                step("notice", "Compare ‘I study English’ and ‘She studies English’. What changed in the verb, and why?", "Study became studies because the subject changed from I to she.", support: true),
                step("contrast", "Compare ‘She is a teacher’ and ‘She works as a teacher’. Write the subject and full predicate of each.", "She / is a teacher. She / works as a teacher.", support: true),
                step("repair", "Repair these sentences: ‘He study art.’ ‘Does she works here?’", "He studies art. Does she work here? After does, use the base form work."),
                step("transform", "Make this sentence negative: ‘She likes cooking.’", "She does not like cooking. She doesn't like cooking is also valid."),
                step("fresh-is", "Complete: She ___ a cook.", "is"),
                step("fresh-study", "Complete: They ___ English. Use study in the simple present.", "study"),
                step("fresh-not", "Complete: He ___ not a teacher.", "is"),
                step("fresh-repair-i", "Repair and keep the meaning: I works in a shop.", "I work in a shop."),
                step("fresh-repair-she", "Repair and keep the meaning: She like walking.", "She likes walking. She likes to walk is also valid."),
                step("message", "Introduce Luis in a new message. Say what he does and one thing he likes. Invent details; use he.", "He works in a shop and he likes music. Look for two subject-verb matches; missing details are not automatically errors."), review]
        case .journalist:
            return [
                step("facts", "Source: ‘Hello. My name is Mina. I study English. I like cooking.’ List only the facts the source states.", "Her name is Mina. She studies English. She likes cooking.", support: true),
                step("question", "Mina says she likes cooking. Write one connected question that asks for a detail she has not given.", "What do you like to cook? This asks for a new detail instead of repeating a known fact."),
                step("follow-up", "Mina answers: ‘I study English.’ Ask a follow-up question that uses her answer.", "Where do you study English? Do you like English? Both questions connect to her answer.", support: true),
                step("clarify", "A draft summary says Mina likes food. What does the original source actually say she likes?", "Cooking. ‘Food’ widens the original fact; ‘She likes cooking’ stays faithful."),
                step("summary", "Summarize the three facts from the original Mina source in one or two sentences. Add nothing.", "Her name is Mina, she studies English and she likes cooking. Other faithful wording is valid. Calling her a cook would invent a job."), review]
        }
    }
    var lesson: ResolvedLesson {
        ResolvedLesson(id: id, level: "A1", title: title, objectiveId: "INTRO-01/\(rawValue)",
                       contentVersion: self == .foundations ? "personal-practice-2" : "personal-practice-1", availability: .ready,
                       practiceActivities: steps.map { .init(id: $0.id, kind: $0.concept ? "foundationConcept" : "specialistPractice", required: true, prompt: $0.prompt, answer: $0.example) })
    }

    func speakingContext(session: LessonSession, step: IntroPracticeStep, origin: LessonPracticeOrigin,
                         defaults: LearnerPreferences, supported: Bool) -> PracticeSessionContext {
        var context = PracticeSessionContext(defaults: defaults, sourceLessonID: origin.lessonID, objectiveID: origin.objectiveID)
        context.sourceLessonJourneyID = origin.journeyID
        context.provenance = SpeakingProvenance(journeyID: session.journey.id, activityID: step.id,
            sourceCourseJourneyID: origin.journeyID, sourceCourseLessonID: origin.lessonID,
            primaryObjectiveID: origin.objectiveID, specialtyObjectiveID: lesson.objectiveId,
            role: rawValue, method: method, packID: id, packVersion: lesson.contentVersion,
            purpose: "specialistPractice", supported: supported)
        context.promptOverride = PromptSnapshot(id: step.id, version: lesson.contentVersion,
            objectiveID: origin.objectiveID, text: step.prompt, isPrivate: false, selectedLevel: "A1")
        return context
    }

    func finish(_ session: inout LessonSession, now: Date) throws {
        // Open responses have no automatic miss judgment. Review every foundation
        // example so completion includes correction review without an accuracy gate.
        if self == .foundations {
            guard steps.dropLast().allSatisfy({ session.response(for: $0.id)?.answerRevealed == true }) else {
                throw LessonProgressError.unfinished
            }
        }
        try session.finish(now: now)
    }
}

struct IntroPracticeStep: Identifiable {
    var id: String
    var prompt: String
    var example: String
    var supported: Bool
    var concept: Bool
}

struct IntroPracticeView: View {
    var storage: LearnerStorageController
    var pack: IntroPracticePack
    var origin: LessonPracticeOrigin
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @State private var session: LessonSession?
    @State private var recordingContext: PracticeSessionContext?
    @State private var answer = ""
    @State private var message: String?
    @State private var showTeaching = true
    @State private var teachingConsulted = true

    private var index: Int { pack.steps.firstIndex { $0.id == session?.journey.currentActivityID } ?? 0 }
    private var step: IntroPracticeStep { pack.steps[index] }
    private var response: LessonResponse? { session?.response(for: step.id) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text(pack.method).font(.title3).foregroundStyle(Kit.secondary)
                    Text("Optional personal practice · separate from your course. Text practice does not assess speech or English level.")
                        .font(.footnote).foregroundStyle(Kit.secondary)
                    DisclosureGroup("Explore the pattern", isExpanded: $showTeaching) {
                        ForEach(pack.teaching, id: \.0) { title, text in
                            KitCard { Text(title).font(.headline); Text(text).fixedSize(horizontal: false, vertical: true) }
                        }
                    }
                    if let session {
                        if session.journey.completedAt != nil {
                            KitCard {
                                Text("Practice recorded").font(.title2.bold()).accessibilityIdentifier("intro.practice.complete")
                                Text("Your responses and self-review are saved. This does not complete your course lesson or prove mastery.")
                            }
                        } else {
                            Text("\(index + 1) of \(pack.steps.count) · \(step.concept ? "Concept check" : "Practice")").font(.headline)
                            KitCard {
                                Text(step.prompt).font(.title3).accessibilityIdentifier("intro.practice.prompt")
                                Text(step.supported || teachingConsulted ? "Supported practice — a model or frame is available." : "Try first. Compare with an example afterward.")
                                    .font(.footnote).foregroundStyle(Kit.secondary)
                                TextField("Your response", text: $answer, axis: .vertical)
                                    .textFieldStyle(.roundedBorder).accessibilityIdentifier("intro.practice.answer")
                                    .dictation($answer)
                                Button(response == nil ? "Save my attempt" : "Save a retry", action: record)
                                    .buttonStyle(.borderedProminent).disabled(answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                    .accessibilityIdentifier("intro.practice.save")
                                if pack != .foundations && step.id != "\(pack.id)-review" {
                                    Button("Practise this aloud", systemImage: "mic") { openSpeaking() }
                                        .accessibilityIdentifier("intro.practice.speak")
                                    Text("Optional recording uses this task. Your written response and course stay separate.")
                                        .font(.footnote).foregroundStyle(Kit.secondary)
                                }
                                if let response {
                                    Text("First response: \(response.firstResponseText ?? response.unaidedText ?? response.assistedText ?? "")").font(.footnote)
                                    if response.answerRevealed {
                                        Text(step.example).accessibilityIdentifier("intro.practice.example")
                                        if let review = IntroductionReviewGuide.bundled?.pack(id: pack.id, version: pack.lesson.contentVersion) {
                                            IntroductionPackReview(pack: review)
                                        }
                                        Text("Compare the meaning and pattern. Open answers can have more than one valid form.").font(.footnote).foregroundStyle(Kit.secondary)
                                    } else {
                                        Button("Compare with an example", action: reveal).accessibilityIdentifier("intro.practice.reveal")
                                    }
                                }
                            }
                            HStack {
                                if index > 0 { Button("Previous") { move(index - 1) } }
                                Spacer()
                                Button(index + 1 == pack.steps.count ? "Finish practice" : "Continue") { advance() }
                                    .disabled(response == nil || (pack == .foundations && index + 1 < pack.steps.count && response?.answerRevealed != true)).accessibilityIdentifier("intro.practice.next")
                            }.frame(minHeight: 44)
                            if pack == .foundations && index + 1 < pack.steps.count {
                                Text("Save your attempt, then compare the example before continuing. A wrong answer does not block you.")
                                    .font(.footnote).foregroundStyle(Kit.secondary)
                            }
                        }
                    } else { ProgressView("Opening practice") }
                    if let message {
                        Text(message).foregroundStyle(Kit.error).accessibilityIdentifier("intro.practice.error")
                        Button(session == nil ? "Retry opening" : "Retry saving") { if session == nil { load() } else { saveDraft() } }
                    }
                }.padding(24).frame(maxWidth: 680).frame(maxWidth: .infinity)
            }
            .background(Kit.canvas(storage.preferences.background)).foregroundStyle(Kit.ink)
            .navigationTitle(pack.title).navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) {
                Button("Return to lesson") { if saveDraft() { dismiss() } }.accessibilityIdentifier("intro.practice.return")
            } }
            .fullScreenCover(item: $recordingContext) { context in
                RecordingView(storage: storage, context: context)
            }
            .modifier(RewardEngagementModifier(storage: storage, audio: { false }))
            .onAppear(perform: load)
            .onChange(of: answer) { _, _ in storage.rewardEngagement.clock.interact(at: ProcessInfo.processInfo.systemUptime) }
            .onChange(of: showTeaching) { _, visible in if visible { teachingConsulted = true } }
            .task(id: answer) {
                do { try await Task.sleep(for: .milliseconds(400)) } catch { return }
                saveDraft()
            }
            .onChange(of: scenePhase) { _, phase in if phase != .active { saveDraft() } }
            .interactiveDismissDisabled()
        }.tint(Kit.accent)
    }

    private func openSpeaking() {
        guard saveDraft(), let session else { return }
        recordingContext = pack.speakingContext(session: session, step: step, origin: origin,
            defaults: storage.preferences, supported: step.supported || teachingConsulted || response?.answerRevealed == true)
    }

    private func load() {
        guard session == nil else { return }
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            let existing = try repository.lessonJourneys(lessonID: pack.id).last { $0.contentVersion == pack.lesson.contentVersion && $0.practiceOrigin?.journeyID == origin.journeyID }
            var opened = try LessonSession.begin(lesson: pack.lesson, presenter: pack.rawValue, now: .now, existing: existing)
            opened.journey.practiceOrigin = origin
            try repository.saveLessonJourney(opened.journey)
            session = opened; restoreAnswer()
        } catch { message = "Practice could not be opened. Unlock your device and return to the lesson to try again." }
    }
    @discardableResult private func commit(_ candidate: LessonSession) -> Bool {
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            try repository.saveLessonJourney(candidate.journey)
            session = candidate; message = nil; return true
        } catch { message = "Your changes could not be saved. Keep this screen open and retry after unlocking your device."; return false }
    }
    @discardableResult private func saveDraft() -> Bool {
        guard var updated = session else { return true }
        guard updated.journey.completedAt == nil else { return true }
        do { try updated.saveDraft(answer, for: step.id); return commit(updated) }
        catch { message = "Use a response under 12,000 characters."; return false }
    }
    private func restoreAnswer() {
        answer = session?.journey.drafts?[step.id] ?? response?.assistedText ?? response?.unaidedText ?? ""
    }
    private func record() {
        guard var updated = session else { return }
        do {
            try updated.record(activityID: step.id, text: answer, assisted: step.supported || teachingConsulted || response != nil)
            try updated.saveDraft(answer, for: step.id)
            _ = commit(updated)
        } catch { message = "Write a response under 12,000 characters before saving." }
    }
    private func reveal() {
        guard var updated = session else { return }
        do { _ = try updated.revealAnswer(activityID: step.id); _ = commit(updated) }
        catch { message = "Save an attempt before comparing with the example." }
    }
    private func move(_ next: Int) {
        guard saveDraft(), var updated = session, pack.steps.indices.contains(next) else { return }
        do { try updated.move(to: pack.steps[next].id); if commit(updated) { restoreAnswer(); showTeaching = false; teachingConsulted = false } }
        catch { message = "This practice step could not be opened." }
    }
    private func advance() {
        if index + 1 < pack.steps.count { move(index + 1); return }
        guard saveDraft(), var updated = session else { return }
        do { try pack.finish(&updated, now: .now); _ = commit(updated) }
        catch { message = "Attempt each practice step and the self-review before finishing." }
    }
}

/// Explicit entry keeps reserved prompts out of course and specialist practice screens.
struct IntroCheckView: View {
    var storage: LearnerStorageController
    var course: LessonJourney
    var kind: IntroCheckKind
    @Environment(\.dismiss) private var dismiss
    @State private var session: LessonSession?
    @State private var supported = false
    @State private var keepText = false
    @State private var intervening = "Not reported"
    @State private var earlierChecks: [LessonJourney] = []
    @State private var response = ""
    @State private var message: String?
    @State private var recordingContext: PracticeSessionContext?

    private var check: IntroCheckSnapshot? { session?.journey.personalCheck }
    private var index: Int { Int(session?.journey.currentActivityID?.replacingOccurrences(of: "check-", with: "") ?? "0") ?? 0 }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text(kind.title).font(.title2.bold())
                    Text("Optional personal check. No automatic score or English-level judgment. Your course is unchanged.")
                        .foregroundStyle(Kit.secondary)
                    if let check, let session {
                        Text(check.purpose == "repeatedBaseline" ? "Repeated baseline" : check.kind.title).font(.headline)
                        Text(check.priorExposure ? "You have opened this prompt before; it is not unseen transfer." : "First opening recorded on this device; prior exposure elsewhere is unknown.")
                        Text(check.supported ? "Supported attempt" : "No in-app hints or examples during this attempt")
                        Text(check.timingDescription).font(.footnote)
                        if check.kind == .baseline {
                            Text(check.teachingMayHaveBeenSeen.map { $0
                                ? "Course teaching or practice had already started when this check began. This is not a pre-teaching baseline."
                                : "Before recorded course teaching; prior exposure elsewhere is unknown."
                            } ?? "Teaching exposure was not frozen for this older check; baseline comparability is unavailable.")
                                .font(.footnote)
                        }
                        if session.journey.completedAt != nil {
                            Label("Check recorded · not assessed", systemImage: "checkmark.circle")
                                .accessibilityIdentifier("intro.check.complete")
                            Text("Text cannot establish intelligibility. Timing and participation alone do not establish retention or improvement.")
                            ForEach(session.journey.responses) { answer in
                                if let text = answer.firstResponseText ?? answer.unaidedText ?? answer.assistedText {
                                    Text(text).textSelection(.enabled)
                                } else if answer.recordedPracticeID != nil {
                                    Text("Spoken response · replay availability follows your recording retention choice.")
                                }
                            }
                            if !check.retainedText { Text("Written responses were not retained.").font(.footnote) }
                            Button("Start a separate attempt") { self.session = nil; response = "" }
                        } else if index < check.prompts.count {
                            Text("Task \(index + 1) of \(check.prompts.count)").font(.headline)
                            KitCard {
                                Text(check.prompts[index]).font(.title3).accessibilityIdentifier("intro.check.prompt")
                                TextField("Your response", text: $response, axis: .vertical)
                                    .textFieldStyle(.roundedBorder).accessibilityIdentifier("intro.check.answer")
                                    .dictation($response)
                                Text(check.retainedText ? "Save records your written response on this device." : "Written response is not retained. Only participation is recorded when you continue; unsaved text disappears when you leave.").font(.footnote)
                                Button("Record written attempt") { recordCurrent() }
                                    .disabled(response.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                    .accessibilityIdentifier("intro.check.save")
                                if kind.window == nil {
                                    Button("Record this task aloud", systemImage: "mic") { openRecording() }
                                        .accessibilityIdentifier("intro.check.speak")
                                }
                            }
                        } else {
                            KitCard {
                                Text("Self-review").font(.headline)
                                Button("Finish self-review") { finish() }.accessibilityIdentifier("intro.check.finish")
                            }
                        }
                    } else {
                        KitCard {
                            Text("Choose conditions before seeing the task").font(.headline)
                            Toggle("I will use outside help or notes", isOn: $supported)
                            Toggle("Keep my written responses on this device", isOn: $keepText)
                            Picker("Practice since teaching", selection: $intervening) {
                                ForEach(["Not reported", "No practice reported", "Some practice reported"], id: \.self) { Text($0) }
                            }
                            Text("Self-paced. Follow-up appears after the first response. Opening records exposure even if you leave. You can decline and return to your lesson.").font(.footnote)
                            Button("Begin check", action: begin).buttonStyle(.borderedProminent)
                                .accessibilityIdentifier("intro.check.begin")
                        }
                    }
                    if !earlierChecks.isEmpty {
                        DisclosureGroup("Saved check records") {
                            ForEach(earlierChecks) { saved in
                                Button(saved.personalCheck?.startedAt.formatted(date: .abbreviated, time: .shortened) ?? "Earlier check") {
                                    guard let frozen = saved.personalCheck else { return }
                                    session = try? LessonSession.begin(lesson: frozen.lesson(), presenter: saved.presenter, now: .now, existing: saved)
                                    response = saved.drafts?[saved.currentActivityID ?? ""] ?? ""
                                }
                            }
                        }
                    }
                    if let message {
                        Text(message).foregroundStyle(Kit.error)
                        if let pending = storage.latestCheckSpeech, pending.journeyID == session?.journey.id,
                           pending.activityID == "check-\(index)" {
                            Button("Retry recording link") {
                                recordCurrent(speakingID: pending.attemptID)
                                if self.message == nil { storage.latestCheckSpeech = nil }
                            }
                        }
                    }
                }.padding(24).frame(maxWidth: 680).frame(maxWidth: .infinity)
            }
            .background(Kit.canvas(storage.preferences.background)).foregroundStyle(Kit.ink)
            .navigationTitle("Personal check").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) {
                Button("Return to lesson") { if saveCheckDraft() { dismiss() } }.accessibilityIdentifier("intro.check.return")
            } }
            .fullScreenCover(item: $recordingContext) { context in RecordingView(storage: storage, context: context) }
            .onAppear(perform: resume)
            .onDisappear { _ = saveCheckDraft() }
            .task(id: response) {
                guard check?.retainedText == true else { return }
                do { try await Task.sleep(for: .milliseconds(400)) } catch { return }
                _ = saveCheckDraft()
            }
            .onChange(of: storage.latestCheckSpeech) { _, completion in
                guard let completion, completion.journeyID == session?.journey.id,
                      completion.activityID == "check-\(index)" else { return }
                recordCurrent(speakingID: completion.attemptID)
                if message == nil { storage.latestCheckSpeech = nil }
            }
        }.tint(Kit.accent)
    }

    @discardableResult private func saveCheckDraft() -> Bool {
        guard check?.retainedText == true, var updated = session,
              updated.journey.completedAt == nil, index < (check?.prompts.count ?? 0) else { return true }
        do { try updated.saveDraft(response, for: "check-\(index)"); return commit(updated) }
        catch { message = "Your draft could not be saved. Keep this screen open and retry."; return false }
    }

    private func resume() {
        guard session == nil else { return }
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            earlierChecks = try repository.lessonJourneys(lessonID: "intro-01-check-\(kind.rawValue)").filter {
                $0.practiceOrigin?.journeyID == course.id && $0.personalCheck != nil
            }
            if let saved = earlierChecks.last(where: { $0.completedAt == nil }) ?? earlierChecks.last, let frozen = saved.personalCheck {
                session = try LessonSession.begin(lesson: frozen.lesson(), presenter: saved.presenter, now: .now, existing: saved)
                response = saved.drafts?[saved.currentActivityID ?? ""] ?? ""
            }
        } catch { message = "Your saved check could not be opened. Unlock the device and try again." }
    }
    private func begin() {
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            let previous = try repository.allLessonJourneys().filter { $0.personalCheck != nil }
            let frozen = IntroCheckSnapshot.begin(kind: kind, course: course, previous: previous, now: .now,
                supported: supported, retainedText: keepText, interveningPractice: intervening)
            var created = try LessonSession.begin(lesson: frozen.lesson(), presenter: storage.preferences.coach.rawValue, now: .now)
            created.journey.practiceOrigin = LessonPracticeOrigin(journeyID: course.id, lessonID: course.lessonID, objectiveID: course.objectiveID, activityID: course.currentActivityID)
            created.journey.personalCheck = frozen
            _ = commit(created)
        } catch { message = "The check could not be started. Your course is kept; try again." }
    }
    private func commit(_ value: LessonSession) -> Bool {
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            try repository.saveLessonJourney(value.journey)
            if let i = earlierChecks.firstIndex(where: { $0.id == value.journey.id }) { earlierChecks[i] = value.journey }
            else { earlierChecks.append(value.journey) }
            session = value; message = nil; return true
        } catch { message = "Changes could not be saved. Keep this screen open and retry."; return false }
    }
    private func recordCurrent(speakingID: UUID? = nil) {
        guard var updated = session else { return }
        do {
            try updated.recordPersonalCheck(text: response, speakingID: speakingID)
            if commit(updated) { response = "" }
        } catch { message = "Write a response under 12,000 characters or finish a recording, then retry." }
    }
    private func finish() {
        guard var updated = session else { return }
        do { try updated.finishPersonalCheck(now: .now); _ = commit(updated) }
        catch { message = "Attempt each task before finishing self-review." }
    }
    private func openRecording() {
        guard let session, let check, index < check.prompts.count else { return }
        var context = PracticeSessionContext(defaults: storage.preferences, sourceLessonID: course.lessonID, objectiveID: course.objectiveID)
        context.sourceLessonJourneyID = session.journey.id
        context.provenance = SpeakingProvenance(journeyID: session.journey.id, activityID: "check-\(index)",
            sourceCourseJourneyID: course.id, sourceCourseLessonID: course.lessonID, primaryObjectiveID: course.objectiveID,
            specialtyObjectiveID: nil, role: session.journey.presenter, method: "Personal check; \(check.preparation)",
            packID: session.journey.lessonID, packVersion: session.journey.contentVersion, purpose: check.purpose, supported: check.supported)
        context.promptOverride = PromptSnapshot(id: "\(session.journey.lessonID)-\(index)", version: session.journey.contentVersion,
            objectiveID: course.objectiveID, text: check.prompts[index], isPrivate: false, selectedLevel: "A1")
        recordingContext = context
    }
}
