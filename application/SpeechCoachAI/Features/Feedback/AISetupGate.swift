import SwiftUI

/// Phase 12: AI entry points always show. Without a provider key, tapping one opens the key setup;
/// `isReady` is checked again when the setup sheet closes.
struct AISetupLink<Destination: View, Label: View>: View {
    var isReady: () -> Bool
    @ViewBuilder var destination: () -> Destination
    @ViewBuilder var label: () -> Label
    @State private var ready = false
    @State private var setup = false

    var body: some View {
        Group {
            if ready {
                NavigationLink(destination: destination, label: label)
            } else {
                Button(action: { setup = true }, label: label)
            }
        }
        .aiSetupSheet(isPresented: $setup) { ready = isReady() }
        .onAppear { ready = isReady() }
    }
}

/// The provider setup in a sheet with a Done button.
struct AISetupSheet: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ProviderSettingsView()
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }.accessibilityIdentifier("ai.setup.done")
                    }
                }
        }
    }
}

extension View {
    func aiSetupSheet(isPresented: Binding<Bool>, onDismiss: @escaping () -> Void = {}) -> some View {
        sheet(isPresented: isPresented, onDismiss: onDismiss) { AISetupSheet() }
    }
}
