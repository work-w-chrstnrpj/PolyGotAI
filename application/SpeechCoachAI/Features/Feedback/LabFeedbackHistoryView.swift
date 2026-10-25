import SwiftUI

/// Saved online feedback, newest first. Shown from the Speech Lab only when something has been saved.
struct LabFeedbackHistoryView: View {
    var storage: LearnerStorageController
    @State private var records: [StoredLabFeedback] = []
    @State private var confirmClear = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                summaryCard
                ForEach(records) { record in
                    NavigationLink {
                        LabFeedbackRecordView(storage: storage, record: record, onChange: reload)
                    } label: {
                        KitCard {
                            KitContentRow(symbol: "text.bubble", title: record.title,
                                          detail: "\(record.mode.historyTitle) · \(record.createdAt.formatted(date: .abbreviated, time: .omitted))",
                                          showsChevron: true)
                        }
                    }.buttonStyle(.plain).accessibilityIdentifier("feedback.record")
                }
                if !records.isEmpty {
                    Button("Delete all", role: .destructive) { confirmClear = true }.accessibilityIdentifier("feedback.clear")
                }
            }.padding(20)
        }
        .background(Kit.canvas(storage.preferences.background))
        .navigationTitle("Feedback history")
        .confirmationDialog("Delete all saved feedback?", isPresented: $confirmClear, titleVisibility: .visible) {
            Button("Delete all", role: .destructive) { try? storage.repository?.clearLabFeedback(); reload() }
        }
        .onAppear(perform: reload)
        .onReceive(NotificationCenter.default.publisher(for: .labFeedbackChanged)) { _ in reload() }
    }

    @ViewBuilder private var summaryCard: some View {
        let summary = LabFeedbackHistorySummary(records: records)
        if summary.total > 0 {
            KitCard {
                Text("\(summary.total) saved · \(summary.lastTwoWeeks) in the last 2 weeks")
                    .font(.headline).accessibilityIdentifier("feedback.summary")
                if !summary.repeatedTips.isEmpty {
                    Text("Tips that came back").font(.subheadline.weight(.semibold))
                    ForEach(summary.repeatedTips, id: \.self) { Text($0).fixedSize(horizontal: false, vertical: true) }
                }
            }
        }
    }

    private func reload() { records = ((try? storage.repository?.labFeedbackHistory()) ?? []).sorted { $0.createdAt > $1.createdAt } }
}

struct LabFeedbackRecordView: View {
    var storage: LearnerStorageController
    var record: StoredLabFeedback
    var onChange: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                KitCard {
                    Text("What you said").font(.headline)
                    Text(record.transcript).fixedSize(horizontal: false, vertical: true).accessibilityIdentifier("feedback.transcript")
                }
                AIFeedbackCard(feedback: record.feedback)
                Button("Delete", role: .destructive) {
                    try? storage.repository?.removeLabFeedback(record.id)
                    onChange(); dismiss()
                }.accessibilityIdentifier("feedback.delete")
            }.padding(20)
        }
        .background(Kit.canvas(storage.preferences.background))
        .navigationTitle(record.title).navigationBarTitleDisplayMode(.inline)
    }
}
