import SwiftUI

/// LR-06 local report. Kit/Status `41:1155` and a sheet with Cancel plus an explicit save.
/// Saving a report does not send it, correct the activity, or publish a replacement.
struct ActivityReportView: View {
    @Binding var session: GeneratedPracticeSession
    var policy: GenerationPolicy?
    var epoch: UUID?
    var background: LearnerPreferences.Background = .creativeAcademy
    var persist: ((GeneratedPracticeRecord) -> Bool)?
    @Environment(\.dismiss) private var dismiss
    @State private var issue: ActivityReportIssue?
    @State private var removing: UUID?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("This stays on this device. It is not sent to a provider, and it does not correct or publish the activity.")
                        .foregroundStyle(Kit.secondary).fixedSize(horizontal: false, vertical: true)
                    if let subject = session.reportSubject {
                        KitCard {
                            Text("Activity identity").font(.headline)
                            Text("Objective \(subject.objectiveID)")
                            Text("Version \(subject.contentVersion) · rubric \(subject.rubricVersion)")
                                .font(.subheadline).foregroundStyle(Kit.secondary)
                        }
                    } else {
                        AvailabilityCard(title: "Nothing to report", detail: "Open an activity before recording a report.", symbol: "exclamationmark.circle")
                    }
                    Picker("What looks wrong", selection: $issue) {
                        Text("Not chosen").tag(Optional<ActivityReportIssue>.none)
                        ForEach(ActivityReportIssue.allCases) { item in
                            Text(item.title).tag(Optional(item))
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("report.issue")
                    retentionCopy
                    if session.commitFailed {
                        Button("Retry saving changes") {
                            if session.persistChanges(expectedEpoch: epoch, using: persist) { dismiss() }
                        }.buttonStyle(.bordered).accessibilityIdentifier("report.save.retry")
                    }
                    if let refusal = session.lastRefusal {
                        AvailabilityCard(title: "Check this step", detail: refusal.message, symbol: "exclamationmark.circle")
                    } else if let report = session.working.reports.last {
                        AvailabilityCard(title: statusTitle(report.status), detail: statusDetail(report.status), symbol: "checkmark.circle")
                            .accessibilityIdentifier("report.status")
                    }
                    Button("Save on this device", action: save)
                        .buttonStyle(KitPrimaryButtonStyle())
                        .disabled(issue == nil || session.reportSubject == nil || policy?.accepted != true)
                        .accessibilityIdentifier("report.save")
                    if let report = session.working.reports.last(where: { $0.status == .pendingSave || $0.status == .recordedLocally }) {
                        Button("Remove report", role: .destructive, action: { removing = report.id })
                            .buttonStyle(.bordered).frame(maxWidth: .infinity, minHeight: 44)
                            .accessibilityIdentifier("report.delete")
                    }
                }
                .padding(20)
                .frame(maxWidth: 640, alignment: .leading)
            }
            .background(Kit.canvas(background))
            .foregroundStyle(Kit.ink)
            .navigationTitle("Report an activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: { dismiss() })
                        .accessibilityIdentifier("report.cancel")
                }
            }
            .alert("Remove local report?", isPresented: Binding(get: { removing != nil }, set: { if !$0 { removing = nil } })) {
                Button("Remove report", role: .destructive) {
                    if let id = removing {
                        _ = session.deleteReport(id: id)
                        if session.persistChanges(expectedEpoch: epoch, using: persist) { dismiss() }
                    }
                    removing = nil
                }.accessibilityIdentifier("report.delete.confirm")
                Button("Cancel", role: .cancel) { removing = nil }
            } message: { Text("This removes the local report. It does not change the activity or send a message.") }
            .onChange(of: epoch) { _, _ in removing = nil }
        }
    }

    private var retentionCopy: some View {
        let export = policy?.accepted == true && policy?.reportRetention.exportPermitted == true
            ? "Export of the activity identity is allowed by the current policy."
            : "Export is off. The report is not included in a transfer."
        let detail = policy?.accepted == true
            ? "Kept only for the approved retention period, then it expires on this device. \(export)"
            : "No report retention policy is approved here. You can remove an existing report, but cannot save a new one."
        return Text(detail)
            .font(.footnote).foregroundStyle(Kit.secondary).fixedSize(horizontal: false, vertical: true)
    }

    private func save() {
        guard let issue else { return }
        switch session.stageReport(issue: issue, policy: policy, now: .now) {
        case .failure:
            break
        case .success:
            if session.persistChanges(expectedEpoch: epoch, using: persist) { dismiss() }
        }
    }

    private func statusTitle(_ status: ActivityReportStatus) -> String {
        switch status {
        case .pendingSave: "On this screen only"
        case .recordedLocally: "Saved on this device"
        case .deleted: "Report removed"
        case .retentionExpired: "Report expired"
        }
    }

    private func statusDetail(_ status: ActivityReportStatus) -> String {
        switch status {
        case .pendingSave: "The learner record has not kept this report yet."
        case .recordedLocally: "It was not sent, and the activity was not changed."
        case .deleted: "The activity and its earlier attempt stay as they were."
        case .retentionExpired: "The report is no longer an open local record."
        }
    }
}
