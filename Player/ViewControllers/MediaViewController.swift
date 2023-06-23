import UIKit
import SnapKit
import UniformTypeIdentifiers
import AVKit

class MediaViewController: UIViewController, UIDocumentPickerDelegate {
    
    let tableView = UITableView()
    
    override func viewDidLoad() {
        print("init MediaVC")
        super.viewDidLoad()
        setupView()
    }
    
    @objc private func add() {
        let supportedTypes: [UTType] = [UTType.audio]
        let pickerViewController = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
        pickerViewController.delegate = self
        pickerViewController.allowsMultipleSelection = false
        pickerViewController.shouldShowFileExtensions = true
        self.present(pickerViewController, animated: true, completion: nil)
    }
    func setupView() {
        view.backgroundColor = .white
        title = "Music"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        let button = UIBarButtonItem(barButtonSystemItem: .add,target: self,action: #selector(add))
        navigationItem.rightBarButtonItem = button
        tableView.register(MusicTableViewCell.self, forCellReuseIdentifier: "MusicCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
        AudioPlayer.shared.playAudio(fileURL: URL(string: url)!)
        AudioPlayer.shared.currentIndex = indexPath.row
        AudioPlayer.shared.currentSong = AudioPlayer.shared.songs[indexPath.row]
        AudioPlayer.shared.delegate?.changeSong(song: AudioPlayer.shared.songs[indexPath.row])
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
        let selectedUrl = urls[0]
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
/* MARK: will add later
func extractAlbumArtwork(from audioURL: URL) async -> UIImage? {
    let asset = AVURLAsset(url: audioURL)
    do {
        guard let format = try await asset.load(.availableMetadataFormats).first else {
            return nil
        }
        let metadata = try await asset.loadMetadata(for: format)
        for item in metadata {
            if let data = try await item.load(.dataValue),
               item.commonKey?.rawValue == "artwork",
               let image = UIImage(data: data) {
                return image
            }
        }
    } catch {
        print(error.localizedDescription)
        print(#function)
    }
    return nil
}
 
 func getData(selectedUrl: URL) async -> UIImage? {
  let asset = AVAsset(url: selectedUrl)
  do {
      let duration = try await asset.load(.duration)
      let metadata = try await asset.load(.commonMetadata)
      
      for metadataItem in metadata {
          if let key = metadataItem.commonKey?.rawValue,
             let value = try await metadataItem.load(.value) {
              print("Key: \(key), Value: \(value)")
          }
      }
      
      for i in metadata {
          if i.commonKey?.rawValue == "artwork" {
              let data = try await i.load(.value) as! Data
              print("this is -> \(data)")
              return UIImage(data: data)
          }
          if i.commonKey?.rawValue == "title"{
              let title = try await i.load(.value) as! String
              print("this is -> \(title)")
          }
      }
      print(duration)
  } catch {
      print(error.localizedDescription)
  }
  return nil
 }
*/
