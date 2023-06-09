import Foundation
import CoreData

final class Audio: NSManagedObject {
    @NSManaged var filePath: String
    @NSManaged var fileName: String
}
