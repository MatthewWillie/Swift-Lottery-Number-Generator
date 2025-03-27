//
//  SubscriptionView.swift
//  JackpotAI
//
//  Created by Matt Willie on 3/17/25.
//

import SwiftUI

struct SubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var iapManager: IAPManager
    @EnvironmentObject private var subscriptionTracker: SubscriptionTracker
    @State private var selectedPlan: SubscriptionPlan = .monthly
    
    // Define subscription plans
    enum SubscriptionPlan: String, CaseIterable, Identifiable {
        case monthly = "Monthly"
        case yearly = "Yearly"
        
        var id: String { rawValue }
        
        var price: String {
            switch self {
            case .monthly: return "$4.99"
            case .yearly: return "$39.99"
            }
        }
        
        var period: String {
            switch self {
            case .monthly: return "month"
            case .yearly: return "year"
            }
        }
        
        var savings: String? {
            switch self {
            case .monthly: return nil
            case .yearly: return "Save 33%"
            }
        }
        
        var productIdentifier: String {
            switch self {
            case .monthly: return "com.jackpotai.subscription.monthly"
            case .yearly: return "com.jackpotai.subscription.yearly"
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let safeArea = geometry.safeAreaInsets
            
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color("darkBlue"), Color.black]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Sparkles and effects
                ZStack {
                    // Large decorative elements - adjusted position based on screen size
                    Circle()
                        .fill(Color("neonBlue").opacity(0.1))
                        .frame(width: min(300, geometry.size.width * 0.7))
                        .blur(radius: 30)
                        .offset(x: -geometry.size.width * 0.25, y: -geometry.size.height * 0.25)
                    
                    Circle()
                        .fill(Color("gold").opacity(0.1))
                        .frame(width: min(250, geometry.size.width * 0.6))
                        .blur(radius: 25)
                        .offset(x: geometry.size.width * 0.25, y: geometry.size.height * 0.25)
                }
                
                // Add scrollview for smaller devices
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Add spacing to account for close button
                        Spacer().frame(height: safeArea.top + 40)
                        
                        // Header
                        VStack(spacing: 0) {
                            Text("JACKPOT AI")
                                .font(.system(size: adaptiveFontSize(defaultSize: 24, screenWidth: geometry.size.width)))
                                .foregroundColor(Color("gold"))
                                .tracking(2)
                                .padding(.top, adaptiveSpacing(defaultSpacing: 25, screenHeight: geometry.size.height))
                            
                            Text("PREMIUM")
                                .font(.system(size: adaptiveFontSize(defaultSize: 36, screenWidth: geometry.size.width), weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: Color("neonBlue").opacity(0.5), radius: 10, x: 0, y: 0)
                        }
                        .padding(.bottom, adaptiveSpacing(defaultSpacing: 10, screenHeight: geometry.size.height))
                        
                        // Free trial callout
                        freeTrialCallout(screenWidth: geometry.size.width)
                            .padding(.bottom, adaptiveSpacing(defaultSpacing: 15, screenHeight: geometry.size.height))
                        
                        // Premium features
                        featuresSection(screenWidth: geometry.size.width, screenHeight: geometry.size.height)
                            .padding(.bottom, adaptiveSpacing(defaultSpacing: 15, screenHeight: geometry.size.height))
                        
                        // Subscription options
                        subscriptionOptionsSection(screenWidth: geometry.size.width)
                            .padding(.bottom, adaptiveSpacing(defaultSpacing: 20, screenHeight: geometry.size.height))
                        
                        // Action buttons
                        actionButtonsSection
                        
                        // Terms and conditions
                        termsSection
                            .padding(.top, adaptiveSpacing(defaultSpacing: 20, screenHeight: geometry.size.height))
                            .padding(.bottom, safeArea.bottom + 20) // Add bottom padding for scrolling
                    }
                    .padding(.horizontal, 20)
                }
                
                // Close button - fixed positioning
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: min(28, geometry.size.width * 0.07)))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.top, safeArea.top + 40)
                        .padding(.trailing, 30)
                    }
                    
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.all)
    }
    
    // MARK: - Adaptive Helpers
    
    private func adaptiveFontSize(defaultSize: CGFloat, screenWidth: CGFloat) -> CGFloat {
        let scaleFactor = min(screenWidth / 390, 1.2) // 390 is baseline iPhone size
        return max(defaultSize * scaleFactor, defaultSize * 0.7) // Don't go below 70% of original
    }
    
    private func adaptiveSpacing(defaultSpacing: CGFloat, screenHeight: CGFloat) -> CGFloat {
        let scaleFactor = min(screenHeight / 844, 1.2) // 844 is baseline iPhone 13 Pro height
        return max(defaultSpacing * scaleFactor, 5) // Minimum spacing of 5
    }
    
    // MARK: - UI Components
    
    private func freeTrialCallout(screenWidth: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color("neonBlue").opacity(0.15), Color("gold").opacity(0.15)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(colors: [Color("neonBlue").opacity(0.5), Color("gold").opacity(0.5)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1
                        )
                )
            
            HStack(spacing: 12) {
                Image(systemName: "gift.fill")
                    .font(.system(size: min(24, screenWidth * 0.055)))
                    .foregroundColor(Color("gold"))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("3-DAY FREE TRIAL")
                        .font(.system(size: min(16, screenWidth * 0.045), weight: .bold))
                        .foregroundColor(Color("gold"))
                    
                    Text("Try all premium features at no cost")
                        .font(.system(size: min(12, screenWidth * 0.035)))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
    
    private func featuresSection(screenWidth: CGFloat, screenHeight: CGFloat) -> some View {
        VStack(spacing: adaptiveSpacing(defaultSpacing: 12, screenHeight: screenHeight)) {
            PremiumFeatureRow(
                iconName: "wand.and.stars",
                title: "Advanced AI Number Predictions",
                description: "Get premium predictions with higher win probabilities",
                screenWidth: screenWidth
            )
            
            PremiumFeatureRow(
                iconName: "chart.bar.fill",
                title: "In-Depth Lottery Analysis",
                description: "Discover patterns and trends in winning numbers",
                screenWidth: screenWidth
            )
            
            PremiumFeatureRow(
                iconName: "xmark.octagon.fill",
                title: "Ad-Free Experience",
                description: "Enjoy a clean, uninterrupted interface",
                screenWidth: screenWidth
            )
            
            PremiumFeatureRow(
                iconName: "bell.fill",
                title: "Jackpot Alerts",
                description: "Get notified when jackpots reach record highs",
                screenWidth: screenWidth
            )
        }
        .padding(.vertical, 5)
    }
    
    private func subscriptionOptionsSection(screenWidth: CGFloat) -> some View {
        VStack(spacing: 12) {
            Text("Choose Your Plan")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 5)
            
            ForEach(SubscriptionPlan.allCases) { plan in
                SubscriptionPlanButton(
                    plan: plan,
                    isSelected: selectedPlan == plan,
                    screenWidth: screenWidth,
                    action: {
                        withAnimation(.spring()) {
                            selectedPlan = plan
                        }
                    }
                )
            }
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            // Subscribe button
            Button(action: {
                // Implement subscription based on selected plan
                if iapManager.isPurchasing {
                    return
                }
                
                // Start the free trial first if not already in one
                if !subscriptionTracker.isInFreeTrial {
                    subscriptionTracker.startFreeTrial()
                }
                
                // Use the selected plan's product identifier
                iapManager.purchaseSubscription(productIdentifier: selectedPlan.productIdentifier)
            }) {
                HStack {
                    if iapManager.isPurchasing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.trailing, 10)
                    }
                    
                    Text(iapManager.isPurchasing ? "Processing..." : "Start Free Trial")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color("neonBlue"), Color("darkBlue")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(15)
                .shadow(color: Color("neonBlue").opacity(0.5), radius: 10, x: 0, y: 5)
            }
            .disabled(iapManager.isPurchasing)
            
            // Free trial explanation
            Text("No charge for 3 days. Auto-renews at \(selectedPlan.price)/\(selectedPlan.period) after trial ends. Cancel anytime.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 20)
                .padding(.top, 4)
            
            // Restore purchases
            Button(action: {
                if !iapManager.isPurchasing {
                    iapManager.restorePurchases()
                }
            }) {
                Text("Restore Purchases")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .disabled(iapManager.isPurchasing)
            .padding(.top, 8)
        }
    }
    
    private var termsSection: some View {
        VStack(spacing: 5) {
            Text("Subscriptions will auto-renew unless canceled")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            
            HStack(spacing: 5) {
                Link("Terms of Service", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    .font(.caption)
                    .foregroundColor(Color("neonBlue"))
                
                Text("•")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                Link("Privacy Policy", destination: URL(string: "https://jackpotai.app/privacy-policy")!)
                    .font(.caption)
                    .foregroundColor(Color("neonBlue"))
            }
        }
        .multilineTextAlignment(.center)
    }
}

// MARK: - Supporting Components

struct PremiumFeatureRow: View {
    let iconName: String
    let title: String
    let description: String
    let screenWidth: CGFloat
    
    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            // Feature icon
            ZStack {
                Circle()
                    .fill(Color("neonBlue").opacity(0.2))
                    .frame(width: iconSize, height: iconSize)
                
                Image(systemName: iconName)
                    .font(.system(size: iconSize * 0.45))
                    .foregroundColor(Color("neonBlue"))
            }
            
            // Feature text
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: titleFontSize, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: descriptionFontSize))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2) // Allow 2 lines on smaller screens
            }
            
            Spacer()
        }
        .padding(.vertical, 5)
    }
    
    // Adaptive sizing
    private var iconSize: CGFloat {
        return min(max(screenWidth * 0.1, 30), 40)
    }
    
    private var titleFontSize: CGFloat {
        return min(max(screenWidth * 0.035, 13), 16)
    }
    
    private var descriptionFontSize: CGFloat {
        return min(max(screenWidth * 0.03, 10), 12)
    }
}

struct SubscriptionPlanButton: View {
    let plan: SubscriptionView.SubscriptionPlan
    let isSelected: Bool
    let screenWidth: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(plan.rawValue)
                            .font(.system(size: titleFontSize, weight: .semibold))
                            .foregroundColor(.white)
                        
                        if let savings = plan.savings {
                            Text(savings)
                                .font(.system(size: savingsFontSize, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color("gold"))
                                .cornerRadius(10)
                        }
                    }
                    
                    Text("\(plan.price) / \(plan.period)")
                        .font(.system(size: priceFontSize))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color("neonBlue") : Color.white.opacity(0.4), lineWidth: 2)
                        .frame(width: checkmarkSize, height: checkmarkSize)
                    
                    if isSelected {
                        Circle()
                            .fill(Color("neonBlue"))
                            .frame(width: checkmarkSize * 0.67, height: checkmarkSize * 0.67)
                    }
                }
            }
            .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(
                                isSelected ? Color("neonBlue") : Color.white.opacity(0.1),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Adaptive sizing
    private var titleFontSize: CGFloat {
        return min(max(screenWidth * 0.04, 14), 17)
    }
    
    private var savingsFontSize: CGFloat {
        return min(max(screenWidth * 0.025, 9), 12)
    }
    
    private var priceFontSize: CGFloat {
        return min(max(screenWidth * 0.035, 12), 15)
    }
    
    private var checkmarkSize: CGFloat {
        return min(max(screenWidth * 0.06, 20), 24)
    }
}

struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionView()
            .environmentObject(IAPManager.shared)
            .environmentObject(SubscriptionTracker())
    }
}
