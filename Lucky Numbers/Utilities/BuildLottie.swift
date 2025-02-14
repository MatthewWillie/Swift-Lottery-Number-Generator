//
//  BuildLottie.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 11/13/22.
//


import SwiftUI
import Lottie


// LottieView

struct LottieView: UIViewRepresentable {
    typealias UIViewType = UIView
    
//    let parent = HomeViewController()
    let filename: String
    let textProvider: AnimationTextProvider
    let animationView = LottieAnimationView()

    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)

        let animation = LottieAnimation.named(filename)
        animationView.animation = animation
        animationView.textProvider = textProvider
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
//        animationView.frame = parent.view.bounds
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
        ])

        return view
    }
    

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
        
            context.coordinator.parent.animationView.play()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: LottieView

        init(_ parent: LottieView) {
            self.parent = parent
        }
    }
}



class TextProvider: AnimationTextProvider {


    @State var fiveBalls: [Int]
    @State var dict: [String : String]

    init(fiveBalls: [Int]){
        self.fiveBalls = fiveBalls
        dict = ["ball_1" : String(fiveBalls[0]),
                    "ball_2" : String(fiveBalls[1]),
                    "ball_3" : String(fiveBalls[2]),
                    "ball_4" : String(fiveBalls[3]),
                    "ball_5" : String(fiveBalls[4]),
                "ball_6" : String(fiveBalls[5])] as [String : String]

//                    "ball_6" : String(Int.random(in: 1...26))] as [String : String]
    }

    func textFor(keypathName: String, sourceText: String) -> String {
        // Return the desire text based on key path
        // If not available, use the source text instead
        return dict[keypathName] ?? sourceText
    }
}



final class WordTextProvider: AnimationTextProvider {
    
    @State var fiveBalls: [String]
    @State var dict: [String : String]

    
    init(fiveBalls: [String]){
        self.fiveBalls = fiveBalls
        dict = ["ball_1" : fiveBalls[0],
                    "ball_2" : fiveBalls[1],
                    "ball_3" : fiveBalls[2],
                    "ball_4" : fiveBalls[3],
                    "ball_5" : fiveBalls[4],
                    "ball_6" : fiveBalls[5]] as [String : String]
    }
    

    func textFor(keypathName: String, sourceText: String) -> String {
        // Return the desire text based on key path
        // If not available, use the source text instead
        return dict[keypathName] ?? sourceText
    }
}


func randomText(random: [Int]) -> TextProvider {
        
    let textProvider : TextProvider = TextProvider(fiveBalls: random)
        
        return textProvider
}

    
func weightedText(weighted: [Int]) -> TextProvider {
        
    let textProvider : TextProvider = TextProvider(fiveBalls: weighted)
        
        return textProvider
    
}
