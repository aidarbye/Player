import Foundation
import CoreData
import UIKit

struct Audio: Codable, Equatable {
    var fileName: String
    var title: String
    var artist: String
    var duration: Float
    var imageData: Data
    var image: UIImage? { return UIImage(data: imageData) }
}
