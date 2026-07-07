import SwiftUI

struct WhyScheduleCard: View {
    let plant: Plant
    var viewModel: PlantDetailViewModel
    @Binding var showPaywall: Bool
    @Environment(PurchaseService.self) private var purchaseService

    var body: some View {
        let result = viewModel.scheduleExplanation(for: plant)

        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "questionmark.circle")
                    .foregroundStyle(AppTheme.quenchBlue)
                Text("Why this schedule?")
                    .font(.headline)
                Spacer()
            }

            Text("Effective interval: **\(result.effectiveInterval) days**")
                .font(.subheadline)

            ForEach(result.factors, id: \.self) { factor in
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 4))
                        .foregroundStyle(.secondary)
                        .padding(.top, 6)
                    Text(factor)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !purchaseService.purchasedLifetime {
                Button {
                    showPaywall = true
                } label: {
                    Label("Enable Weather & Room for smarter schedules", systemImage: "sparkles")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .tint(AppTheme.quenchBlue)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}
