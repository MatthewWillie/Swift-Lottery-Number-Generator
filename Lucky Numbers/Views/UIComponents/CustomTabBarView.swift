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

// MARK: - Constants
private struct TabBarConstants {
    static let height: CGFloat = 70
    static let dipWidth: CGFloat = 160
    static let dipHeight: CGFloat = 50
    static let padding: CGFloat = 20
    static let floatingButtonSize: CGFloat = 65
    static let floatingButtonOffset: CGFloat = 25
    static let lineWidth: CGFloat = 1
    static let iconScale: CGFloat = 1.3
    static let animationDuration: Double = 0.2
}

// MARK: - Shape Definitions
struct CurvedTabBarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let midX = rect.width / 2
        let dipWidth = TabBarConstants.dipWidth
        let dipHeight = TabBarConstants.dipHeight
        
        let dipStartX = midX - dipWidth / 2
        let dipEndX = midX + dipWidth / 2
        
        // Start from the bottom-left corner
        path.move(to: CGPoint(x: 0, y: rect.height))
        
        // Left side going up
        path.addLine(to: CGPoint(x: 0, y: 0))
        
        // Straight line up to dip start
        path.addLine(to: CGPoint(x: dipStartX, y: 0))
        
        // Smooth dip using a cubic Bézier curve
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
        
        // Continue to the right edge
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        
        // Close the path
        path.closeSubpath()
        
        return path
    }
}

struct CurvedTabBarTopStroke: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let midX = rect.width / 2
        let dipWidth = TabBarConstants.dipWidth
        let dipHeight = TabBarConstants.dipHeight

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

// MARK: - Custom Tab Bar View
struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Custom Colors
    private var tabBarBackground: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                .black.opacity(0.9),
                Color("darkBlue").opacity(0.7)
            ]),
            startPoint: .bottom,
            endPoint: .top
        )
    }
    
    private var borderGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color("gold").opacity(0.8),
                Color("softGold").opacity(0.4)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Shape
                tabBarBackground(geometry: geometry)
                
                // Tab Items
                tabButtons(geometry: geometry)
            }
            .frame(height: TabBarConstants.height)
            .edgesIgnoringSafeArea(.bottom)
        }
        .frame(height: TabBarConstants.height)
    }
    
    // MARK: - Component Methods
    private func tabBarBackground(geometry: GeometryProxy) -> some View {
        ZStack {
            // Main background with gradient
            CurvedTabBarShape()
                .fill(tabBarBackground)
                .blur(radius: 0.5)
                .shadow(color: .black.opacity(0.5), radius: 8, y: -3)
            
            // Subtle top edge highlight
            CurvedTabBarTopStroke()
                .stroke(borderGradient, lineWidth: TabBarConstants.lineWidth)
                .blur(radius: 0.2)
        }
    }
    
    private func tabButtons(geometry: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            // Results Tab
            tabButton(
                tab: .results,
                icon: "chart.bar.fill",
                geometry: geometry
            )
            
            // Home Tab (Floating Center Button)
            floatingHomeButton(geometry: geometry)
            
            // Settings Tab
            tabButton(
                tab: .settings,
                icon: "gearshape.fill",
                geometry: geometry
            )
        }
        .padding(.horizontal, TabBarConstants.padding)
        .padding(.bottom, 40) // Extra space for taller curved area
    }
    
    private func tabButton(tab: Tab, icon: String, geometry: GeometryProxy) -> some View {
        Button {
            withAnimation(.easeInOut(duration: TabBarConstants.animationDuration)) {
                selectedTab = tab
            }
        } label: {
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 22, height: 22)
                .foregroundColor(selectedTab == tab ? Color("neonBlue") : .white.opacity(0.5))
                .shadow(color: selectedTab == tab ? Color("neonBlue").opacity(0.6) : .clear, radius: 8)
                .scaleEffect(selectedTab == tab ? TabBarConstants.iconScale : 1.0)
                .animation(.easeInOut(duration: TabBarConstants.animationDuration), value: selectedTab)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(TabButtonStyle())
    }
    
    private func floatingHomeButton(geometry: GeometryProxy) -> some View {
        ZStack {
            // Button Background
            Circle()
                .fill(tabBarBackground)
                .shadow(color: .black.opacity(0.5), radius: 5, y: -2)
                .frame(width: TabBarConstants.floatingButtonSize, height: TabBarConstants.floatingButtonSize)
                .overlay(
                    Circle()
                        .stroke(borderGradient, lineWidth: TabBarConstants.lineWidth)
                )
                .offset(y: -TabBarConstants.floatingButtonOffset)
            
            // Button Icon
            Image(systemName: "house.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundColor(selectedTab == .home ? Color("neonBlue") : .white.opacity(0.5))
                .shadow(color: selectedTab == .home ? Color("neonBlue").opacity(0.6) : .clear, radius: 8)
                .scaleEffect(selectedTab == .home ? TabBarConstants.iconScale : 1.0)
                .animation(.easeInOut(duration: TabBarConstants.animationDuration), value: selectedTab)
                .offset(y: -TabBarConstants.floatingButtonOffset)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: TabBarConstants.animationDuration)) {
                selectedTab = .home
            }
        }
    }
}


// MARK: - Button Style
struct TabButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview
struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ZStack {
                Color("lightBlue").ignoresSafeArea()
                VStack {
                    Spacer()
                    CustomTabBar(selectedTab: .constant(.home))
                }
            }
            .previewDisplayName("Light Mode")
            
            ZStack {
                Color.black.ignoresSafeArea()
                VStack {
                    Spacer()
                    CustomTabBar(selectedTab: .constant(.results))
                }
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
            
            ZStack {
                Color("lightBlue").ignoresSafeArea()
                VStack {
                    Spacer()
                    CustomTabBar(selectedTab: .constant(.settings))
                }
            }
            .previewLayout(.fixed(width: 375, height: 100))
            .previewDisplayName("iPhone SE")
        }
    }
}
