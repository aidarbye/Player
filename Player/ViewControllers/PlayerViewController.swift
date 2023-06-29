import UIKit
import SnapKit
import MediaPlayer

protocol PlayerViewControllerDelegate {
    func changeSong(song: Audio)
}

class PlayerViewController: UIViewController {
    let imageView = UIImageView()
    let slider = UISlider()
    let titleLabel = UILabel()
    let artistLabel = UILabel()
    
    var delegate: PlayerViewControllerDelegate?
    var timer: Timer?
    
    override func viewDidLoad() {
        setupView()
        AudioPlayer.shared.delegate = self
        guard let index = AudioPlayer.shared.currentIndex else { return }
        self.imageView.image = AudioPlayer.shared.songs[index].image
        self.slider.maximumValue = AudioPlayer.shared.songs[index].duration
        self.titleLabel.text = AudioPlayer.shared.songs[index].title
        self.artistLabel.text = AudioPlayer.shared.songs[index].artist
    }
    override func viewWillAppear(_ animated: Bool) {
        if let value = AudioPlayer.shared.audioPlayer?.currentTime() {
            self.slider.value = Float(value.seconds)
        }
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (_) in
                if AudioPlayer.shared.isPlaying {
                    if let value = AudioPlayer.shared.audioPlayer?.currentTime() {
                        self.slider.value = Float(value.seconds)
                    }
                }
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: objc methods
extension PlayerViewController {
    @objc func repeatAction() {
        print(#function)
    }
    @objc func shuffle() {
        
    }
    @objc func playStop() {
        AudioPlayer.shared.playPause()
    }
    @objc func NextMusicPlay() {
        AudioPlayer.shared.playNextSong()
    }
    @objc func PrevMusicPlay() {
        AudioPlayer.shared.playPrevSong()
    }
    @objc func scrubAudio() {
        if let audioPlayer = AudioPlayer.shared.audioPlayer {
            AudioPlayer.shared.isPlaying = true
            audioPlayer.seek(to: CMTime(seconds: Double(slider.value), preferredTimescale: 1),
                             toleranceBefore: .zero, toleranceAfter: .zero)
            audioPlayer.play()
        }
    }
    @objc func sliderValueChanged(_ sender: UISlider) {
        if let audioPlayer = AudioPlayer.shared.audioPlayer {
            AudioPlayer.shared.isPlaying = false
            audioPlayer.pause()
            print(sender.value)
        }
    }
}

// MARK: PlayerViewControllerDelegate methods
extension PlayerViewController: PlayerViewControllerDelegate {
    func changeSong(song: Audio) {
        self.imageView.image = song.image
        self.slider.maximumValue = AudioPlayer.shared.songs[AudioPlayer.shared.currentIndex!].duration
        self.titleLabel.text = song.title
        self.artistLabel.text = song.artist
    }
}

// MARK: UI
extension PlayerViewController {
    private func setupView() {
        overrideUserInterfaceStyle = .light
        let ShuffleButton = UIButton(type: .system)
        let PlayPauseButton = UIButton(type: .system)
        let NextMusicButton = UIButton(type: .system)
        let PrevMusicButton = UIButton(type: .system)
        let Repeat = UIButton(type: .system)
        imageView.tintColor = .black
        imageView.clipsToBounds = true
        titleLabel.textAlignment = .center
        titleLabel.text = "Nothing there buddy"
        titleLabel.numberOfLines = 2
        titleLabel.font = .boldSystemFont(ofSize: 20)
        artistLabel.textAlignment = .center
        artistLabel.text = "and there too"
        artistLabel.font = .systemFont(ofSize: 15)
        slider.tintColor = .black
        slider.thumbTintColor = .black
        view.backgroundColor = .white
        view.addSubview(PlayPauseButton)
        view.addSubview(NextMusicButton)
        view.addSubview(PrevMusicButton)
        view.addSubview(ShuffleButton)
        view.addSubview(slider)
        view.addSubview(Repeat)
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        view.addSubview(artistLabel)
        
        PlayPauseButton.setImage(UIImage(systemName: "playpause"), for: .normal)
        PlayPauseButton.addTarget(self, action: #selector(playStop), for: .touchUpInside)
        PlayPauseButton.tintColor = .black
        
        NextMusicButton.setImage(UIImage(systemName: "arrowtriangle.right"), for: .normal)
        NextMusicButton.addTarget(self, action: #selector(NextMusicPlay), for: .touchUpInside)
        NextMusicButton.tintColor = .black
        
        Repeat.setImage(UIImage(systemName: "repeat"), for: .normal)
        Repeat.addTarget(self, action: #selector(repeatAction), for: .touchUpInside)
        Repeat.tintColor = .black
        
        PrevMusicButton.setImage(UIImage(systemName: "arrowtriangle.backward"), for: .normal)
        PrevMusicButton.addTarget(self, action: #selector(PrevMusicPlay), for: .touchUpInside)
        PrevMusicButton.tintColor = .black
        
        ShuffleButton.setImage(UIImage(systemName: "shuffle"), for: .normal)
        ShuffleButton.addTarget(self, action: #selector(shuffle), for: .touchUpInside)
        ShuffleButton.tintColor = .black
        
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(scrubAudio), for: .touchUpInside)
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(20)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(view.snp.width)
        }
        
        PlayPauseButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-60)
        }
        
        NextMusicButton.snp.makeConstraints { make in
            make.centerY.equalTo(PlayPauseButton.snp.centerY)
            make.left.equalTo(PlayPauseButton.snp.right).offset(30)
        }
        PrevMusicButton.snp.makeConstraints { make in
            make.centerY.equalTo(PlayPauseButton.snp.centerY)
            make.right.equalTo(PlayPauseButton.snp.left).offset(-30)
        }
        Repeat.snp.makeConstraints { make in
            make.centerY.equalTo(PlayPauseButton.snp.centerY)
            make.left.equalTo(view.snp.left).offset(40)
        }
        ShuffleButton.snp.makeConstraints { make in
            make.centerY.equalTo(PlayPauseButton.snp.centerY)
            make.right.equalTo(view.snp.right).offset(-40)
        }
        slider.snp.makeConstraints { make in
            make.width.equalToSuperview().offset(-30)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(PlayPauseButton.snp.top).offset(-30)
        }
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(slider.snp.top).offset(-60)
            make.left.equalTo(view.snp.left).offset(10)
            make.right.equalTo(view.snp.right).offset(-10)
        }
        artistLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.equalTo(view.snp.left).offset(10)
            make.right.equalTo(view.snp.right).offset(-10)
        }
    }
}
