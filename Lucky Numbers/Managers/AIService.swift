//
//  AIService.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 3/1/25.
//

// AIService.swift - Optimized version
import Foundation

class AIService {
    static let shared = AIService()
    
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private var activeTask: URLSessionDataTask?
    
    // Simple response cache to avoid redundant requests
    private var responseCache: [String: String] = [:]
    
    func fetchAIResponse(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Check cache first
        if let cachedResponse = responseCache[prompt] {
            completion(.success(cachedResponse))
            return
        }
        
        // Cancel any existing task
        activeTask?.cancel()
        
        // Get API key from config
        let apiKey = APIConfig.shared.openAIKey
        guard !apiKey.isEmpty else {
            completion(.failure(AIServiceError.missingAPIKey))
            return
        }
        
        guard let url = URL(string: baseURL) else {
            completion(.failure(AIServiceError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant for a lottery app. Keep responses short."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 250
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        activeTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(AIServiceError.noData))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    // Cache the response
                    self.responseCache[prompt] = content
                    
                    completion(.success(content))
                } else {
                    completion(.failure(AIServiceError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        activeTask?.resume()
    }
    
    func cancelCurrentRequest() {
        activeTask?.cancel()
        activeTask = nil
    }
}

// Custom error types for better error handling
enum AIServiceError: Error {
    case missingAPIKey
    case invalidURL
    case noData
    case invalidResponse
    
    var localizedDescription: String {
        switch self {
        case .missingAPIKey:
            return "API key not configured"
        case .invalidURL:
            return "Invalid API URL"
        case .noData:
            return "No data received from server"
        case .invalidResponse:
            return "Invalid response format from server"
        }
    }
}
