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
        
        cell.setData(layer.sample.name)
        cell.delegate = self
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return layerCellH
    }
    
    // MARK: - LayerCellDelegate
    
    func delete(cell: LayerCell) {
        if let indexPath = layersTableView.indexPath(for: cell) {
            layers.remove(at: indexPath.row)
            updateLayers()
        }
    }
}
