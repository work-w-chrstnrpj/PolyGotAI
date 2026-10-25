import CryptoKit
import Foundation

struct CurriculumInstall: Equatable {
    var lessons: [ResolvedLesson]
    var problem: String?
    var archivedLessons: [ResolvedLesson] = []

    /// Ambiguous, missing or mismatched identities never fall forward to the current tasks.
    func lesson(id: String, version: String) -> ResolvedLesson? {
        let matches = (lessons + archivedLessons).filter { $0.id == id && $0.contentVersion == version }
        if !matches.isEmpty { return matches.count == 1 ? matches.first : nil }
        // Optional practice also resumes using its exact source version after a later course update.
        for kind in CurriculumPracticeKind.allCases {
            let suffix = "-practice-\(kind.rawValue)"
            if id.hasSuffix(suffix),
               let source = lesson(id: String(id.dropLast(suffix.count)), version: version) {
                return kind.lesson(from: source)
            }
        }
        return nil
    }

    func opening(_ offered: ResolvedLesson, saved: [LessonJourney]) throws -> (lesson: ResolvedLesson, journey: LessonJourney?) {
        let matching = saved.filter { $0.lessonID == offered.id && $0.objectiveID == offered.objectiveId }
        let existing = matching.last { $0.completedAt == nil } ?? matching.last { $0.contentVersion == offered.contentVersion }
        guard let existing else { return (offered, nil) }
        let installed = (lessons + archivedLessons).contains { $0.id == existing.lessonID && $0.contentVersion == existing.contentVersion }
        let exact = existing.contentVersion == offered.contentVersion && !installed
            ? offered : lesson(id: existing.lessonID, version: existing.contentVersion)
        guard let exact, exact.isReady, exact.objectiveId == existing.objectiveID else {
            throw LessonProgressError.versionMismatch
        }
        return (exact, existing)
    }

    func lessons(at level: String) -> [ResolvedLesson] {
        lessons.filter { $0.level.caseInsensitiveCompare(level) == .orderedSame }
    }

    var hasReadyLesson: Bool { lessons.contains(where: \.isReady) }
}

/// Reads one bundled catalog directory. It does not download, install, or copy curriculum into learner storage.
struct CurriculumCatalogLoader {
    /// Immutable bundle content is inspected once, rather than hashing every audio clip on each UI update.
    static let bundled = CurriculumCatalogLoader().loadBundled()
    func load(directory: URL) -> CurriculumInstall {
        let catalogURL = directory.appendingPathComponent("CurriculumCatalog.json")
        let data: Data
        do {
            data = try Data(contentsOf: catalogURL)
        } catch {
            return CurriculumInstall(lessons: [], problem: "The lesson catalog is not included in this build.")
        }
        let manifest: CurriculumManifest
        do {
            manifest = try JSONDecoder().decode(CurriculumManifest.self, from: data)
        } catch {
            return CurriculumInstall(lessons: [], problem: "The lesson catalog could not be read. No lesson was marked ready.")
        }
        let inspected = inspect(manifest.assets, in: directory)
        // Resolve older versions individually so multiple versions of an id are not duplicate browse rows.
        let archives = (manifest.archivedLessons ?? []).flatMap { lesson -> [ResolvedLesson] in
            var archived = manifest
            archived.lessons = [lesson]
            archived.archivedLessons = nil
            return CurriculumAvailability.resolve(manifest: archived, inspected: inspected)
        }
        return CurriculumInstall(lessons: CurriculumAvailability.resolve(manifest: manifest, inspected: inspected),
                                 problem: nil, archivedLessons: archives)
    }

    func loadBundled(bundle: Bundle = .main) -> CurriculumInstall {
        guard let catalogURL = bundle.url(forResource: "CurriculumCatalog", withExtension: "json") else {
            return CurriculumInstall(lessons: [], problem: "The lesson catalog is not included in this build.")
        }
        return load(directory: catalogURL.deletingLastPathComponent())
    }

    private func inspect(_ assets: [CurriculumAsset], in directory: URL) -> [String: InspectedAsset] {
        var counts: [String: Int] = [:]
        for asset in assets { counts[asset.id, default: 0] += 1 }
        var inspected: [String: InspectedAsset] = [:]
        for asset in assets where counts[asset.id] == 1 {
            inspected[asset.id] = inspect(asset, in: directory)
        }
        return inspected
    }

    private func inspect(_ asset: CurriculumAsset, in directory: URL) -> InspectedAsset {
        guard let file = containedFile(root: directory, relativePath: asset.relativePath),
              let data = try? Data(contentsOf: file) else {
            return InspectedAsset(byteCount: 0, sha256: "", readable: false)
        }
        let digest = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        return InspectedAsset(byteCount: data.count, sha256: digest, readable: true)
    }

    private func containedFile(root: URL, relativePath: String) -> URL? {
        guard !relativePath.isEmpty, !relativePath.hasPrefix("/"), !relativePath.contains("..") else { return nil }
        let root = root.standardizedFileURL
        let file = root.appendingPathComponent(relativePath).standardizedFileURL
        let prefix = root.path.hasSuffix("/") ? root.path : root.path + "/"
        guard file.path.hasPrefix(prefix) else { return nil }
        return file
    }
}
