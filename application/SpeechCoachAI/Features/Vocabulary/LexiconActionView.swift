import SwiftUI

/// Lexicon in Action: words rated Easy come back in context. Fill the blank, or choose the correct sentence.
struct LexiconActionView: View {
    var storage: LearnerStorageController
    var bank: LexiconBank
    @Environment(\.dismiss) private var dismiss
    @State private var questions: [LexiconQuestion] = []
    @State private var index = 0
    @State private var correct = 0
    @State private var loaded = false
    @State private var message: String?

    var body: some View {
        Group {
            if !loaded {
                Text("One moment.").foregroundStyle(Kit.secondary).padding(20)
            } else if questions.isEmpty {
                summary(title: "Nothing is ready yet.", detail: nil)
            } else if index >= questions.count {
                summary(title: "Nice work.", detail: "\(correct) of \(questions.count) right.")
            } else {
                ExerciseActivityView(
                    activity: questions[index].activity,
                    progress: Double(index) / Double(questions.count),
                    positionText: "\(index + 1) of \(questions.count)",
                    isLast: index == questions.count - 1,
                    message: message,
                    onSubmit: { answer in record(answer) },
                    onContinue: { index += 1; message = nil })
                .id(questions[index].id)
            }
        }
        .background(Kit.canvas(storage.preferences.background))
        .foregroundStyle(Kit.ink)
        .navigationTitle("Lexicon in Action").navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: load)
    }

    private func summary(title: String, detail: String?) -> some View {
        ScrollView {
            KitCard {
                Text(title).font(.title2.bold())
                if let detail { Text(detail).foregroundStyle(Kit.secondary) }
                Button("Done") { dismiss() }.buttonStyle(KitPrimaryButtonStyle()).accessibilityIdentifier("lexicon.action.done")
            }.padding(20).frame(maxWidth: 700)
        }
    }

    private func load() {
        guard !loaded, let repository = storage.repository else { return }
        let state = (try? repository.lexiconState()) ?? LexiconState()
        let stages = (try? repository.lexiconStages(bank: bank)) ?? [:]
        let ready = LexiconActionBuilder.eligible(bank: bank, stages: stages, state: state, now: Date())
        questions = LexiconActionBuilder.questions(words: ready, bank: bank)
        loaded = true
    }

    /// Saves the answer. A spelling slip still counts as right; only a wrong answer sends the word back to training.
    private func record(_ answer: String) -> Bool {
        let question = questions[index]
        guard let repository = storage.repository, let word = bank.word(id: question.wordID) else { return false }
        let result = question.activity.resolvedExercise.result(forStored: answer)
        let isRight = result == .correct || { if case .almost = result { return true } else { return false } }()
        do {
            try repository.recordLexiconAction(word: word, correct: isRight)
            if isRight { correct += 1 }
            return true
        } catch {
            message = "That answer could not be saved."
            return false
        }
    }
}
