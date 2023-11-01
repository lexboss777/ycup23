//
//  FlipButton.swift
//  musapp
//
//  Created by imac on 31.10.2023.
//

import UIKit

class ToggleButton: UIButton {
    private var isExpanded = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    private func setupButton() {
        titleLabel?.font = UIFont.systemFont(ofSize: 14)
        contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        setTitleColor(.black, for: .normal)
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc private func buttonTapped() {
        isExpanded.toggle()
        
        if isExpanded {
            backgroundColor = .accent
        } else {
            backgroundColor = .white
        }
    }
}
