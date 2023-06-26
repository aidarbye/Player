import Foundation
import AVFoundation
import UIKit

class AudioPlayer: NSObject, AVAudioPlayerDelegate {
    static let shared = AudioPlayer()
    var audioPlayer: AVAudioPlayer?
    var delegate: PlayerViewControllerDelegate?
    var delegatePV: PlayerViewSongControllerProtocol?
    var currentSong: Audio?
    var currentIndex: Int = 0
    var isPlaying: Bool = false
    var songs: [Audio] = []
    
    override init() {
        super.init()
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
        delegatePV?.songChange(song: AudioPlayer.shared.songs[AudioPlayer.shared.currentIndex])
    }
    func playPrevSong() {
        if AudioPlayer.shared.currentIndex == 0 {
            AudioPlayer.shared.currentIndex = AudioPlayer.shared.songs.count - 1
        } else {
            AudioPlayer.shared.currentIndex -= 1
        }
        AudioPlayer.shared.playAudio(fileName:AudioPlayer.shared.songs[AudioPlayer.shared.currentIndex].fileName)
        delegate?.changeSong(song: AudioPlayer.shared.songs[AudioPlayer.shared.currentIndex])
        delegatePV?.songChange(song: AudioPlayer.shared.songs[AudioPlayer.shared.currentIndex])
    }
}
/* MARK: Add later
 func listMP3FilesInDocumentsDirectory() -> [URL] {
     let fileManager = FileManager.default
     let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
     
     do {
         let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
         let mp3FileURLs = fileURLs.filter { $0.pathExtension == "mp3" }
         return mp3FileURLs
     } catch {
         print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
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
