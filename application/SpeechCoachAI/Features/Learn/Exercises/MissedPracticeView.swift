import SwiftUI

/// A second try at the exercises answered wrongly. Nothing here is saved: the first try stays the lesson's record.
struct MissedPracticeView: View {
    let activities: [CurriculumActivity]
    var onPlayClip: (String) -> Void = { _ in }
    @State private var index = 0
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if index < activities.count {
                    ExerciseActivityView(
                        activity: activities[index], progress: Double(index) / Double(activities.count),
                        positionText: "\(index + 1) of \(activities.count)", isLast: index == activities.count - 1,
                        onPlayClip: onPlayClip, onSubmit: { _ in true }, onContinue: { index += 1 })
                        .id(activities[index].id)
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.seal.fill").font(.system(size: 56)).foregroundStyle(Kit.accent)
                        Text("Nice work.").font(.title.bold())
                        Button("Done") { dismiss() }.buttonStyle(KitPrimaryButtonStyle()).padding(.horizontal, 24)
                            .accessibilityIdentifier("missed.done")
                    }
                }
            }
            .background(Color("Canvas"))
            .navigationTitle("Try again").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
        }.tint(Kit.accent)
    }
}
