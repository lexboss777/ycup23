//
//  ViewController.swift
//  musapp
//
//  Created by imac on 30.10.2023.
//

import UIKit
import AudioKit
import AVFoundation

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
    internal var layersTableView: UITableView!
    
    internal var layers = Array<AudioLayer>()
    internal var layerCellH = 46.0
    
    private var gradientLayer: CAGradientLayer!
    
    private let engine = AudioEngine()
    private var player = AudioPlayer()
    
    // MARK: - init

    init() {
        toolViews = []
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    // MARK: - private methods
    
    private func addTool(_ icon: UIImage, _ title: String, _ alignBottom: Bool = false) -> ToolView {
        let toolView = ToolView()
        toolView.delegate = self
        toolView.setData(icon, title, getAudioSamples("Percussion"))
        toolView.backgroundColor = .white
        
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
    
    private func getAudioSamples(_ subdir: String) -> [AudioSample] {
        var samples = Array<AudioSample>()
        
        if var paths = Bundle.main.urls(forResourcesWithExtension: "wav", subdirectory: subdir) {
            paths.sort() { $0.path < $1.path }
            
            for path in paths {
                samples.append(AudioSample(path: path, name: path.deletingPathExtension().lastPathComponent))
            }
        }
        
        return samples
    }
    
    // MARK: - internal methods
    
    internal func updateLayers() {
        layersTableView.reloadData()
        view.setNeedsLayout()
    }
    
    // MARK: - overridden base members
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        guitarView = addTool(UIImage(systemName: "swift")!, "-")
        guitarView.alignBottom = true
        
        drumsView = addTool(UIImage(systemName: "swift")!, "-")
        windsView = addTool(UIImage(systemName: "swift")!, "-")
        
        layersBtn = ToggleButton()
        layersBtn.setTitle("layers", for: .normal)
        layersBtn.addAction {
            self.layersTableView.isHidden.toggle()
            self.view.setNeedsLayout()
        }
        view.addSubview(layersBtn)
        
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.royalBlue.withAlphaComponent(0).cgColor,
            UIColor.royalBlue.withAlphaComponent(1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 1, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.addSublayer(gradientLayer)
        
        layersTableView = UITableView()
        layersTableView.backgroundColor = .clear
        layersTableView.isHidden = true
        layersTableView.dataSource = self
        layersTableView.delegate = self
        layersTableView.register(LayerCell.self, forCellReuseIdentifier: LayerCell.identifier)
        view.addSubview(layersTableView)
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
        
        let spectrumH = 54.0
        
        let gradientAdditionalTopMargin = 40.0
        let gradientW = view.frame.width - 2 * margin
        let gradientY = toolBottom + gradientAdditionalTopMargin
        let gradientH = layersBtn.frame.minY - spectrumH - gradientY
        gradientLayer.frame = CGRect(x: margin, y: gradientY, width: gradientW, height: gradientH)
        
        let layersTableViewContentH = layerCellH * CGFloat(layers.count)
        let layersTableViewMaxH = gradientH
        layersTableView.setWidth(gradientW)
        layersTableView.setHeight(min(layersTableViewMaxH, layersTableViewContentH))
        layersTableView.setLeft(margin)
        layersTableView.setTop(layersBtn.frame.minY - spectrumH - layersTableView.frame.height)
    }
    
    // MARK: - ToolViewDelegate

    // called when toolView changed it's state: opened or closed
    
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
    
    func tapped(toolView: ToolView) {
        if let path = Bundle.main.url(forResource: "1", withExtension: "wav", subdirectory: "Percussion") {
            print("Путь к файлу: \(path)")
            
            engine.output = player
            
            try! engine.start()
            
            try! player.load(url: path)
            player.play()
            
        } else {
            print("Файл не найден")
        }
    }
    
    func sampleTapped(sample: AudioSample) {
        layers.append(AudioLayer(sample: sample))
        updateLayers()
    }
}

