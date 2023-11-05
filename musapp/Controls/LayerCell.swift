import Foundation
import UIKit

protocol LayerCellDelegate: AnyObject {
    func playOrStop(cell: LayerCell)
    func muteOrUnmute(cell: LayerCell)
    func delete(cell: LayerCell)
}

class LayerCell: UITableViewCell {

    // MARK: - declaration

    static let identifier = "layer_cell"

    let playIcon = "play.fill"
    let pauseIcon = "pause.fill"

    let mutedIcon = "speaker.slash.fill"
    let unmutedIcon = "speaker.fill"

    private let topPadding = 7.0
    private let rad = 4.0

    // MARK: - properties

    private var containerView = UIView()

    private var titleLabel = UILabel()

    private var deleteBtn = UIButton(type: .system)

    private var muteBtn = UIButton(type: .system)
    private var isMuted = false

    private var playBtn = UIButton(type: .system)
    private var isPlaying = false

    var delegate: LayerCellDelegate?

    // MARK: - init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: LayerCell.identifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        selectionStyle = .none
        backgroundColor = .clear

        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = rad
        contentView.addSubview(containerView)

        titleLabel.font = YSText.regular(12)
        containerView.addSubview(titleLabel)

        containerView.addSubview(deleteBtn)
        deleteBtn.addAction { [unowned self] in
            self.delegate?.delete(cell: self)
        }
        configure(btn: deleteBtn, "xmark", UIColor(0xE4E4E4))

        containerView.addSubview(muteBtn)
        configure(btn: muteBtn, unmutedIcon, UIColor.clear)
        muteBtn.addAction { [unowned self] in
            guard let delegate = self.delegate else { return }

            delegate.muteOrUnmute(cell: self)
            self.isMuted.toggle()
            self.setIsMuted(self.isMuted)
        }

        containerView.addSubview(playBtn)
        configure(btn: playBtn, playIcon, UIColor.clear)
        playBtn.addAction { [unowned self] in
            guard let delegate = self.delegate else { return }

            delegate.playOrStop(cell: self)
            self.isPlaying.toggle()
            self.setIsPlaying(self.isPlaying)
        }
    }

    // MARK: - private methods

    private func configure(btn: UIButton, _ img: String, _ bgColor: UIColor) {

        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = bgColor
        configuration.baseForegroundColor = .black
        configuration.image = getImage(img)

        btn.layer.cornerRadius = rad
        btn.configuration = configuration
    }

    private func getImage(_ name: String) -> UIImage? {
        return UIImage(systemName: name)?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold))
    }

    // MARK: - overridden base members

    override func layoutSubviews() {
        super.layoutSubviews()

        containerView.setWidth(frame.width)
        containerView.setHeight(frame.height - topPadding)
        containerView.setTop(topPadding)

        let titleLeftMargin = 10.0
        titleLabel.sizeToFit()
        titleLabel.setTop((containerView.frame.height - titleLabel.frame.height) / 2)
        titleLabel.setLeft(titleLeftMargin)

        let btnEdge = containerView.frame.height

        deleteBtn.frame = CGRect(containerView.frame.width - btnEdge, 0, btnEdge, btnEdge)
        muteBtn.frame = CGRect(deleteBtn.frame.minX - btnEdge, 0, btnEdge, btnEdge)
        playBtn.frame = CGRect(muteBtn.frame.minX - btnEdge, 0, btnEdge, btnEdge)
    }

    // MARK: - public methods

    func setData(_ title: String) {
        titleLabel.text = title
    }

    func setIsPlaying(_ playing: Bool) {
        self.isPlaying = playing
        self.playBtn.configuration?.image = getImage(playing ? pauseIcon : playIcon)
    }

    func setIsMuted(_ muted: Bool) {
        self.isMuted = muted
        self.muteBtn.configuration?.image = getImage(isMuted ? mutedIcon : unmutedIcon)
    }

    func setIsSelected(_ selected: Bool) {
        if selected {
            containerView.backgroundColor = .accent
        } else {
            containerView.backgroundColor = .white
        }
    }
}
