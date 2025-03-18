//
//  FreeTrialView.swift
//  JackpotAI
//
//  Created by Matt Willie on 3/17/25.
//

import SwiftUI

struct FreeTrialView: View {
    var controller: ViewControl
    var dismissAction: () -> Void

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var iapManager: IAPManager
    @State private var currentPage = 0
    
    // Sample trial features to showcase
    let features: [TrialFeature] = [
        TrialFeature(
            title: "AI-Powered Predictions",
            description: "Our advanced AI model analyzes historical lottery data to generate smarter numbers with higher win probability.",
            iconName: "wand.and.stars",
            accentColor: Color("neonBlue")
        ),
        TrialFeature(
            title: "Personalized Analysis",
            description: "Get detailed insights on why certain numbers were selected for your specific lottery game.",
            iconName: "chart.xyaxis.line",
            accentColor: Color("gold")
        ),
        TrialFeature(
            title: "Ad-Free Experience",
            description: "Enjoy a clean, distraction-free interface while you focus on your lucky numbers.",
            iconName: "xmark.octagon.fill",
            accentColor: Color("neonBlue")
        ),
        TrialFeature(
            title: "Start Your 3-Day Free Trial",
            description: "Unlock all premium features - no charge for 3 days. Cancel anytime before trial ends.",
            iconName: "crown.fill",
            accentColor: Color("gold")
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            // Decorative elements
            decorativeBackground
            
            // Main content
            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: { dismiss();      controller.completeOnboarding()
 }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding([.top, .trailing], 20)
                }
                
                // Paging content
                TabView(selection: $currentPage) {
                    ForEach(0..<features.count, id: \.self) { index in
                        featureView(features[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                // Button area
                VStack(spacing: 15) {
                    // Action button (Continue or Start Trial)
                    Button(action: {
                        if currentPage < features.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            // Start trial
                            startFreeTrial()
                            dismissAction()

                        }
                    }) {
                        Text(currentPage < features.count - 1 ? "Continue" : "Start Free Trial")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        features[currentPage].accentColor,
                                        features[currentPage].accentColor.opacity(0.8)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(15)
                            .shadow(
                                color: features[currentPage].accentColor.opacity(0.5),
                                radius: 10,
                                x: 0,
                                y: 5
                            )
                    }
                    
                    // Skip button (except for last page)
                    if currentPage < features.count - 1 {
                        Button(action: {
                            withAnimation {
                                currentPage = features.count - 1
                            }
                        }) {
                            Text("Skip to Trial")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.bottom, 5)
                    } else {
                        // Terms info on last page
                        Text("No charge for 3 days. $4.99/month after trial ends. Cancel anytime.")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 10)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Components
    
    private var decorativeBackground: some View {
        ZStack {
            // Top decoration
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color("neonBlue").opacity(0.3), Color.clear]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .frame(width: 300, height: 300)
                .offset(y: -180)
            
            // Bottom decoration
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color("gold").opacity(0.2), Color.clear]),
                    startPoint: .bottom,
                    endPoint: .top
                ))
                .frame(width: 350, height: 350)
                .offset(y: 200)
        }
    }
    
    private func featureView(_ feature: TrialFeature) -> some View {
        VStack(spacing: 25) {
            Spacer()
            
            // Feature icon
            ZStack {
                Circle()
                    .fill(feature.accentColor.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: feature.iconName)
                    .font(.system(size: 50))
                    .foregroundColor(feature.accentColor)
            }
            .padding(.bottom, 30)
            
            // Feature text
            VStack(spacing: 15) {
                Text(feature.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(feature.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Actions
    
    private func startFreeTrial() {
        // Implement your free trial logic here
        // This would connect to your IAP system
        iapManager.purchaseSubscription()
    }
}

// MARK: - Supporting Types

struct TrialFeature {
    let title: String
    let description: String
    let iconName: String
    let accentColor: Color
}

// MARK: - Preview
struct FreeTrialView_Previews: PreviewProvider {
    static var previews: some View {
        FreeTrialView(
            controller: ViewControl(),
            dismissAction: {
                // This is just a no-op for preview
                print("Dismiss action called in preview")
            }
        )
        .environmentObject(IAPManager.shared)
    }
}
