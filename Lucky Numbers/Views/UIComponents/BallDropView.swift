//
//  BallDropView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 3/1/25.
//

import SwiftUI

struct BallDropView: View {
    let textProvider: AnimationTextProvider
    var onAnimationComplete: (() -> Void)? = nil

    var body: some View {
        LottieView(
            onAnimationComplete: onAnimationComplete,
            filename: "ball_drop",
            textProvider: textProvider
        )
        .shadow(radius: 10, x: -5, y: 20)
        .frame(width: UIScreen.main.bounds.width,
               height: UIScreen.main.bounds.height / 2,
               alignment: .center)
        .offset(y: -UIScreen.main.bounds.height / 7)
    }
}
