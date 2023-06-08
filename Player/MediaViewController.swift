import UIKit
import SnapKit
import MobileCoreServices
import UniformTypeIdentifiers

class MediaViewController: UIViewController, UIDocumentPickerDelegate {
    let tableView = UITableView()
    private var audioFiles: [AudioFile] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Music"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        let button = UIBarButtonItem(barButtonSystemItem: .add,
                                     target: self,
                                     action: #selector(add))
        navigationItem.rightBarButtonItem = button
        tableView.register(MusicTableViewCell.self, forCellReuseIdentifier: "MusicCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let selectedUrl = urls[0]
        let fileName = selectedUrl.lastPathComponent
        let filePath = selectedUrl.path(percentEncoded: true)
        let AudioFile = AudioFile(filePath: filePath, fileName: fileName)
        let insertIndex = audioFiles.count
        audioFiles.insert(AudioFile, at: insertIndex)
        tableView.insertRows(at: [IndexPath(row: insertIndex, section: 0)], with: .automatic)
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("canceled")
    }
    @objc private func add() {
        let supportedTypes: [UTType] = [UTType.audio]
        let pickerViewController = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
        pickerViewController.delegate = self
        pickerViewController.allowsMultipleSelection = false
        pickerViewController.shouldShowFileExtensions = true
        self.present(pickerViewController, animated: true, completion: nil)
    }
}
extension MediaViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        audioFiles.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        AudioPlayer.shared.playAudio(fileURL: URL(string: audioFiles[indexPath.row].filePath)!)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MusicTableViewCell(style: .default, reuseIdentifier: "MusicCell")
        cell.titleLabel.text = audioFiles[indexPath.row].fileName
        return cell
    }
}
