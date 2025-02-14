//
//  Observables.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 12/6/22.
//

import SwiftUI

class CustomRandoms: ObservableObject {
    
    @Published var dict2 = [0,0,0,0,0,0]
    
    func getCustomRandoms(customArray: [Int]) -> [Int] {

        let red = Int.random(in: 1...26)
        
        var count = 0
        if customArray.count == 0 {
            count = 35
        }
        else if customArray.count % 2 == 0 {
            count = 35 - (customArray.count/2)
        }
        else {
            count = customArray.count + 1
            count = 35 - (count/2)
        }
        
        var set = Set<Int>()
        var set2 = Set<Int>()
        var dict = [Int]()
        var dict2 = [Int]()
        
        while set.count < count {
            set.insert((1...70).random(without: customArray))
        }
        
        dict = Array(set) + customArray
        
        while set2.count < count {
            set2.insert((1...70).random(without: dict))
        }
        
        dict = dict + Array(set2)
        dict2 = pickCustom(customArray: dict)
        dict2.append(red)
        
        return dict2
    }
}


class UserSettings: ObservableObject {
    

    enum numberType: String, Identifiable, CaseIterable {
        var id: String {self.rawValue}

        case Random
        case Weighted
        case Custom

    }
    @Published var drawMethod: numberType


    init(drawMethod: numberType) {
        self.drawMethod = drawMethod

    }
    
}


public func randomSet() -> [Int] {
    let red = Int.random(in: 1...26)


    var randomArray = Int.getUnweightedRndms(count: 5)
    
    randomArray.append(red)

    return randomArray
}

public func weightedSet() -> [Int] {
    let red = Int.random(in: 1...26)

    var weightedArray = pickFive(lottoPicks: lottoPicks)

    weightedArray.append(red)
    
    return weightedArray

}

class NumberHold: ObservableObject {

    @Published var randomArray = [0,0,0,0,0]
    @Published var weightedArray = [0,0,0,0,0]

    func update() {

        weightedArray = weightedSet()
        randomArray = randomSet()

    }
}
