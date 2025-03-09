//
//  MainView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 3/2/25.
//


import SwiftUI

struct PremiumSpinner: View {
    @State private var rotating = false

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(AngularGradient(colors: [.blue, .cyan, .blue], center: .center), lineWidth: 4)
            .frame(width: 40, height: 40)
            .rotationEffect(.degrees(rotating ? 360 : 0))
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: rotating)
            .onAppear { rotating = true }
    }
}

// MARK: - MainView Code
struct Ball: Identifiable {
    let id = UUID()
    let number: Int
}

struct MainView: View {
    enum ScaleEffectState {
        case popIn, out, settled, exit
    }
    
    private var ballScale: CGFloat {
        switch scaleEffectState {
        case .popIn:    return 1.2
        case .out:      return 0.8
        case .settled:  return 1.0
        case .exit:     return 0.0
        }
    }
    
    // MARK: - State Variables
    @State private var showSubscriptionAlert: Bool = false
    
    @EnvironmentObject var subscriptionTracker: SubscriptionTracker
    @EnvironmentObject var iapManager: IAPManager
    @State private var generateCount: Int = 0
    
    @State private var savedArray: [CoinListItem] = []
    @State private var firstClick: Int = 0

    @State private var showAIModeOverlay: Bool = false
    @State private var scaleEffectState: ScaleEffectState = .settled
    @State private var useAIMode: Bool = false
    @State private var selectedGame: LotteryGame = .powerball
    
    @State private var activeGame: LotteryGame = .powerball
    @State private var whiteBalls: [Ball] = []
    @State private var specialBalls: [Ball] = []
    @State private var explanation: String = ""
    @State private var isLoading: Bool = false
    @State private var showExplanation: Bool = false
    @State private var showLoadBalls: Bool = true
    @State private var animateBalls: Bool = false
    
    // This state drives the shake animation.
    @State private var shakeTrigger: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                
                ZStack {
                    BackgroundView()
                    (useAIMode ? Color.black.opacity(0.3) : Color("lightBlue").opacity(0.3))
                        .ignoresSafeArea()
                    
                    CoinView(savedArray: $savedArray)
                    FavoritesView()
                    
                    VStack(spacing: geometry.size.height * 0.02) {
                        headerView
                            .conditionalModifier(useAIMode, modifier: { $0.shimmering(active: true) })
                            .conditionalModifier(useAIMode, modifier: { $0.glowing(with: Color("neonBlue")) })
                            .position(x: geometry.size.width / 2, y: geometry.size.height * 0.2)
                        
                        ballDisplay
                            .conditionalModifier(useAIMode, modifier: { $0.glowing(with: Color("gold")) })
                            .position(x: geometry.size.width / 2, y: geometry.size.height * 0.19)
                        
                        gamePicker
                            .frame(width: geometry.size.width * 0.6)
                            .padding(10)
                            .background(useAIMode ? Color.blue.opacity(0.3) : Color.white.opacity(0.3))
                            .cornerRadius(20)
                            .position(x: geometry.size.width / 2, y: geometry.size.height * 0.43)
                        
                        Toggle("", isOn: $useAIMode)
                            .toggleStyle(AIToggleStyle())
                            .onChange(of: useAIMode) { newValue in
                                if newValue {
                                    whiteBalls = []
                                    specialBalls = []
                                    showLoadBalls = true
                                    showExplanation = false
                                    
                                    withAnimation(Animation.linear(duration: 0.6)) {
                                        shakeTrigger = 1
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                        shakeTrigger = 0
                                    }
                                }
                                
                                withAnimation(.easeInOut(duration: 0.6)) {
                                    showAIModeOverlay = newValue
                                }
                                
                                if newValue {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        withAnimation(.easeInOut(duration: 0.4)) {
                                            showAIModeOverlay = false
                                        }
                                    }
                                }
                            }
                            .padding()
                            .cornerRadius(10)
                            .frame(width: geometry.size.width * 0.4)
                            .position(x: geometry.size.width / 2, y: geometry.size.height * -0.07)
                        
                        generateButton
                            .conditionalModifier(useAIMode, modifier: { $0.glowing(with: Color("neonBlue")) })
                            .frame(width: geometry.size.width * 0.8)
                            .position(x: geometry.size.width / 2, y: geometry.size.height * -0.12)
                            .opacity(isLoading ? 0.5 : 1)
                            .disabled(isLoading)
                    }
                    
                    if showLoadBalls {
                        LoadBalls()
                            .transition(.opacity)
                            .conditionalModifier(useAIMode, modifier: { $0.glowing(with: Color("gold")) })
                    }
                    
                    if showExplanation && useAIMode {
                        explanationOverlay(geometry: geometry)
                    }
                    
                    if showAIModeOverlay {
                        VStack {
                            AIModeBanner()
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .zIndex(3)
                    }
                    if isLoading {
                        PremiumSpinner()
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2.5)
                    }
                    
                }
                .shaking(animatableData: shakeTrigger)
            }
        }
        .alert(isPresented: $showSubscriptionAlert) {
            Alert(
                title: Text("Unlock JackpotAI Premium!"),
                message: Text("You've reached your free limit of AI-generated numbers. Subscribe now for unlimited use and an ad-free experience, only $4.99/month!"),
                primaryButton: .default(Text("Subscribe"), action: {
                    iapManager.purchaseSubscription()
                }),
                secondaryButton: .cancel(Text("Maybe Later"))
            )
        }

    }

    // MARK: - Ball View Helper
    @ViewBuilder
    private func ballView(for ball: Ball, isSpecial: Bool, delay: Double) -> some View {
        ZStack {
            Image(isSpecial ? "red_ball" : "lotto_ball")
                .resizable()
                .frame(width: 60, height: 60)
                .shadow(radius: 10, x: -5, y: 20)
            Text("\(ball.number)")
                .font(.custom("Times New Roman", fixedSize: 28))
                .bold()
                .foregroundColor(.black)
                .shadow(radius: 15, x: 5, y: 10)
                .padding(.trailing, 3)
        }
        .scaleEffect(ballScale)
        .animation(
            Animation.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)
                .delay(delay),
            value: scaleEffectState
        )
    }
    
    // MARK: - Ball Display
    private var ballDisplay: some View {
        VStack(spacing: 2) {
            if activeGame == .lottoMax || activeGame == .euroMillions || activeGame == .euroJackpot {
                // Two-row layout.
                HStack(spacing: 2) {
                    if activeGame == .lottoMax {
                        // For LottoMax, assume all 7 balls are in whiteBalls.
                        ForEach(Array(whiteBalls.prefix(5).enumerated()), id: \.element.id) { index, ball in
                            ballView(for: ball, isSpecial: false, delay: Double(index) * 0.1)
                        }
                    } else {
                        // For EuroMillions/EuroJackpot, top row are whiteBalls.
                        ForEach(Array(whiteBalls.enumerated()), id: \.element.id) { index, ball in
                            ballView(for: ball, isSpecial: false, delay: Double(index) * 0.1)
                        }
                    }
                }
                HStack(spacing: 2) {
                    if activeGame == .lottoMax {
                        ForEach(Array(whiteBalls.suffix(2).enumerated()), id: \.element.id) { index, ball in
                            ballView(for: ball, isSpecial: false, delay: 0.5 + Double(index) * 0.1)
                        }
                    } else {
                        // For EuroMillions/EuroJackpot, bottom row are specialBalls.
                        ForEach(Array(specialBalls.enumerated()), id: \.element.id) { index, ball in
                            ballView(for: ball, isSpecial: true, delay: 0.5 + Double(index) * 0.1)
                        }
                    }
                }
            } else {
                // Single-row layout for other games.
                HStack(spacing: 2) {
                    ForEach(Array(whiteBalls.enumerated()), id: \.element.id) { index, ball in
                        ballView(for: ball, isSpecial: false, delay: Double(index) * 0.1)
                    }
                    ForEach(Array(specialBalls.enumerated()), id: \.element.id) { index, ball in
                        ballView(for: ball, isSpecial: true, delay: Double(index) * 0.1 + 0.5)
                    }
                }
            }
        }
    }
    
    // MARK: - Other Subviews
    private var headerView: some View {
        VStack {
            Image("JackpotLogo")
                .resizable()
                .frame(width: 200, height: 200)
                .opacity(0.7)
        }
    }
    
    private var gamePicker: some View {
        Menu {
            ForEach([LotteryGame.powerball, .megaMillions, .euroMillions, .euroJackpot, .lottoMax], id: \.self) { game in
                Button(action: { selectedGame = game }) {
                    Text(game.rawValue)
                }
            }
        } label: {
            HStack {
                Text(selectedGame.rawValue)
                    .foregroundColor(useAIMode ? .black : .black)
                Image(systemName: "chevron.down")
                    .foregroundColor(useAIMode ? .black : .black)
            }
            .padding(8)
            .frame(maxWidth: 200)
            .background(useAIMode ? Color.white.opacity(0.9) : Color.white.opacity(0.7))
            .cornerRadius(10)
        }
    }
    
    private var generateButton: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            withAnimation {
                showLoadBalls = false
            }
            generateNumbers()
        }) {
            ZStack {
                Image("button") // Replace with your asset name
                    .resizable()
                    .scaledToFit()
                    .frame(height: 90)
                    .cornerRadius(30)
                    .shadow(color: Color("neonBlue").opacity(0.7), radius: 5, x: 1, y: 2)
                    .shadow(color: Color("black").opacity(0.7), radius: 12, x: 3, y: 12)
            }
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(isLoading)
        .shadow(
            color: useAIMode ? Color.blue.opacity(0.9) : Color.clear,
            radius: useAIMode ? 5 : 0,
            x: 0,
            y: 0
        )
    }


    
    private func explanationOverlay(geometry: GeometryProxy) -> some View {
        ZStack {
            Color.black.opacity(0.0)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation { showExplanation = false }
                }
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation { showExplanation = false }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 30))
                            .padding()
                    }
                }
                .frame(maxWidth: .infinity)
                Text("Why?")
                    .font(.title)
                    .foregroundColor(.white)
                    .bold()
                    .padding(.top, -50)
                ScrollView {
                    Text(explanation)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                }
                .frame(height: geometry.size.height * 0.25)
                .background(Color.black.opacity(0.7))
                .cornerRadius(12)
            }
            .padding()
            .offset(y: -geometry.size.height * 0.33)
        }
        .transition(.scale)
        .zIndex(1)
    }
    
    // MARK: - Number Generation Methods
    private func generateNumbers() {
        generateCount += 1

        if generateCount % 4 == 0 {
            if let rootVC = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
                .first {
                
                if let interstitial = AdManager.shared.interstitial {
                    AdManager.shared.showInterstitial(from: rootVC)
                } else {
                    print("⚠️ Ad not ready. Resetting count to show next ad sooner.")
                    generateCount -= 1 // So the next click will still try again
                }
            }
        }

        isLoading = true
        showExplanation = false

        withAnimation(Animation.spring(response: 0.5, dampingFraction: 0.6)) {
            self.scaleEffectState = .exit
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if self.useAIMode {
                self.generateAINumbers()
            } else {
                self.generateRandomNumbers()
            }
            activeGame = selectedGame
        }
    }


    private func saveGeneratedNumbers() {
        let whiteNumbers = whiteBalls.map { "\($0.number)" }.joined(separator: ", ")
        let specialNumbers = specialBalls.map { "\($0.number)" }.joined(separator: ", ")

        let combinedNumbers = specialNumbers.isEmpty ? whiteNumbers : "\(whiteNumbers) | \(specialNumbers)"
        let newEntry = CoinListItem(lottoNumbers: combinedNumbers)

        savedArray.insert(newEntry, at: 0)

        // Keep only the latest 10 numbers
        if savedArray.count > 10 {
            savedArray.removeLast()
        }
    }


    
    private func generateRandomNumbers() {
        let availableWhiteNumbers = Array(selectedGame.whiteBallRange)
        whiteBalls = availableWhiteNumbers.shuffled()
            .prefix(selectedGame.whiteBallCount)
            .map { Ball(number: $0) }
            .sorted { $0.number < $1.number }
        if selectedGame.specialBallCount > 0 {
            let availableSpecialNumbers = Array(selectedGame.specialBallRange)
            specialBalls = availableSpecialNumbers.shuffled()
                .prefix(selectedGame.specialBallCount)
                .map { Ball(number: $0) }
        } else {
            specialBalls = []
        }
        self.scaleEffectState = .exit
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(Animation.spring(response: 0.5, dampingFraction: 0.6)) {
                self.scaleEffectState = .popIn
            }
            withAnimation(Animation.spring(response: 0.5, dampingFraction: 0.6).delay(0.3)) {
                self.scaleEffectState = .out
            }
            withAnimation(Animation.spring(response: 0.5, dampingFraction: 0.6).delay(0.6)) {
                self.scaleEffectState = .settled
            }
        }
        saveGeneratedNumbers()
        isLoading = false
    }
    
    private func generateAINumbers() {
        guard subscriptionTracker.canUseAI else {
            showSubscriptionPrompt()
            isLoading = false
            return
        }

//        subscriptionTracker.incrementUsage()
        isLoading = true
        showExplanation = false
        animateBalls = false

        // Retrieve the last three AI-generated sets to avoid repetition
        let previousDrawsKey = "previousAIDraws"
        var previousDraws = UserDefaults.standard.array(forKey: previousDrawsKey) as? [[Int]] ?? []

        // Flatten the last three draws into a single set to exclude from the new draw
        let lastDrawnNumbers = Set(previousDraws.flatMap { $0 })

        // Select one of four prompt styles in rotation instead of random
        let promptStyles = [
            "statistical",
            "energetic",
            "statistical2",
            "mystical",
            "analytical"
        ]

        // Track last used index to rotate prompts evenly
        let lastPromptIndexKey = "lastPromptIndex"
        var lastPromptIndex = UserDefaults.standard.integer(forKey: lastPromptIndexKey)
        lastPromptIndex = (lastPromptIndex + 1) % promptStyles.count
        UserDefaults.standard.set(lastPromptIndex, forKey: lastPromptIndexKey)

        // Select the correct prompt type
        let selectedPromptType = promptStyles[lastPromptIndex]
        var prompt: String = ""

        // Determine number of white and special balls dynamically
        let whiteBallCount = selectedGame.whiteBallCount
        let specialBallCount = selectedGame.specialBallCount
        let specialBallLabel = selectedGame.specialBallLabel ?? "special"

        if specialBallCount > 0 {
            switch selectedPromptType {
            case "statistical":
                prompt = """
                You are a top-tier lottery analyst providing expert insights. Generate \(whiteBallCount) white balls and \(specialBallCount) \(specialBallLabel) balls.

                - Mix hot, cold, and overdue numbers for an optimal blend.
                - Exclude recently drawn numbers: \(Array(lastDrawnNumbers)).
                - No consecutive numbers.
                - Keep the explanation within 60 words.

                Respond in this format:
                White Balls: [number, number, number, number, number]  
                \(specialBallLabel): [number\(specialBallCount > 1 ? ", number" : "")]  
                Explanation: Reveal hidden statistical insights, highlighting **why today’s selection maximizes odds**. Mention a key standout number and its historical significance.
                """

            case "energetic":
                prompt = """
                You’re a dynamic lottery AI! Generate \(whiteBallCount) white balls and \(specialBallCount) \(specialBallLabel) balls.

                - Bring excitement by using **real lottery trends** (hot, cold, overdue).
                - Inject personality and variation into the explanation.
                - Challenge the user: "Will you trust today’s lucky pick?"
                - Avoid these numbers: \(Array(lastDrawnNumbers)).
                - Steer clear of generic “this is exciting!” phrasing.
                - Keep it **under 60 words**.

                Respond in this format:
                White Balls: [number, number, number, number, number]  
                \(specialBallLabel): [number\(specialBallCount > 1 ? ", number" : "")]  
                Explanation: Make it **engaging and unpredictable**! Use a fun twist: “A mix of fire-hot numbers and cool underdogs—could this be your jackpot set?”
                """

            case "statistical2":
                prompt = """
                You are a **data-driven lottery forecaster**. Generate \(whiteBallCount) white balls and \(specialBallCount) \(specialBallLabel) balls.

                - Blend hot, cold, and overdue numbers strategically.
                - Avoid recently drawn numbers: \(Array(lastDrawnNumbers)).
                - No consecutive numbers.
                - Keep it **concise yet informative**—60 words max.

                Respond in this format:
                White Balls: [number, number, number, number, number]  
                \(specialBallLabel): [number\(specialBallCount > 1 ? ", number" : "")]  
                Explanation: Highlight **today’s statistical advantage**—why these numbers could be **the smartest pick** based on trends and probabilities.
                """

            case "mystical":
                prompt = """
                You are a **legendary number oracle**. Generate \(whiteBallCount) white balls and \(specialBallCount) \(specialBallLabel) balls.

                - Merge real lottery data with **mystical insight**.
                - Feature **hot streak numbers & overdue sleepers**.
                - Exclude: \(Array(lastDrawnNumbers)).
                - Identify **one number as “the chosen one.”**
                - Stay under 60 words.

                Respond in this format:
                White Balls: [number, number, number, number, number]  
                \(specialBallLabel): [number\(specialBallCount > 1 ? ", number" : "")]  
                Explanation: Craft a **mystical yet realistic** narrative: “The ancient number 7 calls forth luck, while 39 lies in wait—its time to shine is near.”
                """

            case "analytical":
                prompt = """
                You are a **seasoned lottery analyst** offering professional picks. Generate \(whiteBallCount) white balls and \(specialBallCount) \(specialBallLabel) balls.

                - Avoid these numbers: \(Array(lastDrawnNumbers)).
                - Highlight **one standout number** and explain its importance.
                - Use **data-backed reasoning**—no vague claims.
                - Keep it within **60 words**.

                Respond in this format:
                White Balls: [number, number, number, number, number]  
                \(specialBallLabel): [number\(specialBallCount > 1 ? ", number" : "")]  
                Explanation: Deliver a **concise, expert breakdown**: “Number 22 appears in 30% of recent big wins—today could be its moment.”
                """

            default:
                print("❌ ERROR: No valid prompt type selected")
            }
        } else {
            switch selectedPromptType {
            case "statistical":
                prompt = """
                You are a **lottery strategist**. Generate \(whiteBallCount) white balls.

                - Ensure a mix of **hot, cold, and overdue** numbers.
                - Avoid numbers drawn recently: \(Array(lastDrawnNumbers)).
                - No consecutive numbers.
                - Keep the explanation **structured & insightful**, under 60 words.

                Respond in this format:
                White Balls: [number, number, number, number, number, number, number]  
                Explanation: Provide a **logical breakdown** of how today’s numbers **improve winning odds**.
                """

            case "energetic":
                prompt = """
                Welcome to the **world of winning numbers!** Generate \(whiteBallCount) white balls.

                - Ensure **statistical diversity**.
                - Avoid drawing these numbers: \(Array(lastDrawnNumbers)).
                - Add **suspense & personality**—not just stats!
                - Keep the explanation under **60 words**.

                Respond in this format:
                White Balls: [number, number, number, number, number, number, number]  
                Explanation: Write in an **engaging, playful** tone—keep the user hooked! "Today’s lineup is a wild mix of fate and probability—ready to test your luck?"
                """

            case "statistical2":
                prompt = """
                You are a **fun yet data-driven lottery strategist**. Generate \(whiteBallCount) white balls.

                - Blend **hot, cold, and overdue** numbers effectively.
                - Exclude recent AI-drawn numbers: \(Array(lastDrawnNumbers)).
                - No consecutive numbers.
                - Keep the explanation **logical & concise**—under 60 words.

                Respond in this format:
                White Balls: [number, number, number, number, number, number, number]  
                Explanation: Explain **why today’s selection maximizes odds**—avoid generic lottery advice.
                """

            case "mystical":
                prompt = """
                You are a **visionary number oracle**. Generate \(whiteBallCount) white balls.

                - Balance **proven winners & overlooked underdogs**.
                - Avoid numbers recently drawn: \(Array(lastDrawnNumbers)).
                - Identify **one “hidden lucky charm”**.
                - Stay under **60 words**.

                Respond in this format:
                White Balls: [number, number, number, number, number, number, number]  
                Explanation: Weave a **mystical yet realistic** tale: “The number 13, often misunderstood, carries hidden power today—will fortune favor it?”
                """

            case "analytical":
                prompt = """
                You are a **professional lottery forecaster**. Generate \(whiteBallCount) unique white balls.

                - **Mix hot, cold, and overdue** numbers with strategy.
                - **Exclude** recent draws: \(Array(lastDrawnNumbers)).
                - Deliver a **sharp, data-backed analysis** under 60 words.

                Respond in this format:
                White Balls: [number, number, number, number, number, number, number]  
                Explanation: Provide a **structured, statistical evaluation**: “Number 42 has surged in frequency, while 15 is an overdue sleeper—this mix balances trends & probability.”
                """

            default:
                print("❌ ERROR: No valid prompt type selected")
            }
        }

        print("🎯 Selected Prompt Type: \(selectedPromptType)")


        // Save the current draw to UserDefaults (keeping only the last 3 draws)
        func saveAIDraw(_ newDraw: [Int]) {
            previousDraws.append(newDraw)
            if previousDraws.count > 3 {
                previousDraws.removeFirst()  // Keep only the last 3
            }
            UserDefaults.standard.set(previousDraws, forKey: previousDrawsKey)
        }



        AIService.shared.fetchAIResponse(prompt: prompt) { response in
            DispatchQueue.main.async {
                guard let response = response else {
                    explanation = "Failed to get a response."
                    isLoading = false
                    return
                }

                print("🔍 AI Raw Response:\n\(response)") // Debugging output

                let parsedWhiteBalls = parseNumbers(from: response, label: "White Balls", expectedCount: selectedGame.whiteBallCount)
                let parsedSpecialBalls = parseNumbers(from: response, label: "\(selectedGame.specialBallLabel ?? "Powerball")", expectedCount: selectedGame.specialBallCount)

//                print("🎯 Parsed White Balls: \(parsedWhiteBalls)")
//                print("🎯 Parsed Special Balls: \(parsedSpecialBalls)")

                // Check if numbers are parsed correctly
                if parsedWhiteBalls.isEmpty || parsedSpecialBalls.isEmpty {
                    print("❌ ERROR: Numbers were not parsed correctly")
                }

                // Assign to UI
                whiteBalls = parsedWhiteBalls.map { Ball(number: $0) }
                specialBalls = parsedSpecialBalls.map { Ball(number: $0) }

//                print("✅ Assigned White Balls: \(whiteBalls.map { $0.number })")
//                print("✅ Assigned Special Balls: \(specialBalls.map { $0.number })")

                explanation = extractExplanation(from: response)
                
                withAnimation {
                    showExplanation = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(Animation.spring(response: 0.5, dampingFraction: 0.6)) {
                        self.animateBalls = true
                    }
                    withAnimation(Animation.spring(response: 0.5, dampingFraction: 0.6).delay(0.3)) {
                        self.scaleEffectState = .out
                    }
                    withAnimation(Animation.spring(response: 0.5, dampingFraction: 0.6).delay(0.6)) {
                        self.scaleEffectState = .settled
                    }
                }

                saveGeneratedNumbers()
                isLoading = false
            }
        }
    }
    
    private func showSubscriptionPrompt() {
        showSubscriptionAlert = true
    }
    
    private func parseNumbers(from text: String, label: String, expectedCount: Int) -> [Int] {
        let pattern = "\(label)\\s*[:\\(]\\s*\\[?([\\d,\\s]+)\\]?"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let range = Range(match.range(at: 1), in: text) else {
            print("❌ Failed to parse numbers for label: \(label)")
            return []
        }

        let extractedNumbers = text[range]
            .components(separatedBy: CharacterSet(charactersIn: ", \n"))
            .compactMap { Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
            .prefix(expectedCount)
            .map { $0 } // Convert ArraySlice<Int> to [Int]

//        print("✅ Successfully Parsed \(label): \(extractedNumbers)")
        return extractedNumbers
    }


    private func extractExplanation(from text: String) -> String {
        let explanationStart = "Explanation:"
        guard let range = text.range(of: explanationStart) else { return "No explanation found." }

        var extractedText = text[range.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)

        return extractedText
    }

}

struct AIModeBanner: View {
    var body: some View {
        HStack {
            Image(systemName: "sparkles")
                .font(.system(size: 30))
                .foregroundColor(.white)
                .padding(.trailing, 8)
            VStack(alignment: .leading, spacing: 2) {
                Text("AI Mode")
                    .font(.headline)
                    .foregroundColor(.white)
                    .bold()
                Text("Unlocking smarter number strategies.")
                    .font(.caption)
                    .foregroundColor(Color.white.opacity(0.8))
            }
            Spacer()
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(10)
        .padding(.horizontal)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

struct ShakeEffect: GeometryEffect {
    var travelDistance: CGFloat = 7
    var shakesPerUnit: CGFloat = 7
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = travelDistance * sin(animatableData * .pi * shakesPerUnit)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

extension View {
    func shaking(animatableData: CGFloat) -> some View {
        self.modifier(ShakeEffect(animatableData: animatableData))
    }
}

struct AIToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 0) {
            Image("aiIcon")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(configuration.isOn ? Color.blue : Color.black.opacity(0.7))
                .frame(width: 50, height: 45)
                .padding(7)

            ZStack {
                Capsule()
                    .fill(configuration.isOn ? Color.blue : Color.black.opacity(0.5))
                    .frame(width: 50, height: 28)
                    .shadow(color: .white, radius: 1)

                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .offset(x: configuration.isOn ? 11 : -11)
                    .shadow(radius: 3)
            }
            .onTapGesture {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()

                withAnimation(.easeInOut(duration: 0.2)) {
                    configuration.isOn.toggle()
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(SubscriptionTracker())
            .environmentObject(IAPManager.shared)
    }
}
