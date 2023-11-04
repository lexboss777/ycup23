import Foundation
import UIKit

class AmplitudeView: UIView {
    var amplitudes: [CGFloat] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    let lineSpacing: CGFloat = 1.0
    let color = UIColor.accent
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.clear(rect)
        context.setFillColor(color.cgColor)
        
        let rectWidth = (rect.width - lineSpacing * CGFloat(amplitudes.count - 1)) / CGFloat(amplitudes.count)
        let maxHeight = rect.height
        
        for (index, amplitude) in amplitudes.enumerated() {
            let x = CGFloat(index) * (rectWidth + lineSpacing)
            let height = maxHeight * amplitude
            
            let lineRect = CGRect(x: x, y: rect.height - height, width: rectWidth, height: height)
            context.fill(lineRect)
        }
    }
}
