//
//  RandomGen.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 11/13/22.
//


import SwiftUI
import GameKit


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


// Exclude function
extension ClosedRange where Element: Hashable {
    
    func random(without excluded:[Element]) -> Element {
        
        let valid = Set(self).subtracting(Set(excluded))
        let random = Int.random(in: 0...valid.count - 1)
        
        return Array(valid)[random]
    }
    
}


// Create array of unique random values excluding lux values
extension Int {
    
    static func getUniqueRndms(count: Int) -> [Int] {
        var set = Set<Int>()
        var set2 = Set<Int>()
        var dict = [Int]()
        
        while set.count < count {
            set.insert((1...70).random(without: luxNums))
        }
        
        dict = Array(set) + luxNums
        
        while set2.count < count {
            set2.insert((1...70).random(without: dict))
        }
        
        dict = dict + Array(set2)
        
        return dict
    }
}


// Create array of unique, unweighted random values
extension Int {
    
    static func getUnweightedRndms(count: Int) -> [Int] {
        var set = Set<Int>()
        var dict = [Int]()
        
        while set.count < count {
            set.insert(Int.random(in: 1...70))
        }
        
        dict = Array(set)
        dict = dict.sorted(by: { s1, s2 in return s1 < s2 } )
        
        return dict
    }
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


