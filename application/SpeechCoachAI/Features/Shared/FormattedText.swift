import SwiftUI

/// Lesson text with light structure (2026-10-30): paragraphs split by a blank line, lines starting with "- " as bullets,
/// and **bold** for key forms. Plain text without any of these shows as one paragraph, as before.
struct FormattedText: View {
    enum Block: Equatable {
        case paragraph(String)
        case bullets([String])
    }

    var text: String
    var font: Font = .body
    var spacing: CGFloat = Kit.Space.m
    /// Put on every block, so tests and VoiceOver find the text by the same identifier as before.
    var identifier: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            ForEach(Array(Self.blocks(text).enumerated()), id: \.offset) { _, block in
                switch block {
                case .paragraph(let value):
                    styled(Text(Self.inline(value)))
                case .bullets(let items):
                    VStack(alignment: .leading, spacing: Kit.Space.s) {
                        ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                            HStack(alignment: .firstTextBaseline, spacing: Kit.Space.s) {
                                Text("•").font(font.bold()).foregroundStyle(Kit.accent).accessibilityHidden(true)
                                styled(Text(Self.inline(item)))
                            }
                        }
                    }
                    .padding(.leading, Kit.Space.xs)
                }
            }
        }
    }

    private func styled(_ text: Text) -> some View {
        text.font(font).fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityIdentifier(identifier ?? "")
    }

    /// Splits the text into paragraphs and runs of bullet lines.
    static func blocks(_ text: String) -> [Block] {
        var out: [Block] = []
        for chunk in text.components(separatedBy: "\n\n") {
            var paragraph: [String] = []
            var bullets: [String] = []
            func flushParagraph() {
                let joined = paragraph.joined(separator: " ").trimmingCharacters(in: .whitespaces)
                if !joined.isEmpty { out.append(.paragraph(joined)) }
                paragraph = []
            }
            func flushBullets() {
                if !bullets.isEmpty { out.append(.bullets(bullets)) }
                bullets = []
            }
            for line in chunk.components(separatedBy: "\n") {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.hasPrefix("- ") {
                    flushParagraph()
                    bullets.append(String(trimmed.dropFirst(2)).trimmingCharacters(in: .whitespaces))
                } else if !trimmed.isEmpty {
                    flushBullets()
                    paragraph.append(trimmed)
                }
            }
            flushParagraph()
            flushBullets()
        }
        return out
    }

    /// **bold** and other inline markdown; the raw text when it does not parse.
    static func inline(_ value: String) -> AttributedString {
        (try? AttributedString(markdown: value, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))) ?? AttributedString(value)
    }
}
