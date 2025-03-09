//
//  AppFlowView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/22/25.
//

import SwiftUI

// MARK: - View States for Navigation Flow
enum ViewStates {
    case home
    case onBoarding
    case SwiftUIView
    case euromillions
}

// MARK: - View Controller for Managing App Flow
final class ViewControl: ObservableObject {
    @Published var currentView: ViewStates

    init() {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "onboardingCompleted")
        self.currentView = hasCompletedOnboarding ? .home : .onBoarding
    }

    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "onboardingCompleted")
        self.currentView = .home
    }
}

// MARK: - AppFlowView: Determines Which View to Show
struct AppFlowView: View {
    @StateObject var controller = ViewControl()

    var body: some View {
        switch controller.currentView {
        case .home:
            MainView()
//            HomeView(controller: controller)
        case .onBoarding:
            OnBoardView(controller: controller)
        case .euromillions:
            EuroMillionsView()
        case .SwiftUIView:
            Text("SwiftUIView Placeholder") // Replace with your actual SwiftUIView
        }
    }
}

// MARK: - Preview
struct AppFlowView_Previews: PreviewProvider {
    static var previews: some View {
        AppFlowView()
            .environmentObject(NumberHold())
            .environmentObject(UserSettings(drawMethod: .Weighted))
            .environmentObject(CustomRandoms())
            .environmentObject(BallDropAnimationState())  // Inject BallDropAnimationState
    }
}
