//
//  Move_Text.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 11/13/22.
//

import SwiftUI

struct SparkleView: View {
    @State var isAnimating2 = false
    @State private var isRotating = 0.0

    var body: some View {
        ZStack {
            Image("sparkle")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width / 11,
                       height: UIScreen.main.bounds.width / 11)
        }
        .zIndex(1)
        .opacity(isAnimating2 ? 0 : 1.5)
        .scaleEffect(isAnimating2 ? 1.7 : 0.3)
        .animation(.easeOut(duration: 0.5), value: isAnimating2)
        .rotationEffect(.degrees(isRotating))
        .onAppear {
            isAnimating2 = true
            withAnimation(.linear(duration: 1).speed(1.2).repeatForever(autoreverses: false)) {
                isRotating = 200
            }
        }
        .zIndex(1)
        .offset(x: UIScreen.main.bounds.width / 2.5 + 12,
                y: -UIScreen.main.bounds.height / 2.45 - 11)
    }
}

struct AnimatedTextView: View {
    let text: String
    let index: Int
    let enabled: Bool  // Shared toggle from MoveView

    var body: some View {
        Text(text)
            .font(.custom("Times New Roman", fixedSize: enabled ? 0 : 33))
            .frame(width: enabled ? 0 : 64)
            .fontWeight(.bold)
            .addGlowEffect(
                color1: Color.black,
                color2: Color("neonBlue"),
                color3: Color.yellow
            )
            .offset(
                x: enabled
                    ? UIScreen.main.bounds.width / 45
                    : -UIScreen.main.bounds.width / 45,
                y: enabled
                    ? -UIScreen.main.bounds.height / 1.6
                    : -UIScreen.main.bounds.height / 22
            )
            .opacity(enabled ? 0 : 1)
            .rotation3DEffect(
                .degrees(enabled ? 25 : 0),
                axis: (x: 1, y: 1, z: 3),
                perspective: 0.1
            )
            // Stagger the animation by index
            .animation(
                .default.delay(Double(index) / 8.4),
                value: enabled
            )
    }
}

struct MoveView: View {
    @EnvironmentObject var numberHold: NumberHold
    
    // Provided bindings
    @Binding var firstClick: Int
    @Binding var savedText: [String]
    
    // Local states
    @State var toSparkle: Bool = true
    @State var toGlow: Bool = true
    
    // Single toggle for the entire group
    @State private var enabled = false
    @State private var hasAnimated = false
    
    var body: some View {
        ZStack {
            // First, display the texts
            HStack(spacing: 0) {
                if firstClick > 0 {
                    ForEach(0..<savedText.count, id: \.self) { index in
                        AnimatedTextView(
                            text: savedText[index],
                            index: index,
                            enabled: enabled
                        )
                    }
                }
            }
            // Then, overlay the SparkleView on top using a high zIndex.
            if toSparkle {
                SparkleView()
                    .hidden()
            } else {
                SparkleView()
            }
        }
        .onAppear {
            guard !hasAnimated else { return }
            hasAnimated = true
            // Toggle the group animation.
            self.enabled.toggle()
            // After 1 second, un-hide the SparkleView.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.toSparkle = false
            }
        }
    }
}

struct MyPreview_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            if let _ = UIColor(named: "darkGreen") {
                Color("darkGreen").ignoresSafeArea()
            } else {
                Color.green.ignoresSafeArea()
            }
//            BallDropButton()
//                .environmentObject(UserSettings(drawMethod: .Weighted))
//                .environmentObject(NumberHold())
//                .environmentObject(CustomRandoms())
//                .environmentObject(BallDropAnimationState())
        }
    }
}
