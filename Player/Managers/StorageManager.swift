import Foundation

class StorageManager {
    static let shared = StorageManager()
    let key = "musicLibrary"
    let userDefaults = UserDefaults.standard
    func fetchData() -> [Audio] {
        guard let data = userDefaults.object(forKey: key) as? Data else {return []}
        guard let audios = try? JSONDecoder().decode([Audio].self, from: data) else {return []}
        return audios
    }
    func save(songs: [Audio]) {
        guard let data = try? JSONEncoder().encode(songs) else {return}
        userDefaults.setValue(data, forKey: key)
    }
    func delete() {
        
    }
    func edit() {
        
    }
}
