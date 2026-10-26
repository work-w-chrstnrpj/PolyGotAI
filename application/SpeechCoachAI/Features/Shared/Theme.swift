import SwiftUI
import UIKit
import os

/// One colour set per background (owner decision 2026-10-26: one accent per background, no separate picker).
/// Each colour has a light and a dark variant in the asset catalog.
nonisolated struct KitTheme: Equatable, Sendable {
    let background: LearnerPreferences.Background

    init(_ background: LearnerPreferences.Background) { self.background = background }

    static let academy = KitTheme(.creativeAcademy)

    /// The theme `Kit` colours resolve against. Set by `LearnerStorageController` whenever preferences load or change;
    /// `AppShell` rebuilds its content with `.id(background)` so every view picks up the new colours.
    static var current: KitTheme {
        get { storage.withLock { $0 } }
        set { storage.withLock { $0 = newValue } }
    }
    private static let storage = OSAllocatedUnfairLock(initialState: KitTheme.academy)

    var accent: Color { Color(assetName(.accent)) }
    var onAccent: Color { Color(assetName(.onAccent)) }
    var surface: Color { Color(assetName(.surface)) }
    var soft: Color { Color(assetName(.soft)) }
    var canvas: Color { Kit.canvas(background) }
    /// Series colours for charts, in order. The first is always the accent.
    var chart: [Color] { [accent, Color("ChartOchre"), Color("ChartRose")] }

    enum Role: Sendable { case accent, onAccent, surface, soft }

    func assetName(_ role: Role) -> String {
        let prefix: String = switch background {
        case .creativeAcademy: ""
        case .adventureAtlas: "Atlas"
        case .mixedMediaStudio: "Studio"
        }
        switch role {
        case .accent: return prefix.isEmpty ? "AccentColor" : prefix + "Accent"
        case .onAccent: return prefix + "OnAccent"
        case .surface: return prefix + "Surface"
        case .soft: return prefix + "Soft"
        }
    }
}

extension EnvironmentValues {
    /// The active theme. Prefer this in new views; `Kit` colours follow the same theme.
    @Entry var kitTheme: KitTheme = .academy
}

/// Design tokens. Theme-dependent colours resolve against `KitTheme.current` and the light or dark appearance.
enum Kit {
    static let ink = Color("Ink")
    static let secondary = Color("SecondaryInk")
    static let error = Color("Error")
    static var accent: Color { themed(.accent) }
    static var onAccent: Color { themed(.onAccent) }
    static var surface: Color { themed(.surface) }
    static var soft: Color { themed(.soft) }

    nonisolated static func canvas(_ background: LearnerPreferences.Background) -> Color {
        switch background {
        case .creativeAcademy: Color("Canvas")
        case .adventureAtlas: Color("AtlasCanvas")
        case .mixedMediaStudio: Color("StudioCanvas")
        }
    }

    /// Nonisolated: SwiftUI may resolve colours off the main thread, so the provider must not assume the main actor.
    nonisolated private static func themed(_ role: KitTheme.Role) -> Color {
        Color(uiColor: UIColor { @Sendable traits in
            let name = KitTheme.current.assetName(role)
            return UIColor(named: name, in: .main, compatibleWith: traits) ?? .systemTeal
        })
    }

    /// Spacing scale (points).
    enum Space {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 12
        static let l: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    /// Corner radii (points).
    enum Radius {
        static let control: CGFloat = 14
        static let card: CGFloat = 18
    }

    /// Text roles. All scale with Dynamic Type.
    enum Fonts {
        static let hero = Font.largeTitle.bold()
        static let title = Font.title2.bold()
        static let section = Font.title3.bold()
        static let rowTitle = Font.headline
        static let body = Font.body
        static let detail = Font.subheadline
        static let caption = Font.caption.weight(.semibold)
        static let stat = Font.system(.title, design: .rounded).weight(.bold).monospacedDigit()
    }
}
