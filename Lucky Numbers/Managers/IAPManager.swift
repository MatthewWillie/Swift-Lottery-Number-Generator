//
//  IAPManager.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/17/25.
//

import StoreKit
import SwiftUI

class IAPManager: NSObject, ObservableObject {

    static let shared = IAPManager()

    // Published properties for SwiftUI state management
    @Published var products: [SKProduct] = []
    @Published var isSubscribed: Bool = UserDefaults.standard.bool(forKey: "isSubscribed")

    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        fetchProducts()
    }

    private func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: ["com.jackpotai.subscription.monthly"])
        request.delegate = self
        request.start()
    }

    func purchaseSubscription() {
        guard let product = products.first else {
            print("❌ Product not found.")
            return
        }
        SKPaymentQueue.default().add(SKPayment(product: product))
    }

    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    private func completeSubscriptionPurchase() {
        UserDefaults.standard.set(true, forKey: "isSubscribed")
        DispatchQueue.main.async {
            self.isSubscribed = true
        }
        AdManager.shared.removeAds()  // Removes ads once subscribed
    }
}

extension IAPManager: SKProductsRequestDelegate, SKPaymentTransactionObserver {

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.products = response.products
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased, .restored:
                completeSubscriptionPurchase()
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
}

class SubscriptionTracker: ObservableObject {
    @AppStorage("aiUsageCount") private var aiUsages: Int = 0
    private let maxFreeUses = 5

    var canUseAI: Bool {
        aiUsages < maxFreeUses || IAPManager.shared.isSubscribed
    }

    var remainingFreeUses: Int {
        max(0, maxFreeUses - aiUsages)
    }

    func incrementUsage() {
        guard !IAPManager.shared.isSubscribed else { return }
        aiUsages += 1
    }

    func resetUsage() {
        aiUsages = 0 // Only call if you decide to reset usage, e.g., monthly
    }
}
