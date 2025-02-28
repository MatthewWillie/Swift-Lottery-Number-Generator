//
//  EuroMillions.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/20/25.
//

import SwiftUI

struct EuroMillionsView: View {
    @State private var mainNumbers: [Int] = []
    @State private var luckyNumbers: [Int] = []
    @State private var animationTrigger: Bool = false
    @State private var hasDrawnOnce: Bool = false
    @State private var logoScale: CGFloat = 1.0
    @State private var logoOffset: CGFloat = 0.0
    @State private var logoOpacity: Double = 1.0
    
    @Environment(\.dismiss) var dismiss // Enables manual dismiss
    
    var body: some View {
        ZStack {
            // Premium gradient background
            BackgroundView()
            
            VStack {
                Spacer()
                
                PremiumButton(action: {
                    withAnimation { drawNumbers() }
                })
                .frame(width: UIScreen.main.bounds.width * 0.35, height: UIScreen.main.bounds.height * 0.45)
                .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 20)
                .zIndex(2)

                
            }
            
            // Custom Back Button (Left Corner)
            VStack {
                HStack {
                    Button(action: {
                        dismiss() // Dismiss the full-screen view
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                            Text("Back")
                                .font(.headline)
                        }
                        .foregroundColor(.blue)
                        .padding(10)
                        .background(Color.black.opacity(0.4))
                        .clipShape(Capsule())
                        .shadow(radius: 3)
                    }
                    .padding(.leading, 20)
                    .padding(.top, UIScreen.main.bounds.height * 0.03)
                    Spacer()
                }
                Spacer()
            }
            
            VStack(spacing: 30) {
                // Title or logo depending on state
                if hasDrawnOnce {
                    Image("EuroMillions")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                        .shadow(color: .black.opacity(0.9), radius: 15, x: 0, y: 4)
                }
                
                if hasDrawnOnce {
                    // Main numbers container (blue balls)
                    GlassContainer {
                        HStack(spacing: 10) {
                            ForEach(mainNumbers.indices, id: \.self) { index in
                                PremiumBallView(
                                    finalNumber: mainNumbers[index],
                                    ballColor: Color.blue.opacity(0.9),
                                    delay: Double(index) * 0.4,
                                    numberRange: 1...50,
                                    trigger: animationTrigger,
                                    isMainNumber: true
                                )
                            }
                        }
                        .padding()
                    }
                    
                    // Lucky stars container (yellow stars)
                    GlassContainer {
                        HStack(spacing: 10) {
                            ForEach(luckyNumbers.indices, id: \.self) { index in
                                PremiumBallView(
                                    finalNumber: luckyNumbers[index],
                                    ballColor: Color.yellow.opacity(0.9),
                                    delay: Double(index + mainNumbers.count) * 0.4,
                                    numberRange: 1...12,
                                    trigger: animationTrigger,
                                    isMainNumber: false
                                )
                            }
                        }
                        .padding()
                    }
                } else {
                    Spacer().frame(height: 342) // Layout placeholder
                }
            }
            .padding(.vertical, -253)
            
            // Logo overlay before first draw
            if !hasDrawnOnce {
                Image("EuroMillions")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .offset(y: logoOffset)
                    .shadow(color: .black.opacity(0.9), radius: 15, x: 0, y: 4)
            }
        }
    }
    
    private func drawNumbers() {
        if !hasDrawnOnce {
            withAnimation(.easeInOut(duration: 1)) {
                logoScale = 1.5
                logoOffset = -300
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    logoScale = 0.665
                    logoOffset = -224
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                hasDrawnOnce = true
                logoOpacity = 0.0
                generateNumbers()
            }
        } else {
            generateNumbers()
        }
    }
    
    private func generateNumbers() {
        mainNumbers = Array((1...50).shuffled().prefix(5)).sorted()
        luckyNumbers = Array((1...12).shuffled().prefix(2)).sorted()
        animationTrigger.toggle()
    }
}


// MARK: - PremiumBallView

struct PremiumBallView: View {
    let finalNumber: Int
    let ballColor: Color
    let delay: Double
    let numberRange: ClosedRange<Int>
    let trigger: Bool
    let isMainNumber: Bool
    
    @State private var displayNumber: Int = 0
    @State private var rotation: Double = 0
    @State private var glow: CGFloat = 0
    @State private var scale: CGFloat = 0
    
    private var size: CGFloat { 65 }
    
    var body: some View {
        ZStack {
            if isMainNumber {
                Image("lotto_ball")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: size, height: size)
                                .shadow(color: Color.black.opacity(0.6), radius: 5, x: 0, y: 2)
            } else {
                Image("red_ball")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .foregroundColor(ballColor)
                    .shadow(color: .black.opacity(0.6), radius: 5, x: 0, y: 2)
            }
            
            Text("\(displayNumber)")
                .font(.custom("Times New Roman", size: size / 2)).bold()
                .foregroundColor(isMainNumber ? .black : .black)
                .shadow(color: .black.opacity(isMainNumber ? 0.3 : 0), radius: 2)

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
            withAnimation(.spring(response: 0.9, dampingFraction: 0.4, blendDuration: 0.9)) {
                scale = 1.0
            }
            withAnimation(.easeInOut(duration: 1)) {
                rotation = 1800
                glow = 1
            }
            let duration = 0.8
            let interval = 0.04
            var elapsed: Double = 0
            Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
                elapsed += interval
                if elapsed < duration {
                    displayNumber = Int.random(in: numberRange)
                } else {
                    displayNumber = finalNumber
                    withAnimation(.easeOut(duration: 0.3)) {
                        glow = 1
                    }
                    timer.invalidate()
                }
            }
        }
    }
}

// MARK: - GlassContainer

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

// MARK: - PremiumButton

struct PremiumButton: View {
    let action: () -> Void

    var body: some View {
        GeometryReader { geometry in
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                action()
            }) {
                Image("button")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.85) // Dynamic size
                    .shadow(color: Color("neonBlue").opacity(0.7), radius: 5, x: 1, y: 2)
                    .shadow(color: Color("black").opacity(0.7), radius: 12, x: 3, y: 12)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}


struct EuroMillionsDraw_Previews: PreviewProvider {
    static var previews: some View {
        EuroMillionsView()
    }
}
