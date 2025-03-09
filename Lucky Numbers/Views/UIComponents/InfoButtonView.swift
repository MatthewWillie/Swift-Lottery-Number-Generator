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
                    .font(.system(size: 20))
                    .bold()
                    .foregroundColor(.white)
                Image(systemName: "info.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20, alignment: .trailing)
                    .foregroundColor(.white)
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
                            Image(systemName: "gearshape.2.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                            VStack(alignment: .leading, spacing: 10) {
                                Text("JackpotAI")
                                    .font(.custom("Times New Roman", fixedSize: 24))
                                    .bold()
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)

                                Text("JackpotAI is your ultimate AI-powered lottery companion, built to help you make smarter number selections using cutting-edge data analysis.")
                                    .font(.custom("Times New Roman", fixedSize: 20))

                                Text("AI Mode (Premium)")
                                    .font(.custom("Times New Roman", fixedSize: 22))
                                    .bold()
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)

                                Text("""
                                **Advanced Game-Specific Predictions:**  
                                Unlike any other number generator, **JackpotAI’s AI Mode deeply analyzes each individual lottery game** (Powerball, Mega Millions, EuroMillions, etc.) to **identify the numbers with the highest probability of being drawn**.  
                                - AI Mode uses **machine learning and historical data** to detect **hot numbers, cold numbers, and overdue trends** for each specific lottery.  
                                - Every AI-generated set is tailored **to that game’s unique draw history**, ensuring **you get the most optimized numbers possible**.  
                                - This is the **most advanced lottery prediction model available**, designed for serious players who want the best statistical edge.
                                """)
                                .font(.custom("Times New Roman", fixedSize: 20))

                                Text("Free Mode")
                                    .font(.custom("Times New Roman", fixedSize: 22))
                                    .bold()
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)

                                Text("""
                                **Smart Weighted Picks:**  
                                A great starting point! Free Mode **blends historical lottery data with randomness** for a balanced number selection:  
                                - JackpotAI **tracks frequently drawn numbers across multiple games** and **weights** them into each selection.  
                                - While not as advanced as AI Mode, Free Mode ensures **your numbers reflect real-world trends**, rather than pure randomness.
                                """)
                                .font(.custom("Times New Roman", fixedSize: 20))

                                Text("Your Jackpot Starts Here!")
                                    .font(.custom("Times New Roman", fixedSize: 22))
                                    .bold()
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)

                                Text("Ready to improve your lottery strategy? Try JackpotAI and let **data work in your favor.**")
                                    .font(.custom("Times New Roman", fixedSize: 20))
                                
                                // Legal Disclaimer Section
                                   Text("Disclaimer")
                                       .font(.custom("Times New Roman", fixedSize: 18))
                                       .bold()
                                       .multilineTextAlignment(.center)
                                       .frame(maxWidth: .infinity)
                                       .padding(.top, 10)

                                   Text("""
                                   JackpotAI is a fun and educational tool designed to enhance your lottery experience. While we analyze real historical data to generate numbers, we cannot guarantee winnings (we wish we could!).  
                                   Play responsibly, and remember—every number has an equal chance of winning, no matter what the AI says! 🎲🍀  
                                   """)
                                   .font(.custom("Times New Roman", fixedSize: 16))
                                   .italic()
                                   .multilineTextAlignment(.leading)
                                   .foregroundColor(.black)
                            }
                            .padding(.horizontal, 10)

                            .font(.custom("Times New Roman", fixedSize: 20))
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/1.7)
                .background(BackgroundClearView())
                .scrollContentBackground(.hidden)
                
                .listRowBackground(Color.clear)
                .frame(maxWidth: .infinity, alignment: .center)
                .offset(y: 20)
                
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    showSheet2 = false
                }
                       ,label: {
                    Image("doneButton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width/4.9)
                        .shadow(color: .black.opacity(1), radius: 5, y: 5)
                })
                .padding(13)
                .padding()
                .offset(y: UIScreen.main.bounds.height/2.8)
            }
            .preferredColorScheme(.light)
            .offset(y: UIScreen.main.bounds.height / -12)
        })
    }
}

#Preview {
    InfoButton()
}
