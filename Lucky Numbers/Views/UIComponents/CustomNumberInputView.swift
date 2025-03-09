//
//  CustomNumberInputView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 3/1/25.
//

import SwiftUI
import Combine

struct CustomNumberInputView: View {
    @Binding var customNumbers: [Int]
    @Binding var itemToAdd: String

    var body: some View {
        ZStack {
            Color("darkBlue").opacity(0.4).ignoresSafeArea()
            VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark, opacity: 0.9)
                .ignoresSafeArea()
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
                        Button(action: { addItem() }) {
                            Image(systemName: "plus")
                                .padding(5)
                        }
                    }
                    ForEach(0..<customNumbers.count, id: \.self) { index in
                        HStack {
                            Text("\(customNumbers[index])")
                            Spacer()
                            Button(action: {
                                customNumbers.remove(at: index)
                            }) {
                                Image(systemName: "minus")
                                    .padding()
                            }
                        }
                    }
                    Button(action: {
                        // Dismiss sheet (the parent view will control the sheet)
                    }) {
                        Text("Done").bold()
                    }
                }
            }
            .frame(height: 400)
            .listStyle(InsetGroupedListStyle())
            .scrollContentBackground(.hidden)
            .shadow(color: .black.opacity(0.5), radius: 20)
            .presentationDetents([.medium, .fraction(0.7)])
            .background(BackgroundClearView())
        }
    }
    
    private func addItem() {
        if !itemToAdd.isEmpty, let num = Int(itemToAdd) {
            customNumbers.append(num)
            itemToAdd = ""
        }
    }
}
