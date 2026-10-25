import SwiftUI

/// Word of the Day. Page 1 T02 (`2:38065`) shows one word, its example, and an unmarked state.
/// This screen does not select, rotate, enroll, or credit a word. Goal summary card `2:40095` is not copied.
struct WordOfDayView: View {
    @Binding var session: WordOfDaySession
    var localDay: String
    var catalog: [DailySense]
    var policy: WordOfDayPolicy?
    var background: LearnerPreferences.Background = .creativeAcademy

    private var presentation: WordOfDayPresentation {
        session.presentation(localDay: localDay, catalog: catalog)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(localDay.isEmpty ? "Local day unavailable" : localDay)
                    .font(.caption.weight(.medium)).foregroundStyle(Kit.secondary)
                    .accessibilityIdentifier("word.day.local")
                if let word = presentation.word {
                    KitCard {
                        Text("WORD OF THE DAY").font(.caption.weight(.semibold)).foregroundStyle(Kit.accent)
                        Text(word.lemma).font(.title2.bold()).accessibilityIdentifier("word.day.lemma")
                        if let meaning = word.meaning, !meaning.isEmpty {
                            Text(meaning).foregroundStyle(Kit.secondary).fixedSize(horizontal: false, vertical: true)
                                .accessibilityIdentifier("word.day.meaning")
                        }
                        Text(word.example).fixedSize(horizontal: false, vertical: true)
                            .accessibilityIdentifier("word.day.example")
                        Text("Not marked. No credit is given.")
                            .font(.footnote).foregroundStyle(Kit.secondary)
                        if presentation.meaningChanged {
                            Text("The reviewed wording changed. This word was not replaced or added to review.")
                                .font(.footnote).foregroundStyle(Kit.secondary)
                                .accessibilityIdentifier("word.day.changed")
                        }
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("word.day.card")
                } else {
                    AvailabilityCard(
                        title: "No word for this local day",
                        detail: presentation.reason?.message ?? WordOfDayRefusal.nothingChosen.message,
                        symbol: "calendar")
                        .accessibilityIdentifier("word.day.empty")
                }
                Text(policy?.refusal().message ?? WordOfDayPolicy(decisionRecord: "", ownerDecisionAccepted: false, repeatRule: .unresolved).refusal().message)
                    .font(.footnote).foregroundStyle(Kit.secondary).fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("word.day.policy")
                Button("Save to collection") {}
                    .frame(minHeight: 44)
                    .disabled(true)
                    .accessibilityIdentifier("word.day.save")
                Button("Add to review") {}
                    .frame(minHeight: 44)
                    .disabled(true)
                    .accessibilityIdentifier("word.day.enroll")
                Text("This screen does not save or enroll a word.")
                    .font(.footnote).foregroundStyle(Kit.secondary)
                AvailabilityCard(
                    title: "Practice works offline",
                    detail: "No word is fetched or selected. Your own words remain available in Vocabulary.",
                    symbol: "wifi.slash")
            }
            .padding(20)
            .frame(maxWidth: 640, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(Kit.canvas(background))
        .navigationTitle("Word of the Day")
    }
}

struct WordOfDayLauncher: View {
    var storage: LearnerStorageController
    @Environment(\.scenePhase) private var scenePhase
    @State private var session = WordOfDaySession()
    @State private var storageFailed = false
    @State private var day = LocalDayKey.from(.now, calendar: .current)

    var body: some View {
        VStack {
            if storageFailed {
                AvailabilityCard(title: "Local data unavailable", detail: "Unlock your device and try again. Saved data has been kept.", symbol: "exclamationmark.triangle")
                Button("Try again", action: refresh).frame(minHeight: 44)
            }
            WordOfDayView(session: $session, localDay: day, catalog: [], policy: nil, background: storage.preferences.background)
        }
            .onAppear(perform: refresh)
            .onChange(of: scenePhase) { _, phase in if phase == .active { refresh() } }
            .onChange(of: storage.repository != nil) { _, _ in refresh() }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in refresh() }
            .onReceive(NotificationCenter.default.publisher(for: .NSSystemTimeZoneDidChange)) { _ in refresh() }
            .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in refresh() }
    }

    private func refresh() {
        day = LocalDayKey.from(.now, calendar: .current)
        do {
            guard let repository = storage.repository else { throw LearnerStorageError.unavailable }
            let epoch = try repository.learningDataEpoch()
            session.bindEpoch(epoch)
            if let record = try repository.wordOfDayRecord() { session = .recover(record, epoch: epoch) }
            storageFailed = false
        } catch { session.bindEpoch(nil); storageFailed = true }
    }
}
