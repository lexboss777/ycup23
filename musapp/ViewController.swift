//
//  ViewController.swift
//  musapp
//
//  Created by imac on 30.10.2023.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - properties
    
    private var guitarView: ToolView!
    private var drumsView: ToolView!
    private var windsView: ToolView!
    
    private var toolViews: [ToolView]
    
    // MARK: - ctor

    init() {
        toolViews = []
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    // MARK: - private methods
    
    private func addTool(_ icon: UIImage) -> ToolView {
        let toolView = ToolView()
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
        guitarView = addTool(UIImage(named: "drums")!)
        guitarView = addTool(UIImage(named: "winds")!)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let topMargin: CGFloat = view.safeAreaInsets.top + 15
        let margin: CGFloat = 20
        
        let toolsHorizontalMargin = 15.0
        let toolsWidth = view.frame.width - toolsHorizontalMargin * 2
        let toolEdgeSize = 60.47
        let spaceW = toolsWidth - CGFloat(toolViews.count) * toolEdgeSize
        let toolSpaceW = spaceW / CGFloat(toolViews.count - 1)
        
        for tool in toolViews {
            tool.frame = CGRect(margin, topMargin, toolEdgeSize, toolEdgeSize)
            tool.layer.cornerRadius = guitarView.frame.width / 2
        }
    }
}

