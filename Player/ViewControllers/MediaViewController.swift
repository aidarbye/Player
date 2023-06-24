import UIKit
import SnapKit
import UniformTypeIdentifiers
import AVKit

class MediaViewController: UIViewController, UIDocumentPickerDelegate, UITextFieldDelegate {
    
    let tableView = UITableView()
    let textField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    func setupView() {
        let button = UIBarButtonItem(barButtonSystemItem: .add,target: self,action: #selector(add))
        button.tintColor = .black
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(UIImage(systemName: "x.circle"), for: .normal)
        clearButton.addTarget(self, action: #selector(clearSearchText), for: .touchUpInside)
        clearButton.tintColor = .black
        title = "Library"
        view.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = button
        tableView.register(MusicTableViewCell.self, forCellReuseIdentifier: "MusicCell")
        tableView.delegate = self
        tableView.dataSource = self
        textField.delegate = self
        tableView.allowsSelection = true
        textField.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
        textField.layer.cornerRadius = 10
        textField.placeholder = "Search"
        textField.rightView = clearButton
        textField.rightViewMode = .always
        view.addSubview(tableView)
        view.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(40)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let url = AudioPlayer.shared.songs[indexPath.row].filePath
        AudioPlayer.shared.audioPlayer = nil
        AudioPlayer.shared.playAudio(fileURL: URL(string: url)!)
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
        for url in urls {
            let selectedUrl = url
            Task {
                //MARK: Temporary
                if let metadata = await getMetadataFromURL(selectedUrl: selectedUrl) {
                    let image = await getImageFromMetadata(metadata: metadata)
                    let artist = await getArtistFromMetadata(metadata: metadata)
                    let title = await getTitleFromMetadata(metadata: metadata)
                    let duration = await getDurationFromUrl(selectedUrl: selectedUrl)
                    let filePath = selectedUrl.path(percentEncoded: true)
                    let AudioFile = Audio(filePath: filePath,title: title,artist: artist,image: image,duration: duration)
                    AudioPlayer.shared.songs.insert(AudioFile, at: AudioPlayer.shared.songs.count)
                    tableView.insertRows(at: [IndexPath(row: AudioPlayer.shared.songs.count - 1, section: 0)], with: .automatic)
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
func getImageFromMetadata(metadata: [AVMetadataItem]) async -> UIImage {
    do {
        for metadataItem in metadata {
            if metadataItem.commonKey?.rawValue == "artwork" {
                let data = try await metadataItem.load(.value) as! Data
                if let image = UIImage(data: data) {
                    return image
                }
            }
        }
    } catch {
        print(error.localizedDescription)
    }
    return UIImage(systemName: "music.note")!
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
