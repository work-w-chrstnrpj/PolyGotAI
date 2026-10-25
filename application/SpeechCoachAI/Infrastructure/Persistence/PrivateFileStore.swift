import CryptoKit
import Darwin
import Foundation

/// Narrow fault injection points exercise real on-disk failure/restart behavior.
enum FileOperation { case write, rename, remove, protect }

final class PrivateFileStore {
    let root: URL
    var beforeOperation: ((FileOperation) throws -> Void)?
    private let manager = FileManager.default

    init(root: URL) throws {
        guard root.isFileURL else { throw LearnerStorageError.invalidReference }
        if let attrs = try? manager.attributesOfItem(atPath: root.path),
           attrs[.type] as? String == FileAttributeType.typeSymbolicLink.rawValue {
            throw LearnerStorageError.invalidReference
        }
        // OS-managed ancestors may contain aliases (/var -> /private/var on iOS).
        // Reject symlinks at our root and every managed descendant, not OS ancestors.
        self.root = root.standardizedFileURL
        try manager.createDirectory(at: self.root, withIntermediateDirectories: true,
                                    attributes: [.protectionKey: FileProtectionType.complete])
        try protectTree()
        for directory in ["audio", "staging"] {
            try manager.createDirectory(at: self.root.appendingPathComponent(directory), withIntermediateDirectories: true,
                                        attributes: [.protectionKey: FileProtectionType.complete])
        }
        try protectTree()
    }

    func url(for relativePath: String) throws -> URL {
        let parts = relativePath.split(separator: "/", omittingEmptySubsequences: false)
        guard parts.count == 2, ["audio", "staging"].contains(String(parts[0])),
              parts[1].hasSuffix(".wav"), UUID(uuidString: String(parts[1].dropLast(4))) != nil else {
            throw LearnerStorageError.invalidReference
        }
        let url = root.appendingPathComponent(relativePath)
        guard url.path.hasPrefix(root.path + "/") else { throw LearnerStorageError.invalidReference }
        let directory = url.deletingLastPathComponent()
        let parentAttributes = try manager.attributesOfItem(atPath: directory.path)
        guard parentAttributes[.type] as? String == FileAttributeType.typeDirectory.rawValue else {
            throw LearnerStorageError.invalidReference
        }
        if let attributes = try? manager.attributesOfItem(atPath: url.path),
           attributes[.type] as? String == FileAttributeType.typeSymbolicLink.rawValue {
            throw LearnerStorageError.invalidReference
        }
        return url
    }

    func writeAndFinalize(_ data: Data, recording: RecordingSnapshot) throws {
        let final = try url(for: recording.relativePath)
        let staged = try url(for: "staging/\(recording.id.uuidString).wav")
        guard !manager.fileExists(atPath: final.path), !manager.fileExists(atPath: staged.path) else {
            throw LearnerStorageError.invalidState
        }
        try beforeOperation?(.write)
        try data.write(to: staged, options: [.atomic, .completeFileProtection])
        try protect(staged)
        try sync(staged)
        guard try matches(recording, at: staged) else { throw LearnerStorageError.integrityFailure }
        try beforeOperation?(.rename)
        try manager.moveItem(at: staged, to: final)
        try protect(final)
        try sync(final.deletingLastPathComponent())
    }

    func recoverFinalization(_ recording: RecordingSnapshot) throws -> Bool {
        let final = try url(for: recording.relativePath)
        if manager.fileExists(atPath: final.path) { return try matches(recording, at: final) }
        let staged = try url(for: "staging/\(recording.id.uuidString).wav")
        guard manager.fileExists(atPath: staged.path) else { return false }
        guard try matches(recording, at: staged) else { throw LearnerStorageError.integrityFailure }
        try beforeOperation?(.rename)
        try manager.moveItem(at: staged, to: final)
        try protect(final)
        try sync(final.deletingLastPathComponent())
        return true
    }

    func isAvailable(_ recording: RecordingSnapshot) throws -> Bool {
        let file = try url(for: recording.relativePath)
        guard manager.fileExists(atPath: file.path) else { return false }
        return try matches(recording, at: file)
    }

    func remove(_ relativePath: String) throws {
        let file = try url(for: relativePath)
        if manager.fileExists(atPath: file.path) {
            try beforeOperation?(.remove)
            try manager.removeItem(at: file)
            try sync(file.deletingLastPathComponent())
        }
    }

    func allAudioPaths() throws -> [String] {
        try ["audio", "staging"].flatMap { folder in
            try manager.contentsOfDirectory(atPath: root.appendingPathComponent(folder).path).map { folder + "/" + $0 }
        }
    }

    static func checksum(_ data: Data) -> String { SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined() }

    func protectTree() throws {
        try protect(root)
        guard let entries = manager.enumerator(at: root, includingPropertiesForKeys: [.isSymbolicLinkKey]) else {
            throw LearnerStorageError.storageFailure
        }
        for case let url as URL in entries {
            guard try url.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink != true else {
                throw LearnerStorageError.invalidReference
            }
            try protect(url)
        }
    }

    private func protect(_ url: URL) throws {
        try beforeOperation?(.protect)
        try manager.setAttributes([.protectionKey: FileProtectionType.complete], ofItemAtPath: url.path)
        var mutableURL = url
        var values = URLResourceValues(); values.isExcludedFromBackup = true
        try mutableURL.setResourceValues(values)
    }

    private func matches(_ recording: RecordingSnapshot, at url: URL) throws -> Bool {
        let data = try Data(contentsOf: url)
        return data.count == recording.byteCount && Self.checksum(data) == recording.sha256
    }

    private func sync(_ url: URL) throws {
        let descriptor = open(url.path, O_RDONLY)
        guard descriptor >= 0 else { throw LearnerStorageError.storageFailure }
        defer { close(descriptor) }
        guard fsync(descriptor) == 0 else { throw LearnerStorageError.storageFailure }
    }
}
