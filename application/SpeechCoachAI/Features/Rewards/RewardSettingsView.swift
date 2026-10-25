import SwiftUI
import UserNotifications

struct RewardSettingsView: View {
    var storage: LearnerStorageController
    @State private var baseline: RewardLedger?
    @State private var settings = RewardSettings()
    @State private var minutes = ""
    @State private var activities = ""
    @State private var breakMinutes = ""
    @State private var reminderTime = Date()
    @State private var message: String?
    @State private var saving = false
    var body: some View {
        Form {
            Section("Celebrations") {
                Picker("Celebrations", selection: $settings.celebration) {
                    ForEach(RewardSettings.Celebration.allCases, id: \.self) { Text($0.rawValue.capitalized).tag($0) }
                }.accessibilityIdentifier("rewards.celebrations")
                Toggle("Quiet rewards", isOn: $settings.quiet).accessibilityIdentifier("rewards.quiet")
                Text("Reduce Motion always wins. Quiet mode suppresses decorative motion, sound and haptics. Coach speech never starts automatically.")
                Toggle("Music", isOn: $settings.music)
                Toggle("Effects", isOn: $settings.effects)
                Toggle("Haptics", isOn: $settings.haptics)
            }
            Section("Continuity") {
                Toggle("Use owned Freezes automatically", isOn: $settings.autoFreeze)
                    .accessibilityIdentifier("rewards.auto-freeze")
                Text("One owned item per missed day. Buying items always requires an explicit gold confirmation. Protection does not create learning evidence.")
            }
            Section("Separate daily goals") {
                TextField("Active minutes, optional", text: $minutes).keyboardType(.numberPad).accessibilityIdentifier("rewards.goal.minutes")
                TextField("Activities, optional", text: $activities).keyboardType(.numberPad).accessibilityIdentifier("rewards.goal.activities")
                Text("Active time pauses in background or after 60 seconds without interaction, except uninterrupted learning audio. A chosen lesson plan can earn its bonus without meeting the time target.")
                TextField("Optional break timer, minutes", text: $breakMinutes).keyboardType(.numberPad)
                    .accessibilityIdentifier("rewards.break.minutes")
                Text("Timer starts only when you choose Start. Its static end notice leaves your exercise open and gives no reward.")
            }
            Section("Private reminders") {
                Toggle("Remind me about an unfinished goal", isOn: $settings.reminderEnabled).accessibilityIdentifier("rewards.reminders")
                if settings.reminderEnabled {
                    ForEach(1...7, id: \.self) { day in
                        Toggle(Calendar.current.weekdaySymbols[day-1], isOn: Binding(get: { settings.reminderWeekdays.contains(day) }, set: { selected in
                            settings.reminderWeekdays.removeAll { $0 == day }
                            if selected { settings.reminderWeekdays.append(day) }
                        }))
                    }
                    DatePicker("Reminder time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .onChange(of: reminderTime) { _, value in
                            settings.reminderHour = Calendar.current.component(.hour, from: value)
                            settings.reminderMinute = Calendar.current.component(.minute, from: value)
                        }
                }
                Text("Save asks permission only when enabled. One generic notification is scheduled, with no repeated nudges after it is ignored. Reopen and save to schedule another. No lesson, transcript or provider details appear on the lock screen.")
            }
            Section {
                Button(saving ? "Saving…" : "Save preferences") { save() }.disabled(baseline == nil || saving)
                    .accessibilityIdentifier("rewards.settings.save")
                if let message { Text(message).accessibilityIdentifier("rewards.settings.message") }
            }
        }.navigationTitle("Reward preferences").modifier(RewardDashboardFocus(storage: storage)).onAppear(perform: load)
    }
    private func load() {
        do {
            guard let repo = storage.repository else { throw LearnerStorageError.unavailable }
            let value = try repo.rewardLedger(); baseline = value; settings = value.settings
            minutes = value.settings.activeMinutesGoal.map(String.init) ?? ""
            activities = value.settings.activityGoal.map(String.init) ?? ""
            breakMinutes = value.settings.breakMinutes.map(String.init) ?? ""
            reminderTime = !settings.reminderEnabled && settings.reminderWeekdays.isEmpty ? .now : Calendar.current.date(bySettingHour: settings.reminderHour, minute: settings.reminderMinute, second: 0, of: .now) ?? .now
        } catch { message = "Preferences could not be loaded. Saved data is kept." }
    }
    private func number(_ text: String) throws -> Int? {
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return nil }
        guard let value = Int(text), value > 0 else { throw RewardError.invalidRequest }
        return value
    }
    private func save() {
        do {
            guard let baseline, let repo = storage.repository else { throw LearnerStorageError.unavailable }
            var value = settings
            value.activeMinutesGoal = try number(minutes); value.activityGoal = try number(activities); value.breakMinutes = try number(breakMinutes)
            value.reminderHour = Calendar.current.component(.hour, from: reminderTime)
            value.reminderMinute = Calendar.current.component(.minute, from: reminderTime)
            try value.validate()
            try repo.saveRewardSettings(value, expectedEpoch: baseline.epoch, expectedRevision: baseline.revision)
            let saved = try repo.rewardLedger(); self.baseline = saved; settings = value
            message = "Preferences saved."
            saving = true
            Task { @MainActor in
                defer { saving = false }
                do { try await RewardReminderScheduler.update(ledger: saved, isCurrent: {
                    guard let current = try? repo.rewardLedger(), current.epoch == saved.epoch,
                          current.settings == saved.settings else { return false }
                    return !RewardReminderScheduler.goalMet(current)
                }); message = "Preferences saved. Reminder availability follows your system permission." }
                catch { message = "Preferences saved, but no reminder could be scheduled. Check notification permission and save again." }
            }
        } catch { message = (error as? RewardError)?.message ?? "Nothing was saved. Reload preferences and try again." }
    }
}

/// One pending generic request. No repeating trigger and no foreground rescheduling after an ignored nudge.
enum RewardReminderScheduler {
    static let identifier = "SpeechCoachAI.private-goal-reminder"
    static func goalMet(_ ledger: RewardLedger, now: Date = .now, calendar: Calendar = .current) -> Bool {
        let today = RewardPolicy.day(now, calendar: calendar)
        let count = ledger.transactions.filter { $0.day == today && ["exercise","speaking","review"].contains($0.kind) }.count
        let settings = ledger.settings
        guard settings.activityGoal != nil || settings.activeMinutesGoal != nil else { return false }
        return (settings.activityGoal.map { count >= $0 } ?? true) &&
            (settings.activeMinutesGoal.map { ledger.activeSeconds[today, default: 0] >= Double($0 * 60) } ?? true)
    }
    static func update(ledger: RewardLedger, now: Date = .now, calendar: Calendar = .current, isCurrent: () -> Bool = { true }) async throws {
        let center = UNUserNotificationCenter.current()
        let id = "\(identifier)/\(ledger.epoch)/\(ledger.revision)"
        let pending = await center.pendingNotificationRequests()
        guard isCurrent() else { return }
        center.removePendingNotificationRequests(withIdentifiers: pending.filter { $0.identifier.hasPrefix(identifier) }.map(\.identifier))
        guard ledger.settings.reminderEnabled, !goalMet(ledger, now: now, calendar: calendar) else { return }
        guard try await center.requestAuthorization(options: [.alert, .badge]), isCurrent() else { return }
        guard let date = nextDate(settings: ledger.settings, now: now, calendar: calendar) else { return }
        let content = UNMutableNotificationContent()
        content.title = "A little practice"
        content.body = "Your unfinished practice goal is here when you are ready."
        let trigger = UNCalendarNotificationTrigger(dateMatching: calendar.dateComponents([.year,.month,.day,.hour,.minute], from: date), repeats: false)
        try await center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
        if !isCurrent() { center.removePendingNotificationRequests(withIdentifiers: [id]) }
    }
    static func cancelIfGoalMet(ledger: RewardLedger) {
        guard goalMet(ledger) || !ledger.settings.reminderEnabled else { return }
        let prefix = "\(identifier)/\(ledger.epoch)/"
        Task {
            let center = UNUserNotificationCenter.current()
            let requests = await center.pendingNotificationRequests()
            let ids = requests.filter { request in
                request.identifier.hasPrefix(prefix) && (Int(request.identifier.split(separator: "/").last ?? "") ?? Int.max) <= ledger.revision
            }.map(\.identifier)
            center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }
    static func nextDate(settings: RewardSettings, now: Date, calendar: Calendar) -> Date? {
        settings.reminderWeekdays.compactMap { weekday in
            calendar.nextDate(after: now, matching: DateComponents(hour: settings.reminderHour, minute: settings.reminderMinute, weekday: weekday), matchingPolicy: .nextTime)
        }.min()
    }
    static func cancel(epoch: UUID) {
        Task {
            let center = UNUserNotificationCenter.current()
            let requests = await center.pendingNotificationRequests()
            center.removePendingNotificationRequests(withIdentifiers: requests.filter { $0.identifier.hasPrefix("\(identifier)/\(epoch)/") }.map(\.identifier))
        }
    }
}
