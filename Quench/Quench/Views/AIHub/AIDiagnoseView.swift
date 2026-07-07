import SwiftUI

struct AIDiagnoseView: View {
    @State private var viewModel = AIHubViewModel()
    @State private var photoData: Data? = nil
    @State private var showImagePicker = false
    @State private var plantContext: String = ""

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

                TextField("Plant name / context (optional)", text: $plantContext)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                if photoData != nil && viewModel.diagnosis == nil && !viewModel.isProcessing {
                    Button {
                        Task { await viewModel.diagnose(imageData: photoData!, plantContext: plantContext) }
                    } label: {
                        Label("Diagnose", systemImage: "heart.text.square")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppTheme.urgentRed)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal)
                }

                if viewModel.isProcessing {
                    ProgressView("Diagnosing...")
                        .padding()
                }

                if let err = viewModel.errorMessage {
                    Text(err)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                if let diag = viewModel.diagnosis {
                    DiagnosisResultCard(diagnosis: diag)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Diagnose Health")
        .sheet(isPresented: $showImagePicker) {
            ImagePicker { data in
                photoData = data
                viewModel.diagnosis = nil
                viewModel.errorMessage = nil
            }
        }
    }
}

struct DiagnosisResultCard: View {
    let diagnosis: HealthDiagnosis

    var severityColor: Color {
        switch diagnosis.severity.lowercased() {
        case "low": return AppTheme.plantGreen
        case "medium": return AppTheme.soonOrange
        case "high": return AppTheme.urgentRed
        default: return AppTheme.quenchBlue
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Diagnosis")
                .font(.headline)

            Text(diagnosis.diagnosis)
                .font(.title3.bold())

            HStack {
                Label(diagnosis.severity, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(severityColor)
                Spacer()
                Text("Urgency: \(diagnosis.urgency)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            Text("Treatment Plan")
                .font(.subheadline.weight(.semibold))

            ForEach(diagnosis.treatmentSteps, id: \.self) { step in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 5))
                        .padding(.top, 6)
                    Text(step)
                        .font(.caption)
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
