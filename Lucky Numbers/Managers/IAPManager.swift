//
//  IAPManager.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/17/25.
//

import StoreKit

/// A singleton class to manage in-app purchases.
class IAPManager: NSObject, ObservableObject {
    
    /// Singleton instance
    static let shared = IAPManager()
    
    /// The product ID for removing ads
    private let removeAdsProductID = "remove_ads_199"  // Ensure this matches App Store Connect

    /// Tracks if the purchase was restored
    @Published var isPurchased: Bool = UserDefaults.standard.bool(forKey: "isAdRemoved")
    
    /// StoreKit product array
    private var products: [SKProduct] = []

    override init() {
        super.init()
        SKPaymentQueue.default().add(self) // Observe transactions
        fetchProducts() // Load available products
    }

    /// Fetch available IAP products from App Store
    func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: [removeAdsProductID])
        request.delegate = self
        request.start()
    }

    /// Attempts to purchase the "Remove Ads" product
    func buyRemoveAds(completion: (() -> Void)? = nil) {
        guard let product = products.first(where: { $0.productIdentifier == removeAdsProductID }) else {
            print("❌ Product not found.")
            return
        }
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        
        print("🛒 Attempting to purchase: \(product.localizedTitle)")
    }

    /// Restores previous purchases
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
        print("🔄 Restoring purchases...")
    }
}

// MARK: - StoreKit Delegates
extension IAPManager: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    /// Handles the response from fetching available IAP products
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.products = response.products
            for product in response.products {
                print("✅ Product Available: \(product.localizedTitle) - \(product.price)")
            }
        }
    }

    /// Handles transaction updates
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                print("✅ Purchase successful: \(transaction.payment.productIdentifier)")
                if transaction.payment.productIdentifier == removeAdsProductID {
                    completeRemoveAdsPurchase()
                }
                SKPaymentQueue.default().finishTransaction(transaction)

            case .restored:
                print("✅ Purchase restored: \(transaction.payment.productIdentifier)")
                if transaction.payment.productIdentifier == removeAdsProductID {
                    completeRemoveAdsPurchase()
                }
                SKPaymentQueue.default().finishTransaction(transaction)

            case .failed:
                if let error = transaction.error {
                    print("❌ Purchase failed: \(error.localizedDescription)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)

            default:
                break
            }
        }
    }

    /// Completes the "Remove Ads" purchase and updates the app state
    private func completeRemoveAdsPurchase() {
        UserDefaults.standard.set(true, forKey: "isAdRemoved")
        isPurchased = true
        AdManager.shared.removeAds()  // 🚀 Calls AdManager to remove ads
        print("🚀 Ads have been removed successfully!")
    }
}
