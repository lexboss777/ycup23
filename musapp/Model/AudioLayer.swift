//
//  AudioLayer.swift
//  musapp
//
//  Created by Ilnur Shafigullin on 02.11.2023.
//

import Foundation
import AudioKit

class AudioLayer {
    var player: AudioPlayer?
    let id: UUID
    let toolName: String
    let sample: AudioSample
    var interval: Float = 1
    var volume: Float = 1 {
        didSet {
            guard let player = player else {
                return
            }
            
            player.volume = volume
        }
    }
    
    var isMuted = false
    var isMicRecord = false
    
    init(toolName: String, sample: AudioSample) {
        id = UUID()
        self.toolName = toolName
        self.sample = sample
    }
}
