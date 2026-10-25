import Foundation

struct RewardTransaction: Codable, Equatable, Identifiable {
    var id: String
    var source: String
    var activity: String
    var day: String
    var createdAt: Date
    var xp: Int
    var gold: Int
    var reason: String
    var kind: String
    var multiplier: Int // 2 full, 1 half, 0 exhausted; never a CEFR score.
}

struct RewardAward: Codable, Equatable, Identifiable {
    var id: String
    var family: String
    var tier: Int?
    var earnedAt: Date
    var evidence: [String]
    var evidenceUnavailable = false
}

struct RewardPlan: Codable, Equatable {
    var day: String
    var lessonID: String
    var contentVersion: String
    var activityIDs: [String]
    var startedAt: Date
    var completed = false
}

struct RewardCheckpoint: Codable, Equatable {
    var lessonID: String
    var version: String
    var journeyID: UUID
    var completedAt: Date
}

struct RewardLedger: Codable, Equatable {
    var ruleVersion = RewardPolicy.version
    var epoch: UUID
    var revision = 0
    var startedAt: Date
    var transactions: [RewardTransaction] = []
    var awards: [RewardAward] = []
    var acknowledged: [String] = []
    var settings = RewardSettings()
    var freezes = 0
    var protectedDays: [String] = []
    var lastRepairPracticeCount: Int? = nil
    var activeSeconds: [String: Double] = [:]
    var timeSampleIDs: [UUID] = []
    var clockHighWaterDay: String? = nil
    var plans: [RewardPlan] = []
    var checkpoints: [RewardCheckpoint] = []
    var xp: Int { transactions.reduce(0) { $0 + $1.xp } }
    var gold: Int { transactions.reduce(0) { $0 + $1.gold } }
    var practiceDays: [String] { Array(Set(transactions.filter { ["exercise", "speaking", "review"].contains($0.kind) && $0.multiplier > 0 }.map(\.day))).sorted() }
    var pendingAwards: [RewardAward] { awards.filter { !acknowledged.contains($0.id) } }

    mutating func acceptDay(_ day: String) throws {
        guard let ordinal = RewardPolicy.ordinal(day) else { throw RewardError.invalidRequest }
        if let high = clockHighWaterDay, let highOrdinal = RewardPolicy.ordinal(high), ordinal < highOrdinal { throw RewardError.clockChanged }
        clockHighWaterDay = day
    }

    mutating func credit(source: String, activity: String, kind: String, day: String, now: Date, freshReview: Bool = false) throws {
        guard ["exercise", "speaking", "review"].contains(kind), !source.isEmpty, !activity.isEmpty else { throw RewardError.invalidRequest }
        let fullXP = kind == "speaking" ? 30 : 10
        let fullGold = kind == "speaking" ? 6 : 2
        // Source identity survives restart, timezone changes and repeated callbacks.
        if let index = transactions.firstIndex(where: { $0.source == source && ["exercise", "speaking", "review"].contains($0.kind) }) {
            // A course speaking self-review replaces the nested exercise entitlement; it never stacks both rows.
            if kind == "speaking", transactions[index].kind == "exercise" {
                let prior = transactions[index]
                let xpDelta = fullXP * prior.multiplier / 2 - prior.xp
                let goldDelta = fullGold * prior.multiplier / 2 - prior.gold
                transactions[index].kind = "speaking"
                transactions.append(RewardTransaction(id: "upgrade/" + source, source: source, activity: activity, day: prior.day,
                    createdAt: now, xp: xpDelta, gold: goldDelta, reason: "Speaking self-review · remaining entitlement after nested exercise", kind: "adjustment", multiplier: 0))
                evaluateAwards(now: now)
            }
            return
        }
        try acceptDay(day)
        let count = transactions.filter { $0.activity == activity && $0.day == day && ["exercise", "speaking", "review"].contains($0.kind) }.count
        let multiplier = freshReview ? 2 : (count == 0 ? 2 : count == 1 ? 1 : 0)
        let wasAway = practiceDays.last.flatMap(RewardPolicy.ordinal).flatMap { last in RewardPolicy.ordinal(day).map { $0 - last - 1 >= 7 } } ?? false
        transactions.append(RewardTransaction(id: "credit/" + source, source: source, activity: activity, day: day, createdAt: now,
            xp: fullXP * multiplier / 2, gold: fullGold * multiplier / 2,
            reason: multiplier == 2 ? "Completed \(kind) with correction or self-review" : multiplier == 1 ? "One meaningful repeat · half credit" : "Further practice · no additional XP or gold", kind: kind, multiplier: multiplier))
        if settings.autoFreeze { protectMissedDays(endingAt: day, now: now) }
        if wasAway { award("AW-C-05", now: now, evidence: [source]) }
        evaluateAwards(now: now)
        completePlans(now: now)
    }

    mutating func award(_ family: String, tier: Int? = nil, now: Date, evidence: [String]) {
        let id = family + "/" + (tier.map(String.init) ?? "once") + "/" + ruleVersion
        guard !awards.contains(where: { $0.id == id }) else { return }
        awards.append(RewardAward(id: id, family: family, tier: tier, earnedAt: now, evidence: evidence))
    }

    mutating func evaluateAwards(now: Date) {
        let paid = transactions.filter { $0.multiplier > 0 && ["exercise", "speaking", "review"].contains($0.kind) }
        if let first = paid.first { award("AW-P-01", now: now, evidence: [first.source]) }
        if let first = paid.first(where: { $0.kind == "review" }) { award("AW-P-04", now: now, evidence: [first.source]) }
        if let first = paid.first(where: { $0.kind == "speaking" }) { award("AW-P-05", now: now, evidence: [first.source]) }
        if practiceDays.count >= 3 { award("AW-C-01", now: now, evidence: practiceDays) }
        for tier in [10,30,100,365] where practiceDays.count >= tier { award("AW-C-02", tier: tier, now: now, evidence: practiceDays) }
        for tier in [3,7,14,30,100,365] where streak >= tier { award("AW-C-03", tier: tier, now: now, evidence: practiceDays + protectedDays) }
        for tier in [1,7,30,100] where plans.filter(\.completed).count >= tier { award("AW-C-04", tier: tier, now: now, evidence: plans.filter(\.completed).map(\.day)) }
    }

    var streak: Int {
        let practiced = Set(practiceDays.compactMap(RewardPolicy.ordinal))
        let protected = Set(protectedDays.compactMap(RewardPolicy.ordinal))
        guard var current = practiced.max() else { return 0 }
        var count = 0
        while practiced.contains(current) || protected.contains(current) { count += 1; current -= 1 }
        return count
    }

    func currentStreak(day: String) -> Int {
        guard let last = practiceDays.last, let end = RewardPolicy.ordinal(day), let start = RewardPolicy.ordinal(last) else { return 0 }
        if end <= start + 1 { return streak }
        let protected = Set(protectedDays.compactMap(RewardPolicy.ordinal))
        guard end - start - 1 <= protected.count,
              ((start+1)..<end).allSatisfy({ protected.contains($0) }) else { return 0 }
        return streak + end - start - 1
    }

    func gap(before day: String) -> [String] {
        guard let last = practiceDays.filter({ $0 < day }).last, let start = RewardPolicy.ordinal(last), let end = RewardPolicy.ordinal(day), end > start + 1 else { return [] }
        guard end - start - 1 <= 7 else { return [] }
        var calendar = Calendar(identifier: .gregorian); calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return ((start+1)..<end).map { RewardPolicy.day(Date(timeIntervalSince1970: Double($0)*86_400), calendar: calendar) }.filter { !protectedDays.contains($0) }
    }

    mutating func protectMissedDays(endingAt day: String, now: Date) {
        // Called after the new event; find the preceding actual practice date, never create practice evidence.
        let previous = practiceDays.filter { $0 < day }.last
        guard let previous, let start = RewardPolicy.ordinal(previous), let end = RewardPolicy.ordinal(day), end > start + 1 else { return }
        var calendar = Calendar(identifier: .gregorian); calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        var ordinal = start + 1
        while ordinal < end && freezes > 0 {
            let missing = RewardPolicy.day(Date(timeIntervalSince1970: Double(ordinal)*86_400), calendar: calendar)
            ordinal += 1
            if protectedDays.contains(missing) { continue }
            freezes -= 1; protectedDays.append(missing)
            transactions.append(RewardTransaction(id: "freeze-use/"+missing, source: "freeze-use/"+missing, activity: "continuity", day: day, createdAt: now,
                xp: 0, gold: 0, reason: "Freeze used for \(missing) · continuity only", kind: "freezeUse", multiplier: 0))
        }
    }

    func quote(_ kind: RewardPurchase.Kind, day: String, context: String? = nil) throws -> RewardPurchase {
        guard RewardPolicy.ordinal(day) != nil else { throw RewardError.invalidRequest }
        if let high = clockHighWaterDay, day < high { throw RewardError.clockChanged }
        let missed = kind == .repair ? gap(before: day) : []
        let cost: Int
        switch kind {
        case .hint: cost = transactions.filter { $0.kind == "hint" && $0.day == day }.count < 3 ? 0 : 2
        case .example: cost = 4
        case .freeze: cost = 20
        case .repair:
            guard !missed.isEmpty, missed.count <= 7,
                  lastRepairPracticeCount.map({ practiceDays.count > $0 }) ?? true else { throw RewardError.repairUnavailable }
            cost = missed.count * 30
        }
        guard gold >= cost else { throw RewardError.insufficientGold }
        return RewardPurchase(id: UUID(), epoch: epoch, revision: revision, day: day, kind: kind, cost: cost, missedDays: missed, context: context)
    }

    mutating func purchase(_ quote: RewardPurchase, day: String, now: Date) throws {
        if transactions.contains(where: { $0.id == quote.id.uuidString }) { return }
        guard quote.epoch == epoch, quote.revision == revision, quote.day == day else { throw RewardError.stale }
        let current = try self.quote(quote.kind, day: day, context: quote.context)
        guard current.cost == quote.cost, current.missedDays == quote.missedDays else { throw RewardError.stale }
        try acceptDay(day)
        if quote.kind == .freeze { freezes += 1 }
        if quote.kind == .repair { protectedDays += quote.missedDays; lastRepairPracticeCount = practiceDays.count }
        transactions.append(RewardTransaction(id: quote.id.uuidString, source: quote.id.uuidString, activity: quote.context ?? "wallet", day: day,
            createdAt: now, xp: 0, gold: -quote.cost, reason: "\(quote.kind.rawValue.capitalized) · \(quote.cost) gold", kind: quote.kind.rawValue, multiplier: 0))
        if quote.kind == .repair { evaluateAwards(now: now) }
    }

    mutating func startPlan(lesson: ResolvedLesson, day: String, now: Date) throws {
        try acceptDay(day)
        guard !plans.contains(where: { $0.day == day }), lesson.isReady else { throw RewardError.invalidRequest }
        plans.append(RewardPlan(day: day, lessonID: lesson.id, contentVersion: lesson.contentVersion,
            activityIDs: lesson.sessionActivities.filter { $0.required }.map(\.id), startedAt: now))
    }

    mutating func completePlans(now: Date) {
        for index in plans.indices where !plans[index].completed {
            let plan = plans[index]
            let completed = Set(transactions.filter { $0.day == plan.day && $0.createdAt >= plan.startedAt && ["exercise", "speaking", "completion"].contains($0.kind) }.map(\.activity))
            let required = Set(plan.activityIDs.map { "\(plan.lessonID)/\(plan.contentVersion)/\($0)" })
            guard !required.isEmpty, required.isSubset(of: completed) else { continue }
            plans[index].completed = true
            let source = "plan/"+plan.day
            if !transactions.contains(where: { $0.id == source }) {
                transactions.append(RewardTransaction(id: source, source: source, activity: "dailyPlan", day: plan.day, createdAt: now,
                    xp: 25, gold: 10, reason: "Completed the chosen lesson activity plan · time goal not required", kind: "plan", multiplier: 0))
            }
        }
        // Tier evaluation is independent from currency and presentation.
        for tier in [1,7,30,100] where plans.filter(\.completed).count >= tier { award("AW-C-04", tier: tier, now: now, evidence: plans.filter(\.completed).map(\.day)) }
    }
}
