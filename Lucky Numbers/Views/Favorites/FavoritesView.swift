//
//  FavoritesView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/17/25.
//
import SwiftUI

// MARK: - Constants
private enum FavoriteConstants {
    static let iconSize: CGFloat = 28
    static let buttonSize: CGFloat = UIScreen.main.bounds.width / 8.5
    static let horizontalOffsetDivisor: CGFloat = 3.3
    static let verticalOffsetDivisor: CGFloat = -4.6
    static let fontSize: CGFloat = 14
    static let listHeight: CGFloat = UIScreen.main.bounds.height / 1.8
    static let indexCircleSize: CGFloat = 36
    static let borderWidth: CGFloat = 1.5
    static let cornerRadius: CGFloat = 16
    static let glowRadius: CGFloat = 10
    static let animationDuration: Double = 0.3
}

// MARK: - Premium Favorites Button
struct PremiumFavoritesButton<Content: View>: View {
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
            // Button
            Button(action: action) {
                content
                buttonContent
            }
            .buttonStyle(PressableButtonStyle())
            .onHover { hovering in
                withAnimation(.easeInOut(duration: FavoriteConstants.animationDuration)) {
                    isHovering = hovering
                }
            }
            
            // Label
            Text("Favorites")
                .font(.system(size: FavoriteConstants.fontSize, weight: .medium))
                .foregroundColor(Color("gold"))
                .shadow(color: Color("black").opacity(0.7), radius: 4, x: 2, y: 4)
                .offset(y: FavoriteConstants.buttonSize / 2 + 12)
        }
        .offset(
            x: UIScreen.main.bounds.width / -FavoriteConstants.horizontalOffsetDivisor,
            y: UIScreen.main.bounds.height / -FavoriteConstants.verticalOffsetDivisor
        )
    }
    
    // MARK: Components
    private var buttonContent: some View {
        ZStack {
            // Premium button appearance
            buttonBackground
            
            // Animated glow effect
            Circle()
                .fill(Color("neonBlue").opacity(0.3))
                .scaleEffect(isHovering ? 1.1 : 0.92)
                .opacity(isHovering ? 0.7 : 0)
                .blur(radius: FavoriteConstants.glowRadius)
                .animation(
                    Animation.easeInOut(duration: FavoriteConstants.animationDuration * 2)
                        .repeatForever(autoreverses: true),
                    value: isHovering
                )
            
            // Heart Icon
            Image(systemName: "heart.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: FavoriteConstants.iconSize, height: FavoriteConstants.iconSize)
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
                        lineWidth: FavoriteConstants.borderWidth
                    )
            )
            .shadow(color: Color("neonBlue").opacity(0.7), radius: 5, x: 1, y: 2)
            .shadow(color: Color("black").opacity(0.7), radius: 8, x: 3, y: 12)
            .frame(width: FavoriteConstants.buttonSize, height: FavoriteConstants.buttonSize)
    }
}

// MARK: - FavoritesView
struct FavoritesView: View {
    // MARK: Properties
    @Environment(\.editMode) var editMode
    @State private var donePressed: Bool = false
    @State private var showSheet: Bool = false
    @State private var selected: UUID = UUID()
    @State var savedArray: [CoinListItem] = []
    @AppStorage(UserKeys.userNumber.rawValue) var albums: Data = Data()
    
    var body: some View {
        ZStack {
            PremiumFavoritesButton(action: handleButtonPress) { }
                .buttonStyle(PressableButtonStyle())
                .sheet(isPresented: $showSheet, content: { favoritesSheet })
        }
    }
    
    // MARK: Components
    private var favoritesSheet: some View {
        NavigationView {
            ZStack {
                // Match CoinView's background
                backgroundGradient
                
                VStack(spacing: 0) {
                    headerView
                        .padding(.bottom, 10)
                    
                    if getStrings(data: albums).isEmpty {
                        emptyStateView
                    } else {
                        Spacer().frame(height: 10)
                        
                        // Title for favorites section
                        HStack {
                            Text("YOUR FAVORITES")
                                .font(.system(size: 13, weight: .semibold))
                                .tracking(1.2)
                                .foregroundColor(Color("gold").opacity(0.8))
                                .padding(.leading, 24)
                            
                            Spacer()
                        }
                        .padding(.bottom, 5)
                        
                        // List with restored delete functionality
                        favoritesList
                    }
                    
                    Spacer()
                    
                    infoTextView
                        .padding(.bottom, 15)
                    
                    doneButton
                        .padding(.bottom, 30)
                }
                .padding(.top, 20)
            }
            .background(BackgroundClearView())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .bold()
                        .font(.system(size: 16))
                        .foregroundColor(Color("gold"))
                        .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 1)
                }
            }
        }
        .background(BackgroundClearView())
    }
    
    private var backgroundGradient: some View {
        ZStack {
            // Base gradient - matching CoinView
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("darkBlue").opacity(0.95),
                    Color("black").opacity(0.9)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Decorative elements
            decorativePatterns
        }
    }
    
    private var decorativePatterns: some View {
        ZStack {
            ForEach(0..<6) { i in
                Circle()
                    .fill(Color("neonBlue").opacity(0.05))
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
            Text("Favorite Numbers")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: Color("gold").opacity(0.7), radius: 2, x: 0, y: 2)
                .padding(.top, 15)
            
            Text("Your saved lottery picks")
                .font(.system(size: 16))
                .foregroundColor(Color.white.opacity(0.7))
        }
    }
    
    private var favoritesList: some View {
        List {
            ForEach(getStrings(data: albums), id: \.self) { item in
                ZStack {
                    favoriteItemView(for: item, at: getIndex(for: item))
                        .listRowInsets(EdgeInsets()) // Remove default padding
                        .padding(.vertical, 1)
                }
                .listRowBackground(Color.clear) // Transparent background for list row
            }
            .onDelete(perform: performDelete) // Restore delete functionality
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden) // Hide default background
        .background(Color.clear) // Explicitly set list background to clear
        .frame(height: FavoriteConstants.listHeight)
    }
    
    private func getIndex(for item: String) -> Int {
        getStrings(data: albums).firstIndex(of: item) ?? 0
    }
    
    private func favoriteItemView(for item: String, at index: Int) -> some View {
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
                    .frame(width: FavoriteConstants.indexCircleSize, height: FavoriteConstants.indexCircleSize)
                    .shadow(color: Color("neonBlue").opacity(0.4), radius: 3, x: 0, y: 2)
                
                Text("\(index + 1)")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.leading, 5)
            
            // Lottery numbers
            Text(item)
                .font(.system(size: 22))
                .foregroundColor(.white)
                .lineLimit(1)
                .padding(.leading, 8)
                .bold()
                .shadow(color: Color.black.opacity(0.5), radius: 3, x: 0, y: 1)
            
            Spacer()
            
            // Show share button only when not in edit mode
            if editMode?.wrappedValue.isEditing != true {
                ShareLink(item: item) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20))
                        .foregroundColor(Color("neonBlue"))
                        .shadow(color: Color("gold").opacity(0.5), radius: 2, x: 0, y: 1)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 8)
            }
        }
        .padding(.vertical, 10)
        .background(favoriteCardBackground)
        .padding(.horizontal, 1)
    }
    
    private var favoriteCardBackground: some View {
        RoundedRectangle(cornerRadius: FavoriteConstants.cornerRadius)
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
                RoundedRectangle(cornerRadius: FavoriteConstants.cornerRadius)
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
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color("darkBlue").opacity(0.3))
                    .frame(width: 100, height: 100)
                    .blur(radius: 10)
                
                Image(systemName: "heart.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70)
                    .foregroundColor(Color.white.opacity(0.7))
                    .shadow(color: Color("neonBlue").opacity(0.5), radius: 5, x: 0, y: 2)
            }
            
            Text("No Favorites Yet")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color.white.opacity(0.9))
            
            Text("Your saved numbers will appear here")
                .font(.subheadline)
                .foregroundColor(Color.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding(.top, 80)
        .frame(height: FavoriteConstants.listHeight)
    }
    
    private var infoTextView: some View {
        Text("Your favorite numbers will be stored here.")
            .font(.system(size: 16))
            .foregroundColor(.white.opacity(0.8))
            .frame(alignment: .center)
            .padding(.horizontal, 25)
            .multilineTextAlignment(.center)
    }
    
    private var doneButton: some View {
        Button(action: closeFavoritesSheet) {
            Text("Done")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .padding(.vertical, 14)
                .padding(.horizontal, 45)
                .background(doneButtonBackground)
        }
        .buttonStyle(PressableButtonStyle())
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
    
    // MARK: - Methods
    private func handleButtonPress() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        DispatchQueue.main.async {
            self.showSheet = true
        }
    }
    
    private func closeFavoritesSheet() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        self.showSheet = false
    }
    
    private func performDelete(at offsets: IndexSet) {
        var tmpAlbums = getStrings(data: albums)
        tmpAlbums.remove(atOffsets: offsets)
        albums = Storage.archiveStringArray(object: tmpAlbums)
    }
    
    func removeRows(at offsets: IndexSet) {
        // Preserved empty function from original code
    }
    
    func getStrings(data: Data) -> [String] {
        return Storage.loadStringArray(data: data)
    }
}

// MARK: - Preview Provider
struct Provider_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
    }
}
