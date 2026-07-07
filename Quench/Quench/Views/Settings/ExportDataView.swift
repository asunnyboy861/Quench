import SwiftUI

struct ExportDataView: View {
    @State private var showShareSheet = false
    @State private var exportURL: URL? = nil

    var body: some View {
        Form {
            Section("Export") {
                Text("Export all your plant data, watering history, and rooms to a JSON file. This file can be used for backup or transferred to another device.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Export Data")
    }
}
