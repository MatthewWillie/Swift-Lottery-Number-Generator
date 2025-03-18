//
//  PremiumTeaserView.swift
//  JackpotAI
//
//  Created by Matt Willie on 3/17/25.
//

import SwiftUI

struct PremiumFeatureTeaser: View {
    @EnvironmentObject private var iapManager: IAPManager
    @State private var showSubscriptionView = false
    
    let feature: String
    let description: String
    let iconName: String
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {
                    // Optional: Dismiss on background tap
                }
            
            // Main content
            VStack(spacing: 25) {
                // Feature icon
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color("neonBlue").opacity(0.3), Color("gold").opacity(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                
                // Feature info
                VStack(spacing: 10) {
                    Text(feature)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(description)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                // Subscription options
                VStack(spacing: 15) {
                    // Free usage indicator (if applicable)
                    if let remainingUses = getRemainingFreeUses() {
                        HStack {
                            Text("Free uses remaining: ")
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.7))
                            
                            Text("\(remainingUses)")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .foregroundColor(Color("neonBlue"))
                        }
                        .padding(.bottom, 5)
                    }
                    
                    // Subscribe button
                    Button(action: {
                        showSubscriptionView = true
                    }) {
                        Text("Unlock Premium")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 220)
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
                    
                    // Try once for free option (if applicable)
                    if canTryForFree() {
                        Button(action: {
                            useFreeAttempt()
                        }) {
                            Text("Try Once For Free")
                                .font(.subheadline)
                                .foregroundColor(Color("gold"))
                                .padding(.vertical, 5)
                        }
                    }
                    
                    // Dismiss option
                    Button(action: {
                        // Dismiss the teaser
                    }) {
                        Text("Maybe Later")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.vertical, 5)
                    }
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 35)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.black.opacity(0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("neonBlue"), Color("gold")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: Color("neonBlue").opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 30)
        }
        .sheet(isPresented: $showSubscriptionView) {
            SubscriptionView()
                .environmentObject(iapManager)
        }
    }
    
    // MARK: - Helper Methods
    
    private func getRemainingFreeUses() -> Int? {
        // Connect this to your SubscriptionTracker
        // Example: return subscriptionTracker.remainingFreeUses
        return 3 // Placeholder
    }
    
    private func canTryForFree() -> Bool {
        // Logic to determine if user can try this feature for free
        return getRemainingFreeUses() ?? 0 > 0
    }
    
    private func useFreeAttempt() {
        // Decrement the free usage counter
        // Example: subscriptionTracker.incrementUsage()
        
        // Then dismiss and allow feature access
    }
}

// MARK: - Small Premium Feature Indicator
struct PremiumFeatureIndicator: View {
    @State private var showTeaser = false
    
    let iconName: String
    let feature: String
    let description: String
    
    var body: some View {
        Button(action: {
            showTeaser = true
        }) {
            HStack(spacing: 5) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 10))
                    .foregroundColor(Color("gold"))
                
                Text("PREMIUM")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color("gold"))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.5))
                    .overlay(
                        Capsule()
                            .strokeBorder(Color("gold"), lineWidth: 1)
                    )
            )
        }
        .sheet(isPresented: $showTeaser) {
            PremiumFeatureTeaser(
                feature: feature,
                description: description,
                iconName: iconName
            )
        }
    }
}

// MARK: - Preview
struct PremiumFeatureTeasers_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            // Background for preview
            Color("darkBlue")
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Preview the indicator
                PremiumFeatureIndicator(
                    iconName: "wand.and.stars",
                    feature: "AI Number Prediction",
                    description: "Unlock access to AI powered tools that analyze historical data to generate numbers with higher win probability."
                )
                
                // Preview the full teaser
                PremiumFeatureTeaser(
                    feature: "AI Number Prediction",
                    description: "Unlock access to AI powered tools that analyze historical data to generate numbers with higher win probability.",
                    iconName: "wand.and.stars"
                )
                .environmentObject(IAPManager.shared)
            }
        }
    }
}
