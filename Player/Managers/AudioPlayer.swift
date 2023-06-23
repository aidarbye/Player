import Foundation
import AVFoundation
import UIKit

class AudioPlayer: NSObject, AVAudioPlayerDelegate{
    static let shared = AudioPlayer()
    var audioPlayer: AVAudioPlayer?
    var currentSong: Audio?
    var delegate: PlayerViewControllerDelegate?
    var currentIndex: Int = 0
    var isPlaying: Bool = false
    var songs: [Audio] = []
    
    override init() {
        super.init()
        audioPlayer?.prepareToPlay()
        print("initializain of \(self)")
    }
    func playAudio(fileURL: URL) {
        do {
            isPlaying = true
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.delegate = self
            audioPlayer?.play()
        } catch {
            print("Ошибка при воспроизведении аудио: \(error.localizedDescription)")
        }
    }
    func pause() {
        audioPlayer?.pause()
    }
    func resume() {
        audioPlayer?.play()
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playNextSong()
    }
    
    func playNextSong() {
        if AudioPlayer.shared.currentIndex == AudioPlayer.shared.songs.count - 1 {
            AudioPlayer.shared.currentIndex = 0
        } else {
            AudioPlayer.shared.currentIndex += 1
        }
            AudioPlayer.shared.playAudio(fileURL:URL(string:AudioPlayer.shared.songs[AudioPlayer.shared.currentIndex].filePath)!)
        delegate?.changeSong(song: AudioPlayer.shared.songs[AudioPlayer.shared.currentIndex])
    }
    func playPrevSong() {
        if AudioPlayer.shared.currentIndex == 0 {
            AudioPlayer.shared.currentIndex = AudioPlayer.shared.songs.count - 1
        } else {
            AudioPlayer.shared.currentIndex -= 1
        }
            AudioPlayer.shared.playAudio(fileURL:URL(string:AudioPlayer.shared.songs[AudioPlayer.shared.currentIndex].filePath)!)
        delegate?.changeSong(song: AudioPlayer.shared.songs[AudioPlayer.shared.currentIndex])
    }
}
