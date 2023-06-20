import UIKit
import SnapKit

class PlayerViewController: UIViewController {
    let imageView = UIImageView()
    
    override func viewDidLoad() {
        print("init PlayerVC")
        super.viewDidLoad()
        setupView()
        
    }
    @objc func repeatAction() {
        print(#function)
    }
    @objc func playStop() {
        print(#function)
    }
    @objc func NextMusicPlay() {
        print(#function)
    }
    @objc func PrevMusicPlay() {
        print(#function)
    }
}

extension PlayerViewController {
    private func setupView() {
        view.backgroundColor = .white
        let PlayPauseButton = UIButton(type: .system)
        let NextMusicButton = UIButton(type: .system)
        let PrevMusicButton = UIButton(type: .system)
        let Repeat = UIButton(type: .system)
        let Slider = UISlider()
        imageView.image = UIImage(systemName: "rectangle.on.rectangle.square")
        view.addSubview(imageView)
        view.addSubview(PlayPauseButton)
        view.addSubview(NextMusicButton)
        view.addSubview(PrevMusicButton)
        view.addSubview(Slider)
        view.addSubview(Repeat)
        
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(400)
            make.centerY.equalToSuperview().offset(-30)
            make.centerX.equalToSuperview()
        }
        
        Slider.snp.makeConstraints { make in
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
        
        PlayPauseButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(Slider.snp.bottom).offset(20)
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
