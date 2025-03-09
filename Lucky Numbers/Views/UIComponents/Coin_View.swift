//
//  Coin_View.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/17/25.
//


import SwiftUI

func deleteAppMemory() {
    UserDefaults.standard.resetUser()

}

struct LikeButton : View {
    @Binding var isAnimating : Bool
    var body: some View {
        ZStack {
            Image(systemName: "heart.fill")
                .opacity(isAnimating ? 1 : 0)
                .scaleEffect(isAnimating ? 1.0 : 0.1)
                .animation(.linear, value: self.isAnimating)
            Image(systemName: "heart")
        }.font(.system(size: 40))
//            .onTapGesture {
//                self.isAnimating.toggle()
//        }
            .foregroundColor(isAnimating ? .red : .blue)
    }
}

struct HeartButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
      
        ZStack {
                Image(systemName: "heart.fill")
                .opacity(configuration.isPressed ? 1 : 0)
                    .font(.system(size: 20))
                    .scaleEffect(configuration.isPressed ? 1.0 : 0.1)
                    .foregroundColor(configuration.isPressed ? .red : .blue)
                Image(systemName: "heart")
                .scaleEffect(configuration.isPressed ? 0.1 : 1.0)

                    .font(.system(size: 20))
                    .foregroundColor(configuration.isPressed ? .red : .blue)
                    .overlay(
            ZStack {
                Image("line")
                    .resizable()
                    .frame(width: 300, height: 30)
                    .opacity(configuration.isPressed ? 1 : 0)
                    .offset(x: -UIScreen.main.bounds.width/3)
                                    .offset(x: configuration.isPressed ? -500 : 0)
                    .scaleEffect(configuration.isPressed ? 0.1 : 1.0)
               
            }
            )

        }
    }
}


struct DeleteButton: View {
    @Environment(\.editMode) var editMode
    @AppStorage(UserKeys.userNumber.rawValue) var albums: Data = Data()
    @Binding var likes :[LikeView]
    func likeAction () {
        likes += [LikeView()]
    }
    let i : CoinListItem
    let number: CoinListItem
    @Binding var numbers: [CoinListItem]
    let onDelete: (IndexSet) -> ()

    var body: some View {
        ZStack {
            if self.editMode?.wrappedValue != .active {
                Button(action: {
                    if let index = numbers.firstIndex(of: number) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                            self.onDelete(IndexSet(integer: index))
                        }
                    }
                    likeAction()
                    var tmpAlbums = getStrings(data: albums)

                    tmpAlbums.append("\(i.lottoNumbers)")

                    albums = Storage.archiveStringArray(object: tmpAlbums)
                }) {
                }
                .buttonStyle(HeartButtonStyle())
            }
        }
    }
    func getStrings(data: Data) -> [String] {
        return Storage.loadStringArray(data: data)
    }
}



struct CoinView: View {
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

    var body: some View {
        CoinButton(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            likes = []
            DispatchQueue.main.async {
                self.showSheet = true
            }
        }) { }
        .buttonStyle(PressableButtonStyle())
        .sheet(isPresented: $showSheet, content: {
            NavigationView {
                ZStack {
                    Color("darkBlue").opacity(0.4).ignoresSafeArea()
                    VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark, opacity: 0.9).ignoresSafeArea()

                    VStack {
                        ZStack {
                            Image("banner")
                                .resizable()
                                .scaledToFit()
                                .shadow(color: .black.opacity(0.9), radius: 40, x: 0, y: 0)
                                .offset(y: UIScreen.main.bounds.width / 20)

                            Spacer()
                            Button(action: {
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                                self.showSheet = false
                            }, label: {
                                Image("doneButton")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: UIScreen.main.bounds.width / 4.9)
                                    .shadow(color: .black.opacity(1), radius: 5, y: 5)
                            })
                            .buttonStyle(PlainButtonStyle())
                            .scaleEffect(donePressed ? 0.9 : 1)
                            .animation(.interpolatingSpring(mass: 0.5, stiffness: 350, damping: 9, initialVelocity: 1), value: donePressed)
                            .pressAction {
                                donePressed = true
                            } onRelease: {
                                donePressed = false
                            }
                            .offset(y: UIScreen.main.bounds.height / 4)

                            VStack {
                                List {
                                    Section(header: Text("")) {
                                        ForEach(savedArray) { i in
                                            HStack {
                                                Text(i.lottoNumbers)
                                                    .lineLimit(1)
                                                    .bold()
                                                    .font(.custom("Times New Roman", fixedSize: 25))
                                                    .padding(.vertical, 10)
                                                    .padding(0)
                                                Spacer()
                                                DeleteButton(
                                                    likes: $likes,
                                                    i: i,
                                                    number: i,
                                                    numbers: $savedArray,
                                                    onDelete: removeRows
                                                )
                                                .padding(0)
                                                .pressAction {
                                                    selected = i.id
                                                    plusPressed = true
                                                } onRelease: {
                                                    selected = UUID()
                                                    plusPressed = false
                                                }
                                            }
                                            .listRowSeparatorTint(.black)
                                            .padding(.horizontal)
                                            .edgesIgnoringSafeArea(.leading)
                                            .edgesIgnoringSafeArea(.trailing)
                                            .opacity(selected == i.id ? 0.3 : 1)
                                        }
                                        .onDelete(perform: removeRows)
                                        .multilineTextAlignment(.leading)
                                        .listRowBackground(Color.clear)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .listStyle(InsetGroupedListStyle())
                                .scrollContentBackground(.hidden)
                                .shadow(color: .black.opacity(0.5), radius: 20)
                                .frame(height: 320)
                                .toolbar {
                                    EditButton()
                                        .bold()
                                        .shadow(color: Color.white.opacity(0.5), radius: 8, x: 0, y: 2)
                                }
                            }

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

                        Text("Your ten most recently generated numbers will be shown here. Click the heart to save your favorite numbers")
                            .font(.custom("Helvetica", fixedSize: 16))
                            .foregroundColor(.white)
                            .frame(alignment: .center)
                            .padding()
                            .offset(y: -UIScreen.main.bounds.height / 25)
                            .multilineTextAlignment(.center)
                    }
                }
                .background(BackgroundClearView())
            }
            .background(BackgroundClearView())
        })
    }

    func removeRows(at offsets: IndexSet) {
        savedArray.remove(atOffsets: offsets)
    }
}



#Preview {
    CoinView(
        savedArray: .constant([
            CoinListItem(lottoNumbers: "5 - 12 - 23 - 34 - 56 | 9"),
            CoinListItem(lottoNumbers: "7 - 14 - 21 - 28 - 35 | 10"),
            CoinListItem(lottoNumbers: "3 - 11 - 18 - 26 - 39 | 15")
        ])
    )
    .environmentObject(NumberHold())
    .background(Color("darkBlue").ignoresSafeArea())
}


