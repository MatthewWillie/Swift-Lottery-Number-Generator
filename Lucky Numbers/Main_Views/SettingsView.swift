//
//  SettingsView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/21/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .bold()
                .padding(.top, 20)

            Spacer()
            
            Text("Settings options will be available here.")
                .font(.headline)
                .foregroundColor(.gray)
                .padding()

            Spacer()
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}
