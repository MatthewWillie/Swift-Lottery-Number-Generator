//
//  BallDropAnimationView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 3/1/25.
//

//import SwiftUI
//
//struct BallDropAnimationView: View {
//    @EnvironmentObject var animationState: BallDropAnimationState
//    @EnvironmentObject var userSettings: UserSettings
//    @EnvironmentObject var numberHold: NumberHold
//    
//    var customNumbers: [Int]
//    @Binding var savedText: [String]
//    
//    var body: some View {
//        ZStack {
//            if animationState.firstClick == 0 && animationState.num == 0 {
////                LoadBalls()
//            } else {
//                BallDropView(
//                    textProvider: TextProvider(fiveBalls: customNumbers),
//                    onAnimationComplete: {}
//                )
//            }
//        }
//    
//
//
//        .onChange(of: animationState.firstClick) { _ in
//            withAnimation {
//                animationState.toggle.toggle()
//            }
//        }
//    }
//
//    /// Determines the correct text provider based on user settings and animation state.
//    private func getTextProvider() -> AnimationTextProvider {
//        switch userSettings.drawMethod {
//        case .Weighted:
//            return weightedText(weighted: numberHold.weightedArray)
//        case .Random:
//            return (animationState.num == 1
//                ? WordTextProvider(fiveBalls: ["R","A","N","D","O","M"])
//                : randomText(random: numberHold.randomArray))
//        case .Custom:
//            return TextProvider(fiveBalls: customNumbers)
//        default:
//            return TextProvider(fiveBalls: [0, 0, 0, 0, 0, 0])
//        }
//    }
//
//    /// Handles ad display after the animation completes.
//    private func showAdAfterAnimation() {
//        if let rootVC = UIApplication.shared.connectedScenes
//            .compactMap({ $0 as? UIWindowScene })
//            .first?.windows.first?.rootViewController {
//            AdManager.shared.trackButtonPress(from: rootVC)
//        }
//    }
//}
//
//// ✅ **Preview Provider for `BallDropAnimationView`**
//struct BallDropAnimationView_Previews: PreviewProvider {
//    @State static var previewSavedText: [String] = []
//    static var previews: some View {
//        BallDropAnimationView(customNumbers: [], savedText: $previewSavedText)
//            .environmentObject(BallDropAnimationState())
//            .environmentObject(UserSettings(drawMethod: .Weighted))
//            .environmentObject(NumberHold())
//    }
//}
