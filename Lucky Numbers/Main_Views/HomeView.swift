//
//  HomeView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 12/6/22.
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
        ZStack{
            Color("darkGreen").ignoresSafeArea()
            Image("background")
                .resizable()
                .ignoresSafeArea()
                .opacity(0.6)
            LogoView()
                .offset(y: -UIScreen.main.bounds.height/3.7).opacity(0.9)
            ZStack{
                BallDropButton()

            }
        }
    }
}

