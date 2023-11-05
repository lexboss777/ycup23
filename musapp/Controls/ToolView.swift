import Foundation
import UIKit

protocol ToolViewDelegate: AnyObject {
    func toggled(toolView: ToolView)
    func tapped(toolView: ToolView)
    func sampleTapped(_ toolView: ToolView, _ sample: AudioSample)
}

class ToolView: UIView {
    
    // MARK: - properties
    
    private let circleDiameter = 61.0
    
    private let iconImV = UIImageView()
    private let titleLabel = UILabel()
    private var buttons = Array<UIButton>()
    private var circleView = UIView()
    
    var samples: Array<AudioSample>!
    
    public var alignBottom = false {
        didSet { setNeedsLayout() }
    }
    
    public var isOpen: Bool = false
    
    weak var delegate: ToolViewDelegate?
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        
        backgroundColor = .clear
        
        circleView.backgroundColor = .white
        
        titleLabel.textColor = .white
        titleLabel.font = YSText.regular(12)
        
        addSubview(circleView)
        circleView.layer.masksToBounds = true
        circleView.addSubview(iconImV)
        
        addSubview(titleLabel)
        
        iconImV.isUserInteractionEnabled = true
        
        let longGr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longGr.minimumPressDuration = 0.3
        iconImV.addGestureRecognizer(longGr)
        
        iconImV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
    }
    
    // MARK: - overridden base members
    
    override func sizeToFit() {
        
        var animDuration = 0.3
        let buttonsTopMargin = 23.0
        let buttonsBottomMargin = 38.0
        let buttonsInterMargin = 21.0
        
        if isOpen {
            
            var h = circleDiameter + buttonsTopMargin
            
            for button in buttons {
                button.sizeToFit()
                button.setWidth(circleView.frame.width)
                button.setTop(h)
                h += button.frame.height + buttonsInterMargin
            }
            
            UIView.animate(withDuration: animDuration, animations: {
                self.setHeight(h - buttonsInterMargin + buttonsBottomMargin)
                self.circleView.setHeight(h - buttonsInterMargin + buttonsBottomMargin)
            })
            
        } else {
            
            if frame.isEmpty {
                animDuration = 0
            }
            
            UIView.animate(withDuration: animDuration, animations: {
                self.setSize(self.circleDiameter, self.circleDiameter)
                self.circleView.setSize(self.circleDiameter, self.circleDiameter)
            })
            
            iconImV.contentMode = .center
            iconImV.setSize(circleDiameter, circleDiameter)
            
            titleLabel.sizeToFit()
            titleLabel.centerHorizontallyInView(self)
            titleLabel.setTop(circleDiameter + 9)
            
            if alignBottom {
                iconImV.setTop(circleView.frame.height - iconImV.frame.height + 4)
            } else {
                iconImV.centerInView(circleView)
            }
        }
        
        circleView.layer.cornerRadius = circleView.frame.width / 2
    }
    
    // MARK: - public methods
    
    func setData(_ icon: UIImage, _ title: String, _ samples: [AudioSample]) {
        iconImV.image = icon
        
        titleLabel.text = title
        
        for button in buttons {
            button.removeFromSuperview()
        }
        
        buttons = []
        
        self.samples = samples
        
        for sample in samples {
            let button = UIButton(type: .system)
            button.titleLabel?.font = YSText.regular(12)
            button.setTitle(sample.name, for: .normal)
            button.setTitleColor(.black, for: .normal)
            buttons.append(button)
            circleView.addSubview(button)
            button.addTarget(self, action: #selector(sampleTapped), for: .touchUpInside)
        }
    }
    
    func toggleOpen() {
        isOpen.toggle()
        circleView.backgroundColor = isOpen ? .accent : .white
        titleLabel.isHidden = isOpen
        superview?.setNeedsLayout()
    }
    
    func getTitle() -> String? {
        return titleLabel.text
    }
    
    func animateOpenAndClose() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.toggleOpen()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.toggleOpen()
        }
    }
    
    // MARK: - handlers
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            superview?.bringSubviewToFront(self)
            
            toggleOpen()
            delegate?.toggled(toolView: self)
        }
    }
    
    @objc func handleTap(_ gesture: UILongPressGestureRecognizer) {
        if !isOpen {
            delegate?.tapped(toolView: self)
        } else {
            toggleOpen()
            delegate?.toggled(toolView: self)
        }
    }
    
    @objc func sampleTapped(_ sender: UIButton) {
        if let index = buttons.firstIndex(of: sender) {
            let sample = samples[index]
            delegate?.sampleTapped(self, sample)
        }
    }
}
