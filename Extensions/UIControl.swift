//
//  UIControl.swift
//  musapp
//
//  Created by Ilnur Shafigullin on 02.11.2023.
//

import UIKit

extension UIControl {
    func addAction(for controlEvents: UIControl.Event = .touchUpInside, _ closure: @escaping()->()) {
        addAction(UIAction { (action: UIAction) in closure() }, for: controlEvents)
    }
}
