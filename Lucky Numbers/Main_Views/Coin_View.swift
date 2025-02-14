//
//  Coin_View.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 11/18/22.
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
        .foregroundColor(isAnimating ? .red : .white)
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
                    .foregroundColor(configuration.isPressed ? .red : .white)
                Image(systemName: "heart")
                .scaleEffect(configuration.isPressed ? 0.1 : 1.0)

                    .font(.system(size: 20))
                    .foregroundColor(configuration.isPressed ? .red : .white)
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
    @State var likes :[LikeView] = []
    @Environment(\.editMode) private var editMode

    
    func likeAction () {
        likes += [LikeView()]
    }
    @EnvironmentObject var numberHold: NumberHold
    @AppStorage(UserKeys.userNumber.rawValue) var albums: Data = Data()
    @State private var selected : UUID = UUID()

    @State private var isAnimating : Bool = false
    @State private var num : Int = 0
    @State private var showSheet : Bool = false

    @State private var donePressed : Bool = false
    @State private var plusPressed : Bool = false

    @Binding var savedArray : [CoinListItem]
    @Binding var firstClick : Int
    
    var body: some View {
        
            CoinButton(action: {
                likes = []
                DispatchQueue.main.async {
                        self.showSheet = true
                }
            }){}
                .buttonStyle(PlainButtonStyle())

                .sheet(isPresented: $showSheet, content: {
                    NavigationView {
                        VStack{
                            ZStack{
                                Color("lightGreen").ignoresSafeArea()
                                Image("banner")
                                    .resizable()
                                    .scaledToFit()
                                    .shadow(color: .black.opacity(0.9), radius: 40, x: 0, y: 0)
                                    .offset(y: UIScreen.main.bounds.width/20)
                                
                                Spacer()
                                Button(action: {
                                    self.showSheet = false
                                }, label: {
                                    Image("doneButton")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: UIScreen.main.bounds.width/5.6)
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
                                .offset(y: UIScreen.main.bounds.height/3.8)
                                VStack{
                                    List {
                                        Section(header: Text("")) {
                                            ForEach(savedArray) { i in
                                                if firstClick > 1 {
                                                    HStack {
                                                        Text(i.lottoNumbers)
                                                            .lineLimit(1)
                                                            .bold()
                                                            .font(.custom("Times New Roman", fixedSize: 25))
                                                            .padding(.vertical, 10)
                                                            .padding(0)
                                                        Spacer()
                      
                                                        DeleteButton(likes: $likes, i: i, number: i, numbers: $savedArray, onDelete: removeRows)
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
                                    .offset(y: 0)
                                    .padding(.leading, 0)
                                    //                                .padding(.trailing, 0)
                                    .toolbar{
                                        EditButton()
                                            .bold()
                                        
                                    }
                                }
                                
                                ZStack {
                                    ForEach (likes) { like in
                                        like.image.resizable()
                                            .frame(width: 50, height: 50)
                                            .modifier(LikeTapModifier())
                                        //                                    .padding()
                                            .id(like.id)
                                    }.onChange(of: likes) { newValue in
                                        if likes.count > 5 {
                                            likes.removeFirst()
                                        }
                                    }
                                }
                            }

                            Text("Your ten most recently generated numbers will be shown here. Click the heart to save your favorite numbers")
                                .font(.custom( "Helvetica", fixedSize: 16))
                                .frame(alignment: .center)
                                .padding()
                                .offset(y: -UIScreen.main.bounds.height/25)
                                .multilineTextAlignment(.center)

                            
                        }
                        .background(Color("lightGreen")).ignoresSafeArea()

                    }
                })
        
        
    }
    func removeRows(at offsets: IndexSet) {
        savedArray.remove(atOffsets: offsets)
    }
    func getStrings(data: Data) -> [String] {
        return Storage.loadStringArray(data: data)
    }
    func addAlbum() {
        var tmpAlbums = getStrings(data: albums)
        
        for i in savedArray {
            tmpAlbums.append("\(i)")
        }
        albums = Storage.archiveStringArray(object: tmpAlbums)
    }
}



struct MyView_Previews: PreviewProvider {
    static var previews: some View {

        ZStack {
            Color.green.ignoresSafeArea()
            InfoButton()
            BallDropButton()
                .environmentObject(NumberHold())
                .environmentObject(UserSettings(drawMethod: .Weighted))
                .environmentObject(CustomRandoms())

            FavoritesView()
//            LikeButton()

        }
    }
}


