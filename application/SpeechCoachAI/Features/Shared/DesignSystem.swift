import SwiftUI

enum Kit {
    static let ink = Color("Ink")
    static let secondary = Color("SecondaryInk")
    static let surface = Color("Surface")
    static let soft = Color("Soft")
    static let accent = Color("AccentColor")
    static let error = Color("Error")
    static func canvas(_ background: LearnerPreferences.Background) -> Color {
        switch background {
        case .creativeAcademy: Color("Canvas")
        case .adventureAtlas: Color("AtlasCanvas")
        case .mixedMediaStudio: Color("StudioCanvas")
        }
    }
}

/// Native adaptation of the existing Page 1 primary button; no new color tokens.
struct KitPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var enabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.headline)
            .frame(maxWidth: .infinity, minHeight: 24)
            .padding(.horizontal, 18).padding(.vertical, 15)
            .foregroundStyle(enabled ? Color("OnAccent") : Kit.secondary)
            .background(enabled ? Kit.accent : Kit.soft, in: RoundedRectangle(cornerRadius: 14))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

/// Kit/Content row 41:1105: a readable title, supporting detail, and an optional next action.
struct KitContentRow: View {
    var symbol: String
    var title: String
    var detail: String
    var showsChevron = false
    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: symbol).font(.title3).foregroundStyle(Kit.accent)
                .frame(width: 30).accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.headline).foregroundStyle(Kit.ink)
                Text(detail).font(.subheadline).foregroundStyle(Kit.secondary)
            }.frame(maxWidth: .infinity, alignment: .leading)
            if showsChevron { Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(Kit.secondary).accessibilityHidden(true) }
        }.padding(.vertical, 12).frame(minHeight: 44)
    }
}

struct KitCard<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 8, content: content)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Kit.surface, in: RoundedRectangle(cornerRadius: 18))
    }
}

/// Kit/Status 41:1155 adapted to native text and recovery actions.
struct AvailabilityCard: View {
    @Environment(\.dynamicTypeSize) private var textSize
    var title: String
    var detail: String
    var symbol = "clock"
    var body: some View {
        KitCard {
            if textSize.isAccessibilitySize {
                Image(systemName: symbol).font(.title3).accessibilityHidden(true)
                Text(title).font(.headline).fixedSize(horizontal: false, vertical: true)
            } else { Label(title, systemImage: symbol).font(.headline) }
            Text(detail).font(.body).foregroundStyle(Kit.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}

struct CoachArtwork: View {
    let name: String?
    var body: some View {
        Group {
            if let name {
                Image(name).resizable().scaledToFit()
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "pencil.and.outline").font(.largeTitle)
                    Text("Artwork coming later").font(.caption)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Kit.soft)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .accessibilityHidden(true) // Role/title is expressed in adjacent native text.
    }
}

extension LearnerPreferences.Background {
    var title: String {
        switch self {
        case .creativeAcademy: "Creative Academy"
        case .adventureAtlas: "Adventure Atlas"
        case .mixedMediaStudio: "Mixed-Media Studio"
        }
    }
    var previewArtwork: String {
        switch self {
        case .creativeAcademy: "BackgroundAcademyPreview"
        case .adventureAtlas: "BackgroundAtlasPreview"
        case .mixedMediaStudio: "BackgroundStudioPreview"
        }
    }
}

extension LearnerPreferences.Appearance {
    var title: String { rawValue.capitalized }
    var colorScheme: ColorScheme? {
        switch self { case .system: nil; case .light: .light; case .dark: .dark }
    }
}

extension LearnerPreferences.Coach {
    var title: String {
        switch self {
        case .elephantTeacher: "Elephant Teacher"
        case .foxJournalist: "Fox Journalist"
        case .owlGrammarian: "Owl Grammarian"
        case .bearLibrarian: "Bear Librarian"
        case .tigerBusinessProfessional: "Tiger Business Professional"
        case .parrotSpeaker: "Parrot Speaker"
        case .creativeWriter: "Creative Writer"
        }
    }
    var portrait: String? {
        switch self {
        case .elephantTeacher: "CoachTeacher"
        case .foxJournalist: "CoachJournalist"
        case .owlGrammarian: "CoachGrammarian"
        case .bearLibrarian: "CoachLibrarian"
        case .tigerBusinessProfessional: "CoachBusiness"
        case .parrotSpeaker: "CoachSpeaker"
        case .creativeWriter: nil
        }
    }
}
