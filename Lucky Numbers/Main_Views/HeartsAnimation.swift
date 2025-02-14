//
//  HeartsAnimation.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 12/6/22.
//

import SwiftUI


struct HeartView: View {
    @Binding var isAnimating : Bool

    var body: some View {
        ZStack {
            Image(systemName: "heart.fill")
                .foregroundColor(Color.pink)
                .opacity(isAnimating ? 0 : 1)
                .scaleEffect(isAnimating ? 5 : 0)
                .offset(y: isAnimating ? -100 : 0)
                .animation(.easeIn(duration: 1), value: isAnimating)

            
        }
    }
}


struct LikeTapModifier: ViewModifier {
    @State var time = 0.0
    let duration = 1.0
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .foregroundColor(.red)
                .modifier(LikesGeometryEffect(time: time))

                .opacity(time == 1 ? 0 : 1)
        }
        .onAppear {
            withAnimation (.easeOut(duration: duration)) {
                self.time = duration
            }
        }
    }
}

struct LikesGeometryEffect : GeometryEffect {
    var time : Double
    var speed = Double.random(in: 150 ... 170)
    var xDirection = Double.random(in:  -0.05...0.05)
    var yDirection = Double.random(in: -Double.pi ...  0)
//    var yDirection = -2.0

    
    var animatableData: Double {
        get { time }
        set { time = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let xTranslation = speed * xDirection
        let yTranslation = speed * sin(yDirection) * time

        let affineTranslation =  CGAffineTransform(translationX: xTranslation, y: yTranslation)

        return ProjectionTransform(affineTranslation)
    }

}
