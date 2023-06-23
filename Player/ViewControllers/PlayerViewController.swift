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
        print("init PlayerVC")
        super.viewDidLoad()
        setupView()
        if let duration = shared.audioPlayer?.duration {
            slider.maximumValue = Float(duration)
        }
        imageView.image = shared.songs[shared.currentIndex].image
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
        print(#function)
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
        print(#function)
        if AudioPlayer.shared.songs.isEmpty {
            return
        }
        AudioPlayer.shared.playNextSong()
    }
    @objc func PrevMusicPlay() {
        print(#function)
        if AudioPlayer.shared.songs.isEmpty {
            return
        }
        AudioPlayer.shared.playPrevSong()
    }
    @objc func scrubAudio() {
        print(#function)
        shared.audioPlayer?.currentTime = TimeInterval(slider.value)
        shared.audioPlayer?.prepareToPlay()
        shared.audioPlayer?.play()
    }
    @objc func sliderValueChanged(_ sender: UISlider) {
        print(#function)
        shared.audioPlayer?.stop()
        print(sender.value)
    }
    func changeSong(song: Audio) {
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
        imageView.image = UIImage(systemName: "rectangle.on.rectangle.square")
        view.addSubview(imageView)
        view.addSubview(PlayPauseButton)
        view.addSubview(NextMusicButton)
        view.addSubview(PrevMusicButton)
        view.addSubview(slider)
        view.addSubview(Repeat)
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(400)
            make.centerY.equalToSuperview().offset(-30)
            make.centerX.equalToSuperview()
        }
        
        slider.snp.makeConstraints { make in
            make.width.equalToSuperview().offset(-30)
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(40)
        }
        
        PlayPauseButton.setImage(UIImage(systemName: "playpause"), for: .normal)
        PlayPauseButton.addTarget(self, action: #selector(playStop), for: .touchUpInside)
        
        NextMusicButton.setImage(UIImage(systemName: "arrowtriangle.right"), for: .normal)
        NextMusicButton.addTarget(self, action: #selector(NextMusicPlay), for: .touchUpInside)
        
        Repeat.setImage(UIImage(systemName: "repeat"), for: .normal)
        Repeat.addTarget(self, action: #selector(repeatAction), for: .touchUpInside)
        
        PrevMusicButton.setImage(UIImage(systemName: "arrowtriangle.backward"), for: .normal)
        PrevMusicButton.addTarget(self, action: #selector(PrevMusicPlay), for: .touchUpInside)
        
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(scrubAudio), for: .touchUpInside)
        
        PlayPauseButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(slider.snp.bottom).offset(20)
        }
        
        NextMusicButton.snp.makeConstraints { make in
            make.centerY.equalTo(PlayPauseButton.snp.centerY)
            make.centerX.equalTo(PlayPauseButton.snp.centerX).offset(50)
        }
        
        PrevMusicButton.snp.makeConstraints { make in
            make.centerY.equalTo(PlayPauseButton.snp.centerY)
            make.centerX.equalTo(PlayPauseButton.snp.centerX).offset(-50)
        }
        Repeat.snp.makeConstraints { make in
            make.centerY.equalTo(PlayPauseButton.snp.centerY)
            make.centerX.equalTo(PrevMusicButton.snp.centerX).offset(-50)
        }
    }
}
