//
//  RequestLimiter.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 3/1/25.
//

import Foundation

struct RequestLimiter {
    static let maxTotalRequests = 500   // 🔹 Max for free users
    static let requestCountKey = "requestCount"

    static func canMakeRequest() -> Bool {
        let count = UserDefaults.standard.integer(forKey: requestCountKey)
        return count < maxTotalRequests
    }

    static func incrementRequestCount() {
        let count = UserDefaults.standard.integer(forKey: requestCountKey) + 1
        UserDefaults.standard.set(count, forKey: requestCountKey)
    }

    static func remainingRequests() -> Int {
        let count = UserDefaults.standard.integer(forKey: requestCountKey)
        return max(0, maxTotalRequests - count)
    }

    static func resetRequestCount() {
        UserDefaults.standard.set(0, forKey: requestCountKey)
    }
}
