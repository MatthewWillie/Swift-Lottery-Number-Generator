import SwiftUI
import GoogleMobileAds

class AdManager: NSObject, FullScreenContentDelegate, ObservableObject {
    
    static let shared = AdManager()

    public var interstitial: InterstitialAd?
    @Published var adsDisplayedCount: Int = UserDefaults.standard.integer(forKey: "adsDisplayedCount")
    @Published var isAdRemoved: Bool = UserDefaults.standard.bool(forKey: "isSubscribed")
    @Published var showRemoveAdsPopup: Bool = false

    private override init() {
        super.init()
        if !IAPManager.shared.isSubscribed {
            loadInterstitial()
        }
    }

    private func loadInterstitial() {
        guard !IAPManager.shared.isSubscribed else {
            print("✅ Subscription active—no ads loaded.")
            return
        }

        let request = Request()
        InterstitialAd.load(with: "ca-app-pub-8590416773456100/7127569609", request: request) { [weak self] ad, error in
            if let error = error {
                print("❌ Failed to load interstitial ad: \(error.localizedDescription)")
                return
            }
            self?.interstitial = ad
            self?.interstitial?.fullScreenContentDelegate = self
            print("✅ Interstitial ad loaded successfully")
        }
    }

    func showInterstitial(from rootViewController: UIViewController) {
        guard !IAPManager.shared.isSubscribed else { return }
        guard let interstitial = interstitial else {
            print("⚠️ Interstitial ad not ready")
            return
        }
        interstitial.present(from: rootViewController)
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("✅ Interstitial ad dismissed. Reloading ad.")

        adsDisplayedCount += 1
        UserDefaults.standard.set(adsDisplayedCount, forKey: "adsDisplayedCount")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.adsDisplayedCount % 3 == 0 {
                self.showRemoveAdsPopup = true
            }
        }

        loadInterstitial()
    }

    func removeAds() {
        UserDefaults.standard.set(true, forKey: "isAdRemoved")
        UserDefaults.standard.set(0, forKey: "adsDisplayedCount")
        interstitial = nil
        print("🚀 Ads have been removed permanently!")
    }
}
