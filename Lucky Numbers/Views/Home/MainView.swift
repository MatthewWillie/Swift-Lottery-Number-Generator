//
//  MainView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 3/2/25.
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

// MARK: - Custom Property Wrapper for Codable types
@propertyWrapper
struct CodableSceneStorage<Value: Codable>: DynamicProperty {
    let key: String
    let defaultValue: Value
    @SceneStorage private var storage: String

    var wrappedValue: Value {
        get {
            guard let data = storage.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode(Value.self, from: data) else {
                return defaultValue
            }
            return decoded
        }
        nonmutating set {
            guard let data = try? JSONEncoder().encode(newValue),
                  let json = String(data: data, encoding: .utf8) else { return }
            storage = json
        }
    }
    
    var projectedValue: Binding<Value> {
        Binding(get: { wrappedValue }, set: { wrappedValue = $0 })
    }

    init(wrappedValue: Value, _ key: String) {
        self.key = key
        self.defaultValue = wrappedValue
        
        let initial: String
        if let data = try? JSONEncoder().encode(wrappedValue),
           let json = String(data: data, encoding: .utf8) {
            initial = json
        } else {
            initial = ""
        }
        _storage = SceneStorage(wrappedValue: initial, key)
    }
}

// MARK: - Models
struct Ball: Identifiable, Codable, Equatable {
    let id: UUID
    let number: Int
    
    init(number: Int) {
        self.id = UUID()
        self.number = number
    }
    
    static func == (lhs: Ball, rhs: Ball) -> Bool {
        lhs.id == rhs.id && lhs.number == rhs.number
    }
}

// MARK: - UI Components
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

// MARK: - MainView
struct MainView: View {
    // Static app-session state
    private static var didResetState = false
    
    // MARK: - Types
    enum ScaleEffectState: String, Codable {
        case popIn, out, settled, exit
    }
    
    // MARK: - Dependencies
    @EnvironmentObject var subscriptionTracker: SubscriptionTracker
    @EnvironmentObject var iapManager: IAPManager
    
    // MARK: - Persisted State
    @SceneStorage("MainView.generateCount") private var generateCount: Int = 0
    @SceneStorage("MainView.useAIMode") private var useAIMode: Bool = false
    @SceneStorage("MainView.selectedGameRaw") private var selectedGameRaw: String = LotteryGame.powerball.rawValue
    @SceneStorage("MainView.activeGameRaw") private var activeGameRaw: String = LotteryGame.powerball.rawValue
    @CodableSceneStorage("MainView.whiteBalls") private var whiteBalls: [Ball] = []
    @CodableSceneStorage("MainView.specialBalls") private var specialBalls: [Ball] = []
    @SceneStorage("MainView.explanation") private var explanation: String = ""
    @CodableSceneStorage("MainView.scaleEffectState") private var scaleEffectState: ScaleEffectState = .settled
    @SceneStorage("MainView.showLoadBalls") private var showLoadBalls: Bool = true
    @CodableSceneStorage("MainView.savedArray") private var savedArray: [CoinListItem] = []
    @SceneStorage("MainView.showExplanation") private var showExplanation: Bool = false
    
    // MARK: - Transient State
    @State private var firstClick: Int = 0
    @State private var showAIModeOverlay: Bool = false
    @State private var shakeTrigger: CGFloat = 0
    @State private var isLoading: Bool = false
    @State private var animateBalls: Bool = false
    @State private var showSubscriptionAlert: Bool = false

    
    // MARK: - Layout Constants
        private struct LayoutConstants {
            static let ballSize: CGFloat = 70
            static let miniBallSize: CGFloat = 60
            static let ballSpacing: CGFloat = 4
            static let buttonHeight: CGFloat = 90
            static let sectionSpacing: CGFloat = 20
            static let cornerRadius: CGFloat = 16
        }
    
    // MARK: - Computed Properties
    var selectedGame: LotteryGame {
        get { LotteryGame(rawValue: selectedGameRaw) ?? .powerball }
        set { selectedGameRaw = newValue.rawValue }
    }
    
    var activeGame: LotteryGame {
        get { LotteryGame(rawValue: activeGameRaw) ?? .powerball }
        set { activeGameRaw = newValue.rawValue }
    }
    
    private var ballScale: CGFloat {
        switch scaleEffectState {
        case .popIn:    return 1.2
        case .out:      return 0.8
        case .settled:  return 1.0
        case .exit:     return 0.0
        }
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                mainContent(geometry)
                
                if !IAPManager.shared.isSubscribed {
                    TrialStatusBar()
                        .frame(width: geometry.size.width - 20)
                        .position(x: geometry.size.width / 2, y: geometry.size.height * 0.16)
                        .zIndex(1)
                }
                
                if showLoadBalls {
                    LoadBalls()
                        .transition(.opacity)
                        .conditionalModifier(useAIMode, modifier: { $0.glowing(with: Color("gold")) })
                        .onAppear {
                                    showExplanation = false
                                }
                }
                
                if showExplanation && useAIMode {
                    explanationOverlay(geometry: geometry)
                }
                
                if showAIModeOverlay {
                    aiModeBannerView
                        .offset(y: 120)
                        .zIndex(2)
                }
                
                if isLoading {
                    loadingOverlay
                }
            }
            .onAppear(perform: handleAppear)
        }
        .sheet(isPresented: $showSubscriptionAlert) {
            SubscriptionView()
                .environmentObject(IAPManager.shared)
        }

    }
    
    // MARK: - View Components
    private func mainContent(_ geometry: GeometryProxy) -> some View {
        ZStack {
            HomeBackgroundView()
            (useAIMode ? Color.black.opacity(0.0) : Color("lightBlue").opacity(0.3))
                .ignoresSafeArea()
            
            CoinView(savedArray: $savedArray)
                .conditionalModifier(useAIMode, modifier: { $0.glowing(with: Color("neonBlue")) })
            FavoritesView()
                .conditionalModifier(useAIMode, modifier: { $0.glowing(with: Color("neonBlue")) })
            
            mainVerticalLayout(geometry)
        }
        .shaking(animatableData: shakeTrigger)
    }
    
    private func mainVerticalLayout(_ geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.02) {
            headerView
                .conditionalModifier(useAIMode, modifier: { $0.shimmering(active: true) })
                .conditionalModifier(useAIMode, modifier: { $0.glowing(with: Color("neonBlue")) })
                .position(x: geometry.size.width / 2, y: geometry.size.height * 0.25)
            
            ballDisplay
                .conditionalModifier(useAIMode, modifier: { $0.glowing(with: Color("gold")) })
                .position(x: geometry.size.width / 2, y: geometry.size.height * 0.227)
            
            gamePickerView(geometry)
                .conditionalModifier(useAIMode, modifier: { $0.glowing(with: Color("neonBlue")) })
            
            PremiumAISwitch(isAIMode: $useAIMode, onToggle: { newValue in
                handleAIModeChange(newValue)
            })                .position(x: geometry.size.width / 2, y: geometry.size.height * -0.04)
            
//            PremiumGenerateButton()
//                .position(x: geometry.size.width / 2, y: geometry.size.height * -0.07)
            
            generateButton(geometry)
                .position(x: geometry.size.width / 2, y: geometry.size.height * -0.07)
        }
    }
    
    private var headerView: some View {
        VStack {
            Image("JackpotLogo")
                .resizable()
                .frame(width: 200, height: 200)
                .opacity(0.7)
        }
    }
    
    private var ballDisplay: some View {
        VStack(spacing: 2) {
            if activeGame == .lottoMax || activeGame == .euroMillions || activeGame == .euroJackpot {
                HStack(spacing: 2) {
                    if activeGame == .lottoMax {
                        ForEach(Array(whiteBalls.prefix(5).enumerated()), id: \.element.id) { index, ball in
                            ballView(for: ball, isSpecial: false, delay: Double(index) * 0.1)
                        }
                    } else {
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
                        ForEach(Array(specialBalls.enumerated()), id: \.element.id) { index, ball in
                            ballView(for: ball, isSpecial: true, delay: 0.5 + Double(index) * 0.1)
                        }
                    }
                }
            } else {
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
    
    // Game picker
    private func gamePickerView(_ geometry: GeometryProxy) -> some View {
        PremiumGamePicker(selectedGameRaw: $selectedGameRaw, useAIMode: useAIMode)
            .padding(.horizontal, 70)
            .position(x: geometry.size.width / 2, y: geometry.size.height * -0.33)
    }
    
    private var aiModeToggle: some View {
        Toggle("", isOn: $useAIMode)
            .toggleStyle(AIToggleStyle())
            .onChange(of: useAIMode) { newValue in
                handleAIModeChange(newValue)
            }
            .padding()
            .cornerRadius(10)
            .frame(width: UIScreen.main.bounds.width * 0.4)
    }
    
    private func generateButton(_ geometry: GeometryProxy) -> some View {
        PremiumGenerateButton(
            action: generateButtonPressed,
            isDisabled: isLoading,
            isAIMode: useAIMode
        )
        .frame(width: geometry.size.width * 0.8)
    }
    // Explanation overlay
    private func explanationOverlay(geometry: GeometryProxy) -> some View {
        ZStack {
            // Darkened background
            Color.black.opacity(0.0)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation { self.showExplanation = false }
                }
    
            // Content card
            VStack(spacing: 0) {
                // Header with close button
                HStack {
                    Text("AI Insights")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
    
                    Spacer()
    
                    Button(action: {
                        withAnimation { self.showExplanation = false }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 30))
                    }
                }
                .padding()
    
                Divider()
                    .background(Color.white.opacity(0.6))
    
                // Explanation text
                ScrollView {
                    Text(explanation)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: geometry.size.height * 0.25)
            }
            .background(
                RoundedRectangle(cornerRadius: LayoutConstants.cornerRadius)
                    .fill(Color.black.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: LayoutConstants.cornerRadius)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("gold"), Color("softGold").opacity(0.3)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
            )
            .offset(y: -geometry.size.height * 0.33)
            .padding()
        }
        .transition(.opacity.combined(with: .scale))
        .zIndex(1)
    }
    
    
    // AI Mode banner
    private var aiModeBannerView: some View {
        VStack {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .padding(.trailing, 8)
    
                VStack(alignment: .leading, spacing: 2) {
                    Text("AI Mode Activated")
                        .font(.headline)
                        .foregroundColor(.white)
                        .bold()
    
                    Text("Unlocking advanced number strategies")
                        .font(.subheadline)
                        .foregroundColor(Color.white.opacity(0.8))
                }
    
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color("darkBlue").opacity(0.9), Color("neonBlue").opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.white.opacity(0.6), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 10)
            )
            .padding(.horizontal)
            .transition(.move(edge: .top).combined(with: .opacity))
    
            Spacer()
        }
    }

    
    // Loading overlay
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .animation(.easeInOut, value: isLoading)
    
            VStack(spacing: 20) {
                PremiumSpinner()
    
                Text("Generating...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.6))
                    .shadow(color: Color.black.opacity(0.3), radius: 10)
            )
        }
        .transition(.opacity)
    }

    
    private var subscriptionAlert: Alert {
        Alert(
            title: Text("Unlock JackpotAI Premium!"),
            message: Text("You've reached your free limit of AI-generated numbers. Subscribe now for unlimited use and an ad-free experience, only $4.99/month!"),
            primaryButton: .default(Text("Subscribe"), action: {
                print("🔹 Subscribe button tapped!")
                IAPManager.shared.purchaseSubscription()
            }),
            secondaryButton: .cancel(Text("Maybe Later"))
        )
    }
    
    // MARK: - Event Handlers
    private func handleAppear() {
        if !MainView.didResetState {
            resetState()
            MainView.didResetState = true
        }
    }
    
    private func handleAIModeChange(_ newValue: Bool) {
        if newValue {
            resetBalls()
            triggerShakeAnimation()
        }
        
        withAnimation(.easeInOut(duration: 0.6)) {
            self.showAIModeOverlay = newValue
        }
        
        if newValue {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    self.showAIModeOverlay = false
                }
            }
        }
    }
    
    private func resetBalls() {
        self.whiteBalls = []
        self.specialBalls = []
        self.showLoadBalls = true
        self.explanation = ""
    }
    
    private func triggerShakeAnimation() {
        withAnimation(Animation.linear(duration: 0.6)) {
            self.shakeTrigger = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.shakeTrigger = 0
        }
    }
    
    private func generateButtonPressed() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        withAnimation {
            self.showLoadBalls = false
        }
        self.generateNumbers()
    }
    
    // MARK: - Logic Methods
    private func resetState() {
        self.generateCount = 0
        self.useAIMode = false
        self.selectedGameRaw = LotteryGame.powerball.rawValue
        self.activeGameRaw = LotteryGame.powerball.rawValue
        self.whiteBalls = []
        self.specialBalls = []
        self.explanation = ""
        self.scaleEffectState = .settled
        self.showLoadBalls = true
        self.showExplanation = false
        self.savedArray = []
    }
    
    private func generateNumbers() {
        self.generateCount += 1
        
        checkForAdDisplay()
        
        self.isLoading = true
        self.showExplanation = false
        
        withAnimation(Animation.spring(response: 0.5, dampingFraction: 0.6)) {
            self.scaleEffectState = .exit
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if self.useAIMode {
                self.generateAINumbers()
            } else {
                self.generateRandomNumbers()
            }
            self.activeGameRaw = self.selectedGameRaw
        }
    }
    
    private func checkForAdDisplay() {
        if self.generateCount % 4 == 0 {
            if let rootVC = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
                .first {
                
                if AdManager.shared.interstitial != nil {
                    AdManager.shared.showInterstitial(from: rootVC)
                } else {
                    print("⚠️ Ad not ready. Resetting count to show next ad sooner.")
                    self.generateCount -= 1
                }
            }
        }
    }
    
    private func saveGeneratedNumbers() {
        let whiteNumbers = self.whiteBalls.map { "\($0.number)" }.joined(separator: ", ")
        let specialNumbers = self.specialBalls.map { "\($0.number)" }.joined(separator: ", ")
        let combinedNumbers = specialNumbers.isEmpty ? whiteNumbers : "\(whiteNumbers) | \(specialNumbers)"
        let newEntry = CoinListItem(lottoNumbers: combinedNumbers)
        
        self.savedArray.insert(newEntry, at: 0)
        
        if self.savedArray.count > 10 {
            self.savedArray.removeLast()
        }
    }
    
    private func generateRandomNumbers() {
        let availableWhiteNumbers = Array(self.selectedGame.whiteBallRange)
        self.whiteBalls = availableWhiteNumbers.shuffled()
            .prefix(self.selectedGame.whiteBallCount)
            .map { Ball(number: $0) }
            .sorted { $0.number < $1.number }
        
        if self.selectedGame.specialBallCount > 0 {
            let availableSpecialNumbers = Array(self.selectedGame.specialBallRange)
            self.specialBalls = availableSpecialNumbers.shuffled()
                .prefix(self.selectedGame.specialBallCount)
                .map { Ball(number: $0) }
        } else {
            self.specialBalls = []
        }
        
        animateBallsSequence()
        saveGeneratedNumbers()
        self.isLoading = false
    }
    
    private func animateBallsSequence() {
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
    }
    
        private func generateAINumbers() {
            // Check if user can use AI (subscribed, in trial, or has free uses)
                guard subscriptionTracker.canUseAI else {
                    showSubscriptionPrompt()
                    isLoading = false
                    return
                }
                
                // Increment usage count if not subscribed or in trial
                subscriptionTracker.incrementUsage()
            
            self.isLoading = true
            self.showExplanation = false
            self.animateBalls = false

            let previousDrawsKey = "previousAIDraws"
            var previousDraws = UserDefaults.standard.array(forKey: previousDrawsKey) as? [[Int]] ?? []

            // Limit exclusions to only the last 3 draws
            let recentDrawsLimit = 3
            let lastDrawnNumbers = Set(previousDraws.suffix(recentDrawsLimit).flatMap { $0 })

            let promptType = getNextPromptType()
            let prompt = buildAIPrompt(promptType: promptType, excludedNumbers: lastDrawnNumbers)

            print("🎯 Selected Prompt Type: \(promptType)")

            AIService.shared.fetchAIResponse(prompt: prompt) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        print("🔍 AI Raw Response:\n\(response)")
                        self.processAIResponse(response)
                        
                    case .failure(let error):
                        print("❌ AI Error: \(error.localizedDescription)")
                        self.explanation = "Error: \(error.localizedDescription)"
                        self.isLoading = false
                    }
                }
            }
        }
    
    private func getNextPromptType() -> String {
        // Statistical/analytical prompts (70% chance)
        let analyticalPrompts = [
            "statistical", "statistical2",
            "dataAnalyst", "statisticalAdvantage", "patternRecognition",
            "probabilityMatrix", "optimizedStrategy", "historicalPattern"
        ]
        
        // Mystical/energetic prompts (30% chance)
        let mysticalPrompts = [
            "energetic", "numerology",
            "zodiac", "probabilityWave"
        ]
        
        // 70% chance of analytical, 30% chance of mystical
        let useAnalytical = Double.random(in: 0...1) < 0.7
        let promptPool = useAnalytical ? analyticalPrompts : mysticalPrompts
        
        return promptPool.randomElement() ?? "statistical"
    }

    private func buildAIPrompt(promptType: String, excludedNumbers: Set<Int>) -> String {
        let whiteBallCount = selectedGame.whiteBallCount
        let specialBallCount = selectedGame.specialBallCount
        let specialBallLabel = selectedGame.specialBallLabel ?? "special"
        let excludedArray = Array(excludedNumbers)
        
        // Find the appropriate prompt template
        guard let promptTemplate = AIPromptRepository.allPrompts.first(where: { $0.type == promptType }) else {
            // If not found, get a random one
            return AIPromptRepository.getRandomPrompt().buildPrompt(
                whiteBallCount: whiteBallCount,
                specialBallCount: specialBallCount,
                specialBallLabel: specialBallLabel,
                excludedNumbers: excludedArray
            )
        }
        
        // Build the prompt using the template
        return promptTemplate.buildPrompt(
            whiteBallCount: whiteBallCount,
            specialBallCount: specialBallCount,
            specialBallLabel: specialBallLabel,
            excludedNumbers: excludedArray
        )
    }

    
    private func processAIResponse(_ response: String) {
        let parsedWhiteBalls = parseNumbers(from: response, label: "White Balls", expectedCount: self.selectedGame.whiteBallCount)
        let parsedSpecialBalls = parseNumbers(from: response, label: "\(self.selectedGame.specialBallLabel ?? "Powerball")", expectedCount: self.selectedGame.specialBallCount)
        
        if parsedWhiteBalls.isEmpty || (self.selectedGame.specialBallCount > 0 && parsedSpecialBalls.isEmpty) {
            print("❌ ERROR: Numbers were not parsed correctly")
        }
        
        self.whiteBalls = parsedWhiteBalls.map { Ball(number: $0) }
        self.specialBalls = parsedSpecialBalls.map { Ball(number: $0) }
        
        self.explanation = extractExplanation(from: response)
        
        withAnimation {
            self.showExplanation = true
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
        
        self.saveGeneratedNumbers()
        self.isLoading = false
    }
    
    private func showSubscriptionPrompt() {
        self.showSubscriptionAlert = true
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
            .map { $0 }
        
        return extractedNumbers
    }
    
    private func extractExplanation(from text: String) -> String {
        let explanationStart = "Explanation:"
        guard let range = text.range(of: explanationStart) else { return "No explanation found." }
        let extractedText = text[range.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
        return extractedText
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

// MARK: - Prompt Management
struct AIPromptTemplate {
    let type: String
    let title: String  // Short description for the type
    let template: (Int, Int, String, [Int]) -> String  // Function that builds the prompt
    
    // Helper to apply the template
    func buildPrompt(whiteBallCount: Int, specialBallCount: Int, specialBallLabel: String, excludedNumbers: [Int]) -> String {
        return template(whiteBallCount, specialBallCount, specialBallLabel, excludedNumbers)
    }
}

// MARK: - Prompt Repository
class AIPromptRepository {
    // All available prompts
    static let allPrompts: [AIPromptTemplate] = [
        // Original prompts
        statisticalPrompt,
        energeticPrompt,
        statistical2Prompt,
        
        // New analytical prompts
        dataAnalystPrompt,
        statisticalAdvantagePrompt,
        patternRecognitionPrompt,
        probabilityMatrixPrompt,
        optimizedStrategyPrompt,
        historicalPatternPrompt,
        
        // Mystical prompts (used less frequently)
        numerologyPrompt,
        zodiacPrompt,
        probabilityWavePrompt
    ]
    
    // Get a random prompt template
    static func getRandomPrompt() -> AIPromptTemplate {
        return allPrompts.randomElement()!
    }
    
    // Get next prompt in sequence
    static func getNextPrompt(after currentType: String) -> AIPromptTemplate {
        guard let currentIndex = allPrompts.firstIndex(where: { $0.type == currentType }) else {
            return allPrompts[0]  // Default to first if not found
        }
        
        let nextIndex = (currentIndex + 1) % allPrompts.count
        return allPrompts[nextIndex]
    }
    
    // MARK: - Original Prompt Templates
    
    // Statistical Prompt
    static let statisticalPrompt = AIPromptTemplate(
        type: "statistical",
        title: "Statistical Analysis",
        template: { whiteBallCount, specialBallCount, specialBallLabel, excludedNumbers in
            """
            You are a top-tier lottery statistician providing expert insights with a hint of good luck. Using high-probability patterns, generate \(whiteBallCount) white balls and \(specialBallCount) \(specialBallLabel) balls, but exclude the numbers \(excludedNumbers)
            
            - Exclude these numbers in your selection, DO NOT use them for any reason: \(excludedNumbers).
            - No consecutive numbers.
            - Keep the explanation within 60 words.
            
            Respond in this format:
            White Balls: [number, number, number, number, number]  
            \(specialBallLabel): [number\(specialBallCount > 1 ? ", number" : "")]  
            Explanation: Reveal hidden statistical insights, highlighting **why today's selection maximizes odds**. Mention a key standout number and its historical significance.
            """
        }
    )
    
    // Energetic Prompt
    static let energeticPrompt = AIPromptTemplate(
        type: "energetic",
        title: "High Energy Picks",
        template: { whiteBallCount, specialBallCount, specialBallLabel, excludedNumbers in
            """
            You're a dynamic lottery AI! Generate \(whiteBallCount) white balls and \(specialBallCount) \(specialBallLabel) balls, but exclude the numbers \(excludedNumbers)
            
            - Bring excitement by using **real lottery trends**.
            - Inject personality and variation into the explanation.
            - Challenge the user to trust the selected numbers.
            - EXCLUDE these numbers, do not draw these numbers for any reason: \(excludedNumbers).
            - Steer clear of generic "this is exciting!" phrasing.
            - Keep it **under 60 words**.
            
            Respond in this format:
            White Balls: [number, number, number, number, number]  
            \(specialBallLabel): [number\(specialBallCount > 1 ? ", number" : "")]  
            Explanation: Make it **engaging and unpredictable**! Use a fun twist. Explain why the numbers are exciting.
            """
        }
    )
    
    // Statistical2 Prompt
    static let statistical2Prompt = AIPromptTemplate(
        type: "statistical2",
        title: "Data-Driven Forecast",
        template: { whiteBallCount, specialBallCount, specialBallLabel, excludedNumbers in
            """
            You are a **data-driven lottery forecaster** with a fun personality. Using high-probability patterns, number theory, and statistical theories, generate \(whiteBallCount) white balls and \(specialBallCount) \(specialBallLabel) balls, but exclude the numbers \(excludedNumbers)
            
            - DO NOT draw these numbers, exclude them at all cost: \(excludedNumbers).
            - No consecutive numbers.
            - Keep it **concise yet informative**—60 words max.
            
            Respond in this format:
            White Balls: [number, number, number, number, number]  
            \(specialBallLabel): [number\(specialBallCount > 1 ? ", number" : "")]  
            Explanation: Highlight **today's statistical advantage**—why these numbers could be **the smartest pick** based on trends and probabilities. Explain the reason for choosing each number.
            """
        }
    )
    
    // Additional original prompts would be defined here...
    
    // MARK: - New Prompt Templates
    
    // Numerology Prompt
    static let numerologyPrompt = AIPromptTemplate(
        type: "numerology",
        title: "Numerology Insight",
        template: { whiteBallCount, specialBallCount, specialBallLabel, excludedNumbers in
            """
            You are a **numerology expert** who understands the mystical properties of numbers. Generate \(whiteBallCount) white balls and \(specialBallCount) \(specialBallLabel) balls, but exclude the numbers \(excludedNumbers)
            
            - Use concepts of numerology and number vibrations.
            - Reference life path numbers or destiny numbers.
            - DO NOT include any numbers from this list: \(excludedNumbers)
            - Keep explanation under 60 words.
            
            Respond in this format:
            White Balls: [number, number, number, number, number]  
            \(specialBallLabel): [number\(specialBallCount > 1 ? ", number" : "")]  
            Explanation: Describe the **numerological significance** of these numbers. Explain their **vibrational energy** and why they align with universal patterns today.
            """
        }
    )
    
    // Historical Pattern Prompt
    static let historicalPatternPrompt = AIPromptTemplate(
        type: "historicalPattern",
        title: "Historical Pattern Analysis",
        template: { whiteBallCount, specialBallCount, specialBallLabel, excludedNumbers in
            """
            You are a **lottery historian** who has studied drawing patterns for decades. Generate \(whiteBallCount) white balls and \(specialBallCount) \(specialBallLabel) balls, avoiding these numbers: \(excludedNumbers)
            
            - Focus on cyclical patterns in lottery history.
            - Reference specific historical drawing patterns.
            - Absolutely DO NOT use any numbers from: \(excludedNumbers)
            - Under 60 words total.
            
            Respond in this format:
            White Balls: [number, number, number, number, number]  
            \(specialBallLabel): [number\(specialBallCount > 1 ? ", number" : "")]  
            Explanation: Explain how these numbers follow **historical drawing patterns**. Mention a specific historical cycle these numbers align with.
            """
        }
    )
    
    // Data Analyst Prompt
    static let dataAnalystPrompt = AIPromptTemplate(
        type: "dataAnalyst",
        title: "Data Analyst Approach",
        template: { whiteBallCount, specialBallCount, specialBallLabel, excludedNumbers in
            """
            You are a **professional data analyst** with expertise in lottery probability. Generate \(whiteBallCount) white balls and \(specialBallCount) \(specialBallLabel) balls, but exclude the numbers \(excludedNumbers)
            
            - Use data visualization and frequency analysis concepts.
            - Reference specific number frequencies and patterns.
            - Absolutely EXCLUDE these numbers: \(excludedNumbers)
            - Keep explanation under 60 words.
            
            Respond in this format:
            White Balls: [number, number, number, number, number]  
            \(specialBallLabel): [number\(specialBallCount > 1 ? ", number" : "")]  
            Explanation: Analyze the **statistical significance** of these selections. Highlight how the distribution optimizes potential outcomes. Be specific about frequencies of at least two numbers and why they stand out in your analysis.
            """
        }
    )

    // Statistical Advantage Prompt
    static let statisticalAdvantagePrompt = AIPromptTemplate(
        type: "statisticalAdvantage",
        title: "Statistical Advantage Analysis",
        template: { whiteBallCount, specialBallCount, specialBallLabel, excludedNumbers in
            """
            You are a **mathematical strategist** who applies number theory to lottery selection. Generate \(whiteBallCount) white balls and \(specialBallCount) \(specialBallLabel) balls, but exclude the numbers \(excludedNumbers)
            
            - Apply principles of probability and mathematical strategy.
            - Use number grouping, frequency, and gap analysis.
            - DO NOT use any numbers from this list: \(excludedNumbers)
            - Maximum 60 words.
            
            Respond in this format:
            White Balls: [number, number, number, number, number]  
            \(specialBallLabel): [number\(specialBallCount > 1 ? ", number" : "")]  
            Explanation: Explain the **mathematical advantage** of this selection. Reference specific numbers (like 7 and 23) and their statistical properties. Discuss mathematical groupings and how they increase win potential.
            """
        }
    )

    // Pattern Recognition Prompt
    static let patternRecognitionPrompt = AIPromptTemplate(
        type: "patternRecognition",
        title: "Pattern Recognition Algorithm",
        template: { whiteBallCount, specialBallCount, specialBallLabel, excludedNumbers in
            """
            You are an **advanced pattern recognition algorithm** designed to identify lottery trends. Generate \(whiteBallCount) white balls and \(specialBallCount) \(specialBallLabel) balls, avoiding these numbers: \(excludedNumbers)
            
            - Analyze number patterns, frequency density, and distribution.
            - Identify clusters and isolated numbers with high probability.
            - EXCLUDE all numbers in: \(excludedNumbers)
            - Keep to 60 words maximum.
            
            Respond in this format:
            White Balls: [number, number, number, number, number]  
            \(specialBallLabel): [number\(specialBallCount > 1 ? ", number" : "")]  
            Explanation: Describe the **pattern-based logic** behind these selections. Highlight specific numbers (like 12 and 34) and their positions in historical frequency distributions. Explain how this pattern increases winning potential.
            """
        }
    )

    // Probability Matrix Prompt
    static let probabilityMatrixPrompt = AIPromptTemplate(
        type: "probabilityMatrix",
        title: "Probability Matrix Calculation",
        template: { whiteBallCount, specialBallCount, specialBallLabel, excludedNumbers in
            """
            You are a **probability matrix calculator** that optimizes lottery selections. Generate \(whiteBallCount) white balls and \(specialBallCount) \(specialBallLabel) balls, excluding: \(excludedNumbers)
            
            - Use advanced probability calculations.
            - Consider drawing mechanics and number distribution.
            - DO NOT include any numbers from: \(excludedNumbers)
            - 60 words or less.
            
            Respond in this format:
            White Balls: [number, number, number, number, number]  
            \(specialBallLabel): [number\(specialBallCount > 1 ? ", number" : "")]  
            Explanation: Detail how your **probability matrix** identified these optimal picks. Reference specific numbers like 19 and 31 and why they have elevated probability values. Make the explanation exciting but grounded in mathematics.
            """
        }
    )
    
    // Zodiac Prompt
    static let zodiacPrompt = AIPromptTemplate(
        type: "zodiac",
        title: "Zodiac Alignment",
        template: { whiteBallCount, specialBallCount, specialBallLabel, excludedNumbers in
            """
            You are an **astrological lottery advisor** who aligns numbers with planetary positions. Generate \(whiteBallCount) white balls and \(specialBallCount) \(specialBallLabel) balls, avoiding these numbers: \(excludedNumbers)
            
            - Associate numbers with planets, zodiac signs, or cosmic events.
            - Reference today's astrological alignments.
            - DO NOT include any of these excluded numbers: \(excludedNumbers)
            - Maximum 60 words.
            
            Respond in this format:
            White Balls: [number, number, number, number, number]  
            \(specialBallLabel): [number\(specialBallCount > 1 ? ", number" : "")]  
            Explanation: Describe how these numbers align with current **planetary positions**. Mention which zodiac influences are strongest and how they affect today's lucky numbers.
            """
        }
    )
    
    // Probability Wave Prompt
    static let probabilityWavePrompt = AIPromptTemplate(
        type: "probabilityWave",
        title: "Quantum Probability Wave",
        template: { whiteBallCount, specialBallCount, specialBallLabel, excludedNumbers in
            """
            You are a **quantum probability expert** who understands how numbers exist in probability waves. Generate \(whiteBallCount) white balls and \(specialBallCount) \(specialBallLabel) balls, excluding: \(excludedNumbers)
            
            - Use quantum mechanics terminology.
            - Discuss probability waves and quantum states.
            - DO NOT include these numbers: \(excludedNumbers)
            - Keep explanation under 60 words.
            
            Respond in this format:
            White Balls: [number, number, number, number, number]  
            \(specialBallLabel): [number\(specialBallCount > 1 ? ", number" : "")]  
            Explanation: Describe how these numbers exist in **heightened probability states** today. Mention how **quantum observation** affects their likelihood of manifestation.
            """
        }
    )
    
    // Optimized Strategy Prompt
    static let optimizedStrategyPrompt = AIPromptTemplate(
        type: "optimizedStrategy",
        title: "Optimized Selection Strategy",
        template: { whiteBallCount, specialBallCount, specialBallLabel, excludedNumbers in
            """
            You are a **game theory specialist** who optimizes lottery number selection. Generate \(whiteBallCount) white balls and \(specialBallCount) \(specialBallLabel) balls, but exclude: \(excludedNumbers)
            
            - Focus on strategic number distribution and game theory.
            - Balance hot numbers, cold numbers, and optimal spacing.
            - EXCLUDE these numbers completely: \(excludedNumbers)
            - Maximum 60 words.
            
            Respond in this format:
            White Balls: [number, number, number, number, number]  
            \(specialBallLabel): [number\(specialBallCount > 1 ? ", number" : "")]  
            Explanation: Explain the **strategic advantage** of this number distribution. Mention how it optimizes for both probability and potential prize sharing.
            """
        }
    )
}

struct PremiumGamePicker: View {
    @Binding var selectedGameRaw: String
    let useAIMode: Bool
    
    // Get the current game enum from the raw string
    private var selectedGame: LotteryGame {
        LotteryGame(rawValue: selectedGameRaw) ?? .powerball
    }
    
    var body: some View {
        Menu {
            ForEach(LotteryGame.allCases, id: \.self) { game in
                Button(action: {
                    self.selectedGameRaw = game.rawValue
                }) {
                    HStack {
                        Text(game.rawValue)
                        
                        Spacer()
                        
                        if selectedGame == game {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color("neonBlue"))
                        }
                    }
                }
            }
        } label: {
            HStack {
                // Game icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color("darkBlue").opacity(0.8),
                                    Color("neonBlue").opacity(0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(Color("gold").opacity(0.7), lineWidth: 1.5)
                        )
                        .shadow(color: Color("neonBlue").opacity(0.4), radius: 4, x: 0, y: 2)
                    
                    Image(systemName: "gamecontroller.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                }
                
                // Game name
                VStack(alignment: .leading, spacing: 2) {
                    Text("GAME")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color("gold").opacity(0.8))
                    
                    Text(selectedGame.rawValue)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.leading, 8)
                
                Spacer()
                
                // Dropdown indicator
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 28, height: 28)
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(Color("gold"))
                        .font(.system(size: 12, weight: .bold))
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                ZStack {
                    // Main background
                    RoundedRectangle(cornerRadius: 15)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.black.opacity(0.7),
                                    Color("darkBlue").opacity(0.6)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    // Top highlight
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 15)
                        .blur(radius: 3)
                        .offset(y: -12)
                        .mask(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white)
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color("gold").opacity(0.8),
                                Color("gold").opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color("neonBlue").opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(SubscriptionTracker())
            .environmentObject(IAPManager.shared)
    }
}
