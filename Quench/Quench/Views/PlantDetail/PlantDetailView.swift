import SwiftUI
import SwiftData

struct PlantDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(PurchaseService.self) private var purchaseService
    let plant: Plant
    @State private var viewModel = PlantDetailViewModel()
    @State private var showEditName = false
    @State private var editName: String = ""
    @State private var showDeleteConfirm = false
    @State private var showAddPhoto = false
    @State private var showImagePicker = false
    @State private var showPaywall = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                PlantHeaderCard(plant: plant, onEditName: {
                    editName = plant.nickname
                    showEditName = true
                })

                WaterButton {
                    viewModel.quickWater(plant: plant, context: context)
                }
                .padding(.horizontal)

                WhyScheduleCard(plant: plant, viewModel: viewModel, showPaywall: $showPaywall)

                WateringHistorySection(plant: plant)

                if purchaseService.purchasedLifetime {
                    PhotoDiarySection(plant: plant, onAddPhoto: {
                        showImagePicker = true
                    })
                } else {
                    LockedSection(
                        icon: "photo.stack",
                        title: "Photo Diary",
                        subtitle: "Track growth over time with photos",
                        action: { showPaywall = true }
                    )
                }

                CareInfoCard(plant: plant)
            }
            .padding(.vertical, 12)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(plant.nickname)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        editName = plant.nickname
                        showEditName = true
                    } label: {
                        Label("Rename", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Label("Delete Plant", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("Rename Plant", isPresented: $showEditName) {
            TextField("Nickname", text: $editName)
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                viewModel.updateNickname(editName, for: plant, context: context)
            }
        }
        .alert("Delete Plant?", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                viewModel.deletePlant(plant, context: context)
                dismiss()
            }
        } message: {
            Text("This will permanently delete \(plant.nickname) and all watering history.")
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker { data in
                viewModel.addPhoto(data, note: "", to: plant, context: context)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .overlay {
            WateredAnimation(isShown: $viewModel.showWateredAnimation)
        }
        .sheet(isPresented: $viewModel.showSoilCheckIn) {
            SoilCheckInView(viewModel: viewModel)
        }
    }
}

struct PlantHeaderCard: View {
    let plant: Plant
    var onEditName: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            if let data = plant.photoData, let img = UIImage(data: data) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppTheme.plantGreen.opacity(0.15))
                    .frame(height: 200)
                    .overlay {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(AppTheme.plantGreen)
                    }
            }

            VStack(spacing: 4) {
                Text(plant.commonName)
                    .font(.caption.italic())
                    .foregroundStyle(.secondary)
                Text("Next water in \(plant.daysUntilWater) day\(abs(plant.daysUntilWater) == 1 ? "" : "s")")
                    .font(.headline)
                    .foregroundStyle(AppTheme.statusColor(daysUntilWater: plant.daysUntilWater))

                let streak = ScheduleEngine.streak(for: plant)
                if streak > 0 {
                    Text("🔥 \(streak) day streak")
                        .font(.caption.bold())
                        .foregroundStyle(AppTheme.plantGreen)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct CareInfoCard: View {
    let plant: Plant

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Care Info")
                .font(.headline)

            CareInfoRow(label: "Light", value: plant.lightNeeds, icon: "sun.max")
            CareInfoRow(label: "Humidity", value: plant.humidityNeeds, icon: "humidity")
            CareInfoRow(label: "Toxicity", value: plant.toxicity, icon: "exclamationmark.triangle")

            if !plant.careTips.isEmpty {
                Divider()
                Text(plant.careTips)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

struct CareInfoRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundStyle(AppTheme.quenchBlue)
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
        }
    }
}

struct LockedSection: View {
    let icon: String
    let title: String
    let subtitle: String
    var action: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "lock.fill")
                    .foregroundStyle(.secondary)
            }
            Button("Unlock with Premium", action: action)
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.quenchBlue)
                .frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

struct SoilCheckInView: View {
    var viewModel: PlantDetailViewModel
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var soil: SoilMoisture? = nil
    @State private var leaf: LeafStatus? = nil

    var body: some View {
        NavigationStack {
            Form {
                Section("Soil Moisture (optional)") {
                    ForEach(SoilMoisture.allCases, id: \.self) { moisture in
                        Button {
                            soil = moisture
                        } label: {
                            HStack {
                                Text(moisture.rawValue)
                                Spacer()
                                if soil == moisture {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                Section("Leaf Status (optional)") {
                    ForEach(LeafStatus.allCases, id: \.self) { status in
                        Button {
                            leaf = status
                        } label: {
                            HStack {
                                Text(status.rawValue)
                                Spacer()
                                if leaf == status {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Quick Check-in")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Skip") {
                        viewModel.showSoilCheckIn = false
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        viewModel.setSoilCheckIn(soil, leaf: leaf, context: context)
                        dismiss()
                    }
                }
            }
        }
    }
}
