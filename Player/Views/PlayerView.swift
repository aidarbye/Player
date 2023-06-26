import UIKit
import SnapKit
import Foundation
protocol PlayerViewSongControllerProtocol {
    func songChange(song: Audio)
}
class PlayerView: UIView, PlayerViewSongControllerProtocol {
    let label = UILabel()
    let progress = UIProgressView()
    let playPauseButton = UIButton()
    override init(frame: CGRect) {
        super.init(frame: frame)
        AudioPlayer.shared.delegatePV = self
        progress.progress = 0
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc private func playPause() {
        if AudioPlayer.shared.currentSong != nil {
            if AudioPlayer.shared.isPlaying {
                AudioPlayer.shared.pause()
            } else {
                AudioPlayer.shared.resume()
            }
            AudioPlayer.shared.isPlaying.toggle()
        }
    }
    func songChange(song: Audio) {
        self.label.text = song.title
    }
    func setupView() {
        backgroundColor = UIColor(red: 228/255, green: 228/255, blue: 228/255, alpha: 1)
        addSubview(label)
        addSubview(progress)
        addSubview(playPauseButton)
        label.text = "nothing"
        label.textAlignment = .center
        progress.backgroundColor = .black
        progress.progressTintColor = .red
        progress.progressViewStyle = .default
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
