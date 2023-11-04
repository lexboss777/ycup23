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
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        configuration = UIButton.Configuration.filled()
        configuration!.baseBackgroundColor = .white
        configuration!.baseForegroundColor = .black
        configuration!.image = getImage("chevron.up")
        configuration!.titlePadding = 10
        configuration!.imagePadding = 10
        configuration!.imagePlacement = .trailing
        configuration!.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    private func getImage(_ name: String) -> UIImage? {
        return UIImage(systemName: name)?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold));
    }
    
    @objc private func buttonTapped() {
        isExpanded.toggle()
        
        if isExpanded {
            configuration?.image = getImage("chevron.down")
            configuration?.baseBackgroundColor = .accent
        } else {
            configuration?.image = getImage("chevron.up")
            configuration?.baseBackgroundColor = .white
        }
    }
    
    public func setTitle(_ title: String) {
        configuration?.attributedTitle = AttributedString(title, attributes: AttributeContainer([NSAttributedString.Key.font : YSText.regular(14)]))
    }
}
