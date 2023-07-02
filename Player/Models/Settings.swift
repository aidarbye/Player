import Foundation

struct Settings: Codable {
    var shuffle: Shuffle
    var repeating: Repeat
}

enum Shuffle: Codable {
    case on, off
}
enum Repeat : Codable {
    case oneSong,off
}

