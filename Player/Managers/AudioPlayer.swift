import Foundation
import MediaPlayer
import UIKit

// MARK: Pause bug, Seek from remote control, Storage, get all music in files when app loaded
class AudioPlayer: NSObject, UIDocumentPickerDelegate {
    static let shared = AudioPlayer()
    var audioPlayer: AVPlayer?
    var currentIndex: Int?
    var isPlaying: Bool = false
    var songs: [Audio] = []
    
    var delegate: PlayerViewControllerDelegate?
    var delegatePV: PlayerViewSongControllerProtocol?
    
    override init() {
        super.init()
        setupMediaPlayerNotificationView()
    }
    @objc func playerDidFinishPlaying(_ note: NSNotification) {
        playNextSong()
    }
    func playAudio(fileName: String) {
        do {
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let soundFileURL = documentsDirectory.appendingPathComponent(fileName)
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            let item = AVPlayerItem(url: soundFileURL)
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
            audioPlayer = AVPlayer(playerItem: item)
            audioPlayer?.play()
            isPlaying = true
            setupNotificationView(song: songs[currentIndex!])
        } catch let error {
            print(error)
        }
    }
    func playPause() {
        guard currentIndex != nil else { return }
        
        if isPlaying { audioPlayer?.pause() }
        else { audioPlayer?.play() }
        
        isPlaying.toggle()
    }
    
    func playNextSong() {
        guard audioPlayer != nil || songs.isEmpty else { return }
        if AudioPlayer.shared.currentIndex == AudioPlayer.shared.songs.count - 1 {
            AudioPlayer.shared.currentIndex = 0
        } else {
            AudioPlayer.shared.currentIndex? += 1
        }
        AudioPlayer.shared.playAudio(fileName:AudioPlayer.shared.songs[AudioPlayer.shared.currentIndex!].fileName)
        delegate?.changeSong(song: AudioPlayer.shared.songs[AudioPlayer.shared.currentIndex!])
        delegatePV?.songChange(song: AudioPlayer.shared.songs[AudioPlayer.shared.currentIndex!])
    }
    func playPrevSong() {
        guard audioPlayer != nil || songs.isEmpty else { return }
        if AudioPlayer.shared.currentIndex == 0 {
            AudioPlayer.shared.currentIndex = AudioPlayer.shared.songs.count - 1
        } else {
            AudioPlayer.shared.currentIndex? -= 1
        }
        AudioPlayer.shared.playAudio(fileName:AudioPlayer.shared.songs[AudioPlayer.shared.currentIndex!].fileName)
        delegate?.changeSong(song: AudioPlayer.shared.songs[AudioPlayer.shared.currentIndex!])
        delegatePV?.songChange(song: AudioPlayer.shared.songs[AudioPlayer.shared.currentIndex!])
    }
    func setupMediaPlayerNotificationView() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { [unowned self] event in
            self.playPause()
            return .success
        }
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            self.playPause()
            return .success
        }
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            self.playNextSong()
            return .success
        }
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            self.playPrevSong()
            return .success
        }
    }
    func setupNotificationView(song: Audio) {
        let trackTitle = song.title
        let trackImage = song.image
        
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = trackTitle
        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: CGSize(width: 50, height: 50), requestHandler: { _ in
            if let trackImage = trackImage {
                return trackImage
            } else {
                return UIImage(systemName: "music.note")!
            }
        })
        nowPlayingInfo[MPMediaItemPropertyArtist] = song.artist
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = song.duration
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
//    override class func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if object is AVPlayer {
//            switch audioPlayer?.timeControlStatus {
//            case .waitingToPlayAtSpecifiedRate, .paused:
//                nowPlayingInf
//            case .playing:
//            }
//        }
//    }
    /* will add later
    func listMP3FilesInDocumentsDirectory(url: URL) -> [URL] {
        let fileManager = FileManager.default
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            let mp3FileURLs = fileURLs.filter { $0.pathExtension == "mp3" }
            return mp3FileURLs
        } catch {
            print("Error while enumerating files \(url.path): \(error.localizedDescription)")
            return []
        }
    }
    func fetchFromFiles(urls: [URL]) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for url in urls {
            let fileName = url.lastPathComponent
            let destinationURL = documentsDirectory.appendingPathComponent(fileName)
            do {
                try fileManager.moveItem(at: url, to: destinationURL)
                print("Файл успешно перемещен в директорию документов")
                if fileManager.fileExists(atPath: destinationURL.path) {
                    print("Файл существует в директории документов")
                } else {
                    print("Файл не существует в директории документов")
                }
            } catch {
                print("Ошибка перемещения файла: \(error.localizedDescription)")
            }
            Task {
                //MARK: Temporary
                if let metadata = await getMetadataFromURL(selectedUrl: url) {
                    let imageData = await getImageFromMetadata(metadata: metadata)
                    let artist = await getArtistFromMetadata(metadata: metadata)
                    let title = await getTitleFromMetadata(metadata: metadata)
                    let duration = await getDurationFromUrl(selectedUrl: url)
                    let fileName = url.absoluteURL.lastPathComponent
                    let AudioFile = Audio(fileName: fileName,title: title,artist: artist, duration: duration, imageData: imageData)
                    AudioPlayer.shared.songs.insert(AudioFile, at: AudioPlayer.shared.songs.count)
                }
            }
        }
    }
     */
}
