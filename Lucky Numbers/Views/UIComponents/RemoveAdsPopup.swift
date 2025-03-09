//
//  RemoveAdsPopup.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/17/25.
//

//import SwiftUI
//
///// A pop-up modal that prompts the user to remove ads.
//struct RemoveAdsPopup: View {
//    @Binding var isPresented: Bool  // Controls pop-up visibility
//    @ObservedObject var adManager = AdManager.shared
//
//    var body: some View {
//        ZStack {
//            Color.black.opacity(0.4) // Background blur
//                .edgesIgnoringSafeArea(.all)
//
//            VStack(spacing: 20) {
//                Text("Upgrade to Remove Ads")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .foregroundColor(.white)
//                
//                Text("Enjoy an ad-free experience forever!")
//                    .multilineTextAlignment(.center)
//                    .foregroundColor(.white)
//                
//                Image("RemoveAdsButton") // Your custom button image
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 200, height: 80)
//                    .onTapGesture {
//                        purchaseRemoveAds()
//                    }
//
//                Button(action: {
//                    isPresented = false
//                }) {
//                    Text("No Thanks")
//                        .foregroundColor(.white)
//                        .bold()
//                        .padding()
//                        .frame(width: 150)
//                        .background(Color.gray.opacity(0.5))
//                        .cornerRadius(10)
//                }
//            }
//            .padding()
//            .frame(width: 300)
//            .background(Color.green)
//            .cornerRadius(15)
//            .shadow(radius: 10)
//        }
//    }
//
//    /// Calls the IAPManager to handle the purchase
//    private func purchaseRemoveAds() {
//        IAPManager.shared.buyRemoveAds {
//            adManager.removeAds()
//            isPresented = false // Close popup after purchase
//        }
//    }
//}
//
