//
//  BallDropButton.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/17/25.
//
//import SwiftUI
//import Combine
//
//struct LogoView: View {
//    var body: some View {
//        ZStack(alignment: .center) {
//            Image("Luckies_Logo")
//                .resizable()
//                .scaledToFit()
//                .frame(width: UIScreen.main.bounds.width,
//                       height: UIScreen.main.bounds.height / 3)
//                .opacity(1)
//        }
//    }
//}
//
//// MARK: - BallDrop
//struct BallDrop: View {
//    var onAnimationComplete: (() -> Void)? = nil
//    let textProvider: TextProvider
//
//    var body: some View {
//        ZStack {
//            LottieView(
//                onAnimationComplete: onAnimationComplete,
//                filename: "ball_drop",
//                textProvider: textProvider
//            )
//            .shadow(radius: 10, x: -5, y: 20)
//        }
//        .frame(width: UIScreen.main.bounds.width,
//               height: UIScreen.main.bounds.height / 2,
//               alignment: .center)
//        .offset(y: -UIScreen.main.bounds.height / 7)
//    }
//}
//
//// MARK: - BallDropAlt
//struct BallDropAlt: View {
//    var onAnimationComplete: (() -> Void)? = nil
//    let textProvider: WordTextProvider
//
//    var body: some View {
//        ZStack {
//            LottieView(
//                onAnimationComplete: onAnimationComplete,
//                filename: "ball_drop",
//                textProvider: textProvider
//            )
//            .shadow(radius: 10, x: -5, y: 20)
//        }
//        .frame(width: UIScreen.main.bounds.width,
//               height: UIScreen.main.bounds.height / 2,
//               alignment: .center)
//        .offset(y: -UIScreen.main.bounds.height / 7)
//    }
//}
//
//// MARK: - LoadBalls
//struct LoadBalls: View {
//    @State var toggle: Bool = false
//    let textProvider: TextProvider = TextProvider(fiveBalls: [1,1,1,1,1,1])
//
//    var body: some View {
//        ZStack {
//            LottieView(
//                onAnimationComplete: nil,
//                filename: "load_balls",
//                textProvider: textProvider
//            )
//            .shadow(radius: 10, x: -5, y: 20)
//        }
//        .frame(width: UIScreen.main.bounds.width,
//               height: UIScreen.main.bounds.height / 2,
//               alignment: .center)
//        .offset(y: -UIScreen.main.bounds.height / 7)
//    }
//}
//
//// MARK: - BallDropButton
//struct BallDropButton: View {
//    // Use the shared animation state injected from above.
//    @EnvironmentObject var animationState: BallDropAnimationState
//    @EnvironmentObject private var userSettings: UserSettings
//    @EnvironmentObject var numberHold: NumberHold
//    @EnvironmentObject var customRandoms: CustomRandoms
//
//    // Other local states remain as needed.
//    @State var isButtonHidden: Bool = false
//    @State var isPressed: Bool = false
//    @State private var showSheet = false
//
//    @State var coinPressed: Bool = false
//    @State var donePressed: Bool = false
//
//    @State var savedArray: [CoinListItem] = []
//    @State var savedText: [String] = []
////    @State var toSparkle = true
//
//    @State private var customArray = [Int]()
//    @State var custom = [Int]()
//    @State var stringNum: String = ""
//    @State private var itemToAdd: String = ""
//    @State private var isAddingItem: Bool = false
//    @State private var navigateToEuroMillions = false
//
//    let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
//    
//    // Control whether the button is disabled.
//    @State private var isButtonDisabled = false
//
//    init() {
//        // Customize UISegmentedControl appearance.
//        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.white)
//        UISegmentedControl.appearance().setTitleTextAttributes(
//            [
//                .font: UIFont.boldSystemFont(ofSize: 16),
//                .foregroundColor: UIColor.black
//            ],
//            for: .selected
//        )
//        UISegmentedControl.appearance().setTitleTextAttributes(
//            [
//                .font: UIFont.boldSystemFont(ofSize: 14),
//                .foregroundColor: UIColor.white
//            ],
//            for: .normal
//        )
//    }
//    
//    func update() {
//        animationState.toggle.toggle()
//    }
//    
//    var body: some View {
//        ZStack {
//            // Choose the animation based on the shared state.
//            if animationState.firstClick == 0 && animationState.num == 0 {
//                LoadBalls()
//            }
//            else if userSettings.drawMethod.rawValue == "Weighted" && animationState.num == 2 {
//                BallDropAlt(
//                    onAnimationComplete: { showAdAfterAnimation() },
//                    textProvider: WordTextProvider(fiveBalls: ["L","U","C","K","Y","!"])
//                )
//            }
//            else if userSettings.drawMethod.rawValue == "Weighted" && animationState.firstClick == 1 {
//                BallDrop(
//                    onAnimationComplete: { showAdAfterAnimation() },
//                    textProvider: weightedText(weighted: numberHold.weightedArray)
//                )
//            }
//            else if userSettings.drawMethod.rawValue == "Weighted" && animationState.firstClick > 1 && animationState.num == 7 {
//                BallDrop(
//                    onAnimationComplete: { showAdAfterAnimation() },
//                    textProvider: weightedText(weighted: numberHold.weightedArray)
//                )
//            }
//            else if userSettings.drawMethod.rawValue == "Weighted" && animationState.toggle && animationState.firstClick > 1 {
//                MoveView(firstClick: Binding(get: { animationState.firstClick }, set: { animationState.firstClick = $0 }),
//                         savedText: $savedText)
//                BallDrop(
//                    onAnimationComplete: { showAdAfterAnimation() },
//                    textProvider: weightedText(weighted: numberHold.weightedArray)
//                )
//            }
//            else if userSettings.drawMethod.rawValue == "Weighted" && !animationState.toggle && animationState.firstClick > 1 {
//                MoveView(firstClick: Binding(get: { animationState.firstClick }, set: { animationState.firstClick = $0 }),
//                         savedText: $savedText)
//                BallDrop(
//                    onAnimationComplete: { showAdAfterAnimation() },
//                    textProvider: weightedText(weighted: numberHold.weightedArray)
//                )
//            }
//            else if userSettings.drawMethod.rawValue == "Random" && animationState.num == 1 {
//                BallDropAlt(
//                    onAnimationComplete: { showAdAfterAnimation() },
//                    textProvider: WordTextProvider(fiveBalls: ["R","A","N","D","O","M"])
//                )
//            }
//            else if userSettings.drawMethod.rawValue == "Random" && animationState.num == 6 {
//                BallDrop(
//                    onAnimationComplete: { showAdAfterAnimation() },
//                    textProvider: randomText(random: numberHold.randomArray)
//                )
//            }
//            else if userSettings.drawMethod.rawValue == "Random" && animationState.toggle && animationState.firstClick > 1 {
//                MoveView(firstClick: Binding(get: { animationState.firstClick }, set: { animationState.firstClick = $0 }),
//                         savedText: $savedText)
//                BallDrop(
//                    onAnimationComplete: { showAdAfterAnimation() },
//                    textProvider: randomText(random: numberHold.randomArray)
//                )
//            }
//            else if userSettings.drawMethod.rawValue == "Random" && !animationState.toggle && animationState.firstClick > 1 {
//                MoveView(firstClick: Binding(get: { animationState.firstClick }, set: { animationState.firstClick = $0 }),
//                         savedText: $savedText)
//                BallDrop(
//                    onAnimationComplete: { showAdAfterAnimation() },
//                    textProvider: randomText(random: numberHold.randomArray)
//                )
//            }
//            else if userSettings.drawMethod.rawValue == "Custom" && animationState.num == 3 {
//                BallDropAlt(
//                    onAnimationComplete: { showAdAfterAnimation() },
//                    textProvider: WordTextProvider(fiveBalls: ["C","U","S","T","O","M"])
//                )
//            }
//            else if userSettings.drawMethod.rawValue == "Custom" && animationState.firstClick == 1 {
//                BallDrop(
//                    onAnimationComplete: { showAdAfterAnimation() },
//                    textProvider: TextProvider(fiveBalls: custom)
//                )
//            }
//            else if userSettings.drawMethod.rawValue == "Custom" && animationState.firstClick > 1 && animationState.num == 8 {
//                BallDrop(
//                    onAnimationComplete: { showAdAfterAnimation() },
//                    textProvider: TextProvider(fiveBalls: custom)
//                )
//            }
//            else if userSettings.drawMethod.rawValue == "Custom" && animationState.toggle && animationState.firstClick > 1 {
//                MoveView(firstClick: Binding(get: { animationState.firstClick }, set: { animationState.firstClick = $0 }),
//                         savedText: $savedText)
//                BallDrop(
//                    onAnimationComplete: { showAdAfterAnimation() },
//                    textProvider: TextProvider(fiveBalls: custom)
//                )
//            }
//            else if userSettings.drawMethod.rawValue == "Custom" && !animationState.toggle && animationState.firstClick > 1 {
//                MoveView(firstClick: Binding(get: { animationState.firstClick }, set: { animationState.firstClick = $0 }),
//                         savedText: $savedText)
//                BallDrop(
//                    onAnimationComplete: { showAdAfterAnimation() },
//                    textProvider: TextProvider(fiveBalls: custom)
//                )
//            }
//            
//            MyButton(action: {
//                isButtonDisabled = true
//                update()
//                animationState.firstClick += 1
//                hapticFeedback.impactOccurred()
//                animationState.num += 5
//                isButtonHidden = true
//                addItemToRow()
//                numberHold.update()
//                custom = customRandoms.getCustomRandoms(customArray: customArray)
//                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
//                    isButtonDisabled = false
//                }
//            }) {
//                // MyButton label/content goes here.
//            }
//            .disabled(isButtonDisabled)
//            .buttonStyle(.plain)
//            .offset(y: UIScreen.main.bounds.height / 8)
//            
//            Divider()
//                .padding(UIScreen.main.bounds.height / 11)
//        }
//        .zIndex(1)
//        .overlay(
//            ZStack {
//                CoinView(savedArray: $savedArray,
//                         firstClick: Binding(get: { animationState.firstClick },
//                                             set: { animationState.firstClick = $0 })).zIndex(0)
//                FavoritesView()
//            }
//        )
//        .sheet(isPresented: $showSheet) {
//            ZStack {
//                Color("darkBlue").opacity(0.4).ignoresSafeArea()
//                VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark, opacity: 0.9)
//                    .ignoresSafeArea()
//                Form {
//                    Section(header: Text("Custom Numbers").bold()) {
//                        HStack {
//                            TextField("Enter lucky number", text: $itemToAdd)
//                                .keyboardType(.numberPad)
//                                .onReceive(Just(itemToAdd)) { newValue in
//                                    let filtered = newValue.filter { "0123456789".contains($0) }
//                                    if filtered != newValue {
//                                        self.itemToAdd = filtered
//                                    }
//                                }
//                            Button(action: { addItem() }) {
//                                Image(systemName: "plus")
//                                    .padding(5)
//                            }
//                        }
//                        ForEach(0..<customArray.count, id: \.self) { item in
//                            HStack {
//                                Text("\(customArray[item])")
//                                Spacer()
//                                Button(action: {
//                                    if let index = customArray.firstIndex(of: customArray[item]) {
//                                        customArray.remove(at: index)
//                                    }
//                                }) {
//                                    Image(systemName: "minus")
//                                        .padding()
//                                }
//                            }
//                        }
//                        Button(action: {
//                            isAddingItem = false
//                            showSheet = false
//                        }) {
//                            Text("Done").bold()
//                        }
//                    }
//                }
//                .frame(maxWidth: .infinity, alignment: .center)
//                .listStyle(InsetGroupedListStyle())
//                .scrollContentBackground(.hidden)
//                .shadow(color: .black.opacity(0.5), radius: 20)
//                .frame(height: 400)
//                .presentationDetents([.medium, .fraction(0.7)])
//                .background(BackgroundClearView())
//            }
//        }
//        .overlay(
//            Picker("Draw", selection: $userSettings.drawMethod) {
//                Text("Lucky!").tag(UserSettings.numberType.Weighted)
//                Text("Random").tag(UserSettings.numberType.Random)
//                Text("Custom").tag(UserSettings.numberType.Custom)
//                Text("EuroMillions").tag(UserSettings.numberType.EuroMillions)
//            }
//            .padding(.vertical, 3)
//            .pickerStyle(.segmented)
//            .background(
//                ZStack {
//                    Color.black.opacity(0.5)
//                    VStack {
//                        Rectangle()
//                            .fill(
//                                LinearGradient(
//                                    gradient: Gradient(colors: [
//                                        Color("gold").opacity(1),
//                                        Color("softGold").opacity(0.5)
//                                    ]),
//                                    startPoint: .leading,
//                                    endPoint: .trailing
//                                )
//                            )
//                            .frame(height: 1.3)
//                            .blur(radius: 0.5)
//                        Spacer()
//                        Rectangle()
//                            .fill(
//                                LinearGradient(
//                                    gradient: Gradient(colors: [
//                                        Color("softGold").opacity(0.5),
//                                        Color("gold").opacity(1)
//                                    ]),
//                                    startPoint: .leading,
//                                    endPoint: .trailing
//                                )
//                            )
//                            .frame(height: 1.3)
//                            .blur(radius: 0.5)
//                    }
//                }
//            )
//            .padding(.vertical, 2)
//            .onChange(of: userSettings.drawMethod) { newValue in
//                if newValue == .Random {
//                    DispatchQueue.main.async {
//                        animationState.num = 1
//                        isAddingItem = false
//                    }
//                } else if newValue == .Weighted {
//                    DispatchQueue.main.async {
//                        animationState.num = 2
//                        isAddingItem = false
//                    }
//                } else if newValue == .Custom {
//                    DispatchQueue.main.async {
//                        animationState.num = 3
//                        showSheet = true
//                        isAddingItem = true
//                    }
//                } else if newValue == .EuroMillions {
//                    DispatchQueue.main.async {
//                        navigateToEuroMillions = true
//                    }
//                }
//            }
//            .offset(y: UIScreen.main.bounds.height / 3.5)
//        )
//        .overlay(
//            Text("Drawing Method")
//                .font(.system(size: 16).bold())
//                .foregroundColor(.white)
//                .offset(y: UIScreen.main.bounds.height / 4)
//        )
//        .fullScreenCover(isPresented: $navigateToEuroMillions) {
//            EuroMillionsView()
//        }
//    }
//    
//    private func showAdAfterAnimation() {
//        if let rootVC = UIApplication.shared.connectedScenes
//            .compactMap({ $0 as? UIWindowScene })
//            .first?.windows.first?.rootViewController {
//            AdManager.shared.trackButtonPress(from: rootVC)
//        }
//    }
//    
//    private func addItemToRow() {
//        var string = ""
//        var letters = [Int]()
//        
//        if animationState.num != 6 && animationState.num != 7 && animationState.num != 8 {
//            if animationState.firstClick > 1 && userSettings.drawMethod.rawValue == "Weighted" {
//                string = numberHold.weightedArray.map(String.init).joined(separator: ",  ")
//                letters = numberHold.weightedArray
//            }
//            else if animationState.firstClick > 1 && userSettings.drawMethod.rawValue == "Random" {
//                string = numberHold.randomArray.map(String.init).joined(separator: ",  ")
//                letters = numberHold.randomArray
//            }
//            else if animationState.firstClick > 1 && userSettings.drawMethod.rawValue == "Custom" {
//                string = custom.map(String.init).joined(separator: ",  ")
//                letters = custom
//            }
//            
//            if animationState.firstClick > 1 {
//                savedArray.insert(CoinListItem(lottoNumbers: string), at: 0)
//                savedText = letters.map { String($0) }
//            }
//        }
//        
//        if savedArray.count > 10 {
//            savedArray.removeLast()
//        }
//    }
//    
//    func addItem() {
//        if !itemToAdd.isEmpty, let numValue = Int(itemToAdd) {
//            customArray.append(numValue)
//            itemToAdd = ""
//        }
//    }
//}
//
//struct ConView_Previews: PreviewProvider {
//    static var previews: some View {
//        ZStack {
//            Color("darkGreen").ignoresSafeArea()
//            BallDropButton()
//                .environmentObject(BallDropAnimationState())
//                .environmentObject(UserSettings(drawMethod: .Weighted))
//                .environmentObject(NumberHold())
//                .environmentObject(CustomRandoms())
//        }
//    }
//}
