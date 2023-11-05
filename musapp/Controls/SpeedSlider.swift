import Foundation
import UIKit

class SpeedSlider: UISlider {

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.clear(rect)

        context.setStrokeColor(UIColor.white.cgColor)

        let padding = 4.0
        var step = 3.0
        var x = rect.width - padding
        var c = 0

        while x >= padding {

            let w = 0.5
            let tickRect = CGRect(x: x, y: 0, width: w, height: rect.height)
            context.stroke(tickRect)

            x -= step + w

            if c == 5 {
                step = 5.0
            } else if c == 9 {
                step = 7.0
            } else if c == 10 {
                step = 8.0
            } else if c == 13 {
                step = 9.0
            } else if c == 18 {
                step = 10.0
            }

            c += 1
        }
    }
}
