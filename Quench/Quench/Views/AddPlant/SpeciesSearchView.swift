import SwiftUI

struct SpeciesSearchView: View {
    @Binding var selectedSpecies: CareProfile?
    var onSelected: (CareProfile) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var query: String = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(SpeciesDatabase.shared.search(query: query)) { profile in
                    Button {
                        selectedSpecies = profile
                        onSelected(profile)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(profile.commonName)
                                .font(.headline)
                            Text(profile.scientificName)
                                .font(.caption.italic())
                                .foregroundStyle(.secondary)
                            HStack {
                                Label("\(profile.wateringFrequencyDays)d", systemImage: "drop")
                                Label(profile.lightRequirement, systemImage: "sun.max")
                                Label(profile.toxicity, systemImage: profile.toxicity == "Non-toxic" ? "checkmark.circle" : "exclamationmark.triangle")
                            }
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .searchable(text: $query, prompt: "Search 178+ species")
            .navigationTitle("Species")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
