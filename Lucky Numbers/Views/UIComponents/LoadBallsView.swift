//
//  LoadBallsView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 3/3/25.
//

import SwiftUI

struct LoadBalls: View {
    @State var toggle: Bool = false
    let textProvider: TextProvider = TextProvider(fiveBalls: [1,1,1,1,1,1])

    var body: some View {
        ZStack {
            LottieView(
                onAnimationComplete: nil,
                filename: "load_balls",
                textProvider: textProvider
            )
            .shadow(radius: 10, x: -5, y: 20)
        }
        .frame(width: UIScreen.main.bounds.width,
               height: UIScreen.main.bounds.height / 2.5,
               alignment: .center)
        .offset(y: -UIScreen.main.bounds.height / 5.5)
    }
}
