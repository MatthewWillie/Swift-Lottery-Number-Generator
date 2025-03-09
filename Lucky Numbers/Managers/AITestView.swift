//
//  AITestView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 3/1/25.
//

import SwiftUI

struct AITestView: View {
    @State private var userInput = ""
    @State private var aiResponse = "Ask me about lottery numbers!"
    @State private var isLoading = false

    var body: some View {
        ZStack {
            // Background Color
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text("JackpotAI")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()

                TextField("Enter a question", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)

                Button(action: {
                    askAI()
                }) {
                    Text("Ask AI")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isLoading)

                if isLoading {
                    ProgressView("Thinking...")
                        .padding()
                        .foregroundColor(.white)
                } else {
                    ScrollView { // ✅ Ensures response fits UI
                        Text(aiResponse)
                            .padding()
                            .frame(width: 300, height: 200)
                            .foregroundColor(.white)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .id(aiResponse) // ✅ Force UI update
                    }
                }
            }
            .padding()
        }
    }

    private func askAI() {
        isLoading = true
        aiResponse = "Waiting for response..."

        AIService.shared.fetchAIResponse(prompt: userInput) { response in
            DispatchQueue.main.async {
                print("🎯 AI Response: \(response ?? "No response")")  // ✅ Debugging output

                if let response = response {
                    aiResponse = response
                } else {
                    aiResponse = "Failed to get a response."
                }
                isLoading = false
                
                // ✅ Force a UI redraw
                withAnimation {
                    aiResponse += " "
                }
            }
        }
    }
}

struct AITestView_Previews: PreviewProvider {
    static var previews: some View {
        AITestView()
    }
}
