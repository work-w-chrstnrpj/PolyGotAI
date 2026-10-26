import AVFAudio
import Charts
import SwiftUI

/// Phase 10 speak-first check: hear the model, say it, then see what the phone heard and how your pitch moved.
struct SpeakCheckView: View {
    enum Mode: Equatable {
        /// Say the target word of a minimal pair.
        case pair(MinimalPair)
        /// Say a sentence; intonation items also judge rising or falling.
        case intonation(String)
        /// Say a word or phrase; the pitch line is drawn next to the model's.
        case stress(String)

        var text: String {
            switch self { case .pair(let pair): pair.target; case .intonation(let text), .stress(let text): text }
        }
        var itemID: String {
            switch self { case .pair(let pair): pair.id; case .intonation(let text), .stress(let text): "say-" + LexiconKey.slug(text) }
        }
    }

    var storage: LearnerStorageController
    var store: SpeechLabStore
    var mode: Mode
    @State private var capture: SpeechLabCapture
    @State private var model: PitchContour?
    @State private var savedFor: String?
    @Environment(\.scenePhase) private var scenePhase

    init(storage: LearnerStorageController, store: SpeechLabStore, mode: Mode) {
        self.storage = storage; self.store = store; self.mode = mode
        let capture = SpeechLabCapture(repository: storage.repository, preferences: storage.preferences, itemID: mode.itemID, text: mode.text)
        if case .pair(let pair) = mode { capture.hints = [pair.target, pair.contrast] }
        if case .pair = mode {} else { capture.wantsPitch = true }
        _capture = State(initialValue: capture)
    }

    var body: some View {
        if SpeechLabRecognizer.supported {
            VStack(alignment: .leading, spacing: Kit.Space.l) {
                HeroCard(eyebrow: "Say it", title: mode.text, detail: contrastLine) {
                    HStack(spacing: Kit.Space.m) {
                        Button { SpeechSynthesizer.shared.speak(mode.text) } label: { Label("Hear", systemImage: "speaker.wave.2.fill") }
                            .buttonStyle(KitSecondaryButtonStyle()).accessibilityIdentifier("speak.hear")
                        recordButton
                    }
                }
                if capture.recognizing { ProgressView("Listening…") }
                if let transcript = capture.transcript { result(transcript) }
                if let message = capture.message { Text(message).foregroundStyle(Kit.error).accessibilityIdentifier("speak.error") }
            }
            .task {
                if model == nil, case .pair = mode {} else if model == nil {
                    model = await PitchAnalysis.modelContour(mode.text, settings: storage.preferences.voiceSettings ?? VoiceSettings())
                }
                while !Task.isCancelled {
                    do { try await Task.sleep(for: .milliseconds(100)) } catch { return }
                    capture.tick(maximum: 15)
                }
            }
            .onChange(of: capture.transcript) { _, transcript in
                if let transcript { save(good: verdict(transcript).good) }
            }
            .onDisappear { capture.leave() }
            .onChange(of: scenePhase) { _, value in if value != .active { capture.leave() } }
            .onReceive(NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)) { _ in capture.leave() }
        }
    }

    private var contrastLine: String? {
        if case .pair(let pair) = mode { return "Not “\(pair.contrast)”" }
        return nil
    }

    @ViewBuilder private var recordButton: some View {
        if capture.isRecording {
            Button { capture.stop() } label: { Label("Stop", systemImage: "stop.fill") }
                .buttonStyle(KitPrimaryButtonStyle()).accessibilityIdentifier("speak.stop")
        } else {
            Button { savedFor = nil; capture.start() } label: {
                Label(capture.transcript == nil ? "Say it" : "Again", systemImage: "mic.fill")
            }
            .buttonStyle(KitPrimaryButtonStyle()).disabled(capture.busy).accessibilityIdentifier("speak.record")
        }
    }

    @ViewBuilder private func result(_ transcript: SpeechLabTranscript) -> some View {
        let verdict = self.verdict(transcript)
        KitCard {
            Label(verdict.title, systemImage: verdict.good ? "checkmark.circle.fill" : "arrow.triangle.2.circlepath")
                .font(Kit.Fonts.rowTitle).foregroundStyle(verdict.good ? Kit.accent : Kit.ink)
                .accessibilityIdentifier("speak.verdict")
            if let detail = verdict.detail {
                Text(detail).font(Kit.Fonts.detail).foregroundStyle(Kit.secondary).fixedSize(horizontal: false, vertical: true)
            }
            Button { capture.replay() } label: { Label("Play yours", systemImage: "play.fill") }
                .buttonStyle(.bordered).accessibilityIdentifier("speak.replay")
        }
        if let contour = capture.contour, !contour.points.isEmpty {
            PitchChart(yours: contour, model: model)
        }
    }

    private struct Verdict { var good: Bool; var title: String; var detail: String? }

    private func verdict(_ transcript: SpeechLabTranscript) -> Verdict {
        switch mode {
        case .pair(let pair):
            switch MinimalPairJudge.judge(pair, heard: transcript.text) {
            case .clear: return Verdict(good: true, title: "Clear: we heard “\(pair.target)”", detail: nil)
            case .soundedLike(let word): return Verdict(good: false, title: "That sounded like “\(word)”", detail: pair.tip)
            case .heard(let text): return Verdict(good: false, title: "We heard “\(text)”", detail: "Say the word on its own, a little slower.")
            case .nothing: return Verdict(good: false, title: "We didn't catch a word", detail: "Move closer and try again.")
            }
        case .intonation(let text):
            let expected = IntonationJudge.expected(for: text)
            guard let contour = capture.contour, let shape = IntonationJudge.shape(of: contour) else {
                return Verdict(good: false, title: "We heard “\(transcript.text)”", detail: "Speak a little louder so your pitch line shows.")
            }
            let good = shape == expected
            let said = shape == .rising ? "Your voice went up at the end" : shape == .falling ? "Your voice went down at the end" : "Your voice stayed level at the end"
            let needed = expected == .rising ? "A yes/no question usually goes up at the end." : "A statement usually goes down at the end."
            return Verdict(good: good, title: said + (good ? "." : ""), detail: good ? nil : needed)
        case .stress(let text):
            let heardAll = AnswerChecker.normalize(transcript.text).contains(AnswerChecker.normalize(text))
            return Verdict(good: heardAll, title: heardAll ? "Clear: we heard “\(text)”" : "We heard “\(transcript.text)”",
                           detail: "Compare your pitch line with the model's. The stressed part is usually higher and longer.")
        }
    }

    private func save(good: Bool) {
        guard savedFor != capture.transcript?.text else { return }
        savedFor = capture.transcript?.text
        let recordingID = try? capture.finish(keepAudio: false)
        _ = store.save(SpeechLabAttempt(area: .phonetics, itemID: mode.itemID, correct: good ? 1 : 0, total: 1, recordingID: recordingID ?? nil))
    }
}

/// Your pitch line and the model's, stretched to the same length. Semitones around each speaker's own middle pitch.
struct PitchChart: View {
    @Environment(\.kitTheme) private var theme
    var yours: PitchContour
    var model: PitchContour?

    var body: some View {
        KitCard {
            Text("Your pitch").font(Kit.Fonts.rowTitle)
            Chart {
                if let model {
                    ForEach(Array(model.normalised.enumerated()), id: \.offset) { _, point in
                        LineMark(x: .value("Time", point.time), y: .value("Pitch", point.semitones), series: .value("Line", "Model"))
                            .foregroundStyle(theme.chart[1]).lineStyle(StrokeStyle(lineWidth: 2, dash: [4, 3]))
                    }
                }
                ForEach(Array(yours.normalised.enumerated()), id: \.offset) { _, point in
                    LineMark(x: .value("Time", point.time), y: .value("Pitch", point.semitones), series: .value("Line", "You"))
                        .foregroundStyle(theme.accent).lineStyle(StrokeStyle(lineWidth: 3))
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis { AxisMarks(values: [-6, 0, 6]) { _ in AxisGridLine() } }
            .chartYScale(domain: -9...9)
            .frame(height: 140)
            .accessibilityLabel("Pitch line")
            .accessibilityValue(summary)
            HStack(spacing: Kit.Space.l) {
                Label("You", systemImage: "line.diagonal").foregroundStyle(theme.accent)
                if model != nil { Label("Model", systemImage: "line.diagonal").foregroundStyle(theme.chart[1]) }
            }
            .font(.caption)
        }
        .accessibilityIdentifier("speak.pitch")
    }

    private var summary: String {
        switch IntonationJudge.shape(of: yours) {
        case .rising: "Your voice goes up at the end"
        case .falling: "Your voice goes down at the end"
        case .level: "Your voice stays level at the end"
        case nil: "Too short to read"
        }
    }
}
