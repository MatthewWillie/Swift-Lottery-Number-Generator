//
//  IAPManager.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/17/25.
//

import StoreKit
import SwiftUI
import Firebase

// Manages in-app purchases and subscriptions with Firebase Analytics integration
class IAPManager: NSObject, ObservableObject {
    // MARK: - Properties
    
    /// Shared singleton instance
    static let shared = IAPManager()
    
    /// Available products from the App Store
    @Published var products: [SKProduct] = []
    
    /// Subscription status
    @Published var isSubscribed: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKeys.isSubscribed)
    
    /// Loading state for purchases
    @Published var isPurchasing: Bool = false
    
    // MARK: - Constants
    
    private enum ProductIdentifiers {
        static let monthlySubscription = "com.jackpotai.subscription.monthly"
        static let yearlySubscription = "com.jackpotai.subscription.yearly"
    }
    
    private enum UserDefaultsKeys {
        static let isSubscribed = "isSubscribed"
    }
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupPaymentObserver()
        fetchProducts()
    }
    
    private func setupPaymentObserver() {
        SKPaymentQueue.default().add(self)
    }
    
    // MARK: - Product Fetching
    
    /// Fetches available products from the App Store
    private func fetchProducts() {
        let productIdentifiers: Set<String> = [
            ProductIdentifiers.monthlySubscription,
            ProductIdentifiers.yearlySubscription
        ]
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
        
        // Log event
        Analytics.logEvent("subscription_products_requested", parameters: nil)
    }
    // MARK: - Purchase Methods
    
    /// Initiates the subscription purchase flow
    func purchaseSubscription(productIdentifier: String? = nil) {
        // Track that user started the subscription process
        Analytics.logEvent("subscription_purchase_initiated", parameters: nil)
        
        guard !products.isEmpty else {
            print("❌ Products array is empty. Re-fetching products...")
            fetchProducts()
            // Track error
            Analytics.logEvent("subscription_error", parameters: [
                "error_type": "empty_products",
                "action": "re-fetching"
            ])
            return
        }
        
        // Find the requested product or default to the first one
        let product: SKProduct?
        if let identifier = productIdentifier {
            product = products.first(where: { $0.productIdentifier == identifier })
        } else {
            product = products.first
        }
        
        guard let product = product else {
            print("❌ Product not found.")
            // Track error
            Analytics.logEvent("subscription_error", parameters: [
                "error_type": "product_not_found"
            ])
            return
        }
        
        // Track view subscription details before purchase
        logSubscriptionViewed(product: product)
        
        print("🔔 Starting purchase for: \(product.productIdentifier)")
        
        DispatchQueue.main.async {
            self.isPurchasing = true
        }
        
        SKPaymentQueue.default().add(SKPayment(product: product))
    }
    
    /// Restores previously purchased subscriptions
    func restorePurchases() {
        // Log restore attempt
        Analytics.logEvent("subscription_restore_initiated", parameters: nil)
        
        DispatchQueue.main.async {
            self.isPurchasing = true
        }
        
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    // MARK: - Subscription Status Management
    
    /// Called when a subscription is successfully purchased or restored
    private func completeSubscriptionPurchase(transaction: SKPaymentTransaction? = nil) {
        // Update subscription status
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isSubscribed)
        
        DispatchQueue.main.async {
            self.isSubscribed = true
            self.isPurchasing = false
        }
        
        // Track successful purchase with transaction details
        if let transaction = transaction,
           let product = products.first(where: { $0.productIdentifier == transaction.payment.productIdentifier }) {
            trackPurchaseSuccess(product: product)
        } else if let product = products.first {
            // Fallback to first product if transaction isn't available
            trackPurchaseSuccess(product: product)
        }
        
        // Remove ads for subscribers
        AdManager.shared.removeAds()
    }
    
    /// Called when a subscription is terminated or canceled
    func handleSubscriptionCancellation() {
        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.isSubscribed)
        
        DispatchQueue.main.async {
            self.isSubscribed = false
        }
        
        // Track cancellation
        Analytics.logEvent("subscription_cancelled", parameters: nil)
    }
    
    // MARK: - Analytics Tracking
    
    /// Tracks a successful purchase in Firebase Analytics
    private func trackPurchaseSuccess(product: SKProduct) {
        Analytics.logEvent(AnalyticsEventPurchase, parameters: [
            AnalyticsParameterItemID: product.productIdentifier,
            AnalyticsParameterItemName: product.localizedTitle,
            AnalyticsParameterPrice: NSDecimalNumber(decimal: product.price as Decimal).doubleValue,
            AnalyticsParameterCurrency: product.priceLocale.currencyCode ?? "USD",
            AnalyticsParameterSuccess: true,
            "subscription_period": "monthly" // Add more context about the subscription
        ])
    }
    
    /// Tracks when user views subscription details
    func logSubscriptionViewed(product: SKProduct) {
        Analytics.logEvent("subscription_viewed", parameters: [
            "product_id": product.productIdentifier,
            "price": NSDecimalNumber(decimal: product.price as Decimal).doubleValue,
            "currency": product.priceLocale.currencyCode ?? "USD",
            "title": product.localizedTitle
        ])
    }
    
    /// Tracks when a purchase fails
    private func logPurchaseFailure(productId: String, error: Error?) {
        Analytics.logEvent("subscription_purchase_failed", parameters: [
            "product_id": productId,
            "error_description": error?.localizedDescription ?? "Unknown error"
        ])
    }
}

// MARK: - StoreKit Delegate Extensions

extension IAPManager: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.products = response.products
            
            // Log product fetch results
            if response.products.isEmpty {
                print("❌ No products found. Invalid product identifiers: \(response.invalidProductIdentifiers)")
                Analytics.logEvent("products_fetch_failed", parameters: [
                    "invalid_identifiers": response.invalidProductIdentifiers.joined(separator: ",")
                ])
            } else {
                print("✅ Products loaded successfully: \(response.products.count)")
                Analytics.logEvent("products_fetch_success", parameters: [
                    "product_count": response.products.count
                ])
                
                for product in response.products {
                    print("   - \(product.productIdentifier): \(product.price) \(product.priceLocale.currencySymbol ?? "$")")
                }
            }
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("❌ Product request failed: \(error.localizedDescription)")
        
        // Log error
        Analytics.logEvent("products_request_error", parameters: [
            "error": error.localizedDescription
        ])
        
        DispatchQueue.main.async {
            self.isPurchasing = false
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            let productId = transaction.payment.productIdentifier
            print("💲 Transaction updated: \(productId) - \(transaction.transactionState.rawValue)")
            
            switch transaction.transactionState {
            case .purchasing:
                print("⏳ Purchasing...")
                
            case .purchased:
                print("✅ Purchase successful!")
                completeSubscriptionPurchase(transaction: transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .restored:
                print("🔄 Purchase restored!")
                
                // Log restore success
                Analytics.logEvent("subscription_restore_success", parameters: [
                    "product_id": productId
                ])
                
                completeSubscriptionPurchase(transaction: transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .failed:
                DispatchQueue.main.async {
                    self.isPurchasing = false
                }
                
                if let error = transaction.error {
                    print("❌ Purchase failed: \(error.localizedDescription)")
                    logPurchaseFailure(productId: productId, error: error)
                } else {
                    print("❌ Purchase failed with unknown error")
                    logPurchaseFailure(productId: productId, error: nil)
                }
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .deferred:
                print("⏳ Purchase deferred (waiting for approval)")
                
                Analytics.logEvent("subscription_deferred", parameters: [
                    "product_id": productId
                ])
                
            @unknown default:
                print("❓ Unknown transaction state")
                
                Analytics.logEvent("subscription_unknown_state", parameters: [
                    "product_id": productId,
                    "state_raw_value": transaction.transactionState.rawValue
                ])
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print("🗑️ Transaction removed: \(transaction.payment.productIdentifier)")
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("✅ Restore completed")
        
        if queue.transactions.isEmpty {
            // No purchases to restore
            Analytics.logEvent("subscription_restore_empty", parameters: nil)
            
            DispatchQueue.main.async {
                self.isPurchasing = false
            }
        }
        
        // Overall restore completion event
        Analytics.logEvent("subscription_restore_completed", parameters: nil)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("❌ Restore failed: \(error.localizedDescription)")
        
        // Log restore failure
        Analytics.logEvent("subscription_restore_failed", parameters: [
            "error": error.localizedDescription
        ])
        
        DispatchQueue.main.async {
            self.isPurchasing = false
        }
    }
}

// MARK: - SubscriptionTracker

class SubscriptionTracker: ObservableObject {
    @AppStorage("aiUsageCount") private var aiUsages: Int = 0
    private let maxFreeUses = 5
    
    /// Whether the user can use premium AI features
    var canUseAI: Bool {
        aiUsages < maxFreeUses || IAPManager.shared.isSubscribed
    }
    
    /// Number of remaining free uses
    var remainingFreeUses: Int {
        max(0, maxFreeUses - aiUsages)
    }
    
    /// Increment usage counter
    func incrementUsage() {
        guard !IAPManager.shared.isSubscribed else { return }
        
        aiUsages += 1
        
        // Track usage analytics
        Analytics.logEvent("ai_feature_used", parameters: [
            "remaining_uses": remainingFreeUses,
            "subscription_status": IAPManager.shared.isSubscribed ? "subscribed" : "free"
        ])
        
        // Track when user reaches limit
        if remainingFreeUses == 0 {
            Analytics.logEvent("free_usage_limit_reached", parameters: nil)
        }
    }
    
    /// Reset usage counter (e.g., for monthly reset)
    func resetUsage() {
        aiUsages = 0
        
        Analytics.logEvent("usage_limit_reset", parameters: nil)
    }
}
