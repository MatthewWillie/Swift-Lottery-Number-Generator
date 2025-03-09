//
//  HomeView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/17/25.
//

import SwiftUI
import UIKit

// UIKit-based VisualEffectBlur Wrapper
struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    var opacity: CGFloat  // Allows us to control transparency
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: blurStyle)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = opacity
        return blurView
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.alpha = opacity
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
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.49)
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

struct HomeView: View {
    @ObservedObject var controller: ViewControl
    
    var body: some View {
        NavigationView {
            ZStack {
                HomeBackgroundView()
//                LogoView()
                    .offset(y: -UIScreen.main.bounds.height * 0.27)
                    .opacity(0.8)
//                BallDropButton()
            }
            .navigationBarHidden(true)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView(controller: ViewControl())
        }
        .environmentObject(BallDropAnimationState())
        .environmentObject(UserSettings(drawMethod: .Weighted))
        .environmentObject(NumberHold())
        .environmentObject(CustomRandoms())
    }
}
