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
   // MARK: - Published Properties
   @Published var currentView: ViewStates
   @Published var didCompleteTrial: Bool = UserDefaults.standard.bool(forKey: "didCompleteTrial")

   // MARK: - Constants
   private enum Constants {
       static let onboardingCompletedKey = "onboardingCompleted"
       static let didCompleteTrialKey = "didCompleteTrial"
   }
   
   // MARK: - Initialization
   init() {
       let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: Constants.onboardingCompletedKey)
       self.currentView = hasCompletedOnboarding ? .home : .onBoarding
   }

   // MARK: - Navigation Methods
   func completeOnboarding() {
       UserDefaults.standard.set(true, forKey: Constants.onboardingCompletedKey)
       self.currentView = .home
   }
   
   func completeTrial() {
       UserDefaults.standard.set(true, forKey: Constants.didCompleteTrialKey)
       self.didCompleteTrial = true
       completeOnboarding()
   }
}

// MARK: - AppFlowView: Determines Which View to Show
struct AppFlowView: View {
   // MARK: - Properties
   @StateObject private var controller = ViewControl()
   @State private var isShowingFreeTrialFullScreen = false
   @EnvironmentObject private var iapManager: IAPManager

   // MARK: - Body
   var body: some View {
       mainContentView
           .fullScreenCover(isPresented: $isShowingFreeTrialFullScreen, onDismiss: {
               controller.completeOnboarding()
           }) {
               freeTrialView
           }
   }
   
   // MARK: - View Components
   
   /// The main content view that displays based on navigation state
   private var mainContentView: some View {
       ZStack {
           switch controller.currentView {
           case .home:
               MainView()
           case .onBoarding:
               onboardingTriggerView
           case .euromillions:
               Text("Euromillions Placeholder")
           case .SwiftUIView:
               Text("SwiftUIView Placeholder")
           }
       }
   }
   
   /// Empty view that triggers the onboarding fullscreen cover
   private var onboardingTriggerView: some View {
       Color.clear
           .onAppear {
               isShowingFreeTrialFullScreen = true
           }
   }
   
   /// The free trial view shown as a fullscreen cover
   private var freeTrialView: some View {
       FreeTrialView(
           controller: controller,
           dismissAction: { isShowingFreeTrialFullScreen = false }
       )
       .environmentObject(iapManager)
   }
}

// MARK: - Preview
struct AppFlowView_Previews: PreviewProvider {
   static var previews: some View {
       AppFlowView()
           .environmentObject(NumberHold())
           .environmentObject(UserSettings(drawMethod: .Weighted))
           .environmentObject(CustomRandoms())
           .environmentObject(IAPManager.shared) 
   }
}
