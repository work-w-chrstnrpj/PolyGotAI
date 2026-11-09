import SwiftUI

// `Kit` tokens and `KitTheme` live in Theme.swift.

/// Primary action with semantic theme colours and a visible pressed state.
struct KitPrimaryButtonStyle: ButtonStyle {
    @Environment(\.kitTheme) private var theme
    @Environment(\.isEnabled) private var enabled
    @Environment(\.colorScheme) private var scheme
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.headline)
            .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, minHeight: 24)
            .padding(.horizontal, 18).padding(.vertical, 15)
            .foregroundStyle(enabled ? theme.onAccent : Kit.secondary)
            .background {
                // Solid fill plus a light top sheen: depth that never darkens the fill under the label.
                RoundedRectangle(cornerRadius: Kit.Radius.control, style: .continuous)
                    .fill(enabled ? theme.accent : theme.soft)
                    .overlay {
                        if enabled && scheme == .light {
                            RoundedRectangle(cornerRadius: Kit.Radius.control, style: .continuous)
                                .fill(LinearGradient(colors: [.white.opacity(0.14), .clear], startPoint: .top, endPoint: .center))
                        }
                    }
                    // Glow in light mode only: a light accent halo on a dark canvas reads as low contrast.
                    .shadow(color: enabled && scheme == .light ? theme.accent.opacity(0.28) : .clear, radius: 10, y: 5)
            }
            .contentShape(RoundedRectangle(cornerRadius: Kit.Radius.control, style: .continuous))
            .kitPressEffect(configuration.isPressed)
    }
}

extension View {
    /// The shared pressed state: a small, springy shrink and a slight dim.
    func kitPressEffect(_ pressed: Bool) -> some View {
        scaleEffect(pressed ? 0.97 : 1).opacity(pressed ? 0.88 : 1).animation(Kit.Motion.press, value: pressed)
    }

    /// The card look used across the app: surface fill, continuous corners, a soft shadow in light mode
    /// and a hairline edge in dark mode (where shadows do not read).
    func kitSurface(radius: CGFloat = Kit.Radius.card, fill: Color = Kit.surface) -> some View {
        modifier(KitSurfaceModifier(radius: radius, fill: fill))
    }
}

struct KitSurfaceModifier: ViewModifier {
    @Environment(\.colorScheme) private var scheme
    var radius: CGFloat
    var fill: Color
    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        content
            .background {
                shape.fill(fill)
                    .shadow(color: .black.opacity(scheme == .dark ? 0 : 0.05), radius: 14, y: 6)
                    .shadow(color: .black.opacity(scheme == .dark ? 0 : 0.04), radius: 1.5, y: 1)
            }
            .overlay { shape.strokeBorder(scheme == .dark ? Kit.border.opacity(0.45) : Kit.ink.opacity(0.05), lineWidth: 1) }
    }
}

/// A symbol on a tinted, rounded square: the leading mark of rows and tiles.
struct IconBadge: View {
    var symbol: String
    var tint: Color = Kit.accent
    @ScaledMetric(relativeTo: .title3) private var side = 38.0
    var body: some View {
        Image(systemName: symbol).font(.system(size: min(side, 52) * 0.47, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: min(side, 52), height: min(side, 52))
            .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: min(side, 52) * 0.3, style: .continuous))
            .accessibilityHidden(true)
    }
}

/// A rounded progress bar with a gradient fill that springs to its value. Hidden from VoiceOver;
/// callers speak the value in adjacent text or their own label.
struct KitProgressBar: View {
    var value: Double
    var tint: Color = Kit.accent
    var height: CGFloat = 8
    private var fraction: Double { value.isFinite ? min(max(value, 0), 1) : 0 }
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(tint.opacity(0.16))
                Capsule().fill(LinearGradient(colors: [tint.opacity(0.75), tint], startPoint: .leading, endPoint: .trailing))
                    .frame(width: fraction > 0 ? max(height, proxy.size.width * fraction) : 0)
            }
        }
        .frame(height: height)
        .animation(Kit.Motion.fill, value: fraction)
        .accessibilityHidden(true)
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
            IconBadge(symbol: symbol).dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline).foregroundStyle(Kit.ink)
                Text(detail).font(.subheadline).foregroundStyle(Kit.secondary)
            }.frame(maxWidth: .infinity, alignment: .leading)
            if showsChevron { Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(Kit.secondary)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge).accessibilityHidden(true) }
        }.padding(.vertical, 6).frame(minHeight: 44)
    }
}

struct KitCard<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 8, content: content)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .kitSurface()
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

/// The one focal card of a screen: an eyebrow chip, a large title, optional coach artwork and progress,
/// on a surface with a soft accent glow. Callers supply native Buttons or NavigationLinks for actions.
struct HeroCard<Content: View>: View {
    @Environment(\.kitTheme) private var theme
    @Environment(\.dynamicTypeSize) private var textSize
    var eyebrow: String
    var title: String
    var detail: String? = nil
    /// Coach or illustration asset shown beside the title.
    var artwork: String? = nil
    /// 0...1; shows a progress bar under the detail line.
    var progress: Double? = nil
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    KitEyebrow(text: eyebrow)
                    Text(title).font(.title.bold()).foregroundStyle(Kit.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    if let detail {
                        Text(detail).font(.body).foregroundStyle(Kit.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if let artwork, !textSize.isAccessibilitySize {
                    CoachArtwork(name: artwork).frame(width: 84, height: 84)
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                }
            }
            if let progress { KitProgressBar(value: progress) }
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(alignment: .topTrailing) {
            // A soft glow in the theme colour gives the card its focus without a hard stripe.
            RadialGradient(colors: [theme.accent.opacity(0.16), .clear], center: .topTrailing, startRadius: 0, endRadius: 260)
                .accessibilityHidden(true)
        }
        .clipShape(RoundedRectangle(cornerRadius: Kit.Radius.hero, style: .continuous))
        .kitSurface(radius: Kit.Radius.hero)
    }
}

struct StatTile: View {
    @Environment(\.kitTheme) private var theme
    var title: String
    var value: String
    var symbol: String
    var tint: Color? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            IconBadge(symbol: symbol, tint: tint ?? theme.accent).dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            Text(value).font(Kit.Fonts.stat)
                .foregroundStyle(Kit.ink).fixedSize(horizontal: false, vertical: true)
            Text(title).font(.subheadline).foregroundStyle(Kit.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .kitSurface()
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
                Circle().stroke(theme.accent.opacity(0.14), lineWidth: 10)
                Circle().trim(from: 0, to: fraction)
                    .stroke(AngularGradient(colors: [theme.accent.opacity(0.6), theme.accent], center: .center,
                                            startAngle: .degrees(0), endAngle: .degrees(360 * max(fraction, 0.01))),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(Kit.Motion.fill, value: fraction)
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
        .padding(.horizontal, 8).padding(.vertical, 12)
        // Fill the grid row so tiles in one row share a height.
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .kitSurface()
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
            .background(theme.soft, in: RoundedRectangle(cornerRadius: Kit.Radius.control, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: Kit.Radius.control, style: .continuous))
            .kitPressEffect(configuration.isPressed)
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
            .kitPressEffect(configuration.isPressed)
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
            .kitSurface()
            .contentShape(Rectangle())
        }
        .accessibilityLabel(caption)
        .accessibilityValue(value)
        .accessibilityIdentifier(identifier)
    }
}

/// Tappable cards (NavigationLinks whose label is a KitCard): the plain look plus the shared pressed state.
struct KitCardLinkStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.kitPressEffect(configuration.isPressed)
    }
}

extension ButtonStyle where Self == KitCardLinkStyle {
    static var kitCard: KitCardLinkStyle { KitCardLinkStyle() }
}

/// A small uppercase label on a tinted capsule: what a card is about ("Word of the day", "Rank A1 · Course").
struct KitEyebrow: View {
    var text: String
    var tint: Color = Kit.accent
    var body: some View {
        Text(text).font(.caption.weight(.bold)).textCase(.uppercase).kerning(0.6)
            .foregroundStyle(tint)
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(tint.opacity(0.12), in: Capsule())
    }
}
