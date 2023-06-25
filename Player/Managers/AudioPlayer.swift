import Foundation
import AVFoundation
import UIKit

class AudioPlayer: NSObject, AVAudioPlayerDelegate{
    static let shared = AudioPlayer()
    var audioPlayer: AVAudioPlayer?
    var delegate: PlayerViewControllerDelegate?
    var currentSong: Audio?
    var currentIndex: Int = 0
    var isPlaying: Bool = false
    var songs: [Audio] = []
    
    override init() {
        super.init()
        listFilesInDocumentsDirectory()
        songs = StorageManager.shared.fetchData()
        print("initializain of \(self)")
    }
    func playAudio(fileName: String) {
        do {
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let soundFileURL = documentsDirectory.appendingPathComponent(fileName)
            isPlaying = true
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: soundFileURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch let error {
            print(error)
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
        AudioPlayer.shared.playAudio(fileName:AudioPlayer.shared.songs[AudioPlayer.shared.currentIndex].fileName)
        delegate?.changeSong(song: AudioPlayer.shared.songs[AudioPlayer.shared.currentIndex])
    }
    func playPrevSong() {
        if AudioPlayer.shared.currentIndex == 0 {
            AudioPlayer.shared.currentIndex = AudioPlayer.shared.songs.count - 1
        } else {
            AudioPlayer.shared.currentIndex -= 1
        }
        AudioPlayer.shared.playAudio(fileName:AudioPlayer.shared.songs[AudioPlayer.shared.currentIndex].fileName)
        delegate?.changeSong(song: AudioPlayer.shared.songs[AudioPlayer.shared.currentIndex])
    }
    func listFilesInDocumentsDirectory() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            print(fileURLs)
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
    }
}

