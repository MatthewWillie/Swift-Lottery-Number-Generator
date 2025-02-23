//
//  HomeView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/17/25.
//

import SwiftUI



enum ViewStates{
    //possible views
    case SwiftUIView
    case OnBoardView

}

//Create observableObject

class viewControl: ObservableObject{
    @Published var currentView: ViewStates = .OnBoardView
}

struct ControllerView: View {
    @StateObject var controller: viewControl
//    @StateObject var numberHold = NumberHold()

    
    var body: some View{
        
        switch controller.currentView{
            
        case .SwiftUIView:
            HomeView(controller: controller)
            
        case .OnBoardView:
            OnBoardView(controller: controller)
            
        }
    }
}





struct HomeView: View {
    @State var isButtonHidden = true
    @StateObject var controller: viewControl
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // Premium gradient background
//            LinearGradient(
//                gradient: Gradient(colors: [
//                    Color(hex: "#C1DAED").opacity(0.9), // Light sky blue (soft, premium)
//                    Color(hex: "#A8B5A2").opacity(0.8), // Muted sage green (elegant, grounding)
//                    Color(red: 0.05, green: 0.15, blue: 0.2).opacity(0.7) // Deep navy blue (rich, luxurious)
//                ]),
//                startPoint: .top,
//                endPoint: .bottom
//            )
//            .ignoresSafeArea()
            
//            // Existing semi-transparent background image
//            Color("darkGreen").ignoresSafeArea()
            
            Image("background")
                .resizable()
                .ignoresSafeArea()
//                .opacity(0.3)
                .overlay(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color("darkBlue").opacity(0.3), Color.clear]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
            
            // LogoView with existing positioning and opacity
            LogoView()
                .offset(y: -UIScreen.main.bounds.height / 3.7)
                .opacity(0.9)
            
            // Existing ZStack for BallDropButton
            ZStack {
                BallDropButton()
            }
        }
    }
}

// Extension to handle hex color conversion
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
