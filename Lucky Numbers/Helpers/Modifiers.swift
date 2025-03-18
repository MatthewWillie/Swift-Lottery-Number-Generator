//
//  Modifiers.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 12/6/22.
//

import SwiftUI

// UIKit-based VisualEffectBlur Wrapper
struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    var opacity: CGFloat  // Allows us to control transparency
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: blurStyle)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = opacity
        return blurView
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.alpha = opacity
    }
}

extension View {
    func premiumGlow(color: Color, radius: CGFloat = 10) -> some View {
        self.shadow(color: color.opacity(0.6), radius: radius)
            .shadow(color: color.opacity(0.4), radius: radius / 2)
    }
}

/// A view modifier that applies a pulsing glow effect.
struct GlowingEffect: ViewModifier {
    let glowColor: Color
    @State private var glow = false

    func body(content: Content) -> some View {
        content
            .shadow(color: glowColor.opacity(glow ? 0.9 : 0.3), radius: glow ? 20 : 10)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    glow.toggle()
                }
            }
    }
}

extension View {
    func glowing(with color: Color) -> some View {
        self.modifier(GlowingEffect(glowColor: color))
    }
}


struct PressActions: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        onPress()
                    })
                    .onEnded({ _ in
                        onRelease()
                    })
            )
    }
}



struct BackgroundClearView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view : UIView = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}



