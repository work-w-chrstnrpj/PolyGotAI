import SwiftUI
import UIKit

/// One auto-checked exercise: question, answer area, Check, then instant feedback and Continue.
/// The lesson player owns saving; this view reports the learner's answer as text through `onSubmit`.
struct ExerciseActivityView: View {
    let activity: CurriculumActivity
    var progress: Double
    var positionText: String
    var isLast: Bool
    /// The first answer already saved for this activity, shown again when the learner returns to it.
    var storedResponse: String? = nil
    var message: String? = nil
    var canGoBack = false
    var onBack: () -> Void = {}
    var onPlayClip: (String) -> Void = { _ in }
    /// Saves the answer; false means it could not be saved and `message` explains why.
    var onSubmit: (String) -> Bool
    var onContinue: () -> Void

    @State private var selection: String?
    @State private var typed = ""
    @State private var chosenTiles: [Int] = []
    @State private var leftPick: Int?
    @State private var matched: [Int: Int] = [:]
    @State private var result: AnswerResult?
    @State private var restored = false
    @FocusState private var typing: Bool
    private var synthesizer: SpeechSynthesizer { .shared }

    private var spec: ExerciseSpec { activity.resolvedExercise }
    private var locked: Bool { result != nil }

    // MARK: Stable shuffles

    private func shuffled(_ values: [String], salt: String) -> [String] {
        var generator = SeededGenerator(seed: activity.id + salt)
        return values.shuffled(using: &generator)
    }
    private var choiceOptions: [String] { shuffled(spec.options ?? [], salt: "choice") }
    private var tiles: [String] { shuffled(spec.kind == .order ? (spec.items ?? []) : (spec.options ?? []), salt: "tiles") }
    private var leftItems: [String] { (spec.pairs ?? []).map { $0[0] } }
    private var rightItems: [String] { shuffled((spec.pairs ?? []).map { $0[1] }, salt: "right") }

    // MARK: Body

    var body: some View {
        VStack(spacing: 0) {
            topBar
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text(activity.prompt ?? "Choose the answer.")
                        .font(.title2.weight(.semibold)).fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("exercise.prompt")
                    audioControls
                    exerciseBody.allowsHitTesting(!locked)
                    if let message { Text(message).font(.callout).foregroundStyle(Kit.error) }
                }
                .frame(maxWidth: 640, alignment: .leading)
                .padding(24)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
            bottomBar
        }
        .onAppear(perform: restore)
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            Button(action: onBack) { Image(systemName: "arrow.left").frame(minWidth: 44, minHeight: 44) }
                .accessibilityLabel("Previous activity").accessibilityIdentifier("exercise.back")
                .opacity(canGoBack ? 1 : 0).disabled(!canGoBack).accessibilityHidden(!canGoBack)
            ProgressView(value: progress).tint(Kit.accent).accessibilityHidden(true)
            Text(positionText).font(.subheadline.weight(.semibold)).foregroundStyle(Kit.secondary)
        }
        .padding(.horizontal, 24).padding(.top, 8).frame(maxWidth: 688)
    }

    // MARK: Audio

    @ViewBuilder private var audioControls: some View {
        if let path = activity.playbackPath {
            HStack(spacing: 12) {
                Button { onPlayClip(path) } label: { Label("Play", systemImage: "play.circle.fill") }
                    .accessibilityIdentifier("lesson.play.\(activity.id)")
            }.buttonStyle(.bordered).controlSize(.large)
        } else if let text = spec.audioText, spec.kind == .listenType || spec.kind == .choice || spec.kind == .speak {
            HStack(spacing: 12) {
                Button { synthesizer.speak(text) } label: { Label("Listen", systemImage: "speaker.wave.2.fill") }
                Button { synthesizer.speak(text, slow: true) } label: { Label("Slow", systemImage: "tortoise.fill") }
            }.buttonStyle(.bordered).controlSize(.large)
        }
    }

    // MARK: Answer areas

    @ViewBuilder private var exerciseBody: some View {
        switch spec.kind {
        case .choice: choiceBody
        case .wordBank: tileBody(sequence: true)
        case .order: tileBody(sequence: false)
        case .match: matchBody
        default: typedBody
        }
    }

    private var choiceBody: some View {
        VStack(spacing: 12) {
            ForEach(choiceOptions, id: \.self) { option in
                let isPicked = selection == option
                let isRight = locked && (spec.accepted ?? []).contains(option)
                let isWrong = locked && isPicked && !isRight
                let outline: Color = isRight ? Self.rightColor : isWrong ? Kit.error : isPicked ? Kit.accent : Kit.secondary.opacity(0.25)
                Button { selection = option } label: {
                    HStack(spacing: 14) {
                        Image(systemName: isRight ? "checkmark.circle.fill" : isWrong ? "xmark.circle.fill" : isPicked ? "largecircle.fill.circle" : "circle")
                            .foregroundStyle(isRight ? Self.rightColor : isWrong ? Kit.error : Kit.accent)
                        Text(option).font(.title3.weight(.medium)).foregroundStyle(Kit.ink).multilineTextAlignment(.leading)
                        Spacer(minLength: 0)
                    }
                    .padding(16).frame(minHeight: 54)
                    .background(isPicked && !locked ? Kit.soft : Kit.surface, in: RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(outline, lineWidth: isPicked || isRight ? 2 : 1))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isPicked ? .isSelected : [])
                .accessibilityIdentifier("exercise.choice.\(option)")
            }
        }
    }

    /// wordBank builds a sentence from tiles; order numbers the items. Both share one answer line and one bank.
    private func tileBody(sequence: Bool) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            FlowLayout(spacing: 8) {
                ForEach(Array(chosenTiles.enumerated()), id: \.offset) { position, tileIndex in
                    Button { if !locked { chosenTiles.remove(at: position) } } label: {
                        tileLabel(sequence ? tiles[tileIndex] : "\(position + 1). \(tiles[tileIndex])", highlighted: true)
                    }
                    .buttonStyle(.plain).accessibilityIdentifier("exercise.answer.\(tiles[tileIndex])")
                }
            }
            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
            .padding(12)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Kit.secondary.opacity(0.35), style: StrokeStyle(lineWidth: 1, dash: [5])))
            .accessibilityIdentifier("exercise.answer-line")
            FlowLayout(spacing: 8) {
                ForEach(Array(tiles.enumerated()), id: \.offset) { index, tile in
                    let used = chosenTiles.contains(index)
                    Button { if !used { chosenTiles.append(index) } } label: { tileLabel(tile, dimmed: used) }
                        .buttonStyle(.plain).disabled(used)
                        .accessibilityIdentifier("exercise.tile.\(tile)")
                }
            }
        }
    }

    private func tileLabel(_ text: String, dimmed: Bool = false, highlighted: Bool = false) -> some View {
        Text(text).font(.title3.weight(.medium)).foregroundStyle(Kit.ink)
            .padding(.horizontal, 14).padding(.vertical, 10).frame(minHeight: 44)
            .background(highlighted ? Kit.soft : Kit.surface, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(highlighted ? Kit.accent : Kit.secondary.opacity(0.35)))
            .opacity(dimmed ? 0.25 : 1)
    }

    private var matchBody: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 10) {
                ForEach(Array(leftItems.enumerated()), id: \.offset) { index, item in
                    let partner = matched[index].map { rightItems[$0] }
                    Button {
                        if matched[index] != nil { matched[index] = nil; leftPick = nil } else { leftPick = index }
                    } label: {
                        tileLabel(partner.map { "\(item) → \($0)" } ?? item, highlighted: leftPick == index || partner != nil)
                    }
                    .buttonStyle(.plain).accessibilityIdentifier("exercise.left.\(item)")
                }
            }
            VStack(spacing: 10) {
                ForEach(Array(rightItems.enumerated()), id: \.offset) { index, item in
                    let used = matched.values.contains(index)
                    Button {
                        guard let left = leftPick, !used else { return }
                        matched[left] = index; leftPick = nil
                    } label: { tileLabel(item, dimmed: used) }
                        .buttonStyle(.plain).disabled(used)
                        .accessibilityIdentifier("exercise.right.\(item)")
                }
            }
        }
    }

    private var typedBody: some View {
        let showsDictation = spec.kind != .listenType
        return Group {
            if showsDictation {
                field.dictation($typed)
            } else { field }
        }
    }

    private var field: some View {
        TextField(spec.kind == .listenType ? "Type what you hear" : "Your answer", text: $typed, axis: .vertical)
            .lineLimit(1...4).padding(16)
            .background(Kit.surface, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Kit.secondary.opacity(0.35)))
            .textInputAutocapitalization(.never).autocorrectionDisabled()
            .focused($typing)
            .accessibilityIdentifier("exercise.field")
    }

    // MARK: Checking

    private var canCheck: Bool {
        switch spec.kind {
        case .choice: selection != nil
        case .wordBank: !chosenTiles.isEmpty
        case .order: chosenTiles.count == tiles.count
        case .match: matched.count == leftItems.count
        default: !typed.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    private func currentResponse() -> ExerciseResponse {
        switch spec.kind {
        case .choice: return .text(selection ?? "")
        case .wordBank, .order: return .sequence(chosenTiles.map { tiles[$0] })
        case .match:
            return .pairs(matched.sorted { $0.key < $1.key }.map { [leftItems[$0.key], rightItems[$0.value]] })
        default: return .text(typed)
        }
    }

    private func check() {
        let response = currentResponse()
        typing = false
        _ = onSubmit(spec.storedText(response))
        let checked = spec.evaluate(response) ?? .correct
        result = checked
        let haptic = UINotificationFeedbackGenerator()
        haptic.notificationOccurred(checked == .incorrect ? .error : .success)
    }

    private func restore() {
        guard !restored, let stored = storedResponse else { return }
        restored = true
        result = spec.result(forStored: stored) ?? .correct
        switch spec.response(fromStored: stored) {
        case .text(let text)?:
            if spec.kind == .choice { selection = text } else { typed = text }
        case .sequence(let items)?:
            var used: Set<Int> = []
            chosenTiles = items.compactMap { item in
                guard let index = tiles.indices.first(where: { tiles[$0] == item && !used.contains($0) }) else { return nil }
                used.insert(index); return index
            }
        case .pairs(let pairs)?:
            for pair in pairs where pair.count == 2 {
                if let left = leftItems.firstIndex(of: pair[0]), let right = rightItems.firstIndex(of: pair[1]) { matched[left] = right }
            }
        case nil: break
        }
    }

    // MARK: Bottom bar

    @ViewBuilder private var bottomBar: some View {
        if let result {
            feedbackBar(result)
        } else {
            Button { check() } label: { Text("Check") }
                .buttonStyle(KitPrimaryButtonStyle())
                .disabled(!canCheck)
                .padding(.horizontal, 24).padding(.vertical, 14).frame(maxWidth: 688)
                .accessibilityIdentifier("exercise.check")
        }
    }

    private static let rightColor = Color(red: 0.09, green: 0.46, blue: 0.28)

    private func feedbackBar(_ result: AnswerResult) -> some View {
        let tint: Color = switch result {
        case .correct: Self.rightColor
        case .almost: Color(red: 0.62, green: 0.36, blue: 0.0)
        case .incorrect: Kit.error
        }
        let title: String = switch result {
        case .correct: "Correct!"
        case .almost(let hint): "Almost. " + hint
        case .incorrect: "Not quite"
        }
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: result == .incorrect ? "xmark.circle.fill" : "checkmark.circle.fill").foregroundStyle(tint)
                Text(title).font(.headline).foregroundStyle(tint)
            }
            if result != .correct, let answer = answerText {
                Text("Answer: \(answer)").font(.body.weight(.medium)).foregroundStyle(Kit.ink)
                    .accessibilityIdentifier("exercise.answer")
            }
            if let explanation = activity.explanation {
                Text(explanation).font(.callout).foregroundStyle(Kit.secondary).fixedSize(horizontal: false, vertical: true)
            }
            Button(action: onContinue) { Text(isLast ? "Finish" : "Continue") }
                .buttonStyle(KitPrimaryButtonStyle())
                .accessibilityIdentifier("exercise.continue")
        }
        .frame(maxWidth: 640, alignment: .leading)
        .padding(.horizontal, 24).padding(.vertical, 16).frame(maxWidth: .infinity)
        .background(tint.opacity(0.12))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("exercise.feedback")
    }

    private var answerText: String? {
        switch spec.kind {
        case .match: (spec.pairs ?? []).map { "\($0[0]) → \($0[1])" }.joined(separator: ", ")
        case .order: (spec.items ?? []).joined(separator: " → ")
        default: spec.modelAnswer
        }
    }
}
