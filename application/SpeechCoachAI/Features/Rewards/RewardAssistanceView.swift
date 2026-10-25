import SwiftUI

/// Optional priced aids never replace the existing free comparison/correction/retry path.
struct RewardAssistanceView: View {
    var storage: LearnerStorageController
    var context: String
    var hint: String
    var example: String
    @State private var quote: RewardPurchase?
    @State private var answer: String?
    @State private var message: String?
    @State private var balance = 0
    @State private var isHint = true
    var body: some View {
        DisclosureGroup("Optional extra help") {
            VStack(alignment: .leading, spacing: 10) {
                Text("The normal explanation, compare/retry controls and accessibility help stay free.")
                    .font(.footnote).foregroundStyle(Kit.secondary)
                Button("Optional hint · first 3 per day free, then 2 gold") { prepare(.hint) }
                    .frame(minHeight: 44).accessibilityIdentifier("rewards.hint")
                Button("Extra worked example · 4 gold") { prepare(.example) }
                    .frame(minHeight: 44).accessibilityIdentifier("rewards.example")
                if let answer { Text(answer).accessibilityIdentifier("rewards.help.result") }
                if let message { Text(message).foregroundStyle(Kit.error).accessibilityIdentifier("rewards.help.error") }
            }
        }
        .onChange(of: context) { _, _ in quote = nil; answer = nil; message = nil }
        .alert("Use optional help?", isPresented: Binding(get: { quote != nil }, set: { if !$0 { quote = nil } })) {
            Button("Confirm \(quote?.cost ?? 0) gold") {
                guard let quote else { return }; self.quote = nil
                do {
                    guard let repo = storage.repository else { throw LearnerStorageError.unavailable }
                    try repo.purchaseReward(quote)
                    answer = isHint ? hint : example
                    message = nil
                } catch { message = (error as? RewardError)?.message ?? "Nothing was spent. Keep using free explanations and retries, or try again." }
            }.accessibilityIdentifier("rewards.help.confirm")
            Button("Cancel", role: .cancel) { quote = nil }
        } message: {
            Text("Cost: \(quote?.cost ?? 0) gold. Remaining: \(balance - (quote?.cost ?? 0)) gold. This is optional; ordinary correction and retry are free.")
        }
    }
    private func prepare(_ kind: RewardPurchase.Kind) {
        do {
            guard let repo = storage.repository else { throw LearnerStorageError.unavailable }
            let ledger = try repo.rewardLedger(); balance = ledger.gold
            if ledger.transactions.contains(where: { $0.activity == context && $0.kind == kind.rawValue }) {
                answer = kind == .hint ? hint : example; message = "Previously opened · no additional charge"; return
            }
            quote = try ledger.quote(kind, day: RewardPolicy.day(.now), context: context)
            isHint = kind == .hint; message = nil
        } catch { message = (error as? RewardError)?.message ?? "Help could not be opened. Free correction and retry remain available." }
    }
}

