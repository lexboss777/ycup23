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
    
    var selectedLayer: AudioLayer? {
        didSet {
            updateSliders()
        }
    }
    
    var playBtn: UIButton!
    var isPlayingMix = false
    
    var recordBtn: UIButton!
    var mixRecorder: NodeRecorder?
    var mixRecordURL: URL!
    
    var micRecordBtn: UIButton!
    var isMicRecording = false
    var micRecorder = AudioRecorder()
    
    var layers = Array<AudioLayer>()
    var layerCellH = 46.0
    var playingLayerUUID: UUID?
    
    var gradientLayer: CAGradientLayer!
    
    var volumeSlider: UISlider!
    
    var speedSlider: UISlider!
    let maxSpeed: Float = 5
    let minSpeed: Float = 0
    
    let engine = AudioEngine()
    var engineMixer: Mixer?
    var layerPlayer = AudioPlayer()
    
    var fft: FFTTap?
    var amplitudes : [CGFloat] = Array(repeating: 0.5, count: 100)
    var amplitudeView: AmplitudeView!
    
    // MARK: - init
    
    init() {
        toolViews = []
        super.init(nibName: nil, bundle: nil)
        layerPlayer.completionHandler = { [unowned self] in
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
        
        micRecorder.clearFiles()
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        mixRecordURL = documentsDirectory.appendingPathComponent("mix.wav")
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
    
    private func playMix(record: Bool) {
        engineMixer = Mixer()
        
        guard let engineMixer else { return }
        
        engine.output = engineMixer
        try! engine.start()
        
        for layer in self.layers {
            appendLayerIntoMix(layer)
        }
        
        if record {
            mixRecorder = try? NodeRecorder(node: engineMixer)
            try? mixRecorder?.record()
        } else {
            mixRecorder = nil
        }
        
        fft = FFTTap.init(engine.output!, callbackQueue: DispatchQueue.main, handler: handleFFT)
        fft?.start()
        
        updateMixRecordButton()
    }
    
    private func handleFFT(_ array: Array<Float>) {
        for i in stride(from: 0, to: array.count, by: 2) {
            
            let real = CGFloat(array[i])
            let imaginary = CGFloat(array[i + 1])
            
            let sum = real * real + imaginary * imaginary
            let normalizedBinMagnitude = CGFloat(2.0) * sqrt(sum) / CGFloat(array.count)
            let amplitude = (20.0 * log10(normalizedBinMagnitude))
            
            var scaledAmplitude: CGFloat = (amplitude + 250) / 229.80
            
            if scaledAmplitude < 0 {
                scaledAmplitude = 0
            }
            
            if scaledAmplitude > 1.0 {
                scaledAmplitude = 1.0
            }
            
            if i/2 < self.amplitudes.count {
                self.amplitudes[i/2] = self.mapy(n: scaledAmplitude, start1: 0.3, stop1: 0.9, start2: 0.0, stop2: 1.0)
            }
        }
        
        DispatchQueue.main.async {
            self.amplitudeView.amplitudes = self.amplitudes
        }
    }
    
    // simple mapping function to scale a value to a different range
    func mapy(n:CGFloat, start1:CGFloat, stop1:CGFloat, start2:CGFloat, stop2:CGFloat) -> CGFloat {
        return ((n-start1)/(stop1-start1))*(stop2-start2)+start2;
    }
    
    private func stopMix() {
        
        mixRecorder?.stop()
        updateMixRecordButton()
        
        for layer in layers {
            guard let player = layer.player else { continue }
            
            player.stop()
            layer.player = nil
        }
        
        engine.stop()
        engine.input?.detach()
        
        if let file = mixRecorder?.audioFile {
            convertMix(file) { [weak self] error in
                if let error = error {
                    print("Error during convertion: \(error)")
                } else {
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.shareMix()
                    }
                }
            }
        }
    }
    
    private func shareMix() {
        if FileManager.default.fileExists(atPath: mixRecordURL.path) {
            let activityViewController = UIActivityViewController(activityItems: [mixRecordURL!], applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
        }
    }
    
    private func convertMix(_ file: AVAudioFile, _ completion: @escaping (_ error: Error?) -> Void) {
        var options = FormatConverter.Options()
        options.format = .wav
        options.sampleRate = Double(22050)
        options.bitDepth = UInt32(16)
        options.bitRate = 128 * 1_000
        options.channels = UInt32(2)
        
        let converter = FormatConverter(inputURL: file.url, outputURL: mixRecordURL, options: options)
        DispatchQueue.global(qos: .userInitiated).async {
            converter.start(completionHandler: completion)
        }
    }
    
    private func playBtnClicked(_ record: Bool) {
        if playingLayerUUID != nil {
            stopPlayLayer()
            updateLayers()
        }
        
        if isMicRecording {
            micRecordClicked()
        }
        
        if !isPlayingMix && layers.isEmpty {
            print("nothing to play or record")
            return
        }
        
        isPlayingMix.toggle()
        
        if isPlayingMix {
            playMix(record: record)
        } else {
            stopMix()
        }
        
        updatePlayMixButton()
    }
    
    private func micRecordClicked() {
        stopPlayLayer()
        stopMixIfPlaying()
        
        if !isMicRecording {
            micRecorder.startRecording { [unowned self] success in
                if success {
                    self.isMicRecording.toggle()
                    self.updateMicRecordBtn()
                }
            }
        } else {
            guard let url = micRecorder.stopRecording() else { return }
            
            let micCount = layers.filter{ $0.isMicRecord }.count
            let sample = AudioSample(path: url, name: String(micCount + 1))
            selectedLayer = appendToLayers(toolName: "запись", sample: sample)
            selectedLayer!.isMicRecord = true
            
            isMicRecording.toggle()
            updateMicRecordBtn()
            
            updateLayers()
        }
    }
    
    private func updatePlayMixButton() {
        let active = self.isPlayingMix && (mixRecorder == nil || mixRecorder!.isRecording == false)
        playBtn.configuration!.image = self.getImage(active ? pauseIcon : playIcon)
    }
    
    private func updateMixRecordButton() {
        recordBtn.configuration?.baseForegroundColor = mixRecorder?.isRecording == true ? .red : .black
    }
    
    private func updateMicRecordBtn() {
        micRecordBtn.configuration?.baseForegroundColor = isMicRecording ? .red : .black
    }
    
    private func createButton(_ icon: String, _ iconPointSize: CGFloat) -> UIButton {
        let btn = UIButton(type: .system)
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .white
        configuration.baseForegroundColor = .black
        configuration.image = getImage(icon, iconPointSize)
        btn.layer.cornerRadius = 4.0
        btn.configuration = configuration
        view.addSubview(btn)
        return btn
    }
    
    private func appendLayerIntoMix(_ layer: AudioLayer) {
        guard let engineMixer else { return }
        
        let audioFile = try! AVAudioFile(forReading: layer.sample.path)
        let player = AudioPlayer(file: audioFile, buffered: true)!
        player.completionHandler = {
            self.playerCompletionHandler(layer)
        }
        player.volume = layer.isMuted ? 0 : layer.volume
        engineMixer.addInput(player)
        layer.player = player
        player.start()
    }
    
    // MARK: - internal methods
    
    internal func updateLayers() {
        layersTableView.reloadData()
        view.setNeedsLayout()
    }
    
    internal func stopPlayLayer() {
        playingLayerUUID = nil
        layerPlayer.stop()
    }
    
    internal func play(layer: AudioLayer) {
        stopPlayLayer()
        stopMixIfPlaying()
        if isMicRecording {
            micRecordClicked()
        }
        
        playingLayerUUID = layer.id
        
        engine.output = layerPlayer
        try! engine.start()
        
        try! layerPlayer.load(url: layer.sample.path)
        
        layerPlayer.play()
    }
    
    internal func stopMixIfPlaying() {
        if isPlayingMix {
            isPlayingMix = false
            stopMix()
            updatePlayMixButton()
        }
    }
    
    internal func updateSliders() {
        let isSliderHidden = !layersTableView.isHidden || selectedLayer == nil
        speedSlider.isHidden = isSliderHidden
        volumeSlider.isHidden = isSliderHidden
        
        if !isSliderHidden {
            speedSlider.value = maxSpeed - selectedLayer!.interval
            volumeSlider.value = selectedLayer!.volume
        }
    }
    
    // MARK: - overridden base members
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        melodyView = addTool(UIImage(named: "melody")!, "мелодии", getAudioSamples("Melody"))
        drumsView = addTool(UIImage(named: "drums")!, "ударные", getAudioSamples("Percussion"))
        windsView = addTool(UIImage(named: "winds")!, "духовые", getAudioSamples("Percussion"))
        
        layersBtn = ToggleButton()
        layersBtn.setTitle("Слои")
        layersBtn.addAction { [unowned self] in
            self.layersTableView.isHidden.toggle()
            self.view.setNeedsLayout()
            self.updateSliders()
        }
        view.addSubview(layersBtn)
        
        amplitudeView = AmplitudeView()
        view.addSubview(amplitudeView)
        
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
        volumeSlider.addAction { [unowned self] in
            guard let layer = self.selectedLayer else { return }
            
            layer.volume = self.volumeSlider.value
        }
        view.addSubview(volumeSlider)
        
        speedSlider = UISlider()
        speedSlider.isHidden = true
        speedSlider.minimumValue = minSpeed
        speedSlider.maximumValue = maxSpeed
        speedSlider.tintColor = .accent
        speedSlider.addAction { [unowned self] in
            guard let layer = self.selectedLayer else { return }
            
            layer.interval = self.maxSpeed - self.speedSlider.value
        }
        view.addSubview(speedSlider)
        
        layersTableView = UITableView()
        layersTableView.backgroundColor = .clear
        layersTableView.isHidden = true
        layersTableView.dataSource = self
        layersTableView.delegate = self
        layersTableView.register(LayerCell.self, forCellReuseIdentifier: LayerCell.identifier)
        view.addSubview(layersTableView)
        
        playBtn = createButton("play.fill", 12)
        playBtn.addAction { [weak self] in
            guard let self = self else { return }
            self.playBtnClicked(false)
        }
        
        recordBtn = createButton("circle.fill", 8)
        recordBtn.addAction { [weak self] in
            guard let self = self else { return }
            self.playBtnClicked(true)
        }
        
        micRecordBtn = createButton("mic.fill", 12)
        micRecordBtn.addAction { [weak self] in
            guard let self = self else { return }
            self.micRecordClicked()
        }
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
        
        micRecordBtn.setSize(btnSize, btnSize)
        micRecordBtn.move(recordBtn.frame.minX - btnMargin - micRecordBtn.frame.width, layersBtn.frame.minY)
        
        let amplH = 54.0
        let amplMargin = 8.0
        amplitudeView.setSize(view.frame.width - 2 * margin, amplH - 2 * amplMargin)
        amplitudeView.move(margin, layersBtn.frame.minY - amplH + amplMargin)
        view.bringSubviewToFront(amplitudeView)
        
        let gradientAdditionalTopMargin = 40.0
        let gradientW = view.frame.width - 2 * margin
        let gradientY = toolBottom + gradientAdditionalTopMargin
        let gradientH = layersBtn.frame.minY - amplH - gradientY
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
        layersTableView.setTop(layersBtn.frame.minY - amplH - layersTableView.frame.height)
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
        selectedLayer = layer
        play(layer: layer)
        updateLayers()
    }
    
    func sampleTapped(_ toolView: ToolView, _ sample: AudioSample) {
        
        // close toolView when sample selected while it was open
        toolView.toggleOpen()
        toggled(toolView: toolView)
        
        let layer = appendToLayers(toolName: toolView.getTitle(), sample: sample)
        selectedLayer = layer
        updateLayers()
        
        if isPlayingMix {
            appendLayerIntoMix(layer)
        }
    }
}

