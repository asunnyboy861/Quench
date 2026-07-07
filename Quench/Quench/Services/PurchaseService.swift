import Foundation
import StoreKit
import Observation

@Observable
final class PurchaseService {
    static let shared = PurchaseService()

    static let lifetimeID = "com.zzoutuo.Quench.lifetime"
    static let aiMonthlyID = "com.zzoutuo.Quench.ai.monthly"
    static let aiYearlyID = "com.zzoutuo.Quench.ai.yearly"
    static let aiLifetimeID = "com.zzoutuo.Quench.ai.lifetime"

    static let allProductIDs: Set<String> = [lifetimeID, aiMonthlyID, aiYearlyID, aiLifetimeID]

    var purchasedLifetime: Bool = false
    var purchasedAISubscription: Bool = false
    var purchasedAILifetime: Bool = false
    var products: [Product] = []
    var isLoading: Bool = false

    private var transactionListener: Task<Void, Never>?

    private init() {
        transactionListener = listenForTransactions()
        Task {
            await loadProducts()
            await updateEntitlements()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let storeProducts = try await Product.products(for: PurchaseService.allProductIDs)
            self.products = storeProducts.sorted { $0.price < $1.price }
        } catch {
            self.products = []
        }
    }

    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updateEntitlements()
                await transaction.finish()
                return true
            case .userCancelled, .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            return false
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updateEntitlements()
        } catch {
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified:
            throw StoreError.unverified
        }
    }

    private func updateEntitlements() async {
        var lifetime = false
        var aiSub = false
        var aiLifetime = false

        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                if transaction.productID == PurchaseService.lifetimeID {
                    lifetime = true
                }
                if transaction.productID == PurchaseService.aiMonthlyID || transaction.productID == PurchaseService.aiYearlyID {
                    aiSub = true
                }
                if transaction.productID == PurchaseService.aiLifetimeID {
                    aiLifetime = true
                }
            }
        }

        self.purchasedLifetime = lifetime
        self.purchasedAISubscription = aiSub || aiLifetime
        self.purchasedAILifetime = aiLifetime

        UserDefaults.standard.set(lifetime, forKey: "purchasedLifetime")
        UserDefaults.standard.set(aiSub || aiLifetime, forKey: "purchasedAISubscription")
        UserDefaults.standard.set(aiLifetime, forKey: "purchasedAILifetime")
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self?.updateEntitlements()
                }
            }
        }
    }

    enum StoreError: Error {
        case unverified
    }
}
