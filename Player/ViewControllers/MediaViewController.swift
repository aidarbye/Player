import UIKit
import SnapKit
import UniformTypeIdentifiers
import AVKit

class MediaViewController: UIViewController, UIDocumentPickerDelegate, UITextFieldDelegate {
    
    let tableView = UITableView()
    let textField = UITextField()
    let playerView = PlayerView()
    
    override func viewDidLoad() {
        setupView()
    }
    @objc private func clearSearchText() {
        textField.text = ""
    }
    @objc private func add() {
        let supportedTypes: [UTType] = [UTType.audio]
        let pickerViewController = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
        pickerViewController.delegate = self
        pickerViewController.allowsMultipleSelection = true
        pickerViewController.shouldShowFileExtensions = true
        self.present(pickerViewController, animated: true, completion: nil)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        try? AVAudioSession.sharedInstance().setActive(false)
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    func setupView() {
        let button = UIBarButtonItem(barButtonSystemItem: .add,target: self,action: #selector(add))
        let clearButton = UIButton(type: .custom)
        button.tintColor = .black
        clearButton.setImage(UIImage(systemName: "x.circle"), for: .normal)
        clearButton.addTarget(self, action: #selector(clearSearchText), for: .touchUpInside)
        clearButton.tintColor = .black
        title = "Library"
        view.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = button
        textField.delegate = self
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
        textField.layer.cornerRadius = 10
        textField.placeholder = "Search"
        textField.rightView = clearButton
        textField.rightViewMode = .always
        tableView.allowsSelection = true
        tableView.register(MusicTableViewCell.self, forCellReuseIdentifier: "MusicCell")
        tableView.delegate = self
        tableView.dataSource = self
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
// MARK: TableViewDelegate
extension MediaViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        AudioPlayer.shared.songs.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //MARK: Should change there by removing by name, not index and change StorageManager bruh
            AudioPlayer.shared.songs.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            StorageManager.shared.save(songs: AudioPlayer.shared.songs)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        AudioPlayer.shared.playAudio(fileName: AudioPlayer.shared.songs[indexPath.row].fileName)
        AudioPlayer.shared.currentIndex = indexPath.row
        AudioPlayer.shared.currentSong = AudioPlayer.shared.songs[indexPath.row]
        AudioPlayer.shared.delegate?.changeSong(
            song: AudioPlayer.shared.songs[indexPath.row])
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MusicTableViewCell(style: .default, reuseIdentifier: "MusicCell")
        cell.titleLabel.text = AudioPlayer.shared.songs[indexPath.row].title
        cell.image.image = AudioPlayer.shared.songs[indexPath.row].image
        return cell
    }
}
// MARK: DocumentPicker
extension MediaViewController {
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
                //MARK: Temporary funcs, change them all, optimize
                if let metadata = await getMetadataFromURL(selectedUrl: url) {
                    let imageData = await getImageFromMetadata(metadata: metadata)
                    let artist = await getArtistFromMetadata(metadata: metadata)
                    let title = await getTitleFromMetadata(metadata: metadata)
                    let duration = await getDurationFromUrl(selectedUrl: url)
                    let fileName = url.absoluteURL.lastPathComponent
                    let AudioFile = Audio(fileName: fileName,title: title,artist: artist, duration: duration, imageData: imageData)
                    AudioPlayer.shared.songs.insert(AudioFile, at: AudioPlayer.shared.songs.count)
                    tableView.insertRows(at: [IndexPath(row: AudioPlayer.shared.songs.count - 1, section: 0)], with: .automatic)
                }
            }
        }
    }
}
//MARK: Same, optimize
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

