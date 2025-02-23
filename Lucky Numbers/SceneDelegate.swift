//
//  SceneDelegate.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/17/25.
//
import SwiftUI
import GoogleMobileAds  

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        // Initialize AdMob
        initializeAdMob()

        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        let contentView = ContentView() // Your main SwiftUI view
        window?.rootViewController = UIHostingController(rootView: contentView)
        window?.makeKeyAndVisible()
    }

    // AdMob Initialization Function
    private func initializeAdMob() {
        MobileAds.shared.start { status in
            print("AdMob initialized successfully!")
            for (adapter, state) in status.adapterStatusesByClassName {
                print("Adapter: \(adapter), State: \(state.state.rawValue)")
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
