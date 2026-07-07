import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Plant.createdAt, order: .reverse) private var plants: [Plant]
    @State private var viewModel = DashboardViewModel()
    @State private var showAddPlant = false

    var body: some View {
        NavigationStack {
            ScrollView {
                if plants.isEmpty {
                    EmptyStateView(
                        icon: "leaf",
                        title: "No plants yet",
                        subtitle: "Add your first plant to start getting reminders",
                        actionTitle: "Add Plant",
                        action: { showAddPlant = true }
                    )
                } else {
                    VStack(spacing: 16) {
                        if !viewModel.plantsNeedingWater.isEmpty {
                            TodayTasksCard(
                                plants: viewModel.plantsNeedingWater,
                                onWater: { plant in
                                    viewModel.quickWater(plant: plant, context: context)
                                }
                            )
                        } else {
                            AllGoodCard(nextPlant: viewModel.upcomingPlant)
                        }

                        PlantGridView(plants: plants)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(Date().greeting)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddPlant = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddPlant) {
                AddPlantView()
            }
            .overlay {
                WateredAnimation(isShown: $viewModel.showWateredAnimation) {
                    viewModel.undoWater(context: context)
                }
            }
            .onAppear {
                viewModel.update(plants: plants)
            }
            .onChange(of: plants.count) { _, _ in
                viewModel.update(plants: plants)
            }
            .onChange(of: plants.compactMap(\.lastWateredDate).last) { _, _ in
                viewModel.update(plants: plants)
            }
        }
    }
}

struct PlantsListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Plant.createdAt, order: .reverse) private var plants: [Plant]
    @State private var showAddPlant = false

    var body: some View {
        NavigationStack {
            Group {
                if plants.isEmpty {
                    EmptyStateView(
                        icon: "leaf",
                        title: "No plants yet",
                        subtitle: "Tap the + button to add your first plant",
                        actionTitle: "Add Plant",
                        action: { showAddPlant = true }
                    )
                } else {
                    List {
                        ForEach(plants) { plant in
                            NavigationLink {
                                PlantDetailView(plant: plant)
                            } label: {
                                PlantRow(plant: plant)
                            }
                        }
                        .onDelete(perform: deletePlant)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("My Plants")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddPlant = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddPlant) {
                AddPlantView()
            }
        }
    }

    private func deletePlant(at offsets: IndexSet) {
        for index in offsets {
            context.delete(plants[index])
        }
        try? context.save()
    }
}

struct PlantRow: View {
    let plant: Plant

    var body: some View {
        HStack(spacing: 12) {
            if let data = plant.photoData, let img = UIImage(data: data) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.plantGreen.opacity(0.2))
                    .frame(width: 56, height: 56)
                    .overlay {
                        Image(systemName: "leaf.fill")
                            .foregroundStyle(AppTheme.plantGreen)
                    }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(plant.nickname)
                    .font(.headline)
                Text(plant.commonName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            StatusBadge(daysUntilWater: plant.daysUntilWater, streak: ScheduleEngine.streak(for: plant))
        }
        .padding(.vertical, 4)
    }
}
