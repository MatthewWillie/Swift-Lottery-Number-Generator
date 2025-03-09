//
//  Extensions.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 12/6/22.
//

import SwiftUI

extension View {
    func shimmering(active: Bool) -> some View {
        self.overlay(
            LinearGradient(
                gradient: Gradient(colors: [.clear, .white.opacity(0.4), .clear]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .rotationEffect(.degrees(40))
            .offset(x: active ? 200 : -200)
            .mask(self)
            .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: active)
        )
    }
}


// MARK: - Conditional Modifier Extension
extension View {
    @ViewBuilder
    func conditionalModifier<Content: View>(
        _ condition: Bool,
        modifier: (Self) -> Content
    ) -> some View {
        if condition {
            modifier(self)
        } else {
            self
        }
    }
}


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


// MARK: - Color Extension (Hex initializer)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
