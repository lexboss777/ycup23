import Foundation

import UIKit
import AudioKit
import AVFoundation

class VizualizeViewController: UIViewController {
    
    var threeDots: UIView!
    var spiral: UIImageView!
    var zig: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        var backImg = UIImage(named: "back")
        backImg = backImg?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImg, style: .plain, target: self, action: #selector(goBack))
        
        threeDots = ThreeDots()
        view.addSubview(threeDots)
        animateThreeDots()
        
        spiral = UIImageView(image: UIImage(named: "spiral")!)
        view.addSubview(spiral)
        
        zig = UIImageView(image: UIImage(named: "zig")!)
        view.addSubview(zig)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        animateThreeDots()
        animateSpiral()
        animateZigZag()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        threeDots.layer.removeAllAnimations()
        spiral.layer.removeAllAnimations()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let w = view.frame.width
        let h = view.frame.height
        
        threeDots.sizeToFit()
        
        if spiral != nil {
            spiral.move(0.2 * w, 0.6 * h)
        }
        
        if zig != nil {
            zig.move(0.15 * w, 0.35 * h)
        }
    }
    
    func animateThreeDots() {
        UIView.animate(withDuration: 5, delay: TimeInterval(0), options: [.repeat, .curveEaseIn], animations: { [self] () -> Void in
            
            let randomX = CGFloat.random(in: 14 ... 200)
            let randomY = CGFloat.random(in: 20 ... 600)
            
            threeDots.center = CGPoint(x: self.threeDots.frame.origin.x + randomX, y: threeDots.frame.origin.y + randomY)
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
        spiral.layer.add(rotateAnimation, forKey: "spiral")
    }
    
    func animateZigZag() {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        
        animation.values = [1.0, 1.2, 1.0]
        animation.keyTimes = [0, 0.5, 1]
        animation.duration = 1.5
        animation.repeatCount = Float.infinity
        zig.layer.add(animation, forKey: "zigzag")
    }
    
    @objc func goBack(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}
