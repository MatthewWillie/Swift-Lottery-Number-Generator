//
//  AINumberGeneratorView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 3/1/25.
//

import SwiftUI

enum LotteryGame: String, CaseIterable, Identifiable {
    case powerball = "Powerball"
    case megaMillions = "Mega Millions"
    case euroMillions = "EuroMillions"
    case euroJackpot = "EuroJackpot"
    case lottoMax = "Lotto Max"

    var id: String { self.rawValue }

    var whiteBallCount: Int {
        switch self {
        case .powerball, .megaMillions, .euroMillions, .euroJackpot:
            return 5
        case .lottoMax:
            return 7
        }
    }

    var specialBallCount: Int {
        switch self {
        case .powerball, .megaMillions:
            return 1
        case .euroMillions, .euroJackpot:
            return 2
        case .lottoMax:
            return 0
        }
    }

    var whiteBallRange: ClosedRange<Int> {
        switch self {
        case .powerball:
            return 1...69
        case .megaMillions:
            return 1...70
        case .euroMillions, .euroJackpot, .lottoMax:
            return 1...50
        }
    }

    var specialBallRange: ClosedRange<Int> {
        switch self {
        case .powerball:
            return 1...26
        case .megaMillions:
            return 1...25
        case .euroMillions, .euroJackpot:
            return 1...12
        default:
            return 0...0
        }
    }

    var specialBallLabel: String? {
        switch self {
        case .powerball:
            return "Powerball"
        case .megaMillions:
            return "Mega Ball"
        case .euroMillions:
            return "Lucky Stars"
        case .euroJackpot:
            return "Euro Numbers"
        default:
            return nil
        }
    }
}

struct AINumberGeneratorView: View {
    @State private var selectedGame: LotteryGame = .powerball
    @State private var whiteBalls: [Int] = []
    @State private var specialBalls: [Int] = []
    @State private var aiExplanation: String = "Press 'Generate Numbers' to get your lucky numbers!"
    @State private var showExplanation: Bool = false
    @State private var isLoading: Bool = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.9).edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Picker("Select Game", selection: $selectedGame) {
                    ForEach(LotteryGame.allCases) { game in
                        Text(game.rawValue).tag(game)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(Color.white)
                .cornerRadius(10)

                Text("AI \(selectedGame.rawValue) Generator")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.top)

                if !whiteBalls.isEmpty {
                    HStack(spacing: 10) {
                        ForEach(whiteBalls.indices, id: \.self) { index in
                            ZStack {
                                Image("lotto_ball")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                Text("\(whiteBalls[index])")
                                    .font(.headline)
                                    .foregroundColor(.black)
                            }
                        }

                        ForEach(specialBalls.indices, id: \.self) { index in
                            ZStack {
                                Image("red_ball")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                Text("\(specialBalls[index])")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.vertical)
                }

                Button(action: generateNumbersWithAI) {
                    Text(isLoading ? "Generating..." : "Generate Numbers")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isLoading ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .disabled(isLoading)

                Spacer()

                if showExplanation {
                    Text(aiExplanation)
                        .font(.body)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                        .padding(.bottom, 50)
                        .padding()
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }
            }
            .padding()
        }
    }

    private func generateNumbersWithAI() {
        isLoading = true
        showExplanation = false
        aiExplanation = "Thinking..."

        let prompt = """
        You are a lottery analyst. Generate \(selectedGame.whiteBallCount) unique white balls between \(selectedGame.whiteBallRange.lowerBound) and \(selectedGame.whiteBallRange.upperBound)\(selectedGame.specialBallCount > 0 ? ", and \(selectedGame.specialBallCount) \(selectedGame.specialBallLabel ?? "special") balls between \(selectedGame.specialBallRange.lowerBound) and \(selectedGame.specialBallRange.upperBound)" : ""). Ensure statistical balance using hot, cold, and overdue numbers.

        Respond exactly in this format:
        White Balls: [list of \(selectedGame.whiteBallCount) numbers]
        \(selectedGame.specialBallCount > 0 ? "\(selectedGame.specialBallLabel!): [\(selectedGame.specialBallCount) number\(selectedGame.specialBallCount > 1 ? "s" : "")]" : "")
        Explanation: Briefly explain why these numbers were selected based on trends and balance.
        """

        AIService.shared.fetchAIResponse(prompt: prompt) { response in
            DispatchQueue.main.async {
                guard let response = response else {
                    aiExplanation = "Failed to get a response."
                    isLoading = false
                    return
                }

                print("📜 AI Response:\n\(response)")

                whiteBalls = parseNumbers(from: response, label: "White Balls:", expectedCount: selectedGame.whiteBallCount)
                if selectedGame.specialBallCount > 0, let label = selectedGame.specialBallLabel {
                    specialBalls = parseNumbers(from: response, label: "\(label):", expectedCount: selectedGame.specialBallCount)
                } else {
                    specialBalls = []
                }

                aiExplanation = extractExplanation(from: response)

                withAnimation { showExplanation = true }
                isLoading = false
            }
        }
    }

    private func parseNumbers(from text: String, label: String, expectedCount: Int) -> [Int] {
        guard let range = text.range(of: "\(label) \\[(.*?)\\]", options: .regularExpression),
              let numbersText = text[range].components(separatedBy: "[").last?.components(separatedBy: "]").first else { return [] }

        let numbers = numbersText.components(separatedBy: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
        return numbers.count == expectedCount ? numbers : []
    }

    private func extractExplanation(from text: String) -> String {
        guard let range = text.range(of: "Explanation:(.*)", options: .regularExpression) else { return "No explanation found." }
        return String(text[range]).replacingOccurrences(of: "Explanation:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct AINumberGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        AINumberGeneratorView()
    }
}
