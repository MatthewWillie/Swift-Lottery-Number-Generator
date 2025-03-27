//
//  SettingsView.swift
//  JackpotAI
//
//  Created by Matt Willie on 3/17/25.
//

import SwiftUI
import StoreKit

// Light Mode Modifier
struct ForceLightMode: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color(UIColor.systemBackground))
            .environment(\.colorScheme, .light)
    }
}

extension View {
    func forceLightMode() -> some View {
        self.modifier(ForceLightMode())
    }
}

struct SettingsView: View {
    // MARK: - Properties
    @EnvironmentObject var subscriptionTracker: SubscriptionTracker
    @EnvironmentObject private var iapManager: IAPManager
    @State private var showInfoSheet = false
    @State private var showSubscriptionView = false
    @State private var showDebugMenu = false

    
    // MARK: - Constants
    private struct Constants {
        static let cornerRadius: CGFloat = 16
        static let iconSize: CGFloat = 22
        static let spacing: CGFloat = 16
        static let mainPadding: CGFloat = 16
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background
            backgroundLayer
            
            ScrollView {
                VStack(spacing: Constants.spacing) {
                    subscriptionSection
                    
                    
                    // Info Button Section
                    VStack(spacing: Constants.spacing) {
                        // Add some spacing
                        Spacer()
                            .frame(height: 1)
                        
                        // Info Button
                        infoButton
                        
                        // Footer space
                        Spacer()
                            .frame(height: 1)
                    }
                    aboutSection
                    legalSection
                        .padding(.bottom, 50)
                }
                .padding(.horizontal, Constants.mainPadding)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(Color("neonBlue"))
            }
        }
        .forceLightMode() // Force light mode for this view
        .onAppear {
            // Backup approach to force light mode
            if #available(iOS 13.0, *) {
                UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
            }
        }
        .sheet(isPresented: $showInfoSheet) {
            InfoSheetView(isPresented: $showInfoSheet)
        }
        .sheet(isPresented: $showSubscriptionView) {
            SubscriptionView()
                .environmentObject(iapManager)
        }
    }
    
    // MARK: - UI Components
    
    // Info Button
    private var infoButton: some View {
        Button(action: { showInfoSheet = true }) {
            HStack(spacing: 8) {
                Text("How It Works")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color("darkBlue"))
                
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color("neonBlue"))
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(
                Capsule().stroke(Color.blue, lineWidth: 0.5)
                    .fill(Color.white.opacity(0.85))
                    .shadow(color: Color.blue.opacity(0.2), radius: 2, x: 0, y: 5)
            )
        }
    }
    
    // Background Layer
    private var backgroundLayer: some View {
        Color("lightBlue")
            .opacity(0.1)
            .ignoresSafeArea()
    }
    
    // MARK: - Subscription Section
    private var subscriptionSection: some View {
        VStack(spacing: Constants.spacing) {
            sectionHeader(title: "Subscription", icon: "crown.fill")         .debugMenuTrigger(isPresented: $showDebugMenu)

            
            // Status Card
            VStack(spacing: 12) {
                HStack {
                    Text("Status")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    subscriptionStatusBadge
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                Divider()
                    .padding(.horizontal, 16)
                
                // Action Buttons
                VStack(spacing: 12) {
                    if !iapManager.isSubscribed {
                        subscribeButton
                    }
                    
                    restoreButton
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .fill(Material.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
        }
        .fullScreenCover(isPresented: $showDebugMenu) {
                    DebugMenuView()
                        .environmentObject(iapManager)
                        .environmentObject(subscriptionTracker)
                }
        .padding(.top, 12)
    }
    
    private var subscriptionStatusBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(iapManager.isSubscribed ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            
            Text(iapManager.isSubscribed ? "Active" : "Not Subscribed")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(iapManager.isSubscribed ? .green : .red)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(
                    Capsule()
                        .fill(iapManager.isSubscribed ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                )
        }
    }
    
    private var subscribeButton: some View {
        Button(action: {
            showSubscriptionView = true
        }) {
            VStack(spacing: 6) {
                Text("Unlock Premium")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    premiumFeature(icon: "wand.and.stars", text: "AI Picks")
                    premiumFeature(icon: "xmark.octagon", text: "Ad-Free")
                    premiumFeature(icon: "sparkles", text: "Premium Tools")
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color("neonBlue"), Color("darkBlue")]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 5)
    }
    
    private func premiumFeature(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.9))
            
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color.white.opacity(0.2))
        .cornerRadius(12)
    }
    
    private var restoreButton: some View {
        Button(action: {
            iapManager.restorePurchases()
            print("🔄 Restore button tapped!")
        }) {
            HStack {
                Image(systemName: "arrow.clockwise.circle")
                    .font(.system(size: 14))
                Text("Restore Purchases")
                    .font(.system(size: 15, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundColor(.black)
            .background(
                RoundedRectangle(cornerRadius: 12).stroke(Color.blue, lineWidth: 0.5)
                    .fill(Color.white.opacity(0.85))
                    .shadow(color: Color.blue.opacity(0.2), radius: 2, x: 0, y: 5)
            )
        }
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        VStack(spacing: Constants.spacing) {
            sectionHeader(title: "About", icon: "info.circle.fill")
            
            VStack(spacing: 0) {
                infoRow(
                    title: "App Version",
                    value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
                    icon: "1.circle"
                )
                
                Divider()
                    .padding(.leading, 50)
                
                infoRow(
                    title: "Developer",
                    value: "JackpotAI Team",
                    icon: "person.fill"
                )
                
                Divider()
                    .padding(.leading, 50)
                
                infoRow(
                    title: "Last Updated",
                    value: "March 2025",
                    icon: "calendar"
                )
            }
            .background(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .fill(Material.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
        }
    }
    
    private func infoRow(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: Constants.iconSize))
                .foregroundColor(Color("neonBlue"))
                .frame(width: 30)
            
            Text(title)
                .font(.system(size: 16))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Legal Section
    private var legalSection: some View {
        VStack(spacing: Constants.spacing) {
            sectionHeader(title: "Legal", icon: "doc.text.fill")
            
            VStack(spacing: 0) {
                legalLink(
                    title: "Terms of Use",
                    icon: "doc.plaintext",
                    destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
                )
                
                Divider()
                    .padding(.leading, 50)
                
                legalLink(
                    title: "Privacy Policy",
                    icon: "hand.raised.fill",
                    destination: URL(string: "https://www.apple.com/legal/privacy/")!
                )
                
                Divider()
                    .padding(.leading, 50)
                
                legalLink(
                    title: "Contact Us",
                    icon: "envelope.fill",
                    destination: URL(string: "mailto:support@jackpotai.app")!
                )
            }
            .background(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .fill(Material.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
        }
    }
    
    private func legalLink(title: String, icon: String, destination: URL) -> some View {
        Link(destination: destination) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: Constants.iconSize))
                    .foregroundColor(Color("neonBlue"))
                    .frame(width: 30)
                
                Text(title)
                    .font(.system(size: 16))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Helper Views
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(Color("neonBlue"))
            
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color("darkBlue"))
            
            Spacer()
        }
        .padding(.leading, 8)
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
                .environmentObject(IAPManager.shared)
        }
        .previewDisplayName("Not Subscribed")
    }
}



// Safe Preview Helper
class MockIAPManager: ObservableObject {
    @Published var products: [SKProduct] = []
    @Published var isSubscribed: Bool = false
    @Published var isPurchasing: Bool = false
    
    func purchaseSubscription(productIdentifier: String? = nil) {
        print("Mock: Purchase subscription called")
    }
    
    func restorePurchases() {
        print("Mock: Restore purchases called")
    }
}
