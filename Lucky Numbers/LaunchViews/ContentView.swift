//
//  ContentView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/17/25.
//
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var numberHold: NumberHold
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var custom: CustomRandoms
    @EnvironmentObject var launchScreenState: LaunchScreenStateManager
    @StateObject var controller = viewControl() // View state controller

    var body: some View {
        NavigationView {
            ZStack {
                // ✅ Full-screen background
                Color.black.ignoresSafeArea()

                VStack {
                    TabView {
                        // ✅ Home Screen
                        ControllerView(controller: controller)
                            .tabItem {
                                Image(systemName: "house.fill")
                                Text("Home")
                            }

                        // ✅ Lottery Results Screen
                        LotteryResultsView()
                            .tabItem {
                                Image(systemName: "chart.bar.fill")
                                Text("Results")
                            }

                        // ✅ Settings Screen
                        SettingsView()
                            .tabItem {
                                Image(systemName: "gearshape.fill")
                                Text("Settings")
                            }
                    }
                    .toolbarBackground(Color.blue, for: .tabBar) // ✅ Change the Tab Bar background color
                    .toolbarColorScheme(.dark, for: .tabBar) // ✅ Ensure icons/text are visible
                }
//                .navigationBarTitle("Lucky Numbers", displayMode: .inline)
                .toolbarBackground(Color.blue.opacity(0.8), for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Ensure single-column layout on iPads
    }
}



// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LaunchScreenStateManager())
            .environmentObject(NumberHold())
            .environmentObject(UserSettings(drawMethod: .Weighted))
            .environmentObject(CustomRandoms())
    }
}
