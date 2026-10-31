import SwiftUI

// `Kit` tokens and `KitTheme` live in Theme.swift.

/// Primary action with semantic theme colours and a visible pressed state.
struct KitPrimaryButtonStyle: ButtonStyle {
    @Environment(\.kitTheme) private var theme
    @Environment(\.isEnabled) private var enabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.headline)
            .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, minHeight: 24)
            .padding(.horizontal, 18).padding(.vertical, 15)
            .foregroundStyle(enabled ? theme.onAccent : Kit.secondary)
            .background(enabled ? theme.accent : theme.soft, in: RoundedRectangle(cornerRadius: 14))
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
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge).frame(width: 30).accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.headline).foregroundStyle(Kit.ink)
                Text(detail).font(.subheadline).foregroundStyle(Kit.secondary)
            }.frame(maxWidth: .infinity, alignment: .leading)
            if showsChevron { Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(Kit.secondary)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge).accessibilityHidden(true) }
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
                Image(systemName: "person.crop.square").font(.largeTitle).foregroundStyle(Kit.accent)
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

// MARK: - Phase 7 components

/// A content container; callers supply native Buttons or NavigationLinks for actions.
struct HeroCard<Content: View>: View {
    @Environment(\.kitTheme) private var theme
    var eyebrow: String
    var title: String
    var detail: String? = nil
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(eyebrow).font(.subheadline.weight(.semibold)).foregroundStyle(theme.accent)
            Text(title).font(Kit.Fonts.title).foregroundStyle(Kit.ink)
                .fixedSize(horizontal: false, vertical: true)
            if let detail {
                Text(detail).font(.body).foregroundStyle(Kit.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(theme.surface, in: RoundedRectangle(cornerRadius: Kit.Radius.card + 4))
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2).fill(theme.accent)
                .frame(width: 4).padding(.vertical, 22).accessibilityHidden(true)
        }
    }
}

struct StatTile: View {
    @Environment(\.kitTheme) private var theme
    var title: String
    var value: String
    var symbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: symbol).font(.title3.weight(.semibold))
                .foregroundStyle(theme.accent).accessibilityHidden(true)
            Text(value).font(Kit.Fonts.title).monospacedDigit()
                .foregroundStyle(Kit.ink).fixedSize(horizontal: false, vertical: true)
            Text(title).font(.subheadline).foregroundStyle(Kit.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(theme.surface, in: RoundedRectangle(cornerRadius: Kit.Radius.card))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(value)
    }
}

/// A determinate ring with a single VoiceOver value; text remains readable at large sizes.
struct ProgressRing: View {
    @Environment(\.kitTheme) private var theme
    @ScaledMetric(relativeTo: .title2) private var diameter = 112.0
    var progress: Double
    var title: String
    var detail: String
    private var fraction: Double { progress.isFinite ? min(max(progress, 0), 1) : 0 }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().stroke(theme.soft, lineWidth: 9)
                Circle().trim(from: 0, to: fraction)
                    .stroke(theme.accent, style: StrokeStyle(lineWidth: 9, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text(title).font(Kit.Fonts.title).foregroundStyle(Kit.ink)
                    .multilineTextAlignment(.center).padding(14)
            }
            .frame(width: diameter, height: diameter)
            .padding(5)
            Text(detail).font(.subheadline).foregroundStyle(Kit.secondary)
                .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title), \(detail)")
        .accessibilityValue(fraction.formatted(.percent.precision(.fractionLength(0))))
    }
}

/// Artwork and an earned badge title; navigation belongs to the enclosing control.
struct BadgeTile<Artwork: View>: View {
    @Environment(\.kitTheme) private var theme
    var title: String
    var detail: String? = nil
    @ViewBuilder var artwork: () -> Artwork

    var body: some View {
        VStack(spacing: 8) {
            artwork().frame(height: 80).accessibilityHidden(true)
            Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(Kit.ink)
                .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
            if let detail {
                Text(detail).font(.caption).foregroundStyle(Kit.secondary)
                    .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        // Fill the grid row so tiles in one row share a height.
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(theme.surface, in: RoundedRectangle(cornerRadius: Kit.Radius.card))
        .accessibilityElement(children: .combine)
    }
}

/// The trailing slot accepts a native Button or NavigationLink, preserving its semantics.
struct SectionHeader<Action: View>: View {
    @Environment(\.dynamicTypeSize) private var textSize
    var title: String
    @ViewBuilder var action: () -> Action

    var body: some View {
        let layout = textSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 4))
            : AnyLayout(HStackLayout(alignment: .center, spacing: 12))
        layout {
            Text(title).font(Kit.Fonts.section).foregroundStyle(Kit.ink)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
            action().font(.subheadline.weight(.semibold))
                .frame(minWidth: 44, minHeight: 44).contentShape(Rectangle())
        }
    }
}

extension SectionHeader where Action == EmptyView {
    init(title: String) {
        self.title = title
        self.action = { EmptyView() }
    }
}

struct KitSecondaryButtonStyle: ButtonStyle {
    @Environment(\.kitTheme) private var theme
    @Environment(\.isEnabled) private var enabled
    /// False keeps the button its natural width (icon buttons beside a primary action).
    var fills = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.headline)
            .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: fills ? .infinity : nil, minHeight: 24)
            .padding(.horizontal, 18).padding(.vertical, 15)
            .foregroundStyle(enabled ? theme.accent : Kit.secondary)
            .background(theme.soft, in: RoundedRectangle(cornerRadius: Kit.Radius.control))
            .contentShape(RoundedRectangle(cornerRadius: Kit.Radius.control))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

/// A selectable chip (coach stages, video topics). Selected: soft fill with an accent outline.
struct KitChipStyle: ButtonStyle {
    var selected: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.headline).fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 16).padding(.vertical, 10).frame(minHeight: 44)
            .foregroundStyle(Kit.ink)
            .background(selected ? Kit.soft : Kit.surface, in: Capsule())
            .overlay(Capsule().stroke(selected ? Kit.accent : .clear))
            .contentShape(Capsule())
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

/// Text input that sits on a card: soft fill, no system border, so fields look the same in light and dark.
struct KitFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 14).padding(.vertical, 12).frame(minHeight: 44)
            .background(Kit.soft, in: RoundedRectangle(cornerRadius: Kit.Radius.control - 2))
            .foregroundStyle(Kit.ink)
    }
}

/// A quiet in-card action (Save name, Edit, Discard): accent text, 44-point target, no fill.
struct KitTextButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var enabled
    var role: ButtonRole? = nil
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.subheadline.weight(.semibold))
            .foregroundStyle(role == .destructive ? Kit.error : (enabled ? Kit.accent : Kit.secondary))
            .frame(minHeight: 44).contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

#if DEBUG
/// Synthetic component gallery only; no storage, provider calls or learner data.
struct DesignSystemPreviewStub: View {
    @Environment(\.kitTheme) private var theme
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionHeader(title: "Your practice") { Button("See all") {} }
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 20) { stats }
                    VStack(spacing: 20) { stats }
                }
                HeroCard(eyebrow: "Rank A1", title: "Everyday conversations", detail: "Introduce yourself and meet someone new.") {
                    Button("Continue") {}.buttonStyle(KitPrimaryButtonStyle())
                }
                SectionHeader(title: "Recent badges")
                HStack(alignment: .top) {
                    BadgeTile(title: "First lesson", detail: "Earned today") {
                        Image(systemName: "rosette").resizable().scaledToFit().foregroundStyle(theme.accent)
                    }
                    BadgeTile(title: "Word explorer") {
                        Image(systemName: "book.closed").resizable().scaledToFit().foregroundStyle(theme.accent)
                    }
                }
                Button("Practice history") {}.buttonStyle(KitSecondaryButtonStyle())
                Button("Continue") {}.buttonStyle(KitPrimaryButtonStyle()).disabled(true)
            }.padding(20).frame(maxWidth: 680).frame(maxWidth: .infinity)
        }
        .background(theme.canvas).tint(theme.accent)
    }

    @ViewBuilder private var stats: some View {
        ProgressRing(progress: 0.65, title: "Level 2", detail: "130 XP")
        StatTile(title: "Day streak", value: "7", symbol: "flame")
    }
}

#Preview("Components · light") { DesignSystemPreviewStub() }
#Preview("Components · dark") { DesignSystemPreviewStub().preferredColorScheme(.dark) }
#Preview("Components · large text") {
    DesignSystemPreviewStub().environment(\.dynamicTypeSize, .accessibility3)
}
#endif

#if DEBUG
#Preview("Components · Atlas") {
    DesignSystemPreviewStub().environment(\.kitTheme, KitTheme(.adventureAtlas))
}
#Preview("Components · Studio dark") {
    DesignSystemPreviewStub().environment(\.kitTheme, KitTheme(.mixedMediaStudio)).preferredColorScheme(.dark)
}
#endif

/// Wraps the content of a `List` or `Form` so every row sits on the card colour instead of the system grey.
struct KitRows<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View { Group(content: content).listRowBackground(Kit.surface) }
}

/// A labelled dropdown (Videos topic, coach stage): a small caption, the current choice and an up-down chevron.
/// Tapping opens the menu given in `items` (usually a Picker, so the current choice shows a checkmark).
struct KitDropdown<Items: View>: View {
    var caption: String
    var value: String
    var identifier: String
    @ViewBuilder var items: () -> Items

    var body: some View {
        Menu { items() } label: {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(caption).font(.caption).foregroundStyle(Kit.secondary)
                    Text(value).font(.headline).foregroundStyle(Kit.ink).multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.up.chevron.down").font(.subheadline).foregroundStyle(Kit.accent).accessibilityHidden(true)
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            .frame(minHeight: 44)
            .background(Kit.surface, in: RoundedRectangle(cornerRadius: Kit.Radius.card, style: .continuous))
            .contentShape(Rectangle())
        }
        .accessibilityLabel(caption)
        .accessibilityValue(value)
        .accessibilityIdentifier(identifier)
    }
}
