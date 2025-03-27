//
//  DebugMenu.swift
//  JackpotAI
//
//  Created by Matt Willie on 3/18/25.
//

import SwiftUI
import Foundation

// MARK: - Debug Menu View
struct DebugMenuView: View {
    // MARK: - Environment & Observable Objects
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var iapManager: IAPManager
    @EnvironmentObject private var subscriptionTracker: SubscriptionTracker
    
    // MARK: - State Variables
    @State private var showInitialAnimation = true
    @State private var showTerminal = false
    @State private var showCustomAlert = false
    @State private var typingText = ""
    @State private var commandHistory: [String] = []
    @State private var animationProgress: Double = 0.0
    
    // Password verification states
    @State private var isPasswordVerified = false
    @State private var passwordInput = ""
    @State private var showPasswordPrompt = true
    @State private var incorrectPasswordAttempt = false
    @State private var passwordAttempts = 0
    
    // Code animation states
    @State private var codeLines: [CodeLine] = []
    @State private var visibleLines: [CodeLine] = []
    @State private var currentLineIndex = 0
    @State private var currentTypingLine = ""
    
    // Alert states
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var alertAction: (() -> Void)? = nil
    
    // Matrix animation states
    @State private var randomChars: [String] = []
    @State private var showProgress = false
    @State private var progressValue: Float = 0.0
    @State private var progressText = "Initializing..."
    
    // MARK: - Constants & Computed Properties
    private let matrixCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789$#@&%*!?"
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    private let totalAnimationDuration: Double = 5.0 // Total animation time in seconds
    private let correctPassword = "jackpot2025" // Password for debug menu access
    private let maxPasswordAttempts = 3
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        return "\(version) (\(build))"
    }

// MARK: - Models and Supporting Views
// Code line model
struct CodeLine: Identifiable {
    let id = UUID()
    var text: String
    var opacity: Double = 1.0
    var textColor: Color = .green
    var isHighlighted: Bool = false
}

// Terminal section container
struct TerminalSection<Content: View>: View {
    let title: String
    let content: () -> Content
    
    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("[ \(title) ]")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.green)
                .padding(.vertical, 4)
            
            content()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.4))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.green.opacity(0.6), Color.blue.opacity(0.3)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

// Command button
struct CommandButton: View {
    let command: String
    let description: String
    var isDisabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(command)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.green)
                
                Text(description)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.gray)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.black.opacity(0.3))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green.opacity(0.3), Color.blue.opacity(0.2)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1
                    )
            )
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
    }
}

// Preview provider
struct DebugMenuView_Previews: PreviewProvider {
    static var previews: some View {
        DebugMenuView()
            .environmentObject(IAPManager.shared)
            .environmentObject(SubscriptionTracker())
    }
}
    
    private var deviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    private var systemVersion: String {
        return UIDevice.current.systemName + " " + UIDevice.current.systemVersion
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black.edgesIgnoringSafeArea(.all)
                
                if !isPasswordVerified {
                    // Password verification screen
                    passwordVerificationView
                } else if showInitialAnimation {
                    // Initial hacking animation
                    hackingAnimation(geometry: geometry)
                } else if showTerminal {
                    // Main terminal content with a sleek design
                    terminalInterface(geometry: geometry)
                        .transition(.opacity)
                }
                
                // Custom alert overlay
                if showCustomAlert {
                    customAlertView
                }
            }
            .onAppear {
                if !isPasswordVerified {
                    showPasswordPrompt = true
                } else {
                    startHackingSequence()
                }
            }
        }
    }
    
    // MARK: - Password Verification
    private var passwordVerificationView: some View {
        ZStack {
            // Digital background pattern
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("AUTHORIZATION REQUIRED")
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundColor(.red)
                        .padding(.top, 20)
                    
                    Text("SECURITY LEVEL: ADMIN")
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.green)
                }
                
                // Security icon
                Image(systemName: "lock.shield")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
                    .padding(.vertical, 20)
                
                // Password input field
                VStack(spacing: 8) {
                    if incorrectPasswordAttempt {
                        Text("ACCESS DENIED: INVALID CREDENTIALS")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.red)
                            .padding(.bottom, 5)
                    }
                    
                    Text("REMAINING ATTEMPTS: \(maxPasswordAttempts - passwordAttempts)")
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(passwordAttempts >= maxPasswordAttempts - 1 ? .red : .yellow)
                        .padding(.bottom, 10)
                    
                    SecureField("", text: $passwordInput)
                        .font(.system(size: 18, design: .monospaced))
                        .foregroundColor(.green)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.green.opacity(0.7), lineWidth: 1)
                        )
                        .padding(.horizontal, 30)
                        .disabled(passwordAttempts >= maxPasswordAttempts)
                        .onSubmit {
                            verifyPassword()
                        }
                }
                
                // Action buttons
                HStack(spacing: 20) {
                    // Verify button
                    Button(action: verifyPassword) {
                        Text("VERIFY")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.black)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(Color.green)
                            .cornerRadius(4)
                    }
                    .disabled(passwordAttempts >= maxPasswordAttempts)
                    
                    // Cancel button
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("EXIT")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(Color.red.opacity(0.7))
                            .cornerRadius(4)
                    }
                }
                .padding(.top, 30)
                
                // Lockout warning
                if passwordAttempts >= maxPasswordAttempts {
                    Text("SECURITY LOCKOUT ACTIVE")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.red)
                        .padding(.top, 20)
                }
                
                Spacer()
            }
            .padding(30)
            .background(
                ZStack {
                    // Background grid pattern
                    ForEach(0..<20) { i in
                        Rectangle()
                            .fill(Color.green.opacity(0.05))
                            .frame(height: 1)
                            .offset(y: CGFloat(i * 20))
                    }
                    
                    ForEach(0..<30) { i in
                        Rectangle()
                            .fill(Color.green.opacity(0.05))
                            .frame(width: 1)
                            .offset(x: CGFloat(i * 20))
                    }
                    
                    // Background overlay
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.8))
                }
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(incorrectPasswordAttempt ? Color.red : Color.green, lineWidth: 2)
            )
            .padding(40)
        }
    }
    
    private func verifyPassword() {
        if passwordInput == correctPassword {
            // Correct password
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            withAnimation(.easeInOut(duration: 0.3)) {
                isPasswordVerified = true
                incorrectPasswordAttempt = false
                
                // Start animation sequence
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    startHackingSequence()
                }
            }
        } else {
            // Incorrect password
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
            passwordAttempts += 1
            passwordInput = ""
            
            withAnimation(.easeInOut(duration: 0.3)) {
                incorrectPasswordAttempt = true
            }
            
            // Vibrate device on incorrect
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
    }
    
    // MARK: - Hacking Animation
    private func hackingAnimation(geometry: GeometryProxy) -> some View {
        ZStack {
            // Digital background pattern
            digitalBackground(geometry: geometry)
            
            // Matrix effect
            matrixRainEffect
                .opacity(0.6)
            
            // Scanning grid
            scanningGrid(geometry: geometry)
                .opacity(0.4)
            
            // Progress bar and status
            if showProgress {
                VStack(spacing: 20) {
                    // Status text
                    Text(progressText)
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Progress bar
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.green, Color.blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * 0.8 * CGFloat(progressValue), height: 6)
                            .shadow(color: Color.green.opacity(0.8), radius: 4, x: 0, y: 0)
                    }
                    .frame(width: geometry.size.width * 0.8)
                    
                    // Percentage
                    Text("\(Int(progressValue * 100))%")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 30)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green.opacity(0.5), lineWidth: 1)
                        )
                )
                .shadow(color: Color.green.opacity(0.3), radius: 10)
                .padding(30)
            }
            
            // Code scrolling
            VStack(alignment: .leading, spacing: 2) {
                ForEach(visibleLines) { line in
                    Text(line.text)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(textColorForLine(line.text))
                        .opacity(line.opacity)
                        .padding(.vertical, line.text.isEmpty ? 2 : 0)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .opacity(showProgress ? 0.3 : 1.0)
        }
    }
    
    // Digital background pattern
    private func digitalBackground(geometry: GeometryProxy) -> some View {
        ZStack {
            // Circuit-like pattern
            ForEach(0..<20) { i in
                Path { path in
                    let y = CGFloat.random(in: 0...geometry.size.height)
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                }
                .stroke(Color.green.opacity(0.1), lineWidth: 1)
            }
            
            ForEach(0..<15) { i in
                Path { path in
                    let x = CGFloat.random(in: 0...geometry.size.width)
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                }
                .stroke(Color.green.opacity(0.1), lineWidth: 1)
            }
            
            // Connection nodes
            ForEach(0..<30) { i in
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 6, height: 6)
                    .position(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: 0...geometry.size.height)
                    )
            }
        }
    }
    
    // Matrix rain effect
    private var matrixRainEffect: some View {
        VStack(spacing: 0) {
            ForEach(0..<15, id: \.self) { _ in
                HStack(spacing: 4) {
                    ForEach(0..<randomChars.count, id: \.self) { index in
                        Text(randomChars[index])
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.green.opacity(Double.random(in: 0.2...0.7)))
                    }
                }
            }
        }
        .onReceive(timer) { _ in
            updateMatrixEffect()
        }
    }
    
    // Scanning grid effect
    private func scanningGrid(geometry: GeometryProxy) -> some View {
        ZStack {
            // Horizontal scan line
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .green.opacity(0.5), .clear]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .offset(y: geometry.size.height / 2 * CGFloat(sin(animationProgress * 10)))
                .opacity(0.7)
            
            // Vertical scan line
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .green.opacity(0.5), .clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 2)
                .offset(x: geometry.size.width / 2 * CGFloat(cos(animationProgress * 8)))
                .opacity(0.7)
        }
    }
    
    // MARK: - Terminal Interface
    private func terminalInterface(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            // Terminal header
            terminalHeader
            
            // Main content area
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // System status section
                    statusSection
                    
                    // Command history if any
                    if !commandHistory.isEmpty {
                        commandHistorySection
                    }
                    
                    // Available commands
                    commandsSection
                }
                .padding(16)
            }
            .background(Color(red: 0.05, green: 0.05, blue: 0.05))
            
            // Command input area
            commandInput
        }
        .background(Color(red: 0.05, green: 0.05, blue: 0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.green.opacity(0.7), Color.blue.opacity(0.5)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.green.opacity(0.2), radius: 15)
        .padding(16)
    }
    
    // Terminal header
    private var terminalHeader: some View {
        HStack {
            Text("ROOT@JACKPOTAI:~#")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.green)
            
            Spacer()
            
            Text("v\(appVersion)")
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.green.opacity(0.7))
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("[EXIT]")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.8))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.green.opacity(0.5)),
            alignment: .bottom
        )
    }
    
    // System status section
    private var statusSection: some View {
        TerminalSection(title: "SYSTEM STATUS") {
            statusLine("SUBSCRIPTION_STATUS",
                      value: iapManager.isSubscribed ? "ACTIVE" : "INACTIVE",
                      color: iapManager.isSubscribed ? .green : .red)
            
            statusLine("TRIAL_MODE",
                      value: subscriptionTracker.remainingFreeUses > 0 ? "RUNNING" : "DISABLED",
                      color: subscriptionTracker.remainingFreeUses > 0 ? .yellow : .red)
            
            statusLine("FREE_USES_REMAINING",
                      value: "\(subscriptionTracker.remainingFreeUses)",
                      color: .yellow)
            
            statusLine("AI_REQUEST_COUNT",
                      value: "\(UserDefaults.standard.integer(forKey: "aiUsageCount"))",
                      color: .cyan)
            
            statusLine("DEVICE_MODEL", value: deviceModel, color: .cyan)
            
            statusLine("SYSTEM_VERSION", value: systemVersion, color: .cyan)
        }
    }
    
    // Command history section
    private var commandHistorySection: some View {
        TerminalSection(title: "COMMAND HISTORY") {
            ForEach(commandHistory, id: \.self) { command in
                Text(command)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
    
    // Available commands section
    private var commandsSection: some View {
        TerminalSection(title: "AVAILABLE COMMANDS") {
            CommandButton(
                command: "./reset_all.sh",
                description: "Full System Reset"
            ) {
                showConfirmation(
                    title: "CONFIRM SYSTEM RESET",
                    message: "Warning: This operation will reset all subscription data. System restart required after execution. Proceed?",
                    action: performFullReset
                )
            }
            
            CommandButton(
                command: "./start_trial.sh",
                description: "Activate Trial Mode"
            ) {
                startTrial()
            }
            
            CommandButton(
                command: "./end_trial.sh",
                description: "Terminate Trial"
            ) {
                endTrial()
            }
            
            CommandButton(
                command: "./toggle_subscription.sh",
                description: "Toggle Premium Status"
            ) {
                toggleSubscription()
            }
            
            CommandButton(
                command: "./reset_ai_counter.sh",
                description: "Reset AI Usage"
            ) {
                resetAIUsage()
            }
        }
    }
    
    // Command input
    private var commandInput: some View {
        HStack {
            Text("$")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.green)
            
            Text(typingText)
                .font(.system(size: 16, design: .monospaced))
                .foregroundColor(.green)
            
            // Blinking cursor
            Rectangle()
                .frame(width: 10, height: 18)
                .opacity(animationProgress.truncatingRemainder(dividingBy: 1.0) > 0.5 ? 1 : 0)
            
            Spacer()
        }
        .padding(16)
        .background(Color.black.opacity(0.8))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.green.opacity(0.5)),
            alignment: .top
        )
    }
    
    // Custom alert view
    private var customAlertView: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            // Alert content
            VStack(spacing: 20) {
                Text(alertTitle)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.red)
                
                Text(alertMessage)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.green)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 20) {
                    // Execute button
                    Button(action: {
                        if let action = alertAction {
                            action()
                        }
                        showCustomAlert = false
                    }) {
                        Text("EXECUTE")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.black)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(Color.red)
                            .cornerRadius(4)
                    }
                    
                    // Abort button
                    Button(action: {
                        showCustomAlert = false
                    }) {
                        Text("ABORT")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(Color.gray.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .cornerRadius(4)
                    }
                }
            }
            .padding(30)
            .background(Color(red: 0.1, green: 0.1, blue: 0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.red.opacity(0.7), lineWidth: 2)
            )
            .cornerRadius(8)
            .shadow(color: .red.opacity(0.3), radius: 20)
            .padding(40)
        }
    }
    
    // MARK: - Helper Components
    private func statusLine(_ label: String, value: String, color: Color) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(color)
        }
    }
    
    // Helper function to determine text color based on line content
    private func textColorForLine(_ line: String) -> Color {
        if line.contains("[!]") || line.contains("WARNING") || line.contains("ALERT") {
            return .red
        } else if line.contains("[+]") || line.contains("SUCCESS") {
            return .green
        } else if line.contains("print") {
            return .yellow
        } else if line.starts(with: "#") {
            return .orange
        } else if line.contains("=") && !line.contains("==") {
            return Color(red: 0.3, green: 0.7, blue: 1.0)
        } else {
            return .green
        }
    }
    
    // MARK: - Setup and Animation
    private func startHackingSequence() {
        // Simulate device vibration for effect
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        // Generate code lines
        generateCodeLines()
        
        // Start progress animation
        startProgressAnimation()
        
        // Start code typing animation
        startCodeTypingAnimation()
        
        // Update animation progress periodically
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            self.animationProgress += 0.1
            
            // End animation after specified duration
            if self.animationProgress >= 1.0 * self.totalAnimationDuration {
                timer.invalidate()
                
                // Give haptic feedback for completion
                let completionGenerator = UINotificationFeedbackGenerator()
                completionGenerator.notificationOccurred(.success)
                
                // Reveal terminal
                self.revealTerminal()
            }
        }
    }
    
    private func revealTerminal() {
        // Reveal the terminal interface
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.4)) {
                self.showInitialAnimation = false
                
                // Short delay before showing terminal
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeIn(duration: 0.3)) {
                        self.showTerminal = true
                    }
                }
            }
        }
    }
    
    private func startProgressAnimation() {
        // Show progress after a small delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation {
                self.showProgress = true
            }
        }
        
        // Animate progress from 0 to 100% over the animation duration
        Timer.scheduledTimer(withTimeInterval: totalAnimationDuration / 10, repeats: true) { timer in
            withAnimation {
                // Progress from 0 to 1.0
                self.progressValue = min(Float(self.animationProgress / self.totalAnimationDuration), 1.0)
                
                // Update progress text
                if self.progressValue < 0.33 {
                    self.progressText = "Bypassing security..."
                } else if self.progressValue < 0.66 {
                    self.progressText = "Disabling verification..."
                } else if self.progressValue < 1.0 {
                    self.progressText = "Gaining root access..."
                } else {
                    self.progressText = "Root access granted!"
                    timer.invalidate()
                }
            }
        }
    }
    
    private func updateMatrixEffect() {
        if randomChars.count < 30 {
            randomChars.append(String(matrixCharacters.randomElement()!))
        } else {
            for i in 0..<randomChars.count where Bool.random() {
                randomChars[i] = String(matrixCharacters.randomElement()!)
            }
        }
    }
    
    // MARK: - Code Animation
    private func generateCodeLines() {
        let hackerLines = [
            "# JACKPOTAI SECURITY OVERRIDE",
            "# ACCESSING ROOT PRIVILEGES",
            "import sys, os, time",
            "import security.bypass as bypass",
            "from subscription.manager import SubscriptionVerifier",
            "",
            "# Locating subscription database",
            "db_path = os.path.join('/var/mobile/Containers/Data/Application/', app_uuid, 'Documents/subscriptions.db')",
            "print(f'Target located: {db_path}')",
            "",
            "# Bypassing security layer",
            "bypass.disable_signature_verification()",
            "bypass.set_access_level(9)",
            "",
            "# [!] WARNING: Modifying system parameters",
            "sub_manager = SubscriptionVerifier.get_instance()",
            "sub_manager.override_verification = True",
            "sub_manager.admin_access = True",
            "",
            "# Accessing subscription controls",
            "print('Modifying subscription state...')",
            "os.system('chmod 777 ' + db_path)",
            "",
            "# [!] WARNING: Making permanent changes",
            "print('Root privileges acquired!')",
            "print('Initializing admin console...')"
        ]
        
        codeLines = hackerLines.map { CodeLine(text: $0) }
    }
    
    private func startCodeTypingAnimation() {
        // Type code lines rapidly to fit within animation timeframe
        visibleLines = []
        
        func typeNextLine() {
            if currentLineIndex < codeLines.count {
                // Add the full line immediately - for speed
                let newLine = codeLines[currentLineIndex]
                visibleLines.append(newLine)
                
                // Fade previous lines
                for i in 0..<(visibleLines.count-1) {
                    visibleLines[i].opacity = max(visibleLines[i].opacity - 0.1, 0.6)
                }
                
                // Keep only visible lines
                if visibleLines.count > 15 {
                    visibleLines.removeFirst()
                }
                
                // Go to next line
                currentLineIndex += 1
                
                // Timing for next line
                let lineDelay = currentLineIndex < codeLines.count ? 0.1 : 0
                DispatchQueue.main.asyncAfter(deadline: .now() + lineDelay) {
                    typeNextLine()
                }
            }
        }
        
        // Start typing after a small delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            typeNextLine()
        }
    }
    
    // MARK: - Alert Helpers
    private func showConfirmation(title: String, message: String, action: @escaping () -> Void) {
        alertTitle = title
        alertMessage = message
        alertAction = action
        showCustomAlert = true
    }
    
    // MARK: - Command Execution Methods
    private func simulateCommandExecution(_ command: String) {
        typingText = command
        
        // Simulate command typing and execution
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.typingText = ""
        }
    }
    
    private func addCommandOutput(_ output: String) {
        let timestamp = Date().formatted(date: .omitted, time: .standard)
        commandHistory.insert("[\(timestamp)] \(output)", at: 0)
        
        // Keep history limited for performance
        if commandHistory.count > 10 {
            commandHistory.removeLast()
        }
    }
    
    // MARK: - Command Actions
    private func performFullReset() {
        // Reset all subscription-related state
        UserDefaults.standard.set(false, forKey: "isSubscribed")
        UserDefaults.standard.removeObject(forKey: "trialStartDate")
        UserDefaults.standard.removeObject(forKey: "aiUsageCount")
        
        // Force reset published properties
        DispatchQueue.main.async {
            self.iapManager.isSubscribed = false
        }
        
        simulateCommandExecution("./reset_all.sh")
        addCommandOutput("SYSTEM RESET COMPLETE. Restart required.")
        
        // Give haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func startTrial() {
        // Start a new trial
        subscriptionTracker.resetUsage()
        UserDefaults.standard.set(Date(), forKey: "trialStartDate")
        
        simulateCommandExecution("./start_trial.sh")
        addCommandOutput("Trial mode activated. Runtime: 3 days.")
        
        // Give haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func endTrial() {
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        UserDefaults.standard.set(threeDaysAgo, forKey: "trialStartDate")
        
        simulateCommandExecution("./end_trial.sh")
        addCommandOutput("Trial mode terminated.")
        
        // Give haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    private func toggleSubscription() {
        let newState = !iapManager.isSubscribed
        UserDefaults.standard.set(newState, forKey: "isSubscribed")
        
        DispatchQueue.main.async {
            self.iapManager.isSubscribed = newState
        }
        
        simulateCommandExecution("./toggle_subscription.sh")
        addCommandOutput("Subscription status: \(newState ? "ACTIVE" : "INACTIVE")")
        
        // Give haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(newState ? .success : .warning)
    }
    
    private func resetAIUsage() {
        UserDefaults.standard.set(0, forKey: "aiUsageCount")
        simulateCommandExecution("./reset_ai_counter.sh")
        addCommandOutput("AI usage counter reset to 0.")
        
        // Give haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

// View modifier for debug menu activation
extension View {
    func debugMenuTrigger(isPresented: Binding<Bool>) -> some View {
        self.onTapGesture(count: 7) { // 7 taps to activate
            isPresented.wrappedValue = true
        }
    }
}

// Preview provider
struct DebugMenuView_Previews: PreviewProvider {
    static var previews: some View {
        DebugMenuView()
            .environmentObject(IAPManager.shared)
            .environmentObject(SubscriptionTracker())
    }
}
