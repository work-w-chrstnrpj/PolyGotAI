import SwiftUI
import Testing
import UIKit
@testable import SpeechCoachAI

/// Each background has its own accent, surface and soft colours, and `Kit` follows the current theme.
@MainActor @Suite(.serialized)
struct KitThemeTests {
    private func rgb(_ color: Color, dark: Bool = false) -> [Int] {
        let traits = UITraitCollection(userInterfaceStyle: dark ? .dark : .light)
        let resolved = UIColor(color).resolvedColor(with: traits)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        resolved.getRed(&r, green: &g, blue: &b, alpha: &a)
        return [r, g, b].map { Int(($0 * 255).rounded()) }
    }

    @Test func everyThemeColourExistsInTheAssetCatalog() {
        for background in LearnerPreferences.Background.allCases {
            let theme = KitTheme(background)
            for role in [KitTheme.Role.accent, .onAccent, .surface, .soft] {
                #expect(UIColor(named: theme.assetName(role)) != nil, "\(background) \(role)")
            }
        }
        #expect(UIColor(named: "ChartOchre") != nil)
        #expect(UIColor(named: "ChartRose") != nil)
    }

    @Test func accentsDifferPerThemeInLightAndDark() {
        for dark in [false, true] {
            let accents = LearnerPreferences.Background.allCases.map { rgb(KitTheme($0).accent, dark: dark) }
            #expect(Set(accents.map { $0.description }).count == accents.count)
        }
    }

    @Test func kitAccentFollowsTheCurrentTheme() {
        let saved = KitTheme.current
        defer { KitTheme.current = saved }
        for background in LearnerPreferences.Background.allCases {
            KitTheme.current = KitTheme(background)
            #expect(rgb(Kit.accent) == rgb(KitTheme(background).accent))
            #expect(rgb(Kit.surface, dark: true) == rgb(KitTheme(background).surface, dark: true))
        }
    }
}
