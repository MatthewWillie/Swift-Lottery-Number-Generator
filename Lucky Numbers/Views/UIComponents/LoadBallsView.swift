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
            .shadow(radius: 10, x: -5, y: 20)         }
        .frame(width: UIScreen.main.bounds.width,
               height: UIScreen.main.bounds.height / 2.5,                alignment: .center)
        .offset(y: -UIScreen.main.bounds.height / -11)
    }
}

//struct LoadBalls: View {
//    @State var toggle: Bool = false
//    let textProvider: TextProvider = TextProvider(fiveBalls: [1,1,1,1,1,1])
//    
//    var body: some View {
//        ZStack {
//            LottieView(
//                onAnimationComplete: nil,
//                filename: "load_balls",
//                textProvider: textProvider
//            )
//            .shadow(radius: 10, x: -5, y: 20)
//        }
//        .frame(width: UIScreen.main.bounds.width,
//               height: UIScreen.main.bounds.height / 2.5)
//        // Match the position that's used for ballDisplay in MainView
//        .position(x: UIScreen.main.bounds.width / 2,
//                  y: UIScreen.main.bounds.height * 0.29)
//        // Allow interaction with elements underneath
//        .allowsHitTesting(false)
//    }
//}

#Preview {
    ZStack {
        HomeBackgroundView()
        LoadBalls()
    }

}
