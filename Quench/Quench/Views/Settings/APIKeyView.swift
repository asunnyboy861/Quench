import SwiftUI

struct APIKeyView: View {
    @State private var viewModel = SettingsViewModel()
    @Environment(PurchaseService.self) private var purchaseService

    var body: some View {
        Form {
            Section {
                Text("Quench uses a Bring Your Own Key model. Your OpenAI API key is stored securely in your device's Keychain and never transmitted to Quench servers.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Current Key") {
                if viewModel.apiKeyMasked.isEmpty {
                    Text("No key configured")
                        .foregroundStyle(.secondary)
                } else {
                    Text(viewModel.apiKeyMasked)
                        .font(.subheadline.monospaced())
                }
            }

            Section("Add Key") {
                SecureField("sk-...", text: $viewModel.apiKeyInput)
                    .autocapitalization(.none)

                Button("Save Key") {
                    viewModel.saveAPIKey()
                }
                .disabled(viewModel.apiKeyInput.count < 10)
            }

            Section("Actions") {
                Button {
                    Task { await viewModel.validateKey() }
                } label: {
                    if viewModel.isValidating {
                        ProgressView("Validating...")
                    } else {
                        Label("Validate Key", systemImage: "checkmark.shield")
                    }
                }
                .disabled(viewModel.apiKeyMasked.isEmpty || viewModel.isValidating)

                Button(role: .destructive) {
                    viewModel.removeAPIKey()
                } label: {
                    Label("Remove Key", systemImage: "trash")
                }
                .disabled(viewModel.apiKeyMasked.isEmpty)
            }

            if let msg = viewModel.validationMessage {
                Section {
                    Text(msg)
                        .foregroundStyle(msg.contains("valid") && !msg.contains("invalid") ? AppTheme.plantGreen : AppTheme.urgentRed)
                }
            }

            Section {
                Link("Get an OpenAI API key", destination: URL(string: "https://platform.openai.com/api-keys")!)
            }
        }
        .navigationTitle("OpenAI API Key")
        .onAppear {
            viewModel.loadAPIKey()
        }
    }
}
