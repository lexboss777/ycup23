import Foundation

import UIKit
import AudioKit
import AVFoundation

class VizualizeViewController: UIViewController {
    
    let playIcon = "play.fill"
    let pauseIcon = "pause.fill"
    
    var threeDots: UIView!
    var spiral: UIImageView!
    var zig: UIImageView!
    
    var isAnimatingPrivate = true
    
    var isAnimating: Bool {
        
        guard let mainVC = mainVC else { return isAnimatingPrivate }
        
        return mainVC.isPlayingMix
    }
    
    var playBtn: UIButton!
    
    weak var mainVC: ViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        title = "Название трека"
        
        var backImg = UIImage(named: "back")
        backImg = backImg?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImg, style: .plain, target: self, action: #selector(goBack))
        
        threeDots = ThreeDots()
        view.addSubview(threeDots)
        
        spiral = UIImageView(image: UIImage(named: "spiral")!)
        view.addSubview(spiral)
        
        zig = UIImageView(image: UIImage(named: "zig")!)
        view.addSubview(zig)
        
        playBtn = createButton(pauseIcon, 18)
        playBtn.configuration!.image = self.getImage(isAnimating ? pauseIcon : playIcon)
        playBtn.addAction { [weak self] in
            guard let self = self else { return }
            self.playBtnClicked()
        }
        view.addSubview(playBtn)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isAnimating {
            startAnimations()
        }
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
        
        if playBtn != nil {
            playBtn.sizeToFit()
            playBtn.centerHorizontallyInView(self.view)
            playBtn.setTop(view.frame.height - playBtn.frame.height - 40)
        }
    }
    
    func startAnimations() {
        animateThreeDots()
        animateSpiral()
        animateZigZag()
    }
    
    func stopAnimations() {
        threeDots.layer.removeAllAnimations()
        spiral.layer.removeAllAnimations()
        zig.layer.removeAllAnimations()
    }
    
    private func createButton(_ icon: String, _ iconPointSize: CGFloat) -> UIButton {
        let btn = UIButton(type: .system)
        var configuration = UIButton.Configuration.borderless()
        configuration.baseForegroundColor = .accent
        configuration.image = getImage(icon, iconPointSize)
        btn.layer.cornerRadius = 4.0
        btn.configuration = configuration
        view.addSubview(btn)
        return btn
    }
    
    private func getImage(_ name: String, _ ps: CGFloat = 12) -> UIImage? {
        return UIImage(systemName: name)?.withConfiguration(UIImage.SymbolConfiguration(pointSize: ps, weight: .semibold))
    }
    
    func animateThreeDots() {
        UIView.animate(withDuration: 5, delay: TimeInterval(0), options: [.curveEaseIn], animations: { [self] () -> Void in
            
            let randomX = CGFloat.random(in: -50 ... 200)
            let randomY = CGFloat.random(in: -100 ... 600)
            
            var newX = self.threeDots.frame.origin.x + randomX
            var newY = threeDots.frame.origin.y + randomY
            
            if newX > self.view.frame.width {
                newX -= threeDots.frame.origin.x
            }
            
            if newY > self.view.frame.height {
                newY -= threeDots.frame.origin.y
            }
            
            threeDots.center = CGPoint(x: newX, y: newY)
        }, completion: { finished in
            if self.isAnimating {
                self.animateThreeDots()
            }
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
    
    private func playBtnClicked() {
        
        guard let mainVC = mainVC else {
            playBtnClickedDebug()
            return
        }
        
        mainVC.playBtnClicked(false)
        handleIsAnimating()
    }
    
    func playBtnClickedDebug() {
        isAnimatingPrivate.toggle()
        handleIsAnimating()
    }
    
    func handleIsAnimating () {
        if isAnimating {
            startAnimations()
        } else {
            stopAnimations()
        }
        
        playBtn.configuration!.image = self.getImage(isAnimating ? pauseIcon : playIcon)
    }
}
