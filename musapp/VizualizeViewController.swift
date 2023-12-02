import Foundation

import UIKit
import AudioKit
import AVFoundation

class VizualizeViewController: UIViewController {
    
    var threeDots: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        threeDots = ThreeDots()
        view.addSubview(threeDots)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        threeDots.sizeToFit()
        
        UIView.animate(withDuration: 5, delay: TimeInterval(0), options: [.repeat, .curveEaseIn], animations: { [self] () -> Void in
            
            let randomX = CGFloat.random(in: 14 ... 200)
            let randomY = CGFloat.random(in: 20 ... 600)
            
            threeDots.center = CGPoint(x: self.threeDots.frame.origin.x + randomX, y: threeDots.frame.origin.y + randomY)
            self.view.layoutIfNeeded()
        }, completion: { finished in
        })
    }
}
