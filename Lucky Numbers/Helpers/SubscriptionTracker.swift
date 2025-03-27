//
//  SubscriptionTracker.swift
//  JackpotAI
//
//  Created by Matt Willie on 3/18/25.
//

import SwiftUI
import Firebase

class SubscriptionTracker: ObservableObject {
    // MARK: - Properties
    
    @AppStorage("aiUsageCount") var aiUsages: Int = 0
    @AppStorage("trialStartDate") private var trialStartDateString: String?
    @Published var showTrialExpiredMessage: Bool = false
    
    // Constants
    private let trialDurationDays = 3
    public let maxFreeUses = 5
    
    // MARK: - Computed Properties
    
    /// Checks if user is currently in a free trial period
    var isInFreeTrial: Bool {
        guard !IAPManager.shared.isSubscribed else { return false }
        
        if let dateString = trialStartDateString,
           let startDate = ISO8601DateFormatter().date(from: dateString) {
            let trialEndDate = Calendar.current.date(byAdding: .day, value: trialDurationDays, to: startDate)!
            return Date() < trialEndDate
        }
        return false
    }
    
    /// Gets the time remaining in the free trial as a formatted string
    var trialTimeRemaining: String {
        guard let dateString = trialStartDateString,
              let startDate = ISO8601DateFormatter().date(from: dateString) else {
            return "No trial active"
        }
        
        let trialEndDate = Calendar.current.date(byAdding: .day, value: trialDurationDays, to: startDate)!
        
        if Date() >= trialEndDate {
            return "Trial ended"
        }
        
        let components = Calendar.current.dateComponents([.day, .hour], from: Date(), to: trialEndDate)
        return "\(components.day ?? 0) days, \(components.hour ?? 0) hours"
    }
    
    /// Whether the user can use premium AI features (either subscribed, in trial, or has free uses left)
    var canUseAI: Bool {
        IAPManager.shared.isSubscribed || isInFreeTrial || aiUsages < maxFreeUses
    }
    
    /// Number of remaining free uses
    var remainingFreeUses: Int {
        max(0, maxFreeUses - aiUsages)
    }
    
    // MARK: - Methods
    
    /// Start the free trial period
    func startFreeTrial() {
        let now = ISO8601DateFormatter().string(from: Date())
        trialStartDateString = now
        
        // Log analytics event
        Analytics.logEvent("free_trial_started", parameters: nil)
    }
    
    /// Check if trial has expired and needs messaging
    func checkTrialStatus() {
        if let dateString = trialStartDateString,
           let startDate = ISO8601DateFormatter().date(from: dateString) {
            
            let trialEndDate = Calendar.current.date(byAdding: .day, value: trialDurationDays, to: startDate)!
            
            // If trial has expired and user isn't subscribed, show message
            if Date() >= trialEndDate && !IAPManager.shared.isSubscribed {
                showTrialExpiredMessage = true
                
                // Log analytics event
                Analytics.logEvent("free_trial_expired", parameters: nil)
            }
        }
    }
    
    /// Increment usage counter for premium features
    func incrementUsage() {
        guard !IAPManager.shared.isSubscribed && !isInFreeTrial else { return }
        
        aiUsages += 1
        
        // Track usage analytics
        Analytics.logEvent("ai_feature_used", parameters: [
            "remaining_uses": remainingFreeUses,
            "subscription_status": "free"
        ])
        
        // Track when user reaches limit
        if remainingFreeUses == 0 {
            Analytics.logEvent("free_usage_limit_reached", parameters: nil)
        }
    }
    
    /// Reset usage counter (e.g., for monthly reset)
    func resetUsage() {
        aiUsages = 0
        
        Analytics.logEvent("usage_limit_reset", parameters: nil)
    }
}
