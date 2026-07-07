import SwiftUI
import SwiftData

struct AddPlantView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(PurchaseService.self) private var purchaseService
    @State private var viewModel = AddPlantViewModel()
    @State private var showImagePicker = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showSpeciesSearch = false
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Photo") {
                    HStack {
                        if let data = viewModel.photoData, let img = UIImage(data: data) {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.tertiarySystemFill))
                                .frame(width: 80, height: 80)
                                .overlay {
                                    Image(systemName: "camera")
                                        .foregroundStyle(.secondary)
                                }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Button {
                                imagePickerSourceType = .camera
                                showImagePicker = true
                            } label: {
                                Label("Take Photo", systemImage: "camera")
                                    .font(.subheadline)
                            }

                            Button {
                                imagePickerSourceType = .photoLibrary
                                showImagePicker = true
                            } label: {
                                Label("Choose Photo", systemImage: "photo")
                                    .font(.subheadline)
                            }
                        }
                    }

                    if viewModel.photoData != nil && purchaseService.purchasedAISubscription && AIService.shared.isConfigured {
                        Button {
                            Task {
                                await viewModel.identifyWithAI()
                            }
                        } label: {
                            if viewModel.isIdentifying {
                                ProgressView("Identifying...")
                            } else {
                                Label("Identify with AI", systemImage: "wand.and.stars")
                            }
                        }
                        .disabled(viewModel.isIdentifying)

                        if let err = viewModel.identifyError {
                            Text(err)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }

                Section("Plant") {
                    TextField("Nickname", text: $viewModel.nickname)

                    Button {
                        showSpeciesSearch = true
                    } label: {
                        HStack {
                            Text("Species")
                            Spacer()
                            if let species = viewModel.selectedSpecies {
                                Text(species.commonName)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("Select")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section("Watering") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Watering interval")
                            Spacer()
                            Text("\(viewModel.wateringInterval) days")
                                .foregroundStyle(.secondary)
                        }
                        Stepper(value: $viewModel.wateringInterval, in: 1...30) {
                            Text("Every \(viewModel.wateringInterval) day\(viewModel.wateringInterval > 1 ? "s" : "")")
                        }
                    }
                }

                if viewModel.photoData != nil && !purchaseService.purchasedAISubscription {
                    Section {
                        Button {
                            showPaywall = true
                        } label: {
                            Label("Unlock AI Plant Identification", systemImage: "wand.and.stars")
                        }
                    }
                }
            }
            .navigationTitle("Add Plant")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        if viewModel.savePlant(context: context) != nil {
                            dismiss()
                        }
                    }
                    .disabled(viewModel.selectedSpecies == nil && viewModel.nickname.isEmpty)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: imagePickerSourceType) { data in
                    viewModel.photoData = data
                }
            }
            .sheet(isPresented: $showSpeciesSearch) {
                SpeciesSearchView(selectedSpecies: $viewModel.selectedSpecies, onSelected: { profile in
                    viewModel.selectSpecies(profile)
                    showSpeciesSearch = false
                })
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}
