import Foundation
import Testing
@testable import SpeechCoachAI

struct VocabularyRecallTests {
    @Test func meaningStaysHiddenUntilRevealAndAgainIsAMiss() throws {
        var draft = RecallDraft()
        draft.typed = "  a list of dishes  "
        var hidden = draft
        var log = VocabularyRecallLog(attempts: [])
        #expect(throws: VocabularyRecallError.stillHidden) {
            try log.record(card: card, rating: .good, draft: hidden, now: date(1), sourceEventID: UUID())
        }
        draft.reveal()
        draft.typed = "changed after reveal"
        #expect(draft.firstResponse == "a list of dishes")
        let saved = try log.record(card: card, rating: .again, draft: draft, now: date(1), sourceEventID: UUID())
        #expect(saved.succeeded == false)
        #expect(saved.modality == "text")
        #expect(saved.typedAttempt == "a list of dishes")
        let hard = try log.record(card: card, rating: .hard, draft: RecallDraft(typed: "", revealed: true), now: date(2), sourceEventID: UUID())
        #expect(hard.succeeded)
        #expect(hard.modality == "selfCheck")
        #expect(hard.typedAttempt == nil)
    }

    @Test func optionalModesKeepTypedAndReportedSpeechSeparate() throws {
        var log = VocabularyRecallLog(attempts: [])
        for mode in RecallMode.allCases {
            var draft = RecallDraft(typed: "a list of dishes", mode: mode)
            draft.reveal()
            let result = try log.record(card: card, rating: .hard, draft: draft, now: date(1), sourceEventID: draft.sourceEventID)
            #expect(result.modality == (mode == .say ? "spokenSelfCheck" : mode == .write ? "text" : "selfCheck"))
            #expect(result.typedAttempt == (mode == .write ? "a list of dishes" : nil))
            #expect(result.succeeded)
        }
    }

    @Test func olderOpenRecallDecodesWithoutInventingSpeechOrRating() throws {
        let data = Data(#"{"itemId":"personal-1","senseId":"sense-1","typed":"a list","revealed":true,"firstResponse":"a list","hinted":true}"#.utf8)
        let old = try JSONDecoder().decode(OpenRecall.self, from: data)
        #expect(old.sourceEventID == nil)
        #expect(old.mode == nil)
        let draft = RecallDraft(old)
        #expect(draft.mode == .write)
        #expect(draft.firstResponse == "a list")
        #expect(draft.hinted)
    }

    private var card: VocabularyEnrollment {
        VocabularyEnrollment(itemId: "personal-1", senseId: "sense-1", lemma: "menu", lessonID: "topic",
                             objectiveID: "personal-vocabulary", contentVersion: "personal", enrolledAt: date(1))
    }

    private func date(_ day: Int) -> Date { Date(timeIntervalSince1970: TimeInterval(day) * 86_400) }
}
