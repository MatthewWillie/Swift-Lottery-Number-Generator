////
////  TabBarPreview.swift
////  Lucky Numbers
////
////  Created by Matt Willie on 2/23/25.
////
//
//import SwiftUI
//
//// MARK: - 1) Define an Enum for Tabs
//enum Tab {
//    case home
//    case notifications
//    case cart
//}
//
//// MARK: - 2) A Curved Shape for the Tab Bar
//struct CurvedTabBarShape: Shape {
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        
//        // Start from the bottom-left corner
//        path.move(to: CGPoint(x: 0, y: rect.height))
//        
//        // Left side going up
//        path.addLine(to: CGPoint(x: 0, y: 0))
//        
//        let midX = rect.width / 2
//        let dipWidth: CGFloat = 160  // Adjust width of the dip
//        let dipHeight: CGFloat = 50 // Adjust depth of the dip
//        
//        let dipStartX = midX - dipWidth / 2
//        let dipEndX = midX + dipWidth / 2
//        
//        // Straight line up to dip start
//        path.addLine(to: CGPoint(x: dipStartX, y: 0))
//        
//        // Smooth dip using a cubic Bézier curve
//        path.addCurve(
//            to: CGPoint(x: midX, y: dipHeight), // Bottom of dip
//            control1: CGPoint(x: dipStartX + 50, y: 0), // Adjust control for smoother curve
//            control2: CGPoint(x: midX - 45, y: dipHeight + 0)
//        )
//        
//        path.addCurve(
//            to: CGPoint(x: dipEndX, y: 0),
//            control1: CGPoint(x: midX + 45, y: dipHeight + 0),
//            control2: CGPoint(x: dipEndX - 50, y: 0)
//        )
//        
//        // Continue to the right edge
//        path.addLine(to: CGPoint(x: rect.width, y: 0))
//        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
//        
//        // Close the path
//        path.closeSubpath()
//        
//        return path
//    }
//}
//
//
//// MARK: - 3) The Custom Curved Tab Bar View
//struct CustomTabBar: View {
//    @Binding var selectedTab: Tab
//    
//    var body: some View {
//        ZStack {
//            // The curved background
//            CurvedTabBarShape()
//                .fill(Color(.systemGray6))
//                .shadow(color: .black.opacity(0.15), radius: 5, y: -5)
//            
//            // The tab items (left, center, right)
//            HStack {
//                // Left button
//                Button {
//                    selectedTab = .notifications
//                } label: {
//                    Image(systemName: "bell.fill")
//                        .foregroundColor(selectedTab == .notifications ? .blue : .gray)
//                        .frame(maxWidth: .infinity)
//                }
//                
//                // Center (floating) button
//                ZStack {
//                    Circle()
//                        .fill(Color.black)
//                        .frame(width: 60, height: 60)
//                        .offset(y: -20) // Float above the bar
//                        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
//                    
//                    Image(systemName: "house.fill")
//                        .foregroundColor(selectedTab == .home ? .blue : .white)
//                        .frame(width: 60, height: 60)
//                        .offset(y: -20)
//                }
//                .onTapGesture {
//                    selectedTab = .home
//                }
//                .frame(maxWidth: .infinity)
//                
//                // Right button
//                Button {
//                    selectedTab = .cart
//                } label: {
//                    Image(systemName: "cart.fill")
//                        .foregroundColor(selectedTab == .cart ? .blue : .gray)
//                        .frame(maxWidth: .infinity)
//                }
//            }
//            .padding(.horizontal, 20)
//            .padding(.bottom, 20) // space for bar height
//        }
//        .frame(height: 50) // total height of the custom bar
//    }
//}
//
//// MARK: - 4) ContentView That Uses the Custom Tab Bar
//struct ContentView2: View {
//    @State private var selectedTab: Tab = .home
//    
//    var body: some View {
//        ZStack {
//            // Switch “pages” based on which tab is selected
//            switch selectedTab {
//            case .home:
//                HomeView2()
//            case .notifications:
//                NotificationsView()
//            case .cart:
//                CartView()
//            }
//            
//            // Custom curved tab bar anchored to the bottom
//            VStack {
//                Spacer()
//                CustomTabBar(selectedTab: $selectedTab)
//            }
//            .edgesIgnoringSafeArea(.bottom)
//        }
//    }
//}
//
//// MARK: - 5) Placeholder Views for Each Tab
//struct HomeView2: View {
//    var body: some View {
//        ZStack {
//            Color.blue.opacity(0.2).edgesIgnoringSafeArea(.all)
//            Text("Home View")
//                .font(.largeTitle)
//                .foregroundColor(.blue)
//        }
//    }
//}
//
//struct NotificationsView: View {
//    var body: some View {
//        ZStack {
//            Color.red.opacity(0.2).edgesIgnoringSafeArea(.all)
//            Text("Notifications View")
//                .font(.largeTitle)
//                .foregroundColor(.red)
//        }
//    }
//}
//
//struct CartView: View {
//    var body: some View {
//        ZStack {
//            Color.green.opacity(0.2).edgesIgnoringSafeArea(.all)
//            Text("Cart View")
//                .font(.largeTitle)
//                .foregroundColor(.green)
//        }
//    }
//}
//
//// MARK: - 6) Preview
//struct ContentView2_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView2()
//    }
//}
