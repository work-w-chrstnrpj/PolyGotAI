import SwiftUI

struct LessonReadingPage: View {
    let section: LessonReading
    let index: Int
    let total: Int
    let coach: TrackCoach?

    var body: some View {
        VStack(alignment: .leading, spacing: Kit.Space.l) {
            HStack {
                Text("Read · \(index + 1) of \(total)").font(.subheadline.weight(.semibold)).foregroundStyle(Kit.secondary)
                    .accessibilityIdentifier("lesson.reading.position")
                Spacer()
                if let coach { Image(systemName: coach.symbol).foregroundStyle(Kit.accent).accessibilityLabel(coach.title).accessibilityIdentifier("lesson.host") }
            }
            Text(section.heading).font(Kit.Fonts.title).fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader).accessibilityIdentifier("lesson.reading.heading")
            FormattedText(text: section.explanation, identifier: "lesson.reading.explanation")
            Text(section.examples.count == 1 ? "Example" : "Examples").font(.headline).accessibilityAddTraits(.isHeader)
            ForEach(Array(section.examples.enumerated()), id: \.offset) { _, example in
                KitCard {
                    Text(example.prompt).fixedSize(horizontal: false, vertical: true)
                    Text(example.answer).font(.body.bold()).foregroundStyle(Kit.accent)
                        .fixedSize(horizontal: false, vertical: true).accessibilityIdentifier("lesson.reading.example")
                    Text(example.explanation).font(.callout).foregroundStyle(Kit.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }.accessibilityElement(children: .contain).accessibilityIdentifier("lesson.reading.page")
    }
}
