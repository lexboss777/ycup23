import Foundation
import UIKit

struct YSText {
    static let baseName = "YandexSansText"

    static func regular(_ size: CGFloat) -> UIFont {
        return UIFont(name: "\(baseName)-Regular", size: size)!
    }
}
