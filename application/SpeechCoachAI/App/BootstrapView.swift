import SwiftUI

/// Engineering launch surface for SC-T008. Product navigation belongs to SC-T010.
struct BootstrapView: View {
    var storageFailure = false
    var retryStorage: () -> Void = {}
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("SpeechCoachAI")
                    .font(.largeTitle.bold())
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("bootstrap.title")

                Text("English practice, one step at a time.")
                    .font(.title2)

                Text("Practice features are coming soon.")
                    .font(.body)
                    .accessibilityIdentifier("bootstrap.availability")
                if storageFailure {
                    Text("Local data is unavailable. Unlock your device and try again. Your existing data has been kept.")
                        .font(.body)
                        .accessibilityIdentifier("storage.unavailable")
                    Button("Try Again", action: retryStorage)
                }
            }
            .frame(maxWidth: 600, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}
