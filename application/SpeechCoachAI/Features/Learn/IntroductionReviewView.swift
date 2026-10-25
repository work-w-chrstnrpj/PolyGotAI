import SwiftUI

struct IntroductionActivityReview: View {
    var guide: IntroductionReviewGuide
    var review: IntroductionReviewGuide.Activity

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Other valid wording").font(.headline)
            ForEach(review.alternatives, id: \.self) { Text($0).fixedSize(horizontal: false, vertical: true) }
            Text(review.explanation).foregroundStyle(Kit.secondary)
            Text(review.boundary).font(.footnote).foregroundStyle(Kit.secondary)
            Text(guide.notice).font(.footnote).foregroundStyle(Kit.secondary)
            if review.id == "self-review" {
                DisclosureGroup("How to review an introduction") {
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(guide.selfReview, id: \.self) { Text($0) }
                        ForEach(guide.dimensions) { dimension in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(dimension.title).font(.headline)
                                ForEach(dimension.anchors, id: \.self) { Text($0).font(.callout) }
                                Text("Not assessed: \(dimension.notAssessed)").font(.footnote).foregroundStyle(Kit.secondary)
                            }
                        }
                        Text(guide.independentCriterion).font(.footnote).foregroundStyle(Kit.secondary)
                    }
                }
                .accessibilityIdentifier("intro.review.rubric")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("intro.review.\(review.id)")
    }
}

struct IntroductionPackReview: View {
    var pack: IntroductionReviewGuide.Pack

    var body: some View {
        DisclosureGroup("What this practice checks") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Method").font(.headline)
                ForEach(pack.method, id: \.self) { Text($0) }
                Text("Review priorities").font(.headline)
                ForEach(pack.priorities, id: \.self) { Text($0) }
                Text(pack.criteria)
                Text(pack.boundary).font(.footnote).foregroundStyle(Kit.secondary)
                Text("Draft personal-use guidance; no score or qualified assessment is produced.")
                    .font(.footnote).foregroundStyle(Kit.secondary)
            }
        }
        .accessibilityIdentifier("intro.pack.review")
    }
}
