//
//  SoundPlayer.swift
//  barcode-reader-ios
//
//  Created by haayzaki on 2022/04/20.
//

import Foundation
import AVFoundation

struct SoundPlayer {
    var audioPlayer: AVAudioPlayer!

    enum SoundType: String {
        case pi = "pi.mp3"
    }

    mutating func play(soundType: SoundType, rate: Float = 0.5) {
        do {
            let filePath = Bundle.main.bundleURL.appendingPathComponent(soundType.rawValue)
            debugPrint("filePath", filePath)
            audioPlayer = try AVAudioPlayer(contentsOf: filePath)
            audioPlayer.enableRate = true
            audioPlayer.rate = rate
            audioPlayer.play()
        } catch {
            debugPrint("player error")
        }
    }
}
