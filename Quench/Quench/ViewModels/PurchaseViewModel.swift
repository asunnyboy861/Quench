import Foundation
import StoreKit
import SwiftUI
import Observation

@Observable
final class PurchaseViewModel {
    var isPurchasing: Bool = false
    var purchaseError: String? = nil
    var purchaseSuccess: Bool = false

    func purchase(product: Product) async {
        isPurchasing = true
        purchaseError = nil
        defer { isPurchasing = false }

        let success = await PurchaseService.shared.purchase(product)
        if success {
            purchaseSuccess = true
            Haptics.success()
        } else {
            purchaseError = "Purchase failed or was cancelled"
        }
    }

    func restore() async {
        isPurchasing = true
        defer { isPurchasing = false }
        await PurchaseService.shared.restorePurchases()
    }
}
