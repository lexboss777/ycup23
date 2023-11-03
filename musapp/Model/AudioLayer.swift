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
    
    init(toolName: String, sample: AudioSample) {
        id = UUID()
        self.toolName = toolName
        self.sample = sample
    }
}
