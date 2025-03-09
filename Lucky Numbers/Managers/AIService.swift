//
//  AIService.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 3/1/25.
//

import Foundation

    class AIService {
        static let shared = AIService()

        private let apiKey = "YOUR_API_KEY_REMOVED"  // 🔹 Replace with your actual OpenAI API key
        private let baseURL = "https://api.openai.com/v1/chat/completions"

        func fetchAIResponse(prompt: String, completion: @escaping (String?) -> Void) {
                guard let url = URL(string: baseURL) else { return }

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
                    "max_tokens": 250  // 🔹 Limits response length
                ]

                request.httpBody = try? JSONSerialization.data(withJSONObject: body)

                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("❌ API Error:", error.localizedDescription)
                        completion("Error: \(error.localizedDescription)")
                        return
                    }

                    if let httpResponse = response as? HTTPURLResponse {
                        print("📡 Response Status Code:", httpResponse.statusCode)
                    }

                    if let data = data {
                        let responseString = String(data: data, encoding: .utf8)
                        print("📜 Raw Response:", responseString ?? "No response body")

                        do {
                            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                                if let choices = json["choices"] as? [[String: Any]],
                                   let firstChoice = choices.first,
                                   let message = firstChoice["message"] as? [String: Any],
                                   let content = message["content"] as? String {
                                    print("✅ Received AI Response: \(content)")
                                    completion(content)
                                } else {
                                    print("❌ Failed to extract message content")
                                    completion("Error: Could not extract message content.")
                                }
                            } else {
                                print("❌ Failed to parse AI response JSON")
                                completion("Error: Could not parse response JSON.")
                            }
                        } catch {
                            print("❌ JSON Parsing Error:", error.localizedDescription)
                            completion("Error parsing response")
                        }
                    }
                }.resume()
            }
        }
