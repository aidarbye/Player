import UIKit
import SnapKit
import UniformTypeIdentifiers

class MediaViewController: UIViewController, UIDocumentPickerDelegate {
    
    let tableView = UITableView()
    var audioFiles: [Audio] = []
    
    override func viewDidLoad() {
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
        audioFiles.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MusicTableViewCell(style: .default, reuseIdentifier: "MusicCell")
        cell.titleLabel.text = audioFiles[indexPath.row].fileName
        return cell
    }
}
// MARK: DocumentPicker

extension MediaViewController {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let selectedUrl = urls[0]
        let fileName = selectedUrl.lastPathComponent
        let filePath = selectedUrl.path(percentEncoded: true)
        let AudioFile = Audio(filePath: filePath, fileName: fileName)
        let insertIndex = audioFiles.count
        audioFiles.insert(AudioFile, at: insertIndex)
        tableView.insertRows(at: [IndexPath(row: insertIndex, section: 0)], with: .automatic)
    }
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
*/

