//
//  Lucky_NumbersApp.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 11/13/22.
//

import SwiftUI
import Combine


class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("App Did Launch!")
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig: UISceneConfiguration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }

}


//Persistance
class Storage: NSObject {
    
    static func archiveStringArray(object : [String]) -> Data {
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
            fatalError("loadWStringArray - Can't encode data: \(error)")
        }
    }
}



@main
struct Lucky_NumbersApp: App {
    @StateObject var launchScreenState = LaunchScreenStateManager()
    @StateObject var numberHold = NumberHold()
    @StateObject var userSettings = UserSettings(drawMethod: .Weighted)
    @StateObject var custom = CustomRandoms()

    
    var body: some Scene {
        
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(numberHold)
                    .environmentObject(userSettings)
                    .environmentObject(custom)

                
                if launchScreenState.state != .finished {
                    LaunchScreenView()
                }
            }.environmentObject(launchScreenState)
        }
    }
    
}





