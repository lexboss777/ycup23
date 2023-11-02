//
//  YSText.swift
//  musapp
//
//  Created by Ilnur Shafigullin on 02.11.2023.
//

import Foundation
import UIKit

struct YSText {
    static let baseName = "YSText"

    static func regular(_ size: CGFloat) -> UIFont {
        UIFont.systemFont(ofSize: size)
        //return UIFont(name: "\(baseName)-Regular", size: size)!
    }
}
