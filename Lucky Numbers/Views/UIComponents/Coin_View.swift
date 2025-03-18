//
//  Coin_View.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/17/25.
//


import SwiftUI

// MARK: - Constants
private enum UIConstants {
    static let iconSize: CGFloat = 28
    static let buttonSize: CGFloat = UIScreen.main.bounds.width / 8.5
    static let horizontalOffsetDivisor: CGFloat = 3.3
    static let verticalOffsetDivisor: CGFloat = 4.6
    static let heartIconSize: CGFloat = 22
    static let indexCircleSize: CGFloat = 36
    static let borderWidth: CGFloat = 1.5
    static let cornerRadius: CGFloat = 16
    static let listHeight: CGFloat = 320
    static let glowRadius: CGFloat = 10
    static let animationDuration: Double = 0.3
}

// MARK: - Heart Button Components
struct LikeButton: View {
    @Binding var isAnimating: Bool
    
    var body: some View {
        ZStack {
            Image(systemName: "heart.fill")
                .opacity(isAnimating ? 1 : 0)
                .scaleEffect(isAnimating ? 1.0 : 0.1)
                .animation(.linear, value: isAnimating)
            Image(systemName: "heart")
        }
        .font(.system(size: 40))
        .foregroundColor(isAnimating ? .red : Color("neonBlue"))
    }
}

struct HeartButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
        
        ZStack {
            Image(systemName: "heart.fill")
                .font(.system(size: UIConstants.heartIconSize))
                .opacity(configuration.isPressed ? 1 : 0)
                .scaleEffect(configuration.isPressed ? 1.0 : 0.1)
                .foregroundColor(configuration.isPressed ? .red : .white)
                .shadow(color: configuration.isPressed ? .red.opacity(0.8) : .clear, radius: 6)
            
            Image(systemName: "heart")
                .font(.system(size: UIConstants.heartIconSize))
                .scaleEffect(configuration.isPressed ? 0.1 : 1.0)
                .foregroundColor(configuration.isPressed ? .red : .white)
                .shadow(color: Color("gold").opacity(0.7), radius: 2, x: 0, y: 1)
                .overlay(
                    animatedLineOverlay(isPressed: configuration.isPressed)
                )
        }
    }
    
    private func animatedLineOverlay(isPressed: Bool) -> some View {
        Image("line")
            .resizable()
            .frame(width: 300, height: 30)
            .opacity(isPressed ? 1 : 0)
            .offset(x: -UIScreen.main.bounds.width/3)
            .offset(x: isPressed ? -500 : 0)
            .scaleEffect(isPressed ? 0.1 : 1.0)
    }
}

// MARK: - DeleteButton
struct DeleteButton: View {
    // MARK: Properties
    @Environment(\.editMode) var editMode
    @AppStorage(UserKeys.userNumber.rawValue) var albums: Data = Data()
    @Binding var likes: [LikeView]
    let i: CoinListItem
    let number: CoinListItem
    @Binding var numbers: [CoinListItem]
    let onDelete: (IndexSet) -> Void
    @EnvironmentObject var numberHold: NumberHold
    
    // MARK: Body
    var body: some View {
        ZStack {
            if self.editMode?.wrappedValue != .active {
                Button(action: performHeartAction) {}
                    .buttonStyle(HeartButtonStyle())
                    .padding(.horizontal, 8)
            }
        }
    }
    
    // MARK: Private Methods
    private func performHeartAction() {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Handle deletion
        if let index = numbers.firstIndex(of: number) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.onDelete(IndexSet(integer: index))
            }
        }
        
        // Add like animation
        likes += [LikeView()]
        
        // Update stored favorites
        var storedNumbers = getStrings(data: albums)
        storedNumbers.append(i.lottoNumbers)
        albums = Storage.archiveStringArray(object: storedNumbers)
        
        // Update number hold (if needed)
//        numberHold.num = i.lottoNumbers
    }
    
    private func getStrings(data: Data) -> [String] {
        return Storage.loadStringArray(data: data)
    }
}

// MARK: - Button Styles
struct PremiumButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .brightness(configuration.isPressed ? 0.1 : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Premium CoinButton
struct PremiumCoinButton<Content: View>: View {
    // MARK: Properties
    private let action: () -> Void
    private let content: Content
    @State private var isHovering = false
    
    // MARK: Initialization
    init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }
    
    // MARK: Body
    var body: some View {
        ZStack {
            // Main container for positioning
            Button(action: action) {
                content
                buttonContent
            }
            .buttonStyle(PremiumButtonStyle())
            .onHover { hovering in
                withAnimation(.easeInOut(duration: UIConstants.animationDuration)) {
                    isHovering = hovering
                }
            }
            
            // Text positioned relative to the button
            Text("My Picks")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color("gold"))
                .shadow(color: Color("black").opacity(0.7), radius: 4, x: 2, y: 4)
                .offset(y: UIConstants.buttonSize / 2 + 12) // Position text below button
        }
        .offset(
            x: UIScreen.main.bounds.width / UIConstants.horizontalOffsetDivisor,
            y: UIScreen.main.bounds.height / UIConstants.verticalOffsetDivisor
        )
    }
    
    // MARK: Components
    private var buttonContent: some View {
        // Button content remains the same
        ZStack {
            buttonBackground
            
            Circle()
                .fill(Color("neonBlue").opacity(0.3))
                .scaleEffect(isHovering ? 1.1 : 0.92)
                .opacity(isHovering ? 0.7 : 0)
                .blur(radius: UIConstants.glowRadius)
                .animation(
                    Animation.easeInOut(duration: UIConstants.animationDuration * 2)
                        .repeatForever(autoreverses: true),
                    value: isHovering
                )
            
            Image(systemName: "list.star")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIConstants.iconSize, height: UIConstants.iconSize)
                .foregroundColor(.white)
                .shadow(color: Color("gold").opacity(0.7), radius: 2, x: 0, y: 1)
        }
    }
    
    private var buttonBackground: some View {
        Circle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("darkBlue").opacity(0.8),
                        Color("neonBlue").opacity(0.6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color("gold").opacity(0.8),
                                Color("softGold").opacity(0.4)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: UIConstants.borderWidth
                    )
            )
            .shadow(color: Color("neonBlue").opacity(0.7), radius: 5, x: 1, y: 2)
            .shadow(color: Color("black").opacity(0.7), radius: 8, x: 3, y: 12)
            .frame(width: UIConstants.buttonSize, height: UIConstants.buttonSize)
    }
}

// MARK: - Enhanced CoinView
struct EnhancedCoinView: View {
    // MARK: Properties
    @State var likes: [LikeView] = []
    @Environment(\.editMode) private var editMode
    @EnvironmentObject var numberHold: NumberHold
    @AppStorage(UserKeys.userNumber.rawValue) var albums: Data = Data()
    @State private var selected: UUID = UUID()
    @State private var isAnimating: Bool = false
    @State private var num: Int = 0
    @State private var showSheet: Bool = false
    @State private var donePressed: Bool = false
    @State private var plusPressed: Bool = false
    @Binding var savedArray: [CoinListItem]
    @State private var animateBackground = false

    // MARK: Body
    var body: some View {
        PremiumCoinButton(action: handleButtonPress) { }
            .buttonStyle(PressableButtonStyle())
            .sheet(isPresented: $showSheet, content: { historySheet })
    }
    
    // MARK: Components
    private var historySheet: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                
                VStack(spacing: 0) {
                    headerView
                        .padding(.bottom, 10)
                    
                    if savedArray.isEmpty {
                        emptyStateView
                    } else {
                        Spacer().frame(height: 10)
                        
                        // Title for numbers section
                        HStack {
                            Text("YOUR SELECTIONS")
                                .font(.system(size: 13, weight: .semibold))
                                .tracking(1.2)
                                .foregroundColor(Color("gold").opacity(0.8))
                                .padding(.leading, 24)
                            
                            Spacer()
                        }
                        .padding(.bottom, 5)
                        
                        numberListView
                    }
                    
                    Spacer()
                    
                    likeAnimationView
                    
                    infoTextView
                        .padding(.bottom, 15)
                    
                    doneButton
                        .padding(.bottom, 30)
                }
                .padding(.top, 20)
            }
            .background(BackgroundClearView())
            .onAppear {
                // Use a more compatible animation approach
                withAnimation(
                    Animation.easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true)
                        .delay(0.2)
                ) {
                    animateBackground = true
                }
            }
        }
        .background(BackgroundClearView())
    }
    
    private var backgroundGradient: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("darkBlue").opacity(0.95),
                    Color("black").opacity(0.9)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Animated overlay
            RadialGradient(
                gradient: Gradient(colors: [
                    Color("neonBlue").opacity(0.2),
                    Color.clear
                ]),
                center: .center,
                startRadius: 100,
                endRadius: UIScreen.main.bounds.width
            )
            .scaleEffect(animateBackground ? 1.2 : 0.9)
            .opacity(animateBackground ? 0.6 : 0.3)
            .ignoresSafeArea()
            
            // Decorative elements
            decorativePatterns
        }
    }
    
    private var decorativePatterns: some View {
        ZStack {
            ForEach(0..<6) { i in
                Circle()
                    .fill(Color("neonBlue").opacity(0.1))
                    .frame(width: CGFloat.random(in: 100...200))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .blur(radius: 15)
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Recent Numbers")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: Color("gold").opacity(0.7), radius: 2, x: 0, y: 2)
                .padding(.top, 15)
            
            
            Text("Your lottery history")
                .font(.system(size: 16))
                .foregroundColor(Color.white.opacity(0.7))
        }
    }
    
    private var numberListView: some View {
        List {
            ForEach(Array(savedArray.enumerated()), id: \.element.id) { index, item in
                historyItemView(for: item, at: index)
            }
            .onDelete(perform: removeRows)
        }
        .scrollContentBackground(.hidden)
        .frame(height: UIConstants.listHeight)
        .listStyle(.plain)
        .toolbar {
            EditButton()
                .bold()
                .font(.system(size: 16))
                .foregroundColor(Color("gold"))
                .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 1)
        }
    }
    
    private func historyItemView(for item: CoinListItem, at index: Int) -> some View {
        HStack {
            // Number index
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color("neonBlue").opacity(0.6),
                                Color("darkBlue").opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: UIConstants.indexCircleSize, height: UIConstants.indexCircleSize)
                    .shadow(color: Color("neonBlue").opacity(0.4), radius: 3, x: 0, y: 2)
                
                Text("\(index + 1)")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.leading, 5)
            
            // Lottery numbers
            Text(item.lottoNumbers)
                .font(.system(size: 22))
                .foregroundColor(.white)
                .lineLimit(1)
                .padding(.leading, 8)
                .bold()
                .shadow(color: Color.black.opacity(0.5), radius: 3, x: 0, y: 1)
            
            Spacer()
            
            // Delete/favorite button
            DeleteButton(
                likes: $likes,
                i: item,
                number: item,
                numbers: $savedArray,
                onDelete: removeRows
            )
            .padding(0)
            .pressAction {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selected = item.id
                    plusPressed = true
                }
            } onRelease: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selected = UUID()
                    plusPressed = false
                }
            }
        }
        .padding(.vertical, 8)
        .listRowSeparator(.hidden)
        .listRowBackground(
            numberCardBackground
                .scaleEffect(selected == item.id ? 0.97 : 1)
                .opacity(selected == item.id ? 0.5 : 1)
                .animation(.easeInOut(duration: 0.2), value: selected == item.id)
        )
    }
    
    private var numberCardBackground: some View {
        RoundedRectangle(cornerRadius: UIConstants.cornerRadius)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("darkBlue").opacity(0.6),
                        Color.black.opacity(0.4)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: UIConstants.cornerRadius)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color("gold").opacity(0.9),
                                Color("softGold").opacity(0.5)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: Color("neonBlue").opacity(0.3), radius: 8, x: 0, y: 4)
            .padding(5)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color("darkBlue").opacity(0.3))
                    .frame(width: 100, height: 100)
                    .blur(radius: 10)
                
                Image(systemName: "clock.badge.exclamationmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70)
                    .foregroundColor(Color.white.opacity(0.7))
                    .shadow(color: Color("neonBlue").opacity(0.5), radius: 5, x: 0, y: 2)
            }
            
            Text("No History Yet")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color.white.opacity(0.9))
            
            Text("Generate some numbers to see them here")
                .font(.subheadline)
                .foregroundColor(Color.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding(.top, 80)
        .frame(height: UIConstants.listHeight)
    }
    
    private var likeAnimationView: some View {
        ZStack {
            ForEach(likes) { like in
                like.image
                    .resizable()
                    .frame(width: 50, height: 50)
                    .modifier(LikeTapModifier())
                    .id(like.id)
            }
            .onChange(of: likes) { newValue in
                if likes.count > 5 {
                    likes.removeFirst()
                }
            }
        }
    }
    
    private var infoTextView: some View {
        Text("Your ten most recently generated numbers will be shown here. Click the heart to save your favorite numbers")
            .font(.system(size: 16))
            .foregroundColor(.white.opacity(0.8))
            .frame(alignment: .center)
            .padding(.horizontal, 25)
            .multilineTextAlignment(.center)
    }
    
    private var doneButton: some View {
        Button(action: closeDoneButton) {
            Text("Done")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .padding(.vertical, 14)
                .padding(.horizontal, 45)
                .background(doneButtonBackground)
        }
        .buttonStyle(PremiumButtonStyle())
        .scaleEffect(donePressed ? 0.95 : 1)
        .animation(.interpolatingSpring(mass: 0.5, stiffness: 350, damping: 9, initialVelocity: 1), value: donePressed)
        .pressAction {
            donePressed = true
        } onRelease: {
            donePressed = false
        }
    }
    
    private var doneButtonBackground: some View {
        Capsule()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("darkBlue").opacity(0.9),
                        Color("neonBlue").opacity(0.7)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .overlay(
                Capsule()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color("gold").opacity(0.9),
                                Color("softGold").opacity(0.5)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: Color("neonBlue").opacity(0.6), radius: 10, x: 0, y: 5)
    }
    
    // MARK: Methods
    private func handleButtonPress() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        likes = []
        DispatchQueue.main.async {
            self.showSheet = true
        }
    }
    
    private func closeDoneButton() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        self.showSheet = false
    }
    
    func removeRows(at offsets: IndexSet) {
        savedArray.remove(atOffsets: offsets)
    }
}

// MARK: - CoinView for backwards compatibility
struct CoinView: View {
    @Binding var savedArray: [CoinListItem]
    
    var body: some View {
        EnhancedCoinView(savedArray: $savedArray)
    }
}


#Preview {
    EnhancedCoinView(
        savedArray: .constant([
            CoinListItem(lottoNumbers: "5 - 12 - 23 - 34 - 56 | 9"),
            CoinListItem(lottoNumbers: "7 - 14 - 21 - 28 - 35 | 10"),
            CoinListItem(lottoNumbers: "3 - 11 - 18 - 26 - 39 | 15")
        ])
    )
    .environmentObject(NumberHold())
}
