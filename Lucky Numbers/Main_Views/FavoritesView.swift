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
                DispatchQueue.main.async {
                    self.showSheet = true
                }
            }){
                Image("heart")
                    .resizable()
                    .scaledToFit()
            }
            .frame(width:  UIScreen.main.bounds.width/10, height:  UIScreen.main.bounds.width/10)
            .shadow(color: .black .opacity(0.4), radius: 6, x: -2, y: 5)
            .offset(x: -UIScreen.main.bounds.width/2.8, y: -UIScreen.main.bounds.height/2.5)

                .fullScreenCover(isPresented: $showSheet, content: {
                    NavigationView {
                        ZStack {
                            Color("lightGreen").ignoresSafeArea()
                            Image("favorites")
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIScreen.main.bounds.width)
                                .shadow(color: .black.opacity(0.9), radius: 40, x: 0, y: 0)
                                .offset(y: -UIScreen.main.bounds.height/18)
                            
                            Spacer()
                            Button(action: {
                                self.showSheet = false
                                
                            }, label: {
                                Image("doneButton")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: UIScreen.main.bounds.width/5.9)
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
                            Text("Your favorite numbers will be stored here. Numbers will be lost if the app is deleted.")
                                .font(.custom( "Helvetica", fixedSize: UIScreen.main.bounds.height/50))
//                                .background(Color("lightGreen"))
                                .frame(alignment: .center)
                                .padding()
                                .offset(y: UIScreen.main.bounds.height/2.4)
                                .multilineTextAlignment(.center)
                        }
                        .toolbar{
                            ZStack{
                                EditButton()
                                    .bold()
                                    .shadow(color: Color.white.opacity(0.9), radius: 8, x: 0, y: 2)
                                            .shadow(color: Color.white.opacity(0.8), radius: 10, x: 0, y: 2)
                                            .shadow(color: Color.white.opacity(0.6), radius: 18, x: 0, y: 2)
                            }

                        }
                    }})
            
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
