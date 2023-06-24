import UIKit
import SnapKit

protocol PlayerViewControllerDelegate {
    func changeSong(song: Audio)
}

class PlayerViewController: UIViewController, PlayerViewControllerDelegate {
    let imageView = UIImageView()
    var slider = UISlider()
    let shared = AudioPlayer.shared
    var timer: Timer?
    
    override func viewDidLoad() {
        AudioPlayer.shared.delegate = self
        super.viewDidLoad()
        setupView()
    }
    override func viewWillAppear(_ animated: Bool) {
        if let value = self.shared.audioPlayer?.currentTime {
            self.slider.value = Float(value)
        }
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (_) in
                if self.shared.isPlaying {
                    if let value = self.shared.audioPlayer?.currentTime {
                        self.slider.value = Float(value)
                        print(self.slider.value)
                    }
                }
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
        timer = nil
    }
    @objc func repeatAction() {
        print(#function)
    }
    @objc func playStop() {
        if AudioPlayer.shared.currentSong != nil {
            if AudioPlayer.shared.isPlaying {
                AudioPlayer.shared.pause()
            } else {
                AudioPlayer.shared.resume()
            }
            AudioPlayer.shared.isPlaying.toggle()
        }
    }
    @objc func NextMusicPlay() {
        if let _ = shared.audioPlayer {
            if AudioPlayer.shared.songs.isEmpty {
                return
            }
            AudioPlayer.shared.playNextSong()
        }
    }
    @objc func PrevMusicPlay() {
        if let _ = shared.audioPlayer {
            if AudioPlayer.shared.songs.isEmpty {
                return
            }
            AudioPlayer.shared.playPrevSong()
        }
    }
    @objc func scrubAudio() {
        print(#function)
        if let audioPlayer = shared.audioPlayer {
            shared.isPlaying = true
            audioPlayer.currentTime = TimeInterval(slider.value)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }
    }
    @objc func sliderValueChanged(_ sender: UISlider) {
        if let audioPlayer = shared.audioPlayer {
            shared.isPlaying = false
            audioPlayer.stop()
            print(sender.value)
        }
    }
    func changeSong(song: Audio) {
        AudioPlayer.shared.currentSong = song
        self.imageView.image = song.image
        self.slider.maximumValue = song.duration
    }
}


extension PlayerViewController {
    private func setupView() {
        view.backgroundColor = .white
        let PlayPauseButton = UIButton(type: .system)
        let NextMusicButton = UIButton(type: .system)
        let PrevMusicButton = UIButton(type: .system)
        let Repeat = UIButton(type: .system)
        imageView.image = UIImage(systemName: "rectangle.fill")
        imageView.tintColor = .black
        view.addSubview(imageView)
        view.addSubview(PlayPauseButton)
        view.addSubview(NextMusicButton)
        view.addSubview(PrevMusicButton)
        view.addSubview(slider)
        view.addSubview(Repeat)
        imageView.snp.makeConstraints { make in
            make.height.equalTo(350)
            make.width.equalToSuperview().offset(10)
            make.centerY.equalToSuperview().offset(-30)
            make.centerX.equalToSuperview()
        }
        slider.snp.makeConstraints { make in
            make.width.equalToSuperview().offset(-30)
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(30)
        }
        
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
        
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(scrubAudio), for: .touchUpInside)
        
        PlayPauseButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(slider.snp.bottom).offset(30)
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
    }
}
