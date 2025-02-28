//
//  ContentView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/17/25.
//
import SwiftUI

struct ContentView: View {
    @StateObject var controller = ViewControl()
    @State private var selectedTab: Tab = .home // Track selected tab

    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color.black
                    .ignoresSafeArea()

                // Display content based on selected tab
                switch selectedTab {
                case .home:
                    AppFlowView()
                case .results:
                    LotteryResultsView()
                case .settings:
                    SettingsView()
                }

                // Custom Tab Bar at the bottom
                VStack {
                    Spacer()
                    CustomTabBar(selectedTab: $selectedTab)
                }
                .edgesIgnoringSafeArea(.bottom)
            }
            // Global Navigation Bar settings
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(Color.blue.opacity(0.8), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
