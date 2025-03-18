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
        // Load from environment or use a placeholder for development
        #if DEBUG
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let keys = NSDictionary(contentsOfFile: path),
           let apiKey = keys["OpenAIKey"] as? String {
            self.openAIKey = apiKey
        } else {
            self.openAIKey = "" // Empty string instead of hardcoded key
        }
        #else
        self.openAIKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
        #endif
    }
}
