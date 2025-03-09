//
//  FavoritesView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/17/25.
//

import SwiftUI



struct FavoritesView: View {
    @Environment(\.editMode) var editMode

    @State private var donePressed : Bool = false
    @State private var showSheet : Bool = false
    @State var savedArray : [CoinListItem] = []
    
    @AppStorage(UserKeys.userNumber.rawValue) var albums: Data = Data()
    
    var body: some View {
        
        ZStack{
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                DispatchQueue.main.async {
                    self.showSheet = true
                }
            }){
                VStack(spacing: -2){
                    Image("heart")
                        .resizable()
                        .scaledToFit()
                    Text("Favorites")
                        .font(.system(size: 12))
                        .foregroundColor(Color("gold"))
                        .shadow(color: Color("black").opacity(0.1), radius: 1, x: 2, y: 2)
                }
            }
            .buttonStyle(PressableButtonStyle())
            .frame(width:  UIScreen.main.bounds.width/6.5, height:  UIScreen.main.bounds.width/6.5)
            .shadow(color: Color("neonBlue").opacity(0.7), radius: 5, x: 1, y: 2)
            .shadow(color: Color("black").opacity(0.7), radius: 8, x: 3, y: 12)
            .offset(x: UIScreen.main.bounds.width / -3.3, y: -UIScreen.main.bounds.height / -5.5)

            .fullScreenCover(isPresented: $showSheet, content: {
                NavigationView {
                    ZStack {
                        Color("darkBlue").opacity(0.4).ignoresSafeArea()
                        VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark, opacity: 0.9).ignoresSafeArea()
                        Image("favorites")
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIScreen.main.bounds.width)
                            .shadow(color: .black.opacity(0.9), radius: 40, x: 0, y: 0)
                            .offset(y: -UIScreen.main.bounds.height/18)
                        
                        Spacer()
                        Button(action: {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            self.showSheet = false
                            
                        }, label: {
                            Image("doneButton")
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIScreen.main.bounds.width/4.9)
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
                        .offset(y: UIScreen.main.bounds.height/3.5)
                        ZStack {
                            List {
                                Section(header: Text("")) {
                                    
                                    ForEach (getStrings(data: albums), id:\.self) { s in
                                        HStack{
                                            Text(s)
                                                .lineLimit(1)
                                                .bold()
                                                .font(.custom("Times New Roman", fixedSize: 25))
                                                .padding(.vertical, 10)
                                                .padding(0)
                                            
                                            Spacer()
                                            
                                            ShareLink(item: s){
                                                Image(systemName:  "square.and.arrow.up").foregroundColor(.blue)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .padding(0)
                                            
                                        }
                                        .listRowSeparatorTint(.black)
                                        .padding(.horizontal)
                                        .edgesIgnoringSafeArea(.leading)
                                        .edgesIgnoringSafeArea(.trailing)
                                    }
                                    .onDelete(perform: {i in
                                        var tmpAlbums = getStrings(data: albums)
                                        
                                        tmpAlbums.remove(at: i.last!)
                                        
                                        albums = Storage.archiveStringArray(object: tmpAlbums)
                                        
                                        
                                    })
                                    .multilineTextAlignment(.leading)
                                    .listRowBackground(Color.clear)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .padding(0)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listStyle(InsetGroupedListStyle())
                            .scrollContentBackground(.hidden)
                            .shadow(color: .black.opacity(0.5), radius: 20)
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/1.8)
                            .offset(y: -UIScreen.main.bounds.height/18)
                            .padding(.leading, 0)
                        }
                        Text("Your favorite numbers will be stored here. Numbers may be lost if the app is deleted.")
                            .foregroundColor(.white)
                            .font(.custom( "Helvetica", fixedSize: UIScreen.main.bounds.height/50))
                        //                                .background(Color("lightGreen"))
                            .frame(alignment: .center)
                            .padding()
                            .offset(y: UIScreen.main.bounds.height/2.7)
                            .multilineTextAlignment(.center)
                    }
                    .background(BackgroundClearView())
                    .toolbar{
                        ZStack{
                            EditButton()
                                .bold()
                                .shadow(color: Color.white.opacity(0.9), radius: 8, x: 0, y: 2)

                        }
                        
                    }
                }
                .background(BackgroundClearView())
})
            
            }

        
    }
    func removeRows(at offsets: IndexSet) {
        
    }
    
    func getStrings(data: Data) -> [String] {
        return Storage.loadStringArray(data: data)
    }
}


struct Provider_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
    }
}
