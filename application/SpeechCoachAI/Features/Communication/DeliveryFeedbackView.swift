import SwiftUI

/// Offline delivery record. Text feedback, when present, is structure and word use only.
struct DeliveryFeedbackView: View {
    var feedback: CommunicationTextFeedback?
    var review: CommunicationSelfReview

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AvailabilityCard(
                title: "Sound is not assessed",
                detail: SoundAssessment.transcriptReason,
                symbol: "waveform.slash")
            if let feedback {
                textFeedback(feedback)
            } else {
                AvailabilityCard(
                    title: "Online feedback is off",
                    detail: "Practice works offline. Replay or self-review now. Send only when you choose.",
                    symbol: "wifi.slash")
            }
            if review.isComplete {
                KitCard {
                    Text("Your self-review").font(.headline)
                    Text(review.purposeClear == true ? "The purpose was clear to you." : "The purpose was not clear yet.")
                    labeled("Organization", review.organizationNote)
                    labeled("Word use", review.wordUseNote)
                    if !review.deliveryNote.isEmpty { labeled("What you noticed about delivery", review.deliveryNote) }
                    if !review.eyeContactNote.isEmpty {
                        labeled("Eye contact note", review.eyeContactNote)
                        Text("Eye contact is your note only. It is not measured.").font(.footnote).foregroundStyle(Kit.secondary)
                    }
                }
            }
        }
    }

    private func textFeedback(_ feedback: CommunicationTextFeedback) -> some View {
        KitCard {
            Text("Text feedback").font(.headline)
            Text(feedback.summary).fixedSize(horizontal: false, vertical: true)
            if feedback.strengths.isEmpty {
                Text("No strength was listed.").foregroundStyle(Kit.secondary)
            } else {
                ForEach(Array(feedback.strengths.prefix(2).enumerated()), id: \.offset) { _, item in
                    Text(item).fixedSize(horizontal: false, vertical: true)
                }
            }
            if feedback.improvements.isEmpty {
                Text("No correction was required.").foregroundStyle(Kit.secondary)
            } else {
                ForEach(Array(feedback.improvements.prefix(2).enumerated()), id: \.offset) { _, item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.category.rawValue.capitalized).font(.subheadline.weight(.semibold))
                        Text("“\(item.evidenceQuote)”").fixedSize(horizontal: false, vertical: true)
                        Text(item.explanation).fixedSize(horizontal: false, vertical: true)
                        if let revision = item.suggestedRevision { Text(revision).fixedSize(horizontal: false, vertical: true) }
                        if let hint = item.hint { Text(hint).fixedSize(horizontal: false, vertical: true) }
                        Text(item.retryPrompt).fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            ForEach(Array(feedback.limitations.enumerated()), id: \.offset) { _, item in
                Text(item).font(.footnote).foregroundStyle(Kit.secondary)
            }
        }
        .accessibilityIdentifier("communication.feedback")
    }

    private func labeled(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.subheadline.weight(.semibold))
            Text(value).fixedSize(horizontal: false, vertical: true)
        }
    }
}
