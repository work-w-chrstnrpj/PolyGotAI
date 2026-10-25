import Foundation
import Testing
@testable import SpeechCoachAI

/// The bundled CEFR course: every level A2 to C2 is typed, so every locked level has a jump test.
struct CourseContentTests {
    private let install = CurriculumCatalogLoader.bundled

    private func modelResponse(_ spec: ExerciseSpec) -> ExerciseResponse? {
        switch spec.kind {
        case .wordBank: .sequence((spec.accepted?.first ?? "").split(separator: " ").map(String.init))
        case .order: .sequence(spec.items ?? [])
        case .match: .pairs(spec.pairs ?? [])
        case .choice, .fillBlank, .spotError, .listenType, .speak: .text(spec.accepted?.first ?? "")
        case .open, .none: nil
        }
    }

    @Test func theCourseHasFiftySevenReadyLessonsAcrossSixLevels() {
        let counts = Dictionary(grouping: install.lessons, by: \.level).mapValues(\.count)
        #expect(counts == ["A1": 13, "A2": 11, "B1": 10, "B2": 10, "C1": 8, "C2": 5])
        #expect(install.lessons.allSatisfy { $0.isReady }, "every course lesson is ready")
    }

    @Test func everyLessonFromA2UpIsTypedWithATip() {
        for lesson in install.lessons where lesson.level != "A1" {
            #expect(lesson.hasCheckedExercises, "\(lesson.id) has checked exercises")
            #expect(!(lesson.tip ?? "").isEmpty, "\(lesson.id) has a tip")
            #expect(lesson.contentVersion == "3", "\(lesson.id) is content version 3")
        }
    }

    @Test func everyCheckedCourseExerciseAcceptsItsModelAnswer() {
        var checked = 0
        for lesson in install.lessons {
            for activity in lesson.practiceActivities {
                let spec = activity.resolvedExercise
                #expect(spec.problem(hasClip: activity.assetId != nil) == nil, "\(lesson.id)/\(activity.id) is well formed")
                guard activity.exercise != nil, spec.isChecked, let response = modelResponse(spec) else { continue }
                checked += 1
                #expect(spec.evaluate(response) == .correct, "\(lesson.id)/\(activity.id) accepts its model answer")
            }
        }
        #expect(checked > 600)
    }

    @Test func gapPromptsShowTheirBlankAndOneCorrectChoice() {
        for lesson in install.lessons where lesson.level != "A1" {
            for activity in lesson.practiceActivities where activity.kind == "grammar" && activity.resolvedExercise.kind == .choice {
                let spec = activity.resolvedExercise
                #expect((spec.accepted ?? []).count == 1)
                #expect(Set(spec.options ?? []).count == (spec.options ?? []).count, "\(activity.id) has distinct options")
                #expect(!(activity.prompt ?? "").hasPrefix("Fill the gap."), "\(activity.id) uses the blank format")
            }
        }
    }

    @Test func everyLockedLevelNowHasAJumpTest() {
        let gate = LevelGate(install: install, journeys: [], passedTests: [])
        for level in ["A2", "B1", "B2", "C1", "C2"] {
            #expect(gate.canTakeJumpTest(to: level), "\(level) has a test")
            guard let test = JumpTest.make(target: level, install: install) else { Issue.record("\(level) test could not be built"); continue }
            #expect(test.total == JumpTest.questionCount(for: level))
            let own = test.items.filter { $0.level == level }.count
            #expect(own >= Int((Double(test.total) * 0.6).rounded(.up)), "\(level) draws mostly from its own level")
        }
    }

    @Test func archivedVersionsKeepSavedWorkReadable() {
        // Saved v2 lessons (and v3 of A1) reopen from the archive.
        #expect(install.lesson(id: "a2-travel", version: "2")?.isReady == true)
        #expect(install.lesson(id: "c2-multi", version: "2")?.isReady == true)
        #expect(install.lesson(id: "a2-travel", version: "3")?.hasCheckedExercises == true)
    }

    // MARK: Round 3 proofread rules (A2 to C2)

    private var upperActivities: [CurriculumActivity] {
        install.lessons.filter { $0.level != "A1" }.flatMap(\.practiceActivities)
    }

    @Test func trueFalseKeysAreBalancedFromA2Up() {
        let keys = upperActivities.filter { $0.id.hasSuffix("-tf") }.map(\.answer)
        let trues = keys.filter { $0 == "True" }.count
        #expect(keys.count == 44)
        #expect((18...26).contains(trues), "\(trues) of \(keys.count) keys are True")
    }

    @Test func recallTilesShowTheSameTextAsTheirModelAnswer() {
        for activity in upperActivities where activity.id.contains("-recall-") {
            let spec = activity.resolvedExercise
            guard spec.kind == .choice, let first = spec.accepted?.first else { continue }
            #expect(activity.answer == first, "\(activity.id): answer \(activity.answer) vs tile \(first)")
        }
    }

    @Test func typedAcceptedAnswersNeverContainATemplateMarker() {
        for activity in upperActivities where activity.resolvedExercise.kind == .fillBlank || activity.resolvedExercise.kind == .listenType {
            for accepted in activity.resolvedExercise.accepted ?? [] {
                #expect(!accepted.contains("\u{2026}"), "\(activity.id) accepts a template: \(accepted)")
            }
        }
    }

    @Test func courseTextUsesAmericanWordsAndCurlyApostrophes() throws {
        let british = try NSRegularExpression(pattern: "\\b(film|flat|holiday|cancelled|colour|favourite)\\b", options: [.caseInsensitive])
        for lesson in install.lessons where lesson.level != "A1" {
            var strings: [String] = [lesson.title, lesson.tip ?? ""]
            for activity in lesson.practiceActivities {
                let spec = activity.resolvedExercise
                strings.append(activity.prompt ?? "")
                strings.append(activity.answer ?? "")
                strings.append(contentsOf: spec.options ?? [])
                strings.append(contentsOf: spec.accepted ?? [])
                strings.append(spec.audioText ?? "")
            }
            for text in strings {
                let range = NSRange(text.startIndex..., in: text)
                #expect(british.firstMatch(in: text, range: range) == nil, "\(lesson.id): British word in: \(text)")
                #expect(!text.contains("'"), "\(lesson.id): straight apostrophe in: \(text)")
            }
        }
    }
}
