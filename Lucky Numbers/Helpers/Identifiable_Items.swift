//
//  Identifiable_Items.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 12/6/22.
//

import SwiftUI


struct CoinListItem: Identifiable, Codable, Equatable {
    public var id : UUID = UUID()
    public var lottoNumbers: String
}

struct ListItem: Identifiable {
    public var id : UUID = UUID()
    public var array: [String]
}

struct LikeView : Identifiable, Equatable {
    let image = Image(systemName: "heart.fill")
    let id = UUID()
}

