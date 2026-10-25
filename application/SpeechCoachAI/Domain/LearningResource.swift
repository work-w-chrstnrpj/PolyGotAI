import Foundation

enum ResourceLinkError: Error, Equatable {
    case invalidURL, unsupportedYouTube, titleRequired, duplicate, missing, changed

    var message: String {
        switch self {
        case .invalidURL: "Use an HTTPS link to a public website, without a custom port or credentials in the link."
        case .unsupportedYouTube: "Use a YouTube video, Shorts, channel or handle link."
        case .titleRequired: "Give this resource a title."
        case .duplicate: "This link is already in your library. Edit the existing bookmark instead."
        case .missing: "This bookmark was removed. Your changes have not been saved."
        case .changed: "This bookmark changed elsewhere. Reopen it before editing again."
        }
    }
}

/// Validation is syntactic. It neither resolves DNS nor certifies a destination or redirect.
struct ResourceLink: Equatable {
    let url: URL
    var canonical: String { url.absoluteString }
    var host: String { url.host ?? "" }
    var isYouTube: Bool { host == "www.youtube.com" }

    init(_ input: String) throws {
        let raw = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty, !raw.contains("\\"),
              !raw.unicodeScalars.contains(where: { CharacterSet.controlCharacters.contains($0) }),
              var parts = URLComponents(string: raw), parts.scheme?.lowercased() == "https",
              parts.user == nil, parts.password == nil, parts.port == nil || parts.port == 443,
              let rawHost = parts.host?.lowercased(), Self.publicHost(rawHost),
              parts.percentEncodedHost?.contains("%") != true,
              !(parts.queryItems ?? []).contains(where: {
                  ["token", "access_token", "api_key", "apikey", "password", "auth", "authorization", "signature"].contains($0.name.lowercased())
              }) else { throw ResourceLinkError.invalidURL }
        parts.scheme = "https"; parts.host = rawHost; parts.port = nil
        let youtube = ["youtube.com", "www.youtube.com", "m.youtube.com", "music.youtube.com", "youtu.be", "www.youtu.be"]
        if youtube.contains(rawHost) {
            let components = parts.path.split(separator: "/").map(String.init)
            let video: String?
            if rawHost == "youtu.be" || rawHost == "www.youtu.be" {
                video = components.count == 1 ? components.first : nil
            } else if parts.path == "/watch" {
                let values = (parts.queryItems ?? []).filter { $0.name == "v" }
                video = values.count == 1 ? values.first?.value : nil
            } else if components.count == 2 && ["shorts", "live", "embed"].contains(components[0]) {
                video = components[1]
            } else { video = nil }
            parts.host = "www.youtube.com"; parts.fragment = nil; parts.query = nil
            if let video, video.count == 11, Self.identifier(video) {
                parts.path = "/watch"; parts.queryItems = [URLQueryItem(name: "v", value: video)]
            } else if rawHost != "youtu.be" && rawHost != "www.youtu.be",
                      components.count == 1, let handle = components.first, handle.hasPrefix("@"),
                      handle.count > 1, Self.identifier(String(handle.dropFirst()), allowDot: true) {
                parts.path = "/" + handle.lowercased()
            } else if rawHost != "youtu.be" && rawHost != "www.youtu.be",
                      components.count == 2, components[0] == "channel", Self.identifier(components[1]) {
                parts.path = "/channel/" + components[1]
            } else { throw ResourceLinkError.unsupportedYouTube }
        } else {
            if parts.path.isEmpty { parts.path = "/" }
            // Strip only recognized tracking fields; retain other query semantics and fragments.
            if let query = parts.percentEncodedQuery {
                // Rebuilding queryItems decodes/re-encodes retained values (for example %2B becomes +).
                // Filter raw fields so website-specific query semantics and ordering survive unchanged.
                let fields = query.components(separatedBy: "&").filter { field in
                    let encodedName = String(field.prefix { $0 != "=" })
                    let name = (encodedName.removingPercentEncoding ?? encodedName).lowercased()
                    return !name.hasPrefix("utm_") && !["fbclid", "gclid"].contains(name)
                }
                parts.percentEncodedQuery = fields.isEmpty ? nil : fields.joined(separator: "&")
            }
        }
        guard let url = parts.url, url.host != nil else { throw ResourceLinkError.invalidURL }
        self.url = url
    }

    private static func identifier(_ value: String, allowDot: Bool = false) -> Bool {
        !value.isEmpty && value.utf8.allSatisfy {
            (65...90).contains($0) || (97...122).contains($0) || (48...57).contains($0)
                || $0 == 45 || $0 == 95 || (allowDot && $0 == 46)
        }
    }

    private static func publicHost(_ host: String) -> Bool {
        let labels = host.split(separator: ".", omittingEmptySubsequences: false)
        guard labels.count >= 2, !["local", "localhost", "internal", "home", "lan", "invalid", "test", "onion"].contains(String(labels.last ?? "")),
              labels.last?.utf8.contains(where: { (97...122).contains($0) }) == true else { return false }
        return labels.allSatisfy { label in
            guard !label.isEmpty, label.first != "-", label.last != "-" else { return false }
            return label.utf8.allSatisfy { (97...122).contains($0) || (48...57).contains($0) || $0 == 45 }
        }
    }
}

struct CuratedLearningResource: Identifiable, Equatable {
    let id: String
    let title: String
    let destination: String
    let detail: String
    let source: String
    let version: String

    /// Link metadata only. No copied media, transcript, thumbnail or approved lesson claim.
    static let catalog: [Self] = [
        .init(id: "voa-learning-english", title: "VOA Learning English",
              destination: "https://learningenglish.voanews.com/", detail: "External American English learning resources",
              source: "https://learningenglish.voanews.com/", version: "resources-2026-10-24-v1"),
        .init(id: "voa-youtube", title: "VOA Learning English on YouTube",
              destination: "https://www.youtube.com/@voalearningenglish", detail: "External video channel · YouTube",
              source: "https://learningenglish.voanews.com/", version: "resources-2026-10-24-v1")
    ]
}

struct LearningResource: Codable, Equatable, Identifiable {
    var id: UUID
    var revision: Int
    var title: String
    var destination: String
    var topic: String
    var notes: String
    var curatedID: String?
    var curatedVersion: String?
    var updatedAt: Date
}

/// Kept in memory across navigation; only explicit Save writes learner text.
struct ResourceEditorDraft: Equatable, Identifiable {
    let id: UUID
    let epoch: UUID
    let original: LearningResource?
    var title: String
    var destination: String
    var topic: String
    var notes: String
    var curatedID: String?
    var curatedVersion: String?
    var message: String?

    init(epoch: UUID, resource: LearningResource? = nil, curated: CuratedLearningResource? = nil) {
        id = resource?.id ?? UUID(); self.epoch = epoch; original = resource
        title = resource?.title ?? curated?.title ?? ""
        destination = resource?.destination ?? curated?.destination ?? ""
        topic = resource?.topic ?? ""; notes = resource?.notes ?? ""
        curatedID = resource?.curatedID ?? curated?.id
        curatedVersion = resource?.curatedVersion ?? curated?.version
    }

    var isDirty: Bool {
        if let original {
            return title != original.title || destination != original.destination || topic != original.topic || notes != original.notes
        }
        return !title.isEmpty || !destination.isEmpty || !topic.isEmpty || !notes.isEmpty
    }
}

struct ResourceOpenIntent: Identifiable, Equatable {
    let id = UUID()
    let link: ResourceLink
    let epoch: UUID
    let bookmark: LearningResource?

    init(destination: String, epoch: UUID, bookmark: LearningResource? = nil) throws {
        link = try ResourceLink(destination); self.epoch = epoch; self.bookmark = bookmark
    }
}
