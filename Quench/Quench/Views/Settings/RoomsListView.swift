import SwiftUI
import SwiftData

struct RoomsListView: View {
    @Environment(\.modelContext) private var context
    @Query private var rooms: [Room]
    @Query private var plants: [Plant]
    @State private var showAddRoom = false
    @State private var newRoomName = ""
    @State private var newRoomLight: LightLevel = .medium
    @State private var newRoomHumidity: HumidityLevel = .average

    var body: some View {
        List {
            Section("Rooms") {
                if rooms.isEmpty {
                    Text("No rooms yet. Add one to organize your plants.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(rooms) { room in
                        NavigationLink {
                            RoomDetailView(room: room)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(room.name)
                                    .font(.headline)
                                Text("\(room.plants.count) plant\(room.plants.count == 1 ? "" : "s") • \(room.lightLevel.rawValue) light • \(room.humidityLevel.rawValue) humidity")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: deleteRoom)
                }
            }
        }
        .navigationTitle("Rooms")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddRoom = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddRoom) {
            NavigationStack {
                Form {
                    Section("New Room") {
                        TextField("Name (e.g. Living Room)", text: $newRoomName)
                        Picker("Light Level", selection: $newRoomLight) {
                            ForEach(LightLevel.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                        }
                        Picker("Humidity", selection: $newRoomHumidity) {
                            ForEach(HumidityLevel.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                        }
                    }
                }
                .navigationTitle("Add Room")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") { showAddRoom = false }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Add") {
                            let room = Room(name: newRoomName, lightLevel: newRoomLight, humidityLevel: newRoomHumidity)
                            context.insert(room)
                            try? context.save()
                            newRoomName = ""
                            showAddRoom = false
                        }
                        .disabled(newRoomName.isEmpty)
                    }
                }
            }
        }
    }

    private func deleteRoom(at offsets: IndexSet) {
        for index in offsets {
            context.delete(rooms[index])
        }
        try? context.save()
    }
}

struct RoomDetailView: View {
    @Environment(\.modelContext) private var context
    let room: Room
    @State private var showPlantPicker = false

    var body: some View {
        Form {
            Section("Environment") {
                Picker("Light", selection: Binding(
                    get: { room.lightLevel },
                    set: { room.lightLevel = $0; try? context.save() }
                )) {
                    ForEach(LightLevel.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                Picker("Humidity", selection: Binding(
                    get: { room.humidityLevel },
                    set: { room.humidityLevel = $0; try? context.save() }
                )) {
                    ForEach(HumidityLevel.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
            }

            Section("Plants in this Room (\(room.plants.count))") {
                if room.plants.isEmpty {
                    Text("No plants assigned")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(room.plants) { plant in
                        Text(plant.nickname)
                    }
                }
            }
        }
        .navigationTitle(room.name)
    }
}
