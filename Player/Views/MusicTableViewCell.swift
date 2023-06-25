import UIKit

class MusicTableViewCell: UITableViewCell {
    let titleLabel = UILabel()
    let image = UIImageView(image: UIImage(systemName: "music.note"))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(image)
        titleLabel.tintColor = .black
        image.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(50)
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(image.snp_rightMargin).offset(20)
            make.centerY.equalToSuperview()
            make.height.equalTo(50)
            make.right.equalTo(contentView.snp_rightMargin).offset(20)
        }
        
    }
}
