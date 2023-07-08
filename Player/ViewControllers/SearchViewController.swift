import UIKit
import SnapKit

final class SearchViewController: UIViewController,UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    let textField = UITextField()
    let cancelButton = UIButton()
    let toggle = UISegmentedControl(items: ["Title", "Author"])
    let tableView = UITableView()
    var songs: [Audio] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        textField.text = ""
        textField.resignFirstResponder()
    }
    @objc private func cancelAction() {
        textField.text = ""
        textField.resignFirstResponder()
    }
    @objc private func toggleAction(_ toggle: UISegmentedControl) {
        songs = []
        textField.text = ""
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        songs.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MusicTableViewCell(style: .default, reuseIdentifier: "MusicCell")
        cell.titleLabel.text = songs[indexPath.row].title
        cell.image.image = songs[indexPath.row].image
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var index = 0
        for i in APManager.shared.songs.indices {
            if APManager.shared.songs[i] == songs[indexPath.row] {
                index = i
                break
            }
        }
        APManager.shared.currentIndex = index
        APManager.shared.playAudio(fileName: songs[indexPath.row].fileName)
        APManager.shared.delegatePVC?.changeSong(song: APManager.shared.songs[index])
        APManager.shared.delegatePV?.songChange(song: APManager.shared.songs[index])
        tableView.reloadData()
    }
    
    func textFilterByTitle() {
        textField.resignFirstResponder()
        guard let text = textField.text else { return }
        if text.isEmpty {
            songs = []
            tableView.reloadData()
        }
        let filteredSongs = APManager.shared.songs.filter { $0.title.lowercased().contains(text.lowercased()) }
        if filteredSongs.isEmpty { return } else {
            songs = filteredSongs
            tableView.reloadData()
        }
    }
    func textFilterByAuthor() {
        textField.resignFirstResponder()
        guard let text = textField.text else { return }
        if text.isEmpty {
            songs = []
            tableView.reloadData()
        }
        let filteredSongs = APManager.shared.songs.filter { $0.artist.lowercased().contains(text.lowercased()) }
        if filteredSongs.isEmpty { return } else {
            songs = filteredSongs
            tableView.reloadData()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if toggle.selectedSegmentIndex == 0 {
            textFilterByTitle()
        } else {
            textFilterByAuthor()
        }
        print("end")
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.textField.snp.updateConstraints { make in
                make.trailing.equalToSuperview().offset(-10)
            }
            self?.cancelButton.snp.updateConstraints { make in
                make.leading.equalTo(textField.snp.trailing).offset(10)
            }
            self?.view.layoutIfNeeded()
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("start")
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.textField.snp.updateConstraints { [weak self] make in
                make.trailing.equalToSuperview().offset(-((self?.view.bounds.width)! / 3.5))
            }
            self?.cancelButton.snp.updateConstraints { make in
                make.leading.equalTo(textField.snp.trailing).offset(10)
            }
            self?.view.layoutIfNeeded()
        }
    }
    
    private func setupView() {
        overrideUserInterfaceStyle = .dark
        view.addSubview(textField)
        view.addSubview(cancelButton)
        view.addSubview(toggle)
        view.addSubview(tableView)
        toggle.selectedSegmentIndex = 0
        cancelButton.backgroundColor = .black
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.red, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        cancelButton.layer.cornerRadius = 7
        textField.delegate = self
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.placeholder = " search "
        textField.backgroundColor = .init(red: 22/255, green: 22/255, blue: 22/255, alpha: 1)
        textField.layer.cornerRadius = 7
        let leftViewContainer = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        leftViewContainer.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: leftViewContainer.leadingAnchor, constant: 5).isActive = true
        imageView.trailingAnchor.constraint(equalTo: leftViewContainer.trailingAnchor, constant: -5).isActive = true
        imageView.topAnchor.constraint(equalTo: leftViewContainer.topAnchor, constant: 5).isActive = true
        imageView.bottomAnchor.constraint(equalTo: leftViewContainer.bottomAnchor, constant: -5).isActive = true
        textField.leftView = leftViewContainer
        textField.leftViewMode = .always
        toggle.addTarget(self, action: #selector(toggleAction(_:)), for: .valueChanged)
        
        tableView.allowsSelection = true
        tableView.backgroundColor = .black
        tableView.register(MusicTableViewCell.self, forCellReuseIdentifier: "MusicCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-10)
            make.height.equalTo(40)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-10)
            make.leading.equalTo(textField.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(40)
        }
        toggle.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(10)
            make.width.equalToSuperview()
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(toggle.snp.bottom).offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.snp.bottom)
        }
    }
}
