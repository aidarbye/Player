import UIKit
import SwiftUI
import SnapKit
import UniformTypeIdentifiers
import AVKit
import Combine

protocol MediaViewControllerDelegate {
    func nowSelectedAudio()
}

final class MediaViewController: UIViewController, MediaViewControllerDelegate {
    let buttonSize = CGSize(width: 20, height: 20)
    let tableView = UITableView()
    let playerView = PlayerView()
    var vm: TimerViewModel = TimerViewModel()
    var PlayerVC = PlayerViewController()
    var timer: Timer?

    var cancellable: AnyCancellable?
    var anothercanc: AnyCancellable?
    var forcedcanc: AnyCancellable?
    
    var host = UIHostingController(rootView: TimerView(vm: TimerViewModel()))
    var timerTV: Timer?
    
    override func viewDidLoad() {
        APManager.shared.delegateMVC = self
        host.rootView = TimerView(vm: self.vm)
        setupView()
    }
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        changePicture(buttonSize: buttonSize, button: playerView.playPauseButton)
        if let value = APManager.shared.audioPlayer?.currentTime(),
           let duration = APManager.shared.audioPlayer?.currentItem?.duration {
                self.playerView.progress.setProgress(Float(value.seconds / duration.seconds),
                                                     animated: false)
        }
        if timer == nil {
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] (_) in
                if APManager.shared.isPlaying {
                    if let value = APManager.shared.audioPlayer?.currentTime(),
                       let duration = APManager.shared.audioPlayer?.currentItem?.duration {
                            self?.playerView.progress.setProgress(Float(value.seconds / duration.seconds),
                                                                 animated: false)
                    }
                }
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
        timer = nil
    }
    func nowSelectedAudio() {
        tableView.reloadData()
    }
}
// MARK: TableViewDelegate
extension MediaViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        APManager.shared.songs.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            APManager.shared.songs.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        APManager.shared.currentIndex = indexPath.row
        APManager.shared.playAudio(fileName: APManager.shared.songs[indexPath.row].fileName)
        APManager.shared.delegatePVC?.changeSong(song: APManager.shared.songs[indexPath.row])
        APManager.shared.delegatePV?.songChange(song: APManager.shared.songs[indexPath.row])
        playerView.playPauseButton.setImage(UIImage(systemName: "pause.fill")?.withTintColor(.white).resized(to: buttonSize), for: .normal)
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
        cell.titleLabel.text = APManager.shared.songs[indexPath.row].title
        cell.image.image = APManager.shared.songs[indexPath.row].image
        return cell
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
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
            present(PlayerVC, animated: true)
        }
    }
    @objc private func tapGesture() {
        present(PlayerVC, animated: true)
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
            button.tintColor = .white
            navigationItem.rightBarButtonItems![1] = button
        }
        else {
            let button = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(edit))
            button.tintColor = .white
            navigationItem.rightBarButtonItems![1] = button
        }
    }
    
    @objc private func timerAction() {
        cancellable = host.rootView.startTimer.sink { [weak self] in
            self?.navigationItem.leftBarButtonItem?.tintColor = .orange
            self?.timerTV = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                if self!.vm.progress > 0 {
                    if self!.vm.progress - 0.00027778 > 0 {
                        self?.vm.progress -= 0.00027778
                        self?.vm.angle = self!.vm.progress * 360
                    } else {
                        self?.vm.progress = 0
                        self?.vm.angle = self!.vm.progress * 360
                        self?.host.rootView.stopTimer.send()
                    }
                }
            }
        }
        anothercanc = host.rootView.stopTimer.sink { [weak self] in
            self?.navigationItem.leftBarButtonItem?.tintColor = .white
            if APManager.shared.isPlaying {
                self?.playerView.playPause()
                APManager.shared.delegatePVC?.pause()
            }
            self?.vm.disabled = false
            self?.vm.buttonLabel = "start"
            self?.timerTV?.invalidate()
            self?.timerTV = nil
        }
        forcedcanc = host.rootView.forcedStopTimer.sink { [weak self] in
            self?.navigationItem.leftBarButtonItem?.tintColor = .white
            self?.timerTV?.invalidate()
            self?.timerTV = nil
        }
        present(host, animated: true)
    }
}

// MARK: DocumentPicker delegate method
extension MediaViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let metadataManager = MetadataManager.shared
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for url in urls {
            let destinationURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)
            DispatchQueue.main.async {
                do { try fileManager.moveItem(at: url, to: destinationURL) } catch {  }
            }
            Task { [weak self] in
                if let metadata = await metadataManager.getMetadataFromURL(selectedUrl: destinationURL) {
                    let imageData = await metadataManager.getImageFromMetadata(metadata: metadata)
                    let artist = await metadataManager.getArtistFromMetadata(metadata: metadata)
                    let title = await metadataManager.getTitleFromMetadata(metadata: metadata)
                    let duration = await metadataManager.getDurationFromUrl(selectedUrl: destinationURL)
                    let fileName = destinationURL.absoluteURL.lastPathComponent
                    let AudioFile = Audio(fileName: fileName,title: title,artist: artist, duration: duration, imageData: imageData)
                    if !APManager.shared.songs.contains(AudioFile) {
                        APManager.shared.songs.insert(AudioFile, at: APManager.shared.songs.count)
                        self?.tableView.insertRows(
                            at: [IndexPath(row: APManager.shared.songs.count - 1, section: 0)],
                            with: .automatic)
                    }
                }
            }
        }
    }
}
// MARK: UI
extension MediaViewController {
    func setupView() {
        overrideUserInterfaceStyle = .dark
        PlayerVC.modalPresentationStyle = .fullScreen
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        addButton.tintColor = .white

        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(edit))
        editButton.tintColor = .white

        let timerButton = UIBarButtonItem(title: nil, image: UIImage(systemName: "timer"), target: self, action: #selector(timerAction))
        timerButton.tintColor = .white
        
        title = "media"

        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = .black
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        navigationController?.navigationBar.prefersLargeTitles = false
        
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItems = [addButton, editButton]
        navigationItem.leftBarButtonItem = timerButton
        
        tableView.allowsSelection = true
        tableView.backgroundColor = .black
        tableView.register(MusicTableViewCell.self, forCellReuseIdentifier: "MusicCell")
        tableView.delegate = self
        tableView.dataSource = self

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeGesture(_:)))
        panGestureRecognizer.cancelsTouchesInView = false
        playerView.addGestureRecognizer(panGestureRecognizer)
        playerView.addGestureRecognizer(tap)

        host.overrideUserInterfaceStyle = .dark
        
        view.addSubview(tableView)
        view.addSubview(playerView)
        
        playerView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.width.equalToSuperview()
            make.height.equalTo(50)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(playerView.snp.top)
        }
    }
}
