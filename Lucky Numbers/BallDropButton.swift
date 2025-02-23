//
//  BallDropButton.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/17/25.
//
import SwiftUI
import Combine

/// Global variables (as in your code).
var globalClicked: Bool = false
var firstClick: Int = 0

struct LogoView: View {
    var body: some View {
        ZStack(alignment: .center){
            Image("Luckies_Logo")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width,
                       height: UIScreen.main.bounds.height/3)
                .opacity(1)
        }
    }
}

// MARK: - BallDrop
/// Shows the "ball_drop" animation, calls `onAnimationComplete` when done.
struct BallDrop: View {
    var onAnimationComplete: (() -> Void)? = nil
    let textProvider: TextProvider

    var body: some View {
        ZStack {
            LottieView(
                onAnimationComplete: onAnimationComplete,
                filename: "ball_drop",
                textProvider: textProvider
            )
            .shadow(radius: 10, x: -5, y: 20)
        }
        .frame(width: UIScreen.main.bounds.width,
               height: UIScreen.main.bounds.height / 2,
               alignment: .center)
        .offset(y: -UIScreen.main.bounds.height / 7)
    }
}

// MARK: - BallDropAlt
/// Similar to BallDrop, but uses `WordTextProvider` instead of `TextProvider`.
struct BallDropAlt: View {
    var onAnimationComplete: (() -> Void)? = nil
    let textProvider: WordTextProvider

    var body: some View {
        ZStack {
            LottieView(
                onAnimationComplete: onAnimationComplete,
                filename: "ball_drop",
                textProvider: textProvider
            )
            .shadow(radius: 10, x: -5, y: 20)
        }
        .frame(width: UIScreen.main.bounds.width,
               height: UIScreen.main.bounds.height / 2,
               alignment: .center)
        .offset(y: -UIScreen.main.bounds.height / 7)
    }
}

// MARK: - LoadBalls
/// Your "loading" animation or initial state.
struct LoadBalls: View {
    @State var toggle: Bool = false
    let textProvider: TextProvider = TextProvider(fiveBalls: [1,1,1,1,1,1])

    var body: some View {
        ZStack {
            LottieView(
                onAnimationComplete: nil, // no ad trigger here
                filename: "load_balls",
                textProvider: textProvider
            )
            .shadow(radius: 10, x: -5, y: 20)
        }
        .frame(width: UIScreen.main.bounds.width,
               height: UIScreen.main.bounds.height / 2,
               alignment: .center)
        .offset(y: -UIScreen.main.bounds.height/7)
    }
}

// MARK: - BallDropButton
/// The main view tying everything together, controlling which animation to show
/// and calling `AdManager` after the animation finishes.
struct BallDropButton: View {
    
    @EnvironmentObject private var userSettings: UserSettings
    @EnvironmentObject var numberHold: NumberHold
    @EnvironmentObject var customRandoms: CustomRandoms

    @State var isButtonHidden: Bool = false
    @State var isPressed: Bool = false
    @State var firstClick: Int = 0
    @State private var showSheet = false

    @State var coinPressed: Bool = false
    @State var donePressed: Bool = false

    @State var savedArray: [CoinListItem] = []
    @State var savedText: [String] = []
    @State var toSparkle = true

    @State private var customArray = [Int]()
    @State var custom = [Int]()
    @State var stringNum: String = ""
    @State private var itemToAdd: String = ""
    @State private var isAddingItem: Bool = false

    @State var num: Int = 0
    @State var toggle: Bool = false
    
    let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    
    // NEW: Controls whether the button is disabled
    @State private var isButtonDisabled = false

    init() {
        // Customize UISegmentedControl
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.white)
        UISegmentedControl.appearance().setTitleTextAttributes(
            [
                .font: UIFont.boldSystemFont(ofSize: 16),
                .foregroundColor: UIColor.black
            ], for: .selected)
        
        UISegmentedControl.appearance().setTitleTextAttributes(
            [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor.white
            ], for: .normal)
    }
    
    func update() {
        toggle.toggle()
    }
    
    var body: some View {
        ZStack {
            // Show the correct animation, pass onAnimationComplete to trigger ads
            if firstClick == 0 && num == 0 {
                LoadBalls()
            }
            else if userSettings.drawMethod.rawValue == "Weighted" && num == 2 {
                BallDropAlt(
                    onAnimationComplete: { showAdAfterAnimation() },
                    textProvider: WordTextProvider(fiveBalls: ["L","U","C","K","Y","!"])
                )
            }
            else if userSettings.drawMethod.rawValue == "Weighted" && firstClick == 1 {
                BallDrop(
                    onAnimationComplete: { showAdAfterAnimation() },
                    textProvider: weightedText(weighted: numberHold.weightedArray)
                )
            }
            else if userSettings.drawMethod.rawValue == "Weighted" && firstClick > 1 && num == 7 {
                BallDrop(
                    onAnimationComplete: { showAdAfterAnimation() },
                    textProvider: weightedText(weighted: numberHold.weightedArray)
                )
            }
            else if userSettings.drawMethod.rawValue == "Weighted" && toggle && firstClick > 1 {
                MoveView(firstClick: $firstClick, savedText: $savedText)
                BallDrop(
                    onAnimationComplete: { showAdAfterAnimation() },
                    textProvider: weightedText(weighted: numberHold.weightedArray)
                )
            }
            else if userSettings.drawMethod.rawValue == "Weighted" && !toggle && firstClick > 1 {
                MoveView(firstClick: $firstClick, savedText: $savedText)
                BallDrop(
                    onAnimationComplete: { showAdAfterAnimation() },
                    textProvider: weightedText(weighted: numberHold.weightedArray)
                )
            }
            else if userSettings.drawMethod.rawValue == "Random" && num == 1 {
                BallDropAlt(
                    onAnimationComplete: { showAdAfterAnimation() },
                    textProvider: WordTextProvider(fiveBalls: ["R","A","N","D","O","M"])
                )
            }
            else if userSettings.drawMethod.rawValue == "Random" && num == 6 {
                BallDrop(
                    onAnimationComplete: { showAdAfterAnimation() },
                    textProvider: randomText(random: numberHold.randomArray)
                )
            }
            else if userSettings.drawMethod.rawValue == "Random" && toggle && firstClick > 1 {
                MoveView(firstClick: $firstClick, savedText: $savedText)
                BallDrop(
                    onAnimationComplete: { showAdAfterAnimation() },
                    textProvider: randomText(random: numberHold.randomArray)
                )
            }
            else if userSettings.drawMethod.rawValue == "Random" && !toggle && firstClick > 1 {
                MoveView(firstClick: $firstClick, savedText: $savedText)
                BallDrop(
                    onAnimationComplete: { showAdAfterAnimation() },
                    textProvider: randomText(random: numberHold.randomArray)
                )
            }
            else if userSettings.drawMethod.rawValue == "Custom" && num == 3 {
                BallDropAlt(
                    onAnimationComplete: { showAdAfterAnimation() },
                    textProvider: WordTextProvider(fiveBalls: ["C","U","S","T","O","M"])
                )
            }
            else if userSettings.drawMethod.rawValue == "Custom" && firstClick == 1 {
                BallDrop(
                    onAnimationComplete: { showAdAfterAnimation() },
                    textProvider: TextProvider(fiveBalls: custom)
                )
            }
            else if userSettings.drawMethod.rawValue == "Custom" && firstClick > 1 && num == 8 {
                BallDrop(
                    onAnimationComplete: { showAdAfterAnimation() },
                    textProvider: TextProvider(fiveBalls: custom)
                )
            }
            else if userSettings.drawMethod.rawValue == "Custom" && toggle && firstClick > 1 {
                MoveView(firstClick: $firstClick, savedText: $savedText)
                BallDrop(
                    onAnimationComplete: { showAdAfterAnimation() },
                    textProvider: TextProvider(fiveBalls: custom)
                )
            }
            else if userSettings.drawMethod.rawValue == "Custom" && !toggle && firstClick > 1 {
                MoveView(firstClick: $firstClick, savedText: $savedText)
                BallDrop(
                    onAnimationComplete: { showAdAfterAnimation() },
                    textProvider: TextProvider(fiveBalls: custom)
                )
            }
            
            // The main button to trigger the ball drop logic
            MyButton(action: {
                // 1) Immediately disable the button for 2 seconds
                isButtonDisabled = true
                
                self.update()
                firstClick += 1
                globalClicked = true
                self.hapticFeedback.impactOccurred()
                self.num += 5
                self.isButtonHidden = true
                self.addItemToRow()
                self.numberHold.update()
                custom = customRandoms.getCustomRandoms(customArray: customArray)
                
                // 2) Re-enable after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
                    isButtonDisabled = false
                }
            }) {
                // Keep your MyButton label/content
            }
            // 3) SwiftUI automatically disables the button when isButtonDisabled == true
            .disabled(isButtonDisabled)
            .buttonStyle(.plain)
            .offset(y: UIScreen.main.bounds.height / 8)
            
            Divider()
                .padding(UIScreen.main.bounds.height / 11)
        }
        .zIndex(1)
        
        // Additional Overlays
        ZStack {
            CoinView(savedArray: $savedArray, firstClick: $firstClick)
            FavoritesView()
            InfoButton()
        }
        
        // Custom Number Input Sheet
        .sheet(isPresented: $showSheet, content: {
            ZStack {
                Color("lightGreen").ignoresSafeArea()
                Form {
                    Section(header: Text("Custom Numbers").bold()) {
                        HStack {
                            TextField("Enter lucky number", text: $itemToAdd)
                                .keyboardType(.numberPad)
                                .onReceive(Just(itemToAdd)) { newValue in
                                    let filtered = newValue.filter { "0123456789".contains($0) }
                                    if filtered != newValue {
                                        self.itemToAdd = filtered
                                    }
                                }
                            Button(action: {
                                addItem()
                            }) {
                                Image(systemName: "plus")
                                    .padding(5)
                            }
                        }
                        ForEach(0..<customArray.count, id: \.self) { item in
                            HStack {
                                Text("\(customArray[item])")
                                Spacer()
                                Button(action: {
                                    if let index = customArray.firstIndex(of: customArray[item]) {
                                        customArray.remove(at: index)
                                    }
                                }) {
                                    Image(systemName: "minus")
                                        .padding()
                                }
                            }
                        }
                        Button(action: {
                            isAddingItem = false
                            showSheet = false
                        }) {
                            Text("Done").bold()
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .listStyle(InsetGroupedListStyle())
                .scrollContentBackground(.hidden)
                .shadow(color: .black.opacity(0.5), radius: 20)
                .frame(height: 400)
                .presentationDetents([.medium, .fraction(0.7)])
                .background(BackgroundClearView())
            }
        })
        
        // Picker Setup
        Picker("Draw", selection: $userSettings.drawMethod) {
            Text("Random").tag(UserSettings.numberType.Random)
            Text("Lucky!").tag(UserSettings.numberType.Weighted)
            Text("Custom").tag(UserSettings.numberType.Custom)
        }
        .pickerStyle(.segmented)
        .background(Color.black.opacity(0.3))
        .onChange(of: userSettings.drawMethod) { newValue in
            if newValue.rawValue == "Random" {
                DispatchQueue.main.async {
                    num = 1
                    isAddingItem = false
                }
            } else if newValue.rawValue == "Weighted" {
                DispatchQueue.main.async {
                    num = 2
                    isAddingItem = false
                }
            } else if newValue.rawValue == "Custom" {
                DispatchQueue.main.async {
                    num = 3
                    self.showSheet = true
                    self.isAddingItem = true
                }
            }
        }
        .offset(y: UIScreen.main.bounds.height / 3.2)
        
        Text("Drawing Method")
            .font(.system(size: 16).bold())
            .foregroundColor(.white)
            .offset(y: UIScreen.main.bounds.height / 3.6)
    }
    
    /// Called after the animation finishes. Triggers AdManager if needed.
    private func showAdAfterAnimation() {
        if let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first?.rootViewController {
            AdManager.shared.trackButtonPress(from: rootVC) // ✅ Corrected call
        }
    }

    
    private func addItemToRow() {
        var string = String()
        var letters = [Int]()
        
        if num != 6 && num != 7 && num != 8 {
            if firstClick > 1 && userSettings.drawMethod.rawValue == "Weighted" {
                string = numberHold.weightedArray.map(String.init).joined(separator: ",  ")
                letters = numberHold.weightedArray
            }
            else if firstClick > 1 && userSettings.drawMethod.rawValue == "Random" {
                string = numberHold.randomArray.map(String.init).joined(separator: ",  ")
                letters = numberHold.randomArray
            }
            else if firstClick > 1 && userSettings.drawMethod.rawValue == "Custom" {
                string = custom.map(String.init).joined(separator: ",  ")
                letters = custom
            }
            
            if firstClick > 1 {
                savedArray.insert(CoinListItem(lottoNumbers: string), at: 0)
                savedText = letters.map { String("\($0)") }
            }
        }
        
        if savedArray.count > 10 {
            savedArray.removeLast()
        }
    }
    
    func addItem() {
        if !itemToAdd.isEmpty, let numValue = Int(itemToAdd) {
            customArray.append(numValue)
            itemToAdd = ""
        }
    }
}

struct ConView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color("darkGreen").ignoresSafeArea()
            BallDropButton()
                .environmentObject(UserSettings(drawMethod: .Weighted))
                .environmentObject(NumberHold())
                .environmentObject(CustomRandoms())
        }
    }
}
