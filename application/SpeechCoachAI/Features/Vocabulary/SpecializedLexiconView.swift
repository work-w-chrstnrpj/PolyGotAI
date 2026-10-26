import SwiftUI

/// Specialized Lexicon: the online model writes a short word list for a topic; the learner picks which words to keep.
/// Nothing is saved until the learner taps Save, and saved words live in a personal topic named "AI: <topic>".
struct SpecializedLexiconView: View {
    var storage: LearnerStorageController
    var bank: LexiconBank = LexiconBankLoader.bundled
    /// Set when filling one of the learner's own packs: words are saved there, and the pack name is the topic.
    var pack: CustomVocabularyTopic? = nil
    @State private var controller: SpecializedLexiconController
    @State private var topic = ""
    @State private var level = "B1"
    @State private var count = 8
    @State private var chosen: Set<String> = []
    @State private var saved: Int?
    @State private var privacy = false
    @Environment(\.scenePhase) private var scenePhase

    init(storage: LearnerStorageController, bank: LexiconBank = LexiconBankLoader.bundled, pack: CustomVocabularyTopic? = nil,
         service: LabFeedbackService? = nil) {
        self.storage = storage; self.bank = bank; self.pack = pack
        _controller = State(initialValue: SpecializedLexiconController(service: service ?? AIFeedbackController.localService()))
    }

    private var request: LexiconGenerationRequest { LexiconGenerationRequest(topic: topic, level: level, count: count) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                TextField("Topic", text: $topic).textFieldStyle(.roundedBorder).accessibilityIdentifier("specialized.topic").dictation($topic)
                Picker("Rank", selection: $level) {
                    ForEach(LevelGate.levels, id: \.self) { Text($0).tag($0) }
                }.accessibilityIdentifier("specialized.level")
                Stepper("Words: \(count)", value: $count, in: 3...LexiconGenerationRequest.maximumWords).accessibilityIdentifier("specialized.count")
                Text(LabFeedbackDisclosure.current(mode: .coachReview, includesAudio: false).line)
                    .font(.footnote).foregroundStyle(Kit.secondary).accessibilityIdentifier("specialized.disclosure")
                Button("Cost and privacy") { privacy = true }.accessibilityIdentifier("specialized.privacy")
                if controller.busy {
                    ProgressView("Writing words").accessibilityIdentifier("specialized.loading")
                    Button("Cancel") { controller.cancel() }.accessibilityIdentifier("specialized.cancel")
                } else {
                    Button("Write words") { generate() }.buttonStyle(KitPrimaryButtonStyle())
                        .disabled(!request.isValid).accessibilityIdentifier("specialized.generate")
                }
                if let message = controller.message { Text(message).foregroundStyle(Kit.error).accessibilityIdentifier("specialized.error") }
                if let result = controller.result { resultSection(result) }
            }.padding(20)
        }
        .background(Kit.canvas(storage.preferences.background))
        .navigationTitle(pack == nil ? "Specialized words" : "Fill with AI").navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $privacy) {
            AIFeedbackPrivacyView(disclosure: .current(mode: .coachReview, includesAudio: false), retention: ProviderVerification.bundled?.retentionDisclosure)
        }
        .onAppear {
            level = storage.feedbackLevel
            if let pack, topic.isEmpty { topic = String([pack.title, pack.subtopic].filter { !$0.isEmpty }.joined(separator: ", ").prefix(80)) }
        }
        .onChange(of: scenePhase) { _, phase in if phase != .active { controller.cancel() } }
        .onDisappear { controller.cancel() }
    }

    @ViewBuilder private func resultSection(_ result: GeneratedLexicon) -> some View {
        Text("AI-made. Check each word before you keep it.").font(.footnote).foregroundStyle(Kit.secondary)
        ForEach(result.words, id: \.lemma) { word in
            Toggle(isOn: Binding(get: { chosen.contains(word.lemma) }, set: { on in
                if on { chosen.insert(word.lemma) } else { chosen.remove(word.lemma) }
            })) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(word.lemma).font(.headline)
                    Text("\(word.pos) · \(word.cefr)").font(.caption).foregroundStyle(Kit.secondary)
                    Text(word.meaning).fixedSize(horizontal: false, vertical: true)
                    if let example = word.parsedExamples.first?.plain { Text(example).italic().fixedSize(horizontal: false, vertical: true) }
                }
            }.accessibilityIdentifier("specialized.word.\(word.lemma)")
        }
        if !result.skipped.isEmpty {
            Text("Left out: \(result.skipped.joined(separator: ", "))").font(.footnote).foregroundStyle(Kit.secondary)
        }
        if let saved {
            Text(saved == 0 ? "Nothing new to add." : "Added \(saved) \(saved == 1 ? "word" : "words").")
                .font(.headline).accessibilityIdentifier("specialized.saved")
        } else {
            Button("Save") { save(result) }.buttonStyle(KitPrimaryButtonStyle())
                .disabled(chosen.isEmpty).accessibilityIdentifier("specialized.save")
        }
    }

    private func generate() {
        saved = nil; chosen = []
        let repository = storage.repository
        controller.generate(request, bank: bank,
                            topics: (try? repository?.customTopics()) ?? [],
                            enrollments: (try? repository?.vocabularyEnrollments()) ?? [])
    }

    private func save(_ result: GeneratedLexicon) {
        saved = (try? storage.repository?.saveGeneratedLexicon(result, choosing: chosen, into: pack?.id)) ?? 0
    }
}

@MainActor @Observable final class SpecializedLexiconController {
    private let service: LabFeedbackService?
    private var work: Task<Void, Never>?
    private var generation = UUID()
    private(set) var busy = false
    private(set) var result: GeneratedLexicon?
    private(set) var message: String?
    var isAvailable: Bool { service?.isAvailable == true }

    init(service: LabFeedbackService?) { self.service = service }

    func generate(_ request: LexiconGenerationRequest, bank: LexiconBank, topics: [CustomVocabularyTopic], enrollments: [VocabularyEnrollment]) {
        guard isAvailable, let service, !busy else { return }
        let consent = LabFeedbackConsent(shown: .current(mode: .coachReview, includesAudio: false))
        let token = UUID(); generation = token
        busy = true; result = nil; message = nil
        work = Task { [weak self] in
            do {
                let words = try await service.generateLexicon(request, consent: consent, bank: bank, topics: topics, enrollments: enrollments)
                guard let self, generation == token, !Task.isCancelled else { return }
                result = words; busy = false; work = nil
            } catch {
                guard let self, generation == token, !Task.isCancelled else { return }
                if let error = error as? LabFeedbackError {
                    message = error == .invalidResponse ? "No usable words came back. Try again." : ProviderSettingsModel.firstSentence(error.message)
                } else { message = ProviderSettingsModel.notice(error) }
                busy = false; work = nil
            }
        }
    }

    func cancel() { generation = UUID(); work?.cancel(); work = nil; busy = false }
}
