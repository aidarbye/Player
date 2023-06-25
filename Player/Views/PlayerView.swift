import UIKit
import SnapKit
import Foundation
class PlayerView: UIView {
    let label = UILabel()
    let progress = UIProgressView()
    let playPauseButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupView() {
        backgroundColor = UIColor(red: 228/255, green: 228/255, blue: 228/255, alpha: 1)
        addSubview(label)
        addSubview(progress)
        addSubview(playPauseButton)
        label.text = "nothing"
        label.textAlignment = .center
        progress.backgroundColor = .black
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playPauseButton.tintColor = .black
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
