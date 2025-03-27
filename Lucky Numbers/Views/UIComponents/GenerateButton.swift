//
//  GenerateButton.swift
//  JackpotAI
//
//  Created by Matt Willie on 3/19/25.
//
import SwiftUI

struct PremiumGenerateButton: View {
    // Add action parameter to handle button press from MainView
    var action: () -> Void
    
    // Scale parameter for flexible sizing
    var scale: CGFloat = 0.9
    
    // Animation states
    @State private var isPressed = false
    @State private var hoverIntensity: CGFloat = 0.0
    @State private var rotationDegrees: Double = 0.0
    @State private var sparkleOpacity: CGFloat = 0.0
    @State private var pulseScale: CGFloat = 1.0
    @State private var colorCyclePhase: CGFloat = 0.0
    @State private var borderPulse: CGFloat = 1.0
    
    // Optional properties to match MainView functionality
    var isDisabled: Bool = false
    var isAIMode: Bool = false
    
    // Timer for subtle animations
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Button(action: {
            if !isDisabled {
                hapticFeedback(style: .medium)
                action()
            }
        }) {
            ZStack {
                // Outer gradient border with pulsing color animation
                ZStack {
                    // Base gradient with more colors including purple and red
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color("neonBlue"),
                                    Color.red.opacity(0.4),
                                    Color("darkBlue")
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Animated color overlay 2 - blue pulse (offset timing, more intense)
                    Circle()
                        .fill(Color("neonBlue"))
                        .opacity(0.7 + (sin(Date().timeIntervalSince1970 * 0.9 + 1) + 1) * 0.15)
                        .blendMode(.overlay)
                        
                    // Animated color overlay 4 - red pulse (new)
                    Circle()
                        .fill(Color.red)
                        .opacity(0.3 + (sin(Date().timeIntervalSince1970 * 0.7 + 3) + 1) * 0.15)
                        .blendMode(.overlay)
                        
                    // Moving gradient wave effect (more pronounced)
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.clear,
                                    Color.white.opacity(0.5),
                                    Color.clear
                                ]),
                                startPoint: UnitPoint(x: hoverIntensity * 2.5 - 0.8, y: 0.2),
                                endPoint: UnitPoint(x: hoverIntensity * 2.5, y: 0.8)
                            )
                        )
                        .blendMode(.overlay)
                }
                .frame(width: 115 * scale, height: 115 * scale)
                .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 5)
                
                // Inner shadow for outer rectangle - enhanced for premium look
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.4),
                                Color.black.opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5 * scale
                    )
                    .blur(radius: 0.5)
                    .frame(width: 110 * scale, height: 110 * scale)
                    .scaleEffect(borderPulse)
                
                // Animated colored ring - enhanced with more colors
                Circle()
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                Color("gold"),
                                Color("neonBlue"),
                                Color.red.opacity(0.8),
                                Color("darkBlue"),
                                Color("gold")
                            ]),
                            center: .center,
                            startAngle: .degrees(Double(colorCyclePhase) * 360),
                            endAngle: .degrees(Double(colorCyclePhase) * 360 + 360)
                        ),
                        lineWidth: 2.5 * scale
                    )
                    .frame(width: 112 * scale, height: 112 * scale)
                    .opacity(0.8)
                    .blur(radius: 0.8)
                
                // Metallic finish layer
                Circle()
                    .fill(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.0),
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.0),
                                Color.white.opacity(0.1)
                            ]),
                            center: .center,
                            startAngle: .degrees(rotationDegrees),
                            endAngle: .degrees(360 + rotationDegrees)
                        )
                    )
                    .frame(width: 115 * scale, height: 115 * scale)
                    .blendMode(.overlay)
                
                // Inner content area - dark theme to match app background
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color("blue").opacity(0.9),
                                Color("darkBlue").opacity(0.95)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .stroke(Color.black, lineWidth: 2 * scale)
                    .frame(width: 100 * scale, height: 100 * scale)
                    .shadow(color: Color.black.opacity(0.9), radius: 8, x: 2, y: 2)
                
                // Subtle inner pattern for premium look
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.05),
                                Color.clear
                            ]),
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 120 * scale
                        )
                    )
                    .frame(width: 100 * scale, height: 100 * scale)
                
                // Inner shadow effect for depth
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.2),
                                Color.black.opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5 * scale
                    )
                    .blur(radius: 0.5)
                    .frame(width: 100 * scale, height: 100 * scale)
                
                // Content: Premium "GENERATE NUMBERS" with stars
                VStack(spacing: 0 * scale) {
                    // Enhanced stars icon
                    ZStack {
                        // Glowing background for stars
                        Circle()
                            .fill(Color("neonBlue").opacity(0.1))
                            .frame(width: 30 * scale, height: 30 * scale)
                            .blur(radius: 5)
                            .opacity(0.3 + sparkleOpacity * 0.3)
                        
                        // Main star
                        starShape(points: 4, innerRatio: 0.4)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color("gold"),
                                        Color("softGold").opacity(0.8)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 16 * scale, height: 16 * scale)
                        
                        // Small star 1
                        starShape(points: 4, innerRatio: 0.4)
                            .fill(Color("neonBlue").opacity(0.9))
                            .frame(width: 8 * scale, height: 8 * scale)
                            .offset(x: 14 * scale, y: -4 * scale)
                        
                        // Small star 2
                        starShape(points: 4, innerRatio: 0.4)
                            .fill(Color("gold").opacity(0.8))
                            .frame(width: 6 * scale, height: 6 * scale)
                            .offset(x: -12 * scale, y: -2 * scale)
                            
                        // Animated small sparkles for added premium effect
                        ForEach(0..<4) { i in
                            let angle = Double(i) * .pi / 2
                            starShape(points: 4, innerRatio: 0.5)
                                .fill(Color.white.opacity(0.4 * sparkleOpacity))
                                .frame(width: 3 * scale, height: 3 * scale)
                                .offset(
                                    x: cos(angle) * 20 * scale,
                                    y: sin(angle) * 20 * scale
                                )
                        }
                    }
                    .padding(.top, 0 * scale)
                    .shadow(color: Color("neonBlue").opacity(0.5), radius: 3, x: 0, y: 0)
                    
                    // Primary text - GENERATE
                    Text("GENERATE")
                        .font(.system(size: 15 * scale, weight: .bold))
                        .tracking(1)
                        .foregroundColor(.white)
                        .shadow(color: Color("neonBlue").opacity(0.8), radius: 2, x: 0, y: 1)
                    
                    // Secondary text - NUMBERS
                    Text("NUMBERS")
                        .font(.system(size: 10 * scale, weight: .semibold))
                        .tracking(1)
                        .foregroundColor(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color("gold"),
                                    Color("softGold").opacity(0.8)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color.black, radius: 1, x: 0, y: 1)
                        .padding(.top, 2 * scale)
                }
                .offset(y: -4 * scale) // Adjust content position
                
                // Button press overlay effect
                Circle()
                    .fill(Color("neonBlue").opacity(isPressed ? 0.15 : 0))
                    .frame(width: 100 * scale, height: 100 * scale)
            }
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .brightness(isPressed ? -0.05 : 0) // Slight darkening when pressed
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .opacity(isDisabled ? 0.5 : 1.0) // Apply opacity when disabled
        }
        .buttonStyle(PlainButtonStyle()) // No default button styling
        .disabled(isDisabled) // Disable the button when needed
        .pressAction {
            if !isDisabled {
                hapticFeedback(style: .medium)
                isPressed = true
            }
        } onRelease: {
            isPressed = false
            if !isDisabled {
                hapticFeedback(style: .light)
            }
        }
        .onReceive(timer) { _ in
            // Enhanced animations for premium feel
            withAnimation(.easeInOut(duration: 2)) {
                hoverIntensity = sin(Date().timeIntervalSince1970 * 0.5) * 0.5 + 0.5
                sparkleOpacity = sin(Date().timeIntervalSince1970 * 0.7) * 0.5 + 0.5
                
                // Subtle pulse animation
                let pulseTime = Date().timeIntervalSince1970 * 0.4
                pulseScale = 1.0 + sin(pulseTime) * 0.03
                
                // Color cycle animation - faster for more noticeable effect
                colorCyclePhase = (colorCyclePhase + 0.01).truncatingRemainder(dividingBy: 1.0)
                
                // Border pulsing animation - more pronounced
                borderPulse = 1.0 + sin(Date().timeIntervalSince1970 * 1.2) * 0.08
            }
            
            // Very slow rotation for metallic effect
            rotationDegrees += 0.2
            if rotationDegrees >= 360 {
                rotationDegrees = 0
            }
        }
    }
    
    // Create a star shape with specified number of points
    private func starShape(points: Int, innerRatio: CGFloat) -> some Shape {
        StarShape(points: points, innerRatio: innerRatio)
    }
    
    // Haptic feedback
    private func hapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// Custom star shape
struct StarShape: Shape {
    let points: Int
    let innerRatio: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * innerRatio
        
        var path = Path()
        
        let angleIncrement = .pi * 2 / CGFloat(points * 2)
        
        for i in 0..<(points * 2) {
            let angle = CGFloat(i) * angleIncrement - .pi / 2
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            
            let x = center.x + cos(angle) * radius
            let y = center.y + sin(angle) * radius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        path.closeSubpath()
        return path
    }
}

// Extension for gradient text
extension Text {
    func foregroundColor(_ gradient: LinearGradient) -> some View {
        self.overlay(gradient.mask(self))
    }
}

//// Preview
//struct PremiumGenerateButton_Previews: PreviewProvider {
//    static var previews: some View {
//        ZStack {
//            // Dark background to match app
//            LinearGradient(
//                gradient: Gradient(colors: [Color("darkBlue"), Color.black]),
//                startPoint: .top,
//                endPoint: .bottom
//            )
//            .ignoresSafeArea()
//            
//            // Standard size
//            PremiumGenerateButton()
//                .padding(.bottom, 200)
//            
//            // Scaled versions
//            PremiumGenerateButton(scale: 0.7)
//                .padding(.top, 200)
//                .padding(.trailing, 200)
//            
//            PremiumGenerateButton(scale: 1.2)
//                .padding(.top, 200)
//                .padding(.leading, 200)
//        }
//    }
//}
