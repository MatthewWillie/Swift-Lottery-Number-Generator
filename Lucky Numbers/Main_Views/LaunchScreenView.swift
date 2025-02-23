//
//  LaunchScreenView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/19/25.
//

import SwiftUI
import Lottie

struct LaunchScreenView: View {
    @EnvironmentObject private var launchScreenState: LaunchScreenStateManager

    var textProvider = TextProvider(fiveBalls: [0,0,0,0,0,0])

    @State private var firstAnimation = false
    @State private var secondAnimation = false
    @State private var startFadeoutAnimation = false
    
    private let animationTimer = Timer
        .publish(every: 0.5, on: .current, in: .common)
        .autoconnect()

    var body: some View {
        ZStack {
            // If you have a background image, place it here
            Image("backgroundMix")
                .resizable()
                .ignoresSafeArea()

            // Your Lottie animation
            LottieView(
                onAnimationComplete: nil,
                filename: "Luckies_Logo",
                textProvider: textProvider
            )
        }
        .task {
            try? await Task.sleep(for: .seconds(1.8))
                    launchScreenState.dismiss()
                }
        // Fade out if needed
        .opacity(startFadeoutAnimation ? 0 : 1)
        .onReceive(animationTimer) { _ in
            updateAnimation()
        }
    }
    
    private func updateAnimation() {
        switch launchScreenState.state {
        case .firstStep:
            withAnimation(.easeInOut(duration: 0.9)) {
                firstAnimation.toggle()
            }
        case .secondStep:
            if !secondAnimation {
                withAnimation(.linear) {
                    secondAnimation = true
                    startFadeoutAnimation = true
                }
            }
        case .finished:
            // If your app logic sets state to .finished, do nothing
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
