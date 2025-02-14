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
        self.action =  action
        self.content = content()
    }
    
    var body: some View {
        ZStack{
            Button(action: action){
                content
                ZStack {
                    Image("coin")
                        .resizable()
                        .scaledToFit()
                        .frame(width:  UIScreen.main.bounds.width/11, height:  UIScreen.main.bounds.width/11)
                        .shadow(color: .black .opacity(0.8), radius: 6, x: -2, y: 5)
                }
                
            }
            .offset(x: UIScreen.main.bounds.width/2.7, y: -UIScreen.main.bounds.height/2.5)
        }
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
            let buttonWidth = min(geometry.size.width, geometry.size.height) * 0.4 // Adjust based on smaller dimension
            
            Button(action: action) {
                VStack {
                    content
                    Image("button")
                        .resizable()
                        .scaledToFit()
                        .frame(width: buttonWidth)
                        .shadow(color: .black.opacity(0.7), radius: 10, x: 0, y: 10)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
        }
    }
}

