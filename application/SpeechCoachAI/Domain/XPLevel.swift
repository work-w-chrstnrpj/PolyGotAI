import Foundation

/// The learner's level, from XP. Level 1 starts at 0 XP; each level needs a little more than the one before.
/// XP counts finished practice only. It is participation, not an English level.
struct XPLevel: Equatable {
    let level: Int
    /// XP earned since this level began.
    let xpIntoLevel: Int
    /// XP needed to finish this level.
    let xpForLevel: Int

    var fraction: Double { xpForLevel > 0 ? min(1, Double(xpIntoLevel) / Double(xpForLevel)) : 1 }
    var xpToNext: Int { max(0, xpForLevel - xpIntoLevel) }

    /// Total XP at which `level` begins: 0, 100, 300, 600, 1,000, 1,500 …
    static func threshold(for level: Int) -> Int { 50 * max(0, level - 1) * max(1, level) }

    init(xp: Int) {
        let xp = max(0, xp)
        var level = 1
        while Self.threshold(for: level + 1) <= xp { level += 1 }
        self.level = level
        xpIntoLevel = xp - Self.threshold(for: level)
        xpForLevel = Self.threshold(for: level + 1) - Self.threshold(for: level)
    }
}
