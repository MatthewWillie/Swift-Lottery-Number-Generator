//
//  EuroMillions.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/20/25.
//

import SwiftUI

struct EuroMillionsDraw: View {
    @State private var mainNumbers: [Int] = []
    @State private var luckyNumbers: [Int] = []
    @State private var animationTrigger: Bool = false
    @State private var hasDrawnOnce: Bool = false
    @State private var logoScale: CGFloat = 1.0
    @State private var logoOffset: CGFloat = 0.0
    @State private var logoOpacity: Double = 1.0
    
    var body: some View {
        ZStack {
            // Premium gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.45),
                    Color(red: 0.05, green: 0.1, blue: 0.25)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            // Main content
            VStack(spacing: 50) {
                // Title or logo depending on state
                if hasDrawnOnce {
                    Image("EuroMillions")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                        .shadow(color: .white.opacity(0.4), radius: 15, x: 0, y: 0)
                }
                
                if hasDrawnOnce {
                    // Main numbers container
                    GlassContainer {
                        HStack(spacing: 10) {
                            ForEach(mainNumbers.indices, id: \.self) { index in
                                PremiumBallView(
                                    finalNumber: mainNumbers[index],
                                    ballColor: Color.blue.opacity(0.9),
                                    delay: Double(index) * 0.4,
                                    numberRange: 1...50,
                                    trigger: animationTrigger,
                                    isMainNumber: true // Flag to use smaller size for blue balls
                                )
                            }
                        }
                        .padding()
                    }
                    
                    // Lucky stars container
                    GlassContainer {
                        HStack(spacing: 10) {
                            ForEach(luckyNumbers.indices, id: \.self) { index in
                                PremiumBallView(
                                    finalNumber: luckyNumbers[index],
                                    ballColor: Color.yellow.opacity(0.9),
                                    delay: Double(index + mainNumbers.count) * 0.4,
                                    numberRange: 1...12,
                                    trigger: animationTrigger,
                                    isMainNumber: false // Flag for default size (yellow balls)
                                )
                            }
                        }
                        .padding()
                    }
                } else {
                    Spacer()
                        .frame(height: 342) // Placeholder for layout
                }
                
                // Premium button (always visible)
                PremiumButton(action: {
                    withAnimation {
                        drawNumbers()
                    }
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                }) {
                    Text(hasDrawnOnce ? "Regenerate Numbers" : "Generate Numbers")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.vertical, 15)
                        .frame(maxWidth: .infinity)
                }
                .frame(width: 260)
            }
            .padding(.vertical, 40)
            
            // Logo overlay before first draw
            if !hasDrawnOnce {
                Image("EuroMillions")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .offset(y: logoOffset)
                    .shadow(color: .white.opacity(0.4), radius: 15, x: 0, y: 0)
            }
        }
    }
    
    private func drawNumbers() {
        if !hasDrawnOnce {
            // First draw: smooth arc animation
            withAnimation(.easeInOut(duration: 1)) {
                // Keyframe-like behavior within one animation
                // Peak scale and offset at midpoint, then settle
                logoScale = 1.5 // Peak scale at arc apex
                logoOffset = -300 // Peak height of arc
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                // Midpoint: start scaling down and adjusting offset
                withAnimation(.easeInOut(duration: 0.5)) {
                    logoScale = 0.665 // Final scale (200/300)
                    logoOffset = -193 // Final position
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                hasDrawnOnce = true
                logoOpacity = 0.0 // Hide animated logo
                generateNumbers()
            }
        } else {
            // Subsequent draws: regenerate numbers
            generateNumbers()
        }
    }
    
    private func generateNumbers() {
        mainNumbers = Array((1...50).shuffled().prefix(5)).sorted()
        luckyNumbers = Array((1...12).shuffled().prefix(2)).sorted()
        animationTrigger.toggle()
    }
}

// Premium Ball View
struct PremiumBallView: View {
    let finalNumber: Int
    let ballColor: Color
    let delay: Double
    let numberRange: ClosedRange<Int>
    let trigger: Bool
    let isMainNumber: Bool // New parameter to differentiate blue and yellow ball sizes
    
    @State private var displayNumber: Int = 0
    @State private var rotation: Double = 0
    @State private var glow: CGFloat = 0
    @State private var scale: CGFloat = 0
    
    private var size: CGFloat {
        isMainNumber ? 60 : 60 // Reduce blue balls to 60, keep yellow at 60 for consistency
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [ballColor.opacity(0.6), ballColor]),
                        center: .center,
                        startRadius: 1,
                        endRadius: size/2
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(.white.opacity(1), lineWidth: 1)
                        .blur(radius: 2)
                )
                .shadow(color: ballColor.opacity(0.6), radius: glow, x: 0, y: 0)
            
            Text("\(displayNumber)")
                .font(.system(size: size/2.5, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2)
        }
        .scaleEffect(scale)
        .rotation3DEffect(Angle.degrees(rotation), axis: (x: 1, y: 0, z: 0))
        .onAppear(perform: runAnimation)
        .onChange(of: trigger) { _ in runAnimation() }
    }
    
    private func runAnimation() {
        scale = 0
        rotation = 0
        glow = 0
        displayNumber = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.spring(response: 0.9, dampingFraction: 0.3, blendDuration: 0.4)) {
                scale = 1.0
            }
            withAnimation(.easeInOut(duration: 1.2)) {
                rotation = 1080
                glow = 10
            }
            let duration = 1.0
            let interval = 0.04
            var elapsed: Double = 0
            Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
                elapsed += interval
                if elapsed < duration {
                    displayNumber = Int.random(in: numberRange)
                } else {
                    displayNumber = finalNumber
                    withAnimation(.easeOut(duration: 0.3)) {
                        glow = 5
                    }
                    timer.invalidate()
                }
            }
        }
    }
}

// Glass Container View
struct GlassContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.1))
                    .blur(radius: 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 10)
            )
    }
}

// Premium Button
struct PremiumButton<Content: View>: View {
    let action: () -> Void
    let content: Content
    
    @State private var isPressed: Bool = false // State to track button press
    
    init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Button(action: {
            // Trigger action and haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            action()
        }) {
            content
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.1, green: 0.3, blue: 0.6, opacity: 0.8), // Darker blue
                                    Color(red: 0.05, green: 0.2, blue: 0.5, opacity: 0.6) // Lighter blue
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.9), lineWidth: 2)
                                .blur(radius: 2)
                        )
                        .shadow(color: Color.blue.opacity(0.4), radius: 10, x: 0, y: 6)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0) // Scale down on press
                .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.1), value: isPressed) // Smooth spring animation
                .pressAction {
                    isPressed = true // Set press state on button press
                } onRelease: {
                    isPressed = false // Reset press state on release
                }
        }
    }
}

struct EuroMillionsDraw_Previews: PreviewProvider {
    static var previews: some View {
        EuroMillionsDraw()
    }
}
