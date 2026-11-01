import SwiftUI

/// The IPA line under a Lexicon word (General American).
struct PronunciationText: View {
    var ipa: String
    var body: some View {
        Text(ipa).font(.title3).foregroundStyle(Kit.secondary)
            .padding(.horizontal, 10).padding(.vertical, 3)
            .background(Kit.soft.opacity(0.7), in: Capsule())
            .accessibilityLabel("Pronunciation")
            .accessibilityValue(ipa)
            .accessibilityIdentifier("lexicon.ipa")
    }
}

/// Daily Lexicon on Today: one word a day with its meaning, an example and a speaker button.
/// Showing it counts as an exposure only; nothing is scheduled until the word is trained.
struct DailyLexiconCard: View {
    var storage: LearnerStorageController
    var bank: LexiconBank = LexiconBankLoader.bundled
    @State private var word: LexiconWord?
    @State private var added = false
    @Environment(\.dynamicTypeSize) private var textSize

    var body: some View {
        if let word {
            KitCard {
                KitEyebrow(text: "Word of the day")
                header(word)
                if let ipa = word.ipa { PronunciationText(ipa: ipa) }
                Text(word.meaning).fixedSize(horizontal: false, vertical: true)
                if let example = word.parsedExamples.first {
                    Text(example.plain).italic().foregroundStyle(Kit.secondary).fixedSize(horizontal: false, vertical: true)
                }
                if added {
                    Label("In training", systemImage: "checkmark.circle").font(.subheadline).foregroundStyle(Kit.secondary)
                } else {
                    Button("Add to training") { add(word) }.buttonStyle(KitSecondaryButtonStyle()).frame(minHeight: 44)
                        .accessibilityIdentifier("daily.lexicon.add")
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("daily.lexicon")
        } else {
            Color.clear.frame(height: 0).onAppear(perform: load)
        }
    }

    /// Word, part of speech and speaker. At accessibility sizes they stack so the word never breaks mid-syllable.
    private func header(_ word: LexiconWord) -> some View {
        let layout = textSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 4)) : AnyLayout(HStackLayout(alignment: .firstTextBaseline))
        return layout {
            Text(word.lemma).font(.title.bold()).fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("daily.lexicon.lemma")
            Text(word.pos).font(.subheadline).foregroundStyle(Kit.secondary)
            if !textSize.isAccessibilitySize { Spacer() }
            if let example = word.parsedExamples.first {
                Button { SpeechSynthesizer.shared.speak("\(word.lemma). \(example.plain)") } label: {
                    Image(systemName: "speaker.wave.2.fill").font(.headline)
                        .frame(width: 44, height: 44).background(Kit.accent.opacity(0.12), in: Circle())
                }.accessibilityLabel("Listen")
            }
        }
    }

    private func load() {
        guard let repository = storage.repository else { return }
        do {
            let state = try repository.lexiconState()
            let stages = try repository.lexiconStages(bank: bank)
            let today = DailyLexicon.dayString(Date())
            guard let pick = DailyLexicon.pick(bank: bank, state: state, stages: stages, day: today) else { return }
            if pick.state != state { try repository.saveLexiconState(pick.state) }
            added = try repository.vocabularyEnrollments().contains { $0.itemId == pick.word.itemId }
            word = pick.word
        } catch {
            word = nil
        }
    }

    private func add(_ word: LexiconWord) {
        guard let repository = storage.repository,
              (try? repository.startLexiconWords([word], bankVersion: LexiconBankLoader.bankVersion)) != nil else { return }
        added = true
    }
}
