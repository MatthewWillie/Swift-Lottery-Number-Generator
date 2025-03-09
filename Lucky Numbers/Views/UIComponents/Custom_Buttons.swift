//
//  Custom_Buttons.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 12/6/22.
//

import SwiftUI

struct CoinButton<MyView: View>: View {
    let action: () -> Void
    let content: MyView
    
    init(action: @escaping () -> Void, @ViewBuilder content: () -> MyView) {
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) { // Stack button and label with slight spacing
            ZStack {
                Button(action: action) {
                    content
                    ZStack {
                        Image("coin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIScreen.main.bounds.width / 8.5, height: UIScreen.main.bounds.width / 8.5)
                            .shadow(color: Color("neonBlue").opacity(0.7), radius: 5, x: 1, y: 2)
                            .shadow(color: Color("black").opacity(0.7), radius: 8, x: 3, y: 12)
                    }
                }
            }
            
            // Label Below the Button
            Text("My Picks")
                .font(.system(size: 11))
                .foregroundColor(Color("gold"))
                .shadow(color: Color("black").opacity(0.7), radius: 4, x: 2, y: 4)
        }
        .offset(x: UIScreen.main.bounds.width / 3.3, y: -UIScreen.main.bounds.height / -5.5)
    }
}


//  Button used for BallDrop-----------------------------------

//struct MyButton<MyView: View>: View {
//    
//    @State var isPressed : Bool = false
//    @State var toggleValue : Bool = false
//    
//    let action: () -> Void
//    let content: MyView
//    
//    init(action: @escaping () -> Void, @ViewBuilder content: () -> MyView) {
//        self.action =  action
//        self.content = content()
//    }
//    
//    var body: some View {
//        Button(action: action){
//            content
//            Image("button")
//                .resizable()
//                .scaledToFit()
//                .frame(width: UIScreen.main.bounds.width/2.3)
//                .shadow(color: .black .opacity(0.7), radius: 10, x: 0, y: 10)
//
//        }
//    }
//}

struct MyButton<MyView: View>: View {
    
    @State var isPressed: Bool = false
    @State var toggleValue: Bool = false
    
    let action: () -> Void
    let content: MyView
    
    init(action: @escaping () -> Void, @ViewBuilder content: () -> MyView) {
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            let buttonWidth = min(geometry.size.width, geometry.size.height) * 0.3 // Adjust based on smaller dimension
            
            Button(action: action) {
                VStack {
                    content
                    Image("button")
                        .resizable()
                        .scaledToFit()
                        .frame(width: buttonWidth)
                        .shadow(color: Color("neonBlue").opacity(0.7), radius: 5, x: 1, y: 2)
                        .shadow(color: Color("black").opacity(0.7), radius: 12, x: 3, y: 12)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
        }
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

#Preview {
    CoinView(
        savedArray: .constant([
            CoinListItem(lottoNumbers: "5 - 12 - 23 - 34 - 56 | 9"),
            CoinListItem(lottoNumbers: "7 - 14 - 21 - 28 - 35 | 10"),
            CoinListItem(lottoNumbers: "3 - 11 - 18 - 26 - 39 | 15")
        ])
    )
    .environmentObject(NumberHold())
    .background(Color("darkBlue").ignoresSafeArea())
}

