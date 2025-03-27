//
//  PremiumAISwitch.swift
//  Lucky Numbers
//
//  Created by Code AI on 3/21/25.
//

import SwiftUI

struct PremiumAISwitch: View {
    @Binding var isAIMode: Bool
    var onToggle: ((Bool) -> Void)?
    
    // Animation states
    @State private var animateIcon = false
    @State private var animateGlow = false
    @State private var animatePress = false
    
    var body: some View {
        VStack(spacing: 8) {
            // Main control
            HStack(spacing: 12) {
                // Standard mode option
                HStack(spacing: 6) {
                    // Icon with shimmer effect
                    ZStack {
                        Image(systemName: "dice.fill")
                            .font(.system(size: 16))
                            .foregroundColor(!isAIMode ? .white : .white.opacity(0.5))
                            .shadow(color: !isAIMode ? Color("neonBlue").opacity(0.8) : .clear, radius: 3, x: 0, y: 0)
                            
                    }
                    
                    Text("Standard")
                        .font(.system(size: 13, weight: !isAIMode ? .semibold : .regular))
                        .foregroundColor(!isAIMode ? .white : .white.opacity(0.5))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    !isAIMode ?
                        // Multi-layer background for 3D effect
                        ZStack {
                            // Base gradient
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color("neonBlue").opacity(0.3),
                                            Color("neonBlue").opacity(0.15)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            
                            // Subtle highlight overlay
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .white.opacity(0.2),
                                            .clear
                                        ]),
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                )
                                .padding(1)
                            
                            // Border
                            Capsule()
                                .strokeBorder(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color("neonBlue").opacity(0.9),
                                            Color("neonBlue").opacity(0.4)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 1.5
                                )
                        }
                        .shadow(color: Color("neonBlue").opacity(0.4), radius: 5, x: 0, y: 0)
                        .scaleEffect(animatePress && !isAIMode ? 0.95 : 1.0)
                        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: animatePress)
                        : nil
                )
                .onTapGesture {
                    if isAIMode {
                        // Haptic feedback
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        
                        // Press animation
                        withAnimation {
                            animatePress = true
                        }
                        
                        // Reset animation after delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            animatePress = false
                        }
                        
                        withAnimation {
                            isAIMode = false
                            onToggle?(false)
                        }
                    }
                }
                
                // Divider with metallic effect
                ZStack {
                    // Shadow for 3D effect
                    Rectangle()
                        .fill(Color.black.opacity(0.5))
                        .frame(width: 1, height: 24)
                        .offset(x: 1, y: 0)
                        .blur(radius: 0.5)
                    
                    // Highlight
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 1, height: 24)
                }
                
                // AI mode option
                HStack(spacing: 6) {
                    // Icon with animation
                    ZStack {
                        // Dynamic glow effect
                        if isAIMode && animateGlow {
                            Image(systemName: "sparkles")
                                .font(.system(size: 16))
                                .foregroundColor(Color("gold"))
                                .opacity(0.7)
                                .blur(radius: 3)
                                .scaleEffect(1.3)
                        }
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 16))
                            .foregroundColor(isAIMode ? Color("gold") : .white.opacity(0.5))
                            .scaleEffect(animateIcon && isAIMode ? 1.3 : 1.0)
                            .animation(
                                Animation.spring(response: 0.3, dampingFraction: 0.6)
                                    .repeatCount(1),
                                value: animateIcon
                            )
                            .shadow(color: isAIMode ? Color("gold").opacity(0.8) : .clear, radius: 3, x: 0, y: 0)
                    }
                    
                    // Text label with premium visual effects
                    Text("AI Mode")
                        .font(.system(size: 13, weight: isAIMode ? .semibold : .regular))
                        .foregroundColor(isAIMode ? Color("gold") : .white.opacity(0.5))
                        .shadow(color: isAIMode ? Color("gold").opacity(0.6) : .clear, radius: 1, x: 0, y: 0)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    isAIMode ?
                        // Multi-layer background for premium 3D effect
                        ZStack {
                            // Base gradient
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color("gold").opacity(0.25),
                                            Color("gold").opacity(0.1)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            
                            // Subtle highlight overlay
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .white.opacity(0.2),
                                            .clear
                                        ]),
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                )
                                .padding(1)
                            
                            // Premium gold border
                            Capsule()
                                .strokeBorder(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color("gold").opacity(0.9),
                                            Color("gold").opacity(0.5),
                                            Color("softGold").opacity(0.3)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        }
                        .shadow(color: Color("gold").opacity(0.4), radius: 5, x: 0, y: 2)
                        .scaleEffect(animatePress && isAIMode ? 0.95 : 1.0)
                        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: animatePress)
                        : nil
                )
                .onTapGesture {
                    if !isAIMode {
                        // Haptic feedback
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        
                        // Press animation
                        withAnimation {
                            animatePress = true
                        }
                        
                        // Reset animation after delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            animatePress = false
                        }
                        
                        withAnimation {
                            isAIMode = true
                            onToggle?(true)
                            animateIcon = true
                            
                            // Reset icon animation after delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                animateIcon = false
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 8)
            .background(
                // Luxurious inset background with multi-layer shadows
                ZStack {
                    // Deep inset base
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.5))
                        .shadow(color: Color.black.opacity(0.6), radius: 3, x: 1, y: 1)
                    
                    // Inner shadow for depth
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.black.opacity(0.7),
                                    Color.black.opacity(0.3)
                                ]),
                                startPoint: .bottomTrailing,
                                endPoint: .topLeading
                            ),
                            lineWidth: 2
                        )
                        .blur(radius: 2)
                        .offset(x: 1, y: 1)
                        .mask(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.black)
                                .padding(1)
                        )
                    
                    // Subtle highlight for bevel effect
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            // Outer shadow for premium depth
            .shadow(color: Color.black.opacity(0.5), radius: 5, x: 1, y: 2)
            
            // Mode description text
            if isAIMode {
                // AI mode description
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 9))
                        .foregroundColor(Color("gold"))
                        .shadow(color: Color("gold").opacity(0.6), radius: 1, x: 0, y: 0)
                    
                    Text("AI-powered smart predictions")
                        .font(.system(size: 10))
                        .foregroundColor(Color("gold").opacity(0.9))
                        .shadow(color: Color.black, radius: 2, x: 0, y: 1)
                }
                .padding(.top, 2)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: isAIMode)
            } else {
                // Standard mode description
                HStack(spacing: 4) {
                    Image(systemName: "shuffle")
                        .font(.system(size: 9))
                        .foregroundColor(Color("neonBlue"))
                        .shadow(color: Color("neonBlue").opacity(0.6), radius: 1, x: 0, y: 0)
                    
                    Text("Classic random number generation")
                        .font(.system(size: 10))
                        .foregroundColor(Color("neonBlue").opacity(0.9))
                        .shadow(color: Color.black, radius: 2, x: 0, y: 1)
                }
                .padding(.top, 2)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: isAIMode)
            }
        }
        .onAppear {
            // Start animations
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    animateGlow = true
                }
            }
        }
    }
}

// Preview
struct PremiumAISwitch_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            // Background for preview
            Color("darkBlue").ignoresSafeArea()
            
            // Preview both states
            VStack(spacing: 40) {
                PremiumAISwitch(isAIMode: .constant(false))
                PremiumAISwitch(isAIMode: .constant(true))
            }
        }
    }
}
