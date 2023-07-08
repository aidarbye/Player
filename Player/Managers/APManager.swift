import Foundation
import MediaPlayer
import UIKit

final class APManager: NSObject, UIDocumentPickerDelegate {
    static let shared = APManager()
    var audioPlayer: AVPlayer?
    var currentIndex: Int?
    var isPlaying: Bool = false
    var songs: [Audio] = []
    
    var delegatePVC: PlayerViewControllerDelegate?
    var delegatePV: PlayerViewSongControllerProtocol?
    var delegateMVC: MediaViewControllerDelegate?
    
    override init() {
        super.init()
        songs = StorageManager.shared.fetchData()
        setupMediaPlayerNotificationView()
    }
    @objc func playerDidFinishPlaying(_ note: NSNotification) {
        playNextSong()
    }
    
    func playAudio(fileName: String) {
        do {
            removeObservation()
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let soundFileURL = documentsDirectory.appendingPathComponent(fileName)
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            let item = AVPlayerItem(url: soundFileURL)
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
            audioPlayer = AVPlayer(playerItem: item)
            audioPlayer?.play()
            setupObservation()
            isPlaying = true
            setupNotificationView(song: songs[currentIndex!])
        } catch let error { print(error) }
    }
    func playPause() {
        guard currentIndex != nil else { return }
        
        if isPlaying { audioPlayer?.pause() }
        else { audioPlayer?.play() }
        
        isPlaying.toggle()
    }
    func getShuffledIndex() {
        self.currentIndex? = Int.random(in: 0..<self.songs.count)
    }
    func getRepeatingIndex() {
        self.currentIndex? += 0
    }
    func getDefaultNextIndex() {
        if APManager.shared.currentIndex == APManager.shared.songs.count - 1 {
            APManager.shared.currentIndex = 0
        } else {
            APManager.shared.currentIndex? += 1
        }
    }
    func getDefaultPrevIndex() {
        if APManager.shared.currentIndex == 0 {
            APManager.shared.currentIndex = APManager.shared.songs.count - 1
        } else {
            APManager.shared.currentIndex? -= 1
        }
    }
    func playNextSong() {
        guard audioPlayer != nil || songs.isEmpty else { return }
        
        if SettingsManager.shared.settings.shuffle == .off && SettingsManager.shared.settings.repeating == .off {
            getDefaultNextIndex()
        } else if SettingsManager.shared.settings.shuffle == .on && SettingsManager.shared.settings.repeating == .off {
            getShuffledIndex()
        } else {
            getRepeatingIndex()
        }
        
        APManager.shared.playAudio(fileName:APManager.shared.songs[APManager.shared.currentIndex!].fileName)
        delegatePVC?.changeSong(song: APManager.shared.songs[APManager.shared.currentIndex!])
        delegatePV?.songChange(song: APManager.shared.songs[APManager.shared.currentIndex!])
        delegateMVC?.nowSelectedAudio()
    }
    func playPrevSong() {
        guard audioPlayer != nil || songs.isEmpty else { return }
        
        if SettingsManager.shared.settings.shuffle == .off && SettingsManager.shared.settings.repeating == .off {
            getDefaultPrevIndex()
        } else if SettingsManager.shared.settings.shuffle == .on && SettingsManager.shared.settings.repeating == .off {
            getShuffledIndex()
        } else {
            getRepeatingIndex()
        }

        APManager.shared.playAudio(fileName:APManager.shared.songs[APManager.shared.currentIndex!].fileName)
        delegatePVC?.changeSong(song: APManager.shared.songs[APManager.shared.currentIndex!])
        delegatePV?.songChange(song: APManager.shared.songs[APManager.shared.currentIndex!])
        delegateMVC?.nowSelectedAudio()
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
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = song.title
        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: CGSize(width: 50, height: 50), requestHandler: { _ in
            if let trackImage = song.image {
                return trackImage
            } else {
                return UIImage(systemName: "music.note")!
            }
        })
        nowPlayingInfo[MPMediaItemPropertyArtist] = song.artist
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = song.duration
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    func updateNowPlayingInfo(song: AVPlayerItem) {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPNowPlayingInfoPropertyElapsedPlaybackTime: song.currentTime(),
            MPNowPlayingInfoPropertyPlaybackRate: 1,
            MPMediaItemPropertyPlaybackDuration: song.duration
        ]
    }
    func setupObservation() {
        audioPlayer?.addObserver(self, forKeyPath: "timeControlStatus", options: [.new, .old], context: nil)
    }
    func removeObservation() {
        audioPlayer?.removeObserver(self, forKeyPath: "timeControlStatus")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus" {
            if object is AVPlayer {
                if let newStatus = change?[.newKey] as? Int {
                    let newTimeControlStatus = AVPlayer.TimeControlStatus(rawValue: newStatus)
                    handleTimeControlStatusChange(newStatus: newTimeControlStatus)
                }
            }
        }
    }
    func handleTimeControlStatusChange(newStatus: AVPlayer.TimeControlStatus?) {
        if let newStatus = newStatus {
            var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
            switch newStatus {
            case .playing:
                nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
                nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer!.currentTime().seconds
            case .waitingToPlayAtSpecifiedRate, .paused:
                nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0
                nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer!.currentTime().seconds
            @unknown default:
                fatalError("Неизвестный статус воспроизведения")
            }
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
    }
}
