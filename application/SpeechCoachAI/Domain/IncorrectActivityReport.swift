import Foundation

enum ActivityReportIssue: String, Codable, CaseIterable, Identifiable, Sendable {
    case malformedItem, invalidAnswer, ambiguousPrompt, wrongLevel, other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .malformedItem: "Something doesn't make sense"
        case .invalidAnswer: "The answer looks wrong"
        case .ambiguousPrompt: "The prompt is ambiguous"
        case .wrongLevel: "The level looks wrong"
        case .other: "Something else"
        }
    }
}

enum ActivityReportStatus: String, Codable, Sendable {
    case pendingSave, recordedLocally, deleted, retentionExpired
}

struct ActivityReportSubject: Equatable, Sendable {
    var variantID: String
    var schemaVersion: Int
    var contentVersion: String
    var objectiveID: String
    var templateID: String
    var rubricVersion: String
}

/// Local trace of a learner's incorrect-activity report.
/// A report is not a correction, a remote submission, or a publication approval.
struct IncorrectActivityReport: Equatable, Codable, Identifiable, Sendable {
    var id: UUID
    var variantID: String
    var schemaVersion: Int
    var contentVersion: String
    var objectiveID: String
    var templateID: String
    var rubricVersion: String
    var issue: ActivityReportIssue
    var status: ActivityReportStatus
    var recordedAt: Date
    var expiresAt: Date
    var supersededByVariantID: String?
    fileprivate(set) var learnerResponseIncluded: Bool
    fileprivate(set) var remoteSubmission: Bool
    fileprivate(set) var correctionPublished: Bool
    fileprivate(set) var transmitsOffDevice: Bool

    init(id: UUID, subject: ActivityReportSubject, issue: ActivityReportIssue, now: Date, expiresAt: Date) {
        self.id = id
        variantID = subject.variantID
        schemaVersion = subject.schemaVersion
        contentVersion = subject.contentVersion
        objectiveID = subject.objectiveID
        templateID = subject.templateID
        rubricVersion = subject.rubricVersion
        self.issue = issue
        status = .pendingSave
        recordedAt = now
        self.expiresAt = expiresAt
        supersededByVariantID = nil
        learnerResponseIncluded = false
        remoteSubmission = false
        correctionPublished = false
        transmitsOffDevice = false
    }

    enum CodingKeys: String, CodingKey {
        case id, variantID, schemaVersion, contentVersion, objectiveID, templateID, rubricVersion
        case issue, status, recordedAt, expiresAt, supersededByVariantID
        case learnerResponseIncluded, remoteSubmission, correctionPublished, transmitsOffDevice
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        variantID = try container.decode(String.self, forKey: .variantID)
        schemaVersion = try container.decode(Int.self, forKey: .schemaVersion)
        contentVersion = try container.decode(String.self, forKey: .contentVersion)
        objectiveID = try container.decode(String.self, forKey: .objectiveID)
        templateID = try container.decode(String.self, forKey: .templateID)
        rubricVersion = try container.decode(String.self, forKey: .rubricVersion)
        issue = try container.decode(ActivityReportIssue.self, forKey: .issue)
        status = try container.decode(ActivityReportStatus.self, forKey: .status)
        recordedAt = try container.decode(Date.self, forKey: .recordedAt)
        expiresAt = try container.decode(Date.self, forKey: .expiresAt)
        supersededByVariantID = try container.decodeIfPresent(String.self, forKey: .supersededByVariantID)
        let included = try container.decodeIfPresent(Bool.self, forKey: .learnerResponseIncluded) ?? false
        let remote = try container.decodeIfPresent(Bool.self, forKey: .remoteSubmission) ?? false
        let published = try container.decodeIfPresent(Bool.self, forKey: .correctionPublished) ?? false
        let transmits = try container.decodeIfPresent(Bool.self, forKey: .transmitsOffDevice) ?? false
        if included || remote || published || transmits {
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "A report cannot carry a private response or a remote correction."))
        }
        learnerResponseIncluded = false
        remoteSubmission = false
        correctionPublished = false
        transmitsOffDevice = false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(variantID, forKey: .variantID)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(contentVersion, forKey: .contentVersion)
        try container.encode(objectiveID, forKey: .objectiveID)
        try container.encode(templateID, forKey: .templateID)
        try container.encode(rubricVersion, forKey: .rubricVersion)
        try container.encode(issue, forKey: .issue)
        try container.encode(status, forKey: .status)
        try container.encode(recordedAt, forKey: .recordedAt)
        try container.encode(expiresAt, forKey: .expiresAt)
        try container.encodeIfPresent(supersededByVariantID, forKey: .supersededByVariantID)
        try container.encode(false, forKey: .learnerResponseIncluded)
        try container.encode(false, forKey: .remoteSubmission)
        try container.encode(false, forKey: .correctionPublished)
        try container.encode(false, forKey: .transmitsOffDevice)
    }
}

enum IncorrectActivityReports {
    static func stage(issue: ActivityReportIssue, subject: ActivityReportSubject, existing: [IncorrectActivityReport], policy: GenerationPolicy, now: Date) -> Result<IncorrectActivityReport, GenerationRefusal> {
        if let refusal = policy.refusal() { return .failure(.policyRejected(refusal)) }
        guard !subject.variantID.isEmpty, !subject.objectiveID.isEmpty, !subject.contentVersion.isEmpty,
              !subject.templateID.isEmpty, !subject.rubricVersion.isEmpty,
              subject.schemaVersion == GeneratedPracticeSchema.version else {
            return .failure(.malformed)
        }
        if let match = existing.first(where: {
            $0.variantID == subject.variantID && $0.issue == issue && $0.schemaVersion == subject.schemaVersion
                && $0.objectiveID == subject.objectiveID && $0.contentVersion == subject.contentVersion
                && $0.templateID == subject.templateID && $0.rubricVersion == subject.rubricVersion
                && now < $0.expiresAt && ($0.status == .pendingSave || $0.status == .recordedLocally)
        }) {
            return .success(match)
        }
        let expiry = now.addingTimeInterval(TimeInterval(policy.reportRetention.retainForSeconds))
        return .success(IncorrectActivityReport(id: UUID(), subject: subject, issue: issue, now: now, expiresAt: expiry))
    }

    static func expire(_ reports: [IncorrectActivityReport], now: Date) -> [IncorrectActivityReport] {
        reports.map { report in
            guard now >= report.expiresAt, report.status == .pendingSave || report.status == .recordedLocally else { return report }
            var expired = report
            expired.status = .retentionExpired
            return expired
        }
    }

    static func supersede(_ reports: [IncorrectActivityReport], reportID: UUID, variantID: String) -> [IncorrectActivityReport]? {
        guard let index = reports.firstIndex(where: { $0.id == reportID }) else { return nil }
        var copy = reports
        guard copy[index].variantID != variantID else { return copy }
        copy[index].supersededByVariantID = variantID
        copy[index].correctionPublished = false
        copy[index].remoteSubmission = false
        return copy
    }

    /// Local export of minimal identity. Returns nil when the approved policy does not permit export.
    static func exportData(_ reports: [IncorrectActivityReport], policy: GenerationPolicy, now: Date = .now) -> Data? {
        guard policy.accepted, policy.reportRetention.exportPermitted else { return nil }
        let rows = reports.filter { $0.status == .recordedLocally && now < $0.expiresAt }.map { report in
            ExportRow(id: report.id, variantID: report.variantID, schemaVersion: report.schemaVersion,
                       contentVersion: report.contentVersion, objectiveID: report.objectiveID,
                       templateID: report.templateID, rubricVersion: report.rubricVersion,
                       issue: report.issue, status: report.status)
        }
        return try? JSONEncoder().encode(rows)
    }

    private struct ExportRow: Encodable {
        var id: UUID
        var variantID: String
        var schemaVersion: Int
        var contentVersion: String
        var objectiveID: String
        var templateID: String
        var rubricVersion: String
        var issue: ActivityReportIssue
        var status: ActivityReportStatus
    }
}
