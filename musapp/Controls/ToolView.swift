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
    private var buttons = Array<UIButton>()
    
    public var alignBottom = false {
        didSet { setNeedsLayout() }
    }
    
    public var isOpen: Bool = false
    
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
        
        let animDuration = 0.3
        let edgeSize = 61.0
        let buttonsTopMargin = 23.0
        let buttonsBottomMargin = 38.0
        let buttonsInterMargin = 21.0
        
        if isOpen {
            
            var h = edgeSize + buttonsTopMargin
            
            for button in buttons {
                button.sizeToFit()
                button.centerHorizontallyInView(self)
                button.setTop(h)
                h += button.frame.height + buttonsInterMargin
            }
            
            UIView.animate(withDuration: animDuration, animations: {
                self.setHeight(h - buttonsInterMargin + buttonsBottomMargin)
            })
            
        } else {
            
            UIView.animate(withDuration: animDuration, animations: {
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
    
    func setData(_ icon: UIImage, _ options: [String]) {
        iconImV.image = icon
        
        for button in buttons {
            button.removeFromSuperview()
        }
        
        for option in options {
            let button = UIButton(type: .system)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.setTitle(option, for: .normal)
            button.setTitleColor(.black, for: .normal)
            buttons.append(button)
            addSubview(button)
        }
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
