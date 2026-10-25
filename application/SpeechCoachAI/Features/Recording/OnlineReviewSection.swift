import SwiftUI

struct OnlineReviewSection: View {
    @Bindable var online: OnlinePracticeController
    var background: LearnerPreferences.Background
    @State private var showSubmission = false
    @State private var stage: SpeakingRequestStage = .transcription
    @Environment(\.verticalSizeClass) private var verticalSize
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Divider()
            Text("Optional online guidance").font(.headline)
            if online.isBusy {
                ProgressView("Waiting for provider")
                Button("Cancel request") { online.cancel() }.buttonStyle(.bordered)
                Text("Cancellation stops local waiting. Remote processing and charges may continue.").font(.footnote)
            } else {
                Button(online.original == nil ? "Transcribe this take" : "Request transcription again") {
                    stage = .transcription; showSubmission = true
                }.buttonStyle(.bordered).accessibilityIdentifier("online.transcribe")
                if !online.canSubmit {
                    Text(online.scope == nil ? "Set up your own provider key in Profile & settings. Recording and self-review work without one." : SpeakingProviderError.verificationRequired.message)
                        .font(.callout).foregroundStyle(Kit.secondary)
                }
            }
            if let original = online.original {
                DisclosureGroup("Original recognition · Revision \(original.revision)") {
                    Text(original.text).textSelection(.enabled)
                }
                Text("Check your words").font(.headline)
                Text("Recognition can be mistaken. Editing stays local and never changes the original recognition.").font(.footnote).foregroundStyle(Kit.secondary)
                TextEditor(text: $online.editedText)
                    .frame(minHeight: verticalSize == .compact ? 96 : 180)
                    .padding(8).background(Kit.soft, in: RoundedRectangle(cornerRadius: 12))
                    .accessibilityLabel("Transcript to confirm").accessibilityIdentifier("online.transcript")
                    .disabled(online.isBusy)
                Button("Confirm this text") { online.confirm() }.buttonStyle(.bordered)
                    .disabled(online.isBusy).accessibilityIdentifier("online.confirm")
                if let confirmed = online.currentConfirmed {
                    Text("Confirmed revision \(confirmed.revision)").font(.caption)
                    Toggle("Hints only", isOn: $online.hintsOnly).disabled(online.isBusy)
                    Toggle("Expanded detail (up to five actions)", isOn: $online.expanded).disabled(online.isBusy)
                    Button(online.currentFeedback == nil ? "Review coaching request" : "Request new coaching") {
                        stage = .coaching; showSubmission = true
                    }.buttonStyle(.bordered)
                        .disabled(online.isBusy || confirmed.text != online.editedText)
                        .accessibilityIdentifier("online.coach")
                }
            }
            if let feedback = online.currentFeedback { FeedbackContent(feedback: feedback) }
            if let message = online.message {
                Text(message).font(.callout).foregroundStyle(Kit.secondary).accessibilityIdentifier("online.message")
            }
        }
        .sheet(isPresented: $showSubmission) {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(stage == .transcription ? "Send selected voice for transcription?" : "Send confirmed text for coaching?").font(.title2.bold())
                        Text(online.disclosure)
                        Text(stage == .transcription ? "Only the selected voice recording and language option are sent. Your local original stays here." : "Only confirmed text, the frozen task/objective and coaching choices are sent. Your audio and full history are not sent for text coaching.")
                        if stage == .coaching, let text = online.currentConfirmed?.text { Text(text).padding().background(Kit.soft).textSelection(.enabled) }
                        Text("Your provider account may be charged. Each retry is a new request. A timeout or cancellation can leave the billing outcome unknown. There is no automatic retry or paid fallback.")
                        if online.canSubmit {
                            Button(stage == .transcription ? "Send voice for transcription" : "Send text for coaching") {
                                showSubmission = false; online.submit(stage)
                            }.buttonStyle(.borderedProminent).foregroundStyle(Color("OnAccent"))
                                .accessibilityIdentifier("online.send")
                        } else { Text(SpeakingProviderError.verificationRequired.message).foregroundStyle(Kit.secondary) }
                        Button("Keep practicing offline") { showSubmission = false }.buttonStyle(.bordered)
                    }.padding(20).frame(maxWidth: 700).frame(maxWidth: .infinity)
                }.background(Kit.canvas(background)).foregroundStyle(Kit.ink)
                    .navigationTitle("Before you send").navigationBarTitleDisplayMode(.inline)
                    .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { showSubmission = false } } }
            }.tint(Kit.accent)
        }
    }
}
