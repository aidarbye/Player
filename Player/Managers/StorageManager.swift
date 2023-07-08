import Foundation

final class StorageManager {
    static let shared = StorageManager()
    let keyForLibrary = "musicLibrary"
    let keyForSettings = "settings"
    let userDefaults = UserDefaults.standard
    
    func fetchData() -> [Audio] {
        guard let data = userDefaults.object(forKey: keyForLibrary) as? Data else { return [] }
        guard let audios = try? JSONDecoder().decode([Audio].self, from: data)
            else { return [] }
        return audios
    }
    func fetchSettings() -> Settings {
        guard let data = userDefaults.object(forKey: keyForSettings) as? Data else { return Settings(shuffle: Shuffle.off, repeating: Repeat.off)
        }
        guard let settings = try? JSONDecoder().decode(Settings.self, from: data) else {
            return Settings(shuffle: Shuffle.off, repeating: Repeat.off)
        }
        return settings
    }
    
    func save(songs: [Audio]) {
        guard let data = try? JSONEncoder().encode(songs) else {return}
        userDefaults.setValue(data, forKey: keyForLibrary)
    }
    
    func saveSettings(settings: Settings) {
        guard let data = try? JSONEncoder().encode(settings) else {return}
        userDefaults.setValue(data, forKey: keyForSettings)
    }
}
