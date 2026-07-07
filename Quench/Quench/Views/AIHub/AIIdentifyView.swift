import SwiftUI

struct AIIdentifyView: View {
    @State private var viewModel = AIHubViewModel()
    @State private var photoData: Data? = nil
    @State private var showImagePicker = false

    var body: some View {
    ScrollView {
            VStack(spacing: 16) {
                if let data = photoData, let img = UIImage(data: data) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                }

                Button {
                    showImagePicker = true
                } label: {
                    Label(photoData == nil ? "Choose Photo" : "Change Photo", systemImage: "photo")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.quenchBlue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal)
                .disabled(viewModel.isProcessing)

                if photoData != nil && viewModel.identification == nil && !viewModel.isProcessing {
                    Button {
                        Task { await viewModel.identify(imageData: photoData!) }
                    } label: {
                        Label("Identify Plant", systemImage: "wand.and.stars")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppTheme.plantGreen)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal)
                }

                if viewModel.isProcessing {
                    ProgressView("Identifying...")
                        .padding()
                }

                if let err = viewModel.errorMessage {
                    Text(err)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                if let id = viewModel.identification {
                    IdentificationResultCard(identification: id)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Identify Plant")
        .sheet(isPresented: $showImagePicker) {
            ImagePicker { data in
                photoData = data
                viewModel.identification = nil
                viewModel.errorMessage = nil
            }
        }
    }
}

struct IdentificationResultCard: View {
    let identification: PlantIdentification

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Result")
                .font(.headline)

            HStack {
                Text("Common Name")
                Spacer()
                Text(identification.commonName)
                    .bold()
            }
            HStack {
                Text("Species")
                Spacer()
                Text(identification.species)
                    .italic()
            }
            HStack {
                Text("Confidence")
                Spacer()
                Text(String(format: "%.0f%%", identification.confidence * 100))
                    .foregroundStyle(identification.confidence > 0.7 ? AppTheme.plantGreen : AppTheme.soonOrange)
            }
            HStack {
                Text("Watering")
                Spacer()
                Text("Every \(identification.wateringFrequencyDays) days")
            }
            HStack {
                Text("Light")
                Spacer()
                Text(identification.lightNeeds)
            }

            if !identification.careTips.isEmpty {
                Divider()
                Text(identification.careTips)
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
