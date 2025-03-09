//
//  Lucky_NumbersApp.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/17/25.
//

import SwiftUI
import Combine

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("App Did Launch!")
        return true
    }
    
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
}

// Persistence
class Storage: NSObject {
    static func archiveStringArray(object: [String]) -> Data {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: false)
            return data
        } catch {
            fatalError("Can't encode data: \(error)")
        }
    }
    
    static func loadStringArray(data: Data) -> [String] {
        do {
            guard let array = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String] else {
                return []
            }
            return array
        } catch {
            fatalError("loadStringArray - Can't decode data: \(error)")
        }
    }
}

@main
struct Lucky_NumbersApp: App {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    @StateObject var launchScreenState = LaunchScreenStateManager()
    @StateObject var numberHold = NumberHold()
    @StateObject var userSettings = UserSettings(drawMethod: .Weighted)
    @StateObject var custom = CustomRandoms()
    @StateObject var animationState = BallDropAnimationState()
    @StateObject var iapManager = IAPManager.shared           // ✅ IAP Manager globally
    @StateObject var subscriptionTracker = SubscriptionTracker() // ✅ Add SubscriptionTracker here

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ZStack {
                    ContentView()
                        .environmentObject(numberHold)
                        .environmentObject(userSettings)
                        .environmentObject(custom)
                        .environmentObject(animationState)
                        .environmentObject(iapManager)          // ✅ Inject IAPManager
                        .environmentObject(subscriptionTracker) // ✅ Inject SubscriptionTracker

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

struct RootViewForPreview: View {
    @StateObject var launchScreenState = LaunchScreenStateManager()
    @StateObject var numberHold = NumberHold()
    @StateObject var userSettings = UserSettings(drawMethod: .Weighted)
    @StateObject var custom = CustomRandoms()
    @StateObject var animationState = BallDropAnimationState()
    @StateObject var subscriptionTracker = SubscriptionTracker() // ✅ Added here for Preview

    var body: some View {
        NavigationView {
            ZStack {
                ContentView()
                    .environmentObject(numberHold)
                    .environmentObject(userSettings)
                    .environmentObject(custom)
                    .environmentObject(animationState)
                    .environmentObject(subscriptionTracker) // ✅ Inject for preview as well

                if launchScreenState.state != .finished {
                    LaunchScreenView()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .environmentObject(launchScreenState)
    }
}
// ✅ **Ensure Preview Uses `RootViewForPreview` Correctly**
struct Lucky_NumbersApp_Previews: PreviewProvider {
    static var previews: some View {
        RootViewForPreview()
            .environmentObject(BallDropAnimationState())  // ✅ Ensures preview gets animation state
            .environmentObject(UserSettings(drawMethod: .Weighted))
            .environmentObject(NumberHold())
            .environmentObject(CustomRandoms())
    }
}
