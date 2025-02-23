//
//  Extensions.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 12/6/22.
//

import SwiftUI



extension View {
    func pressAction(onPress: @escaping (() -> Void), onRelease: @escaping (() -> Void)) -> some View {
        modifier(PressActions(onPress: {
            onPress()
        }, onRelease: {
            onRelease()
        }))
    }
}

enum UserKeys: String, CaseIterable{
    case userNumber = "USER_NUMBER"
}

extension UserDefaults {
    func resetUser(){
        UserKeys.allCases.forEach{
            removeObject(forKey: $0.rawValue)
        }
    }
}


extension View {
    
    func addGlowEffect(color1:Color, color2:Color, color3:Color) -> some View {
        self
            .foregroundColor(Color(hue: 1, saturation: 0, brightness: 1))
            .background {
                self
                    .foregroundColor(color1).blur(radius: 2).brightness(0.8)
            }
            .background {
                self
                    .foregroundColor(color2).blur(radius: 6).brightness(1)
            }
            .background {
                self
                    .foregroundColor(color3).blur(radius: 5).brightness(1)
            }
            .background {
                self
                    .foregroundColor(color3).blur(radius: 8).brightness(1)
                
            }
    }
}


// Random Number Extensions-------------------------


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

extension LottieView {
    func persistent(withID id: String = "UniqueLottieAnimationView") -> some View {
        self.id(id)
    }
}
