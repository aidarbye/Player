import Foundation
import AVFoundation
import UIKit

class AudioPlayer {
    static let shared = AudioPlayer()
    var delegate = AVdelegate()
    var audioPlayer: AVAudioPlayer?
    var currentSong: Audio?
    var isPlaying: Bool = false
    init() {
        self.audioPlayer?.delegate = self.delegate
        audioPlayer?.prepareToPlay()
        NotificationCenter.default.addObserver(forName: NSNotification.Name("Finish"), object: nil, queue: .main) { (_) in
            self.isPlaying = false
        }
        print("initializain of \(self)")
    }
    
    func playAudio(fileURL: URL) {
        do {
            isPlaying = true
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
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
}
class AVdelegate : NSObject,AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name("Finish"), object: nil)
    }
}
