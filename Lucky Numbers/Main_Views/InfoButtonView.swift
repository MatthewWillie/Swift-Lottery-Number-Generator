//
//  InfoButtonView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 12/6/22.
//

import SwiftUI



struct InfoButton: View {
    
    @State private var showSheet2 : Bool = false

    var body: some View {
        Button(action: {
            showSheet2 = true
        },
               label: {
            HStack {
                Text("How It Works")
                    .font(.system(size: 15))
                    .bold()
                Image(systemName: "info.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18, alignment: .trailing)
            }
        })
        .opacity(0.7)
        .offset(y: UIScreen.main.bounds.height/4.9)
        .buttonStyle(PlainButtonStyle())
                
        .sheet(isPresented: $showSheet2, content: {
            ZStack{
                Image("infoBanner")
                    .resizable()
                    .scaledToFit()
                    .shadow(color: .black.opacity(0.9), radius: 40, x: 0, y: 0)
                    .offset(y: UIScreen.main.bounds.width/20)
                
                List {
                    ZStack {
                        VStack {
                            Text("How It Works")
                                .font(.system(.largeTitle))
                                .bold()
                                .underline()
                            Text("""
                                *Lucky Numbers* uses three different methods to generate the best possible lotto numbers.
                            """)
                            .font(.custom( "Times New Roman", fixedSize: 20))
                            .bold()
                            .padding(10)
//                            .frame(alignment: .center)
                            Image(systemName: "gearshape.2.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                            Text("""
                                **Lucky:**  In live lotteries, certain numbers tend to show up more frequently than others. We've gathered those stats over the past 5 years, and use them in your favor! Generating lotto numbers based on those tendancies gives you a better chance of winning!
                                When the "Lucky" setting is selected in the bottom picker, *Lucky Numbers* uses a proprietary algorithm to randomly select lotto numbers at the same frequency that those numbers are picked in live lotteries. They're your lucky numbers!
                            """)
                            .font(.custom( "Times New Roman", fixedSize: 20))
                            .padding(10)
                            Image(systemName: "gearshape.2.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                            Text("""
                                **Random:**  When the "Random" setting is selected, numbers are generated on a completely random basis. It's Chance!
                                """)
                            .font(.custom( "Times New Roman", fixedSize: 20))
                            .padding(10)
                            Image(systemName: "gearshape.2.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                            Text("""
                                **Custom:**  When the "Custom" setting is selected, you take chance into your own hands!
                                Click on the "Custom" tab, and enter any of your preferred lucky numbers. You can use any whole numbers between 1 and 70, such as birthdays, 2-digit years, your age, or any other numbers you'd like. Your numbers are then given a weighted value, and new lotto numbers are generated, making your custom numbers as the most likely numbers to appear.
                            
                            """)
                            .font(.custom( "Times New Roman", fixedSize: 20))
                            .padding(10)
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/1.5)
                .background(BackgroundClearView())
                .scrollContentBackground(.hidden)
                
                .listRowBackground(Color.clear)
                .frame(maxWidth: .infinity, alignment: .center)
                .offset(y: 20)
                
                Button(action: {
                    showSheet2 = false
                }
                       ,label: {
                    Image("doneButton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width/5.9)
                        .shadow(color: .black.opacity(1), radius: 5, y: 5)
                })
                .padding(13)
                .padding()
                .offset(y: UIScreen.main.bounds.height/2.45)
            }
            .preferredColorScheme(.light)
            .background(Color("lightGreen"))
        })
        
    }
}

