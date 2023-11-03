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
    
    private var playBtn: UIButton!
    
    internal var layers = Array<AudioLayer>()
    internal var layerCellH = 46.0
    internal var playingLayerUUID: UUID?
    
    private var gradientLayer: CAGradientLayer!
    
    private let engine = AudioEngine()
    private var player = AudioPlayer()
    
    // MARK: - init

    init() {
        toolViews = []
        super.init(nibName: nil, bundle: nil)
        player.completionHandler = {
            self.stopPlay()
            self.updateLayers()
        }
        
        do {
            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(Settings.bufferLength.duration)
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.defaultToSpeaker, .mixWithOthers, .allowBluetoothA2DP])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let err {
            print(err)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    // MARK: - private methods
    
    private func addTool(_ icon: UIImage, _ title: String, _ samples: [AudioSample]) -> ToolView {
        let toolView = ToolView()
        toolView.delegate = self
        toolView.setData(icon, title, samples)
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
    
    private func appendToLayers(toolName: String?, sample: AudioSample) -> AudioLayer {
        let layer = AudioLayer(toolName: toolName ?? "", sample: sample)
        layers.append(layer)
        
        return layer
    }
    
    private func getImage(_ name: String) -> UIImage? {
        return UIImage(systemName: name)?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold));
    }
    
    private func playMix() {
        let engineMixer = Mixer()
        
        engine.output = engineMixer
        try! engine.start()
        
        var players:[AudioPlayer] = []
        
        for layer in self.layers {
            let audioFile = try! AVAudioFile(forReading: layer.sample.path)
            let player = AudioPlayer(file: audioFile, buffered: true)
            engineMixer.addInput(player!)
            players.append(player!)
        }
        
        print(engine.connectionTreeDescription)
        
        players.forEach { $0.isLooping = true }
        
        players.forEach { $0.start() }
    }
    
    // MARK: - internal methods
    
    internal func updateLayers() {
        layersTableView.reloadData()
        view.setNeedsLayout()
    }
    
    internal func stopPlay() {
        playingLayerUUID = nil
        player.stop()
    }
    
    internal func play(layer: AudioLayer) {
        stopPlay()
        
        playingLayerUUID = layer.id
        
        engine.output = player
        try! engine.start()
        try! player.load(url: layer.sample.path)
        
        player.play()
    }
    
    // MARK: - overridden base members
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        guitarView = addTool(UIImage(named: "guitar")!, "мелодия", getAudioSamples("Guitar"))
        guitarView.alignBottom = true
        
        drumsView = addTool(UIImage(named: "drums")!, "ударные", getAudioSamples("Percussion"))
        windsView = addTool(UIImage(named: "winds")!, "духовые", getAudioSamples("Percussion"))
        
        layersBtn = ToggleButton()
        layersBtn.setTitle("Слои", for: .normal)
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
        
        let btnRad = 4.0
        
        playBtn = UIButton(type: .system)
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .white
        configuration.baseForegroundColor = .black
        configuration.image = getImage("play.fill")
        playBtn.layer.cornerRadius = btnRad
        playBtn.configuration = configuration
        playBtn.addAction {
            self.playMix()
        }
        view.addSubview(playBtn)
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
        
        playBtn.setSize(34, 34)
        playBtn.move(view.frame.width - playBtn.frame.width - margin, layersBtn.frame.minY)
        
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
        
        guard let sample = toolView.samples.first else {
            return
        }
        
        let layer = appendToLayers(toolName: toolView.getTitle(), sample: sample)
        play(layer: layer)
        updateLayers()
    }
    
    func sampleTapped(_ toolView: ToolView, _ sample: AudioSample) {
        
        // close toolView when sample selected while it was open
        toolView.toggleOpen()
        toggled(toolView: toolView)
        
        appendToLayers(toolName: toolView.getTitle(), sample: sample)
        updateLayers()
    }
}

