//
//  LaunchScreenView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/19/25.
//
import SwiftUI
import Lottie

struct LaunchScreenView: View {
   // MARK: - Properties
   @EnvironmentObject private var launchScreenState: LaunchScreenStateManager
   @State private var firstAnimation = false
   @State private var secondAnimation = false
   @State private var startFadeoutAnimation = false

   
   // MARK: - Constants
   private let textProvider = TextProvider(fiveBalls: [0, 0, 0, 0, 0, 0])
   private let animationDuration: Double = 1.0
   private let fadeoutDelay: Double = 1.8
   private let dismissDelay: Double = 1.0
   
   // MARK: - Animation Timer
   private let animationTimer = Timer
       .publish(every: 0.5, on: .current, in: .common)
       .autoconnect()

   // MARK: - Body
   var body: some View {
       ZStack {
           // Background layer
           BackgroundView()
               

           
           // Logo layer
           Image("JackpotLogo")
               .opacity(0.9)
           
           // Lottie animation layer
           lottieAnimationView
       }
       .onAppear(perform: setupFadeoutAnimation)
       .opacity(startFadeoutAnimation ? 0 : 1)
       .onReceive(animationTimer) { _ in
           updateAnimation()
       }
   }
   
   // MARK: - View Components
   
   /// The Lottie animation view with configured parameters
   private var lottieAnimationView: some View {
       LottieView(
           onAnimationComplete: nil,
           filename: "JackpotAI_Logo",
           textProvider: textProvider
       )
   }
   
   // MARK: - Animation Methods
   
   /// Sets up the fadeout animation sequence
   private func setupFadeoutAnimation() {
       DispatchQueue.main.asyncAfter(deadline: .now() + fadeoutDelay) {
           withAnimation(.easeOut(duration: animationDuration)) {
               startFadeoutAnimation = true
           }
           
           DispatchQueue.main.asyncAfter(deadline: .now() + dismissDelay) {
               launchScreenState.dismiss()
           }
       }
   }
   
   /// Updates the animation state based on the launch screen state
   private func updateAnimation() {
       switch launchScreenState.state {
       case .firstStep:
           withAnimation(.easeInOut(duration: animationDuration)) {
               firstAnimation.toggle()
           }
       case .secondStep:
           if !secondAnimation {
               withAnimation(.easeOut(duration: animationDuration)) {
                   secondAnimation = true
                   startFadeoutAnimation = true  // Ensure it aligns with transition timing
               }
           }
       case .finished:
           break
       }
   }
}

// MARK: - Preview
struct LaunchScreenView_Previews: PreviewProvider {
   static var previews: some View {
       LaunchScreenView()
           .environmentObject(LaunchScreenStateManager())
   }
}
