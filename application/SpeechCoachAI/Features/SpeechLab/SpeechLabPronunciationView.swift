import SwiftUI

/// Pronunciation: the sounds of English (Phonetics) and saying them clearly (Articulation) behind one Lab entry.
struct SpeechLabPronunciationView: View {
    var storage: LearnerStorageController
    var body: some View {
        SpeechLabPage(storage: storage, title: "Pronunciation") {
            Text("Hear the sounds. Say them clearly.").foregroundStyle(Kit.secondary).lineLimit(1).minimumScaleFactor(0.7)
            NavigationLink {
                SpeechLabPhoneticsView(storage: storage)
            } label: {
                KitCard { KitContentRow(symbol: "character.phonetic", title: "Sounds", detail: "Meet the sounds", showsChevron: true) }
            }.buttonStyle(.plain).accessibilityIdentifier("pronunciation.sounds")
            NavigationLink {
                SpeechLabArticulationView(storage: storage)
            } label: {
                KitCard { KitContentRow(symbol: "mouth", title: "Clear speech", detail: "Make sounds clear", showsChevron: true) }
            }.buttonStyle(.plain).accessibilityIdentifier("pronunciation.clear")
        }
    }
}
