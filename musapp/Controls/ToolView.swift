//
//  ToolView.swift
//  musapp
//
//  Created by imac on 30.10.2023.
//

import Foundation
import UIKit

class ToolView: UIView {
    
    // MARK: - properties
    
    private let iconImV = UIImageView()
    
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
        addSubview(iconImV)
    }
    
    // MARK: - overridden base members
    
    override func layoutSubviews() {
        
        iconImV.sizeToFit()
        iconImV.centerHorizontallyInView(self)
        iconImV.setTop(frame.height - iconImV.frame.height + 4)
    }
    
    // MARK: - public methods
    
    func setData(_ icon: UIImage ) {
        iconImV.image = icon
    }
}
