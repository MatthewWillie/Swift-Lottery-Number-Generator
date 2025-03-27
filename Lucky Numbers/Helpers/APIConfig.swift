//
//  APIConfig.swift
//  JackpotAI
//
//  Created by Matt Willie on 3/18/25.
//

import Foundation

class APIConfig {
    static let shared = APIConfig()
    
    // API Keys
    let openAIKey: String
    
    private init() {
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let keys = NSDictionary(contentsOfFile: path),
           let apiKey = keys["OpenAIKey"] as? String {
            self.openAIKey = apiKey
        } else {
            // Fallback API key, only used if plist missing
            self.openAIKey = "sk-your-actual-key-here"
        }
    }
}
