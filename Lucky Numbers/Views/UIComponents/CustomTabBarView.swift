//
//  CustomTabBarView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/23/25.
//

import SwiftUI

// MARK: - Tab Enum
enum Tab {
    case home
    case results
    case settings
}

struct CurvedTabBarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Start from the bottom-left corner
        path.move(to: CGPoint(x: 0, y: rect.height))
        
        // Left side going up
        path.addLine(to: CGPoint(x: 0, y: 0))
        
        let midX = rect.width / 2
        let dipWidth: CGFloat = 160  // Adjust width of the dip
        let dipHeight: CGFloat = 50  // Adjust depth of the dip
        
        let dipStartX = midX - dipWidth / 2
        let dipEndX = midX + dipWidth / 2
        
        // Straight line up to dip start
        path.addLine(to: CGPoint(x: dipStartX, y: 0))
        
        // Smooth dip using a cubic Bézier curve
        path.addCurve(
            to: CGPoint(x: midX, y: dipHeight),
            control1: CGPoint(x: dipStartX + 50, y: 0),
            control2: CGPoint(x: midX - 45, y: dipHeight + 0)
        )
        
        path.addCurve(
            to: CGPoint(x: dipEndX, y: 0),
            control1: CGPoint(x: midX + 45, y: dipHeight + 0),
            control2: CGPoint(x: dipEndX - 50, y: 0)
        )
        
        // Continue to the right edge
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        
        // Close the path
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Stroke Shape for the Top Edge Only
struct CurvedTabBarTopStroke: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let midX = rect.width / 2
        let dipWidth: CGFloat = 160
        let dipHeight: CGFloat = 50

        let dipStartX = midX - dipWidth / 2
        let dipEndX = midX + dipWidth / 2

        // Start from the left edge
        path.move(to: CGPoint(x: 0, y: 0))

        // Line to the start of the dip
        path.addLine(to: CGPoint(x: dipStartX, y: 0))

        // Smooth dip curve
        path.addCurve(
            to: CGPoint(x: midX, y: dipHeight),
            control1: CGPoint(x: dipStartX + 50, y: 0),
            control2: CGPoint(x: midX - 45, y: dipHeight)
        )

        path.addCurve(
            to: CGPoint(x: dipEndX, y: 0),
            control1: CGPoint(x: midX + 45, y: dipHeight),
            control2: CGPoint(x: dipEndX - 50, y: 0)
        )

        // Line to the right edge
        path.addLine(to: CGPoint(x: rect.width, y: 0))

        return path
    }
}

// MARK: - Custom Curved Tab Bar View
struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    
    var body: some View {
        ZStack {
            // Curved background with a refined glassy gradient
            CurvedTabBarShape()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.9),
                            Color("darkBlue").opacity(0.7)
                        ]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .blur(radius: 5) // Slight blur for a premium soft-glass effect
                .shadow(color: .black.opacity(0.9), radius: 10, y: -5)

            // Subtle gold stroke on the top edge
            CurvedTabBarTopStroke()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color("gold"), Color("softGold").opacity(0.5)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1
                )
                .blur(radius: 0.2) // Softens the gold stroke for a polished look

            // Tab Bar Items
            HStack {
                // Left Button (Results)
                Button {
                    selectedTab = .results
                } label: {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(selectedTab == .results ? Color("neonBlue") : Color("lightGray").opacity(0.5))
                        .shadow(color: selectedTab == .results ? Color("neonBlue").opacity(0.6) : .clear, radius: 8)
                        .scaleEffect(selectedTab == .results ? 1.3 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: selectedTab)
                        .frame(maxWidth: .infinity)
                }
                
                // Center (Floating Home Button)
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.black.opacity(0.9),
                                    Color("darkBlue").opacity(0.7)
                                ]),
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .shadow(color: .black.opacity(0.9), radius: 5, y: -3)
                        .frame(width: 65, height: 65)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color("gold"), Color("softGold").opacity(0.5)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 1.3
                                )
                                .blur(radius: 0.5)
                        )
                        .shadow(color: .black.opacity(0.9), radius: 10, y: 4)
                        .offset(y: -25)


                    Image(systemName: "house.fill")
                        .foregroundColor(selectedTab == .home ? Color("neonBlue") : Color("lightGray").opacity(0.5))
                        .shadow(color: selectedTab == .home ? Color("neonBlue").opacity(0.6) : .clear, radius: 10)
                        .scaleEffect(selectedTab == .home ? 1.3 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: selectedTab)
                        .frame(width: 65, height: 65)
                        .offset(y: -25)

                }
                .onTapGesture {
                    selectedTab = .home
                }
                .frame(maxWidth: .infinity)
                
                // Right Button (Settings)
                Button {
                    selectedTab = .settings
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(selectedTab == .settings ? Color("neonBlue") : Color("lightGray").opacity(0.5))
                        .shadow(color: selectedTab == .settings ? Color("neonBlue").opacity(0.6) : .clear, radius: 8)
                        .scaleEffect(selectedTab == .settings ? 1.3 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: selectedTab)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40) // Space for bar height
        }
        .frame(height: 50) // Total height of the custom bar
    }
}

// MARK: - Preview
struct CustomTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color("darkGreen") // Custom background color
                .ignoresSafeArea()
            
            CustomTabBar(selectedTab: .constant(.home))
        }
        .previewLayout(.sizeThatFits)
    }
}
