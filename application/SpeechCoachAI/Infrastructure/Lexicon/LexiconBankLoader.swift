import Foundation

/// Reads the bundled `lexicon-*.json` group files. A word that fails validation or repeats an earlier word
/// (same normalized lemma and part of speech) is skipped, never shown.
struct LexiconBankLoader {
    static let bundled = LexiconBankLoader().loadBundled()
    static let bankVersion = "1"

    private struct GroupFile: Decodable {
        struct Header: Decodable {
            var id: String
            var title: String
            var level: String
            var tagline: String
            var sources: [String]
        }
        var group: Header
        var words: [LexiconWord]
    }

    func loadBundled(bundle: Bundle = .main) -> LexiconBank {
        let urls = bundle.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? []
        return load(files: urls)
    }

    func load(directory: URL) -> LexiconBank {
        load(files: (try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? [])
    }

    func load(files: [URL]) -> LexiconBank {
        let groupFiles = files.filter { $0.lastPathComponent.hasPrefix("lexicon-") && $0.pathExtension == "json" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
        var bank = LexiconBank()
        var seenKeys = Set<String>()
        var seenGroups = Set<String>()
        for file in groupFiles {
            guard let data = try? Data(contentsOf: file), let parsed = try? JSONDecoder().decode(GroupFile.self, from: data),
                  !parsed.group.id.isEmpty, seenGroups.insert(parsed.group.id).inserted else { bank.skipped += 1; continue }
            var words: [LexiconWord] = []
            for var word in parsed.words {
                let key = "\(LexiconKey.normalize(word.lemma))|\(word.pos)"
                guard word.problem() == nil, seenKeys.insert(key).inserted else { bank.skipped += 1; continue }
                word.id = "\(parsed.group.id).\(LexiconKey.slug(word.lemma))"
                words.append(word)
            }
            bank.groups.append(LexiconGroup(id: parsed.group.id, title: parsed.group.title, level: parsed.group.level,
                                            tagline: parsed.group.tagline, sources: parsed.group.sources, words: words))
        }
        return bank
    }
}
