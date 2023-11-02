//
//  LayerCell.swift
//  musapp
//
//  Created by Ilnur Shafigullin on 02.11.2023.
//

import Foundation
import UIKit

protocol LayerCellDelegate: AnyObject {
    func play(cell: LayerCell)
    func delete(cell: LayerCell)
}

class LayerCell: UITableViewCell {
    
    // MARK: - declaration
    
    static let identifier = "layer_cell"
    
    private let topPadding = 7.0
    private let rad = 4.0
    
    
    // MARK: - properties
    
    private var containerView = UIView()
    
    private var titleLabel = UILabel()
    
    private var deleteBtn = UIButton(type: .system)
    private var muteBtn = UIButton(type: .system)
    private var playBtn = UIButton(type: .system)
    
    var delegate: LayerCellDelegate?
    
    // MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: LayerCell.identifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        selectionStyle = .none
        backgroundColor = .clear
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = rad
        contentView.addSubview(containerView)
        
        titleLabel.font = YSText.regular(12)
        containerView.addSubview(titleLabel)
        
        containerView.addSubview(deleteBtn)
        deleteBtn.addAction {
            self.delegate?.delete(cell: self)
        }
        configure(btn: deleteBtn, "xmark", UIColor(0xE4E4E4))
        
        containerView.addSubview(muteBtn)
        configure(btn: muteBtn, "speaker.slash.fill", UIColor.white)
        
        containerView.addSubview(playBtn)
        playBtn.addAction {
            self.delegate?.play(cell: self)
        }
        configure(btn: playBtn, "play.fill", UIColor.white)
    }
    
    // MARK: - private methods
    
    private func configure(btn: UIButton, _ img: String, _ bgColor: UIColor) {
        
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = bgColor
        configuration.baseForegroundColor = .black
        configuration.image = getImage(img)
        
        btn.layer.cornerRadius = rad
        btn.configuration = configuration
    }
    
    private func getImage(_ name: String) -> UIImage? {
        return UIImage(systemName: name)?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold));
    }
    
    // MARK: - overridden base members
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.setWidth(frame.width)
        containerView.setHeight(frame.height - topPadding)
        containerView.setTop(topPadding)
        
        let titleLeftMargin = 10.0
        titleLabel.sizeToFit()
        titleLabel.setTop((containerView.frame.height - titleLabel.frame.height) / 2)
        titleLabel.setLeft(titleLeftMargin)
        
        let btnEdge = containerView.frame.height
        
        deleteBtn.frame = CGRect(containerView.frame.width - btnEdge, 0, btnEdge, btnEdge)
        muteBtn.frame = CGRect(deleteBtn.frame.minX - btnEdge, 0, btnEdge, btnEdge)
        playBtn.frame = CGRect(muteBtn.frame.minX - btnEdge, 0, btnEdge, btnEdge)
    }
    
    // MARK: - public methods
    
    func setData(_ title: String) {
        titleLabel.text = title
    }
}
