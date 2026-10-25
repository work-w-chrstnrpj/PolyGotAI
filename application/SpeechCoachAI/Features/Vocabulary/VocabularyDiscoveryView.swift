import SwiftUI

/// Vocabulary topic discovery. Manual topics stay on the existing vocabulary screen.
/// Page 1 T08 (`2:38663`) and Kit/Status (`41:1155`): offline writing stays available, and generation does not resubmit itself.
struct VocabularyDiscoveryView: View {
    @Binding var session: VocabularyDiscoverySession
    var policy: GenerationPolicy?
    var background: LearnerPreferences.Background = .creativeAcademy
    @State private var notice: String?
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AvailabilityCard(
                    title: "You can still write your own practice",
                    detail: "Create and edit topics without a connection. Saving a word and adding it to review stay separate.",
                    symbol: "square.and.pencil")
                    .accessibilityIdentifier("vocabulary.discovery.manual")
                pathPicker
                fields
                Button("Preview a suggestion", action: request)
                    .buttonStyle(KitPrimaryButtonStyle())
                    .disabled(policy == nil || !session.choices.isReady || session.practice.phase == .awaiting)
                    .accessibilityIdentifier("vocabulary.discovery.generate")
                if session.practice.phase == .awaiting {
                    Button("Stop waiting", action: stop)
                        .frame(minHeight: 44)
                        .accessibilityIdentifier("vocabulary.discovery.cancel")
                }
                if let notice {
                    Text(notice).font(.callout).foregroundStyle(Kit.secondary).fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("vocabulary.discovery.notice")
                }
                preview
                AvailabilityCard(
                    title: "Online generation is unavailable",
                    detail: "This screen does not send a request. A suggestion is not added to your words.",
                    symbol: "wifi.slash")
                    .accessibilityIdentifier("vocabulary.discovery.offline")
            }
            .padding(20)
            .frame(maxWidth: 640, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(Kit.canvas(background))
        .navigationTitle("Topic words")
        .onChange(of: session.practice.epoch) { _, _ in notice = nil }
        .onChange(of: session.choices) { _, _ in
            if session.preview != nil || session.practice.phase == .awaiting { stop() }
        }
        .onChange(of: scenePhase) { _, phase in if phase != .active { stop() } }
        .onDisappear { stop() }
    }

    private var pathPicker: some View {
        Picker("Path", selection: $session.choices.path) {
            Text("Not chosen").tag(Optional<DiscoveryPath>.none)
            ForEach(DiscoveryPath.allCases) { path in
                Text(path.title).tag(Optional(path))
            }
        }
        .pickerStyle(.menu)
        .accessibilityIdentifier("vocabulary.discovery.path")
    }

    private var fields: some View {
        VStack(alignment: .leading, spacing: 12) {
            entry("Topic", text: $session.choices.topicTitle, identifier: "vocabulary.discovery.topic")
            if session.choices.path == .subtopic {
                entry("Subtopic", text: $session.choices.subtopic, identifier: "vocabulary.discovery.subtopic")
            }
            entry("Level", text: $session.choices.level, identifier: "vocabulary.discovery.level")
            entry("Count", text: $session.choices.countText, identifier: "vocabulary.discovery.count")
            entry("Purpose", text: $session.choices.purpose, identifier: "vocabulary.discovery.purpose")
            Text("Suggestions are unavailable while the activity and generation rules are being prepared. Your entries stay in memory on this screen; use your own topics to save words offline.")
                .font(.footnote).foregroundStyle(Kit.secondary)
                .accessibilityIdentifier("vocabulary.discovery.unavailable")
        }
    }

    private func entry(_ title: String, text: Binding<String>, identifier: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption.weight(.semibold)).foregroundStyle(Kit.secondary)
            TextField(title, text: text, prompt: Text(title).foregroundStyle(Kit.secondary))
                .textFieldStyle(.plain)
                .padding(14)
                .background(Kit.surface, in: RoundedRectangle(cornerRadius: 14))
                .accessibilityIdentifier(identifier)
        }
    }

    @ViewBuilder private var preview: some View {
        if let presented = session.presented {
            KitCard {
                Text("Word suggestion").font(.headline)
                Text("Generated. This is not educator-reviewed.")
                    .font(.footnote).foregroundStyle(Kit.secondary)
                if let prompt = presented.prompt {
                    Text(prompt).fixedSize(horizontal: false, vertical: true)
                }
                if session.hidesCandidateUntilReveal {
                    Text("The suggestion stays hidden until you reveal it.")
                        .font(.callout).foregroundStyle(Kit.secondary)
                    Button("Reveal suggestion") {
                        notice = session.reveal()?.message
                    }
                    .frame(minHeight: 44)
                    .accessibilityIdentifier("vocabulary.discovery.reveal")
                } else {
                    entry("Word", text: draftLemma, identifier: "vocabulary.discovery.lemma")
                    entry("Meaning", text: draftMeaning, identifier: "vocabulary.discovery.meaning")
                    Button("Select this suggestion") {
                        notice = session.select(now: .now)?.message ?? "Selected. It is still not in your topics."
                    }
                    .frame(minHeight: 44)
                    .accessibilityIdentifier("vocabulary.discovery.select")
                }
                Text(session.blocksEnrollment()?.message ?? DiscoveryRefusal.manualPracticeRemains.message)
                    .font(.footnote).foregroundStyle(Kit.secondary)
                Button("Save to collection") {}
                    .frame(minHeight: 44)
                    .disabled(true)
                    .accessibilityIdentifier("vocabulary.discovery.save")
                Button("Add to review") {}
                    .frame(minHeight: 44)
                    .disabled(true)
                    .accessibilityIdentifier("vocabulary.discovery.enroll")
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("vocabulary.discovery.preview")
        }
    }

    private var draftLemma: Binding<String> {
        Binding(get: { session.draftLemma }, set: { session.edit(lemma: $0, meaning: session.draftMeaning) })
    }

    private var draftMeaning: Binding<String> {
        Binding(get: { session.draftMeaning }, set: { session.edit(lemma: session.draftLemma, meaning: $0) })
    }

    private func request() {
        notice = session.requestSuggestion(policy: policy, connected: false, now: .now)?.message
    }

    private func stop() {
        notice = session.cancel().message
    }
}

struct VocabularyDiscoveryLauncher: View {
    var storage: LearnerStorageController
    @Environment(\.scenePhase) private var scenePhase
    @State private var session = VocabularyDiscoverySession()
    @State private var unavailable = false

    var body: some View {
        VStack {
            if unavailable {
                AvailabilityCard(title: "Local data unavailable", detail: "Unlock your device and return to try again.", symbol: "exclamationmark.triangle")
            }
            VocabularyDiscoveryView(session: $session, policy: nil, background: storage.preferences.background)
        }
        .onAppear(perform: bind)
        .onChange(of: scenePhase) { _, phase in if phase == .active { bind() } }
        .onChange(of: storage.repository != nil) { _, _ in bind() }
    }

    private func bind() {
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            session.bindEpoch(try repository.learningDataEpoch())
            unavailable = false
        } catch {
            session.bindEpoch(nil)
            unavailable = true
        }
    }
}
