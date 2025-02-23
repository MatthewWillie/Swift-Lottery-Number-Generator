//
//  BuildLottie.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/17/25.
//


import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    typealias UIViewType = UIView
    
    let onAnimationComplete: (() -> Void)?
    let filename: String
    let textProvider: AnimationTextProvider
    
    // LottieAnimationView is the underlying view
    let animationView = LottieAnimationView()

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        // Load the specified animation
        let animation = LottieAnimation.named(filename)
        animationView.animation = animation
        
        // Assign text provider for dynamic text in the animation
        animationView.textProvider = textProvider
        
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the animationView as a subview
        view.addSubview(animationView)
        
        // Pin the animationView to the parent UIView’s edges
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
        ])
        
        // Store the animationView in the coordinator for persistent access
        context.coordinator.animationView = animationView
        
        // Play the animation once during initial setup
        playAnimationIfNeeded(context: context)
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Only play the animation if it hasn’t played yet
        playAnimationIfNeeded(context: context)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func playAnimationIfNeeded(context: Context) {
        guard !context.coordinator.hasPlayed else { return }
        
        context.coordinator.animationView?.play { finished in
            if finished {
                context.coordinator.hasPlayed = true
                self.onAnimationComplete?()
            }
        }
    }

    class Coordinator: NSObject {
        var parent: LottieView
        var animationView: LottieAnimationView?
        var hasPlayed: Bool = false
        
        init(_ parent: LottieView) {
            self.parent = parent
        }
    }
}

/// Provides integer-based text (e.g., 1,2,3,4,5,6) for Lottie placeholders.
class TextProvider: AnimationTextProvider {
    @State var fiveBalls: [Int]
    @State var dict: [String : String]

    init(fiveBalls: [Int]) {
        self.fiveBalls = fiveBalls
        dict = [
            "ball_1": String(fiveBalls[0]),
            "ball_2": String(fiveBalls[1]),
            "ball_3": String(fiveBalls[2]),
            "ball_4": String(fiveBalls[3]),
            "ball_5": String(fiveBalls[4]),
            "ball_6": String(fiveBalls[5])
        ]
    }

    func textFor(keypathName: String, sourceText: String) -> String {
        dict[keypathName] ?? sourceText
    }
}

/// Provides string-based text (e.g., letters) for Lottie placeholders.
final class WordTextProvider: AnimationTextProvider {
    @State var fiveBalls: [String]
    @State var dict: [String : String]

    init(fiveBalls: [String]) {
        self.fiveBalls = fiveBalls
        dict = [
            "ball_1": fiveBalls[0],
            "ball_2": fiveBalls[1],
            "ball_3": fiveBalls[2],
            "ball_4": fiveBalls[3],
            "ball_5": fiveBalls[4],
            "ball_6": fiveBalls[5]
        ]
    }

    func textFor(keypathName: String, sourceText: String) -> String {
        dict[keypathName] ?? sourceText
    }
}

/// Helper for creating a TextProvider from an Int array
func randomText(random: [Int]) -> TextProvider {
    TextProvider(fiveBalls: random)
}

/// Helper for creating a TextProvider from an Int array (weighted)
func weightedText(weighted: [Int]) -> TextProvider {
    TextProvider(fiveBalls: weighted)
}
