//
//  BallDropPickerView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 3/1/25.
//

import SwiftUI

struct BallDropPickerView: View {
    @ObservedObject var userSettings: UserSettings
    @Binding var showSheet: Bool
    @Binding var isAddingItem: Bool
    @Binding var animationNum: Int

    var body: some View {
        Picker("Draw", selection: $userSettings.drawMethod) {
            Text("Lucky!").tag(UserSettings.numberType.Weighted)
            Text("Random").tag(UserSettings.numberType.Random)
            Text("Custom").tag(UserSettings.numberType.Custom)
            Text("EuroMillions").tag(UserSettings.numberType.EuroMillions)
        }
        .padding(.vertical, 3)
        .pickerStyle(SegmentedPickerStyle())
        .background(
            ZStack {
                Color.black.opacity(0.5)
                VStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color("gold").opacity(1),
                                                            Color("softGold").opacity(0.5)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1.3)
                        .blur(radius: 0.5)
                    Spacer()
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color("softGold").opacity(0.5),
                                                            Color("gold").opacity(1)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1.3)
                        .blur(radius: 0.5)
                }
            }
        )
        .padding(.vertical, 2)
        .onChange(of: userSettings.drawMethod) { newValue in
            if newValue == .Random {
                DispatchQueue.main.async {
                    animationNum = 1
                    isAddingItem = false
                }
            } else if newValue == .Weighted {
                DispatchQueue.main.async {
                    animationNum = 2
                    isAddingItem = false
                }
            } else if newValue == .Custom {
                DispatchQueue.main.async {
                    animationNum = 3
                    showSheet = true
                    isAddingItem = true
                }
            } else if newValue == .EuroMillions {
                // Handle navigation to EuroMillions if needed.
            }
        }
        .offset(y: UIScreen.main.bounds.height / 3.5)
    }
}
