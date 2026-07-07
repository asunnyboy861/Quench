import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(PurchaseService.self) private var purchaseService
    @State private var viewModel = PurchaseViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Image(systemName: "drop.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(AppTheme.quenchBlue)

                        Text("Unlock Quench")
                            .font(.largeTitle.bold())

                        Text("One-time purchase. No subscriptions required for core features.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    if purchaseService.isLoading {
                        ProgressView()
                    } else {
                        VStack(spacing: 12) {
                            ForEach(purchaseService.products, id: \.id) { product in
                                ProductCard(product: product, isPurchasing: viewModel.isPurchasing) {
                                    Task {
                                        await viewModel.purchase(product: product)
                                        if viewModel.purchaseSuccess {
                                            dismiss()
                                        }
                                    }
                                }
                            }
                        }

                        Button {
                            Task { await viewModel.restore() }
                        } label: {
                            Text("Restore Purchases")
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.quenchBlue)
                        }
                    }

                    if let err = viewModel.purchaseError {
                        Text(err)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    VStack(spacing: 8) {
                        Text("Subscription auto-renews unless cancelled at least 24 hours before the end of the current period. Manage in your App Store account settings.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        HStack {
                            Link("Privacy Policy", destination: URL(string: "https://asunnyboy861.github.io/Quench/privacy.html")!)
                            Text("•")
                            Link("Terms of Use", destination: URL(string: "https://asunnyboy861.github.io/Quench/terms.html")!)
                        }
                        .font(.caption2)
                        .foregroundStyle(AppTheme.quenchBlue)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Quench Premium")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

struct ProductCard: View {
    let product: Product
    let isPurchasing: Bool
    var action: () -> Void

    var displayName: String {
        product.displayName
    }

    var isLifetime: Bool {
        product.id == PurchaseService.lifetimeID || product.id == PurchaseService.aiLifetimeID
    }

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(displayName)
                        .font(.headline)
                    Text(product.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                    if isLifetime {
                        Text("Lifetime — pay once")
                            .font(.caption2.bold())
                            .foregroundStyle(AppTheme.plantGreen)
                    }
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(product.displayPrice)
                        .font(.headline)
                    if isPurchasing {
                        ProgressView()
                            .padding(.top, 4)
                    }
                }
            }
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .disabled(isPurchasing)
    }
}
