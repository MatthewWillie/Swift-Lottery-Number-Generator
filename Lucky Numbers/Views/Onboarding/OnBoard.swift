//
//  OnBoard.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 11/13/22.
//


import SwiftUI
import Foundation

struct OnBoardView: View {
    @ObservedObject var controller: ViewControl
    
    @State private var isPresented: Bool = false
    @State private var showSheet: Bool = false
    @AppStorage("onboarding") var isShowOnBoard: Bool = true
    @State private var buttonOffSet: CGFloat = 10
    @State private var isAnimating: Bool = false
    @State private var textTitle: String = "Generate & Win!"
    
    let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            ZStack {
                // Background
                
                ZStack {
                    Image("background")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                        .opacity(0.9)
                    // **Glassmorphic Blur Overlay**
                    VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark, opacity: 0.2)
                        .edgesIgnoringSafeArea(.all)
                    Image("JackpotLogo")

                    // **Layered Gradients for Depth**
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color("darkBlue").opacity(1),
                            Color("black").opacity(0.5)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .edgesIgnoringSafeArea(.all)
                    
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color("gold").opacity(0.3),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: screenWidth * 0.1,
                        endRadius: screenWidth * 0.8
                    )
                    .edgesIgnoringSafeArea(.all)
                    
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color("neonBlue").opacity(0.4),
                            Color.clear
                        ]),
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                    .edgesIgnoringSafeArea(.all)
                }

                VStack {
//                    Spacer()
                    
                    // **Title**
                    Text(textTitle)
                        .foregroundColor(.white)
                        .bold()
                        .font(.custom("Helvetica", size: screenWidth * 0.11)) // Scales dynamically
                        .fontWeight(.heavy)
                        .transition(.opacity)
                        .id(textTitle)
                        .padding(.bottom, screenHeight * 0.02)

                    // **Subtitle**
                    Text("""
                        JackpotAI helps you choose the smartest lottery numbers using advanced data analysis and AI-powered insights.
                        Forget blind luck—AI optimizes your picks and boosts your chances.
                        
                        Let AI analyze the trends.
                        Pick your numbers.
                        Play smarter and win bigger.
                        """)
                        .bold()
                        .font(.custom("Helvetica", size: screenWidth * 0.06)) // Adjust font size dynamically
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, screenWidth * 0.05)
                    
                    // **Swipe to Start Button**
                    ZStack {
                        Capsule()
                            .fill(.white.opacity(0.2))
                        Capsule()
                            .fill(.white.opacity(0.2))
                            .padding(8)
                        Text("Get Started")
                            .font(.system(size: screenWidth * 0.05)) // Dynamic font size
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .offset(x: 10)
                        Image(systemName: "chevron.right.2")
                            .font(.system(size: screenWidth * 0.06, weight: .bold))
                            .opacity(0.2)
                            .offset(x: screenWidth * 0.25)

                        // **Swipe Capsule Dynamic**
                        HStack {
                            Capsule()
                                .fill(Color("neonBlue").opacity(0.4))
                                .frame(width: buttonOffSet + 70)
                            Spacer()
                        }
                        
                        // **Swipe Circle Button**
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(.white.opacity(0.4))
                                Circle()
                                    .fill(.black.opacity(0.7))
                                    .padding(8)
                                Image(systemName: "chevron.right.2")
                                    .font(.system(size: screenWidth * 0.07, weight: .bold))
                            }
                            .foregroundColor(Color("neonBlue"))
                            .frame(width: screenWidth * 0.15, height: screenWidth * 0.15)
                            .offset(x: buttonOffSet)
                            .gesture(
                                DragGesture()
                                    .onChanged({ gesture in
                                        if gesture.translation.width > 0 && buttonOffSet <= screenWidth - screenWidth * 0.25 {
                                            buttonOffSet = gesture.translation.width
                                        }
                                        if gesture.translation.width > 0 {
                                            textTitle = "Pick Numbers!"
                                        }
                                    })
                                    .onEnded({ _ in
                                        withAnimation(.easeOut(duration: 0.5)) {
                                            if buttonOffSet > screenWidth / 2 {
                                                hapticFeedback.impactOccurred()
                                                buttonOffSet = screenWidth - screenWidth * 0.15
                                                controller.currentView = .home
                                                isShowOnBoard = false
                                                controller.completeOnboarding()
                                            } else {
                                                hapticFeedback.impactOccurred()
                                                buttonOffSet = 0
                                                textTitle = "Generate & Win!"
                                            }
                                        }
                                    })
                            )
                            Spacer()
                        }
                    }
                    .frame(width: screenWidth * 0.85, height: screenWidth * 0.2)
                    .padding()
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : screenHeight * 0.05)
                    .animation(.easeOut(duration: 1).delay(0.5), value: isAnimating)
                }
                .offset(y: -screenHeight * 0.1)
            }
            .onAppear {
                self.isAnimating = true
            }
            .preferredColorScheme(.light)
        }
    }
}

// MARK: - Preview
struct MyPreviewProvider_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnBoardView(controller: ViewControl())
                .previewDevice("iPhone 15 Pro")
        }
    }
}
