import SwiftUI

// `PracticeArea` (Lesson, Lexicon, Lab) lives in Domain/PracticeLog.swift.

/// Practice screens publish their area; the app shell reads it. While any is present the bottom tab bar is hidden
/// (iPad floating bar and iPhone system bar), see ADR-0011.
struct PracticeAreaKey: PreferenceKey {
    static var defaultValue: [PracticeArea] = []
    static func reduce(value: inout [PracticeArea], nextValue: () -> [PracticeArea]) { value += nextValue() }
}

extension View {
    /// Marks this screen as a practice screen in `area`: the tab bar hides while it is open.
    /// Declare it exactly once per screen.
    func practiceScreen(area: PracticeArea) -> some View {
        preference(key: PracticeAreaKey.self, value: [area])
    }
}
