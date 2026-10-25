import SwiftUI
import Network
import Observation

/// Observes connectivity only; it never probes a saved website or fetches its content.
@Observable @MainActor
final class ResourceConnectivity {
    private(set) var offline = false
    private var monitor: NWPathMonitor?
    private var generation: UUID?

    func start() {
        guard monitor == nil else { return }
        #if DEBUG
        if SpeakingEnvironment.fixtureID != nil,
           ProcessInfo.processInfo.environment["SC_RESOURCE_OFFLINE"] == "1" {
            offline = true; return
        }
        #endif
        let current = UUID(); generation = current
        let monitor = NWPathMonitor(); self.monitor = monitor
        monitor.pathUpdateHandler = { [weak self] path in
            let offline = path.status != .satisfied
            Task { @MainActor [weak self] in
                guard self?.generation == current else { return }
                self?.offline = offline
            }
        }
        monitor.start(queue: DispatchQueue(label: "SpeechCoachAI.resource-connectivity"))
    }

    func stop() { generation = nil; monitor?.cancel(); monitor = nil }
}

/// RS-01/02 use Page 1 T03/T08, Content row, Input and Status with native editing.
struct ResourceLibraryView: View {
    var storage: LearnerStorageController
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @State private var resources: [LearningResource] = []
    @State private var epoch: UUID?
    @State private var query = ""
    @FocusState private var searchFocused: Bool
    @State private var showEditor = false
    @State private var pendingOpen: ResourceOpenIntent?
    @State private var deleting: LearningResource?
    @State private var message: String?
    @State private var readFailed = false
    @State private var connectivity = ResourceConnectivity()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                KitCard {
                    Text("A little curiosity. More ways to learn.").font(.title2.bold()).lineLimit(1).minimumScaleFactor(0.6)
                    Text("Keep useful links and personal notes. Websites open outside SpeechCoachAI after you confirm.")
                        .foregroundStyle(Kit.secondary)
                    Text("Notes work offline. Videos and websites need internet; their availability is not checked here.")
                        .font(.footnote).foregroundStyle(Kit.secondary)
                }
                if connectivity.offline {
                    AvailabilityCard(title: "You're offline", detail: "Your saved titles and notes are still here. Reconnect before opening a website.", symbol: "wifi.slash")
                        .accessibilityIdentifier("resources.offline")
                }
                if let message {
                    Text(message).foregroundStyle(Kit.error).accessibilityIdentifier("resources.message")
                }
                if readFailed {
                    Button("Try loading again", action: reload).frame(minHeight: 44)
                        .accessibilityIdentifier("resources.reload")
                } else {
                    if storage.resourceDraft != nil {
                        Button("Resume unsaved bookmark") { showEditor = true }
                            .frame(minHeight: 44).accessibilityIdentifier("resources.resume")
                    }
                    Button { edit() } label: { Label("Add resource", systemImage: "plus") }
                        .buttonStyle(KitPrimaryButtonStyle()).accessibilityIdentifier("resources.add")
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Search your library").font(.caption).foregroundStyle(Kit.secondary)
                        TextField("Title, topic or notes", text: $query,
                                  prompt: Text("Title, topic or notes").foregroundStyle(Kit.secondary))
                            .textFieldStyle(.roundedBorder).focused($searchFocused)
                            .submitLabel(.search).onSubmit { searchFocused = false }
                            .accessibilityIdentifier("resources.search")
                    }
                    Text("Your bookmarks").font(.title3.bold())
                    if resources.isEmpty {
                        AvailabilityCard(title: "Your library starts here", detail: "Add a useful link, or save one of the source links below. Saving a resource does not complete a lesson.", symbol: "bookmark")
                            .accessibilityIdentifier("resources.empty")
                    } else if filtered.isEmpty {
                        AvailabilityCard(title: "No matching resources", detail: "Try another title, topic or note.", symbol: "magnifyingglass")
                    }
                    LazyVStack(spacing: 12) {
                        ForEach(filtered) { resource in bookmark(resource) }
                    }
                    Text("Source links").font(.title3.bold())
                    ForEach(CuratedLearningResource.catalog) { resource in curated(resource) }
                }
            }
            .frame(maxWidth: 700, alignment: .leading).padding(20).frame(maxWidth: .infinity)
        }
        .background(Kit.canvas(storage.preferences.background)).foregroundStyle(Kit.ink)
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Learning resources").navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditor) { ResourceEditorView(storage: storage, onSave: reload) }
        .alert("Open external website?", isPresented: Binding(get: { pendingOpen != nil }, set: { if !$0 { pendingOpen = nil } })) {
            Button("Open website") { openPending() }.accessibilityIdentifier("resources.open.confirm")
            Button("Cancel", role: .cancel) { pendingOpen = nil }
        } message: {
            Text("Destination: \(pendingOpen?.link.canonical ?? "")\n\nThe website or its app may use its own cookies, tracking, sign-in and redirects. Your notes are not sent. SpeechCoachAI has not read or checked this content.")
        }
        .confirmationDialog("Remove bookmark and its notes?", isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } }), titleVisibility: .visible) {
            Button("Remove bookmark", role: .destructive, action: remove)
            Button("Cancel", role: .cancel) { deleting = nil }
        }
        .onAppear { reload(); connectivity.start() }
        .onDisappear { connectivity.stop(); pendingOpen = nil }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { reload(); connectivity.start() }
            else { pendingOpen = nil; connectivity.stop() }
        }
        .accessibilityIdentifier("resources.library")
    }

    private var filtered: [LearningResource] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return resources.filter { q.isEmpty || [$0.title, $0.topic, $0.notes, $0.destination].contains(where: { $0.localizedStandardContains(q) }) }
    }

    private func bookmark(_ resource: LearningResource) -> some View {
        KitCard {
            KitContentRow(symbol: resource.curatedID == nil ? "bookmark" : "link", title: resource.title,
                          detail: (try? ResourceLink(resource.destination).host) ?? "Link unavailable")
                .accessibilityElement(children: .combine)
            if !resource.topic.isEmpty { Text(resource.topic).font(.caption).foregroundStyle(Kit.accent) }
            if !resource.notes.isEmpty { Text(resource.notes).font(.callout).textSelection(.enabled) }
            Text(resource.curatedID == nil ? "Personal bookmark · not reviewed teaching" : "Saved source link · notes are personal")
                .font(.caption).foregroundStyle(Kit.secondary)
            ViewThatFits(in: .horizontal) {
                HStack { actions(resource) }
                VStack(alignment: .leading) { actions(resource) }
            }
        }.accessibilityElement(children: .contain)
            .accessibilityIdentifier("resources.bookmark.\(resource.id.uuidString)")
    }

    @ViewBuilder private func actions(_ resource: LearningResource) -> some View {
        Button { prepareOpen(resource.destination, bookmark: resource) } label: {
            Text("Open website").frame(minWidth: 44, minHeight: 44)
        }.disabled(connectivity.offline).accessibilityIdentifier("resources.open.\(resource.id.uuidString)")
        Button { edit(resource) } label: { Text("Edit").frame(minWidth: 44, minHeight: 44) }
            .accessibilityIdentifier("resources.edit.\(resource.id.uuidString)")
        Button(role: .destructive) { deleting = resource } label: { Text("Remove").frame(minWidth: 44, minHeight: 44) }
            .accessibilityIdentifier("resources.remove.\(resource.id.uuidString)")
    }

    private func curated(_ resource: CuratedLearningResource) -> some View {
        KitCard {
            KitContentRow(symbol: "link", title: resource.title, detail: resource.detail)
            Text("Source: \((try? ResourceLink(resource.source).host) ?? "external publisher")")
                .font(.caption).foregroundStyle(Kit.secondary)
            Button { prepareOpen(resource.destination) } label: { Text("Open website").frame(minHeight: 44) }
                .disabled(connectivity.offline).accessibilityIdentifier("resources.source.open.\(resource.id)")
            let existing = resources.first { $0.destination == (try? ResourceLink(resource.destination).canonical) }
            Button { edit(existing, curated: existing == nil ? resource : nil) } label: {
                Text(existing == nil ? "Save to my library" : "Edit saved bookmark").frame(minHeight: 44)
            }.accessibilityIdentifier("resources.source.save.\(resource.id)")
        }
    }

    private func edit(_ resource: LearningResource? = nil, curated: CuratedLearningResource? = nil) {
        do {
            try storage.validateResourceDraftEpoch()
            try storage.beginResourceDraft(resource: resource, curated: curated)
            showEditor = true
        } catch {
            message = "Your bookmark could not be opened for editing. Try again after unlocking your device."
        }
    }

    private func reload() {
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            let current = try repository.learningDataEpoch()
            if epoch != current { resources = []; pendingOpen = nil; deleting = nil; epoch = current }
            try storage.validateResourceDraftEpoch()
            resources = try repository.learningResources()
            if readFailed { message = nil }
            readFailed = false
        } catch LearnerStorageError.staleVersion {
            message = "Learning data was reset. The old unsaved bookmark was discarded."
            reload()
        } catch {
            readFailed = true
            message = "Your library could not be loaded. Existing saved data has been kept. Try again after unlocking your device."
        }
    }

    private func prepareOpen(_ destination: String, bookmark: LearningResource? = nil) {
        do {
            guard !connectivity.offline, let repository = storage.repository else { throw LearnerStorageError.unavailable }
            let intent = try ResourceOpenIntent(destination: destination, epoch: repository.learningDataEpoch(), bookmark: bookmark)
            _ = try repository.resourceDestination(intent)
            pendingOpen = intent
        } catch { message = "This link cannot be opened. Reload the library or edit the bookmark." }
    }

    private func openPending() {
        guard let intent = pendingOpen else { return }
        pendingOpen = nil
        do {
            guard !connectivity.offline, let repository = storage.repository else { throw LearnerStorageError.unavailable }
            let url = try repository.resourceDestination(intent)
            #if DEBUG
            if SpeakingEnvironment.fixtureID != nil, ProcessInfo.processInfo.environment["SC_RESOURCE_OPEN_FAILURE"] == "1" {
                finishOpening(false, epoch: intent.epoch); return
            }
            #endif
            openURL(url) { accepted in finishOpening(accepted, epoch: intent.epoch) }
        } catch { message = "The link changed or is unavailable. Reload the library and try again." }
    }

    private func finishOpening(_ accepted: Bool, epoch: UUID) {
        guard (try? storage.repository?.learningDataEpoch()) == epoch else { return }
        message = accepted ? nil : "The website could not be opened. Your bookmark and notes are still saved. You can edit or remove an unavailable link."
    }

    private func remove() {
        guard let resource = deleting, let epoch else { return }
        deleting = nil
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            try repository.deleteLearningResource(resource, expectedEpoch: epoch)
            if storage.resourceDraft?.id == resource.id { storage.resourceDraft = nil }
            message = nil; reload()
        } catch { message = "This bookmark could not be removed. Reload and try again. Its saved notes have been kept." }
    }
}
