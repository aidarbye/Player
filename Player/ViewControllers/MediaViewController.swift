import UIKit
import SnapKit
import UniformTypeIdentifiers
import AVKit
/*
 Storage
 Repeat & Shuffle buttons
 Make UI look better(animation etc)
 Is there any way to load automatically?
 Editing(is it should be in storage?)
 Optimize some process(like, its should be optional rght?)
*/
class MediaViewController: UIViewController {
    var songs: [Audio] = []
    let tableView = UITableView()
    let textField = UITextField()
    let playerView = PlayerView()
    var PlayerVC: PlayerViewController?
    var timer: Timer?
    
    override func viewDidLoad() {
        PlayerVC = PlayerViewController()
        setupView()
    }
    override func viewWillAppear(_ animated: Bool) {
        print("apperaince")
        if let value = AudioPlayer.shared.audioPlayer?.currentTime(),
           let duration = AudioPlayer.shared.audioPlayer?.currentItem?.duration {
                self.playerView.progress.setProgress(Float(value.seconds / duration.seconds),
                                                     animated: false)
        }
        if timer == nil {
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (_) in
                if AudioPlayer.shared.isPlaying {
                    if let value = AudioPlayer.shared.audioPlayer?.currentTime(),
                       let duration = AudioPlayer.shared.audioPlayer?.currentItem?.duration {
                            self.playerView.progress.setProgress(Float(value.seconds / duration.seconds),
                                                                 animated: false)
                    }
                }
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("disapear")
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
            for i in AudioPlayer.shared.songs.indices {
                if AudioPlayer.shared.songs[i] == songs[indexPath.row] {
                    index = i
                    break
                }
            }
            
            AudioPlayer.shared.songs.remove(at: index)
            songs.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        AudioPlayer.shared.currentIndex = indexPath.row
        AudioPlayer.shared.playAudio(fileName: songs[indexPath.row].fileName)
        AudioPlayer.shared.delegate?.changeSong(song: songs[indexPath.row])
        AudioPlayer.shared.delegatePV?.songChange(song: songs[indexPath.row])
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MusicTableViewCell(style: .default, reuseIdentifier: "MusicCell")
        cell.titleLabel.text = songs[indexPath.row].title
        cell.image.image = songs[indexPath.row].image
        return cell
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
        songs = AudioPlayer.shared.songs
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
}

// MARK: TextFieldDelegate methods
extension MediaViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let text = textField.text else { return true }
        if text.isEmpty {
            songs = AudioPlayer.shared.songs
            tableView.reloadData()
        }
        let filteredSongs = AudioPlayer.shared.songs.filter {$0.title.lowercased().contains(text.lowercased())}
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
            do {
                try fileManager.moveItem(at: url, to: destinationURL)
                print("Файл успешно перемещен в директорию документов")
            } catch {
                print("Ошибка перемещения файла: \(error.localizedDescription)")
            }
            Task {
                if let metadata = await getMetadataFromURL(selectedUrl: destinationURL) {
                    let imageData = await getImageFromMetadata(metadata: metadata)
                    let artist = await getArtistFromMetadata(metadata: metadata)
                    let title = await getTitleFromMetadata(metadata: metadata)
                    let duration = await getDurationFromUrl(selectedUrl: url)
                    let fileName = url.absoluteURL.lastPathComponent
                    let AudioFile = Audio(fileName: fileName,title: title,artist: artist, duration: duration, imageData: imageData)
                    AudioPlayer.shared.songs.insert(AudioFile, at: AudioPlayer.shared.songs.count)
                    songs.insert(AudioFile, at: songs.count)
                    tableView.insertRows(at: [IndexPath(row: songs.count - 1, section: 0)], with: .automatic)
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
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(UIImage(systemName: "x.circle"), for: .normal)
        clearButton.addTarget(self, action: #selector(clearSearchText), for: .touchUpInside)
        clearButton.tintColor = .black
        title = "media"
        view.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = addButton
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
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
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
