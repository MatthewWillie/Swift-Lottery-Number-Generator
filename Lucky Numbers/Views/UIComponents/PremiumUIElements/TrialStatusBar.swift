//
//  TrialStatusBar.swift
//  JackpotAI
//
//  Created by Matt Willie on 3/18/25.
//
import SwiftUI
import Firebase

// MARK: - Trial Status Bar View
struct TrialStatusBar: View {
    // Environment objects
    @EnvironmentObject private var subscriptionTracker: SubscriptionTracker
    
    // Local state
    @State private var showSubscriptionView = false
    @State private var showFullBar = true
    
    // Define where to position the collapsed button (e.g., trailing edge)
    // You can change this to .leading, .center, or .trailing
    private let collapsedAlignment: Alignment = .trailing
    
    var body: some View {
        // Only hide if user is actually subscribed
        if !IAPManager.shared.isSubscribed {
            ZStack {
                // This empty container takes up the full width
                Rectangle()
                    .fill(Color.clear)
                    .frame(maxWidth: .infinity)
                
                if showFullBar {
                    // Full expanded banner (centered)
                    fullBannerView
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    // Collapsed mini button (positioned based on alignment)
                    collapsedButtonView
                        .frame(maxWidth: .infinity, alignment: collapsedAlignment)
                        .padding(.horizontal, 35) // Add padding to keep away from edges
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.easeInOut, value: showFullBar)
            .padding(.horizontal)
            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
            .sheet(isPresented: $showSubscriptionView) {
                SubscriptionView()
                    .environmentObject(IAPManager.shared)
            }
            .onAppear {
                // Auto-collapse after 5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    withAnimation(.easeInOut) {
                        showFullBar = false
                    }
                }
                
                // For debugging - print status to console
                print("TrialStatusBar appeared - Free trial: \(subscriptionTracker.isInFreeTrial), Remaining uses: \(subscriptionTracker.remainingFreeUses)")
            }
        } else {
            // Empty view if subscribed
            EmptyView()
                .onAppear {
                    print("User is subscribed - hiding status bar")
                }
        }
    }
    
    // Full banner view
    private var fullBannerView: some View {
        HStack {
            // Content based on trial status
            if subscriptionTracker.isInFreeTrial {
                trialTimeContent
            } else {
                freeGenerationsContent
            }
            
            // Collapse button
            Button(action: {
                withAnimation(.easeInOut) {
                    showFullBar = false
                }
            }) {
                Image(systemName: "chevron.up")
                    .foregroundColor(.white.opacity(0.7))
                    .font(.system(size: 12))
            }
            .padding(.leading, 5)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("darkBlue").opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            subscriptionTracker.isInFreeTrial && trialTimeRemainingPercentage < 0.3
                                ? Color.red.opacity(0.7)
                                : Color("gold").opacity(0.5),
                            lineWidth: 1
                        )
                )
        )
    }
    
    // Collapsed mini button view
    private var collapsedButtonView: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                showFullBar = true
            }
        }) {
            HStack(spacing: 5) {
                // Icon based on trial status
                Image(systemName: subscriptionTracker.isInFreeTrial ? "timer" : "wand.and.stars")
                    .foregroundColor(Color("gold"))
                    .font(.system(size: 14))
                
                // Mini text
                Text(subscriptionTracker.isInFreeTrial ?
                     "Trial" :
                     "\(subscriptionTracker.remainingFreeUses)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(6)
            .background(
                Capsule()
                    .fill(Color("darkBlue").opacity(0.8))
                    .overlay(
                        Capsule()
                            .stroke(Color("gold").opacity(0.5), lineWidth: 1)
                    )
            )
        }
    }
    
    // Content showing remaining free generations
    private var freeGenerationsContent: some View {
        HStack {
            // Icon
            Image(systemName: "wand.and.stars")
                .foregroundColor(Color("gold"))
                .font(.system(size: 16))
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                // Status text
                Text("\(subscriptionTracker.remainingFreeUses) Free Generations Left")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 4)
                            .cornerRadius(2)
                        
                        // Filled portion
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("neonBlue"), Color("gold")]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: (CGFloat(subscriptionTracker.remainingFreeUses) / CGFloat(subscriptionTracker.maxFreeUses)) * geometry.size.width, height: 4)
                            .cornerRadius(2)
                    }
                }
                .frame(height: 4)
            }
            
            Spacer()
            
            // Call-to-action buttons
            Button(action: {
                showSubscriptionView = true
                print("Free trial button pressed - showing subscription view")
            }) {
                Text("Start Trial")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color("neonBlue"))
                    .cornerRadius(12)
            }
        }
    }
    
    // Content showing remaining trial time
    private var trialTimeContent: some View {
        HStack {
            Image(systemName: "timer")
                .foregroundColor(Color("gold"))
                .font(.system(size: 16))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Trial: \(subscriptionTracker.trialTimeRemaining)")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                
                // Progress bar for visualizing remaining time
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 4)
                            .cornerRadius(2)
                        
                        // Filled portion representing remaining time
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("neonBlue"), Color("gold")]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: trialTimeRemainingPercentage * geometry.size.width, height: 4)
                            .cornerRadius(2)
                    }
                }
                .frame(height: 4)
            }
            
            Spacer()
            
            Button(action: {
                showSubscriptionView = true
                print("Subscribe pressed")
            }) {
                Text("Subscribe")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color("neonBlue"))
                    .cornerRadius(12)
            }
        }
    }
    
    // Helper to calculate trial time percentage
    private var trialTimeRemainingPercentage: CGFloat {
        guard let dateString = UserDefaults.standard.string(forKey: "trialStartDate"),
              let startDate = ISO8601DateFormatter().date(from: dateString) else {
            return 0
        }
        
        let trialEndDate = Calendar.current.date(byAdding: .day, value: 3, to: startDate)!
        
        if Date() >= trialEndDate {
            return 0
        }
        
        let totalTrialDuration = trialEndDate.timeIntervalSince(startDate)
        let remainingTime = trialEndDate.timeIntervalSince(Date())
        
        return min(1.0, max(0.0, CGFloat(remainingTime / totalTrialDuration)))
    }
}

// MARK: - Trial Status Bar Preview
struct TrialStatusBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Status Bar Preview")
                .font(.headline)
                .padding(.bottom, 20)
            
            TrialStatusBar()
        }
        .environmentObject(SubscriptionTracker())
        .padding()
        .background(Color.gray.opacity(0.3))
        .previewLayout(.sizeThatFits)
    }
}
