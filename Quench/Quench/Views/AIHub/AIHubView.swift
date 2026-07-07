import SwiftUI

struct AIHubView: View {
    @Environment(PurchaseService.self) private var purchaseService
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            Group {
                if !purchaseService.purchasedAISubscription {
                    LockedAIHubView(onUnlock: { showPaywall = true })
                } else if !AIService.shared.isConfigured {
                    APIKeyPromptView()
                } else {
                    AIHubUnlockedView()
                }
            }
            .navigationTitle("AI Plant Doctor")
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}

struct LockedAIHubView: View {
    var onUnlock: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "stethoscope")
                .font(.system(size: 64))
                .foregroundStyle(AppTheme.quenchBlue)

            Text("AI Plant Doctor")
                .font(.title.bold())

            Text("Identify plants, diagnose health issues, and chat with an AI plant coach. Bring your own OpenAI API key — no per-generation limits.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 12) {
                FeatureBullet(icon: "wand.and.stars", text: "AI Plant Identification")
                FeatureBullet(icon: "heart.text.square", text: "Health Diagnosis & Treatment Plans")
                FeatureBullet(icon: "bubble.left.and.bubble.right", text: "AI Coach — answers to plant questions")
            }
            .padding()

            Button("Unlock AI Plant Doctor") {
                onUnlock()
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.quenchBlue)
            .padding()
        }
        .padding()
    }
}

struct FeatureBullet: View {
    let icon: String
    let text: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 28)
                .foregroundStyle(AppTheme.quenchBlue)
            Text(text)
        }
    }
}

struct APIKeyPromptView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "key.fill")
                .font(.system(size: 56))
                .foregroundStyle(AppTheme.quenchBlue)

            Text("Add Your OpenAI API Key")
                .font(.title3.bold())

            Text("Quench uses a Bring Your Own Key model. Your key is stored securely in Keychain and never sent to Quench servers.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            NavigationLink {
                APIKeyView()
            } label: {
                Text("Add API Key")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.quenchBlue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal)

            Link("Get an OpenAI API key",
                 destination: URL(string: "https://platform.openai.com/api-keys")!)
                .font(.caption)
        }
        .padding()
    }
}

struct AIHubUnlockedView: View {
    var body: some View {
        List {
            Section("AI Tools") {
                NavigationLink {
                    AIIdentifyView()
                } label: {
                    Label("Identify Plant", systemImage: "wand.and.stars")
                }
                NavigationLink {
                    AIDiagnoseView()
                } label: {
                    Label("Diagnose Health", systemImage: "heart.text.square")
                }
                NavigationLink {
                    AICoachChatView()
                } label: {
                    Label("AI Coach Chat", systemImage: "bubble.left.and.bubble.right")
                }
            }

            Section("API Key") {
                NavigationLink {
                    APIKeyView()
                } label: {
                    Label("Manage OpenAI Key", systemImage: "key")
                }
            }
        }
    }
}
