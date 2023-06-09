import UIKit
import SnapKit
import MediaPlayer

protocol PlayerViewControllerDelegate {
    func changeSong(song: Audio)
    func pause()
}

final class PlayerViewController: UIViewController {
    let buttonSize = CGSize(width: 33, height: 30)
    let imageView = UIImageView()
    let slider = UISlider()
    let titleLabel = UILabel()
    let artistLabel = UILabel()
    let ShuffleButton = UIButton(type: .system)
    let PlayPauseButton = UIButton(type: .system)
    let Repeat = UIButton(type: .system)
    
    var timer: Timer?
    
    override func viewDidLoad() {
        setupView()
        APManager.shared.delegatePVC = self
        guard let index = APManager.shared.currentIndex else { return }
        self.imageView.image = APManager.shared.songs[index].image
        self.slider.maximumValue = APManager.shared.songs[index].duration
        self.titleLabel.text = APManager.shared.songs[index].title
        self.artistLabel.text = APManager.shared.songs[index].artist
    }
    override func viewWillAppear(_ animated: Bool) {
        if let value = APManager.shared.audioPlayer?.currentTime() {
            self.slider.value = Float(value.seconds)
        }
        changePicture(buttonSize: buttonSize, button: PlayPauseButton)
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] (_) in
                if APManager.shared.isPlaying {
                    if let value = APManager.shared.audioPlayer?.currentTime() {
                        self?.slider.value = Float(value.seconds)
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
        switch SettingsManager.shared.settings.repeating {
        case .off: Repeat.tintColor = .red
            Repeat.setImage(UIImage(systemName: "repeat.1")?.withTintColor(.white).resized(to: buttonSize),
                            for: .normal)
        case .oneSong: Repeat.setImage(UIImage(systemName: "repeat")?.withTintColor(.white).resized(to: buttonSize),
                                       for: .normal)
            Repeat.tintColor = .white
        }
        SettingsManager.shared.nextRepeat()
    }
    @objc func shuffle() {
        switch SettingsManager.shared.settings.shuffle {
        case .off: ShuffleButton.tintColor = .red
        case .on: ShuffleButton.tintColor = .white }
        SettingsManager.shared.nextShuffle()
    }
    @objc func playStop() {
        APManager.shared.playPause()
        changePicture(buttonSize: buttonSize, button: PlayPauseButton)
    }
    @objc func NextMusicPlay() {
        APManager.shared.playNextSong()
        PlayPauseButton.setImage(UIImage(systemName: "pause.fill")?.resized(to: buttonSize), for: .normal)
    }
    @objc func PrevMusicPlay() {
        APManager.shared.playPrevSong()
        PlayPauseButton.setImage(UIImage(systemName: "pause.fill")?.resized(to: buttonSize), for: .normal)
    }
    @objc func scrubAudio() {
        if let audioPlayer = APManager.shared.audioPlayer {
            APManager.shared.isPlaying = true
            PlayPauseButton.setImage(UIImage(systemName: "pause.fill")?.resized(to: buttonSize), for: .normal)
            audioPlayer.seek(to: CMTime(seconds: Double(slider.value), preferredTimescale: 1),
                             toleranceBefore: .zero, toleranceAfter: .zero)
            audioPlayer.play()
        }
    }
    @objc func sliderValueChanged(_ sender: UISlider) {
        if let audioPlayer = APManager.shared.audioPlayer {
            APManager.shared.isPlaying = false
            audioPlayer.pause()
        }
    }
    @objc private func swipeGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            let transition = gestureRecognizer.translation(in: view)
            if transition.y > 0 {
                dismiss(animated: true)
            }
        }
    }
}

// MARK: PlayerViewControllerDelegate methods
extension PlayerViewController: PlayerViewControllerDelegate {
    func changeSong(song: Audio) {
        self.imageView.image = song.image
        self.slider.maximumValue = APManager.shared.songs[APManager.shared.currentIndex!].duration
        self.titleLabel.text = song.title
        self.artistLabel.text = song.artist
    }
    func pause() {
        self.PlayPauseButton.setImage(UIImage(systemName: "play.fill")?.withTintColor(.white).resized(to: buttonSize), for: .normal)
    }
}
// MARK: UI
extension PlayerViewController {
    private func setupView() {
        overrideUserInterfaceStyle = .dark
        let NextMusicButton = UIButton(type: .system)
        let PrevMusicButton = UIButton(type: .system)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeGesture(_:)))
        imageView.tintColor = .black
        imageView.clipsToBounds = true
        titleLabel.textAlignment = .center
        titleLabel.text = "Nothing there buddy"
        titleLabel.numberOfLines = 2
        titleLabel.font = .boldSystemFont(ofSize: 20)
        artistLabel.textAlignment = .center
        artistLabel.text = "and there too"
        artistLabel.font = .systemFont(ofSize: 15)
        slider.tintColor = .white
        slider.thumbTintColor = .white
        view.backgroundColor = .black
        view.addSubview(PlayPauseButton)
        view.addSubview(NextMusicButton)
        view.addSubview(PrevMusicButton)
        view.addSubview(ShuffleButton)
        view.addSubview(slider)
        view.addSubview(Repeat)
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        view.addSubview(artistLabel)
        view.addGestureRecognizer(panGestureRecognizer)
        
        PlayPauseButton.setImage(UIImage(systemName: "play.fill")?.withTintColor(.white).resized(to: buttonSize), for: .normal)
        PlayPauseButton.addTarget(self, action: #selector(playStop), for: .touchUpInside)
        PlayPauseButton.tintColor = .white
        PlayPauseButton.imageView?.contentMode = .scaleToFill
        
        NextMusicButton.setImage(UIImage(systemName: "arrowtriangle.right")?.withTintColor(.white).resized(to: buttonSize), for: .normal)
        NextMusicButton.addTarget(self, action: #selector(NextMusicPlay), for: .touchUpInside)
        NextMusicButton.tintColor = .white
        
        Repeat.setImage(UIImage(systemName: "repeat")?.withTintColor(.white).resized(to: buttonSize), for: .normal)
        Repeat.addTarget(self, action: #selector(repeatAction), for: .touchUpInside)
        switch SettingsManager.shared.settings.repeating {
        case .off: Repeat.tintColor = .white
        case .oneSong:
            Repeat.setImage(UIImage(systemName: "repeat.1")?.withTintColor(.white).resized(to: buttonSize), for: .normal)
            Repeat.tintColor = .red
        }
        
        ShuffleButton.setImage(UIImage(systemName: "shuffle")?.withTintColor(.white).resized(to: buttonSize), for: .normal)
        ShuffleButton.addTarget(self, action: #selector(shuffle), for: .touchUpInside)
        switch SettingsManager.shared.settings.shuffle {
        case .on: ShuffleButton.tintColor = .red
        case .off: ShuffleButton.tintColor = .white
        }
        
        PrevMusicButton.setImage(UIImage(systemName: "arrowtriangle.backward")?.withTintColor(.white).resized(to: buttonSize), for: .normal)
        PrevMusicButton.addTarget(self, action: #selector(PrevMusicPlay), for: .touchUpInside)
        PrevMusicButton.tintColor = .white
        
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(scrubAudio), for: .touchUpInside)
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
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
