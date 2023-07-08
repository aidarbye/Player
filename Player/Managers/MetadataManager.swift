import Foundation
import AVFoundation

final class MetadataManager {
    static let shared = MetadataManager()
    func getMetadataFromURL(selectedUrl: URL) async -> [AVMetadataItem]? {
        let asset = AVAsset(url: selectedUrl)
        do {
         return try await asset.load(.commonMetadata)
        } catch {
         print(error.localizedDescription)
        }
        return [AVMetadataItem()]
    }
    func getImageFromMetadata(metadata: [AVMetadataItem]) async -> Data {
        do {
            for metadataItem in metadata {
                if metadataItem.commonKey?.rawValue == "artwork" {
                    let data = try await metadataItem.load(.value) as! Data
                    return data
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        return Data()
    }
    func getArtistFromMetadata(metadata: [AVMetadataItem]) async -> String {
        do {
            for metadataItem in metadata {
                if metadataItem.commonKey?.rawValue == "artist" {
                    return try await metadataItem.load(.value) as! String
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        return "NoName"
    }
    func getTitleFromMetadata(metadata: [AVMetadataItem]) async -> String {
        do {
            for metadataItem in metadata {
                if metadataItem.commonKey?.rawValue == "title" {
                    return try await metadataItem.load(.value) as! String
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        return "NoName"
    }
    func getDurationFromUrl(selectedUrl: URL) async -> Float {
        let asset = AVAsset(url: selectedUrl)
        do {
            let duration = try await asset.load(.duration)
            let seconds = CMTimeGetSeconds(duration)
            return Float(seconds)
        } catch {
            print(error.localizedDescription)
        }
        return 0.0
    }
    func listFilesInDocumentDirectory() {
        let fileManager = FileManager.default
        guard let documentDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Document directory not found.")
            return
        }
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentDirectoryURL, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                print(fileURL.lastPathComponent)
            }
        } catch {
            print("Error listing files in document directory: \(error.localizedDescription)")
        }
    }

}
