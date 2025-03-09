//
//  GlowingEffect.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 3/3/25.
//
//import SwiftUI
//
///// A view modifier that applies a pulsing glow effect.
//struct GlowingEffect: ViewModifier {
//    @State private var glow = false
//
//    func body(content: Content) -> some View {
//        content
//            .shadow(color: Color("gold").opacity(glow ? 0.9 : 0.3), radius: glow ? 20 : 10)
//            .onAppear {
//                withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
//                    glow.toggle()
//                }
//            }
//    }
//}
//
//extension View {
//    func glowing() -> some View {
//        self.modifier(GlowingEffect())
//    }
//}
//
///// A view demonstrating the glowing effect on both text and an image with a transparent background.
//struct GlowingEffectView: View {
//    var body: some View {
//        VStack(spacing: 40) {
//            Text("Glowing Text")
//                .font(.largeTitle)
//                .padding()
//                .glowing()
//
//            Image(systemName: "sparkles")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 100, height: 100)
//                .foregroundColor(.yellow)
//                .glowing()
//        }
//        .padding()
//        .background(Color.clear)
//    }
//}
//
///// A container view that overlays GlowingEffectView on top of BackgroundView.
//struct GlowingEffectOverlayView: View {
//    var body: some View {
//        ZStack {
//            BackgroundView()  // Your custom background view
//            GlowingEffectView()
//        }
//    }
//}
//
//struct GlowingEffectOverlayView_Previews: PreviewProvider {
//    static var previews: some View {
//        GlowingEffectOverlayView()
//            .edgesIgnoringSafeArea(.all)
//    }
//}
