import UIKit
import SnapKit
import Foundation

protocol PlayerViewSongControllerProtocol {
    func songChange(song: Audio)
}

class PlayerView: UIView {
    let label = UILabel()
    let progress = UIProgressView()
    let playPauseButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        AudioPlayer.shared.delegatePV = self
        setupView()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        AudioPlayer.shared.delegatePV = self
        setupView()
    }
    
    @objc private func playPause() {
        AudioPlayer.shared.playPause()
    }
}

//MARK: PlayerViewSongControllerProtocol methods
extension PlayerView: PlayerViewSongControllerProtocol {
    func songChange(song: Audio) {
        self.label.text = song.title
    }
}

// MARK: UI
extension PlayerView {
    func setupView() {
        backgroundColor = UIColor(red: 228/255, green: 228/255, blue: 228/255, alpha: 0.8)
        addSubview(label)
        addSubview(progress)
        addSubview(playPauseButton)
        label.text = "nothing"
        label.textAlignment = .center
        progress.backgroundColor = .black
        progress.progressTintColor = .red
        progress.progressViewStyle = .default
        progress.progress = 0
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playPauseButton.tintColor = .black
        playPauseButton.addTarget(self, action: #selector(playPause), for: .touchUpInside)
        
        progress.snp.makeConstraints { make in
            make.top.equalTo(snp.top)
            make.width.equalToSuperview()
            make.height.equalTo(5)
        }
        label.snp.makeConstraints { make in
            make.top.equalTo(progress.snp.bottom).offset(10)
            make.width.equalTo(350)
            make.centerX.equalToSuperview()
        }
        playPauseButton.snp.makeConstraints { make in
            make.top.equalTo(progress.snp.bottom).offset(10)
            make.left.equalTo(snp.right).offset(-30)
        }
    }
}
