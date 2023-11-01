//
//  ViewController.swift
//  musapp
//
//  Created by imac on 30.10.2023.
//

import UIKit

class ViewController: UIViewController, ToolViewDelegate {
    
    // MARK: - declaration
    
    let margin = 15.0

    // MARK: - properties
    
    private var guitarView: ToolView!
    private var drumsView: ToolView!
    private var windsView: ToolView!
    
    private var toolViews: [ToolView]
    private var lastOpenedTool: ToolView?
    
    private var layersBtn: ToggleButton!
    
    private var gradientLayer: CAGradientLayer!
    
    // MARK: - init

    init() {
        toolViews = []
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    // MARK: - private methods
    
    private func addTool(_ icon: UIImage, _ alignBottom: Bool = false) -> ToolView {
        let toolView = ToolView()
        toolView.delegate = self
        toolView.setData(icon, ["сэмпл 1", "сэмпл 2", "сэмпл 3"])
        toolView.backgroundColor = .white
        toolView.layer.masksToBounds = true
        
        view.addSubview(toolView)
        toolViews.append(toolView)
        
        return toolView
    }
    
    private func updateToolViewsOpacity() {
        if lastOpenedTool != nil {
            toolViews.filter { $0 != lastOpenedTool }.forEach { toolView in
                toolView.layer.opacity = 0.3
            }
        } else {
            toolViews.forEach { toolView in
                toolView.layer.opacity = 1
            }
        }
    }
    
    // MARK: - overridden base members
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        guitarView = addTool(UIImage(named: "guitar")!)
        guitarView.alignBottom = true
        
        drumsView = addTool(UIImage(named: "drums")!)
        windsView = addTool(UIImage(named: "winds")!)
        
        layersBtn = ToggleButton()
        layersBtn.setTitle("Слои", for: .normal)
        view.addSubview(layersBtn)
        
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.royalBlue.withAlphaComponent(0).cgColor,
            UIColor.royalBlue.withAlphaComponent(1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 1, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.addSublayer(gradientLayer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let topMargin: CGFloat = view.safeAreaInsets.top + margin
        let bottomMargin: CGFloat = view.safeAreaInsets.bottom + margin
        
        let toolsWidth = view.frame.width - margin * 2
        
        var toolEdgeSize = 0.0
        if !toolViews.isEmpty {
            let toolView = toolViews[0]
            toolView.sizeToFit()
            toolEdgeSize = toolView.frame.width
        }
        
        let spaceW = toolsWidth - CGFloat(toolViews.count) * toolEdgeSize
        let toolSpaceW = spaceW / CGFloat(toolViews.count - 1)
        
        var x = margin
        var toolBottom = 0.0
        
        for tool in toolViews {
            tool.sizeToFit()
            tool.move(x, topMargin)
            x += toolEdgeSize + toolSpaceW
            tool.layer.cornerRadius = tool.frame.width / 2
            toolBottom = tool.frame.maxY
        }
        
        layersBtn.sizeToFit()
        layersBtn.move(margin, view.frame.height - layersBtn.frame.height - bottomMargin)
        
        let gradientY = toolBottom + 40
        let gradientH = layersBtn.frame.minY - 54.0 - gradientY
        gradientLayer.frame = CGRect(x: margin, y: gradientY, width: view.frame.width - 2 * margin, height: gradientH)
    }
    
    // MARK: - ToolViewDelegate

    func toggled(toolView: ToolView) {
        
        if toolView.isOpen {
            lastOpenedTool?.toggleOpen()
            lastOpenedTool = toolView
            toolView.layer.opacity = 1
            updateToolViewsOpacity()
        } else {
            lastOpenedTool = nil
            updateToolViewsOpacity()
        }
    }
}

