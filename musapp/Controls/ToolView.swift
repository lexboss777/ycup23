//
//  ToolView.swift
//  musapp
//
//  Created by imac on 30.10.2023.
//

import Foundation
import UIKit

protocol ToolViewDelegate: AnyObject {
    func toggled(toolView: ToolView)
}

class ToolView: UIView {
    
    // MARK: - properties
    
    private let iconImV = UIImageView()
    
    public var alignBottom = false {
        didSet { setNeedsLayout() }
    }
    
    public var isOpen: Bool = false
    
    public var options: [String] = []
    
    weak var delegate: ToolViewDelegate?
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        layer.cornerRadius = 25
        
        addSubview(iconImV)
        
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:))))
    }
    
    // MARK: - overridden base members
    
    override func sizeToFit() {
        
        if isOpen {
            UIView.animate(withDuration: 0.3, animations: {
                self.setHeight(300)
            })
        } else {
            
            let edgeSize = 61.0
            UIView.animate(withDuration: 0.3, animations: {
                self.setSize(edgeSize, edgeSize)
            })
            
            iconImV.sizeToFit()
            iconImV.centerHorizontallyInView(self)
            
            if alignBottom {
                iconImV.setTop(frame.height - iconImV.frame.height + 4)
            } else {
                iconImV.centerInView(self)
            }
        }
    }
    
    // MARK: - public methods
    
    func setData(_ icon: UIImage ) {
        iconImV.image = icon
    }
    
    func toggleOpen() {
        isOpen.toggle()
        backgroundColor = isOpen ? .accent : .white
        superview?.setNeedsLayout()
    }
    
    // MARK: - handlers
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            toggleOpen()
            delegate?.toggled(toolView: self)
        }
    }
}
