//
//  Lucky_NumbersApp.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/17/25.
//
import SwiftUI
import Combine
import AppTrackingTransparency
import AdSupport
import Firebase
import FirebaseCrashlytics

// MARK: - App Delegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        print("App Did Launch!")
        
        // Configure services
        setupFirebase()
        requestTrackingPermission()
        
        return true
    }
    
    // MARK: - Setup Methods
    
    private func setupFirebase() {
        FirebaseApp.configure()
        Analytics.setAnalyticsCollectionEnabled(true)
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
    }
    
    private func requestTrackingPermission() {
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else {
            print("🚫 ATT already requested, skipping request")
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization { [weak self] status in
                self?.handleTrackingAuthorizationResponse(status)
            }
        }
    }
    
    private func handleTrackingAuthorizationResponse(_ status: ATTrackingManager.AuthorizationStatus) {
        switch status {
        case .authorized:
            print("✅ Tracking authorized")
        case .denied:
            print("❌ Tracking denied")
        case .notDetermined:
            print("⚠️ Tracking not determined")
        case .restricted:
            print("⚠️ Tracking restricted")
        @unknown default:
            print("⚠️ Unknown tracking status")
        }
    }
}

// MARK: - Persistence
class Storage {
    enum StorageError: Error {
        case encodingFailed(Error)
        case decodingFailed(Error)
        case invalidData
        
        var localizedDescription: String {
            switch self {
            case .encodingFailed(let error):
                return "Failed to encode data: \(error.localizedDescription)"
            case .decodingFailed(let error):
                return "Failed to decode data: \(error.localizedDescription)"
            case .invalidData:
                return "Invalid data format"
            }
        }
    }
    
    static func archiveStringArray(object: [String]) -> Data {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: false)
            return data
        } catch {
            print("❌ Encoding error: \(error.localizedDescription)")
            // Return empty data instead of crashing with fatalError
            return Data()
        }
    }
    
    static func loadStringArray(data: Data) -> [String] {
        guard !data.isEmpty else { return [] }
        
        do {
            guard let array = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String] else {
                print("❌ Invalid data format when unarchiving")
                return []
            }
            return array
        } catch {
            print("❌ Decoding error: \(error.localizedDescription)")
            return []
        }
    }
}

// MARK: - Main App
@main
struct Lucky_NumbersApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // App State Objects
    @StateObject private var launchScreenState = LaunchScreenStateManager()
    @StateObject private var numberHold = NumberHold()
    @StateObject private var userSettings = UserSettings(drawMethod: .Weighted)
    @StateObject private var custom = CustomRandoms()
    @StateObject private var iapManager = IAPManager.shared
    @StateObject private var subscriptionTracker = SubscriptionTracker()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ZStack {
                    ContentView()
                        .environmentObject(numberHold)
                        .environmentObject(userSettings)
                        .environmentObject(custom)
                        .environmentObject(iapManager)
                        .environmentObject(subscriptionTracker)
                        .onAppear {
                            // Check trial status on app launch
                            subscriptionTracker.checkTrialStatus()
                        }

                    if launchScreenState.state != .finished {
                        LaunchScreenView()
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .environmentObject(launchScreenState)
        }
    }
}

// MARK: - Preview Helpers
struct RootViewForPreview: View {
    // State Objects for preview
    @StateObject private var launchScreenState = LaunchScreenStateManager()
    @StateObject private var numberHold = NumberHold()
    @StateObject private var userSettings = UserSettings(drawMethod: .Weighted)
    @StateObject private var custom = CustomRandoms()
    @StateObject private var iapManager = IAPManager.shared
    @StateObject private var subscriptionTracker = SubscriptionTracker()

    var body: some View {
        NavigationView {
            ZStack {
                ContentView()
                    .environmentObject(numberHold)
                    .environmentObject(userSettings)
                    .environmentObject(custom)
                    .environmentObject(iapManager)
                    .environmentObject(subscriptionTracker)

                if launchScreenState.state != .finished {
                    LaunchScreenView()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .environmentObject(launchScreenState)
    }
}

// MARK: - Preview Provider
struct Lucky_NumbersApp_Previews: PreviewProvider {
    static var previews: some View {
        RootViewForPreview()
            .environmentObject(UserSettings(drawMethod: .Weighted))
            .environmentObject(NumberHold())
            .environmentObject(CustomRandoms())
            .environmentObject(IAPManager.shared)
            .environmentObject(SubscriptionTracker())
    }
}
