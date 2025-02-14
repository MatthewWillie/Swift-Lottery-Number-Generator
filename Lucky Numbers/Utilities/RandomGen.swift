//
//  RandomGen.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 11/13/22.
//


import SwiftUI
import GameKit


//  Most commonly chosen lotto numbers------------------
let luxNums = [68, 16, 22, 42, 37, 44, 28, 53, 20, 3, 62, 14, 10, 17, 64, 32, 8, 59, 27, 15, 56, 40, 6, 18]


// Gaussian Distribution
func random(count: Int, in range: ClosedRange<Int>, mean: Int, deviation: Int) -> [Int] {
    guard count > 0 else { return [] }
    
    let randomSource = GKARC4RandomSource()
    let randomDistribution = GKGaussianDistribution(randomSource: randomSource, mean: Float(mean), deviation: Float(deviation))
    var set = Set<Int>()
    
    // Clamp the result to range
    while set.count < count {
        
        let rnd = randomDistribution.nextInt()
        
        if rnd < range.lowerBound {
            continue
        } else if rnd > range.upperBound {
            continue
        } else {
            set.insert(rnd)
        }
    }
    
    return Array(set)
}


var lottoPicks = Int.getUniqueRndms(count: 23)


// Fill array with final 5 lotto numbers
func pickFive(lottoPicks: [Int]) -> [Int] {
    
    var list = [Int]()
    var dict = [Int]()
    
    let arr = random(count: 5, in: 1...70, mean: 35, deviation: 20)
    
    for (_, element) in arr.enumerated() {
        list.append(lottoPicks[element - 1])
    }
    
    dict = list.sorted(by: { s1, s2 in return s1 < s2 } )
    return dict
}


// Fill array with final 5 CUSTOM lotto numbers
func pickCustom(customArray: [Int]) -> [Int] {
    
    var list = [Int]()
    var dict = [Int]()
    
    let arr = random(count: 5, in: 1...70, mean: 35, deviation: 10)
    
    for (_, element) in arr.enumerated() {
        list.append(customArray[element - 1])
    }
    
    dict = list.sorted(by: { s1, s2 in return s1 < s2 } )
    return dict
}

