//
//  YSText.swift
//  musapp
//
//  Created by Ilnur Shafigullin on 02.11.2023.
//

import Foundation
import UIKit

struct YSText {
    static let baseName = "YandexSansText"

    static func regular(_ size: CGFloat) -> UIFont {
        return UIFont(name: "\(baseName)-Regular", size: size)!
    }
}
