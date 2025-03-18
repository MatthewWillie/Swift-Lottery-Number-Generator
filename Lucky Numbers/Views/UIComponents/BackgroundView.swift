//
//  BackgroundView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/24/25.
//

import SwiftUI


struct BackgroundView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
            
                // Background Image
                Image("background")
                    .resizable()
                    .ignoresSafeArea()
                    .opacity(0.4)

                // **Glassmorphic Blur Overlay**
                VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark, opacity: 0.2)
                    .ignoresSafeArea()

                // **Layered Gradients for Depth**
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("darkBlue").opacity(1),
                        Color("black").opacity(0.5)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Gold Gradient Fading Up & Down from the Center
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color("gold").opacity(0.3),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 20,
                    endRadius: 400
                )
                .ignoresSafeArea()
                
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("neonBlue").opacity(0.4),
                        Color.clear
                    ]),
                    startPoint: .bottomLeading,
                    endPoint: .topTrailing
                )
                .ignoresSafeArea()
                
            }
        }
    }
}

struct HomeBackgroundView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Image
                Image("background")
                    .resizable()
                    .ignoresSafeArea()
                    .opacity(0.9)
                
                // Glassmorphic Blur Overlay
                VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark, opacity: 0.2)
                    .ignoresSafeArea()
                
                // Layered Gradients for Depth
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("darkBlue").opacity(1),
                        Color("black").opacity(0.5)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color("gold").opacity(0.3),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 20,
                    endRadius: 400
                )
                .ignoresSafeArea()
                
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("neonBlue").opacity(0.4),
                        Color.clear
                    ]),
                    startPoint: .bottomLeading,
                    endPoint: .topTrailing
                )
                .ignoresSafeArea()
                
                // Red Line Platform for Lottery Balls
                Rectangle()
                    .fill(Color("darkBlue").opacity(0.6))
                    .frame(height: 4)
                    .frame(width: geometry.size.width)
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.47)
                    .mask(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear, Color.white, Color.white, Color.clear
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color.black.opacity(0.9), radius: 7, x: 10, y: 15)
            }
        }
    }
}


struct BackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundView()
    }
}
