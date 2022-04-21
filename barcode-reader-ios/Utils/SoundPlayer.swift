//
//  SoundPlayer.swift
//  barcode-reader-ios
//
//  Created by haayzaki on 2022/04/20.
//

import Foundation
import AVFoundation
import DequeModule

class SoundPlayer : NSObject {
    var audioPlayer: AVAudioPlayer!
    var playFilesQueue = Deque<(filePath: URL, rate: Float)>()
    var isPlaying = false

    enum SoundType: String {
        case pi = "pi.mp3"
        case en = "en.mp3"
    }

    func play(soundType: SoundType, rate: Float = 0.5) {
        self.play(fileName: soundType.rawValue, rate: rate)
    }
    
    func play(fileName: String, rate: Float = 0.5) {
        let filePath = Bundle.main.bundleURL.appendingPathComponent(fileName)
        let playFileItem = (filePath: filePath, rate: rate)
        self.playFilesQueue.append(playFileItem)
        self.startPlay()
    }

    func playForPrice(_ price: Int) {
        self.play(soundType: .pi)
        // TODO: 複数桁対応
        self.play(fileName: "\(String(price)).mp3", rate: 1)
        self.play(soundType: .en, rate: 1)
    }
    
    func startPlay() {
        if (isPlaying) {
            return
        }
        isPlaying = true
        self.playFileInQueue()
    }
    
    func playFileInQueue() {
        guard let playFileItem = playFilesQueue.popFirst() else {
            return
        }
        do {
            debugPrint("filePath", playFileItem.filePath)
            audioPlayer = try AVAudioPlayer(contentsOf: playFileItem.filePath)
            audioPlayer.delegate = self
            audioPlayer.enableRate = true
            audioPlayer.rate = playFileItem.rate
            audioPlayer.play()
        } catch {
            debugPrint("player error")
        }
    }
}

extension SoundPlayer : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if (playFilesQueue.count == 0) {
            self.isPlaying = false
            return
        }
        playFileInQueue()
    }
}
