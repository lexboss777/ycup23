import Foundation
import UIKit

class VolumeSlider: UISlider {

    let tickCount = 30.0
    let longTickInterval = 5

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.clear(rect)

        context.setStrokeColor(UIColor.white.cgColor)

        let step = rect.width / tickCount
        let stepRounded = floor(step * 2) / 2

        for i in 0...Int(tickCount) {
            let x = CGFloat(i) * stepRounded + 4

            let h = i % longTickInterval == 0 ? rect.height : rect.height / 2
            let tickRect = CGRect(x: x, y: 0, width: 1.0, height: h)
            context.stroke(tickRect)
        }
    }
}
