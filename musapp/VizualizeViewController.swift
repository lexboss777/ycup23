import Foundation

import UIKit
import AudioKit
import AVFoundation

class VizualizeViewController: UIViewController {
    
    var threeDots: UIView!
    var spiral: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        threeDots = ThreeDots()
        view.addSubview(threeDots)
        animateThreeDots()
        
        spiral = UIImageView(image: UIImage(named: "spiral")!)
        view.addSubview(spiral)
        animateSpiral()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let w = view.frame.width
        let h = view.frame.height
        
        threeDots.sizeToFit()
        
        if spiral != nil {
            spiral.move(0.2 * w, 0.6 * h)
        }
    }
    
    func animateThreeDots() {
        UIView.animate(withDuration: 5, delay: TimeInterval(0), options: [.repeat, .curveEaseIn], animations: { [self] () -> Void in
            
            let randomX = CGFloat.random(in: 14 ... 200)
            let randomY = CGFloat.random(in: 20 ... 600)
            
            threeDots.center = CGPoint(x: self.threeDots.frame.origin.x + randomX, y: threeDots.frame.origin.y + randomY)
            self.view.layoutIfNeeded()
        }, completion: { finished in
        })
    }
    
    func animateSpiral() {
        let duration: CFTimeInterval = 3
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2)
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount=Float.infinity
        spiral.layer.add(rotateAnimation, forKey: nil)
    }
}
