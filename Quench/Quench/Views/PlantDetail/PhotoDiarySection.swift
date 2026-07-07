import SwiftUI

struct PhotoDiarySection: View {
    let plant: Plant
    var onAddPhoto: () -> Void

    private var sortedPhotos: [PlantPhoto] {
        plant.photos.sorted { $0.date > $1.date }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Photo Diary")
                    .font(.headline)
                Spacer()
                Button {
                    onAddPhoto()
                } label: {
                    Label("Add", systemImage: "plus.circle.fill")
                        .font(.subheadline)
                }
            }

            if sortedPhotos.isEmpty {
                Text("Track growth over time by adding photos")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(sortedPhotos) { photo in
                            VStack {
                                if let img = UIImage(data: photo.imageData) {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                Text(photo.date.formatted(dateStyle: .short))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}
