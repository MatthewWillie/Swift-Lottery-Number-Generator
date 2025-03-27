//
//  ContentView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/17/25.
//
import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    @StateObject private var controller = ViewControl()
    @State private var selectedTab: Tab = .home
    @State private var animationFinished = false
    @EnvironmentObject var iapManager: IAPManager
    @EnvironmentObject var subscriptionTracker: SubscriptionTracker

    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.black.ignoresSafeArea()
                
                // Main content
                mainContentView
                
                // Tab bar overlay
                tabBarOverlay
                        
            }
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(Color.blue.opacity(0.8), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - View Components
    
    /// The main content area showing either the startup animation or the selected tab view
    private var mainContentView: some View {
        Group {
            if animationFinished {
                selectedTabView
            } else {
                HomeAnimationsView(animationFinished: $animationFinished)
            }
        }
    }
    
    /// The view for the currently selected tab
    private var selectedTabView: some View {
        Group {
            switch selectedTab {
            case .home:
                AppFlowView()
            case .results:
                LotteryResultsView()
            case .settings:
                SettingsView()
                    .environmentObject(iapManager)
                    .preferredColorScheme(.light)
            }
        }
    }
    
    /// The tab bar that appears at the bottom of the screen after animations
    private var tabBarOverlay: some View {
        Group {
            if animationFinished {
                VStack {
                    Spacer()
                    CustomTabBar(selectedTab: $selectedTab)
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
    }
}

// MARK: - Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LaunchScreenStateManager())
            .environmentObject(NumberHold())
            .environmentObject(UserSettings(drawMethod: .Weighted))
            .environmentObject(CustomRandoms())
            .environmentObject(IAPManager.shared)
            .environmentObject(SubscriptionTracker())
    }
}
