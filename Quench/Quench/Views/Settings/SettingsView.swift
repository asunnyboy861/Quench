import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(PurchaseService.self) private var purchaseService
    @State private var viewModel = SettingsViewModel()
    @Query private var plants: [Plant]
    @Query private var rooms: [Room]
    @State private var showPaywall = false
    @State private var showShareSheet = false
    @State private var exportURL: URL? = nil

    var body: some View {
        NavigationStack {
            Form {
                Section("Premium") {
                    if !purchaseService.purchasedLifetime {
                        Button {
                            showPaywall = true
                        } label: {
                            Label("Unlock Premium ($3.99)", systemImage: "star.fill")
                        }
                    } else {
                        Label("Premium Unlocked", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(AppTheme.plantGreen)
                    }

                    if !purchaseService.purchasedAISubscription {
                        Button {
                            showPaywall = true
                        } label: {
                            Label("Unlock AI Plant Doctor", systemImage: "stethoscope")
                        }
                    } else {
                        Label("AI Plant Doctor Active", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(AppTheme.plantGreen)
                    }

                    Button {
                        showPaywall = true
                    } label: {
                        Label("Manage Subscriptions", systemImage: "creditcard")
                    }
                }

                Section("Notifications") {
                    NavigationLink {
                        NotificationTimeView()
                    } label: {
                        Label("Notification Time", systemImage: "clock")
                    }

                    Button {
                        NotificationService.shared.scheduleTestNotification()
                    } label: {
                        Label("Send Test Notification", systemImage: "bell.badge")
                    }

                    if UserDefaults.standard.bool(forKey: "notificationPermissionAsked") {
                        Label("Reminders require notification permission", systemImage: "info.circle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Plants & Rooms") {
                    NavigationLink {
                        RoomsListView()
                    } label: {
                        Label("Rooms", systemImage: "door.left.hand.open")
                    }

                    NavigationLink {
                        SpeciesBrowseView()
                    } label: {
                        Label("Browse 178+ Species", systemImage: "leaf")
                    }
                }

                Section("AI") {
                    NavigationLink {
                        APIKeyView()
                    } label: {
                        Label("OpenAI API Key", systemImage: "key")
                    }
                    NavigationLink {
                        AIHubView()
                    } label: {
                        Label("AI Plant Doctor", systemImage: "stethoscope")
                    }
                }

                Section("Data & Theme") {
                    Button {
                        if let url = viewModel.exportData(plants: plants, rooms: rooms) {
                            exportURL = url
                            showShareSheet = true
                        }
                    } label: {
                        Label("Export Data (JSON)", systemImage: "square.and.arrow.up")
                    }
                    .disabled(plants.isEmpty)

                    NavigationLink {
                        ThemePickerView()
                    } label: {
                        Label("Theme", systemImage: "paintbrush")
                    }
                }

                Section("Support") {
                    NavigationLink {
                        ContactSupportView(viewModel: viewModel)
                    } label: {
                        Label("Contact Support", systemImage: "envelope")
                    }

                    Link(destination: URL(string: "https://asunnyboy861.github.io/Quench/support.html")!) {
                        Label("Support Page", systemImage: "questionmark.circle")
                    }
                    Link(destination: URL(string: "https://asunnyboy861.github.io/Quench/privacy.html")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                    Link(destination: URL(string: "https://asunnyboy861.github.io/Quench/terms.html")!) {
                        Label("Terms of Use", systemImage: "doc.text")
                    }
                }

                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                }
            }
            .onAppear {
                viewModel.loadAPIKey()
            }
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct SpeciesBrowseView: View {
    @State private var query: String = ""

    var body: some View {
        List {
            ForEach(SpeciesDatabase.shared.search(query: query)) { profile in
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.commonName)
                        .font(.headline)
                    Text(profile.scientificName)
                        .font(.caption.italic())
                        .foregroundStyle(.secondary)
                    Text("Water every \(profile.wateringFrequencyDays) days • \(profile.lightRequirement) light")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .searchable(text: $query, prompt: "Search species")
        .navigationTitle("Species Database")
    }
}

struct ContactSupportView: View {
    @Bindable var viewModel: SettingsViewModel

    var body: some View {
        Form {
            Section("Your Info") {
                TextField("Name", text: $viewModel.feedbackName)
                TextField("Email", text: $viewModel.feedbackEmail)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }

            Section("Message") {
                TextEditor(text: $viewModel.feedbackMessage)
                    .frame(minHeight: 120)
            }

            if let status = viewModel.feedbackStatus {
                Section {
                    Text(status)
                        .foregroundStyle(status.contains("Thank") ? AppTheme.plantGreen : AppTheme.urgentRed)
                }
            }

            Section {
                Button("Send Feedback") {
                    viewModel.sendFeedback()
                }
                .disabled(viewModel.feedbackName.isEmpty || viewModel.feedbackEmail.isEmpty || viewModel.feedbackMessage.isEmpty)
            }
        }
        .navigationTitle("Contact Support")
    }
}
