import Foundation
import UIKit

class ThreeDots : UIView {
    var d1: UIView!
    var d2: UIView!
    var d3: UIView!
    
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
        
        d1 = getDotView()
        d1.frame = CGRect(0, 0, 27.35, 27.35)
        d1.layer.cornerRadius = d1.frame.width / 2
        
        d2 = getDotView()
        d2.frame = CGRect(51, 20, 27.35, 27.35)
        d2.layer.cornerRadius = d2.frame.width / 2
        
        d3 = getDotView()
        d3.frame = CGRect(11, 58, 27.35, 27.35)
        d3.layer.cornerRadius = d3.frame.width / 2
    }
    
    func getDotView() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor(0x5A50E2)
        addSubview(v)
        return v
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func sizeToFit() {
        super.sizeToFit()
    }
}
