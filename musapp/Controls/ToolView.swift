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
    func tapped(toolView: ToolView)
    func sampleTapped(_ toolView: ToolView, _ sample: AudioSample)
}

class ToolView: UIView {
    
    // MARK: - properties
    
    private let iconImV = UIImageView()
    private let titleLabel = UILabel()
    private var buttons = Array<UIButton>()
    private var circleView = UIView()
    
    var samples: Array<AudioSample>!
    
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
        
        backgroundColor = .clear
        
        circleView.backgroundColor = .white
        
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        
        addSubview(circleView)
        circleView.layer.masksToBounds = true
        circleView.addSubview(iconImV)
        
        addSubview(titleLabel)
        
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:))))
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
    }
    
    // MARK: - overridden base members
    
    override func sizeToFit() {
        
        var animDuration = 0.3
        let edgeSize = 61.0
        let buttonsTopMargin = 23.0
        let buttonsBottomMargin = 38.0
        let buttonsInterMargin = 21.0
        
        if isOpen {
            
            var h = edgeSize + buttonsTopMargin
            
            for button in buttons {
                button.sizeToFit()
                button.centerHorizontallyInView(circleView)
                button.setTop(h)
                h += button.frame.height + buttonsInterMargin
            }
            
            UIView.animate(withDuration: animDuration, animations: {
                self.setHeight(h - buttonsInterMargin + buttonsBottomMargin)
                self.circleView.setHeight(h - buttonsInterMargin + buttonsBottomMargin)
            })
            
        } else {
            
            if frame.isEmpty {
                animDuration = 0
            }
            
            UIView.animate(withDuration: animDuration, animations: {
                self.setSize(edgeSize, edgeSize)
                self.circleView.setSize(edgeSize, edgeSize)
            })
            
            iconImV.sizeToFit()
            iconImV.centerHorizontallyInView(circleView)
            
            titleLabel.sizeToFit()
            titleLabel.centerHorizontallyInView(self)
            titleLabel.setTop(edgeSize + 9)
            
            if alignBottom {
                iconImV.setTop(circleView.frame.height - iconImV.frame.height + 4)
            } else {
                iconImV.centerInView(circleView)
            }
        }
        
        circleView.layer.cornerRadius = circleView.frame.width / 2
    }
    
    // MARK: - public methods
    
    func setData(_ icon: UIImage, _ title: String, _ samples: [AudioSample]) {
        iconImV.image = icon
        
        titleLabel.text = title
        
        for button in buttons {
            button.removeFromSuperview()
        }
        
        self.samples = samples
        
        for sample in samples {
            let button = UIButton(type: .system)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.setTitle(sample.name, for: .normal)
            button.setTitleColor(.black, for: .normal)
            buttons.append(button)
            circleView.addSubview(button)
            button.addTarget(self, action: #selector(sampleTapped), for: .touchUpInside)
        }
    }
    
    func toggleOpen() {
        isOpen.toggle()
        circleView.backgroundColor = isOpen ? .accent : .white
        titleLabel.isHidden = isOpen
        superview?.setNeedsLayout()
    }
    
    func getTitle() -> String? {
        return titleLabel.text
    }
    
    // MARK: - handlers
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            superview?.bringSubviewToFront(self)
            toggleOpen()
            delegate?.toggled(toolView: self)
        }
    }
    
    @objc func handleTap(_ gesture: UILongPressGestureRecognizer) {
        if !isOpen {
            delegate?.tapped(toolView: self)
        } else {
            toggleOpen()
            delegate?.toggled(toolView: self)
        }
    }
    
    @objc func sampleTapped(_ sender: UIButton) {
        if let index = buttons.firstIndex(of: sender) {
            let sample = samples[index]
            delegate?.sampleTapped(self, sample)
        }
    }
}
