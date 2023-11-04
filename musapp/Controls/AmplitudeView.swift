import Foundation
import UIKit

class AmplitudeView: UIView {
    var amplitudes: [CGFloat] = [] {
        didSet {
            currentTick += 1
            
            if currentTick == updateInterval {
                currentTick = 0
                setNextColor()
            }
            
            setNeedsDisplay()
        }
    }
    
    let updateInterval = 25
    var currentTick = 0
    
    let lineSpacing: CGFloat = 1.0
    var color = UIColor.white
    var currentColorIndex = 0
    
    let colors: [UIColor] = [
        .white,
        UIColor(0xF98022),
        UIColor(0x4DE28C),
        UIColor(0xBF5FFF)
    ]
    
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
    
    func setNextColor() {
        currentColorIndex += 1
        
        if currentColorIndex >= colors.count {
            currentColorIndex = 0
        }
        
        color = colors[currentColorIndex]
    }
}
