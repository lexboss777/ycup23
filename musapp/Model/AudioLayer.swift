//
//  AudioLayer.swift
//  musapp
//
//  Created by Ilnur Shafigullin on 02.11.2023.
//

import Foundation

struct AudioLayer {
    let id: UUID
    let toolName: String
    let sample: AudioSample
    
    init(toolName: String, sample: AudioSample) {
        id = UUID()
        self.toolName = toolName
        self.sample = sample
    }
}
