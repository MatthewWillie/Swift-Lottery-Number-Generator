//
//  ToggleView.swift
//  JackpotAI
//
//  Created by Matt Willie on 3/18/25.
//

import SwiftUI

struct SciFiQuantumSpinnerView: View {
    // MARK: - Properties
    @State private var isAnimating = false
    @State private var ringRotation = 0.0
    @State private var particleScale: CGFloat = 0.3
    @State private var pulseOpacity: CGFloat = 0.0
    @State private var scannerOffset: CGFloat = -150
    
    let size: CGFloat
    let primaryColor: Color
    let secondaryColor: Color
    let tertiaryColor: Color
    let particleCount: Int
    
    // MARK: - Initialization
    init(
        size: CGFloat = 120,
        primaryColor: Color = Color("neonBlue", defaultValue: .blue),
        secondaryColor: Color = Color("gold", defaultValue: .yellow),
        tertiaryColor: Color = .white,
        particleCount: Int = 6
    ) {
        self.size = size
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.tertiaryColor = tertiaryColor
        self.particleCount = particleCount
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            primaryColor.opacity(0.8),
                            secondaryColor.opacity(0.6),
                            primaryColor.opacity(0.4),
                            secondaryColor.opacity(0.8)
                        ]),
                        center: .center
                    ),
                    lineWidth: size * 0.05
                )
                .frame(width: size, height: size)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .shadow(color: primaryColor.opacity(0.6), radius: 15, x: 0, y: 0)
            
            // Inner ring (counter-rotating)
            Circle()
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            secondaryColor.opacity(0.8),
                            primaryColor.opacity(0.6),
                            secondaryColor.opacity(0.4),
                            primaryColor.opacity(0.8)
                        ]),
                        center: .center
                    ),
                    lineWidth: size * 0.03
                )
                .frame(width: size * 0.7, height: size * 0.7)
                .rotationEffect(Angle(degrees: isAnimating ? -270 : 90))
            
            // Core circle with pulsing glow
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            secondaryColor.opacity(0.7),
                            primaryColor.opacity(0.5),
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.25
                    )
                )
                .frame(width: size * 0.4, height: size * 0.4)
                .scaleEffect(isAnimating ? 1.1 : 0.9)
                .shadow(color: secondaryColor.opacity(0.5), radius: 10, x: 0, y: 0)
            
            // Particles orbiting
            ForEach(0..<particleCount, id: \.self) { index in
                QuantumParticle(
                    color: index % 2 == 0 ? primaryColor : secondaryColor,
                    size: size * 0.08,
                    angle: Double(index) * (360.0 / Double(particleCount)) + (isAnimating ? ringRotation : 0),
                    distance: size * 0.35,
                    scale: particleScale
                )
            }
            
            // Scanner line effect
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            tertiaryColor.opacity(0),
                            tertiaryColor.opacity(0.8),
                            tertiaryColor.opacity(0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: size * 1.5, height: 1.5)
                .offset(y: scannerOffset)
                .rotationEffect(Angle(degrees: 30))
                .blendMode(.screen)
            
            // Ambient pulse effect
            Circle()
                .stroke(tertiaryColor.opacity(pulseOpacity), lineWidth: 0.5)
                .frame(width: size * 1.2, height: size * 1.2)
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 10).repeatForever(autoreverses: false)) {
                ringRotation = 360
            }
            
            withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                particleScale = 1.0
            }
            
            withAnimation(Animation.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                pulseOpacity = 0.4
            }
            
            withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                scannerOffset = 150
            }
            
            isAnimating = true
        }
    }
}

// MARK: - Quantum Particle Component
struct QuantumParticle: View {
    let color: Color
    let size: CGFloat
    let angle: Double
    let distance: CGFloat
    let scale: CGFloat
    
    var body: some View {
        ZStack {
            // Glowing core
            Circle()
                .fill(color)
                .frame(width: size, height: size)
                .scaleEffect(scale)
                .shadow(color: color.opacity(0.8), radius: 5, x: 0, y: 0)
            
            // Halo effect
            Circle()
                .stroke(color.opacity(0.3), lineWidth: 1)
                .frame(width: size * 1.5, height: size * 1.5)
                .scaleEffect(scale)
        }
        .offset(
            x: cos(angle * .pi / 180) * distance,
            y: sin(angle * .pi / 180) * distance
        )
    }
}

// MARK: - Color Extension
extension Color {
    init(_ name: String, defaultValue: Color) {
        if UIColor(named: name) != nil {
            self.init(name)
        } else {
            self = defaultValue
        }
    }
}

// MARK: - Preview
struct SciFiQuantumSpinnerView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            SciFiQuantumSpinnerView()
        }
    }
}
