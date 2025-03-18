//
//  SubscriptionSmartBanner.swift
//  JackpotAI
//
//  Created by Matt Willie on 3/17/25.
//

import SwiftUI

struct SubscriptionSmartBanner: View {
    @Binding var isPresented: Bool
    @State private var showSubscriptionView = false
    @EnvironmentObject private var iapManager: IAPManager
    
    // Banner content options
    enum BannerType {
        case usage(remaining: Int)
        case jackpot(amount: String)
        case winRate(percentage: String)
        case generic
        
        var title: String {
            switch self {
            case .usage(let remaining):
                return "You have \(remaining) free AI predictions left"
            case .jackpot(let amount):
                return "Powerball is now $\(amount) Million!"
            case .winRate(let percentage):
                return "Premium users win \(percentage)% more often"
            case .generic:
                return "Upgrade to Premium"
            }
        }
        
        var description: String {
            switch self {
            case .usage:
                return "Unlock unlimited AI predictions with Premium"
            case .jackpot:
                return "Use AI predictions for better odds on this record jackpot"
            case .winRate:
                return "Our AI algorithm has shown higher win rates for subscribers"
            case .generic:
                return "Remove ads and get advanced predictions"
            }
        }
        
        var iconName: String {
            switch self {
            case .usage: return "hourglass"
            case .jackpot: return "dollarsign.circle"
            case .winRate: return "chart.line.uptrend.xyaxis"
            case .generic: return "crown.fill"
            }
        }
        
        var accentColor: Color {
            switch self {
            case .usage: return Color("neonBlue")
            case .jackpot: return Color("gold")
            case .winRate: return Color("neonBlue")
            case .generic: return Color("gold")
            }
        }
    }
    
    let bannerType: BannerType
    let displayDuration: Double
    let showCloseButton: Bool
    let onActionTapped: (() -> Void)?
    
    init(
        isPresented: Binding<Bool>,
        type: BannerType = .generic,
        displayDuration: Double = 0, // 0 means stay until dismissed
        showCloseButton: Bool = true,
        onActionTapped: (() -> Void)? = nil
    ) {
        self._isPresented = isPresented
        self.bannerType = type
        self.displayDuration = displayDuration
        self.showCloseButton = showCloseButton
        self.onActionTapped = onActionTapped
        
        // Auto-dismiss if duration is set
        if displayDuration > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + displayDuration) {
                isPresented.wrappedValue = false
            }
        }
    }
    
    var body: some View {
        Group {
            if isPresented {
                bannerView
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isPresented)
            }
        }
    }
    
    private var bannerView: some View {
        VStack(spacing: 0) {
            // Banner content
            HStack(spacing: 15) {
                // Icon
                Circle()
                    .fill(bannerType.accentColor.opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: bannerType.iconName)
                            .font(.system(size: 16))
                            .foregroundColor(bannerType.accentColor)
                    )
                
                // Text content
                VStack(alignment: .leading, spacing: 2) {
                    Text(bannerType.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(bannerType.description)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Action button
                Button(action: {
                    // Custom action or default to showing subscription view
                    if let customAction = onActionTapped {
                        customAction()
                    } else {
                        showSubscriptionView = true
                    }
                }) {
                    Text("Upgrade")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 7)
                        .background(
                            Capsule()
                                .fill(bannerType.accentColor)
                        )
                }
                
                // Optional close button
                if showCloseButton {
                    Button(action: {
                        withAnimation {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(5)
                    }
                }
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    // Gradient background
                    LinearGradient(
                        gradient: Gradient(colors: [Color("darkBlue"), Color.black]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    
                    // Subtle pattern overlay
                    HStack(spacing: 0) {
                        ForEach(0..<8) { i in
                            Rectangle()
                                .fill(Color.white.opacity(0.05))
                                .frame(width: 40, height: 60)
                                .rotationEffect(Angle(degrees: 45))
                                .offset(x: CGFloat(i * 30 - 100), y: 0)
                        }
                    }
                    .mask(Rectangle())
                    .blendMode(.plusLighter)
                }
            )
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(bannerType.accentColor.opacity(0.5)),
                alignment: .bottom
            )
            .cornerRadius(0)
        }
        .shadow(color: Color.black.opacity(0.3), radius: 5, y: 3)
        .sheet(isPresented: $showSubscriptionView) {
            SubscriptionView()
                .environmentObject(iapManager)
        }
    }
}

// MARK: - Banner Manager
class SubscriptionBannerManager: ObservableObject {
    @Published var showBanner: Bool = false
    @Published var currentBannerType: SubscriptionSmartBanner.BannerType = .generic
    
    // Show banner with usage counter when approaching limit
    func showUsageBanner(remainingUses: Int) {
        guard !showBanner else { return }
        
        currentBannerType = .usage(remaining: remainingUses)
        withAnimation {
            showBanner = true
        }
        
        // Auto-hide after 5 seconds
        autoDismiss(after: 5)
    }
    
    // Show banner when jackpot is high
    func showJackpotBanner(amount: String) {
        guard !showBanner else { return }
        
        currentBannerType = .jackpot(amount: amount)
        withAnimation {
            showBanner = true
        }
        
        // Auto-hide after 8 seconds (longer for important info)
        autoDismiss(after: 8)
    }
    
    // Show banner with win rate statistics
    func showWinRateBanner(percentage: String) {
        guard !showBanner else { return }
        
        currentBannerType = .winRate(percentage: percentage)
        withAnimation {
            showBanner = true
        }
        
        // Auto-hide after 5 seconds
        autoDismiss(after: 5)
    }
    
    // Show generic premium banner
    func showGenericBanner() {
        guard !showBanner else { return }
        
        currentBannerType = .generic
        withAnimation {
            showBanner = true
        }
        
        // Auto-hide after 5 seconds
        autoDismiss(after: 5)
    }
    
    // Hide banner manually
    func hideBanner() {
        withAnimation {
            showBanner = false
        }
    }
    
    // Auto-dismiss after specified seconds
    private func autoDismiss(after seconds: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [weak self] in
            withAnimation {
                self?.showBanner = false
            }
        }
    }
}

// MARK: - Usage Example
struct BannerDemoView: View {
    @StateObject private var bannerManager = SubscriptionBannerManager()
    @State private var manualBannerShown = false
    
    var body: some View {
        ZStack(alignment: .top) {
            // Main content
            VStack(spacing: 20) {
                Spacer().frame(height: 50)
                
                // Demo buttons
                Button("Show Usage Banner") {
                    bannerManager.showUsageBanner(remainingUses: 2)
                }
                .buttonStyle(.bordered)
                
                Button("Show Jackpot Banner") {
                    bannerManager.showJackpotBanner(amount: "850")
                }
                .buttonStyle(.bordered)
                
                Button("Show Win Rate Banner") {
                    bannerManager.showWinRateBanner(percentage: "37")
                }
                .buttonStyle(.bordered)
                
                Button("Show Generic Banner") {
                    bannerManager.showGenericBanner()
                }
                .buttonStyle(.bordered)
                
                // Example of banner with binding
                Button("Show Manual Banner") {
                    manualBannerShown = true
                }
                .buttonStyle(.bordered)
                
                Spacer()
            }
            .padding()
            
            // Banner from manager
            SubscriptionSmartBanner(
                isPresented: $bannerManager.showBanner,
                type: bannerManager.currentBannerType
            )
            
            // Manually controlled banner example
            if manualBannerShown {
                SubscriptionSmartBanner(
                    isPresented: $manualBannerShown,
                    type: .jackpot(amount: "750"),
                    displayDuration: 3
                )
            }
        }
    }
}

// MARK: - Preview
struct SubscriptionSmartBanner_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Preview banner types
            VStack(spacing: 20) {
                SubscriptionSmartBanner(
                    isPresented: .constant(true),
                    type: .usage(remaining: 2)
                )
                
                SubscriptionSmartBanner(
                    isPresented: .constant(true),
                    type: .jackpot(amount: "1.2B")
                )
                
                SubscriptionSmartBanner(
                    isPresented: .constant(true),
                    type: .winRate(percentage: "27")
                )
                
                SubscriptionSmartBanner(
                    isPresented: .constant(true),
                    type: .generic
                )
            }
            .previewDisplayName("Banner Types")
            
            // Preview usage in a view
            BannerDemoView()
                .previewDisplayName("Banner Demo")
        }
        .environmentObject(IAPManager.shared)
        .preferredColorScheme(.dark)
    }
}
