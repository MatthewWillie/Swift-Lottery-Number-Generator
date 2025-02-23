//
//  OnBoard.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 11/13/22.
//


import SwiftUI
import Foundation



struct OnBoardView: View {
    @ObservedObject var controller : viewControl
    
    @State private var isPresented : Bool = false
    @State private var showSheet : Bool = false
    @AppStorage("onboarding") var isShowOnBoard : Bool = true
    @State private var buttonWidth : Double = UIScreen.main.bounds.width - 80
    @State private var buttonOffSet : CGFloat = 0
    @State private var isAnimating : Bool = false
    @State private var imageOffset : CGSize = .zero
    @State private var indicatorOpacity : Double = 1.0
    @State private var textTitle : String = "Generate & Win!"
    
    let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
//        ZStack{
        ZStack {
            
            //            Color("darkGreen").ignoresSafeArea()
            Image("backgroundMix")
                .resizable()
                .ignoresSafeArea()
            //                .opacity(0.1)
            Image("Luckies_Logo")
                .resizable()
                .scaledToFit()
                .opacity(0.25)
                ZStack{
                    VStack {
                        //MARK - Header
                        Spacer()
                        ZStack {
                            Text(textTitle)
                                .foregroundColor(.white)
                                .bold()
                                .font(.custom( "Helvetica", fixedSize: 45))                                .fontWeight(.heavy)
                                .transition(.opacity)
                                .id(textTitle)
                                .offset(y: -UIScreen.main.bounds.height/3)
                            Text("""
                    
                    Luckies Lotto Number Generator helps you pick the best numbers for the world’s biggest lotteries.  
                    Instead of guessing, use smart data-driven selections to improve your odds.  

                    Pick your numbers.  
                    Let the algorithm optimize your luck.  
                    Play smarter and win bigger.  
                    """)
                            .bold()
                            .font(.custom( "Helvetica", fixedSize: 25))                            .foregroundColor(.white)
                            .fontWeight(.medium)
                            .offset(y: -UIScreen.main.bounds.height/13)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                         
                        }
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : -40)
                        .offset(y: 0)
                        .animation(.easeOut(duration: 1.1).delay(1.7), value: isAnimating)
                        .onAppear() {
                            self.isAnimating = true
                                
                        }
                        
                        
                        ZStack {
                            Button(action: {
                                showSheet = true
                            },
                                   label: {
                                HStack {
                                    Text("How It Works")
                                        .font(.system(size: 20))
                                        .bold()
                                    Image(systemName: "info.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20, alignment: .trailing)
                                }
                            })
                            .offset(y: -UIScreen.main.bounds.height/14)
                        }
                        .frame(width: 200, height: 50)
                        
                        .sheet(isPresented: $showSheet, content: {
                            ZStack{
                                Image("infoBanner")
                                    .resizable()
                                    .scaledToFit()
                                    .shadow(color: .black.opacity(0.9), radius: 40, x: 0, y: 0)
                                    .offset(y: UIScreen.main.bounds.width/20)
                                
                                List {
                                    ZStack {
                                        VStack {
                                            //                                    VStack {
                                            Text("How It Works")
                                                .font(.system(.largeTitle))
                                                .bold()
                                                .underline()
                                            Text("""
                                            Luckies uses three powerful methods to generate your best possible lotto numbers.  

                                            """)
                                            .font(.custom( "Helvetica", fixedSize: 20))
                                            .multilineTextAlignment(.center)
                                            .bold()
                                            .padding(4)
                                            .frame(alignment: .center)
                                            Image(systemName: "gearshape.2.fill")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                            Text("""
                                        Lucky Mode  
                                        Some numbers appear more frequently in real lottery draws. We’ve analyzed five years of winning numbers to help you select the most common ones.  

                                         Select "Lucky" mode to let our proprietary algorithm generate numbers based on real-world winning patterns.  

                                        """)
                                            .font(.custom( "Helvetica", fixedSize: 20))
                                            .multilineTextAlignment(.center)
                                            .padding(4)
                                            Image(systemName: "gearshape.2.fill")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                            Text("""
                                        Random Mode  
                                        Want pure chance? "Random" mode generates completely unpredictable numbers, just like a real lottery draw.  

                                        """)
                                            .font(.custom( "Helvetica", fixedSize: 20))
                                            .multilineTextAlignment(.center)
                                            .padding(4)
                                            Image(systemName: "gearshape.2.fill")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                            Text("""
                                        Custom Mode  
                                        Pick your own lucky numbers—birthdays, anniversaries, favorite digits—it's up to you.  

                                          Your selected numbers receive a weighted boost in our algorithm, increasing their chances of appearing in your generated lotto picks.  

                                        """)
                                            .font(.custom( "Helvetica", fixedSize: 20))
                                            .multilineTextAlignment(.center)
                                            .padding(4)
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
                                    showSheet = false
                                }
                                       ,label: {
                                    Image("doneButton")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: UIScreen.main.bounds.width/5.9)
                                        .shadow(color: .black.opacity(1), radius: 5, y: 5)
                                })
                                .padding(13)
                                .foregroundColor(.white)
                                .padding()
                                .offset(y: UIScreen.main.bounds.height/2.45)
                            }
                            .preferredColorScheme(.light)
                            .background(Color("lightGreen"))
                        })
                        
                        
                        
                        ZStack {
                            //                    1. Background Static
                            Capsule()
                                .fill(.white.opacity(0.2))
                            Capsule()
                                .fill(.white.opacity(0.2))
                                .padding(8)
                            //                    2. Call to Action (static)
                            Text("Get Started")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .offset(x: 10)
                            Image(systemName: "chevron.right.2")
                                .font(.system(size: 24, weight: .bold))
                                .opacity(0.2)
                                .offset(x: 100)
                            //                    3. Capuse dynamic
                            HStack {
                                Capsule()
                                    .fill(.green.opacity(0.4))
                                //                            .fill(.green)
                                    .frame(width: buttonOffSet + 80)
                                Spacer()
                            }
                            //                    4. Circle
                            HStack {
                                ZStack() {
                                    Circle()
                                        .fill(.white.opacity(0.4))
                                    Circle()
                                        .fill(.black.opacity(0.7))
                                        .padding(8)
                                    Image(systemName: "chevron.right.2")
                                        .font(.system(size: 27, weight: .bold))
                                }
                                .foregroundColor(.green)
                                .frame(width: 80, height: 80, alignment: .center)
                                .offset(x: buttonOffSet)
                                .gesture(
                                    DragGesture()
                                        .onChanged({ gesture in
                                            if gesture.translation.width > 0 && buttonOffSet <= buttonWidth - 80 {
                                                buttonOffSet = gesture.translation.width
                                                
                                            }
                                            if gesture.translation.width > 0  {
                                                textTitle = "Pick Numbers!"
                                            }
                                            
                                        })
                                        .onEnded({ _ in
                                            withAnimation(Animation.easeOut(duration: 0.5)) {
                                                if buttonOffSet > buttonWidth/2 {
                                                    hapticFeedback.impactOccurred()
                                                    
                                                    buttonOffSet = buttonWidth - 80
                                                    controller.currentView = .SwiftUIView
                                                    isShowOnBoard = false
                                                } else {
                                                    hapticFeedback.impactOccurred()
                                                    buttonOffSet = 0
                                                    textTitle = "Generate & Win!"
                                                }
                                            }
                                        })
                                )
                                Spacer()
                            }
                        }// footer
                        .frame(width: buttonWidth,height: 80, alignment: .center)
                        .padding()
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 40)
                        .offset(y: -70)
                        .animation(.easeOut(duration: 1).delay(1.7), value: isAnimating)
                        
                    }
        
                }
      
        }// Zstack
        .onAppear {
            self.isAnimating = true
                
        }
        .preferredColorScheme(.light)
        
    }
}



struct MyPreviewProvider_Previews: PreviewProvider {
    static var previews: some View {
        
        OnBoardView(controller: viewControl())

//        HomeView(controller: viewControl())
//            .environmentObject(UserSettings(drawMethod: .Weighted))
//            .environmentObject(NumberHold())

    }
}







