import SwiftUI

/// Practice (Phase 8): train again any time. Choose the word that fits the sentence, or choose the synonym.
/// Nothing here changes when a word is due.
struct LexiconPracticeView: View {
    var storage: LearnerStorageController
    var bank: LexiconBank
    @Environment(\.dismiss) private var dismiss
    @State private var questions: [LexiconQuestion] = []
    @State private var index = 0
    @State private var correct = 0
    @State private var loaded = false

    var body: some View {
        Group {
            if !loaded {
                Text("One moment.").foregroundStyle(Kit.secondary).padding(20)
            } else if questions.isEmpty {
                summary(title: "Start a few words first.", detail: nil, again: false)
            } else if index >= questions.count {
                summary(title: "\(correct) of \(questions.count) right", detail: correct == questions.count ? "Perfect round." : nil, again: true)
            } else {
                ExerciseActivityView(
                    activity: questions[index].activity,
                    progress: Double(index) / Double(questions.count),
                    positionText: "\(index + 1) of \(questions.count)",
                    isLast: index == questions.count - 1,
                    message: nil,
                    onSubmit: { answer in record(answer) },
                    onContinue: { index += 1 })
                .id(questions[index].id)
            }
        }
        .background(Kit.canvas(storage.preferences.background))
        .foregroundStyle(Kit.ink)
        .navigationTitle("Practice").navigationBarTitleDisplayMode(.inline)
        .onAppear { if !loaded { newRound() } }
    }

    private func summary(title: String, detail: String?, again: Bool) -> some View {
        ScrollView {
            HeroCard(eyebrow: "Practice", title: title, detail: detail) {
                if again {
                    Button("Again", action: newRound).buttonStyle(KitPrimaryButtonStyle()).accessibilityIdentifier("lexicon.practice.again")
                }
                Button("Done") { dismiss() }.buttonStyle(KitSecondaryButtonStyle()).accessibilityIdentifier("lexicon.practice.done")
            }
            .padding(20).frame(maxWidth: 700).frame(maxWidth: .infinity)
            .accessibilityIdentifier("lexicon.practice.summary")
        }
    }

    private func newRound() {
        let state = (try? storage.repository?.lexiconState()) ?? LexiconState()
        let stages = (try? storage.repository?.lexiconStages(bank: bank)) ?? [:]
        let level = storage.levelGate(install: CurriculumCatalogLoader.bundled).unlockedLevels.last ?? "A1"
        let pool = LexiconPracticeBuilder.pool(bank: bank, stages: stages, state: state, startLevel: level)
        questions = LexiconPracticeBuilder.questions(words: pool, bank: bank)
        index = 0; correct = 0; loaded = true
    }

    /// Counts the answer for this round only; a spelling slip counts as right.
    private func record(_ answer: String) -> Bool {
        let result = questions[index].activity.resolvedExercise.result(forStored: answer)
        if result == .correct { correct += 1 } else if case .almost = result { correct += 1 }
        return true
    }
}
