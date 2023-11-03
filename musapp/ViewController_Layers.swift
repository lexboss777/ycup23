//
//  ViewController_Layers.swift
//  musapp
//
//  Created by Ilnur Shafigullin on 02.11.2023.
//

import Foundation
import UIKit

extension ViewController: UITableViewDataSource, UITableViewDelegate, LayerCellDelegate {
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return layers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LayerCell.identifier, for: indexPath) as! LayerCell
        
        let row = indexPath.row
        
        let layer = layers[row]
        
        cell.setData("\(layer.toolName.capitalized) \(layer.sample.name)")
        cell.setIsPlaying(layer.id == playingLayerUUID)
        cell.setIsMuted(layer.isMuted)
        cell.delegate = self
        cell.setIsSelected(layer === selectedLayer)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return layerCellH
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var reloadPaths: [IndexPath] = []
        
        if selectedPath != nil {
            reloadPaths.append(selectedPath!)
        }
        
        selectedLayer = layers[indexPath.row]
        selectedPath = indexPath
        
        reloadPaths.append(indexPath)
        tableView.reloadRows(at: reloadPaths, with: .none)
        
        speedSlider.value = maxSpeed - selectedLayer!.interval
    }
    
    // MARK: - LayerCellDelegate
    
    func delete(cell: LayerCell) {
        if let indexPath = layersTableView.indexPath(for: cell) {
            let row = indexPath.row
            let layer = layers[row]
            if layer.id == playingLayerUUID {
                stopPlayLayer()
            }
            
            layer.player?.stop()
            layer.player = nil
            
            if selectedLayer === layer {
                selectedLayer = nil
                selectedPath = nil
                updateSlidersVisibility()
            }
            
            layers.remove(at: row)
            updateLayers()
            
            if layers.isEmpty {
                stopMixIfPlaying()
            }
        }
    }
    
    func playOrStop(cell: LayerCell) {
        if let indexPath = layersTableView.indexPath(for: cell) {
            let layer = layers[indexPath.row]
            if layer.id == playingLayerUUID {
                stopPlayLayer()
            } else {
                play(layer: layer)
            }
            updateLayers()
        }
    }
    
    func muteOrUnmute(cell: LayerCell) {
        if let indexPath = layersTableView.indexPath(for: cell) {
            let layer = layers[indexPath.row]
            layer.isMuted.toggle()
            
            guard let player = layer.player else {
                return
            }
            
            if layer.isMuted {
                player.volume = 0
            } else {
                player.volume = 1
            }
        }
    }
}
