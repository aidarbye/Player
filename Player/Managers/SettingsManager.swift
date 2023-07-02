import Foundation
final class SettingsManager {
    static let shared = SettingsManager()
    var settings: Settings
    init() {
        settings = StorageManager.shared.fetchSettings()
    }
    func nextShuffle() {
        switch settings.shuffle {
        case .on: settings.shuffle = .off
        case .off: settings.shuffle = .on
        }
    }
    func nextRepeat() {
        switch settings.repeating {
        case .off: settings.repeating = .oneSong
        case .oneSong: settings.repeating = .off
        }
    }
}
