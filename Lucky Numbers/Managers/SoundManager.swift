//
//  SoundManager.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 3/1/25.
//

import AVFoundation

class SoundManager {
    static var player: AVAudioPlayer?

    static func playSound(named soundName: String) {
        if let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
            } catch {
                print("❌ Could not play sound: \(error.localizedDescription)")
            }
        }
    }
}
