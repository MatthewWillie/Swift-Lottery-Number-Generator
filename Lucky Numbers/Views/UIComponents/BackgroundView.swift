////
////  BackgroundView.swift
////  Lucky Numbers
////
////  Created by Matt Willie on 2/24/25.
////
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


// Preview just the background without UI elements
struct BackgroundOnlyPreview: PreviewProvider {
    static var previews: some View {
        HomeBackgroundView()
    }
}

// MARK: - The actual background view implementation from the artifact

struct HomeBackgroundView: View {
    // Animation properties
    @State private var animateGradient = false
    @State private var animateParticles = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base layer - Dark gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("darkBlue").opacity(0.8),
                        Color("black")
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Background Image with reduced opacity for subtlety
                Image("background")
                    .resizable()
                    .ignoresSafeArea()
                    .opacity(0.6)
                    .blendMode(.overlay)
                
                // Premium radial gradient in the center
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color("softGold").opacity(animateGradient ? 0.3 : 0.1),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: animateGradient ? 50 : 20,
                    endRadius: animateGradient ? 350 : 400
                )
                .ignoresSafeArea()
                .animation(
                    Animation.easeInOut(duration: 2.5)
                        .repeatForever(autoreverses: true),
                    value: animateGradient
                )
                
                // Subtle grid pattern overlay
                GridPatternView()
                    .opacity(0.15)
                    .ignoresSafeArea()
                
                // Top accent layer
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("neonBlue").opacity(0.4),
                        Color.clear
                    ]),
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
                .ignoresSafeArea()
                .blendMode(.softLight)
                
                // Soft blur overlay for depth
                VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark, opacity: 0.15)
                    .ignoresSafeArea()
                
                // Enhanced platform for lottery balls with glow
                VStack(spacing: 0) {
                    // Main platform line
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.clear,
                                    Color("neonBlue").opacity(0.8),
                                    Color("gold").opacity(0.6),
                                    Color.clear
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 2)
                        .frame(width: geometry.size.width * 0.85)
                        .blur(radius: 0.5)
                        .shadow(color: Color("neonBlue").opacity(0.6), radius: 4, x: 0, y: 2)
                    
                    // Subtle reflection
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.clear,
                                    Color("neonBlue").opacity(0.3),
                                    Color("gold").opacity(0.2),
                                    Color.clear
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                        .frame(width: geometry.size.width * 0.7)
                        .blur(radius: 1)
                        .offset(y: 3)
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height * 0.47)
            }
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 3)
                        .repeatForever(autoreverses: true)
                ) {
                    animateGradient = true
                }
                
                withAnimation(
                    Animation.easeInOut(duration: 8)
                        .repeatForever(autoreverses: false)
                ) {
                    animateParticles = true
                }
            }
        }
    }
}

// MARK: - Supporting Views

// Subtle grid pattern for depth
struct GridPatternView: View {
    var body: some View {
        GeometryReader { geometry in
            let lineCount = 15
            let spacing = geometry.size.width / CGFloat(lineCount)
            
            ZStack {
                // Vertical lines
                ForEach(0..<lineCount, id: \.self) { i in
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 0.5)
                        .frame(height: geometry.size.height)
                        .offset(x: CGFloat(i) * spacing - geometry.size.width / 2)
                }
                
                // Horizontal lines
                ForEach(0..<Int(geometry.size.height / spacing), id: \.self) { i in
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: geometry.size.width)
                        .frame(height: 0.5)
                        .offset(y: CGFloat(i) * spacing - geometry.size.height / 2)
                }
            }
        }
    }
}


// Mock extension for Color
extension Color {
    static func adaptiveColor(light: Color, dark: Color) -> Color {
        return light
    }
}

// Mock environment for the preview
extension Color {
    static let neonBlue = Color.blue
    static let darkBlue = Color.navy
    static let gold = Color.yellow
}

// Custom navy color
extension Color {
    static let navy = Color(red: 0, green: 0, blue: 0.5)
}
