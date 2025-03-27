//
//  InfoButtonView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 12/6/22.
//

import SwiftUI

struct InfoButton: View {
    // MARK: - Properties
    @State private var showInfoSheet = false
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Constants
    private struct Constants {
        static let buttonHeight: CGFloat = 44
        static let cornerRadius: CGFloat = 22  // Rounded capsule
        static let glowRadius: CGFloat = 4
        static let offsetRatio: CGFloat = 3.3  // Screen height division
    }
    
    // MARK: - Body
    var body: some View {
        Button(action: { showInfoSheet = true }) {
            HStack(spacing: 8) {
                Text("How It Works")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("darkBlue"))
                
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color("neonBlue"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(.white.opacity(0.85))
                    .overlay(
                        Capsule()
                            .strokeBorder(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("gold").opacity(0.6), Color("softGold").opacity(0.3)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color("neonBlue").opacity(0.2), radius: Constants.glowRadius, x: 0, y: 2)
            )
        }
        .offset(y: UIScreen.main.bounds.height / Constants.offsetRatio)
        .sheet(isPresented: $showInfoSheet) {
            InfoSheetView(isPresented: $showInfoSheet)
        }
    }
}

// MARK: - Info Sheet View
struct InfoSheetView: View {
    // MARK: - Properties
    @Binding var isPresented: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Constants
    private struct Constants {
        static let cornerRadius: CGFloat = 16
        static let bannerHeight: CGFloat = 150
        static let contentSpacing: CGFloat = 20
        static let innerCornerRadius: CGFloat = 12
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background
            backgroundView
            
            // Content
            VStack(spacing: 0) {
                // Banner
                BannerView()
                
                // Content
                ScrollView {
                    VStack(spacing: Constants.contentSpacing) {
                        introSection
                        premiumSection
                        freeSection
                        conclusionSection
                        disclaimerSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            
            // Close Button
            VStack {
                Spacer()
                closeButton
                    .padding(.bottom, 30)
            }
        }
        .preferredColorScheme(.light)
    }
    
    // MARK: - Background
    private var backgroundView: some View {
        ZStack {
            // Base blur layer
            Rectangle()
                .fill(Material.thin)
                .ignoresSafeArea()
            
            // Gradient overlay for depth
            LinearGradient(
                colors: [
                    Color.white.opacity(0.3),
                    Color("lightBlue").opacity(0.3),
                    Color("darkBlue").opacity(0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Light patterns/shapes for glass effect
            decorativeElements
        }
    }
    
    // MARK: - Decorative Elements
    private var decorativeElements: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.1))
                .frame(width: 200, height: 200)
                .blur(radius: 15)
                .offset(x: -100, y: -200)
            
            Circle()
                .fill(Color("neonBlue").opacity(0.1))
                .frame(width: 300, height: 300)
                .blur(radius: 20)
                .offset(x: 150, y: 200)
                
            Circle()
                .fill(Color("lightBlue").opacity(0.07))
                .frame(width: 250, height: 250)
                .blur(radius: 25)
                .offset(x: 150, y: -250)
        }
    }
    
    // MARK: - Close Button
    private var closeButton: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            isPresented = false
        }) {
            // Glassmorphic button
            Text("Done")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 12)
                .background(
                    ZStack {
                        // Button layers
                        Capsule()
                            .fill(Material.ultraThinMaterial)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("darkBlue").opacity(0.9), Color("neonBlue").opacity(0.7)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .overlay(
                                Capsule()
                                    .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        
                        // Shine effect
                        Capsule()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .white.opacity(0.5),
                                        .white.opacity(0.2),
                                        .white.opacity(0.0)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 25)
                            .offset(y: -10)
                            .mask(Capsule())
                    }
                )
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                .shadow(color: Color("neonBlue").opacity(0.3), radius: 15, x: 0, y: 8)
        }
    }
    
    // MARK: - Content Sections
    
    private var introSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "gearshape.2.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color("neonBlue"))
                
                Text("JackpotAI")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color("darkBlue"))
            }
            
            Text("JackpotAI is your ultimate AI-powered lottery companion, built to help you make smarter number selections using cutting-edge data analysis.")
                .font(.body)
                .foregroundColor(Color("darkBlue"))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 5)
        .background(
            glassPanel()
        )
    }
    
    private var premiumSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "AI Mode (Premium)", systemImage: "sparkles")
            
            FeatureItem(
                title: "Advanced Game-Specific Predictions",
                description: "JackpotAI's AI Mode deeply analyzes each individual lottery game to identify the numbers with the highest probability of being drawn."
            )
            
            FeatureList(items: [
                "Uses machine learning and historical data to detect hot numbers, cold numbers, and overdue trends",
                "Every AI-generated set is tailored to that game's unique draw history",
                "The most advanced lottery prediction model available for serious players"
            ])
        }
        .padding(.vertical, 10)
    }
    
    private var freeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Free Mode", systemImage: "dice")
            
            FeatureItem(
                title: "Smart Weighted Picks",
                description: "A great starting point! Free Mode blends historical lottery data with randomness for a balanced number selection."
            )
            
            FeatureList(items: [
                "Tracks frequently drawn numbers across multiple games and weights them",
                "Ensures your numbers reflect real-world trends rather than pure randomness"
            ])
        }
        .padding(.vertical, 10)
    }
    
    private var conclusionSection: some View {
        VStack(spacing: 12) {
            Text("Your Jackpot Starts Here!")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color("darkBlue"))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            
            Text("Ready to improve your lottery strategy? Try JackpotAI and let data work in your favor.")
                .font(.body)
                .foregroundColor(Color("darkBlue"))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 10)
        .background(
            glassPanel(opacity: 0.3)
        )
    }
    
    private var disclaimerSection: some View {
        VStack(spacing: 8) {
            Text("Disclaimer")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(Color("darkBlue"))
                .padding(.top, 5)
            
            Text("JackpotAI is a fun and educational tool designed to enhance your lottery experience. While we analyze real historical data to generate numbers, we cannot guarantee winnings (we wish we could!). Play responsibly, and remember—every number has an equal chance of winning, no matter what the AI says! 🎲🍀")
                .font(.footnote)
                .italic()
                .multilineTextAlignment(.center)
                .foregroundColor(Color("darkBlue").opacity(0.7))
                .padding(.horizontal)
        }
        .padding()
        .background(
            glassPanel(opacity: 0.2)
        )
    }
    
    // Helper method to create consistent glass panels
    private func glassPanel(opacity: Double = 0.2) -> some View {
        RoundedRectangle(cornerRadius: Constants.innerCornerRadius)
            .fill(Material.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.innerCornerRadius)
                    .fill(Color("lightBlue").opacity(opacity))
                    .blendMode(.overlay)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Constants.innerCornerRadius)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.5), Color.white.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
    }
}

// MARK: - Banner View
struct BannerView: View {
    var body: some View {
        ZStack {
            // Banner background
            ZStack {
                // Base
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color("darkBlue").opacity(0.8), Color("darkBlue").opacity(0.6)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Rectangle()
                            .strokeBorder(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("gold").opacity(0.8), Color("softGold").opacity(0.4)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                
                // Gradient overlay
                LinearGradient(
                    gradient: Gradient(colors: [Color("darkBlue").opacity(0.7), Color("neonBlue").opacity(0.6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .blendMode(.overlay)
                
                // Subtle patterns
                HStack(spacing: 0) {
                    ForEach(0..<5) { i in
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .blur(radius: 12)
                            .offset(x: CGFloat(i * 20 - 40), y: CGFloat(i % 2 == 0 ? 40 : -20))
                    }
                }
                .mask(Rectangle())
            }
            .frame(height: 150)
            
            // Shimmering effect overlay
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, Color("neonBlue").opacity(0.5), .clear]),
                        startPoint: UnitPoint(x: -1, y: 0.5),
                        endPoint: UnitPoint(x: 2, y: 0.5)
                    )
                )
                .frame(height: 150)
                .mask(Rectangle())
                .blur(radius: 5)
            
            // Icon with glow
            ZStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 72))
                    .foregroundColor(.white.opacity(0.3))
                    .blur(radius: 2)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 70))
                    .foregroundColor(.white.opacity(0.7))
            }
            .offset(x: -100, y: 0)
            
            // Title
            VStack {
                Text("How It Works")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                
                Text("Discover JackpotAI's Features")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.9))
            }
            .offset(x: 40)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 5)
        .padding(.horizontal)
        .padding(.top)
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .font(.system(size: 20))
                .foregroundColor(Color("neonBlue"))
                .frame(width: 30)
            
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color("darkBlue"))
        }
        .padding(.vertical, 5)
    }
}

// MARK: - Feature Item
struct FeatureItem: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color("darkBlue"))
            
            Text(description)
                .font(.body)
                .foregroundColor(Color("darkBlue").opacity(0.7))
        }
        .padding(.leading, 30)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Material.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("lightBlue").opacity(0.2))
                        .blendMode(.overlay)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.6), Color.white.opacity(0.1)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                )
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Feature List
struct FeatureList: View {
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color("neonBlue"))
                        .font(.system(size: 14))
                    
                    Text(item)
                        .font(.callout)
                        .foregroundColor(Color("darkBlue").opacity(0.7))
                }
                .padding(.leading, 30)
            }
        }
    }
}

// MARK: - Preview
struct InfoButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.opacity(0.2).ignoresSafeArea()
            InfoButton()
        }
    }
}
