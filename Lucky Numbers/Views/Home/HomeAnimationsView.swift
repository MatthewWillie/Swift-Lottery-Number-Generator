//
//  HomeAnimationsView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/19/25.
//

import SwiftUI

struct HomeAnimationsView: View {
    @Binding var animationFinished: Bool

    var body: some View {
        ZStack {
            // Your existing launch animation or background
            BackgroundView()
        }
        .onAppear {
            // Dismiss the launch screen after 1.8 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                animationFinished = true
            }
        }
    }
}



