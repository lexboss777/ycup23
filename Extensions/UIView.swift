//
//  ToolView.swift
//  musapp
//
//  Created by imac on 30.10.2023.
//

import Foundation
import UIKit

extension UIView {
    func setHeight(_ height: CGFloat) {
        frame = CGRect(frame.minX, frame.minY, frame.width, height)
    }

    func setWidth(_ width: CGFloat) {
        frame = CGRect(frame.minX, frame.minY, width, frame.height)
    }

    func move(_ x: CGFloat, _ y: CGFloat) {
        frame = CGRect(x, y, frame.width, frame.height)
    }

    func setLeft(_ x: CGFloat) {
        frame = CGRect(x, frame.minY, frame.width, frame.height)
    }

    func setTop(_ y: CGFloat) {
        frame = CGRect(frame.minX, y, frame.width, frame.height)
    }

    func setSize(_ w: CGFloat, _ h: CGFloat) {
        frame = CGRect(frame.minX, frame.minY, w, h)
    }

    func centerInView(_ inView: UIView) {
        frame = CGRect((inView.frame.width - frame.width) / 2, (inView.frame.height - frame.height) / 2, frame.width, frame.height)
    }

    func centerHorizontallyInView(_ inView: UIView) {
        frame = CGRect((inView.frame.width - frame.width) / 2, frame.minY, frame.width, frame.height)
    }
}
