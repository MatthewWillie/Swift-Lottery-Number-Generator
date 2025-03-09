//
//  ContentView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/17/25.
//
import SwiftUI

struct ContentView: View {
    @StateObject var controller = ViewControl()
    @State private var selectedTab: Tab = .home // Track selected tab (ensure Tab is defined elsewhere)
    @State private var animationFinished = false // Track animation completion

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if animationFinished {
                    // Display content based on selected tab AFTER animation finishes
                    switch selectedTab {
                    case .home:
                        AppFlowView()
                    case .results:
                        LotteryResultsView()
                    case .settings:
                        InfoButton()
                    }
                } else {
                    // Show animation first
                    HomeAnimationsView(animationFinished: $animationFinished)
                }

                // Custom Tab Bar at the bottom (only when animation is done)
                if animationFinished {
                    VStack {
                        Spacer()
                        CustomTabBar(selectedTab: $selectedTab)
                    }
                    .edgesIgnoringSafeArea(.bottom)
                }
            }
            // Global Navigation Bar settings
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(Color.blue.opacity(0.8), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LaunchScreenStateManager())
            .environmentObject(NumberHold())
            .environmentObject(UserSettings(drawMethod: .Weighted))
            .environmentObject(CustomRandoms())
            .environmentObject(BallDropAnimationState())  // Inject BallDropAnimationState
    }
}
