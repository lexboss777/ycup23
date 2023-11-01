//
//  ViewController.swift
//  musapp
//
//  Created by imac on 30.10.2023.
//

import UIKit

class ViewController: UIViewController, ToolViewDelegate {

    // MARK: - properties
    
    private var guitarView: ToolView!
    private var drumsView: ToolView!
    private var windsView: ToolView!
    
    private var toolViews: [ToolView]
    private var lastOpenedTool: ToolView?
    
    private var layersBtn: ArrowButton!
    
    // MARK: - ctor

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
        toolView.setData(icon)
        toolView.backgroundColor = .white
        toolView.layer.masksToBounds = true
        view.addSubview(toolView)
        toolViews.append(toolView)
        
        return toolView
    }
    
    // MARK: - overridden base members
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        guitarView = addTool(UIImage(named: "guitar")!)
        guitarView.alignBottom = true
        
        drumsView = addTool(UIImage(named: "drums")!)
        windsView = addTool(UIImage(named: "winds")!)
        
        layersBtn = ArrowButton()
        layersBtn.setTitle("Слои", for: .normal)
        view.addSubview(layersBtn)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let m = 15.0
        
        let topMargin: CGFloat = view.safeAreaInsets.top + m
        let bottomMargin: CGFloat = view.safeAreaInsets.bottom + m
        
        let toolsWidth = view.frame.width - m * 2
        
        var toolEdgeSize = 0.0
        if !toolViews.isEmpty {
            let toolView = toolViews[0]
            toolView.sizeToFit()
            toolEdgeSize = toolView.frame.width
        }
        
        let spaceW = toolsWidth - CGFloat(toolViews.count) * toolEdgeSize
        let toolSpaceW = spaceW / CGFloat(toolViews.count - 1)
        
        var x = m
        
        for tool in toolViews {
            tool.sizeToFit()
            tool.move(x, topMargin)
            x += toolEdgeSize + toolSpaceW
            tool.layer.cornerRadius = tool.frame.width / 2
        }
        
        layersBtn.sizeToFit()
        layersBtn.move(m, view.frame.height - layersBtn.frame.height - bottomMargin)
    }
    
    // MARK: - ToolViewDelegate

    func toggled(toolView: ToolView) {
        
        if toolView.isOpen {
            lastOpenedTool?.toggleOpen()
            lastOpenedTool = toolView
        } else {
            lastOpenedTool = nil
        }
    }
}

