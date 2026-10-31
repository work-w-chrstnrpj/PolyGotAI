import SwiftUI
import UIKit

/// Lab videos by topic. A tap opens YouTube; when the learner comes back to the app the video counts as watched.
/// Favorite channels sort first; the circle on a row undoes or sets "watched" by hand.
struct LabVideosView: View {
    var storage: LearnerStorageController
    @Environment(\.scenePhase) private var scenePhase
    @SceneStorage("videos.topic") private var topicID = LabVideoTopic.pronunciation.rawValue
    @State private var watched: [String: Date] = [:]
    @State private var favorites: Set<String> = []
    @State private var opening: String?
    @State private var showChannels = false
    @State private var message: String?

    private var topic: LabVideoTopic { LabVideoTopic(rawValue: topicID) ?? .pronunciation }
    private var videos: [LabVideo] { LabVideoCatalog.ordered(LabVideoCatalog.videos(for: topic), favorites: favorites, watched: watched) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("\(LabVideoCatalog.watchedCount(watched)) of \(LabVideoCatalog.all.count) watched")
                        .font(.subheadline).foregroundStyle(Kit.secondary).accessibilityIdentifier("videos.count")
                    Spacer()
                    Button("Channels") { showChannels = true }
                        .buttonStyle(KitTextButtonStyle()).accessibilityIdentifier("videos.channels")
                }
                topicMenu
                if let message { Text(message).foregroundStyle(Kit.error) }
                ForEach(videos) { row($0) }
            }
            .padding(20).frame(maxWidth: 700, alignment: .leading).frame(maxWidth: .infinity)
        }
        .background(Kit.canvas(storage.preferences.background))
        .foregroundStyle(Kit.ink)
        .navigationTitle("Videos").navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: load)
        .onChange(of: scenePhase) { _, phase in
            // Back from YouTube: count the video that was opened as watched.
            if phase == .active, let id = opening { opening = nil; setWatched(id, true) }
        }
        .sheet(isPresented: $showChannels, onDismiss: load) {
            NavigationStack { LabVideoChannelsView(storage: storage) }
                .environment(\.kitTheme, KitTheme(storage.preferences.background)).tint(Kit.accent)
        }
    }

    /// One dropdown for the topic, with how many videos each topic has.
    private var topicMenu: some View {
        Menu {
            Picker("Topic", selection: $topicID) {
                ForEach(LabVideoTopic.allCases) { item in
                    Text("\(item.title) (\(LabVideoCatalog.videos(for: item).count))").tag(item.rawValue)
                }
            }
        } label: {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Topic").font(.caption).foregroundStyle(Kit.secondary)
                    Text(topic.title).font(.headline).foregroundStyle(Kit.ink)
                }
                Spacer()
                Image(systemName: "chevron.up.chevron.down").font(.subheadline).foregroundStyle(Kit.accent).accessibilityHidden(true)
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            .frame(minHeight: 44)
            .background(Kit.surface, in: RoundedRectangle(cornerRadius: Kit.Radius.card, style: .continuous))
            .contentShape(Rectangle())
        }
        .accessibilityLabel("Topic")
        .accessibilityValue(topic.title)
        .accessibilityIdentifier("videos.topic")
    }

    private func row(_ video: LabVideo) -> some View {
        let seen = watched[video.id] != nil
        return KitCard {
            HStack(spacing: 12) {
                Button { open(video) } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "play.rectangle.fill").font(.title3).foregroundStyle(Kit.accent)
                            .frame(width: 30).accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(video.title).font(.headline).foregroundStyle(Kit.ink).multilineTextAlignment(.leading)
                            HStack(spacing: 4) {
                                if favorites.contains(video.channel) {
                                    Image(systemName: "star.fill").font(.caption).foregroundStyle(Kit.accent).accessibilityLabel("Favorite")
                                }
                                Text(video.channel).font(.subheadline).foregroundStyle(Kit.secondary)
                            }
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }.contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityHint("Opens YouTube")
                .accessibilityIdentifier("videos.open.\(video.id)")
                Button { setWatched(video.id, !seen) } label: {
                    Image(systemName: seen ? "checkmark.circle.fill" : "circle").font(.title2)
                        .foregroundStyle(seen ? Kit.accent : Kit.secondary).frame(minWidth: 44, minHeight: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(seen ? "Watched" : "Mark watched")
                .accessibilityIdentifier("videos.watched.\(video.id)")
            }
        }
    }

    /// Opens the YouTube app when it is installed, otherwise the browser.
    private func open(_ video: LabVideo) {
        opening = video.id
        UIApplication.shared.open(video.url, options: [.universalLinksOnly: true]) { opened in
            if !opened {
                UIApplication.shared.open(video.url) { ok in if !ok { opening = nil } }
            }
        }
    }

    private func load() {
        let extras = (try? storage.repository?.labExtras()) ?? LabExtrasState()
        watched = extras.watched
        favorites = Set(extras.favoriteChannels ?? [])
    }

    private func setWatched(_ id: String, _ on: Bool) {
        do {
            try storage.repository?.setLabVideoWatched(id, on)
            load()
            message = nil
        } catch { message = "Could not save that." }
    }
}

/// Favorite channels: their videos come first in every topic.
private struct LabVideoChannelsView: View {
    var storage: LearnerStorageController
    @Environment(\.dismiss) private var dismiss
    @State private var favorites: Set<String> = []

    var body: some View {
        List(LabVideoCatalog.channels, id: \.self) { channel in
            Toggle(isOn: Binding(get: { favorites.contains(channel) }, set: { set(channel, $0) })) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(channel)
                    Text("\(LabVideoCatalog.all.filter { $0.channel == channel }.count) videos").font(.caption).foregroundStyle(Kit.secondary)
                }
            }
            .listRowBackground(Kit.surface)
            .accessibilityIdentifier("videos.channel.\(channel)")
        }
        .scrollContentBackground(.hidden)
        .background(Kit.canvas(storage.preferences.background))
        .navigationTitle("Favorite channels").navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() }.accessibilityIdentifier("videos.channels.done") }
        }
        .onAppear { favorites = Set(((try? storage.repository?.labExtras()) ?? LabExtrasState()).favoriteChannels ?? []) }
    }

    private func set(_ channel: String, _ on: Bool) {
        try? storage.repository?.setLabVideoChannelFavorite(channel, on)
        favorites = Set(((try? storage.repository?.labExtras()) ?? LabExtrasState()).favoriteChannels ?? [])
    }
}
