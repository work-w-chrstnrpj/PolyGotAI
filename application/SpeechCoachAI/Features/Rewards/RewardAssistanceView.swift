import SwiftUI

/// Optional help for a few guided activities. Hints and worked examples are free; opening them changes nothing in XP or badges.
struct RewardAssistanceView: View {
    var storage: LearnerStorageController
    var context: String
    var hint: String
    var example: String
    @State private var shown: String?

    var body: some View {
        DisclosureGroup("Extra help") {
            VStack(alignment: .leading, spacing: 10) {
                Button("Hint") { shown = hint }.frame(minHeight: 44).accessibilityIdentifier("rewards.hint")
                Button("Example") { shown = example }.frame(minHeight: 44).accessibilityIdentifier("rewards.example")
                if let shown { Text(shown).fixedSize(horizontal: false, vertical: true).accessibilityIdentifier("rewards.help.result") }
            }
        }
        .onChange(of: context) { _, _ in shown = nil }
    }
}
