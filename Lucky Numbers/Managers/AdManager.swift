//
//  Untitled.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/16/25.
//
//
import SwiftUI
import GoogleMobileAds

/// A singleton class to manage Interstitial Ads (SDK v12+).
class AdManager: NSObject, FullScreenContentDelegate, ObservableObject {
    
    /// Singleton instance
    static let shared = AdManager()
    
    /// The current interstitial ad object
    private var interstitial: InterstitialAd?
    
    /// Tracks how many times the button is pressed for ad display logic
    private var buttonPressCount = UserDefaults.standard.integer(forKey: "buttonPressCount")
    
    /// Tracks how many ads have actually been displayed
    @Published var adsDisplayedCount: Int = UserDefaults.standard.integer(forKey: "adsDisplayedCount")
    
    /// Tracks if ads are removed (updated via UserDefaults)
    @Published var isAdRemoved: Bool = UserDefaults.standard.bool(forKey: "isAdRemoved")
    
    /// Determines if the "Remove Ads" pop-up should be shown
    @Published var showRemoveAdsPopup: Bool = false

    private override init() {
        super.init()
        
        // Initialize the Google Mobile Ads SDK
        MobileAds.shared.start { status in
            print("✅ Google Mobile Ads SDK initialized")
        }
        
        // Load an interstitial immediately if ads are NOT removed
        if !isAdRemoved {
            loadInterstitial()
        }
    }
    
    /// Loads and caches a new interstitial ad
    private func loadInterstitial() {
        guard !isAdRemoved else { return } // Skip loading if ads are removed
        
        let request = Request() // ✅ FIX: Correct Google Ads request type
        
        InterstitialAd.load(
            with: "ca-app-pub-8590416773456100/7127569609", // ✅ Your AdMob Ad Unit ID
            request: request,
            completionHandler: { [weak self] ad, error in
                if let error = error {
                    print("❌ Failed to load interstitial ad: \(error.localizedDescription)")
                    return
                }
                self?.interstitial = ad
                self?.interstitial?.fullScreenContentDelegate = self
                print("✅ Interstitial ad loaded successfully")
            }
        )
    }
    
    /// Called after the user presses the button (for ads).
    /// Increments `buttonPressCount`, shows an interstitial every 3rd press.
    func trackButtonPress(from rootViewController: UIViewController) {
        guard !isAdRemoved else { return } // Skip if ads are removed
        
        buttonPressCount += 1
        UserDefaults.standard.set(buttonPressCount, forKey: "buttonPressCount")
        
        // Show interstitial on every 3rd press
        if buttonPressCount % 10 == 0 {
            showInterstitial(from: rootViewController)
        }
    }
    
    /// Presents the interstitial ad if ready
    private func showInterstitial(from rootViewController: UIViewController) {
        guard let interstitial = interstitial else {
            print("⚠️ Interstitial ad not ready")
            return
        }
        interstitial.present(from: rootViewController) // ✅ FIX: Correct argument label
    }
    
    // MARK: - FullScreenContentDelegate
    
    /// Called when the ad is dismissed. Reload a new ad and track the count.
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("✅ Interstitial ad dismissed. Reloading a new ad.")

        // Increment displayed ad count
        adsDisplayedCount += 1
        UserDefaults.standard.set(adsDisplayedCount, forKey: "adsDisplayedCount")

        // ✅ Introduce a small delay before triggering UI changes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.adsDisplayedCount % 3 == 0 {
                self.showRemoveAdsPopup = true
            }
        }

        loadInterstitial()
    }

    
    /// Removes ads permanently when purchase is complete
    func removeAds() {
        isAdRemoved = true
        UserDefaults.standard.set(true, forKey: "isAdRemoved")
        UserDefaults.standard.set(0, forKey: "buttonPressCount") // Reset button press count
        UserDefaults.standard.set(0, forKey: "adsDisplayedCount") // Reset ad display count
        interstitial = nil // Prevent further ad loads
        print("🚀 Ads have been removed permanently!")
    }
}
