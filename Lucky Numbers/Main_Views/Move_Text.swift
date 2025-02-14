//
//  Move_Text.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 11/13/22.
//

import SwiftUI

struct GlowingBallView: View {
    @State private var glowScale: CGFloat = 2.0
    @State private var glowOpacity: Double = 0.8

    var body: some View {
        Circle()
            .fill(Color.yellow.opacity(0.7))
            .frame(width: 80, height: 80)
            .shadow(color: Color.yellow.opacity(0.9), radius: 20)
            .overlay(
                Circle()
                    .stroke(Color.yellow.opacity(0.8), lineWidth: 4)
                    .blur(radius: 10)
            )
            .scaleEffect(glowScale)
            .opacity(glowOpacity)
            .animation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: glowScale)
            .onAppear {
                glowScale = 1.3
                glowOpacity = 0.5
            }
            .offset(y: -UIScreen.main.bounds.height / 20) // Adjust position as needed
    }
}

struct SparkleView: View {
    @State var isAnimating2 = false
    @State private var isRotating = 0.0

    var body: some View {
        ZStack {
            Image("sparkle")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width / 11, height: UIScreen.main.bounds.width / 11)
        }
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
        .offset(x: UIScreen.main.bounds.width / 2.7 + 12, y: -UIScreen.main.bounds.height / 2.5 - 11)
    }
}

struct MoveView: View {
    @EnvironmentObject var numberHold: NumberHold
    @Binding var firstClick: Int
    @State var toSparkle: Bool = true
    @Binding var savedText: [String]
    @State private var enabled = false
    @State var toGlow: Bool = true

    var body: some View {
        ZStack {
            if toSparkle {
                SparkleView().hidden()
            } else {
                SparkleView()
            }
            
            HStack(spacing: 0) {
                if firstClick > 0 {
                    ForEach(0..<savedText.count, id: \.self) { num in
                        Text(String(savedText[num]))
                            .frame(width: 64)
                            .fontWeight(.bold)
                            .addGlowEffect(
                                color1: Color.black,
                                color2: Color.black,
                                color3: Color.yellow
                            )
                            .font(.custom("Times New Roman", fixedSize: enabled ? 0 : 33))
                            .frame(width: enabled ? 0 : 64)
                            .offset(
                                x: enabled ? UIScreen.main.bounds.width / 9 : -UIScreen.main.bounds.width / 45,
                                y: enabled ? -UIScreen.main.bounds.height / 1.4 : -UIScreen.main.bounds.height / 23
                            )
                            .opacity(enabled ? 0 : 1)
                            .rotation3DEffect(.degrees(enabled ? 25 : 0), axis: (x: 1, y: 1, z: 3), perspective: 0.1)
                            .animation(Animation.default.delay(Double(num) / 7.4), value: enabled)
                    }
                }
            }
        }
        .onAppear {
            self.enabled.toggle()
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

            BallDropButton()
                .environmentObject(UserSettings(drawMethod: .Weighted))
                .environmentObject(NumberHold())
                .environmentObject(CustomRandoms())

            GlowingBallView() // Adds the glowing ball effect
        }
    }
}
