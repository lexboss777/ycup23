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
    
    let playIcon = "play.fill"
    let pauseIcon = "pause.fill"

    // MARK: - properties
    
    var melodyView: ToolView!
    var drumsView: ToolView!
    var windsView: ToolView!
    
    var toolViews: [ToolView]
    var lastOpenedTool: ToolView?
    
    var layersBtn: ToggleButton!
    var layersTableView: UITableView!
    
    var selectedLayer: AudioLayer?
    var selectedPath: IndexPath?
    
    var playBtn: UIButton!
    var isPlayingMix = false
    
    var recordBtn: UIButton!
    
    var layers = Array<AudioLayer>()
    var layerCellH = 46.0
    var playingLayerUUID: UUID?
    
    var gradientLayer: CAGradientLayer!
    
    var volumeSlider: UISlider!
    
    var speedSlider: UISlider!
    let maxSpeed: Float = 5
    let minSpeed: Float = 0
    
    let engine = AudioEngine()
    var player = AudioPlayer()
    
    // MARK: - init

    init() {
        toolViews = []
        super.init(nibName: nil, bundle: nil)
        player.completionHandler = {
            self.stopPlayLayer()
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
    
    private func getImage(_ name: String, _ ps: CGFloat = 12) -> UIImage? {
        return UIImage(systemName: name)?.withConfiguration(UIImage.SymbolConfiguration(pointSize: ps, weight: .semibold));
    }
    
    private func playerCompletionHandler(_ layer: AudioLayer) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(layer.interval)) {
            guard let player = layer.player else {
                print("player seems to be detached")
                return
            }
            
            player.play()
        }
    }
    
    private func playMix() {
        let engineMixer = Mixer()
        
        engine.output = engineMixer
        try! engine.start()
        
        var players:[AudioPlayer] = []
        
        for layer in self.layers {
            let audioFile = try! AVAudioFile(forReading: layer.sample.path)
            let player = AudioPlayer(file: audioFile, buffered: true)!
            player.completionHandler = {
                self.playerCompletionHandler(layer)
            }
            player.volume = layer.isMuted ? 0 : 1
            engineMixer.addInput(player)
            players.append(player)
            layer.player = player
        }
        
        print(engine.connectionTreeDescription)
        
        players.forEach { $0.start() }
    }
    
    private func stopMix() {
        for layer in layers {
            guard let player = layer.player else {
                continue
            }
            
            player.stop()
            layer.player = nil
        }
        
        engine.stop()
        engine.input?.detach()
        
        print(engine.connectionTreeDescription)
        print("stopMix end")
    }
    
    private func updatePlayMixButton() {
        self.playBtn.configuration!.image = self.getImage(self.isPlayingMix ? pauseIcon : playIcon)
    }
    
    private func updateSlidersVisibility() {
        let sliderHidden = !layersTableView.isHidden || selectedLayer == nil
        speedSlider.isHidden = sliderHidden
        volumeSlider.isHidden = sliderHidden
    }
    
    private func playBtnClicked() {
        if playingLayerUUID != nil {
            stopPlayLayer()
            updateLayers()
        }
        
        if !isPlayingMix && layers.isEmpty {
            print("nothing to play")
            return
        }
        
        isPlayingMix.toggle()
        updatePlayMixButton()
        if isPlayingMix {
            playMix()
        } else {
            stopMix()
        }
    }
    
    // MARK: - internal methods
    
    internal func updateLayers() {
        layersTableView.reloadData()
        view.setNeedsLayout()
    }
    
    internal func stopPlayLayer() {
        playingLayerUUID = nil
        player.stop()
    }
    
    internal func play(layer: AudioLayer) {
        stopPlayLayer()
        stopMixIfPlaying()
        
        playingLayerUUID = layer.id
        
        engine.output = player
        try! engine.start()
        
        try! player.load(url: layer.sample.path)
        
        player.play()
    }
    
    internal func stopMixIfPlaying() {
        if isPlayingMix {
            isPlayingMix = false
            stopMix()
            updatePlayMixButton()
        }
    }
    
    // MARK: - overridden base members
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        melodyView = addTool(UIImage(named: "melody")!, "мелодия", getAudioSamples("Guitar"))        
        drumsView = addTool(UIImage(named: "drums")!, "ударные", getAudioSamples("Percussion"))
        windsView = addTool(UIImage(named: "winds")!, "духовые", getAudioSamples("Percussion"))
        
        layersBtn = ToggleButton()
        layersBtn.setTitle("Слои", for: .normal)
        layersBtn.addAction {
            self.layersTableView.isHidden.toggle()
            self.view.setNeedsLayout()
            self.updateSlidersVisibility()
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
        
        volumeSlider = UISlider()
        volumeSlider.isHidden = true
        volumeSlider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2))
        volumeSlider.tintColor = .accent
        view.addSubview(volumeSlider)
        
        speedSlider = UISlider()
        speedSlider.isHidden = true
        speedSlider.minimumValue = minSpeed
        speedSlider.maximumValue = maxSpeed
        speedSlider.tintColor = .accent
        speedSlider.addAction {
            if self.selectedLayer != nil {
                self.selectedLayer!.interval = self.maxSpeed - self.speedSlider.value
                print(self.selectedLayer!.interval)
            }
        }
        view.addSubview(speedSlider)
        
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
            self.playBtnClicked()
        }
        view.addSubview(playBtn)
        
        recordBtn = UIButton(type: .system)
        configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .white
        configuration.baseForegroundColor = .black
        configuration.image = getImage("circle.fill", 8)
        recordBtn.layer.cornerRadius = btnRad
        recordBtn.configuration = configuration
        view.addSubview(recordBtn)
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
        
        let btnSize = 34.0
        let btnMargin = 5.0
        
        playBtn.setSize(btnSize, btnSize)
        playBtn.move(view.frame.width - playBtn.frame.width - margin, layersBtn.frame.minY)
        
        recordBtn.setSize(btnSize, btnSize)
        recordBtn.move(playBtn.frame.minX - btnMargin - recordBtn.frame.width, layersBtn.frame.minY)
        
        let spectrumH = 54.0
        
        let gradientAdditionalTopMargin = 40.0
        let gradientW = view.frame.width - 2 * margin
        let gradientY = toolBottom + gradientAdditionalTopMargin
        let gradientH = layersBtn.frame.minY - spectrumH - gradientY
        gradientLayer.frame = CGRect(x: margin, y: gradientY, width: gradientW, height: gradientH)
        
        volumeSlider.sizeToFit()
        volumeSlider.setHeight(gradientLayer.frame.height - margin * 2)
        volumeSlider.move(margin, gradientY)
        
        speedSlider.sizeToFit()
        speedSlider.setWidth(gradientLayer.frame.width - margin)
        speedSlider.move(margin * 2, gradientLayer.frame.maxY - speedSlider.frame.height)
        
        let layersTableViewContentH = layerCellH * CGFloat(layers.count)
        let layersTableViewMaxH = gradientH
        layersTableView.setWidth(gradientW)
        layersTableView.setHeight(min(layersTableViewMaxH, layersTableViewContentH))
        layersTableView.setLeft(margin)
        layersTableView.setTop(layersBtn.frame.minY - spectrumH - layersTableView.frame.height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        melodyView.animateOpenAndClose()
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
        
        _ = appendToLayers(toolName: toolView.getTitle(), sample: sample)
        updateLayers()
    }
}

