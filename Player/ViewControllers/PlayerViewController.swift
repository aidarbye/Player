import UIKit
import SnapKit
import MediaPlayer

//MARK: Change constaints, pause button also
protocol PlayerViewControllerDelegate {
    func changeSong(song: Audio)
}

class PlayerViewController: UIViewController {
    let imageView = UIImageView()
    let slider = UISlider()
    let label = UILabel()
    
    var delegate: PlayerViewControllerDelegate?
    var timer: Timer?
    
    override func viewDidLoad() {
        setupView()
        AudioPlayer.shared.delegate = self
        guard let index = AudioPlayer.shared.currentIndex else { return }
        self.imageView.image = AudioPlayer.shared.songs[index].image
        self.slider.maximumValue = AudioPlayer.shared.songs[index].duration
        self.label.text = AudioPlayer.shared.songs[index].title
    }
    override func viewWillAppear(_ animated: Bool) {
        if let value = AudioPlayer.shared.audioPlayer?.currentTime {
            self.slider.value = Float(value)
        }
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (_) in
                if AudioPlayer.shared.isPlaying {
                    if let value = AudioPlayer.shared.audioPlayer?.currentTime {
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
}

// MARK: objc methods
extension PlayerViewController {
    @objc func repeatAction() {
        print(#function)
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
            audioPlayer.currentTime = TimeInterval(slider.value)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }
    }
    @objc func sliderValueChanged(_ sender: UISlider) {
        if let audioPlayer = AudioPlayer.shared.audioPlayer {
            AudioPlayer.shared.isPlaying = false
            audioPlayer.stop()
            print(sender.value)
        }
    }
}

// MARK: PlayerViewControllerDelegate methods
extension PlayerViewController: PlayerViewControllerDelegate {
    func changeSong(song: Audio) {
        self.imageView.image = song.image
        self.slider.maximumValue = song.duration
        self.label.text = song.title
    }
}

// MARK: UI
extension PlayerViewController {
    private func setupView() {
        let PlayPauseButton = UIButton(type: .system)
        let NextMusicButton = UIButton(type: .system)
        let PrevMusicButton = UIButton(type: .system)
        let Repeat = UIButton(type: .system)
        imageView.image = UIImage(systemName: "rectangle.fill")
        imageView.tintColor = .black
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 40
        label.textAlignment = .center
        label.text = "Nothing there buddy"
        label.font = .boldSystemFont(ofSize: 20)
        slider.tintColor = .black
        slider.thumbTintColor = .black
        view.backgroundColor = .white
        view.addSubview(imageView)
        view.addSubview(PlayPauseButton)
        view.addSubview(NextMusicButton)
        view.addSubview(PrevMusicButton)
        view.addSubview(slider)
        view.addSubview(Repeat)
        view.addSubview(label)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(20)
            make.left.equalTo(view.snp.left).offset(10)
            make.right.equalTo(view.snp.right).offset(-10)
            make.centerX.equalToSuperview()
            make.height.equalTo(view.layer.bounds.width / 1.2)
        }
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(30)
            make.left.equalTo(view.snp.left).offset(10)
            make.right.equalTo(view.snp.right).offset(-10)
        }
        slider.snp.makeConstraints { make in
            make.width.equalToSuperview().offset(-30)
            make.centerX.equalToSuperview()
            make.top.equalTo(label.snp.bottom).offset(30)
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
