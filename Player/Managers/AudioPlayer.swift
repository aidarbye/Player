import Foundation
import AVFoundation

class AudioPlayer {
    static let shared = AudioPlayer()
    var audioPlayer: AVAudioPlayer?
    var currentSong: Audio?
    func playAudio(fileURL: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.prepareToPlay()
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
