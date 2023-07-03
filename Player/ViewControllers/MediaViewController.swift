import UIKit
import SnapKit
import UniformTypeIdentifiers
import AVKit
/*
 After song searched, play only this songs, should put in another view?
 Optimize some process(like, its should be optional rght?)
 Timer? left bar button item
 UI!
*/

protocol MediaViewControllerDelegate {
    func changeREDselect()
}

class MediaViewController: UIViewController, MediaViewControllerDelegate {
    let buttonSize = CGSize(width: 20, height: 20)
    var songs: [Audio] = []
    let tableView = UITableView()
    let textField = UITextField()
    let playerView = PlayerView()
    var PlayerVC: PlayerViewController?
    var timer: Timer?
    
    override func viewDidLoad() {
        songs = APManager.shared.songs
        PlayerVC = PlayerViewController()
        PlayerVC?.modalPresentationStyle = .fullScreen
        APManager.shared.delegateMVC = self
        setupView()
    }
    override func viewWillAppear(_ animated: Bool) {
        print("apperainceMEDIA")
        if APManager.shared.isPlaying {
            playerView.playPauseButton.setImage(UIImage(systemName: "pause.fill")?.resized(to: buttonSize), for: .normal)
        } else {
            playerView.playPauseButton.setImage(UIImage(systemName: "play.fill")?.resized(to: buttonSize), for: .normal)
        }
        if let value = APManager.shared.audioPlayer?.currentTime(),
           let duration = APManager.shared.audioPlayer?.currentItem?.duration {
                self.playerView.progress.setProgress(Float(value.seconds / duration.seconds),
                                                     animated: false)
        }
        if timer == nil {
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (_) in
                if APManager.shared.isPlaying {
                    if let value = APManager.shared.audioPlayer?.currentTime(),
                       let duration = APManager.shared.audioPlayer?.currentItem?.duration {
                            self.playerView.progress.setProgress(Float(value.seconds / duration.seconds),
                                                                 animated: false)
                    }
                }
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("disapearMEDIA")
        timer?.invalidate()
        timer = nil
    }
}
// MARK: TableViewDelegate
extension MediaViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        songs.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var index = 0
            for i in APManager.shared.songs.indices {
                if APManager.shared.songs[i] == songs[indexPath.row] {
                    index = i
                    break
                }
            }
            
            APManager.shared.songs.remove(at: index)
            songs.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        APManager.shared.currentIndex = indexPath.row
        APManager.shared.playAudio(fileName: songs[indexPath.row].fileName)
        APManager.shared.delegate?.changeSong(song: songs[indexPath.row])
        APManager.shared.delegatePV?.songChange(song: songs[indexPath.row])
        playerView.playPauseButton.setImage(UIImage(systemName: "pause.fill")?.resized(to: buttonSize), for: .normal)
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let index = APManager.shared.currentIndex else { return }
        if index == indexPath.row {
            cell.contentView.layer.borderColor = UIColor.red.cgColor
            cell.contentView.layer.borderWidth = 2
        } else {
            cell.contentView.layer.borderColor = UIColor.white.cgColor
            cell.contentView.layer.borderWidth = 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MusicTableViewCell(style: .default, reuseIdentifier: "MusicCell")
        cell.titleLabel.text = songs[indexPath.row].title
        cell.image.image = songs[indexPath.row].image
        return cell
    }
    func changeREDselect() {
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        songs.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        APManager.shared.songs.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        if APManager.shared.isPlaying {
            APManager.shared.currentIndex? = destinationIndexPath.row
        }
    }
}

// MARK: @objc methods
extension MediaViewController {
    @objc private func swipeGesture(_ gestureRecognizer: UISwipeGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            guard let pvc = PlayerVC else {return}
            present(pvc, animated: true)
        }
    }
    @objc private func tapGesture() {
        guard let pvc = PlayerVC else { return }
        present(pvc, animated: true)
    }
    @objc private func clearSearchText() {
        textField.text = ""
        songs = APManager.shared.songs
        tableView.reloadData()
    }
    @objc private func add() {
        let supportedTypes: [UTType] = [UTType.audio]
        let pickerViewController = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes,
                                                                  asCopy: true)
        pickerViewController.delegate = self
        pickerViewController.allowsMultipleSelection = true
        pickerViewController.shouldShowFileExtensions = true
        
        self.present(pickerViewController, animated: true, completion: nil)
    }
    @objc private func edit() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        if tableView.isEditing {
            let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(edit))
            button.tintColor = .black
            navigationItem.rightBarButtonItems![1] = button
        }
        else {
            let button = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(edit))
            button.tintColor = .black
            navigationItem.rightBarButtonItems![1] = button
        }
    }
}

// MARK: TextFieldDelegate methods
extension MediaViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let text = textField.text else { return true }
        if text.isEmpty {
            songs = APManager.shared.songs
            tableView.reloadData()
        }
        let filteredSongs = APManager.shared.songs.filter {$0.title.lowercased().contains(text.lowercased())}
        if filteredSongs.isEmpty { return true } else {
            songs = filteredSongs
            tableView.reloadData()
        }
        return true
    }
}

// MARK: DocumentPicker delegate method
extension MediaViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for url in urls {
            let fileName = url.lastPathComponent
            let destinationURL = documentsDirectory.appendingPathComponent(fileName)
            do { try fileManager.moveItem(at: url, to: destinationURL) } catch {  }
            Task {
                if let metadata = await getMetadataFromURL(selectedUrl: destinationURL) {
                    let imageData = await getImageFromMetadata(metadata: metadata)
                    let artist = await getArtistFromMetadata(metadata: metadata)
                    let title = await getTitleFromMetadata(metadata: metadata)
                    let duration = await getDurationFromUrl(selectedUrl: url)
                    let fileName = url.absoluteURL.lastPathComponent
                    let AudioFile = Audio(fileName: fileName,title: title,artist: artist, duration: duration, imageData: imageData)
                    if !APManager.shared.songs.contains(AudioFile) {
                        APManager.shared.songs.insert(AudioFile, at: APManager.shared.songs.count)
                        songs.insert(AudioFile, at: songs.count)
                        tableView.insertRows(at: [IndexPath(row: songs.count - 1, section: 0)], with: .automatic)
                    }
                }
            }
        }
    }
}
func getMetadataFromURL(selectedUrl: URL) async -> [AVMetadataItem]? {
    let asset = AVAsset(url: selectedUrl)
    do {
     return try await asset.load(.commonMetadata)
    } catch {
     print(error.localizedDescription)
    }
    return nil
}
func getImageFromMetadata(metadata: [AVMetadataItem]) async -> Data {
    do {
        for metadataItem in metadata {
            if metadataItem.commonKey?.rawValue == "artwork" {
                let data = try await metadataItem.load(.value) as! Data
                return data
            }
        }
    } catch {
        print(error.localizedDescription)
    }
    return Data()
}
func getArtistFromMetadata(metadata: [AVMetadataItem]) async -> String {
    do {
        for metadataItem in metadata {
            if metadataItem.commonKey?.rawValue == "artist" {
                return try await metadataItem.load(.value) as! String
            }
        }
    } catch {
        print(error.localizedDescription)
    }
    return "NoName"
}
func getTitleFromMetadata(metadata: [AVMetadataItem]) async -> String {
    do {
        for metadataItem in metadata {
            if metadataItem.commonKey?.rawValue == "title" {
                return try await metadataItem.load(.value) as! String
            }
        }
    } catch {
        print(error.localizedDescription)
    }
    return "NoName"
}
func getDurationFromUrl(selectedUrl: URL) async -> Float {
    let asset = AVAsset(url: selectedUrl)
    do {
        let duration = try await asset.load(.duration)
        let seconds = CMTimeGetSeconds(duration)
        return Float(seconds)
    } catch {
        print(error.localizedDescription)
    }
    return 0.0
}
// MARK: UI
extension MediaViewController {
    func setupView() {
        overrideUserInterfaceStyle = .light
        let addButton = UIBarButtonItem(barButtonSystemItem: .add,target: self,action: #selector(add))
        addButton.tintColor = .black
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(edit))
        editButton.tintColor = .black
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(UIImage(systemName: "x.circle"), for: .normal)
        clearButton.tintColor = .red
        clearButton.addTarget(self, action: #selector(clearSearchText), for: .touchUpInside)
        title = "media"
        view.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItems = [addButton,editButton]
        textField.delegate = self
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
        textField.layer.cornerRadius = 10
        textField.placeholder = " search"
        textField.rightView = clearButton
        textField.rightViewMode = .always
        tableView.allowsSelection = true
        tableView.register(MusicTableViewCell.self, forCellReuseIdentifier: "MusicCell")
        tableView.delegate = self
        tableView.dataSource = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeGesture(_:)))
        panGestureRecognizer.cancelsTouchesInView = false
        playerView.addGestureRecognizer(panGestureRecognizer)
        playerView.addGestureRecognizer(tap)
        view.addSubview(tableView)
        view.addSubview(textField)
        view.addSubview(playerView)
        textField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(40)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        playerView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.width.equalToSuperview()
            make.height.equalTo(50)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(playerView.snp.top)
        }
    }
}
