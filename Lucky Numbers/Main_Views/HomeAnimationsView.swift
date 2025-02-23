//
//  HomeAnimationsView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/19/25.
//

import SwiftUI
import Lottie

struct HomeAnimationsView: View {
    // A boolean to ensure we only play the animation once
    @State private var hasPlayedAnimation = false

    var body: some View {
        ZStack {
            Image("backgroundMix")
                .resizable()
                .ignoresSafeArea()

            // Only show the Lottie animation if it hasn't played yet
            if !hasPlayedAnimation {
                LottieView(
                    onAnimationComplete: nil,
                    filename: "Luckies_Logo",
                    textProvider: TextProvider(fiveBalls: [0,0,0,0,0,0])
                )
                .onAppear {
                    // Mark it as played so it won’t replay
                    DispatchQueue.main.async {
                        hasPlayedAnimation = true
                    }
                }
            }
        }
    }
}

// Optional Preview
struct HomeAnimationsView_Previews: PreviewProvider {
    static var previews: some View {
        HomeAnimationsView()
    }
}
