//
//  ContentView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 11/13/22.
//

import SwiftUI
import Lottie

struct ContentView: View {
    @EnvironmentObject private var launchScreenState: LaunchScreenStateManager
    
    var body: some View {
        
        
        VStack {
              ControllerView(controller: viewControl())

          }
          .task {
              try? await Task.sleep(for: Duration.seconds(1.2))
              self.launchScreenState.dismiss()
          }
    }
}




struct LaunchScreenView: View {
    @EnvironmentObject private var launchScreenState: LaunchScreenStateManager // Mark 1

    var textProvider = TextProvider(fiveBalls: [0,0,0,0,0,0])

    @State private var firstAnimation = false  // Mark 2
    @State private var secondAnimation = false // Mark 2
    @State private var startFadeoutAnimation = false // Mark 2
    
    @ViewBuilder
    private var image: some View {  // Mark 3
        
        LottieView(filename: "Luckies_Logo", textProvider: textProvider)
        
    }
    
    @ViewBuilder
    private var backgroundColor: some View {
        Image("backgroundMix")
            .resizable()
            .ignoresSafeArea()
    }
    
    private let animationTimer = Timer // Mark 5
        .publish(every: 0.5, on: .current, in: .common)
        .autoconnect()
    
    var body: some View {
        ZStack {
            backgroundColor  // Mark 3
            image  // Mark 3
        }.onReceive(animationTimer) { timerValue in
            updateAnimation()  // Mark 5
        }.opacity(startFadeoutAnimation ? 0 : 1)
    }
    
    private func updateAnimation() { // Mark 5
        switch launchScreenState.state {
        case .firstStep:
            withAnimation(.easeInOut(duration: 0.9)) {
                firstAnimation.toggle()
            }
        case .secondStep:
            if secondAnimation == false {
                withAnimation(.linear) {
                    self.secondAnimation = true
                    startFadeoutAnimation = true
                }
            }
        case .finished:
            // use this case to finish any work needed
            break
        }
    }
    
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LaunchScreenStateManager())

    }
}
